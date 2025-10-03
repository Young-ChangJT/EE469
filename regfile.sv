module regfile (
    output logic [63:0] ReadData1,
    output logic [63:0] ReadData2,
    input logic [63:0] WriteData,
    input logic [4:0] ReadRegister1,
    input logic [4:0] ReadRegister2,
    input logic [4:0] WriteRegister,
    input logic RegWrite,
    input logic clk
);

    // 32 x 64-bit register array
    logic [63:0] registers [31:0];

    // Write operation - on posedge clk
    always_ff @(posedge clk) begin
        if (RegWrite && (WriteRegister != 31)) begin
            registers[WriteRegister] <= WriteData;
        end
        // Always keep register 31 as zero
        registers[31] <= 64'd0;
    end

    // Read operation - combinational
    assign ReadData1 = registers[ReadRegister1];
    assign ReadData2 = registers[ReadRegister2];
endmodule
