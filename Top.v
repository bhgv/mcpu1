
`include "sizes.v"
`include "states.v"
`include "inter_cpu_msgs.v"

`include "defines.v"


/**
`define MEM_CTLR_WAIT               0

`define MEM_CTLR_READ_SET_ADDRESS   1
`define MEM_CTLR_READ_DATA_GET      2
`define MEM_CTLR_READ_FINISH        3

`define MEM_CTLR_WRITE_SET_ADDRESS  4
`define MEM_CTLR_WRITE_SET_WE       5
`define MEM_CTLR_WRITE_FINISH       6
/**/


module Top(
	clk,
	
	ext_mem_addr,
	ext_mem_data,
	
	video1_addr,
	video1_data,
	
//	ext_read_q,
//   ext_write_q,
	
//	ext_read_dn,
//	ext_write_dn,
	
	prg_ba,
	prg_bb,
	prg_bc,
	prg_bd,
	
	prg_ce0,
	prg_ce1,
	prg_ce2,
	
	prg_oe,
	
	prg_we,
	
	video1_oe,
	
	video1_we,

	
	TxD,
	RxD,
	
	
	pix_clk,
	de,
	
	hs,
	vs,
		 
//	r,
//	g,
//	b,
		
	ttl_en_,
	vga1_oe_,
	vga1_we_,
	vga2_oe_,
	vga2_we_,
	
	vga1_ce1,
	vga1_ce2,
	vga1_ce3,
	
	tst1_out,
	
	rst
);

  parameter ClkFrequency = `MAIN_CLK_FREQ; //50_000_000;

  parameter CPU_QUANTITY = `CPU_QUANTITY;
  parameter PROC_QUANTITY = `PROC_QUANTITY;

  parameter INTERNAL_MEM_VALUE = `INTERNAL_MEM_VALUE;
  parameter INTERNAL_MEM_FILE = `INTERNAL_MEM_FILE;

  parameter EXTERNAL_PRG_ADDR_E = `EXTERNAL_PRG_ADDR_E;

  parameter VIDEO1_ADDR_B = `VIDEO1_ADDR_B;
  parameter VIDEO1_ADDR_E = `VIDEO1_ADDR_E;
  
  
  parameter RAM_TOTAL = `RAM_TOTAL; //524288 + INTERNAL_MEM_VALUE;
  

  parameter RS232_DATA_ADDR = `RS232_DATA_ADDR;//ADDR_SIZE'h fffffff0;

  parameter Baud = `RS232_BAUD_RATE;//9600; //115200; //
  
  
  parameter UNMODIFICABLE_ADDR_B = `UNMODIFICABLE_ADDR_B;


  
	input wire clk;
	input wire rst;
	
	wire clk_oe_pll;
	wire clk_oe;// = clk_oe_pll;

	wire clk_int = clk;
	wire clk_25mhz;// = clk_oe;
	
	output wire prg_ba;// = 0;
	output wire prg_bb;// = 0;
	output wire prg_bc;// = 0;
	output wire prg_bd;// = 0;
	
	output wire prg_ce0;// = prg_ce_r;
	output wire prg_ce1;// = prg_ce_r;
	output wire prg_ce2;// = prg_ce_r;
	
	output wire prg_oe;// = prg_oe_r;
	
	output wire prg_we;// = prg_we_r;
	
	
	output wire video1_oe;
	output wire video1_we;
	
	
	output wire vga1_ce1;
	output wire vga1_ce2;
	output wire vga1_ce3;


	
	output wire TxD;
	input wire RxD;

	output wire tst1_out;
  
//  wire read_dn; // = read_dn_r;
  
//  wire write_dn; // = write_dn_r;
  
//  trior [`DATA_SIZE0:0] data_in; // = data_wire_r;
//  wire [`DATA_SIZE0:0] data_out; // = data_wire_r;
  
  
  
  wire [`ADDR_SIZE0:0] com_prt_addr_out;
  wire [`DATA_SIZE0:0] com_prt_data_out;
  
  wire com_prt_read_dn;
  wire com_prt_write_dn;
  
  
  wire [`ADDR_SIZE0:0] vga_addr_out;
  wire [`DATA_SIZE0:0] vga_data_out;
  
  wire vga_read_dn;
  wire vga_write_dn;
  
  
  
  
  output [`ADDR_SIZE0:0] video1_addr;
  wire [`ADDR_SIZE0:0] video1_addr;
  
  inout [`DATA_SIZE0:0] video1_data;
  tri [`DATA_SIZE0:0] video1_data;
  
  
  
    
  wire [`ADDR_SIZE0:0] int_mem_addr_out;
  wire [`DATA_SIZE0:0] int_mem_data_out;

  wire [`ADDR_SIZE0:0] ext_mem_addr_out;
  wire [`DATA_SIZE0:0] ext_mem_data_out;

  wire [`ADDR_SIZE0:0] mem_addr_out;
  wire [`DATA_SIZE0:0] mem_data_out;

  wire [`ADDR_SIZE0:0] mem_addr_in = 
                                    int_mem_addr_out 
												| ext_mem_addr_out
												| com_prt_addr_out
												| vga_addr_out
												; //tmp_addr; 
												
  wire [`DATA_SIZE0:0] mem_data_in = 
                                    int_mem_data_out 
												| ext_mem_data_out
												| com_prt_data_out
												| vga_data_out
												; //tmp_data; 
  
//  reg ext_read_dn_r;
//  reg ext_write_dn_r;

  wire int_mem_read_dn; // | ext_mem_read_dn;
  wire int_mem_write_dn; // | ext_mem_write_dn;

  wire ext_mem_read_dn;
  wire ext_mem_write_dn;

  wire mem_read_dn = 
                     int_mem_read_dn 
							| ext_mem_read_dn
							| com_prt_read_dn
							| vga_read_dn
							; //ext_read_dn_r;
							
  wire mem_write_dn = 
                     int_mem_write_dn 
							| ext_mem_write_dn
							| com_prt_write_dn
							| vga_write_dn
							; //ext_write_dn_r;
   

  wire rw_halt_rs232;
  
  
  
//  wire DOC_rw_halt_out;
  
//  wire DOC_ext_rw_halt_out;
  wire DOC_ext_rw_halt_in = 
                            rw_halt_rs232
									 ;
  
  

//  wire bus_busy; // = bus_busy_r;
  
  
 
//  wire [31:0] command 
                    /*= {
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
//                    ;

//  wire [`DATA_SIZE0:0] ext_cpu_index; // = ext_cpu_index_r;
  
//  reg cpu_q_r;
//  tri0 ext_cpu_q; // = cpu_q_r;
//  trior ext_cpu_e;
    
//  trior dispatcher_q;
   
 
  wire ext_read_q;
  wire ext_write_q;
  
  inout [`ADDR_SIZE0:0] ext_mem_addr; 
  tri [`ADDR_SIZE0:0] ext_mem_addr;
	
  

  inout [`DATA_SIZE0:0] ext_mem_data; 
  tri [`DATA_SIZE0:0] ext_mem_data;
	
	
	
	
	
	
	
	
/**
  wire ext_rst_b; // = rst;
  wire ext_rst_e; // = ext_rst_e_r;
  
  wire init;


  
wire [`ADDR_SIZE0:0] addr_unmodificable_b = UNMODIFICABLE_ADDR_B;


wire [CPU_QUANTITY-1:0] rst_w_e_a;
wire [CPU_QUANTITY-1:0] rst_w_b_a;

//assign rst_w_b_a = {rst_w_e_a[CPU_QUANTITY-2:0], ext_rst_b};

assign rst_w_b_a = {rst_w_e_a[CPU_QUANTITY-2:0], ext_rst_b};
assign ext_rst_e = rst_w_e_a[CPU_QUANTITY-1];


  wire [CPU_QUANTITY-1:0] disp_online;
//  tri [(`CPU_MSG_SIZE*CPU_QUANTITY)-1:0] cpu_msg_in_a ;
  trior [`CPU_MSG_SIZE0:0] cpu_msg_in // = cpu_msg_in_a[7:0]
//						disp_online[0] == 1
//						? cpu_msg_in_a[7:0]
//						: cpu_msg_in_a[15:8]
						;
  wire [`CPU_MSG_SIZE0:0] cpu_msg_dispatcher_out;
  
  wire [`CPU_MSG_SIZE0:0] cpu_msg_out = cpu_msg_in | cpu_msg_dispatcher_out;
						

wire [`ADDR_SIZE*CPU_QUANTITY-1:0] addr_in_a;
wire [`DATA_SIZE*CPU_QUANTITY-1:0] data_in_a;

  wire [`ADDR_SIZE0:0] addr_out; // = addr_out_r;
  trior [`ADDR_SIZE0:0] addr_in 
									/** = 
									addr_in_a[`DATA_SIZE0:0]
									| addr_in_a[`DATA_SIZE0 + `DATA_SIZE:`DATA_SIZE]
									/** /
									;


  //output 
  wire [CPU_QUANTITY-1:0] read_q_a;
  wire read_q = |read_q_a;
  //output 
  wire [CPU_QUANTITY-1:0] write_q_a;
  wire write_q = |write_q_a;
  



wire [CPU_QUANTITY-1:0] rw_halt_a;
//wire rw_halt = (|rw_halt_a) | DOC_rw_halt_out;

wire [CPU_QUANTITY-1:0] halt_q_a;
wire halt_q = |halt_q_a;

wire ext_rw_halt;


wire [CPU_QUANTITY-1:0] bus_busy_in_a;
//wire bus_busy_out = ( |bus_busy_in_a ) | bus_busy;


wire [CPU_QUANTITY-1:0] want_write_out_a;
wire want_write_in = |want_write_out_a;



/** /
Cpu cpu1 [CPU_QUANTITY-1:0] (
            .clk(clk_int),
				.clk_oe(clk_oe),
            
            .halt_q_in(halt_q),
            .halt_q_out(halt_q_a),
            .rw_halt_in(rw_halt),
            .rw_halt_out(rw_halt_a),
            
            .want_write_in(want_write_in),
            .want_write_out(want_write_out_a),
				
				.addr_unmodificable_b(addr_unmodificable_b),
            
            .addr_in(addr_out),
            .addr_out(addr_in),
            .data_in(data_out),
            .data_out(data_in),
            
            .read_q(read_q_a),
            .write_q(write_q_a),
            .read_dn(read_dn),
            .write_dn(write_dn),
            
            .bus_busy_in(bus_busy_out),
				.bus_busy_out(bus_busy_in_a),
            
				.init(init),
            .ext_rst_b(rst_w_b_a),
            .ext_rst_e(rst_w_e_a),    //ext_rst_e),
            
            .ext_cpu_index(ext_cpu_index),
            
            .ext_cpu_q(ext_cpu_q),
            .ext_cpu_e(ext_cpu_e),
            
            .cpu_msg(cpu_msg_in), //_a),
				.cpu_msg_in(cpu_msg_out),
				
				.disp_online(disp_online),
            
            .dispatcher_q(dispatcher_q)
          );
/** /


/** /
DispatcherOfCpus disp_1(
            .clk(clk_int),
				.clk_oe(clk_oe),
            .rst(~rst),
            
            .halt_q(halt_q),
            .rw_halt_in(rw_halt),
            .rw_halt_out(DOC_rw_halt_out),
				
				.addr_unmodificable_b(addr_unmodificable_b),
            
            .addr_in(addr_in),
            .addr_out(addr_out),
            .data_in(data_in),
            .data_out(data_out),
            
            .read_q(read_q),
            .write_q(write_q),
            .read_dn(read_dn),
            .write_dn(write_dn),
            
            .bus_busy(bus_busy),
            
				.init(init),
            .ext_rst_b(ext_rst_b),
            .ext_rst_e(ext_rst_e),
            
            .ext_cpu_index(ext_cpu_index),
            
            .ext_cpu_q(ext_cpu_q),
            .ext_cpu_e(ext_cpu_e),
            

//            .ext_mem_addr_in(ext_mem_addr_in),
//            .ext_mem_addr_out(ext_mem_addr_out),
 
            .ext_mem_addr_in(mem_addr_in),
            .ext_mem_addr_out(mem_addr_out),				
				
            .ext_mem_data_in(mem_data_in),
            .ext_mem_data_out(mem_data_out),

//            .ext_mem_data_in(ext_mem_data_in),
//            .ext_mem_data_out(ext_mem_data_out),
				
				.ext_rw_halt_in(DOC_ext_rw_halt_in),
				.ext_rw_halt_out(ext_rw_halt),
            
            .ext_read_q(ext_read_q),
            .ext_write_q(ext_write_q),
				
//            .ext_read_dn(ext_read_dn),
//            .ext_write_dn(ext_write_dn),

            .ext_read_dn(mem_read_dn),
            .ext_write_dn(mem_write_dn),
            
//            .ext_rw_busy(ext_rw_busy),

            .cpu_msg_in(cpu_msg_out), //cpu_msg_in),
            .cpu_msg_out(cpu_msg_dispatcher_out),
            
            .dispatcher_q(dispatcher_q)
          );
          
defparam disp_1.CPU_QUANTITY = CPU_QUANTITY;
defparam disp_1.PROC_QUANTITY = PROC_QUANTITY;

/**/

wire halt_q;
wire ext_rw_halt;


CpuBlock block_of_cpus(
    .clk(clk_int),
    .clk_oe(clk_oe),

    .addr_in(mem_addr_in),
    .addr_out(mem_addr_out),
  
    .data_in(mem_data_in),
    .data_out(mem_data_out),

    .read_q(ext_read_q), //read_q),
    .write_q(ext_write_q), //write_q),
  
    .read_dn(mem_read_dn),
    .write_dn(mem_write_dn),
	 
	 .halt_q(halt_q),
    .rw_halt_in(DOC_ext_rw_halt_in),
	 .rw_halt_out(ext_rw_halt),

    .rst(~rst)
);



/**/
InternalStartupRAM int_ram(
	.clk(clk_int),
	.clk_oe(clk_oe),
	
//	.data_in(ext_mem_data_out),
//	.data_out(ext_mem_data_in),

	.data_in(mem_data_out),
	.data_out(int_mem_data_out), //mem_data_in), //
	
	.addr_in(mem_addr_out),
	.addr_out(int_mem_addr_out), //mem_addr_in), //

//	.addr_in(ext_mem_addr_out),
//	.addr_out(ext_mem_addr_in),
	
	.read_q(ext_read_q), //read_q),
	.write_q(ext_write_q), //write_q),
	
//	.read_dn(ext_read_dn),
//	.write_dn(ext_write_dn),

	.read_dn(int_mem_read_dn), //mem_read_dn), //
	.write_dn(int_mem_write_dn), //mem_write_dn), //
	
   .rw_halt(ext_rw_halt),
	
	.rst(~rst)
);
defparam int_ram.INTERNAL_MEM_VALUE = INTERNAL_MEM_VALUE;
defparam int_ram.INTERNAL_MEM_FILE = INTERNAL_MEM_FILE;
/**/


/**/
ExternalSRAMInterface ext_ram_itf(
	.clk(clk_int),
	.clk_oe(clk_oe),
	
	.addr_in(mem_addr_out),
	.addr_out(ext_mem_addr_out),
	
	.data_in(mem_data_out),
	.data_out(ext_mem_data_out),
	
   .read_q(ext_read_q), //read_q),
   .write_q(ext_write_q), //write_q),
	
   .read_dn(ext_mem_read_dn),
   .write_dn(ext_mem_write_dn),
	
	.rw_halt(ext_rw_halt),
	
	
	.prg_addr(ext_mem_addr),
	.prg_data(ext_mem_data),
	
//	.video1_addr(video1_addr),
//	.video1_data(video1_data),
	
	.prg_ba(prg_ba),
	.prg_bb(prg_bb),
	.prg_bc(prg_bc),
	.prg_bd(prg_bd),
	
	.prg_ce0(prg_ce0),
	.prg_ce1(prg_ce1),
	.prg_ce2(prg_ce2),
	
	.prg_oe(prg_oe),
	
	.prg_we(prg_we),

	
//	.video1_oe(video1_oe),
//	.video1_we(video1_we),

	
	.rst(~rst)
);
  defparam ext_ram_itf.MEM_BEGIN = INTERNAL_MEM_VALUE;
  defparam ext_ram_itf.MEM_END = EXTERNAL_PRG_ADDR_E;
  
//  defparam ext_ram_itf.VIDEO1_ADDR_B = VIDEO1_ADDR_B;
//  defparam ext_ram_itf.VIDEO1_ADDR_E = VIDEO1_ADDR_E;
/**/



/**/
  Rs232 com_itf (
    .clk(clk_int),
    .clk_oe(clk_oe),

    .addr_in(mem_addr_out),
    .addr_out(com_prt_addr_out),
  
    .data_in(mem_data_out),
    .data_out(com_prt_data_out),

    .read_q(ext_read_q), //read_q),
    .write_q(ext_write_q), //write_q),
  
    .read_dn(com_prt_read_dn),
    .write_dn(com_prt_write_dn),
	 
	 .halt_q(halt_q),
	 .rw_halt_out(rw_halt_rs232),

    .RxD(RxD),
    .TxD(TxD),
	 
	 .rx_received(tst1_out),

    .rst(~rst)
  );
  defparam com_itf.RS232_DATA_ADDR = RS232_DATA_ADDR; //1_000_000;

  defparam com_itf.ClkFrequency = ClkFrequency;
  defparam com_itf.Baud = Baud; //115200;
/**/


/**
pll_core pll (
//	.areset(~rst),
	.inclk0(clk),
	
	.c0(clk_int),
//	.c1(clk_oe_pll),
//	.c2(clk_25mhz)
	);
/**/


/**
  Rs232_UART16550 com_itf (
    .clk(clk),
    .clk_oe(clk_oe),

    .addr_in(mem_addr_out),
    .addr_out(com_prt_addr_out),
  
    .data_in(mem_data_out),
    .data_out(com_prt_data_out),

    .read_q(ext_read_q), //read_q),
    .write_q(ext_write_q), //write_q),
  
    .read_dn(com_prt_read_dn),
    .write_dn(com_prt_write_dn),
	 
	 .halt_q(halt_q),
	 .rw_halt_out(rw_halt_rs232),

    .RxD(RxD),
    .TxD(TxD),
	 
	 .rx_received(tst1_out),

    .rst(~rst)
  );
  defparam com_itf.RS232_DATA_ADDR = RS232_DATA_ADDR; //1_000_000;

  defparam com_itf.ClkFrequency = ClkFrequency;
  defparam com_itf.Baud = Baud; //115200;
/**/




  output wire pix_clk;
  output wire de;

  output wire hs;
  output wire vs;

  output wire ttl_en_;
  output wire vga1_oe_;
  output wire vga1_we_;
  output wire vga2_oe_;
  output wire vga2_we_;

//  inout tri [3:0] g;
//  inout tri [3:0] r;
//  inout tri [3:0] b;

  RGB_640x480 vga(
		 .clk(clk_int),
		 .clk_oe(clk_oe),
		 
//		 .clk_video(0), //~clk_25mhz),
		 
		 .pix_clk(pix_clk),
		 .de(de),
		 
		 .hs(hs),
		 .vs(vs),
		 
//		 .r(r),
//		 .g(g),
//		 .b(b),
		
		 .ttl_en_(ttl_en_),
		 
		 .vga1_oe_(vga1_oe_),
		 .vga1_we_(vga1_we_),
		 .vga2_oe_(vga2_oe_),
		 .vga2_we_(vga2_we_),
		 
		 
		 
		 .data_in(mem_data_out),
		 .data_out(vga_data_out),
		 
		 .addr_in(mem_addr_out),
		 .addr_out(vga_addr_out),
		 
       .read_q(ext_read_q), //read_q),
       .write_q(ext_write_q), //write_q),
		 
		 .read_dn(vga_read_dn),
		 .write_dn(vga_write_dn),
		 
		 .rw_halt(ext_rw_halt),
		 
		 .video_mem_addr(video1_addr),
		 .video_mem_data(video1_data),
		 .video_mem_oe(video1_oe),
		 .video_mem_we(video1_we),
		 
		.video_mem_ce1(vga1_ce1),
		.video_mem_ce2(vga1_ce2),
		.video_mem_ce3(vga1_ce3),


		 .rst(~rst)
		);
//		defparam vga.ADDR_VGA_R = ADDR_VGA_R;
//		defparam vga.ADDR_VGA_G = ADDR_VGA_G;
//		defparam vga.ADDR_VGA_B = ADDR_VGA_B;
		
		defparam vga.VIDEO_MEM_B = VIDEO1_ADDR_B;
		defparam vga.VIDEO_MEM_E = VIDEO1_ADDR_E;





/**
always @(posedge clk) begin
  if(rst == 1) begin
    addr_unmodificable_b = UNMODIFICABLE_ADDR_B;
  end
end
/**/

/**
//  ext_write_dn = 0;
//  ext_read_dn = 0;

  if(clk_oe == 0) begin
  
//    ext_read_dn_r  = 0;
//    ext_write_dn_r = 0;

//    ext_mem_data_r = 0; //`DATA_SIZE'h zzzz_zzzz_zzzz_zzzz;
//    ext_mem_addr_r = 0; //`ADDR_SIZE'h zzzz_zzzz_zzzz_zzzz;

		  if(ext_rw_halt == 1) begin
          mem_wrk_state = `MEM_CTLR_WAIT;			 
          bus_director = 0;

          ext_read_dn_r  = 0;
          ext_write_dn_r = 0;

          ext_mem_data_r = 0; //`DATA_SIZE'h zzzz_zzzz_zzzz_zzzz;
          ext_mem_addr_r = 0; //`ADDR_SIZE'h zzzz_zzzz_zzzz_zzzz;
        end


  end else begin
  
  if(rst == 1) begin
    tmp_addr = 0;
	 tmp_data =0;
	 
//    data_wire_r = 0; //`DATA_SIZE'h zzzz_zzzz_zzzz_zzzz;
	 
    mem_wrk_state = `MEM_CTLR_WAIT;
    
    ext_rw_busy = 0;
	 
	 bus_director = 0;
	 
	 ext_read_dn_r = 0;
	 ext_write_dn_r = 0;
	 
	 ext_mem_data_r = 0; //`DATA_SIZE'h zzzz_zzzz_zzzz_zzzz;
	 ext_mem_addr_r = 0; //`ADDR_SIZE'h zzzz_zzzz_zzzz_zzzz;
	 
	 prg_ce_r = 1;
	 prg_oe_r = 0;
	 prg_we_r = 1;
  end else
  begin
  
/** /
    case(mem_wrk_state)
    
      `MEM_CTLR_WAIT: begin
		  
        ext_read_dn_r  = 0;
        ext_write_dn_r = 0;

        tmp_addr = 0;
	     tmp_data =0;
		  
		  prg_ce_r = 1;

//        ext_mem_data_r = 0; //`DATA_SIZE'h zzzz_zzzz_zzzz_zzzz;
//        ext_mem_addr_r = 0; //`ADDR_SIZE'h zzzz_zzzz_zzzz_zzzz;
		
        if(read_q == 1 && ext_rw_halt == 0) begin
          if(mem_addr_out >= INTERNAL_MEM_VALUE) begin
			 
          tmp_addr = mem_addr_out;// - INTERNAL_MEM_VALUE;
          mem_wrk_state = `MEM_CTLR_READ_SET_ADDRESS;

          bus_director = 0;
			 
			 end
        end
        else
        if(write_q == 1 && ext_rw_halt == 0) begin
          if(mem_addr_out >= INTERNAL_MEM_VALUE) begin
			 
          tmp_addr = mem_addr_out;// - INTERNAL_MEM_VALUE;
          tmp_data = mem_data_out;
          mem_wrk_state = `MEM_CTLR_WRITE_SET_ADDRESS;

          bus_director = 1;
			 
			 end
        end
      end

		// read states
      `MEM_CTLR_READ_SET_ADDRESS: begin
		  if(ext_rw_halt == 1) begin
           mem_wrk_state = `MEM_CTLR_WAIT;			 
			 bus_director = 0;
        end else
//        if(bus_director == 1)
        begin
          ext_mem_addr_r = tmp_addr - INTERNAL_MEM_VALUE;

          prg_ce_r = 0;
			 prg_oe_r = 0;
			 prg_we_r = 1;
			 
          mem_wrk_state = `MEM_CTLR_READ_DATA_GET;
        end
      end
  
      `MEM_CTLR_READ_DATA_GET: begin
		  if(ext_rw_halt == 1) begin
           mem_wrk_state = `MEM_CTLR_WAIT;			 
			 bus_director = 0;
        end else
//        if(bus_director == 1) 
        begin
          tmp_data = ext_mem_data;
//          ext_mem_addr_r = 
//          tmp_addr = tmp_addr + INTERNAL_MEM_VALUE;
          ext_read_dn_r = 1;
                    
          mem_wrk_state = `MEM_CTLR_READ_FINISH;
        end
      end
      
      `MEM_CTLR_READ_FINISH: begin
		  if(ext_rw_halt == 1) begin
           mem_wrk_state = `MEM_CTLR_WAIT;			 
			 bus_director = 0;
       end else
//       if(bus_director == 1) 
       begin
         tmp_addr = 0;
	      tmp_data = 0;

          ext_read_dn_r = 0;
                    
          mem_wrk_state = `MEM_CTLR_WAIT;
			 
			 bus_director = 0;
        end
      end
      
		// write states
      `MEM_CTLR_WRITE_SET_ADDRESS: begin
		  if(ext_rw_halt == 1) begin
          mem_wrk_state = `MEM_CTLR_WAIT;			 
          bus_director = 0;
        end else
//        if(bus_director == 1) 
        begin
		  
          ext_mem_addr_r = tmp_addr - INTERNAL_MEM_VALUE;
          ext_mem_data_r = tmp_data;

          prg_ce_r = 0;
			 prg_oe_r = 0;
          
          mem_wrk_state = `MEM_CTLR_WRITE_SET_WE;
        end
      end
      
      `MEM_CTLR_WRITE_SET_WE: begin
		  if(ext_rw_halt == 1) begin
          mem_wrk_state = `MEM_CTLR_WAIT;
          bus_director = 0;
        end else
//        if(bus_director == 1) 
        begin
		  
          prg_we_r = 0;
			 
          mem_wrk_state = `MEM_CTLR_WRITE_FINISH;
        end
      end
          
      `MEM_CTLR_WRITE_FINISH: begin
		  if(ext_rw_halt == 1) begin
          mem_wrk_state = `MEM_CTLR_WAIT;
          bus_director = 0;
        end else
//        if(bus_director == 1) 
        begin
		  
//          mem[tmp_addr] = tmp_data;
//          ext_mem_data_r = tmp_data;
//          ext_mem_addr_r = tmp_addr;
          ext_write_dn_r = 1;
			 
			 prg_we_r = 1;
          
          mem_wrk_state = `MEM_CTLR_WAIT;
			 
			 bus_director = 0;
        end
      end
    
    endcase
	 
/** /

  end
  
  end

end
/**/
       
endmodule
