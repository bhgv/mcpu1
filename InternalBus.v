

`include "sizes.v"
`include "states.v"
`include "cmd_codes.v"



module InternalBus(
        clk,
        //    state,
        bus_busy,
        
        //command,
        
        //state,
        
            addr,
            data,
            
            read_q,
            write_q,
            read_dn,
            write_dn,
            read_e,
            write_e,
            
        //src1,
        //src0,
        //dst,
        //dst_h,
        
        //next_state,
        
        rst
        );
        
  input wire clk;
  inout bus_busy;
  reg bus_busy_r;
  wire bus_busy = bus_busy_r;
  
  //output 
  wire [31:0] command;
    
  input wire rst;
  

//  reg [`ADDR_SIZE0:0] addr_out_r;
  inout wire [`ADDR_SIZE0:0] addr; //= addr_out_r;
  
  output wire read_q;
  output wire write_q;
  input wire read_dn;
  input wire write_dn;
  output wire read_e;
  output wire write_e;
  
  
//  reg [`DATA_SIZE0:0] data_r;
  inout wire [`DATA_SIZE0:0] data; // = data_r;
  

  //output 
  wire [`DATA_SIZE0:0] src1;
  //output 
  wire [`DATA_SIZE0:0] src0;
  //output 
  wire [`DATA_SIZE0:0] dst;
  //output 
  wire [`DATA_SIZE0:0] dst_h;
  /*output*/ wire [`DATA_SIZE0:0] cond;
  
  //output 
  wire [`STATE_SIZE0:0] state;
  //input 
  wire next_state;
 
                    
  wire [`ADDR_SIZE0:0] base_addr;
  
  
  
//	reg [31:0] mem [0:100]; 
//  initial $readmemh("mem.txt", mem);
  

//parameter STEP = 20;



  StartManager start_mng(
            .clk(clk), 
            .state(state),
            
            .base_addr(base_addr),
            .command(command),
            
            .is_bus_busy(bus_busy),
            .addr(addr),
            .read_q(read_q),
            .write_q(write_q),
            .data(data),
            .read_dn(read_dn),
            .write_dn(write_dn),
            .read_e(read_e),
            .write_e(write_e),
            
            .next_state(next_state),
            
            .rst(rst)
            );


  FinishManager finish_mng(
            .clk(clk), 
            .state(state),
            
            .base_addr(base_addr),
            .command(command),
            
            .is_bus_busy(bus_busy),
            .addr(addr),
            .data(data),
            
            .next_state(next_state),
            
            .rst(rst)
            );


  StateManager states_mng(
            .clk(clk),
            .state(state),
            
            .cond(cond),
            
            .next_state(next_state),
            
            .rst(rst)
            );
            


  MemManager mem_mng (
            .clk(clk), 
            .state(state),
            .base_addr(base_addr),
            .command_word(command),
            
            .is_bus_busy(bus_busy),
            .addr(addr),
            .read_q(read_q),
            .write_q(write_q),
            .data(data),
            .read_dn(read_dn),
            .write_dn(write_dn),
            .read_e(read_e),
            .write_e(write_e),
            
            .src1(src1),
            .src0(src0),
            .dst(dst),
            .dst_h(dst_h),
            .cond(cond),
            
            .next_state(next_state),
            
            .rst(rst)
            );


  Alu alu_1 (
        .clk(clk),
        .is_bus_busy(bus_busy),
        
        .command(command),
        
        .state(state),
        
        .src1(src1),
        .src0(src0),
        .dst(dst),
        .dst_h(dst_h),
        
        .next_state(next_state),
        
        .rst(rst)
        );




  always @(posedge clk) begin
    
    if(rst == 1) begin
      bus_busy_r = 1'b z;
    end //else begin

/*
      case(state)
        `START_BEGIN: begin
          data_wire_r = 0; //Q;
          read_dn = 1;
        end
        
      endcase
*/

  end
  
  
endmodule








