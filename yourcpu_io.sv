`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/01/2024 12:29:00 AM
// Design Name: 
// Module Name: yourcpu_io
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


interface yourcpu_io(input bit clock);
logic reset_n;
logic [31:0] pc;
logic [31:0] prg_data;
logic [31:0] wb;

clocking cb @(posedge clock);
    default input #1ns output #1ns;
    output reset_n;
    input wb;
endclocking

modport TB(clocking cb, output reset_n, output prg_data, input pc);
endinterface: yourcpu_io
