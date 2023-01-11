// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
 
 
import "./Proxy.sol";

 
contract AevumProxy is Proxy {
    
    address public impl;
    address public contractOwner;

    modifier onlyContractOwner() { 
        require(msg.sender == contractOwner); 
        _; 
    }

    constructor(address _impl) public {
        impl = _impl;
        contractOwner = msg.sender;
    }
    
    function update(address newImpl) public onlyContractOwner {
        impl = newImpl;
    }

    function removeOwnership() public onlyContractOwner {
        contractOwner = address(0);
    }
    
    function _implementation() internal override view returns (address) {
        return impl;
    }
}