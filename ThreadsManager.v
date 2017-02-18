



`include "sizes.v"
`include "states.v"
`include "inter_cpu_msgs.v"
`include "misc_codes.v"


//`define USE_CLK_2F 1


module ThreadsManager(
                    clk,
						  clk_oe,
                    clk_2f,
						  
						  next_thread,
                    
                    ctl_state,
                    
                    cpu_msg_in,
                    cpu_msg_out,
                    
//                    proc,

                    next_proc,
                    
                    thrd_cmd,
                    thrd_rslt,
                    
                    data_in,
                    data_out,
						  
                    addr_in,
						  
						  chan_data_out,
						  
						  result_op_out,
                    
                    cpu_q,
						  
						  run_next_cpu_from_loop,
                    
                    rst
                      );

parameter PROC_QUANTITY = 8;


  input wire clk;
  
  input wire clk_oe;

  input wire clk_2f;

  input wire next_thread;
  
//  inout [`DATA_SIZE0:0] proc;
//  reg [`DATA_SIZE0:0] proc_r;
//  wire [`DATA_SIZE0:0] proc = proc_r;
  
  input wire [7:0] ctl_state;
  reg [7:0] ctl_state_int;
  
  input wire [`CPU_MSG_SIZE0:0] cpu_msg_in;
  output wire [`CPU_MSG_SIZE0:0] cpu_msg_out;

  reg [`DATA_SIZE0:0] next_proc_int_r;
`ifdef USE_CLK_2F
  output /*reg*/ wire [`DATA_SIZE0:0] next_proc = next_proc_int_r;
`else
  output reg [`DATA_SIZE0:0] next_proc;
`endif
  
  input wire [7:0] thrd_cmd;
  
  output [1:0] thrd_rslt;
  reg [1:0] thrd_rslt_r;
  wire [1:0] thrd_rslt = thrd_rslt_r;
  
  //reg run_next_cpu_from_loop;
  
  input wire cpu_q;
  
  reg cpu_msg_pulse;
  
  input wire [`DATA_SIZE0:0] data_in;
  output [`DATA_SIZE0:0] data_out;
  
  
  reg [`DATA_SIZE0:0] data_r_int;
  reg [`DATA_SIZE0:0] data_r;
  wire [`DATA_SIZE0:0] data_out =
/**/
                             (
                               (ctl_state == `CTL_CPU_CMD && cpu_msg_in == `CPU_R_FORK_DONE)
                               || (ctl_state == `CTL_CPU_CMD && cpu_msg_in == `CPU_R_STOP_DONE)
//                               || (ctl_state == `CTL_CPU_LOOP)
                             )
                             || cpu_q == 1
/**/
`ifdef USE_CLK_2F
                             ? data_r_int //data_r
`else
                             ? data_r
`endif
                             : 0
                             ;
  
  input wire [`ADDR_SIZE0:0] addr_in;
  
  
  reg [`DATA_SIZE0:0] chan_data_r;
  output wire [`DATA_SIZE0:0] chan_data_out = 
                                     chan_data_r
                                     ;
												 
  reg [`CHN_OP_SIZE0:0] result_op_r;
  output wire [`CHN_OP_SIZE0:0] result_op_out = 
                                     result_op_r
                                     ;
  

  input wire rst;
  
  
  // VV min threads loop (active)
  reg [(`DATA_SIZE0 + `ADDR_SIZE /*+ 1*/):0] aproc_tbl [0:PROC_QUANTITY];
  
  reg [15:0] aproc_tbl_addr;
  
  wire [(`DATA_SIZE0 + `ADDR_SIZE /*+ 1*/):0] aproc_tbl_item = aproc_tbl[aproc_tbl_addr];
  
//  reg [(`DATA_SIZE0 + `ADDR_SIZE):0] pproc_tbl [0:PROC_QUANTITY];
//  reg [(`DATA_SIZE0 + `ADDR_SIZE):0] sproc_tbl [0:PROC_QUANTITY];

  // VV thread is waiting for fork (passive)
  reg [(`DATA_SIZE0 + `ADDR_SIZE):0] pproc_r;
  reg is_pproc;

`ifdef PAUSE_PROC_ENABLE
  // VV thread is waiting for pause (escape and wait on longtime in/out operations). 
  reg [(`DATA_SIZE0 + `ADDR_SIZE):0] pause_proc_r;
  reg is_pause_proc;
  
  // VV wait counters loop for thread pause counters
  reg [`DATA_SIZE0:0] pause_proc_tbl [0:PROC_QUANTITY];
  wire [`DATA_SIZE0:0] pause_proc_tbl_item = pause_proc_tbl[aproc_tbl_addr];
  reg [`DATA_SIZE0:0] pause_proc_r_int;
  
  reg [9:0] pause_proc_timeout_r;
`endif  

  // VV thread of current channel operation 
  reg [(`DATA_SIZE0 + `ADDR_SIZE):0] chn_proc_r;
  reg [`DATA_SIZE0:0] chn_data_r;
  reg [`ADDR_SIZE0:0] chn_number_r;
  reg [`CHN_OP_SIZE0:0] chn_op_r;
  reg is_chn_proc;
  reg is_chn_data;

  // VV results of last channel operation 
  reg [(`DATA_SIZE0 + `ADDR_SIZE):0] chn_rslt_proc_r;
  reg [`DATA_SIZE0:0] chn_rslt_data_r;
  reg [`ADDR_SIZE0:0] chn_rslt_number_r;
  reg [`CHN_OP_SIZE0:0] chn_rslt_op_r;
  reg is_chn_rslt;
  
  //wire [`DATA_SIZE0:0] chn_cur_data_parsed = chn_data_r_int[(`DATA_SIZE0 + `ADDR_SIZE):`ADDR_SIZE];
  //wire [`DATA_SIZE0:0] chn_cur_num_parsed = chn_data_r_int[`ADDR_SIZE0:0];
  
  // VV loop of active channel operations (also sinchronised with the main threads loop)
  //reg [(`DATA_SIZE0 + `ADDR_SIZE):0] chn_proc_tbl [0:PROC_QUANTITY];
  //wire [(`DATA_SIZE0 + `ADDR_SIZE):0] chn_proc_tbl_item = chn_proc_tbl[aproc_tbl_addr];
  //reg [(`DATA_SIZE0 + `ADDR_SIZE):0] chn_proc_r_int;

  reg [(`DATA_SIZE0 + `ADDR_SIZE):0] chn_data_tbl [0:PROC_QUANTITY];
  wire [(`DATA_SIZE0 + `ADDR_SIZE):0] chn_data_tbl_item = chn_data_tbl[aproc_tbl_addr];
  reg [(`DATA_SIZE0 + `ADDR_SIZE):0] chn_data_r_int;
  wire [`DATA_SIZE0:0] chn_data_parsed = chn_data_r_int[(`DATA_SIZE0 + `ADDR_SIZE):`ADDR_SIZE];
  wire [`DATA_SIZE0:0] chn_num_parsed = chn_data_r_int[`ADDR_SIZE0:0];

  reg [`CHN_OP_SIZE0:0] chn_op_tbl [0:PROC_QUANTITY];
  wire [`CHN_OP_SIZE0:0] chn_op_tbl_item = chn_op_tbl[aproc_tbl_addr];
  reg [`CHN_OP_SIZE0:0] chn_op_r_int;

  // VV thread is waiting for stop
  reg [(`DATA_SIZE0 + `ADDR_SIZE):0] sproc_r;
  reg [`DATA_SIZE0:0] sproc_finish_i_r;
  reg is_sproc;

  // VV parts of the main threads loop
  reg [`DATA_SIZE0:0] aproc_b;
  reg [`DATA_SIZE0:0] aproc_e;
  reg [`DATA_SIZE0:0] aproc_i;
  
  wire [`DATA_SIZE:0] aproc_e_minus_1 = aproc_e - 1;
  
  wire [`DATA_SIZE:0] aproc_i_next =
                (aproc_e_minus_1 == aproc_i)
                ? 0
                : aproc_i + 1
                ;
  
  
//  reg [`DATA_SIZE0:0] pproc_b;
//  reg [`DATA_SIZE0:0] pproc_e;
  

//  reg [`DATA_SIZE0:0] sproc_e;
//  reg [`DATA_SIZE0:0] sproc_i;

  
//  wire [`ADDR_SIZE0:0] aproc_addrs[0:PROC_QUANTITY]; // = aproc_tbl[`ADDR_SIZE0:0][0:PROC_QUANTITY];
//  assign aproc_addrs [`ADDR_SIZE0:0] = aproc_tbl[`ADDR_SIZE0:0];
//  wire aproc_tst[0:PROC_QUANTITY]; // = (aproc_tbl[0:PROC_QUANTITY]) === addr;
//  assign aproc_tst[0:PROC_QUANTITY] = (aproc_tbl[0:PROC_QUANTITY] === addr);

  reg [7:0] i;
  
  
  
  reg [`DATA_SIZE0:0] new_proc_cntr;

  reg ready_to_fork_thread;
  
  reg is_need_stop_thrd;

  reg [`DATA_SIZE0:0] tmp_data_r;
  
  reg next_proc_ready;
  output reg run_next_cpu_from_loop; // = next_proc_ready;
  
  reg chn_seek_cntr;
  
  //reg [7:0] dbg;

  
/**/
`ifndef USE_CLK_2F
  always @(negedge clk_2f) begin
    if(rst == 1) begin
//      proc_r = 0; //32'h zzzzzzzz;
      next_proc <= 0;
		data_r <= 0;
		
		//run_next_cpu_from_loop <= 0;
    end else /*if(clk == 1)*/ begin

      //case(ctl_state)
      //  `CTL_CPU_LOOP: begin
		//    run_next_cpu_from_loop <= 0;
		//  end

      //  default: begin
      //    run_next_cpu_from_loop <= run_next_cpu_from_loop | next_proc_ready;
      //  end

		//endcase

	   if(next_proc_ready == 1) begin
        next_proc <= next_proc_int_r;
		  data_r <= data_r_int;
		end
    end
  end
`endif
/**/


`ifdef USE_CLK_2F
  always @(negedge clk_2f) begin //negedge clk) begin
`else
  always @(negedge clk) begin
`endif

//    if(ctl_state_int != 0) begin
/**/






		    case(ctl_state_int)
			   0: begin
				  //run_next_cpu_from_loop <= 0;
				  
              //dbg <= 0;
              if(
				     ready_to_fork_thread == 1 || //next_thread == 1 ||
					  (is_chn_proc == 1 && is_chn_data == 1) ||
					  is_chn_rslt == 1
				  ) begin

                ready_to_fork_thread <= 0;

                if(is_pproc == 1) begin
				      {data_r_int, next_proc_int_r} <= pproc_r;
                  
						next_proc_ready <= 1;
                  
						aproc_tbl_addr <= aproc_e;
                  //aproc_tbl[aproc_e] <= pproc_r; //{data_r_int, next_proc_int_r};
                  
				      //is_pproc <= 0;

				      ctl_state_int <= `CTL_CPU_START_THREAD_ph01;
//				      ctl_state_int <= `CTL_CPU_START_THREAD_ph1;
                end else begin
              
//                  {data_r_int, next_proc_int_r} <= aproc_tbl[aproc_i];
						aproc_tbl_addr <= aproc_i;

				      ctl_state_int <= `CTL_CPU_GET_NEXT_FROM_LOOP_STORE_0;
//				      ctl_state_int <= `CTL_CPU_MAIN_THREAD_PROCESSOR_0;
                end
              end
            end


				`CTL_CPU_START_THREAD_ph01: begin
              //aproc_tbl[aproc_e] <= pproc_r; //{data_r_int, next_proc_int_r};
              aproc_tbl[aproc_tbl_addr] <= pproc_r; //{data_r_int, next_proc_int_r};
				  
`ifdef PAUSE_PROC_ENABLE
              pause_proc_tbl[aproc_tbl_addr] <= 0;
`endif
				  
              chn_data_tbl[aproc_tbl_addr] <= 0;
              //chn_proc_tbl[aproc_tbl_addr] <= 0;
              chn_op_tbl[aproc_tbl_addr] <= `CHN_OP_NULL;
              //aproc_tbl_item <= pproc_r;
				  
              is_pproc <= 0;

              next_proc_ready <= 0;

              //ctl_state_int <= `CTL_CPU_START_THREAD_ph1;
              if(aproc_e < PROC_QUANTITY-1) begin
				    aproc_e <= aproc_e + 1;
				  end
				  
				  ctl_state_int <= 0;
				end
				
				`CTL_CPU_GET_NEXT_FROM_LOOP_STORE_0: begin
//                  {data_r_int, next_proc_int_r} <= aproc_tbl[aproc_i];
                  {data_r_int, next_proc_int_r} <= aproc_tbl_item;
						
						//chn_proc_r_int <= chn_proc_tbl_item;
						chn_data_r_int <= chn_data_tbl_item;
						chn_op_r_int <= chn_op_tbl_item;


`ifdef PAUSE_PROC_ENABLE
						pause_proc_r_int <= pause_proc_tbl_item;
						
                  if(
				        is_pause_proc == 1 //&& 
						//  /*{data_r_int, next_proc_int_r}*/ aproc_tbl_item == pause_proc_r
                  ) begin
				      //  ctl_state_int <= `CTL_CPU_PAUSE_SET_TO_LOOP;
						//end else
                    if(
				        //    is_pause_proc == 1 //&& 
						      /*{data_r_int, next_proc_int_r}*/ aproc_tbl_item == pause_proc_r
                    ) begin
				          ctl_state_int <= `CTL_CPU_PAUSE_SET_TO_LOOP;
                    end else 
						  if(pause_proc_timeout_r == 0) begin
						    is_pause_proc <= 0;
							 //pause_proc_timeout_r <= 0;
							 
							 ctl_state_int <= `CTL_CPU_MAIN_THREAD_PROCESSOR_0;
                    end else begin
                      pause_proc_timeout_r <= pause_proc_timeout_r - 1;
							 
							 ctl_state_int <= `CTL_CPU_MAIN_THREAD_PROCESSOR_0;
                    end
						end else
						
						if(pause_proc_tbl_item != 0) begin
						  ctl_state_int <= `CTL_CPU_PAUSE_PROCESS;
						end else
`endif
						
						if(is_chn_proc == 1 && is_chn_data == 1 && is_chn_rslt == 0) begin
				        ctl_state_int <= `CTL_CPU_CHAN_OP_ph0;
						end else begin
				        ctl_state_int <= `CTL_CPU_MAIN_THREAD_PROCESSOR_0;
						end
				end
				
				`CTL_CPU_REMOVE_THREAD_ph10: begin
//						 {data_r_int, next_proc_int_r} <= aproc_tbl[0]; //aproc_b];
                  {data_r_int, next_proc_int_r} <= aproc_tbl_item;
						
						next_proc_ready <= 1;
						run_next_cpu_from_loop <= 1;

				      ctl_state_int <= `CTL_CPU_MAIN_THREAD_PROCESSOR_FINALISER;
				end
				
				`CTL_CPU_MAIN_THREAD_PROCESSOR_FINALISER: begin
						next_proc_ready <= 0;
						//run_next_cpu_from_loop <= 1;

				      ctl_state_int <= 0;
				end
				
				`CTL_CPU_REMOVE_THREAD_ph20: begin
//						 {data_r_int, next_proc_int_r} <= aproc_tbl[aproc_e_minus_1];
						 {data_r_int, next_proc_int_r} <= aproc_tbl_item;
						 
						 next_proc_ready <= 1;
						 run_next_cpu_from_loop <= 1;
						 
						 ctl_state_int <= `CTL_CPU_REMOVE_THREAD_ph2;
				end
				
				
				`CTL_CPU_CHAN_OP_ph0: begin
				  if(
				    chn_proc_r == {data_r_int, next_proc_int_r} 
					 //&& chn_op_r_int == `CHN_OP_NULL
				  ) begin
				  
				    if(chn_op_r_int != `CHN_OP_NULL) begin
						chn_op_r <= `CHN_OP_NULL;
					 
					   is_chn_proc <= 0;
					   is_chn_data <= 0;
						
					   ctl_state_int <= `CTL_CPU_MAIN_THREAD_PROCESSOR_0;
					 end else
				    if(chn_seek_cntr == 0 /*&& chn_op_r_int == `CHN_OP_NULL*/) begin
					   aproc_tbl_addr <= aproc_i_next;
					   aproc_i <= aproc_i_next;

					   chn_seek_cntr <= 1;

					   ctl_state_int <= `CTL_CPU_GET_NEXT_FROM_LOOP_STORE_0;
					 end else 
					 begin
				      //if(chn_op_r_int == `CHN_OP_NULL) begin
                    chn_data_tbl[aproc_tbl_addr] <= {chn_data_r, chn_number_r};
                    chn_op_tbl[aproc_tbl_addr] <= chn_op_r;

						  chn_data_r_int <= {chn_data_r, chn_number_r};
                    chn_op_r_int <= chn_op_r;
						
						  //chn_op_r <= `CHN_OP_NULL;
                  //end
					 
                  //chn_op_tbl[aproc_tbl_addr] <= chn_op_r;
					   is_chn_proc <= 0;
					   is_chn_data <= 0;
						
                  ctl_state_int <= `CTL_CPU_MAIN_THREAD_PROCESSOR_0;

                        /**
                        aproc_i <= aproc_i_next;
                        aproc_tbl_addr <= aproc_i_next;

                        next_proc_ready <= 0;
                        ctl_state_int <= `CTL_CPU_GET_NEXT_FROM_LOOP_STORE_0;
								/**/
					 end

					   //is_chn_proc <= 0;
					   //is_chn_data <= 0;
						
//					   ctl_state_int <= `CTL_CPU_MAIN_THREAD_PROCESSOR_0;
					 
					 /*
					 case(chn_op_r)
					   `CHN_OP_SEND,
						`CHN_OP_RECEIVE
						: begin
					     //aproc_i <= aproc_i_next;
					     //aproc_tbl_addr <= aproc_i_next;

                    ctl_state_int <= `CTL_CPU_MAIN_THREAD_PROCESSOR_0;
					   end
						
						`CHN_OP_DATA_RECEIVED,
						`CHN_OP_DATA_SENT
						: begin
//						  chn_data_r_int <= {chn_data_r, chn_number_r};
//                    chn_op_r_int <= chn_op_r;
 
					     ctl_state_int <= `CTL_CPU_MAIN_THREAD_PROCESSOR_0;
						end
						
                endcase
					 */
						
				  end else 
				  if(chn_number_r == chn_num_parsed) begin
				    case(chn_op_r_int)
					   `CHN_OP_DATA_SENT,
						`CHN_OP_SEND_FREEZED,
				      `CHN_OP_SEND: begin // thread from loop sends
					     if(
						    chn_op_r == `CHN_OP_RECEIVE //&&
//						    {chn_data_r, chn_number_r} == 
						    //chn_number_r == chn_num_parsed
						  ) begin
						    chn_data_r <= chn_data_parsed;
							 chn_op_r <= `CHN_OP_DATA_RECEIVED;
							 
							 //chn_seek_cntr <= 1;
/*
							 is_chn_rslt <= 1;
							 
                      chn_rslt_proc_r <= chn_proc_r;
                      chn_rslt_number_r <= chn_number_r;

                      chn_rslt_data_r <= chn_data_parsed;
                      chn_rslt_op_r <= chn_op_r_int;
						
                      is_chn_data <= 0;
                      is_chn_proc <= 0;

					       //is_chn_proc <= 0;
					       //is_chn_data <= 0;
*/
							 chn_op_tbl[aproc_tbl_addr] <= `CHN_OP_DATA_SENT;
							 chn_op_r_int <= `CHN_OP_DATA_SENT;
						  end
							 
					       ctl_state_int <= `CTL_CPU_MAIN_THREAD_PROCESSOR_0;
					   end

						`CHN_OP_RECEIVE_FREEZED,
				      `CHN_OP_RECEIVE: begin // thread from loop receives
					     if(
						    chn_op_r == `CHN_OP_SEND ||
						    chn_op_r == `CHN_OP_DATA_SENT //&&
//						    {chn_data_r, chn_number_r} == 
						    //chn_number_r == chn_num_parsed
						  ) begin
						    chn_data_tbl[aproc_tbl_addr] <= {chn_data_r, chn_number_r};
							 chn_data_r_int <= {chn_data_r, chn_number_r};
							 
							 chn_op_tbl[aproc_tbl_addr] <= `CHN_OP_DATA_RECEIVED;
							 chn_op_r_int <= `CHN_OP_DATA_RECEIVED;
							 
							 chn_op_r <= `CHN_OP_DATA_SENT;
						  end
							 
					       ctl_state_int <= `CTL_CPU_MAIN_THREAD_PROCESSOR_0;
					   end

					   default: begin
					     ctl_state_int <= `CTL_CPU_MAIN_THREAD_PROCESSOR_0;
					   end
				    endcase
              //end else
				  //if(chn_op_r_int != `CHN_OP_NULL) begin
				  end else begin
				    ctl_state_int <= `CTL_CPU_MAIN_THREAD_PROCESSOR_0;
				  end
				
				end
				
/**/
`ifdef PAUSE_PROC_ENABLE
            `CTL_CPU_PAUSE_SET_TO_LOOP: begin
              //if(
				  //    is_pause_proc == 1'b 1 && 
              //    {data_r_int, next_proc_int_r} == pause_proc_r
              //) begin
              //if(/*is_pause_proc == 1 &&*/ {data_r_int, next_proc_int_r} == pause_proc_r) begin
                if(pause_proc_tbl_item == 0) begin
                  pause_proc_tbl[aproc_tbl_addr] <= `THREAD_SLEEP_TIMEOUT;
                end
					 
					 is_pause_proc <= 0;
					 //pause_proc_r <= 0;
					 
					 pause_proc_timeout_r <= 0;

					 aproc_i <= aproc_i_next;
					 aproc_tbl_addr <= aproc_i_next;

                next_proc_ready <= 0;
					 
					 //run_next_cpu_from_loop <= 1;
              
                ctl_state_int <= `CTL_CPU_GET_NEXT_FROM_LOOP_STORE_0;
              //end else begin
				    //if(pause_proc_timeout_r != 0) begin
					 //  pause_proc_timeout_r <= pause_proc_timeout_r - 1;
                //end else begin
                //  is_pause_proc <= 0;
                //end

					 //aproc_i <= aproc_i_next;
					 //aproc_tbl_addr <= aproc_i_next;

                //ctl_state_int <= `CTL_CPU_GET_NEXT_FROM_LOOP_STORE_0;
              //end 
              //end else
				end

				
				`CTL_CPU_PAUSE_PROCESS: begin
                 //end else begin
              pause_proc_tbl[aproc_tbl_addr] <= pause_proc_tbl_item - 1; //pause_proc_r_int - 1;
              //pause_proc_tbl[aproc_tbl_addr] <= pause_proc_r_int - 1;

              aproc_i <= aproc_i_next;
              aproc_tbl_addr <= aproc_i_next;

              next_proc_ready <= 0;
              
				  //run_next_cpu_from_loop <= 1;
				  
              ctl_state_int <= `CTL_CPU_GET_NEXT_FROM_LOOP_STORE_0;
            end
`endif

				
            `CTL_CPU_MAIN_THREAD_PROCESSOR_0: begin
/*
				if(
				      chn_op_r_int == `CHN_OP_SEND_FREEZED ||
				      chn_op_r_int == `CHN_OP_RECEIVE_FREEZED
              ) begin
					 aproc_i <= aproc_i_next;
					 aproc_tbl_addr <= aproc_i_next;

                ctl_state_int <= `CTL_CPU_GET_NEXT_FROM_LOOP_STORE_0;
              end else
*/

/*
              if(
				      is_pause_proc == 1'b 1 && 
						{data_r_int, next_proc_int_r} == pause_proc_r
              ) begin
              //if(/*is_pause_proc == 1 &&* / {data_r_int, next_proc_int_r} == pause_proc_r) begin
                if(pause_proc_tbl_item == 0) begin
                  pause_proc_tbl[aproc_tbl_addr] <= `THREAD_SLEEP_TIMEOUT;
                end
					 
					 is_pause_proc <= 0;
					 pause_proc_r <= 0;

					 aproc_i <= aproc_i_next;
					 aproc_tbl_addr <= aproc_i_next;

                ctl_state_int <= `CTL_CPU_GET_NEXT_FROM_LOOP_STORE_0;
              //end else begin
				    //if(pause_proc_timeout_r != 0) begin
					 //  pause_proc_timeout_r <= pause_proc_timeout_r - 1;
                //end else begin
                //  is_pause_proc <= 0;
                //end

					 //aproc_i <= aproc_i_next;
					 //aproc_tbl_addr <= aproc_i_next;

                //ctl_state_int <= `CTL_CPU_GET_NEXT_FROM_LOOP_STORE_0;
              //end 
              end else
*/
				  
              if(is_sproc == 1 && {data_r_int, next_proc_int_r} == sproc_r) begin

					  if(aproc_i >= aproc_e_minus_1) begin
						 aproc_i <= 0; //aproc_b;
						 
						 aproc_tbl_addr <= 0;
						 //{data_r_int, next_proc_int_r} <= aproc_tbl[0]; //aproc_b];
			
						 if(aproc_e > 1) begin 
							aproc_e <= aproc_e_minus_1; //aproc_e - 1;
						 end
						 
						 //ctl_state_int <= 0;
						 
						 is_sproc <= 0;
						 
						 //ready_to_fork_thread <= 0;
						 
						 ctl_state_int <= `CTL_CPU_REMOVE_THREAD_ph10;
					  end else begin
						 //{data_r_int, next_proc_int_r} <= aproc_tbl[aproc_e_minus_1];
						 
						 aproc_tbl_addr <= aproc_e_minus_1;
						 ctl_state_int <= `CTL_CPU_REMOVE_THREAD_ph20;
					  end

              end
              else begin
				     if(is_sproc == 1 && sproc_finish_i_r == aproc_i) begin
					     is_sproc <= 0;
                 end

                 //if(pause_proc_r_int == 0) begin

					    case(chn_op_r_int)
						   //`CHN_OP_NULL: begin
							//end
							
                      `CHN_OP_SEND_FREEZED,
                      `CHN_OP_RECEIVE_FREEZED
                      : begin
                        //aproc_i <= aproc_i_next;
                        aproc_tbl_addr <= aproc_i_next;

                        next_proc_ready <= 0;
                        ctl_state_int <= `CTL_CPU_GET_NEXT_FROM_LOOP_STORE_0;
							 end

						   `CHN_OP_SEND: begin
							  //if(chn_seek_cntr == 0) begin
							  //  chn_seek_cntr <= 1;

							  //  aproc_tbl_addr <= aproc_i_next;

                       //  next_proc_ready <= 0;
                       //  ctl_state_int <= `CTL_CPU_GET_NEXT_FROM_LOOP_STORE_0;
                       //end else begin
                         chn_op_tbl[aproc_tbl_addr] <= `CHN_OP_SEND_FREEZED;

                       //next_proc_ready <= 1;
							  //run_next_cpu_from_loop <= 1;
							  
                       //ctl_state_int <= `CTL_CPU_MAIN_THREAD_PROCESSOR_FINALISER; //0;

							    aproc_tbl_addr <= aproc_i_next;

                         next_proc_ready <= 0;
                         ctl_state_int <= `CTL_CPU_GET_NEXT_FROM_LOOP_STORE_0;
                       //end
                     end

							`CHN_OP_RECEIVE: begin
							  //if(chn_seek_cntr == 0) begin
							  //  chn_seek_cntr <= 1;

							  //  aproc_tbl_addr <= aproc_i_next;

                       //  next_proc_ready <= 0;
                       //  ctl_state_int <= `CTL_CPU_GET_NEXT_FROM_LOOP_STORE_0;
                       //end else begin
                         chn_op_tbl[aproc_tbl_addr] <= `CHN_OP_RECEIVE_FREEZED;

                       //next_proc_ready <= 1;
							  //run_next_cpu_from_loop <= 1;
							  
                       //ctl_state_int <= `CTL_CPU_MAIN_THREAD_PROCESSOR_FINALISER; //0;

							    aproc_tbl_addr <= aproc_i_next;

                         next_proc_ready <= 0;
                         ctl_state_int <= `CTL_CPU_GET_NEXT_FROM_LOOP_STORE_0;
                       //end
                     end

                     `CHN_OP_DATA_SENT,
                     `CHN_OP_DATA_RECEIVED
							: begin

							  //if(chn_proc_r == {data_r_int, next_proc_int_r}) begin
                         if(
							        is_chn_rslt == 0 &&
								     is_chn_data == 0 &&
								     is_chn_proc == 0 //&&
									  //chn_proc_r == {data_r_int, next_proc_int_r}
                         ) begin
					            chn_rslt_proc_r <= {data_r_int, next_proc_int_r}; //chn_proc_r_int;
                           chn_rslt_data_r <= chn_data_parsed;  // chn_cur_data_parsed
                           chn_rslt_number_r <= chn_num_parsed; // chn_cur_num_parsed
                           chn_rslt_op_r <= chn_op_r_int;
								 
								   chn_op_tbl[aproc_tbl_addr] <= `CHN_OP_NULL;
								 //chn_op_r <= `CHN_OP_NULL;
								 
								 //chn_data_tbl[aproc_tbl_addr] <= 0;

                           is_chn_rslt <= 1;
								 
								 //is_chn_data <= 0;
								 //is_chn_proc <= 0;

                           next_proc_ready <= 1;
									//run_next_cpu_from_loop <= 1;
									
                           ctl_state_int <= `CTL_CPU_MAIN_THREAD_PROCESSOR_FINALISER; //0;
                         end else begin
								   //aproc_tbl_addr <= aproc_i_next;
								 
							      //next_proc_ready <= 0;
								   //ctl_state_int <= `CTL_CPU_GET_NEXT_FROM_LOOP_STORE_0;
								 
                           next_proc_ready <= 1;
									//run_next_cpu_from_loop <= 1;
									
                           ctl_state_int <= `CTL_CPU_MAIN_THREAD_PROCESSOR_FINALISER; //0;
							    end
								 
                       //end else begin
								 //aproc_tbl_addr <= aproc_i_next;
								 
							    //next_proc_ready <= 0;
								 //ctl_state_int <= `CTL_CPU_GET_NEXT_FROM_LOOP_STORE_0;
								 
                       //  next_proc_ready <= 1;
                       //  ctl_state_int <= `CTL_CPU_MAIN_THREAD_PROCESSOR_FINALISER; //0;
							  //end
                     end
							
							default: begin
                       next_proc_ready <= 1;
							  //run_next_cpu_from_loop <= 1;
							  
                       ctl_state_int <= `CTL_CPU_MAIN_THREAD_PROCESSOR_FINALISER; //0;
							end
                   endcase

                   aproc_i <= aproc_i_next;

//                   next_proc_ready <= 1;

//                   ctl_state_int <= `CTL_CPU_MAIN_THREAD_PROCESSOR_FINALISER; //0;
                 //end else begin

                 //  pause_proc_tbl[aproc_tbl_addr] <= pause_proc_r_int - 1;
                  
					  //  aproc_i <= aproc_i_next;
					  //  aproc_tbl_addr <= aproc_i_next;

                 //  next_proc_ready <= 0;
                   
                 //  ctl_state_int <= `CTL_CPU_GET_NEXT_FROM_LOOP_STORE_0;
                 //end
              end
            end

/**/
		      `CTL_CPU_REMOVE_THREAD_ph2: begin
              //aproc_tbl[aproc_i] <= {data_r_int, next_proc_int_r};
				  
				  next_proc_ready <= 0;
				  
              aproc_tbl_addr <= aproc_i;
				  
              if(aproc_e > 1) begin 
                aproc_e <= aproc_e - 1;
              end
				  
			     ctl_state_int <= `CTL_CPU_REMOVE_THREAD_ph12; //0;
				  
				  is_sproc <= 0;
		      end
/**/

		      `CTL_CPU_REMOVE_THREAD_ph12: begin
              //aproc_tbl_item <= {data_r_int, next_proc_int_r};
              aproc_tbl[aproc_tbl_addr] <= {data_r_int, next_proc_int_r};
				  
              //if(aproc_e > 1) begin 
              //  aproc_e <= aproc_e - 1;
              //end
				  
			     ctl_state_int <= 0;
				  
				  //is_sproc <= 0;
		      end


/**
            `CTL_CPU_START_THREAD_ph1: begin

              if(aproc_e < PROC_QUANTITY-1) begin
				    aproc_e <= aproc_e + 1;
				  end
				  
				  ctl_state_int <= 0;
				end
/**/
          endcase





//    end else


    if(clk_oe == 0) begin
//    if(clk_oe == 0 && clk == 1) begin
//    if(clk_oe == 0 && clk == 0) begin

      //data_r <= 0;
//		chan_data_r <= 0;
      //result_op_r <= `CHN_OP_NULL;

//      case(ctl_state)
//        `CTL_CPU_LOOP, `CTL_CPU_CMD: begin
		  
//		    case(ctl_state_int)
/**
            `CTL_CPU_MAIN_THREAD_PROCESSOR_0: begin
              if(is_sproc == 1 && {data_r_int, next_proc_int_r} == sproc_r) begin

					  if(aproc_i == aproc_e_minus_1) begin
						 aproc_i <= 0; //aproc_b;
						 
	//					 {data_r_int, next_proc_int_r} <= aproc_tbl[0]; //aproc_b];
						 //aproc_tbl_addr <= 0;
						 {data_r_int, next_proc_int_r} <= aproc_tbl[0]; //aproc_b];
			
						 if(aproc_e > 1) begin 
							aproc_e <= aproc_e - 1;
						 end
						 
						 ctl_state_int <= 0;
						 
						 is_sproc <= 0;
						 
						 ready_to_fork_thread <= 0;
					  end else begin
						 {data_r_int, next_proc_int_r} <= aproc_tbl[aproc_e_minus_1];
						 ctl_state_int <= `CTL_CPU_REMOVE_THREAD_ph2;
					  end


                  end
                  else begin
				        if(is_sproc == 1 && sproc_finish_i_r == aproc_i) begin
					       is_sproc <= 0;
                    end
					 
						    if(aproc_e_minus_1 == aproc_i) begin
                        aproc_i <= 0; //aproc_b;
                      end else begin
					         aproc_i <= aproc_i + 1;
                      end
              
                    ctl_state_int <= 0;
						  
                  end
            end

/**
		      `CTL_CPU_REMOVE_THREAD_ph2: begin
              aproc_tbl[aproc_i] <= {data_r_int, next_proc_int_r};
				  
              if(aproc_e > 1) begin 
                aproc_e <= aproc_e - 1;
              end
				  
			     ctl_state_int <= 0;
				  
				  is_sproc <= 0;
		      end
/**/


/**
            `CTL_CPU_START_THREAD_ph1: begin

              if(aproc_e < PROC_QUANTITY-1) begin
				    aproc_e <= aproc_e + 1;
				  end
				  
				  ctl_state_int <= 0;
				end
/**/
//          endcase




//    if(clk_oe == 0) begin
	 
	 end else begin
	 
    if(rst == 1) begin
      next_proc_int_r <= 0;
		//next_proc <= 0;
		data_r_int <= 0;
		//data_r <= 0;
      
      aproc_b <= 0;
      aproc_e <= 0;
      aproc_i <= 0;
      
//      pproc_b = 0;
//      pproc_e = 1;
      
//      pproc_tbl[0] = 0;
      pproc_r <= 0;
		is_pproc <= 1;
      
`ifdef PAUSE_PROC_ENABLE
      pause_proc_r <= 0;
		is_pause_proc <= 0;
`endif
      
      chn_proc_r <= 0;
      chn_data_r <= 0;
      chn_op_r <= `CHN_OP_NULL;
		is_chn_proc <= 0;
		is_chn_data <= 0;
      
      new_proc_cntr <= 1;
      
      thrd_rslt_r <= 0;
      
      ready_to_fork_thread <= 1;
      
		is_sproc <= 0;
//      sproc_e = 0;

      ctl_state_int <= 0;
		
		aproc_tbl_addr <= 0;
		
		next_proc_ready <= 0;

      chn_rslt_proc_r <= 0;
      chn_rslt_data_r <= 0;
      chn_rslt_number_r <= 0;
      chn_rslt_op_r <= 0;
      is_chn_rslt <= 0;
		
		chan_data_r <= 0;
		result_op_r <= 0;
		
		chn_seek_cntr <= 1;
		
`ifdef PAUSE_PROC_ENABLE
		pause_proc_timeout_r <= 0;
`endif
		
		run_next_cpu_from_loop <= 0;
    end else begin


      if(next_thread == 1) begin //thrd_cmd == `THREAD_CMD_GET_NEXT_STATE) begin
        ready_to_fork_thread <= 1;
      end //else 
		
		begin

      
      case(ctl_state)
        `CTL_CPU_LOOP: begin
		  
		    //run_next_cpu_from_loop <= 0;
		  
//		    case(ctl_state_int)
/**
			   0: begin
				  //run_next_cpu_from_loop <= 0;
				  
              //dbg <= 0;
              if(
				     ready_to_fork_thread == 1 || next_thread == 1 ||
					  (is_chn_proc == 1 && is_chn_data == 1) ||
					  is_chn_rslt == 1
				  ) begin

                ready_to_fork_thread <= 0;

                if(is_pproc == 1) begin
				      {data_r_int, next_proc_int_r} <= pproc_r;
                  
						next_proc_ready <= 1;
                  
						aproc_tbl_addr <= aproc_e;
                  //aproc_tbl[aproc_e] <= pproc_r; //{data_r_int, next_proc_int_r};
                  
				      //is_pproc <= 0;

				      ctl_state_int <= `CTL_CPU_START_THREAD_ph01;
//				      ctl_state_int <= `CTL_CPU_START_THREAD_ph1;
                end else begin
              
//                  {data_r_int, next_proc_int_r} <= aproc_tbl[aproc_i];
						aproc_tbl_addr <= aproc_i;

				      ctl_state_int <= `CTL_CPU_GET_NEXT_FROM_LOOP_STORE_0;
//				      ctl_state_int <= `CTL_CPU_MAIN_THREAD_PROCESSOR_0;
                end
              end
            end
/**/

/**
            `CTL_CPU_MAIN_THREAD_PROCESSOR_0: begin
//                  if(is_need_stop_thrd) begin
				      if(is_sproc == 1 && {data_r_int, next_proc_int_r} == sproc_r) begin
//                    aproc_tbl[aproc_i] = aproc_tbl[aproc_e];
//                    is_sproc = 0;
					 
                    if(aproc_e != aproc_b) begin
                      if(aproc_e == 0) begin
                        aproc_e = PROC_QUANTITY - 1;
                      end 
                      else begin
                        aproc_e = aproc_e - 1;
                      end
                    end
					 
				        ctl_state_int = `CTL_CPU_REMOVE_THREAD_ph1;

/**
                if(aproc_i == aproc_e) begin
                  aproc_i = aproc_b;
                end else begin
/**  only for test! * /
//                  aproc_tbl[aproc_i] = aproc_tbl[aproc_e];
                  {/*is_need_stop_thrd,* / data_r_int, next_proc_int_r} = aproc_tbl[aproc_e];
                  aproc_tbl[aproc_i] = {/*is_need_stop_thrd,* / data_r_int, next_proc_int_r};
                end
/** /
                  end
                  else begin
				        if(is_sproc == 1 && sproc_finish_i_r == aproc_i) begin
					       is_sproc = 0;
                    end
					 
                    //aproc_i = aproc_i + 1;
                    if(aproc_i >= PROC_QUANTITY-1) begin
						    if(aproc_e == 0) begin
                        aproc_i = aproc_b;
							 end else begin
                        aproc_i = 0;
                      end
                    end else begin
						    if(aproc_e_minus_1 == aproc_i) begin
                        aproc_i = aproc_b;
                      end else begin
					         aproc_i = aproc_i + 1;
                      end
					     end
                
//                    if(aproc_i == aproc_e) begin
//                      aproc_i = aproc_b;
//                    end
              
                    ctl_state_int = 0;
						  
                    ready_to_fork_thread = 0;
                  end
//                end
          
//              end
            end
/**/
				

/**
		      `CTL_CPU_REMOVE_THREAD_ph1:
//		  else if(ctl_state_int == `CTL_CPU_REMOVE_THREAD_ph1) 
		  
		      /*`CTL_CPU_REMOVE_THREAD:* / begin
              is_sproc = 0;

/**
          if(aproc_e != aproc_b) begin
            if(aproc_e == 0) begin
              aproc_e = PROC_QUANTITY - 1;
            end 
            else begin
              aproc_e = aproc_e - 1;
            end
          end
/** /

              if(aproc_i == aproc_e) begin
                aproc_i = aproc_b;
			       ctl_state_int = 0;
              end else begin
/**  only for test! * /
//                  aproc_tbl[aproc_i] = aproc_tbl[aproc_e];
                {/*is_need_stop_thrd,* / data_r_int, next_proc_int_r} = aproc_tbl[aproc_e];
//                aproc_tbl[aproc_i] = {/*is_need_stop_thrd,* / data_r_int, next_proc_int_r};
			       ctl_state_int = `CTL_CPU_REMOVE_THREAD_ph2;
              end
			 
		      end 
/**/

		  
/**
		      `CTL_CPU_REMOVE_THREAD_ph2: begin
              aproc_tbl[aproc_i] = {/*is_need_stop_thrd,* / data_r_int, next_proc_int_r};
			     ctl_state_int = 0;
		      end
/**/


/**
		      `CTL_CPU_REMOVE_THREAD_ph1: begin
              if(aproc_i == aproc_e_minus_1) begin
                aproc_i = 0; //aproc_b;
					 
					 {data_r_int, next_proc_int_r} = aproc_tbl[0]; //aproc_b];
		
                if(aproc_e > 0) begin 
                  aproc_e = aproc_e - 1;
                end
					 
			       ctl_state_int = 0;
					 
                is_sproc = 0;
					 
					 ready_to_fork_thread = 0;
              end else begin
                {data_r_int, next_proc_int_r} = aproc_tbl[aproc_e];
			       ctl_state_int = `CTL_CPU_REMOVE_THREAD_ph2;
              end
		      end 
/**/
				
//		    endcase
		  
		  end
		  
        
        `CTL_CPU_CMD: begin
        
          case(thrd_cmd)
            `THREAD_CMD_RUN: begin
/**
              if(pproc_e < PROC_QUANTITY) begin
                pproc_tbl[pproc_e] = {data_in, addr_in};
                pproc_e = pproc_e + 1;
/**/
              if(is_pproc == 0) begin
				    pproc_r <= {data_in, addr_in};
					 is_pproc <= 1;
                
                data_r_int <= 32'h deadbeef; //-1;
                thrd_rslt_r <= 1;
              end else
              begin
                data_r_int <= 0;
                thrd_rslt_r <= 0;
              end
            end
            
            `THREAD_CMD_STOP: begin
				
				  if(is_sproc == 1) begin
                data_r_int <= 0;
                thrd_rslt_r <= 0;
				  end else begin
				    sproc_r <= {data_in, addr_in};
					 sproc_finish_i_r <= aproc_i;
					 is_sproc <= 1;
					 
                data_r_int <= 32'h beefdead; //-1;
                thrd_rslt_r <= 1;
              end
              
//              for(i = aproc_b; i != aproc_e; i = (i < (PROC_QUANTITY - 1)) ? i+1 : 0 ) begin

/**  only for test! *
              for(i = 0; i < PROC_QUANTITY; i = i+1 ) begin
                if( aproc_tbl[i][`ADDR_SIZE0:0] == addr_in ) begin
                  aproc_tbl[i][(`DATA_SIZE0 + `ADDR_SIZE + 1)] = 1'b 1;

                  data_r_int = -1;
                  thrd_rslt_r = 1;
                end
              end
						
/**/

              /*
              if(pproc_e < PROC_QUANTITY) begin
                pproc_tbl[pproc_e] = addr;
                pproc_e = pproc_e + 1;
                
                data_r_int = -1;
                thrd_rslt_r = 1;
              end else
              begin
                data_r_int = 0;
                thrd_rslt_r = 0;
              end
              */
            end
            
`ifdef PAUSE_PROC_ENABLE
            `THREAD_CMD_PAUSE: begin
              if(is_pause_proc == 0) begin
				    pause_proc_r <= {data_in, addr_in};
					 is_pause_proc <= 1;
                
                //data_r_int <= 32'h deadbeef; //-1;
                thrd_rslt_r <= 0; //1;
					 
					 pause_proc_timeout_r <= PROC_QUANTITY; // * 2;
              end else
              begin
                data_r_int <= 0;
                thrd_rslt_r <= 0;
              end
            end
`endif
            
            `THREAD_CMD_CHAN_SET: begin
				  /**/
              if(is_chn_proc == 0 && is_chn_data == 0) begin
				    chn_op_r <= `CHN_OP_SEND;
				    //chn_number_r <= {data_in, addr_in};
				    chn_data_r <= data_in;
				    chn_number_r <= addr_in;
					 is_chn_data <= 1;
                
                //data_r_int <= 32'h deadbeef; //-1;
                //thrd_rslt_r <= 1;
              end else
              begin
                data_r_int <= 0;
                thrd_rslt_r <= 0;
              end
				  /**/
            end
            
            `THREAD_CMD_CHAN_GET: begin
				  /**/
              if(is_chn_proc == 0 && is_chn_data == 0) begin
				    chn_op_r <= `CHN_OP_RECEIVE;
				    //chn_number_r <= {data_in, addr_in};
				    chn_data_r <= 32'hdeadbeef;
				    chn_number_r <= addr_in;
					 is_chn_data <= 1;
                
                //data_r_int <= 32'h deadbeef; //-1;
                //thrd_rslt_r <= 0;
              end else
              begin
                data_r_int <= 0;
                thrd_rslt_r <= 0;
              end
				  /**/
            end
            
            `THREAD_CMD_THRD_ADDR: begin
				  /**/
              if(is_chn_proc == 0 && is_chn_data == 1 /*&& chn_seek_cntr == 1*/) begin
				    chn_proc_r <= {data_in, addr_in};
//					 is_chn_proc <= 1;
					 
					 if(is_chn_rslt == 1) begin
					   if( 
						    chn_rslt_proc_r == {data_in, addr_in} //&&
						    //chn_number_r == chn_rslt_number_r
					   ) begin
					     //chan_data_r <= chn_rslt_number_r;
						  //data_r <= chn_rslt_data_r;
						  chan_data_r <= chn_rslt_data_r;
						  result_op_r <= chn_rslt_op_r;

						  is_chn_rslt <= 0;
                  end else begin
						  result_op_r <= `CPU_R_CHAN_NO_RESULTS; //`CHN_OP_NO_RESULTS;
                  end
					   is_chn_data <= 0;
					   is_chn_proc <= 0;
					 end else begin
						result_op_r <= `CPU_R_CHAN_NO_RESULTS; //`CHN_OP_NO_RESULTS;
						
						chn_seek_cntr <= 1;

					   is_chn_proc <= 1;
					 end
                
                //data_r_int <= 32'h deadbeef; //-1;
                //thrd_rslt_r <= 0;
              end else
              begin
                data_r_int <= 0;
                thrd_rslt_r <= 0;
              end
				  /**/
            end
            
          endcase
          
        end
      
      endcase
		
		end // if(thrd_cmd != `THREAD_CMD_GET_NEXT_STATE)
    
    end
	 
	 end

  end
                      
endmodule


