class apb_ro_write_seq extends apb_base_seq;

    `uvm_object_utils(apb_ro_write_seq)

    apb_seq_item tr;

    function new(string name = "apb_ro_write_seq");
        super.new(name);
    endfunction

    task body();
        tr = apb_seq_item::type_id::create("tr");

        start_item(tr);

        tr.addr = STATUS_ADDR;
        tr.write = 1'b1;
        tr.wdata = 32'h12345678;
        tr.strb = 4'b1111;
        tr.prot = 3'b000;

        tr.exp_slverr = 1;
        finish_item(tr);
    endtask
endclass