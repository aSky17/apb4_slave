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

        vif.PSEL    <= 1'b1;
        vif.PENABLE <= 1'b0;
        vif.PADDR   <= tr.addr;
        vif.PWRITE  <= tr.write;
        vif.PWDATA  <= tr.wdata;
        vif.PSTRB   <= tr.strb;
        vif.PPROT   <= tr.prot;

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

        //Complete transfer — check for back-to-back
        seq_item_port.item_done();          // release current item first

        seq_item_port.try_next_item(req);   // non-blocking: gets next item if ready

        if(req != null) begin
            // Back-to-back: stay in SETUP, keep PSEL high, drop PENABLE
            @(posedge vif.PCLK);
            vif.PENABLE <= 1'b0;
            vif.PADDR   <= req.addr;
            vif.PWRITE  <= req.write;
            vif.PWDATA  <= req.wdata;
            vif.PSTRB   <= req.strb;
            vif.PPROT   <= req.prot;

            // drive the next transfer recursively
            // ACCESS phase for the new item
            @(posedge vif.PCLK);
            vif.PENABLE <= 1'b1;

            while(vif.PREADY == 0) begin
                @(posedge vif.PCLK);
            end

            if(!req.write) begin
                req.rdata = vif.PRDATA;
            end

            req.slverr = vif.PSLVERR;

            seq_item_port.item_done();      // release the b2b item

        end
        else begin
            // No next item — go to IDLE
            @(posedge vif.PCLK);
            vif.PSEL    <= 1'b0;
            vif.PENABLE <= 1'b0;
        end

    endtask

endclass