/* this is the basics of the code
This is also called as a configurtor instruction, and not for physical design 
the syntax of this timescale is `timescale <Reference_Time> / <Time_Precision>
*/
`timescale 1ns / 1ps
//since I'm working on verilog for the first time, I'm going to use soo many comments for understanding the code and it's structutre
//every code has to start with the folllowing codes, module <module_name>(<parameters>); <contents> endmodule
module program_counter (input  wire clk, input  wire rst, input wire [31:0] pc_next, output reg [31:0] pc );
    //After the defination of the module is done, we will have to write the conditions and all for what this is working 
    // Update the Program Counter on every rising edge of the clock
    //always means, whatever happens run it every time.It's syntax being, always @ (@ means at event) (<condition of event)> begin <statements> end 
    always @(posedge clk) begin // posedge = register updates after the clock rises from low to high 
        //the if else condition works in the following syntax
        /* 
        if (<condition>) begin  
            <statement>
        end else if (<condition>) begin 
            <statement>
        end else if (<condition>) begin
            <statement>
        end */
        if (rst) begin //rst is reset pin
            pc <= 32'h00000000; // When it's true, we reset PC to address 0
        end else begin
            pc <= pc_next;      // When it's false, we update PC to the next address. Next address = Current PC address + 4 bytes. BUT <= is not normal assignation, but it's caled non-blocking assignment,
            // non-blocking assignment means that the assignment happens at the same clock cycle and not in the next clock cycle, it does the following
            /* if the following code is there
            A <= B
            C <= A 
            then it means to the computer:
            Do not update anything yet. Just look at the current values. Ready? Okay, simultaneously push B into A, and push the old value of A into C.
            */
        end
    end // Rule of thumb: Always use <= when you are inside an always @(posedge clk) block.
endmodule