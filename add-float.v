`include "adder-float.v"

module top_module();
    reg            clk = 0;
    reg             st = 0;
    always #1 clk = ~clk;

    reg     [31:0]      in0;
    reg     [31:0]      in1;
    wire    [31:0]      sum;
    wire    [1:0]   overflow;
    

    initial begin
        assign in0 = 32'b01000010011010101000000000000000;
        assign in1 = 32'b01000010011010101000000000000000;    
        #2 st = 1;
        #3000 $finish;
        
    end

    float_adder a(
        .clk        (clk),
        .st         (st),
        .x          (in0),
        .y          (in1),
        .sum        (sum),
        .overflow   (overflow)
    );

    always @(*) begin
        $display("%b", sum);
    end
endmodule