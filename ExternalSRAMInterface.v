


`include "sizes.v"
`include "states.v"
`include "inter_cpu_msgs.v"


`define MEM_CTLR_WAIT               0

`define MEM_CTLR_READ_SET_ADDRESS   1
`define MEM_CTLR_READ_DATA_GET      2
`define MEM_CTLR_READ_FINISH        3

`define MEM_CTLR_WRITE_SET_ADDRESS  4
`define MEM_CTLR_WRITE_SET_WE       5
`define MEM_CTLR_WRITE_FINISH       6



module ExternalSRAMInterface(
	clk,
	clk_oe,
	
	addr_in,
	data_in,
	
	addr_out,
	data_out,
	
   read_q,
   write_q,
	
   read_dn,
   write_dn,
	
	rw_halt,
	
	
	prg_addr,
	prg_data,
	
//	video1_addr,
//	video1_data,
	
	prg_ba,
	prg_bb,
	prg_bc,
	prg_bd,
	
	prg_ce0,
	prg_ce1,
	prg_ce2,
	
	prg_oe,
	
	prg_we,
	
	
//	video1_oe,
//	video1_we,
	

	rst
);

parameter MEM_BEGIN = 0;
parameter MEM_END = 10;

//parameter VIDEO1_ADDR_B = 10;
//parameter VIDEO1_ADDR_E = 100;




	input wire clk;
	input wire rst;
	
	output wire prg_ba = 0;
	output wire prg_bb = 0;
	output wire prg_bc = 0;
	output wire prg_bd = 0;
	
	reg prg_ce_r;
	output wire prg_ce0 = prg_ce_r;
	output wire prg_ce1 = prg_ce_r;
	output wire prg_ce2 = prg_ce_r;
	
	reg prg_oe_r;
	output prg_oe;
	
	reg prg_we_r;
	output prg_we;

  
  reg read_dn_r;
  reg write_dn_r;

  output wire read_dn = read_dn_r;  
  output wire write_dn = write_dn_r;
  
  
  
  reg [7:0] mem_wrk_state;
  
  reg bus_director;
  
  reg [`ADDR_SIZE0:0] tmp_addr;
  reg [`DATA_SIZE0:0] tmp_data;
  
//  reg [`DATA_SIZE0:0] tmp_video_data;

  
  
//   wire is_addr_video1 = prg_addr_r >= VIDEO1_ADDR_B && prg_addr_r < VIDEO1_ADDR_E;
//   wire is_addr_prg = prg_addr_r >= MEM_BEGIN && prg_addr_r < VIDEO1_ADDR_B;

//   wire is_addr_video1 = tmp_addr >= VIDEO1_ADDR_B && tmp_addr < VIDEO1_ADDR_E;
   wire is_addr_prg = tmp_addr >= MEM_BEGIN && tmp_addr < MEM_END; //VIDEO1_ADDR_B;

  

  input wire [`ADDR_SIZE0:0] addr_in;
  input wire [`DATA_SIZE0:0] data_in;
  
  output wire [`ADDR_SIZE0:0] addr_out = tmp_addr;
  output wire [`DATA_SIZE0:0] data_out = /*is_addr_video1 ? tmp_video_data :*/ tmp_data;

  input wire read_q;
  input wire write_q;
    

  inout [`ADDR_SIZE0:0] prg_addr;
  inout [`DATA_SIZE0:0] prg_data;
     
  reg [`ADDR_SIZE0:0] prg_addr_r;  
  tri [`ADDR_SIZE0:0] prg_addr = 
                                  prg_ce_r == 0
											 ?
											   prg_addr_r 
											 : 0
                                  ;

												 
  reg [`DATA_SIZE0:0] prg_data_r;
  tri [`DATA_SIZE0:0] prg_data = 
											is_addr_prg == 1
										   && bus_director == 1
										 ? prg_data_r 
                               : `DATA_SIZE'h zzzz_zzzz_zzzz_zzzz
                               ;
    

//  inout [`ADDR_SIZE0:0] video1_addr;
//  inout [`DATA_SIZE0:0] video1_data;
     
//  reg [`ADDR_SIZE0:0] prg_addr_r;
//  tri [`ADDR_SIZE0:0] video1_addr = 
//												 prg_addr_r 
//                                     ;
	
//  reg [`DATA_SIZE0:0] prg_data_r;
//  tri [`DATA_SIZE0:0] video1_data = 
//                                 is_addr_video1
//										   && bus_director == 1
//										 ? prg_data_r 
//                               : `DATA_SIZE'h zzzz_zzzz_zzzz_zzzz
//                               ;


//  output video1_oe;
//  output video1_we;
  
//  wire video1_oe = is_addr_video1 ? prg_oe_r : 1;
//  wire video1_we = is_addr_video1 ? prg_we_r : 1;


	wire prg_oe = is_addr_prg == 1 ? prg_oe_r : 1;
	wire prg_we = is_addr_prg == 1 ? prg_we_r : 1;

/**
  wire [`DATA_SIZE0:0] int_prg_data = (
											  prg_addr_r >= MEM_BEGIN
											  && prg_addr_r < VIDEO1_ADDR_B
											)
											? prg_data
											: (
                                     prg_addr_r >= VIDEO1_ADDR_B
											    && prg_addr_r < VIDEO1_ADDR_E
											  )
											  ? video1_data
											  : 0
											  ;
/**/

  input wire rw_halt;
  
  input wire clk_oe;

  
  
 
/**/
always @(posedge clk) begin

  if(clk_oe == 0) begin
  
		  if(rw_halt == 1) begin
          mem_wrk_state <= `MEM_CTLR_WAIT;			 
          bus_director <= 0;

          read_dn_r  <= 0;
          write_dn_r <= 0;

          prg_data_r <= 0;
          prg_addr_r <= 0;
        end


  end else begin
  
  if(rst == 1) begin
    tmp_addr <= 0;
	 tmp_data <= 0;
//	 tmp_video_data = 0;
	 	 
    mem_wrk_state <= `MEM_CTLR_WAIT;
    
//    ext_rw_busy <= 0;
	 
	 bus_director <= 0;
	 
	 read_dn_r <= 0;
	 write_dn_r <= 0;
	 
	 prg_data_r <= 0;
	 prg_addr_r <= 0;
	 
	 prg_ce_r <= 1;
	 prg_oe_r <= 0;
	 prg_we_r <= 1;
  end else
  begin
  
/**/
    case(mem_wrk_state)
    
      `MEM_CTLR_WAIT: begin
		  
//        read_dn_r  = 0;
//        write_dn_r = 0;

//        tmp_addr = 0;
//	     tmp_data = 0;
//		  tmp_video_data = 0;
		  
		  prg_ce_r <= 1;
		
        if(read_q == 1 && rw_halt == 0) begin
          read_dn_r  <= 0;
          write_dn_r <= 0;
			 
          if(addr_in >= MEM_BEGIN && addr_in < MEM_END) begin
			 
            tmp_addr <= addr_in;// - INTERNAL_MEM_VALUE;
	         //tmp_data = 0;
            mem_wrk_state <= `MEM_CTLR_READ_SET_ADDRESS;

            bus_director <= 0;
			 end
        end
        else
        if(write_q == 1 && rw_halt == 0) begin
          read_dn_r  <= 0;
          write_dn_r <= 0;

          if(addr_in >= MEM_BEGIN && addr_in < MEM_END) begin
			 
            tmp_addr <= addr_in;// - INTERNAL_MEM_VALUE;
            tmp_data <= data_in;
//			   tmp_video_data = data_in;
            mem_wrk_state <= `MEM_CTLR_WRITE_SET_ADDRESS;

            bus_director <= 1;
			 end
        end
		  else begin
          read_dn_r  <= 0;
          write_dn_r <= 0;

          tmp_addr <= 0;
	       tmp_data <= 0;
			 
			 bus_director <= 0;
		  end
      end

		// read states
      `MEM_CTLR_READ_SET_ADDRESS: begin
		  if(rw_halt == 1) begin
           mem_wrk_state <= `MEM_CTLR_WAIT;			 
			 bus_director <= 0;
        end else
//        if(bus_director == 1)
        begin
          prg_addr_r <= tmp_addr - (/*is_addr_video1 ? VIDEO1_ADDR_B :*/ MEM_BEGIN);

          prg_ce_r <= 0;
			 prg_oe_r <= 0;
			 prg_we_r <= 1;
			 
          mem_wrk_state <= `MEM_CTLR_READ_DATA_GET;
        end
      end

      `MEM_CTLR_READ_DATA_GET: begin
		  if(rw_halt == 1) begin
          mem_wrk_state <= `MEM_CTLR_WAIT;			 
          bus_director <= 0;
        end else
//        if(bus_director == 1) 
        begin
			 
//		    if(
//          is_addr_video1
//          && bus_director == 0
//			 ) begin
//            tmp_video_data = video1_data;
//          end else begin
            tmp_data <= prg_data;
//          end
			 
          read_dn_r <= 1;
          
          mem_wrk_state <= `MEM_CTLR_READ_FINISH;
        end
      end
      
      `MEM_CTLR_READ_FINISH: begin
		  if(rw_halt == 1) begin
           mem_wrk_state <= `MEM_CTLR_WAIT;			 
			 bus_director <= 0;
       end else
//       if(bus_director == 1) 
       begin
         tmp_addr <= 0;
	      tmp_data <= 0;
//			tmp_video_data = 0;

          read_dn_r <= 0;
                    
          mem_wrk_state <= `MEM_CTLR_WAIT;
			 
			 bus_director <= 0;
        end
      end
      
		// write states
      `MEM_CTLR_WRITE_SET_ADDRESS: begin
		  if(rw_halt == 1) begin
          mem_wrk_state <= `MEM_CTLR_WAIT;			 
          bus_director <= 0;
        end else
//        if(bus_director == 1) 
        begin
          prg_addr_r <= tmp_addr - (/*is_addr_video1 ? VIDEO1_ADDR_B :*/ MEM_BEGIN);
          prg_data_r <= tmp_data;

          prg_ce_r <= 0;
			 prg_oe_r <= 0;
          
          mem_wrk_state <= `MEM_CTLR_WRITE_SET_WE;
        end
      end
      
      `MEM_CTLR_WRITE_SET_WE: begin
		  if(rw_halt == 1) begin
          mem_wrk_state <= `MEM_CTLR_WAIT;
          bus_director <= 0;
        end else
//        if(bus_director == 1) 
        begin
          prg_we_r <= 0;
			 
          mem_wrk_state <= `MEM_CTLR_WRITE_FINISH;
        end
      end
          
      `MEM_CTLR_WRITE_FINISH: begin
		  if(rw_halt == 1) begin
          mem_wrk_state <= `MEM_CTLR_WAIT;
          bus_director <= 0;
        end else
//        if(bus_director == 1) 
        begin
          write_dn_r <= 1;
			 
			 prg_we_r <= 1;
          
          mem_wrk_state <= `MEM_CTLR_WAIT;
			 
			 bus_director <= 0;
        end
      end

/**/
		default: begin
        read_dn_r  <= 0;
        write_dn_r <= 0;

        tmp_addr <= 0;
	     tmp_data <= 0;
		  
		  bus_director <= 0;
		  
		  mem_wrk_state <= `MEM_CTLR_WAIT;
		end
/**/

    endcase
	 
/**/

  end
  
  end

end

       
endmodule
