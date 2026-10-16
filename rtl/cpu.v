// supports: loadi, mov, add, sub, and, or, j, beq, bne, sll, slr, sra, ror
// future updates: mult, sla, bge, ble, bgt, blt
`timescale 1ns/1ps

module control_unit(
    input [7:0] OPCODE,             // The operation code from the instruction
    output reg [2:0] ALUOP,         // Tells the ALU what operation to perform
    output reg SEL_2S_COMP,         // Selects if we need to invert the second register (for subtraction)
    output reg SEL_IMM,             // Selects if we are using an immediate (constant) value
    output reg EN_WR,               // Enables writing the result back to a register
    output reg JUMP,                // Jump signal
    output reg BRANCH               // Branch signal
);
    always @(*) begin
        #1 // delay

        case(OPCODE)
            8'b00000000: begin      // loadi
                ALUOP = 3'b000;
                SEL_2S_COMP = 1'b0;
                SEL_IMM = 1'b1;     // Use the immediate value
                EN_WR = 1'b1;       // Allow writing to register
                JUMP = 1'b0;
                BRANCH = 1'b0;
            end

            8'b00000001: begin      // mov
                ALUOP = 3'b000;
                SEL_2S_COMP = 1'b0;
                SEL_IMM = 1'b0;     // Use register value, not immediate
                EN_WR = 1'b1;       // Allow writing to register
                JUMP = 1'b0;
                BRANCH = 1'b0;
            end

            8'b00000010: begin      // add
                ALUOP = 3'b001;     // ALU code for addition
                SEL_2S_COMP = 1'b0;
                SEL_IMM = 1'b0;
                EN_WR = 1'b1;       // Save the result
                JUMP = 1'b0;
                BRANCH = 1'b0;
            end

            8'b00000011: begin      // sub
                ALUOP = 3'b001;     // Uses addition hardware but with negative number
                SEL_2S_COMP = 1'b1; // Turn the second register value negative (2's complement)
                SEL_IMM = 1'b0;
                EN_WR = 1'b1;       // Save the result
                JUMP = 1'b0;
                BRANCH = 1'b0;
            end

            8'b00000100: begin      // and
                ALUOP = 3'b010;     // ALU code for AND
                SEL_2S_COMP = 1'b0;
                SEL_IMM = 1'b0;
                EN_WR = 1'b1;       // Save the result
                JUMP = 1'b0;
                BRANCH = 1'b0;
            end

            8'b00000101: begin      // or
                ALUOP = 3'b011;     // ALU code for OR
                SEL_2S_COMP = 1'b0;
                SEL_IMM = 1'b0;
                EN_WR = 1'b1;       // Save the result
                JUMP = 1'b0;
                BRANCH = 1'b0;
            end

            8'b00000110: begin      // jump
                ALUOP = 3'b000;     // ALU code for j
                SEL_2S_COMP = 1'b0;
                SEL_IMM = 1'b0;
                EN_WR = 1'b0;     
                JUMP = 1'b1;        // set new control signal high to identify a jump
                BRANCH = 1'b0;
            end

            8'b00000111: begin      // beq
                ALUOP = 3'b001;     // ALU code for beq
                SEL_2S_COMP = 1'b1; //to subtract
                SEL_IMM = 1'b0;
                EN_WR = 1'b0;     
                JUMP = 1'b0;
                BRANCH = 1'b1;      // set new control signal high to identify a branch
            end

            8'b00010000: begin      // bne
                ALUOP = 3'b001;     // ALU code for bne
                SEL_2S_COMP = 1'b1; 
                SEL_IMM = 1'b0;
                EN_WR = 1'b0;     
                JUMP = 1'b1;
                BRANCH = 1'b1;      //I have used both jump and branch signals to identify a bne 
            end

            8'b00010001: begin      // shift left
                ALUOP = 3'b100;     // ALU code for shift left
                SEL_2S_COMP = 1'b0; 
                SEL_IMM = 1'b1;
                EN_WR = 1'b1;       // Save the result
                JUMP = 1'b0;
                BRANCH = 1'b0;
            end

            8'b00010010: begin      // shift right
                ALUOP = 3'b101;     // ALU code for shift right
                SEL_2S_COMP = 1'b0; 
                SEL_IMM = 1'b1;     //use variable offset as shamt
                EN_WR = 1'b1;       // Save the result
                JUMP = 1'b0;
                BRANCH = 1'b0;
            end

            8'b00010011: begin      // algorithmic shift right
                ALUOP = 3'b110;     // ALU code for algorithmic shift right
                SEL_2S_COMP = 1'b0; 
                SEL_IMM = 1'b1;     //use variable offset as shamt
                EN_WR = 1'b1;       // Save the result
                JUMP = 1'b0;
                BRANCH = 1'b0;
            end

            8'b00010100: begin      // rotate right
                ALUOP = 3'b111;     // ALU code for rotate
                SEL_2S_COMP = 1'b0; 
                SEL_IMM = 1'b1;     //use variable offset as shamt
                EN_WR = 1'b1;       // Save the result
                JUMP = 1'b0;
                BRANCH = 1'b0;
            end

            default: begin          // Default case: Run this if OPCODE doesn't match any above
                ALUOP = 3'b000;
                SEL_2S_COMP = 1'b0;
                SEL_IMM = 1'b0;
                EN_WR = 1'b0;       // Do not write anything to registers (safe mode)
                JUMP = 1'b0;
                BRANCH = 1'b0;
            end
        endcase
    end

endmodule


module _2s_complement(
    input [7:0] REGOUT2,        // Input data from register 2
    output reg [7:0] RESULT_2S  // Output data made negative
);
    always @(*) begin
        #1 //delay

        // Flip all the bits (~) and add 1 to make it negative
        RESULT_2S = ~REGOUT2 + 1;
    end
endmodule

module sign_extension (
    input  wire [7:0]  IN,  // 8-bit signed input
    output wire [31:0] OUT  // 32-bit signed output
);

    assign OUT = { {24{IN[7]}}, IN };   //use the 7th index of the 8bit input to fill the 32bit output
endmodule

module insFetch (
    input [31:0] INS,           // The full 32-bit instruction
    output reg [7:0] OP,        // Bits 31 to 24: The operation code
    output reg [2:0] WRITEREG,  // Bits 18 to 16: The destination register address
    output reg [7:0] OFFSET,    // Bits 23 to 16: immediate value (jump or branch target offset)
    output reg [2:0] READREG1,  // Bits 10 to 8: First source register address
    output reg [2:0] READREG2,  // Bits 2 to 0: Second source register address
    output reg [7:0] IMM        // Bits 7 to 0: Immediate constant value
);
    always @(*) begin
        OP = INS[31:24];
        OFFSET = INS[23:16];
        WRITEREG = INS[18:16];
        READREG1 = INS[10:8];
        READREG2 = INS[2:0];
        IMM = INS[7:0];
    end
    
endmodule 


module pc (
    input RESET,                // Reset signal to start over
    input CLK,                  // Clock signal to time the steps
    input ENABLE,               // ENABLE signal to time the steps
    input [31:0] EXTD_OFFSET,   // extended offset
    output reg [31:0] PC        // The current instruction address output
);
    reg [31:0] target;
    reg [31:0] next;

    // Runs every time the clock signal goes from 0 to 1 (rising edge)
    always @(posedge CLK) begin
        #1 // delay

        if (RESET) begin
            PC <= 32'h00000000; // Go back to the very beginning (address 0)
        end 
        else begin
            if (ENABLE == 1'b1) // this is the enable to jump to the target address that is not +4
                PC <= (EXTD_OFFSET << 2) + PC; // we shift by 2 to make the offset a multiple of 4 and add it to PC to make the actual target address
            else
                PC <= PC + 32'h4;               //default method to go to next instruction
        end
    end

    
endmodule


module cpu(
    output [31:0] PC,           // Outputs current program counter address
    input [31:0] INSTRUCTION,   // Inputs current instruction fetched from memory
    input CLK,                  // Clock input
    input RESET                 // Reset input
);
    // Internal wires used to pass data between internal modules
    wire [7:0] opcode;          // Operation code
    wire [2:0] write_reg;       // Destination register address
    wire [2:0] read_reg1;       // First source register address
    wire [2:0] read_reg2;       // Second source register address
    wire [7:0] imm;             // Immediate constant value
    wire [2:0] aluop;           // ALU operation control wire
    wire sel_imm;               // Wire to select immediate value
    wire sel_2s_comp;           // Wire to select negative value
    wire en_write;              // Register write enable wire
    wire [7:0] regout2;         // Data output from register 2
    wire [7:0] regout1;         // Data output from register 1
    wire [7:0] out_2s_comp;     // Negative version of register 2 data
    wire [7:0] mux1_out;        // Output of MUX 1 (chooses normal or negative register 2)
    wire [7:0] mux2_out;        // Output of MUX 2 (chooses register data or immediate value)
    wire [7:0] alu_result;      // Final calculation result from the ALU

    wire [7:0] offset;          //8bit offset to use with jump and branch
    wire [31:0] extd_offset;    //32 bit sign extended version of above
    wire jump;                  //jump signal
    wire branch;                //branch signal
    wire zero;                  //zero signal from ALU
    wire enable_jump;           //enable signal to PC

    //instantiate all the modules
    // Connect the Program Counter module
    pc _pc(
        .RESET(RESET),
        .CLK(CLK),
        .ENABLE(enable_jump),
        .EXTD_OFFSET(extd_offset),
        .PC(PC)
    );

    // Connect the Instruction Decoder module
    insFetch _insFetch(
        .INS(INSTRUCTION),
        .OP(opcode),
        .WRITEREG(write_reg),
        .OFFSET(offset),
        .READREG1(read_reg1),
        .READREG2(read_reg2),
        .IMM(imm)
    );

    // Connect the Control Unit module
    control_unit _control_unit(
        .OPCODE(opcode),
        .ALUOP(aluop),
        .SEL_2S_COMP(sel_2s_comp),
        .SEL_IMM(sel_imm),
        .EN_WR(en_write),
        .JUMP(jump),
        .BRANCH(branch)
    );

    // Connect the Register File module (where variable data is stored)
    reg_file _reg_file(
        .IN(alu_result),
        .OUT1(regout1),
        .OUT2(regout2),
        .INADDRESS(write_reg),
        .OUT1ADDRESS(read_reg1),
        .OUT2ADDRESS(read_reg2),
        .WRITE(en_write),
        .CLK(CLK),
        .RESET(RESET)
    );

    // Connect sign extension module
    sign_extension _sign_extension(
        .IN(offset),
        .OUT(extd_offset)
    );

    // Connect the 2's Complement module
    _2s_complement __2s_complement(
        .REGOUT2(regout2),
        .RESULT_2S(out_2s_comp)
    );

    // Connect the ALU module
    alu _alu(
        .DATA1(regout1),
        .DATA2(mux2_out),
        .RESULT(alu_result),
        .SELECT(aluop),
        .ZERO(zero)
    );

    // Multiplexer 1: If sel_2s_comp is 1, pick the negative number. Otherwise, pick normal register 2 data.
    assign mux1_out = (sel_2s_comp == 1'b1) ? out_2s_comp : regout2;
    
    // Multiplexer 2: If sel_imm is 1, pick the constant immediate value. Otherwise, pick the result from MUX 1.
    assign mux2_out = (sel_imm == 1'b1) ? imm : mux1_out;


    assign enable_jump = (branch && (jump ^ zero)) || (!branch && jump);    //enable jump if it is a branch and the zero signal is not equal to the jump signal (bne) or if it is a jump instruction

endmodule