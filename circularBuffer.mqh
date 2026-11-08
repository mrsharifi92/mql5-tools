//+------------------------------------------------------------------+
//|                                     GenericCircularBuffer.mqh    |
//+------------------------------------------------------------------+
#ifndef __GENERIC_CIRCULAR_BUFFER_MQH__
#define __GENERIC_CIRCULAR_BUFFER_MQH__

template <typename T>
class CircularBuffer
  {
private:
   T      m_data[];      // Dynamic array of Type T
   int    m_capacity;
   int    m_head;        // Index of oldest
   int    m_tail;        // Index of next free
   int    m_count;       // Current items
   int    m_dropped;     // Count of dropped items

public:
   CircularBuffer() : m_capacity(0), m_head(0), m_tail(0), m_count(0), m_dropped(0) {}

   // Initialize buffer with specific size
   bool Init(const int capacity)
     {
      if(capacity <= 0) return false;
      m_capacity = capacity;
      ArrayResize(m_data, m_capacity);
      Clear();
      return true;
     }

   void Clear()
     {
      m_head    = 0;
      m_tail    = 0;
      m_count   = 0;
      m_dropped = 0;
     }

   // Add item - Generic type T
   bool Push(const T &value)
     {
      if(m_capacity <= 0) return false;

      if(m_count == m_capacity)
        {
         m_head = (m_head + 1) % m_capacity; // Overwrite: slide head
         m_count--;
         m_dropped++;
        }

      m_data[m_tail] = value;
      m_tail = (m_tail + 1) % m_capacity;
      m_count++;
      return true;
     }

   // Retrieve item
   bool Pop(T &value)
     {
      if(m_count <= 0) return false;
      value = m_data[m_head];
      m_head = (m_head + 1) % m_capacity;
      m_count--;
      return true;
     }

   // Check buffer status
   int  Size()     const { return m_count; }
   int  Capacity() const { return m_capacity; }
   int  Dropped()  const { return m_dropped; }
   void ResetDropped()   { m_dropped = 0; }
  };

#endif
