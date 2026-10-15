`timescale 1ns/1ps
module reg_file (
    input [7:0] IN,             // 8-bit data input for writing to the register file
    output reg [7:0] OUT1,      // 8-bit data output from the first read port
    output reg [7:0] OUT2,      // 8-bit data output from the second read port
    input [2:0] INADDRESS,      // 3-bit address for writing to the register file
    input [2:0] OUT1ADDRESS,    // 3-bit address for reading from the first read port
    input [2:0] OUT2ADDRESS,    // 3-bit address for reading from the second read port
    input WRITE,                // Write enable signal
    input CLK,                  // Clock signal for synchronizing write and reset operations
    input RESET                 // Reset signal to clear all registers in the register file
);

    reg [7:0] registers [7:0];  // 8 registers, each 8 bits wide, forming the register file
    integer i;                  // Loop variable
    wire [7:0] R0 = registers[0];
    wire [7:0] R1 = registers[1];
    wire [7:0] R2 = registers[2];
    wire [7:0] R3 = registers[3];
    wire [7:0] R4 = registers[4];
    wire [7:0] R5 = registers[5];
    wire [7:0] R6 = registers[6];
    wire [7:0] R7 = registers[7];


    always @(*) begin
        #2; 
        OUT1 = registers[OUT1ADDRESS];  // Combinational read with a delay of #2
        OUT2 = registers[OUT2ADDRESS];  // Combinational read with a delay of #2
    end

    always @(posedge CLK) begin
        #1; // Artificial write/reset delay
        if (RESET) begin
            for (i = 0; i < 8; i = i + 1) begin //loop every regiter
                registers[i] = 8'b0; // Clear registers to zero
            end
        end else if (WRITE) begin
            registers[INADDRESS] = IN; // Write data into INADDRESS register
        end
    end

endmodule