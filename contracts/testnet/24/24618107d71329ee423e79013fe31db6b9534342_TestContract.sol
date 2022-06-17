/**
 *Submitted for verification at BscScan.com on 2022-06-16
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract TestContract {
    address admin;

    uint public data1;
    uint[] public dataArray1;

    uint public result1=0;
    uint public result2=0;
    uint public result3=0;
    uint public result4=0;

    constructor (){
        admin = msg.sender;
        //dataArray1[0] = 1; //This is not okay, need to initialize first!
        dataArray1 = [1,2,3];
        dataArray1 = [5,6,7,8];
        dataArray1.pop();
        dataArray1.push(9);  //dataArray should be [5,6,7,9]
    }
    
    //Storage array
    uint[]  storageArray        = [uint256(5),6,7,8];
    uint[4] storageArray_fixed  = [uint256(5),6,7,8];    
    
    //Fixed array assiging to Storage / Memory array
    function test1 () public {

        storageArray        = [uint256(5),6,7,8,9];

        storageArray_fixed  = [uint256(5),6,7,8];

        uint[] memory memoryArray_dynamic = new uint[](4);
        memoryArray_dynamic[0] = 5;
        memoryArray_dynamic[1] = 6;
        memoryArray_dynamic[2] = 7;
        memoryArray_dynamic[3] = 8;

        //Assign fixed array to fixed memory array
        uint[4] memory z = [uint256(5),6,7,8];
        z[0] = 2;
        result1 = z[0];
    }


    //Storage array copying to Memory array
    function test2(uint[] memory  memoryArray) public {
            //value in the Storage array will be copied to Memory array
            memoryArray = storageArray;

            result1 = memoryArray[0];
            result2 = storageArray[0];
            
            memoryArray[0] =15;
            storageArray[0]=19;        

            result3 = memoryArray[0];
            result4 = storageArray[0];
    }

}