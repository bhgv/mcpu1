
`include "../../../sizes.v"



`define Th   800
`define Thd  640

`define Thp  96
`define Ths  144

//`define DOT_TO_NEXT_ROW `Thd + 96

`define Tv   525
`define Tvd  480

`define Tvp  2
`define Tvs  34

//`define ROW_TO_NEXT_KADR 520

module RGB_640x480(
		 clk,
		 clk_oe,
		 
		 clk_video,
		 
		 pix_clk,
		 de,
		 
		 hs,
		 vs,
		 
		 r,
		 g,
		 b,
		
		 ttl_en_,
		 vga1_oe_,
		 vga1_we_,
		 vga2_oe_,
		 vga2_we_,
		 
		 
		 
		 
		 data_in,
		 data_out,
		 addr_in,
		 addr_out,
		 
		 read_q,
		 write_q,
		 read_dn,
		 write_dn,
		 
		 rw_halt,
		 
		 
		 video_mem_addr,
		 video_mem_data,
		 video_mem_oe,
		 video_mem_we,

		 video_mem_ce1,
		 video_mem_ce2,
		 video_mem_ce3,
		 
		 rst
		);
		
		parameter ADDR_VGA_R = 999979;
		parameter ADDR_VGA_G = 999978;
		parameter ADDR_VGA_B = 999977;
		
		parameter VIDEO_MEM_B = 1;
		parameter VIDEO_MEM_E = 2;
		
		
		
		
		output [`ADDR_SIZE0:0] video_mem_addr;
		inout tri [`DATA_SIZE0:0] video_mem_data;
		
		output wire video_mem_oe;
		output wire video_mem_we;

		 output wire video_mem_ce1 = 0;
		 output wire video_mem_ce2 = 0;
		 output wire video_mem_ce3 = 0;

		 wire is_mem_rw_idle; // = video_mem_ce1;
		
		
		input wire clk;
		
		input clk_video;
		
		output reg pix_clk = 1;
		output wire de;
		
		output wire hs = dot > `Thp;
		output wire vs = row > `Tvp;

		output /*wire*/ ttl_en_;// = 0;
		output wire vga1_oe_;
		output wire vga1_we_;
		output wire vga2_oe_;
		output wire vga2_we_;
		
	wire ttl_en_not;
  	wire ttl_en_ = ~ttl_en_not; //~is_mem_rw_idle; //0;

//	assign vga1_oe_ = 1;
//	assign vga1_we_ = 1;
//	assign vga2_oe_ = 1;
//	assign vga2_we_ = 1;

		
  reg [9:0] dot = 0;
  reg [9:0] row = 0;
  
  reg clk_int = 0;
  
  wire hblank = (dot >= `Ths) && (dot < `Ths + `Thd);
  wire vblank = (row >= `Tvs) && (row < `Tvs + `Tvd);
  
//  assign pix_clk = clk_int; //dot[0] & ~clk;
  
  assign de = hblank & vblank;
  
//  wire [10:0] row_dot = row + dot;

  reg [`ADDR_SIZE0:0] scanline_pt;

//  output wire [3:0] g = dot[4] ^ row[4] ? (row_dot[3:0] ^ ((row[5:4] == 2'b 00) ? dot[3:0] : row[3:0])) : 0; //dot[9:6]; //4'b 1111;
//  output wire [3:0] g = dot[5:2]; //4'b 1111;

//  output [3:0] g;
  reg [3:0] g_r;
//  wire [3:0] g = g_r;

//  output wire [3:0] r = dot[4] ^ row[4] ? (row_dot[6:3] ^ ((row[5:4] == 2'b 01) ? dot[3:0] : row[3:0])) : 0; //dot[9:6]; //4'b 1111;
//  output wire [3:0] r = dot[9:6]; //4'b 1111;

//  output [3:0] r;
  reg [3:0] r_r;
//  wire [3:0] r = r_r;

//  output wire [3:0] b = dot[4] ^ row[4] ? (row_dot[9:6] ^ ((row[5:4] == 2'b 10) ? dot[3:0] : row[3:0])) : 0; //dot[9:6]; //4'b 0000;
//  output wire [3:0] b = row[7:4]; //4'b 0000;

//  output [3:0] b;
  reg [3:0] b_r;
//  wire [3:0] b = b_r;
  
  
  
  
  input wire clk_oe;
  
  input wire rst;

  
  reg read_dn_r;
  output read_dn;
  wire read_dn; // = read_dn_r;
  reg write_dn_r;
  output write_dn;
  wire write_dn; // = write_dn_r;
  

  input wire [`ADDR_SIZE0:0] addr_in;
  output [`ADDR_SIZE0:0] addr_out;
  reg [`ADDR_SIZE0:0] addr_r;
  wire [`ADDR_SIZE0:0] addr_out; /** = (
                                   read_dn_r == 1
											  || write_dn_r == 1
											)
											? addr_r
											: 0
											;
											/**/
  
  input wire [`DATA_SIZE0:0] data_in;
  output [`DATA_SIZE0:0] data_out;
  reg [`DATA_SIZE0:0] data_r;
  wire [`DATA_SIZE0:0] data_out; /** = (
                                   read_dn_r == 1
											  || write_dn_r == 1
											)
											? data_r
											: 0
											;
											/**/
  
  input wire read_q;
  input wire write_q;
  
  input wire rw_halt;
  
  
//  wire is_mem_rw_idle;
  
  wire [`ADDR_SIZE0:0] ext_mem_itf_addr;
  
  
ExternalSRAMInterface ext_vram_itf(
	.clk(clk),
	.clk_oe(clk_oe),
	
	.addr_in(addr_in),
	.addr_out(addr_out),
	
	.data_in(data_in),
	.data_out(data_out),
	
   .read_q(read_q), //read_q),
   .write_q(write_q), //write_q),
	
   .read_dn(read_dn),
   .write_dn(write_dn),
	
	.rw_halt(rw_halt),
	
	
	.prg_addr(ext_mem_itf_addr),
	.prg_data(video_mem_data),
		
//	.prg_ba(prg_ba),
//	.prg_bb(prg_bb),
//	.prg_bc(prg_bc),
//	.prg_bd(prg_bd),
	
	.prg_ce0(is_mem_rw_idle),  //video_mem_ce1),
	.prg_ce1(ttl_en_not),
//	.prg_ce2(video_mem_ce3),
	
	.prg_oe(video_mem_oe), //vga1_oe_),
	
	.prg_we(video_mem_we), //vga1_we_),

	.rst(rst)
);
  defparam ext_vram_itf.MEM_BEGIN = VIDEO_MEM_B;
  defparam ext_vram_itf.MEM_END = VIDEO_MEM_E;

  inout [3:0] r;
  tri [3:0] r;// = video_mem_data[3:0];
  inout [3:0] g;
  tri [3:0] g;// = video_mem_data[11:8];
  inout [3:0] b;
  tri [3:0] b;// = video_mem_data[19:16];

/**/
  wire [`ADDR_SIZE0:0] video_mem_addr =
                                      is_mem_rw_idle == 1
												  ? scanline_pt
												  : ext_mem_itf_addr
												  ;
/**
  wire [`ADDR_SIZE0:0] video_mem_addr =
												  scanline_pt
												  | ext_mem_itf_addr
												  ;
/**/

 assign vga1_oe_ = is_mem_rw_idle == 1
												  ? 0
												  : video_mem_oe
												  ;

 assign vga1_we_ = is_mem_rw_idle == 1
												  ? 1
												  : video_mem_we
												  ;
		

  always @(posedge clk_int) begin	 
    dot = dot + 1;

	 if( dot >= `Th ) begin
	   dot = 0;
//  end
  
//  always @(negedge clk_int and dot == 0) begin
//	 if( dot == `DOT_TO_NEXT_ROW )
	   row = row + 1;
      if( row >= `Tv )
        row = 0;
    end
//	 else begin
//	   if( row < `Tv )
//	     scanline_pt = scanline_pt + 1;
//	 end

  end
  
  
  always @(posedge clk_video) begin
    pix_clk = /*hblank &*/ ~pix_clk;
	 
	 if(rst) 
	   scanline_pt = 0;
    else
	 if(pix_clk == 1) begin
	   if( dot < `Th && row < `Tv) begin
		  if(scanline_pt >= (`Thd * `Tvd) - 1) begin
		    scanline_pt = 0;
		  end else begin
		    scanline_pt = scanline_pt + 1;
		  end
		end
	 end
  end
	 
  always @(posedge clk_video) begin
    clk_int = ~clk_int;
  end
	 

/**
  always @(posedge clk) begin
    if(clk_oe == 0) begin
	 end else begin
	   if(rst == 1) begin
		  r_r = 0;
		  g_r = 0;
		  b_r = 0;
		  
//		  dot = 0;
//		  row = 0;
		  
//		  clk_int = 0;
		  
		  
		  addr_r = 0;
		  data_r = 0;
		  
		  read_dn_r = 0;
		  write_dn_r = 0;

		end else begin
		  read_dn_r = 0;
		  write_dn_r = 0;

//        case(addr_in)
          if(addr_in == ADDR_VGA_R) begin
		      if(write_q == 1) begin
			     data_r = data_in;
				  addr_r = addr_in;
				  
				  r_r = data_in[3:0];
				  
				  write_dn_r = 1;
				end else
		      if(read_q == 1) begin
//			     data_r = data_in;
				  addr_r = addr_in;
				
				  data_r = {`DATA_SIZE'h0000000, r_r};
				  
				  read_dn_r = 1;
				end
          end
          else
          if(addr_in == ADDR_VGA_G) begin
		      if(write_q == 1) begin
			     data_r = data_in;
				  addr_r = addr_in;
				  
				  g_r = data_in[3:0];
				  
				  write_dn_r = 1;
				end else
		      if(read_q == 1) begin
//			     data_r = data_in;
				  addr_r = addr_in;
				
				  data_r = {`DATA_SIZE'h0000000, g_r};
				  
				  read_dn_r = 1;
				end
          end
          else
          if(addr_in == ADDR_VGA_B) begin
		      if(write_q == 1) begin
			     data_r = data_in;
				  addr_r = addr_in;
				  
				  b_r = data_in[3:0];
				  
				  write_dn_r = 1;
				end else
		      if(read_q == 1) begin
//			     data_r = data_in;
				  addr_r = addr_in;
				
				  data_r = {`DATA_SIZE'h0000000, b_r};
				  
				  read_dn_r = 1;
				end
          end

//        endcase
      end // rst
    end //clk_oe
  end //clk
/**/

endmodule
