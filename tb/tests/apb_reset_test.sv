class apb_reset_test extends apb_base_test;

    `uvm_component_utils(apb_reset_test)

    apb_reset_seq reset_seq;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        reset_seq = apb_reset_seq::type_id::create("reset_seq");

        reset_seq.start(env.agent.seqr);

        #100;
        phase.drop_objection(this);
    endtask
endclass