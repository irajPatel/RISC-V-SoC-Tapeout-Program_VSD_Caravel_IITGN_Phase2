module dummy_por (
`ifdef USE_POWER_PINS
    inout vdd3v3,
    inout vdd1v8,
    inout vss3v3,
    inout vss1v8,
`endif
    input  wire clk,        // NEW: clock input
    input  wire rst_n_in,   // NEW: external power-good/reset (active low)
    output wire porb_h,
    output wire porb_l,
    output wire por_l
);

    wire reset_n_out;

    // Instantiate your digital POR
    digital_por #(
        .N_CYCLES(1024)   // change this number later as needed
    ) u_dpor (
        .clk        (clk),
        .rst_n_in   (rst_n_in),
        .reset_n_out(reset_n_out)
    );

    // Map outputs exactly like the old simple_por did
    assign porb_h = reset_n_out;
    assign porb_l = reset_n_out;
    assign por_l  = ~reset_n_out;

endmodule
