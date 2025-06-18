//+------------------------------------------------------------------+
//|                                                         lab8.mq4 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

datetime cTime =0;
int bars=10;
double x = 5;
double volume = 0.01;
double s=10;
int magic = 123;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool newBar() {
   if(cTime==Time[1])
      return false;
   else
      cTime=Time[1];
   return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double average() {
   double avg=0.0;
   for(int i=1; i<=bars; i++) {
      avg+=(High[i]+Low[i])/2;
   }
   avg/=bars;
   return avg;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void isAskBigger() {
   if(Ask>x*Point + average() ) {
      OrderSend(Symbol(), OP_BUY, volume, Ask, 0, Ask-x*Point, Ask+x*Point, NULL, magic);
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void isBidLower() {
   if(Bid<average()-x*Point) {
      OrderSend(Symbol(), OP_SELL, volume, Bid, 0, Bid+x*Point, Bid-x*Point, NULL, magic);
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double totalProfit() {
   double profit =0 ;
   for(int i=OrdersTotal()-1; i>=0; i--) {
      if(OrderSelect(i,SELECT_BY_POS, MODE_TRADES)) {
         if(OrderSymbol()==Symbol()&&OrderMagicNumber()==magic) {
            profit+=OrderProfit();
         }
      }
   }
   return profit;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void closeAll() {
   for(int i=OrdersTotal()-1; i>=0; i--) {
      if(OrderSelect(i,SELECT_BY_POS, MODE_TRADES)) {
         if(OrderSymbol()==Symbol()) {
            if(OrderType()==OP_BUY)
               OrderClose(OrderTicket(), OrderLots(), Bid, 0,0);
            if(OrderType()==OP_SELL)
               OrderClose(OrderTicket(), OrderLots(), Ask, 0,0);
         }
      }
   }
}

int OnInit() {

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick() {
   Print("Alt mes")
   if(newBar()) {
      isAskBigger();
      isBidLower();
   }

   double tp=totalProfit();
   if(tp>=s || tp<=-s)
      closeAll();

}
//+------------------------------------------------------------------+
