//+------------------------------------------------------------------+
//|                                               UseCustomArrow.mq4 |
//|                                                              gfx |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "gfx"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


//https://www.youtube.com/watch?v=RRrMRY1gX8o&ab_channel=OrchardForex

// 6-3-2022 - created

/* 
   Trading Rules
   
   Base on the scanner.
   
   Current timeframe need to be outside the Boolinger Bands, 2 Higher timeframes Linear Regression need to point in the same direction
      
*/



// Some inputs
/*
// Moving average
input int                InpMAPeriod          =  200;          // MA period
input ENUM_MA_METHOD     InpMAMethod          =  MODE_SMA;     // MA Method
input ENUM_APPLIED_PRICE InpMAAppliedPrice    =  PRICE_CLOSE;  // MA Applied Price
*/
/*
// MACD inputs iMACD
input int                   InpMACDFastPeriod   =   12;           // MACD Fast Period
input int                   InpMACDSlowPeriod   =   26;           // MACD Slow Period
input int                   InpMACDSignalPeriod =   9;            // MACD Signal Period
input ENUM_APPLIED_PRICE    InpMACDAppliedPrice =   PRICE_CLOSE;  // MACD Applied Price

// Stochastics
input int                   InpStochKPeriod     =   70;           // Stochastics K Period
input int                   InpStochDPeriod     =   10;           // Stochastics D Period
input int                   InpStochSlowPeriod  =   10;           // Stochastics Slowing Period
*/

/*
// For the swing high and low
input int                InpSwingLookback     = 20;            // Swing lookback
*/

// Standard Deviation
//input int                InpLinearRegPeriod   = 200;           // LR Period

// For the tp/sl
//input double             InpRatio             = 5;//1.25;          // P/L ratio


// Dunchian input 
extern int    InpBarsBack   =  1;

input int                InpLinearRegPeriod   = 20;           // LR Period



// Standard trading inputs
input double             InpVolume         =  0.01;            // Trade lot size
input int                InpMagicNumber    =  212121;          // Magic number
input string             InpTradeComment   =  __FILE__;        // Trade comment


/*
//Medium MA
input int                InpMediumPeriods   = 50;          // Medium Periods
input ENUM_MA_METHOD     InpMediumMethod    = MODE_SMA;    // Medium method
input ENUM_APPLIED_PRICE InpMediumPrice     = PRICE_CLOSE; // Medium price


//ADX
extern int    InpAdxPeriod  =  50;//25;
extern int    InpAdxPrice   = PRICE_CLOSE;
extern int    InpAdxLevel   =  40;// Adx Level 
*/

input int                InpMaxOpenPositions = 1;


int gLastOpenPositionTicket = 0;

double gLastOpenPositionPrice = 0;

double gAtr = 0;

input int InpAtrMulti = 3; // gAtrMulti

input double InpAddPositionMulti = 1.00; // When to add to position, with relevant to (gAtr*InpAtrMulti)

//int gCountRound = 0;

//ENUM_ORDER_TYPE gPositionDirection;

//input double InpStandardDeviation = 2.9;

//input int InpNumMartingaleRounds = 8;

//double  gDollarProfit = 0;

input double InpMinProfit = 100000.00; // Profit in base currency

input double InpMaxSpreadInPoints = 70.00;

double gAdjustedLots = 0;

bool gIsActiveBasket = false;

//ENUM_ORDER_TYPE LongOrShort = -1; 


// Exit prices as a precentage of InpAtrMulti
input double   InpProfitPct         =  100.0;   // Take profit % of range
input double   InpLossPct           =  100.0;   // Stop loss as % of range


input string InpCustomIndicator = "NO REPAINT ARROWS";

input bool   InpUseInverseSignal = true;


struct STradeSum
{
   int count;
   double profit;
   double trailPrice;

};

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
//Print("OnInit11111111111111===============iTime = ", iTime(Symbol(),Period(),1));  
//Print("OnInit11111111111111===============InpStandardDeviation = ", InpStandardDeviation);
   NewBar(); // Just sets up prev time to avoid trading when first opened  (12:50 at youtube video)
/*   
   gAtr = iATR(Symbol(), Period(), 100, 1);
   double atrInPoints = AtrInPoints(gAtr, Symbol());
   double pointValue = PointValue(Symbol());

   //gDollarProfit = pointValue*InpVolume*atrInPoints; 
   
   gAdjustedLots = InpMinProfit/(pointValue*atrInPoints);
*/   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

/*
if (AccountBalance()-AccountEquity()>3000)
{
CloseOpenPositions();
}


   static int ConditionPriceFastMA = 0;
*/
//Print("OnTick11111111111111===============iTime = ", iTime(Symbol(),Period(),1));  
   //ENUM_ORDER_TYPE LongOrShort = 0; // int LongOrShort = 0;
   
   
   // is trading allowed
   if (!CanTrade()) return;   


   int numOpenPositions = TradeCount();
   
   if (gIsActiveBasket==true) 
   {  
      //=ManageOpenPositions();
      //=return;       
   }   
   
   
   if (!NewBar()) //=return; // Only trade once per bar
   {
      //if (gLastOpenPositionTicket!=0) // there are open positions that need to be managed
      //=if (numOpenPositions!=0) // there are open positions that need to be managed      
         //=ManageOpenPositions(); 
         
      return;     
   }
   
//Print("OnTick===============iTime = ", iTime(Symbol(),Period(),1));     

//Print(" TradeCount =" , TradeCount(), "   InpMaxOpenPositions =", InpMaxOpenPositions); 
//   if (numOpenPositions >= InpMaxOpenPositions)  return; // exeeced max positions
      

   if (Ask-Bid > InpMaxSpreadInPoints) return; // spread is too wide (future update: need to check digits for Gold)

   // Grab the relevant values
   
   int ConditionCustomIndicator = CheckConditionCustomIndicator();
   //int ConditionMACD = CheckConditionMACD(); // CheckConditionOSMA(); // CheckConditionMACD();
   //int ConditionOSMA = CheckConditionOSMA();


      if (   ConditionCustomIndicator == 1 
            //=&& LongOrShort != ORDER_TYPE_BUY // we already have an open buy position
            //&& LongOrShort != ORDER_TYPE_SELL // we already have an open sell position

          //&& ConditionOSMA == 1 
          )
          {   
            //=LongOrShort = ORDER_TYPE_BUY; // 1; 
            //LongOrShort = ORDER_TYPE_SELL; // 1; 
            //=gAtr = iATR(Symbol(), Period(), 100, 1); 
            CloseAllOpenPositions();
            if(InpUseInverseSignal==false)
               OpenTrade(ORDER_TYPE_BUY);
            else
               OpenTrade(ORDER_TYPE_SELL);   
            // OpenTradePending(ORDER_TYPE_BUY_STOP);//=OpenTradePending(ORDER_TYPE_SELL_LIMIT);//OpenTradePending(ORDER_TYPE_BUY_STOP);//OpenTrade(ORDER_TYPE_BUY);                                                 
            //OpenTrade(ORDER_TYPE_BUY);//OpenTrade(ORDER_TYPE_SELL);                                                 
            //=gIsActiveBasket = true;
            
          }


      if (   ConditionCustomIndicator == -1 
            //=&& LongOrShort != ORDER_TYPE_SELL // we already have an open sell position      
            //&& LongOrShort != ORDER_TYPE_BUY // we already have an open buy position      
          //&& ConditionOSMA == -1 
          )
          {           
            //=LongOrShort = ORDER_TYPE_SELL; // -1; 
            //LongOrShort = ORDER_TYPE_BUY; // -1; 
            //=gAtr = iATR(Symbol(), Period(), 100, 1);              
            CloseAllOpenPositions();            
            if(InpUseInverseSignal==false)
               OpenTrade(ORDER_TYPE_SELL);
            else
               OpenTrade(ORDER_TYPE_BUY);   

            //OpenTrade(ORDER_TYPE_SELL); //OpenTradePending(ORDER_TYPE_SELL_STOP);//=OpenTradePending(ORDER_TYPE_BUY_LIMIT);//OpenTradePending(ORDER_TYPE_SELL_STOP);//OpenTrade(ORDER_TYPE_SELL);  
            //OpenTrade(ORDER_TYPE_SELL);//OpenTrade(ORDER_TYPE_BUY);
            //=gIsActiveBasket = true;                                                                                                
          }

/*
      //if (LongOrShort!=0)
      if (LongOrShort==ORDER_TYPE_BUY || LongOrShort==ORDER_TYPE_SELL)      
      {
         OpenTrade(LongOrShort);
         /*
         if (OpenTrade(LongOrShort)>0) // succeeded open position
         {
            //ConditionPriceFastMA  = 0; 
         } 
                                
      }
*/



   //}

   
  }
//+------------------------------------------------------------------+




int CheckConditionCustomIndicator()
{

   int returnValue = 0;

   int bufferNumber2 = 2; // buffer number for up arrows (blue arrows)
   int bufferNumber3 = 3; // buffer number for down arrows (red arrows)
   
   double checkBufferNumber2 = iCustom(NULL,0,InpCustomIndicator,bufferNumber2,1);
   double checkBufferNumber3 = iCustom(NULL,0,InpCustomIndicator,bufferNumber3,1);
   
   if(checkBufferNumber2 != EMPTY_VALUE )
      returnValue = 1;
   else if(checkBufferNumber3 != EMPTY_VALUE )
      returnValue = -1;


   return returnValue;

}





//----------------
int CheckConditionMTFLinBB()
{
/*
   double adx = iADX(Symbol(), Period(),InpAdxPeriod, InpAdxPrice,0,1);;
   double mediumMA1 = iMA(Symbol(), Period(), InpMediumPeriods, 0, InpMediumMethod, InpMediumPrice, 1);        
   double close1 = iClose(Symbol(), Period(), 1);  
       
   
   if (adx >= InpAdxLevel && close1 > mediumMA1) 
      return -1;

   if (adx >= InpAdxLevel && close1 < mediumMA1) 
      return 1;



   double close0 = iClose(Symbol(), Period(), 0);  // current active price
   //Bid

   double DonchainSlowHi1=iCustom(Symbol(),Period(),     "Double Donchian",     InpDunchian_Period_For_Entry,12,       0,   1);  //0=high1 line
   double DonchainSlowLo1=iCustom(Symbol(),Period(),     "Double Donchian",     InpDunchian_Period_For_Entry,12,       2,   1);  //2=low1 line
*/
   //double DonchainFastHi1=iCustom(Symbol(),Period(),     "Double Donchian",     InpDunchian_Period_For_Entry,12,       3,   0);  //0=high1 line
   //double DonchainFastLo1=iCustom(Symbol(),Period(),     "Double Donchian",     InpDunchian_Period_For_Entry,12,       5,   0);  //2=low1 line

//Print("Bid = ", Bid, "   DonchainSlowHi1 = ",DonchainSlowHi1, "  DonchainSlowLo1 = ", DonchainSlowLo1, "    DonchainFastHi1 = ",DonchainFastHi1, "  DonchainFastLo1 = ", DonchainFastLo1); 


   int returnValue = 0;

   double BBLower = 0;
   double BBHigher = 0;
   double Price_short_tf = 0;

   //==double Cur_custom_indicator_medium_tf = 0;   
   double Cur_custom_indicator_long_tf = 0;   


//input int InpLRShortTFLength = 20;
int InpLRMediumTFLength = 10;
int InpLRLongTFLength = 5;

int bars_back = 0;

// Assuming 4H TF trading
   Price_short_tf = iClose(Symbol(),Period(),InpBarsBack); // closing price of previous bar                  
   BBLower = iBands(Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_LOWER,InpBarsBack); 
   BBHigher = iBands(Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_UPPER,InpBarsBack); 
   
   /*
   Cur_custom_indicator_medium_tf = iCustom(Symbol(),PERIOD_D1,"linear regression slope",20,0,1,0,    0,InpBarsBack/6 + 1); // 20linear regression slope(1),-shift1 //mql4 file     
   Cur_custom_indicator_long_tf = iCustom(Symbol(),PERIOD_W1,"linear regression slope",20,0,1,0,    0,InpBarsBack/30 + 1); // 20linear regression slope(1),-shift1 //mql4 file                       
   */
//==   Cur_custom_indicator_medium_tf = iCustom(Symbol(),PERIOD_D1,"linear regression slope",InpLRMediumTFLength,0,1,0,    0,1+bars_back); // 20linear regression slope(1),-shift1 //mql4 file     
//==   Cur_custom_indicator_long_tf = iCustom(Symbol(),PERIOD_W1,"linear regression slope",InpLRLongTFLength,0,1,0,    0,1+bars_back); // 20linear regression slope(1),-shift1 //mql4 file                       

   double Price_rel_to_Median_Line_short_tf = iClose(Symbol(),PERIOD_H4,1+bars_back); // closing price of previous bar         
   //double Cur_custom_indicator__Median_Line_medium_tf = iCustom(Symbol(),PERIOD_D1,"uLinRegrBuf",true,InpLRMediumTFLength,    0,1+bars_back); // 20linear regression line(1),-shift1 //mql4 file     
   //double Cur_custom_indicator__Lower_Line_medium_tf = iCustom(Symbol(),PERIOD_D1,"uLinRegrBuf",true,InpLRMediumTFLength,    1,1+bars_back); // 20linear regression line(1),-shift1 //mql4 file     
   //double Cur_custom_indicator__Higher_Line_medium_tf = iCustom(Symbol(),PERIOD_D1,"uLinRegrBuf",true,InpLRMediumTFLength,    2,1+bars_back); // 20linear regression line(1),-shift1 //mql4 file     
//   double Cur_custom_indicator__Median_Line_medium_tf=iCustom(Symbol(),PERIOD_D1,     "StandardDeviationChannel",     1+bars_back,InpLRMediumTFLength,1.0,1.0,       0,   1+bars_back);  //1=high1 line
//   double Cur_custom_indicator__Higher_Line_medium_tf=iCustom(Symbol(),PERIOD_D1,     "StandardDeviationChannel",     1+bars_back,InpLRMediumTFLength,2.0,2.0,       3,   1+bars_back);  //1=high1 line
//   double Cur_custom_indicator__Lower_Line_medium_tf=iCustom(Symbol(),PERIOD_D1,     "StandardDeviationChannel",     1+bars_back,InpLRMediumTFLength,2.0,2.0,       4,   1+bars_back);  //2=low1 line
  


   int                InpMACDFastMAPeriod  =  12;           // MACD Fast MA period
   int                InpMACDSlowMAPeriod  =  26;           // MACD Slow MA period
   int                InpMACDSignalPeriod  =  9;            // MACD Signal line period
   ENUM_APPLIED_PRICE InpMACDAppliedPrice  =  PRICE_CLOSE;  // MACD Price

   double macdMain1 = iMACD(Symbol(),PERIOD_H4, InpMACDFastMAPeriod, InpMACDSlowMAPeriod, InpMACDSignalPeriod, InpMACDAppliedPrice, MODE_MAIN, InpBarsBack);
   double macdMain2 = iMACD(Symbol(),PERIOD_H4, InpMACDFastMAPeriod, InpMACDSlowMAPeriod, InpMACDSignalPeriod, InpMACDAppliedPrice, MODE_MAIN, InpBarsBack+1);
   double macdMain3 = iMACD(Symbol(),PERIOD_H4, InpMACDFastMAPeriod, InpMACDSlowMAPeriod, InpMACDSignalPeriod, InpMACDAppliedPrice, MODE_MAIN, InpBarsBack+2);

   double macdSig1 = iMACD(Symbol(),PERIOD_H4, InpMACDFastMAPeriod, InpMACDSlowMAPeriod, InpMACDSignalPeriod, InpMACDAppliedPrice, MODE_SIGNAL, InpBarsBack);
   double macdSig2 = iMACD(Symbol(),PERIOD_H4, InpMACDFastMAPeriod, InpMACDSlowMAPeriod, InpMACDSignalPeriod, InpMACDAppliedPrice, MODE_SIGNAL, InpBarsBack+1);


/*
//pullback to MA20,50 Pointing the same direction strategy

if(iMA(Symbol(),Period(),20,0,MODE_SMA,PRICE_CLOSE,1)>iMA(Symbol(),Period(),50,0,MODE_SMA,PRICE_CLOSE,1))//ma20>ma50
if(iMA(Symbol(),Period(),20,0,MODE_SMA,PRICE_CLOSE,1)>iMA(Symbol(),Period(),20,0,MODE_SMA,PRICE_CLOSE,2))//ma 20 pointing up
if(iMA(Symbol(),Period(),50,0,MODE_SMA,PRICE_CLOSE,1)>iMA(Symbol(),Period(),50,0,MODE_SMA,PRICE_CLOSE,2))//ma 50 pointing up
if(Close[2]>iMA(Symbol(),Period(),20,0,MODE_SMA,PRICE_CLOSE,2))//price was above ma20
if(Open[2]>iMA(Symbol(),Period(),20,0,MODE_SMA,PRICE_CLOSE,2))//price was above ma20
if(Close[1]<iMA(Symbol(),Period(),20,0,MODE_SMA,PRICE_CLOSE,1))//price is below ma20
if(Close[1]>iMA(Symbol(),Period(),50,0,MODE_SMA,PRICE_CLOSE,1))//price is NOT below ma50(price above ma50)
if(Low[1]>iMA(Symbol(),Period(),50,0,MODE_SMA,PRICE_CLOSE,1))//price is NOT touching ma50(price above ma50)
if (CheckJimdandy()==1)
//if (Cur_custom_indicator_medium_tf>0.00026) // Higher TF pointing UP
   return 1;//-1;//1;
   
if(iMA(Symbol(),Period(),20,0,MODE_SMA,PRICE_CLOSE,1)<iMA(Symbol(),Period(),50,0,MODE_SMA,PRICE_CLOSE,1))//ma20<ma50
if(iMA(Symbol(),Period(),20,0,MODE_SMA,PRICE_CLOSE,1)<iMA(Symbol(),Period(),20,0,MODE_SMA,PRICE_CLOSE,2))//ma 20 pointing down
if(iMA(Symbol(),Period(),50,0,MODE_SMA,PRICE_CLOSE,1)<iMA(Symbol(),Period(),50,0,MODE_SMA,PRICE_CLOSE,2))//ma 50 pointing down
if(Close[2]<iMA(Symbol(),Period(),20,0,MODE_SMA,PRICE_CLOSE,2))//price was below ma20
if(Open[2]<iMA(Symbol(),Period(),20,0,MODE_SMA,PRICE_CLOSE,2))//price was below ma20
if(Close[1]>iMA(Symbol(),Period(),20,0,MODE_SMA,PRICE_CLOSE,1))//price is above ma20
if(Close[1]<iMA(Symbol(),Period(),50,0,MODE_SMA,PRICE_CLOSE,1))//price is NOT above ma50(price above ma50)
if(High[1]<iMA(Symbol(),Period(),50,0,MODE_SMA,PRICE_CLOSE,1))//price is NOT touching ma50(price above ma50)
if (CheckJimdandy()==-1)
   return -1;//1;//-1;


return 0;
*/
//=============Original BB startegy=========================
/*
if(iATR(Symbol(),Period(),1,1) < 0.35*iATR(Symbol(),Period(),100,1)) // candle is only 0.75 size of ATR 
{
   return 0;
}

if(iStdDev(Symbol(),Period(),20,0,MODE_EMA,PRICE_CLOSE,1)<0.0013) // BB are too squeezed(close to one another)
{
   return 0;
}


if(iStdDev(Symbol(),Period(),20,0,MODE_EMA,PRICE_CLOSE,1)>0.0055) // BB are too wide(far from one another)
//if(iStdDev(Symbol(),Period(),20,0,MODE_EMA,PRICE_CLOSE,1)<0.0045) // REVERSE - BB are too wide(far from one another)
{
   return 0;
}
*/


   if (true//Cur_custom_indicator_medium_tf>-0.3 //&& Cur_custom_indicator_long_tf >0.0024 // slope on 2HigherTF is up
      //&& Price_rel_to_Median_Line_short_tf>Cur_custom_indicator__Median_Line_medium_tf // price is above the mediam line of daily(medium) Linear Regression
      //&& Price_rel_to_Median_Line_short_tf<Cur_custom_indicator__Lower_Line_medium_tf // price is below the lower line of daily(medium) Linear Regression
      //&& Price_rel_to_Median_Line_short_tf<Cur_custom_indicator__Higher_Line_medium_tf // price is below the lower line of daily(medium) Linear Regression
      )   
   {
      //if (macdMain3>macdMain2 && macdMain2<macdMain1 /*&& macdMain1>0*/)//(Price_short_tf<BBLower)//(CheckJimdandy()==1) // if(Price_short_tf<BBLower)
      if (CheckJimdandy()==1) // if(Price_short_tf<BBLower)
      //if (CheckLongerTF()==1)
      {
         returnValue = 1;
      }
   }

   if (true//Cur_custom_indicator_medium_tf<+0.3 //&& Cur_custom_indicator_long_tf <-0.0024  // slope on 2HigherTF is down
      //&& Price_rel_to_Median_Line_short_tf<Cur_custom_indicator__Median_Line_medium_tf // price is below the mediam line of daily(medium) Linear Regression   
      //&& Price_rel_to_Median_Line_short_tf>Cur_custom_indicator__Higher_Line_medium_tf // price is above the upper line of daily(medium) Linear Regression     
      //&& Price_rel_to_Median_Line_short_tf>Cur_custom_indicator__Lower_Line_medium_tf // price is above the upper line of daily(medium) Linear Regression     
      )
   {
      //if (macdMain3<macdMain2 && macdMain2>macdMain1 /*&& macdMain1<0*/)//(Price_short_tf>BBHigher)//(CheckJimdandy()==-1) //       if(Price_short_tf>BBHigher)
      if (CheckJimdandy()==-1) //       if(Price_short_tf>BBHigher)
      //if (CheckLongerTF()==-1)
      {
         returnValue = -1;
      }
   }


   return returnValue;


/*
   if (close0 > DonchainSlowHi1) 
      return 1;

   if (close0 < DonchainSlowLo1) 
      return -1;



   return 0;
*/
}
//----------------

int CheckJimdandy()
{


   int BollingerPeriod=20;
   int BollingerDeviation=2;
   
   int Fast_Macd_Ema=21;
   int Slow_Macd_Ema=89;
   double MacdThreshold=50;

   double Macd_Value=iMACD(NULL,0,Fast_Macd_Ema,Slow_Macd_Ema,1,PRICE_CLOSE,MODE_MAIN,1);   
   //double threshold=MacdThreshold*pips;
   double MiddleBB=iBands(NULL,0,BollingerPeriod,BollingerDeviation,0,0,MODE_MAIN,1);
   double LowerBB=iBands(NULL,0,BollingerPeriod,BollingerDeviation,0,0,MODE_LOWER,1);
   double UpperBB=iBands(NULL,0,BollingerPeriod,BollingerDeviation,0,0,MODE_UPPER,1);

   double PrevMiddleBB=iBands(NULL,0,BollingerPeriod,BollingerDeviation,0,0,MODE_MAIN,2);
   double PrevLowerBB=iBands(NULL,0,BollingerPeriod,BollingerDeviation,0,0,MODE_LOWER,2);
   double PrevUpperBB=iBands(NULL,0,BollingerPeriod,BollingerDeviation,0,0,MODE_UPPER,2);

   double PrevPrevLowerBB=iBands(NULL,0,BollingerPeriod,BollingerDeviation,0,0,MODE_LOWER,3);
   double PrevPrevUpperBB=iBands(NULL,0,BollingerPeriod,BollingerDeviation,0,0,MODE_UPPER,3);

   double PrevPrevPrevLowerBB=iBands(NULL,0,BollingerPeriod,BollingerDeviation,0,0,MODE_LOWER,4);
   double PrevPrevPrevUpperBB=iBands(NULL,0,BollingerPeriod,BollingerDeviation,0,0,MODE_UPPER,4);

   double stochM1 = iStochastic(Symbol(), Period(), 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 1);
   double stochM2 = iStochastic(Symbol(), Period(), 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 2);   
   double stochSig1 = iStochastic(Symbol(), Period(), 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 1);
   double stochSig2 = iStochastic(Symbol(), Period(), 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 2);   


/*
   if(Macd_Value>0.0000006)//(Macd_Value>0.004 && Macd_Value<0.025)//(Macd_Value>0.004 && Macd_Value<0.0067)//AUDUSD
      return 1;

   if(Macd_Value<-0.000006)//(Macd_Value<-0.004 && Macd_Value>-0.025)//(Macd_Value<-0.004 && Macd_Value>-0.0067)//AUDUSD
      return -1;
   
   return 0;
*/


//====Original Conditions====
   //=if(Macd_Value>0.000003 /*&& Macd_Value<threshold*/)
      if(Close[1]>LowerBB&&Close[2]<PrevLowerBB) // hook to the upside
      //if(Close[3]<PrevPrevLowerBB) // SECOND CANLDE OUTIDE BB
      //if(Close[4]<PrevPrevPrevLowerBB) // THIRD CANLDE OUTIDE BB
      //if(Close[1]>iMA(Symbol(),Period(),50,0,MODE_SMA,PRICE_CLOSE,1))
      //if(Close[1]>Open[1])
      //if(stochM2<stochSig2 && stochM1>stochSig1 && stochM1 < 20)
      //if(iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,2)<iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,2)
      //&& iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,1)>iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1))
      if(iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,3)>iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,2)
      && iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,2)<iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,1))

         return 1;
         
   //=if(Macd_Value<-0.000003 /*&& Macd_Value>-threshold*/)
      if(Close[1]<UpperBB&&Close[2]>PrevUpperBB) // hook to the downside
      //if(Close[3]>PrevPrevUpperBB) // SECOND CANLDE OUTIDE BB
      //if(Close[4]>PrevPrevPrevUpperBB) // THIRD CANLDE OUTIDE BB
      //if(Close[1]<iMA(Symbol(),Period(),50,0,MODE_SMA,PRICE_CLOSE,1))      
      //if(Close[1]<Open[1])
      //if(stochM2>stochSig2 && stochM1<stochSig1 && stochM1 > 80)      
      //if(iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,2)>iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,2)
      //&& iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,1)<iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1))        
      if(iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,3)<iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,2)
      && iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,2)>iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,1))

         return -1;

   return 0;


}


int CheckLongerTF()
{

   int longerTF = 22;//5;//22; // Monthly TF
   
   int Fast_Macd_Ema=21*longerTF; // macd paramets can be change, but i keep them as short tf
   int Slow_Macd_Ema=89*longerTF;
   double MacdThreshold=50;

   double Macd_Value=iMACD(NULL,0,Fast_Macd_Ema,Slow_Macd_Ema,1,PRICE_CLOSE,MODE_MAIN,1);   
   
   if(Macd_Value>0 /*&& Macd_Value<threshold*/)
      return 1;
   if(Macd_Value<0 /*&& Macd_Value<threshold*/)
      return -1;

   return 0;

}
/*
//----------------
int CheckConditionDoubleDonchain()
{
   double close0 = iClose(Symbol(), Period(), 0);  // current active price
   //Bid

   double DonchainSlowHi1=iCustom(Symbol(),Period(),     "Double Donchian",     InpDunchian_Period_For_Entry,12,       0,   1);  //0=high1 line
   double DonchainSlowLo1=iCustom(Symbol(),Period(),     "Double Donchian",     InpDunchian_Period_For_Entry,12,       2,   1);  //2=low1 line

   //double DonchainFastHi1=iCustom(Symbol(),Period(),     "Double Donchian",     InpDunchian_Period_For_Entry,12,       3,   0);  //0=high1 line
   //double DonchainFastLo1=iCustom(Symbol(),Period(),     "Double Donchian",     InpDunchian_Period_For_Entry,12,       5,   0);  //2=low1 line

//Print("Bid = ", Bid, "   DonchainSlowHi1 = ",DonchainSlowHi1, "  DonchainSlowLo1 = ", DonchainSlowLo1, "    DonchainFastHi1 = ",DonchainFastHi1, "  DonchainFastLo1 = ", DonchainFastLo1); 

   if (close0 > DonchainSlowHi1) 
      return 1;

   if (close0 < DonchainSlowLo1) 
      return -1;



   return 0;

}
//----------------
*/




/*
//----------------
int CheckConditionADX()
{

   double adx = iADX(Symbol(), Period(),InpAdxPeriod, InpAdxPrice,0,1);;
   double mediumMA1 = iMA(Symbol(), Period(), InpMediumPeriods, 0, InpMediumMethod, InpMediumPrice, 1);        
   double close1 = iClose(Symbol(), Period(), 1);  
       
   
   if (adx >= InpAdxLevel && close1 > mediumMA1) 
      return -1;

   if (adx >= InpAdxLevel && close1 < mediumMA1) 
      return 1;

   return 0;

}
//----------------



//----------------
// based on Z_Arrow (but instead of using Custom function, I used the conditions themselfs)
int CheckConditionStoch_Osma()
{

   int value = 0;
   
   //double close = iClose(Symbol(), Period(), 1);

   double macd1 = iMACD(Symbol(), Period(), InpMACDFastPeriod, InpMACDSlowPeriod, InpMACDSignalPeriod, InpMACDAppliedPrice, MODE_MAIN, 1);
   double macd2 = iMACD(Symbol(), Period(), InpMACDFastPeriod, InpMACDSlowPeriod, InpMACDSignalPeriod, InpMACDAppliedPrice, MODE_MAIN, 2);   
  
   double stoch = iStochastic(Symbol(), Period(), InpStochKPeriod, InpStochDPeriod, InpStochSlowPeriod, MODE_SMA, 0, MODE_MAIN, 1);
 
   double osma1 = iOsMA(Symbol(), Period(), InpMACDFastPeriod, InpMACDSlowPeriod, InpMACDSignalPeriod, InpMACDAppliedPrice, 1);
   double osma2 = iOsMA(Symbol(), Period(), InpMACDFastPeriod, InpMACDSlowPeriod, InpMACDSignalPeriod, InpMACDAppliedPrice, 2);   



   double ma1 = iMA(Symbol(), Period(),50,0, MODE_SMA, PRICE_CLOSE, 1);
   double ma2 = iMA(Symbol(), Period(),50,0, MODE_SMA, PRICE_CLOSE, 2);
   double ma3 = iMA(Symbol(), Period(),50,0, MODE_SMA, PRICE_CLOSE, 3);
   
   double maSlow1 = iMA(Symbol(), Period(),200,0, MODE_SMA, PRICE_CLOSE, 1);
   double maSlow2 = iMA(Symbol(), Period(),200,0, MODE_SMA, PRICE_CLOSE, 2);

//Print("ma1 = ", ma1, ",   ma2 = ", ma2);

   if(osma2<0 && osma1>0 // Buy Arrow
      && stoch<20
      && ma1 > ma2 && ma2 > ma3 //&& maSlow1 > maSlow2   // ma is pointing up  
      //&& ma1 > maSlow1            
      )
   {
      value = 1;
   }      

   if(osma2>0 && osma1<0 // Sell Arrow
      && stoch>80
      && ma1 < ma2 && ma2 < ma3 //&& maSlow1 < maSlow2   // ma is pointing down 
      //&& ma1 < maSlow1              
      )
   {
      value = -1;
   }      
        
   return value;


}
//----------------
*/

/*
//----------------
int CheckConditionPriceMA()
{

   double ma = iMA(Symbol(), Period(), InpMAPeriod, 0, InpMAMethod, InpMAAppliedPrice, 1);   
   double close = iClose(Symbol(), Period(), 1);
      
   if (close > ma)
   {
      return 1;
   }     
   
   if (close < ma)
   {
      return -1;
   }     
        
   return 0;

}

//----------------

//----------------
int CheckConditionMACD()
{

   double macdMain1 = iMACD(Symbol(), Period(), InpMACDFastMAPeriod, InpMACDSlowMAPeriod, InpMACDSignalPeriod, InpMACDAppliedPrice, MODE_MAIN, 1);
   double macdMain2 = iMACD(Symbol(), Period(), InpMACDFastMAPeriod, InpMACDSlowMAPeriod, InpMACDSignalPeriod, InpMACDAppliedPrice, MODE_MAIN, 2);

   double macdSig1 = iMACD(Symbol(), Period(), InpMACDFastMAPeriod, InpMACDSlowMAPeriod, InpMACDSignalPeriod, InpMACDAppliedPrice, MODE_SIGNAL, 1);
   double macdSig2 = iMACD(Symbol(), Period(), InpMACDFastMAPeriod, InpMACDSlowMAPeriod, InpMACDSignalPeriod, InpMACDAppliedPrice, MODE_SIGNAL, 2);

   if (macdMain1>macdSig1 && macdMain2<=macdSig2 && macdMain1 < 0)
   {
      return 1;      
   }

   if (macdMain1<macdSig1 && macdMain2>=macdSig2 && macdMain1 > 0)
   {
      return -1;
   }

   return 0;

}
//----------------
*/
/*
//----------------
int CheckConditionOSMA()
{

   double osma1 = iOsMA(Symbol(), Period(), InpMACDFastMAPeriod, InpMACDSlowMAPeriod, InpMACDSignalPeriod, InpMACDAppliedPrice, 1);
   double osma2 = iOsMA(Symbol(), Period(), InpMACDFastMAPeriod, InpMACDSlowMAPeriod, InpMACDSignalPeriod, InpMACDAppliedPrice, 2);
   double osma3 = iOsMA(Symbol(), Period(), InpMACDFastMAPeriod, InpMACDSlowMAPeriod, InpMACDSignalPeriod, InpMACDAppliedPrice, 3);
   
   if (osma1>osma2 && osma2<=osma3 && osma1 < 0) // buy hook
   {
      return 1;      
   }

   if (osma1<osma2 && osma2>=osma3 && osma1 > 0) // sell hook
   {
      return -1;
   }

   return 0;

}
//----------------
*/



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


//----------------
int TradeCount()
{
   int result = 0;
   int count      = OrdersTotal();
   for (int i=count-1; i>=0; i--)
   {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if (OrderSymbol()==Symbol() && OrderMagicNumber()==InpMagicNumber) result++;
   }
   //return count;// just for TESING - need to delete this line
   return result;

}
//----------------






//----------------

int OpenTrade(ENUM_ORDER_TYPE type)                      // 1==long , -1==short
{
Print("===Bars=", Bars);
//if (Bars<InpLinearRegPeriod) return 0; // No LR channel yet(not enough bars) , for tesing Only, need to delete this line

   //double LastOpenPositionPrice = GetLastOpenPositionPrice();


      Print("OpenTrade = ", iTime(Symbol(),Period(),1));   

   //gPositionDirection = type; // update the global variable of the direction of th eposition.
      
   //=gAtr = iATR(Symbol(), Period(), 100, 1); // moved to OnInit function
   //=int gAtrMulti = 10;//12;//6;//3;
   
   int numOpenPositions = TradeCount();
   if (numOpenPositions == 0) // first position in the basket (after the first position other positions are at the same size)
   {
      //=gAdjustedLots = CalculateLotSize();
      gAdjustedLots = 0.1;
      
   }

/* // research shows that double the positions at this stage is no helping (it is just add to drawdown and exit at the same stage)          
   else if (numOpenPositions == 10) // Second leg of positions in the basket 
   {
      gAdjustedLots = gAdjustedLots*2;
   }
   
   else if (numOpenPositions == 20) // third leg of positions in the basket 
   {
      gAdjustedLots = gAdjustedLots*1.5;
   }

*/

   //=double price = (type==ORDER_TYPE_BUY) ? SymbolInfoDouble(Symbol(), SYMBOL_ASK) : SymbolInfoDouble(Symbol(), SYMBOL_BID);
   //=price        = NormalizeDouble(price, Digits());   

   //=double sl    = (type==ORDER_TYPE_BUY) ? (price-gAtr*InpAtrMulti) : (price+gAtr*InpAtrMulti);//*InpRatio); // sl is bigger than tp
   //=sl           = NormalizeDouble(sl, Digits());

   //=double tp    = (type==ORDER_TYPE_BUY) ? (price+gAtr*InpAtrMulti) : (price-gAtr*InpAtrMulti); 
   //=tp           = NormalizeDouble(tp, Digits());
   
   
/*   
if(type==ORDER_TYPE_BUY && (LastOpenPositionPrice-price) < atr*atrMulti)  // price is not low enough to open another BUY position
{
   return 0;   
}
*/   

/*
   double sl    = (type==ORDER_TYPE_BUY) ? (price-0.00700) : (price+0.00700);//*InpRatio); // sl is bigger than tp
   sl           = NormalizeDouble(sl, Digits());

   double tp    = (type==ORDER_TYPE_BUY) ? (price+0.00100) : (price-0.00100); 
   tp           = NormalizeDouble(tp, Digits());
*/

gAtr = iATR(Symbol(), Period(), 100, 1);

   double price = (type==ORDER_TYPE_BUY) ? SymbolInfoDouble(Symbol(), SYMBOL_ASK) : SymbolInfoDouble(Symbol(), SYMBOL_BID);
   price        = NormalizeDouble(price, Digits());   

   double sl    = (type==ORDER_TYPE_BUY) ? (price-gAtr*InpAtrMulti*InpLossPct/100) : (price+gAtr*InpAtrMulti*InpLossPct/100);//*InpRatio); // sl is bigger than tp
   sl           = NormalizeDouble(sl, Digits());

   double tp    = (type==ORDER_TYPE_BUY) ? (price+gAtr*InpAtrMulti*InpProfitPct/100) : (price-gAtr*InpAtrMulti*InpProfitPct/100); 
   tp           = NormalizeDouble(tp, Digits());


   //=gLastOpenPositionTicket = OrderSend(Symbol(), type, InpVolume, price, 0, sl, tp, InpTradeComment, InpMagicNumber);   
   //=gLastOpenPositionTicket = OrderSend(Symbol(), type, InpVolume, price, 0, 0, tp, InpTradeComment, InpMagicNumber);   
   //=gLastOpenPositionTicket = OrderSend(Symbol(), type, gAdjustedLots, price, 0, 0, 0, InpTradeComment, InpMagicNumber);   
   //=gLastOpenPositionTicket = OrderSend(Symbol(), type, gAdjustedLots, price, 0, sl, tp, InpTradeComment, InpMagicNumber);   
   gLastOpenPositionTicket = OrderSend(Symbol(), type, InpVolume, price, 0, 0, 0, InpTradeComment, InpMagicNumber);   
   gLastOpenPositionPrice = price; // seems to be a bug with order selecet and openprice of open selecet
   
   return(gLastOpenPositionTicket);   
   



/*   
   double price = (type==ORDER_TYPE_BUY) ? SymbolInfoDouble(Symbol(), SYMBOL_ASK) : SymbolInfoDouble(Symbol(), SYMBOL_BID);
   price        = NormalizeDouble(price, Digits());
   double sl    = NormalizeDouble(SwingPrice(type), Digits());
   double tp    = NormalizeDouble(price + ((price-sl)*InpRatio), Digits());
   
   return(OrderSend(Symbol(), type, InpVolume, price, 0, sl, tp, InpTradeComment, InpMagicNumber));   
*/
   //return(0);

}
//--------------------





//----------------

int OpenTradePending(ENUM_ORDER_TYPE type)                      // 1==long , -1==short
{
Print("===Bars=", Bars);
//if (Bars<InpLinearRegPeriod) return 0; // No LR channel yet(not enough bars) , for tesing Only, need to delete this line

   //double LastOpenPositionPrice = GetLastOpenPositionPrice();


      Print("OpenTrade = ", iTime(Symbol(),Period(),1));   

   //gPositionDirection = type; // update the global variable of the direction of th eposition.
      
   //=gAtr = iATR(Symbol(), Period(), 100, 1); // moved to OnInit function
   //=int gAtrMulti = 10;//12;//6;//3;
   
   int numOpenPositions = TradeCount();
   if (numOpenPositions == 0) // first position in the basket (after the first position other positions are at the same size)
   {
      //=gAdjustedLots = CalculateLotSize();
      gAdjustedLots = 0.1;
      
   }

/* // research shows that double the positions at this stage is no helping (it is just add to drawdown and exit at the same stage)          
   else if (numOpenPositions == 10) // Second leg of positions in the basket 
   {
      gAdjustedLots = gAdjustedLots*2;
   }
   
   else if (numOpenPositions == 20) // third leg of positions in the basket 
   {
      gAdjustedLots = gAdjustedLots*1.5;
   }

*/

   //=double price = (type==ORDER_TYPE_BUY) ? SymbolInfoDouble(Symbol(), SYMBOL_ASK) : SymbolInfoDouble(Symbol(), SYMBOL_BID);
   //=price        = NormalizeDouble(price, Digits());   

   //=double sl    = (type==ORDER_TYPE_BUY) ? (price-gAtr*InpAtrMulti) : (price+gAtr*InpAtrMulti);//*InpRatio); // sl is bigger than tp
   //=sl           = NormalizeDouble(sl, Digits());

   //=double tp    = (type==ORDER_TYPE_BUY) ? (price+gAtr*InpAtrMulti) : (price-gAtr*InpAtrMulti); 
   //=tp           = NormalizeDouble(tp, Digits());
   
   
/*   
if(type==ORDER_TYPE_BUY && (LastOpenPositionPrice-price) < atr*atrMulti)  // price is not low enough to open another BUY position
{
   return 0;   
}
*/   

/*
   double sl    = (type==ORDER_TYPE_BUY) ? (price-0.00700) : (price+0.00700);//*InpRatio); // sl is bigger than tp
   sl           = NormalizeDouble(sl, Digits());

   double tp    = (type==ORDER_TYPE_BUY) ? (price+0.00100) : (price-0.00100); 
   tp           = NormalizeDouble(tp, Digits());
*/

gAtr = iATR(Symbol(), Period(), 100, 1);


// pending order is the PEAK of the last 3 bars 
double entryPending = 0;
double sl = 0;
double tp = 0;
int numBars=1;//3;// number of bars to check the peak

if (type==ORDER_TYPE_BUY_STOP)
{
   int bar = iHighest(Symbol(),Period(),MODE_HIGH,numBars,1);
   entryPending = iHigh(Symbol(),Period(),bar);
   entryPending = NormalizeDouble(entryPending, Digits());
}

if (type==ORDER_TYPE_SELL_STOP)
{
   int bar = iLowest(Symbol(),Period(),MODE_LOW,numBars,1);
   entryPending = iLow(Symbol(),Period(),bar);
   entryPending = NormalizeDouble(entryPending, Digits());
}

if (type==ORDER_TYPE_BUY_LIMIT)
{
   int bar = iLowest(Symbol(),Period(),MODE_LOW,numBars,1);
   entryPending = iLow(Symbol(),Period(),bar);   
   entryPending = NormalizeDouble(entryPending, Digits());
}

if (type==ORDER_TYPE_SELL_LIMIT)
{
   int bar = iHighest(Symbol(),Period(),MODE_HIGH,numBars,1);
   entryPending = iHigh(Symbol(),Period(),bar);
   entryPending = NormalizeDouble(entryPending, Digits());
}



   //double price = (type==ORDER_TYPE_BUY) ? SymbolInfoDouble(Symbol(), SYMBOL_ASK) : SymbolInfoDouble(Symbol(), SYMBOL_BID);
   //price        = NormalizeDouble(price, Digits()); 
   
//the below if statemnts can be remove to the upside if statments     
if(type==ORDER_TYPE_BUY_STOP || type==ORDER_TYPE_SELL_STOP)
{
   sl    = (type==ORDER_TYPE_BUY_STOP) ? (entryPending-gAtr*InpAtrMulti*InpLossPct/100) : (entryPending+gAtr*InpAtrMulti*InpLossPct/100);//*InpRatio); // sl is bigger than tp
   sl           = NormalizeDouble(sl, Digits());

   tp    = (type==ORDER_TYPE_BUY_STOP) ? (entryPending+gAtr*InpAtrMulti*InpProfitPct/100) : (entryPending-gAtr*InpAtrMulti*InpProfitPct/100); 
   tp           = NormalizeDouble(tp, Digits());
}


if(type==ORDER_TYPE_BUY_LIMIT || type==ORDER_TYPE_SELL_LIMIT)
{
   sl    = (type==ORDER_TYPE_BUY_LIMIT) ? (entryPending-gAtr*InpAtrMulti*InpLossPct/100) : (entryPending+gAtr*InpAtrMulti*InpLossPct/100);//*InpRatio); // sl is bigger than tp
   sl           = NormalizeDouble(sl, Digits());

   tp    = (type==ORDER_TYPE_BUY_LIMIT) ? (entryPending+gAtr*InpAtrMulti*InpProfitPct/100) : (entryPending-gAtr*InpAtrMulti*InpProfitPct/100); 
   tp           = NormalizeDouble(tp, Digits());
}

   //=gLastOpenPositionTicket = OrderSend(Symbol(), type, InpVolume, price, 0, sl, tp, InpTradeComment, InpMagicNumber);   
   //=gLastOpenPositionTicket = OrderSend(Symbol(), type, InpVolume, price, 0, 0, tp, InpTradeComment, InpMagicNumber);   
   //=gLastOpenPositionTicket = OrderSend(Symbol(), type, gAdjustedLots, price, 0, 0, 0, InpTradeComment, InpMagicNumber);   
   //=gLastOpenPositionTicket = OrderSend(Symbol(), type, gAdjustedLots, price, 0, sl, tp, InpTradeComment, InpMagicNumber);   
   //=gLastOpenPositionPrice = price; // seems to be a bug with order selecet and openprice of open selecet

   int bar_to_expiration = 4;//2; // pending order will be valid to 6 bars
   datetime expiration = iTime(Symbol(), Period(), 0) + PeriodSeconds()*bar_to_expiration - 1;

   
   gLastOpenPositionTicket = OrderSend(Symbol(), type, gAdjustedLots, entryPending, 0, sl, tp,
                                             InpTradeComment, InpMagicNumber, expiration);   
   
   
   return(gLastOpenPositionTicket);   
   



/*   
   double price = (type==ORDER_TYPE_BUY) ? SymbolInfoDouble(Symbol(), SYMBOL_ASK) : SymbolInfoDouble(Symbol(), SYMBOL_BID);
   price        = NormalizeDouble(price, Digits());
   double sl    = NormalizeDouble(SwingPrice(type), Digits());
   double tp    = NormalizeDouble(price + ((price-sl)*InpRatio), Digits());
   
   return(OrderSend(Symbol(), type, InpVolume, price, 0, sl, tp, InpTradeComment, InpMagicNumber));   
*/
   //return(0);

}
//--------------------








/*
//--------------------
void ManageOpenPositions()
{

   //double DonchainFastHi1=iCustom(Symbol(),Period(),     "Double Donchian",     inpDunchian_Period_For_SL,inpDunchian_Period_For_SL,       3,   1);  //0=high1 line
   //double DonchainFastLo1=iCustom(Symbol(),Period(),     "Double Donchian",     inpDunchian_Period_For_SL,inpDunchian_Period_For_SL,       5,   1);  //2=low1 line

   bool check = OrderSelect(gLastOpenPositionTicket, SELECT_BY_TICKET);

   STradeSum sum;
   GetSum(sum);
//Print("====ManageOpenPositions====", sum.count);    
   if (sum.profit>InpMinProfit) // dollar target reach (of all the basket)
   {
      CloseAllOpenPositions(); 
      gIsActiveBasket = false;  
   }


   else if(sum.count<=InpMaxOpenPositions) // we can still open positions if needed
   {

      if (OrderType() == OP_BUY
         && SymbolInfoDouble(Symbol(), SYMBOL_ASK) <= DonchainFastLo1) // price has reach the faster Donchian chanel
         //&& SymbolInfoDouble(Symbol(), SYMBOL_ASK) <= gLastOpenPositionPrice-gAtr*InpAtrMulti*InpAddPositionMulti) // price has reach the next level to open a Buy position
             
            {
               CloseAllOpenPositions(); 
               gIsActiveBasket = false;                       
            }

   

      else if (OrderType() == OP_SELL
         && SymbolInfoDouble(Symbol(), SYMBOL_BID) >= DonchainFastHi1) // price has reach the faster Donchian chanel
             
            {
               CloseAllOpenPositions(); 
               gIsActiveBasket = false;                       
            }

   }


}
*/
/*
void ManageOpenPositions()
{

   bool check = OrderSelect(gLastOpenPositionTicket, SELECT_BY_TICKET);

   STradeSum sum;
   GetSum(sum);
//Print("====ManageOpenPositions====", sum.count);    
   if (sum.profit>InpMinProfit) // dollar target reach (of all the basket)
   {
      CloseAllOpenPositions(); 
      gIsActiveBasket = false;  
   }
   
   else if(sum.count<=InpMaxOpenPositions) // we can still open positions if needed
   {
//Print("====sum.count<InpMaxOpenPositions===gLastOpenPositionTicket=", gLastOpenPositionTicket, "   OrderOpenPrice()=", OrderOpenPrice());   
      if (OrderType() == OP_BUY 
         //&& Ask <= OrderOpenPrice()-gAtr*InpAtrMulti) // price has reach the next level to open a Buy position  I
         && SymbolInfoDouble(Symbol(), SYMBOL_ASK) <= gLastOpenPositionPrice-gAtr*InpAtrMulti*InpAddPositionMulti) // price has reach the next level to open a Buy position
      {
         if(sum.count==InpMaxOpenPositions) // we reach the maximum of possible open position(CAN'T open positions anymore)
         {
            CloseAllOpenPositions(); 
            gIsActiveBasket = false;           
         }
         else // we can open more positions
         {
            OpenTrade(ORDER_TYPE_BUY);      
         }   
      }   
      
      else if (OrderType() == OP_SELL 
         //&& Bid >= OrderOpenPrice()+gAtr*InpAtrMulti) // price has reach the next level to open a Sell position  I
         && SymbolInfoDouble(Symbol(), SYMBOL_BID) >= gLastOpenPositionPrice+gAtr*InpAtrMulti*InpAddPositionMulti) // price has reach the next level to open a Sell position
      {
         if(sum.count==InpMaxOpenPositions) // we reach the maximum of possible open position(CAN'T open positions anymore)
         {
            CloseAllOpenPositions(); 
            gIsActiveBasket = false;           
         }
         else // we can open more positions
         {
            OpenTrade(ORDER_TYPE_SELL);      
         }   
      }        
      
   }
   

}
*/
//--------------------



//--------------------
void GetSum(STradeSum &sum)
{

   int count      = OrdersTotal();
   
   sum.count      = 0;
   sum.profit     = 0.0;
   sum.trailPrice = 0.0;
   
   for(int i = count-1; i>=0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if( OrderSymbol()==Symbol()
             && OrderMagicNumber()==InpMagicNumber
             //&& OrderType()==InpType
             )
             {
               sum.count++;
               sum.profit+= OrderProfit()+OrderSwap()+OrderCommission();             
             }
      
      }   
   }
      
}
//--------------------









//--------------------
/*
double CalculatLotSize(double lots)
{

Print("CalculatLotSize , gCountRound = ", gCountRound);

   double updatedLots=0;


   switch(gCountRound)
   {
      case 0:
         updatedLots = lots; // InpVolume; 0.01
         gCountRound++; 
         break;
      case 1:
         updatedLots = 1*lots; //2*lots; // 0.02
         gCountRound++; 
         break;
      case 2:
         updatedLots = 1*lots; //2*lots; // 0.04         
         gCountRound++; 
         break;
      case 3:
         updatedLots = 1*lots; //2*lots; // 0.08         
         gCountRound++; 
         break;
      case 4:
         updatedLots = 1*lots; // 2*lots; // 0.16         
         gCountRound++; 
         break;
      case 5:
         updatedLots = 1*lots; // 2*lots; // 0.32         
         gCountRound++; 
         break;


      default: // reach maximum rounds
         gCountRound = 0;
         break;                                      
   }
   
   if (gCountRound>InpNumMartingaleRounds)//1)//4)//2) // OverRide the Switch
   {
      gCountRound = 0;
   }

/*   
   //if (lots == InpVolume)
   if(gCountRound==0)
   {
      updatedLots = lots; 
      gCountRound++;
   }
   else
   {
      updatedLots = 2*lots;    
   }
   
*/   
/*
   return updatedLots;

}
*/


/*
//--------------------
// https://www.youtube.com/watch?v=KS-BXFMVdTc&ab_channel=OrchardForex
bool CloseAllOpenPositions()
{

   bool result = true;
   int count = OrdersTotal();
   for (int i=count-1; i>=0; i--)
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         result = false; // for some reason wee didn't succeeded to OrderSelect   
      }
      else
      {
         if(      OrderSymbol()==Symbol()
               && OrderMagicNumber()==InpMagicNumber 
               && (   OrderType()==ORDER_TYPE_BUY || OrderType()==ORDER_TYPE_SELL   ) // no pending position in this ea, so there is no need to check order type, but anyway we check
           )   
           {
              result &= OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0);        
           }
      
      }
      
   
   }
   
   return result;
}
*/




//--------------------
// https://www.youtube.com/watch?v=KS-BXFMVdTc&ab_channel=OrchardForex
bool CloseAllOpenPositions()
{

   bool result = true;
   
   for(int retries=1; retries<=10; retries++) // 10 retries to close all positions
   {
      int count = OrdersTotal();
      for (int i=count-1; i>=0; i--)
      {
         if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         {
            result = false; // for some reason wee didn't succeeded to OrderSelect   
         }
         else
         {
            if(      OrderSymbol()==Symbol()
                  && OrderMagicNumber()==InpMagicNumber 
                  && (   OrderType()==ORDER_TYPE_BUY || OrderType()==ORDER_TYPE_SELL   ) // no pending position in this ea, so there is no need to check order type, but anyway we check
              )   
              {
                 result &= OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0);        
              }
         
         }
      }

      if(result==true) // we succeeded closing all positions
      {
         Print("===We succeeded close all open position?=== num of open position left=", OrdersTotal(), ",num of tries=", retries);//, "  i=",i);
         break; // no need to try again closing positions
      }
      
   
   }
   
   return result;
}














/*
//----------------
double SwingPrice(ENUM_ORDER_TYPE type)
{

   // init the variables
   int bar = 0;
   double price = 0;
   
   if (type==ORDER_TYPE_BUY)
   {
      bar =   iLowest(Symbol(), Period(), MODE_LOW, InpSwingLookback, 1); // First just find lowest for the 
      price = iLow(Symbol(), Period(), bar);
      while (price>=iLow(Symbol(), Period(), ++bar)) // Now keep moving back as king as next bar is lowest
      {
         price = iLow(Symbol(), Period(), bar);   
      }
   }
   else // type==ORDER_TYPE_SELL
   {
      bar   = iHighest(Symbol(), Period(), MODE_HIGH, InpSwingLookback, 1); // First just find highest for the 
      price = iHigh(Symbol(), Period(), bar);
      while (price<=iHigh(Symbol(), Period(), ++bar)) // Now keep moving back as king as next bar is highest
      {
         price = iHigh(Symbol(), Period(), bar);   
      }      
   }
   
   return price;
      
}
*/













/*
//----------------
int CheckConditionATR()
{

   int returnValue = 0;

   //if (inidcator3 == true)
   //{
      double mediumMA1 = iMA(Symbol(), Period(), InpMediumPeriods, 0, InpMediumMethod, InpMediumPrice, 1);     
   
      double close1 = iClose(Symbol(), Period(), 1);
      
      double atr = iATR(Symbol(), Period(), 100, 1);
      
      if(mediumMA1-close1 > 12*atr) // there is big gap between MA50 and close price
      {
         returnValue =  1;  
         return returnValue; 
      }
   
      if(close1-mediumMA1 > 12*atr) // there is big gap between MA50 and close price
      {
         returnValue =  -1;  
         return returnValue; 
      }
   
   //} // end indicator3   
   return returnValue;   


}

//----------------

*/








/*
//----------------
int CheckConditionMFI()
{

   double mfi = iMFI(Symbol(), Period(), InpMFIPeriod, 1);
   
   if (mfi > 0)
   {
      return 1;
   }

   if (mfi < 0)
   {
      return -1;
   }

   return 0;

}




//-------------


double SymbolAsk () 
{
   return(SymbolInfoDouble(Symbol(),SYMBOL_ASK));
}

double SymbolBid () 
{
   return(SymbolInfoDouble(Symbol(),SYMBOL_BID));
}







//===================acount balance mangment==========================
//+------------------------------------------------------------------+
void CloseOpenPositions() // add magic number for the checking
{

//===========LIFO========   
int cnt = OrdersTotal()-1;
   for (int i=cnt; i>=0; i--)
   {
      bool result = false;
      double closing_price;
      
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) // function OrderSelect succeeded
         if(OrderSymbol()==_Symbol)
            if (InpMagicNumber == OrderMagicNumber())
               if(OrderType() <= 1)
               { 
                  if (OrderType() == OP_BUY)
                     closing_price = Bid;
                  else 
                     closing_price = Ask;
                  result = OrderClose(OrderTicket(),OrderLots(),closing_price,3,Red);
                  if (result) // OrderClose succeeded
                  {
                  //i--;
                     Print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@Closed Position, ticket num = ", OrderTicket(), "   i= ", i);
                  }
                  else
                  {
                     i++; // repeat again this position until successfuly close
                     Print("====FAILED=====@@@@@@@@@@@@@@@@@Closed Position, ticket num = ", OrderTicket(), "   i= ", i);
                  }
               }
   }
   


   
}
//+------------------------------------------------------------------+
*/



//+------------------------------------------------------------------+
// PipSize function return 0.01 fo jpy, 0.0001 for eurusd
double PipSize(string symbol)
{

   double point    = MarketInfo(symbol, MODE_POINT);
   int    digits   = (int)MarketInfo(symbol, MODE_DIGITS);
   return(   ((digits%2)==1)  ?  point*10 :  point);

}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
// Calculate the value in base currrency
//    of one point move in the price
//    of the supplied currency for one lot      
double PointValue(string symbol)
{

   double tickSize     = MarketInfo(symbol, MODE_TICKSIZE);
   double tickValue    = MarketInfo(symbol, MODE_TICKVALUE);
   double point        = MarketInfo(symbol, MODE_POINT);
   
   double ticksPerPoint = tickSize/point; // usually is 1
   
   double pointValue    = tickValue/ticksPerPoint;
   
   PrintFormat("tickSize=%f, tickValue=%f, point=%f, ticksPerPoint=%f, pointValue=%f",
                  tickSize, tickValue, point, ticksPerPoint, pointValue);
   
   return pointValue;

}



//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
// for jpy symbols need to multiply by 100
// for usd symbols need to multiply by 10000
// need to check for pairs that don't have Point value(like GOLD) need to add a check
double AtrInPoints(double atr, string symbol)
{

   double atrInPoint = 0;
   
   int digits = (int)MarketInfo(symbol, MODE_DIGITS);   
   
   //return atr*MathPow(10, Digits() - 0); // atr in pips = ATR*MathPow(10,Digits() - 1) 
   
   int checkDigits = digits%2;
      
   if (checkDigits == 0) // GOLD
   {
      atrInPoint = atr*MathPow(10, digits-1);   
   }
   else // all other pairs have 3 or 5 digits
   {
      atrInPoint = atr*MathPow(10, digits - 0);      
   }

   
Print("====AtrInPoints====", atrInPoint);   

   return atrInPoint;   
}


//+------------------------------------------------------------------+




//+------------------------------------------------------------------+

double CalculateLotSize()
{

   //gAtr = iATR(Symbol(), Period(), 100, 1);
   double atrInPoints = AtrInPoints(gAtr, Symbol());
   atrInPoints = atrInPoints*InpAtrMulti; // updated the atr with multiply the number of atr's for stoploss
   
   double pointValue = PointValue(Symbol());

   //gDollarProfit = pointValue*InpVolume*atrInPoints; 
   
   gAdjustedLots = InpMinProfit/(pointValue*atrInPoints);
   
   return gAdjustedLots;


}



//--------------------
bool CanTrade()
{

   // Some general get out early conditions
   return (  TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) 
             && MQLInfoInteger(MQL_TRADE_ALLOWED)
             && AccountInfoInteger(ACCOUNT_TRADE_EXPERT)
             && AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)
             );

}
//--------------------
