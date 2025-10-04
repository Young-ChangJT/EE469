module DFF(output logic q, input logic d, input logic clk);
    always_ff @(posedge clk) begin
        q <= d;
    end
endmodule

module reg64(output logic [63:0] q, input logic [63:0] d, input logic clk, input logic enable);
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin : bit_dffs
            logic din;
            // Enable gating: q retains old value if !enable, else captures d
            assign din = (enable & d[i]) | (~enable & q[i]);
            DFF dff_inst(.q(q[i]), .d(din), .clk(clk));
        end
    endgenerate
endmodule

module decoder5to32(output logic [31:0] out, input logic [4:0] in);
    always_comb begin
        out = 32'b0;
        out[in] = 1'b1;
    end
endmodule

module mux32to1_64(output logic [63:0] out, input logic [31:0] sel, input logic [63:0] inputs [31:0]);
    integer i;
    always_comb begin
        out = 64'b0;
        for (i = 0; i < 32; i = i + 1) begin
            if (sel[i])
                out = inputs[i];
        end
    end
endmodule

module regfile(
    output logic [63:0] ReadData1,
    output logic [63:0] ReadData2,
    input logic [63:0] WriteData,
    input logic [4:0] ReadRegister1,
    input logic [4:0] ReadRegister2,
    input logic [4:0] WriteRegister,
    input logic RegWrite,
    input logic clk
);
    // Internal register array
    logic [63:0] registers [31:0];

    // Generate write enable signals by decoder
    logic [31:0] write_enable;
    decoder5to32 dec(.out(write_enable), .in(WriteRegister));

    // Disable write enable for register 31 (hardwired zero)
    // assign write_enable[31] = 1'b0;

    // Write operation: write enable gated by RegWrite
    // logic [31:0] gated_write_enable;
    // genvar j;
    // generate
    //     for (j = 0; j < 32; j = j + 1) begin
    //         assign gated_write_enable[j] = RegWrite & write_enable[j];
    //     end
    // endgenerate

    // Instantiate 32 registers of 64 bits each
    genvar k;
    generate
        for (k = 0; k < 31; k = k + 1) begin : regs
            reg64 r(.q(registers[k]), .d(WriteData), .clk(clk), .enable(RegWrite & write_enable[k]));
        end
    endgenerate

    // register 31 hardwired to zero
    assign registers[31] = 64'b0;

    // Read ports: 2 x 32-to-1 muxes
    logic [31:0] read_sel1, read_sel2;
    decoder5to32 read_dec1(.out(read_sel1), .in(ReadRegister1));
    decoder5to32 read_dec2(.out(read_sel2), .in(ReadRegister2));

    mux32to1_64 mux1(.out(ReadData1), .sel(read_sel1), .inputs(registers));
    mux32to1_64 mux2(.out(ReadData2), .sel(read_sel2), .inputs(registers));

endmodule
