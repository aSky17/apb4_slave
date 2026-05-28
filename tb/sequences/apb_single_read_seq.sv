class apb_single_read_seq extends apb_base_seq;

    `uvm_object_utils(apb_single_read_seq)

    apb_seq_item tr;

    function new(string name = "apb_single_read_seq");
        super.new(name);
    endfunction

    task body();

        tr = apb_seq_item::type_id::create("tr");

        start_item(tr);

            tr.addr = CTRL_ADDR;
            tr.write = 1'b0;
            tr.strb = 4'b0000;
            tr.prot = 3'b000;

        finish_item(tr);

        `uvm_info("SINGLE_READ_SEQUENCE", 
                    $sformatf("Read addr=%h data=%h", tr.addr, tr.rdata),
                    UVM_LOW)
    endtask
endclass