

`include "sizes.v"
`include "states.v"
`include "inter_cpu_msgs.v"

`include "defines.v"



module FrequencyManager(
    clk,
    cpu_cell_clk_oe,
	 cpu_cell_clk_int,
    cpu_disp_clk_oe,
	 cpu_disp_clk_int,
    mem_int_clk_oe,
	 mem_int_clk_int,
	 
	 clk25mhz,
	 
	 rst_in,
	 rst_out
);


  input wire clk;
  input wire rst_in;
  output reg  rst_out;
  
//  output reg clk_int;
//  output reg clk_oe;

  reg [1:0] freq_coder;

  output wire cpu_cell_clk_int = freq_coder[0];
  output reg cpu_cell_clk_oe; //  = freq_coder[3];
  output wire cpu_disp_clk_int = freq_coder[1];
  output reg cpu_disp_clk_oe; //  = freq_coder[2];
  output wire mem_int_clk_int  = freq_coder[0];
  output reg mem_int_clk_oe; //   = freq_coder[3];
  
  reg [7:0] rst_cntr;

  reg [7:0] cntr;
  
  output reg clk25mhz; // = cntr == 0;

  always @(negedge clk) begin
    if(cpu_cell_clk_int == 1'b 0) begin
      cpu_cell_clk_oe <= ~cpu_cell_clk_oe;
    end
  end

  always @(negedge clk) begin
    if(cpu_disp_clk_int == 1'b 0) begin
      cpu_disp_clk_oe <= ~cpu_disp_clk_oe;
    end
  end

  always @(negedge clk) begin
    if(mem_int_clk_int == 1'b 0) begin
      mem_int_clk_oe <= ~mem_int_clk_oe;
    end
  end

/*
  always @(negedge clk) begin
    if(clk_int == 1'b 0) begin
      clk_oe <= ~clk_oe;
    end
  end
*/

  always @(posedge clk) begin
/*
//    clk_int <= ~clk_int;
    if(clk_int == 1'b 0) begin
      clk_int <= 1'b 1;
////      clk_oe <= ~clk_oe;
    end else begin
      clk_int <= 1'b 0;
//      clk_oe <= ~clk_oe;
    end
*/
//    freq_coder <= {freq_coder[2], freq_coder[1], freq_coder[0], freq_coder[3]};
    freq_coder <= {freq_coder[0], freq_coder[1]};

    if(rst_in == 1) begin
		freq_coder <= 1;
	   cntr <= 0;
//		clk_oe <= 0;
		clk25mhz <= 0;

		rst_out <= 1;
		rst_cntr <= 0;
	 end else begin
	   if(rst_out == 1) begin
		  if(rst_cntr < 8)
		    rst_cntr <= rst_cntr + 1;
		  else
		    rst_out <= 0;
//		    rst_cntr <= 0;
		end

	   if(cntr >= `FREQ_VIDEO_DIVIDER ) begin
		  cntr <= 0;
		  clk25mhz <= 1;
		end else begin
		  cntr <= cntr + 1;
		  clk25mhz <= 0;
		end
	 end
  end
  
/*
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
*/
  
endmodule

