

`include "sizes.v"
`include "states.v"



module MemManager (
            clk, 
            state,
            
            base_addr,
            command_word,
            
            is_bus_busy,
            addr,
            read_q,
            write_q,
            data,
            read_dn,
            write_dn,
            read_e,
            write_e,
            
            src1,
            src0,
            dst,
            dst_h,
            cond,
            
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
  

  inout  wire [`DATA_SIZE0:0] src1;
  reg [`DATA_SIZE0:0] src1_r_adr;
  reg [`DATA_SIZE0:0] src1_r;
  assign src1 = src1_r;
  reg src1_waiting;
  reg src1ptr_waiting;

  inout  wire [`DATA_SIZE0:0] src0;
  reg [`DATA_SIZE0:0] src0_r_adr;
  reg [`DATA_SIZE0:0] src0_r;
  assign src0 = src0_r;
  reg src0_waiting;
  reg src0ptr_waiting;

  inout  wire [`DATA_SIZE0:0] dst;
  reg [`DATA_SIZE0:0] dst_r_adr;
  reg [`DATA_SIZE0:0] dst_r;
  assign dst = dst_r;
  reg dst_waiting;
  reg dstptr_waiting;
  
  input wire [`DATA_SIZE0:0] dst_h;
  reg [`DATA_SIZE0:0] dst_h_r;

  inout  wire [`DATA_SIZE0:0] cond;
  reg [`DATA_SIZE0:0] cond_r_adr;
  reg [`DATA_SIZE0:0] cond_r;
  assign cond = cond_r;
  reg cond_waiting;
  reg condptr_waiting;
  
  output reg next_state;
  
  input wire rst;
  
  
  reg [8:0] progress;


  always @(posedge clk) begin
    addr_r = 32'h zzzzzzzz;
//     $monitor("state=%b  nxt=%b  progr=%b S0ptr=%b",state,next_state,progress,isRegS0Ptr);

  if(rst == 1) begin
    read_q = 1'b z;
    write_q = 1'b z;
    read_e = 1'b z;
    write_e = 1'b z;
    progress = `MEM_BEGIN;
    addr_r = 32'h zzzzzzzz;
//    base_addr_r = 0;
    next_state = 1'b z;
    
    src1_r = 32'h zzzzzzzz;
    src0_r = 32'h zzzzzzzz;
    dst_r = 32'h zzzzzzzz;
    
    data_r = 32'h zzzzzzzz;
    is_bus_busy_r = 1'b z;
    
    src1_waiting = 0; src0_waiting = 0; dst_waiting = 0; cond_waiting = 0; 
    src1ptr_waiting = 0; src0ptr_waiting = 0; dstptr_waiting = 0; condptr_waiting = 0; 
  end
  else begin
     
    next_state = 1'b z;
    read_e = 1'b z;
    write_e = 1'b z;
    read_q = 1'b z;
    write_q = 1'b z;
    
    if(is_bus_busy == 1) begin
      
      if(read_dn == 1) begin
        addr_r = 32'h zzzzzzzz;
        
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

        end end
        if(src0_waiting == 1) begin if(
              (src0ptr_waiting == 0 && addr == src0_r_adr) || 
              (src0ptr_waiting == 1 && addr == src0_r)
        ) begin
          src0_r = data;
          
          src0_waiting = 0;
          if(isRegS0Ptr==1 && src0ptr_waiting==0) begin
            src0ptr_waiting = 1;
          end else begin
            src0ptr_waiting = 0;
          end

        end end
        if(cond_waiting == 1) begin if(
              (condptr_waiting == 0 && addr == cond_r_adr) || 
              (condptr_waiting == 1 && addr == cond_r)
        ) begin
          cond_r = data;
          
          cond_waiting = 0;
          if(isRegCondPtr==1 && condptr_waiting==0) begin
            condptr_waiting = 1;
          end else begin
            condptr_waiting = 0;
          end

        end end
      end
    
    end else begin
     
      case(state)
//        `BASE_ADDR_SET: begin
//          base_addr_r = base_addr;
//          progress = `MEM_BEGIN;
//          next_state = 1;
//        end
        
        `READ_COND: begin
//          $monitor("progress=%b",progress);
          case(progress)
          `MEM_BEGIN: begin
            if(regCondFlags == 2'b 11) begin
              cond_r = 1;
              progress = `MEM_RD_SRC1_BEGIN;
              next_state = 1;
            end else begin
              cond_r_adr = base_addr + regNumCnd /* `DATA_SIZE*/;
              addr_r = cond_r_adr;
              read_q = 1;
              cond_waiting = 1;
              progress = `MEM_WAIT_FOR_READ_REGS; //MEM_RD_SRC1_BEGIN; //MEM_REG_COND_TRAP;
            end
          end
          
          `MEM_WAIT_FOR_READ_REGS: begin
//            if(src1_waiting == 0 && src1ptr_waiting == 1) begin
//              addr_r = src1_r; //cond_r_aux;
//              src1_r_adr = src1_r;
//              read_q = 1;
//              src1_waiting = 1; 
//            end else if(src0_waiting == 0 && src0ptr_waiting == 1) begin
//              addr_r = src0_r; //cond_r_aux;
//              src0_r_adr = src0_r;
//              read_q = 1;
//              src0_waiting = 1;
//            end else 
            if(cond_waiting == 0 && condptr_waiting == 1) begin
              addr_r = cond_r; //cond_r_aux;
              cond_r_adr = cond_r;
              read_q = 1;
              cond_waiting = 1;
            end else if( (/*src1_waiting | src0_waiting |*/ cond_waiting) == 0) begin
                read_e = 1;
                next_state = 1'b 1;
  
                progress = `MEM_RD_SRC1_BEGIN;  //MEM_BEGIN; //MEM_REG_SRC0_TRAP;
            end
          end
          
          endcase
        end

        `READ_DATA: begin
          case(progress)
          `MEM_RD_SRC1_BEGIN: begin
            if(regS1Flags == 2'b 11) begin
              src1_r = 1;
              progress = `MEM_RD_SRC0_BEGIN;
            end else begin
              src1_r_adr = base_addr + regNumS1 /* `DATA_SIZE*/;
              addr_r = src1_r_adr;
              read_q = 1;
              src1_waiting = 1;
              progress = `MEM_RD_SRC0_BEGIN; //MEM_REG_SRC1_TRAP;
            end
          end

          `MEM_RD_SRC0_BEGIN: begin
            if(regS0Flags == 2'b 11) begin
              src0_r = 1;
              progress = `MEM_BEGIN;
            end else begin
              src0_r_adr = base_addr + regNumS0 /* `DATA_SIZE*/;
              addr_r = src0_r_adr;
              read_q = 1;
              src0_waiting = 1;
              progress = `MEM_WAIT_FOR_READ_REGS;
            end
          end
          
          `MEM_WAIT_FOR_READ_REGS: begin
            if(src1_waiting == 0 && src1ptr_waiting == 1) begin
              addr_r = src1_r; //cond_r_aux;
              src1_r_adr = src1_r;
              read_q = 1;
              src1_waiting = 1; 
            end else if(src0_waiting == 0 && src0ptr_waiting == 1) begin
              addr_r = src0_r; //cond_r_aux;
              src0_r_adr = src0_r;
              read_q = 1;
              src0_waiting = 1;
//            end else if(cond_waiting == 0 && condptr_waiting == 1) begin
//              addr_r = cond_r; //cond_r_aux;
//              cond_r_adr = cond_r;
//              read_q = 1;
//              cond_waiting = 1;
            end else if( (src1_waiting | src0_waiting | cond_waiting) == 0) begin
                read_e = 1;
                next_state = 1'b 1;
  
                progress = `MEM_BEGIN; //MEM_REG_SRC0_TRAP;
            end
             
          end

          endcase
        end
   
   
        `WRITE_DATA: begin
          case(progress)
          `MEM_BEGIN: begin
            dst_r = (regDFlags == 2'b 01 ? dst+1 : 
                      regDFlags == 2'b 10 ? dst-1 : 
                                            dst );
            data_r = dst_r;
            addr_r = base_addr + regNumD /* ((`DATA_SIZE0+1)/8)*/;
            write_q = 1;
            progress = `MEM_WR_DST_WAIT;
          end
          
          `MEM_WR_DST_WAIT: begin
            write_q = 1'b z;
            if(write_dn == 1) begin
              progress = `MEM_WR_SRC_REGS;
//              next_state = 1;
//              write_e = 1;
//              addr_r = 32'h zzzzzzzz;
//              data_r = 32'h zzzzzzzz;
            end
          end
          
          `MEM_WR_SRC_REGS: begin
            if(^regCondFlags == 1 && condptr_waiting == 0) begin
              if(regCondFlags == 2'b 01) begin
                data_r = (isRegCondPtr==1 ? cond_r_adr : cond_r)+1;
              end else if(regCondFlags == 2'b 10) begin
                data_r = (isRegCondPtr==1 ? cond_r_adr : cond_r)-1;
              end
              //data_r = cond_r;
              addr_r = base_addr + regNumCnd;
              cond_waiting = 1;
              write_q = 1;
              progress = `MEM_WR_SRC_REGS_WAIT;
            end else
            if(^regS1Flags == 1 && src1ptr_waiting == 0 && cond_r != 0) begin
              if(regS1Flags == 2'b 01) begin
                data_r = (isRegS1Ptr==1 ? src1_r_adr : src1_r)+1;
              end else if(regS1Flags == 2'b 10) begin
                data_r = (isRegS1Ptr==1 ? src1_r_adr : src1_r)-1;
              end
              //data_r = src1_r;
              addr_r = base_addr + regNumS1;
              src1_waiting = 1;
              write_q = 1;
              progress = `MEM_WR_SRC_REGS_WAIT;
            end else
            if(^regS0Flags == 1 && src0ptr_waiting == 0 && cond_r != 0) begin
              if(regS0Flags == 2'b 01) begin
                data_r = (isRegS0Ptr==1 ? src0_r_adr : src0_r)+1;
              end else if(regS0Flags == 2'b 10) begin
                data_r = (isRegS0Ptr==1 ? src0_r_adr : src0_r)-1;
              end
              //data_r = src0_r;
              addr_r = base_addr + regNumS0;
              src0_waiting = 1;
              write_q = 1;
              progress = `MEM_WR_SRC_REGS_WAIT;
            end else begin
              condptr_waiting = 0;
              src1ptr_waiting = 0;
              src0ptr_waiting = 0;
              progress = `MEM_BEGIN;
              addr_r = 32'h zzzzzzzz;
              data_r = 32'h zzzzzzzz;
              next_state = 1;
              write_e = 1;
            end
          
          end
          
          `MEM_WR_SRC_REGS_WAIT: begin
            write_q = 1'b z;
            if(write_dn == 1) begin
              if(cond_waiting == 1) begin
                cond_waiting = 0;
                condptr_waiting = 1;
              end else
              if(src1_waiting == 1) begin
                src1_waiting = 0;
                src1ptr_waiting = 1;
              end else
              if(src0_waiting == 1) begin
                src0_waiting = 0;
                src0ptr_waiting = 1;
              end
              progress = `MEM_WR_SRC_REGS;
            end

          end
          
          endcase
        end
      endcase
      
    end
    
  end
  
  end

  
endmodule

