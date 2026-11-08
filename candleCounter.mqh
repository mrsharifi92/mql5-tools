class CandleCounter
{
private:
   string           m_symbol;
   ENUM_TIMEFRAMES  m_tf;
   datetime         m_startBar;   // زمان کندلِ لحظه‌ی شروع
   int              m_target;
   bool             m_active;

public:
   CandleCounter() : m_active(false), m_target(0), m_startBar(0), m_symbol(""), m_tf(PERIOD_CURRENT) {}

   // شروع شمارش از همین الان
   void Start(int candles, string symbol = NULL, ENUM_TIMEFRAMES tf = PERIOD_CURRENT)
   {
      m_symbol   = (symbol == NULL || symbol == "") ? _Symbol : symbol;
      m_tf       = tf;
      m_target   = candles;
      m_startBar = iTime(m_symbol, m_tf, 0);
      m_active   = (candles > 0 && m_startBar > 0);
   }

   void Stop() { m_active = false; }
   bool IsActive() { return m_active; }

   // تعداد کندل‌های بسته‌شده از زمان شروع
   int Elapsed()
   {
      if(!m_active) return 0;
      int shift = iBarShift(m_symbol, m_tf, m_startBar, true);
      return (shift < 0) ? 0 : shift;
   }

   // در OnTick صدا بزن؛ وقتی تعداد کندل رسید true می‌دهد (یک بار)
   bool IsReached()
   {
      if(!m_active) return false;
      if(Elapsed() >= m_target)
      {
         m_active = false;   // فقط یک بار true
         return true;
      }
      return false;
   }
};
