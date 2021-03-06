
`include "sizes.v"
`include "states.v"
`include "inter_cpu_msgs.v"

`include "defines.v"


`define MEM_CTLR_WAIT  0
`define MEM_CTLR_READ  1
`define MEM_CTLR_WRITE 2
//`define MEM_CTLR_NULL  3



module InternalStartupRAM(
	clk,
	clk_oe,
	
	data_in,
	data_out,
	
	addr_in,
	addr_out,
	
	read_q,
	write_q,
	
	read_dn,
	write_dn,
	
   rw_halt,
	
	rst
);

parameter INTERNAL_MEM_VALUE = `INTERNAL_MEM_VALUE; //200;
parameter INTERNAL_MEM_FILE = `INTERNAL_MEM_FILE; //"mem.txt";



	input wire clk;
	input wire rst;  
   

//  wire bus_busy; 
  
  reg bus_director;
  

  input wire read_q;
  input wire write_q;
    
  reg read_dn_r;
  reg write_dn_r;

  output read_dn;
  output write_dn;
  
  wire read_dn = read_dn_r;
  wire write_dn = write_dn_r;
  

  reg [`ADDR_SIZE0:0] addr_r; 
  
  input wire [`ADDR_SIZE0:0] addr_in; 
  output wire [`ADDR_SIZE0:0] addr_out = 
                               read_dn_r == 1
										 || write_dn_r == 1
										 ? tmp_addr  //addr_r
										 : 0
										 ; 
  
//  assign addr_out = addr_r;
	
  
  reg [`DATA_SIZE0:0] data_r;
  
  input wire [`DATA_SIZE0:0] data_in; 
  output [`DATA_SIZE0:0] data_out; 
  wire [`DATA_SIZE0:0] data_out =
                              read_dn_r == 1
										? data_r
										: write_dn_r == 1
										? tmp_data
										: 0
										;

//  assign data_out = data_r;  
  
  
  reg [`ADDR_SIZE0:0] tmp_addr;
  reg [`DATA_SIZE0:0] tmp_data;
  
  reg [2:0] mem_wrk_state;
  
  
  
	reg [`DATA_SIZE:0] mem [0:INTERNAL_MEM_VALUE-1]; 
   initial $readmemh(INTERNAL_MEM_FILE, mem); //("mem.txt", mem);
//   initial $readmemh("mem.txt", mem);
	
	reg [`DATA_SIZE0:0] mem_out_tmp;




/**
//altera megafunc mem VVV
  wire [`DATA_SIZE0:0] mem_data_out;
  
  MemMod mem_inst(
	.clock(clk),
	.address(tmp_addr),
	.data(tmp_data),
	.wren(mem_wrk_state == `MEM_CTLR_WRITE && clk_oe == 0 && clk == 1),
	.q(mem_data_out)
	);
// ......  AAA
/**/




   input wire rw_halt;


   input wire clk_oe;


//	reg is_rw_hlt;

  wire [`INTERNAL_MEM_ADDR_BITS-1:0] int_mem_addr = tmp_addr[`INTERNAL_MEM_ADDR_BITS-1:0];


/**/
always @(negedge clk_oe) begin
  case(mem_wrk_state)
    `MEM_CTLR_READ: begin
      /*mem_out_tmp*/data_r <= mem[int_mem_addr];
	 end
	 
	 `MEM_CTLR_WRITE: begin
      mem[int_mem_addr] <= tmp_data;
//		data_r = tmp_data;
	 end
	 
  endcase
end
/**/


always @(posedge clk) begin

  if(clk_oe == 0) begin
  
		  if(rw_halt == 1) begin
          mem_wrk_state <= `MEM_CTLR_WAIT;			 
          bus_director <= 0;

          read_dn_r  <= 0;
          write_dn_r <= 0;

//          data_r = 0; //`DATA_SIZE'h zzzz_zzzz_zzzz_zzzz;
//          addr_r = 0; //`ADDR_SIZE'h zzzz_zzzz_zzzz_zzzz;
        end


  end else begin
  
  if(rst == 1) begin
//    data_wire_r = 0; //`DATA_SIZE'h zzzz_zzzz_zzzz_zzzz;
	 
//    ext_rw_busy = 0;
	 
	bus_director <= 0;
	 
	read_dn_r <= 0;
	write_dn_r <= 0;
	 
//	 data_r = 0; //`DATA_SIZE'h zzzz_zzzz_zzzz_zzzz;
//	 addr_r = 0; //`ADDR_SIZE'h zzzz_zzzz_zzzz_zzzz;
	 
	 //mem[2 + 15] = `DATA_SIZE'h 10;
	 
	tmp_addr <= `THREAD_HEADER_SPACE + `REG_IP;
	tmp_data <= `REG_IP + `THREAD_REGS_TO_CODE_SPACE;

	mem_wrk_state <= `MEM_CTLR_WRITE; //`MEM_CTLR_WAIT;
  end else
  begin

/**/
    case(mem_wrk_state)
    
	   default:
      //`MEM_CTLR_WAIT: 
		begin
		  
//        read_dn_r  = 0;
//        write_dn_r = 0;

//        data_r = 0; //`DATA_SIZE'h zzzz_zzzz_zzzz_zzzz;
//        addr_r = 0; //`ADDR_SIZE'h zzzz_zzzz_zzzz_zzzz;
		
        if(/*ext_*/ read_q == 1 && rw_halt == 0) begin
          if(addr_in <= INTERNAL_MEM_VALUE) begin
			 
            tmp_addr <= addr_in;
            mem_wrk_state <= `MEM_CTLR_READ;
//          ext_mem_data_r = mem[ext_mem_addr];
//          ext_read_dn = 1;

            read_dn_r  <= 0;
            write_dn_r <= 0;

		      bus_director <= 1;
			 
			 end
        end
        else
        if(/*ext_*/ write_q == 1 && rw_halt == 0) begin
          if(addr_in <= INTERNAL_MEM_VALUE) begin
			 
            tmp_addr <= addr_in;
            tmp_data <= data_in;
            
				mem_wrk_state <= `MEM_CTLR_WRITE;
				
//          mem[ext_mem_addr] = ext_mem_data;
//          ext_write_dn = 1;

            read_dn_r  <= 0;
            write_dn_r <= 0;

            bus_director <= 1;
			 
			 end
        end
		  else
		  begin
            read_dn_r  <= 0;
            write_dn_r <= 0;
		  end
      end

      `MEM_CTLR_READ: begin
		 //if(rw_halt == 1) begin
       //  mem_wrk_state = `MEM_CTLR_WAIT;			 
       //  bus_director = 0;
       //end else
//       if(bus_director == 1) begin
          //data_r = mem_out_tmp; //mem[tmp_addr[`INTERNAL_MEM_ADDR_BITS-1:0]];//mem_data_out;//
//          addr_r = tmp_addr;
          read_dn_r <= 1;
          
          mem_wrk_state <= `MEM_CTLR_WAIT;
			 
			 bus_director <= 0;
//        end
      end
          
      `MEM_CTLR_WRITE: begin
		  //if(rw_halt == 1) begin
        //  mem_wrk_state = `MEM_CTLR_WAIT;			 
        //  bus_director = 0;
        //end else
//        if(bus_director == 1) begin
		  
          //mem[tmp_addr[`INTERNAL_MEM_ADDR_BITS-1:0]] = tmp_data;
          //data_r = tmp_data;
//          addr_r = tmp_addr;
          write_dn_r <= 1;
          
          mem_wrk_state <= `MEM_CTLR_WAIT;
			 
			 bus_director <= 0;
//        end
      end
          
    endcase
/**/

  end
  
  end
          
end

endmodule
