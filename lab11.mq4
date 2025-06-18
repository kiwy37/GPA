//+------------------------------------------------------------------+
//|                                                        lab11.mq4 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

extern int n=3;
extern double vol = 0.01;
extern double x=3;
datetime cTime = 0;
extern int m=12;
extern int magic=123;
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

   if(cTime==Time[1])
      return;
   cTime=Time[1];

   int openOrders=0;
   for(int i=OrdersTotal()-1; i>=0; i--) {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {
         if(OrderSymbol()==Symbol()&&OrderMagicNumber()==magic) {
            openOrders++;
         }
      }
   }
   if(openOrders>=m)
      return;

   for(int i=1; i<=n; i++) {
      if(Close[i]>iMA(NULL,0,n,0,MODE_SMA,PRICE_CLOSE,i)) {
         if(!OrderSend(Symbol(),OP_BUY, vol, Ask, 0, Ask-x*Point, Ask+x*Point, "comment", magic))
            Alert("Nu s-a deschis ordinul");
      }
      if(Close[i]<iMA(NULL,0,n,0,MODE_SMA,PRICE_CLOSE,i)) {
         if(!OrderSend(Symbol(),OP_SELL, vol, Bid, 0, Bid+x*Point, Bid-x*Point, "comment", magic))
            Alert("Nu s-a deschis ordinul");
      }
   }
}
//+------------------------------------------------------------------+
