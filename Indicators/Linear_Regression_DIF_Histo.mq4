//+------------------------------------------------------------------+
//|                                  Linear_Regression_DIF_Histo.mq4 |
//|                                                              gfx |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "gfx"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+


//--- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 2
#property  indicator_color1  Silver
#property  indicator_color2  Red
#property  indicator_width1  2




//--- indicator buffers
double    ExtMacdBuffer[];
double    ExtSignalBuffer[];
//--- right input parameters flag
bool      ExtParameters=false;



int OnInit()
{
      
   IndicatorDigits(Digits+1);
//--- drawing settings
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_LINE);
   //SetIndexDrawBegin(1,InpSignalSMA); 
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtMacdBuffer);
   SetIndexBuffer(1,ExtSignalBuffer);

   IndicatorShortName("Z_Linear_regression_DIF_Histo(" );//+IntegerToString(InpFastMA)+","+IntegerToString(InpSlowMA)+","+IntegerToString(InpSlowShift)+","+IntegerToString(InpSignalSMA)+")");
   SetIndexLabel(0,"Z_Lin_Reg_Histo");
   SetIndexLabel(1,"Signal");

   
   
   
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

   int i,limit;
//---
   //=if(rates_total<=InpSignalSMA || !ExtParameters)
      //=return(0);
//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(prev_calculated>0)
      limit++;
//--- macd counted in the 1-st buffer   
limit=30;
   for(i=0; i<limit; i++)
   {
      //ExtMacdBuffer[i]=iMA(NULL,0,InpFastMA,0,MODE_EMA,PRICE_CLOSE,i)-
      //              iMA(NULL,0,InpSlowMA,0,MODE_EMA,PRICE_CLOSE,i);
      
double indi1 =  iCustom(Symbol(),Period(),"Z_Linear_Regression",true,20,0+i,    0, 0+i); // 20linear regression slope(1),-shift1 //mql4 file     
double indi20 = iCustom(Symbol(),Period(),"Z_Linear_Regression",true,20,0+i,    0, 19+i); // 20linear regression slope(1),-shift1 //mql4 file     
double dif =  indi1 - indi20;

ExtMacdBuffer[i]= dif;
      
      
  }





   return(rates_total);
  }
//+------------------------------------------------------------------+
