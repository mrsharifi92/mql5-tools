//+------------------------------------------------------------------+
//| ChartShot.mqh                                                 |
//+------------------------------------------------------------------+
#define OPENTRADEIMAGE "Open"
#define CLOSETRADEIMAGE "Close"
#define  ScreenShotFolder "Screenshots\\Auto"
class CChartShot
{
private:
   int    m_width;
   int    m_height;
   string m_subfolder;    // relative to MQL5\Files
   int    m_wait_ms;
   int    m_max_wait_ms;

   string m_last_full_path;
   string m_last_rel_path;
   int    m_last_error;

private:
   string FilesRoot()
   {
      return TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL5\\Files\\";
   }

   // Create folder tree inside MQL5\Files (relative path)
   // Accepts: "Screenshots\\Auto" or "Screenshots/Auto"
   bool EnsureFolderTree(string relative_folder)
   {
      m_last_error = 0;

      if(relative_folder == "" || relative_folder == "\\" || relative_folder == "/")
         return true;

      string path = relative_folder;
      StringReplace(path, "/", "\\");

      // trim leading/trailing slashes
      while(StringLen(path) > 0 && StringGetCharacter(path, 0) == '\\')
         path = StringSubstr(path, 1);
      while(StringLen(path) > 0 && StringGetCharacter(path, StringLen(path)-1) == '\\')
         path = StringSubstr(path, 0, StringLen(path)-1);

      if(path == "")
         return true;

      string parts[];
      int n = StringSplit(path, '\\', parts);
      if(n <= 0) return true;

      string accum = "";
      for(int i=0; i<n; i++)
      {
         if(parts[i] == "") continue;
         accum = (accum == "" ? parts[i] : accum + "\\" + parts[i]);

         ResetLastError();
         bool ok = FolderCreate(accum);

         if(!ok)
         {
            int err = GetLastError();

            // اگر پوشه از قبل وجود داشته باشد، این را خطای مرگبار نگیریم.
            // (کد خطا ممکن است بین بیلدها فرق کند؛ پس از FileIsExist هم کمک می‌گیریم)
            if(FileIsExist(accum)) // اگر موجود است، اوکی
               continue;

            // بعضی وقت‌ها مسیر پوشه را FileIsExist تشخیص نمی‌دهد؛ پس یک تست جایگزین:
            // تلاش برای ساخت یک فایل موقت داخل آن پوشه (اختیاری/سنگین) نمی‌کنیم.
            m_last_error = err;
            return false;
         }
      }
      return true;
   }

   long FindOpenChart(string symbol, ENUM_TIMEFRAMES tf)
   {
      long id = ChartFirst();
      while(id != -1)
      {
         if(ChartSymbol(id) == symbol && (ENUM_TIMEFRAMES)ChartPeriod(id) == tf)
            return id;
         id = ChartNext(id);
      }
      return -1;
   }

   bool WaitChartReady(long chart_id)
   {
      if(chart_id <= 0) return false;

      string sym = ChartSymbol(chart_id);
      ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)ChartPeriod(chart_id);

      int waited = 0;
      while(waited <= m_max_wait_ms)
      {
         // شرط آماده بودن: حداقل 1 کندل در history
         if(Bars(sym, tf) > 0)
         {
            ChartRedraw(chart_id);
            return true;
         }
         Sleep(m_wait_ms);
         waited += m_wait_ms;
      }
      return false;
   }

   string MakeFileName(string symbol, ENUM_TIMEFRAMES tf,string which,ulong id)
   {
      string tf_name = EnumToString(tf);
      StringReplace(tf_name, "PERIOD_", "");

      string t = TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES|TIME_SECONDS);
      StringReplace(t, ".", "-");
      StringReplace(t, ":", "-");
      StringReplace(t, " ", "_");
      
      string idName = IntegerToString(id);

      return   symbol + "_" + tf_name + "_" + idName + "_" + t + "_" + which +  ".png";
   }
   
   string MakeFolderName(string symbol,datetime openDate)
   {
      string date_str = TimeToString(openDate, TIME_DATE);
      StringReplace(date_str, ".", "");
      return  symbol + "\\" + date_str;
   }

public:
   CChartShot(int width=1280,
                 int height=720,
                 string subfolder="Screenshots",
                 int wait_step_ms=200,
                 int max_wait_ms=5000)
   {
      m_width       = width;
      m_height      = height;
      m_subfolder   = subfolder;
      m_wait_ms     = wait_step_ms;
      m_max_wait_ms = max_wait_ms;

      m_last_full_path = "";
      m_last_rel_path  = "";
      m_last_error     = 0;
   }

   void   SetSize(int width, int height) { m_width=width; m_height=height; }
   void   SetFolder(string subfolder)    { m_subfolder=subfolder; }

   string LastFullPath() const           { return m_last_full_path; }
   string LastRelativePath() const       { return m_last_rel_path; }
   int    LastError() const              { return m_last_error; }

   // Main API:
   // - only open charts
   // - auto folder create
   // - auto filename
   // - waits until chart has bars
   // - returns full path
   bool CaptureOpenOnly(string symbol,ENUM_TIMEFRAMES tf,ulong id,string whichImage,string &full_path_out)
   {
      m_last_error     = 0;
      m_last_full_path = "";
      m_last_rel_path  = "";
      full_path_out    = "";

      long chart_id = FindOpenChart(symbol, tf);
      if(chart_id == -1)
      {
         m_last_error = 4106; // ERR_CHART_NOT_FOUND (برای گزارش)
         return false;
      }

      if(!WaitChartReady(chart_id))
      {
         m_last_error = 4066; // ERR_HISTORY_WILL_UPDATED (برای گزارش)
         return false;
      }

      string rel = MakeFileName(symbol,tf, whichImage,id);
      string subFolder = MakeFolderName(symbol,TimeCurrent());
      rel = subFolder + "\\" + rel;
      if(!EnsureFolderTree(subFolder))
         return false;

      ResetLastError();
      bool ok = ChartScreenShot(chart_id, rel, m_width, m_height, ALIGN_RIGHT);
      if(!ok)
      {
         m_last_error = GetLastError();
         return false;
      }

      string full = FilesRoot() + "\\"+ rel;
      StringReplace(full, "\\\\", "\\");

      m_last_rel_path  = rel;
      m_last_full_path = full;
      full_path_out    = full;
      return true;
   }
};


bool              SaveScreenShot(ENUM_TIMEFRAMES timeframe,ulong magicNumber,string whichImage,string & fullAddress)
     {
      fullAddress = "";
      CChartShot shot(1600, 900, ScreenShotFolder);
      if(shot.CaptureOpenOnly(_Symbol, timeframe,magicNumber,whichImage,fullAddress))
         return true;
      else
        {
         Print("Failed. err=", shot.LastError());
         return false;
        }
     }