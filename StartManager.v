

`include "sizes.v"
`include "states.v"



module StartManager (
            clk, 
            state,
            
            base_addr,
            command,
            
            is_bus_busy,
            addr,
            read_q,
            write_q,
            data,
            read_dn,
            write_dn,
            read_e,
            write_e,
            
           // cond,
            
            next_state,
            
            rst
            );
  input wire clk;
  input wire [`STATE_SIZE0:0] state;
  output reg [31:0] command;
  
  reg [`ADDR_SIZE0:0] cmd_ptr;
  reg cmd_ptr_waiting;
  reg cmd_waiting;

  
  output reg [`ADDR_SIZE0:0] base_addr;
//  reg [`ADDR_SIZE0:0] base_addr_r;
  
  inout [`ADDR_SIZE0:0] addr;
  reg [`ADDR_SIZE0:0] addr_r;
  wire [`ADDR_SIZE0:0] addr = addr_r;
  
  output reg read_q;
  output reg write_q;

  inout is_bus_busy;
  reg is_bus_busy_r;
  wire is_bus_busy = is_bus_busy_r;
  
  inout [`DATA_SIZE0:0] data;
  reg [`DATA_SIZE0:0] data_r;
  wire [`DATA_SIZE0:0] data = data_r;
//  assign data = write_q==1 ? dst_r : 32'h z;
  
  input  wire read_dn;
  input  wire write_dn;
  output reg read_e;
  output reg write_e;
  
  
  output reg next_state;
  
  input wire rst;
  
  
  reg [8:0] progress;


  always @(posedge clk) begin
    addr_r = 32'h zzzzzzzz;
    data_r = 32'h zzzzzzzz;
//     $monitor("state=%b  nxt=%b  progr=%b S0ptr=%b",state,next_state,progress,isRegS0Ptr);

  if(rst == 1) begin
    read_q = 1'b z;
    write_q = 1'b z;
    read_e = 1'b z;
    write_e = 1'b z;
    progress = `MEM_BEGIN;
    addr_r = 32'h zzzzzzzz;
    base_addr = 0;
    next_state = 1'b z;
    
//    dst_r = 32'h55;
    
    data_r = 32'h zzzzzzzz;
    is_bus_busy_r = 1'b z;
    
    cmd_waiting = 0; cmd_ptr_waiting = 0;
  end
  else begin
     
    data_r = 32'h zzzzzzzz;
    next_state = 1'b z;
    read_e = 1'b z;
    write_e = 1'b z;
    read_q = 1'b z;
    write_q = 1'b z;
    
    if(is_bus_busy == 1) begin
      
      if(read_dn == 1) begin
        addr_r = 32'h zzzzzzzz;
        
        if(cmd_waiting == 1) begin if(
              (cmd_ptr_waiting == 0 && addr == (base_addr + `REG_IP /** `DATA_SIZE*/)) || 
              (cmd_ptr_waiting == 1 && addr == cmd_ptr)
        ) begin
          
          cmd_waiting = 0;
          
//          cmd_ptr_waiting = 0;
          if(cmd_ptr_waiting==0) begin
            cmd_ptr = data;
            cmd_ptr_waiting = 1;
          end else begin
            command = data;
            cmd_ptr_waiting = 0;
          end

        end end
      end
    
    end else begin
     
      case(state)
        `START_BEGIN: begin
          if(read_dn == 1) begin
            data_r = 32'h zzzzzzzz;
            base_addr = data;
            progress = `MEM_BEGIN;
            next_state = 1;
          end
        end
        
        `START_READ_CMD: begin
//          $monitor("progress=%b",progress);
          case(progress)
            `MEM_BEGIN: begin
                cmd_ptr = base_addr + `REG_IP /* `DATA_SIZE*/;
                addr_r = cmd_ptr;
                read_q = 1;
                cmd_waiting = 1;
                progress = `MEM_WAIT_FOR_READ_REGS; //MEM_REG_COND_TRAP;
            end

            `MEM_WAIT_FOR_READ_REGS: begin
              if(cmd_waiting == 0 && cmd_ptr_waiting == 1) begin
                addr_r = cmd_ptr; //cond_r_aux;
                read_q = 1;
                cmd_waiting = 1; 
              end 
              else if( cmd_waiting /*| src0_waiting | cond_waiting)*/ == 0) begin
                  read_e = 1;
                  next_state = 1'b 1;
  
                  progress = `MEM_BEGIN; //MEM_REG_SRC0_TRAP;
              end
            end
          endcase
        end
   
   
        `WRITE_REG_IP: begin
          case(progress)
            `MEM_BEGIN: begin
              addr_r = base_addr + `REG_IP /* `DATA_SIZE*/;
              cmd_ptr = cmd_ptr + 1;
              data_r = cmd_ptr;
              write_q = 1;
              progress = 1;
            end
            
            1: begin
              write_q = 1'b z;
              if(write_dn == 1) begin
                 progress = `MEM_BEGIN;
                 next_state = 1;
                 write_e = 1;
                 addr_r = 32'h zzzzzzzz;
                data_r = 32'h zzzzzzzz;
              end
            end
          endcase
        end
      endcase
      
    end
    
  end
  
  end

  
endmodule

