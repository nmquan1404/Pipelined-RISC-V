`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/01/2024 07:26:58 PM
// Design Name: 
// Module Name: ImmGen
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


module ImmGen(
input [31:0] inst,
input [2:0] sel,
output reg [31:0] extend_imm
    );
//Select
parameter SEL_I_TYPE = 3'b001;
parameter SEL_S_TYPE = 3'b010;
parameter SEL_B_TYPE = 3'b011;
parameter SEL_U_TYPE = 3'b100;
parameter SEL_J_TYPE = 3'b101;

always @(*) begin 
    //I-type
    if(sel == SEL_I_TYPE) begin
        extend_imm = {{21{inst[31]}}, inst[30:25], inst[24:21], inst[20]};
    end
    //S-type
    else if(sel == SEL_S_TYPE) begin
        extend_imm = {{21{inst[31]}}, inst[30:25], inst[11:8], inst[7]};
    end 
    //B-type
    else if(sel == SEL_B_TYPE) begin
        extend_imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
    end
    //U-type
    else if(sel == SEL_U_TYPE) begin
        extend_imm = {inst[31:12], {12{1'b0}}};
    end
    //J-type
    else if(sel == SEL_J_TYPE) begin
        extend_imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:25], inst[24:21], 1'b0};
    end
end

endmodule
