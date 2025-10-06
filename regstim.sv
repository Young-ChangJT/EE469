// Test bench for Register file
`timescale 1ns/10ps

module regstim(); 		

	parameter ClockDelay = 5000;

	logic	[4:0] 	ReadRegister1, ReadRegister2, WriteRegister;
	logic [63:0]	WriteData;
	logic 			RegWrite, clk;
	logic [63:0]	ReadData1, ReadData2;

	integer i;

	// Your register file MUST be named "regfile".
	// Also you must make sure that the port declarations
	// match up with the module instance in this stimulus file.
	regfile dut (.ReadData1, .ReadData2, .WriteData, 
					 .ReadRegister1, .ReadRegister2, .WriteRegister,
					 .RegWrite, .clk);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end

	initial begin
		// $dumpfile("reg.vcd");
        // $dumpvars(0, regstim);
		// Try to write the value 0xA0 into register 31.
		// Register 31 should always be at the value of 0.
		RegWrite <= 5'd0;
		ReadRegister1 <= 5'd0;
		ReadRegister2 <= 5'd0;
		WriteRegister <= 5'd31;
		WriteData <= 64'h00000000000000A0;
		@(posedge clk);
		
		$display("%t Attempting overwrite of register 31, which should always be 0", $time);
		RegWrite <= 1;
		@(posedge clk);

		// Write a value into each  register.
		$display("%t Writing pattern to all registers.", $time);
		for (i=0; i<31; i=i+1) begin
			RegWrite <= 0;
			ReadRegister1 <= i-1;
			ReadRegister2 <= i;
			WriteRegister <= i;
			WriteData <= i*64'h0000010204080001;
			@(posedge clk);
			
			RegWrite <= 1;
			@(posedge clk);
		end

		// Go back and verify that the registers
		// retained the data.
		$display("%t Checking pattern.", $time);
		for (i=0; i<32; i=i+1) begin
			RegWrite <= 0;
			ReadRegister1 <= i-1;
			ReadRegister2 <= i;
			WriteRegister <= i;
			WriteData <= i*64'h0000000000000100+i;
			@(posedge clk);
		end
		$display("%t Check complete.", $time);

		// read/write register 5 in the same time
		$display("%t read/write register 5 in the same time", $time);
		RegWrite <= 1;
		WriteRegister <= 5'd5;
		WriteData <= 64'h123456789ABCDEF0;
		ReadRegister1 <= 5'd5;
		@(posedge clk);
		RegWrite <= 0;
		@(posedge clk);
		$display("Register 5 after write = %h (should be 123456789ABCDEF0)", ReadData1);

		// write same register in two consecutive cycles
		$display("%t write same register in two consecutive cycles", $time);
		RegWrite <= 1;
		WriteRegister <= 5'd10;
		WriteData <= 64'h1111111111111111;
		@(posedge clk);
		WriteData <= 64'h2222222222222222;
		@(posedge clk);
		RegWrite <= 0;
		ReadRegister1 <= 5'd10;
		@(posedge clk);
		$display("Register 10 = %h (should be 2222222222222222)", ReadData1);

		$stop;
	end
endmodule
