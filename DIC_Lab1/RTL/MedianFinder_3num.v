module MedianFinder_3num(
    input  [3:0] num1, 
    input  [3:0] num2, 
    input  [3:0] num3,  
    output [3:0] median  
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
        .A(com_1.min),
        .B(com_2.min),
        .min(),
        .max()
    );

    assign median = com_3.max;
endmodule
