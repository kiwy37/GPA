//+------------------------------------------------------------------+
//|                                                         lab2.mq4 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link "https://www.mql5.com"
#property version "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int order = -1;
int transaction = OP_BUY;
double openPrice = 0;         //PRETRILE SUNT DOUBLE NU INT

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit() {
   MathSrand(TimeLocal());
   int random = MathRand() % 2;
   transaction = random ? OP_BUY : OP_SELL;

   if(transaction == OP_BUY) {
      order = OrderSend(Symbol(), transaction, 0.01, Ask, 0, 0, 0);
      openPrice = Ask;
   } else {
      order = OrderSend(Symbol(), transaction, 0.01, Bid, 0, 0, 0);
      openPrice = Bid;
   }

   if(order < 0) {
      Alert("Error opening order.");
      return (INIT_FAILED);
   }

   return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick() {
   if(transaction == OP_BUY) {
      if(MathAbs(openPrice - Bid) > 0.001) {
         OrderClose(order, 0.01, Bid, 0);
         transaction = OP_SELL;
         order = OrderSend(Symbol(), transaction, 0.01, Bid, 0, 0, 0);
         openPrice = Bid;  //NU UITA DE ASTA
      }
   } else {
      if(MathAbs(openPrice - Ask) > 0.001) {
         OrderClose(order, 0.01, Ask, 0);
         transaction = OP_BUY;
         order = OrderSend(Symbol(), transaction, 0.01, Ask, 0, 0, 0);
         openPrice = Ask;  //NU UITA DE ASTA
      }
   }
}
//+------------------------------------------------------------------+
