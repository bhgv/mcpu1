

`define CPU_R_VOID 8'h00

`define CPU_R_RESET   8'hce

`define CPU_R_START   8'hb9
`define CPU_R_END     8'hed

`define CPU_R_FORK_THRD 8'hff
`define CPU_R_FORK_DONE 8'hfd
`define CPU_R_STOP_THRD 8'h5f
`define CPU_R_STOP_DONE 8'h5d


`define CPU_R_CHAN_GET  8'hc9
`define CPU_R_CHAN_SET  8'hc5

`define CPU_R_CHAN_CRT  8'hcc
`define CPU_R_CHAN_DEL  8'hcd

`define CPU_R_CHAN_TST  8'hc7

`define CPU_R_CHAN_DONE  8'hcf

`define CPU_R_BREAK_THREAD  8'hbf

`define CPU_R_THREAD_ADDRESS  8'hfa




`define THREAD_CMD_NULL  0
`define THREAD_CMD_RUN   1
`define THREAD_CMD_STOP  2
`define THREAD_CMD_GET_NEXT_STATE 3
`define THREAD_CMD_PAUSE 4
