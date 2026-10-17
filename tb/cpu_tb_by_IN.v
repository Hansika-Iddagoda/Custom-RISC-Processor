// Computer Architecture (CO2070) - Upgraded Integrated Testbench
// Design: Testbench of Integrated CPU with Data Memory
`timescale 1ns/1ps

module cpu_tb;
    reg CLK, RESET;
    wire [31:0] PC;
    wire [31:0] INSTRUCTION;
    
    // Memory communication wires to link CPU and Data Memory
    wire mem_read, mem_write;
    wire [7:0] mem_address;
    wire [7:0] mem_writedata;
    wire [7:0] mem_readdata;
    wire busywait;

    integer k;

    /* ------------------------
     SIMPLE INSTRUCTION MEM
    ------------------------
    */
    reg [7:0] instr_mem [1023:0];

    // Combinational logic supporting CPU instruction fetching
    assign #2 INSTRUCTION = {instr_mem[PC + 3], instr_mem[PC+2], instr_mem[PC+1], instr_mem[PC]};

    initial
    begin
        // Initialize instruction memory array
        for (k = 0; k < 1024; k = k + 1) begin
            instr_mem[k] = 8'b00000000;
        end
        // loadi 1 0xAA (Load data 10101010 into r1)
        // Opcode: 00000000 | Dest: 00000001 (r1) | Ignore: 00000000 | Imm: 10101010 (0xAA)
        {instr_mem[10'd3], instr_mem[10'd2], instr_mem[10'd1], instr_mem[10'd0]} = 32'b00000000_00000001_00000000_10101010;  

        // loadi 2 0xBB (Load data 10111011 into r2)
        // Opcode: 00000000 | Dest: 00000010 (r2) | Ignore: 00000000 | Imm: 10111011 (0xBB)
        {instr_mem[10'd7], instr_mem[10'd6], instr_mem[10'd5], instr_mem[10'd4]} = 32'b00000000_00000010_00000000_10111011;  

        // loadi 3 0x10 (Load memory address 0x10 into r3 to be used by swd/lwd)
        // Opcode: 00000000 | Dest: 00000011 (r3) | Ignore: 00000000 | Imm: 00010000 (0x10)
        {instr_mem[10'd11], instr_mem[10'd10], instr_mem[10'd9], instr_mem[10'd8]} = 32'b00000000_00000011_00000000_00010000;  


        // --- 2. STORE TO MEMORY ---
        // swd 1 3 (Store value from r1 [0xAA] into memory at address held in r3 [0x10])
        // Opcode: 00001010 | Ignore: 00000000 | Src Data: 00000001 (r1) | Addr Reg: 00000011 (r3)
        {instr_mem[10'd15], instr_mem[10'd14], instr_mem[10'd13], instr_mem[10'd12]} = 32'b00001010_00000000_00000001_00000011;  

        // swi 2 0x20 (Store value from r2 [0xBB] directly to memory address 0x20)
        // Opcode: 00001011 | Ignore: 00000000 | Src Data: 00000010 (r2) | Imm Addr: 00100000 (0x20)
        {instr_mem[10'd19], instr_mem[10'd18], instr_mem[10'd17], instr_mem[10'd16]} = 32'b00001011_00000000_00000010_00100000;  


        // --- 3. LOAD FROM MEMORY ---
        // lwd 4 3 (Load memory from address held in r3 [0x10] and store into r4) 
        // Note: r4 will now contain 0xAA
        // Opcode: 00001000 | Dest: 00000100 (r4) | Ignore: 00000000 | Addr Reg: 00000011 (r3)
        {instr_mem[10'd23], instr_mem[10'd22], instr_mem[10'd21], instr_mem[10'd20]} = 32'b00001000_00000100_00000000_00000011;  

        // lwi 5 0x20 (Load memory directly from address 0x20 and store into r5)
        // Note: r5 will now contain 0xBB
        // Opcode: 00001001 | Dest: 00000101 (r5) | Ignore: 00000000 | Imm Addr: 00100000 (0x20)
        {instr_mem[10'd27], instr_mem[10'd26], instr_mem[10'd25], instr_mem[10'd24]} = 32'b00001001_00000101_00000000_00100000;  



        // Loading instruction memory content from generated instr_mem.mem file
        //$readmemb("instr_mem.mem", instr_mem);
    end
    
    /* ----------------------
     CPU INSTANTIATION
    ----------------------
    */
    // Connecting all ports cleanly using named port mapping to avoid position confusion
    cpu mycpu(
        .PC(PC),
        .INSTRUCTION(INSTRUCTION),
        .CLK(CLK),
        .RESET(RESET),
        .BUSYWAIT(busywait),
        .MEM_READ(mem_read),
        .MEM_WRITE(mem_write),
        .MEM_ADDRESS(mem_address),
        .MEM_WRITEDATA(mem_writedata),
        .MEM_READDATA(mem_readdata)
    );

    /* ----------------------
     DATA MEMORY MODULE
    ----------------------
    */
    // Connects directly to the processor memory interface ports
    data_memory my_data_mem(
        .clock(CLK),
        .reset(RESET),
        .read(mem_read),
        .write(mem_write),
        .address(mem_address),
        .writedata(mem_writedata),
        .readdata(mem_readdata),
        .busywait(busywait)
    );

    /* ----------------------
     SIMULATION CONTROL
    ----------------------
    */
    initial
    begin
        // Generate files needed to plot the waveform using GTKWave
        $dumpfile("cpu_wavedata.vcd");
        $dumpvars(0, cpu_tb);
        
        CLK = 1'b0;
        RESET = 1'b0;
        
        // Assert reset signal to clean architecture registers
        #2
        RESET = 1'b1;
        #16 // Extended reset duration to clear memory registers smoothly
        RESET = 1'b0;
        
        // Run the system for 1200 time units to allow for heavy multi-cycle data memory steps
        #1200
        $finish;
    end
    
    // Clock generation loop (Full period of 8 time units)
    always
        #4 CLK = ~CLK;

endmodule