// Educational ISP-style RGB-to-luma pixel pipeline with programmable controls.
// One-cycle latency from accepted input to output; stalls are not supported.
module isp_pixel_pipeline (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        in_valid,
    input  logic [7:0]  r_in,
    input  logic [7:0]  g_in,
    input  logic [7:0]  b_in,
    input  logic [7:0]  gain_q4,     // 16 == 1.0x, 0..255 == 0..15.9375x
    input  logic [7:0]  edge_threshold, // simple brightness-threshold diagnostic
    output logic        out_valid,
    output logic [7:0]  luma_out,
    output logic        bright_flag
);
    logic [15:0] weighted_sum;
    logic [7:0] luma_comb;
    logic [15:0] gain_product;
    logic [7:0] saturated_luma;

    // Approximate BT.601 luma using integer coefficients summing to 256.
    // Constants: 77 R + 150 G + 29 B, rounded before division by 256.
    always_comb begin
        weighted_sum  = (16'(r_in) * 16'd77) +
                        (16'(g_in) * 16'd150) +
                        (16'(b_in) * 16'd29) + 16'd128;
        luma_comb     = weighted_sum[15:8];
        gain_product   = 16'(luma_comb) * 16'(gain_q4);
        if (gain_product > 16'd4080) // 255 * 16; saturate before /16
            saturated_luma = 8'hFF;
        else
            saturated_luma = gain_product[11:4];
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_valid   <= 1'b0;
            luma_out    <= 8'h00;
            bright_flag <= 1'b0;
        end else begin
            out_valid <= in_valid;
            if (in_valid) begin
                luma_out    <= saturated_luma;
                bright_flag <= (saturated_luma >= edge_threshold);
            end
        end
    end
endmodule
