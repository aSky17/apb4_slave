class apb_data_seq extends apb_base_seq;

    `uvm_object_utils(apb_data_seq)

    apb_seq_item wr_tr;
    apb_seq_item rd_tr;

    function new(string name = "apb_data_seq");
        super.new(name);
    endfunction

    task body();
        repeat(10) begin
            //write
            wr_tr = apb_seq_item::type_id::create("wr_tr");
            
            start_item(wr_tr);

            wr_tr.addr   = CTRL_ADDR;
            wr_tr.write  = 1'b1;
            wr_tr.wdata  = $random;
            wr_tr.strb   = 4'b1111;
            wr_tr.prot   = 3'b000;
            
            finish_item(wr_tr);

            // READBACK
            rd_tr = apb_seq_item::type_id::create("rd_tr");
            
            start_item(rd_tr);

            rd_tr.addr   = CTRL_ADDR;
            rd_tr.write  = 1'b0;
            rd_tr.strb   = 4'b0000;
            rd_tr.prot   = 3'b000;

            finish_item(rd_tr);

        end 
    endtask
endclass