


`include "sizes.v"
`include "states.v"
`include "inter_cpu_msgs.v"





module Cpu(
            clk,
            
            addr,
            data,
            
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
            
            dispatcher_q
          );
          
  input wire clk;
  
  inout wire [`ADDR_SIZE0:0] addr;
  
  inout wire read_q;
  inout wire write_q;
  
  input wire read_dn;
  
  input wire write_dn;
  
  wire read_e;
  wire write_e;
  
  inout wire [`DATA_SIZE0:0] data;
  
   
  wire [`DATA_SIZE0:0] src1;
  wire [`DATA_SIZE0:0] src0;
  wire [`DATA_SIZE0:0] dst;
  wire [`DATA_SIZE0:0] dst_h;
  wire [`DATA_SIZE0:0] cond;
  
  wire [`STATE_SIZE0:0] state;
  wire nxt_state;
  
  inout wire bus_busy;
  
  wire [31:0] command;
          
          
          
  wire [`ADDR_SIZE0:0] base_addr;
  
  wire rst;
  
  
//  reg ext_rst_e_r;
  
  input wire ext_rst_b; // = RESET;
  output wire ext_rst_e; // = ext_rst_e_r;
  
  inout wire [`DATA_SIZE0:0] ext_cpu_index;
  
  input wire ext_cpu_q;
  output wire ext_cpu_e;
  
//  reg cpu_running;
  
  wire ext_bus_busy;
  
  output wire dispatcher_q;

          
          
BridgeToOutside outside_bridge (
            .clk(clk),
            .state(state),
            
            //base_addr,
            .command(command),
            
            .bus_busy(bus_busy),
            .addr(addr),
            .data(data),
            .read_q(read_q),
            .write_q(write_q),
            .read_dn(read_dn),
            .write_dn(write_dn),
            .read_e(read_e),
            .write_e(write_e),
            
            .src1(src1),
            .src0(src0),
            .dst(dst),
            .dst_h(dst_h),
            .cond(cond),
            
            .next_state(nxt_state),
            
            .rst(rst),
            
            .ext_rst_b(ext_rst_b),
            .ext_rst_e(ext_rst_e),
            
            .ext_cpu_index(ext_cpu_index),
            
            .ext_next_cpu_q(ext_cpu_q),
            .ext_next_cpu_e(ext_cpu_e),
            
            .ext_bus_busy(ext_bus_busy),
            
            .ext_dispatcher_q(dispatcher_q)
            );
            
            
  InternalBus int_bus (
            .clk(clk), 
            .state(state),
            //.base_addr(base_addr),
            .command(command),
            
            .bus_busy(bus_busy),
            .addr(addr),
            .read_q(read_q),
            .write_q(write_q),
            .data(data),
            .read_dn(read_dn),
            .write_dn(write_dn),
            .read_e(read_e),
            .write_e(write_e),
            
            //.src1(src1),
            //.src0(src0),
            //.dst(dst),
            //.dst_h(dst_h),
            //.cond(cond),
            
            .next_state(nxt_state),
            
            .rst(rst)
            );
          
          
          
          
endmodule
