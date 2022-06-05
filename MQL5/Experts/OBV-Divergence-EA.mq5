//+------------------------------------------------------------------+
//|                                            OnBalanceVolumeEA.mq5 |
//|                                                              gfx |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "gfx"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade/Trade.mqh>

input int                   InpVerificationCandles = 20;

input ENUM_APPLIED_VOLUME   InpAppVolume           = VOLUME_TICK;   

input int                   MaxTimeGapCandles      = 5;

input double   InpProfitPct         =  100.0;   // Take profit % of range (ATR*Multiplier)
input double   InpLossPct           =  100.0;   // Stop loss as % of range (ATR*Multiplier)

input int      InpAtrMulti = 3; // gAtrMulti (ATR multiplier. ex: *3 the ATR)

input double   InpLots       = 0.1;
input string   InpTradeComment = "OBV DIVERGENCE"; //	Trade comment



int handleObv;
int atrHandle;

// store the values of last 2 highs/lows of price and OBV
double low1, low2, high1, high2;
datetime timeLow1, timeLow2, timeHigh1, timeHigh2;
double lowObv1, lowObv2, highObv1, highObv2;
datetime timeLowObv1, timeLowObv2, timeHighObv1, timeHighObv2;

bool openedPositionLong = false;
bool openedPositionShort = false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{

   handleObv = iOBV(Symbol(), Period(), InpAppVolume);
   
   atrHandle = iATR(Symbol(), Period(), 200);//200);   

   if (handleObv == INVALID_HANDLE || atrHandle == INVALID_HANDLE)
   {
      Print("Failed to create indicator handles");
      return(INIT_FAILED);
   }

   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{

   IndicatorRelease(handleObv);
   IndicatorRelease(atrHandle);
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{

   if(!NewBar())  return;
   
   datetime newTime = 0;
   double newLow = 0;
   double newHigh = 0;   
   findHighLow(newLow, newHigh, newTime);
 
   datetime newTimeObv = 0;   
   double newLowObv = 0;
   double newHighObv = 0;      
   findHighLowObv(newLowObv, newHighObv, newTimeObv); 
   
   //
   // checking for divergence on the lows
   //
   if(newLow != 0) // there is new Low on the chart. need to update the global variables
   {
      low2 = low1;
      timeLow2 = timeLow1;
      low1 = newLow;
      timeLow1 = newTime;
      openedPositionLong = false; // we can open position for this divergence
   }
   
   if(newLowObv != 0) // there is new Low on the OBVchart. need to update the global variables
   {
      lowObv2 = lowObv1;
      timeLowObv2 = timeLowObv1;      
      lowObv1 = newLowObv;
      timeLowObv1 = newTimeObv;  
   }
   
   ulong timeGap = MaxTimeGapCandles * PeriodSeconds(PERIOD_CURRENT);
   
   // checking for devirgence on the lows prices/OBV
   if(low1 < low2 && lowObv1 > lowObv2 
      && (ulong)MathAbs(timeLow1 - timeLowObv1) < timeGap // checking when the lows occurs ar price and OBV
      && (ulong)MathAbs(timeLow2 - timeLowObv2) < timeGap // checking when the lows occurs ar price and OBV
      && low2 != 0 && lowObv2 != 0) // low2 != 0 , so we verify there are at least 2 lows (and same for OBV)
   {
      Print(__FUNCTION__, " > New buy signal...", " , openedPositionLong =", openedPositionLong);   
      if (openedPositionLong == false) // we did not already open position for this divergence      
      {
         Print(__FUNCTION__, " > New buy signal...");
         OpenPosition(ORDER_TYPE_BUY);   
         openedPositionLong = true; // indicate that we opened position for this divergence   
      }
   }
   
   
   //
   // checking for divergence on the highs
   //
   if(newHigh != 0) // there is new High on the chart. need to update the global variables
   {
      high2 = high1;
      timeHigh2 = timeHigh1;      
      high1 = newHigh;
      timeHigh1 = newTime; 
      openedPositionShort = false; // we can open position for this divergence           
   }
   
   if(newHighObv != 0) // there is new high on the OBVchart. need to update the global variables
   {
      highObv2 = highObv1;
      timeHighObv2 = timeHighObv1;            
      highObv1 = newHighObv;
      timeHighObv1 = newTimeObv;  
      
   }
   
   // checking for devirgence on the highs prices/OBV
   if(high1 > high2 && highObv1 < highObv2 
      && (ulong)MathAbs(timeHigh1 - timeHighObv1) < timeGap // checking when the lows occurs ar price and OBV
      && (ulong)MathAbs(timeHigh2 - timeHighObv2) < timeGap // checking when the lows occurs ar price and OBV
      && high2 != 0 && highObv2 != 0) // high2 != 0 , so we verify there are at least 2 highs
   {
      Print(__FUNCTION__, " > New sell signal...", " , openedPositionShort =", openedPositionShort);
      if (openedPositionShort == false) // we did not already open position for this divergence
      {
         //Print(__FUNCTION__, " > New sell signal...");
         OpenPosition(ORDER_TYPE_SELL);  
         openedPositionShort = true; // indicate that we opened position for this divergence          
      }
   }
   

   
}
//+------------------------------------------------------------------+






void findHighLowObv(double &newLowObv, double &newHighObv, datetime &newTimeObv)
{

   int indexBar = InpVerificationCandles; // InpVerificationCandles+1;
   
   double obv[];
//ArraySetAsSeries(obv, true);   
   int numBars = InpVerificationCandles*2 + 1;
   if (CopyBuffer(handleObv, 0, 1, numBars, obv) < numBars) return;

   double obvValue = obv[indexBar];
   
   datetime time = iTime(Symbol(), Period(), indexBar+1);

   bool isHigh = true;      
   bool isLow  = true;
      
   for (int i = 1; i <= InpVerificationCandles; i++)
   {
      double valLeft  = obv[indexBar+i];
      double valRight = obv[indexBar-i];
      
      if(valLeft > obvValue || valRight > obvValue) isHigh = false; // indexBar is not the highest
 
      
      if(valLeft < obvValue || valRight < obvValue) isLow = false; // indexBar is not the lowest
      
      if(!isHigh && !isLow) break; // indexBar is not the highest and not the lowest (there are bars that are higher and bars that are lower)    
      
      if(i == InpVerificationCandles) // we run at all the for loop, and we did not break, so we found the Highest/Lowest bar
      {
         if(isHigh)
         {
            Print(__FUNCTION__, " > Found a new OBV_high (", DoubleToString(obvValue, Digits()), ") at", time, "...");
            ObjectCreate(0, "OBV_High@"+TimeToString(time),OBJ_ARROW_SELL, 1, time, obvValue);
            newHighObv = obvValue;      
            newTimeObv = time;   
         }

         if(isLow)
         {
            Print(__FUNCTION__, " > Found a new OBV_low (", DoubleToString(obvValue, Digits()), ") at", time, "...");         
            ObjectCreate(0, "OBV_Low@"+TimeToString(time),OBJ_ARROW_BUY, 1, time, obvValue);
            newLowObv = obvValue;
            newTimeObv = time;           
         }      
      
      }   
   
   }

}





void findHighLow(double &newLow, double &newHigh, datetime &newTime)
{

   int indexBar = InpVerificationCandles+1;
   
   double high   = iHigh(Symbol(), Period(), indexBar);
   double low    = iLow(Symbol(), Period(), indexBar);
   datetime time = iTime(Symbol(), Period(), indexBar);

   bool isHigh = true;      
   bool isLow  = true;
      
   for (int i = 1; i <= InpVerificationCandles; i++)
   {
      double highLeft  = iHigh(Symbol(), Period(), indexBar+i);
      double highRight = iHigh(Symbol(), Period(), indexBar-i);
      
      if(highLeft > high || highRight > high) isHigh = false; // indexBar is not the highest
       
      double lowLeft   = iLow(Symbol(), Period(), indexBar+i);
      double lowRight  = iLow(Symbol(), Period(), indexBar-i);
      if(lowLeft < low || lowRight < low) isLow = false; // indexBar is not the lowest
      
      if(!isHigh && !isLow) break; // indexBar is not the highest and not the lowest (there are bars that are higher and bars that are lower)    
      
      if(i == InpVerificationCandles) // we run at all the for loop, and we did not break, so we found the Highest/Lowest bar
      {
         if(isHigh)
         {
            Print(__FUNCTION__, " > Found a new high (", DoubleToString(high, Digits()), ") at", time, "...");
            ObjectCreate(0, "High@"+TimeToString(time),OBJ_ARROW_SELL, 0, time, high);
            newHigh = high; 
            newTime = time;          
         }

         if(isLow)
         {
            Print(__FUNCTION__, " > Found a new low (", DoubleToString(low, Digits()), ") at", time, "...");         
            ObjectCreate(0, "Low@"+TimeToString(time),OBJ_ARROW_BUY, 0, time, low);
            newLow = low;  
            newTime = time;                   
         }
      
      
      }
   
   
   }



}






//----------
bool NewBar()
{
   static datetime prevTime = 0;
   datetime        now      = iTime(Symbol(), Period(),0);
   if (prevTime==now) return(false);
   prevTime = now;
   return (true);

}
//-------------





double OpenPosition( ENUM_ORDER_TYPE type ) {

   //int atrHandle = iATR(Symbol(), Period(), 20);//200);   
   double atr[];
   ArraySetAsSeries(atr, true); // so it will match the location of bars, as MQL4(by default it is reverse)
   //CopyBuffer(atrHandle,0,0,2,atr); // copy atr[0], atr[1] (2 places) // positions are in an opposite location from MQL4
   int CopyBufferSucceed = CopyBuffer(atrHandle,0,0,2,atr); // copy atr[0], atr[1] (2 places) 
   if (CopyBufferSucceed < 2)//
   {
      Print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& Falied to CopyBuffer(atrHandle.  atrHandle = ", atrHandle, "    , Copied bar = ", CopyBufferSucceed);
      return -1;
   }

   double Atr = atr[1]; // gAtr = iATR(Symbol(), Period(), 100, 1); 

   // entry price
   double entryPrice = ( type == ORDER_TYPE_BUY ) ? SymbolInfoDouble( _Symbol, SYMBOL_ASK )
                                                  : SymbolInfoDouble( Symbol(), SYMBOL_BID );
  
   entryPrice = NormalizeDouble(entryPrice, _Digits);                                             


   // sl
   double sl    = (type==ORDER_TYPE_BUY) ? (entryPrice-Atr*InpAtrMulti*InpLossPct/100) 
                                         : (entryPrice+Atr*InpAtrMulti*InpLossPct/100);//*InpRatio); // sl is bigger than tp
                                    
   sl           = NormalizeDouble(sl, Digits());

   
   // tp   
   double tp    = (type==ORDER_TYPE_BUY) ? (entryPrice+Atr*InpAtrMulti*InpProfitPct/100) 
                                         : (entryPrice-Atr*InpAtrMulti*InpProfitPct/100); 
   
   tp           = NormalizeDouble(tp, Digits());
   
   Print("====================entryPrice=",entryPrice, "  sl=", sl,  "  tp=", tp);   
            
   CTrade Trade;
                                             
   //if ( Trade.PositionOpen( Symbol(), type, InpLots, entryPrice, 0, 0, InpTradeComment ) ) {
   if ( Trade.PositionOpen( Symbol(), type, InpLots, entryPrice, sl, tp, InpTradeComment ) ) {
      return ( Trade.ResultPrice() );
   }
   
   
   return ( 0 );
}
