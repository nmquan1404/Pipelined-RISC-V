`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/06/2024 10:52:36 PM
// Design Name: 
// Module Name: Forwarding_unit
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


module Forwarding_unit(
input [4:0] rs1_s3,
input [4:0] rs2_s3,
input RegWEn_s4,
input RegWEn_s5,
input [4:0] rd_s4,
input [4:0] rd_s5,
output reg [1:0] ASel,
output reg [1:0] BSel
    );
    
always @(*) begin
    ASel = 2'b00;
    BSel = 2'b00;
    // EX hazard
    if(RegWEn_s4 && rd_s4!=0 && rd_s4 == rs1_s3) ASel = 2'b10;
    if(RegWEn_s4 && rd_s4!=0 && rd_s4 == rs2_s3) BSel = 2'b10;

    //MEM hazard
    if(RegWEn_s5 && rd_s5!=0 && !(RegWEn_s4 && rd_s4!=0 && rd_s4 == rs1_s3) && rd_s5 == rs1_s3) ASel = 2'b01; 
    if(RegWEn_s5 && rd_s5!=0 && !(RegWEn_s4 && rd_s4!=0 && rd_s4 == rs2_s3) && rd_s5 == rs2_s3) BSel = 2'b01; 

end
endmodule
