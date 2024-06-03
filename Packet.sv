`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/08/2024 11:54:54 PM
// Design Name: 
// Module Name: Packet
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
`ifndef INC_PACKET_SV
`define INC_PACKET_SV
class Packet;
string name;
rand bit [6:0] opcode;
rand bit [4:0] rs1, rs2, rd;
rand bit [11:0] imm;
rand bit [2:0] funct3;
rand bit [6:0] funct7;

constraint opcode_range {
    opcode == 7'b0110011 || opcode == 7'b0010011; 
//    || opcode == 7'b0000011 || opcode == 7'b1100111 || opcode == 7'b0100011  || opcode == 7'b1100011 || opcode == 7'b0110111 || opcode == 7'b1101111;
}
constraint rd_range{
    rd!=5'b00000;
}

constraint funct7_range{
    opcode == 7'b0110011 -> (funct7 == 7'b0000000 || funct7 ==7'b0100000);

}

constraint funct3_range{
    (opcode == 7'b0110011 && funct7 == 7'b0100000) -> (funct3 == 3'b000 || funct3 == 3'b101);
//    opcode == 7'b0000011 -> (funct3 == 3'b000 || funct3 == 3'b001 && funct3 == 3'b010 || funct3 == 3'b100 || funct3 == 3'b101);
//    opcode == 7'b1100111 -> funct3 == 3'b000;
//    opcode == 7'b0100011 -> (funct3 == 3'b000 || funct3 == 3'b001 || funct3 == 3'b010);
//    opcode == 7'b1100011 -> (funct3 == 3'b000 || funct3 == 3'b001 || funct3 == 3'b100 || funct3 == 3'b101 || funct3 == 3'b110 || funct3 == 3'b111);
}

constraint imm_range{
    (opcode == 7'b0010011 && funct3 == 3'b001) -> imm[11:5] == 7'b0000000;
    (opcode == 7'b0010011 && funct3 == 3'b101) -> (imm[11:5] == 7'b0000000 || imm[11:5] == 7'b0100000); 
}

extern function new(string name = "Packet");
extern function bit [31:0] gen();
extern function void display(string prefix = "NOTE");
endclass: Packet


function Packet::new(string name);
    this.name = name;
endfunction: new

function bit [31:0] Packet::gen();
    logic [31:0] inst;
    if(this.opcode == 7'b0110011 || opcode == 7'b1100011)
        inst = {this.funct7, this.rs2, this.rs1, this.funct3, this.rd, this.opcode};
    else if (opcode == 7'b0010011 || opcode == 7'b0000011 || opcode == 7'b1100111) begin
        inst = {this.imm, this.rs1, this.funct3, this.rd, this.opcode};
    end
    
    else if(opcode == 7'b0100011) begin
        inst = {this.funct7, this.rs2, this.rs1, this.funct3, this.rd, this.opcode};
    end
    else if(opcode == 7'b0110111 || opcode == 7'b1101111)
        inst = {this.funct7, this.rs2, this.rs1, this.funct3, this.rd, this.opcode};
    return inst;
    
endfunction: gen


function Packet::display(string prefix = "NOTE");
    $display("Name: %s", name);
    $display("Opcode: %b", opcode);
    $display("rs1: %b", rs1);
    $display("rs2: %b", rs2);
    $display("rd: %b", rd);
    $display("Imm: %b", imm);
    $display("Funct3: %b", funct3); 
    $display("Funct7: %b", funct7); 

endfunction: display


`endif