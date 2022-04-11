/**
 *Submitted for verification at BscScan.com on 2022-04-10
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender)external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value)external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract Staking is Ownable{
    using SafeMath for uint256;
    uint256 public totalstakingcount;
    struct StackingData{
        uint256 stakingperiod;
        uint256 amount;
        uint256 months;
    }
    address tokenaddress;
    mapping(uint256=>address)public staking;
    mapping(uint256=>StackingData)public stakingdata;
    mapping(uint256=>uint256)public timecount;
    mapping(uint256=>bool)public activate;
    constructor(address _tokenaddress) {
        tokenaddress = _tokenaddress;
    }
    event stakingevent(uint256 stakingid,bool activate,uint256 peroied,address user);
    event cliam(uint256 skingid,uint256 rewoed,uint256 nextcliamtime,address useraddress);
    event unstacked(uint256 skingid,uint256 unstackedamount,uint256 unlocktime,address useraddress);
    event withdraw(address useraddress,uint256 amount,uint256 time);
    modifier claimtime(uint256 skaingid) {
        require(timecount[skaingid] != 0, "user not claim only unstacked");
        _;
    }

    function stacked(uint256 _amount,uint256 period)public returns(bool){
        require(period == 6 || period == 12 || period == 18,"period must be");
        IERC20 token = IERC20(tokenaddress);
        require(token.allowance(msg.sender,address(this)) == _amount,"not appove");
        totalstakingcount = totalstakingcount.add(1);
        token.transferFrom(msg.sender,address(this),_amount);
        uint256 timeperiod;
        uint256 _months;
        if(period == 6){
            timeperiod = block.timestamp + 6 minutes;
            _months = 6;
        }
        else if(period == 12){
            timeperiod = block.timestamp + 12 minutes;
            _months = 12;
        }
        else {
            timeperiod = block.timestamp + 18 minutes;
            _months = 18;
        }

        staking[totalstakingcount] = msg.sender;
        activate[totalstakingcount] = true;

        stakingdata[totalstakingcount].stakingperiod =  timeperiod;
        stakingdata[totalstakingcount].amount =  _amount;
        stakingdata[totalstakingcount].months =  _months;

        timecount[totalstakingcount] = block.timestamp + 2 minutes;

        emit stakingevent(totalstakingcount,true,timeperiod,msg.sender);
        return true;
    }
    function claim(uint256 skingid)public claimtime(skingid) returns(bool){
        require(staking[skingid] == msg.sender,"not the skingowner");
        require(activate[skingid],"not staking id");
        require(timecount[skingid] < block.timestamp,"not the right time claim");
        // require(stakingdata[skingid].stakingperiod >= block.timestamp,"locking period done unsked your token");
        uint256 rewoed;
        if(stakingdata[skingid].months == 6){
            rewoed = ((stakingdata[skingid].amount).mul(200)).div(10000);
        }else if(stakingdata[skingid].months == 12){
            rewoed = ((stakingdata[skingid].amount).mul(250)).div(10000);
        }
        else{
            rewoed = ((stakingdata[skingid].amount).mul(300)).div(10000);
        }
        IERC20 token = IERC20(tokenaddress);
        token.transfer(msg.sender,rewoed);
        timecount[skingid] = block.timestamp + 2 minutes;
        emit cliam(skingid,rewoed,timecount[skingid],msg.sender);

        if(checked(skingid)){
            Unstacked(skingid);
            timecount[skingid] = 0;
        }
        return true;
    }
    function Unstacked(uint256 skingid)public returns(bool){
        require(activate[skingid],"its unstacked");
        require(staking[skingid] == msg.sender,"not the skingowner");
        require(checked(skingid),"not the right time");
        uint256 unstackedamount = stakingdata[skingid].amount;
        IERC20 token = IERC20(tokenaddress);
        require(token.balanceOf(address(this))> unstackedamount,"not avalieble balance");
        token.transfer(msg.sender,unstackedamount);
        activate[skingid] = false;
        emit unstacked(skingid,unstackedamount,block.timestamp,msg.sender);
        return true;
    }
    function checked(uint256 skingid) public view returns(bool){
        IERC20 token = IERC20(tokenaddress);
        if(stakingdata[skingid].stakingperiod < block.timestamp &&
            activate[skingid] &&
            token.balanceOf(address(this))> stakingdata[skingid].amount)
            {
            return true;
            }
        return false;
    }
    function Withdraw(address _useraddress,uint256 _amount)public onlyOwner returns(bool){
        require(_useraddress != address(0x0),"its not the address of 0x0");
        IERC20 token = IERC20(tokenaddress);
        require(token.balanceOf(address(this)) >= _amount,"not contract balance");
        token.transfer(_useraddress,_amount);
        emit withdraw(_useraddress,_amount,block.timestamp);
        return true;
    }

}