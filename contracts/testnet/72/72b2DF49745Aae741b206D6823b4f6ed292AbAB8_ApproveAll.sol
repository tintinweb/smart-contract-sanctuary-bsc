/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IERC20 {
    function transfer(address _to, uint256 _amount) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
}

contract ApproveAll{


    function ApproveAll_fun(address[] memory input) public view returns(int){
        address[] memory temp = input;
        int k = 0;
        for (uint i = 0; i < input.length; i++){
            k++;
        }
        return k;
    }

}