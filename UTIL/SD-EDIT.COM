 &0 n0�X�9 A6 b�� � �  �0��Ʉ�� �5L0��8 A6� �� ��� ���� ����	 e0 Z0 �1�` �5��L  � �(�)�*�+`� �ܩ��`�%�8 A6�I�8 A6��( x6��` �0H� �0H� �0h �0h �0`� 8�
����i
`	0LW6 �5�)�;� �5� � ���0��������ȹ�0Hȹ�0H`��8`L1D1C1V+1�-1�R1�W1�P1�X2&?2)Z21>2N<2k/2�B2�  55� �1`��8` n0 e0� ��� 36��� �4Ș)����� �4Ș)�� 36������ 36��` e0 �5�
�H��A�0��8` D5��������� D5�������8`Ɂ��`��8` D5�ͅ������� �5��������8`� �(����� �1`� �(�(������� �1` e0�(� �% ��8`` e0�(� �& ���8` �5��1��5���8` �2� �2`�5 �2�� C3�� 4`hh`�d�9 A6` 5���
��N������������` e0� �ܑ������	�ܑ������	` e0� ���������	���������	`��
��� � ` 5�
�� �멂8`Ɂ���
��ݩ�8` D5��	�`� ��(�7�D�P�T�@�� �1`������Q�8 A6��� 86� �4� 86� � �4� 86�� �4� 86�� x6����� 86�� x6���� 36�e��������`�5��8)���	� i����� ���7�D�(�����H���D�����h� �4�f �1�a��>��?��=��@�N��A�O �4��7�T����;�Y��L��M��@�P��A�Q@� �4���M �4�;�� �4 �1`�$�@�P�%�A�Q�&�B�R�'�C�S�2�ML�3���8 A6�D�� � �4���8 A6�H�� � �4���8 A6�L �4�Š8 A6�M �4�Ҡ8 A6�= �4��8 A6�N�O �4���8 A6�Y �4��9 A6�P�� � �4�"�9 A6�T�� � �4�7�9 A6�(�� � �4 36`� ��7u@�7��`��7�(��`���������8``�J��Iɀ`8`�� x6��0	H� x6h x6�  W6`)� ����. W6` D5�')�
��
�)�JHe
�
hJJe
���0id����8`�
` D5�	���(��`� ����� �5�	��	����8`� �� ��Ʉ��;�쩁8`�;��,�Ʉ�ܥ�` �5��0��:��A��G�8`i	)�&&����`� � � ���� �5`��`�a��~�)_`�! 36��6�� ���)�!� Z6�� Z6L�5 Z6H 6 Z6��� A6h	 c6�!` '68`� J����������6� W6������6 A6�! x6�LW6�  W6���`��� ���
 D��������`LD�������`���6 A6 G� �5�Y�`8`HJJJJ �6h)�
�ii0 W6` Error $ 
Retry (Y/N) ?  BIOS BDOS CCP  RSX  USER �Invalid Drive ނDirectory full ݂File not found �File exists ؂Disk full ւFile is R/O �no image available �too many IMG files �no partition found �no SD card found �SD card changed �SD card write protected �Invalid Drive �End of Line �Too Much Parameters �Illegal Parameter �Missing Parameter �Unknown Command      ����

SD-EDIT V1.1
 
SD-EDIT V1.1  SD-Drive :  Sector     LBA  
Part#   Bootflag  Type     Begin    Length
 
Partition # 1
           Begin:     Length:  
      Media Byte:           FAT       Sectors/Cluster:  
Reserved Sectors:      # of FATs:        FAT Length:  
        FAT Base:                   Root Dir Base:  
Command >    SD-EDIT V1.1                    (c) 18.7.2023
Command Summary:
 D  dump current Sector      Lnnnnnn  read LBA nnnnnn   
 +  read next sector         -  read last sector
 R  read current sector      W  write current sector
 Pn show data partition n    Znn        wait for nn s   
 >  save sector to buffer    <  get sector from buffer
 Baddr set buffer to addr    /nn        repeat nn times
 CHad,by,by,...     change value at ad with by
 CAad,<string>      change at ad with string
 ?  prints this screen       ;   command separator
 X  exit to CP/M            
 T3
	CLC
WAITX	RTS


STOBUF	JSR SET_BLK		;SAVE DMA TO BUFFER
	LDY #0
STOBU1	LDA (BL