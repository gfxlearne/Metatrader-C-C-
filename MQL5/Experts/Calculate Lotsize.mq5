//+------------------------------------------------------------------+
//|                                            Calculate Lotsize.mq5 |
//+------------------------------------------------------------------+

#property version   "1.00"


#include <Trade/Trade.mqh>


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

   if(PositionsTotal() != 0) return;
   
   double entry = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   entry = NormalizeDouble(entry, _Digits);
   
   double sl = entry - 280 * _Point; // 280 points sl
   sl = NormalizeDouble(sl, _Digits);
   
   double lots = calcLots(1.5, entry-sl); // 1.5% risk, (entry-sl) points in tisk
   
   CTrade trade;
   trade.Buy(lots,_Symbol,entry,sl);
   
   
   //calcLots(1.5, 0.00280); // 1.5% risk,  280 points(28 pips)
      
}
//+------------------------------------------------------------------+



double calcLots(double riskPercent, double slDistance)
{

   double tickSize = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);     // smallest change in pip(point) value
   double tickValue = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);   // change in value for 1.0 lot for smallest change in pip value
   double lotStep = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);          // smallest increment in lot size

   // Print(tickSize, " ", tickValue, " ", lotStep);
      
   if(tickSize==0 || tickValue==0 || lotStep==0)
   {
      Print(__FUNCTION__, " > Lotsize cannot be calculted...");
      return 0;   
   }
   
   double riskMoney = AccountInfoDouble(ACCOUNT_BALANCE) * riskPercent / 100; // how much money we want to risk(ex: 53$)
   
   double moneyLotStep = (slDistance / tickSize) * tickValue * lotStep;
   
   if(moneyLotStep==0) // we can not devide by 0 
      return 0;
      
   double lots = riskMoney / moneyLotStep * lotStep;
   
   lots = MathFloor(lots);
   
   Print(riskMoney, " ", moneyLotStep, " ", lots);

   
   return lots;

}