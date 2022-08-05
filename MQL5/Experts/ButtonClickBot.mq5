//+------------------------------------------------------------------+
//|                                               ButtonClickBot.mq5 |
//|                                                              gfx |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "gfx"
#property link      ""
#property version   "1.00"

#include <Trade/Trade.mqh>

#define KEY_B 66
#define KEY_C 67
#define KEY_S 83

CTrade trade;

double mousePrice;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{

   mousePrice = 0;

   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,true); // chart=0.  CHART_EVENT_MOUSE_MOVE is set to true in-order to catch the mouse move on chart
   
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
   
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| OnChartEvent function                                            |
//+------------------------------------------------------------------+
void  OnChartEvent(const int       id,       // event ID  
                   const long&     lparam,   // long type event parameter 
                   const double&   dparam,   // double type event parameter 
                   const string&   sparam    // string type event parameter 
   )
{

   Print(id, " ", lparam, " ", dparam, " ", sparam);   


   if(id == CHARTEVENT_MOUSE_MOVE)
   {

      int lastX = (int)lparam;
      int lasty = (int)dparam;
      
      int subWindow;
      datetime time;
      
      ChartXYToTimePrice(0,lastX,lasty,subWindow,time,mousePrice); // the price&time that the mouse cursor is on
      //ChartXYToTimePrice(0,(int)lparam,(int)dparam,subWindow,time,mousePrice); // the price&time that the mouse cursor is on
      
      mousePrice = NormalizeDouble(mousePrice,_Digits);
      
      Print(mousePrice, " ", time);
      
   }
   

   if(id == CHARTEVENT_KEYDOWN)
   {
      if(lparam == KEY_B) 
      {
         Print("'b' was pressed...");
         Print("Open Buy Position...");
         
         if(mousePrice > SymbolInfoDouble(_Symbol,SYMBOL_ASK)) // mouse price is above the current ask price
         {
            trade.BuyStop(0.1,mousePrice);
         
         }
         
         else // mouse price is below the current ask price
         {
            if(mousePrice != 0) // just in case that mousePrice hasn't been set for some reason
            {
               trade.BuyLimit(0.1,mousePrice);
            }                     
         }
         
         // trade.Buy(0.1);
      }         
      
      
      if(lparam == KEY_C) // (lparam == 67)
      {
         Print("'c' was pressed...");
      }         
      
      
      if(lparam == KEY_S) 
      {
         Print("'s' was pressed...");
         Print("Open Short Position...");
         
         if(mousePrice > SymbolInfoDouble(_Symbol,SYMBOL_ASK)) // mouse price is above the current ask price
         {
            trade.SellLimit(0.1,mousePrice);
         
         }
         
         else // mouse price is below the current ask price
         {
            if(mousePrice != 0) // just in case that mousePrice hasn't been set for some reason
            {
               trade.SellStop(0.1,mousePrice);
            }                     
         }
                  
         // trade.Sell(0.1);         
      }   
                        
   }

}   
