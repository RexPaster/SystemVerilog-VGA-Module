/* module top #(
    parameter bit SIMULATION = 1'b0
) (
    input  logic       clk_12mhz,
    input  logic       rst_n,
    input  logic       rom_spi_miso,
    output logic       rom_spi_mosi,
    output logic       rom_spi_sck,
    output logic       rom_spi_cs_n,

    // Digilent PMOD VGA — JA connector (upper)
    output logic [3:0] vga_r,    // R[3:0]  → JA1-4
    output logic [3:0] vga_g,    // G[3:0]  → JA7-10

    // Digilent PMOD VGA — JB connector (lower)
    output logic [3:0] vga_b,    // B[3:0]  → JB1-4
    output logic       vga_hs,   // HSync   → JB7  (active-low)
    output logic       vga_vs    // VSync   → JB8  (active-low)
);

    // Shared screen bus between Hack memory map and VGA framebuffer.
    logic [12:0] fb_write_addr;
    logic        fb_write_en;
    logic [15:0] fb_write_data;
    logic [12:0] fb_read_addr;
    logic [15:0] fb_read_data;

    vga_top #(
        .SIMULATION(SIMULATION)
    ) vga_top (
        .clk_12mhz(clk_12mhz),
        .rst_n(rst_n),
        .fb_read_addr(fb_read_addr),
        .fb_read_data(fb_read_data),
        .fb_write_en(fb_write_en),
        .fb_write_data(fb_write_data),
        .fb_write_addr(fb_write_addr),
        .vga_r(vga_r),
        .vga_g(vga_g),
        .vga_b(vga_b),
        .vga_hs(vga_hs),
        .vga_vs(vga_vs)
    );

endmodule */

module top #(
    parameter bit SIMULATION = 1'b0
) (
    input  logic       clk_12mhz,
    input  logic       rst_n,
    input  logic       rom_spi_miso,
    output logic       rom_spi_mosi,
    output logic       rom_spi_sck,
    output logic       rom_spi_cs_n,

    output logic [3:0] vga_r,
    output logic [3:0] vga_g,

    output logic [3:0] vga_b,
    output logic       vga_hs,
    output logic       vga_vs
);

    localparam int FB_WORDS      = 7680;
    localparam int WORDS_PER_ROW = 32;

    logic sys_rst_n;

    generate
        if (SIMULATION) begin : g_rst_sim
            assign sys_rst_n = rst_n;
        end else begin : g_rst_hw
            logic [15:0] por_ctr = 16'h0000;

            always_ff @(posedge clk_12mhz) begin
                if (!por_ctr[15]) begin
                    por_ctr <= por_ctr + 16'h0001;
                end
            end

            assign sys_rst_n = por_ctr[15];
        end
    endgenerate

    logic [12:0] fb_write_addr;
    logic        fb_write_en;
    logic [15:0] fb_write_data;
    logic [12:0] fb_read_addr;
    logic [15:0] fb_read_data;

    assign rom_spi_mosi = 1'b0;
    assign rom_spi_sck  = 1'b0;
    assign rom_spi_cs_n = 1'b1;

    logic [12:0] addr_counter;
    logic [8:0]  x_word;
    logic [8:0]  y;

    logic border;
    logic stripe;
    logic center_box;

    always_comb begin
        x_word = addr_counter % WORDS_PER_ROW;
        y      = addr_counter / WORDS_PER_ROW;

        border =
            (y < 4) ||
            (y >= 236) ||
            (x_word < 1) ||
            (x_word >= 31);

        center_box =
            (y >= 70) &&
            (y < 170) &&
            (x_word >= 8) &&
            (x_word < 24);

        stripe = x_word[1] ^ y[3];
    end

    always_ff @(posedge clk_12mhz or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            addr_counter  <= 13'd0;
            fb_write_addr <= 13'd0;
            fb_write_data <= 16'h0000;
            fb_write_en   <= 1'b0;
        end else begin
            fb_write_en   <= 1'b1;
            fb_write_addr <= addr_counter;

            if (border) begin
                fb_write_data <= 16'hFFFF;
            end else if (center_box) begin
                fb_write_data <= stripe ? 16'hAAAA : 16'h5555;
            end else begin
                fb_write_data <= stripe ? 16'hF0F0 : 16'h0F0F;
            end

            if (addr_counter == FB_WORDS - 1)
                addr_counter <= 13'd0;
            else
                addr_counter <= addr_counter + 13'd1;
        end
    end

    vga_top #(
            .SIMULATION(SIMULATION)
    ) vga_top (
        .clk_12mhz(clk_12mhz),
        .rst_n(sys_rst_n),

        .fb_read_addr(fb_read_addr),
        .fb_read_data(fb_read_data),

        .fb_write_en(fb_write_en),
        .fb_write_data(fb_write_data),
        .fb_write_addr(fb_write_addr),

        .vga_r(vga_r),
        .vga_g(vga_g),
        .vga_b(vga_b),
        .vga_hs(vga_hs),
        .vga_vs(vga_vs)
    );

endmodule
