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
    input logic [STRB_WIDTH-1:0] PSTRB,
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
    logic [ADDR_WIDTH:0] ctrl_reg;
    logic [ADDR_WIDTH:0] status_reg;
    logic [ADDR_WIDTH:0] txdata_reg;
    logic [ADDR_WIDTH:0] rxdata_reg;
    logic [ADDR_WIDTH:0] config_reg;

    //wait counter
    // update: does not fail for WAIT_CYCLES = 0
    localparam WAIT_W = (WAIT_CYCLES > 0) ? $clog2(WAIT_CYCLES+1) : 1;
    logic [WAIT_W-1:0] wait_count;

    //internal error signal
    logic pslverr_next;

    //protection policy
    logic prot_error;

    //helper wires
    logic setup_phase;
    logic access_phase;
    logic transfer_done;

    assign setup_phase   = PSEL && !PENABLE;
    assign access_phase  = PSEL && PENABLE;
    assign transfer_done = PSEL && PENABLE && PREADY;

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
                if (setup_phase) begin
                    next_state = SETUP;
                end
            end

            SETUP: begin
                next_state = ACCESS;
            end

            ACCESS: begin
                if (PREADY) begin
                    if (setup_phase) begin
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
    assign PREADY = (state == ACCESS) && (wait_count == 0);

    //address valid logic 
    function automatic logic is_valid_addr
    (
        input logic [ADDR_WIDTH-1:0] addr
    );
        case(addr)
            CTRL_ADDR,
            STATUS_ADDR,
            TXDATA_ADDR,
            RXDATA_ADDR,
            CONFIG_ADDR:
                is_valid_addr = 1'b1;
            default:
                is_valid_addr = 1'b0;
        endcase
    endfunction

    //byte write logic 
    task automatic apply_pstrb_write
    (
        inout logic [DATA_WIDTH-1:0] reg_data,
        input logic [DATA_WIDTH-1:0] write_data,
        input logic [STRB_WIDTH-1:0] strb
    );
        for (int i = 0; i < STRB_WIDTH; i++) begin

            if (strb[i]) begin
                reg_data[i*8 +: 8] = write_data[i*8 +: 8];
            end
        end
    endtask

    //write logic 
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            ctrl_reg <= 32'h0;
            status_reg <= 32'h0;
            txdata_reg <= 32'h0;
            rxdata_reg <= 32'h0;
            config_reg <= 32'h0;
        end else begin
            if (access_phase && PWRITE && PREADY && !PSLVERR && !prot_error) begin
                case(PADDR) 
                    CTRL_ADDR: begin
                        apply_pstrb_write(ctrl_reg, PWDATA, PSTRB);
                    end

                    TXDATA_ADDR: begin
                        apply_pstrb_write(txdata_reg, PWDATA, PSTRB);
                    end

                    CONFIG_ADDR: begin
                        apply_pstrb_write(config_reg, PWDATA, PSTRB);
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
        if (transfer_done) begin
            
            //invalid address
            if (!is_valid_addr(PADDR))
                pslverr_next = 1'b1;

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
        PRDATA = '0;

        if (access_phase && !PWRITE && PREADY) begin
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