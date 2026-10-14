module alu_tb;

    // Inputs to the UUT as registers
    reg [7:0] data1;    //declare data1 as 8-bit register
    reg [7:0] data2;    //declare data2 as 8-bit register
    reg [2:0] select;   //declare select as 3-bit register

    // Outputs from the UUT as wires
    wire [7:0] result;  //declare result as 8-bit wire

    // Instantiate the ALU
    alu uut (
        .DATA1(data1),    //connect data1 to the ALU's DATA1 input
        .DATA2(data2),    //connect data2 to the ALU's DATA2 input
        .RESULT(result),  //connect result to the ALU's RESULT output
        .SELECT(select)   //connect select to the ALU's SELECT input
    );

    initial begin
        $dumpfile("waveform.vcd");  //save waveform data as
        $dumpvars(1, alu_tb);

        //TEST 1: FORWARD
        data1 = 8'h0A; data2 = 8'hFF; select = 3'b000;
        #10;    // Wait 10 time units before next change

        //TEST 2: ADD
        data1 = 8'h05; data2 = 8'h03; select = 3'b001;
        #10;    // Wait 10 time units before next change

        //TEST 3: AND
        data1 = 8'b11110000; data2 = 8'b10101010; select = 3'b010;
        #10;    // Wait 10 time units before next change

        //TEST 4: OR
        data1 = 8'b00001111; data2 = 8'b01010101; select = 3'b011;
        #10;    // Wait 10 time units before next change

        $finish;
    end

endmodule