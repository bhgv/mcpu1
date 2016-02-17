


`include "sizes.v"
`include "states.v"
`include "inter_cpu_msgs.v"





module Cpu(
            clk,
				clk_oe,
            
            addr_in,
            addr_out,
            data_in,
            data_out,
            
            halt_q_in,
            halt_q_out,
            rw_halt_in,
            rw_halt_out,
            
            want_write_in,
            want_write_out,
            
            read_q,
            write_q,
            read_dn,
            write_dn,
            
            bus_busy_in,
				bus_busy_out,
				
				disp_online,
            
				init,
            ext_rst_b,
            ext_rst_e,
            
            ext_cpu_index,
            
            ext_cpu_q,
            ext_cpu_e,
            
            cpu_msg,
				cpu_msg_in,
            
            dispatcher_q
          );
          
  input wire clk;
  
  input wire clk_oe;
  
  input wire [`ADDR_SIZE0:0] addr_in;
  output wire [`ADDR_SIZE0:0] addr_out;
  
  wire int_read_q;
  wire int_write_q;
  
  output wire read_q;
  output wire write_q;
  
  input wire read_dn;
  
  input wire write_dn;
  
//  wire read_e;
//  wire write_e;
  
  input [`DATA_SIZE0:0] data_in;
  output [`DATA_SIZE0:0] data_out;
  
  wire [`DATA_SIZE0:0] data_in;

/*
  tri [`DATA_SIZE0:0] data = 
									 !(
									   read_q === 1'b 1
									   || write_q === 1'b 1
									 )
									? data_in
									: `DATA_SIZE'h zzzz_zzzz_zzzz_zzzz
									;
*/

  wire [`DATA_SIZE0:0] data_out; /* = 
											 read_q === 1'b 1
											 || write_q === 1'b 1
											? data
											: `DATA_SIZE'h zzzz_zzzz_zzzz_zzzz
											;
*/
  
  input wire rw_halt_in;
  output wire rw_halt_out;
  
//  tri int_rw_halt;
  
  input wire halt_q_in;
  output wire halt_q_out;
  
  input wire want_write_in;
  output wire want_write_out;
  
  wire [1:0] cpu_ind_rel;
   
  wire [`DATA_SIZE0:0] src1;
  wire [`DATA_SIZE0:0] src0;
  wire [`DATA_SIZE0:0] dst;
  wire [`DATA_SIZE0:0] dst_h;
  wire [`DATA_SIZE0:0] cond;
  
  wire [`STATE_SIZE0:0] state;
  wire nxt_state;
  
  input wire bus_busy_in;
  output wire bus_busy_out;
  
  wire [31:0] command;
  
  
  output wire disp_online;
          
          
  wire [`ADDR_SIZE0:0] base_addr;
  wire [`ADDR_SIZE0:0] base_addr_data;
  
  wire rst;
  
  
//  reg ext_rst_e_r;
  
  input wire init;
  
  input wire ext_rst_b; // = RESET;
  output wire ext_rst_e; // = ext_rst_e_r;
  
  inout tri [`DATA_SIZE0:0] ext_cpu_index;
  
  input wire ext_cpu_q;
  output wire ext_cpu_e;
  
  wire [`CPU_MSG_SIZE0:0] int_cpu_msg;
  output wire [`CPU_MSG_SIZE0:0] cpu_msg;
  
  input wire [`CPU_MSG_SIZE0:0] cpu_msg_in;
  
//  reg cpu_running;
    
  output wire dispatcher_q;

          
/**/
BridgeToOutside outside_bridge (
            .clk(clk),
				.clk_oe(clk_oe),

            .state(state),
            
            .base_addr(base_addr),
            .base_addr_data(base_addr_data),

            .command(command),
            
            .cpu_ind_rel(cpu_ind_rel),
				
//            .halt_q_in(halt_q),
//            .halt_q(halt_q),
//            .rw_halt(rw_halt), //(int_rw_halt),
//            .rw_halt(rw_halt), //(int_rw_halt),
            
            .bus_busy_in(bus_busy_in),
            .bus_busy_out(bus_busy_out),
				
            .addr_in(addr_in),
            .addr_out(addr_out),
            .data_in(data_in),
            .data_out(data_out),
            .read_q(int_read_q),
            .write_q(int_write_q),
            .read_dn(read_dn),
            .write_dn(write_dn),
//            .read_e(read_e),
//            .write_e(write_e),
            
            .src1(src1),
            .src0(src0),
            .dst(dst),
            .dst_h(dst_h),
            .cond(cond),
            
            .disp_online(disp_online),
            
            .next_state(nxt_state),
            
            .rst(rst),
            
				.init(init),
				
            .ext_rst_b(ext_rst_b),
            .ext_rst_e(ext_rst_e),
            
            .ext_cpu_index(ext_cpu_index),
            
//            .ext_rw_halt(rw_halt),
            
            .ext_next_cpu_q(ext_cpu_q),
            .ext_next_cpu_e(ext_cpu_e),
                        
            .int_cpu_msg(int_cpu_msg),
            .ext_cpu_msg(cpu_msg),
				
				.ext_cpu_msg_in(cpu_msg_in),
            
            .ext_dispatcher_q(dispatcher_q),
            
            .ext_read_q(read_q),
            .ext_write_q(write_q)
            );
/**/
            
  InternalBus int_bus (
            .clk(clk), 
				.clk_oe(clk_oe),

            .state(state),
            .base_addr(base_addr),
            .base_addr_data(base_addr_data),

            .command(command),
            
            .halt_q_in(halt_q_in),
            .halt_q_out(halt_q_out),
            .rw_halt_in(rw_halt_in), //(int_rw_halt),
            .rw_halt_out(rw_halt_out), //(int_rw_halt),
				
            .cpu_ind_rel(cpu_ind_rel),
            
            .want_write_in(want_write_in),
            .want_write_out(want_write_out),
            
            .bus_busy(bus_busy_in),
            .addr_in(addr_in),
            .addr_out(addr_out),
            .read_q(int_read_q),
            .write_q(int_write_q),
            .data_in(data_in),
            .data_out(data_out),
            .read_dn(read_dn),
            .write_dn(write_dn),
//            .read_e(read_e),
//            .write_e(write_e),
            
            //.src1(src1),
            //.src0(src0),
            //.dst(dst),
            //.dst_h(dst_h),
            //.cond(cond),
            
            .cpu_msg(int_cpu_msg),
            
            .disp_online(disp_online),
            
            .next_state(nxt_state),
            
            .rst(rst)
            );
          
          
          
          
endmodule
