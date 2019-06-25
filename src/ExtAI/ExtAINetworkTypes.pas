unit ExtAINetworkTypes;
interface
uses
  ExtAISharedNetworkTypes;


// Here are all private network types of the ExtAI
const

  //Size of chunks that a file is sent in (must be smaller than MAX_PACKET_SIZE)
  ExtAI_MSG_MAX_CUMULATIVE_PACKET_SIZE = ExtAI_MSG_MAX_SIZE - 255;
implementation

end.

