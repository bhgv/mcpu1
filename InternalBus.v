

`include "sizes.v"
`include "states.v"
`include "cmd_codes.v"



module InternalBus(
        clk,
		  clk_oe,
		  
        //    state,
        bus_busy,
        
        base_addr,
        base_addr_data,
		  
		  addr_unmodificable_b,
        
        command,
        
        state,
        
         halt_q_in,
         halt_q_out,
         rw_halt_in,
         rw_halt_out,

			cpu_ind_rel,
        
         want_write_in,
         want_write_out,
        
            addr_in,
				addr_out,
            data_in,
            data_out,
            
            read_q,
            write_q,
            read_dn,
            write_dn,
				
            chan_msg_strb_i,
            chan_msg_strb_o,

//            read_e,
//            write_e,
            
//        src1,
//        src0,
//        dst,
        //dst_h,
        
        cpu_msg_in,
        cpu_msg_out,
		  
		  chan_op,
		  
		  chan_escape,
        
        disp_online,
        
        next_state,
		  
		  no_data_new,
		  no_data_tick,
		  no_data_exit_and_wait_begin,
		  
		  thread_escape,
        
        rst
        );
		  
  input wire clk_oe;
        
  input wire clk;
  
  input bus_busy;
//  reg bus_busy_r;
  wire bus_busy; // = bus_busy_r;
  
  output wire [31:0] command;
  
  
  wire [`CMD_BITS_PER_CMD_CODE0:0] cmd_code = command[31:28];
  
  
  input wire rst;
  
  input wire halt_q_in;
  output wire halt_q_out;
  input wire rw_halt_in;
  output wire rw_halt_out;
  
  output wire chan_escape;
  
  input wire[`ADDR_SIZE0:0] addr_unmodificable_b;
  
  
  input wire [1:0] cpu_ind_rel;
  
  input wire want_write_in;
  output wire want_write_out;
  

  wire cpu_msg_pulse_t;
  wire cpu_msg_pulse_ch;
  wire cpu_msg_pulse = 
                     cpu_msg_pulse_t
							| cpu_msg_pulse_ch
							;
  
		
  output wire read_q;
  output wire write_q;
  input wire read_dn;
  input wire write_dn;
//  output wire read_e;
//  output wire write_e;
  
  input wire chan_msg_strb_i;
  output wire chan_msg_strb_o;


//  reg [`ADDR_SIZE0:0] addr_out_r;
  input wire [`ADDR_SIZE0:0] addr_in; //= addr_out_r;
  
  output [`ADDR_SIZE0:0] addr_out;
  
  wire [`ADDR_SIZE0:0] addr_out_m;
  wire [`ADDR_SIZE0:0] addr_out_t;
  wire [`ADDR_SIZE0:0] addr_out_ch;
  
  wire [`ADDR_SIZE0:0] addr_out = 
                                 (
                                    read_q == 1
											 || write_q == 1
											 || cpu_msg_pulse == 1
											)
											? (
                                       addr_out_m //[`ADDR_SIZE0:0]
                                     | addr_out_t //[`ADDR_SIZE0:0]
                                     | addr_out_ch //[`ADDR_SIZE0:0]
                                   )
											: 0
                                 ;

  
//  reg [`DATA_SIZE0:0] data_r;
  input wire [`DATA_SIZE0:0] data_in; // = data_r;
  output [`DATA_SIZE0:0] data_out; // = data_r;
//  wire [`DATA_SIZE0:0] data_out_s; // = data_r;
  wire [`DATA_SIZE0:0] data_out_m; // = data_r;
  wire [`DATA_SIZE0:0] data_out_t; // = data_r;
  wire [`DATA_SIZE0:0] data_out_ch; // = data_r;
  wire [`DATA_SIZE0:0] data_out = 
                                 (
                                    read_q == 1
											 || write_q == 1
											 || cpu_msg_pulse == 1
											)
											? (
                                       data_out_m
                                     | data_out_t
                                     | data_out_ch
//                                   | data_out_s
                                   )
											: 0
                                 ;
  

  wire [`DATA_SIZE0:0] src1_in;
  wire [`DATA_SIZE0:0] src0_in;
  
  wire [`DATA_SIZE0:0] dst_alu_in;
  wire [`DATA_SIZE0:0] dst_trd_ctl_in;
  wire [`DATA_SIZE0:0] dst_chnl_ctl_in;
  
  wire [`DATA_SIZE0:0] dst_in =
                            dst_alu_in
                            | dst_trd_ctl_in
                            | dst_chnl_ctl_in
                            ;
  
  
  wire [`DATA_SIZE0:0] src1_out;
  wire [`DATA_SIZE0:0] src0_out;
  wire [`DATA_SIZE0:0] dst_out;
  
  
  wire [`DATA_SIZE0:0] dst_h;
  wire [`DATA_SIZE0:0] cond;
  
  wire [`DATA_SIZE0:0] cmd_ptr;
  
  output wire [`STATE_SIZE0:0] state;
  
  
  input next_state;
  wire next_state;
  
  wire next_state_m, next_state_a, next_state_t, next_state_ch;//, next_state_s;
  
  wire next_state_rslt = 
								next_state
								| next_state_m
								| next_state_a
//								| next_state_s
								| next_state_t
								| next_state_ch
								;
 
                    
  input wire [`ADDR_SIZE0:0] base_addr;
  input wire [`ADDR_SIZE0:0] base_addr_data;
  
  
  input wire disp_online;
  
  
  input wire [`CPU_MSG_SIZE0:0] cpu_msg_in;
  output [`CPU_MSG_SIZE0:0] cpu_msg_out;
  
  wire [`CPU_MSG_SIZE0:0] cpu_msg_out_t;
  wire [`CPU_MSG_SIZE0:0] cpu_msg_out_ch;
  
  wire [`CPU_MSG_SIZE0:0] cpu_msg_out = 
                                       cpu_msg_out_t
													| cpu_msg_out_ch
                                       ;
  
  
  
  
  wire 
		is_ip_read,
		is_ip_read_ptr,
		is_cnd_read,
		is_cnd_read_ptr,
		is_s1_read,
		is_s1_read_ptr,
		is_s0_read,
		is_s0_read_ptr,
		is_d_read
		;
  
  
  output wire chan_op;
  
  
  output wire no_data_new;
  output wire no_data_tick;
  input wire no_data_exit_and_wait_begin;
  
  input wire thread_escape;
  
  wire chan_wait_next_time;
  

/**
  StartManager start_mng(
            .clk(clk), 
 				.clk_oe(clk_oe),

				.state(state),
            
            .base_addr(base_addr),
            .command(command),
            
            .cpu_ind_rel(cpu_ind_rel),
//            .halt_q(halt_q),
//            .rw_halt(rw_halt),
            
            .is_bus_busy(bus_busy),
            .addr_in(addr_in),
//            .addr_out(addr_out),

//            .read_q(read_q),
//            .write_q(write_q),
            .data_in(data_in),
            .data_out(data_out_s),
            .read_dn(read_dn),
            .write_dn(write_dn),
//            .read_e(read_e),
//            .write_e(write_e),

            .cmd_ptr(cmd_ptr),
            
            .disp_online(disp_online),
            
            .next_state(next_state_s),
            
            .rst(rst)
            );
/**/

/**

  FinishManager finish_mng(
            .clk(clk), 
            .state(state),
            
            .base_addr(base_addr),
            .command(command),
            
            .is_bus_busy(bus_busy),
            .addr(addr),
            .data(data),
            
            .next_state(next_state),
            
            .rst(rst)
            );
/**/

  StateManager states_mng(
            .clk(clk),
				.clk_oe(clk_oe),

            .state(state),

            .command(command),
            
            .cond(cond),
            
            .next_state(next_state_rslt),
            
            .isIpSaveAllowed(isIpSaveAllowed),
            .isDSaveAllowed(isDSaveAllowed),
            .isDSavePtrAllowed(isDSavePtrAllowed),
            .isCndSaveAllowed(isCndSaveAllowed),
            .isCndSavePtrAllowed(isCndSavePtrAllowed),
            .isS1SaveAllowed(isS1SaveAllowed),
            .isS1SavePtrAllowed(isS1SavePtrAllowed),
            .isS0SaveAllowed(isS0SaveAllowed),
            .isS0SavePtrAllowed(isS0SavePtrAllowed),
				
				.is_ip_read(is_ip_read),
				.is_ip_read_ptr(is_ip_read_ptr),
				.is_cnd_read(is_cnd_read),
				.is_cnd_read_ptr(is_cnd_read_ptr),
				.is_s1_read(is_s1_read),
				.is_s1_read_ptr(is_s1_read_ptr),
				.is_s0_read(is_s0_read),
				.is_s0_read_ptr(is_s0_read_ptr),
				.is_d_read(is_d_read),
				
				.no_data_exit_and_wait_begin(no_data_exit_and_wait_begin),
//				.no_data_new(no_data_new),
//				.no_data_tick(no_data_tick),

				.thread_escape(thread_escape),
				.chan_escape(chan_escape),
				
            .chan_op(chan_op),
				.chan_wait_next_time(chan_wait_next_time),

            .rst(rst)
            );
            

/**/
  MemManager mem_mng (
            .clk(clk), 
				.clk_oe(clk_oe),

            .state(state),
            .base_addr(base_addr),
            .base_addr_data(base_addr_data),
				
				.addr_unmodificable_b(addr_unmodificable_b),
            
            .command_word(command),
            
            .cpu_ind_rel(cpu_ind_rel),
				
            .halt_q_in(halt_q_in),
            .halt_q_out(halt_q_out),
            .rw_halt_in(rw_halt_in),
            .rw_halt_out(rw_halt_out),
            
            .want_write_in(want_write_in),
            .want_write_out(want_write_out),
            
            .is_bus_busy(bus_busy),
            .addr_in(addr_in),
            .addr_out(addr_out_m),
            .read_q(read_q),
            .write_q(write_q),
            .data_in(data_in),
            .data_out(data_out_m),
            .read_dn(read_dn),
            .write_dn(write_dn),
//            .read_e(read_e),
//            .write_e(write_e),
            
            .src1_in(src1_in),
            .src0_in(src0_in),
            .dst_in(
//			               cmd_code == `CMD_FORK
//						   || cmd_code == `CMD_STOP
//						 ? dst_trd_ctl_in
//						 : cmd_code == `CMD_CHN
//						 ? dst_chnl_ctl_in
//						 : 
						 dst_in 
						),
            .dst_h_in(dst_h),
//            .cond_in(cond),
				
            .src1_out(src1_out),
            .src0_out(src0_out),
            .dst_out(dst_out),
//            .dst_h(dst_h),
            .cond_out(cond),
            
            .cmd_ptr(cmd_ptr),
            
            .disp_online(disp_online),
            
            .next_state(next_state_m),
            
            .isIpSaveAllowed(isIpSaveAllowed),
            .isDSaveAllowed(isDSaveAllowed),
            .isDSavePtrAllowed(isDSavePtrAllowed),
            .isCndSaveAllowed(isCndSaveAllowed),
            .isCndSavePtrAllowed(isCndSavePtrAllowed),
            .isS1SaveAllowed(isS1SaveAllowed),
            .isS1SavePtrAllowed(isS1SavePtrAllowed),
            .isS0SaveAllowed(isS0SaveAllowed),
            .isS0SavePtrAllowed(isS0SavePtrAllowed),

				.is_ip_read(is_ip_read),
				.is_ip_read_ptr(is_ip_read_ptr),
				.is_cnd_read(is_cnd_read),
				.is_cnd_read_ptr(is_cnd_read_ptr),
				.is_s1_read(is_s1_read),
				.is_s1_read_ptr(is_s1_read_ptr),
				.is_s0_read(is_s0_read),
				.is_s0_read_ptr(is_s0_read_ptr),
				.is_d_read(is_d_read),
				
				.no_data_new(no_data_new),
				.no_data_tick(no_data_tick),
				.no_data_exit_and_wait_begin(no_data_exit_and_wait_begin),
            
            .rst(rst)
            );
/**/

/**/
  Alu alu_1 (
        .clk(clk),
			.clk_oe(clk_oe),

			.is_bus_busy(bus_busy),
        
        .command(command),
        
        .state(state),
        
        .src1_in(src1_out),
        .src0_in(src0_out),
//        .dst(dst),
		  
        .src1_out(src1_in),
        .src0_out(src0_in),
        .dst_out(dst_alu_in),
		  
        .dst_h_out(dst_h),
        
        .next_state(next_state_a),
        
        .rst(rst)
        );
/**/

/**/
  ThreadCtlr thrd_1 (
        .clk(clk),
 		  .clk_oe(clk_oe),

			.is_bus_busy(bus_busy),
        
        .base_addr(base_addr),
        .base_addr_data(base_addr_data),
        
        .command(command),
        
        .state(state),
        
        .src1(src1_out),
        .src0(src0_out),
//        .dst_in(dst_out),
		  
//        .src1_out(src1),
//        .src0_out(src0),
        .dst(dst_trd_ctl_in),
		  
        .dst_h(dst_h),
        
        .data_in(data_in),
        .data_out(data_out_t),
            .addr_in(addr_in),
            .addr_out(addr_out_t),
        
        .disp_online(disp_online),
        
        .cpu_msg_in(cpu_msg_in),
        .cpu_msg_out(cpu_msg_out_t),
		  
		  .cpu_msg_pulse(cpu_msg_pulse_t),
        
        .next_state(next_state_t),
        
        .rst(rst)
        );
/**/


/**/
  ChannelCtlr chnl_1 (
        .clk(clk),
 		  .clk_oe(clk_oe),

			.is_bus_busy(bus_busy),
        
        .base_addr(base_addr),
        .base_addr_data(base_addr_data),
        
        .command(command),
        
        .state(state),
        
        .src1(src1_out),
        .src0(src0_out),
//        .dst_in(dst_out),
		  
//        .src1_out(src1),
//        .src0_out(src0),
        .dst(dst_chnl_ctl_in),
		  
        .dst_h(dst_h),
        
        .data_in(data_in),
        .data_out(data_out_ch),
        
		  .addr_in(addr_in),
        .addr_out(addr_out_ch),
        
        .disp_online(disp_online),
        
        .cpu_msg_in(cpu_msg_in),
        .cpu_msg_out(cpu_msg_out_ch),
		  
		  .cpu_msg_pulse(cpu_msg_pulse_ch),
		  
		  .chan_msg_strb_i(chan_msg_strb_i),
        .chan_msg_strb_o(chan_msg_strb_o),
		  
		  .chan_op(chan_op),
		  .chan_wait_next_time(chan_wait_next_time),
		  
		  .chan_escape(chan_escape),
        
        .next_state(next_state_ch),
        
        .rst(rst)
        );
/**/


/**
  always @(posedge clk) begin
    
//      bus_busy_r = 1'b z;

    if(rst == 1) begin
//      bus_busy_r = 1'b z;
    end //else begin

/*
      case(state)
        `START_BEGIN: begin
          data_tri_r = 0; //Q;
          read_dn = 1;
        end
        
      endcase
* /

  end
/**/
  
endmodule








