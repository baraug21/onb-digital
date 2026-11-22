`timescale 1ns / 1ps

module uart_tx #(
    parameter int unsigned CLK_FREQ_HZ = 50_000_000,
    parameter int unsigned BAUD_RATE   = 115_200
) (
    input  logic       clk,
    input  logic       rst_n,

    // Data handshake
    input  logic [7:0] tx_data,
    input  logic       tx_valid,
    output logic       tx_ready,

    // Physical line
    output logic       txd
);

    // TODO:
    // 1. Implement a clock prescaler generating bit clock ticks:
    //    CLKS_PER_BIT = (CLK_FREQ_HZ + BAUD_RATE/2) / BAUD_RATE. DONE
    // 2. Build the state machine (FSM): IDLE, START, DATA, STOP.
    // 3. Transmit data bits in 8N1 format (LSB first).
    // 4. Manage the tx_ready flag to support back-to-back continuous transmission.

    parameter CLKS_PER_BIT = (CLK_FREQ_HZ + BAUD_RATE/2) / BAUD_RATE;

    typedef enum logic [1:0] {  
        IDLE = 2'b00,
        START = 2'b01,
        DATA = 2'b10,
        STOP = 2'b11
    } state;
    
    state current_state, next_state;

    logic [$clog2(CLKS_PER_BIT)-1:0]bit_counter;
    logic [2:0]bit_index;
    logic [7:0]tx_data_q;

    always_comb begin 
        
        tx_ready = 1'b0;
        next_state = current_state;
        
        case(current_state)
            
            IDLE: begin
                tx_ready = 1'b1;
                if(tx_valid) begin
                    next_state = START;
                end
            end

            START: begin
               if(bit_counter==CLKS_PER_BIT-1) begin
                    next_state = DATA;
               end
            end

            DATA: begin
                if(bit_index==3'b111 && bit_counter==CLKS_PER_BIT-1) begin
                    next_state = STOP;
                end
            end

            STOP: begin
                if(bit_counter==CLKS_PER_BIT-1) begin
                    next_state = IDLE;
                end
            end
        
        endcase
        
    end
    

    always_ff @( posedge clk, negedge rst_n ) begin 
        
        if(!rst_n) begin
            
            current_state <= IDLE;
            bit_counter <= '0;
            bit_index <= '0;
            txd <= 1;
        
        end
        
        else begin
            
            current_state <= next_state;

            case(current_state)

                IDLE: begin
                    
                    txd <= 1;
                    bit_counter <= '0;
                    bit_index <= '0;

                    //saving data in IDLE to prevent it from changing during transmission
                    if(tx_ready==1 && tx_valid==1) begin
                        tx_data_q <= tx_data;
                    end

                end

                START: begin
                    
                    txd <= 0;
                    bit_counter <= bit_counter+1;

                    if(bit_counter==CLKS_PER_BIT-1) begin
                        bit_counter <= '0;
                    end
                
                end

                DATA: begin
                    
                    txd <= tx_data_q[bit_index];
                    bit_counter <= bit_counter+1;
                    
                    if(bit_counter==CLKS_PER_BIT-1) begin
                        bit_index <= bit_index+1;
                        bit_counter <= '0;
                    end
                
                end

                STOP: begin
                    
                    txd <= 1;
                    bit_counter <= bit_counter+1;
                    
                    if(bit_counter==CLKS_PER_BIT-1) begin
                        bit_counter <= '0;
                    end
                
                end

            endcase

        end
        
    end
    
    
    
    // assign tx_ready = 1'b1;
    // assign txd      = 1'b1;

endmodule
