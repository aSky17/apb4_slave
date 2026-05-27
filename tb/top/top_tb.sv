module top_tb;

    import uvm_pkg::*;
    import apb_tb_pkg::*;
    import apb4_pkg::*;

    logic PCLK;

    always #5 PCLK = ~PCLK;

    apb_if apb_vif(PCLK);

    //DUT
    
    apb4_slave dut(
        .PCLK      (PCLK),
        .PRESETn   (apb_vif.PRESETn),

        .PADDR     (apb_vif.PADDR),
        .PSEL      (apb_vif.PSEL),
        .PENABLE   (apb_vif.PENABLE),
        .PWRITE    (apb_vif.PWRITE),
        .PWDATA    (apb_vif.PWDATA),
        .PSTRB     (apb_vif.PSTRB),
        .PPROT     (apb_vif.PPROT),

        .PRDATA    (apb_vif.PRDATA),
        .PREADY    (apb_vif.PREADY),
        .PSLVERR   (apb_vif.PSLVERR)
    );

    initial begin
        PCLK = 0;

        apb_vif.PRESETn = 0;

        repeat(5) @(posedge PCLK);

        apb_vif.PRESETn = 1; //deasserted
    end

    initial begin
        uvm_config_db #(virtual apb_if)::set(
            null,
            "*",
            "vif",
            apb_vif
        );

        run_test("apb_base_test");
    end
endmodule