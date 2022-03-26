//+------------------------------------------------------------------+
//|                                                        NR4ID.mq4 |
//|                                                 Николай Максимов |
//|                                                  nikki21@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Николай Максимов"
#property link      "nikki21@mail.ru"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red
//+------------------------------------------------------------------+
extern int       Back=4;
//+------------------------------------------------------------------+
double ExtMapBuffer1[];
//+------------------------------------------------------------------+
int init(){
  SetIndexStyle(0,DRAW_ARROW);
  SetIndexArrow(0,167);
  SetIndexBuffer(0,ExtMapBuffer1);
  SetIndexEmptyValue(0,0.0);
  return(0);
}
//+------------------------------------------------------------------+
int start(){
  int i,j,pos;
  for(i=Bars-IndicatorCounted()-1;i>=0;i--){
    if ((High[i]<High[i+1])&&(Low[i]>Low[i+1])){
      pos=i;
      for(j=i+1;j<i+Back;j++)
        if ((High[j]-Low[j])<(High[i]-Low[i]))
          pos=j;
      if (pos==i) 
        ExtMapBuffer1[i]=(High[i]+Low[i])/2;
    }    
  }
  return(0);
}
//+------------------------------------------------------------------+