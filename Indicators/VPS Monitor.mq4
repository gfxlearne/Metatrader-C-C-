//+------------------------------------------------------------------+
//|                                                  VPS Monitor.mq4 |
//|                                                              gfx |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "gfx"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

input bool     SendEmail=false; // Send Email
input bool     SendNotif=true; // Send Notification
input int      ScheduleHour=6; // Period Active in Hour
input string   Message="Account XXX is ON"; // Message


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   OnTimer();
  EventSetTimer(ScheduleHour*60*60);
//--- indicator buffers mapping
  
//---
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
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
//---
   if (SendNotif)
   {
      SendNotification(Message);
      Print("Send Notification Last Error:"+(string)GetLastError());
   }
  
   if (SendEmail)
   {
      SendMail(Message,Message);
      Print("Send Email Last Error:"+(string)GetLastError());
   }
  
   Print(Message);
}
//+------------------------------------------------------------------+
