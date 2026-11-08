// DynArray.mqh
#ifndef DYN_ARRAY_MQH
#define DYN_ARRAY_MQH

template<typename T>
class DynamicArray
{
private:
   T   m_data[];
   int m_size;

public:
   DynamicArray() : m_size(0) {}

   int  Size()  const { return m_size; }
   bool Empty() const { return m_size == 0; }

   void Clear()
   {
      m_size = 0;
      ArrayResize(m_data, 0);
   }

   bool Add(const T &item)
   {
      // reserve=16 باعث می‌شود resize های پشت‌سرهم هر بار realloc نکنند
      if(ArrayResize(m_data, m_size + 1, 16) < 0)
         return false;
      m_data[m_size++] = item;
      return true;
   }

   bool Insert(int index, const T &item)
   {
      if(index < 0 || index > m_size) return false;
      if(ArrayResize(m_data, m_size + 1, 16) < 0) return false;
      for(int i = m_size; i > index; i--)
         m_data[i] = m_data[i - 1];
      m_data[index] = item;
      m_size++;
      return true;
   }

   bool RemoveAt(int index)
   {
      if(index < 0 || index >= m_size) return false;
      for(int i = index; i < m_size - 1; i++)
         m_data[i] = m_data[i + 1];
      m_size--;
      ArrayResize(m_data, m_size, 16);
      return true;
   }

   bool Get(int index, T &out) const
   {
      if(index < 0 || index >= m_size) return false;
      out = m_data[index];
      return true;
   }

   bool Set(int index, const T &item)
   {
      if(index < 0 || index >= m_size) return false;
      m_data[index] = item;
      return true;
   }

   T operator[](int index) const { return m_data[index]; }

  
};
#endif
