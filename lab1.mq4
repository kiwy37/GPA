//+------------------------------------------------------------------+
//|                                                         lab1.mq4 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

int order = -1;   // ca sa evit eroarea la inchidere

int OnInit()
  {
    for(int i=1; i<=10; i++)
      {
        Alert(Open[i], High[i], Low[i], Close[i]);
      }

    // int order = OrderSend(Symbol(), OP_BUY, 0.01, Ask, 0, 0, 0);
    order = OrderSend(Symbol(), OP_SELL, 0.01, Bid, 0, 0, 0);
    
    if(order < 0 )
    {
      Alert("Order not sent");
    }
    else{
      Alert("Order number: ", order); 
    }

   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
     // OrderClose(order,0.01,Bid, 0); 
     OrderClose(order, 0.01, Ask, 0);
  }

void OnTick()
  {
   Alert("Ask"+Ask+" Bid:"+Bid);
  }
