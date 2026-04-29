module fifo #(
  
  
  
  
   // the comments in the file are just for me to understand the rtl and while writing tb it helps me refer back to these comments for quick recall.
   
   
   parameter WIDTH  = 4, 
   parameter DEPTH  = 12,     
   parameter ALMOST_FULL_TH  = 2,   // Raise warning near full
   parameter ALMOST_EMPTY_TH  = 2,  
   parameter POINTER_W  = $clog2(DEPTH)   
)
(
   input logic clk,
   input logic n_rst,                     
   input logic we,  // write data
   input logic re,  // read data
   input logic [WIDTH-1:0] wrdata,  // incoming data or the value (for example 10)
   output logic [WIDTH-1:0] rddata,  // outgoing data
   output logic full, 
   output logic almost_full, 
   output logic empty, 
   output logic almost_empty
);

logic [WIDTH-1:0] ram [DEPTH];  // the storage with total 12 slots and each slot is 4 bit wide
logic [POINTER_W-1:0] wptr;  // track where the next write is going
logic [POINTER_W-1:0] rptr;  // track where the next read is going
logic [POINTER_W-1:0] next_wptr;  // computing next locations
logic [POINTER_W-1:0] next_rptr;  
logic [POINTER_W-1:0] count;  
      

always_ff @(posedge clk) 
   begin
   if (!n_rst) // all the main trackers are reset to 0
      begin      
      wptr  <= '0;
      rptr  <= '0;      
      count <= '0;
      end
   else 
      begin                    
      if (we && !full) // if write data is on and the ram is not full
         begin             
         ram[wptr] <= wrdata ;  // store incoming data into ram
         wptr <= next_wptr; //move write pointer forward
         end
        /*
        if wptr = 3, wrdata = A then we Store A in slot 3
        */
      if (re && !empty) // only read if ram is not empty
         begin  
         rddata <= ram[rptr];       // read the oldest data
         rptr <= next_rptr; // move read pointer forward
         end

      if (we && !full) 
         begin       
         count <= count + 1;
         end                    
      else if (re && !empty) 
         begin    
         count <= count - 1;         
         end
      end
   end
/* Imagine you have 4 box in order 1,2,3,4 and you want to feed data 1,2,3,4 now the first write will be to box 1
2nd will be to box 2 and box 3 and so on but when we read we read from the oldest data as this is the point of FIFO so the 
Box 1 becomes the oldest data hence the count decrements theoretically as the value 1 is pushed down each clk
*/



always_comb
  begin
  if (count == DEPTH) // FIFO Full
    full = 1'b1;
  else 
    full = 1'b0;
  if (count == 1) 
    empty = 1'b1;
  else
    empty = 1'b0;
  if (count > DEPTH - ALMOST_FULL_TH) // release warning when count is around 11,12...
    almost_full = 1'b1;
  else
    almost_full = 1'b0;
  if (count < ALMOST_EMPTY_TH)
    almost_empty = 1'b1;
  else
    almost_empty = 1'b0;
  if (wptr == DEPTH-1) // wrap back to the beginning of the array
    next_wptr = '0; // we start from array one once with hit the 12th slot
  else
    next_wptr = wptr + 1;
  if (rptr == DEPTH-1)
    next_rptr =  '0;
  else
    next_rptr = rptr + 1;
  end

endmodule