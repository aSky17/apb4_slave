class apb_raw_war_test extends apb_base_test;

    `uvm_component_utils(apb_raw_war_test)

    apb_multiple_write_seq wr_seq;
    apb_multiple_read_seq rd_seq;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);

        super.run_phase(phase);
        phase.raise_objection(this);

        wr_seq = apb_multiple_write_seq::type_id::create("wr_seq");
        rd_seq = apb_multiple_read_seq::type_id::create("rd_seq");

        //WAW
        wr_seq.start(env.agent.seqr);

        //RAW
        rd_seq.start(env.agent.seqr);

        //WAR
        wr_seq.start(env.agent.seqr);

        //RAW
        rd_seq.start(env.agent.seqr);

        #100;
        phase.drop_objection(this);
    endtask
endclass