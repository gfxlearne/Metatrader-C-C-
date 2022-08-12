//+------------------------------------------------------------------+
//|                                              BreakEvenButton.mq5 |
//|                                                              gfx |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "gfx"
#property link      "https://www.mql5.com"
#property version   "1.00"


#include <Trade/Trade.mqh>

#define BTN_BREAK_EVEN "Break Even Button"

CTrade trade;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{

   ObjectCreate(0, BTN_BREAK_EVEN, OBJ_BUTTON, 0, 0, 0);

   // position of the button
   ObjectSetInteger(0, BTN_BREAK_EVEN, OBJPROP_XDISTANCE, 100); 
   ObjectSetInteger(0, BTN_BREAK_EVEN, OBJPROP_YDISTANCE, 50);

   // size of button
   ObjectSetInteger(0, BTN_BREAK_EVEN, OBJPROP_XSIZE, 150); 
   ObjectSetInteger(0, BTN_BREAK_EVEN, OBJPROP_YSIZE, 40);
   
   // color of button
   ObjectSetInteger(0, BTN_BREAK_EVEN, OBJPROP_BGCOLOR, clrYellow);
   
   // text color of button
   ObjectSetInteger(0, BTN_BREAK_EVEN, OBJPROP_COLOR, clrRed);

   // text inside the button
   ObjectSetString(0, BTN_BREAK_EVEN, OBJPROP_TEXT, "Break Even");




   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{

   ObjectDelete(0, BTN_BREAK_EVEN);
   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{

   
}
//+------------------------------------------------------------------+






void  OnChartEvent( 
   const int       id,       // event ID  
   const long&     lparam,   // long type event parameter 
   const double&   dparam,   // double type event parameter 
   const string&   sparam    // string type event parameter 
   )
{
   
   if(id == CHARTEVENT_OBJECT_CLICK) // object on the chart has been clicked
   {
      if(sparam == BTN_BREAK_EVEN) // the BTN_BREAK_EVEN has been clicked
      {
         Print(id, " ", lparam, " ", dparam, " ", sparam);
         Print(__FUNCTION__, "  -  The break even button was clicked...");
         
         MovePositionsToOpenPrice(); 
         
         // set the state of the button back to unclick
         ObjectSetInteger(0, BTN_BREAK_EVEN, OBJPROP_STATE, false);       
      
      }
   
   }

}   





void MovePositionsToOpenPrice()
{

   for(int i=PositionsTotal()-1; i>=0; i--)
   {
      ulong posTicket = PositionGetTicket(i);
      
      if(PositionSelectByTicket(posTicket))
      {
         string posSymbol = PositionGetString(POSITION_SYMBOL); // get the currency pair name(ex: eurusd)
         
         if(posSymbol == _Symbol) // check if the symbol match the chart
         {
            ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            double posOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            double posTp = PositionGetDouble(POSITION_TP);
            double posSl = PositionGetDouble(POSITION_SL);  
            
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);       
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            
            if(posType == POSITION_TYPE_BUY)
            {
               // check if the sl can to BE
               if(bid > posOpenPrice && posSl < posOpenPrice) 
               {
                  if(trade.PositionModify(posTicket, posOpenPrice, posTp))
                  {
                     Print(__FUNCTION__, "   > Long Pos #", posTicket, " was modified by the break even button...");
                  }
               
               }
            
            }
            
            else if(posType == POSITION_TYPE_SELL)
            {
               // check if the sl can to BE
               if(ask < posOpenPrice && (posSl > posOpenPrice || posSl == 0))
               {
                  if(trade.PositionModify(posTicket, posOpenPrice, posTp))
                  {
                     Print(__FUNCTION__, "   > Short Pos #", posTicket, " was modified by the break even button...");
                  }
               }
            
            }
         
         }
      
      }
   
   
   }

}
   
