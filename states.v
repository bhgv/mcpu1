

`define CTL_RESET_BEGIN 0
`define CTL_RESET_WAIT  1
`define CTL_CPU_LOOP    2
`define CTL_CPU_CMD     3
`define CTL_MEM_WORK    4



`define WAIT_FOR_START 0

`define START_BEGIN 1
`define START_READ_CMD 2
`define START_READ_CMD_P 3
`define PREEXECUTE   4
`define WRITE_REG_IP 5


//`define BASE_ADDR_SET 3

`define READ_COND    6
`define READ_COND_P  7
//`define READ_DATA  5
`define READ_SRC1    8
`define READ_SRC1_P  9
`define READ_SRC0    10
`define READ_SRC0_P  11

`define ALU_BEGIN  12

//`define WRITE_DATA 7
`define WRITE_PREP 13

`define WRITE_DST  14

`define WRITE_COND 15
`define WRITE_SRC1 16
`define WRITE_SRC0 17


`define FINISH_BEGIN 18
`define FINISH_END   19




`define MEM_BEGIN 0

`define MEM_RD_SRC1_BEGIN 2
`define MEM_RD_SRC0_BEGIN 3

`define MEM_WAIT_FOR_READ_REGS 10

`define MEM_WR_DST 0
`define MEM_WR_DST_WAIT 1
`define MEM_WR_SRC_REGS 2
`define MEM_WR_SRC_REGS_WAIT 3



