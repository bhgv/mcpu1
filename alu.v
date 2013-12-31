
`include "sizes.v"
`include "states.v"
`include "cmd_codes.v"

module Alu(
        clk,
        is_bus_busy,
        
        command,
        
        state,
        
        src1,
        src0,
        dst,
        dst_h,
        
        next_state,
        
        rst
        );
        
  input wire clk;
  inout is_bus_busy;
  reg is_bus_busy_r;
  wire is_bus_busy = is_bus_busy_r;
  
  input wire [31:0] command;
  
  input wire [`STATE_SIZE0:0] state;
  
  inout [`DATA_SIZE0:0] src1;
  inout [`DATA_SIZE0:0] src0;
  inout [`DATA_SIZE0:0] dst;
  output reg [`DATA_SIZE0:0] dst_h;

  reg [`DATA_SIZE0:0] src1_r;
  reg [`DATA_SIZE0:0] src0_r;
  reg [`DATA_SIZE0:0] dst_r;
  
  wire [`DATA_SIZE0:0] src1 = src1_r;
  wire [`DATA_SIZE0:0] src0 = src0_r;
  wire [`DATA_SIZE0:0] dst  = dst_r;

  output reg next_state;
  
  input wire rst;
  
  
  wire [3:0] cmd_code = command[31:28];
  
  
  
        
  always @(posedge clk) begin
    next_state = 1'b z;
    
    if(rst == 1) begin
      src1_r = `DATA_SIZE'h zzzzzzzz;
      src0_r = `DATA_SIZE'h zzzzzzzz;
      dst_r =  `DATA_SIZE'h zzzzzzzz;
      dst_h =  `DATA_SIZE'h zzzzzzzz;
      
      is_bus_busy_r = 1'b z;
    end else begin
    
      case(state)
        `ALU_BEGIN: begin
          dst_h = 0;
          case(cmd_code)
            `CMD_MOV: begin
              dst_h = src1;
              dst_r = src0;
              src0_r = dst_h;
            end
            
            `CMD_ADD: begin
              {dst_h, dst_r} = src0 + src1;
            end
            
            `CMD_SUB: begin
              {dst_h, dst_r} = src0 - src1;
            end
            
            `CMD_MUL: begin
              {dst_h, dst_r} = src0 * src1;
            end
            
            `CMD_DIV: begin
              dst_r = src0 / src1;
              dst_h = src0 % src1;
            end
            
            `CMD_SHR: begin
              dst_r = src0 >> src1;
            end
            
            `CMD_SHL: begin
              dst_r = src0 << src1;
            end
            
            `CMD_XOR: begin
              dst_r = src0 ^ src1;
            end
            
            `CMD_AND: begin
              dst_r = src0 & src1;
            end
            
            `CMD_OR: begin
              dst_r = src0 | src1;
            end
            
//            `: begin
//            end
            
//            `: begin
//            end
            
//            `: begin
//            end
          
          endcase
          
          next_state = 1;
        end
        
      endcase
    
    
    
    end
  
  end
        
        
        
        
        
endmodule