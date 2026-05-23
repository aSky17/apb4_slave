module apb4_slave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input logic PCLK,
    input logic PRESETn,
    input logic [DATA_WIDTH-1:0] PADDR,
    input logic PSEL,
    input logic PENABLE,
    input logic PWRITE,
    input logic [DATA_WIDTH-1:0] PWDATA,

    output logic [DATA_WIDTH-1:0] PRDATA,
    output logic PREADY,
    output logic PSLVERR
);

    import apb4_pkg::*;

    parameter int WAIT_CYCLES = 2;
    
    //fsm
    apb_state_t state, next_state;

    //registers
    logic [31:0] ctrl_reg;
    logic [31:0] status_reg;
    logic [31:0] txdata_reg;
    logic [31:0] rxdata_reg;
    logic [31:0] config_reg;

    //wait counter
    logic [$clog2(WAIT_CYCLES+1)-1:0] wait_count;

    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin
        next_state = state;

        case(state)

            IDLE: begin
                if (PSEL && !PENABLE) begin
                    next_state = SETUP;
                end
            end

            SETUP: begin
                next_state = ACCESS;
            end

            ACCESS: begin
                if (PREADY) begin
                    if (PSEL && !PENABLE) begin
                        next_state = SETUP;
                    end else begin
                        next_state = IDLE;
                    end
                end else begin
                    next_state = ACCESS;
                end
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    //wait counter logic
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            wait_count <= 0;
        end else begin
            if (state == SETUP) begin
                wait_count <= WAIT_CYCLES;
            end else if (state == ACCESS && wait_count != 0) begin
                wait_count <= wait_count - 1'b1;
            end
        end
    end

    //PREADY generation
    always_comb begin
        if (state == ACCESS && wait_count == 0) begin
            PREADY = 1'b1;
        end else begin
            PREADY = 1'b0;
        end
    end


    //write logic 
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            ctrl_reg <= 32'h0;
            status_reg <= 32'h0;
            txdata_reg <= 32'h0;
            rxdata_reg <= 32'h0;
            config_reg <= 32'h0;
        end else begin
            if (PSEL && PENABLE && PWRITE && PREADY) begin
                case(PADDR) 
                    CTRL_ADDR: begin
                        ctrl_reg <= PWDATA;
                    end

                    TXDATA_ADDR: begin
                        txdata_reg <= PWDATA;
                    end

                    CONFIG_ADDR: begin
                        config_reg <= PWDATA;
                    end

                    default: begin
                    end
                endcase
            end
        end
    end

    //read logic
    always_comb begin
        PRDATA = 32'h00;

        if (PSEL && PENABLE && !PWRITE && PREADY) begin
            case (PADDR) 
                CTRL_ADDR: begin
                    PRDATA = ctrl_reg;
                end

                STATUS_ADDR: begin
                    PRDATA = status_reg;
                end

                TXDATA_ADDR: begin
                    PRDATA = txdata_reg;
                end

                RXDATA_ADDR: begin
                    PRDATA = rxdata_reg;
                end

                CONFIG_ADDR: begin
                    PRDATA = config_reg;
                end

                default: begin
                    PRDATA = 32'hDEAD_BEEF;
                end
            endcase
        end
    end

    assign PSLVERR = 1'b0;


endmodule