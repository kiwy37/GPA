//+------------------------------------------------------------------+
//|                                                         lab9.mq4 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

double volume=0.01;
double x = 5;
int magic = 123;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool areOpenOrders() {
   for(int i=OrdersTotal()-1; i>=0; i--) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if(OrderMagicNumber()==magic)
            return true;
      }
   }
   return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void wasLastProfit() {
   int wasProfit = 0;
   datetime cTime = 0;
   double orderType=0;
   double vol =0;

//OrdersTotal() returnează numărul de comenzi deschise, dar voi căutați
//în istoric (MODE_HISTORY). Pentru istoric trebuie să folosiți OrdersHistoryTotal().

   for(int i=OrdersHistoryTotal()-1; i>=0; i--) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
         if(OrderMagicNumber()==magic) {
            if(OrderCloseTime()>cTime) {
               if(OrderProfit()>0) {
                  wasProfit = 1;
               } else {
                  wasProfit=-1;
                  orderType = OrderType();
                  vol = OrderLots();
               }
               cTime=OrderCloseTime();
            }
         }
      }
   }
   if(wasProfit==1) {
      MathSrand(TimeCurrent());
      if(MathRand()%2==0) {
         OrderSend(Symbol(), OP_BUY, volume, Ask, 0, Ask-x*Point,Ask+x*Point, "", magic);
      } else {
         OrderSend(Symbol(), OP_SELL, volume, Bid, 0,Bid+x*Point,Bid-x*Point, "", magic);
      }
   } else if(wasProfit==-1) {
      if(orderType==OP_SELL) {
         OrderSend(Symbol(), OP_BUY, 2*vol, Ask, 0,Ask-x*Point,Ask+x*Point, "", magic);
      } else {
         OrderSend(Symbol(), OP_SELL, 2*vol, Bid, 0,Bid+x*Point,Bid-x*Point, "", magic);
      }
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit() {
   if(!areOpenOrders()) {
      MathSrand(TimeCurrent());
      if(MathRand()%2==0) {
         OrderSend(Symbol(), OP_BUY, volume, Ask, 0,Ask-x*Point,Ask+x*Point, "", magic);
      } else {
         OrderSend(Symbol(), OP_SELL, volume, Bid, 0,Bid+x*Point,Bid-x*Point, "", magic);
      }
   }

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick() {
   if(areOpenOrders())
      return;

   wasLastProfit();
}
//+------------------------------------------------------------------+
