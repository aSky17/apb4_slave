class apb_pprot_seq extends apb_base_seq;

    `uvm_object_utils(apb_pprot_seq)

    apb_seq_item tr;

    function new(string name = "apb_pprot_seq");
        super.new(name);
    endfunction

    task body();

        tr = apb_seq_item::type_id::create("tr");

        start_item(tr);

        tr.addr = CONFIG_ADDR;
        tr.write = 1;
        tr.wdata = $random;
        tr.strb = 4'b1111;

        tr.prot = $urandom_range(0,7);

        if((tr.prot[0] == 1'b1) && (tr.prot[1] == 1'b0)) begin
            tr.exp_slverr = 0;
        end else begin
            tr.exp_slverr = 1;
        end
        
        finish_item(tr);
    endtask
endclass