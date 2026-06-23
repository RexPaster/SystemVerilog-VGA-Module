`timescale 1ns/1ps

module top_tb;
    // The DUT writes its own framebuffer pattern; this bench only checks the output timing.
    logic clk_12mhz;
    logic rst_n;
    logic rom_spi_miso;
    logic rom_spi_mosi;
    logic rom_spi_sck;
    logic rom_spi_cs_n;
    logic [3:0] vga_r;
    logic [3:0] vga_g;
    logic [3:0] vga_b;
    logic vga_hs;
    logic vga_vs;
    logic saw_vsync_low;

    top #(
        .SIMULATION(1'b1)
    ) dut (
        .clk_12mhz(clk_12mhz),
        .rst_n(rst_n),
        .rom_spi_miso(rom_spi_miso),
        .rom_spi_mosi(rom_spi_mosi),
        .rom_spi_sck(rom_spi_sck),
        .rom_spi_cs_n(rom_spi_cs_n),
        .vga_r(vga_r),
        .vga_g(vga_g),
        .vga_b(vga_b),
        .vga_hs(vga_hs),
        .vga_vs(vga_vs)
    );

    // 12 MHz clock: ~83 ns period. Use 41 ns half-period for integer timing.
    initial begin
        clk_12mhz = 0;
        forever #41 clk_12mhz = ~clk_12mhz;
    end

    initial begin
        rom_spi_miso = 1'b0;
        rst_n = 1'b0;
        saw_vsync_low = 1'b0;

        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);

        #200 rst_n = 1;

        repeat (500000) begin
            @(posedge clk_12mhz);
            if (rst_n && vga_vs == 1'b0) begin
                saw_vsync_low = 1'b1;
            end
        end

        if (dut.vga_top.pll_locked !== 1'b1) begin
            $display("ERROR: PLL never locked");
        end

        if (dut.vga_top.srst_n !== 1'b1) begin
            $display("ERROR: system reset never released");
        end

        if (!saw_vsync_low) begin
            $display("ERROR: vga_vs never went low during the capture window");
        end

        $finish;
    end
endmodule
