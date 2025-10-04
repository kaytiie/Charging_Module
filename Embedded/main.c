#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"

int *drop_counting, *sendtohost_counting, *forward_counting, *drop_capacity, *sendtohost_capacity, *forward_capacity, *check_false_policy;
int main()
{
    init_platform();
    	//read
    	// muốn đọc giá trị từ thanh ghi thì ta phải dùng con trỏ để trỏ đến địa chỉ của thanh ghi
        drop_counting = XPAR_REGISTER_READ_0_BASEADDR;
    	sendtohost_counting = XPAR_REGISTER_READ_0_BASEADDR + 4;
    	forward_counting = XPAR_REGISTER_READ_0_BASEADDR + 8;
    	drop_capacity = XPAR_REGISTER_READ_0_BASEADDR + 12;
    	sendtohost_capacity = XPAR_REGISTER_READ_0_BASEADDR + 16;
    	forward_capacity= XPAR_REGISTER_READ_0_BASEADDR + 20;
    	check_false_policy =XPAR_REGISTER_READ_0_BASEADDR + 24;

    	// write
    	// muốn ghi giá trị vào thanh ghi: ép hằng số địa chỉ thanh ghi đó thành con trỏ trỏ tới một vùng
    	// nhớ kiểu u32 tại địa chỉ XPAR_REGISTER_READ_0_BASEADDR + 64,
    	// sau đó gán giá trị vào *con trỏ đó

    	// id 0
    	// (volatile u32 *)(XPAR_REGISTER_READ_0_BASEADDR + 64) chỉ có thể gán nó cho biến con trỏ khác hoặc dùng nó, chứ k thể gán địa chỉ cho nó
    	*(volatile u32 *)(XPAR_REGISTER_READ_0_BASEADDR + 64) = 0;
    	*(volatile u32 *)(XPAR_REGISTER_READ_0_BASEADDR + 68) = 3;
    	*(volatile u32 *)(XPAR_REGISTER_READ_0_BASEADDR + 72) = 102400;
    	*(volatile u32 *)(XPAR_REGISTER_READ_0_BASEADDR + 76) = 71680;
    	*(volatile u32 *)(XPAR_REGISTER_READ_0_BASEADDR + 80) = 30720;

    	*(volatile u32 *)(XPAR_REGISTER_READ_0_BASEADDR + 84) = 11;
    	*(volatile u32 *)(XPAR_REGISTER_READ_0_BASEADDR + 88) = 81920;
    	*(volatile u32 *)(XPAR_REGISTER_READ_0_BASEADDR + 92) = 51200;
    	*(volatile u32 *)(XPAR_REGISTER_READ_0_BASEADDR + 96) = 30720;


    xil_printf("drop_counting        = %u\n\r", *drop_counting);
    xil_printf("sendtohost_counting  = %u\n\r", *sendtohost_counting);
    xil_printf("forward_counting     = %u\n\r", *forward_counting);
    xil_printf("drop_capacity        = %u\n\r", *drop_capacity);
    xil_printf("sendtohost_capacity  = %u\n\r", *sendtohost_capacity);
    xil_printf("forward_capacity     = %u\n\r", *forward_capacity);
    xil_printf("check_false_policy   = %u\n\r", *check_false_policy);

    cleanup_platform();
    return 0;
}

