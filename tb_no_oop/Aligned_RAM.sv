// Code your design here
// Code your design here
module Aligned_RAM(
    input logic clk,
    input logic rst_n,
    input logic wr_en,
    input logic [31:0]addr,
    input logic [31:0]wdata,
    output logic error
);

always_ff@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        error <= 0;
    end else begin
        if(wr_en)begin
            if(addr[1:0] == 0)begin
                $display("write success: Time:%0t\t | Addr:%h\t | Data:%h\t",$time,addr,wdata);
                error <= 0;
            end else begin
                $display("ERROR address mismatched: Time:%0t\t | Addr:%h\t | Data:%h",$time,addr,wdata);
                error <= 1;
            end 
        end else begin 
            $display("wr_en is zero");
        end
    end
end
  endmodule


