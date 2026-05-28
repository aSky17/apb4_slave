class apb_multiple_write_seq extends apb_base_seq;

    `uvm_object_utils(apb_multiple_write_seq)

    apb_seq_item tr;

    logic [31:0] addr_q[$];
    logic [31:0] data_q[$];

    function new(string name = "apb_multiple_write_seq");
        super.new(name);

        addr_q.push_back(CTRL_ADDR);
        addr_q.push_back(TXDATA_ADDR);
        addr_q.push_back(CONFIG_ADDR);

        data_q.push_back(32'h1111_1111);
        data_q.push_back(32'h2222_2222);
        data_q.push_back(32'h3333_3333);
        
    endfunction

    task body();
        for (int i = 0; i < addr_q.size();i++) begin
            tr = apb_seq_item::type_id::create($sformatf("tr_%0d",i));

            start_item(tr);

            tr.addr = addr_q[i];
            tr.write = 1'b1;
            tr.wdata = data_q[i];
            tr.strb = 4'b1111;
            tr.prot = 3'b001;

            finish_item(tr);

            `uvm_info("Multiple_Write",
                        $sformatf("WRITE addr=%h data=%h",tr.addr, tr.wdata),
                        UVM_LOW)
        end
    endtask

endclass