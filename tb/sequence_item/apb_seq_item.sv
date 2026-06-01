class apb_seq_item extends uvm_sequence_item;

    rand bit [31:0] addr;
    rand bit write;
    rand bit [31:0] wdata;
    bit [31:0] rdata;

    rand bit [3:0] strb;
    rand bit [2:0] prot;
    bit slverr;
    bit exp_slverr; //for error testing, it means i expect an error
    bit reset_seen;

    `uvm_object_utils_begin(apb_seq_item)

        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(write, UVM_ALL_ON)
        `uvm_field_int(wdata, UVM_ALL_ON)
        `uvm_field_int(rdata, UVM_ALL_ON)
        `uvm_field_int(strb, UVM_ALL_ON)
        `uvm_field_int(prot, UVM_ALL_ON)
        `uvm_field_int(slverr, UVM_ALL_ON)

    `uvm_object_utils_end

    //it does mean pass the class name, its a default name incase a user does not
    //pass any value which creating the object by calling the constructor, take this
    function new(string name = "apb_seq_item"); 
        super.new(name);
    endfunction
endclass