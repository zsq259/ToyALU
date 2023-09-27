module CarryLookaheadAdder(
        input wire[3:0] a,
        input wire[3:0] b,
        input wire c0,
        output wire[3:0] S,
        output wire carry
    );
    wire[3:0] c;
    wire[3:0] G = a & b;
    wire[3:0] P = a ^ b;
    assign c[0] = c0;
    assign S = P ^ c;

    assign c[1] = G[0] | (c[0] & P[0]);
    assign c[2] = G[1] | (P[1] & G[0]) | (c[0] & P[0] & P[1]);
    assign c[3] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (c[0] & P[0] & P[1] & P[2]);
    assign carry = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) | (c[0] & P[0] & P[1] & P[2] & P[3]);
endmodule

module adder(
        input wire[15:0] a,
        input wire[15:0] b,
        input wire c0,
        output wire[15:0] S,
        output wire carry
    );    
    wire[3:1] c;    
    
    CarryLookaheadAdder subAdder0(a[3:0], b[3:0], c0, S[3:0], c[1]);
    CarryLookaheadAdder subAdder1(a[7:4], b[7:4], c[1], S[7:4], c[2]);
    CarryLookaheadAdder subAdder2(a[11:8], b[11:8], c[2], S[11:8], c[3]);
    CarryLookaheadAdder subAdder3(a[15:12], b[15:12], c[3], S[15:12], carry);
endmodule

module adder32(
        input wire[31:0] a,
        input wire[31:0] b,
        input wire c0,
        output wire[31:0] S,
        output wire carry
    );    
    wire[3:1] c;
    
    adder subAdder0(a[15:0], b[15:0], c0, S[15:0], c[1]);
    adder subAdder1(a[31:16], b[31:16], c[1], S[31:16], carry);
    
endmodule


module Add(
        input wire[31:0] a,
        input wire[31:0] b,
        output reg[31:0] sum
    );
    wire zero = 0;    
    wire[31:0] ret;
    adder32 adder(a, b, zero, ret, null);
    always @* begin
        sum <= ret;
    end
endmodule