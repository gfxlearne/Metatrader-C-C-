//+------------------------------------------------------------------+
//|                                                Calc_Lot_Size.mq4 |
//|                                                               ZB |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "ZB"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#property show_inputs

//#include <stderror.mqh>
#include <stdlib.mqh>



// created 25-12-2021
//
// based on the ea 



enum Order_Type // int
{
   Buy = 0,
   Sell = 1,
   Buy_Limit = 2,
   Sell_Limit = 3,
   Buy_Stop = 4,
   Sell_Stop = 5

};


input Order_Type InpTrade_Order;


input double InpEntry_Price = 0; // the entry price, 0-for market orders
input double InpPrice_SL = 0; // the actual price of the SL
input int InpDollar_Amount_To_Risk = 100; // Dollar Amount To Risk (100$)
input int InpReward_ratio = 2; // reward/risk ratio
input int InpMagicNumber = 12340;
input string             InpTradeComment   =  "__FILE__";        // Trade comment

input double             InpVolume         =  0.01;            // Trade lot size





//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{

   OrderEntry();
   
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| order entry function                                             |
//+------------------------------------------------------------------+
void OrderEntry()
{
   
   double LotSize = 0;
   
   double stop_price = 0; // SL price
   double pips_to_sl = 0; //pips to sl (ie: 0.00500)
   double takeprofit_price = 0;
   double pips_to_sl_Amount = 0;
   
   int ticket = 0;   
   
   double pips =Point(); //.00001 or .0001. .001 .01.
   if(Digits==1||Digits==3||Digits==5)
   {
      pips*=10;
   }

      
   switch(InpTrade_Order)
   {
      case OP_BUY: // BUY MARKET ORDER
         stop_price = InpPrice_SL; // SL price
         pips_to_sl = Ask-stop_price; //pips to sl (ie: 0.00500)
         takeprofit_price = Ask+(pips_to_sl*InpReward_ratio);
         
         pips_to_sl_Amount = (pips_to_sl/pips); //amount pips to sl (ie: 50.0 pips)
         pips_to_sl_Amount  = NormalizeDouble(pips_to_sl_Amount,2);
         
         LotSize = (InpDollar_Amount_To_Risk/ pips_to_sl_Amount) / 10;
Print(" LotSize = ",LotSize , " , InpDollar_Amount_To_Risk = ", InpDollar_Amount_To_Risk, " , pips_to_sl_Amount = ", pips_to_sl_Amount);          
         ticket = OrderSend(Symbol(),OP_BUY,LotSize,Ask,3,stop_price,takeprofit_price,InpTradeComment,InpMagicNumber,0,clrGreen);   
         
         break;   
   
      case OP_SELL: // SELL MARKET ORDER
         stop_price = InpPrice_SL; // SL price
         pips_to_sl = stop_price-Bid; //pips to sl (ie: 0.00500)
         takeprofit_price = Bid-(pips_to_sl*InpReward_ratio);
         
         pips_to_sl_Amount = (pips_to_sl/pips); //amount pips to sl (ie: 50.0 pips)
         pips_to_sl_Amount  = NormalizeDouble(pips_to_sl_Amount,2);
         
         LotSize = (InpDollar_Amount_To_Risk/ pips_to_sl_Amount) / 10;
Print(" LotSize = ",LotSize , " , InpDollar_Amount_To_Risk = ", InpDollar_Amount_To_Risk, " , pips_to_sl_Amount = ", pips_to_sl_Amount);          
         
         ticket = OrderSend(Symbol(),OP_SELL,LotSize,Bid,3,stop_price,takeprofit_price,InpTradeComment,InpMagicNumber,0,clrGreen);   
         
         break;   

      case OP_BUYLIMIT: // BUY LIMIT ORDER
      
         if (InpEntry_Price > Bid) // invalid buy limit order, the limit is greater than Bid
         {
            Print("===Invalid Buy limit Order Price = ",InpEntry_Price, " , is greater than current Bid = ", Bid); 
            Alert("===Invalid Buy limit Order Price =");
            return;
         }
      
      
         stop_price = InpPrice_SL; // SL price
         pips_to_sl = InpEntry_Price-stop_price; //pips to sl (ie: 0.00500)
         takeprofit_price = InpEntry_Price+(pips_to_sl*InpReward_ratio);
         
         pips_to_sl_Amount = (pips_to_sl/pips); //amount pips to sl (ie: 50.0 pips)
         pips_to_sl_Amount  = NormalizeDouble(pips_to_sl_Amount,2);
         
         LotSize = (InpDollar_Amount_To_Risk/ pips_to_sl_Amount) / 10;
Print(" LotSize = ",LotSize , " , InpDollar_Amount_To_Risk = ", InpDollar_Amount_To_Risk, " , pips_to_sl_Amount = ", pips_to_sl_Amount);          
         
         ticket = OrderSend(Symbol(),OP_BUYLIMIT,LotSize,InpEntry_Price,3,stop_price,takeprofit_price,InpTradeComment,InpMagicNumber,0,clrGreen);   
         
         break;   


      case OP_SELLLIMIT: // SELL LIMIT ORDER
      
         if (InpEntry_Price < Ask) // invalid sell limit order, the limit is lower than Ask
         {
            Print("===Invalid Sell limit Order Price = ",InpEntry_Price, " , is lower than current Ask = ", Ask); 
            Alert("===Invalid Sell limit Order Price =");
            return;
         }
      
      
         stop_price = InpPrice_SL; // SL price
         pips_to_sl = stop_price-InpEntry_Price; //pips to sl (ie: 0.00500)
         takeprofit_price = InpEntry_Price-(pips_to_sl*InpReward_ratio);
         
         pips_to_sl_Amount = (pips_to_sl/pips); //amount pips to sl (ie: 50.0 pips)
         pips_to_sl_Amount  = NormalizeDouble(pips_to_sl_Amount,2);
         
         LotSize = (InpDollar_Amount_To_Risk/ pips_to_sl_Amount) / 10;
Print(" LotSize = ",LotSize , " , InpDollar_Amount_To_Risk = ", InpDollar_Amount_To_Risk, " , pips_to_sl_Amount = ", pips_to_sl_Amount);          
         
         ticket = OrderSend(Symbol(),OP_SELLLIMIT,LotSize,InpEntry_Price,3,stop_price,takeprofit_price,InpTradeComment,InpMagicNumber,0,clrGreen);   
         
         break;   


      case OP_BUYSTOP: // BUY STOP ORDER
      
         if (InpEntry_Price < Bid) // invalid buy stop order, the stop is lower than Bid
         {
            Print("===Invalid Buy stop Order Price = ",InpEntry_Price, " , is lower than current Bid = ", Bid); 
            Alert("===Invalid Buy stop Order Price =");
            return;
         }
      
      
         stop_price = InpPrice_SL; // SL price
         pips_to_sl = InpEntry_Price-stop_price; //pips to sl (ie: 0.00500)
         takeprofit_price = InpEntry_Price+(pips_to_sl*InpReward_ratio);
         
         pips_to_sl_Amount = (pips_to_sl/pips); //amount pips to sl (ie: 50.0 pips)
         pips_to_sl_Amount  = NormalizeDouble(pips_to_sl_Amount,2);
         
         LotSize = (InpDollar_Amount_To_Risk/ pips_to_sl_Amount) / 10;
Print(" LotSize = ",LotSize , " , InpDollar_Amount_To_Risk = ", InpDollar_Amount_To_Risk, " , pips_to_sl_Amount = ", pips_to_sl_Amount);          
         
         ticket = OrderSend(Symbol(),OP_BUYSTOP,LotSize,InpEntry_Price,3,stop_price,takeprofit_price,InpTradeComment,InpMagicNumber,0,clrGreen);   
         
         break;   


      case OP_SELLSTOP: // SELL STOP ORDER
      
         if (InpEntry_Price > Ask) // invalid sell stop order, the stop is higher than Ask
         {
            Print("===Invalid Sell stop Order Price = ",InpEntry_Price, " , is higher than current Ask = ", Ask); 
            Alert("===Invalid Sell stop Order Price =");
            return;
         }
      
      
         stop_price = InpPrice_SL; // SL price
         pips_to_sl = stop_price-InpEntry_Price; //pips to sl (ie: 0.00500)
         takeprofit_price = InpEntry_Price-(pips_to_sl*InpReward_ratio);
         
         pips_to_sl_Amount = (pips_to_sl/pips); //amount pips to sl (ie: 50.0 pips)
         pips_to_sl_Amount  = NormalizeDouble(pips_to_sl_Amount,2);
         
         LotSize = (InpDollar_Amount_To_Risk/ pips_to_sl_Amount) / 10;
Print(" LotSize = ",LotSize , " , InpDollar_Amount_To_Risk = ", InpDollar_Amount_To_Risk, " , pips_to_sl_Amount = ", pips_to_sl_Amount);          
         
         ticket = OrderSend(Symbol(),OP_SELLSTOP,LotSize,InpEntry_Price,3,stop_price,takeprofit_price,InpTradeComment,InpMagicNumber,0,clrGreen);   
         
         break;   
   
   
   
   }


   if(ticket==-1) // fail to open an order
   {
      int err = GetLastError();
      Print("Encountered an error during order placement!"+(string)err+" "+ErrorDescription(err)  );
      Alert("Encountered an error during order placement!");
      if(err==ERR_TRADE_NOT_ALLOWED)MessageBox("You can not place a trade because \"Allow Live Trading\" is not checked in your options. Please check the \"Allow Live Trading\" Box!","Check Your Settings!");
   }




}