//+------------------------------------------------------------------+
//|                                                         lab3.mq4 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

int barNumber = 10;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int trend(int n) {
   bool cresc = true;
   bool descresc = true;
   for(int i=1; i < n; i++) {
      if(Close[i] < Close[i+1]) {
         cresc = false;
      }
      if(Close[i] > Close[i+1]) {
         descresc = false;
      }
   }
   if(cresc==true)
      return(1);
   if(descresc==true)
      return(-1);
   return(0);
}

// MODE_TRADES – selectează ordinele deschise activ (open trades), adică cele care sunt în desfășurare pe piață.

// MODE_HISTORY – selectează ordinele închise sau finalizate (din istoric), utile pentru analiză, backtest etc.

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAllSells() {
   for(int i = OrdersTotal() - 1; i >= 0; i--) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if(OrderType() == OP_SELL && OrderSymbol() == Symbol()) {
            bool result = OrderClose(OrderTicket(), OrderLots(), Ask, 3);
            if(!result) {
               Alert("Failed to close SELL order.");
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAllBuys() {
   for(int i = OrdersTotal() - 1; i >= 0; i--) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if(OrderType() == OP_BUY && OrderSymbol() == Symbol()) {
            bool result = OrderClose(OrderTicket(), OrderLots(), Bid, 3);
            if(!result) {
               Alert("Failed to close BUY order.");
            }
         }
      }
   }
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
   int t = trend(barNumber);
   int o =-1;
   if(t==1) {
      CloseAllBuys();
      o = OrderSend(Symbol(), OP_SELL, 0.01, Bid, 0,0,0);
   } else if(t==-1) {
      CloseAllSells();
      o = OrderSend(Symbol(), OP_BUY, 0.01, Ask, 0,0,0);
   }

   if(o<0)
      Alert("Nu s-a plasat tranzactia.");
}

void OnTimer() {

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam) {

}
//+------------------------------------------------------------------+
