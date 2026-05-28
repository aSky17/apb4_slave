class apb_smoke_test extends apb_base_test;

    `uvm_component_utils(apb_smoke_test)

    apb_single_write_seq single_write_seq;
    apb_single_read_seq single_read_seq;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);

        super.run_phase(phase);
        phase.raise_objection(this);

        single_write_seq = apb_single_write_seq::type_id::create("single_write_seq");
        single_read_seq = apb_single_read_seq::type_id::create("single_read_seq");

        //write
        single_write_seq.start(env.agent.seqr);

        //read
        single_read_seq.start(env.agent.seqr);
        #100;
        phase.drop_objection(this);
    endtask
endclass