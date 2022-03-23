//+------------------------------------------------------------------+
//|                                                      Deleter.mq4 |
//|                                                              gfx |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "gfx"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


// created 18/12/2021

// DELETE PENDING ORDERS (for speciic symbol) 

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   // FIFO
   for(int i=0; i<=OrdersTotal()-1; i++) // OrdersTotal is in the for statement in-order to self-adjust 
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderType()>1 && OrderSymbol()==Symbol()) // pending orders only(not market orders)
         {
            int ticket = OrderTicket();
            if(!OrderDelete(ticket))
               Print(GetLastError());
            else // succeeded deleting the order
               i--; // because of fifo we need to repeat the same i  
         }
      
   }

   
}
//+------------------------------------------------------------------+
