
`include "sizes.v"


module CommandWordParse (
	command_word,
	regNumS1,
	regNumS0,
	regNumD,
	regNumCnd,
	isRegS1Ptr,
	isRegS0Ptr,
	isRegDPtr,
	isRegCondPtr,
	regS1Flags,
	regS0Flags,
	regDFlags,
	regCondFlags,
	isCond,
	isCondTrue,
	cmd_code
	);
	
	
  input wire [31:0] command_word;

  output wire [`CMD_BITS_PER_REG0:0] regNumS1;
  assign regNumS1 = command_word[2:0];

  output wire isRegS1Ptr;
  assign isRegS1Ptr = command_word[3];
  
  output wire [`CMD_BITS_PER_REG0:0] regNumS0;
  assign regNumS0 = command_word[6:4];

  output wire isRegS0Ptr;
  assign isRegS0Ptr = command_word[7];
  
  output wire [`CMD_BITS_PER_REG0:0] regNumD;
  assign regNumD = command_word[10:8];

  output wire isRegDPtr;
  assign isRegDPtr = command_word[11];
  
  output wire [`CMD_BITS_PER_REG0:0] regNumCnd;
  assign regNumCnd = command_word[14:12];
  
  output wire isRegCondPtr;
  assign isRegCondPtr = command_word[15];
  
  
  output wire [1:0] regS1Flags;
  assign regS1Flags = command_word[17:16];
  
  output wire [1:0] regS0Flags;
  assign regS0Flags = command_word[19:18];
  
  output wire [1:0] regDFlags;
  assign regDFlags = command_word[21:20];
  
  output wire [1:0] regCondFlags;
  assign regCondFlags = command_word[23:22];
  
  // a place for new flags
  // ...
  
  output wire isCond;
  assign isCond = command_word[24];
  
  output wire isCondTrue;
  assign isCondTrue = command_word[25];
  
  
  output wire [`CMD_BITS_PER_CMD_CODE0:0] cmd_code = command_word[31:28];
    
endmodule
