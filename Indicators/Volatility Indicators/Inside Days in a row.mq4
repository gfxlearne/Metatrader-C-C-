//+------------------------------------------------------------------+
//|                                         Inside Days in a row.mq4 |
//|                                                              gfx |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "gfx"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window


#property indicator_buffers 2
#property indicator_color1 clrRed
#property indicator_color2 clrBlue


double buf_1[];
double buf_2[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,buf_1);
   SetIndexBuffer(1,buf_2);

   SetIndexStyle (0,DRAW_ARROW, STYLE_SOLID, 2);
   SetIndexStyle (1,DRAW_ARROW, STYLE_SOLID, 2);
   SetIndexArrow (0,82);
   SetIndexArrow (1,82);

   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
   
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

   //if( rates_total == prev_calculated ) return rates_total; // only trade on new bar
    
   int limit = rates_total-prev_calculated; // usually equal to 0, unless first tick of new bar(equal to 1). and unless the first time we drop the indicator on the chart      

   if(prev_calculated==0) // first time we drop the indicator on the chart   , (!prev_calculated)  
      limit = limit-3;// added -3 because to prevent array out of range (because we check i in the for loop)  
 
   for(int i=limit-1;i>=0;i--) // calculate Green/Red histogram  (for ease of logic thinking)       
   //for(int i=limit-1;i>=1;i--) // calculate Green/Red histogram  (for ease of logic thinking)    // only on new bar
   { 
      bool DOWN  =  High[i+2] >= High[i+1] && High[i+1]>=  High[i+0] &&  
                    Low[i+2]  <= Low[i+1] &&  Low[i+1]  <= Low[i+0];
      
                       
                   
      bool UP =  High[i+2] >= High[i+1] && High[i+1] >= High[i+0] &&  
                Low[i+2]  <= Low[i+1] &&  Low[i+1]  <= Low[i+0];
            
       
      if (UP)
         buf_1[i+0] = Low[i+0]-3*Point;
      if (DOWN)
         buf_2[i+0] = High[i+0]+3*Point;
         
   }
  
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
