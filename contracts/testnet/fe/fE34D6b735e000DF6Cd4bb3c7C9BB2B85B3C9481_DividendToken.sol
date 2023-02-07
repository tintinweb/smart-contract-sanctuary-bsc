/**
 *Submitted for verification at BscScan.com on 2023-02-06
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.18;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

contract DividendToken is IERC20 {
    address public creator;
    mapping(address => uint) public nodes;
    mapping(uint => address) public _nodes;
    uint public bonusTokenAmount;
    uint public triggerAmount;
    uint totalBonus;
    mapping(address => uint256) private _balances;
    uint public count;
    uint public _count;
    
    constructor()  {
        creator = msg.sender;
    }

     function addNode(address nodeAddress) public onlyCreator {
        nodes[nodeAddress] = count;
        _nodes[count] = nodeAddress;
        count=count+1;
        _count=_count+1;
    }

    function removeNode(address nodeAddress) public onlyCreator {
        delete _nodes[nodes[nodeAddress]];
        delete nodes[nodeAddress];
        _count=_count-1;
    }

    function setTriggerAmount(uint amount) public onlyCreator {
        triggerAmount = amount;
    }

   
    function distributeBonus() public onlyCreator {
            totalBonus = balanceOf(address(this));
        if (totalBonus < triggerAmount) {
            return;
        }
        else{
        uint bonusPerNode = totalBonus / _count;
        uint x;
        for (uint256 i = 0; x < _count ;i++) {
            address payable recipient = payable(_nodes[i]);
            if(recipient != address(0)){
                x=x+1;
                recipient.transfer(bonusPerNode);
            }  
        }
        }
    }
    function balanceOf(address account) public view override returns (uint256) {
        uint256 balance = _balances[account];
        return balance;
    }
    modifier onlyCreator() {
        require(msg.sender == creator, "Only the creator can perform this action.");
        _;
    }
}