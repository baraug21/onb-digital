`timescale 1ns / 1ps

module sync_fifo #(
    parameter int unsigned DATA_WIDTH          = 8,
    parameter int unsigned DEPTH               = 16,
    parameter int unsigned ALMOST_FULL_THRESH  = 14,
    parameter int unsigned ALMOST_EMPTY_THRESH = 2
) (
    input  logic                    clk,
    input  logic                    rst_n,

    // Write interface
    input  logic                    wr_en,
    input  logic [DATA_WIDTH-1:0]   wr_data,
    output logic                    full,
    output logic                    almost_full,

    // Read interface
    input  logic                    rd_en,
    output logic [DATA_WIDTH-1:0]   rd_data,
    output logic                    empty,
    output logic                    almost_empty,

    // Diagnostics / occupancy
    output logic [$clog2(DEPTH):0]  occupancy
);

    // TODO:
    // 1. Declare the RAM memory array: logic [DATA_WIDTH-1:0] mem [0:DEPTH-1]; DONE
    // 2. Implement write (wr_ptr) and read (rd_ptr) pointers. DONE
    // 3. Implement an occupancy counter.
    // 4. Calculate flags: empty, full, almost_empty, almost_full.
    // 5. Handle simultaneous read and write.

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    logic [$clog2(DEPTH)-1:0] wr_ptr, rd_ptr;


    always_ff@(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            wr_ptr <= '0;
            rd_ptr <= '0;
        end
        else begin
            if(wr_en == 1 && full == 0) begin
                if(wr_ptr<DEPTH-1) begin
                    wr_ptr <= wr_ptr+1;
                end
                else begin
                    wr_ptr <= 0;
                end
            end

            if(rd_en == 1 && empty == 0) begin
                if(rd_ptr<DEPTH-1) begin
                    rd_ptr <= rd_ptr+1;
                end
                else begin
                    rd_ptr <= 0;
                end
            end
           
        end
    end



    // assign full         = 1'b0;
    // assign almost_full  = 1'b0;
    // assign empty        = 1'b1;
    // assign almost_empty = 1'b1;
    // assign rd_data      = '0;
    // assign occupancy    = '0;

endmodule
