

`include "sizes.v"
`include "states.v"



module MemManager (
            clk, 
            state,
            
            base_addr,
            command_word,
            
            is_bus_busy,
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
            
            rst
            );
  input wire clk;
  input wire [`STATE_SIZE0:0] state;
  input wire [31:0] command_word;

  wire [3:0] regNumS1;
  assign regNumS1 = command_word[3:0];

  wire [3:0] regNumS0;
  assign regNumS0 = command_word[7:4];

  wire [3:0] regNumD;
  assign regNumD = command_word[11:8];

  wire [3:0] regNumCnd;
  assign regNumCnd = command_word[15:12];
  
  
  wire isRegS1Ptr;
  assign isRegS1Ptr = command_word[16];
  
  wire isRegS0Ptr;
  assign isRegS0Ptr = command_word[17];
  
  wire isRegDPtr;
  assign isRegDPtr = command_word[18];
  
  wire isRegCondPtr;
  assign isRegCondPtr = command_word[19];
  
  
  wire [1:0] regS1Flags;
  assign regS1Flags = command_word[21:20];
  
  wire [1:0] regS0Flags;
  assign regS0Flags = command_word[23:22];
  
  wire [1:0] regDFlags;
  assign regDFlags = command_word[25:24];
  
  wire [1:0] regCondFlags;
  assign regCondFlags = command_word[27:26];
  
//  wire ifPtr;
  
  input wire [`ADDR_SIZE0:0] base_addr;
//  reg [`ADDR_SIZE0:0] base_addr_r;
  
  inout [`ADDR_SIZE0:0] addr;
  reg [`ADDR_SIZE0:0] addr_r;
  wire [`ADDR_SIZE0:0] addr  = (
                        state == `READ_COND ||
                        state == `READ_COND_P ||
                        state == `READ_SRC1 ||
                        state == `READ_SRC1_P ||
                        state == `READ_SRC0 ||
                        state == `READ_SRC0_P ||
                        
                        state == `WRITE_DST    ||
                        state == `WRITE_SRC1   ||
                        state == `WRITE_SRC0   ||
                        state == `WRITE_COND
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
  wire [`DATA_SIZE0:0] data = data_r;
//  assign data = write_q==1 ? dst_r : 32'h z;
  
  input  wire read_dn;
  input  wire write_dn;
  output reg read_e;
  output reg write_e;
  

  inout  wire [`DATA_SIZE0:0] src1;
  reg [`DATA_SIZE0:0] src1_r_adr;
  reg [`DATA_SIZE0:0] src1_r;
  assign src1 = src1_r;
//  reg src1_waiting;
//  reg src1ptr_waiting;

  inout  wire [`DATA_SIZE0:0] src0;
  reg [`DATA_SIZE0:0] src0_r_adr;
  reg [`DATA_SIZE0:0] src0_r;
  assign src0 = src0_r;
//  reg src0_waiting;
//  reg src0ptr_waiting;

  inout  wire [`DATA_SIZE0:0] dst;
  reg [`DATA_SIZE0:0] dst_r_adr;
  reg [`DATA_SIZE0:0] dst_r;
  assign dst = dst_r;
//  reg dst_waiting;
//  reg dstptr_waiting;
  
  input wire [`DATA_SIZE0:0] dst_h;
  reg [`DATA_SIZE0:0] dst_h_r;

  inout  wire [`DATA_SIZE0:0] cond;
  reg [`DATA_SIZE0:0] cond_r_adr;
  reg [`DATA_SIZE0:0] cond_r;
  assign cond = cond_r;
//  reg cond_waiting;
//  reg condptr_waiting;
  
  input wire disp_online;
  
  output reg next_state;
  
  input wire rst;
  
  reg single;
  
  

  always @(posedge clk) begin
    addr_r = 32'h zzzzzzzz;
    data_r = 32'h zzzzzzzz;

    is_bus_busy_r = 1'b z;

//     $monitor("state=%b  nxt=%b  progr=%b S0ptr=%b",state,next_state,progress,isRegS0Ptr);

  if(rst == 1) begin
    read_q = 1'b z;
    write_q = 1'b z;

    addr_r = 32'h zzzzzzzz;

    next_state = 1'b z;
    
    cond_r = 1; //32'h zzzzzzzz;
    src1_r = 1; //32'h zzzzzzzz;
    src0_r = 1; //32'h zzzzzzzz;
    dst_r = 32'h zzzzzzzz;
   
//    src1_waiting = 0; src0_waiting = 0; dst_waiting = 0; cond_waiting = 0; 
//    src1ptr_waiting = 0; src0ptr_waiting = 0; dstptr_waiting = 0; condptr_waiting = 0; 
    
    single = 0;
  end
  else begin
     
    next_state = 1'b z;

    read_q = 1'b z;
    write_q = 1'b z;
    
    
    if(disp_online == 0) single = 1;
    
    
    if(is_bus_busy == 1) begin
      
        addr_r = `ADDR_SIZE'h zzzzzzzz;
        
        case(state)
          `READ_COND: begin
            if(read_dn == 1) begin
                if(addr == cond_r_adr) begin
                  cond_r = data;
                  next_state = 1;
                end
            end
          end
        
          `READ_COND_P: begin
            if(read_dn == 1) begin
                if(addr == cond_r) begin
                  cond_r = data;
                  next_state = 1;
                end
            end
          end

          `READ_SRC1: begin
            if(read_dn == 1) begin
                if(addr == src1_r_adr) begin
                  src1_r = data;
                  next_state = 1;
                end
            end
          end
        
          `READ_SRC1_P: begin
            if(read_dn == 1) begin
                if(addr == src1_r) begin
                  src1_r = data;
                  next_state = 1;
                end
            end
          end
        
          `READ_SRC0: begin
            if(read_dn == 1) begin
                if(addr == src0_r_adr) begin
                  src0_r = data;
                  next_state = 1;
                end
            end
          end
        
          `READ_SRC0_P: begin
            if(read_dn == 1) begin
                if(addr == src0_r) begin
                  src0_r = data;
                  next_state = 1;
                end
            end
          end

        `WRITE_DST: begin
          if(write_dn == 1 && addr == (base_addr + regNumD)) begin
             next_state = 1;
          end
        end
           
        `WRITE_COND: begin
          if(write_dn == 1 && addr == (base_addr + regNumCnd)) begin
             next_state = 1;
          end
        end
           
        `WRITE_SRC1: begin
          if(write_dn == 1 && addr == (base_addr + regNumS1)) begin
             next_state = 1;
          end
        end
           
        `WRITE_SRC0: begin
          if(write_dn == 1 && addr == (base_addr + regNumS0)) begin
             next_state = 1;
          end
        end

        endcase
        
/*
        if(src1_waiting == 1) begin if(
              (src1ptr_waiting == 0 && addr == src1_r_adr) || 
              (src1ptr_waiting == 1 && addr == src1_r)
        ) begin
          src1_r = data;
          
          src1_waiting = 0;
          if(isRegS1Ptr==1 && src1ptr_waiting==0) begin
            src1ptr_waiting = 1;
          end else begin
            src1ptr_waiting = 0;
          end
          
          next_state = 1;

        end end
        ... ... ...
*/
/*
      end
      else
      if(
          write_dn == 1  && 
          (
          (state == `WRITE_DST  && addr == base_addr + regNumD) ||
          (state == `WRITE_SRC1 && addr == base_addr + regNumS1) ||
          (state == `WRITE_SRC0 && addr == base_addr + regNumS0) ||
          (state == `WRITE_COND && addr == base_addr + regNumCnd)
          )
      ) begin
        addr_r = 32'h zzzzzzzz;
        data_r = 32'h zzzzzzzz;
        next_state = 1;
      end
*/
    end else begin
     
      case(state)
        `WRITE_REG_IP: begin
          cond_r_adr = base_addr + regNumCnd /* `DATA_SIZE*/;
          src1_r_adr = base_addr + regNumS1 /* `DATA_SIZE*/;
          src0_r_adr = base_addr + regNumS0 /* `DATA_SIZE*/;
        end
        
        `READ_COND: begin
          if(read_q == 1) begin
            addr_r = `ADDR_SIZE'h zzzzzzzz;
            read_q = 1'bz;
          end else
          if(disp_online == 1 && single == 1) begin
            addr_r = cond_r_adr;
            read_q = 1;
                
            single = 0;
          end
        end
          
        `READ_COND_P: begin
          if(read_q == 1) begin
            addr_r = `ADDR_SIZE'h zzzzzzzz;
            read_q = 1'bz;
          end else
          if(disp_online == 1 && single == 1) begin
            addr_r = cond_r; //cond_r_aux;
            cond_r_adr = cond_r;
            read_q = 1;
            
            single = 0;
          end
        end

        `READ_SRC1: begin
          if(read_q == 1) begin
            addr_r = `ADDR_SIZE'h zzzzzzzz;
            read_q = 1'bz;
          end else 
          if(disp_online == 1 && single == 1) begin
            addr_r = src1_r_adr;
            read_q = 1;

            single = 0;
          end  
        end
          
        `READ_SRC1_P: begin
          if(read_q == 1) begin
            addr_r = `ADDR_SIZE'h zzzzzzzz;
            read_q = 1'bz;
          end else
          if(disp_online == 1 && single == 1) begin
            addr_r = src1_r; //cond_r_aux;
            src1_r_adr = src1_r;
            read_q = 1;
            
            single = 0;
          end
        end

        `READ_SRC0: begin
          if(read_q == 1) begin
            addr_r = `ADDR_SIZE'h zzzzzzzz;
            read_q = 1'bz;
          end else //begin
          if(disp_online == 1 && single == 1) begin
            addr_r = src0_r_adr;
            read_q = 1;

            single = 0;
          end
        end
         
        `READ_SRC0_P: begin
          if(read_q == 1) begin
            addr_r = `ADDR_SIZE'h zzzzzzzz;
            read_q = 1'bz;
          end else
          if(disp_online == 1 && single == 1) begin
            addr_r = src0_r; //cond_r_aux;
            src0_r_adr = src0_r;
            read_q = 1;
            
            single = 0;
          end
        end

        `WRITE_DST: begin
          if(write_q == 1) begin
            write_q = 1'bz;
          end else
          if(disp_online == 1 && single == 1) begin
            dst_r = (regDFlags == 2'b 01 ? dst+1 : 
                     regDFlags == 2'b 10 ? dst-1 : 
                                           dst );
            data_r = dst_r;
            addr_r = base_addr + regNumD /* ((`DATA_SIZE0+1)/8)*/;
            write_q = 1;
            
            single = 0;
          end
        end

        `WRITE_COND: begin
          if(disp_online == 1 && single == 1) begin
            if(regCondFlags == 2'b 01) begin
              data_r = (isRegCondPtr==1 ? cond_r_adr : cond_r)+1;
            end else if(regCondFlags == 2'b 10) begin
              data_r = (isRegCondPtr==1 ? cond_r_adr : cond_r)-1;
            end
            addr_r = base_addr + regNumCnd;
            write_q = 1;
            
            single = 0;
          end
        end
        
        `WRITE_SRC1: begin
          if(disp_online == 1 && single == 1) begin
            if(regS1Flags == 2'b 01) begin
              data_r = (isRegS1Ptr==1 ? src1_r_adr : src1_r)+1;
            end else if(regS1Flags == 2'b 10) begin
              data_r = (isRegS1Ptr==1 ? src1_r_adr : src1_r)-1;
            end
            addr_r = base_addr + regNumS1;
            write_q = 1;
            
            single = 0;
          end
        end
        
        `WRITE_SRC0: begin
          if(disp_online == 1 && single == 1) begin
            if(regS0Flags == 2'b 01) begin
              data_r = (isRegS0Ptr==1 ? src0_r_adr : src0_r)+1;
            end else if(regS0Flags == 2'b 10) begin
              data_r = (isRegS0Ptr==1 ? src0_r_adr : src0_r)-1;
            end
            addr_r = base_addr + regNumS0;
            write_q = 1;
            
            single = 0;
          end          
        end
        
      endcase
      
    end
    
  end
  
  end

  
endmodule

