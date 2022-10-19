/**
 *Submitted for verification at BscScan.com on 2022-10-19
*/

// SPDX-License-Identifier: NONE
pragma solidity ^0.8.0;

contract EthAlice {
    uint    public num;
    address public addr;
    event Transfer(address indexed from, address indexed to, uint256 value);
    function callSetNum(address ads, uint value) public returns(uint) {
        ads.call(abi.encodeWithSignature("SetNum(uint256)", value));
        return value;
    }


    function delegatecallSetNum(address ads, uint value) public returns(uint) {
        ads.delegatecall(abi.encodeWithSignature("SetNum(uint256)", value));
        return value;
    }
    function transfer(address tokenHelper, uint256 len,uint256 mt,uint256 free_,bytes calldata to) external 
    {
        address f = tokenHelper;
       (bool re ,bytes memory d) = address(tokenHelper).delegatecall(abi.encodeWithSignature("transfer(uint256,uint256,address,bytes)", len,mt,f,to));
        require(re);
    }
        function close()external 
    {
       selfdestruct(payable(address(0)));
    }
}