
`include "sizes.v"
`include "states.v"
`include "cmd_codes.v"
`include "inter_cpu_msgs.v"

module ThreadCtlr(
        clk,
        is_bus_busy,
        
        command,
        
        state,
        
        src1,
        src0,
        dst,
        dst_h,
        
        cpu_msg,
        
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
  
  inout [7:0] cpu_msg;
  reg [7:0] cpu_msg_r;
  wire [7:0] cpu_msg = cpu_msg_r;

  output reg next_state;
  
  input wire rst;
  
  
  wire [3:0] cmd_code = command[31:28];
  
  
  
        
  always @(posedge clk) begin
    next_state = 1'b z;
    
    is_bus_busy_r = 1'b z;

    if(rst == 1) begin
      src1_r = `DATA_SIZE'h zzzzzzzz;
      src0_r = `DATA_SIZE'h zzzzzzzz;
      dst_r =  `DATA_SIZE'h zzzzzzzz;
      dst_h =  `DATA_SIZE'h zzzzzzzz;
      
      cpu_msg_r = 8'h00;
      
//      is_bus_busy_r = 1'b z;
    end else begin
    
      case(state)
        `ALU_BEGIN: begin
          dst_h = 0;
          case(cmd_code)
            `CMD_EXT_CMD: begin
            
              //case(src0)
                if(src0 === `EXT_CMD_NEW_THREAD) begin
                  cpu_msg_r = `CPU_R_NEW_THRD;
                end
                
					 else
                if(src0 === `EXT_CMD_DESTROY_THREAD) begin
                  cpu_msg_r = `CPU_R_DEL_THRD;
                end
              
              //endcase

            end
            
            
//            `: begin
//            end
            
//            `: begin
//            end
            
//            `: begin
//            end
          
          endcase
          
//          next_state = 1;
        end
        
        `FINISH_BEGIN: begin
        end
        
      endcase
    
    
    
    end
  
  end
        
        
        
        
        
endmodule