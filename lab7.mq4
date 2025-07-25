//+------------------------------------------------------------------+
//|                                                         lab7.mq4 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

double s = 5;

int OnInit() {

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool profit() {
   double profit = 0;
   for(int i=0; i<OrdersTotal(); i++) {
      if(OrderSelect(i,SELECT_BY_POS, MODE_TRADES)) {
         if(OrderSymbol()==Symbol()) {
            profit += OrderProfit();
         }
      }
   }
   if(profit>s||profit<-s)
      return true;
   else
      return false;
}

// Inchide toate ordinele
void closeAll() {
   for(int i=OrdersTotal()-1; i>=0; i--) {
      if(OrderSelect(i,SELECT_BY_POS, MODE_TRADES)) {
         if(OrderSymbol() == Symbol()) { 
            if(OrderType() == OP_BUY) {
               OrderClose(OrderTicket(), OrderLots(), Bid, 0);
            } else if(OrderType() == OP_SELL) {
               OrderClose(OrderTicket(), OrderLots(), Ask, 0);
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick() {
   if(profit())
      closeAll();
}
//+------------------------------------------------------------------+
