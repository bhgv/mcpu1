

`include "sizes.v"
`include "states.v"
`include "inter_cpu_msgs.v"

`include "defines.v"



module FrequencyManager(
    clk,
    clk_oe,
	 clk_int,
	 
	 clk25mhz,
	 
	 rst
);


  input wire clk;
  input wire rst;
  
  output reg clk_int;
  output reg clk_oe;
  
  reg [7:0] cntr;
  
  output reg clk25mhz; // = cntr == 0;
  
  
  always @(negedge clk) begin
    if(clk_int == 1'b 0) begin
      clk_oe <= ~clk_oe;
    end
  end
  
  always @(posedge clk) begin
//    clk_int <= ~clk_int;
    if(clk_int == 1'b 0) begin
      clk_int <= 1'b 1;
////      clk_oe <= ~clk_oe;
    end else begin
      clk_int <= 1'b 0;
//      clk_oe <= ~clk_oe;
    end
  
    if(rst == 1) begin
	   cntr <= 0;
//		clk_oe <= 0;
		clk25mhz <= 0;
	 end else begin
	   if(cntr >= `FREQ_VIDEO_DIVIDER ) begin
		  cntr <= 0;
		  clk25mhz <= 1;
		end else begin
		  cntr <= cntr + 1;
		  clk25mhz <= 0;
		end
	 end
  end
  
endmodule

