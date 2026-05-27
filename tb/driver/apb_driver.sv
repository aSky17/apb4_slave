class apb_driver extends uvm_driver #(apb_seq_item);

    `uvm_component_utils(apb_driver)

    virtual apb_if vif;

    apb_seq_item req;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(virtual apb_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRIVER","Unable to get vif")
    endfunction

    task run_phase(uvm_phase phase);

        forever begin
            seq_item_port.get_next_item(req);

            drive_transfer(req);

            seq_item_port.item_done();

        end
    endtask

    task drive_transfer(apb_seq_item tr);

        //SETUP phase
        @(posedge vif.PCLK);

        vif.PSEL <= 1'b1;
        vif.PENABLE <= 1'b0;

        vif.PADDR <= tr.addr;
        vif.PWRITE <= tr.write;
        vif.PWDATA <= tr.wdata;
        vif.PSTRB <= tr.strb;
        vif.PPROT <= tr.prot;

        //ACCESS phase
        @(posedge vif.PCLK);

        vif.PENABLE <= 1'b1;

        while(vif.PREADY == 0) begin
            @(posedge vif.PCLK);
        end 

        //read data
        if(!tr.write) begin
            tr.rdata = vif.PRDATA;
        end

        tr.slverr = vif.PSLVERR;

        //Complete transfer
        @(posedge vif.PCLK);
        vif.PSEL <= 1'b0;
        vif.PENABLE <= 1'b0;

    endtask

endclass