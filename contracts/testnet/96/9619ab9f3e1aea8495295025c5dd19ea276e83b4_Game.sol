/**
 *Submitted for verification at BscScan.com on 2022-02-23
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract KRC20 {
    function balanceOf(address tokenOwner) public virtual view returns (uint balance);
    function transferFrom(address from, address to, uint tokens) public virtual returns (bool success);
    function transfer(address to, uint tokens) public virtual returns (bool success);
}


abstract contract Ownable {

  address public owner;

  modifier onlyOwner {
    require(msg.sender == owner, "Ownable: You are not the owner.");
    _;
  }

  constructor () {
    owner = msg.sender;
  }
}


contract Game is Ownable{

     modifier notContract() {
        require(!_isContract(msg.sender), "contract not allowed");
        require(msg.sender == tx.origin, "proxy contract not allowed");
        _;
    }

    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    address token = 0x180dD66c86E392B112FF76ADC09E4c618294C844;
    
    struct game{
        uint id;
        uint guess;
        uint bet;
        uint multip;
        uint ran;
        uint reward;
        uint timestamp;
        bool win;
    }
    
    uint public id;
    uint public kphi;
    uint public maxWin = 2;
    uint public wagered = 0;
    uint public won = 0;
    int public profit = 0;
    
    mapping(address => game[]) public games;
    mapping(address => uint) public gamesL;
    mapping(address => int) public winnings;
    
    function setMaxWin(uint percentage) public onlyOwner{
        maxWin = percentage;
    }
    
    function addTKN(uint value) public onlyOwner{
        kphi+=value;
        KRC20(token).transferFrom(msg.sender, address(this), value);
    }
    
    function reduceTKN(uint value) public onlyOwner{
        kphi = value;
        KRC20(token).transfer(msg.sender, KRC20(token).balanceOf(address(this)) - kphi);
    }

 
    function play(uint8 guess, uint multip, uint bet) notContract public{
        require(guess==0 || guess==1, "you can only guess high or low" );
        require(multip>=101 && multip<=475000, "The multiplier is out of bounds");
        uint reward = bet*multip/100;
        require((reward)<=(kphi*maxWin)/100, "Can't win this much");

        KRC20(token).transferFrom(msg.sender, address(this), bet);
        
        id++;
        wagered+=bet;
        uint lo;
        
        if (950000%multip >= (multip*1000000)/2000000){
            lo = (950000/multip)+1;
        }
        else{
            lo = 950000/multip;
        }
        
        uint hi = 10000-lo;
        
        bool win = false;
        
        uint16 ran = uint16(uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, gasleft(), bet, hi, id, lo)))%9999)+1;


        
        if(guess==1 && ran>hi){
            KRC20(token).transfer(msg.sender, reward);
            win = true;
            won += reward;
            winnings[msg.sender]+=int(reward-bet);
            profit -= int(reward-bet);
        }
        else if(guess == 0 && ran<lo){
            KRC20(token).transfer(msg.sender, reward);
            win = true;
            won += reward;
            winnings[msg.sender] += int(reward-bet);
            profit -= int(reward-bet);
        }
        else{
            reward = 0;
            profit += int(bet);
            winnings[msg.sender] -= int(bet);
        }
        if(KRC20(token).balanceOf(address(this))>kphi){
            uint p = KRC20(token).balanceOf(address(this))-kphi;
            KRC20(token).transfer(owner, p);
        }
        gamesL[msg.sender]++;
        games[msg.sender].push(game(id, guess, bet, multip, ran, reward, block.timestamp, win));
    }
}