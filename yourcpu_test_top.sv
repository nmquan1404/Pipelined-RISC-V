`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/08/2024 10:37:33 PM
// Design Name: 
// Module Name: yourcpu_test_top
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


module yourcpu_test_top();
parameter simulation_cycle = 100;
bit SystemClock;
initial begin
    SystemClock = 0;
end

always #(simulation_cycle/2) SystemClock = ~SystemClock;

yourcpu_io cpu_io(SystemClock);
test t(cpu_io);
pipelined_processor dut(.clk(cpu_io.clock),
                        .rst(cpu_io.reset_n),
                        .pc(cpu_io.pc),
                        .prg_data(cpu_io.prg_data),
                        .wb(cpu_io.wb));
endmodule
