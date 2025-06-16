extern int magicNumber = 1234;
extern int x = 10; //distance between stop loss and take profit
extern int n = 10; //the last numbber of bars to check 
extern int m = 5; //open orders 

int OnInit()
{
return(INIT_SUCCEEDED);
}



int openOrdersNumber()
{
   int openOrders = 0;
   for (int i = OrdersTotal() - 1; i >= 0; i--) {
     if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderMagicNumber() == magicNumber)
             openOrders++;
      }
   }
   return openOrders;
}


void OnTick()
{
    printf("Enter on tick");
    static datetime lastBarTime = 0;
    if (Time[0] == lastBarTime)
        return;
        
    lastBarTime = Time[0];

    //open orders
    int openOrders = openOrdersNumber();
    
    printf("open orders");
    if (openOrders >= m) return;

    bool greaterThaniMA = true;
    bool belowThaniMA = true;

    for (int i = 1; i <= n; i++) {     
        double ma = iMA(NULL, 0, 5, 0, MODE_SMA, PRICE_CLOSE, i);
        if (Close[i] >= ma)
            belowThaniMA = false;
        if (Close[i] <= ma)
            greaterThaniMA = false;
    }
    if (greaterThaniMA)     
         OrderSend(Symbol(), OP_BUY, 0.01, Ask, 0,  Bid - x * Point,  Bid + x * Point,"Buy Order", magicNumber, 0);      
    else if (belowThaniMA) 
         OrderSend(Symbol(), OP_SELL, 0.01, Bid, 0, Ask + x * Point, Ask - x * Point,"Sell Order", magicNumber, 0);         
}