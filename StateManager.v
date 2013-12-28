
`include "sizes.v"
`include "states.v"


module StateManager(
            clk,
            state,
            
            next_state,
            
            rst
            );
  input wire clk;
  output reg [`STATE_SIZE0:0] state;
  input wire next_state;
  
  input wire rst;
  
  always @(negedge clk) begin
    if( rst == 1 ) begin
      state = 0;
    end
    else if(next_state == 1) begin
      state = state + 1;
    end
  end
endmodule
