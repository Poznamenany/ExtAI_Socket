unit ExtAINetworkTypes;
interface
uses
  ExtAISharedNetworkTypes;


// Here are all private network types of the ExtAI
const

  //Size of chunks that a file is sent in (must be smaller than MAX_PACKET_SIZE)
  ExtAI_MSG_MAX_CUMULATIVE_PACKET_SIZE = ExtAI_MSG_MAX_SIZE - 255;
  ExtAI_MSG_MAX_NET_PING_CNT = 20;
  ExtAI_MSG_MAX_TICK_PING_CNT = 20;
  ExtAI_MSG_TIME_INTERVAL_NET_PING = 1000;
  ExtAI_MSG_TIME_INTERVAL_TICK_PING = 500;
implementation

end.

