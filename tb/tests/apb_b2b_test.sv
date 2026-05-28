class apb_b2b_test extends apb_base_test;

    `uvm_component_utils(apb_b2b_test)

    apb_b2b_seq b2b_seq;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);

        super.run_phase(phase); //IMP, u might miss this
        phase.raise_objection(this);

        b2b_seq = apb_b2b_seq::type_id::create("b2b_seq");

        b2b_seq.start(env.agent.seqr);
        #100;
        phase.drop_objection(this);

    endtask

endclass