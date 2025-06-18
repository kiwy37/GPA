//+------------------------------------------------------------------+
//|                                                        lab10.mq4 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

extern int n=5;
extern double volume = 0.01;
extern double x = 5;
extern double y = 5;
extern int magic = 123;
extern double z=10;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit() {
   for(int i=1; i<=n; i++) {
      double below = Ask - i*x*Point;
      double above = Ask +i*x*Point;

      if(!OrderSend(Symbol(), OP_BUYLIMIT, volume, below, 0,below-y*Point, below+y*Point, "comment", magic)) {
         Alert("Couldn't send order");
      }

      if(!OrderSend(Symbol(), OP_BUYSTOP, volume, above, 0,above-y*Point, above+y*Point, "comment", magic) ) {
         Alert("Couldn't send order");
      }
   }
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void closeAll() {
   Alert("Close");
   for(int i=OrdersTotal()-1; i>=0; i--) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if(OrderSymbol()== Symbol()&&OrderMagicNumber()==magic) {
            if(OrderType()==OP_BUY) {
               if(!OrderClose(OrderTicket(),OrderLots(),Bid, 0))
                  Alert("Couldn't close order");
            }
            if(OrderType()==OP_SELL) {
               if(!OrderClose(OrderTicket(),OrderLots(),Ask, 0))
                  Alert("Couldn't close order");
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deleteAllPending() {
   for(int i=OrdersTotal()-1; i>=0; i--) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if(OrderSymbol()== Symbol()&&OrderMagicNumber()==magic) {
            if(OrderType() > OP_SELL) {  // Pending orders have type > 1
               if(!OrderDelete(OrderTicket())) {
                  Alert("Couldn't delete pending order");
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick() {
   Print("message");
   double totalProfit=0;
   for(int i=OrdersTotal()-1; i>=0; i--) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if(OrderSymbol()== Symbol()&&OrderMagicNumber()==magic) {
            if(OrderType() == OP_BUY || OrderType() == OP_SELL)
               totalProfit+=OrderProfit();
         }
      }
   }

   if(totalProfit>=z||totalProfit<=-z) {
      closeAll();
      deleteAllPending();
   }

}
//+------------------------------------------------------------------+
