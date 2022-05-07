//+------------------------------------------------------------------+
//|                         SupportAndResistanceTrendlinesSystem.mq5 |
//|                                                              gfx |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "gfx"
#property link      "https://www.mql5.com"
#property version   "1.00"



input double InpLots       = 0.1;

//input int    InpTpPoints   = 1000;
//input int    InpSlPoints   = 1000;

input double   InpProfitPct         =  100.0;   // Take profit % of range (ATR*Multiplier)
input double   InpLossPct           =  100.0;   // Stop loss as % of range (ATR*Multiplier)

input int      InpAtrMulti = 3; // gAtrMulti (ATR multiplier. ex: *3 the ATR)


#define APP_COMMENT "SupportAndResistanceTrendlinesSystem"
input string   InpTradeComment = APP_COMMENT; //	Trade comment




#include <Trade/Trade.mqh>
CTrade Trade;

double lastBid = 0;

double gAtr = 0;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{



   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{


   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{

/*
int atrHandle = iATR(Symbol(), Period(), 5);   
double atr[];
CopyBuffer(atrHandle,0,0,2,atr); // copy atr[0], atr[1] (2 places)

gAtr = atr[0]; // gAtr = iATR(Symbol(), Period(), 100, 1);

Print(gAtr);
*/

   if(PositionsTotal()!=0) // there is an open position (only 1 position at a time is alowed)
      return;


   double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);

   for(int i=ObjectsTotal(0,0,OBJ_TREND)-1; i>=0; i--) // run on all Trendline objects that are on the chart
   {   
      string name = ObjectName(0,i,0,OBJ_TREND); // catch the name of the current(i)  trendline
      
      if(StringFind(name, "RSLines") > -1) // there is a string "RSLines" within the name of the current trendline. meaning this trendline is relevant (draw by the SR indicator that is on the chart)
      {
      
         double TlPrice = ObjectGetDouble(0,name,OBJPROP_PRICE);           // get the price of the SupportResistanceTrendline
         color  TlColor = (color)ObjectGetInteger(0,name,OBJPROP_COLOR);   // get the color of the SupportResistanceTrendline
         
         if(TlColor == clrRed) // Support trendline. 
         {  
            if(lastBid >= TlPrice && bid<TlPrice && lastBid!=0) // Buy (price has cross support trendline from above to below)
            {
               OpenPosition(ORDER_TYPE_BUY);
            }
            
         
         }
         
         else if (TlColor == clrGreen) // Resistance trendline. 
         {
            if(lastBid <= TlPrice && bid>TlPrice && lastBid!=0) // Short (price has cross resistance trendline from below to above)
            {
               OpenPosition(ORDER_TYPE_SELL);            
            }         
         
         
         }
      
      }

      if(PositionsTotal()!=0) // position was open during the for loop. No need to continue checking the other trendlines
      {
         lastBid = 0; // to prevent checking the case of lastBid that was long ago before a position was open, and current bid that is after a position is close
         return;
      }
      
   }
   
   lastBid = bid;

   
}
//+------------------------------------------------------------------+





double OpenPosition( ENUM_ORDER_TYPE type ) {

   int atrHandle = iATR(Symbol(), Period(), 200);   
   double atr[];
   CopyBuffer(atrHandle,0,0,2,atr); // copy atr[0], atr[1] (2 places) // positions are in an opposite location from MQL4

   gAtr = atr[0]; // gAtr = iATR(Symbol(), Period(), 100, 1); // atr[0] is actually atr[1] in MQL4

   // entry price
   double entryPrice = ( type == ORDER_TYPE_BUY ) ? SymbolInfoDouble( _Symbol, SYMBOL_ASK )
                                                  : SymbolInfoDouble( Symbol(), SYMBOL_BID );
  
   entryPrice = NormalizeDouble(entryPrice, _Digits);                                             


   // sl
   double sl    = (type==ORDER_TYPE_BUY) ? (entryPrice-gAtr*InpAtrMulti*InpLossPct/100) 
                                         : (entryPrice+gAtr*InpAtrMulti*InpLossPct/100);//*InpRatio); // sl is bigger than tp
                                    
   sl           = NormalizeDouble(sl, Digits());

   
   // tp   
   double tp    = (type==ORDER_TYPE_BUY) ? (entryPrice+gAtr*InpAtrMulti*InpProfitPct/100) 
                                         : (entryPrice-gAtr*InpAtrMulti*InpProfitPct/100); 
   
   tp           = NormalizeDouble(tp, Digits());
   
   
   
      

                                             
   //if ( Trade.PositionOpen( Symbol(), type, InpLots, entryPrice, 0, 0, InpTradeComment ) ) {
   if ( Trade.PositionOpen( Symbol(), type, InpLots, entryPrice, sl, tp, InpTradeComment ) ) {
      return ( Trade.ResultPrice() );
   }
   
   
   return ( 0 );
}
