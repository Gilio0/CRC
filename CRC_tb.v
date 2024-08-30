`timescale 1us/1ns
module CRC_tb ();

  	reg    			DATA_tb;
  	reg 			CLK_tb;
  	reg 			RST_tb;
  	reg 			ACTIVE_tb;
  	wire  			CRC_tb;
  	wire  			Valid_tb;

 	localparam Clock_PERIOD = 0.1;
 	localparam CRC_WD_tb = 8 ;
	localparam Test_Cases = 10 ;
	parameter Seed = 8'hD8;
	
	integer			index;

	reg    [CRC_WD_tb-1:0]   DATA_h   		[Test_Cases-1:0] ;
	reg    [CRC_WD_tb-1:0]   Expec_Outs   	[Test_Cases-1:0] ;

always #(Clock_PERIOD/2)  CLK_tb = ~CLK_tb ;

CRC #(.Seed(Seed)) DUT
(
.DATA(DATA_tb),
.CLK(CLK_tb),
.RST(RST_tb),
.CRC(CRC_tb),
.ACTIVE(ACTIVE_tb),
.Valid(Valid_tb)
);

task initialize;
 begin
  CLK_tb  = 'b0;
  RST_tb  = 'b1;
  ACTIVE_tb = 'b0;
  DATA_tb = 0;
 end
endtask

task reset;
 begin
  RST_tb =  'b1;
  #0.02
  RST_tb =  'b0;
  #0.02
  RST_tb  = 'b1;
 end
endtask

task do_oper;
 input  reg [7:0] d; 
 integer i;
 begin
   reset();
   ACTIVE_tb = 1'b1;
   for(i=0; i<8; i=i+1)
   begin
    DATA_tb = d[i];
    #(Clock_PERIOD);
   end
   ACTIVE_tb = 1'b0;   
 end
endtask

task check_out;
 input  reg     [CRC_WD_tb-1:0]     expec_out ;
 input  integer                      Oper_Num ; 

 integer i;
 
 reg    [CRC_WD_tb-1:0]     gener_out ;

 begin
  ACTIVE_tb = 1'b0;
  RST_tb = 1;
  @(posedge Valid_tb)
  #0.05
  for(i=0; i<8; i=i+1)
   begin
    gener_out[i] <= CRC_tb;
    #(Clock_PERIOD);
   end
   if(gener_out == expec_out)
    begin
     $display("Test Case %d is succeeded",Oper_Num);
    end
   else
    begin
     $display("Test Case %d is failed, expected:0x %0h,  Out:0x %0h", Oper_Num, expec_out, gener_out);
    end
   ACTIVE_tb = 1'b1;
 end
endtask

initial 
 begin
 
 // System Functions
 $dumpfile("CRC.vcd") ;       
 $dumpvars; 
 
 // Read Input Files
 $readmemh("DATA_h.txt", DATA_h);
 $readmemh("Expec_Out_h.txt", Expec_Outs);

 // initialization
 initialize() ;

 // Test Cases
 for (index=0;index<Test_Cases;index=index+1)
  begin
   do_oper(DATA_h[index]);
   check_out(Expec_Outs[index],index);// check output response
  end

 #1
 $finish ;

 end

endmodule