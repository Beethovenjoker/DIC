module MedianFinder_5num(
    input  [3:0] num1, 
    input  [3:0] num2, 
    input  [3:0] num3, 
    input  [3:0] num4, 
    input  [3:0] num5,  
    output [3:0] median  
);

    Comparator2 com_1(
        .A(num1),
        .B(num2),
        .min(),
        .max()
    );

    Comparator2 com_2(
        .A(num3),
        .B(num4),
        .min(),
        .max()
    );

    Comparator2 com_3(
        .A(com_1.min),
        .B(com_2.min),
        .min(),
        .max()
    );

    Comparator2 com_4(
        .A(com_1.max),
        .B(com_2.max),
        .min(),
        .max()
    );

    MedianFinder_3num med3(
	.num1(com_3.max),
	.num2(com_4.min),
	.num3(num5),
	.median()
    );

	assign median = med3.median;
endmodule
