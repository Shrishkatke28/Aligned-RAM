// Code your testbench here
// or browse Examples
interface intf(input clk,input rst_n);
 logic wr_en;
 logic [31:0]addr;
 logic [31:0]wdata;
 logic       error;

 modport driver(output wr_en,addr,wdata);
 modport monitor(input wr_en,addr,wdata,error);

endinterface

class transaction;
    rand logic wr_en;
    rand logic [31:0]addr;
    rand logic [31:0]wdata;
           bit       error;

    constraint c1{
      addr[1:0]== 0;
        wdata == 0;
//       wr_en == 1;
    };

  virtual task display(string name);
        $display("[%s] wr_en:%b | addr:%h | wdata:%h error:%b",name,wr_en,addr,wdata,error);
    endtask

endclass

class bad_transaction extends transaction;
    constraint c1{addr [1:0]!=0;}
    // display("Bad_tarnsaction");
// endclass

virtual task display(string name);
    super.display("Bad_transaction");
endtask

endclass


class generator;
transaction tr;
mailbox gen2drive;

function new(mailbox gen2drive);
    this.gen2drive = gen2drive;
endfunction

task main;
bad_transaction bad_tr;
    repeat(10)begin
        
        randcase
        70:tr=new();
        30:begin bad_tr =new(); tr=bad_tr; end
        endcase
        tr.randomize();
        gen2drive.put(tr);
        tr.display("GEN");
    end

endtask
endclass

class driver;
mailbox gen2drive;
transaction tr;
virtual intf vif;

function new(mailbox gen2drive,virtual intf vif);
    this.gen2drive = gen2drive;
    this.vif= vif;
endfunction

//you could add forever loop so that there no need to use repeat and before running task main put one clock delay as mailbox empty at start so it would give
//head start 
task main;
    repeat(10) begin
        @(posedge vif.clk)
      gen2drive.get(tr);
      
    // tr=new(); // not necessary
//     gen2drive.get(tr);
    // vif.wr_en <= tr.wr_en;
    // vif.addr <= tr.addr;
    // vif.wdata <= tr.wdata;
      vif.wr_en = tr.wr_en;
    vif.addr = tr.addr;
    vif.wdata = tr.wdata;
    tr.display("DRV");
      @(posedge vif.clk);
        
    end    
endtask

endclass

class monitor;
transaction tr;
mailbox mon2soc;
virtual intf vif;

function new(mailbox mon2soc,virtual intf vif);
    this.mon2soc = mon2soc;
    this.vif = vif;
endfunction

task main;
forever begin
tr=new();
    @(posedge vif.clk);
//     if(tr.wr_en)begin
if(vif.wr_en)begin
    tr.wdata = vif.wdata;
    tr.addr = vif.addr;
    tr.wr_en = vif.wr_en;
    @(posedge vif.clk);
  #1;
    tr.error = vif.error; 
    mon2soc.put(tr);
    tr.display("MON");
    end
end 
endtask
endclass

class scoreboard;
transaction tr;
mailbox mon2soc;

function new(mailbox mon2soc);
    this.mon2soc = mon2soc;
endfunction

function check_result(transaction tr);

    if(tr.addr[1:0] == 2'b00)begin
//       tr.display("SOC");
        if(tr.error == 0) begin
      $display("pass aligned address | addr:%h",tr.addr);
        end else begin
            $display("ERROR");
        end     
    end else begin
//       tr.display("SOC");
if(tr.error == 1)begin
      $display("pass  unaligned address| addr:%h",tr.addr);
end
    end


endfunction

task main;
forever begin
tr = new();
mon2soc.get(tr);
check_result(tr);
tr.display("SOC");
end 

endtask


endclass

class enviroment;
virtual intf vif;
generator gen;
driver drv;
monitor mon;
scoreboard soc;
mailbox gen2drive;
mailbox mon2soc;

function new(virtual intf vif);
    this.vif = vif;


    gen2drive = new();
    mon2soc = new();

    gen=new(gen2drive);
    drv=new(gen2drive,vif);
    mon=new(mon2soc,vif);
    soc=new(mon2soc);
endfunction


task main;
    fork
        gen.main();
        drv.main();
        mon.main();
        soc.main();
    join_any
    wait(mon2soc.num() == 0);
    #200;
    $finish;
endtask
endclass

module top();

logic clk,rst_n;

initial begin
    clk=0;
    forever #5 clk=~clk;
end

initial begin
    rst_n=0;
    @(posedge vif.clk);
    rst_n=1;
end

intf vif(clk,rst_n);


Aligned_RAM a1 (
  .clk(clk),    
  .rst_n(rst_n),  
  .wr_en(vif.wr_en),
  .addr(vif.addr),
  .wdata(vif.wdata),
  .error(vif.error)
);


enviroment env;

initial begin
    env=new(vif);
    env.main();
end


endmodule