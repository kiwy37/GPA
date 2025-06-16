//+------------------------------------------------------------------+
//|                    Simple Moving Average EA                      |
//+------------------------------------------------------------------+
extern int N = 5;              // Number of bars to check
extern int M = 3;              // Max number of open orders
extern double X = 50;          // Take Profit and Stop Loss in points
extern int MagicNumber = 1234; // Unique ID for EA orders
extern int MA_Period = 14;     // Period for moving average

int lastBarTime = 0;

void OnTick()
{
    // Only run when a new bar appears
    if (Time[0] == lastBarTime)
        return;

    lastBarTime = Time[0];

    // Check how many orders we already have
    int openOrders = 0;
    for (int i = 0; i < OrdersTotal(); i++)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if (OrderMagicNumber() == MagicNumber)
                openOrders++;
        }
    }

    // Do not open more if we already have M orders
    if (openOrders >= M)
        return;

    // Check if all of the last N bars closed ABOVE the MA
    bool buySignal = true;
    bool sellSignal = true;

    for (int i = 1; i <= N; i++)
    {
        double closePrice = Close[i];
        double maValue = iMA(NULL, 0, MA_Period, 0, MODE_SMA, PRICE_CLOSE, i);

        if (closePrice <= maValue)
            buySignal = false;

        if (closePrice >= maValue)
            sellSignal = false;
    }

    double slippage = 3;
    double lotSize = 0.1;
    double ask = NormalizeDouble(Ask, Digits);
    double bid = NormalizeDouble(Bid, Digits);

    if (buySignal)
    {
        OrderSend(Symbol(), OP_BUY, lotSize, ask, slippage, ask - X * Point, ask + X * Point, "Buy Order", MagicNumber, 0, clrBlue);
    }

    if (sellSignal)
    {
        OrderSend(Symbol(), OP_SELL, lotSize, bid, slippage, bid + X * Point, bid - X * Point, "Sell Order", MagicNumber, 0, clrRed);
    }
}