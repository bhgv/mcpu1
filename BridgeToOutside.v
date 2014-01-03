


`include "sizes.v"
`include "states.v"



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
            
            next_state,
            
            rst,
            
            ext_rst_b,
            ext_rst_e,
            
            ext_cpu_index,
            
            ext_next_cpu_q,
            ext_next_cpu_e,
            
            ext_bus_busy
            
            );
  input wire clk;
  input wire [`STATE_SIZE0:0] state;
  input wire [31:0] command;
/*
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
*/

//  input wire [`ADDR_SIZE0:0] base_addr;
  reg [`ADDR_SIZE0:0] base_addr_r;
  
  inout [`ADDR_SIZE0:0] addr;
  reg [`ADDR_SIZE0:0] addr_r;
  wire [`ADDR_SIZE0:0] addr = addr_r;
  
  output reg read_q;
  output reg write_q;

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
//  reg [`DATA_SIZE0:0] src1_r_adr;
//  reg [`DATA_SIZE0:0] src1_r;
//  assign src1 = src1_r;
//  reg src1_waiting;
//  reg src1ptr_waiting;

  input  wire [`DATA_SIZE0:0] src0;
//  reg [`DATA_SIZE0:0] src0_r_adr;
//  reg [`DATA_SIZE0:0] src0_r;
//  assign src0 = src0_r;
//  reg src0_waiting;
//  reg src0ptr_waiting;

  input  wire [`DATA_SIZE0:0] dst;
//  reg [`DATA_SIZE0:0] dst_r_adr;
//  reg [`DATA_SIZE0:0] dst_r;
//  assign dst = dst_r;
//  reg dst_waiting;
//  reg dstptr_waiting;
  
  input wire [`DATA_SIZE0:0] dst_h;
//  reg [`DATA_SIZE0:0] dst_h_r;

  input  wire [`DATA_SIZE0:0] cond;
//  reg [`DATA_SIZE0:0] cond_r_adr;
//  reg [`DATA_SIZE0:0] cond_r;
//  assign cond = cond_r;
//  reg cond_waiting;
//  reg condptr_waiting;
  
  output reg next_state;
  
  output reg rst;
  
  
  
  input wire ext_rst_b;
  output reg ext_rst_e = 0;
  
  input wire [`DATA_SIZE0:0] ext_cpu_index;
  reg [`DATA_SIZE0:0] cpu_index_r;
  
  input wire ext_next_cpu_q;
  output reg ext_next_cpu_e;
  
  inout ext_bus_busy;
  reg ext_bus_busy_r;
  wire ext_bus_busy = ext_bus_busy_r;
    
  
//  reg [8:0] progress;


  always @(posedge clk) begin
    addr_r = 32'h zzzzzzzz;
    data_r = 32'h zzzzzzzz;
      next_state = 1'b z;
      ext_rst_e = 0;
      
      ext_next_cpu_e = 1'b z;
      
      read_dn_r = 1'b z;
      
//     $monitor("state=%b  nxt=%b  progr=%b S0ptr=%b",state,next_state,progress,isRegS0Ptr);

    if(ext_rst_b == 1) begin
      
      read_q = 1'b z;
      write_q = 1'b z;
      read_e = 1'b z;
      write_e = 1'b z;
//      progress = `MEM_BEGIN;
      addr_r = 32'h zzzzzzzz;
  //    base_addr_r = 0;
      next_state = 1'b z;
      
//      src1_r = 32'h zzzzzzzz;
//      src0_r = 32'h zzzzzzzz;
//      dst_r = 32'h zzzzzzzz;
      
      data_r = 32'h zzzzzzzz;
      bus_busy_r = 1'b z;
      
      //base_addr_r = addr;
      cpu_index_r = data;
      //data_r = cpu_index_r + 1;
      
      rst = 1;
      
      ext_rst_e = 1;
      
      ext_next_cpu_e = 1'b z;
      ext_bus_busy_r = 1'b z;
      
    end
    else begin
      rst = 0;

      read_e = 1'b z;
      write_e = 1'b z;
      read_q = 1'b z;
      write_q = 1'b z;
      
      if(ext_bus_busy == 1) begin
        
//        if(read_dn == 1) begin
//          addr_r = 32'h zzzzzzzz;
//          
//        end
      end else begin
        if(ext_next_cpu_q == 1 && 
           ext_cpu_index == cpu_index_r &&
           state == 0
        ) begin
          base_addr_r = addr;
          next_state = 1;
          
          ext_next_cpu_e = 1;
        end else begin
          case(state)
            `START_BEGIN: begin
            
              data_r = base_addr_r;
              read_dn_r = 1;
            end
            
          endcase
          
        end
      end
        
    end
    
  end



endmodule

