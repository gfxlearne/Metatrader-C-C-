//+------------------------------------------------------------------+
//|                                                   Screen DPI.mq4 |
//|                                                              gfx |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "gfx"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
//---
   int screen_dpi = TerminalInfoInteger(TERMINAL_SCREEN_DPI);
   Alert("DPI Value: ",screen_dpi);   
}
//+------------------------------------------------------------------+
