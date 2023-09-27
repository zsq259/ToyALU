module CarryLookaheadAdder(
        input wire[7:0] a,
        input wire[7:0] b,
        input wire c0,
        output wire[7:0] S,
        output wire carry
    );
    wire[7:0] c;
    wire[7:0] G = a & b;
    wire[7:0] P = a ^ b;
    assign c[0] = c0;
    assign S = P ^ c;

    assign c[1] = G[0] | (c[0] & P[0]);
    assign c[2] = G[1] | (P[1] & G[0]) | (c[0] & P[0] & P[1]);
    assign c[3] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (c[0] & P[0] & P[1] & P[2]);
    assign c[4] = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) | (c[0] & P[0] & P[1] & P[2] & P[3]);
    assign c[5] = G[4] | (P[4] & G[3]) | (P[4] & P[3] & G[2]) | (P[4] & P[3] & P[2] & G[1]) | (P[4] & P[3] & P[2] & P[1] & G[0]) | (c[0] & P[0] & P[1] & P[2] & P[3] & P[4]);
    assign c[6] = G[5] | (P[5] & G[4]) | (P[5] & P[4] & G[3]) | (P[5] & P[4] & P[3] & G[2]) | (P[5] & P[4] & P[3] & P[2] & G[1]) | (P[5] & P[4] & P[3] & P[2] & P[1] & G[0]) | (c[0] & P[0] & P[1] & P[2] & P[3] & P[4] & P[5]);
    assign c[7] = G[6] | (P[6] & G[5]) | (P[6] & P[5] & G[4]) | (P[6] & P[5] & P[4] & G[3]) | (P[6] & P[5] & P[4] & P[3] & G[2]) | (P[6] & P[5] & P[4] & P[3] & P[2] & G[1]) | (P[6] & P[5] & P[4] & P[3] & P[2] & P[1] & G[0]) | (c[0] & P[0] & P[1] & P[2] & P[3] & P[4] & P[5] & P[6]);
    assign carry = G[7] | (P[7] & G[6]) | (P[7] & P[6] & G[5]) | (P[7] & P[6] & P[5] & G[4]) | (P[7] & P[6] & P[5] & P[4] & G[3]) | (P[7] & P[6] & P[5] & P[4] & P[3] & G[2]) | (P[7] & P[6] & P[5] & P[4] & P[3] & P[2] & G[1]) | (P[7] & P[6] & P[5] & P[4] & P[3] & P[2] & P[1] & G[0]) | (c[0] & P[0] & P[1] & P[2] & P[3] & P[4] & P[5] & P[6] & P[7]);
    
endmodule

module adder(
        input wire[31:0] a,
        input wire[31:0] b,
        input wire c0,
        output wire[31:0] S,
        output wire carry
    );    
    wire[3:1] c;    
    
    CarryLookaheadAdder subAdder0(a[7:0], b[7:0], c0, S[7:0], c[1]);
    CarryLookaheadAdder subAdder1(a[15:8], b[15:8], c[1], S[15:8], c[2]);
    CarryLookaheadAdder subAdder2(a[23:16], b[23:16], c[2], S[23:16], c[3]);
    CarryLookaheadAdder subAdder3(a[31:24], b[31:24], c[3], S[31:24], carry);
    

endmodule

module Add(
        input wire[31:0] a,
        input wire[31:0] b,
        output reg[31:0] sum
    );
    wire zero = 0;    
    wire[31:0] ret;
    adder adder(a, b, zero, ret, null);
    always @* begin
        sum <= ret;
    end
endmodule