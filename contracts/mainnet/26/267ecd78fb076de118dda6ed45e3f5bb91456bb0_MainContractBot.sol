/**
 *Submitted for verification at BscScan.com on 2022-09-20
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;


contract MainContractBot {
    
    address payable private administrator;
    
    mapping(address => bool) public authenticatedSeller;
    
    constructor(){
        administrator = payable(msg.sender);
        authenticatedSeller[msg.sender] = true;
    }
    
    function JpManual(address ti, address to, uint  ai, uint aom, uint bc, uint lp) external payable returns(bool success) {
        require(msg.sender == administrator, "in: must be called by admin or owner");
        return true;
    }

    function JpManualMax(address ti, address to, uint  ai, uint mt, uint bc, uint lp) external payable returns(bool success) {
        require(msg.sender == administrator, "in: must be called by admin or owner");
        return true;
    }

    function sellJpManual(address _ti, address _to, uint _aom, address[] memory bc, uint _pt, uint _lp) external returns(bool success) {
        require(msg.sender == administrator, "out: must be called by admin or owner");
        return true;
    }
}