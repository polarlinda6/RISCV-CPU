# init ELF
li x5, 0x000130cc  #data
li x6, 0x0000000b
sw x6, 0, x5
li x5, 0x000130c8
li x6, 0x0005deec
sw x6, 0, x5
li x5, 0x000130c4
li x6, 0xe66d1234
sw x6, 0, x5
li x5, 0x000130c0
li x6, 0xabcd330e
sw x6, 0, x5
li x5, 0x000130b8
li x6, 0x00000001
sw x6, 0, x5
li x5, 0x0001301c
li x6, 0x000133cc
sw x6, 0, x5
li x5, 0x00013018
li x6, 0x00013364
sw x6, 0, x5
li x5, 0x00013014
li x6, 0x000132fc
sw x6, 0, x5
li x5, 0x0001300c
li x6, 0x000100d0
sw x6, 0, x5
li x5, 0x00013008
li x6, 0x00010120
sw x6, 0, x5
li x5, 0x00013004
li x6, 0x00010074
sw x6, 0, x5
li x5, 0x00013440  #sdata
li x6, 0x00013010
sw x6, 0, x5
li x5, 0x00013438
li x6, 0x00013010
sw x6, 0, x5

li x5, 0x00012bf4  #rodata
li x6, 0xffffed58
sw x6, 0, x5
li x5, 0x00012bf0
li x6, 0xffffed1c
sw x6, 0, x5
li x5, 0x00012bec
li x6, 0xffffe680
sw x6, 0, x5
li x5, 0x00012be8
li x6, 0xffffe58c
sw x6, 0, x5
li x5, 0x00012be4
li x6, 0xffffe58c
sw x6, 0, x5
li x5, 0x00012be0
li x6, 0xffffe58c
sw x6, 0, x5
li x5, 0x00012bdc
li x6, 0xffffe5c0
sw x6, 0, x5
li x5, 0x00012bd8
li x6, 0xffffe590
sw x6, 0, x5
li x5, 0x00012bd4
li x6, 0xffffe680
sw x6, 0, x5
li x5, 0x00012bd0
li x6, 0xffffe590
sw x6, 0, x5
li x5, 0x00012bcc
li x6, 0xffffe5c0
sw x6, 0, x5
li x5, 0x00012bc8
li x6, 0xffffe680
sw x6, 0, x5
li x5, 0x00012bc4
li x6, 0xffffe590
sw x6, 0, x5
li x5, 0x00012bc0
li x6, 0xffffe590
sw x6, 0, x5
li x5, 0x00012bbc
li x6, 0xffffe5c0
sw x6, 0, x5
li x5, 0x00012bb8
li x6, 0xffffe59c
sw x6, 0, x5
li x5, 0x00012bb4
li x6, 0xffffe59c
sw x6, 0, x5
li x5, 0x00012bb0
li x6, 0xffffdf7c
sw x6, 0, x5
li x5, 0x00012bac
li x6, 0xffffdf40
sw x6, 0, x5
li x5, 0x00012ba8
li x6, 0xffffdf40
sw x6, 0, x5
li x5, 0x00012ba4
li x6, 0xffffdf40
sw x6, 0, x5
li x5, 0x00012ba0
li x6, 0xffffdf74
sw x6, 0, x5
li x5, 0x00012b9c
li x6, 0xffffe040
sw x6, 0, x5
li x5, 0x00012b98
li x6, 0xffffe054
sw x6, 0, x5
li x5, 0x00012b94
li x6, 0xffffe054
sw x6, 0, x5
li x5, 0x00012b90
li x6, 0xffffdf74
sw x6, 0, x5
li x5, 0x00012b8c
li x6, 0xffffdf68
sw x6, 0, x5
li x5, 0x00012b88
li x6, 0xffffe040
sw x6, 0, x5
li x5, 0x00012b84
li x6, 0xffffdf68
sw x6, 0, x5
li x5, 0x00012b80
li x6, 0xffffdf74
sw x6, 0, x5
li x5, 0x00012b7c
li x6, 0xffffdf68
sw x6, 0, x5
li x5, 0x00012b78
li x6, 0xffffe054
sw x6, 0, x5
li x5, 0x00012b74
li x6, 0x40100000
sw x6, 0, x5
li x5, 0x00012b70
li x6, 0x00000000
sw x6, 0, x5
li x5, 0x00012b6c
li x6, 0x00000000
sw x6, 0, x5
li x5, 0x00012b68
li x6, 0x3f800000
sw x6, 0, x5
li x5, 0x00012b64
li x6, 0x47914780
sw x6, 0, x5
li x5, 0x00012b60
li x6, 0x45aaf800
sw x6, 0, x5
li x5, 0x00012b5c
li x6, 0x44a36000
sw x6, 0, x5
li x5, 0x00012b58
li x6, 0x45b5a800
sw x6, 0, x5

li x5, 0x00012c94  #rodata
li x6, 0x06060606
sw x6, 0, x5
li x5, 0x00012c90
li x6, 0x06060606
sw x6, 0, x5
li x5, 0x00012c8c
li x6, 0x06060606
sw x6, 0, x5
li x5, 0x00012c88
li x6, 0x06060606
sw x6, 0, x5
li x5, 0x00012c84
li x6, 0x05050505
sw x6, 0, x5
li x5, 0x00012c80
li x6, 0x05050505
sw x6, 0, x5
li x5, 0x00012c7c
li x6, 0x05050505
sw x6, 0, x5
li x5, 0x00012c78
li x6, 0x05050505
sw x6, 0, x5
li x5, 0x00012c74
li x6, 0x04040404
sw x6, 0, x5
li x5, 0x00012c70
li x6, 0x04040404
sw x6, 0, x5
li x5, 0x00012c6c
li x6, 0x03030303
sw x6, 0, x5
li x5, 0x00012c68
li x6, 0x02020100
sw x6, 0, x5
li x5, 0x00012c64
li x6, 0xfffff17c
sw x6, 0, x5
li x5, 0x00012c60
li x6, 0xfffff0e8
sw x6, 0, x5
li x5, 0x00012c5c
li x6, 0xfffff0e8
sw x6, 0, x5
li x5, 0x00012c58
li x6, 0xfffff0e8
sw x6, 0, x5
li x5, 0x00012c54
li x6, 0xfffff118
sw x6, 0, x5
li x5, 0x00012c50
li x6, 0xfffff0ec
sw x6, 0, x5
li x5, 0x00012c4c
li x6, 0xfffff17c
sw x6, 0, x5
li x5, 0x00012c48
li x6, 0xfffff0ec
sw x6, 0, x5
li x5, 0x00012c44
li x6, 0xfffff118
sw x6, 0, x5
li x5, 0x00012c40
li x6, 0xfffff17c
sw x6, 0, x5
li x5, 0x00012c3c
li x6, 0xfffff0ec
sw x6, 0, x5
li x5, 0x00012c38
li x6, 0xfffff0ec
sw x6, 0, x5
li x5, 0x00012c34
li x6, 0xfffff118
sw x6, 0, x5
li x5, 0x00012c30
li x6, 0xfffff0f4
sw x6, 0, x5
li x5, 0x00012c2c
li x6, 0xfffff0f4
sw x6, 0, x5
li x5, 0x00012c28
li x6, 0xffffedb8
sw x6, 0, x5
li x5, 0x00012c24
li x6, 0xffffed34
sw x6, 0, x5
li x5, 0x00012c20
li x6, 0xffffed34
sw x6, 0, x5
li x5, 0x00012c1c
li x6, 0xffffed34
sw x6, 0, x5
li x5, 0x00012c18
li x6, 0xffffedb0
sw x6, 0, x5
li x5, 0x00012c14
li x6, 0xffffee1c
sw x6, 0, x5
li x5, 0x00012c10
li x6, 0xffffed1c
sw x6, 0, x5
li x5, 0x00012c0c
li x6, 0xffffed1c
sw x6, 0, x5
li x5, 0x00012c08
li x6, 0xffffedb0
sw x6, 0, x5
li x5, 0x00012c04
li x6, 0xffffed58
sw x6, 0, x5
li x5, 0x00012c00
li x6, 0xffffee1c
sw x6, 0, x5
li x5, 0x00012bfc
li x6, 0xffffed58
sw x6, 0, x5
li x5, 0x00012bf8
li x6, 0xffffedb0
sw x6, 0, x5

li x5, 0x00012d34  #rodata
li x6, 0x08080808
sw x6, 0, x5
li x5, 0x00012d30
li x6, 0x08080808
sw x6, 0, x5
li x5, 0x00012d2c
li x6, 0x08080808
sw x6, 0, x5
li x5, 0x00012d28
li x6, 0x08080808
sw x6, 0, x5
li x5, 0x00012d24
li x6, 0x08080808
sw x6, 0, x5
li x5, 0x00012d20
li x6, 0x08080808
sw x6, 0, x5
li x5, 0x00012d1c
li x6, 0x08080808
sw x6, 0, x5
li x5, 0x00012d18
li x6, 0x08080808
sw x6, 0, x5
li x5, 0x00012d14
li x6, 0x08080808
sw x6, 0, x5
li x5, 0x00012d10
li x6, 0x08080808
sw x6, 0, x5
li x5, 0x00012d0c
li x6, 0x08080808
sw x6, 0, x5
li x5, 0x00012d08
li x6, 0x08080808
sw x6, 0, x5
li x5, 0x00012d04
li x6, 0x08080808
sw x6, 0, x5
li x5, 0x00012d00
li x6, 0x08080808
sw x6, 0, x5
li x5, 0x00012cfc
li x6, 0x08080808
sw x6, 0, x5
li x5, 0x00012cf8
li x6, 0x08080808
sw x6, 0, x5
li x5, 0x00012cf4
li x6, 0x08080808
sw x6, 0, x5
li x5, 0x00012cf0
li x6, 0x08080808
sw x6, 0, x5
li x5, 0x00012cec
li x6, 0x08080808
sw x6, 0, x5
li x5, 0x00012ce8
li x6, 0x08080808
sw x6, 0, x5
li x5, 0x00012ce4
li x6, 0x07070707
sw x6, 0, x5
li x5, 0x00012ce0
li x6, 0x07070707
sw x6, 0, x5
li x5, 0x00012cdc
li x6, 0x07070707
sw x6, 0, x5
li x5, 0x00012cd8
li x6, 0x07070707
sw x6, 0, x5
li x5, 0x00012cd4
li x6, 0x07070707
sw x6, 0, x5
li x5, 0x00012cd0
li x6, 0x07070707
sw x6, 0, x5
li x5, 0x00012ccc
li x6, 0x07070707
sw x6, 0, x5
li x5, 0x00012cc8
li x6, 0x07070707
sw x6, 0, x5
li x5, 0x00012cc4
li x6, 0x07070707
sw x6, 0, x5
li x5, 0x00012cc0
li x6, 0x07070707
sw x6, 0, x5
li x5, 0x00012cbc
li x6, 0x07070707
sw x6, 0, x5
li x5, 0x00012cb8
li x6, 0x07070707
sw x6, 0, x5
li x5, 0x00012cb4
li x6, 0x07070707
sw x6, 0, x5
li x5, 0x00012cb0
li x6, 0x07070707
sw x6, 0, x5
li x5, 0x00012cac
li x6, 0x07070707
sw x6, 0, x5
li x5, 0x00012ca8
li x6, 0x07070707
sw x6, 0, x5
li x5, 0x00012ca4
li x6, 0x06060606
sw x6, 0, x5
li x5, 0x00012ca0
li x6, 0x06060606
sw x6, 0, x5
li x5, 0x00012c9c
li x6, 0x06060606
sw x6, 0, x5
li x5, 0x00012c98
li x6, 0x06060606
sw x6, 0, x5

li x5, 0x00012d64 #rodata
li x6, 0x08080808
sw x6, 0, x5
li x5, 0x00012d60
li x6, 0x08080808
sw x6, 0, x5
li x5, 0x00012d5c
li x6, 0x08080808
sw x6, 0, x5
li x5, 0x00012d58
li x6, 0x08080808
sw x6, 0, x5
li x5, 0x00012d54
li x6, 0x08080808
sw x6, 0, x5
li x5, 0x00012d50
li x6, 0x08080808
sw x6, 0, x5
li x5, 0x00012d4c
li x6, 0x08080808
sw x6, 0, x5
li x5, 0x00012d48
li x6, 0x08080808
sw x6, 0, x5
li x5, 0x00012d44
li x6, 0x08080808
sw x6, 0, x5
li x5, 0x00012d40
li x6, 0x08080808
sw x6, 0, x5
li x5, 0x00012d3c
li x6, 0x08080808
sw x6, 0, x5
li x5, 0x00012d38
li x6, 0x08080808
sw x6, 0, x5

mv x5, x0   #start
mv x6, x0 
jal x0, 0xF550