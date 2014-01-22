


`include "sizes.v"
`include "states.v"
`include "inter_cpu_msgs.v"





module DispatcherOfCpus(
            clk,
            rst,
            
            halt_q,
            rw_halt,
            
            addr_out,
            data_wire,
            
            read_q,
            write_q,
            read_dn,
            write_dn,
            
            bus_busy,
            
            ext_rst_b,
            ext_rst_e,
            
            ext_cpu_index,
            
            ext_cpu_q,
            ext_cpu_e,
            
            dispatcher_q
          );
          
  input wire clk;
  input wire rst;

  input wire halt_q;
  inout wire rw_halt;
  
  inout [`ADDR_SIZE0:0] addr_out;
  reg [`ADDR_SIZE0:0] addr_out_r;
  wire [`ADDR_SIZE0:0] addr_out = addr_out_r;
  
  input wire read_q;
  input wire write_q;
  
  output read_dn;
  reg read_dn_r;
  wire read_dn = read_dn_r;
  
  output write_dn;
  reg write_dn_r;
  wire write_dn = write_dn_r;
  
  
  inout [`DATA_SIZE0:0] data_wire;
  reg [`DATA_SIZE0:0] data_wire_r;
  wire [`DATA_SIZE0:0] data_wire = data_wire_r;
  
  inout bus_busy;
  reg bus_busy_r;
  wire bus_busy = bus_busy_r;
  
  

  output reg ext_rst_b; // = RESET;
  input wire ext_rst_e; // = ext_rst_e_r;
  
  inout [`DATA_SIZE0:0] ext_cpu_index;
  reg [`DATA_SIZE0:0] ext_cpu_index_r;
  wire [`DATA_SIZE0:0] ext_cpu_index = ext_cpu_index_r;
  
  output ext_cpu_q;
  reg cpu_q_r;
  wire ext_cpu_q = cpu_q_r;

  input wire ext_cpu_e;
  
  input wire dispatcher_q;
  
  
  
  
  reg [31:0] mem_addr_tmp;
  reg [31:0] mem_data_tmp;
  reg mem_rd;
  reg mem_wr;
  
	reg [31:0] mem [0:100]; 
  initial $readmemh("mem.txt", mem);
  


parameter CPU_QUANTITY = 2;



  reg [`DATA_SIZE0:0] cpu_tbl [0:CPU_QUANTITY];
  reg [`DATA_SIZE0:0] cpu_num;

  reg [7:0] state_ctl;



always @(negedge clk) begin
    
    ext_rst_b = 0;
    
    read_dn_r = 1'b z;
    write_dn_r = 1'b z;
//    bus_busy_r = 1'b z;
    
    cpu_q_r = 0;
    
//    halt_q = 0; //1'bz;
    
  if(rst == 1) begin 
    bus_busy_r = 1'b z;
    
    cpu_num = 0;
    data_wire_r = 32'h zzzzzzzz; //cpu_num; //Q;
    bus_busy_r  = 1'bz;
    
    state_ctl = `CTL_RESET_WAIT;
    
    ext_cpu_index_r = cpu_num; //32'h zzzzzzzz;
    cpu_q_r = 0;
    
    ext_rst_b = 1;
    
    mem_addr_tmp = 0;
    mem_rd = 0;
    mem_wr = 0;
    
  end else /*if(ext_rst_e == 1)*/ begin
//    if(read_q == 1 || write_q == 1)
//      halt_q = 1;


          if(mem_rd == 1 || mem_wr == 1) begin
            if(rw_halt == 1) begin
              mem_rd = 0;
              mem_wr = 0;
              state_ctl = `CTL_CPU_LOOP;
            end else begin
              state_ctl = `CTL_MEM_WORK;
            end
          end 
//          else
//          if(dispatcher_q == 1) begin
//            
//          end else begin
//            state_ctl = `CTL_MEM_WORK;
//          end


    case(state_ctl)
      `CTL_RESET_WAIT: begin
        if(read_dn == 1) begin
          //data_wire_r = data_wire_r + 1;
          cpu_tbl[ext_cpu_index_r] = 0; //32'h ffffffff;
          ext_cpu_index_r = ext_cpu_index_r + 1;
          //data_wire_r = 32'h zzzzzzzz;
          addr_out_r  = 32'h zzzzzzzz;
        end
          
        if(bus_busy == 1) begin
          //cpu_tbl[data_wire] = 0; //32'h ffffffff;
        end
        
        ext_rst_b = 0;
        if(ext_rst_e == 1) begin
          //ext_rst_b = 0;
          ext_cpu_index_r = 32'h zzzzzzzz;
          data_wire_r = 32'h zzzzzzzz;
          state_ctl = `CTL_CPU_LOOP;
        end
      end
      
      `CTL_CPU_LOOP: begin
//        bus_busy_r  = 1;
        ext_cpu_index_r = cpu_num;
        addr_out_r = cpu_tbl[cpu_num];
        
        cpu_num = cpu_num + 1;
        if(cpu_num >= CPU_QUANTITY) begin
          cpu_num = 0;
        end
        
//        cpu_num = cpu_num + 1;
        
//        addr_out_r = cpu_tbl[cpu_num];
        
        cpu_q_r = 1;
        
        state_ctl = `CTL_CPU_CMD;
      end
      
      `CTL_CPU_CMD: begin
          addr_out_r = `ADDR_SIZE'h zzzzzzzz;
        if(cpu_q_r == 1) begin
          cpu_q_r = 0;
        end
        
        if(
          read_q == 1 &&
          mem_rd == 0 &&
          mem_wr == 0
        ) begin
          mem_addr_tmp = addr_out;
          mem_rd = 1;
          mem_wr = 0;
        end else 
        if(
          write_q == 1 &&
          mem_rd == 0 &&
          mem_wr == 0
        ) begin
          mem_addr_tmp = addr_out;
          mem_data_tmp = data_wire;
          mem_rd = 0;
          mem_wr = 1;
        end else 
        if(ext_cpu_e == 1) begin
            //cpu_running = 1;
            //addr_out_r = `ADDR_SIZE'h zzzzzzzz;
          ext_cpu_index_r = `DATA_SIZE'h zzzzzzzz;
          
//          data_wire_r = mem_addr_tmp;
          
            case(data_wire)
              `CPU_R_START: begin
              end
            
              `CPU_R_END: begin
              end
            
            endcase
//          if(mem_rd == 1 || mem_wr == 1) begin
//            state_ctl = `CTL_MEM_WORK;
//          end else
          if(dispatcher_q == 1) begin
            state_ctl = `CTL_CPU_LOOP;
          end else begin
            state_ctl = `CTL_MEM_WORK;
          
//            bus_busy_r  = 1'bz;
          end
        end
      end
      
      `CTL_MEM_WORK: begin

        data_wire_r = 32'h zzzzzzzz;
        addr_out_r  = 32'h zzzzzzzz;
        
//        data_wire_r = 32'h zzzzzzzz;

          if(mem_rd == 1 || mem_wr == 1) begin
            if(bus_busy_r == 1) begin
              bus_busy_r = 1'b z;
              mem_rd = 0;
              mem_wr = 0;
//              halt_q = 0;
              if(dispatcher_q == 1) begin
                state_ctl = `CTL_CPU_LOOP;
              end
            end
          end else begin
              if(dispatcher_q == 1) begin
                state_ctl = `CTL_CPU_LOOP;
              end
          end

          if(mem_rd == 1) begin
            //addr_out_r = 32'h zzzzzzzz;
            addr_out_r = mem_addr_tmp;
            data_wire_r = mem[mem_addr_tmp];
            read_dn_r = 1;
            bus_busy_r = 1;
//            halt_q = 1;
//            mem_rd = 0;
          end 
//          else begin
//         //            data_wire_r = 32'h zzzzzzzz;
//          end

          if(mem_wr == 1) begin
            addr_out_r = mem_addr_tmp;
            mem[mem_addr_tmp] = mem_data_tmp; // data_wire;
            data_wire_r = mem_data_tmp;
            //$monitor("wrote mem[ %x ] = %x",addr_out,mem[addr_out]);
            write_dn_r = 1;
            bus_busy_r = 1;
//            halt_q = 1;
//            mem_wr = 0;
          end
          
          if(dispatcher_q == 1) begin
        //    state_ctl = `CTL_CPU_LOOP;
          end
      
      end
    
    endcase
    
  end
  
end


endmodule