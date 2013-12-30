
/**
 * format
      --------
 * 00 - 
 * 01 - src
 * 02 - 1
 * 03 - 
      --------
 * 04 - 
 * 05 - src
 * 06 - 0
 * 07 - 
      --------
 * 08 - 
 * 09 - dst
 * 10 - 
 * 11 - 
      --------
 * 12 - 
 * 13 - cond
 * 14 - 
 * 15 - 
      --------
 * 16 - 
 * 17 - 
 * 18 - 
 * 19 - 
      --------
 * 20 - 
 * 21 - 
 * 22 - 
 * 23 - 
 * 24 - 
 * 25 - 
 * 26 - 
 * 27 - 
 * 28 - 
 * 29 - 
 * 30 - 
 * 31 - 
*/ 




`include "sizes.v"
`include "states.v"




module test;

  reg  CLK;
  reg RESET_r;
  wire RESET = RESET_r;

  
  reg [`ADDR_SIZE0:0] addr_out_r;
  wire [`ADDR_SIZE0:0] addr_out = addr_out_r;
  
  wire read_q;
  wire write_q;
  reg read_dn = 0;
  reg write_dn = 0;
  wire read_e;
  wire write_e;
  
  
  reg [`DATA_SIZE0:0] data_wire_r;
  wire [`DATA_SIZE0:0] data_wire = data_wire_r;
  
   
  wire [`DATA_SIZE0:0] src1;
  wire [`DATA_SIZE0:0] src0;
  wire [`DATA_SIZE0:0] dst;
  wire [`DATA_SIZE0:0] dst_h;
  wire [`DATA_SIZE0:0] cond;
  
  wire [`STATE_SIZE0:0] state;
  wire nxt_state;
  
  reg bus_busy_r;
  wire bus_busy = bus_busy_r;
  
  
 
  wire [31:0] command /*= {
                    4'h 0,  //command code
                    
                    2'b 00,    //flags Cond: 00 - as is, 01 - post inc, 10 - post dec, 11 - unused
                    2'b 00,    //flags D   : 00 - as is, 01 - post inc, 10 - post dec, 11 - unused 
                    2'b 01,    //flags S0  : 00 - as is, 01 - post inc, 10 - post dec, 11 - unused
                    2'b 10,    //flags S1  : 00 - as is, 01 - post inc, 10 - post dec, 11 - unused
                    
                    1'b 1,      //isRegCondPtr
                    1'b 1,      //isRegDPtr
                    1'b 1,      //isRegS0Ptr
                    1'b 1,      //isRegS1Ptr
                    
                    4'b 0111,   //cond
                    4'b 0011,   //dst
                    4'b 0100,   //src0
                    4'b 0010    //src1
                    }*/
                    ;
                    
  wire [`ADDR_SIZE0:0] base_addr;
  
  
  
	reg [31:0] mem [0:100]; 
  initial $readmemh("mem.txt", mem);
  

parameter STEP = 20;



StartManager start_mng(
            .clk(CLK), 
            .state(state),
            
            .base_addr(base_addr),
            .command(command),
            
            .is_bus_busy(bus_busy),
            .addr(addr_out),
            .read_q(read_q),
            .write_q(write_q),
            .data(data_wire),
            .read_dn(read_dn),
            .write_dn(write_dn),
            .read_e(read_e),
            .write_e(write_e),
            
            .next_state(nxt_state),
            
            .rst(RESET)
            );


FinishManager finish_mng(
            .clk(CLK), 
            .state(state),
            
            .base_addr(base_addr),
            .command(command),
            
            .is_bus_busy(bus_busy),
            .addr(addr_out),
            .data(data_wire),
            
            .next_state(nxt_state),
            
            .rst(RESET)
            );


StateManager states_mng(
            .clk(CLK),
            .state(state),
            
            .next_state(nxt_state),
            
            .rst(RESET)
            );
            


MemManager mem_mng (
            .clk(CLK), 
            .state(state),
            .base_addr(base_addr),
            .command_word(command),
            
            .is_bus_busy(bus_busy),
            .addr(addr_out),
            .read_q(read_q),
            .write_q(write_q),
            .data(data_wire),
            .read_dn(read_dn),
            .write_dn(write_dn),
            .read_e(read_e),
            .write_e(write_e),
            
            .src1(src1),
            .src0(src0),
            .dst(dst),
            .dst_h(dst_h),
            .cond(cond),
            
            .next_state(nxt_state),
            
            .rst(RESET)
            );


Alu alu_1 (
        .clk(CLK),
        .is_bus_busy(bus_busy),
        
        .command(command),
        
        .state(state),
        
        .src1(src1),
        .src0(src0),
        .dst(dst),
        .dst_h(dst_h),
        
        .next_state(nxt_state),
        
        .rst(RESET)
        );





initial begin
// $monitor("RESET=%b  CLK=%b  Q=%b",RESET,CLK,Q);
                      RESET_r = 1'bz;
           #(STEP*5)  RESET_r = 1'b1;
           #STEP      RESET_r = 1'bz;
           //#(STEP*20) RESET = 1'b1;
           //#STEP      RESET = 1'b0;
           //#(STEP*20)
           #(STEP*44)
          $finish;
        end

always begin
                    CLK = 0;
          #(STEP/2) CLK = 1;
          #(STEP/2);
       end


always @(posedge CLK) begin
//          Q = Q+1;
          
       end



always @(negedge CLK) begin

    addr_out_r = 32'h zzzzzzzz;
    
    read_dn = 0;
    write_dn = 0;
    bus_busy_r = 1'b z;
    
  if(RESET == 1) begin
    data_wire_r = 32'h zzzzzzzz;
    //addr_out_r = 32'h zzzzzzzz;
    //bus_busy_r = 1'b z;
    //read_dn = 0;
    //write_dn = 0;
  end else begin

    case(state)
      `START_BEGIN: begin
        data_wire_r = 0; //Q;
        read_dn = 1;
      end
  
      default: begin
        data_wire_r = 32'h zzzzzzzz;
        if(read_q == 1) begin
          //addr_out_r = 32'h zzzzzzzz;
          addr_out_r = addr_out;
          data_wire_r = mem[addr_out];
          read_dn = 1;
          bus_busy_r = 1;
        end else /*if(read_e == 1)*/ begin
       //            data_wire_r = 32'h zzzzzzzz;
        end
        
        if(write_q == 1) begin
          addr_out_r = addr_out;
          mem[addr_out] = data_wire;
          $monitor("wrote mem[ %x ] = %x",addr_out,mem[addr_out]);
          write_dn = 1;
        end
        
      end
    endcase
  end
  
end



//always @(negedge RESET) begin
//  data_wire_r = 32'h zzzzzzzz;
//  addr_out_r = 32'h zzzzzzzz;
//  bus_busy_r = 1'b z;
//end
       
endmodule
