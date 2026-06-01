class apb_nonsecure_access_seq extends apb_base_seq;

    `uvm_object_utils(apb_nonsecure_access_seq)

    apb_seq_item tr;

    function new(string name="apb_nonsecure_access_seq");
        super.new(name);
    endfunction

    task body();

        tr = apb_seq_item::type_id::create("tr");

        start_item(tr);

        tr.addr = CONFIG_ADDR;
        tr.write = 1;
        tr.wdata = 32'h22222222;
        tr.strb = 4'b1111;

        // privileged + non-secure
        tr.prot = 3'b011;

        tr.exp_slverr = 1;

        finish_item(tr);

    endtask

endclass