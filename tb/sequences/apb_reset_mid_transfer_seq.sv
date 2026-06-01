class apb_reset_mid_transfer_seq extends apb_base_seq;

    `uvm_object_utils(apb_reset_mid_transfer_seq)

    apb_seq_item tr;

    virtual apb_if vif;

    function new(string name = "apb_reset_mid_transfer_seq");
        super.new(name);
    endfunction

    task body();
        if(!uvm_config_db #(virtual apb_if)::get(
                null,
                "",
                "vif",
                vif))
        begin
            `uvm_fatal("RESET_SEQ","Cannot get vif")
        end
            
        tr = apb_seq_item::type_id::create("tr");

        start_item(tr);

        tr.addr  = CTRL_ADDR;
        tr.write = 1;
        tr.wdata = 32'hAAAA_BBBB;
        tr.strb  = 4'b1111;
        tr.prot  = 3'b000;

        finish_item(tr);

        wait(vif.PSEL && vif.PENABLE);
        vif.PRESETn <= 0;

        repeat(3) @(posedge vif.PCLK);
        vif.PRESETn <= 1;
    endtask
endclass