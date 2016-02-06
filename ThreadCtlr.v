
`include "sizes.v"
`include "states.v"
`include "cmd_codes.v"
`include "inter_cpu_msgs.v"

module ThreadCtlr(
        clk,
        is_bus_busy,
        
        command,
        
        base_addr,
        base_addr_data,
        
        state,
        
        src1,
        src0,
        dst,
        dst_h,
        
        data,
        addr,
        
        disp_online,
        
        cpu_msg,
        
        next_state,
        
        rst
        );
        
  input wire clk;
  inout is_bus_busy;
  reg is_bus_busy_r;
  tri is_bus_busy = is_bus_busy_r;
  
  input wire [31:0] command;
  
  wire [3:0] cmd_code = command[31:28];
  
  input wire [`ADDR_SIZE0:0] base_addr;
  input wire [`ADDR_SIZE0:0] base_addr_data;
  
  input wire [`STATE_SIZE0:0] state;
  
  inout [`DATA_SIZE0:0] src1;
  inout [`DATA_SIZE0:0] src0;
  inout [`DATA_SIZE0:0] dst;
  output reg [`DATA_SIZE0:0] dst_h;

  reg [`DATA_SIZE0:0] src1_r;
  reg [`DATA_SIZE0:0] src0_r;
  reg [`DATA_SIZE0:0] dst_r;
  
  tri [`DATA_SIZE0:0] src1 = src1_r;
  tri [`DATA_SIZE0:0] src0 = src0_r;
  tri [`DATA_SIZE0:0] dst  = dst_r;
  
  
  input wire disp_online;
  
  
  reg cpu_msg_in;
  inout [7:0] cpu_msg;
  reg [7:0] cpu_msg_r;
  tri [7:0] cpu_msg = cpu_msg_in == 0 ? cpu_msg_r : 8'h zzzz_zzzz;


  inout [`DATA_SIZE0:0] data;
  reg [`DATA_SIZE0:0] data_r;
  tri [`DATA_SIZE0:0] data = 
                           (
                              disp_online == 1 
                              && state == `ALU_BEGIN 
                              && (
                                cpu_msg_r === `CPU_R_FORK_THRD
                                || cpu_msg_r === `CPU_R_STOP_THRD
                                )
                             )
                             ? data_r 
                             : `DATA_SIZE'h zzzz_zzzz_zzzz_zzzz
                             ;
  
  inout [`ADDR_SIZE0:0] addr;
  reg [`ADDR_SIZE0:0] addr_r;
  tri [`ADDR_SIZE0:0] addr = (
                              disp_online == 1
                              && state == `ALU_BEGIN 
                              && (
                                cpu_msg_r === `CPU_R_FORK_THRD
                                || cpu_msg_r === `CPU_R_STOP_THRD
                                )
                             )
                             ? addr_r 
                             : `DATA_SIZE'h zzzz_zzzz_zzzz_zzzz
                             ;
  

  output reg next_state;
  
  input wire rst;
  
  
//  wire [3:0] cmd_code = command[31:28];
  
  reg signal_sent;
  
        
  always @(negedge clk) begin
    next_state = 1'b z;
    
    is_bus_busy_r = 1'b z;
    
    cpu_msg_r = 8'h zzzz;
    
    cpu_msg_in = 0;

    if(rst == 1) begin
      src1_r = `DATA_SIZE'h zzzzzzzz;
      src0_r = `DATA_SIZE'h zzzzzzzz;
      dst_r =  `DATA_SIZE'h zzzzzzzz;
      dst_h =  `DATA_SIZE'h zzzzzzzz;
      
      cpu_msg_r = 8'h 00;
      
      signal_sent = 0;
      
      cpu_msg_in = 0;
//      is_bus_busy_r = 1'b z;
    end else begin
    
      case(state)
        `ALU_BEGIN: begin
          dst_h = 0;
          
          case(cmd_code)
            `CMD_FORK: begin
              if(disp_online == 1) begin
                if(
//                  cpu_msg_r !== `CPU_R_FORK_THRD && 
                  signal_sent == 0
                ) begin
                  addr_r = src0 + base_addr;
                  data_r = src1 == 0 ? 0 : src1 + base_addr_data;
                
                  cpu_msg_r = `CPU_R_FORK_THRD;
                  
                  signal_sent = 1;
                end
                else begin
//                  if(signal_sent == 0) begin
//                    signal_sent = 1;
//                  end
//                  else begin
                    cpu_msg_r = 8'h 00;
                    cpu_msg_in = 1;
                  
                    if(cpu_msg === `CPU_R_FORK_DONE) begin
                    
                      signal_sent = 0;
                      next_state = 1;
                    end
//                  end
                end
              end
              else begin
                cpu_msg_r = 8'h00;
              end
            end
            
            
            `CMD_STOP: begin
//              cpu_msg_r = `CPU_R_STOP_THRD;
              if(disp_online == 1) begin
                if(
//                  cpu_msg_r !== `CPU_R_FORK_THRD && 
                  signal_sent == 0
                ) begin
                  addr_r = src0 + base_addr - `THREAD_HEADER_SPACE;
                  data_r = src1 == 0 ? 0 : src1 + base_addr_data - `THREAD_HEADER_SPACE;
                
                  cpu_msg_r = `CPU_R_STOP_THRD;
                  
                  signal_sent = 1;
                end
                else begin
//                  if(signal_sent == 0) begin
//                    signal_sent = 1;
//                  end
//                  else begin
                    cpu_msg_r = 8'h 00;
                    cpu_msg_in = 1;
                  
                    if(cpu_msg === `CPU_R_STOP_DONE) begin
                    
                      signal_sent = 0;
                      next_state = 1;
                    end
//                  end
                end
              end
              else begin
                cpu_msg_r = 8'h00;
              end
            end
            
            
            /**
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
            **/
            
            
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