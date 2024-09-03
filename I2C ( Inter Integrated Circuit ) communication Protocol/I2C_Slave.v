
module I2c(reset_in,scl,sda,data_out,address_out);

 input reset_in;
 inout sda, scl;
 output [6:0] address_out;
 output [7:0] data_out;
 
 wire wr_rd;
 reg [7:0] address_in;
 reg [7:0] wr_data;
 reg [7:0] rd_data;
 reg [7:0] sipo_data;
 reg [7:0] piso_data;
 
 reg [3:0] count;
 reg [3:0] present_state;
 reg [3:0] next_state;
 
 reg sda_out;
 reg dir_en;
 reg [7:0] mem [255:0] ;
 
 reg wr_en;
 reg rd_en;
 reg start;
 reg stop;
 reg count_en;
 reg sipo_en;
 reg piso_en;
 reg sipo_valid;
 reg piso_valid;
 reg stop_en;
 reg start_en;
 
 parameter idle        = 4'b0000,
          state_start  = 4'b0001,
          reg_addr     = 4'b0010,
          reg_addr_ack = 4'b0011,
          state_write  = 4'b0100,
          write_ack    = 4'b0101,
          read         = 4'b0110,
          state_read_ack= 4'b0111,
          state_stop   = 4'b1000,
          stop_m       = 4'b1001;
          
      
    assign sda = dir_en? sda_out:1'bz;
    assign data_out = rd_data;
    assign {address_out,wr_rd} = address_in;
    
    always@(negedge scl or posedge reset_in) begin
     if(reset_in)
       present_state <= idle;
     else
       present_state <= next_state;
    end
    
    always@( negedge scl or posedge reset_in) begin
     if(reset_in)
       count <= 0;
     else begin
       if(count_en)
          count <= count +1;
       else 
          count <= 0;
     end
    end
    
    always@( negedge scl or negedge reset_in) begin
      if(!reset_in) begin
        if(wr_en)
          mem[address_out] <= wr_data;
        else if(rd_en)
         rd_data <= mem[address_out];
      end
    end
    
    always@(negedge sda) begin
      if(scl) 
        start <=1 ;
    end
    
    always@(posedge sda) begin
     stop <= 0;
     if(scl && stop_en) 
      stop <= 1;
    end
    
    always@(*)begin
      case(present_state)
      
            idle : begin
                   if(start) 
                      next_state <= state_start;
                   else
                      next_state <= idle;
                   end 
    
      state_start : begin
                     next_state <= reg_addr ;
                    end
                    
      reg_addr :    begin
                         if(count >=0 && count<6)
                           next_state <= reg_addr;
                         else
                           next_state <= reg_addr_ack;
                       end
                       
       reg_addr_ack : begin
                         if(sda_out==0) begin
                           if(wr_rd==0) begin
                             next_state = state_write;
                           end
                           else begin
                             next_state = read;
                           end
                         end
                         else begin
                           next_state = stop_m ;
                         end
                       end
                       
       state_write  :  begin
                         if(count >=0 && count<6)
                           next_state <= state_write;
                         else
                           next_state <= write_ack;
                       end
                       
          write_ack : begin
                           if(sda_out==0)
                             next_state <= reg_addr;
                           else
                             next_state <= stop_m ;
                         end
                         
                         
              read :  begin
                         if(count >=0 && count<6)
                           next_state <= read;
                         else
                           next_state <= state_read_ack;
                        end
                        
          state_read_ack : begin
                            if(sda == 0)
                              next_state <= reg_addr ;
                            else
                              next_state <= stop_m ;
                           end
                           
          stop_m        : begin
                            if(stop)
                              next_state <= state_stop;
                            else if(start)
                              next_state <= state_start;
                          end
                          
          state_stop    : begin
                            if(start)
                              next_state <= state_start ;
                            else
                              next_state <= state_stop ;
                          end
                          
          default       : next_state <= idle ;
         
          endcase
          end
          
          
         always@(*) begin
         case(present_state)
             idle  :  begin
                            dir_en = 0;
                            sda_out = 0;
                            count_en = 0;
                            piso_en = 0;
                            sipo_en = 0;
                            wr_en = 0;
                            rd_en = 0;
                            stop_en = 0;
                            start_en = 1;
                            address_in = 0;
                            wr_data = 0;
                          end
                          
            state_start  : begin
                             dir_en = 0;
                             sda_out = 0;
                             count_en = 0;
                             piso_en = 0;
                             sipo_en = 0;
                             wr_en = 0;
                             rd_en = 0;
                             start_en = 0;
                             address_in = 0;
                             wr_data = 0;
                           end
                           
             reg_addr  : begin
                           dir_en = 0;
                           sda_out = 0;
                           count_en = 1;
                           piso_en = 0;
                           sipo_en = 1;
                           wr_en = 0;
                           rd_en = 0;
                           start_en = 0;
                           address_in = 0;
                           wr_data = 0;
                         end
                         
             reg_addr_ack : begin
                             dir_en = 1;
                             sda_out = 0;
                             count_en = 0;
                             piso_en = 0;
                             sipo_en = 0;
                             wr_en = 0;
                             rd_en = 0;
                             address_in = sipo_data;
                             wr_data = 0;
                           end 
                           
              state_write : begin
                             dir_en = 0;
                             sda_out = 0;
                             count_en = 1;
                             piso_en = 0;
                             sipo_en = 1;
                             wr_en = 0;
                             rd_en = 0;
                             address_in = 0;
                             wr_data = 0;
                           end
                           
              write_ack   : begin
                             dir_en = 1;
                             sda_out = 0;
                             count_en = 0;
                             piso_en = 0;
                             sipo_en = 0;
                             wr_en = 1;
                             rd_en = 0;
                             address_in = 0;
                             wr_data = sipo_data;
                           end
                           
                   read  :  begin
                             dir_en = 1;
                             sda_out = piso_data[0];
                             count_en = 1;
                             piso_en = 1;
                             sipo_en = 0;
                             wr_en = 0;
                             rd_en = (count==0)?1:0;
                             address_in = 0;
                             wr_data = 0;
                                  
                            end  
                            
           state_read_ack : begin
                             dir_en = 0;
                             sda_out = 0;
                             count_en = 0;
                             piso_en = 0;
                             sipo_en = 0;
                             wr_en = 0;
                             rd_en = 0;
                             address_in = 0;
                             wr_data = 0;
                          end
                          
               stop_m  :   begin
                             dir_en = 0;
                             sda_out = 0;
                             count_en = 0;
                             piso_en = 0;
                             sipo_en = 0;
                             wr_en = 0;
                             rd_en = 0;
                             stop_en = 1;
                             address_in = 0;
                             wr_data = 0;
                          end
                          
              state_stop : begin
                             dir_en = 0;
                             sda_out = 0;
                             count_en = 0;
                             piso_en = 0;
                             sipo_en = 0;
                             wr_en = 0;
                             rd_en = 0;
                             address_in = 0;
                             wr_data = 0;
                          end
                          
              default   :  begin
                             dir_en = 0;
                             sda_out = 0;
                             count_en = 0;
                             piso_en = 0;
                             sipo_en = 0;
                             wr_en = 0;
                             rd_en = 0;
                             address_in = 0;
                             wr_data = 0;
                          end
                          
               endcase
               end
               
               
        always@(negedge scl) begin
           if(reset_in)
             sipo_data <=0;
           else begin
             if(sipo_en)
               sipo_data <={sda,sipo_data[7:1]} ;
           end
           
       end
       
       always@(negedge scl) begin
           if(reset_in)
             piso_data <=0;
           else begin
             if(piso_en)begin
               if(count==0)
                 piso_data <= rd_data;
               else
                piso_data <= piso_data>>1;
           end
       end
       end
       
       
       
   endmodule
