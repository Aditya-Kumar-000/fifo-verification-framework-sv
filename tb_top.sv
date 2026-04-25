module tb_top;
  // 1. Generate the main clock
  logic clk = 0;
  always #5 clk = ~clk; // toggles every 5 unit
    int write_count = 0;
    int read_count = 0;
    int match_count = 0;
  
  // Instantiating the interface module (Passing the clock we just made into it)
  fifo_if #(.WIDTH(4), .DEPTH(12)) intf (.clk(clk));

  //Here we instantiate the hardware module (from fifo.sv)
  // We wire the interface signals directly to the hardware ports
  // Here I have created a connected between DUT <-> Interface <-> TB
  fifo #(.WIDTH(4), .DEPTH(12)) dut (
    .clk(intf.clk),
    .n_rst(intf.n_rst),
    .we(intf.we),
    .re(intf.re),
    .wrdata(intf.wrdata),
    .rddata(intf.rddata),
    .full(intf.full),
    .almost_full(intf.almost_full),
    .empty(intf.empty),
    .almost_empty(intf.almost_empty)
  );

// Scoreboard

  

  logic [3:0] golden_queue [$]; // I have used my mathematical model 'queue' hence golden queue represents a "ideal" FIFO model
  logic [3:0] expected_data; // the data I expect to arrive next

  // Whenever H/W successfully writes data, the scoreboard also stores data in the perfect model
  always @(posedge clk) begin
    if (intf.we && !intf.full && intf.n_rst) begin // Check if write is valid and not full
      golden_queue.push_back(intf.wrdata); // push_back = write
      write_count++;
    end
  end

  // Monitor for Read
  always @(negedge clk) begin // selected negedge to avoid race condition (more mention in logbook)
    if (intf.re && !intf.empty && intf.n_rst) begin
      // read what the math model predicts the output to be as
      expected_data = golden_queue.pop_front(); // Give me the oldest value stored AND remove it from the queue
       read_count++;                                         // pop_front means read
                                            
      // Compare the expected vs real output
      if (expected_data !== intf.rddata) begin // if expected vs real dont match then flag error
         $display("FATAL ERROR! Time: %0t | Expected: %0h | Got: %0h", $time, expected_data, intf.rddata);
         $stop; // Halt the simulation
      end 
      
      else begin
         $display("SUCCESS! Time: %0t | Read matched: %0h", $time, intf.rddata);
          match_count++;
      end
    end
  end


// Test cases, some designed to purposely hit the assertions

    initial begin
  // 1. Initialised everything to zero
        intf.we <= 0;
        intf.re <= 0;
        intf.wrdata <= 0;
  

        intf.n_rst <= 0;
        repeat(2) @(posedge clk); // holding reset low for 2 cycles
        intf.n_rst <= 1; 
        @(posedge clk);                                                                                                                                                                                                                                         

   
    for (int i = 0; i < 14; i++) begin // since depth = 12 so to trigger the assert for no write
        intf.we <= 1;
        intf.re <= 0;
        intf.wrdata <= i; // Just feeding it basic sequential numbers
        @(posedge clk);
    end
        intf.we <= 0; // Turn off write enable when done
        @(posedge clk);

  
    for (int i = 0; i < 14; i++) begin // the first 12reads are fine but the next 13,14 read will read a empty fifo as we have read all the data
        intf.re <= 1;
        intf.we <= 0;
        @(posedge clk);
    end
        intf.re <= 0; // Turn off read enable when don     
  // FIFO is currently empty. Let's write one item so it's not empty.
  intf.we <= 1; intf.re <= 0; intf.wrdata <= 9; // wrdata is 9 to ensure the FIFO has some data to read as the last loop from line 84 must have cleared all of FIFO
  @(posedge clk);
  // With regards to the specification this loop ensures we rite and read on the same clk
  for (int i = 0; i < 5; i++) begin
    intf.we <= 1; 
    intf.re <= 1; // we assert both we and re on the same clock edge (the main aspect from the spec)
    intf.wrdata <= i + 10; // we can only feed data after 9 so we start from 10,11...
    @(posedge clk); // we ensure that H/W is able to process the data hence we wait for one posedge
  end
  intf.we <= 0; // we initialise we, re back to 0 just to avoid any race conditions
  intf.re <= 0;

    $display("Coverage Summary_FIFO");
    $display("Total Valid Writes: %0d", write_count);
    $display("Total Valid Reads:  %0d", read_count);
    $display("Total Data Matches: %0d", match_count);
    $display("Quality Score:      %0.2f%%", (match_count*100.0/read_count)); // simple formula match_cnt/read_count * 100
    #50 $finish;

end


endmodule