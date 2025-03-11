module MedianFinder_7num(
    input  	[3:0]  	num1  , 
	input  	[3:0]  	num2  , 
	input  	[3:0]  	num3  , 
	input  	[3:0]  	num4  , 
	input  	[3:0]  	num5  , 
	input  	[3:0]  	num6  , 
	input  	[3:0]  	num7  ,  
    output 	[3:0] 	median  
);

    Comparator2 com_1(
        .A(num1),
        .B(num2),
        .min(),
        .max()
    );

	Comparator2 com_2(
        .A(com_1.max),
        .B(num3),
        .min(),
        .max()
    );

    Comparator2 com_3(
        .A(com_2.max),
        .B(num4),
        .min(),
        .max()
    );

    Comparator2 com_4(
        .A(com_3.max),
        .B(num5),
        .min(),
        .max()
    );

    Comparator2 com_5(
        .A(com_4.max),
        .B(num6),
        .min(),
        .max()
    );

    Comparator2 com_6(
        .A(com_5.max),
        .B(num7),
        .min(),
        .max()
    );

    Comparator2 com_a(
        .A(com_5.min),
        .B(com_6.min),
        .min(),
        .max()
    );

	Comparator2 com_b(
        .A(com_4.min),
        .B(com_a.min),
        .min(),
        .max()
    );

	Comparator2 com_c(
        .A(com_3.min),
        .B(com_b.min),
        .min(),
        .max()
    );

    Comparator2 com_d(
        .A(com_2.min),
        .B(com_c.min),
        .min(),
        .max()
    );

    Comparator2 com_e(
        .A(com_1.min),
        .B(com_d.min),
        .min(),
        .max()
    );

    MedianFinder_5num median_5(
		.num1(com_a.max),
		.num2(com_b.max),
		.num3(com_c.max),
		.num4(com_d.max),
		.num5(com_e.max),
		.median()
	);

    assign median = median_5.median;
endmodule
