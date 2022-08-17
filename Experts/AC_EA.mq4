//+------------------------------------------------------------------+
//|                                                        AC_EA.mq4 |
//|                                                              gfx |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "gfx"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


double InpVol = 0.1;


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
   
   int ACstatus = checkACStatuts();
   
   //Buy
   if(ACstatus == 1)
   {
      if(OrdersTotal()>0)
      {
         closePositions(OP_SELL);
      }
   
      if(OrdersTotal()==0)
      {
         OpenPosition(OP_BUY);   
      }   
   }
   
   //Short
   else if(ACstatus == -1)
   {
      if(OrdersTotal()>0)
      {
         closePositions(OP_BUY);
      }
      
      if(OrdersTotal()==0)
      {
         OpenPosition(OP_SELL);   
      }   
   }
   
  }
//+------------------------------------------------------------------+


int checkACStatuts()
{

   int result = 0;
   
   double ac1 = iAC(0,0,1);
   double ac2 = iAC(0,0,2);
   
   //Buy
   if(ac2<0 && ac1>0)
   {
      result = 1; 
   }

   //Sell
   if(ac2>0 && ac1<0)
   {
      result = -1;
   }

   return result;
      
}



void closePositions(ENUM_ORDER_TYPE type)
{

   double price = (type==ORDER_TYPE_BUY) ? SymbolInfoDouble(Symbol(), SYMBOL_BID) 
                                         : SymbolInfoDouble(Symbol(), SYMBOL_ASK);
                                         
   int totalPos = OrdersTotal()-1;
      
   for(int i=totalPos; i>=0; i--)
   {  
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if(   type==OrderType()
         && Symbol() == OrderSymbol()
         //&& magic == OrderMagicNumber()
        )
      {
         OrderClose(OrderTicket(), OrderLots(), price, 0, clrRed); 
      }  
      
   }

}





void OpenPosition(ENUM_ORDER_TYPE type)
{

   double price = (type==ORDER_TYPE_BUY) ? SymbolInfoDouble(Symbol(), SYMBOL_ASK) 
                                         : SymbolInfoDouble(Symbol(), SYMBOL_BID);


   OrderSend(Symbol(), type, InpVol, price, 0, 0, 0, NULL, 0, 0, clrGreen);


}
