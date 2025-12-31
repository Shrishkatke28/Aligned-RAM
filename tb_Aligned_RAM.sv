module tb_Aligned_RAM();

    input logic clk,
    input logic rst_n,
    input logic wr_en,
    input logic [31:0]addr,
    input logic [31:0]wdata,
    output logic error

    Aligned_RAM a1 (clk,rst_n,wr_en,addr,wdata,error);

    initial begin
        forever begin
            #5;
            clk=~clk;
        end
    end

    initial begin
        $monitor("Time:%0t\t | wr_en:%b\t  | addr:%h\t | data:%h",$time,wr_en,addr,wdata);
        rst_n=0;
        #11;
        rst_n=1;
        #2;
        wr_en=1;
        #10;
        addr = 32'h4;#10;
        wdata = 32'h8;#10;
        addr = 32'h5;#10;
        wdata = 32'h12;#10;

        wr_en = 0;
        addr = 32'h8;#10;
        wdata = 32'h10;#10;
    #100;
    $finish;

    end

endmodule