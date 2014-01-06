
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
`include "inter_cpu_msgs.v"




module test;

  reg  CLK;
  reg RESET_r;
  wire RESET = RESET_r;

  
//  reg [`ADDR_SIZE0:0] addr_out_r;
  wire [`ADDR_SIZE0:0] addr_out; // = addr_out_r;
  
  wire read_q;
  wire write_q;
  
//  reg read_dn_r;
  wire read_dn; // = read_dn_r;
  
//  reg write_dn_r;
  wire write_dn; // = write_dn_r;
  
//  wire read_e;
//  wire write_e;
  
  
//  reg [`DATA_SIZE0:0] data_wire_r;
  wire [`DATA_SIZE0:0] data_wire; // = data_wire_r;
  
   
/*
  wire [`DATA_SIZE0:0] src1;
  wire [`DATA_SIZE0:0] src0;
  wire [`DATA_SIZE0:0] dst;
  wire [`DATA_SIZE0:0] dst_h;
  wire [`DATA_SIZE0:0] cond;
  
  wire [`STATE_SIZE0:0] state;
  wire nxt_state;
*/

//  reg bus_busy_r;
  wire bus_busy; // = bus_busy_r;
  
  
 
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

/*
  wire [`ADDR_SIZE0:0] base_addr;
  
  wire rst;
  
  
  reg ext_rst_e_r;
*/

  //reg
  wire ext_rst_b; // = RESET;
  wire ext_rst_e; // = ext_rst_e_r;
  
//  reg [`DATA_SIZE0:0] ext_cpu_index_r;
  wire [`DATA_SIZE0:0] ext_cpu_index; // = ext_cpu_index_r;
  
//  reg cpu_q_r;
  wire ext_cpu_q; // = cpu_q_r;
  wire ext_cpu_e;
  
//  reg cpu_running;
  
//  wire ext_bus_busy;
  
  wire dispatcher_q;
  
  
  
  
	reg [31:0] mem [0:100]; 
  initial $readmemh("mem.txt", mem);
  
//  reg [7:0] stage;

parameter STEP = 20;


parameter CPU_QUANTITY = 1;



Cpu cpu1(
            .clk(CLK),
            
            .addr(addr_out),
            .data(data_wire),
            
            .read_q(read_q),
            .write_q(write_q),
            .read_dn(read_dn),
            .write_dn(write_dn),
            
            .bus_busy(bus_busy),
            
            .ext_rst_b(ext_rst_b),
            .ext_rst_e(ext_rst_e),
            
            .ext_cpu_index(ext_cpu_index),
            
            .ext_cpu_q(ext_cpu_q),
            .ext_cpu_e(ext_cpu_e),
            
            .dispatcher_q(dispatcher_q)
          );

DispatcherOfCpus disp_1(
            .clk(CLK),
            .rst(RESET),
            
            .addr_out(addr_out),
            .data_wire(data_wire),
            
            .read_q(read_q),
            .write_q(write_q),
            .read_dn(read_dn),
            .write_dn(write_dn),
            
            .bus_busy(bus_busy),
            
            .ext_rst_b(ext_rst_b),
            .ext_rst_e(ext_rst_e),
            
            .ext_cpu_index(ext_cpu_index),
            
            .ext_cpu_q(ext_cpu_q),
            .ext_cpu_e(ext_cpu_e),
            
            .dispatcher_q(dispatcher_q)
          );


/*
BridgeToOutside outside_bridge (
            .clk(CLK),
            .state(state),
            
            //base_addr,
            .command(command),
            
            .bus_busy(bus_busy),
            .addr(addr_out),
            .data(data_wire),
            .read_q(read_q),
            .write_q(write_q),
            .read_dn(read_dn),
            .write_dn(write_dn),
            .read_e(read_e),
            .write_e(write_e),
            
            .src1(src1),
            .src0(src0),
            .dst(dst),
            .dst_h(dst_h),
            .cond(cond),
            
            .next_state(nxt_state),
            
            .rst(rst),
            
            .ext_rst_b(ext_rst_b),
            .ext_rst_e(ext_rst_e),
            
            .ext_cpu_index(ext_cpu_index),
            
            .ext_next_cpu_q(ext_cpu_q),
            .ext_next_cpu_e(ext_cpu_e),
            
            .ext_bus_busy(ext_bus_busy),
            
            .ext_dispatcher_q(dispatcher_q)
            );
            
            
  InternalBus int_bus (
            .clk(CLK), 
            .state(state),
            //.base_addr(base_addr),
            .command(command),
            
            .bus_busy(bus_busy),
            .addr(addr_out),
            .read_q(read_q),
            .write_q(write_q),
            .data(data_wire),
            .read_dn(read_dn),
            .write_dn(write_dn),
            .read_e(read_e),
            .write_e(write_e),
            
            //.src1(src1),
            //.src0(src0),
            //.dst(dst),
            //.dst_h(dst_h),
            //.cond(cond),
            
            .next_state(nxt_state),
            
            .rst(rst)
            );

*/

/*
reg [`DATA_SIZE0:0] cpu_tbl [1:CPU_QUANTITY];
reg [`DATA_SIZE0:0] cpu_num;

reg [7:0] state_ctl;
*/

initial begin
// $monitor("RESET=%b  CLK=%b  Q=%b",RESET,CLK,Q);
                      RESET_r = 1'bz;
           #(STEP*3)  RESET_r = 1'b1;
           #(STEP)  RESET_r = 1'bz;
           //#(STEP*20) RESET = 1'b1;
           //#STEP      RESET = 1'b0;
           #(STEP*40) //stage = 0; cpu_running = 0;
           #(STEP*125); //90)
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


/*
always @(negedge CLK) begin

//    addr_out_r = 32'h zzzzzzzz;
//    data_wire_r = 32'h zzzzzzzz;
    
    ext_rst_b = 0;
    
    read_dn_r = 1'b z;
    write_dn_r = 1'b z;
    bus_busy_r = 1'b z;
    
//    ext_rst_e_r = 1'b z;
    cpu_q_r = 0;
//    ext_cpu_index_r = 32'h zzzzzzzz;
    
  if(RESET == 1) begin 
    cpu_num = 0;
    data_wire_r = cpu_num; //Q;
    bus_busy_r  = 1'bz;
    
    state_ctl = `CTL_RESET_WAIT;
    
        //read_dn = 1;

    //addr_out_r = 32'h zzzzzzzz;
    //bus_busy_r = 1'b z;
    //read_dn = 0;
    //write_dn = 0;
    
    ext_cpu_index_r = 32'h zzzzzzzz;
    cpu_q_r = 0;
    
//    cpu_running = 0;
    
    //stage = 0;
    
    ext_rst_b = 1;
    
//    ext_rst_e_r = 1;
  end else begin
  
//    data_wire_r = 32'h zzzzzzzz;
//    addr_out_r  = 32'h zzzzzzzz;

    case(state_ctl)
      `CTL_RESET_WAIT: begin
        if(read_dn == 1) begin
          data_wire_r = 32'h zzzzzzzz;
          addr_out_r  = 32'h zzzzzzzz;
        end
          
        if(bus_busy == 1) begin
          cpu_tbl[data_wire] = 0; //32'h ffffffff;
        end
        
        if(ext_rst_e == 1) begin
          ext_rst_b = 0;
          
          state_ctl = `CTL_CPU_LOOP;
        end
      end
      
      `CTL_CPU_LOOP: begin
        if(cpu_num == CPU_QUANTITY) begin
          cpu_num = 0;
        end
        ext_cpu_index_r = cpu_num;
        
        cpu_num = cpu_num + 1;
        
        addr_out_r = cpu_tbl[cpu_num];
        
        cpu_q_r = 1;
        
        state_ctl = `CTL_CPU_CMD;
      end
      
      `CTL_CPU_CMD: begin
        if(cpu_q_r == 1) begin
          cpu_q_r = 0;
        end
        if(ext_cpu_e == 1) begin
          //cpu_running = 1;
          addr_out_r = 32'h zzzzzzzz;
          ext_cpu_index_r = 32'h zzzzzzzz;
          
          case(data_wire)
            `CPU_R_START: begin
            end
            
            `CPU_R_END: begin
            end
            
          endcase
          
          state_ctl = `CTL_MEM_WORK;
        end
      end
      
      `CTL_MEM_WORK: begin

        data_wire_r = 32'h zzzzzzzz;
        addr_out_r  = 32'h zzzzzzzz;
        

//    if(stage < 3) stage = stage + 1;
//  
//    if(stage == 2) begin
//    
//      addr_out_r = 0;
//      ext_cpu_index_r = cpu_num;
//      cpu_q_r = 1;
    
//    end else if( cpu_q_r == 1) begin
//      cpu_q_r = 0;
//    end else if(ext_cpu_e == 1) begin
//      cpu_running = 1;
//    end else 

//    if(cpu_running == 1) begin

          data_wire_r = 32'h zzzzzzzz;
//      case(state)
/*
        `FINISH_END: begin
          state_ctl = `CTL_CPU_LOOP;
        end
        
        `READ_COND, 
        `READ_DATA, 
        `START_READ_CMD: begin
          if(read_q == 1) begin
            //addr_out_r = 32'h zzzzzzzz;
            addr_out_r = addr_out;
            data_wire_r = mem[addr_out];
            read_dn_r = 1;
            bus_busy_r = 1;
         // end else begin
         //            data_wire_r = 32'h zzzzzzzz;
          end
        end
*/

/*
        
//        default: begin
          if(read_q == 1) begin
            //addr_out_r = 32'h zzzzzzzz;
            addr_out_r = addr_out;
            data_wire_r = mem[addr_out];
            read_dn_r = 1;
            bus_busy_r = 1;
          end else begin
         //            data_wire_r = 32'h zzzzzzzz;
          end

          if(write_q == 1) begin
            addr_out_r = addr_out;
            mem[addr_out] = data_wire;
            //$monitor("wrote mem[ %x ] = %x",addr_out,mem[addr_out]);
            write_dn_r = 1;
          end
          
          if(dispatcher_q == 1) begin
            state_ctl = `CTL_CPU_LOOP;
          end
          
//        end
//      endcase
      
    end
    
    
      //end
    endcase
    
    
    
  end
  
end
*/


//always @(negedge RESET) begin
//  data_wire_r = 32'h zzzzzzzz;
//  addr_out_r = 32'h zzzzzzzz;
//  bus_busy_r = 1'b z;
//end
       
endmodule
