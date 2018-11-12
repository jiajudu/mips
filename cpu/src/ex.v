`timescale 1ns / 1ps
`include "defines.v"
module ex(
    input wire reset,
    input wire[7:0] ALUOperation,
    input wire[2:0] ALUSel,
    input wire[31:0] Register1,
    input wire[31:0] Register2,
    input wire[4:0] WriteAddressIn,
    input wire WriteRegisterIn,
    input wire WriteHiIn,
    input wire WriteLoIn,
    input wire[31:0] LinkAddress,
    input wire IsInDelaySlotIn,
    input wire[15:0] Instruction,
    input wire[4:0] WriteCPAddress,
    input wire tlbwi,
    input wire syscall,
    input wire eret,
    input wire privilege,
    input wire ValidInstruction,
    input wire PCTLBMiss,
    input wire[31:0] currentPC,
    output reg[31:0] WriteDataOut,
    output reg[4:0] WriteAddressOut,
    output reg WriteRegisterOut,
    output reg[31:0] WriteHiDataOut,
    output reg WriteHiOut,
    output reg[31:0] WriteLoDataOut,
    output reg WriteLoOut,
    output reg IsLoad,
    output reg SignExtend,
    output reg[31:0] RAMAddress,
    output reg RAMWriteEnable,
    output reg[31:0] RAMData,
    output reg RAMDataSize,
    output reg RAMReadEnable,
    output reg WriteCPOut,
    output reg[4:0] WriteCPAddressOut,
    output reg[31:0] WriteCPDataOut,
    output reg IsInDelaySlotOut,
    output reg tlbwiOut,
    output reg syscallOut,
    output reg eretOut,
    output reg privilegeOut,
    output reg ValidInstructionOut,
    output reg PCTLBMissOut,
    output reg[31:0] currentPCOut,
    output reg ExAddressReadPrivilege,
    output reg ExAddressWritePrivilege
);
    reg[63:0] MultiplyResult;
    wire[31:0] RegisterConverter;
    wire[31:0] SumResult;
    wire SltResult;
    wire[31:0] MultiplyElement1;
    wire[31:0] MultiplyElement2;
    wire[63:0] MultiplyUnsignedResult;
    wire[31:0] MemoryAddress;
    assign MemoryAddress = Register1 + {{16{Instruction[15]}},Instruction[15:0]};
    assign RegisterConverter = ((ALUOperation == `EXE_SUBU_OP) || (ALUOperation == `EXE_SLT_OP) ) ? (~Register2)+1 : Register2;
    assign SumResult = Register1 + RegisterConverter;
    assign SltResult = ((ALUOperation == `EXE_SLT_OP)) ? ((Register1[31] && !Register2[31]) || (!Register1[31] && !Register2[31] && SumResult[31])|| (Register1[31] && Register2[31] && SumResult[31])) : (Register1 < Register2);
    always @ (*) begin
        currentPCOut <= currentPC;
        IsInDelaySlotOut <= IsInDelaySlotIn;
        PCTLBMissOut <= PCTLBMiss;
        WriteAddressOut <= WriteAddressIn;
        WriteRegisterOut <= WriteRegisterIn;
        tlbwiOut <= tlbwi;
        syscallOut <= syscall;
        eretOut <= eret;
        privilegeOut <= privilege;
        ValidInstructionOut <= ValidInstruction;
        if(reset == 1'b0) begin
            WriteDataOut <= 32'b0;
        end else begin
            case(ALUSel)
                `EXE_RES_LOGIC: begin
                    case (ALUOperation)
                        `EXE_OR_OP: begin
                            WriteDataOut <= Register1 | Register2;
                        end
                        `EXE_AND_OP: begin
                            WriteDataOut <= Register1 & Register2;
                        end
                        `EXE_NOR_OP: begin
                            WriteDataOut <= ~(Register1 | Register2);
                        end
                        `EXE_XOR_OP: begin
                            WriteDataOut <= Register1 ^ Register2;
                        end
                        default: begin
                            WriteDataOut <= 32'b0;
                        end
                    endcase
                end
                `EXE_RES_SHIFT: begin
                    case (ALUOperation)
                        `EXE_SLL_OP: begin
                            WriteDataOut <= Register2 << Register1[4:0] ;
                        end
                        `EXE_SRL_OP: begin
                            WriteDataOut <= Register2 >> Register1[4:0];
                        end
                        `EXE_SRA_OP: begin
                            WriteDataOut <= ({32{Register2[31]}} << (6'd32-{1'b0, Register1[4:0]}))| Register2 >> Register1[4:0];
                        end
                        default: begin
                            WriteDataOut <= 32'b0;
                        end
                    endcase
                end
                `EXE_RES_MOVE: begin
                    case (ALUOperation)
                        `EXE_MFHiOutP: begin
                            WriteDataOut <= Register1;
                        end
                        `EXE_MFLoOutP: begin
                            WriteDataOut <= Register1;
                        end
                        `EXE_MFC0_OP: begin
                            WriteDataOut <= Register1;
                        end
                        default: begin
                            WriteDataOut <= 32'b0;
                        end
                    endcase
                end
                `EXE_RES_ARITHMETIC: begin
                    case (ALUOperation)
                        `EXE_SLT_OP, `EXE_SLTU_OP: begin
                            WriteDataOut <= SltResult ;
                        end
                        `EXE_ADDU_OP, `EXE_ADDIU_OP: begin
                            WriteDataOut <= SumResult;
                        end
                        `EXE_SUBU_OP: begin
                            WriteDataOut <= SumResult;
                        end
                        default: begin
                            WriteDataOut <= 32'b0;
                        end
                    endcase
                end
                `EXE_RES_JUMP_BRANCH: begin
                    WriteDataOut <= LinkAddress;
                end
                default: begin
                    WriteDataOut <= 32'b0;
                end
            endcase
        end
    end
    assign MultiplyElement1 = (Register1[31] == 1'b1) ? (~Register1 + 1) : Register1;
    assign MultiplyElement2 = (Register2[31] == 1'b1) ? (~Register2 + 1) : Register2;
    assign MultiplyUnsignedResult = MultiplyElement1 * MultiplyElement2;
    always @ (*) begin
        if(reset == 1'b0) begin
            MultiplyResult <= 64'b0;
        end else if (ALUOperation == `EXE_MULT_OP) begin
            if(Register1[31] ^ Register2[31] == 1'b1) begin
                MultiplyResult <= ~MultiplyUnsignedResult + 1;
            end else begin
                MultiplyResult <= MultiplyUnsignedResult;
            end
        end else begin
            MultiplyResult <= 64'b0;
        end
    end
    always @ (*) begin
        if(reset == 1'b0) begin
            WriteHiOut <= 1'b0;
            WriteLoOut <= 1'b0;
            WriteHiDataOut <= 32'b0;
            WriteLoDataOut <= 32'b0;
        end else begin
            WriteHiOut <= WriteHiIn;
            WriteLoOut <= WriteLoIn;
            if(ALUOperation == `EXE_MULT_OP) begin
                WriteHiDataOut <= MultiplyResult[63:32];
                WriteLoDataOut <= MultiplyResult[31:0];
            end else if(ALUOperation == `EXE_MTHiOutP) begin
                WriteHiDataOut <= Register1;
                WriteLoDataOut <= 32'b0;
            end else if(ALUOperation == `EXE_MTLoOutP) begin
                WriteHiDataOut <= 32'b0;
                WriteLoDataOut <= Register1;
            end else begin
                WriteHiDataOut <= 32'b0;
                WriteLoDataOut <= 32'b0;
            end
        end
    end
    always @ (*) begin
        if(reset == 1'b0) begin
            WriteCPOut <= 1'b0;
            WriteCPAddressOut <= 5'b0;
            WriteCPDataOut <= 32'b0;
        end else begin
            if(ALUSel == `EXE_RES_MOVE && ALUOperation == `EXE_MTC0_OP) begin
                WriteCPOut <= 1'b1;
                WriteCPAddressOut <= WriteCPAddress;
                WriteCPDataOut <= Register1;
            end else begin
                WriteCPOut <= 1'b0;
                WriteCPAddressOut <= 5'b0;
                WriteCPDataOut <= 32'b0;
            end
        end
    end
    always @ (*) begin
        if(reset == 1'b0) begin
            RAMWriteEnable <= 1'b0;
            RAMData <= 32'b0;
            RAMDataSize <= 32'b0;
            RAMReadEnable <= 1'b0;
            RAMAddress <= 32'b0;
            IsLoad <= 1'b0;
            SignExtend <= 1'b0;
            ExAddressReadPrivilege <= 1'b0;
            ExAddressWritePrivilege <= 1'b0;
        end else begin
            case(ALUOperation)
                `EXE_LB_OP:begin
                    RAMAddress <= MemoryAddress;
                    RAMWriteEnable <= 1'b0;
                    RAMData <= Register2;
                    RAMDataSize <= 1'b0;
                    RAMReadEnable <= 1'b1;
                    IsLoad <= 1'b1;
                    SignExtend <= 1'b1;
                    ExAddressReadPrivilege <= MemoryAddress[31];
                    ExAddressWritePrivilege <= 1'b0;
                end
                `EXE_LBU_OP:begin
                    RAMAddress <= MemoryAddress;
                    RAMWriteEnable <= 1'b0;
                    RAMData <= Register2;
                    RAMDataSize <= 1'b0;
                    RAMReadEnable <= 1'b1;
                    IsLoad <= 1'b1;
                    SignExtend <= 1'b0;
                    ExAddressReadPrivilege <= MemoryAddress[31];
                    ExAddressWritePrivilege <= 1'b0;
                end
                `EXE_LW_OP:begin
                    RAMAddress <= MemoryAddress;
                    RAMWriteEnable <= 1'b0;
                    RAMData <= Register2;
                    RAMDataSize <= 1'b1;
                    RAMReadEnable <= 1'b1;
                    IsLoad <= 1'b1;
                    SignExtend <= 1'b0;
                    ExAddressReadPrivilege <= MemoryAddress[31];
                    ExAddressWritePrivilege <= 1'b0;
                end
                `EXE_SB_OP:begin
                    RAMAddress <= MemoryAddress;
                    RAMWriteEnable <= 1'b1;
                    RAMData <= Register2;
                    RAMDataSize <= 1'b0;
                    RAMReadEnable <= 1'b0;
                    IsLoad <= 1'b1;
                    SignExtend <= 1'b0;
                    ExAddressReadPrivilege <= 1'b0;
                    ExAddressWritePrivilege <= MemoryAddress[31];
                end
                `EXE_SW_OP:begin
                    RAMAddress <= MemoryAddress;
                    RAMWriteEnable <= 1'b1;
                    RAMData <= Register2;
                    RAMDataSize <= 1'b1;
                    RAMReadEnable <= 1'b0;
                    IsLoad <= 1'b1;
                    SignExtend <= 1'b0;
                    ExAddressReadPrivilege <= 1'b0;
                    ExAddressWritePrivilege <= MemoryAddress[31];
                end
                default:begin
                    RAMAddress <= 32'b0;
                    RAMWriteEnable <= 1'b0;
                    RAMData <= 32'b0;
                    RAMDataSize <= 32'b0;
                    RAMReadEnable <= 1'b0;
                    IsLoad <= 1'b0;
                    SignExtend <= 1'b0;
                    ExAddressReadPrivilege <= 1'b0;
                    ExAddressWritePrivilege <= 1'b0;
                end
            endcase
        end
    end
endmodule