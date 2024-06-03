`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/04/2024 04:10:04 PM
// Design Name: 
// Module Name: pipelined_processor
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


module pipelined_processor(
input clk,
input rst,
output reg [31:0] pc,
//output reg [31:0] prg_data,
input [31:0] prg_data,
output [31:0] wb
 );
    

reg [31:0] pc_s2;           //pc at stage ID
reg [31:0] pc_s3;           //pc at stage EX
wire [31:0] pc_incr4;       //pc incr4 
reg [31:0] pc_incr4_s2;     //pc incr4 at stage ID
reg [31:0] pc_incr4_s3;     //pc incr4 at stage EX
reg [31:0] pc_incr4_s4;     //pc incr4 at stage MEM
assign pc_incr4 = pc + 4;   

reg [31:0] inst;        //instruction at stage ID
wire [4:0] rs1;         //source register at stage ID
reg [4:0] rs1_s3;       //source register at stage EX
wire [4:0] rs2;         //source register at stage ID
reg [4:0] rs2_s3;       //source register at stage EX
wire [4:0] rd;          //Destination register
wire [4:0] rd_s2;       //Destination register at stage ID
reg [4:0] rd_s3;        //Destination register at stage EX
reg [4:0] rd_s4;        //Destination register at stage MEM
reg [4:0] rd_s5;        //Destination register at stage WB
wire [6:0] opcode;
wire [2:0] funct3;


assign rs1 = inst[19:15];
assign rs2 = inst[24:20];
assign rd_s2 = inst[11:7];
assign rd = rd_s5;
assign opcode = inst[6:0];
assign funct3 = inst[14:12];

reg [1:0] PCSel;     //select addr write to pc
wire [1:0] Asel;     //Select operand for ALU
wire [1:0] Bsel;     //Select operand for ALU
wire [3:0] ALUSel;   //Select function for ALU
wire [31:0] wb_s4;   //data write back at stage MEM
reg [31:0] wb_s5;    //data write back at stage WB

wire [31:0] data_read_r1_s2;        //data read from registerfile at rs1
wire [31:0] data_read_r2_s2;        //data read from register file at rs2
reg [31:0] data_read_r1_s3;         //data read from registerfile at rs1 - stage EX
reg [31:0] data_read_r2_s3;         //data read from registerfile at rs2 - stage EX

reg [3:0] ALUSel_s2;                ///ALU select function at stage ID
reg [3:0] ALUSel_s3;                //ALU select function at stage EX
assign ALUSel = ALUSel_s3;

wire MemRW;          //DataMem Write enable
reg MemRW_s2;                       //Data memory write enable at stage ID
reg MemRW_s3;                       //Data memory write enable at stage EX
reg MemRW_s4;                       //Data memory write enable at stage MEM
assign MemRW = MemRW_s4;

wire MemEN;                         //Data memory access
reg MemEN_s2;                       //Data memory access at stage ID
reg MemEN_s3;                       //Data memory access at stage EX
reg MemEN_s4;                       //Data memory access at stage MEM
assign MemEN = MemEN_s4;

wire [1:0] WBSel;                   //Select data write back
reg [1:0] WBSel_s2;                 //Select data write back at stage ID
reg [1:0] WBSel_s3;                 //Select data write back at stage EX
reg [1:0] WBSel_s4;                 //Select data write back at stage MEM
assign WBSel = WBSel_s4;

wire RegWEn;         //Register File write enable
reg RegWEn_s2;       //Register File write enable at stage ID               
reg RegWEn_s3;       //Register File write enable at stage EX 
reg RegWEn_s4;       //Register File write enable at stage MEM
reg RegWEn_s5;       //Register File write enable at stage WB
assign RegWEn = RegWEn_s5;

wire ALU_src2;          //select source operand for ALU
reg ALU_src2_s2;        //select source operand for ALU at stage ID
reg ALU_src2_s3;        //select source operand for ALU at stage EX
assign ALU_src2 = ALU_src2_s3;

wire ALU_src1;          //select source operand for ALU
reg ALU_src1_s2;        //select source operand for ALU at stage ID
reg ALU_src1_s3;        //select source operand for ALU at stage EX
assign ALU_src1 = ALU_src1_s3;

reg [2:0] ImmSel;       //immediate extend select
wire [31:0] imm;        //immediate after extending
wire [31:0] imm_s2;     //immediate after extending at stage ID
reg [31:0] imm_s3;      //immediate after extending at stage EX
assign imm = imm_s3;

wire [31:0] imm_branch;     //danh cho cac lenh B-type
assign imm_branch = ({{16{imm_s2[15]}},imm_s2[15:0]} << 1) + pc_s2;

reg [31:0] address_jalr;       //dia chi ma lenh jalr nhay den
wire [31:0] op1_s3;         //operand 1 for ALU after first select   
wire [31:0] op2_s3;         //operand 2 for ALU after first select
wire [31:0] op1_s3_final;   //operand 1 for ALU after second select
wire [31:0] op2_s3_final;   //operand 2 for ALU after second select
reg [31:0] op2_s4;          //operand 2 after first select at stage MEM
wire [31:0] alu_result_s3;  //alu result at stage EX
reg [31:0] alu_result_s4;   //alu result at stage MEM
wire zero_s3;               

wire PCWrite;               //PC Write enable
wire IF_ID_Write;           //IF/ID Register write enable
wire Control_sel;           //Select control source for EX, MEM and WB 
wire [31:0] rdata_s4;       //data read at DMEM

//type access
//01: word
//10: halfword
//11: byte
wire [1:0]type_access;          //type access DMEM
reg [1:0] type_access_s2;
reg [1:0] type_access_s3;
reg [1:0] type_access_s4;
wire load_signed;               //load data from DMEM signed / unsigned
reg load_signed_s2;
reg load_signed_s3;
reg load_signed_s4;

reg BrUn;                       //compare signed / unsigned operand
wire BrEq;                      //compare equal
wire BrLT;                      //compare less than

wire [3:0] ALUSel_s2_final;     //ALU select function final at stage ID
wire MemRW_s2_final;            //DMEM write/read enable final at stage ID
wire [1:0] WBSel_s2_final;      //Select WB data final at stage ID
wire RegWEn_s2_final;           //RegisterFile write enable final at stage ID
wire ALU_src2_s2_final;         //ALU src final at stage ID
wire ALU_src1_s2_final;         //ALU src final at stage ID
wire MemEN_s2_final;            //DMEM access enable final at stage ID

assign op1_s3 = (Asel == 2'b00) ? data_read_r1_s3:
                (Asel == 2'b01) ? wb :
                (Asel == 2'b10) ? alu_result_s4 : 'hz;
                
assign op2_s3 = (Bsel == 2'b00) ? data_read_r2_s3:
                (Bsel == 2'b01) ? wb :
                (Bsel == 2'b10) ? alu_result_s4 : 'hz;

assign op1_s3_final = (ALU_src1) ? pc_s3 : op1_s3;
assign op2_s3_final = (ALU_src2) ? imm : op2_s3;

assign  type_access = type_access_s4;
assign load_signed = load_signed_s4;    //=1 thì load signed, =0 thì load unsigned

//Create JALR unit========================================================================
always @(*) begin
    if(inst[6:0] == 7'b1100111) begin
        if(!MemRW_s3 && rs1 == rd_s3) 
            address_jalr = (alu_result_s3 + imm_s2) & (~1);
        else if(!MemRW_s4 && rs1 == rd_s4)
            address_jalr = (wb_s4 + imm_s2) & (~1);
        else if(rs1 == rd_s5)
            address_jalr = (wb_s5 + imm_s2) & (~1);
        else address_jalr = (data_read_r1_s2 + imm_s2) & (~1);
    end
end

RegisterFile rf(.rs1(rs1), 
                .rs2(rs2),
                .wa(rd),
                .we(RegWEn),
                .clk(clk),
                .wd(wb),
                .rd1(data_read_r1_s2),
                .rd2(data_read_r2_s2));
                

ImmGen generate_imm (inst, ImmSel, imm_s2);
 
ALU alu(.dataA(op1_s3_final),
        .dataB(op2_s3_final),
        .sel(ALUSel),
        .result(alu_result_s3),
        .zero(zero_s3));

Forwarding_unit forward_unit(rs1_s3, rs2_s3, RegWEn_s4, RegWEn_s5, rd_s4, rd_s5, Asel, Bsel);

Hazard_detection_unit hazard_unit(!rst, !MemRW_s3, MemEN_s3, rd_s3, rs1, rs2, PCWrite, IF_ID_Write, Control_sel);

Control_hazard_unit control_hazard(rs1, rs2, rd_s3, rd_s4, data_read_r1_s2, data_read_r2_s2, alu_result_s3, wb_s4, BrUn, BrEq, BrLT);

DMEM dmem(.addr(alu_result_s4),
          .wdata(op2_s4),
          .rwe(MemRW),
          .mem_en(MemEN),
          .type_access(type_access),
          .load_signed(load_signed),
          .rdata(rdata_s4));

//PC========================================================================
reg [31:0] temp;
always @(posedge clk or negedge rst) begin          
    if(!rst) begin
        pc <= 0;
    end    
    else begin
        temp = pc;
        pc = pc_incr4;
        if(PCSel == 0) pc <= pc_incr4;
        else if(PCSel == 1) pc <= imm_branch;
        else if(PCSel == 2) pc = address_jalr;
        if(!PCWrite)
            pc <= temp;
    end
end


assign ALUSel_s2_final = (Control_sel) ? 0 : ALUSel_s2;
assign MemRW_s2_final = (Control_sel) ? 0 : MemRW_s2;
assign WBSel_s2_final = (Control_sel) ? 0 : WBSel_s2;
assign RegWEn_s2_final = (Control_sel) ? 0 : RegWEn_s2;
assign ALU_src2_s2_final = (Control_sel) ? 0 : ALU_src2_s2;
assign ALU_src1_s2_final = (Control_sel) ? 0 : ALU_src1_s2;
assign MemEN_s2_final = (Control_sel) ? 0 : MemEN_s2;

//Register MEM/WB========================================================================
always @(negedge clk or negedge rst) begin              
    if(!rst) begin
        rd_s5 = 0;
        RegWEn_s5 = 0;
        wb_s5 = 0;
    end
    else begin
        rd_s5 = rd_s4;
        RegWEn_s5 = RegWEn_s4;
        wb_s5 = wb_s4;
    end
end
//Register EX/MEM========================================================================
always @(negedge clk or negedge rst) begin            
    if(!rst) begin
        alu_result_s4 = 0;
        op2_s4 = 0;
        rd_s4 = 0;
        
        MemRW_s4 = 0;
        WBSel_s4 = 0;
        RegWEn_s4 = 0;
        type_access_s4 = 0;
        load_signed_s4 = 0;
        MemEN_s4 = 0;
        
        pc_incr4_s4 = 0;
    end
    else begin
        alu_result_s4 = alu_result_s3;
        op2_s4 = op2_s3;
        rd_s4 = rd_s3;
        
        MemRW_s4 = MemRW_s3;
        WBSel_s4 = WBSel_s3;
        RegWEn_s4 = RegWEn_s3;
        
        type_access_s4 = type_access_s3;
        load_signed_s4 = load_signed_s3;
        MemEN_s4 = MemEN_s3;
        
        pc_incr4_s4 = pc_incr4_s3;
    end 
end



//REGISTER ID/EX========================================================================
always @(negedge clk or negedge rst) begin      
    if(!rst) begin
        data_read_r1_s3 = 0;
        data_read_r2_s3 = 0;
        rs1_s3 = 0;
        rs2_s3 = 0;
        rd_s3 = 0;
        
        ALUSel_s3 = 0;
        MemRW_s3 = 0;
        WBSel_s3 = 0;
        RegWEn_s3 = 0;
        ALU_src2_s3 = 0;
        ALU_src1_s3 = 0;
        imm_s3 = 0;
        type_access_s3 = 0;
        load_signed_s3 = 0;
        MemEN_s3 = 0;
        
        pc_incr4_s3 = 0;
        pc_s3 = 0;
    end

    else begin
        data_read_r1_s3 = data_read_r1_s2;
        data_read_r2_s3 = data_read_r2_s2;
        rs1_s3 = rs1;
        rs2_s3 = rs2;
        rd_s3 = rd_s2;
        
        ALUSel_s3 = ALUSel_s2_final;
        MemRW_s3 = MemRW_s2_final;
        WBSel_s3 = WBSel_s2_final;
        RegWEn_s3 = RegWEn_s2_final;
        ALU_src2_s3 = ALU_src2_s2_final;
        ALU_src1_s3 = ALU_src1_s2_final;

        imm_s3 = imm_s2;
        type_access_s3 = type_access_s2;
        load_signed_s3 = load_signed_s2;
        MemEN_s3 = MemEN_s2_final;
        
        pc_incr4_s3 = pc_incr4_s2;
        pc_s3 = pc_s2;
    end
end


//REGISTER IF/ID========================================================================
always @(negedge clk or negedge rst) begin          
    if(!rst) begin
        inst = 0;
        pc_incr4_s2 = 0;
        pc_s2 = 0;
    end
    else begin
        if(IF_ID_Write) begin
            inst = prg_data;
            pc_incr4_s2 = pc_incr4;
            pc_s2 = pc;
        end
    end
end


//Controller========================================================================
always @(*) begin                        
    //reset
    if(!rst || inst == 'h0) begin
        BrUn = 0;
        MemRW_s2 = 0;
        WBSel_s2 = 0;
        RegWEn_s2 = 0;
        ALU_src2_s2 = 0;
        ALU_src1_s2 = 0;

        ImmSel = 3'b000;
        MemEN_s2 = 0;
        PCSel = 0;
    end
    
     //R_type--------------------------------------------------------------------------------------------------------
    else if(inst[6:0] == 7'b0110011) begin      
        MemRW_s2 = 0;
        WBSel_s2 = 1;
        RegWEn_s2 = 1;
        ALU_src2_s2 = 0;
        ALU_src1_s2 = 0;
        ImmSel = 3'b000;
        MemEN_s2 = 0;
        PCSel = 0;
        if (inst[31:25] == 7'b0000000) begin
            case (inst[14:12])
                3'b000: ALUSel_s2 = 4'b0010;        //add
                3'b001: ALUSel_s2 = 4'b0011;        //sll
                3'b010: ALUSel_s2 = 4'b0100;        //slt
                3'b011: ALUSel_s2 = 4'b0101;        //sltu
                3'b100: ALUSel_s2 = 4'b0111;        //xor
                3'b101: ALUSel_s2 = 4'b1000;        //srl
                3'b110: ALUSel_s2 = 4'b0001;        //or
                3'b111: ALUSel_s2 = 4'b0000;        //and
            endcase
        end
        else if (inst[31:25] == 7'b0100000) begin
            case (inst[14:12])
                3'b000: ALUSel_s2 = 4'b0110;        //sub
                3'b101: ALUSel_s2 = 4'b1010;        //sra
            endcase
        end
    end
    
    //I-type--------------------------------------------------------------------------------------------------------
    //arithmetic
    else if(inst[6:0] == 7'b0010011) begin
        MemRW_s2 = 0;
        WBSel_s2 = 1;
        RegWEn_s2 = 1;
        ALU_src2_s2 = 1;
        ALU_src1_s2 = 0;
        ImmSel = 3'b001;
        MemEN_s2 = 0;
        PCSel = 0;
                                                
        if(inst[14:12] == 3'b000) ALUSel_s2 = 4'b0010;          //addi
        else if(inst[14:12] == 3'b010) ALUSel_s2 = 4'b0100;     //slti
        else if(inst[14:12] == 3'b011) ALUSel_s2 = 4'b0101;     //sltiu
        else if(inst[14:12] == 3'b100) ALUSel_s2 = 4'b0111;     //xori
        else if(inst[14:12] == 3'b110) ALUSel_s2 = 4'b0001;     //ori
        else if(inst[14:12] == 3'b111) ALUSel_s2 = 4'b0000;     //andi
        else if(inst[31:27] == 5'b00000 && inst[14:12] == 3'b001) ALUSel_s2 = 4'b0011;  //slli
        else if(inst[31:27] == 5'b00000 && inst[14:12] == 3'b101) ALUSel_s2 = 4'b1000;  //srli
        else if(inst[31:27] == 5'b01000 && inst[14:12] == 3'b101) ALUSel_s2 = 4'b1010;  //srai

    end
    
    //load
    else if(inst[6:0] == 7'b0000011) begin
        MemRW_s2 = 0;
        WBSel_s2 = 0;
        RegWEn_s2 = 1;
        ALU_src2_s2 = 1;
        ALU_src1_s2 = 0;
        ImmSel = 3'b001;
        ALUSel_s2 = 4'b0010;
        MemEN_s2 = 1;
        PCSel = 0;
        case(inst[14:12])
            3'b000: begin
                        type_access_s2 = 2'b11;     //load byte signed extend - lb
                        load_signed_s2 = 1;
                    end
            3'b001: begin
                        type_access_s2 = 2'b10;     //load half signed extend   - lh
                        load_signed_s2 = 1;
                    end
            3'b010: begin
                        type_access_s2 = 2'b01;     //load word signed extend   -lw
                        load_signed_s2 = 1;
                    end
            3'b100: begin
                        type_access_s2 = 2'b11;     //load byte unsigned extend - lbu
                        load_signed_s2 = 0;
                    end
            3'b101: begin
                        type_access_s2 = 2'b10;     //load half unsigned extend   - lhu
                        load_signed_s2 = 0;
                    end
        endcase   
    end
    //jalr
    else if(inst[6:0] == 7'b1100111) begin
        MemRW_s2 = 0;
        WBSel_s2 = 2;
        RegWEn_s2 = 1;
        ALU_src2_s2 = 0;
        ALU_src1_s2 = 0;
        ImmSel = 3'b001;
//        ALUSel_s2 = 4'b0010;
        MemEN_s2 = 0;
        PCSel = 2;
    end
    
    
    
    //S-type--------------------------------------------------------------------------------------------------------
    else if(inst[6:0] == 7'b0100011) begin  
        MemRW_s2 = 1;
        RegWEn_s2 = 0;
        ALU_src2_s2 = 1;
        ALU_src1_s2 = 0;
        ImmSel = 3'b010;
        ALUSel_s2 = 4'b0010;
        MemEN_s2 = 1;
        PCSel = 0;
        case(inst[14:12]) 
            3'b000: type_access_s2 = 2'b11;
            3'b001: type_access_s2 = 2'b10;
            3'b010: type_access_s2 = 2'b01;

        endcase
    end
    
    
    //B-type--------------------------------------------------------------------------------------------------------
    else if(inst[6:0] == 7'b1100011)  begin
        ImmSel = 3'b011;
        
        MemRW_s2 = 0;
        WBSel_s2 = 0;
        RegWEn_s2 = 0;
        ALU_src2_s2 = 0;
        ALU_src1_s2 = 0;
        MemEN_s2 = 0;
        PCSel = 0;
        if(inst[14:12] == 3'b000) begin         //beq
            BrUn = 0;
            if(BrEq == 1) PCSel = 1;
            else PCSel = 0;
        end
        else if(inst[14:12] == 3'b001) begin    //bne
            BrUn = 0;
            if(BrEq == 0) PCSel = 1;
            else PCSel = 0;
        end
        else if(inst[14:12] == 3'b100) begin    //blt
            BrUn = 0;
            if(BrLT == 1) PCSel = 1;
            else PCSel = 0;
        end
        else if(inst[14:12] == 3'b101) begin    //bge
            BrUn = 0;
            if(BrLT == 0) PCSel = 1;
            else PCSel = 0;
        end
        else if(inst[14:12] == 3'b110) begin    //bltu
            BrUn = 1;   
            if(BrLT == 1) PCSel = 1;
            else PCSel = 0;
        end
        else if(inst[14:12] == 3'b111) begin    //bgeu 
            BrUn = 1;
            if(BrLT == 0) PCSel = 1;
            else PCSel = 0;
        end
    end
    
    //U-type--------------------------------------------------------------------------------------------------------
    else if(inst[6:0] == 7'b0110111) begin      //lui instruction
        MemRW_s2 = 0;
        WBSel_s2 = 1;
        RegWEn_s2 = 1;
        ALU_src2_s2 = 1;
        ALU_src1_s2 = 0;
        ImmSel = 3'b100;
        MemEN_s2 = 0;
        PCSel = 0;
        ALUSel_s2 = 4'b1111;
    end
    
    
    else if(inst[6:0] == 7'b0010111) begin      //auipc instruction
        MemRW_s2 = 0;
        WBSel_s2 = 1;
        RegWEn_s2 = 1;
        ALU_src2_s2 = 1;
        ALU_src1_s2 = 1;
        ImmSel = 3'b100;
        MemEN_s2 = 0;
        PCSel = 0;
        ALUSel_s2 = 4'b0010;
    end
    
    //J-type
    else if(inst[6:0] == 7'b1101111) begin      //jal instruction
        ImmSel = 3'b101;
        MemRW_s2 = 0;
        MemEN_s2 = 0;
        WBSel_s2 = 2;
        RegWEn_s2 = 1;
        ALU_src2_s2 = 0;
        ALU_src1_s2 = 0;
//        ALUSel_s2 = 4'b0010;
        PCSel = 1;
    end
end


////Instruction Memory========================================================================
//always @(pc) begin
//    case(pc)
//        32'h00000000: prg_data = 32'b000000000111_00000_000_00011_0010011;  //addi r3, r0, 7            r3 = 7
//        32'h00000004: prg_data = 32'b000000001010_00011_000_00100_0010011;  //addi r4, r3, 10           r4 = 17
//        32'h00000008: prg_data = 32'b000000001111_00011_000_00001_0010011;  //addi r1, r3, 15           r1 = 22
//        32'h0000000C: prg_data = 32'b0000000_00100_00001_000_00010_0110011; //add r2, r1, r4            r2 = 39
//        32'h00000010: prg_data = 32'b0000000_00010_00010_101_00101_0010011; //srli r5, r2, 2            r5 = 9
//        32'h00000014: prg_data = 32'b0000000_00101_00011_100_00100_0110011; //xor r4, r3, r5            r4 = 14
//        32'h00000018: prg_data = 32'b011011001111_00000_000_00111_0010011; //addi r7, r0, 1743          r7 = 1743
//        32'h0000001C: prg_data = 32'b0000000_00111_00101_000_00000_0100011; //sb r7, 0(r5)              mem[9] = 0xcf
//        32'h00000020: prg_data = 32'b0000000_00111_00101_001_00001_0100011; //sh r7, 1(r5)              mem[10] = 0xcd, mem[11] = 0x06
//        32'h00000024: prg_data = 32'b000000000000_00101_101_01000_0000011;  //lhu r8, 0(r5)             r8 = 53199
//        32'h00000028: prg_data = 32'b000000000010_00000_000_00100_0010011; //addi r4, r0, 2             r4 = 2
//        32'h0000002C: prg_data = 32'b0000000_01000_00000_000_00011_0110011; //add r3, r8, r0            r3 = 53199
//        32'h00000030: prg_data = 32'b0100000_00010_00111_000_01001_0110011; //sub r9, r7, r2            r9 = 1704
//        32'h00000034: prg_data = 32'b0100000_00100_01000_101_01000_0110011; //sra r8, r8, r4            r8 = r8 >> 2
//        32'h00000038: prg_data = 32'b111111110110_00111_000_00111_0010011;  //addi r7, r7, -10
//        32'h0000003C: prg_data = 32'b1111111_00111_01001_110_11101_1100011; //bltu r9, r7, -8           r9 < r7 ? jump to 0x34
//        32'h00000040: prg_data = 32'b00000000000000001010_01011_0110111;    //lui r11, 10               r11 = 0xA000
//        32'h00000044: prg_data = 32'b0100000_00111_01000_000_00001_0110011; //sub r1, r8, r7            r1 = -1496
//        32'h00000048: prg_data = 32'b000001100100_00101_000_00010_1100111;  //jalr r2, r5, 10           r2 = 0x4C, jump to 0x6C
//        32'h0000006C: prg_data = 32'b000000001000_00000000_01100_1101111;   //jal r12, 16               r12 = 0x70, jump to 0x7C   
//        32'h0000007C: prg_data = 32'b000000000000_00101_101_01111_0000011;  //lhu r15, 0(r5)            r15 = 53199
//        32'h00000080: prg_data = 32'b0000000_01111_00000_000_10000_0110011; //add r16, r15, r0          r16 = 53199
//        32'h00000084: prg_data = 32'b000000001000_00000_000_00100_0010011; //addi r4, r0, 8             r4 = 8
//        32'h00000090: prg_data = 32'b000000100000_00000_000_00100_0010011; //addi r4, r0, 32            r4 = 32
//        32'h00000094: prg_data = 32'b000010000000_00100_000_10001_1100111; //jalr r17, r4, 128          r17 = 0x98
//        32'h000000A0: prg_data = 32'b010011001100_01111_111_10010_0010011; //andi r18, r15, 8           r18 = 0x04CC
//        32'h000000A4: prg_data = 32'b00000000000000001100_10011_0010111;   //auipc r19, 0xC000
//        default: prg_data = 'b0;
//    endcase
//end

assign wb_s4 = (WBSel == 0) ? rdata_s4:
               (WBSel == 1) ? alu_result_s4:
               (WBSel == 2) ? pc_incr4_s4 : 'h0;

assign wb = wb_s5;
endmodule