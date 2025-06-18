//+------------------------------------------------------------------+
//|                                                         lab5.mq4 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

double volume = 0.01;
double x = 3;
double DISTANCE = 5;
int magic = 12345;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit() {
   MathSrand(TimeCurrent());
   int random = MathRand()%2;
   if(random==0) {
      OrderSend(Symbol(),OP_BUY,volume, Ask, 0, Ask-DISTANCE*Point, Ask+DISTANCE*Point, NULL, magic);
   } else {
      OrderSend(Symbol(),OP_SELL,volume, Bid, 0, Bid+DISTANCE*Point, Bid-DISTANCE*Point, NULL, magic);
   }
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick() {
   int temp = 0;
   for(int i=OrdersTotal(); i>0; i--) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);

      if(OrderType()==OP_BUY) {
         if(OrderMagicNumber()==magic&&OrderSymbol()==Symbol()) {
            if(Bid < OrderOpenPrice() - x*Point) {
               OrderSend(Symbol(),OP_BUY,volume, Ask, 0, Ask-DISTANCE*Point, Ask+DISTANCE*Point, NULL, magic);
            }
            temp++;
         }
      }

      if(OrderType()==OP_SELL) {
         if(OrderMagicNumber()==magic&&OrderSymbol()==Symbol()) {
            if(Ask > OrderOpenPrice() + x*Point) {
               OrderSend(Symbol(),OP_SELL,volume, Bid, 0, Bid+DISTANCE*Point, Bid-DISTANCE*Point, NULL, magic);
            }
            temp++;
         }
      }

      if(temp==2)
         break;

   }
}

void OnTimer() {

}
//+------------------------------------------------------------------+
