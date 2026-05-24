module top;

    logic         PCLK;
    logic         PRESETn;

    logic [31:0]  PADDR;
    logic         PSEL;
    logic         PENABLE;
    logic         PWRITE;
    logic [31:0]  PWDATA;
    logic [3:0]   PSTRB;
    logic [2:0]   PPROT;

    logic [31:0]  PRDATA;
    logic         PREADY;
    logic         PSLVERR;

    // DUT
    apb4_slave dut (
        .PCLK      (PCLK),
        .PRESETn   (PRESETn),

        .PADDR     (PADDR),
        .PSEL      (PSEL),
        .PENABLE   (PENABLE),
        .PWRITE    (PWRITE),
        .PWDATA    (PWDATA),
        .PSTRB     (PSTRB),
        .PPROT     (PPROT),

        .PRDATA    (PRDATA),
        .PREADY    (PREADY),
        .PSLVERR   (PSLVERR)
    );

endmodule