


`include "sizes.v"
`include "states.v"
`include "inter_cpu_msgs.v"



module BridgeToOutside (
            clk, 
            state,
            
            //base_addr,
            command,
            
            bus_busy,
            addr,
            data,
            read_q,
            write_q,
            read_dn,
            write_dn,
            read_e,
            write_e,
            
            src1,
            src0,
            dst,
            dst_h,
            cond,
            
            disp_online,
            
            next_state,
            
            rst,
            
            ext_rst_b,
            ext_rst_e,
            
            ext_cpu_index,
            
            ext_next_cpu_q,
            ext_next_cpu_e,
            
            ext_bus_busy,
            
            ext_dispatcher_q,
            
            ext_read_q,
            ext_write_q
            
            );
  input wire clk;
  input wire [`STATE_SIZE0:0] state;
  input wire [31:0] command;

//  input wire [`ADDR_SIZE0:0] base_addr;
  reg [`ADDR_SIZE0:0] base_addr_r;
  
  inout [`ADDR_SIZE0:0] addr;
  reg [`ADDR_SIZE0:0] addr_r;
  wire [`ADDR_SIZE0:0] addr = addr_r;
  
  input wire read_q;
  input wire  write_q;

  inout bus_busy;
  reg bus_busy_r;
  wire bus_busy = bus_busy_r;
  
  inout [`DATA_SIZE0:0] data;
  reg [`DATA_SIZE0:0] data_r;
  wire [`DATA_SIZE0:0] data = data_r;
//  assign data = write_q==1 ? dst_r : 32'h z;
  
  inout  read_dn;
  reg read_dn_r;
  wire read_dn = read_dn_r;
  
  input  wire write_dn;
  output reg read_e;
  output reg write_e;
  

  input  wire [`DATA_SIZE0:0] src1;
  input  wire [`DATA_SIZE0:0] src0;
  input  wire [`DATA_SIZE0:0] dst;
  input wire [`DATA_SIZE0:0] dst_h;

  input  wire [`DATA_SIZE0:0] cond;
  
  
  output reg disp_online;
  
  
  output reg next_state;
  
  output reg rst;
  reg [2:0] rst_state;
  
  
  input wire ext_rst_b;
  output reg ext_rst_e = 0;
  
  inout [`DATA_SIZE0:0] ext_cpu_index;
  reg [`DATA_SIZE0:0] cpu_index_itf;
  wire [`DATA_SIZE0:0] ext_cpu_index = cpu_index_itf;
  reg [`DATA_SIZE0:0] cpu_index_r;
  
  input wire ext_next_cpu_q;
  output reg ext_next_cpu_e;
  
  inout ext_bus_busy;
  reg ext_bus_busy_r;
  wire ext_bus_busy = ext_bus_busy_r;
  
  output reg ext_dispatcher_q;
  
  output ext_read_q;
  wire ext_read_q    = (state == `READ_COND ||
                        state == `READ_COND_P ||
                        state == `READ_SRC1 ||
                        state == `READ_SRC1_P ||
                        state == `READ_SRC0 ||
                        state == `READ_SRC0_P ||
                        state == `START_READ_CMD ||
                        state == `START_READ_CMD_P
                        ) &&
                        disp_online == 1 
//                        && (!ext_next_cpu_e == 1)
                        ? read_q 
                        : 1'bz;
  output ext_write_q;
  wire ext_write_q   = (state == `WRITE_REG_IP ||
                        state == `WRITE_DST    ||
                        state == `WRITE_SRC1   ||
                        state == `WRITE_SRC0   ||
                        state == `WRITE_COND
                        ) &&
                        disp_online == 1 
//                        && (!ext_next_cpu_e == 1)
                        ? write_q 
                        : 1'bz;


  always @(posedge clk) begin
    addr_r = 32'h zzzzzzzz;
    data_r = 32'h zzzzzzzz;
    next_state = 1'b z;
    ext_rst_e = 0;
  
    read_dn_r = 1'b z;
    
    bus_busy_r = 1'b z;
    
    cpu_index_itf = 32'h zzzzzzzz;

    if(ext_rst_b == 1) begin  // begin of RESET
      rst_state = 0;
    end else if(rst_state < 5) begin // == 1) begin
      ext_next_cpu_e = 1'b z;
      rst = 0;

      if(ext_next_cpu_q == 1 && 
         ext_cpu_index == cpu_index_r
      ) begin
        ext_next_cpu_e = 1;
      end
      
      case(rst_state)
        0: begin
          ext_dispatcher_q = 1'b z;
          
          disp_online = 0;
          
          rst_state = 1;
        end
        
        1: begin
          if(state == `FINISH_END) begin
            rst_state = 3;
          end else begin
            rst_state = 2;
          end
        end
        
        2: begin
          cpu_index_r = ext_cpu_index; //data;
          read_dn_r = 1;
          
          rst_state = 3;
        end
        
        3: begin
          read_dn_r = 1'b z;
          
          rst = 1;

          bus_busy_r = 1'b 1;
          
          if(state == `FINISH_END) begin
          end else begin
            ext_rst_e = 1;
          end
          
          rst_state = 4;
        end
        
        4: begin
          ext_dispatcher_q = 1;
          
          rst_state = 5;
        end
        
      endcase

    end else begin      // end of RESET
      
      if(bus_busy == 1) begin
      end else begin

        if(disp_online == 1) begin
          if(
            read_q == 1 ||
            write_q == 1
          ) begin
            ext_next_cpu_e = 1;
          end 
          else if(ext_next_cpu_e == 1) begin
            ext_next_cpu_e = 1'bz;
            disp_online = 0;
          end
        end
      
        if(ext_next_cpu_q == 1 && 
           ext_cpu_index == cpu_index_r
        ) begin
          disp_online = 1;
          
          case(state)
            `WAIT_FOR_START: begin
              data_r = `CPU_R_START;
              base_addr_r = addr;
              ext_dispatcher_q = 1'b z;
              disp_online = 1;
              
//              ext_next_cpu_e = 1;
              
              next_state = 1;
              ext_next_cpu_e = 1;
            end
            
            `READ_COND, 
            `READ_COND_P,
            `READ_SRC1,
            `READ_SRC1_P,
            `READ_SRC0,
            `READ_SRC0_P,
            `START_READ_CMD,
            `START_READ_CMD_P: begin
                ext_dispatcher_q = 1;
            end
            
            `WRITE_REG_IP,
            `WRITE_DST,
            `WRITE_SRC1,
            `WRITE_SRC0,
            `WRITE_COND: begin
              ext_dispatcher_q = 1;
            end
            
            `FINISH_END: begin
              rst_state = 0; // = 1;
              ext_next_cpu_e = 1;
            end
            
            default: begin
              if(read_q == 1) begin
//                ext_read_q = 1;
              end else begin
//                data_r = `CPU_R_VOID;
              end
            end

          endcase
          
        end else 
        begin
          case(state)
            `START_BEGIN: begin
            
              data_r = base_addr_r;
              read_dn_r = 1;
            end
            
            `READ_COND, 
            `READ_COND_P,
            `READ_SRC1,
            `READ_SRC1_P,
            `READ_SRC0,
            `READ_SRC0_P,
            `START_READ_CMD,
            `START_READ_CMD_P: begin
              ext_dispatcher_q = 1;
            end
            
            `WRITE_REG_IP,
            `WRITE_DST,
            `WRITE_SRC1,
            `WRITE_SRC0,
            `WRITE_COND: begin
              ext_dispatcher_q = 1;
            end
            
            `FINISH_END: begin
              rst_state = 0; // = 1;
            end
            
            default: begin
              ext_dispatcher_q = 1'b z;
              cpu_index_itf = 32'h zzzzzzzz;
            end
            
          endcase
          
        end
      end
    end
  end

endmodule

