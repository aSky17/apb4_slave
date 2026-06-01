class apb_monitor extends uvm_monitor;
    
    `uvm_component_utils(apb_monitor)

    virtual apb_if vif;

    uvm_analysis_port #(apb_seq_item) mon_ap; //used for broadcasting transactions

    function new(string name, uvm_component parent);
        super.new(name, parent);

        //creating analysis port object
        mon_ap = new("mon_ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(virtual apb_if)::get(this, "", "vif", vif))
            `uvm_fatal("MONITOR", "Unable to get vif")
    endfunction

    task run_phase(uvm_phase phase);
        
        apb_seq_item tr;
        
        forever begin
            @(posedge vif.PCLK);

            //detect valid apb transfer, means ACCESS phase completed successfully
            if (vif.PSEL && vif.PENABLE && vif.PREADY) begin
                
                //create transcation/transaction object
                tr = apb_seq_item::type_id::create("tr");

                //convert pin activity to transaction
                tr.addr   = vif.PADDR;
                tr.write  = vif.PWRITE;
                tr.wdata  = vif.PWDATA;
                tr.rdata  = vif.PRDATA;
                tr.strb   = vif.PSTRB;
                tr.prot   = vif.PPROT;
                tr.slverr = vif.PSLVERR;

                tr.exp_slverr = 0;
                // Predict expected PSLVERR
                // invalid address
                if(!(tr.addr inside {
                        CTRL_ADDR,
                        STATUS_ADDR,
                        TXDATA_ADDR,
                        RXDATA_ADDR,
                        CONFIG_ADDR
                    }))
                begin
                    tr.exp_slverr = 1;
                end

                // STATUS register is RO
                else if(tr.addr == STATUS_ADDR && tr.write)
                begin
                    tr.exp_slverr = 1;
                end

                // CONFIG register protection
                else if(tr.addr == CONFIG_ADDR)
                begin

                    // must be privileged
                    if(tr.prot[0] == 1'b0)
                        tr.exp_slverr = 1;

                    // must be secure
                    if(tr.prot[1] == 1'b1)
                        tr.exp_slverr = 1;

                end

                //broadcast transction
                mon_ap.write(tr);
            end
        end

    endtask
endclass
