// Classical MIPS processor for Educational and Understanding the architecture 

// Reference Material : Harris & Harris Book - Digital Design and Computer Architecture
// Educational Single Cycle Processor 


// MODULE 1 : PROGRAM CONUNTER 
// PURPOSE : GIVING THE NEXT INSTR 
module program_counter(
    input clk ,
    input reset ,
    input [31:0] pc_next ,
    output reg [31:0] pc
);

    always @ (posedge clk) begin 
        if(reset) begin 
            pc <= 32'b1;
        end
        else begin 
            pc <= pc_next ;
        end
    end

endmodule

// PC ADDER
// TO MOVE THE SEQ CKT 

module pc_4(
    input [31:0] pc ,
    output reg [31:0] pc_next
);

    always @ (*) begin
        pc_next <= pc + 4 ;
    end

endmodule

// INSTRUCTION MEMORY 
// TAKES INSTR FROM PC AND ACCESS LOCATION FROM EXTERNAL 

module instr_memory (
    input [31:0] addr ,
    output [31:0] instr 
);
    reg [31:0] mem [0:255] ;

    assign instr = mem[addr>>2];

    // WRITE THE FILE NAME TO TAKE THE INPUT FROM THE EXACT FILE
    initial begin
        $readmemh("program.hex", mem);
    end

endmodule

// INSTR EXTRACTOR 

// DECODE THE INSTR OBTAINED IN I , R , J TYPE INSTR FOR COMPUTER 
module instructionunderstand(
    input [31:0] instr ,
    output reg [5:0] opcode,
    output reg [4:0] rs ,
    output reg [4:0] rt ,
    output reg [4:0] rd ,
    output reg [4:0] shamt ,
    output reg [5:0] funct,
    output reg [15:0] imm ,
    output reg [25:0] jaddr
);

always @(*) begin
    opcode = instr[31:26];
    rs     = instr[25:21];   
    rt     = instr[20:16];
    rd     = instr[15:11];
    shamt  = instr[10:6];
    funct  = instr[5:0];
    imm    = instr[15:0];
    jaddr  = instr[25:0];
end

endmodule

// MAIN CONTROL UNIT 
// DECIDES WHAT TYPE OF INSTR IT IS

module control_unit(
    input [5:0 ] opcode ,
    output reg reg_write,
    output reg alu_src,
    output reg mem_write,
    output reg memtoreg,
    output reg regdst,
    output reg [1:0] ALUop,
    output reg memread,
    output reg beq,
    output reg j
);

always @(*) begin
    reg_write = 0;
    alu_src   = 0;
    mem_write = 0;
    memtoreg  = 0;
    regdst    = 0;
    ALUop     = 2'b00;
    memread   = 0;
    beq       = 0;
    j         = 0;

    case (opcode)

        6'b000000: begin
            reg_write = 1;
            regdst    = 1;
            alu_src   = 0;
            ALUop     = 2'b10;
        end

        6'b100011: begin
            reg_write = 1;
            alu_src   = 1;
            memread   = 1;
            memtoreg  = 1;
            ALUop     = 2'b00;
        end

        6'b101011: begin
            alu_src   = 1;
            mem_write = 1;
            ALUop     = 2'b00;
        end

        6'b000100: begin
            beq   = 1;
            ALUop = 2'b01;
        end

        6'b001000: begin
            reg_write = 1 ;
            alu_src = 1 ;
            
        end

        6'b000010: begin
            j = 1;
        end

        default: begin
        end

    endcase
end

endmodule
    
// REGISTER FILE 
// CONTAINS THE TEMP REGS THAT WILL ACCESSED FOR FASTER 

module reg_file (
    input clk ,
    input reg_write ,
    input [4:0] rs , 
    input [4:0] rt ,
    input [4:0] rd ,
    input [31:0] write_data ,
    output [31:0] read_data1 ,
    output [31:0] read_data2  
); 

    reg [31:0] regs [31:0]; 

    
    assign read_data1 = (rs == 0) ? 32'b0 : regs[rs];
    assign read_data2 = (rt == 0) ? 32'b0 : regs[rt];

    
    always @(posedge clk) begin
        if (reg_write && rd != 0) begin 
            regs[rd] <= write_data;
        end
    end

endmodule

// SIGN EXTENDER 
// CONVERTS IMM INTO 32 BITS 

module sign_extend (
    input [15:0] imm,
    output [31:0] imm_ext
);
    assign imm_ext = {{16{imm[15]}}, imm};
endmodule

// ALU ctrl 
// INSTR INTO CALCUALTIONS OR OPERATIONS 



module alu_control (
    input [1:0] ALUop,
    input [5:0] funct,
    output reg [3:0] alu_ctrl
);

    always @(*) begin
        case (ALUop)
            2'b00: alu_ctrl = 4'b0010; // ADD
            2'b01: alu_ctrl = 4'b0110; // SUB
            2'b10: begin
                case (funct)
                    6'b100000: alu_ctrl = 4'b0010; // ADD
                    6'b100010: alu_ctrl = 4'b0110; // SUB
                    6'b100100: alu_ctrl = 4'b0000; // AND
                    6'b100101: alu_ctrl = 4'b0001; // OR
                    6'b101010: alu_ctrl = 4'b0111; // SLT
                    default:   alu_ctrl = 4'b0000;
                endcase
            end
            default: alu_ctrl = 4'b0000;
        endcase
    end

endmodule 

// ALU 
// ARTHIMATIC LOGIC UNIT - COMPLETES THE CALCULATIONS 

module alu (
    input [31:0] A,
    input [31:0] B,
    input [3:0] alu_ctrl,
    output reg [31:0] result,
    output zero
);

    always @(*) begin
        case (alu_ctrl)
            4'b0010: result = A + B;
            4'b0110: result = A - B;
            4'b0000: result = A & B;
            4'b0001: result = A | B;
            4'b0111: result = (A < B) ? 32'b1 : 32'b0;
            default: result = 32'b0;
        endcase
    end

    assign zero = (result == 0);

endmodule

//  DATA MEMORY 
// TO STORE AND USE FOR OPERATIONS 

module data_memory (
    input clk,
    input memread,
    input mem_write,
    input [31:0] addr,
    input [31:0] write_data,
    output reg [31:0] read_data
);

    reg [31:0] mem [0:255];

    always @(posedge clk) begin
        if (mem_write)
            mem[addr >> 2] <= write_data;
    end

    always @(*) begin
        if (memread)
            read_data = mem[addr >> 2];
        else
            read_data = 32'b0;
    end

endmodule

// MAIN CPU
// THE WIRING OF EACH MODULE 
// INSTATIATING EACH MODULE TO CONNECT THE DOTS AND MODULES 

module single_cycle_cpu(
    input clk,
    input reset
);
    wire [31:0] pc, pc_plus_4, pc_next;
    wire [31:0] instr;
    wire [5:0] opcode, funct;
    wire [4:0] rs, rt, rd;
    wire [15:0] imm;
    wire [25:0] jaddr;

    wire reg_write, alu_src, mem_write, memtoreg;
    wire regdst, memread, beq, j;
    wire [1:0] ALUop;

    wire [31:0] read_data1, read_data2;
    wire [31:0] imm_ext;
    wire [3:0] alu_ctrl;
    wire [31:0] alu_result;
    wire zero;
    wire [31:0] mem_data;

    wire [31:0] alu_in2;
    wire [4:0] write_reg;
    wire [31:0] write_data;
    wire [31:0] branch_target;
    wire [31:0] jump_target;

    program_counter PC(clk, reset, pc_next, pc);
    pc_4 PC4(pc, pc_plus_4);

    instr_memory IM(pc, instr);
    instructionunderstand IU(instr, opcode, rs, rt, rd, , funct, imm, jaddr);

    control_unit CU(opcode, reg_write, alu_src, mem_write, memtoreg,
                    regdst, ALUop, memread, beq, j);

    reg_file RF(clk, reg_write, rs, rt, write_reg, write_data,
                read_data1, read_data2);

    sign_extend SE(imm, imm_ext);

    alu_control AC(ALUop, funct, alu_ctrl);

    assign alu_in2 = alu_src ? imm_ext : read_data2;

    alu ALU(read_data1, alu_in2, alu_ctrl, alu_result, zero);

    data_memory DM(clk, memread, mem_write, alu_result,
                   read_data2, mem_data);

    assign write_reg  = regdst ? rd : rt;
    assign write_data = memtoreg ? mem_data : alu_result;

    assign branch_target = pc_plus_4 + (imm_ext << 2);
    assign jump_target   = {pc_plus_4[31:28], jaddr, 2'b00};

    assign pc_next = j ? jump_target :
                     (beq && zero) ? branch_target :
                     pc_plus_4;
endmodule
