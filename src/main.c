#include <stdio.h>
#include "xil_printf.h"
#include "xil_io.h"
#include "xparameters.h"

// to be modified
#define BRAM_BASEADDR XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR
#define INST_ADDR XPAR_AXI_GPIO_0_BASEADDR
#define k_ADDR (XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 0)
#define Kx_ADDR (XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 8)
#define Ky_ADDR (XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 16)
#define Mx_ADDR (XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 24)
#define My_ADDR (XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 32)
#define Gx_ADDR (XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 40)
#define Gy_ADDR (XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 48)
#define C1x_ADDR (XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 56)
#define C1y_ADDR (XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 64)
#define C2x_ADDR (XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 72)
#define C2y_ADDR (XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 80)
#define r_ADDR (XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 88)
#define done_ADDR (XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 96)


u32 inst;
u64 k, Kx, Ky, Mx, My, Gx, Gy, C1x, C1y, C2x, C2y, r;

void Gen_key();
void Encrypt();
void Decrypt();
void delay_enough_time();


int main(){
    inst = 0;
    Gx = 3124469192170877657;
    Gy = 4370601445727723733;
    u32 data;
    Xil_Out32(INST_ADDR, inst);

    data = Gx & 0x00000000ffffffff;
    Xil_Out32(Gx_ADDR, data);
    //printf("\r\n %x\r\n" ,data);
    data = Gx >> 32;
    Xil_Out32(Gx_ADDR + 4, data);
    //printf("\r\n %x\r\n" ,data);
    data = Gy & 0x00000000ffffffff;
    Xil_Out32(Gy_ADDR, data);
    data = Gy >> 32;
    Xil_Out32(Gy_ADDR + 4, data);
    Xil_Out32(done_ADDR, 0);
    while(1){
        printf("\r\nPlease choose operation\r\n");
        printf("\r\n(1: generate key, 2: encrypt, 3: decrypt)\r\n");
        scanf("%d", &inst);
        printf("\rmode is %d\r\n" ,inst);

        if(inst == 1) {
            Gen_key();
        }
        else if(inst == 2) {
            Encrypt();
        }
        else if(inst == 3) {
            Decrypt();
        }
        else {
            printf("\r\nInput error, please try again.\r\n");
        }
    }


    return 0;
}

void Gen_key(){
    // setup the parameters
    u32 data;
    printf("\r\nPlease input private key k : (in hex)\r\n");
    scanf("%llx", &k);
    printf("\r k is : %llx\r\n\n" , k);
    data = k & 0x00000000ffffffff;
    Xil_Out32(k_ADDR, data);
    data = k >> 32;
    Xil_Out32(k_ADDR + 4, data);

    // start computation
    Xil_Out32(INST_ADDR, inst);
    delay_enough_time();

    // get result & output
    Kx = Xil_In32(Kx_ADDR + 4);
    //printf("123456abKx = %llx (in hex)\r\n", Kx);
    Kx = Kx << 32;
    //printf("123456abKx = %llx (in hex)\r\n", Kx);
    Kx += Xil_In32(Kx_ADDR);
    //printf("123456abKx = %llx (in hex)\r\n", Kx);
    Ky = Xil_In32(Ky_ADDR + 4);
    Ky = Ky << 32;
    Ky += Xil_In32(Ky_ADDR);

    printf("Public Key :\r\n");
    printf("Kx = %llx (in hex)\r\n", Kx);
    printf("Ky = %llx (in hex)\r\n", Ky);

    // reset instruction register
    inst = 0;
    Xil_Out32(INST_ADDR, inst);
}


void Encrypt(){
    // setup the parameters
    u32 data;
    printf("\r\nPlease input x position of public key Kx : (in hex)\r\n");
    scanf("%llx", &Kx);
    printf("\rKx is %llx\r\n" ,Kx);

    printf("\r\nPlease input y position of public key Ky : (in hex)\r\n");
    scanf("%llx", &Ky);
    printf("\rKy is %llx\r\n" ,Ky);

    printf("\r\nPlease input x position of message Mx : (in hex)\r\n");
    scanf("%llx", &Mx);
    printf("\rMx is %llx\r\n" ,Mx);

    printf("\r\nPlease input y position of message My : (in hex)\r\n");
    scanf("%llx", &My);
    printf("\rMy is %llx\r\n" ,My);

    printf("\r\nPlease input a random number r for encryption : (in hex)\r\n");
    scanf("%llx", &r);
    printf("\r r is %llx\r\n" ,r);

    data = Kx & 0x00000000ffffffff;
    Xil_Out32(Kx_ADDR, data);
    data = Kx >> 32;
    Xil_Out32(Kx_ADDR + 4, data);
    data = Ky & 0x00000000ffffffff;
    Xil_Out32(Ky_ADDR, data);
    data = Ky >> 32;
    Xil_Out32(Ky_ADDR + 4, data);
    data = Mx & 0x00000000ffffffff;
    Xil_Out32(Mx_ADDR, data);
    data = Mx >> 32;
    Xil_Out32(Mx_ADDR + 4, data);
    data = My & 0x00000000ffffffff;
    Xil_Out32(My_ADDR, data);
    data = My >> 32;
    Xil_Out32(My_ADDR + 4, data);
    data = r & 0x00000000ffffffff;
    Xil_Out32(r_ADDR, data);
    data = r >> 32;
    Xil_Out32(r_ADDR + 4, data);

    // start computation
    Xil_Out32(INST_ADDR, inst);
    delay_enough_time();

    // get result & output
    C1x = Xil_In32(C1x_ADDR + 4);
    C1x = C1x << 32;
    C1x += Xil_In32(C1x_ADDR);
    C1y = Xil_In32(C1y_ADDR + 4);
    C1y = C1y << 32;
    C1y += Xil_In32(C1y_ADDR);

    C2x = Xil_In32(C2x_ADDR + 4);
    C2x = C2x << 32;
    C2x += Xil_In32(C2x_ADDR);
    C2y = Xil_In32(C2y_ADDR + 4);
    C2y = C2y << 32;
    C2y += Xil_In32(C2y_ADDR);

    printf("Encrypted data :\r\n");
    printf("C1x = %llx (in hex)\r\n", C1x);
    printf("C1y = %llx (in hex)\r\n", C1y);
    printf("C2x = %llx (in hex)\r\n", C2x);
    printf("C2y = %llx (in hex)\r\n", C2y);

    // reset instruction register
    inst = 0;
    Xil_Out32(INST_ADDR, inst);
}

void Decrypt(){
    // setup the parameters
    u32 data;
    printf("\r\nPlease input private key k : (in hex)\r\n");
    scanf("%llx", &k);
    printf("\rk is %llx\r\n" ,k);

    printf("\r\nPlease input encrypted data C1x : (in hex)\r\n");
    scanf("%llx", &C1x);
    printf("\rC1x is %llx\r\n" ,C1x);

    printf("\r\nPlease input encrypted data C1y : (in hex)\r\n");
    scanf("%llx", &C1y);
    printf("\rC1y is %llx\r\n" ,C1y);

    printf("\r\nPlease input encrypted data C2x : (in hex)\r\n");
    scanf("%llx", &C2x);
    printf("\rC2x is %llx\r\n" ,C2x);

    printf("\r\nPlease input encrypted data C2y : (in hex)\r\n");
    scanf("%llx", &C2y);
    printf("\rC2y is %llx\r\n" ,C2y);


    data = k & 0x00000000ffffffff;
    Xil_Out32(k_ADDR, data);
    data = k >> 32;
    Xil_Out32(k_ADDR + 4, data);
    data = C1x & 0x00000000ffffffff;
    Xil_Out32(C1x_ADDR, data);
    data = C1x >> 32;
    Xil_Out32(C1x_ADDR + 4, data);
    data = C1y & 0x00000000ffffffff;
    Xil_Out32(C1y_ADDR, data);
    data = C1y >> 32;
    Xil_Out32(C1y_ADDR + 4, data);
    data = C2x & 0x00000000ffffffff;
    Xil_Out32(C2x_ADDR, data);
    data = C2x >> 32;
    Xil_Out32(C2x_ADDR + 4, data);
    data = C2y & 0x00000000ffffffff;
    Xil_Out32(C2y_ADDR, data);
    data = C2y >> 32;
    Xil_Out32(C2y_ADDR + 4, data);

    // start computation
    Xil_Out32(INST_ADDR, inst);
    delay_enough_time();

    // get result & output
    Mx = Xil_In32(Mx_ADDR + 4);
    Mx = Mx << 32;
    Mx += Xil_In32(Mx_ADDR);

    My = Xil_In32(My_ADDR + 4);
    My = My << 32;
    My += Xil_In32(My_ADDR);

    printf("Decrypted message :\r\n");
    printf("Mx = %llx (in hex)\r\n", Mx);
    printf("My = %llx (in hex)\r\n", My);

    // reset instruction register
    inst = 0;
    Xil_Out32(INST_ADDR, inst);
}


void delay_enough_time(){
    u32 data = Xil_In32(done_ADDR);
    while(data != 1){
        data = Xil_In32(done_ADDR);
    }
    return;
}
