// 1. Declare the software queue (assuming WIDTH = 4)
logic [3:0] golden_queue [$];
logic [3:0] expected_data;

// 2. The Write Logic (Pushing data)
always @(posedge clk) begin
  if (we && !full) begin
    golden_queue.push_back(wrdata);
  end
end

// 3. The Read & Check Logic (Popping and comparing)
always @(posedge clk) begin
  if (re && !empty) begin
    // Grab the oldest data from our perfect queue
    expected_data = golden_queue.pop_front();
    
    // Compare it to the hardware output
    if (expected_data !== rddata) begin
      $error("MISMATCH! Expected: %0h, Got: %0h", expected_data, rddata);
    end
  end
end