/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == _msgSender() , "Ownable: caller is not the owner");
        _;
    }
    
    function waiveOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}



contract validation is Ownable{
    uint256 public dayPrice = 5000000000000000000;
    uint256 public weeksPrice = 20000000000000000000;
    uint256 public monthPrice = 88000000000000000000;
    uint256 public seasonPrice = 188000000000000000000;
    uint256 public rebate = 20;
    uint256 public timeMin = 1 days;

    address internal USDT = 0x55d398326f99059fF775485246999027B3197955;
    struct user {
        address addr;
        uint256 time;
    }
    mapping (address => user) public _user;
    mapping (address => bool) public isAdministration;

    function setAdministration(address administration,bool _bool) external onlyOwner {
        isAdministration[administration] = _bool;
    }
   
    function setRebate(uint256 _rebate) external onlyOwner {
        rebate = _rebate;
       
    }
   
    function setPrice(uint256 _dayPrice,uint256 _weeksPrice,uint256 _monthPrice,uint256 _seasonPrice) external onlyOwner {
        dayPrice = _dayPrice;
        weeksPrice =_weeksPrice;
        monthPrice = _monthPrice;
        seasonPrice = _seasonPrice;
    }
  
     function setTimeMin(uint256 _timeMin) external onlyOwner {
        timeMin = _timeMin;
    }
  
    function isOverdue(address addr) external virtual view returns(bool overdue){
        if (block.timestamp <= _user[addr].time){
            overdue = true;
        }else{
            overdue = false;
        }
    }


    function customTime(address[] memory addr,uint256 time)  external  {
        require(isAdministration[msg.sender] ||msg.sender == owner(),"you're not Administration");
        for (uint i = 1; i <= addr.length; i++) {
            _user[addr[i-1]]= user(addr[i-1],time);
        }
    }

    function changeAddress(address from,address to)  external  {

         require(msg.sender == from,"Sender address error");
      
        require(block.timestamp <= _user[from].time,"expired address");
        require(_user[from].time - block.timestamp >= timeMin,"Less than the minimum change time");
        _user[to] = user(to,_user[from].time);
        _user[from].time = 0;
        
    }

    function withdrawBNB(address to) public onlyOwner{
        uint256 balance = address(this).balance;
            payable(to).transfer(balance);
    }

    function withdrawToken(address token,address to) public onlyOwner{
        uint256 balance = IERC20(token).balanceOf(address(this));
            IERC20(token).transfer(to,balance);
    }

    function addTime(address inviter,address userAddr,uint256 types) external  {
        require(block.timestamp <= _user[inviter].time,"The inviter is not the user");
        uint256 price;
        uint256 time;
        if(types == 1){
            price = dayPrice;
            time  = 1 days;
        }else if(types == 2){
            price = weeksPrice;
            time  = 7 days;
        }else if(types == 3){
            price = monthPrice;
            time  = 30 days;
        }else if(types == 4){
            price = seasonPrice;
            time  = 90 days;
        }

        IERC20(USDT).transferFrom(userAddr,address(this),price);
         IERC20(USDT).transfer(inviter,(price * rebate) / 100);

        if(_user[userAddr].time == 0 || block.timestamp >= _user[userAddr].time){
            _user[userAddr]= user(userAddr,block.timestamp + time);
        }else{
            _user[userAddr]= user(userAddr,_user[userAddr].time + time);
        }
    }

    
}