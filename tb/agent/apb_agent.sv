class apb_agent extends uvm_agent;

    `uvm_component_utils(apb_agent)

    //component handles
    apb_driver drv;
    apb_monitor mon;
    apb_sequencer seqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);


        //this means current object handle
        //without this uvm wouldnt know where to place driver in the hierarchy
        drv = apb_driver::type_id::create("drv", this); //this means create driver named drv whose parent is this agent
        mon = apb_monitor::type_id::create("mon", this);
        seqr = apb_sequencer::type_id::create("seqr", this);

    endfunction

    //connect phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        //connecting driver and sequencer, without this driver cannot receive transactions
        drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction

endclass