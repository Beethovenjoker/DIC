module MedianFinder_7num(
    input  [3:0] num1, 
    input  [3:0] num2, 
    input  [3:0] num3, 
    input  [3:0] num4, 
    input  [3:0] num5, 
    input  [3:0] num6, 
    input  [3:0] num7,  
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

    Comparator2 com_5(
        .A(num5),
        .B(num6),
        .min(),
        .max()
    );

    Comparator2 com_6(
        .A(com_3.min),
        .B(com_5.min),
        .min(),
        .max()
    );

    Comparator2 com_7(
        .A(com_5.max),
        .B(com_4.max),
        .min(),
        .max()
    );

    MedianFinder_5num median_5(
	.num1(com_3.max),
	.num2(com_6.max),
	.num3(com_7.min),
	.num4(com_4.min),
	.num5(num7),
	.median()
    );

    assign median = median_5.median;
endmodule
