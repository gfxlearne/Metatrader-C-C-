//+------------------------------------------------------------------+
//|                                                      Deleter.mq4 |
//|                                                               ZB |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "gfx"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


// created 18/12/2021

// DELETE MARKET ORDERS (for speciic symbol) 

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   // FIFO
   for(int i=0; i<=OrdersTotal()-1; i++) // OrdersTotal is in the for statement in-order to self-adjust 
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderType()<2 && OrderSymbol()==Symbol()) // market orders only(not pending orders)
         {
            double price = Ask; // assuming OP_SELL
            int ticket = OrderTicket();
            int type = OrderType();
            if(type == OP_BUY)
               price = Bid;            
                  
            if(!OrderClose(ticket,OrderLots(),price,30,clrNONE))
               Print(GetLastError());
            else // succeeded closing the order
               i--; // because of fifo we need to repeat the same i  
         }
      
   }

   
}
//+------------------------------------------------------------------+
