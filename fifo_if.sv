interface fifo_if #(parameter WIDTH = 4, parameter DEPTH = 12) (input logic clk);
logic full;
logic almost_full;
logic empty;
logic almost_empty;
logic n_rst;
logic we;
logic re;
logic [WIDTH-1:0] wrdata;
logic [WIDTH-1:0] rddata;

  clocking cb @(posedge clk);
    default input #1 output #1; // added to ensure tb drives and reads signal after the clock edge ensuring we dont hit any race conditions
    output n_rst;
    output we;
    output re;
    output wrdata;
    input  rddata;
    input full;
    input almost_full;
    input empty;
    input almost_empty;
  endclocking

  modport TB(clocking cb, output n_rst);


    property reset_check;
          @(posedge clk) (!n_rst) |=> (empty == 1'b1); // sequentioal logic 
    endproperty
  
      assert_reset_empty: assert property(reset_check) 
          else $error("error: Reset enable, but FIFO does not report as empty!");


    property empty_read_check;
          @(posedge clk) disable iff (!n_rst) // Don't check this while reset is not enabled
            (re && empty) |-> 0;
    endproperty

      assert_no_bad_read: assert property(empty_read_check) 
          else $warning("Error, FIFO is empty but read is attempted");
      
    property p_no_write_on_full;
          @(posedge clk) disable iff (!n_rst)
          (we && full) |-> 0;
    endproperty
  
      assert_no_bad_write: assert property(p_no_write_on_full) 
          else $warning("Error, FIFO Mem is full but write is attempted");

    property wake_up_check;
          @(posedge clk) disable iff (!n_rst)
          (we && !re && empty) |=> empty == 1'b0;  // on the left ive written the condition the logical condition and then on the right is what happens if the condition is true
    endproperty
    
      assert_wake_up: assert property(wake_up_check) 
        else $error("error, wrote to FIFO yet empty flag is high");
    
    property full_flag_check;
          @(posedge clk) disable iff (!n_rst)
          (re && !we && full) |=> full == 1'b0;
    endproperty

      assert_full_flag: assert property(full_flag_check) 
        else $error("error, read from FIFO yet full flag is high");
    
    property simultaneous_write_check;
          @(posedge clk) disable iff (!n_rst)
          (full && we && re) |=> full == 1'b1;
    endproperty

      assert_simultaneous_write: assert property(simultaneous_write_check) 
        else $error("error, simultaneous write and read attempted");

endinterface