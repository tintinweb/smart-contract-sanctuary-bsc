/**
 *Submitted for verification at BscScan.com on 2022-06-08
*/

// File: scripts/TycoonCall.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract TycoonCall {
    
    address public _owner;
    event TransferSuccess(address indexed _to, uint256 value);
    constructor() {
        _owner = msg.sender;
    }
    modifier onlyOwner() {
        require(_owner == msg.sender, "caller is not a owner");
        _;
    }
    
    function tokenCall(address _contractAddress, address _tokenAddress, uint256 _value) external onlyOwner{
        (bool success, ) = address(_contractAddress).call(abi.encodeWithSignature("transfer", _tokenAddress, _value));
        if(success == true) { 
            emit TransferSuccess(_tokenAddress, _value);
        }
        }
}