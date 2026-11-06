`timescale 1ns / 1ps

module debounce_edge_detect #(
    parameter int unsigned CLK_FREQ_HZ    = 50_000_000,
    parameter int unsigned STABLE_TIME_MS = 10
) (
    input  logic clk,
    input  logic rst_n,
    input  logic sig_in,
    output logic sig_debounced,
    output logic edge_rise,
    output logic edge_fall
);

    // TODO:
    // 1. Implement a 2-stage synchronizer on the sig_in input. DONE
    // 2. Calculate the required cycle count: CYCLES = (CLK_FREQ_HZ * STABLE_TIME_MS) / 1000. DONE
    // 3. Implement a counter measuring the stability interval. DONE
    // 4. Update sig_debounced with the stable input state. DONE
    // 5. Generate 1-clock-cycle pulses for edge_rise and edge_fall. DONE

    logic s1, s2;

    always_ff @( posedge clk, negedge rst_n ) begin
        
        if (!rst_n) begin
            s1 <= 0;
            s2 <= 0;
        end
        else begin
            s1 <= sig_in;
            s2 <= s1;
        end

    end

    parameter CYCLES = (CLK_FREQ_HZ * STABLE_TIME_MS) / 1000;

    //$clog - ceiling of log base 2
    logic [$clog2(CYCLES)-1:0] counter;

    logic sig_debounced_prev;

    always_ff @( posedge clk, negedge rst_n ) begin

        
        if (!rst_n) begin
            counter <= '0;
            sig_debounced <= 0;
        end
        else begin
            if ( s2 == sig_debounced ) begin
                counter <= '0;
            end
            else begin
                counter <= counter+1;
            end
        end

        if (counter == CYCLES-1) begin
            sig_debounced <= s2;
            counter <= 0;
        end
        
        sig_debounced_prev <= sig_debounced;
    end

    assign edge_rise = ~sig_debounced_prev & sig_debounced;
    assign edge_fall = sig_debounced_prev & ~sig_debounced;


endmodule
