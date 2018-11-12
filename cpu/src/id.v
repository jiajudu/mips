`include "defines.v"
`timescale 1ns / 1ps
module id(
    input wire reset,
    input wire[31:0] IdPC,
    input wire[31:0] IdInstruction,
    input wire[31:0] RegisterData1,
    input wire[31:0] RegisterData2,
    input wire[31:0] CPData,
    input wire IsInDelaySlotIn,
    input wire[31:0] hi,
    input wire[31:0] lo,
    input wire ExWriteRegisterIn,
    input wire[31:0] ExWriteDataIn,
    input wire[4:0] ExWriteAddressIn,
    input wire ExWriteHiIn,
    input wire[31:0] ExWriteHiDataIn,
    input wire ExWriteLoIn,
    input wire[31:0] ExWriteLoDataIn,
    input wire ExWriteCPIn,
    input wire[4:0] ExWriteCPAddress,
    input wire[31:0] ExWriteCPData,
    input wire MemWriteRegisterIn,
    input wire[31:0] MemWriteDataIn,
    input wire[4:0] MemWriteAddressIn,
    input wire MemWriteHiIn,
    input wire[31:0] MemWriteHiDataIn,
    input wire MemWriteLoIn,
    input wire[31:0] MemWriteLoDataIn,
    input wire MemWriteCPIn,
    input wire[4:0] MemWriteCPAddress,
    input wire[31:0] MemWriteCPData,
    input wire ExIsLoad,
    input wire PCTLBMiss,
    output reg[31:0] currentPC,
    output reg tlbwi,
    output reg syscall,
    output reg eret,
    output reg privilege,
    output reg ValidInstruction,
    output reg RegisterReadEnable1,
    output reg RegisterReadEnable2,
    output reg[4:0] RegisterAddress1,
    output reg[4:0] RegisterAddress2,
    output reg[4:0] CPAddress,
    output reg[4:0] WriteCPAddress,
    output reg[7:0] ALUOperation,
    output reg[2:0] ALUSel,
    output reg[31:0] Register1,
    output reg[31:0] Register2,
    output reg[4:0] WriteAddressOut,
    output reg WriteRegisterOut,
    output reg WriteHiOut,
    output reg WriteLoOut,
    output reg NextInstructionInDelaySlot,
    output reg BranchFlag,
    output reg[31:0] BranchTarget, 
    output reg[31:0] LinkAddress,
    output reg PauseRequest,
    output reg[15:0] IdInstructionOut,
    output reg IsInDelaySlotOut,
    output reg PCTLBMissOut
);
    reg[31:0] immediate;
    wire[31:0] PCPlus8;
    wire[31:0] PCPlus4;
    wire[31:0] JumpOffset;
    reg HiReadEnable;
    reg LoReadEnable;
    wire PauseSignal1;
    wire PauseSignal2;
    reg CPReadEnable;
    assign PCPlus8 = IdPC + 8;
    assign PCPlus4 = IdPC + 4;
    assign JumpOffset = {{14{IdInstruction[15]}}, IdInstruction[15:0], 2'b00 };
    always @ (*) begin
        if (reset == 1'b0) begin
            ALUOperation <= `EXE_NOP_OP;
            ALUSel <= `EXE_RES_NOP;
            WriteAddressOut <= 5'b00000;
            WriteRegisterOut <= 1'b0;
            ValidInstruction <= 1'b0;
            RegisterReadEnable1 <= 1'b0;
            RegisterReadEnable2 <= 1'b0;
            RegisterAddress1 <= 5'b00000;
            RegisterAddress2 <= 5'b00000;
            HiReadEnable <= 1'b0;
            LoReadEnable <= 1'b0;
            immediate <= 32'h0;
            WriteHiOut <= 1'b0;
            WriteLoOut <= 1'b0;
            LinkAddress <= 32'b0;
            BranchTarget <= 32'b0;
            BranchFlag <= 1'b0;
            NextInstructionInDelaySlot <= 1'b0;
            IdInstructionOut <= 16'b0;
            CPAddress <= 5'b0;
            WriteCPAddress <= 1'b0;
            CPReadEnable <= 1'b0;
            tlbwi <= 1'b0;
            syscall <= 1'b0;
            eret <= 1'b0;
            privilege <= 1'b0;
            PCTLBMissOut <= 1'b0;
            currentPC <= 32'b0;
        end else begin
            ALUOperation <= `EXE_NOP_OP;
            ALUSel <= `EXE_RES_NOP;
            WriteAddressOut <= IdInstruction[15:11];
            WriteRegisterOut <= 1'b0;
            ValidInstruction <= 1'b1;
            RegisterReadEnable1 <= 1'b0;
            RegisterReadEnable2 <= 1'b0;
            RegisterAddress1 <= IdInstruction[25:21];
            RegisterAddress2 <= IdInstruction[20:16];
            HiReadEnable <= 1'b0;
            LoReadEnable <= 1'b0;
            immediate <= 32'h0;
            WriteHiOut <= 1'b0;
            WriteLoOut <= 1'b0;
            LinkAddress <= 32'b0;
            BranchTarget <= 32'b0;
            BranchFlag <= 1'b0; 
            NextInstructionInDelaySlot <= 1'b0;
            IdInstructionOut <= IdInstruction[15:0];
            CPAddress <= 5'b0;
            WriteCPAddress <= 1'b0;
            CPReadEnable <= 1'b0;
            privilege <= 1'b0;
            PCTLBMissOut <= PCTLBMiss;
            currentPC <= IdPC;
            case (IdInstruction[31:26])
            `EXE_SPECIAL_INST: begin
                case (IdInstruction[10:6])
                    5'b00000: begin
                        case (IdInstruction[5:0])
                            `EXE_OR: begin
                                WriteRegisterOut <= 1'b1;
                                ALUOperation <= `EXE_OR_OP;
                                ALUSel <= `EXE_RES_LOGIC;
                                RegisterReadEnable1 <= 1'b1;
                                RegisterReadEnable2 <= 1'b1;
                                ValidInstruction <= 1'b0;
                            end
                            `EXE_AND: begin
                                WriteRegisterOut <= 1'b1;
                                ALUOperation <= `EXE_AND_OP;
                                ALUSel <= `EXE_RES_LOGIC;
                                RegisterReadEnable1 <= 1'b1;
                                RegisterReadEnable2 <= 1'b1;
                                ValidInstruction <= 1'b0;
                            end
                            `EXE_XOR: begin
                                WriteRegisterOut <= 1'b1;
                                ALUOperation <= `EXE_XOR_OP;
                                ALUSel <= `EXE_RES_LOGIC;
                                RegisterReadEnable1 <= 1'b1;
                                RegisterReadEnable2 <= 1'b1;
                                ValidInstruction <= 1'b0;
                            end
                            `EXE_NOR: begin
                                WriteRegisterOut <= 1'b1;
                                ALUOperation <= `EXE_NOR_OP;
                                ALUSel <= `EXE_RES_LOGIC;
                                RegisterReadEnable1 <= 1'b1;
                                RegisterReadEnable2 <= 1'b1;
                                ValidInstruction <= 1'b0;
                            end
                            `EXE_SLLV: begin
                                WriteRegisterOut <= 1'b1;
                                ALUOperation <= `EXE_SLL_OP;
                                ALUSel <= `EXE_RES_SHIFT;
                                RegisterReadEnable1 <= 1'b1;
                                RegisterReadEnable2 <= 1'b1;
                                ValidInstruction <= 1'b0;
                            end
                            `EXE_SRLV: begin
                                WriteRegisterOut <= 1'b1;
                                ALUOperation <= `EXE_SRL_OP;
                                ALUSel <= `EXE_RES_SHIFT;
                                RegisterReadEnable1 <= 1'b1;
                                RegisterReadEnable2 <= 1'b1;
                                ValidInstruction <= 1'b0;
                            end
                            `EXE_SRAV: begin
                                WriteRegisterOut <= 1'b1;
                                ALUOperation <= `EXE_SRA_OP;
                                ALUSel <= `EXE_RES_SHIFT;
                                RegisterReadEnable1 <= 1'b1;
                                RegisterReadEnable2 <= 1'b1;
                                ValidInstruction <= 1'b0;
                            end
                            `EXE_MFHI: begin
                                WriteRegisterOut <= 1'b1;
                                ALUOperation <= `EXE_MFHiOutP;
                                ALUSel <= `EXE_RES_MOVE;
                                RegisterReadEnable1 <= 1'b0;
                                RegisterReadEnable2 <= 1'b0;
                                ValidInstruction <= 1'b0; 
                                HiReadEnable <= 1'b1;
                            end
                            `EXE_MFLO: begin
                                WriteRegisterOut <= 1'b1;
                                ALUOperation <= `EXE_MFLoOutP;
                                ALUSel <= `EXE_RES_MOVE;
                                RegisterReadEnable1 <= 1'b0;
                                RegisterReadEnable2 <= 1'b0;
                                ValidInstruction <= 1'b0; 
                                LoReadEnable <= 1'b1;
                            end
                            `EXE_MTHI: begin
                                WriteRegisterOut <= 1'b0;
                                ALUOperation <= `EXE_MTHiOutP;
                                RegisterReadEnable1 <= 1'b1;
                                RegisterReadEnable2 <= 1'b0;
                                ValidInstruction <= 1'b0;
                                WriteHiOut <= 1'b1;
                            end
                            `EXE_MTLO: begin
                                WriteRegisterOut <= 1'b0;
                                ALUOperation <= `EXE_MTLoOutP;
                                RegisterReadEnable1 <= 1'b1;
                                RegisterReadEnable2 <= 1'b0;
                                ValidInstruction <= 1'b0;
                                WriteLoOut <= 1'b1;
                            end
                            `EXE_SLT: begin
                                WriteRegisterOut <= 1'b1;
                                ALUOperation <= `EXE_SLT_OP;
                                ALUSel <= `EXE_RES_ARITHMETIC;
                                RegisterReadEnable1 <= 1'b1;
                                RegisterReadEnable2 <= 1'b1;
                                ValidInstruction <= 1'b0; 
                            end
                            `EXE_SLTU: begin
                                WriteRegisterOut <= 1'b1;
                                ALUOperation <= `EXE_SLTU_OP;
                                ALUSel <= `EXE_RES_ARITHMETIC;
                                RegisterReadEnable1 <= 1'b1;
                                RegisterReadEnable2 <= 1'b1;
                                ValidInstruction <= 1'b0; 
                            end
                            `EXE_ADDU: begin
                                WriteRegisterOut <= 1'b1;
                                ALUOperation <= `EXE_ADDU_OP;
                                ALUSel <= `EXE_RES_ARITHMETIC;
                                RegisterReadEnable1 <= 1'b1;
                                RegisterReadEnable2 <= 1'b1;
                                ValidInstruction <= 1'b0; 
                            end
                            `EXE_SUBU: begin
                                WriteRegisterOut <= 1'b1;
                                ALUOperation <= `EXE_SUBU_OP;
                                ALUSel <= `EXE_RES_ARITHMETIC;
                                RegisterReadEnable1 <= 1'b1;
                                RegisterReadEnable2 <= 1'b1;
                                ValidInstruction <= 1'b0; 
                            end
                            `EXE_MULT: begin
                                WriteRegisterOut <= 1'b0;
                                ALUOperation <= `EXE_MULT_OP;
                                RegisterReadEnable1 <= 1'b1;
                                RegisterReadEnable2 <= 1'b1;
                                ValidInstruction <= 1'b0; 
                                WriteHiOut <= 1'b1;
                                WriteLoOut <= 1'b1;
                            end
                            `EXE_JR: begin
                                WriteRegisterOut <= 1'b0;
                                ALUOperation <= `EXE_JR_OP;
                                ALUSel <= `EXE_RES_JUMP_BRANCH;
                                RegisterReadEnable1 <= 1'b1;
                                RegisterReadEnable2 <= 1'b0;
                                LinkAddress <= 32'b0;
                                BranchTarget <= Register1;
                                BranchFlag <= 1'b1;
                                NextInstructionInDelaySlot <= 1'b1;
                                ValidInstruction <= 1'b0; 
                            end
                            `EXE_JALR: begin
                                WriteRegisterOut <= 1'b1;
                                ALUOperation <= `EXE_JALR_OP;
                                ALUSel <= `EXE_RES_JUMP_BRANCH;
                                RegisterReadEnable1 <= 1'b1;
                                RegisterReadEnable2 <= 1'b0;
                                WriteAddressOut <= IdInstruction[15:11];
                                LinkAddress <= PCPlus8;
                                BranchTarget <= Register1;
                                BranchFlag <= 1'b1;
                                NextInstructionInDelaySlot <= 1'b1;
                                ValidInstruction <= 1'b0; 
                            end
                            default: begin
                            end
                        endcase
                    end
                    default: begin
                    end
                endcase
            end
            `EXE_ORI: begin
                WriteRegisterOut <= 1'b1;
                ALUOperation <= `EXE_OR_OP;
                ALUSel <= `EXE_RES_LOGIC;
                RegisterReadEnable1 <= 1'b1;
                RegisterReadEnable2 <= 1'b0;
                immediate <= {16'h0, IdInstruction[15:0]};
                WriteAddressOut <= IdInstruction[20:16];
                ValidInstruction <= 1'b0;
            end
            `EXE_ANDI: begin
                WriteRegisterOut <= 1'b1;
                ALUOperation <= `EXE_AND_OP;
                ALUSel <= `EXE_RES_LOGIC;
                RegisterReadEnable1 <= 1'b1;
                RegisterReadEnable2 <= 1'b0;
                immediate <= {16'h0, IdInstruction[15:0]};
                WriteAddressOut <= IdInstruction[20:16];
                ValidInstruction <= 1'b0;
            end
            `EXE_XORI: begin
                WriteRegisterOut <= 1'b1;
                ALUOperation <= `EXE_XOR_OP;
                ALUSel <= `EXE_RES_LOGIC;
                RegisterReadEnable1 <= 1'b1;
                RegisterReadEnable2 <= 1'b0;
                immediate <= {16'h0, IdInstruction[15:0]};
                WriteAddressOut <= IdInstruction[20:16];
                ValidInstruction <= 1'b0;
            end
            `EXE_LUI: begin
                WriteRegisterOut <= 1'b1;
                ALUOperation <= `EXE_OR_OP;
                ALUSel <= `EXE_RES_LOGIC;
                RegisterReadEnable1 <= 1'b1;
                RegisterReadEnable2 <= 1'b0;
                immediate <= {IdInstruction[15:0], 16'h0};
                WriteAddressOut <= IdInstruction[20:16];
                ValidInstruction <= 1'b0;
            end
            `EXE_SLTI: begin
                WriteRegisterOut <= 1'b1;
                ALUOperation <= `EXE_SLT_OP;
                ALUSel <= `EXE_RES_ARITHMETIC;
                RegisterReadEnable1 <= 1'b1;
                RegisterReadEnable2 <= 1'b0; 
                immediate <= {{16{IdInstruction[15]}}, IdInstruction[15:0]};
                WriteAddressOut <= IdInstruction[20:16]; 
                ValidInstruction <= 1'b0; 
            end
            `EXE_SLTIU: begin
                WriteRegisterOut <= 1'b1;
                ALUOperation <= `EXE_SLTU_OP;
                ALUSel <= `EXE_RES_ARITHMETIC;
                RegisterReadEnable1 <= 1'b1;
                RegisterReadEnable2 <= 1'b0; 
                immediate <= {{16{IdInstruction[15]}}, IdInstruction[15:0]};
                WriteAddressOut <= IdInstruction[20:16]; 
                ValidInstruction <= 1'b0; 
            end
            `EXE_ADDIU: begin
                WriteRegisterOut <= 1'b1;
                ALUOperation <= `EXE_ADDIU_OP;
                ALUSel <= `EXE_RES_ARITHMETIC;
                RegisterReadEnable1 <= 1'b1;
                RegisterReadEnable2 <= 1'b0; 
                immediate <= {{16{IdInstruction[15]}}, IdInstruction[15:0]};
                WriteAddressOut <= IdInstruction[20:16]; 
                ValidInstruction <= 1'b0; 
            end
            `EXE_J: begin
                WriteRegisterOut <= 1'b0;
                ALUOperation <= `EXE_J_OP;
                ALUSel <= `EXE_RES_JUMP_BRANCH;
                RegisterReadEnable1 <= 1'b0;
                RegisterReadEnable2 <= 1'b0;
                LinkAddress <= 32'b0;
                BranchTarget <= {PCPlus4[31:28], IdInstruction[25:0], 2'b00};
                BranchFlag <= 1'b1;
                NextInstructionInDelaySlot <= 1'b1; 
                ValidInstruction <= 1'b0; 
            end
            `EXE_JAL: begin
                WriteRegisterOut <= 1'b1;
                ALUOperation <= `EXE_JAL_OP;
                ALUSel <= `EXE_RES_JUMP_BRANCH;
                RegisterReadEnable1 <= 1'b0;
                RegisterReadEnable2 <= 1'b0;
                WriteAddressOut <= 5'b11111; 
                LinkAddress <= PCPlus8 ;
                BranchTarget <= {PCPlus4[31:28], IdInstruction[25:0], 2'b00};
                BranchFlag <= 1'b1;
                NextInstructionInDelaySlot <= 1'b1; 
                ValidInstruction <= 1'b0; 
            end
            `EXE_BEQ: begin
                WriteRegisterOut <= 1'b0;
                ALUOperation <= `EXE_BEQ_OP;
                ALUSel <= `EXE_RES_JUMP_BRANCH;
                RegisterReadEnable1 <= 1'b1;
                RegisterReadEnable2 <= 1'b1;
                ValidInstruction <= 1'b0; 
                if(Register1 == Register2) begin
                    BranchTarget <= PCPlus4 + JumpOffset;
                    BranchFlag <= 1'b1;
                    NextInstructionInDelaySlot <= 1'b1; 
                end
            end
            `EXE_BGTZ: begin
                WriteRegisterOut <= 1'b0;
                ALUOperation <= `EXE_BGTZ_OP;
                ALUSel <= `EXE_RES_JUMP_BRANCH;
                RegisterReadEnable1 <= 1'b1;
                RegisterReadEnable2 <= 1'b0;
                ValidInstruction <= 1'b0; 
                if((Register1[31] == 1'b0) && (Register1 != 32'b0)) begin
                    BranchTarget <= PCPlus4 + JumpOffset;
                    BranchFlag <= 1'b1;
                    NextInstructionInDelaySlot <= 1'b1; 
                end
            end
            `EXE_BLEZ: begin
                WriteRegisterOut <= 1'b0;
                ALUOperation <= `EXE_BLEZ_OP;
                ALUSel <= `EXE_RES_JUMP_BRANCH;
                RegisterReadEnable1 <= 1'b1;
                RegisterReadEnable2 <= 1'b0;
                ValidInstruction <= 1'b0; 
                if((Register1[31] == 1'b1) || (Register1 == 32'b0)) begin
                    BranchTarget <= PCPlus4 + JumpOffset;
                    BranchFlag <= 1'b1;
                    NextInstructionInDelaySlot <= 1'b1; 
                end
            end
            `EXE_BNE: begin
                WriteRegisterOut <= 1'b0;
                ALUOperation <= `EXE_BLEZ_OP;
                ALUSel <= `EXE_RES_JUMP_BRANCH;
                RegisterReadEnable1 <= 1'b1;
                RegisterReadEnable2 <= 1'b1;
                ValidInstruction <= 1'b0; 
                if(Register1 != Register2) begin
                    BranchTarget <= PCPlus4 + JumpOffset;
                    BranchFlag <= 1'b1;
                    NextInstructionInDelaySlot <= 1'b1; 
                end
            end
            `EXE_REGimmediate_INST: begin
                case (IdInstruction[20:16])
                    `EXE_BGEZ: begin
                        WriteRegisterOut <= 1'b0;
                        ALUOperation <= `EXE_BGEZ_OP;
                        ALUSel <= `EXE_RES_JUMP_BRANCH;
                        RegisterReadEnable1 <= 1'b1;
                        RegisterReadEnable2 <= 1'b0;
                        ValidInstruction <= 1'b0; 
                        if(Register1[31] == 1'b0) begin
                            BranchTarget <= PCPlus4 + JumpOffset;
                            BranchFlag <= 1'b1;
                            NextInstructionInDelaySlot <= 1'b1; 
                        end
                    end
                    `EXE_BLTZ: begin
                        WriteRegisterOut <= 1'b0;
                        ALUOperation <= `EXE_BGEZAL_OP;
                        ALUSel <= `EXE_RES_JUMP_BRANCH;
                        RegisterReadEnable1 <= 1'b1;
                        RegisterReadEnable2 <= 1'b0;
                        ValidInstruction <= 1'b0; 
                        if(Register1[31] == 1'b1) begin
                            BranchTarget <= PCPlus4 + JumpOffset;
                            BranchFlag <= 1'b1;
                            NextInstructionInDelaySlot <= 1'b1; 
                        end
                    end
                    default: begin
                end
                endcase
            end
            `EXE_LB: begin
                WriteRegisterOut <= 1'b1;
                ALUOperation <= `EXE_LB_OP;
                ALUSel <= `EXE_RES_LOAD_STORE;
                RegisterReadEnable1 <= 1'b1;
                RegisterReadEnable2 <= 1'b0;
                WriteAddressOut <= IdInstruction[20:16];
                ValidInstruction <= 1'b0;
            end
            `EXE_LBU: begin
                WriteRegisterOut <= 1'b1;
                ALUOperation <= `EXE_LBU_OP;
                ALUSel <= `EXE_RES_LOAD_STORE;
                RegisterReadEnable1 <= 1'b1;
                RegisterReadEnable2 <= 1'b0;
                WriteAddressOut <= IdInstruction[20:16];
                ValidInstruction <= 1'b0;
            end
            `EXE_LW: begin
                WriteRegisterOut <= 1'b1;
                ALUOperation <= `EXE_LW_OP;
                ALUSel <= `EXE_RES_LOAD_STORE;
                RegisterReadEnable1 <= 1'b1;
                RegisterReadEnable2 <= 1'b0;
                WriteAddressOut <= IdInstruction[20:16];
                ValidInstruction <= 1'b0;
            end
            `EXE_SB: begin
                WriteRegisterOut <= 1'b0;
                ALUOperation <= `EXE_SB_OP;
                ALUSel <= `EXE_RES_LOAD_STORE;
                RegisterReadEnable1 <= 1'b1;
                RegisterReadEnable2 <= 1'b1;
                ValidInstruction <= 1'b0;
            end
            `EXE_SW: begin
                WriteRegisterOut <= 1'b0;
                ALUOperation <= `EXE_SW_OP;
                ALUSel <= `EXE_RES_LOAD_STORE;
                RegisterReadEnable1 <= 1'b1;
                RegisterReadEnable2 <= 1'b1;
                ValidInstruction <= 1'b0;
            end
            `EXE_CP: begin
                case(IdInstruction[25:21])
                    5'b00100:begin
                        WriteRegisterOut <= 1'b0;
                        ALUOperation <= `EXE_MTC0_OP;
                        ALUSel <= `EXE_RES_MOVE;
                        ValidInstruction <= 1'b0;
                        WriteCPAddress <= IdInstruction[15:11];
                        RegisterReadEnable1 <= 1'b1;
                        RegisterAddress1 <= IdInstruction[20:16];
                        RegisterReadEnable2 <= 1'b0;
                        privilege <= 1'b1;
                    end
                    5'b00000:begin
                        WriteRegisterOut <= 1'b1;
                        WriteAddressOut <= IdInstruction[20:16];
                        ALUOperation <= `EXE_MFC0_OP;
                        ALUSel <= `EXE_RES_MOVE;
                        ValidInstruction <= 1'b0;
                        CPReadEnable <= 1'b1;
                        CPAddress <= IdInstruction[15:11];
                        RegisterReadEnable1 <= 1'b0;
                        RegisterReadEnable2 <= 1'b0;
                        privilege <= 1'b1;
                    end
                    default:begin
                    end
                endcase
            end
            default: begin
            end
            endcase
            if (IdInstruction[31:21] == 11'b00000000000) begin
                if (IdInstruction[5:0] == `EXE_SLL) begin
                    WriteRegisterOut <= 1'b1;
                    ALUOperation <= `EXE_SLL_OP;
                    ALUSel <= `EXE_RES_SHIFT;
                    RegisterReadEnable1 <= 1'b0;
                    RegisterReadEnable2 <= 1'b1;
                    immediate[4:0] <= IdInstruction[10:6];
                    WriteAddressOut <= IdInstruction[15:11];
                    ValidInstruction <= 1'b0;
                end else if ( IdInstruction[5:0] == `EXE_SRL ) begin
                    WriteRegisterOut <= 1'b1;
                    ALUOperation <= `EXE_SRL_OP;
                    ALUSel <= `EXE_RES_SHIFT;
                    RegisterReadEnable1 <= 1'b0;
                    RegisterReadEnable2 <= 1'b1;
                    immediate[4:0] <= IdInstruction[10:6];
                    WriteAddressOut <= IdInstruction[15:11];
                    ValidInstruction <= 1'b0;
                end else if ( IdInstruction[5:0] == `EXE_SRA ) begin
                    WriteRegisterOut <= 1'b1;
                    ALUOperation <= `EXE_SRA_OP;
                    ALUSel <= `EXE_RES_SHIFT;
                    RegisterReadEnable1 <= 1'b0;
                    RegisterReadEnable2 <= 1'b1;
                    immediate[4:0] <= IdInstruction[10:6];
                    WriteAddressOut <= IdInstruction[15:11];
                    ValidInstruction <= 1'b0;
                end
            end
            if(IdInstruction[31:0] == 32'b01000010000000000000000000000010) begin
                tlbwi <= 1'b1;
                ValidInstruction <= 1'b0;
                privilege <= 1'b1;
            end else begin
                tlbwi <= 1'b0;
            end
            if(IdInstruction[31:0] == 32'b00000000000000000000000000001100) begin
                syscall <= 1'b1;
                ValidInstruction <= 1'b0;
                privilege <= 1'b0;
            end else begin
                syscall <= 1'b0;
            end
            if(IdInstruction[31:0] == 32'b01000010000000000000000000011000) begin
                eret <= 1'b1;
                ValidInstruction <= 1'b0;
                privilege <= 1'b1;
            end else begin
                eret <= 1'b0;
            end
            //$display("pc:%h, instruction:%h",IdPC,IdInstruction);
        end
    end
    always @ (*) begin
        if(reset == 1'b0) begin
            Register1 <= 32'b0;
        end else if(CPReadEnable == 1'b1) begin
            if(ExWriteCPIn == 1'b1 && ExWriteCPAddress == CPAddress) begin
                Register1 <= ExWriteCPData;
            end else if(MemWriteCPIn == 1'b1 && MemWriteCPAddress == CPAddress) begin
                Register1 <= MemWriteCPData;
            end else begin
                Register1 <= CPData;
            end
        end else if(HiReadEnable == 1'b1) begin 
            if (ExWriteHiIn == 1'b1) begin
                Register1 <= ExWriteHiDataIn;
            end else if (MemWriteHiIn == 1'b1) begin
                Register1 <= MemWriteHiDataIn;
            end else begin
                Register1 <= hi;
            end
        end else if(LoReadEnable == 1'b1) begin
            if (ExWriteLoIn == 1'b1) begin
                Register1 <= ExWriteLoDataIn;
            end else if (MemWriteLoIn == 1'b1) begin
                Register1 <= MemWriteLoDataIn;
            end else begin
                Register1 <= lo;
            end
        end else if((RegisterReadEnable1 == 1'b1) && (ExWriteRegisterIn == 1'b1) && (ExWriteAddressIn == RegisterAddress1)) begin
            Register1 <= ExWriteDataIn;
        end else if((RegisterReadEnable1 == 1'b1) && (MemWriteRegisterIn == 1'b1) && (MemWriteAddressIn == RegisterAddress1)) begin
            Register1 <= MemWriteDataIn;
        end else if(RegisterReadEnable1 == 1'b1) begin
            Register1 <= RegisterData1;
        end else if(RegisterReadEnable1 == 1'b0) begin
            Register1 <= immediate;
        end else begin
            Register1 <= 32'b0;
        end
    end
    always @ (*) begin
        if(reset == 1'b0) begin
            Register2 <= 32'b0;
        end else if((RegisterReadEnable2 == 1'b1) && (ExWriteRegisterIn == 1'b1) && (ExWriteAddressIn == RegisterAddress2)) begin
            Register2 <= ExWriteDataIn;
        end else if((RegisterReadEnable2 == 1'b1) && (MemWriteRegisterIn == 1'b1) && (MemWriteAddressIn == RegisterAddress2)) begin
            Register2 <= MemWriteDataIn;
        end else if(RegisterReadEnable2 == 1'b1) begin
            Register2 <= RegisterData2;
        end else if(RegisterReadEnable2 == 1'b0) begin
            Register2 <= immediate;
        end else begin
            Register2 <= 32'b0;
        end
    end
    always @ (*) begin
        if(reset == 1'b0) begin
            PauseRequest <= 1'b0;
        end else if(ExIsLoad == 1'b1) begin
            if((RegisterReadEnable1 == 1'b1) && (ExWriteAddressIn == RegisterAddress1)) begin
                PauseRequest <= 1'b1;
            end else if((RegisterReadEnable2 == 1'b1) && (ExWriteAddressIn == RegisterAddress2)) begin
                PauseRequest <= 1'b1;
            end else begin
                PauseRequest <= 1'b0;
            end
        end else begin
            PauseRequest <= 1'b0;
        end
    end
    always @ (*) begin
        if(reset == 1'b0) begin
            IsInDelaySlotOut <= 1'b0;
        end else begin
            IsInDelaySlotOut <= IsInDelaySlotIn; 
        end
    end
endmodule
