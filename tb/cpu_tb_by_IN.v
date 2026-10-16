// Design: Testbench of Integrated CPU of Simple Processor
// Author: Isuru Nawinne
`timescale 1ns/1ps
module cpu_tb;

    reg CLK, RESET;
    wire [31:0] PC;
    wire [31:0] INSTRUCTION;
    
    integer k;
    /* 
    ------------------------
     SIMPLE INSTRUCTION MEM
    ------------------------
    */
    
    // TODO: Initialize an array of registers (8x1024) named 'instr_mem' to be used as instruction memory
    reg [7:0] instr_mem [1023:0];
    // TODO: Create combinational logic to support CPU instruction fetching, given the Program Counter(PC) value 
    //       (make sure you include the delay for instruction fetching here)
    assign #2 INSTRUCTION = {instr_mem[PC + 3], instr_mem[PC+2], instr_mem[PC+1], instr_mem[PC]};
    
    initial
    begin
        // Initialize instruction memory with the set of instructions you need execute on CPU
        
        for (k = 0; k < 1024; k = k + 1) begin
            instr_mem[k] = 8'b00000000;
        end

        // METHOD 1: manually loading instructions to instr_mem
        {instr_mem[10'd3], instr_mem[10'd2], instr_mem[10'd1], instr_mem[10'd0]} = 32'b00000000_00000010_00000000_00000101;    //loadi r2 _ 5
        {instr_mem[10'd7], instr_mem[10'd6], instr_mem[10'd5], instr_mem[10'd4]} = 32'b00000000_00000001_00000000_00000101;    //loadi r1 _ 9
        {instr_mem[10'd11], instr_mem[10'd10], instr_mem[10'd9], instr_mem[10'd8]} = 32'b00000011_00000110_00000001_00000010;  //sub r6 r1 r2
                // R-Type format: Opcode (31-24) | Dest (23-16) | Src1 (15-8) | Src2 (7-0)
        
        // add 4 1 2 
        // Opcode: 00000010 (add) | Dest: 00000100 (r4) | Src1: 00000001 (r1) | Src2: 00000010 (r2)
        {instr_mem[10'd15], instr_mem[10'd14], instr_mem[10'd13], instr_mem[10'd12]} = 32'b00000010_00000100_00000001_00000010;  

        // sub 4 1 2
        // Opcode: 00000011 (sub) | Dest: 00000100 (r4) | Src1: 00000001 (r1) | Src2: 00000010 (r2)
        {instr_mem[10'd19], instr_mem[10'd18], instr_mem[10'd17], instr_mem[10'd16]} = 32'b00000011_00000100_00000001_00000010;  

        // and 4 1 2
        // Opcode: 00000100 (and) | Dest: 00000100 (r4) | Src1: 00000001 (r1) | Src2: 00000010 (r2)
        {instr_mem[10'd23], instr_mem[10'd22], instr_mem[10'd21], instr_mem[10'd20]} = 32'b00000100_00000100_00000001_00000010;  

        // or 4 1 2
        // Opcode: 00000101 (or) | Dest: 00000100 (r4) | Src1: 00000001 (r1) | Src2: 00000010 (r2)
        {instr_mem[10'd27], instr_mem[10'd26], instr_mem[10'd25], instr_mem[10'd24]} = 32'b00000101_00000100_00000001_00000010;  

        // beq 0x4 1 2
        // Opcode: 00000111 (beq) | Imm: 00000100 (4) | Src1: 00000001 (r1) | Src2: 00000010 (r2)
        {instr_mem[10'd31], instr_mem[10'd30], instr_mem[10'd29], instr_mem[10'd28]} = 32'b00000111_00000100_00000001_00000010;  

        // mov 4 1
        // Opcode: 00000001 (mov) | Dest: 00000100 (r4) | Ignore (15-8): 00000000 | Src: 00000001 (r1)
        {instr_mem[10'd35], instr_mem[10'd34], instr_mem[10'd33], instr_mem[10'd32]} = 32'b00000001_00000100_00000000_00000001;  

        // loadi 4 0xFF
        // Opcode: 00000000 (loadi) | Dest: 00000100 (r4) | Ignore (15-8): 00000000 | Imm: 11111111 (0xFF)
        {instr_mem[10'd39], instr_mem[10'd38], instr_mem[10'd37], instr_mem[10'd36]} = 32'b00000000_00000100_00000000_11111111;  

        // j 0x-03
        // Opcode: 00000110 (j) | Imm: 11111101 (-3) | Ignore (15-8): 00000000 | Ignore (7-0): 00000000
        {instr_mem[10'd43], instr_mem[10'd42], instr_mem[10'd41], instr_mem[10'd40]} = 32'b00000110_11111101_00000001_00000010;  

        // METHOD 2: loading instr_mem content from instr_mem.mem file
        //$readmemb("instr_mem.mem", instr_mem);
    end
    
    /* 
    -----
     CPU
    -----
    */
    cpu mycpu(PC, INSTRUCTION, CLK, RESET);

    initial
    begin
    
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("cpu_wavedata.vcd");
		$dumpvars(0, cpu_tb);
        
        CLK = 1'b0;
        RESET = 1'b0;
        
        // TODO: Reset the CPU (by giving a pulse to RESET signal) to start the program execution
        #2
        RESET = 1'b1;
        #8
        RESET = 1'b0;
        // finish simulation after some time
        #500
        $finish;
        
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;
        

endmodule