//+------------------------------------------------------------------+
//|                                                         lab4.mq4 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

int barNumber=10;
datetime lastBarTime = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void closePrevBuys() {
   for(int i=OrdersTotal(); i>0; i--) {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {
         if(OrderType()==OP_BUY) {
            int o = OrderClose(OrderTicket(),OrderLots(),Ask,0);

            if(o<0)
               Alert("Operatia a esuat");
         }
      }
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void closePrevSels() {
   for(int i=OrdersTotal(); i>0; i--) {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {
         if(OrderType()==OP_SELL) {
            int o = OrderClose(OrderTicket(),OrderLots(),Bid,0);

            if(o<0) {
               Alert("Operatia a esuat");
            }
         }
      }
   }
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool decrease(int n) {
   for(int i=1; i<=n; i++)
      if(Close[i]>Open[i])
         return false;

   return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool increase(int n) {
   for(int i=1; i<=n; i++)
      if(Close[i]<Open[i])
         return false;

   return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isNewBar() {
   datetime currentTime = Time[0];
   if(currentTime!=lastBarTime) {
      lastBarTime=currentTime;
      return true;
   }
   return false;
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
   if(isNewBar()) {
      if(increase(barNumber)) {
         closePrevBuys();
         OrderSend(Symbol(),OP_SELL,0.01, Bid, 0,0,0);
      } else if(decrease(barNumber)) {
         closePrevSels();
         OrderSend(Symbol(),OP_BUY,0.01, Ask, 0,0,0);
      }
   }
}

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
