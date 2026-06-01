class apb_pprot_test extends apb_base_test;

    `uvm_component_utils(apb_pprot_test)

    apb_secure_access_seq secure_seq;
    apb_user_access_seq user_seq;
    apb_nonsecure_access_seq ns_seq;
    apb_pprot_seq pprot_seq;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);

        phase.raise_objection(this);

        secure_seq = apb_secure_access_seq::type_id::create("secure_seq");

        user_seq = apb_user_access_seq::type_id::create("user_seq");

        ns_seq = apb_nonsecure_access_seq::type_id::create("ns_seq");

        pprot_seq = apb_pprot_seq::type_id::create("pprot_seq");

        secure_seq.start(env.agent.seqr);
        user_seq.start(env.agent.seqr);
        ns_seq.start(env.agent.seqr);
        pprot_seq.start(env.agent.seqr);

        #100;
        phase.drop_objection(this);
    endtask
endclass