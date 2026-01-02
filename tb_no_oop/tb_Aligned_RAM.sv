
module tb_Aligned_RAM();

   logic clk;
   logic rst_n;
   logic wr_en;
   logic [31:0]addr;
  
  logic [31:0]wdata;
  logic error;
    Aligned_RAM a1 (clk,rst_n,wr_en,addr,wdata,error);

    initial begin
            clk =0;
        forever #5 clk=~clk;       
    end
    initial begin
//         $monitor("Time:%0t\t | wr_en:%b\t  | addr:%h\t | data:%h",$time,wr_en,addr,wdata);
        rst_n=0;
        @(posedge clk);
        rst_n=1;
        #2;
    end
        task drive_mem(input [31:0]a,input [31:0]d);
            @(posedge clk);
            wr_en <= 1;
            addr <= a;
            wdata <= d;
            
            @(posedge clk);
          wr_en<=0;
        endtask
task check_result(input [31:0]a_sent);
// @(posedge clk);
logic expected_error; 
            if(a_sent[1:0] == 0)begin
                expected_error = 0;
            end else begin
                expected_error = 1;
            end
            if(expected_error == error) begin
                $display("write success: Time:%0t\t | Addr:%h\t | Data:%h\t",$time,addr,wdata);
            end else begin
                $display("ERROR: Time:%0t\t | Addr:%h\t | Data:%h",$time,addr,wdata);
            end
endtask
    initial begin
        bit [31:0]t_addr;
        bit [31:0]t_data;
        repeat(10) begin
        t_addr=$urandom();
        t_data=$urandom();
            drive_mem(t_addr,t_data);
          @(posedge clk);
            check_result(t_addr);
        end
        $finish;
    end
endmodule