


`include "sizes.v"
`include "states.v"
`include "inter_cpu_msgs.v"
`include "misc_codes.v"

`include "defines.v"



module DispatcherOfCpus(
            clk,
				clk_oe,
				clk_2f,
				
            rst_in,
				rst_out,
            
            halt_q,
            rw_halt_in,
            rw_halt_out,
				
				addr_unmodificable_b,
            
				addr_in,
            addr_out,
				
            data_in,
            data_out,
            
            ext_mem_addr_in,
            ext_mem_addr_out,

            ext_mem_data_in,
            ext_mem_data_out,
            
            ext_read_q,
            ext_write_q,
            ext_read_dn,
            ext_write_dn,
            
				ext_rw_halt_in,
				ext_rw_halt_out,
				
//            ext_rw_busy,

            ext_bus_q,
            ext_bus_allow,
            
            read_q,
            write_q,
            read_dn,
            write_dn,
            
            bus_busy,
            
				init,
            ext_rst_b,
            ext_rst_e,
            
            ext_cpu_index,
            
            ext_cpu_q,
            ext_cpu_e,
            
            cpu_msg_in,
            cpu_msg_out,
            
            dispatcher_q
          );
          
parameter CPU_QUANTITY = `CPU_QUANTITY;
parameter PROC_QUANTITY = `PROC_QUANTITY;


  input wire clk;
  input wire rst_in;
  
  output reg rst_out;

//  output reg clk_oe;
  input wire clk_oe;
  
  input wire clk_2f;

  input wire halt_q;
  
  input wire rw_halt_in;
  output rw_halt_out;
  reg rw_halt_r;
  wire rw_halt_out = rw_halt_r;
  
  input wire [`ADDR_SIZE0:0] addr_unmodificable_b;
  
  
  input wire [`ADDR_SIZE0:0] addr_in;
  output [`ADDR_SIZE0:0] addr_out;
  reg [`ADDR_SIZE0:0] addr_out_r;
  
  input wire read_q;
  input wire write_q;
  
  output read_dn;
  reg read_dn_r;
  wire read_dn = read_dn_r;
  
  output write_dn;
  reg write_dn_r;
  wire write_dn = write_dn_r;
  
  
  input [`DATA_SIZE0:0] data_in;
  output [`DATA_SIZE0:0] data_out;
  reg [`DATA_SIZE0:0] data_r;
  //tri [`DATA_SIZE0:0] data_wire = data_wire_r;
  
  output bus_busy;
  reg bus_busy_r;
  wire bus_busy = bus_busy_r;
  
  

  output init;
  reg init_r;
  wire init = init_r;
  
  output ext_rst_b; // = RESET;
  reg ext_rst_b_r; // = RESET;
  wire ext_rst_b = ext_rst_b_r; // = RESET;
  
  input wire ext_rst_e; // = ext_rst_e_r;
  
  output [`DATA_SIZE0:0] ext_cpu_index;
  reg [`DATA_SIZE0:0] ext_cpu_index_r;
  wire [`DATA_SIZE0:0] ext_cpu_index = ext_cpu_index_r;
  
  output ext_cpu_q;
  reg cpu_q_r;
  wire ext_cpu_q = cpu_q_r;

  input wire ext_cpu_e;
  
  input wire [`CPU_MSG_SIZE0:0] cpu_msg_in;
  output [`CPU_MSG_SIZE0:0] cpu_msg_out;
  
  reg [`CPU_MSG_SIZE0:0] cpu_msg_r;
  wire [`CPU_MSG_SIZE0:0] cpu_msg_out = cpu_msg_r;
  
  input wire dispatcher_q;
  
  
  input wire ext_bus_q;
  output reg ext_bus_allow;
  
  
  reg [31:0] mem_addr_tmp;
  reg [31:0] mem_data_tmp;
  reg mem_rd;
  reg mem_wr;  



  reg [7:0] state_ctl;
  


  reg [7:0] thrd_cmd_r;
  wire [1:0] thrd_rslt;
  
  wire [`DATA_SIZE0:0] next_proc;
  
  wire [`DATA_SIZE0:0] addr_chan_to_op_out;

  reg [`ADDR_SIZE0:0] addr_thread_to_op_r;
  reg [`DATA_SIZE0:0] addr_chan_to_op_r;
  wire [`DATA_SIZE0:0] addr_chan_to_op =
/*                                        //(cpu_msg === `CPU_R_FORK_DONE)
                                        ext_cpu_q === 1 ||
                                        (
                                         (/*state_ctl == `CTL_CPU_CMD &&* / cpu_msg === `CPU_R_FORK_DONE)
                                         || (/*state_ctl == `CTL_CPU_CMD &&* / cpu_msg === `CPU_R_STOP_DONE)
//                                         || (state_ctl == `CTL_CPU_LOOP)
                                        )
                                        ? `DATA_SIZE'h zzzz_zzzz_zzzz_zzzz
                                        : 
*/
													 addr_chan_to_op_r
                                        ;
                                        

/*  !!! */
  wire [`DATA_SIZE0:0] data_in; // = 
/*
  //  assign data_wire = 
                                  //(cpu_msg === `CPU_R_FORK_DONE)
                                  ext_cpu_q === 1 ||
                                  (
                                   (/*state_ctl == `CTL_CPU_CMD &&* / cpu_msg === `CPU_R_FORK_DONE)
                                   || (/*state_ctl == `CTL_CPU_CMD &&* / cpu_msg === `CPU_R_STOP_DONE)
//                                   || (state_ctl == `CTL_CPU_LOOP)
                                  )
                                  ? addr_chan_to_op_out
                                  : 
                                  data_wire_r
                                  ;
/**/


/*  !!! */
  wire [`DATA_SIZE0:0] data_out = 
//  assign data_wire = 
                                  //(cpu_msg === `CPU_R_FORK_DONE)
                                  ext_cpu_q === 1 ||
                                  (
                                   (/*state_ctl == `CTL_CPU_CMD &&*/ cpu_msg_in == `CPU_R_FORK_DONE)
                                   || (/*state_ctl == `CTL_CPU_CMD &&*/ cpu_msg_in == `CPU_R_STOP_DONE)
//                                   || (state_ctl == `CTL_CPU_LOOP)
                                  )
                                  ? addr_chan_to_op_out
                                  : (
											    bus_busy_r == 1
											    ? data_r
											    : data_in //0
											 )
											 //: (data_r | data_in)
                                  ;
/**/


  wire [`ADDR_SIZE0:0] addr_out = 
//                                (ext_cpu_q === 1 || read_dn_r === 1 || write_dn_r === 1)
//                                ? 
                                  addr_out_r 
											 | addr_in
                                ;

  wire [`ADDR_SIZE0:0] chan_num_in;
  wire [`DATA_SIZE0:0] chan_data_in;
  wire [`CHN_OP_SIZE0:0] chan_thread_result_op_in;
  
  reg next_thread_r;
  wire next_thread =
                   cpu_msg_in == `CPU_R_START
						 || cpu_msg_in == `CPU_R_FORK_DONE
						 || next_thread_r == 1
                   ;
						 
  wire run_next_cpu_from_loop;

  ThreadsManager trds_mngr (
                    .clk(clk),
						  .clk_oe(clk_oe),
						  .clk_2f(clk_2f),
                    
						  .next_thread(next_thread),
						  
                    .cpu_q(ext_cpu_q),
                    
                    .ctl_state(state_ctl),
                    
                    .cpu_msg_in(cpu_msg_in),
                    
                    .next_proc(next_proc),
                    
                    .thrd_cmd(thrd_cmd_r),
                    .thrd_rslt(thrd_rslt),
                    
                    .addr_in(addr_thread_to_op_r),
                    .data_out(addr_chan_to_op_out),
                    .data_in(addr_chan_to_op),
                    
						  .chan_data_out(chan_data_in),
						  
						  .result_op_out(chan_thread_result_op_in),
						  
						  .run_next_cpu_from_loop(run_next_cpu_from_loop),

                    .rst(rst_out)
                    );



  reg [`DATA_SIZE0:0] cpu_num_a;
  reg [`DATA_SIZE0:0] cpu_num_na;
  
  reg [`DATA_SIZE0:0] cpu_num;
  wire [`DATA_SIZE0:0] cpu_num_plus_1 = cpu_num + 1;

//  reg [7:0] state_ctl;
  
  reg new_cpu_restarted;
  
  


  output ext_read_q;
  reg ext_read_q_r;
  wire ext_read_q = ext_read_q_r;
  
  output ext_write_q;
  reg ext_write_q_r;
  wire ext_write_q = ext_write_q_r;
  
  input wire ext_read_dn;
  input wire ext_write_dn;
  
//  input wire ext_rw_busy;
  
  
  input ext_rw_halt_in;
  output ext_rw_halt_out;
  reg ext_rw_halt_r;
  wire ext_rw_halt_out = ext_rw_halt_r;

  
  input wire [`ADDR_SIZE0:0] ext_mem_addr_in;
  output [`ADDR_SIZE0:0] ext_mem_addr_out;
  wire [`ADDR_SIZE0:0] ext_mem_addr_out = 
                                    (
//												 read_q == 1
//												 || write_q == 1
												 mem_wr == 1
												 || mem_rd == 1
                                     //ext_read_q_r == 1
                                     //|| ext_write_q_r == 1
                                    )
                                    ? 
												mem_addr_tmp
                                    : 0 
                                    ;

  input wire [`DATA_SIZE0:0] ext_mem_data_in;
  output [`DATA_SIZE0:0] ext_mem_data_out;
  wire [`DATA_SIZE0:0] ext_mem_data_out = 
//                                    (
////                                     ext_read_q == 1 || 
//                                     ext_write_q_r == 1
//                                    )
//                                    ? 
												mem_data_tmp
//                                    : `ADDR_SIZE'h zzzz_zzzz_zzzz_zzzz
                                    ;
            

reg [7:0] mem_op_timeout;



always @(/*pos*/negedge clk) begin
  
//  clk_oe = ~clk_oe;
  
  if(clk_oe == 0) begin
  
    //thrd_cmd_r <= 0;
	 
  end else begin
    
  if(rst_in == 1) begin 
    rst_out <= 1;
	 
    bus_busy_r <= 1'b 1;
	 
//	 clk_oe = 1;

    cpu_num <= 0;
    cpu_num_a <= 0;
    cpu_num_na <= CPU_QUANTITY;
    
    data_r <= 0; 
    
    state_ctl <= `CTL_RESET_WAIT;
    
    ext_cpu_index_r <= 0;
    cpu_q_r <= 0;
    
//	 init_r = 1;
    ext_rst_b_r <= 1;
    
	 mem_data_tmp <= 0;
    mem_addr_tmp <= 0;
    mem_rd <= 0;
    mem_wr <= 0;
    
    new_cpu_restarted <= 0;
    
    cpu_msg_r <= 0; 
    
    thrd_cmd_r <= `THREAD_CMD_NULL;
//    thrd_cmd_r = `THREAD_CMD_GET_NEXT_STATE;

    addr_chan_to_op_r <= 0; 
	 
	 ext_rw_halt_r <= 0;
	 rw_halt_r <= 0;
	 
	 next_thread_r <= 0;
	 
	 ext_bus_allow <= 0;
	 
	 mem_op_timeout <= 0;
  end else /*if(ext_rst_e == 1)*/ begin
//    if(read_q == 1 || write_q == 1)
//      halt_q = 1;


/**  test! *
          ext_read_q_r = 0;
          ext_write_q_r = 0;
			 
			 rw_halt_r = 0;
			 ext_rw_halt_r = 0;

          cpu_msg_r = 0; //`CPU_MSG_SIZE'h zzzz_zzzz;
/**/

			 
          /**
          if(mem_rd == 1 || mem_wr == 1) begin
            if(rw_halt_in == 1) begin
              mem_rd = 0;
              mem_wr = 0;
				  ext_rw_halt_r = 1;
              state_ctl = `CTL_CPU_LOOP;
				end else
            if(ext_rw_halt_in == 1) begin
              mem_rd = 0;
              mem_wr = 0;
				  rw_halt_r = 1;
              state_ctl = `CTL_CPU_LOOP;
            end else begin
              ext_rw_halt_r = 0;
              rw_halt_r = 0;
              state_ctl = `CTL_MEM_WORK;
            end
          end 
          /**/
			 
//          else
//          if(dispatcher_q == 1) begin
//            
//          end else begin
//            state_ctl = `CTL_MEM_WORK;
//          end


/**
          if(next_thread_r == 1) begin //thrd_cmd_r == `THREAD_CMD_GET_NEXT_STATE) begin
			   next_thread_r = 0;
            //thrd_cmd_r = `THREAD_CMD_NULL;
          end
/**/


    case(state_ctl)
      `CTL_RESET_WAIT: begin
		  ext_bus_allow <= 1'b 0;
		  
		  bus_busy_r <= 1'b 0;

		    // VV test!
          ext_read_q_r <= 0;
          ext_write_q_r <= 0;
			 
			 rw_halt_r <= 0;
			 ext_rw_halt_r <= 0;

          cpu_msg_r <= 0; 
			 // AA test!
			 
			 next_thread_r <= 0;
			 
        if(cpu_msg_in == `CPU_R_RESET) begin 
          ext_cpu_index_r <= ext_cpu_index_r + 1;
          addr_out_r  <= 0; ;
        end
        
        ext_rst_b_r <= 0;
		  
        if(ext_rst_e == 1) begin
		    rst_out <= 0;
			 
          ext_cpu_index_r <= 0;
          data_r <= 0;  
          state_ctl <= `CTL_CPU_LOOP;
        end
      end
      
		
      `CTL_CPU_LOOP: begin
		/**/
        read_dn_r <= 1'b 0; 
        write_dn_r <= 1'b 0; 

		    // VV test!
          ext_read_q_r <= 0;
          ext_write_q_r <= 0;
			 
			 rw_halt_r <= 0;
			 ext_rw_halt_r <= 0;

          cpu_msg_r <= 0; 
			 // AA test!
			 
			 next_thread_r <= 0;
			 
        if(bus_busy_r == 0) begin
          if(ext_bus_q == 1'b 1) begin
            state_ctl <= `CTL_CPU_EXT_BUS;
				
			 end else begin
            if(cpu_num_na > 0 && new_cpu_restarted == 0) begin
              ext_cpu_index_r <= `CPU_NONACTIVE;
              new_cpu_restarted <= 1;
            end else begin
              if(cpu_num >= cpu_num_a-1) begin
                cpu_num <= 0;
                ext_cpu_index_r <= 0 | `CPU_ACTIVE;
              end else begin
                cpu_num <= cpu_num + 1;
                ext_cpu_index_r <= (cpu_num + 1) | `CPU_ACTIVE;
//                cpu_num <= cpu_num_plus_1; //cpu_num + 1;
//                ext_cpu_index_r <= cpu_num_plus_1 | `CPU_ACTIVE; //(cpu_num + 1) | `CPU_ACTIVE;
              end
//            ext_cpu_index_r <= cpu_num | `CPU_ACTIVE;
              new_cpu_restarted <= 0;
            end
            addr_out_r <= next_proc; 
                  
            cpu_q_r <= 1;
                  
            state_ctl <= `CTL_CPU_CMD;
          end
        end else begin
		    bus_busy_r <= 1'b 0;
		  end
		/**/
      end
      
		
      `CTL_CPU_CMD: begin
		  cpu_q_r <= 0;
		  
		    // VV test!
 //         ext_read_q_r = 0;
 //         ext_write_q_r = 0;
			 
			 rw_halt_r <= 0;
			 ext_rw_halt_r <= 0;

//          cpu_msg_r = 0; 
			 // AA test!
			 
        addr_out_r <= 0; 
        
        if(
          read_q == 1 &&
          mem_rd == 0 &&
          mem_wr == 0 //&&
			 //rw_halt_in == 0
        ) begin
//!!!			 addr_out_r = addr_in;
			 
          mem_addr_tmp <= addr_in;
          mem_rd <= 1;
          mem_wr <= 0;
			 
          ext_read_q_r <= 1;
			 ext_write_q_r <= 0;
			 
			 cpu_msg_r <= 0; 
			 
			 next_thread_r <= 0;
			 
			 mem_op_timeout <= 0;
			 state_ctl <= `CTL_MEM_WORK;
        end else 
        if(
          write_q == 1 &&
          mem_rd == 0 &&
          mem_wr == 0 //&&
			 //rw_halt_in == 0
        ) begin
//!!!			 addr_out_r = addr_in;
			 
          mem_addr_tmp <= addr_in;
          mem_data_tmp <= data_in;
          mem_rd <= 0;
          mem_wr <= 1;
			 
			 ext_write_q_r <= 1;
			 ext_read_q_r <= 0;
			 
			 cpu_msg_r <= 0; 
			 
			 next_thread_r <= 0;
			 
			 mem_op_timeout <= 0;
			 state_ctl <= `CTL_MEM_WORK;
        end else 
        if(ext_cpu_e == 1) begin
//!!          ext_cpu_index_r = 0;
          ext_read_q_r <= 0;
			 ext_write_q_r <= 0;
			 
			 cpu_msg_r <= 0;  // test!
          
            case(cpu_msg_in) //data_wire)
              `CPU_R_START: begin
                cpu_num_na <= cpu_num_na - 1;
                cpu_num_a <= cpu_num_a + 1;
          
                cpu_num <= cpu_num + 1;

                new_cpu_restarted <= 0;

					 next_thread_r <= 1;
//                thrd_cmd_r = `THREAD_CMD_GET_NEXT_STATE;

                state_ctl <= `CTL_CPU_LOOP;
              end
            
              `CPU_R_END: begin
                cpu_num_a <= cpu_num_a - 1;
                cpu_num_na <= cpu_num_na + 1;
					 
					 next_thread_r <= 0;
					 state_ctl <= `CTL_CPU_LOOP;
              end
            
              `CPU_R_FORK_DONE: begin
				    next_thread_r <= 1;
//                thrd_cmd_r = `THREAD_CMD_GET_NEXT_STATE;
                
                //cpu_msg_r <= 0;
					 state_ctl <= `CTL_CPU_LOOP;
              end
				  
`ifdef PAUSE_PROC_ENABLE
				  `CPU_R_BREAK_THREAD: begin
                addr_thread_to_op_r <= addr_in;
                addr_chan_to_op_r <= data_in;

                thrd_cmd_r <= `THREAD_CMD_PAUSE;

                next_thread_r <= 1;
						
						state_ctl <= `CTL_CPU_LOOP;
              end
`endif

				  default: begin
				    next_thread_r <= 0;

                //if(dispatcher_q == 1) begin
                  state_ctl <= `CTL_CPU_LOOP;
                //end else
                ////if(mem_rd == 1 || mem_wr == 1) 
                //begin
                //  state_ctl <= `CTL_MEM_WORK;
                //end
              end
            
            endcase
//          if(mem_rd == 1 || mem_wr == 1) begin
//            state_ctl = `CTL_MEM_WORK;
//          end else

//          if(dispatcher_q == 1) begin
//            state_ctl <= `CTL_CPU_LOOP;
//          end else
//			 //if(mem_rd == 1 || mem_wr == 1) 
//          begin
//            state_ctl <= `CTL_MEM_WORK;
//          end
          
        end
		  //else
		  //if(run_next_cpu_from_loop == 1) begin
		  //  state_ctl <= `CTL_CPU_LOOP;
		  //end
        else begin
		  
		    ext_read_q_r <= 0;
			 ext_write_q_r <= 0;
			 
			 next_thread_r <= 0;

            if(thrd_cmd_r == `THREAD_CMD_NULL) begin
				  cpu_msg_r <= 0; 
				  
              case(cpu_msg_in) //data_wire)  				  
                `CPU_R_STOP_THRD: begin
                  addr_thread_to_op_r <= addr_in;
                  addr_chan_to_op_r <= data_in;
						
                  thrd_cmd_r <= `THREAD_CMD_STOP;
                end
                
                `CPU_R_FORK_THRD: begin
                  addr_thread_to_op_r <= addr_in;
                  addr_chan_to_op_r <= data_in;
						
                  thrd_cmd_r <= `THREAD_CMD_RUN;
                end
                
					 `CPU_R_CHAN_SET: begin
                  addr_thread_to_op_r <= addr_in;
                  addr_chan_to_op_r <= data_in;
						
                  thrd_cmd_r <= `THREAD_CMD_CHAN_SET;
					 end
					 
					 `CPU_R_CHAN_GET: begin
                  addr_thread_to_op_r <= addr_in;
                  //addr_chan_to_op_r <= data_in;
						
                  thrd_cmd_r <= `THREAD_CMD_CHAN_GET;
					 end
					 
					 `CPU_R_THREAD_ADDRESS: begin
                  addr_thread_to_op_r <= addr_in;
                  addr_chan_to_op_r <= data_in;
						
                  thrd_cmd_r <= `THREAD_CMD_THRD_ADDR;
					 end
					 
                    //.addr_in(addr_thread_to_op_r),
                    //.data_in(addr_chan_to_op),

					 
				    //`CPU_R_BREAK_THREAD: begin
                  //next_thread_r <= 0;
                //  thrd_cmd_r <= `THREAD_CMD_NULL;
                //end
                
              endcase
            end else begin
				  case(thrd_cmd_r)
					 `THREAD_CMD_RUN: begin
					   cpu_msg_r <= `CPU_R_FORK_DONE;
					  
					   thrd_cmd_r <= `THREAD_CMD_NULL;
					 end
					
					 `THREAD_CMD_STOP: begin
					   cpu_msg_r <= `CPU_R_STOP_DONE;
					  
					   thrd_cmd_r <= `THREAD_CMD_NULL;
					 end
					
					 `THREAD_CMD_CHAN_SET,
					 `THREAD_CMD_CHAN_GET
					 : begin
					   //cpu_msg_r <= `CPU_R_STOP_DONE;
					   thrd_cmd_r <= `THREAD_CMD_NULL;
					 end
					
`ifdef PAUSE_PROC_ENABLE
					 `THREAD_CMD_PAUSE
					 : begin
					   //cpu_msg_r <= `CPU_R_STOP_DONE;
					   thrd_cmd_r <= `THREAD_CMD_NULL;
						
						state_ctl <= `CTL_CPU_LOOP;
					 end
`endif
					
					 `THREAD_CMD_THRD_ADDR
					 : begin
					   //cpu_msg_r <= `CPU_R_STOP_DONE;
					   thrd_cmd_r <= `THREAD_CMD_NULL;
						
						state_ctl <= `CTL_CHAN_RESULT_LOOP;
					 end
				  endcase
				end
        end
      end
		
		
		`CTL_CHAN_RESULT_LOOP: begin
		  if(chan_thread_result_op_in != 0 /*`CHAN_OP_NULL*/) begin
		    cpu_msg_r <= chan_thread_result_op_in;
			 data_r <= chan_data_in;
			 
			 bus_busy_r <= 1;
			 
		    state_ctl <= `CTL_CPU_LOOP;
		  end
		end
      
		
      `CTL_MEM_WORK: begin			
		  
		    // VV test!
          ext_read_q_r <= 0;
          ext_write_q_r <= 0;
			 
//			 rw_halt_r = 0;
//			 ext_rw_halt_r = 0;

          cpu_msg_r <= 0; 
			 // AA test!
			 
			 next_thread_r <= 0;
			 
/**/
		  if(rw_halt_in == 1) begin
          mem_rd <= 0;
          mem_wr <= 0;
			 
          ext_rw_halt_r <= 1;
			 rw_halt_r <= 0; // test!
			 
			 bus_busy_r <= 0; //
          state_ctl <= `CTL_MEM_WORK_FINISH; //`CTL_CPU_LOOP;
        end else
		  if(ext_rw_halt_in == 1) begin
          mem_rd <= 0;
          mem_wr <= 0;
			 
			 rw_halt_r <= 1;       //!!
			 ext_rw_halt_r <= 0; // test! 
			 
			 bus_busy_r <= 0; //
          state_ctl <= `CTL_MEM_WORK_FINISH; //`CTL_CPU_LOOP;
        end else 
		  
        if(mem_op_timeout > 50) begin
		    mem_op_timeout <= 0;
			 
			 bus_busy_r <= 0; //
			 state_ctl <= `CTL_MEM_WORK_FINISH;
			 
          ext_rw_halt_r <= 1;
			 rw_halt_r <= 1;     //!!
        end else

		  begin
          ext_rw_halt_r <= 0;
			 rw_halt_r <= 0;     //!!
			 
			 mem_op_timeout <= mem_op_timeout + 1;
//        end // test
/**/
          /** // test
          if(mem_rd == 1 || mem_wr == 1) begin
            if(bus_busy_r == 1) begin
              bus_busy_r <= 1'b 0; //z;
              mem_rd <= 0;
              mem_wr <= 0;
//              halt_q = 0;
  //            if(dispatcher_q == 1) begin
  //              state_ctl = `CTL_CPU_LOOP;
  //            end
            end
          end
          /**/  // test
  //        else begin
  //            if(dispatcher_q == 1) begin
  //              state_ctl = `CTL_CPU_LOOP;
  //            end
  //        end
  
          if(mem_rd == 1) begin

            if(bus_busy_r == 1) begin
              bus_busy_r <= 1'b 0; //z;
              mem_rd <= 0;
              //mem_wr <= 0;
//              halt_q = 0;
  //            if(dispatcher_q == 1) begin
  //              state_ctl = `CTL_CPU_LOOP;
  //            end
            end else

            if(ext_read_dn == 1) begin
              addr_out_r <= ext_mem_addr_in; //mem_addr_tmp;
              data_r <= ext_mem_data_in; //mem[mem_addr_tmp];
              read_dn_r <= 1;
              //bus_busy_r <= 0;
              bus_busy_r <= 1;
              
				  mem_rd <= 0;
				  
				  mem_addr_tmp <= 0; //!!!
				  
              //if(dispatcher_q == 1) begin
                state_ctl <= `CTL_MEM_WORK_FINISH; //`CTL_CPU_LOOP;
              //end

//            end else
//            begin
//              ext_read_q_r = 1;
            end
          end 
          else
          if(mem_wr == 1) begin

            if(bus_busy_r == 1) begin
              bus_busy_r <= 1'b 0; //z;
              //mem_rd <= 0;
              mem_wr <= 0;
//              halt_q = 0;
  //            if(dispatcher_q == 1) begin
  //              state_ctl = `CTL_CPU_LOOP;
  //            end
            end else

            if(ext_write_dn == 1) begin
              addr_out_r <= ext_mem_addr_in; //mem_addr_tmp;
              data_r <= ext_mem_data_in; //mem_data_tmp;
              write_dn_r <= 1;
              //bus_busy_r <= 0;
              bus_busy_r <= 1;
				  
				  mem_addr_tmp <= 0;
				  mem_data_tmp <= 0;
				  
				  mem_wr <= 0;
              
              //if(dispatcher_q == 1) begin
                state_ctl <= `CTL_MEM_WORK_FINISH; //`CTL_CPU_LOOP;
              //end

//            end else
//            begin
//              ext_write_q_r = 1;
            end
          end
          //else
          //begin
          //  if(dispatcher_q == 1) begin
          //    state_ctl <= `CTL_CPU_LOOP;
          //  end
          //end

        end // test

      end

		
		`CTL_MEM_WORK_FINISH: begin
          ext_rw_halt_r <= 0;
			 rw_halt_r <= 0;     //!!
			 
			 mem_op_timeout <= 0;
//          if(
//			   read_dn_r == 1 ||
//			   write_dn_r == 1
//			 ) begin
              addr_out_r <= 0;
              data_r <= 0;
				  
              write_dn_r <= 0;
				  read_dn_r <= 0;
              bus_busy_r <= 0;

            //if(ext_cpu_e == 1) begin
				  state_ctl <= `CTL_CPU_LOOP;
            //end //else
		end
		
		
      `CTL_CPU_EXT_BUS: begin
        if(ext_bus_q == 1'b 1) begin
          ext_bus_allow <= 1'b 1;
			 
        end else begin
          ext_bus_allow <= 1'b 0;
          
          //if(dispatcher_q == 1) begin
            state_ctl <= `CTL_CPU_LOOP;
          //end
        end
      end
    
    endcase
    
  end
  
  end
  
end


endmodule
