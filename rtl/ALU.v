`timescale 1ns/1ps
module forward_unit (
    input [7:0] DATA2,      //declare DATA2 as 8-bit input
    output reg [7:0] RESULT //declare RESULT as 8-bit register
);
    always @(*) begin
        #1 RESULT = DATA2;  // Delay of 1 time unit
    end
endmodule

module add_unit (
    input [7:0] DATA1, input [7:0] DATA2,   //declare DATA1 and DATA2 as 8-bit inputs
    output reg [7:0] RESULT //declare RESULT as 8-bit register
);
    always @(*) begin
        #2 RESULT = DATA1 + DATA2; // Delay of 2 time units
    end
endmodule

module and_unit (
    input [7:0] DATA1, input [7:0] DATA2,   //declare DATA1 and DATA2 as 8-bit inputs
    output reg [7:0] RESULT         //declare RESULT as 8-bit register
);
    always @(*) begin
        #1 RESULT = DATA1 & DATA2; // Delay of 1 time unit
    end
endmodule

module or_unit (
    input [7:0] DATA1, input [7:0] DATA2,   //declare DATA1 and DATA2 as 8-bit inputs
    output reg [7:0] RESULT     //declare RESULT as 8-bit register
);
    always @(*) begin
        #1 RESULT = DATA1 | DATA2; // Delay of 1 time unit
    end
endmodule

//ALU Module
module alu (
    input [7:0] DATA1,      //declare DATA1 as 8-bit input
    input [7:0] DATA2,      //declare DATA2 as 8-bit input
    output reg [7:0] RESULT, //declare RESULT as 8-bit register
    input [2:0] SELECT      //declare SELECT as 3-bit input
);

    // Internal connection wires 
    wire [7:0] w_forward, w_add, w_and, w_or;   //declare internal wires for sub-unit outputs

    // Instantiate sub-units 
    forward_unit u1 (DATA2, w_forward);     //connect DATA2 to forward_unit's input and w_forward to its output
    add_unit     u2 (DATA1, DATA2, w_add); //connect DATA1 and DATA2 to add_unit's inputs and w_add to its output
    and_unit     u3 (DATA1, DATA2, w_and); //connect DATA1 and DATA2 to and_unit's inputs and w_and to its output
    or_unit      u4 (DATA1, DATA2, w_or);  //connect DATA1 and DATA2 to or_unit's inputs and w_or to its output

    always @(*) begin
        case (SELECT)
            3'b000:  RESULT = w_forward; // For loadi, mov
            3'b001:  RESULT = w_add;     // For add, sub
            3'b010:  RESULT = w_and;     // For and
            3'b011:  RESULT = w_or;      // For or
            default: RESULT = 8'b00000000; // Unused bits
        endcase
    end

endmodule