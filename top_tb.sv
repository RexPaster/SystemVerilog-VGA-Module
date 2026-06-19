`timescale 1ns/1ps

module top_tb;
    logic clk_12mhz;
    logic rst_n;
    // TODO: declare signals to match top ports

    top #(
        .SIMULATION(1'b1)
    ) dut (
        .clk_12mhz(clk_12mhz),
        .rst_n(rst_n)
        // TODO: connect your ports here
    );

    // 12 MHz clock: period = ~83 ns, half-period = 41 ns (integer safe for Yosys)
    initial begin
        clk_12mhz = 1'b0;
        forever #41 clk_12mhz = ~clk_12mhz;
    end

    initial begin
        rst_n = 1'b0;
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);

        #200 rst_n = 1'b1;
        // TODO: add stimulus here
        #10_000;
        $finish;
    end
endmodule
