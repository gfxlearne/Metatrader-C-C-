//+------------------------------------------------------------------+
//|                                                Master Candle.mq4 |
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


//---- input parameters
input int       InpNumberOfCandels=8;

//---- buffers
//double upLR[];
//double loLR[];
double MasterCandle[];
//double NoBbKeltSqueeze[];



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

   SetIndexBuffer(0,MasterCandle);
   SetIndexStyle (0,DRAW_ARROW, STYLE_SOLID, 2);
   SetIndexArrow (0,82);
   SetIndexEmptyValue(0,EMPTY_VALUE);   

   
   //SetIndexStyle(1,DRAW_ARROW);
   //SetIndexBuffer(1,NoBbKeltSqueeze);
   //SetIndexEmptyValue(1,EMPTY_VALUE);
   //SetIndexArrow(1,159);


   
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
   
   
   int limit = rates_total-prev_calculated; // usually equal to 0, unless first tick of new bar(equal to 1). and unless the first time we drop the indicator on the chart      

   if(prev_calculated==0) // first time we drop the indicator on the chart   , (!prev_calculated)  
      limit = limit-3;// added -3 because to prevent array out of range (because we check i in the for loop)  
 
   //for(int i=limit-1;i>=0;i--) // calculate Green/Red histogram     
   //for(int i=limit-1;i>=1;i--) // calculate Green/Red histogram     // only on new bar
   for(int i=limit-1;i>=InpNumberOfCandels+1;i--) // calculate setup      // only on new bar
   { 
      double currentHigh = High[i];
      double currentLow  = Low[i];
      bool validSetup = false;
      
      for(int j=i-1; j>=i-InpNumberOfCandels; j--) // checking from the next candle if the current candle is Master candle
      {
         if(currentHigh > High[j] && currentLow<Low[j]) // setup is valid
         {
            validSetup = true;
         }
         else // Not a valid setup
         {
            validSetup = false;
            break; // no need to contiue check for the i candle. can check the next candle
         }            
      }
      
      if (validSetup==true) // there is Master candle
      {
         MasterCandle[i] = High[i]+3*Point;
         MasterCandle[i-InpNumberOfCandels] = Low[i]-3*Point;
      
      }
   
            
   }
      
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+






//+------------------------------------------------------------------+
//double LinearRegressionValue(int Len,int shift) {
//   double SumBars = 0;
//   double SumSqrBars = 0;
//   double SumY = 0;
//   double Sum1 = 0;
//   double Sum2 = 0;
//   double Slope = 0;
//
//   SumBars = Len * (Len-1) * 0.5;
//   SumSqrBars = (Len - 1) * Len * (2 * Len - 1)/6;
//
//  for (int x=0; x<=Len-1;x++) {
//   double HH = Low[x+shift];
//   double LL = High[x+shift];
//   for (int y=x; y<=(x+Len)-1; y++) {
//     HH = MathMax(HH, High[y+shift]);
//     LL = MathMin(LL, Low[y+shift]);
//   }
//    Sum1 += x* (Close[x+shift]-((HH+LL)/2 + iMA(NULL,0,Len,0,MODE_EMA,PRICE_CLOSE,x+shift))/2);
//    SumY += (Close[x+shift]-((HH+LL)/2 + iMA(NULL,0,Len,0,MODE_EMA,PRICE_CLOSE,x+shift))/2);
//  }
//  Sum2 = SumBars * SumY;
//  double Num1 = Len * Sum1 - Sum2;
//  double Num2 = SumBars * SumBars-Len * SumSqrBars;
//
//  if (Num2 != 0.0)  { 
//    Slope = Num1/Num2; 
//  } else { 
//    Slope = 0; 
//  }
//
//  double Intercept = (SumY - Slope*SumBars) /Len;
//  //debugPrintln(Intercept+" : "+Slope);
//  double LinearRegValue = Intercept+Slope * (Len - 1);
//
//  return (LinearRegValue);
//
//}

