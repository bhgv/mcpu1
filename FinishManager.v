

`include "sizes.v"
`include "states.v"



module FinishManager (
            clk, 
            state,
            
            base_addr,
            command,
            
            is_bus_busy,
            addr,
            //read_q,
            //write_q,
            data,
            //read_dn,
            //write_dn,
            //read_e,
            //write_e,
            
           // cond,
            
            next_state,
            
            rst
            );
  input wire clk;
  input wire [`STATE_SIZE0:0] state;
  input wire [31:0] command;
  
//  reg [`ADDR_SIZE0:0] cmd_ptr;
//  reg cmd_ptr_waiting;
//  reg cmd_waiting;

  
  input wire [`ADDR_SIZE0:0] base_addr;

  inout [`ADDR_SIZE0:0] addr;
  reg [`ADDR_SIZE0:0] addr_r;
  wire [`ADDR_SIZE0:0] addr = addr_r;
  
  inout is_bus_busy;
  reg is_bus_busy_r;
  wire is_bus_busy = is_bus_busy_r;
  
  inout [`DATA_SIZE0:0] data;
  reg [`DATA_SIZE0:0] data_r;
  wire [`DATA_SIZE0:0] data = data_r;
//  assign data = write_q==1 ? dst_r : 32'h z;
  
  output reg next_state;
  
  input rst;
//  reg rst_r;
  wire rst; // = rst_r;
  
  
//  reg [8:0] progress;


  always @(posedge clk) begin
    addr_r = 32'h zzzzzzzz;
    data_r = 32'h zzzzzzzz;
//    rst_r = 1'b z;
    next_state = 1'b z;
    
//     $monitor("state=%b  nxt=%b  progr=%b S0ptr=%b",state,next_state,progress,isRegS0Ptr);

    if(rst == 1) begin
//      progress = `MEM_BEGIN;
      addr_r = 32'h zzzzzzzz;
      next_state = 1'b z;
      
      data_r = 32'h zzzzzzzz;
      is_bus_busy_r = 1'b z;
    end
    else begin
      case(state)
        `FINISH_BEGIN: begin
          //rst_r = 1;
          next_state = 1;
        end
        
      endcase
  
    end
  end
  
endmodule



