

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
  reg [`ADDR_SIZE0:0] base_addr_r;
  
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

  inout  wire [`DATA_SIZE0:0] src0;
  reg [`DATA_SIZE0:0] src0_r_adr;
  reg [`DATA_SIZE0:0] src0_r;
  assign src0 = src0_r;
  reg src0_waiting;

  inout  wire [`DATA_SIZE0:0] dst;
  reg [`DATA_SIZE0:0] dst_r_adr;
  reg [`DATA_SIZE0:0] dst_r;
  assign dst = dst_r;
  reg dst_waiting;

  inout  wire [`DATA_SIZE0:0] cond;
  reg [`DATA_SIZE0:0] cond_r_adr;
  reg [`DATA_SIZE0:0] cond_r;
  assign cond = cond_r;
  reg cond_waiting;
  
  output reg next_state;
  
  input wire rst;
  
  
  reg [8:0] progress;


  always @(posedge clk) begin
    addr_r = 32'h zzzzzzzz;
//     $monitor("state=%b  nxt=%b  progr=%b S0ptr=%b",state,next_state,progress,isRegS0Ptr);

  if(rst == 1) begin
    read_q = 0;
    write_q = 0;
    read_e = 0;
    write_e = 0;
    progress = `MEM_BEGIN;
    addr_r = 32'h zzzzzzzz;
    base_addr_r = 0;
    next_state = 1'b z;
    
    dst_r = 32'h55;
    
    data_r = 32'h zzzzzzzz;
    is_bus_busy_r = 1'b z;
    
    src1_waiting = 0; src0_waiting = 0; dst_waiting = 0; cond_waiting = 0; 
  end
  else begin
     
    next_state = 1'b z;
    read_e = 0;
    write_e = 0;
     
    case(state)
      `BASE_ADDR_SET: begin
        base_addr_r = base_addr;
        progress = `MEM_BEGIN;
        next_state = 1;
      end
      
      `READ_DATA: begin
        $monitor("progress=%b",progress);
        case(progress)
        `MEM_BEGIN: begin
          if(regCondFlags == 2'b 11) begin
            cond_r = 1;
            progress = `MEM_RD_SRC1_BEGIN;
          end else begin
            cond_r_adr = base_addr_r + regNumCnd * ((`DATA_SIZE0+1)/8);
            addr_r = cond_r_adr;
            read_q = 1;
            progress = `MEM_REG_COND_TRAP;
          end
        end
        
        `MEM_REG_COND_TRAP: begin
          read_q = 0;
          if(read_dn == 1) begin
            
            if(isRegCondPtr==1) begin
              cond_r_adr = data;
              addr_r = data; //cond_r_aux;
              read_q = 1;
               progress = `MEM_REG_COND_PTR_TRAP;
            end else begin
              cond_r = data;
              progress = `MEM_RD_SRC1_BEGIN;
            end
            
            read_e = 0;
            next_state = 1'b z;
          end
        end
        
        `MEM_REG_COND_PTR_TRAP: begin
          read_q = 0;
          if(read_dn == 1) begin
            cond_r = data;
            
            read_e = 0;
            next_state = 1'b z;
            progress = `MEM_RD_SRC1_BEGIN;
          end
        end
        
        `MEM_RD_SRC1_BEGIN: begin
          if(regS1Flags == 2'b 11) begin
            src1_r = 1;
            progress = `MEM_RD_SRC0_BEGIN;
          end else begin
            src1_r_adr = base_addr_r + regNumS1 * ((`DATA_SIZE0+1)/8);
            addr_r = src1_r_adr;
            read_q = 1;
            progress = `MEM_REG_SRC1_TRAP;
          end
        end
        
        `MEM_REG_SRC1_TRAP: begin
          read_q = 0;
          if(read_dn == 1) begin
            if(isRegS1Ptr==1) begin
              src1_r_adr = data;
              addr_r = data;
              read_q = 1;
              progress = `MEM_REG_SRC1_PTR_TRAP;
            end else begin
              src1_r = data;
              progress = `MEM_RD_SRC0_BEGIN;
            end
            read_e = 0;
            next_state = 1'b z;
          end
        end
        
        `MEM_REG_SRC1_PTR_TRAP: begin
          read_q = 0;
          if(read_dn == 1) begin
            src1_r = data;
            
            read_e = 0;
            next_state = 1'b z;
            progress = `MEM_RD_SRC0_BEGIN;
          end
        end
        
        `MEM_RD_SRC0_BEGIN: begin
          if(regS0Flags == 2'b 11) begin
            src0_r = 1;
            progress = `MEM_BEGIN;
          end else begin
            src0_r_adr = base_addr_r + regNumS0 * ((`DATA_SIZE0+1)/8);
            addr_r = src0_r_adr;
            read_q = 1;
            progress = `MEM_REG_SRC0_TRAP;
          end
        end
        
        `MEM_REG_SRC0_TRAP: begin
          read_q = 0;
          if(read_dn == 1) begin
            if(isRegS0Ptr == 1) begin
              src0_r_adr = data;
              addr_r = data;
              read_q = 1;
              
              next_state = 1'b z;
              
              progress = `MEM_REG_SRC0_PTR_TRAP;
            end else begin
              src0_r = data;
              read_e = 1;
              next_state = 1'b 1;
              progress = `MEM_BEGIN;
            end
          end
        end
        
        `MEM_REG_SRC0_PTR_TRAP: begin
          read_q = 0;
          if(read_dn == 1) begin
            src0_r = data;
            
            read_e = 1;
            next_state = 1'b 1;
            progress = `MEM_BEGIN;
          end
        end

        endcase
      end
 
 
      `WRITE_DATA: begin
        case(progress)
        `MEM_BEGIN: begin
          addr_r = base_addr_r + regNumD * ((`DATA_SIZE0+1)/8);
          data_r = dst_r;
          write_q = 1;
          progress = 1;
        end
        
        1: begin
          write_q = 0;
          progress = `MEM_BEGIN;
          next_state = 1;
          write_e = 1;
          data_r = 32'h zzzzzzzz;
        end
        
        endcase
      end
    endcase
//    if(state == `
//    if(state == `READ_DATA) begin
//    end
  end
  
  end

  
endmodule

