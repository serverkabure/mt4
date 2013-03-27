//+------------------------------------------------------------------+
//|                                                         10AC.mq4 |
//|                                                               sk |
//|                                                http://www.sk.net |
//+------------------------------------------------------------------+
#property copyright "sk"
#property link      "http://www.sk.net"
//---- indicator settings
#property   indicator_separate_window
#property   indicator_buffers 5  // UpDown
#property   indicator_color1  Black
#property   indicator_color2  Lime
#property   indicator_color3  Red
#property   indicator_color4  LightPink //Up
#property   indicator_color5  LightBlue //Down

//---- indicator buffers
double   ExtBuffer0[];
double   ExtBuffer1[];
double   ExtBuffer2[];
//---- UpDown
double   UpSignalBuffer[];    //Up
double   DownSignalBuffer[];  //Down
double   ExtBuffer3[];
double   ExtBuffer4[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- 2 additional buffers are used for counting.
   IndicatorBuffers(7); // UpDown
//---- drawing settings
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   //SetIndexStyle(3,DRAW_ARROW);  //UpSignal
   //SetIndexStyle(4,DRAW_ARROW);  //DownSignal
   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexStyle(4,DRAW_HISTOGRAM);
   
   IndicatorDigits(Digits+2);
   SetIndexDrawBegin(0,38);
   SetIndexDrawBegin(1,38);
   SetIndexDrawBegin(2,38);
   //SetIndexArrow(3,SYMBOL_ARROWUP);   //UpSigal
   //SetIndexArrow(4,SYMBOL_ARROWDOWN);  //DownSignal
   SetIndexDrawBegin(3,38);
   SetIndexDrawBegin(4,38);
//---- 4 indicator buffers mapping
   SetIndexBuffer(0,ExtBuffer0);
   SetIndexBuffer(1,ExtBuffer1);
   SetIndexBuffer(2,ExtBuffer2);
   SetIndexBuffer(3,UpSignalBuffer);   //UpSignal
   SetIndexBuffer(4,DownSignalBuffer); //DownSignal
   SetIndexBuffer(5,ExtBuffer3);
   SetIndexBuffer(6,ExtBuffer4);
   
   // UpDownSignal
   SetIndexEmptyValue(3,0.0); //UpSignal
   SetIndexEmptyValue(4,0.0); //DownSignal
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("10AC");
   SetIndexLabel(1,NULL);
   SetIndexLabel(2,NULL);
   SetIndexLabel(3,NULL);  //UpSignal
   SetIndexLabel(4,NULL);  //DownSignal
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Accelerator/Decelerator Oscillator                               |
//+------------------------------------------------------------------+
int start()
  {
   int    limit;
   int    counted_bars=IndicatorCounted();
   double prev,current;
   double prev2, prev3, prev4; // UpDownSignal
   //---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   //---- macd counted in the 1-st additional buffer
   for(int i=0; i<limit; i++)
      ExtBuffer3[i]=iMA(NULL,0,5,0,MODE_SMA,PRICE_MEDIAN,i)-iMA(NULL,0,34,0,MODE_SMA,PRICE_MEDIAN,i);
   //---- signal line counted in the 2-nd additional buffer
   for(i=0; i<limit; i++)
      ExtBuffer4[i]=iMAOnArray(ExtBuffer3,Bars,5,0,MODE_SMA,i);
   //---- dispatch values between 2 buffers
   bool up=true;
   for(i=limit-1; i>=0; i--)
     {
      current=ExtBuffer3[i]-ExtBuffer4[i];
      prev=ExtBuffer3[i+1]-ExtBuffer4[i+1];
      prev2=ExtBuffer3[i+2]-ExtBuffer4[i+2]; // UpDownSignal
      prev3=ExtBuffer3[i+3]-ExtBuffer4[i+3]; // UpDownSignal
      prev4=ExtBuffer3[i+4]-ExtBuffer4[i+4]; // UpDownSignal
      if(current>prev) up=true;
      if(current<prev) up=false;
      if(!up)
        {
         ExtBuffer2[i]=current;
         ExtBuffer1[i]=0.0;
        }
      else
        {
         ExtBuffer1[i]=current;
         ExtBuffer2[i]=0.0;
        }
       ExtBuffer0[i]=current;
      // UpDownSignal
      // ZeroOverUnder
      if(current>0 && prev>0 && prev2>0 && prev3>0)   // over zero
         if(current>prev && prev>prev2 && prev2<prev3) UpSignalBuffer[i]=current; // (R|G)RGG
      if(current<0 && prev<0 && prev2<0 && prev3<0)   // under zero
         if(current<prev && prev<prev2 && prev2>prev3) DownSignalBuffer[i]=current;  // (R|G)GRR
      // ZeroCross
      if(current>0 && prev<0 && prev>prev2 && prev2<prev3) UpSignalBuffer[i]=current;  // (R|G)R-G+G
      if(current<0 && prev>0 && prev<prev2 && prev2>prev3) DownSignalBuffer[i]=current;// (R|G)G+R-R
      // ZeroOverTopR3, ZeroUnderBottomG3
      if(prev3<0) // zero under bottom
         if(current>prev && prev>prev2 && prev2>prev3 && prev3<prev4) UpSignalBuffer[i]=current;//ZeroUnderBottomG3
      if(prev3>0)
         if(current<prev && prev<prev2 && prev2<prev3 && prev3>prev4) DownSignalBuffer[i]=current;//ZeroOverTopR3
     }
   //---- done
   return(0);
  }
//+------------------------------------------------------------------+