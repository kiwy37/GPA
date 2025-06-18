//+------------------------------------------------------------------+
//|                                                         lab6.mq4 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double x = 5;
datetime cTime = 0;
int bars = 10;
double distance =10;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool newBar() {
   if(cTime == Time[1])
      return false;
   cTime = Time[1];
   return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int crestePret(int n) {
   double average =0;
   for(int i=1; i<=n; i++) {
      average += (High[i]+ Low[i])/2;
   }
   average = average/n;

   if(average + x*Point < Ask) {
      return 1;
   }

   return 0;
}

int scadePret(int n) {
   double average =0;
   for(int i=1; i<=n; i++) {
      average += (High[i]+ Low[i])/2;
   }
   average = average/n;

   if(average - x*Point > Bid) {
      return 1;
   }

   return 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit() {
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick() {
   if(!newBar())
      return;
      
      if(crestePret(bars))
      {
      OrderSend(Symbol(), OP_BUY, 0.01, Ask, 0, Ask-distance*Point, Ask+distance*Point, NULL, 12345);
      }
      
      if(scadePret(bars))
      {
      OrderSend(Symbol(), OP_SELL, 0.01, Bid, 0, Bid+distance*Point, Bid-distance*Point, NULL, 12345);
      }
   }
}
//+------------------------------------------------------------------+
