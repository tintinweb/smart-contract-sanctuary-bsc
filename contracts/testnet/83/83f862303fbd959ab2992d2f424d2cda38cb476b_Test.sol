/**
 *Submitted for verification at BscScan.com on 2022-08-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Test{
    uint256[] public Arr;

    function circleAdd(uint256 len) external {
        for(uint i=0;i< len ;i++){
            Arr.push(i+1);
        }
    }

    function len() public view returns(uint256){
        return Arr.length;
    }

    function addNext(uint256 n) external {
        for(uint256 i=0; i<= Arr.length;i++){
            if(i == Arr.length){
                Arr.push(n);
            }
        }
    }

    function del(uint256 i) external{
        delete Arr[i];
    }

    function clearAll() external{
        for(uint256 i=0; i< Arr.length;i++){
            delete Arr[i];
        }
    }
}