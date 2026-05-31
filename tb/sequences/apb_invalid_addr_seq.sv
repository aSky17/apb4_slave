class apb_invalid_addr_seq extends apb_base_seq;

    `uvm_object_utils(apb_invalid_addr_seq)

    apb_seq_item tr;

    function new(string name = "apb_invalid_addr_seq");
        super.new(name);
    endfunction

    task body();
        tr = apb_seq_item::type_id::create("tr");

        start_item(tr);

        tr.addr = 32'hFFFF_FFFF;
        tr.write = 1'b1;
        tr.wdata = 32'hDEAD_BEEF;
        tr.strb = 4'b1111;
        tr.prot = 3'b000;

        tr.exp_slverr = 1;

        finish_item(tr);
    endtask
endclass