class apb_data_test extends apb_base_test;

    `uvm_component_utils(apb_data_test)

    apb_data_seq data_seq;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);

        phase.raise_objection(this);

        data_seq = apb_data_seq::type_id::create(
                        "data_seq");

        data_seq.start(env.agent.seqr);
        #100;
        phase.drop_objection(this);

    endtask

endclass