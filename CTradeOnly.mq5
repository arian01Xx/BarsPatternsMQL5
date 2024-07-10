#include <Trade/Trade.mqh>

CTrade trade;

input ENUM_TIMEFRAMES Timeframe=PERIOD_M5;
int barsTotal;
int bars;
input double TpFactors=3.33;
double lots=0.1;
double open1;
double close1;
double low1;
double high1;
double open2;
double close2;
double low2;
double high2;
double open3;
double close3;
double open4;
double close4;

int OnInit(){

   barsTotal=iBars(_Symbol,Timeframe);
   bars=iBars(_Symbol,Timeframe);
   
   open1=iOpen(_Symbol,Timeframe,1);
   close1=iClose(_Symbol,Timeframe,1);
   low1=iLow(_Symbol,Timeframe,1);
   high1=iHigh(_Symbol,Timeframe,1);
   
   open2=iOpen(_Symbol,Timeframe,2);
   close2=iClose(_Symbol,Timeframe,2);
   low2=iLow(_Symbol,Timeframe,2);
   high2=iHigh(_Symbol,Timeframe,2);
   
   open3=iOpen(_Symbol,Timeframe,3);
   close3=iClose(_Symbol,Timeframe,3);
    
   open4=iOpen(_Symbol,Timeframe,4);
   close4=iClose(_Symbol,Timeframe,4);
   
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){

}

void OnTick(){

   int period=14;
   double sma=SMA(period);
   double ema=EMA(period);
   
   double currentPrice=iClose(_Symbol,Timeframe,0);
   
   if(barsTotal!=bars){
     barsTotal=iBarShift(_Symbol,Timeframe,0);
     if(currentPrice>sma && currentPrice>ema){
       //UPTREND
       //reversal bar pattern
       if(open1<close1){ //identife the first green bar
         if(open2>close2){  //red bar
           if(low1<low2 && high1<high2){
             double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
             ask=NormalizeDouble(ask,_Digits);
             int indextLowestLow=iLowest(_Symbol,Timeframe,MODE_LOW,2,1);
             double sl=iLow(_Symbol,Timeframe,indextLowestLow);
             double tp=ask+(ask-sl)*TpFactors;
             trade.Buy(lots,_Symbol,ask,sl,tp);
           }
         }
       }
       
       //pattern key reversal bar
       if(open1<close1){ //the first green bar
         if(open2<close2){  //red bar
           if(low1<low2 && high1>high2){ //the first bars would be a gigant
             //buying
             double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
             ask=NormalizeDouble(ask,_Digits);
             int indextLowestLow=iLowest(_Symbol,Timeframe,MODE_LOW,2,1);
             double sl=iLow(_Symbol,Timeframe,indextLowestLow);
             double tp=ask+(ask-sl)*TpFactors;
             trade.Buy(lots,_Symbol,ask,sl,tp);
           }
         }
       }
       
       //strategy one
       if(open1 <close1){ //checking if the last bar is green
         if(open2 > close2 && open3 >close3 && open4 > close4){ //red
           if(close1 >open4){ //check if last bar is really big
             Print("buy signal...");
             double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
             //get lowest low of the last 4 bars
             int indexLowestLow=iLowest(_Symbol,Timeframe,MODE_LOW,4,1);
             //get low of the lowest low of the last 4 bars
             double sl=iLow(_Symbol,Timeframe,indexLowestLow);
             double tp=ask+(ask-sl)*TpFactors;
             trade.Buy(lots,_Symbol,ask,sl,tp);
           }
         }
       } 
     
     }
     if(currentPrice<sma && currentPrice<ema){
     //DOWNTREND
       if(open1<close1){
         if(open2>close2){
           if(low1<low2 && high1>high2){
             //selling
             double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
             bid=NormalizeDouble(bid,_Digits);
             int indextHighestHigh=iHighest(_Symbol,Timeframe,MODE_HIGH,2,1);
             double sl=iHigh(_Symbol,Timeframe,indextHighestHigh);
             double tp=bid-(sl-bid)*TpFactors;
             trade.Sell(lots,_Symbol,bid,sl,tp);
           }
         }
       }
       if(open1 > close1){  //checking if the last bar is red
         if(open2<close2 && open3<close3 && open4<close4){ //green
           if(close1 < open4){ //check if last bar is really big
             Print("sell signal...");
             double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
             //get highest hiw of the last 4 bars
             int indexHighestHigh=iHighest(_Symbol,Timeframe,MODE_LOW,4,1);
             //get low of the lowest low of the last 4 bars
             double sl=iHigh(_Symbol,Timeframe,indexHighestHigh);
             double tp=bid-(sl-bid)*TpFactors;
             trade.Sell(lots,_Symbol,bid,sl,tp);
           }
         }
       }
     }
   }
}

double SMA(int period){
  double sum=0.0;
  for(int i=0; i<period; i++){
    sum += iClose(_Symbol,Timeframe,i);
  }
  return sum/period;
}

double EMA(int period){
  double ema=iClose(_Symbol,Timeframe,0); //precio actual
  double multiplier=2.0/(period+1.0);
  for(int i=1; i<period; i++){
    ema += (iClose(_Symbol,Timeframe,i)-ema)*multiplier;
  }
  return ema;
}