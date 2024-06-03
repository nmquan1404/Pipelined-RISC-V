`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/06/2024 10:38:43 PM
// Design Name: 
// Module Name: test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


//module test();

//reg clk;
//reg rst;
//wire [31:0] pc, wb, prg_data;
//initial begin
//    clk = 0;
//    rst = 1;
//    #10
//    rst = 0;
//    #100 
//    rst = 1;
//end

//always #5 clk = ~clk;

//pipelined_processor processor(clk, rst, pc, prg_data, wb);
//endmodule

program automatic test(yourcpu_io.TB cpu_io);

Packet pkt2send;
static int pkts_generated = 30;
logic [31:0] inst_arr[$];
initial begin
    reset();
    gen();
    driver();
end

task reset();
    cpu_io.reset_n <= 0;
    ##2 cpu_io.cb.reset_n <= 1;
endtask: reset

task gen();
    logic [31:0] inst;
    integer i;
    for(i = 0; i < pkts_generated; i = i + 1) begin
        pkt2send = new($sformatf("pkt[%0d]",i));
        pkt2send.randomize();
        inst = pkt2send.gen();
        inst_arr.push_back(inst);
    end
endtask: gen

bit [31:0] addr;
bit [31:0] inst;

task driver();
    forever begin #1
        addr = cpu_io.pc >> 2;
        inst = inst_arr[addr];
        cpu_io.prg_data <= inst;
    end
endtask: driver
endprogram