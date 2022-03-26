//+-----------------------------------------------------------------------+
//|                                          ATM_MasterCandle_IB_PBv3.mq4 |
//| Identifies the following candle formations :                          |
//| Inside Bars - candle is within or touching previous candle extreme    |
//| Master Inside Bars - a series of consecutive IB's                     |
//| PinBars - candle shadow is greater than defined ratio                 |
//| V3  Removed color key and bar timer
//+-----------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Gold
#property indicator_color2 Gold
#property indicator_width1 5
#property indicator_width2 5
#property indicator_color3 Lime
#property indicator_color4 Lime
#property indicator_width3 0
#property indicator_width4 0
#property indicator_color5 Black
#property indicator_color6 Black
#property indicator_width5 0
#property indicator_width6 0

static string   Indicator_Name      ="MasterCandlePlus";
static string   Version             ="1.0";

double MasterIB_High[], MasterIB_Low[];
double IB_High[], IB_Low[];
double PinBar_High[], PinBar_Low[];
double HighestHigh, LowestLow;
int BarCount;

extern int    MasterIB_Extra_Pips  =0;
extern string a_                   ="Default BarsBeforePaint";
extern string b_                   ="M1, M2, M3, or M4 default 5 bars";
extern string c_                   ="M5 or greater     default 4 bars";
extern string d_                   ="Set to 0 to use defaults";
extern int    MasterIB_Minimum_Bars=5;
extern color  MasterIB_Color       =Gold;
extern string e_                   ="Set width to 0 to disable";
extern int    MasterIB_Width       =5;

extern color  IB_Color             =Lime;
extern string f_                   ="Set width to 0 to disable";
extern int    IB_Width             =5;

extern int    Minimum_Nose_Ratio   =60;
extern int    Maximum_Body_Ratio   =40;
extern color  PinBar_Color         =Black;
extern string g_                   ="Set width to 0 to disable";
extern string g1_                  ="Set width to -size to show as star";
extern string g2_                  ="eg -1=small, -3=larger";
extern int    PinBar_Width         =0;


int init()
  {

   IndicatorBuffers(6);
   SetIndexStyle( 0, DRAW_HISTOGRAM, 0, MasterIB_Width, MasterIB_Color );
   SetIndexBuffer( 0, MasterIB_High );
   SetIndexStyle( 1, DRAW_HISTOGRAM, 0, MasterIB_Width, MasterIB_Color );
   SetIndexBuffer( 1, MasterIB_Low );
   SetIndexStyle( 2, DRAW_HISTOGRAM, 0, IB_Width, IB_Color );
   SetIndexBuffer( 2, IB_High );
   SetIndexStyle( 3, DRAW_HISTOGRAM, 0, IB_Width, IB_Color );
   SetIndexBuffer( 3, IB_Low );
   if( PinBar_Width>0 )
     {
      SetIndexStyle( 4, DRAW_HISTOGRAM, 0, PinBar_Width, PinBar_Color );
      SetIndexBuffer( 4, PinBar_High );
      SetIndexStyle( 5, DRAW_HISTOGRAM, 0, PinBar_Width, PinBar_Color );
      SetIndexBuffer( 5, PinBar_Low );
     }
   else if( PinBar_Width<0 )
     {
      SetIndexStyle( 4, DRAW_ARROW, 0, MathAbs( PinBar_Width ), PinBar_Color );
      SetIndexArrow( 4, 171 );
      SetIndexBuffer( 4, PinBar_High );
      SetIndexStyle( 5, DRAW_ARROW, 0, MathAbs( PinBar_Width ), PinBar_Color );
      SetIndexArrow( 5, 171 );
      SetIndexBuffer( 5, PinBar_Low );
     }
   HighestHigh      = 0;
   LowestLow        = 0;  
   return(0);
  }

int deinit()
  {
   int _ObjectsTotal=ObjectsTotal();
   for( int _Object=_ObjectsTotal; _Object>=0; _Object-- )
     {
      string _ObjectName=ObjectName( _Object );
      if( StringSubstr( _ObjectName, 0, StringLen( Indicator_Name )+2 )=="["+Indicator_Name+"]" ) ObjectDelete( _ObjectName );
     }    
   return(0);
  }


int start()
  {
   int shift, bar, limit, counted_bars=IndicatorCounted();
   double bar_length, noseup_length, nosedn_length, body_length, eye_pos;
   if( MasterIB_Minimum_Bars==0 )
     {   
      if( Period() < 5 )  MasterIB_Minimum_Bars=5;
      else                MasterIB_Minimum_Bars=4;
     }    

//---- 
   if( counted_bars<0 ) return(-1);
   if( counted_bars==0 ) limit=Bars-1;
//---- last counted bar will be recounted
   if( counted_bars>0 ) limit=Bars-counted_bars;
   limit--;
   
   for( shift=limit; shift>0; shift-- )
     {
//--- Pin Bar
      if( PinBar_Width!=0 )
        {
         bar_length=High[shift]-Low[shift];
         if( bar_length==0 ) bar_length=Point;
         noseup_length=MathMin( Open[shift], Close[shift] )-Low[shift];
         nosedn_length=High[shift]-MathMax( Open[shift], Close[shift] );
         body_length=MathAbs( Open[shift]-Close[shift] );
         if(
            noseup_length/bar_length>Minimum_Nose_Ratio/100.0
            &&
            body_length/bar_length<Maximum_Body_Ratio/100.0
            &&
            Low[shift+1]-Low[shift]>=bar_length/3.0
           )
           {
            if( PinBar_Width>0 )
              {
               if( Open[shift]<Close[shift] ) PinBar_High[shift]=Open[shift];
               else                           PinBar_High[shift]=Close[shift];
               PinBar_Low[shift]=Low[shift];
              }
            else if( PinBar_Width<0 )
              {
               PinBar_Low[shift]=Low[shift]-Point;
              }
           }
         if(
            nosedn_length/bar_length>Minimum_Nose_Ratio/100.0
            &&
            body_length/bar_length<Maximum_Body_Ratio/100.0
            &&
            High[shift]-High[shift+1]>=bar_length/3.0
           )
           {
            if( PinBar_Width>0 )
              {
               PinBar_High[shift]=High[shift];
               if( Open[shift]>Close[shift] ) PinBar_Low[shift]=Open[shift];
               else                           PinBar_Low[shift]=Close[shift];
              }
            else if( PinBar_Width<0 )
              {
               PinBar_High[shift]=High[shift]+Point;
              }
           }
        }
//--- Inside Bar
      if( IB_Width!=0 )
        {
         if(
            ( High[shift+1]<=High[shift] && Low[shift+1]>Low[shift] )
            ||
            ( High[shift+1]<High[shift] && Low[shift+1]>=Low[shift] )
           )
           {
		       IB_High[shift]=High[shift];
		       IB_Low[shift] =Low[shift];
		     }
		  }
//--- Master Inside Bar
      if( MasterIB_Width!=0 )
        {
         if( High[shift]<=HighestHigh && Low[shift]>=LowestLow ) 
           {
             BarCount++;  
           }
         else
           {
            HighestHigh=High[shift];
            LowestLow  = Low[shift];
            BarCount=0;
           }
         if( BarCount>=MasterIB_Minimum_Bars )
           {        
            for( bar=0; bar<BarCount; bar++ )   
              {
               MasterIB_High[shift+bar]=HighestHigh+( MasterIB_Extra_Pips*Point ); 
	            MasterIB_Low[shift+bar] =LowestLow  -( MasterIB_Extra_Pips*Point );  
	           }  
           }
        }
     } 
                                                    ObjectMove( "["+Indicator_Name+"] CandleTime", 0, Time[0], Close[0] );
   return(0);
  }


