//+------------------------------------------------------------------+
//|                                                         20AO.mq4 |
//|                                                               sk |
//|                                                http://www.sk.net |
//+------------------------------------------------------------------+
#property copyright "sk"
#property link      "http://www.sk.net"
//---- indicator settings
#property   indicator_separate_window

#property   indicator_buffers 6  // Up/Down, Signal
#property   indicator_color1  White
#property   indicator_color2  Lime
#property   indicator_color3  Red
#property   indicator_color4  LightPink//Up
#property   indicator_color5  LightBlue//Down
#property   indicator_color6  Gray   //Signal

//---- indicator buffers
double   ExtBuffer0[];
double   ExtBuffer1[];
double   ExtBuffer2[];
//---- Up/Down, Signal
double   UpSignalBuffer[];    //Up
double   DownSignalBuffer[];  //Down
double   SignalBuffer[];      //Signal

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   //---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexStyle(3,DRAW_HISTOGRAM); //Up
   SetIndexStyle(4,DRAW_HISTOGRAM); //Down
   SetIndexStyle(5,DRAW_LINE);      //Signal
   
   IndicatorDigits(Digits+1);
   SetIndexDrawBegin(0,34);
   SetIndexDrawBegin(1,34);
   SetIndexDrawBegin(2,34);
   SetIndexDrawBegin(3,34);//Up
   SetIndexDrawBegin(4,34);//Down
   SetIndexDrawBegin(5,34);//Signal
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtBuffer0);
   SetIndexBuffer(1,ExtBuffer1);
   SetIndexBuffer(2,ExtBuffer2);
   SetIndexBuffer(3,UpSignalBuffer);   //Up
   SetIndexBuffer(4,DownSignalBuffer); //Down
   SetIndexBuffer(5,SignalBuffer);     //Signal
   // Up/DownSignal
   SetIndexEmptyValue(3,0.0);
   SetIndexEmptyValue(4,0.0);
   SetIndexEmptyValue(5,0.0);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("20AO");
   SetIndexLabel(1,NULL);
   SetIndexLabel(2,NULL);
   SetIndexLabel(3,NULL);
   SetIndexLabel(4,NULL);
   SetIndexLabel(5,NULL);
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Awesome Oscillator                                               |
//+------------------------------------------------------------------+
int start()
  {
   int    limit;
   int    counted_bars=IndicatorCounted();
   double prev,current;
   double prev2;  // Up/Down
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- macd
   for(int i=0; i<limit; i++)
      ExtBuffer0[i]=iMA(NULL,0,5,0,MODE_EMA,PRICE_MEDIAN,i)-iMA(NULL,0,34,0,MODE_EMA,PRICE_MEDIAN,i);
//---- dispatch values between 2 buffers
   bool up=true;
   for(i=limit-1; i>=0; i--){
      current=ExtBuffer0[i];
      prev=ExtBuffer0[i+1];
      prev2=ExtBuffer0[i+2];  // Up/Down
      if(current>prev) up=true;
      if(current<prev) up=false;
      if(!up){
         ExtBuffer2[i]=current;
         ExtBuffer1[i]=0.0;
      }
      else{
         ExtBuffer1[i]=current;
         ExtBuffer2[i]=0.0;
      }
      // Up/DownSignal
      // zero line over
      if(current>0 && prev<0) UpSignalBuffer[i]=current;    // minus to plus
      if(current<0 && prev>0) DownSignalBuffer[i]=current;  // plus to minus
      // Saucer signal, WTop/WBottom
      if(current>0 && prev>0 && prev2>0){
         // zero over
         // Saucer Up
         if(current>prev && prev<prev2) UpSignalBuffer[i]=current;   
         //WTop
         if(current<prev && prev>prev2){
            for(int i0=i+3;(ExtBuffer0[i0]>0 && ExtBuffer0[i0+1]>0 && ExtBuffer0[i0+2]>0);i0++){
               double cur1=ExtBuffer0[i0], pre1=ExtBuffer0[i0+1], pre2=ExtBuffer0[i0+2];
               if(cur1<pre1 && pre1>pre2){
                  if(prev<pre1) DownSignalBuffer[i]=current; 
                  break;
               }
            }
         }
         
      }
      if(current<0 && prev<0 && prev2<0){
         // zero under
         // Saucer Down
         if(current<prev && prev>prev2) DownSignalBuffer[i]=current;
         //WBottom
         if(current>prev && prev<prev2){
            for(int i1=i+3;(ExtBuffer0[i1]<0 && ExtBuffer0[i1+1]<0 && ExtBuffer0[i1+2]<0);i1++){
               double cur01=ExtBuffer0[i1], pre01=ExtBuffer0[i1+1], pre02=ExtBuffer0[i1+2];
               if(cur01>pre01 && pre01<pre02){
                  if(prev>pre01) UpSignalBuffer[i]=current; 
                  break;
               }
            }
         }
      }
     }
//---- signal line counted in the 2-nd buffer
   for(i=0; i<limit; i++)
      SignalBuffer[i]=iMAOnArray(ExtBuffer0,Bars,5,0,MODE_SMA,i);
//---- done
   return(0);
  }
//+------------------------------------------------------------------+