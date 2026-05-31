class apb_pstrb_test extends apb_base_test;

    `uvm_component_utils(apb_pstrb_test)

    apb_pstrb_seq pstrb_seq;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        
        phase.raise_objection(this);
        
        super.run_phase(phase);

        pstrb_seq = apb_pstrb_seq::type_id::create("pstrb_seq");

        pstrb_seq.start(env.agent.seqr);
        #100;

        phase.drop_objection(this);
    endtask
endclass