
`define  CPU_MASK      32'h7fffffff
`define  CPU_ACTIVE    32'h80000000
`define  CPU_NONACTIVE 32'h00000000


`define ADDR_NONE  2'b00
`define ADDR_EQ    2'b11    
`define ADDR_LT    2'b01
`define ADDR_GT    2'b10



`define SIZE_REG_OP 3

`define REG_OP_NULL        0 //3'b000
`define REG_OP_PREEXECUTE  1 //3'b001
`define REG_OP_READ        2 //3'b010
`define REG_OP_READ_P      3 //3'b011
`define REG_OP_WRITE       4 //3'b100
`define REG_OP_WRITE_PREP  5 //3'b101
`define REG_OP_WRITE_P     6 //3'b110
`define REG_OP_CATCH_DATA  7 //3'b111
