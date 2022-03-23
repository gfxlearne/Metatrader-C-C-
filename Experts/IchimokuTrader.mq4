//+------------------------------------------------------------------+
//|                                               IchimokuTrader.mq4 |
//|                                                               ZB |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "gfx"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict



// https://www.youtube.com/watch?v=3T1SPf-6EgY&ab_channel=Ren%C3%A9Balke


// Some inputs
// Ichimoku cloud
input int InpTenkanSen = 9;
input int InpKijunSen = 26;
input int InpSenkouSpanBSen = 52;


// Standard trading inputs
input double             InpVolume         =  0.01;            // Trade lot size
input int                InpMagicNumber    =  212121;          // Magic number
input string             InpTradeComment   =  __FILE__;        // Trade comment
input int                InpSlippage       =  100000;          // slippage 


input int                InpMaxOpenPositions = 0;//1000;


int gPositionDirection = 0;


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

   // Some general get out early conditions
   if (!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) return; // exit if expert trading is now allowed
   if (!MQLInfoInteger(MQL_TRADE_ALLOWED)) return; // allow live trading checkbox on the chart
   if (!(bool)AccountInfoInteger(ACCOUNT_TRADE_EXPERT)) return; // if allowed to trade an automated trade on this account
   if (!(bool)AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)) return; // if allowed to trade at all on this account
   
   if (!NewBar()) return; // Only trade once per bar

   //if (TradeCount()>InpMaxOpenPositions) return;


   int ConditionIchimoku = CheckConditionIchimoku();
   
   
      if (   ConditionIchimoku == 1 && gPositionDirection!=1 // conditions are for BUY and there is no BUY position open
          )
          {   
            CloseAll();
            OpenTrade(ORDER_TYPE_BUY);   
            gPositionDirection = 1;                                              
            //OpenTrade(ORDER_TYPE_SELL);                                                 
            
          }


      if (   ConditionIchimoku == -1 && gPositionDirection!=-1 // conditions are for SELL and there is no SELL position open  
          )
          {           
            CloseAll();             
            OpenTrade(ORDER_TYPE_SELL); 
            gPositionDirection = -1;             
            //OpenTrade(ORDER_TYPE_BUY);                                                                                                
          }
   





   
  }
//+------------------------------------------------------------------+




//----------
bool NewBar()
{

   static int totalBars = 0;
   int CurrentTotalbars = iBars(Symbol(), Period());
   
   if(totalBars==CurrentTotalbars) return false; // NOT new bar
   
   totalBars = CurrentTotalbars;
   
   return true;

/*
   static datetime prevTime = 0;
   datetime        now      = iTime(Symbol(), Period(),0);
   if (prevTime==now) return(false);
   prevTime = now;
   return (true);
*/

}
//-------------



//+------------------------------------------------------------------+


int CheckConditionIchimoku()
{

   double tenkanSen1   = iIchimoku(Symbol(), Period(), InpTenkanSen, InpKijunSen, InpSenkouSpanBSen, MODE_TENKANSEN, 1);
   double kijunSen1    = iIchimoku(Symbol(), Period(), InpTenkanSen, InpKijunSen, InpSenkouSpanBSen, MODE_KIJUNSEN, 1);

   double tenkanSen2   = iIchimoku(Symbol(), Period(), InpTenkanSen, InpKijunSen, InpSenkouSpanBSen, MODE_TENKANSEN, 2);
   double kijunSen2    = iIchimoku(Symbol(), Period(), InpTenkanSen, InpKijunSen, InpSenkouSpanBSen, MODE_KIJUNSEN, 2);


   double senkouSpanA = iIchimoku(Symbol(), Period(), InpTenkanSen, InpKijunSen, InpSenkouSpanBSen, MODE_SENKOUSPANA, 1);
   double senkouSpanB = iIchimoku(Symbol(), Period(), InpTenkanSen, InpKijunSen, InpSenkouSpanBSen, MODE_SENKOUSPANB, 1);



   if (tenkanSen1>kijunSen1 && tenkanSen2<=kijunSen2 // CROSS of tenkanSen over kijunSen
      && Ask > senkouSpanA && Ask > senkouSpanB      // price is above the cloud
   ) 
   {
      return 1;      
   }
   else if (tenkanSen1<kijunSen1 && tenkanSen2>=kijunSen2 // CROSS of tenkanSen over kijunSen
            && Bid < senkouSpanA && Bid < senkouSpanB     // price is below the cloud
   ) 
   {
      return -1;
   }

   return 0;

}






//+------------------------------------------------------------------+

//----------------

int OpenTrade(ENUM_ORDER_TYPE type)                      // 1==long , -1==short
{
      Print("OpenTrade = ", iTime(Symbol(),Period(),1));   
   
   double price = (type==ORDER_TYPE_BUY) ? SymbolInfoDouble(Symbol(), SYMBOL_ASK) : SymbolInfoDouble(Symbol(), SYMBOL_BID);
   price        = NormalizeDouble(price, Digits());
   double sl    = 0;//NormalizeDouble(SwingPrice(type), Digits());
   double tp    = 0;//NormalizeDouble(price + ((price-sl)*InpRatio), Digits());
   
   return(OrderSend(Symbol(), type, InpVolume, price, InpSlippage, sl, tp, InpTradeComment, InpMagicNumber));   

   //return(0);

}
//--------------------





//+------------------------------------------------------------------+
bool CloseAll()
{

   bool result = true;

   Print("Attempting to close trades and orders");
   int retries = 10;
   for (int r=0; r<retries; r++) // Build in some retries
   {
      
      int count = OrdersTotal();
      for (int i=count-1; i>=0; i--)
      {
         if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         {
            result = false;      
         }
         else
         {
            if(   OrderSymbol()==Symbol()
                  && OrderMagicNumber()==InpMagicNumber)   
             {
               if(OrderType()==ORDER_TYPE_BUY || OrderType()==ORDER_TYPE_SELL)
               {
                  result   &= OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0);                  
               }
               else // limit or stop orders
               {
                  result   &= OrderDelete(OrderTicket());
               }               
             }         
         }
      
      } // end OrdersTotal loop
      
      if(result==true) // succeeded to close ALL orders -> there is no need to continue to retries
      {
         break; // break the retries loop
      }
   
   } // end retries loop
   
   return(result);
}






//+------------------------------------------------------------------+
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
   return result;

}
//----------------
