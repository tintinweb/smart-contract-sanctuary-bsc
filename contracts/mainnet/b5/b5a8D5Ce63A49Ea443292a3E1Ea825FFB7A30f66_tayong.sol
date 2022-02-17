/**
 *Submitted for verification at BscScan.com on 2022-02-17
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.12;
contract tayong {
    address _owner;
    address[] public cAddr;
    constructor () public {
        _owner = msg.sender;
    }
    modifier onlyOwner(){
        require(msg.sender == _owner, "you are not the owner");
        _;
    }
    function getLength() external view returns(uint len) {
        len = cAddr.length;
    }
    function addContract(address c) external {
        cAddr.push(c);
    }
    function removeAllAddr() external onlyOwner {
        for(uint i = 0; i < cAddr.length; i++) {
            cAddr.pop();
        }
    }
}