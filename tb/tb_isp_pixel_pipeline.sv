`timescale 1ns/1ps
module tb_isp_pixel_pipeline;
    logic clk = 0;
    always #5 clk = ~clk;
    logic rst_n = 0;
    logic in_valid = 0;
    logic [7:0] r_in, g_in, b_in, gain_q4, edge_threshold;
    logic out_valid, bright_flag;
    logic [7:0] luma_out;
    integer fd, rc, passed = 0, line_no = 0;
    logic [7:0] exp_luma;
    logic exp_bright;
    string vector_path;

    isp_pixel_pipeline dut (.*);

    initial begin
        if (!$value$plusargs("VECTORS=%s", vector_path))
            vector_path = "tb/vectors.txt";
        fd = $fopen(vector_path, "r");
        if (fd == 0) $fatal(1, "Cannot open %s", vector_path);

        r_in=0; g_in=0; b_in=0; gain_q4=16; edge_threshold=128;
        repeat (2) @(negedge clk);
        rst_n = 1;

        while (!$feof(fd)) begin
            // Inputs applied on falling edge; outputs checked after rising edge.
            rc = $fscanf(fd, "%h %h %h %h %h %h %h\n",
                         r_in, g_in, b_in, gain_q4, edge_threshold,
                         exp_luma, exp_bright);
            if (rc == 7) begin
                line_no = line_no + 1;
                in_valid = 1;
                @(posedge clk);
                #1;
                if (out_valid !== 1'b1 || luma_out !== exp_luma || bright_flag !== exp_bright)
                    $fatal(1, "Vector %0d: expected luma=%0d flag=%0d; got luma=%0d flag=%0d valid=%0d",
                           line_no, exp_luma, exp_bright, luma_out, bright_flag, out_valid);
                passed = passed + 1;
                @(negedge clk);
            end else if (rc != -1) begin
                $fatal(1, "Malformed vector line near %0d", line_no + 1);
            end
        end
        in_valid = 0;
        @(posedge clk); #1;
        if (out_valid !== 1'b0) $fatal(1, "valid did not deassert");
        $display("PASS: %0d ISP pixel vectors", passed);
        $fclose(fd);
        $finish;
    end
endmodule
