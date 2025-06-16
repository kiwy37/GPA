//+------------------------------------------------------------------+
//|                                                 PendingOrder.mq4 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

extern int MagicNumber = 1234;
extern double MinVol = 0.01;
extern int n = 5;  //number of buy limits
extern int x = 20; //distance between levels
extern int y = 10; //take profit and stop loss distance
extern double z = 0.5; //max profit or loss for stop/delete

int OnInit()
{      
   RefreshRates();
   
   for (int i = 1; i <= n; i++)
   {
      double buyStopPrice = Ask + i * x * Point;
      double buyLimitPrice = Ask - i * x * Point;

      // Buy Stop - above the current price
      OrderSend(Symbol(), OP_BUYSTOP, MinVol, buyStopPrice, 0,
                buyStopPrice - y * Point, buyStopPrice + y * Point,
                "Plantator BuyStop", MagicNumber, 0);

      // Buy Limit - below the curent price
      OrderSend(Symbol(), OP_BUYLIMIT, MinVol, buyLimitPrice, 3,
                buyLimitPrice - y * Point, buyLimitPrice + y * Point,
                "Plantator BuyLimit", MagicNumber, 0);
   }
   return(INIT_SUCCEEDED);
}

void OnTick()
{
   double totalProfit = 0.0;

   //profit of all orders with our magic number
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if (OrderMagicNumber() == MagicNumber)
         {
            if (OrderType() == OP_BUY || OrderType() == OP_SELL)
               totalProfit += OrderProfit();
         }
      }
   }
   
   //if total profit or loss exceeds z we remove everything
   if (totalProfit >= z || totalProfit <= -z)
   {
      Alert("Threshold exceeded: ", totalProfit, " -> Destroying grid");

      // Close open BUY/SELL orders
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         {
            if (OrderMagicNumber() == MagicNumber)
            {
               int type = OrderType();
                 if (type == OP_BUY)
                 {
                     if (!OrderClose(OrderTicket(), OrderLots(), Bid, 0))
                         Alert("Failed to close BUY ", OrderTicket(), " error: ", GetLastError());
                 }
                 else if (type == OP_SELL)
                 {
                     if (!OrderClose(OrderTicket(), OrderLots(), Ask, 0))
                         Alert("Failed to close SELL ", OrderTicket(), " error: ", GetLastError());
                 }
            }
         }
      }//end for
      
      //Delete pending orders
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         {
            if (OrderMagicNumber() == MagicNumber)
            {
               if (!OrderDelete(OrderTicket()))
                  Alert("Failed to delete order ", OrderTicket(), " Error: ", GetLastError());
            }
         }
      }//end for
   }//end if
}

void OnDeinit(const int reason)
{

}
