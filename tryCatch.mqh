//+------------------------------------------------------------------+
//|                                                     tryCatch.mqh |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| کلاس مدیریت خطا مانند try-catch                                   |
//+------------------------------------------------------------------+
class TryCatch
{
private:
   int               m_lastError;
   string            m_errorMessage;
   bool              m_hasError;
   
public:
   TryCatch()
   {
      Reset();
   }
   
   void Reset()
   {
      m_lastError = 0;
      m_errorMessage = "";
      m_hasError = false;
   }
   
   bool Try()
   {
      Reset();
      ResetLastError();
      return true;
   }
   
   void Catch(int &errorCode, string &errorMessage)
   {
      m_lastError = GetLastError();
      m_hasError = (m_lastError != 0);
      
      if(m_hasError)
      {
         errorCode = m_lastError;
         errorMessage = GetErrorDescription(m_lastError);
      }
      else
      {
         errorCode = 0;
         errorMessage = "";
      }
   }
   
   bool HasError()
   {
      return m_hasError;
   }
   
   string GetErrorDescription(int errorCode)
   {
      switch(errorCode)
      {
         case 0:           return "No error";
         case 4001:        return "Internal error";
         case 4003:        return "Invalid parameter";
         case 4004:        return "Not enough memory";
         case 5001:        return "Database handle invalid";
         case 5002:        return "Database prepare error";
         case 5003:        return "Database execute error";
         case 5004:        return "Database open error";
         case 5005:        return "Database read error";
         default:          return "Unknown error " + IntegerToString(errorCode);
      }
   }
};
