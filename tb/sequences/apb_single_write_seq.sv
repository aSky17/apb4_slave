class apb_single_write_seq extends apb_base_seq;

    `uvm_object_utils(apb_single_write_seq)

    apb_seq_item tr;

    function new(string name = "apb_single_write_seq");
        super.new(name);
    endfunction

    task body();

        tr = apb_seq_item::type_id::create("tr");

        start_item(tr);

        tr.addr = CTRL_ADDR;
        tr.write = 1'b1;
        tr.wdata = 32'hA5A5_1234;
        tr.strb = 4'b1111;
        tr.prot = 3'b000;
        
        finish_item(tr);

        `uvm_info("_SINGLE_WRITE_SEQUENCE",
                    $sformatf("Write addr=%h data=%h",tr.addr, tr.wdata),
                    UVM_LOW)
    endtask
endclass