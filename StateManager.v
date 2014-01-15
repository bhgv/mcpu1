
`include "sizes.v"
`include "states.v"


module StateManager(
            clk,
            state,
            
            command,

            cond,
            
            next_state,
            
            rst
            );
  input wire clk;
  output reg [`STATE_SIZE0:0] state;
  

  input wire [31:0] command;  
  
  wire isRegS1Ptr;
  assign isRegS1Ptr = command[16];
  
  wire isRegS0Ptr;
  assign isRegS0Ptr = command[17];
  
  wire isRegDPtr;
  assign isRegDPtr = command[18];
  
  wire isRegCondPtr;
  assign isRegCondPtr = command[19];
  
  
  wire [1:0] regS1Flags;
  assign regS1Flags = command[21:20];
  
  wire [1:0] regS0Flags;
  assign regS0Flags = command[23:22];
  
  wire [1:0] regDFlags;
  assign regDFlags = command[25:24];
  
  wire [1:0] regCondFlags;
  assign regCondFlags = command[27:26];


  input wire [`DATA_SIZE0:0] cond;
  
  input wire next_state;
  
  input wire rst;
  
  always @(negedge clk) begin
    if( rst == 1 ) begin
      state = `WAIT_FOR_START;
    end
    else if(next_state == 1) begin
      case(state)
        `WRITE_REG_IP: begin
          if(regCondFlags == 2'b11) begin
            state = `READ_SRC1;
          end else begin
            state = `READ_COND;
          end
        end
        
        `READ_COND: begin
          if(regCondFlags != 2'b11) begin
            if(isRegCondPtr == 0 && cond == 0) begin
              state = `WRITE_DATA;
            end else if(isRegCondPtr == 1) begin
              state = `READ_COND_P;
            end else begin
              state = `READ_SRC1;
            end
          end else begin
            state = `READ_SRC1;
          end
        end
        
        `READ_COND_P: begin
          if(cond == 0) begin
            state = `WRITE_DATA;
          end else begin
            state = `READ_SRC1;
          end
        end
        
        `READ_SRC1: begin
          if(
            regS1Flags != 2'b11 &&
            isRegS1Ptr == 1
          ) begin
            state = `READ_SRC1_P;
          end else begin
            state = `READ_SRC0;
          end
        end

        `READ_SRC1_P: begin
          state = `READ_SRC0;
        end

        `READ_SRC0: begin
          if(
            regS0Flags != 2'b11 &&
            isRegS0Ptr == 1
          ) begin
            state = `READ_SRC0_P;
          end else begin
            state = `ALU_BEGIN;
          end
        end

        `READ_SRC0_P: begin
          state = `ALU_BEGIN;
        end

        `ALU_BEGIN: begin
            state = `WRITE_DST;
        end

        `WRITE_DST: begin
          if(^regCondFlags == 1) begin
            state = `WRITE_COND;
          end else
          if(^regS1Flags == 1) begin
            state = `WRITE_SRC1;
          end else
          if(^regS0Flags == 1) begin
            state = `WRITE_SRC0;
          end else
          begin
            state = `FINISH_BEGIN;
          end
        end

        `WRITE_COND: begin
          if(^regS1Flags == 1) begin
            state = `WRITE_SRC1;
          end else
          if(^regS0Flags == 1) begin
            state = `WRITE_SRC0;
          end else
          begin
            state = `FINISH_BEGIN;
          end
        end
        
        `WRITE_SRC1: begin
          if(^regS0Flags == 1) begin
            state = `WRITE_SRC0;
          end else
          begin
            state = `FINISH_BEGIN;
          end
        end

        `WRITE_SRC0: begin
            state = `FINISH_BEGIN;
        end

        default: begin
          state = state + 1;
        end

      endcase
      
    end 
//    else if(state == 0) begin
//      state = 1;
//    end
  end
endmodule
