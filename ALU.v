`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/01/2024 04:15:02 PM
// Design Name: 
// Module Name: ALU
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


module ALU(
input [31:0] dataA,
input [31:0] dataB,
input [3:0] sel,
output reg [31:0] result,
output zero
);
always @(*) begin
    case (sel)
        4'b0010: result = dataA + dataB;            //add, addi
        4'b0110: result = dataA - dataB;            //sub
        4'b0000: result = dataA & dataB;            //and, andi
        4'b0001: result = dataA | dataB;            //or, ori
        4'b0011: result = dataA << dataB;           //sll, slli
        4'b0100: begin                              //slt, slti
                     if((~dataA+1) < (~dataB+1)) result = 1;
                     else result = 0;
                 end
        4'b0101: begin                              //sltu, sltiu
                    if(dataA < dataB) result = 1;
                    else result = 0;
                 end 
        4'b0111: result = dataA ^ dataB;            //xor, xori
        4'b1000: result = dataA >> dataB;           //srl, srli
        4'b1010: result = dataA >>> dataB;          //sra, srai
        4'b1111: result = dataB;                    //lui
        default: result = 32'hxxxxxxxx;
    endcase
end 
assign zero = (!result) ? 1 : 0;
endmodule
