/*
* PPROT[0]: 1 = privileged, 0 = user
* PPROT[1]: 1 = non-secure, 0 = secure
* PPROT[2]: 1 = instruction access, 0 = data access
*/

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
    input logic [3:0] PSTRB,
    input logic [2:0] PPROT,

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

    //internal error signal
    logic pslverr_next;

    //protection policy
    logic prot_error;

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
            if (PSEL && PENABLE && PWRITE && PREADY && !PSLVERR && !prot_error) begin
                case(PADDR) 
                    CTRL_ADDR: begin
                        if (PSTRB[0]) begin
                            ctrl_reg[7:0] <= PWDATA[7:0];
                        end
                        if (PSTRB[1]) begin
                            ctrl_reg[15:8] <= PWDATA[15:8];
                        end
                        if (PSTRB[2]) begin
                            ctrl_reg[23:16] <= PWDATA[23:16];
                        end
                        if (PSTRB[3]) begin
                            ctrl_reg[31:24] <= PWDATA[31:24];
                        end
                    end

                    TXDATA_ADDR: begin
                        if (PSTRB[0]) begin
                            txdata_reg[7:0] <= PWDATA[7:0];
                        end
                        if (PSTRB[1]) begin
                            txdata_reg[15:8] <= PWDATA[15:8];
                        end
                        if (PSTRB[2]) begin
                            txdata_reg[23:16] <= PWDATA[23:16];
                        end
                        if (PSTRB[3]) begin
                            txdata_reg[31:24] <= PWDATA[31:24];
                        end
                    end

                    CONFIG_ADDR: begin
                        if (PSTRB[0]) begin
                            config_reg[7:0] <= PWDATA[7:0];
                        end
                        if (PSTRB[1]) begin
                            config_reg[15:8] <= PWDATA[15:8];
                        end
                        if (PSTRB[2]) begin
                            config_reg[23:16] <= PWDATA[23:16];
                        end
                        if (PSTRB[3]) begin
                            config_reg[31:24] <= PWDATA[31:24];
                        end
                    end

                    default: begin
                    end
                endcase
            end
        end
    end

    //protection logic
    always_comb begin
        prot_error = 1'b0;

        //for CONFIG register, we require secure + priviledge access
        if (PADDR == CONFIG_ADDR) begin
            
            //must be priviledge
            if (PPROT[0] == 1'b0) begin
                prot_error = 1'b1;
            end

            //must be secure
            if (PPROT[1] == 1'b1) begin
                prot_error = 1'b1;
            end
        end
    end


    //PSLVERR Generation
    always_comb begin
        pslverr_next = 1'b0;

        //error is valid only during transfer completion
        if (PSEL && PENABLE && PREADY) begin
            
            //invalid address
            case (PADDR) 
                CTRL_ADDR,
                STATUS_ADDR,
                TXDATA_ADDR,
                CONFIG_ADDR,
                RXDATA_ADDR: begin
                    pslverr_next = 1'b0;
                end
                default: begin
                    pslverr_next = 1'b1;
                end
            endcase

            //write to RO(READ ONLY) registers
            if (PWRITE) begin
                if (PADDR == STATUS_ADDR || PADDR == RXDATA_ADDR) begin
                    pslverr_next = 1'b1;
                end
            end

            //protection violation
            if (prot_error) begin
                pslverr_next = 1'b1;
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

    assign PSLVERR = pslverr_next;

    //assertions
    `ifdef ASSERTIONS
        `include "apb4_assertions.sv"
    `endif

endmodule