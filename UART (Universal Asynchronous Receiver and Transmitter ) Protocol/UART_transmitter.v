
module UART_TX(input start_bit, clk , rst, stop_bit, [7:0] tx_data, output  TX_data_out);

 
 wire [1:0] selm;
 
 
 fsmtx FSM ( start_bit, rst, clk,  shift, selm);
 mux4x1 MUX ( rst,start_bit, data_out,parity,stop_bit,  selm, TX_data_out);
 even_parity_generator epg (tx_data, parity);
 PISO piso (tx_data ,shift, clk, rst, data_out);
  
endmodule
