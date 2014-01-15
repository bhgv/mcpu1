

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
            
            disp_online,
            
           // cond,
            
            next_state,
            
            rst
            );
  input wire clk;
  input wire [`STATE_SIZE0:0] state;
  output reg [31:0] command;
  
  reg [`ADDR_SIZE0:0] cmd_ptr;
//  reg cmd_ptr_waiting;
//  reg cmd_waiting;

  
  output reg [`ADDR_SIZE0:0] base_addr;
//  reg [`ADDR_SIZE0:0] base_addr_r;
  
  inout [`ADDR_SIZE0:0] addr;
  reg [`ADDR_SIZE0:0] addr_r;
  wire [`ADDR_SIZE0:0] addr = (
                        state == `START_READ_CMD   ||
                        state == `START_READ_CMD_P   ||
                        state == `WRITE_REG_IP
                        ) &&
                        disp_online == 1 
//                        && (!ext_next_cpu_e == 1)
                        ? addr_r
                        : `ADDR_SIZE'h zzzzzzzz;
  
  output reg read_q;
  output reg write_q;

  inout is_bus_busy;
  reg is_bus_busy_r;
  wire is_bus_busy = is_bus_busy_r;
  
  inout [`DATA_SIZE0:0] data;
  reg [`DATA_SIZE0:0] data_r;
  wire [`DATA_SIZE0:0] data = (
                        state == `WRITE_REG_IP
                        ) &&
                        disp_online == 1 
//                        && (!ext_next_cpu_e == 1)
                        ?data_r
                        : `DATA_SIZE'h zzzzzzzz;
//  assign data = write_q==1 ? dst_r : 32'h z;
  
  input  wire read_dn;
  input  wire write_dn;
  output reg read_e;
  output reg write_e;
  
  input wire disp_online;
  
  output reg next_state;
  
  input wire rst;
  
  wire [`ADDR_SIZE0:0] ip_addr = base_addr + `REG_IP;
  
  reg single;
  

  always @(posedge clk) begin
    addr_r = 32'h zzzzzzzz;
    data_r = 32'h zzzzzzzz;

    is_bus_busy_r = 1'b z;

//     $monitor("state=%b  nxt=%b  progr=%b S0ptr=%b",state,next_state,progress,isRegS0Ptr);

  if(rst == 1) begin
    read_q = 1'b z;
    write_q = 1'b z;

    base_addr = 0;
    next_state = 1'b z;
    
//    cmd_waiting = 0; cmd_ptr_waiting = 0;
    
    single = 1;
  end
  else begin
     
    data_r = `DATA_SIZE'h zzzzzzzz;
    next_state = 1'b z;
    read_e = 1'b z;
    write_e = 1'b z;

    if(disp_online == 0) single = 1;
    
    if(is_bus_busy == 1) begin
      addr_r = `ADDR_SIZE'h zzzzzzzz;

      case(state)
        `START_READ_CMD: begin
          if(read_dn == 1) begin
            if(addr == ip_addr) begin
              cmd_ptr = data;
              next_state = 1;
            end
          end
        end
        
        `START_READ_CMD_P: begin
          if(read_dn == 1) begin
            if(addr == cmd_ptr) begin
              command = data;
              next_state = 1;
            end
          end
        end
        
        `WRITE_REG_IP: begin
          if(write_dn == 1 && addr == ip_addr) begin
            next_state = 1;
          end
        end
           
      endcase

    end else begin
     
      case(state)
        `START_BEGIN: begin
          if(read_dn == 1) begin
            data_r = `DATA_SIZE'h zzzzzzzz;
            base_addr = data;
            
            cmd_ptr = ip_addr;
            
            next_state = 1;
          end
        end
        
        `START_READ_CMD: begin
          if(read_q == 1) begin
            read_q = 1'b z;
          end else
          if(disp_online == 1 && single == 1) begin
            addr_r = cmd_ptr;
            read_q = 1;
            
            single = 0;
          end
        end

        `START_READ_CMD_P: begin
          if(read_q == 1) begin
            read_q = 1'b z;
          end else
          if(disp_online == 1 && single == 1) begin
            addr_r = cmd_ptr; //cond_r_aux;
            read_q = 1;
            
            single = 0;
          end
        end

        `WRITE_REG_IP: begin
          if(write_q == 1) begin
            write_q = 1'b z;
          end else
          if(disp_online == 1 && single == 1) begin
            addr_r = ip_addr;
            cmd_ptr = cmd_ptr + 1;
            data_r = cmd_ptr;
            write_q = 1;
            
            single = 0;
          end
        end
        
      endcase
      
    end
    
  end
  
  end

  
endmodule

