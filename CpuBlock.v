
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


module CpuBlock(
    clk,
    clk_oe,
    clk_2f,

    addr_in,
    addr_out,
  
    data_in,
    data_out,

    read_q, //read_q),
    write_q, //write_q),
  
    read_dn,
    write_dn,
	 
	 halt_q,
    rw_halt_in,
	 rw_halt_out,
	 
    ext_bus_q,
    ext_bus_allow,

    rst_in,
	 rst_out
);

parameter CPU_QUANTITY = `CPU_QUANTITY;
parameter PROC_QUANTITY = `PROC_QUANTITY;

parameter UNMODIFICABLE_ADDR_B = `UNMODIFICABLE_ADDR_B;

  
	input wire clk;
	input wire rst_in;
	output wire rst_out;
	
	input wire clk_oe;
//	output wire clk_oe;

   input wire clk_2f;


   wire [`ADDR_SIZE0:0] mem_addr_out;
   wire [`DATA_SIZE0:0] mem_data_out;

   wire ext_read_q;
   wire ext_write_q;

	
	input wire [`ADDR_SIZE0:0] addr_in;
   output wire [`ADDR_SIZE0:0] addr_out = mem_addr_out;
//   wire [`ADDR_SIZE0:0] addr_out = mem_addr_out;
  
   input wire [`DATA_SIZE0:0] data_in;
   output wire [`DATA_SIZE0:0] data_out = mem_data_out;
//   wire [`DATA_SIZE0:0] data_out = mem_data_out;
//   wire [`DATA_SIZE0:0] data_out = mem_data_out;

   output wire read_q = ext_read_q;
   output wire write_q = ext_write_q;
  
   input wire read_dn;
   input wire write_dn;
	
	output /*wire*/ halt_q;
   input wire rw_halt_in;
	output /*wire*/ rw_halt_out;
	
	input wire ext_bus_q;
	output wire ext_bus_allow;
	
	//-----------------------------------------------------

  genvar i;
  
//wire [`ADDR_SIZE*CPU_QUANTITY-1:0] addr_in_a;
//  wire [(`DATA_SIZE*CPU_QUANTITY)-1:0] data_in_a;
  
  wire [`DATA_SIZE0:0] data_in_a [0:CPU_QUANTITY - 1];
  wire [`DATA_SIZE0:0] data_in_a_to_or [0:CPU_QUANTITY - 1];

  wire [`DATA_SIZE0:0] addr_in_a [0:CPU_QUANTITY - 1];
  wire [`DATA_SIZE0:0] addr_in_a_to_or [0:CPU_QUANTITY - 1];

  wire [`CPU_MSG_SIZE0:0] cpu_msg_in_a [0:CPU_QUANTITY - 1];
  wire [`CPU_MSG_SIZE0:0] cpu_msg_in_a_to_or [0:CPU_QUANTITY - 1];

  wire [`CPU_MSG_SIZE0:0] ext_cpu_e_a [0:CPU_QUANTITY - 1];
  wire [`CPU_MSG_SIZE0:0] ext_cpu_e_a_to_or [0:CPU_QUANTITY - 1];

  wire [`CPU_MSG_SIZE0:0] dispatcher_q_a [0:CPU_QUANTITY - 1];
  wire [`CPU_MSG_SIZE0:0] dispatcher_q_a_to_or [0:CPU_QUANTITY - 1];

  
  
  
  
  wire
//  wor 
  [`DATA_SIZE0:0] cpu_cell_data_in;// = |data_in_a; // = data_wire_r;
//  trior [`DATA_SIZE0:0] cpu_cell_data_in; // = data_wire_r;
  wire [`DATA_SIZE0:0] cpu_cell_data_out; // = data_wire_r;  
  
  
//  wire [`ADDR_SIZE0:0] mem_addr_out;
//  wire [`DATA_SIZE0:0] mem_data_out;

  wire [`ADDR_SIZE0:0] mem_addr_in = addr_in
//                                    int_mem_addr_out 
//												| ext_mem_addr_out
												; //tmp_addr; 
												
  wire [`DATA_SIZE0:0] mem_data_in = data_in
//                                    int_mem_data_out 
//												| ext_mem_data_out
												; //tmp_data; 
  

  wire mem_read_dn = read_dn
//                     int_mem_read_dn 
//							| ext_mem_read_dn
							; //ext_read_dn_r;
							
  wire mem_write_dn = write_dn
//                     int_mem_write_dn 
//							| ext_mem_write_dn
							; //ext_write_dn_r;  
  
  
  wire DOC_rw_halt_out;
  
  wire DOC_ext_rw_halt_out;
  wire DOC_ext_rw_halt_in = 
                            rw_halt_in
									 ;



  wire bus_busy; // = bus_busy_r;


  wire [`DATA_SIZE0:0] ext_cpu_index; // = ext_cpu_index_r;

  wire ext_cpu_q; // = cpu_q_r;
//  trior ext_cpu_e;
  wire 
//  wor 
  ext_cpu_e;
    
//  trior dispatcher_q;
  wire 
//  wor 
  dispatcher_q;


//  wire ext_read_q;
//  wire ext_write_q;	

  wire ext_rst_b; // = rst;
  wire ext_rst_e; // = ext_rst_e_r;

  wire init;



wire [`ADDR_SIZE0:0] addr_unmodificable_b = UNMODIFICABLE_ADDR_B;


wire [CPU_QUANTITY-1:0] rst_w_e_a;
wire [CPU_QUANTITY-1:0] rst_w_b_a;


assign rst_w_b_a = {rst_w_e_a[CPU_QUANTITY-2:0], ext_rst_b};
assign ext_rst_e = rst_w_e_a[CPU_QUANTITY-1];


//  wire [CPU_QUANTITY-1:0] disp_online;

  wire
//  wor 
  [`CPU_MSG_SIZE0:0] cpu_msg_in;
//  trior [`CPU_MSG_SIZE0:0] cpu_msg_in;
  wire [`CPU_MSG_SIZE0:0] cpu_msg_dispatcher_out;

  wire [`CPU_MSG_SIZE0:0] cpu_msg_out = cpu_msg_in | cpu_msg_dispatcher_out;


//wire [`ADDR_SIZE*CPU_QUANTITY-1:0] addr_in_a;
//  wire [`DATA_SIZE*CPU_QUANTITY-1:0] data_in_a;

  wire [`ADDR_SIZE0:0] cpu_cell_addr_out;
  /*trior*/ wire
  //wor 
  [`ADDR_SIZE0:0] cpu_cell_addr_in;


  wire read_q_a[0:CPU_QUANTITY-1];
  wire read_q_a_to_or[0:CPU_QUANTITY-1];
  
  wire 
  //wor 
  cpu_cell_read_q;// = |read_q_a;

  wire write_q_a[0:CPU_QUANTITY-1];
  wire write_q_a_to_or[0:CPU_QUANTITY-1];
  wire 
  //wor 
  cpu_cell_write_q;// = |write_q_a;
  



wire rw_halt_a[0:CPU_QUANTITY-1];
wire rw_halt_a_to_or[0:CPU_QUANTITY-1];
wire 
//wor 
cpu_cell_rw_halt_in;// = (|rw_halt_a) | DOC_rw_halt_out;
wire cpu_cell_rw_halt_in_wire = cpu_cell_rw_halt_in;

wire halt_q_a[0:CPU_QUANTITY-1];
wire halt_q_a_to_or[0:CPU_QUANTITY-1];
wire 
//wor 
cpu_cell_halt_q_in;// = |halt_q_a;
wire cpu_cell_halt_q_in_wire = cpu_cell_halt_q_in;

//wire ext_rw_halt;


wire bus_busy_in_a[0:CPU_QUANTITY-1];
wire bus_busy_in_a_to_or[0:CPU_QUANTITY-1];
wire 
//wor 
bus_busy_out;// = ( |bus_busy_in_a ) | bus_busy;
wire bus_busy_out_wire = bus_busy_out;


wire want_write_out_a[0:CPU_QUANTITY-1];
wire want_write_out_a_to_or[0:CPU_QUANTITY-1];
wire 
//wor 
want_write_in;// = |want_write_out_a;
wire want_write_in_wire = want_write_in;// = |want_write_out_a;



wire cpu_cell_read_dn;
wire cpu_cell_write_dn;


wire [CPU_QUANTITY-1:0]chan_msg_strb_i;
wire chan_msg_strb_o = |chan_msg_strb_i;


generate
for(i = 0; i < CPU_QUANTITY; i=i+1) begin:cpu_cell_gen
/**/
CpuCell cpu_cell //[CPU_QUANTITY-1:0] 
(
            .clk(clk),
				.clk_oe(clk_oe),
				.clk_2f(clk_2f),
            
            .halt_q_in(cpu_cell_halt_q_in_wire),
            .halt_q_out(halt_q_a[i]),
            .rw_halt_in(cpu_cell_rw_halt_in_wire),
            .rw_halt_out(rw_halt_a[i]),
            
            .want_write_in(want_write_in_wire),
            .want_write_out(want_write_out_a[i]),
				
				.addr_unmodificable_b(addr_unmodificable_b),
            
            .addr_in(cpu_cell_addr_out),
            .addr_out(addr_in_a[i]), //cpu_cell_addr_in),
            .data_in(cpu_cell_data_out),
//				.data_out_bus_in(
//				                  i == 0
//										? 0
//										: data_in_a[i-1]
//                            ),
            .data_out(data_in_a[i]), //cpu_cell_data_in), //
            
            .read_q(read_q_a[i]),
            .write_q(write_q_a[i]),
            .read_dn(cpu_cell_read_dn),
            .write_dn(cpu_cell_write_dn),
				
				.chan_msg_strb_o(chan_msg_strb_i[i]),
				.chan_msg_strb_i(chan_msg_strb_o),
            
            .bus_busy_in(bus_busy_out_wire),
				.bus_busy_out(bus_busy_in_a[i]),
            
				.init(init),
            .ext_rst_b(rst_w_b_a[i]),
            .ext_rst_e(rst_w_e_a[i]),    //ext_rst_e),
            
            .ext_cpu_index(ext_cpu_index),
            
            .ext_cpu_q(ext_cpu_q),
            .ext_cpu_e(ext_cpu_e_a[i]), //ext_cpu_e),
            
            .cpu_msg(cpu_msg_in_a[i]), //cpu_msg_in), //_a),
				.cpu_msg_in(cpu_msg_out),
				
//				.disp_online(disp_online),
            
            .dispatcher_q(dispatcher_q_a[i]) //dispatcher_q)
          );

			 
//			 assign cpu_cell_data_in = data_in_a[i];
//			 assign cpu_cell_addr_in = addr_in_a[i];
//			 assign cpu_msg_in = cpu_msg_in_a[i];
/**/			 
//			 assign ext_cpu_e = ext_cpu_e_a[i];
//			 assign dispatcher_q = dispatcher_q_a[i];
//			 assign cpu_cell_read_q = read_q_a[i];
//			 assign cpu_cell_write_q = write_q_a[i];
			 
//			 assign cpu_cell_rw_halt_in = rw_halt_a[i];
//			 assign cpu_cell_halt_q_in = halt_q_a[i];
//			 assign bus_busy_out = bus_busy_in_a[i];
//			 assign want_write_in = want_write_out_a[i];
/**/

			 
/**/
if(i > 0) begin:cpu_cell_or_buses_biger_0
  assign data_in_a_to_or[i] = data_in_a[i] | data_in_a_to_or[i-1];
  assign addr_in_a_to_or[i] = addr_in_a[i] | addr_in_a_to_or[i-1];
  assign cpu_msg_in_a_to_or[i] = cpu_msg_in_a[i] | cpu_msg_in_a_to_or[i-1];

  assign ext_cpu_e_a_to_or[i] = ext_cpu_e_a[i] | ext_cpu_e_a_to_or[i-1];
  assign dispatcher_q_a_to_or[i] = dispatcher_q_a[i] | dispatcher_q_a_to_or[i-1];
  assign read_q_a_to_or[i] = read_q_a[i] | read_q_a_to_or[i-1];
  assign write_q_a_to_or[i] = write_q_a[i] | write_q_a_to_or[i-1];

  assign rw_halt_a_to_or[i] = rw_halt_a[i] | rw_halt_a_to_or[i-1];
  assign halt_q_a_to_or[i] = halt_q_a[i] | halt_q_a_to_or[i-1];
  assign bus_busy_in_a_to_or[i] = bus_busy_in_a[i] | bus_busy_in_a_to_or[i-1];
  assign want_write_out_a_to_or[i] = want_write_out_a[i] | want_write_out_a_to_or[i-1];
/**/
end else begin:cpu_cell_or_buses_0
  assign data_in_a_to_or[0] = data_in_a[0];
  assign addr_in_a_to_or[0] = addr_in_a[0];
  assign cpu_msg_in_a_to_or[0] = cpu_msg_in_a[0];

  assign ext_cpu_e_a_to_or[0] = ext_cpu_e_a[0];
  assign dispatcher_q_a_to_or[0] = dispatcher_q_a[0];
  assign read_q_a_to_or[0] = read_q_a[0];
  assign write_q_a_to_or[0] = write_q_a[0];

  assign rw_halt_a_to_or[0] = rw_halt_a[0];
  assign halt_q_a_to_or[0] = halt_q_a[0];
  assign bus_busy_in_a_to_or[0] = bus_busy_in_a[0];
  assign want_write_out_a_to_or[0] = want_write_out_a[0];
/**/
end

end //for
endgenerate

/**
			 assign ext_cpu_e = |ext_cpu_e_a;
			 assign dispatcher_q = |dispatcher_q_a;
			 assign cpu_cell_read_q = |read_q_a;
			 assign cpu_cell_write_q = |write_q_a;
			 assign cpu_cell_rw_halt_in = |rw_halt_a;
			 assign cpu_cell_halt_q_in = |halt_q_a;
			 assign bus_busy_out = |bus_busy_in_a;
			 assign want_write_in = |want_write_out_a;
**/

/**
  assign data_in_a_to_or[0] = data_in_a[0];
  assign addr_in_a_to_or[0] = addr_in_a[0];
  assign cpu_msg_in_a_to_or[0] = cpu_msg_in_a[0];
  assign ext_cpu_e_a_to_or[0] = ext_cpu_e_a[0];
  assign dispatcher_q_a_to_or[0] = dispatcher_q_a[0];
  assign read_q_a_to_or[0] = read_q_a[0];
  assign write_q_a_to_or[0] = write_q_a[0];
  assign rw_halt_a_to_or[0] = rw_halt_a[0];
  assign halt_q_a_to_or[0] = halt_q_a[0];
  assign bus_busy_in_a_to_or[0] = bus_busy_in_a[0];
  assign want_write_out_a_to_or[0] = want_write_out_a[0];
/**/

/**
integer ii;
always @* begin
  cpu_cell_data_in = 0;
  for(ii=0; ii<CPU_QUANTITY; ii=ii+1) begin //: sign_or
    cpu_cell_data_in = cpu_cell_data_in | data_in_a[ii];
  end
end
/**/

/**/
assign cpu_cell_data_in = data_in_a_to_or[CPU_QUANTITY - 1];
assign cpu_cell_addr_in = addr_in_a_to_or[CPU_QUANTITY - 1];
assign cpu_msg_in = cpu_msg_in_a_to_or[CPU_QUANTITY - 1];

assign ext_cpu_e = ext_cpu_e_a_to_or[CPU_QUANTITY - 1];
assign dispatcher_q = dispatcher_q_a_to_or[CPU_QUANTITY - 1];
assign cpu_cell_read_q = read_q_a_to_or[CPU_QUANTITY - 1];
assign cpu_cell_write_q = write_q_a_to_or[CPU_QUANTITY - 1];

assign cpu_cell_rw_halt_in = rw_halt_a_to_or[CPU_QUANTITY - 1] | DOC_rw_halt_out;
assign cpu_cell_halt_q_in = halt_q_a_to_or[CPU_QUANTITY - 1];
assign bus_busy_out = bus_busy_in_a_to_or[CPU_QUANTITY - 1] | bus_busy;
assign want_write_in = want_write_out_a_to_or[CPU_QUANTITY - 1];
/**/
//assign cpu_cell_rw_halt_in = DOC_rw_halt_out;
//assign bus_busy_out = bus_busy;



/**/
DispatcherOfCpus disp_1(
            .clk(clk),
				.clk_oe(clk_oe),
				.clk_2f(clk_2f),
				
            .rst_in(rst_in),
				.rst_out(rst_out),
            
            .halt_q(cpu_cell_halt_q_in_wire),
            .rw_halt_in(cpu_cell_rw_halt_in_wire),
            .rw_halt_out(DOC_rw_halt_out),
				
				.addr_unmodificable_b(addr_unmodificable_b),
            
            .addr_in(cpu_cell_addr_in),
            .addr_out(cpu_cell_addr_out),
            .data_in(cpu_cell_data_in),
            .data_out(cpu_cell_data_out),
            
            .read_q(cpu_cell_read_q),
            .write_q(cpu_cell_write_q),
            .read_dn(cpu_cell_read_dn),
            .write_dn(cpu_cell_write_dn),
            
            .bus_busy(bus_busy),
            
				.init(init),
            .ext_rst_b(ext_rst_b),
            .ext_rst_e(ext_rst_e),
            
            .ext_cpu_index(ext_cpu_index),
            
            .ext_cpu_q(ext_cpu_q),
            .ext_cpu_e(ext_cpu_e),
             
            .ext_mem_addr_in(mem_addr_in),
            .ext_mem_addr_out(mem_addr_out),				
				
            .ext_mem_data_in(mem_data_in),
            .ext_mem_data_out(mem_data_out),
				
				.ext_rw_halt_in(DOC_ext_rw_halt_in),
				.ext_rw_halt_out(DOC_ext_rw_halt_out), //ext_rw_halt),
            
            .ext_read_q(ext_read_q),
            .ext_write_q(ext_write_q),
				
            .ext_read_dn(mem_read_dn),
            .ext_write_dn(mem_write_dn),
            
            .cpu_msg_in(cpu_msg_out), //cpu_msg_in),
            .cpu_msg_out(cpu_msg_dispatcher_out),
            
            .dispatcher_q(dispatcher_q),
				
				.ext_bus_q(ext_bus_q),
				.ext_bus_allow(ext_bus_allow)
          );
          
defparam disp_1.CPU_QUANTITY = CPU_QUANTITY;
defparam disp_1.PROC_QUANTITY = PROC_QUANTITY;

/**/


wire halt_q = cpu_cell_halt_q_in;
wire rw_halt_out = DOC_ext_rw_halt_out;

/**
InternalStartupRAM int_ram(
	.clk(clk_int),
	.clk_oe(clk_oe),
	
	.data_in(mem_data_out),
	.data_out(int_mem_data_out), //mem_data_in), //
	
	.addr_in(mem_addr_out),
	.addr_out(int_mem_addr_out), //mem_addr_in), //
	
	.read_q(ext_read_q), //read_q),
	.write_q(ext_write_q), //write_q),
	
	.read_dn(int_mem_read_dn), //mem_read_dn), //
	.write_dn(int_mem_write_dn), //mem_write_dn), //
	
   .rw_halt(DOC_ext_rw_halt_out),//ext_rw_halt),
	
	.rst(~rst)
);
defparam int_ram.INTERNAL_MEM_VALUE = INTERNAL_MEM_VALUE;
defparam int_ram.INTERNAL_MEM_FILE = INTERNAL_MEM_FILE;
/**/


       
endmodule
