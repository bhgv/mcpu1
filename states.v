

`define CTL_RESET_BEGIN 0
`define CTL_RESET_WAIT  1
`define CTL_CPU_LOOP    2
`define CTL_CPU_CMD     3
`define CTL_MEM_WORK    4




`define START_BEGIN 1
`define START_READ_CMD 2
`define WRITE_REG_IP 3


//`define BASE_ADDR_SET 3

`define READ_COND  4
`define READ_DATA  5

`define ALU_BEGIN 6

`define WRITE_DATA 7


`define FINISH_BEGIN 8 
`define FINISH_END   9 




`define MEM_BEGIN 0

`define MEM_RD_SRC1_BEGIN 2
`define MEM_RD_SRC0_BEGIN 3

`define MEM_WAIT_FOR_READ_REGS 10

`define MEM_WR_DST 0
`define MEM_WR_DST_WAIT 1
`define MEM_WR_SRC_REGS 2
`define MEM_WR_SRC_REGS_WAIT 3



