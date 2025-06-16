//+------------------------------------------------------------------+
//|                 Moving Average Expert Advisor                    |
//+------------------------------------------------------------------+

extern int N = 5;               // Number of bars to check
extern int M = 3;               // Max open orders allowed
extern double X = 50;           // TP/SL distance in points
extern int MagicNumber = 1234;  // Magic number for EA orders

int lastBarTime = 0;

void OnTick()
{
    // Run only when a new bar appears
    if (Time[0] == lastBarTime)
        return;
    lastBarTime = Time[0];

    // Count open orders from this EA
    int count = 0;
    for (int j = 0; j < OrdersTotal(); j++)  // renamed loop variable to 'j'
    {
        if (OrderSelect(j, SELECT_BY_POS, MODE_TRADES))
            if (OrderMagicNumber() == MagicNumber)
                count++;
    }

    if (count >= M)
        return; // Too many orders

    // Check last N bars against MA
    bool buy = true;
    bool sell = true;

    for (int k = 1; k <= N; k++)  // renamed loop variable to 'k'
    {
        double ma = iMA(NULL, 0, N, 0, MODE_SMA, PRICE_CLOSE, k);
        if (Close[k] <= ma) buy = false;
        if (Close[k] >= ma) sell = false;
    }

    double lot = 0.1;
    double slippage = 3;
    double ask = Ask;
    double bid = Bid;

    // Place Buy Order
    if (buy)
    {
        int buyTicket = OrderSend(Symbol(), OP_BUY, lot, ask, slippage, ask - X * Point, ask + X * Point, "", MagicNumber, 0, clrGreen);
        if (buyTicket < 0)
            Print("Buy order failed. Error: ", GetLastError());
    }

    // Place Sell Order
    if (sell)
    {
        int sellTicket = OrderSend(Symbol(), OP_SELL, lot, bid, slippage, bid + X * Point, bid - X * Point, "", MagicNumber, 0, clrRed);
        if (sellTicket < 0)
            Print("Sell order failed. Error: ", GetLastError());
    }
}