class apb_wait_test extends apb_base_test;

    `uvm_component_utils(apb_wait_test)

    apb_wait_seq wait_seq;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);

        super.run_phase(phase);
        
        phase.raise_objection(this);

        wait_seq = apb_wait_seq::type_id::create("wait_seq");
        wait_seq.start(env.agent.seqr);
        #1000;
        
        phase.drop_objection(this);

    endtask

endclass