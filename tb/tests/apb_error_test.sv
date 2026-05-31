class apb_error_test extends apb_base_test;

    `uvm_component_utils(apb_error_test)

    apb_invalid_addr_seq inv_seq;
    apb_ro_write_seq     ro_seq;
    apb_prot_error_seq   prot_seq;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        inv_seq = apb_invalid_addr_seq::type_id::create("inv_seq");

        ro_seq = apb_ro_write_seq::type_id::create("ro_seq");

        prot_seq = apb_prot_error_seq::type_id::create("prot_seq");

        inv_seq.start(env.agent.seqr);

        ro_seq.start(env.agent.seqr);

        prot_seq.start(env.agent.seqr);

        #100;
        phase.drop_objection(this);
    endtask
endclass