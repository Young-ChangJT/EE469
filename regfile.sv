`timescale 1ns/10ps

module and2 (output y, input a, b);
    assign #50 y = a & b;
endmodule

module and4(output out, input in0, in1, in2, in3);
    wire t0, t1;
    and2 a0(.y(t0), .a(in0), .b(in1));
    and2 a1(.y(t1), .a(in2), .b(in3));
    and2 a2(.y(out), .a(t0), .b(t1));
endmodule

module or2 (output y, input a, b);
    assign #50 y = a | b;
endmodule

module or4(output out, input in0, in1, in2, in3);
    wire t0, t1;
    or2 o0(.y(t0), .a(in0), .b(in1));
    or2 o1(.y(t1), .a(in2), .b(in3));
    or2 o2(.y(out), .a(t0), .b(t1));
endmodule

module not1 (output y, input a);
    assign #50 y = ~a;
endmodule

module D_FF (q, d, reset, clk);
    output reg q;
    input d, reset, clk;
    always_ff @(posedge clk)
        if (reset)
            q <= 0;
        else
            q <= d;
endmodule

// 單一 bit 可寫入暫存器（用 gate 實現 enable gating）
module reg1(output q, input d, input clk, input reset, input enable);
    wire d_gated, not_en, old_q, d_new;
    not1 n1(.y(not_en), .a(enable));
    and2 a1(.y(d_gated), .a(enable), .b(d));
    and2 a2(.y(old_q), .a(not_en), .b(q));
    or2  o1(.y(d_new), .a(d_gated), .b(old_q));
    D_FF dff1(.q(q), .d(d_new), .reset(reset), .clk(clk));
endmodule

// 64 bit register
module reg64(output [63:0] q, input [63:0] d, input clk, input reset, input enable);
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin : bits
            reg1 r(.q(q[i]), .d(d[i]), .clk(clk), .reset(reset), .enable(enable));
        end
    endgenerate
endmodule

// 5-to-32 decoder（完全用 and2/and4/not1 結構化）
module decoder5to32(output [31:0] out, input [4:0] in);
    wire n0, n1, n2, n3, n4;
    not1 not0(.y(n0), .a(in[0]));
    not1 not1(.y(n1), .a(in[1]));
    not1 not2(.y(n2), .a(in[2]));
    not1 not3(.y(n3), .a(in[3]));
    not1 not4(.y(n4), .a(in[4]));

    // out[0] = n4 & n3 & n2 & n1 & n0
    wire tmp0;
    and4 a0(.out(tmp0), .in0(n4), .in1(n3), .in2(n2), .in3(n1));
    and2 a1(.y(out[0]), .a(tmp0), .b(n0));

    // out[1] = n4 & n3 & n2 & n1 & in[0]
    wire tmp1;
    and4 a2(.out(tmp1), .in0(n4), .in1(n3), .in2(n2), .in3(n1));
    and2 a3(.y(out[1]), .a(tmp1), .b(in[0]));

    // out[2] = n4 & n3 & n2 & in[1] & n0
    wire tmp2;
    and4 a4(.out(tmp2), .in0(n4), .in1(n3), .in2(n2), .in3(in[1]));
    and2 a5(.y(out[2]), .a(tmp2), .b(n0));

    // out[3] = n4 & n3 & n2 & in[1] & in[0]
    wire tmp3;
    and4 a6(.out(tmp3), .in0(n4), .in1(n3), .in2(n2), .in3(in[1]));
    and2 a7(.y(out[3]), .a(tmp3), .b(in[0]));

    // out[4] = n4 & n3 & in[2] & n1 & n0
    wire tmp4;
    and4 a8(.out(tmp4), .in0(n4), .in1(n3), .in2(in[2]), .in3(n1));
    and2 a9(.y(out[4]), .a(tmp4), .b(n0));

    // out[5] = n4 & n3 & in[2] & n1 & in[0]
    wire tmp5;
    and4 a10(.out(tmp5), .in0(n4), .in1(n3), .in2(in[2]), .in3(n1));
    and2 a11(.y(out[5]), .a(tmp5), .b(in[0]));

    // out[6] = n4 & n3 & in[2] & in[1] & n0
    wire tmp6;
    and4 a12(.out(tmp6), .in0(n4), .in1(n3), .in2(in[2]), .in3(in[1]));
    and2 a13(.y(out[6]), .a(tmp6), .b(n0));

    // out[7] = n4 & n3 & in[2] & in[1] & in[0]
    wire tmp7;
    and4 a14(.out(tmp7), .in0(n4), .in1(n3), .in2(in[2]), .in3(in[1]));
    and2 a15(.y(out[7]), .a(tmp7), .b(in[0]));

    // out[8] = n4 & in[3] & n2 & n1 & n0
    wire tmp8;
    and4 a16(.out(tmp8), .in0(n4), .in1(in[3]), .in2(n2), .in3(n1));
    and2 a17(.y(out[8]), .a(tmp8), .b(n0));

    // out[9] = n4 & in[3] & n2 & n1 & in[0]
    wire tmp9;
    and4 a18(.out(tmp9), .in0(n4), .in1(in[3]), .in2(n2), .in3(n1));
    and2 a19(.y(out[9]), .a(tmp9), .b(in[0]));

    // out[10] = n4 & in[3] & n2 & in[1] & n0
    wire tmp10;
    and4 a20(.out(tmp10), .in0(n4), .in1(in[3]), .in2(n2), .in3(in[1]));
    and2 a21(.y(out[10]), .a(tmp10), .b(n0));

    // out[11] = n4 & in[3] & n2 & in[1] & in[0]
    wire tmp11;
    and4 a22(.out(tmp11), .in0(n4), .in1(in[3]), .in2(n2), .in3(in[1]));
    and2 a23(.y(out[11]), .a(tmp11), .b(in[0]));

    // out[12] = n4 & in[3] & in[2] & n1 & n0
    wire tmp12;
    and4 a24(.out(tmp12), .in0(n4), .in1(in[3]), .in2(in[2]), .in3(n1));
    and2 a25(.y(out[12]), .a(tmp12), .b(n0));

    // out[13] = n4 & in[3] & in[2] & n1 & in[0]
    wire tmp13;
    and4 a26(.out(tmp13), .in0(n4), .in1(in[3]), .in2(in[2]), .in3(n1));
    and2 a27(.y(out[13]), .a(tmp13), .b(in[0]));

    // out[14] = n4 & in[3] & in[2] & in[1] & n0
    wire tmp14;
    and4 a28(.out(tmp14), .in0(n4), .in1(in[3]), .in2(in[2]), .in3(in[1]));
    and2 a29(.y(out[14]), .a(tmp14), .b(n0));

    // out[15] = n4 & in[3] & in[2] & in[1] & in[0]
    wire tmp15;
    and4 a30(.out(tmp15), .in0(n4), .in1(in[3]), .in2(in[2]), .in3(in[1]));
    and2 a31(.y(out[15]), .a(tmp15), .b(in[0]));

    // out[16] = in[4] & n3 & n2 & n1 & n0
    wire tmp16;
    and4 a32(.out(tmp16), .in0(in[4]), .in1(n3), .in2(n2), .in3(n1));
    and2 a33(.y(out[16]), .a(tmp16), .b(n0));

    // out[17] = in[4] & n3 & n2 & n1 & in[0]
    wire tmp17;
    and4 a34(.out(tmp17), .in0(in[4]), .in1(n3), .in2(n2), .in3(n1));
    and2 a35(.y(out[17]), .a(tmp17), .b(in[0]));

    // out[18] = in[4] & n3 & n2 & in[1] & n0
    wire tmp18;
    and4 a36(.out(tmp18), .in0(in[4]), .in1(n3), .in2(n2), .in3(in[1]));
    and2 a37(.y(out[18]), .a(tmp18), .b(n0));

    // out[19] = in[4] & n3 & n2 & in[1] & in[0]
    wire tmp19;
    and4 a38(.out(tmp19), .in0(in[4]), .in1(n3), .in2(n2), .in3(in[1]));
    and2 a39(.y(out[19]), .a(tmp19), .b(in[0]));

    // out[20] = in[4] & n3 & in[2] & n1 & n0
    wire tmp20;
    and4 a40(.out(tmp20), .in0(in[4]), .in1(n3), .in2(in[2]), .in3(n1));
    and2 a41(.y(out[20]), .a(tmp20), .b(n0));

    // out[21] = in[4] & n3 & in[2] & n1 & in[0]
    wire tmp21;
    and4 a42(.out(tmp21), .in0(in[4]), .in1(n3), .in2(in[2]), .in3(n1));
    and2 a43(.y(out[21]), .a(tmp21), .b(in[0]));

    // out[22] = in[4] & n3 & in[2] & in[1] & n0
    wire tmp22;
    and4 a44(.out(tmp22), .in0(in[4]), .in1(n3), .in2(in[2]), .in3(in[1]));
    and2 a45(.y(out[22]), .a(tmp22), .b(n0));

    // out[23] = in[4] & n3 & in[2] & in[1] & in[0]
    wire tmp23;
    and4 a46(.out(tmp23), .in0(in[4]), .in1(n3), .in2(in[2]), .in3(in[1]));
    and2 a47(.y(out[23]), .a(tmp23), .b(in[0]));

    // out[24] = in[4] & in[3] & n2 & n1 & n0
    wire tmp24;
    and4 a48(.out(tmp24), .in0(in[4]), .in1(in[3]), .in2(n2), .in3(n1));
    and2 a49(.y(out[24]), .a(tmp24), .b(n0));

    // out[25] = in[4] & in[3] & n2 & n1 & in[0]
    wire tmp25;
    and4 a50(.out(tmp25), .in0(in[4]), .in1(in[3]), .in2(n2), .in3(n1));
    and2 a51(.y(out[25]), .a(tmp25), .b(in[0]));

    // out[26] = in[4] & in[3] & n2 & in[1] & n0
    wire tmp26;
    and4 a52(.out(tmp26), .in0(in[4]), .in1(in[3]), .in2(n2), .in3(in[1]));
    and2 a53(.y(out[26]), .a(tmp26), .b(n0));

    // out[27] = in[4] & in[3] & n2 & in[1] & in[0]
    wire tmp27;
    and4 a54(.out(tmp27), .in0(in[4]), .in1(in[3]), .in2(n2), .in3(in[1]));
    and2 a55(.y(out[27]), .a(tmp27), .b(in[0]));

    // out[28] = in[4] & in[3] & in[2] & n1 & n0
    wire tmp28;
    and4 a56(.out(tmp28), .in0(in[4]), .in1(in[3]), .in2(in[2]), .in3(n1));
    and2 a57(.y(out[28]), .a(tmp28), .b(n0));

    // out[29] = in[4] & in[3] & in[2] & n1 & in[0]
    wire tmp29;
    and4 a58(.out(tmp29), .in0(in[4]), .in1(in[3]), .in2(in[2]), .in3(n1));
    and2 a59(.y(out[29]), .a(tmp29), .b(in[0]));

    // out[30] = in[4] & in[3] & in[2] & in[1] & n0
    wire tmp30;
    and4 a60(.out(tmp30), .in0(in[4]), .in1(in[3]), .in2(in[2]), .in3(in[1]));
    and2 a61(.y(out[30]), .a(tmp30), .b(n0));

    // out[31] = in[4] & in[3] & in[2] & in[1] & in[0]
    wire tmp31;
    and4 a62(.out(tmp31), .in0(in[4]), .in1(in[3]), .in2(in[2]), .in3(in[1]));
    and2 a63(.y(out[31]), .a(tmp31), .b(n0));
endmodule

// 32-to-1 mux, 64 bit（用 and2/or2/or4 結構化）
module mux32to1_64(output [63:0] out, input [31:0] sel, input [63:0] inputs [31:0]);
    genvar i, j;
    generate
        for (i = 0; i < 64; i = i + 1) begin : bits
            wire [31:0] and_out;
            for (j = 0; j < 32; j = j + 1) begin : mux
                and2 a(.y(and_out[j]), .a(sel[j]), .b(inputs[j][i]));
            end
            // 32-input OR tree using or4
            wire [7:0] or4_out;
            for (j = 0; j < 8; j = j + 1) begin : or4_group
                or4 or4_inst(.out(or4_out[j]), .in0(and_out[j*4]), .in1(and_out[j*4+1]), .in2(and_out[j*4+2]), .in3(and_out[j*4+3]));
            end
            wire [1:0] or4_out2;
            or4 or4_inst0(.out(or4_out2[0]), .in0(or4_out[0]), .in1(or4_out[1]), .in2(or4_out[2]), .in3(or4_out[3]));
            or4 or4_inst1(.out(or4_out2[1]), .in0(or4_out[4]), .in1(or4_out[5]), .in2(or4_out[6]), .in3(or4_out[7]));
            or2 or2_inst(.y(out[i]), .a(or4_out2[0]), .b(or4_out2[1]));
        end
    endgenerate
endmodule

// regfile
module regfile(
    output [63:0] ReadData1,
    output [63:0] ReadData2,
    input [63:0] WriteData,
    input [4:0] ReadRegister1,
    input [4:0] ReadRegister2,
    input [4:0] WriteRegister,
    input RegWrite,
    // input reset,
    input clk
);
    wire [63:0] registers [31:0];
    wire [31:0] write_enable, read_sel1, read_sel2;
    decoder5to32 dec(.out(write_enable), .in(WriteRegister));
    decoder5to32 read_dec1(.out(read_sel1), .in(ReadRegister1));
    decoder5to32 read_dec2(.out(read_sel2), .in(ReadRegister2));
    genvar k;
    generate
        for (k = 0; k < 31; k = k + 1) begin : regs
            reg64 r(.q(registers[k]), .d(WriteData), .clk(clk), .reset(1'b0), .enable(RegWrite & write_enable[k]));
        end
    endgenerate
    assign registers[31] = 64'b0;
    mux32to1_64 mux1(.out(ReadData1), .sel(read_sel1), .inputs(registers));
    mux32to1_64 mux2(.out(ReadData2), .sel(read_sel2), .inputs(registers));
endmodule