//+------------------------------------------------------------------+
//|                                                    10AtrBand.mq4 |
//|                                                               sk |
//|                                               http://www.sk.net/ |
//+------------------------------------------------------------------+
#property copyright "sk"
#property link      "http://www.sk.net/"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 DodgerBlue
#property indicator_color2 DodgerBlue

//---- input parameters
extern int AtrPeriod=14;
//---- buffers
double Ue[];
double Sita[];
double TempBuffer[];
//double AtrBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init(){
//---- 1 additional buffer used for counting.
   IndicatorBuffers(3);
//---- indicator line
   SetIndexStyle(0,DRAW_LINE);   //Ue
   SetIndexStyle(1,DRAW_LINE);   //Sita
   //SetIndexStyle(2,DRAW_NONE);   //TempBuffer
   //SetIndexStyle(3,DRAW_NONE);   //AtrBuffer
   SetIndexBuffer(0,Ue);
   SetIndexBuffer(1,Sita);
   SetIndexBuffer(2,TempBuffer);
   //SetIndexBuffer(3,AtrBuffer);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("10AtrBand("+AtrPeriod+")");
   SetIndexLabel(0,"10ABUe");
   SetIndexLabel(1,"10ABSita");
   //SetIndexLabel(2,"10ABTemp");
   //SetIndexLabel(3,"10ABAtr");
//----
   SetIndexDrawBegin(0,AtrPeriod);
   SetIndexDrawBegin(1,AtrPeriod);
   //SetIndexDrawBegin(2,AtrPeriod);
   //SetIndexDrawBegin(3,AtrPeriod);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Average True Range                                               |
//+------------------------------------------------------------------+
int start(){
   int i,counted_bars=IndicatorCounted();
//----
   if(Bars<=AtrPeriod) return(0);
//---- initial zero
   //if(counted_bars<1)
   //   for(i=1;i<=AtrPeriod;i++) AtrBuffer[Bars-i]=0.0;
//----
   i=Bars-counted_bars-1;
   while(i>=0)
     {
      double high=High[i];
      double low =Low[i];
      if(i==Bars-1) TempBuffer[i]=high-low;
      else
        {
         double prevclose=Close[i+1];
         TempBuffer[i]=MathMax(high,prevclose)-MathMin(low,prevclose);
        }
      i--;
     }
//----
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   for(i=0; i<limit; i++){
      //AtrBuffer[i]=iMAOnArray(TempBuffer, Bars, AtrPeriod, 0, MODE_SMA,i);
      double AtrBuffer=iMAOnArray(TempBuffer, Bars, AtrPeriod, 0, MODE_SMA,i);
      Ue[i]=Close[i]+AtrBuffer;
      Sita[i]=Close[i]-AtrBuffer;
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+