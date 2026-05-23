module top;

    logic         PCLK;
    logic         PRESETn;

    logic [31:0]  PADDR;
    logic         PSEL;
    logic         PENABLE;
    logic         PWRITE;
    logic [31:0]  PWDATA;

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

        .PRDATA    (PRDATA),
        .PREADY    (PREADY),
        .PSLVERR   (PSLVERR)
    );

endmodule