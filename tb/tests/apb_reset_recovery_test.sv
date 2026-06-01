class apb_reset_recovery_test extends apb_base_test;

    `uvm_component_utils(apb_reset_recovery_test)

    apb_reset_mid_transfer_seq rst_seq;
    apb_single_write_seq write_seq;
    apb_single_read_seq read_seq;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    task run_phase(uvm_phase phase);

        phase.raise_objection(this);

        rst_seq = apb_reset_mid_transfer_seq::type_id::create("rst_seq");

        write_seq =apb_single_write_seq::type_id::create("write_seq");

        read_seq =apb_single_read_seq::type_id::create("read_seq");

        rst_seq.start(env.agent.seqr);

        write_seq.start(env.agent.seqr);

        read_seq.start(env.agent.seqr);

        #100;
        phase.drop_objection(this);

    endtask

endclass