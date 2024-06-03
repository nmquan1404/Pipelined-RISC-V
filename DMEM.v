`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/01/2024 04:09:53 PM
// Design Name: 
// Module Name: DMEM
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


module DMEM(
input [31:0] addr,
input [31:0] wdata,
input rwe,
input mem_en,
input [1:0] type_access,
input load_signed,
output reg [31:0] rdata
);
reg [7:0] mem[0:1023];
integer i;
initial begin
    for(i = 0; i < 1024; i = i + 1) 
        mem[i] = 0;
end

parameter LOAD_STORE_WORD = 2'b01; 
parameter LOAD_STORE_HALF = 2'b10; 
parameter LOAD_STORE_BYTE = 2'b11; 

always @(*) begin
    if(mem_en) begin
        if(rwe) begin       //ghi
            if(type_access == LOAD_STORE_WORD) begin
                mem[addr] = wdata[7:0];
                mem[addr+1] = wdata[15:8];
                mem[addr+2] = wdata[23:16];
                mem[addr+3] = wdata[31:24];
            end
            else if(type_access == LOAD_STORE_HALF) begin
                mem[addr] = wdata[7:0];
                mem[addr+1] = wdata[15:8];
            end
            else if(type_access == LOAD_STORE_BYTE) begin
                mem[addr] = wdata[7:0];
            end
        end
        else begin          //doc
            if(type_access == LOAD_STORE_WORD) begin
                rdata[7:0] = mem[addr];
                rdata[15:8] = mem[addr+1];
                rdata[23:16] = mem[addr+2];
                rdata[31:24] = mem[addr+3];
            end
            else if(type_access == LOAD_STORE_HALF) begin
                rdata[7:0] = mem[addr];
                rdata[15:8] = mem[addr+1]; 
                if(load_signed) rdata[31:16] = {16{mem[addr+1][7]}};
                else rdata[31:16] = 'h0;
            end
            else if(type_access == LOAD_STORE_BYTE) begin
                rdata[7:0] = mem[addr];
                if(load_signed) rdata[31:8] = {24{mem[addr][7]}};
                else rdata[31:8] = 'h0;
            end
        end
    end
end
endmodule

