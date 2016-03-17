
`include "../../../sizes.v"



`define Th   799 //800
`define Thd  640

`define Thp  96
`define Ths  144

//`define DOT_TO_NEXT_ROW `Thd + 96

`define Tv   524 //525
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
		 
//		 r,
//		 g,
//		 b,
		
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
		
//		parameter ADDR_VGA_R = 999979;
//		parameter ADDR_VGA_G = 999978;
//		parameter ADDR_VGA_B = 999977;
		
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
		
		input wire clk_video;
		
		output reg pix_clk = 1;
//		output wire pix_clk = clk_video;
		output wire de;
		
		output hs;//wire hs = dot > `Thp;
		output vs;//wire vs = row > `Tvp;

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

		
  reg [9:0] dot;
  reg [9:0] row;
  
  reg clk_int = 0;
//  wire clk_int = clk_video;
  
//  wire hblank = (dot >= `Ths) && (dot < `Ths + `Thd);
//  wire vblank = (row >= `Tvs) && (row < `Tvs + `Tvd);
  
  
  
  wire [9:0] r_hcnt = dot;
  wire [9:0] r_vcnt = row;

  
  
  
  
    reg            r_vsync_x;
    reg            r_hsync_x;
    reg            r_hsync_x_i; // internal use, vactive only

    reg            r_blank_x;

    reg            r_vsync_neg;
    reg            r_hsync_neg;
    reg            r_de;

    // VGA : 60Hz
    wire w_h_end = (r_hcnt == 'd799);  // 800 clock
    wire w_v_end = w_h_end & (r_vcnt == 'd524);  // 525 line

    wire w_vsync = ((r_vcnt == 10'd10) | (r_vcnt == 10'd11)) ? 1'b0 : 1'b1;
    wire w_hsync = ((r_hcnt >= 10'd16)&(r_hcnt <= 10'd111)) ? 1'b0 : 1'b1;
    wire w_hsync_dma = ((r_hcnt >= 10'd16)&(r_hcnt <= 10'd39)) ? 1'b0 : 1'b1;

    wire w_hactive = ((r_hcnt >= 10'd160)&(r_hcnt <= 10'd799)) ? 1'b1 : 1'b0;
    wire w_vactive = ((r_vcnt >= 10'd45)&(r_vcnt <= 10'd524))  ? 1'b1 : 1'b0;
    wire w_vactive_first = (r_vcnt == 10'd45);

    wire w_active = w_hactive & w_vactive;
    wire w_active_first = w_vactive_first;

    wire w_hsync_x_i = w_vactive & w_hsync_dma;
    // color should be black in blanking
    //assign w_r = (w_active) ? w_rgb[7:0]   : 8'h00;
    //assign w_g = (w_active) ? w_rgb[15:8]  : 8'h00;
    //assign w_b = (w_active) ? w_rgb[23:16] : 8'h00;

    wire o_vsync_x = r_vsync_x;//r_vsync_neg;
    wire o_hsync_x = r_hsync_x;//r_hsync_neg;
    wire o_blank_x = r_blank_x;
    wire o_de = r_de;
	 
  assign de = o_de; //hblank & vblank;
  
  wire hs = o_hsync_x;
  wire vs = o_vsync_x;

  wire hblank = (dot >= `Ths) && (dot < `Ths + `Thd);
  wire vblank = (row >= `Tvs) && (row < `Tvs + `Tvd);


//    wire o_r = (w_active) ? w_r_test : 8'h00;
//    wire o_g = (w_active) ? w_g_test : 8'h00;
//    wire o_b = (w_active) ? w_b_test : 8'h00;

    wire o_vsync_i = r_vsync_x;
    wire o_hsync_i = r_hsync_x_i;
    wire o_active = w_active;
    wire o_first_line = w_active_first;

  
  
  
  
  
  
  
  
  
  
  
  
  
  
//  assign pix_clk = clk_int; //dot[0] & ~clk;
  
//  assign de = hblank & vblank;
  
//  wire [10:0] row_dot = row + dot;

  reg [`ADDR_SIZE0:0] scanline_pt;  
  
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
//  reg [`ADDR_SIZE0:0] addr_r;
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
//  reg [`DATA_SIZE0:0] data_r;
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

//  inout [3:0] r;
//  tri [3:0] r;// = video_mem_data[3:0];
//  inout [3:0] g;
//  tri [3:0] g;// = video_mem_data[11:8];
//  inout [3:0] b;
//  tri [3:0] b;// = video_mem_data[19:16];

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
	
	
	
  always @(negedge clk_video) begin
//    if(rst == 1 && clk_int == 1) begin
//	   pix_clk = 0;//1; //0;
//		clk_int = 0;
//	 end else 
	 begin
      pix_clk = /*hblank &*/ ~pix_clk;  //clk_video; // 
    end
end

  always @(posedge clk_video) begin
	   clk_int = ~clk_int; //clk_video;
//	 end
  end


  always @(posedge clk_int) begin

    if(rst == 1) begin
	   dot = 0;
		row = 9;
    end else begin 	 
      //dot = dot + 1;

	   if( w_h_end ) begin //dot >= `Th ) begin
	     dot = 0;
		  
		  if( w_v_end )
		    row = 0;
        else
		    row = row + 1;
//      if( row >= `Tv )
//        row = 0;
      end else begin
		  dot = dot + 1;
		end
    end

  end
  
    // sync
	 always @(posedge clk_int) begin
//    always @(posedge pix_clk) begin
        if (rst == 1) begin
            r_vsync_x = 1'b1;
            r_hsync_x = 1'b1;
            r_blank_x = 1'b1;
            r_de = 1'b0;
        end else begin
            r_vsync_x = w_vsync;
            r_hsync_x = w_hsync;
            r_hsync_x_i = w_hsync_x_i;
            r_blank_x = w_active;
            r_de = w_active;
        end
    end


  
  
	 
	 
	 
	 
  always @(posedge clk_int) begin
	 if(rst) begin
	   scanline_pt = 0;
		
//		pix_clk = 1;
    end else
//	 if(pix_clk == 1) begin
	   if( w_active ) begin //dot < `Th && row < `Tv) begin
		  if(scanline_pt >= (`Thd * `Tvd) - 1) begin
		    scanline_pt = 0;
		  end else begin
		    scanline_pt = scanline_pt + 1;
		  end
		end
//	 end
  end
	 
//  always @(posedge clk_video) begin
//    clk_int = ~clk_int;
//  end
	 

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
