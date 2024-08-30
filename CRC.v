module CRC #( parameter Seed) (
	input  wire  		DATA,
	input  wire 		CLK,
	input  wire 		RST,
	input  wire 		ACTIVE,
	output reg  		CRC,
	output reg  		Valid
	);

reg[7:0] LFSR;

wire Feedback;
reg count;
assign Feedback = LFSR[0] ^ DATA;

always@(posedge CLK or negedge RST)
begin
	if (!RST)
		begin
			LFSR <= Seed;
			CRC <= 1'b0;
			Valid <= 1'b0;
			count <= 0;
		end
	else if(ACTIVE)
		begin
			count <= 0;
			Valid <= 1'b0;
			LFSR[7] <= Feedback; 	 
			LFSR[6] <= LFSR[7] ^ Feedback;
			LFSR[5] <= LFSR[6];
			LFSR[4] <= LFSR[5];
			LFSR[3] <= LFSR[4];
			LFSR[2] <= LFSR[3] ^ Feedback;
			LFSR[1] <= LFSR[2];
			LFSR[0] <= LFSR[1];
		end
	else
	    begin
	    	if (count <= 8) begin
				{LFSR[6:0],CRC} <= LFSR ;
				Valid <= 1'b1;
				CRC <= LFSR[0];
				LFSR[0] <= LFSR[1];
				LFSR[1] <= LFSR[2];
				LFSR[2] <= LFSR[3];
				LFSR[3] <= LFSR[4];
				LFSR[4] <= LFSR[5];
				LFSR[5] <= LFSR[6];
				LFSR[6] <= LFSR[7];
				count = count + 1;
			end
			else begin
				Valid <= 0;
			end
		end
end

endmodule