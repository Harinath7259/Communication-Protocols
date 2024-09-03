
module testbench ;

 reg RESET;
 wire [6:0] ADDRESS_OUT;
 wire [7:0] DATA_OUT;
 wire SCL;
 wire SDA;
 
 reg clk;
 reg sda;
 
 I2c dut(RESET,SCL,SDA,DATA_OUT,ADDRESS_OUT);
 assign SCL = clk;
 assign SDA = dut.dir_en? 1'bz:sda;
 
 task initialization;
 
  begin
    clk = 0;
    sda = 0;
    RESET = 0;
  end
 endtask
 
 task rst;
  begin
    RESET = 1;
    repeat(2)@(negedge clk) ;
    #2;
    RESET = 0;
  end
 endtask
 
 always #10 clk = !clk;
 
 task start_gen;
 begin
   sda = 1;
   @(posedge clk);
   #2;
  sda = 0;
   @(negedge clk);
 end
 endtask
 
 task stop_gen;
   begin
    @(negedge clk);
    sda = 0;
    @(posedge clk); #2;
    sda = 1;
   end
 endtask
 
 task wr_address;
  reg [7:0] temp;
  begin
    temp = 8'b0000_1010;
    repeat(8) begin
     @(posedge clk);
     sda = temp;
     temp = temp>>1;
  end
  end
  endtask
  
  task rd_address;
  reg [7:0] temp;
  begin
    temp = 8'b0000_1011;
    repeat(8) begin
     @(posedge clk);
     sda = temp;
     temp = temp>>1;
  end
  end
  endtask
  
  task write_data;
  reg [7:0] temp;
  begin
    temp = 8'b1100_1100;
    repeat(8) begin
     @(posedge clk);
     sda = temp;
     temp = temp>>1;
  end
  end
  endtask
  
  task read_data;
   begin
   @(negedge clk);
    repeat(8) begin
     @(negedge clk);
    end
   end
  endtask
  
  initial begin
   initialization;
   rst;
   start_gen();
   wr_address();
   write_data;
   rd_address();
   @(negedge clk);
   read_data;
   #200;
   $finish;
  end
  
  initial begin
  
   $dumpfile("dump.vcd");
   $dumpvars(0);
   
  end
  
  
  endmodule
   
