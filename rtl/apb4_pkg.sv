package apb4_pkg;

    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;

    typedef enum logic [1:0] {
        IDLE = 2'b00,
        SETUP = 2'b01,
        ACCESS = 2'b10
    } apb_state_t;

    localparam logic [ADDR_WIDTH-1:0] CTRL_ADDR = 32'h0000_0000;
    localparam logic [ADDR_WIDTH-1:0] STATUS_ADDR = 32'h0000_0004;
    localparam logic [ADDR_WIDTH-1:0] TXDATA_ADDR = 32'h0000_0008;
    localparam logic [ADDR_WIDTH-1:0] RXDATA_ADDR = 32'h0000_000C;
    localparam logic [ADDR_WIDTH-1:0] CONFIG_ADDR = 32'h0000_0010;
    localparam int STRB_WIDTH = DATA_WIDTH/8;

endpackage