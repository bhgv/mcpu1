


`include "sizes.v"
`include "states.v"
`include "inter_cpu_msgs.v"





module DispatcherOfCpus(
            clk,
            rst,
            
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
  
  
	reg [31:0] mem [0:100]; 
  initial $readmemh("mem.txt", mem);
  


parameter CPU_QUANTITY = 1;



  reg [`DATA_SIZE0:0] cpu_tbl [1:CPU_QUANTITY];
  reg [`DATA_SIZE0:0] cpu_num;

  reg [7:0] state_ctl;



always @(negedge clk) begin
    
    ext_rst_b = 0;
    
    read_dn_r = 1'b z;
    write_dn_r = 1'b z;
    bus_busy_r = 1'b z;
    
    cpu_q_r = 0;
    
  if(rst == 1) begin 
    cpu_num = 0;
    data_wire_r = cpu_num; //Q;
    bus_busy_r  = 1'bz;
    
    state_ctl = `CTL_RESET_WAIT;
    
    ext_cpu_index_r = 32'h zzzzzzzz;
    cpu_q_r = 0;
    
    ext_rst_b = 1;
    
  end else /*if(ext_rst_e == 1)*/ begin

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
        
        data_wire_r = 32'h zzzzzzzz;

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
      
      end
    
    endcase
    
  end
  
end


endmodule