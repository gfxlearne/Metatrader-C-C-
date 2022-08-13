//+------------------------------------------------------------------+
//|                                                   MsgBoxTest.mq4 |
//|                                                              gfx |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "gfx"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window


// MessageBox function do no not work on an indicators (only scripts and EAs)
// however MessageBoxW do work 

#include <WinUser32.mqh>



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{

   if(Period()!=PERIOD_H4)
   {
      //MessageBox("This only works on 4H timeframe. \nCahnge to the 4h TimeFrame and reload."
      //             , "Can not Initialize"
      //             , MB_ICONERROR);


      Alert("Message Box On indicator PopUp");


      MessageBoxW(WindowHandle(Symbol(), Period())
                   , "This only works on 4H timeframe. \nCahnge to the 4h TimeFrame and reload."
                   , "Can not Initialize"
                   , MB_ICONERROR);
 
 
      Alert("Message Box Closed.   (INIT_FAILED)");

      

      return (INIT_FAILED);   
   }


   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
