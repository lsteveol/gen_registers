module wav_clock_mux(
  input  wire   clk0,
  input  wire   clk1,
  input  wire   sel,
  output wire   clk_out
);

assign clk_out = sel ? clk1 : clk0;


endmodule


module demet_reset(
  input  wire   clk,
  input  wire   reset,
  input  wire   sig_in,
  output wire   sig_out
);

reg dflop1;
reg dflop2;

always @(posedge clk or posedge reset) begin
  if(reset) begin
    dflop1    <= 1'b0;
    dflop2    <= 1'b0;
  end else begin
    dflop1    <= sig_in;
    dflop2    <= dflop1;
  end
end

assign sig_out = dflop2;

endmodule
