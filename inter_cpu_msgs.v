

`define CPU_R_VOID 8'h00

`define CPU_R_RESET   8'hce

`define CPU_R_START   8'hb9
`define CPU_R_END     8'hed

`define CPU_R_FORK_THRD 8'hff
`define CPU_R_FORK_DONE 8'hfd
`define CPU_R_STOP_THRD 8'h5f
`define CPU_R_STOP_DONE 8'h5d



`define THREAD_CMD_NULL  0
`define THREAD_CMD_RUN   1
`define THREAD_CMD_STOP  2
`define THREAD_CMD_READY_TO_FORK 3
