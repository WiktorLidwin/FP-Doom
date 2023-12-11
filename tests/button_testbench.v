`timescale 1ns / 1ps
module button_testbench;
	reg clk;
	reg btnA, btnB, btnC;
	wire rotateN90, forward, rotate90;

	// instantiate button
	buttons_driver Buttons(
		.A(btnA),
		.B(btnB),
		.C(btnC),
		.rotateN90_press(rotateN90),
		.forward_press(forward),
		.rotate90_press(rotate90)
	);

	// generate clock
	initial begin
	    clk = 1'b0; // Initialize clk to a specific value
    	    forever #5 clk = ~clk;
	end
	//always #5 clk = ~clk;

	//buttons
	initial begin
		clk = 0;
		btnA = 0;
		btnB = 0;
		btnC = 0;

		$display("Initial state - A:%b, B:%b, C:%b", btnA, btnB, btnC);
		$display("Outputs - turn N90:%b, forward:%b, turn 90:%b", rotateN90, forward, rotate90);
		//simualte
		#10 btnA = 1;

		$display("A pressed - A:%b, B:%b, C:%b", btnA, btnB, btnC);
		$display("Outputs - turn N90:%b, forward:%b, turn 90:%b", rotateN90, forward, rotate90);

		#10 btnB = 1;

		$display("B pressed, both active - A:%b, B:%b, C:%b", btnA, btnB, btnC);
		$display("Outputs - turn N90:%b, forward:%b, turn 90:%b", rotateN90, forward, rotate90);

		#10 btnA = 0;

		$display("B only - A:%b, B:%b, C:%b", btnA, btnB, btnC);
		$display("Outputs - turn N90:%b, forward:%b, turn 90:%b", rotateN90, forward, rotate90);

		#10 btnB = 0;

		$display("None state - A:%b, B:%b, C:%b", btnA, btnB, btnC);
		$display("Outputs - turn N90:%b, forward:%b, turn 90:%b", rotateN90, forward, rotate90);

		#10 btnC = 1;
		$display("C pressed - A:%b, B:%b, C:%b", btnA, btnB, btnC);
		$display("Outputs - turn N90:%b, forward:%b, turn 90:%b", rotateN90, forward, rotate90);

		//end
		#100 $finish;
	end
endmodule
