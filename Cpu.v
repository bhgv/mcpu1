


`include "sizes.v"
`include "states.v"
`include "inter_cpu_msgs.v"





module Cpu(
            clk,
            
            addr,
            data,
            
            halt_q,
            rw_halt,
            
            read_q,
            write_q,
            read_dn,
            write_dn,
            
            bus_busy,
            
            ext_rst_b,
            ext_rst_e,
            
            ext_cpu_index,
            
            ext_cpu_q,
            ext_cpu_e,
            
            cpu_msg,
            
            dispatcher_q
          );
          
  input wire clk;
  
  inout tri [`ADDR_SIZE0:0] addr;
  
  wire int_read_q;
  wire int_write_q;
  
  inout wire read_q;
  inout wire write_q;
  
  input wire read_dn;
  
  input wire write_dn;
  
//  wire read_e;
//  wire write_e;
  
  inout tri [`DATA_SIZE0:0] data;
  
  inout tri rw_halt;
  tri int_rw_halt;
  
  inout wire halt_q;
  
  wire [1:0] cpu_ind_rel;
   
  wire [`DATA_SIZE0:0] src1;
  wire [`DATA_SIZE0:0] src0;
  wire [`DATA_SIZE0:0] dst;
  wire [`DATA_SIZE0:0] dst_h;
  wire [`DATA_SIZE0:0] cond;
  
  wire [`STATE_SIZE0:0] state;
  wire nxt_state;
  
  inout wire bus_busy;
  
  //wire [31:0] command;
  
  
  wire disp_online;
          
          
  wire [`ADDR_SIZE0:0] base_addr;
  
  wire rst;
  
  
//  reg ext_rst_e_r;
  
  input wire ext_rst_b; // = RESET;
  output wire ext_rst_e; // = ext_rst_e_r;
  
  inout wire [`DATA_SIZE0:0] ext_cpu_index;
  
  input wire ext_cpu_q;
  output wire ext_cpu_e;
  
  wire [7:0] int_cpu_msg;
  inout wire [7:0] cpu_msg;
  
//  reg cpu_running;
  
  wire ext_bus_busy;
  
  output wire dispatcher_q;

          
/**/
BridgeToOutside outside_bridge (
            .clk(clk),
            .state(state),
            
            //base_addr,
            //.command(command),
            
            .halt_q(halt_q),
            .cpu_ind_rel(cpu_ind_rel),
            .rw_halt(rw_halt), //(int_rw_halt),
            
            .bus_busy(bus_busy),
            .addr(addr),
            .data(data),
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
            .state(state),
            //.base_addr(base_addr),
            //.command(command),
            
            .halt_q(halt_q),
            .rw_halt(rw_halt), //(int_rw_halt),
            .cpu_ind_rel(cpu_ind_rel),
            
            .bus_busy(bus_busy),
            .addr(addr),
            .read_q(int_read_q),
            .write_q(int_write_q),
            .data(data),
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
