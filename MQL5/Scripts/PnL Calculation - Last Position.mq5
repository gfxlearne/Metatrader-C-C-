//+------------------------------------------------------------------+
//|                                           Profit Calculation.mq5 |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"


// Calculate the Profit/Loss of the most recent position that was closed, of a symbol 



//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{

   // Before calling HistoryDealsTotal we have to select history
   HistorySelect(0, TimeCurrent());
   
   // after selecting the history period, we can run on all deals for that period
   for(int i=HistoryDealsTotal()-1; i>=0; i--)
   {
      // go through history looking for a deal for the relevant symbol
      ulong ticket = HistoryDealGetTicket(i);
      string pair = HistoryDealGetString(ticket, DEAL_SYMBOL);  
      
      long type = HistoryDealGetInteger(ticket, DEAL_TYPE);
      long entryType = HistoryDealGetInteger(ticket, DEAL_ENTRY);
      
      if(pair==Symbol() && type<=DEAL_TYPE_SELL && entryType==DEAL_ENTRY_OUT)
      {
         long pid = HistoryDealGetInteger(ticket, DEAL_POSITION_ID);
         HistorySelectByPosition(pid);
         
         double profit = 0;
         double commission = 0;
         double swap = 0;
         
         for(int ii=HistoryDealsTotal()-1; ii>=0; ii--)
         {
            ulong dealTicket = HistoryDealGetTicket(ii);
            
            profit += HistoryDealGetDouble(dealTicket, DEAL_PROFIT);
            commission += HistoryDealGetDouble(dealTicket, DEAL_COMMISSION);
            swap += HistoryDealGetDouble(dealTicket, DEAL_SWAP);

            
         }
         
         double totalProfit = profit + swap + commission;
         
         MessageBox("The most recent profit/loss in the " + Symbol() + 
                     " was " + (string)totalProfit, "PRFOIT/LOSS");
         break;            
      }
     
      
   }
   
   
}
//+------------------------------------------------------------------+
