//+------------------------------------------------------------------+
//|                                             SimpleChartEvent.mq4 |
//|                                                              gfx |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "gfx"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict




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

   
}
//+------------------------------------------------------------------+




void OnChartEvent(const int id,         // Event ID 
                  const long& lparam,   // Parameter of type long event 
                  const double& dparam, // Parameter of type double event 
                  const string& sparam  // Parameter of type string events 
                 )
{  
  
   if(id == CHARTEVENT_CLICK)
   {
      MessageBox("Chart was clicked:" 
                  + "\n"
                  + "\nX-Value: " + lparam 
                  + "\n"
                  + "\nY-Value: " + dparam
                  , "Headline", MB_OK);
   }  
  
}  
  
  