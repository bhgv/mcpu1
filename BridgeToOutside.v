


`include "sizes.v"
`include "states.v"
`include "inter_cpu_msgs.v"
`include "misc_codes.v"



//`define CPU_IND_REL_INSIDE_MAIN_BLOCK


module BridgeToOutside (
            clk, 
				clk_oe,
				clk_2f,
				
            state,
            
            base_addr,
            base_addr_data,
            command,
            
//            halt_q,
            cpu_ind_rel,
            rw_halt,
            
            bus_busy_in,
            bus_busy_out,
				
            addr_in,
				addr_out,
            data_in,
            data_out,
            read_q,
            write_q,
            read_dn,
            write_dn,
//            read_e,
//            write_e,
            
            src1,
            src0,
            dst,
            dst_h,
            cond,
				
				chan_op,
            
            disp_online,
            
            next_state,
            
            no_data_new,
		      no_data_tick,
		      no_data_exit_and_wait_begin,
				
				thread_escape,
            
            rst,
           
				init,
            ext_rst_b,
            ext_rst_e,
            
            ext_cpu_index,
            
            ext_next_cpu_q,
            ext_next_cpu_e,

            ext_dispatcher_q,
            
//            ext_rw_halt,
            
            int_cpu_msg_in,
            int_cpu_msg_out,
            ext_cpu_msg,
				ext_cpu_msg_in,
            
            ext_read_q,
            ext_write_q
            
            );
  input wire clk;
  
  input wire clk_2f;
  
  input wire [`STATE_SIZE0:0] state;
  input wire [31:0] command;
  
  input wire rw_halt;
  
  input wire no_data_new;
  input wire no_data_tick;
  output reg no_data_exit_and_wait_begin;
//  wire no_data_exit_and_wait_begin_stim = 
//											(no_data_cntr >= `NO_DATA_COUNTER_MAX)
//											//&& no_data_exit_and_wait_begin == 1'b 0
//											;
  
  
  wire [3:0] cmd_code = command[31:28];
  

  output [`ADDR_SIZE0:0] base_addr;
  reg [`ADDR_SIZE0:0] base_addr_r;
  wire [`ADDR_SIZE0:0] base_addr = base_addr_r;
  
  output [`ADDR_SIZE0:0] base_addr_data;
  reg [`ADDR_SIZE0:0] base_addr_data_r;
  wire [`ADDR_SIZE0:0] base_addr_data = base_addr_data_r;
  
  
  output reg [1:0] cpu_ind_rel;
  
  
  input [`ADDR_SIZE0:0] addr_in;
  output [`ADDR_SIZE0:0] addr_out;
  reg [`ADDR_SIZE0:0] addr_r;
  wire [`ADDR_SIZE0:0] addr_in; // = addr_r;
  wire [`ADDR_SIZE0:0] addr_out = addr_r;
//                                cpu_msg_r == `CPU_R_BREAK_THREAD
//										  ? base_addr_r - `THREAD_HEADER_SPACE //addr_r
//										  : 0
//										  ;
  
  input wire read_q;
  input wire  write_q;

  output bus_busy_out;
  reg bus_busy_r;
  wire bus_busy_out = bus_busy_r;
  
  output [`DATA_SIZE0:0] data_out;
  input [`DATA_SIZE0:0] data_in;
  reg [`DATA_SIZE0:0] data_r;
  wire [`DATA_SIZE0:0] data_in; // = data_r;
  wire [`DATA_SIZE0:0] data_out = data_r;
//                                cpu_msg_r == `CPU_R_BREAK_THREAD &&
//										  base_addr_data_r != base_addr_r
//										  ? base_addr_data_r - `THREAD_HEADER_SPACE//data_r
//										  : 0
//										  ;
  
//  assign data = write_q==1 ? dst_r : 32'h z;
  
  input  read_dn;
//  reg read_dn_r;
//  wire read_dn = read_dn_r;
  
  input  wire write_dn;
//  output reg read_e;
//  output reg write_e;
  

  input  wire [`DATA_SIZE0:0] src1;
  input  wire [`DATA_SIZE0:0] src0;
  input  wire [`DATA_SIZE0:0] dst;
  input  wire [`DATA_SIZE0:0] dst_h;

  input  wire [`DATA_SIZE0:0] cond;
  
  
  output disp_online;
  reg disp_online_r;
  wire disp_online = disp_online_r;
  
  
  output  next_state;
  reg next_state_r;
  wire next_state = next_state_r;
 
  output rst;
  reg rst_r;
  wire rst = rst_r;
  reg [2:0] rst_state;
  
  
  input wire init;
  
  input wire ext_rst_b;
  output ext_rst_e;
  reg ext_rst_e_r;
  wire ext_rst_e = ext_rst_e_r;
  
  input [`DATA_SIZE0:0] ext_cpu_index;
//!!  reg [`DATA_SIZE0:0] cpu_index_itf;
  wire [`DATA_SIZE0:0] ext_cpu_index //!!! = 
//                              (
//                                read_q == 1 ||
//                                write_q == 1
//                              ) ?
//                              cpu_index_r :
                              //!!! cpu_index_itf
										;

  wire [`DATA_SIZE0:0] cpu_index_int;
  
  reg [`DATA_SIZE0:0] cpu_index_r;
  wire [`DATA_SIZE0:0] cpu_index = cpu_index_r;
  reg cpu_index_set_r;
  
  input wire ext_next_cpu_q;
  output ext_next_cpu_e;
  reg ext_next_cpu_e_r;
  wire ext_next_cpu_e = ext_next_cpu_e_r;
  
  wire ext_next_cpu_e_stim =
            (
//              read_q == 1 || write_q == 1 
              rw_halt == 1 || read_dn == 1 || write_dn == 1 
				  || chan_op == 1
            )
            && disp_online_r == 1
            //&& ~ext_next_cpu_e_r
            ;

  
  input bus_busy_in;
//  reg ext_bus_busy_r;
  wire bus_busy_in; // = ext_bus_busy_r;
    
  
  output ext_dispatcher_q;
  reg ext_dispatcher_q_r;
  wire ext_dispatcher_q = ext_dispatcher_q_r;
  
  
  input [`CPU_MSG_SIZE0:0] int_cpu_msg_in;
  output [`CPU_MSG_SIZE0:0] int_cpu_msg_out;
//  reg [`CPU_MSG_SIZE0:0] int_cpu_msg_r;
//  wire [`CPU_MSG_SIZE0:0] int_cpu_msg_out = int_cpu_msg_r;
  
//  reg [`CPU_MSG_SIZE0:0] cpu_msg_tmp;
  
  input wire [`CPU_MSG_SIZE0:0] ext_cpu_msg_in;

  output [`CPU_MSG_SIZE0:0] ext_cpu_msg;
  reg [`CPU_MSG_SIZE0:0] cpu_msg_r;
  wire [`CPU_MSG_SIZE0:0] cpu_msg = cpu_msg_r;
  wire [`CPU_MSG_SIZE0:0] ext_cpu_msg = //cpu_msg_r;
                    int_cpu_msg_in != 0
                    ? int_cpu_msg_in
                    : cpu_msg_r
                    ;
/**
                    ( int_cpu_msg_in == `CPU_R_FORK_THRD
                      ? `CPU_R_FORK_THRD
                      : ( int_cpu_msg_in == `CPU_R_STOP_THRD
                          ? `CPU_R_STOP_THRD
                          : cpu_msg_r
                        )
                    )
                    ;


/**/
  
/* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! */
  wire [`CPU_MSG_SIZE0:0] int_cpu_msg_in;
  wire [`CPU_MSG_SIZE0:0] int_cpu_msg_out =  //ext_cpu_msg_in;
                              (
                                ext_cpu_msg_in == `CPU_R_FORK_DONE ||
                                ext_cpu_msg_in == `CPU_R_STOP_DONE ||
                                ext_cpu_msg_in == `CPU_R_CHAN_NO_RESULTS ||
                                ext_cpu_msg_in == `CPU_R_CHAN_RES_RD ||
                                ext_cpu_msg_in == `CPU_R_CHAN_RES_WR //||
                              )								
                              ? ext_cpu_msg_in
                              :  0 
                          ;

/**
								     (
                              ext_cpu_msg_in == `CPU_R_FORK_DONE
                              ? `CPU_R_FORK_DONE
                              : ( ext_cpu_msg_in ==`CPU_R_STOP_DONE
                                  ? `CPU_R_STOP_DONE
                                  :  0 
                                )
                            )
                          ;

/**/
  
  output ext_read_q;
  wire ext_read_q    = (state == `READ_COND ||
                        state == `READ_COND_P ||
                        state == `READ_SRC1 ||
                        state == `READ_SRC1_P ||
                        state == `READ_SRC0 ||
                        state == `READ_SRC0_P ||
                        state == `READ_DST ||
                        state == `START_READ_CMD ||
                        state == `START_READ_CMD_P ||
                        state == `READ_MEM_SIZE_1
                        ) &&
                        disp_online_r == 1 
//                        && (!ext_next_cpu_e === 1)
                        ? read_q 
                        : 1'b 0; //z;
  output ext_write_q;
  wire ext_write_q   = (state == `WRITE_REG_IP ||
                        state == `WRITE_DST    ||
                        state == `WRITE_DST_P  ||
                        state == `WRITE_SRC1   ||
                        state == `WRITE_SRC0   ||
                        state == `WRITE_COND
                        ) &&
                        disp_online_r == 1 
//                        && (!ext_next_cpu_e === 1)
                        ? write_q 
                        : 1'b 0; //z;

  input wire clk_oe;
  
  input wire chan_op;
  
  
  
`ifdef PAUSE_PROC_ENABLE
  reg [7:0] no_data_cntr;
`endif

  wire thread_escape_stim = //0;
`ifdef PAUSE_OR_CHAN_OP_TAIL_CUTOFF_ENABLE
  /**/
                        //state != 0 &&
//								rst_state >= 7 &&						
`ifdef PAUSE_PROC_ENABLE
								ext_cpu_msg_in == `CPU_R_BREAK_THREAD &&
`else
//								ext_cpu_msg_in == `CPU_R_THREAD_ADDRESS &&
								ext_cpu_msg_in == `CPU_R_CHAN_NO_RESULTS &&
`endif

								addr_in == base_addr_r - `THREAD_HEADER_SPACE &&
								(
								  data_in == base_addr_data_r - `THREAD_HEADER_SPACE 
//								  || (
//								       base_addr_data_r == base_addr_r &&
//										 data_in == 0
//								  )
                        ) &&
								
//                        ext_cpu_index[30:0] > cpu_index/*_r*/[30:0]
								cpu_ind_rel == 2'b 10 &&
								rst_state >= 7

								//no_data_exit_and_wait_begin == 1'b 0 //&&
								//thread_escape == 1'b 0 //&&
`else
                        0
`endif
								;
  /**/
  output reg thread_escape; // = thread_escape_stim;

  
//  wire is_ext_cpu_index_active = (ext_cpu_index & `CPU_ACTIVE) === `CPU_ACTIVE;
//  wire is_cpu_index_active = (cpu_index_r & `CPU_ACTIVE) === `CPU_ACTIVE;
//  wire is_ext_cpu_index_lt = ext_cpu_index[30:0] < cpu_index_r[30:0];
  
//  reg init_int;
  
  

  
/**/
  CpuIndexManager cpu_idx_mngr(
    .clk(clk),
    .clk_oe(clk_oe),
  
    .cpu_index_in(ext_cpu_index), //cpu_index_r), //
    .cpu_index_out(cpu_index_int),
  
    .bus_busy_in(bus_busy_in),
    .ext_next_cpu_q(ext_next_cpu_q),
    .ext_cpu_msg_in(ext_cpu_msg_in),
    .ext_cpu_index(ext_cpu_index),
    .state(state),
  
    .cpu_index_set(cpu_index_set_r),
  
    .rst(cpu_index_set_r) //ext_rst_b)
  );
/**/
  
  
/**/
`ifndef CPU_IND_REL_INSIDE_MAIN_BLOCK
  always @(posedge clk) begin //ext_next_cpu_q or posedge ext_next_cpu_e or posedge rst) begin
  
        if(rst == 1) begin
		    cpu_ind_rel <= 0;
        end else
        if(ext_next_cpu_q == 1) begin
        
          if(ext_cpu_index[30:0] < cpu_index/*_r*/[30:0]) begin
            cpu_ind_rel <= 2'b01;
          end else
          if(ext_cpu_index[30:0] > cpu_index/*_r*/[30:0]) begin
            cpu_ind_rel <= 2'b10;
          end else
          if(ext_cpu_index == cpu_index/*_r*/) begin
            cpu_ind_rel <= 2'b11;
//          end else begin
//            cpu_ind_rel = 0;
          end


/*
//      if(ext_next_cpu_q == 1) begin 
          if(ext_cpu_index == cpu_index_r) begin
//          ext_next_cpu_e_r = 1;
          end else if(ext_cpu_index == `CPU_NONACTIVE) begin
        
            if((cpu_index_r & `CPU_ACTIVE) == `CPU_ACTIVE) begin
              cpu_index_r = cpu_index_r + 1;
            end else begin
              cpu_index_r = cpu_index_r - 1;
            end
          end  
//      end
*/
          
        end else if(ext_next_cpu_e == 1) begin
          cpu_ind_rel <= 0;
			 
			 //disp_online_r = 0; //!!!
//			 ext_next_cpu_e_r = 1'b z;
        end
  end
`endif
/**/
  

/**
  always @(negedge clk) begin
    if(rst_state == 3) begin
      cpu_index_r <= ext_cpu_index; //data;
    end else
    if(rst_state >= 7) begin //!!!!!!!!!!!!!!!!!!!
	   cpu_index_r <= cpu_index_int; //!!!!!!!!!!!!!!!!!!!
		
      thread_escape <= thread_escape_stim;
    end
  end
/**/

  always @(negedge clk_2f) begin
    if(rst_state == 3) begin
      cpu_index_r <= ext_cpu_index; //data;
    end else
    if(rst_state >= 7) begin
      cpu_index_r <= cpu_index_int;
//	 thread_escape <= thread_escape_stim;
    end
  end
  
  
  always @(posedge clk) begin

`ifdef PAUSE_OR_CHAN_OP_TAIL_CUTOFF_ENABLE
    //if(rst_state >= 7) begin //!!!!!!!!!!!!!!!!!!!
//!!!	   cpu_index_r <= cpu_index_int; //!!!!!!!!!!!!!!!!!!!
	 thread_escape <= thread_escape_stim;
    //end
`endif
	 
//	 thread_escape <= thread_escape_stim;
//	 thread_escape <= thread_escape | thread_escape_stim;
	 
//    clk_oe = ~clk_oe;
	 if(clk_oe == 0) begin
	 
		 addr_r <= 0; 
		 data_r <= 0; 
		 
		 //next_state_r <= 1'b 0;
		 
		 bus_busy_r <= 1'b 0; //z;
		 
		 if(ext_next_cpu_e_r == 1) begin
	      ext_next_cpu_e_r = 1'b 0; //z;
			disp_online_r <= 0;
		 end 
		 
//		 no_data_exit_and_wait_begin <= 0;
		 
		 //if(next_state_r == 1'b 1) begin
		 //  next_state_r <= 1'b 0;
		 //end else
		 
		 /*
		 if(
         ext_cpu_msg_in == `CPU_R_BREAK_THREAD &&
			
         addr_in == base_addr_r &&
         data_in == base_addr_data_r &&
			
			cpu_ind_rel == 2'b 01 &&
			
         no_data_exit_and_wait_begin == 1'b 0 &&
         thread_escape == 1'b 0 //&&
			//next_state_r == 1'b 0 
		 ) begin
			thread_escape <= 1'b 1;
			
			next_state_r <= 1'b 1;
		 end else
		 */
		 
		 
		 //if(
		 /**
         ext_cpu_msg_in == `CPU_R_BREAK_THREAD &&
			
         addr_in == base_addr_r &&
         data_in == base_addr_data_r &&
			
			cpu_ind_rel == 2'b 10 &&
			
         no_data_exit_and_wait_begin == 1'b 0 &&
         thread_escape == 1'b 0 //&&
			//next_state_r == 1'b 0 
		 /**/
			  //thread_escape == 1'b 1
		 //) begin
			//thread_escape <= 1'b 1;
			//no_data_exit_and_wait_begin <= 1'b 1;
			
			//next_state_r <= 1'b 1;
		 //end //else

//		 if(rst_state >= 7) begin


`ifdef PAUSE_PROC_ENABLE
//			if(no_data_exit_and_wait_begin_stim == 1'b 0)
//			begin
		 if(no_data_new == 1'b 1) begin
		   no_data_cntr <= 0;
			
			no_data_exit_and_wait_begin <= 1'b 0;
		//	next_state_r <= thread_escape_stim; //1'b 0;
       end
		 else if(no_data_tick == 1'b 1) begin
		   /**/
		   if(no_data_cntr >= `NO_DATA_COUNTER_MAX) begin
			  //no_data_cntr <= 0;
			  
			  no_data_exit_and_wait_begin <= 1'b 1;
			  
		//	  next_state_r <= thread_escape_stim; //0; //1;
			end else begin
			/**/
			  no_data_cntr <= no_data_cntr + 1;
			  
		//	  next_state_r <= thread_escape_stim; //1'b 0;
			  ////no_data_exit_and_wait_begin <= 1'b 0;
			end
       end 
		 //else begin
		   ////no_data_exit_and_wait_begin <= 1'b 0;

		//no_data_exit_and_wait_begin <= no_data_exit_and_wait_begin | no_data_exit_and_wait_begin_stim;
		
      //if(no_data_exit_and_wait_begin_stim == 1'b 1 && next_state_r == 1) begin
      //  no_data_cntr <= 0;
      //  next_state_r <= 1'b 0;
      //end else

`endif

     //if(rst_state >= 7) begin
       next_state_r <= thread_escape_stim; //1'b 0;
     //end
//			next_state_r <= thread_escape_stim | no_data_exit_and_wait_begin_stim; //1'b 0;
       //end
		 
		 /** 
		 else begin // no_data_exit_and_wait_begin_stim == 1
//		   if(no_data_exit_and_wait_begin == 1'b 1) begin
				no_data_cntr <= 0;
//				next_state_r <= 1'b 1;
//			end else begin
//				no_data_exit_and_wait_begin <= 1'b 1;
//				next_state_r <= 1'b 0;
//			end
         next_state_r <= 1; //~no_data_exit_and_wait_begin;
			no_data_exit_and_wait_begin <= 1'b 1;
		 end
		 /**/
		 
//		 end // rst_state >= 7
//		 else begin
//		   next_state_r <= 0;
//		 end

//			next_state_r <= thread_escape_stim; //1'b 0;

//		 next_state_r <= thread_escape_stim | no_data_exit_and_wait_begin_stim;

    end else begin

    if(ext_rst_b == 1) begin  // begin of RESET
`ifdef CPU_IND_REL_INSIDE_MAIN_BLOCK
      cpu_ind_rel <= 0;
`endif
//      cpu_msg_tmp <= 0;
      
      base_addr_r <= 0;
		
		cpu_msg_r <= 0; 
		
		ext_next_cpu_e_r <= 0;
		
      next_state_r <= 1'b 0;
		
      rst_state <= 1;
		
		rst_r <= 0;
		ext_rst_e_r <= 0;
		
		cpu_index_set_r <= 0;
		
		no_data_exit_and_wait_begin <= 0;

`ifdef PAUSE_PROC_ENABLE
		no_data_cntr <= 0;
		thread_escape <= 0;
`endif
		

//      init_int = 1;
      
    end else if(rst_state < 7 /*&& init === 1 /*&& init_int == 1*/) begin // == 1) begin

/**/
      if(ext_next_cpu_q == 1 && ext_cpu_index == cpu_index_int/*_r*/) begin
        ext_next_cpu_e_r <= 1'b 1;
		  disp_online_r <= 0;  //!!!
	   end else begin
		  ext_next_cpu_e_r <= 1'b 0; //z;
      end 
/**/
      no_data_exit_and_wait_begin <= 0;
`ifdef PAUSE_PROC_ENABLE
      no_data_cntr <= 0;
      thread_escape <= 1'b 0;
`endif
		
		addr_r <= 0;
		data_r <= 0;
		
//`ifdef CPU_IND_REL_INSIDE_MAIN_BLOCK
//      cpu_ind_rel <= 0;
//`endif
		
      case(rst_state)
        1: begin
          ext_dispatcher_q_r <= 1'b 0; //z;
          
          disp_online_r <= 0;
			 
			 cpu_index_set_r <= 0;
          
          //no_data_exit_and_wait_begin <= 0;
			 
			 //thread_escape <= 0;

          rst_state <= 2;
        end
        
        2: begin
          if(state == `FINISH_END) begin
            rst_state <= 4;
          end else begin
            rst_state <= 3;
			   cpu_index_set_r <= 1;
          end
			 
          //no_data_exit_and_wait_begin <= 0;
			 
			 //thread_escape <= 0;

        end
        
        3: begin
          //!!! cpu_index_r <= ext_cpu_index; //data;
//			 cpu_index_set_r = 1;
			 cpu_index_set_r <= 0;
          //read_dn_r = 1;
          cpu_msg_r <= `CPU_R_RESET;
          
          //no_data_exit_and_wait_begin <= 0;
			 
			 //thread_escape <= 0;

          rst_state <= 4;
        end
        
        4: begin
          //read_dn_r = 1'b z;
//			 cpu_index_set_r = 0;
			 
			 cpu_msg_r <= 0; 
          
          rst_r <= 1;

          bus_busy_r <= 1'b 1;
          
          if(state != `FINISH_END) begin
//          end else begin
            ext_rst_e_r <= 1;
          end
          
          //no_data_exit_and_wait_begin <= 0;
			 
			 //thread_escape <= 0;

          rst_state <= 5;
        end
        
        5: begin
          ext_dispatcher_q_r <= 1;
          
          rst_r <= 0;
          ext_rst_e_r <= 0;
          //if(state !== `FINISH_END) begin
          //  ext_rst_e_r = 1;
          //end
			 
//			 cpu_index_r = cpu_index_int;

          //no_data_exit_and_wait_begin <= 0;
			 
			 //thread_escape <= 0;

          rst_state <= 7;
        end
        
      endcase

    end else 
//	 if(init !== 1 && init_int == 1) 
	 begin      // end of RESET
//	 if(init !== 1 && init_int == 0) begin      // end of RESET
    
      //cpu_msg_r = 0; 
		

/**/
`ifdef CPU_IND_REL_INSIDE_MAIN_BLOCK
        if(ext_next_cpu_q == 1) begin
        
          if(ext_cpu_index[30:0] < cpu_index/*_r*/[30:0]) begin
            cpu_ind_rel <= 2'b01;
          end else
          if(ext_cpu_index[30:0] > cpu_index/*_r*/[30:0]) begin
            cpu_ind_rel <= 2'b10;
          end else
          if(ext_cpu_index == cpu_index/*_r*/) begin
            cpu_ind_rel <= 2'b11;
//          end else begin
//            cpu_ind_rel = 0;
          end


/*
//      if(ext_next_cpu_q == 1) begin 
          if(ext_cpu_index == cpu_index_r) begin
//          ext_next_cpu_e_r = 1;
          end else if(ext_cpu_index == `CPU_NONACTIVE) begin
        
            if((cpu_index_r & `CPU_ACTIVE) == `CPU_ACTIVE) begin
              cpu_index_r = cpu_index_r + 1;
            end else begin
              cpu_index_r = cpu_index_r - 1;
            end
          end  
//      end
*/

        end else if(ext_next_cpu_e == 1) begin
          cpu_ind_rel <= 0;
			 
			 //disp_online_r = 0; //!!!
//			 ext_next_cpu_e_r = 1'b z;
        end
`endif
/**/


			/**
		   if(no_data_exit_and_wait_begin_stim == 1'b 1) begin
				no_data_cntr <= 0;
				next_state_r <= 1'b 1;
				no_data_exit_and_wait_begin <= 1'b 1;
			end
			else
			/**/


/**
      no_data_exit_and_wait_begin <= no_data_exit_and_wait_begin | no_data_exit_and_wait_begin_stim;
		
      if(no_data_exit_and_wait_begin_stim == 1'b 1) begin
        no_data_cntr <= 0;
        next_state_r <= 1'b 1;
      end else
/**/

      //if(/* bus_busy_r != 1 */ bus_busy_in != 1 ) 
		begin
//      end else begin

/*******
        if(disp_online_r == 1) begin
          if(
            read_q == 1 || write_q == 1 
				|| chan_op == 1
//            read_dn === 1 || write_dn === 1 || rw_halt === 1
          ) begin
            ext_next_cpu_e_r <= 1'b 1;
//            disp_online_r = 0;
          end 
			 
        end // if(disp_online_r == 1)
        else if(ext_next_cpu_e_r == 1) begin
          ext_next_cpu_e_r <= 1'b 0; //z;
//!!!            disp_online_r = 0;
        end
//!!!        end // if(disp_online_r == 1)
/**********/
        //ext_next_cpu_e_r <= ext_next_cpu_e_stim;

//        else if(ext_next_cpu_e_r === 1'b 1) begin
//          ext_next_cpu_e_r = 1'b 0; //z;
//			 disp_online_r = 0; //!!!
//        end

		  
        if(ext_next_cpu_q == 1 && 
		    //cpu_ind_rel == 2'b11
			 ext_cpu_index == cpu_index/*_r*/
        ) begin
          disp_online_r <= 1;
          
          case(state)
            `WAIT_FOR_START: begin
//				  cpu_msg_r <= 0;
				  
              //data_r
 //             if( ext_next_cpu_q === 1 ) begin
              cpu_msg_r <= `CPU_R_START;

//           end
                
              base_addr_r <= addr_in + `THREAD_HEADER_SPACE;
              
/**/
              if(data_in == 0 ) begin
                 base_addr_data_r <= addr_in + `THREAD_HEADER_SPACE;
              end else begin
                 base_addr_data_r <= data_in + `THREAD_HEADER_SPACE;
              end
/**/

              ext_next_cpu_e_r <= 1;
              next_state_r <= 1'b 1;
//              end  // if( ext_next_cpu_q === 1 )

//              disp_online_r = 1;
              
//              cpu_index_r = cpu_index_r | `CPU_ACTIVE;
              
//              ext_next_cpu_e_r = 1;

              //no_data_exit_and_wait_begin <= 1'b 0;
            end
            
            `READ_MEM_SIZE_1,
            `READ_DST,
            `READ_DST_P,
            `READ_COND, 
            `READ_COND_P,
            `READ_SRC1,
            `READ_SRC1_P,
            `READ_SRC0,
            `READ_SRC0_P,
            `START_READ_CMD,
            `START_READ_CMD_P: begin
                //ext_dispatcher_q_r <= 1;
                cpu_msg_r <= 0; 

                //ext_next_cpu_e_r <= ext_next_cpu_e_stim;

                //if(no_data_exit_and_wait_begin == 1) begin
                //  next_state_r <= 1;
                //end
            end
            
            `WRITE_DST,
            `WRITE_DST_P,
            `WRITE_REG_IP,
            `WRITE_DST,
            `WRITE_SRC1,
            `WRITE_SRC0,
            `WRITE_COND: begin
              //ext_dispatcher_q_r <= 1;
              cpu_msg_r <= 0; 

                //ext_next_cpu_e_r <= ext_next_cpu_e_stim;
            end
            
            /** //!!!
            `ALU_BEGIN: begin
              if(
                ext_cpu_msg_in == `CPU_R_FORK_DONE
              ) begin
                cpu_msg_r = int_cpu_msg_in;
//                cpu_index_itf = cpu_index_r;
                
//                next_state_r = 1;
                ext_next_cpu_e_r = 1;
              end
            end
            /**/
            
            `FINISH_BEGIN: begin
              //data_r
		//		  if(cpu_ind_rel == 2'b11) begin
                cpu_msg_r <= `CPU_R_END;
              //!! cpu_index_itf = cpu_index_r;
//              cpu_index_r = `CPU_NONACTIVE;
//              rst_state = 0; // = 1;

                //thread_escape <= 1'b 0;
					 //no_data_exit_and_wait_begin <= 1'b 0;
					 
                ext_dispatcher_q_r <= 1'b 1;
					 
                ext_next_cpu_e_r <= 1;
                next_state_r <= 1;
      //        end
            end
 
/**
            `BREAK_THREAD_SAVE_IP_AND_WAIT: begin
//		        if(ext_cpu_msg_in == 0) begin
              if(ext_next_cpu_q == 0) begin
                cpu_msg_r <= `CPU_R_BREAK_THREAD;

					 addr_r <= base_addr_r - `THREAD_HEADER_SPACE;
					 data_r <= base_addr_data_r != base_addr_r
										  ? base_addr_data_r - `THREAD_HEADER_SPACE//data_r
										  : 0;

					 //cpu_i <= cpu_index;

                ext_dispatcher_q_r <= 1;
				  //cpu_msg_r <= 0; 

//              end else if(cpu_msg_r == `CPU_R_BREAK_THREAD) begin
//				    cpu_msg_r <= 0;
                ext_next_cpu_e_r <= 1;
                next_state_r <= 1;
              end
            end
/**

            `BREAK_THREAD_EXIT_AND_WAIT: begin
//		        if(ext_cpu_msg_in == 0) begin
              if(ext_next_cpu_q == 0) begin
                cpu_msg_r <= `CPU_R_BREAK_THREAD;

					 addr_r <= base_addr_r - `THREAD_HEADER_SPACE;
					 data_r <= base_addr_data_r != base_addr_r
										  ? base_addr_data_r - `THREAD_HEADER_SPACE//data_r
										  : 0;

					 //cpu_i <= cpu_index;

                ext_dispatcher_q_r <= 1;
				  //cpu_msg_r <= 0; 

//              end else if(cpu_msg_r == `CPU_R_BREAK_THREAD) begin
//				    cpu_msg_r <= 0;
                ext_next_cpu_e_r <= 1;
                next_state_r <= 1;
              end
            end
/**/

`ifdef PAUSE_PROC_ENABLE
            `AUX_PRE_FINISH_BEGIN: begin
              ext_dispatcher_q_r <= 1;
              //cpu_msg_r <= 0; 
                ext_next_cpu_e_r <= 1;
                next_state_r <= 1;
            end
`endif

            //`AFTER_MEM_SIZE_READ: begin
            //  ext_dispatcher_q_r <= 1;
            //  cpu_msg_r <= 0; 
            //    ext_next_cpu_e_r <= 1;
                //next_state_r <= 1;
            //end              
            
            default: begin
                cpu_msg_r <= 0; 
				  /*
              if(read_q == 1) begin
//                ext_read_q = 1;
              end else begin
//                data_r = `CPU_R_VOID;
              end
				  */

                ext_next_cpu_e_r <= ext_next_cpu_e_stim;
            end

          endcase
          
        end else
        begin
//		    cpu_msg_r <= 0; 
			 
          case(state)
/**
//`ifndef PAUSE_PROC_ENABLE
            `START_BEGIN: begin
              //cpu_index_r = cpu_index_r | `CPU_ACTIVE;
            
//              data_r = base_addr_r - 1;
              //read_dn_r = 1;
				  next_state_r <= 1;
            end
//`endif
/**/

            `READ_MEM_SIZE_1,
            `READ_DST,
            `READ_DST_P,
            `READ_COND, 
            `READ_COND_P,
            `READ_SRC1,
            `READ_SRC1_P,
            `READ_SRC0,
            `READ_SRC0_P,
            `START_READ_CMD,
            `START_READ_CMD_P: begin
              cpu_msg_r <= 0; 
              //ext_dispatcher_q_r <= 1;

              if(no_data_exit_and_wait_begin == 1) begin
                next_state_r <= 1;
              end

				  //if(
				  //  disp_online_r == 1 &&
				  // (
					//   rw_halt == 1 ||
					//	read_dn == 1 ||
               //   write_dn == 1
				  // )
				  //) begin
                ext_next_cpu_e_r <= ext_next_cpu_e_stim;
              //end
            end
           
			  
            /**/
            `ALU_BEGIN: begin
              cpu_msg_r <= 0; 
              if(
                ext_cpu_msg_in == `CPU_R_FORK_DONE
//                && ext_next_cpu_e_r !== 1
              ) begin
//                cpu_msg_r = int_cpu_msg;
//                cpu_index_itf = cpu_index_r;
                
//                next_state_r = 1;
                ext_next_cpu_e_r <= 1;
              end else
              if(
                ext_cpu_msg_in == `CPU_R_STOP_DONE
//                && ext_next_cpu_e_r !== 1
              ) begin
//                cpu_msg_r = int_cpu_msg;
//                cpu_index_itf = cpu_index_r;
                
//                next_state_r = 1;
                ext_next_cpu_e_r <= 1;
              end

            end
            /**/
				
				
            `ALU_RESULTS: begin
              if(cmd_code == `CMD_CHN) begin
                ext_next_cpu_e_r <= 1;
                
                ext_dispatcher_q_r <= 1'b 1;
              end
            end
            
				
            `WRITE_DST,
            `WRITE_DST_P,
            `WRITE_REG_IP,
            `WRITE_DST,
            `WRITE_SRC1,
            `WRITE_SRC0,
            `WRITE_COND: begin
              cpu_msg_r <= 0; 
              //ext_dispatcher_q_r <= 1'b 1;

				  //if(
				  //  disp_online_r == 1 &&
				  // (
				  //   rw_halt == 1 ||
				  //	read_dn == 1 ||
              //    write_dn == 1
				  // )
				  //) begin
                ext_next_cpu_e_r <= ext_next_cpu_e_stim;
              //end
            end


/**/
`ifdef PAUSE_PROC_ENABLE
            `BREAK_THREAD_SAVE_IP_AND_WAIT: begin
//		        if(ext_cpu_msg_in == 0) begin
              if(disp_online_r == 1) begin
                cpu_msg_r <= `CPU_R_BREAK_THREAD;

					 addr_r <= base_addr_r - `THREAD_HEADER_SPACE;
					 //data_r <= base_addr_data_r != base_addr_r
					//					  ? base_addr_data_r - `THREAD_HEADER_SPACE//data_r
					//					  : 0;

								  //if(base_addr_data_r == base_addr_r)
								  //  data_r <= 0;
                          //else
                            data_r <= base_addr_data_r - `THREAD_HEADER_SPACE;


					 //cpu_i <= cpu_index;

                ext_dispatcher_q_r <= 1;
				  //cpu_msg_r <= 0; 

//              end else if(cpu_msg_r == `CPU_R_BREAK_THREAD) begin
//				    cpu_msg_r <= 0;
                ext_next_cpu_e_r <= 1;
                next_state_r <= 1;
              end
            end
/**/


            `BREAK_THREAD_EXIT_AND_WAIT: begin
//		        if(ext_cpu_msg_in == 0) begin
              if(disp_online_r == 1) begin
                cpu_msg_r <= `CPU_R_BREAK_THREAD;

					 addr_r <= base_addr_r - `THREAD_HEADER_SPACE;
					 //data_r <= base_addr_data_r != base_addr_r
						//				  ? base_addr_data_r - `THREAD_HEADER_SPACE//data_r
						//				  : 0;

								  //if(base_addr_data_r == base_addr_r)
								  //  data_r <= 0;
                          //else
                            data_r <= base_addr_data_r - `THREAD_HEADER_SPACE;

					 //cpu_i <= cpu_index;

                ext_dispatcher_q_r <= 1;
				  //cpu_msg_r <= 0; 

//              end else if(cpu_msg_r == `CPU_R_BREAK_THREAD) begin
//				    cpu_msg_r <= 0;
                ext_next_cpu_e_r <= 1;
                next_state_r <= 1;
              end
            end
/**/


/**
            `BREAK_THREAD_SAVE_IP_AND_WAIT: begin
                cpu_msg_r <= 0; //`CPU_R_BREAK_THREAD;
//		ext_dispatcher_q_r <= 1'b 1; //z;

                ext_next_cpu_e_r <= ext_next_cpu_e_stim;
            end
/**

            `BREAK_THREAD_EXIT_AND_WAIT: begin
              cpu_msg_r <= 0; //`CPU_R_BREAK_THREAD;
//              ext_dispatcher_q_r <= 1'b 1; //z;

                ext_next_cpu_e_r <= ext_next_cpu_e_stim;
            end
/**/


            `AUX_PRE_FINISH_BEGIN: begin
//              ext_dispatcher_q_r <= 1;
              cpu_msg_r <= 0; 

                ext_next_cpu_e_r <= ext_next_cpu_e_stim;
            end
`endif

				
            `FINISH_BEGIN: begin
                cpu_msg_r <= 0; //cpu_msg_r ^ `CPU_R_END; //0;
                //thread_escape <= 1'b 0;
                //no_data_exit_and_wait_begin <= 1'b 0;

                ext_dispatcher_q_r <= 1'b 1; //?????

                ext_next_cpu_e_r <= ext_next_cpu_e_stim;
            end

				
            `FINISH_END: begin
              cpu_msg_r <= 0; 
              rst_state <= 1; //0; // = 1;
/**
              cpu_index_r = `CPU_NONACTIVE;
/**/

                ext_next_cpu_e_r <= ext_next_cpu_e_stim;
            end
				
            //`AFTER_MEM_SIZE_READ: begin
            //  cpu_msg_r <= 0;
            //end

				
            default: begin
              cpu_msg_r <= 0; 
              ext_dispatcher_q_r <= 1'b 0; //z;

                ext_next_cpu_e_r <= ext_next_cpu_e_stim;
            end
            
          endcase
          
        end
      end
    end
    
   
    end //clk_oe
	 
	 
//	 cpu_index_r = cpu_index_int;


	 
/**
	 if(clk_oe == 0) begin
/** /
//    if(ext_next_cpu_e === 1) begin 
      if(
		   ext_cpu_index == cpu_index_r
//			cpu_ind_rel == 2'b11
      ) begin
		
        if(
            cpu_index_r == 0 
            && state == `START_BEGIN 
        ) begin
          cpu_index_r = `CPU_ACTIVE;
        end
        
      end 
      else // if(ext_next_cpu_e_r === 1)

//      if(
////        cpu_ind_rel != 2'b11
//        ext_cpu_index !== cpu_index_r
//      )
      begin // ext_cpu_index !== cpu_index_r

/** /
              if(
                 (ext_cpu_index & `CPU_ACTIVE) !== 0 //=== `CPU_ACTIVE
//					  is_ext_cpu_index_active
//                   |(ext_cpu_index & `CPU_ACTIVE) == 1'b 1
              ) begin
				  
				    if(
                  ext_cpu_msg_in == `CPU_R_END //: begin
						&& (cpu_index_r & `CPU_ACTIVE) != 0 //=== `CPU_ACTIVE
//						&& is_cpu_index_active

//						&& (ext_cpu_index & `CPU_ACTIVE) === `CPU_ACTIVE
//						&& (ext_cpu_index & ~`CPU_ACTIVE) < (cpu_index_r & ~`CPU_ACTIVE)

						&& ext_cpu_index[30:0] < cpu_index_r[30:0]
//						&& cpu_ind_rel == 2'b01
//						&& is_ext_cpu_index_lt
                ) begin
                  cpu_index_r[30:0] = cpu_index_r[30:0] - 1;
                end
            
				 end else begin // (ext_cpu_index & `CPU_ACTIVE) !== `CPU_ACTIVE
				 
					if(
						 ext_cpu_msg_in == `CPU_R_START //: begin
	//					 && (ext_cpu_index & `CPU_ACTIVE) === `CPU_NONACTIVE
					) begin
					
	//              cpu_index_r[30:0] = cpu_index_r[30:0] + (cpu_index_r[31] ? 1 : -1);
					  if( 
						  (cpu_index_r & `CPU_ACTIVE) != 0 //=== `CPU_ACTIVE 
//						  cpu_index_r[31]
	//					  is_cpu_index_active
					  ) begin
						 cpu_index_r[30:0] = cpu_index_r[30:0] + 1;
					  end else begin
						 cpu_index_r[30:0] = cpu_index_r[30:0] - 1;
					  end
					  
					end
				 end // (ext_cpu_index & `CPU_ACTIVE) ==/!= `CPU_ACTIVE
/** /

//        end //if(ext_next_cpu_e_r === 1)

			end // ext_cpu_index ==/!= cpu_index_r

    end //clk_oe
	 
/**/

  end //always
/**/

  
endmodule

