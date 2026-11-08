//+------------------------------------------------------------------+
//|                                                   sanfamPipe.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+


#include <Files\FilePipe.mqh>
#include <JAson.mqh>


class ClientPipe
{
   CFilePipe I2APipe;
   
   bool isReady;
   

public:
  ClientPipe()
  {
  // isReady = false;
  }
  bool Connect()
  { 
      I2APipe.Close();
      
    //  PRINT_IF(": Opening pipe...");
      int pipeHandle = I2APipe.Open("\\\\.\\pipe\\I2A", FILE_READ | FILE_WRITE | FILE_BIN);
     // PRINT_IF(pipeHandle);
      if(pipeHandle != INVALID_HANDLE)
      {
            //isReady = true;
   //         PRINT_IF(" Pipe opened.");
            return true;
      }
      else
      {
  //       PRINT_IF("Indicator: Failed to open pipe!");
         return false;
      }
    
  }
  
  void Disconnect()
  {
   //   if(isReady)
      {
         I2APipe.Close();
  //       PRINT_IF("Indicator: Pipe closed.");
      }
  }
  
  
  bool SendJson(CJAVal & jData)
  {
      return SendStr( jData.Serialize() );
  }
  
  bool SendStr(string text)
  {
      if(!Connect())
      {
         return false;
      }

      uchar buffer[];
      StringToCharArray(text + "\n", buffer, 0, WHOLE_ARRAY, CP_UTF8);

      if(I2APipe.WriteArray(buffer, 0, ArraySize(buffer)) <= 0)
      {
     //    PRINT_IF("Indicator: Failed to send message to pipe");
         return false;
      }
      return true;
  }
};