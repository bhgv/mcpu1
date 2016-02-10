


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
            
            halt_q,
            rw_halt,
            
            want_write,
            
            read_q,
            write_q,
            read_dn,
            write_dn,
            
            bus_busy,
				
				disp_online,
            
            ext_rst_b,
            ext_rst_e,
            
            ext_cpu_index,
            
            ext_cpu_q,
            ext_cpu_e,
            
            cpu_msg,
            
            dispatcher_q
          );
          
  input wire clk;
  
  input wire clk_oe;
  
  input tri [`ADDR_SIZE0:0] addr_in;
  output tri [`ADDR_SIZE0:0] addr_out;
  
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
  
  tri [`DATA_SIZE0:0] data_in;

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

  tri [`DATA_SIZE0:0] data_out; /* = 
											 read_q === 1'b 1
											 || write_q === 1'b 1
											? data
											: `DATA_SIZE'h zzzz_zzzz_zzzz_zzzz
											;
*/
  
  inout tri rw_halt;
  tri int_rw_halt;
  
  inout tri halt_q;
  
  inout tri want_write;
  
  wire [1:0] cpu_ind_rel;
   
  wire [`DATA_SIZE0:0] src1;
  wire [`DATA_SIZE0:0] src0;
  wire [`DATA_SIZE0:0] dst;
  wire [`DATA_SIZE0:0] dst_h;
  wire [`DATA_SIZE0:0] cond;
  
  wire [`STATE_SIZE0:0] state;
  wire nxt_state;
  
  inout wire bus_busy;
  
  wire [31:0] command;
  
  
  output wire disp_online;
          
          
  wire [`ADDR_SIZE0:0] base_addr;
  wire [`ADDR_SIZE0:0] base_addr_data;
  
  wire rst;
  
  
//  reg ext_rst_e_r;
  
  input wire ext_rst_b; // = RESET;
  output wire ext_rst_e; // = ext_rst_e_r;
  
  inout tri [`DATA_SIZE0:0] ext_cpu_index;
  
  input wire ext_cpu_q;
  output tri ext_cpu_e;
  
  tri [7:0] int_cpu_msg;
  output tri [7:0] cpu_msg;
  
//  reg cpu_running;
  
  wire ext_bus_busy;
  
  output wire dispatcher_q;

          
/**/
BridgeToOutside outside_bridge (
            .clk(clk),
				.clk_oe(clk_oe),

            .state(state),
            
            .base_addr(base_addr),
            .base_addr_data(base_addr_data),

            .command(command),
            
            .halt_q(halt_q),
            .cpu_ind_rel(cpu_ind_rel),
            .rw_halt(rw_halt), //(int_rw_halt),
            
            .bus_busy(bus_busy),
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
            
            .ext_rst_b(ext_rst_b),
            .ext_rst_e(ext_rst_e),
            
            .ext_cpu_index(ext_cpu_index),
            
            .ext_rw_halt(rw_halt),
            
            .ext_next_cpu_q(ext_cpu_q),
            .ext_next_cpu_e(ext_cpu_e),
            
            .ext_bus_busy(ext_bus_busy),
            
            .int_cpu_msg(int_cpu_msg),
            .ext_cpu_msg(cpu_msg),
            
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
            
            .halt_q(halt_q),
            .rw_halt(rw_halt), //(int_rw_halt),
            .cpu_ind_rel(cpu_ind_rel),
            
            .want_write(want_write),
            
            .bus_busy(bus_busy),
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
