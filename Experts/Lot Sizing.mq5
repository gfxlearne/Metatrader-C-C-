//+------------------------------------------------------------------+
//|                                                   Lot Sizing.mq5 |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

// 3-10-2023
// https://www.youtube.com/watch?v=7ukcoP3vEEQ



#include <Trade/Trade.mqh>
CTrade obj_Trade;


int OnInit()
{

   double Ask = NormalizeDouble( SymbolInfoDouble(_Symbol,SYMBOL_ASK), _Digits );
   double Bid = NormalizeDouble( SymbolInfoDouble(_Symbol,SYMBOL_BID), _Digits );

   double slBuy = Ask-500*_Point;
   double slSell = Bid-500*_Point;
   
   obj_Trade.Buy(calcLotSize(500,10),NULL,Ask,slBuy); // 500 points sl, 10% risk of account
   obj_Trade.Sell(calcLotSize(500,10),NULL,Bid,slSell);


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
//|                                                                  |
//+------------------------------------------------------------------+
double calcLotSize(double stoploss_or_risk_points, double percent_risk)
{

   double minLots = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double maxLots = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double stepLots = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP); // for eurusd = volume step is 0.01      , for usdjpy = volume step is 0.01
   double tickSize = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE); // for eurusd = tick size is 0.00001 , for usdjpy = tick size is 0.001         
   double tickValue = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE); // for eurusd = tick value is 1($) for 1Lot  
   
   double accountValue = fmin( fmin(AccountInfoDouble(ACCOUNT_BALANCE), 
                                    AccountInfoDouble(ACCOUNT_EQUITY)),
                                    AccountInfoDouble(ACCOUNT_MARGIN_FREE));      
   
   double riskValue = accountValue * (percent_risk/100);
   
   double risk_per_lot_value = (stoploss_or_risk_points*_Point ) *
                               (tickValue/tickSize);
   
   
   //double tradeLots = NormalizeDouble( (riskValue/risk_per_lot_value/stepLots) * stepLots , 2);  
   double tradeLots = NormalizeDouble( (riskValue/risk_per_lot_value) , 2);  


   // checking that the lots are within the allowed boundaries
   double tradeLots_checked = fmin( maxLots, fmax(tradeLots,minLots) );
   

   return tradeLots_checked;

}
