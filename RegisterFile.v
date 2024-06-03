`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/01/2024 03:54:59 PM
// Design Name: 
// Module Name: RegisterFile
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


module RegisterFile(
input [4:0] rs1, 
input [4:0] rs2, 
input [4:0] wa, 
input we, 
input clk,
input [31:0] wd,
output [31:0] rd1, 
output [31:0] rd2
);

reg [31:0] mem[0:31];
integer i;
initial begin
    for(i = 0; i < 32; i = i + 1)
        mem[i] = 0;
end

always @(posedge clk) begin
    if(we) begin 
        mem[wa] = wd;
    end   
end 
   
assign rd1 = mem[rs1];
assign rd2 = mem[rs2];
endmodule
