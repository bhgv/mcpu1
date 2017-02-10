
// VVV -- dispatcherOfCpus states
`define CTL_RESET_BEGIN 0
`define CTL_RESET_WAIT  1
`define CTL_CPU_LOOP    2
`define CTL_CPU_EXT_BUS 16


`define CTL_CPU_GET_NEXT_FROM_LOOP_STORE_0	9
`define CTL_CPU_MAIN_THREAD_PROCESSOR_0	7

`define CTL_CPU_REMOVE_THREAD_ph1	5
`define CTL_CPU_REMOVE_THREAD_ph2	6

`define CTL_CPU_START_THREAD_ph01	10
`define CTL_CPU_START_THREAD_ph1		8

`define CTL_CPU_REMOVE_THREAD_ph10		11
`define CTL_CPU_MAIN_THREAD_PROCESSOR_FINALISER		14
`define CTL_CPU_REMOVE_THREAD_ph20		12
`define CTL_CPU_REMOVE_THREAD_ph12		13

`define CTL_CPU_CHAN_OP_ph0		15

/**
`define CTL_CPU_LOOP_ACTIVATE_PROC_SAVE_TO_APROC	5
`define CTL_CPU_LOOP_ACTIVATE_PROC_NEW_APROC_E		6
`define CTL_CPU_LOOP_GNP_IF_NEED_STOP					7
`define CTL_CPU_LOOP_GNP_NEED_STOP_CORR_I_FROM		8
`define CTL_CPU_LOOP_GNP_NEED_STOP_CORR_I_TO			9
`define CTL_CPU_LOOP_GNP_NO_NEED_STOP_CORR_I			10
/**/

`define CTL_CPU_CMD     3
`define CTL_MEM_WORK    4

`define CTL_CHAN_RESULT_LOOP    5
// AAA -- dispatcherOfCpus states



// VVV -- CPU module states
`define WAIT_FOR_START   0

`define START_BEGIN      1
`define START_READ_CMD   2
`define START_READ_CMD_P 3
`define PREEXECUTE       4
`define WRITE_REG_IP     5

`define READ_MEM_SIZE_1 28
`define READ_MEM_SIZE_2 29

`define AFTER_MEM_SIZE_READ 30


//`define BASE_ADDR_SET 3

`define FILL_COND    23
`define READ_COND    6
`define READ_COND_P  7
//`define READ_DATA  5

`define FILL_SRC1    21
`define READ_SRC1    8
`define READ_SRC1_P  9

`define FILL_SRC0    22
`define READ_SRC0    10
`define READ_SRC0_P  11

`define FILL_DST_P   25
`define READ_DST     26
`define READ_DST_P   27

`define ALU_BEGIN		12
`define ALU_RESULTS	20
`define ALU_CHAN_THREAD_ADDR_OUT	55

//`define CHAN_WR_END	28
//`define CHAN_RD		29

//`define WRITE_DATA 7
`define WRITE_PREP 13

`define WRITE_DST  14

`define WRITE_COND 15
`define WRITE_SRC1 16
`define WRITE_SRC0 17

`define WRITE_DST_P  24


`define AUX_PRE_FINISH_BEGIN 33

`define FINISH_BEGIN 18
`define FINISH_END   19

`define BREAK_THREAD_SAVE_IP_AND_WAIT	31
`define BREAK_THREAD_EXIT_AND_WAIT	32


`define CPU_STATE_FIRST_EMPTY 35
// AAA -- CPU module states



// VVV registers internal states
`define MEM_BEGIN 0

`define MEM_RD_SRC1_BEGIN 2
`define MEM_RD_SRC0_BEGIN 3

`define MEM_WAIT_FOR_READ_REGS 10

`define MEM_WR_DST 0
`define MEM_WR_DST_WAIT 1
`define MEM_WR_SRC_REGS 2
`define MEM_WR_SRC_REGS_WAIT 3
// AAA registers internal states


// VVV channels in-threadManager ops/states
`define CHN_OP_NULL 0
`define CHN_OP_SEND 1
`define CHN_OP_RECEIVE 2
`define CHN_OP_DATA_RECEIVED 8'hc1
`define CHN_OP_DATA_SENT 8'hc2

`define CHN_OP_SEND_FREEZED 5
`define CHN_OP_RECEIVE_FREEZED 6

`define CHN_OP_NO_RESULTS 8'hc0
// AAA channels in-threadManager ops/states
