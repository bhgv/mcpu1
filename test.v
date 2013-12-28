
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
  reg RESET;

//  reg [31:0] Q;
  
  
  wire [`ADDR_SIZE0:0] addr_out;
  
  wire read_q;
  wire write_q;
  reg read_dn = 0;
  reg write_dn = 0;
  
//  reg [`DATA_SIZE0:0] mem;
  wire [`DATA_SIZE0:0] data_wire;
  reg [`DATA_SIZE0:0] data_wire_r;
  assign data_wire = data_wire_r;
  
//  reg [`DATA_SIZE0:0] reg_block [15:0];
//  reg ifPtr_block [3:0];
//  wire ifptr_wire;
  
   
  wire [`DATA_SIZE0:0] src1;
  wire [`DATA_SIZE0:0] src0;
  wire [`DATA_SIZE0:0] dst;
  wire [`DATA_SIZE0:0] cond;
  
  wire [`STATE_SIZE0:0] state;
  wire nxt_state;
  
 
  reg [31:0] command = {
                    4'b 0000,  //command code
                    
                    2'b 11,    //flags Cond: 00 - as is, 01 - post inc, 10 - post dec, 11 - unused
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
                    };
                    
  reg [`ADDR_SIZE0:0] base_addr;
  
  
  
	reg [31:0] mem [0:100]; 
  initial $readmemh("mem.txt", mem);
  
 // assign data_wire = mem[addr_out];


//RIPPL0 DUT(
//           .Q     ( Q ),
//           .CLK   ( CLK ),
//           .RESET ( RESET )
//          );=0;


parameter STEP = 20;

//RIPPL0 DUT(RESET,CLK,Q);


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
//            .ifPtr(ifPtr_wire),
            
            .addr(addr_out),
            .read_q(read_q),
            .write_q(write_q),
            .data(data_wire),
            .read_dn(read_dn),
            .write_dn(write_dn),
            //.read_e(),
            //.write_e(),
            
            .src1(src1),
            .src0(src0),
            .dst(dst),
            .cond(cond),
            
            .next_state(nxt_state),
            
            .rst(RESET)
            );






initial begin
// $monitor("RESET=%b  CLK=%b  Q=%b",RESET,CLK,Q);
                      RESET = 1'b0;
           #(STEP*5)  RESET = 1'b1;
           #STEP      RESET = 1'b0;
           //#(STEP*20) RESET = 1'b1;
           //#STEP      RESET = 1'b0;
           //#(STEP*20)
           #(STEP*12)
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
  if(state == `BASE_ADDR_SET) begin
    base_addr = 0; //Q;
  end
  
  
          read_dn = 0;
          
          if(read_q == 1) begin
            data_wire_r = mem[addr_out];
            read_dn = 1;
          end else /*if(read_e == 1)*/ begin
            data_wire_r = 32'h zzzzzzzz;
          end
  
       end



always @(negedge RESET) begin
//          Q = 0;
       end
       
endmodule
