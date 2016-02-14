

`include "sizes.v"
`include "states.v"
`include "misc_codes.v"



module StartManager (
            clk, 
				clk_oe,
				
            state,
            
            base_addr,
            command,
            
            cpu_ind_rel,
            halt_q,
            rw_halt,
            
            is_bus_busy,
            addr_in,
//				addr_out,
//            read_q,
//            write_q,
            data_in,
				data_out,
            read_dn,
            write_dn,
//            read_e,
//            write_e,
            
            disp_online,
            
            cmd_ptr,
           // cond,
            
            next_state,
            
            rst
            );
            
  input wire disp_online;
  
  input wire clk_oe;
            
  input wire clk;
  input wire [`STATE_SIZE0:0] state;
  input wire [31:0] command;
//  reg [31:0] command_r;
//  wire [31:0] command = command_r;
  
  output reg [`ADDR_SIZE0:0] cmd_ptr;
//  reg cmd_ptr_waiting;
//  reg cmd_waiting;

  
//  output reg [`ADDR_SIZE0:0] base_addr;
  input wire [`ADDR_SIZE0:0] base_addr;
//  reg [`ADDR_SIZE0:0] base_addr_r;
  
  input tri [1:0] cpu_ind_rel;
  
  inout halt_q;
  reg halt_q_r;
  tri halt_q; // = halt_q_r;
  
  inout rw_halt;
  reg rw_halt_r;
  tri rw_halt = rw_halt_r;
  /*
   = (halt_q == 0) 
                  ? 1'bz
                  :
                (
                
                  addr == ip_addr && !(read_q == 1 || write_q == 1)
                ) 
                ? 1
                : 1'bz
                ;
  */
  
  input [`ADDR_SIZE0:0] addr_in;
//  output [`ADDR_SIZE0:0] addr_out;
  reg [`ADDR_SIZE0:0] addr_r;
  tri [`ADDR_SIZE0:0] addr_in;
  
  //tri [`ADDR_SIZE0:0] addr_out 
  /*= (
                        state == `START_READ_CMD   ||
                        state == `START_READ_CMD_P   ||
                        state == `WRITE_REG_IP
                        ) &&
                        disp_online == 1 
//                        && (!ext_next_cpu_e == 1)
                        ? addr_r
                        : `ADDR_SIZE'h zzzzzzzz
                        */
	//							;
  
//  output wire read_q;
//  output wire write_q;

  input is_bus_busy;
//  reg is_bus_busy_r;
  wire is_bus_busy; // = is_bus_busy_r;
  
  input [`DATA_SIZE0:0] data_in;
  output [`DATA_SIZE0:0] data_out;
  reg [`DATA_SIZE0:0] data_r;
  tri [`DATA_SIZE0:0] data_in;
  tri [`DATA_SIZE0:0] data_out = (
                        state == `WRITE_REG_IP
                        ) &&
                        disp_online == 1 
//                        && (!ext_next_cpu_e == 1)
                        ? data_r
                        : `DATA_SIZE'h zzzzzzzz;
//  assign data = write_q==1 ? dst_r : 32'h z;
  
  input  tri read_dn;
  input  tri write_dn;
//  output reg read_e;
//  output reg write_e;
  
//  input wire disp_online;
  
  output next_state;
  reg next_state_r;
  tri next_state = next_state_r;
  
  input wire rst;
  
  wire [`ADDR_SIZE0:0] ip_addr = base_addr + `REG_IP;
  reg ip_addr_saved;
  reg ip_addr_to_read;
  
  reg write_wait;
  
  reg single;
  
  reg started;
  
  
  
  always @(posedge clk) begin
  
    if(clk_oe == 0) begin
	 
    addr_r = 32'h zzzzzzzz;
    data_r = 32'h zzzzzzzz;
    
    next_state_r = 1'b 0;
//    next_state_r = 1'b z;
    

    rw_halt_r = 1'bz;
/*
    if(halt_q === 1) begin
//      case(state)
//        `START_READ_CMD_P,
//        `WRITE_REG_IP,
//        `START_READ_CMD: begin
          if(cpu_ind_rel === 2'b01) begin
            if(
              ip_addr_saved == 0 
              && write_wait == 1
//              && state <= `WRITE_REG_IP
            ) begin
              rw_halt_r = (addr === ip_addr) ? 1 : 1'bz;
              
//              ip_addr_to_read = 0;
            end 
          end 
//        end
//        
//      endcase
    end
*/
    
    if(rw_halt === 1) begin
      ip_addr_to_read = 0;
    end
    
/*
*/
//    is_bus_busy_r = 1'b z;

//     $monitor("state=%b  nxt=%b  progr=%b S0ptr=%b",state,next_state,progress,isRegS0Ptr);

  end else begin

  if(rst == 1) begin
//    command_r = 32'h zzzzzzzz;

//    read_q = 1'b z;
//    write_q = 1'b z;

//    base_addr = 1;
    next_state_r = 1'b 0;
//    next_state_r = 1'b z;
    
//    cmd_waiting = 0; cmd_ptr_waiting = 0;
    
    ip_addr_saved = 0;
    ip_addr_to_read = 0;
    
    halt_q_r = 1'b z;
    
    write_wait = 0;
    
    single = 1;
    
    started = 0;
  end
  else begin
    
//    data_r = `DATA_SIZE'h zzzzzzzz;
//    next_state_r = 1'b z;
//    read_e = 1'b z;
//    write_e = 1'b z;

    if(disp_online == 0) begin single = 1; end
    
/*
    if(is_bus_busy === 1) begin
//      addr_r = `ADDR_SIZE'h zzzzzzzz;

      case(state)
        `START_READ_CMD: begin
          if(
              (read_dn === 1 && ip_addr_to_read == 1) //||
              //(write_dn == 1)
          ) begin
            if(addr === ip_addr) begin
              ip_addr_to_read = 0;
              cmd_ptr = data;
              next_state_r = 1;
            end
          end
        end
        
        `START_READ_CMD_P: begin
          if(read_dn === 1) begin
            if(addr === cmd_ptr) begin
              command_r = data;
              next_state_r = 1;
            end
          end
        end
        
        `WRITE_REG_IP: begin
          if(write_dn === 1 && addr === ip_addr) begin
            ip_addr_saved = 1;
            
            write_wait = 0;
            
            next_state_r = 1;
          end
        end
           
      endcase

    end else begin
*/
 
      case(state)
        `START_BEGIN: begin
//          if(started == 0) begin
            data_r = `DATA_SIZE'h zzzzzzzz;
//            base_addr = data;
            
            cmd_ptr = ip_addr;
            
            write_wait = 1;
            
            started = 1;
            
//            next_state_r = 1;
//          end
        end

/*        
        `START_READ_CMD: begin
          if(read_q === 1) begin
            read_q = 1'b z;
            halt_q_r = 1'b z;
          end else
          if(disp_online == 1 && single == 1) begin
            ip_addr_to_read = 1;
            
            ip_addr_saved = 0;
            addr_r = cmd_ptr;
            read_q = 1;
            halt_q_r = 1;
            
            single = 0;
          end
        end

        `START_READ_CMD_P: begin
          if(read_q == 1) begin
            read_q = 1'b z;
            halt_q_r = 1'b z;
          end else
          if(disp_online == 1 && single == 1) begin
            addr_r = cmd_ptr; //cond_r_aux;
            read_q = 1;
            halt_q_r = 1;
            
            single = 0;
          end
        end
        
        `PREEXECUTE: begin
            cmd_ptr = cmd_ptr + 1;
            
            next_state_r = 1;
        end

        `WRITE_REG_IP: begin
          if(write_q === 1) begin
            write_q = 1'b z;
            halt_q_r = 1'b z;
          end else
          if(disp_online == 1 && single == 1) begin
            addr_r = ip_addr;
//            cmd_ptr = cmd_ptr + 1;
            data_r = cmd_ptr;
            write_q = 1;
            halt_q_r = 1;
            
            single = 0;
          end
        end
*/
        
      endcase
      
//    end
  
  end
  
  end
  
  end

  
endmodule

