`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/08/2024 12:16:34 PM
// Design Name: 
// Module Name: Control_hazard_unit
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


module Control_hazard_unit(
input [4:0] rs1_s2,
input [4:0] rs2_s2,
input [4:0] rd_s3,
input [4:0] rd_s4,
input [31:0] data_rs1,
input [31:0] data_rs2,
input [31:0] alu_result_s3,
input [31:0] wb_s4,
input BrUn,
output BrEq,
output BrLT 
);

reg [31:0] data_op1;
reg [31:0] data_op2;
initial begin
    data_op1 = 0;
    data_op2 = 0;
end

always @(*) begin
    if(rs1_s2 == rd_s3)
        data_op1 = alu_result_s3;
    else if(rs1_s2 == rd_s4)
        data_op1 = wb_s4;
    else data_op1 =  data_rs1;
    
    
    if(rs2_s2 == rd_s3)
        data_op2 = alu_result_s3;
    else if(rs2_s2 == rd_s4)
        data_op2 = wb_s4;
    else data_op2 =  data_rs2;   
    
end
    
assign BrEq = (data_op1 == data_op2) ? 1 : 0;
assign BrLT = (BrUn) ? ((data_op1 < data_op2) ? 1 : 0) : ((((~data_op1+1) < (~data_op2+1)) ? 1 : 0));

endmodule
