`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/08/2024 01:28:24 AM
// Design Name: 
// Module Name: Hazard_detection_unit
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


module Hazard_detection_unit(
input rst,
input MemRead_s3,
input MemEN_s3,
input [4:0] rd_s3,
input [4:0] rs1,
input [4:0] rs2,
output reg PCWrite,
output reg IF_ID_Write,
output reg Control_sel
    );
always @(*) begin
    if(rst) begin
        PCWrite = 1;
        IF_ID_Write = 1;
        Control_sel = 0;
    end
    else if(MemEN_s3 && MemRead_s3 && ((rd_s3 == rs1) || (rd_s3 == rs2))) begin
        PCWrite = 0;    //Khong cho ghi PC moi
        IF_ID_Write = 0; //Khong cho thanh ghi chot gia tri
        Control_sel = 1;    //Cho cac tin hieu dieu khien deu bang 0
    end
    else begin
        PCWrite = 1;
        IF_ID_Write = 1;
        Control_sel = 0;
    end
end

endmodule

