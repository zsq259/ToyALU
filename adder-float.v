module float_adder(
    input   clk,
    input   st,
    input   [31:0]  x,
    input   [31:0]  y,
    output  reg [31:0]  sum,
    output  reg [1:0]   overflow//2'b00:没有溢出    2'b01:上溢  2'b10:下溢  2'b11:输入不是规格数
);
    reg [24:0]  m_x, m_y, m_sum;
    reg [7:0]   exp_x, exp_y, exp_sum;
    reg [2:0]   state_now, state_next;
    reg sign_x, sign_y, sign_sum;

    reg [24:0] out_x, out_y, mid_y, mid_x; //out: 舍弃的尾数, mid: 用于判断舍弃的尾数是否大于0.5
    reg [7:0]  move_tot;
    reg [2:0]  bigger;

    parameter start = 3'b000, zerocheck = 3'b001, equalcheck = 3'b010, addm = 3'b011, normal = 3'b100, over = 3'b110;

    always @(posedge clk) begin
        if (!st) begin
            state_now <= start;
        end
        else begin
            state_now <= state_next;
        end
    end

    always @(state_now, state_next, exp_x, exp_y, exp_sum, m_x, m_y, m_sum, out_x, out_y, mid_x, mid_y) begin
        case(state_now)
            start: begin
                exp_x <= x[30:23];
                exp_y <= y[30:23];
                m_x <= {2'b01, x[22:0]};
                m_y <= {2'b01, y[22:0]};
                //以下为对齐用到的变量
                mid_y<={24'b0, 1'b1};
                mid_x<={24'b0, 1'b1};
                move_tot <= 8'b0;
                out_x <= 25'b0;
                out_y <= 25'b0;
                bigger <= 2'b00;
                if ((exp_x == 8'd255 && m_x[22:0] != 0) || (exp_y == 8'd255 && m_y[22:0] != 0)) begin //NaN
                    overflow <= 2'b11;
                    state_next <= 3'b101;
                    sign_sum <= 1'b1;
                    exp_sum <= 8'd255;
                    m_sum <= 23'b11111111111111111111111;
                end
                else if ((exp_x == 8'd255 && m_x[22:0] == 0) || (exp_y == 8'd255 && m_y[22:0] == 0)) begin //无穷大
                    overflow <= 2'b11;
                    state_next <= 3'b101;
                    sign_sum <= 1'b0;
                    exp_sum <= 8'd255;
                    m_sum <= 23'b0;
                end
                else begin
                    overflow <= 2'b00;
                    state_next <= zerocheck;
                end
            end
            zerocheck: begin                
                if (m_x[22:0] == 23'b0 && exp_x == 8'b0) begin
                    sign_sum <= y[31];
                    exp_sum <= exp_y;
                    m_sum <= m_y;
                    state_next <= over;
                end
                else if (m_y[22:0] == 23'b0 && exp_y == 8'b0) begin
                    sign_sum <= x[31];
                    exp_sum <= exp_x;
                    m_sum <= m_x;
                    state_next <= over;
                end
                else begin
                    state_next <= equalcheck;
                end
                //以下为非规格化数字的处理，需要把预装填的1清除
                if (m_x[22:0] != 23'b0 && exp_x == 8'b0) begin
                    m_x <= {2'b0, x[22:0]};
                end
                if (m_y[22:0] != 23'b0 && exp_y == 8'b0) begin
                    m_y <= {2'b0, y[22:0]};
                end
            end
            equalcheck: begin
                if (exp_x == exp_y) begin
                    if (bigger == 2'b0) begin
                        state_next <= addm;//指数对齐，进入尾数相加阶段
                    end
                    else if (bigger == 2'b10) begin
                        if (out_y > mid_y) begin
                            m_y <= m_y + 1'b1;
                        end 
                        else if (out_y < mid_y) begin
                            m_y <= m_y;
                        end
                        else if (out_y == m_y) begin
                            if (m_y[0] == 0) begin
                                m_y <= m_y + 1'b1;
                            end
                            else begin
                                m_y <= m_y;
                            end
                        end
                        state_next <= addm;
                    end
                    else if (bigger == 2'b01) begin
                        if (out_x > mid_x) begin
                            m_x <= m_x + 1'b1;
                        end 
                        else if (out_x < mid_x) begin
                            m_x <= m_x;
                        end
                        else if (out_x == m_x) begin
                            if (m_x[0] == 0) begin
                                m_x <= m_x + 1'b1;
                            end
                            else begin
                                m_x <= m_x;
                            end
                        end
                        state_next <= addm;
                    end
                end
                else begin
                    if (exp_x > exp_y) begin
                        bigger <= 2'b01;
                        exp_y <= exp_y + 1;
                        m_y[23:0] <= {1'b0, m_y[23:1]};
                        out_y[move_tot] <= m_y[0];
                        mid_y = {mid_y[23:0], mid_y[24]};
                        move_tot <= move_tot + 1'b1;
                        if (m_y == 24'b0) begin //指数相差太大，导致尾数全为0 
                            sign_sum <= sign_x;
                            exp_sum <= exp_x;
                            m_sum <= m_x;
                            state_next <= over;
                        end
                        else begin
                            state_next <= equalcheck;
                        end
                    end 
                    else begin
                        bigger <= 2'b10;
                        exp_x <= exp_x + 1;
                        m_x[23:0] <= {1'b0, m_x[23:1]};
                        out_x[move_tot] <= m_x[0];
                        mid_x = {mid_x[23:0], mid_x[24]};
                        move_tot <= move_tot + 1'b1;
                        if (m_x == 24'b0) begin //指数相差太大，导致尾数全为0 
                            sign_sum <= sign_y;
                            exp_sum <= exp_y;
                            m_sum <= m_y;
                            state_next <= over;
                        end
                        else begin
                            state_next <= equalcheck;
                        end
                    end
                end
            end
            addm: begin
                if (x[31] ^ y[31] == 1'b0) begin
                    exp_sum <= exp_x;
                    sign_sum <= x[31];
                    m_sum <= m_x + m_y;
                    state_next <= normal;
                end 
                else begin
                    if (m_x > m_y) begin
                        exp_sum <= exp_x;
                        sign_sum <= x[31];
                        m_sum <= m_x - m_y;
                        state_next <= normal;
                    end
                    else if (m_x < m_y) begin
                        exp_sum <= exp_y;
                        sign_sum <= y[31];
                        m_sum <= m_y - m_x;
                        state_next <= normal;
                    end
                    else begin
                        exp_sum <= exp_x;
                        m_sum <= 23'b0;
                        state_next <= over;
                    end
                end
            end
            
            normal: begin
                if (m_sum[24] == 1'b1) begin
                    if (m_sum[0] == 1) begin
                        m_sum <= m_sum + 1'b1;
                        m_sum[0] <= 0;
                        state_next <= normal;
                    end
                    else begin
                        m_sum <= {1'b0, m_sum[24:1]};
                        exp_sum <= exp_sum + 1'b1;
                        state_next <= over;
                    end
                end 
                else begin
                    if (m_sum[23] == 1'b0 && exp_sum >= 1) begin
                        m_sum <= {m_sum[23:1], 1'b0};
                        exp_sum <= exp_sum - 1'b1;
                        state_next <= normal;
                    end 
                    else begin
                        state_next <= over;
                    end
                end
            end
            over: begin
                sum = {sign_sum, exp_sum[7:0], m_sum[22:0]};
                if (overflow) begin
                    overflow <= overflow;
                    // state_next <= start;
                end
                else if (exp_sum == 8'd255) begin
                    overflow <= 2'b01;
                    // state_next <= start;
                end
                else if (exp_sum == 8'd0 && m_sum[22:0] != 23'b0) begin
                    overflow <= 2'b10;
                    // state_next <= start;
                end
                else begin
                    overflow <= 2'b0;
                    // state_next <= start;
                end
            end
        endcase
    end
endmodule
