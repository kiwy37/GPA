//+------------------------------------------------------------------+
//|                                                       Ajutor.mq4 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input int MagicNumber = 12345; // Unique identifier for EA orders

datetime lastBarTime = 0;
bool isNewBar() {
   datetime currentBarTime = Time[0];
   if (currentBarTime != lastBarTime) {
      lastBarTime = currentBarTime;
      return true;
   }
   return false;
}

// Check if there's any open order
bool isOrderOpen() {
   for(int i = 0; i < OrdersTotal(); i++) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
            return true; // Found open order for this symbol and magic number
         }
      }
   }
   return false; // No orders found
}

// Close all buy orders with the specified magic number
void closeAllBuy() {
   for(int i = OrdersTotal() - 1; i >= 0; i--) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if(OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
            bool closed = OrderClose(OrderTicket(), OrderLots(), Bid, 0);
            if(!closed) {
               Print("Eroare la închiderea BUY ", OrderTicket(), ": ", GetLastError());
            } else {
               Print("BUY închis: ", OrderTicket());
            }
         }
      }
   }
}

// Close all sell orders with the specified magic number
void closeAllSell() {
   for(int i = OrdersTotal() - 1; i >= 0; i--) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if(OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
            bool closed = OrderClose(OrderTicket(), OrderLots(), Ask, 0);
            if(!closed) {
               Print("Eroare la închiderea SELL ", OrderTicket(), ": ", GetLastError());
            } else {
               Print("SELL închis: ", OrderTicket());
            }
         }
      }
   }
}

// Close all orders with the specified magic number
void CloseAllOrders() {
   for (int i = OrdersTotal() - 1; i >= 0; i--) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
            if (OrderType() == OP_BUY)
               OrderClose(OrderTicket(), OrderLots(), Bid, 0, 0);
            else if (OrderType() == OP_SELL)
               OrderClose(OrderTicket(), OrderLots(), Ask, 0, 0);
         }
      }
   }
}

// Check for consecutive closing prices going up
bool isConsecutiveCloseUp(int n) {
   if(n < 2) return false; // Need at least 2 bars

   for(int i = 1; i < n; i++) {
      if(Close[i] <= Close[i + 1]) {
         return false; // If a bar doesn't close higher, return false
      }
   }

   return true; // All closes are increasing
}

// Get open profit for current symbol and magic number
double getOpenProfitForSymbol() {
   double totalProfit = 0;

   for(int i = 0; i < OrdersTotal(); i++) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
            totalProfit += OrderProfit() + OrderSwap() + OrderCommission();
         }
      }
   }

   return totalProfit;
}

// Check if last closed order was profitable (with magic number check)
bool wasLastClosedOrderProfitable() {
   int total = OrdersHistoryTotal();
   if(total == 0) return false; // No closed orders

   datetime lastCloseTime = 0;
   int lastIndex = -1;

   // Find the most recently closed order with our magic number
   for(int i = 0; i < total; i++) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
            if(OrderCloseTime() > lastCloseTime) {
               lastCloseTime = OrderCloseTime();
               lastIndex = i;
            }
         }
      }
   }

   if(lastIndex == -1) return false; // No valid order found

   if(OrderSelect(lastIndex, SELECT_BY_POS, MODE_HISTORY)) {
      double profitNet = OrderProfit() + OrderSwap() + OrderCommission();
      return profitNet > 0;
   }

   return false;
}

bool testForSell()
{
   for (int i = 1; i <= n; i++)
   {
      if (Close[i] <= iMA(NULL, 0, n, 0, MODE_SMA, PRICE_CLOSE, i))
         return false;
   }
   
   return true;
}

int OnInit() {
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
}

void OnTick() {
}