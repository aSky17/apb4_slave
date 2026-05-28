class apb_wait_seq extends apb_base_seq;

    `uvm_object_utils(apb_wait_seq)

    apb_seq_item tr;

    function new(string name = "apb_wait_seq");
        super.new(name);
    endfunction

    task body();

        repeat(5) begin
            tr = apb_seq_item::type_id::create("tr");

            start_item(tr);

            tr.addr = CTRL_ADDR;
            tr.write = $urandom_range(0,1);
            tr.wdata = $random;
            tr.strb = 4'b1111;
            tr.prot = 3'b000;

            finish_item(tr);

            `uvm_info("WAIT_SEQ",
                      $sformatf(
                        "WAIT transfer addr=%h write=%0d data=%h",
                        tr.addr,
                        tr.write,
                        tr.wdata
                      ),
                      UVM_LOW)
        end
    endtask
endclass