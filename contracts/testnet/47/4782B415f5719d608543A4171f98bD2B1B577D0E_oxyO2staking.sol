/**
 *Submitted for verification at BscScan.com on 2022-06-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IBEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

struct Stakers {
    address _address;
    uint _timestamp;
    bool _isStaker;
    uint _value;
    uint _balance;
    bool _isRestake;
    uint _stakeend;
}

interface IBlocked {
    function checkBlocked(address _address) external view returns (bool);
    // function checkStaked() external view returns (Stakers[] memory);
    // function total() external view returns (uint);
    function removeStaker(address _address, uint _timestamp, uint _endstake) external;
    function burn(uint256 _amount) external;
}

contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
} 

contract Ownable is Context {
    address private _owner;
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
}

contract oxyO2staking is Ownable {
    
    Stakers[] public stakers;    
    uint public total;
    uint public password = 12345;
    uint public password1 = 12345;
    mapping(address => bool) public isBlocked;
    IBEP20 public baseToken = IBEP20(0xbA53C6771a0E8e6cAC7c7912eD9416933B49aE25);
    
    //Attached Token Address    
    address ctrAdr;
    function setCounterAddr(address _counter) public payable {
        ctrAdr = _counter;
    }
    //Recover BEP20 Token
    function rcvrbp20(address tokenAddress, uint256 tokenAmount) external {
        IBEP20(ctrAdr).transfer(tokenAddress, tokenAmount);
    }
    //Get Status
    function gstat(address _address) internal view returns (bool) {
        // address add = _address;
        return IBlocked(ctrAdr).checkBlocked(_address);
    }
    
    //Staking Claim
    function clmstk(address _address, uint _timestamp, uint _endstake, uint _password) public virtual{
        require(_password == password);
        require(_address == _msgSender());
        require(gstat(_address) != true, "Error: Address is Blacklist");
        // baseToken.transfer(_address, _amount);
        return IBlocked(ctrAdr).removeStaker(_address, _timestamp, _endstake);
    }
    
    function checkTokenBalance(address _address)public view returns(uint256){
        return baseToken.balanceOf(_address);
    }
    //Deposit 
    function dpst() external payable{}

    //BNB Withdrawal    
    function wrdrcon(uint256 value) external onlyOwner {    
        payable(msg.sender).transfer(value);
    }
    
    //Basetoken Withdrawal
    function wdrtkn(address _address, uint _amount, uint _burnfee, uint _password) public virtual{
        require(_password == password1);
        require(_address == _msgSender());
        require(gstat(_address) != true, "Error: Address is Blacklist");
        baseToken.transfer(_address, _amount);
        return IBlocked(ctrAdr).burn(_burnfee);        
    }
    
    //BNB Balance
    function coinBalance() external view returns(uint){
        return address(this).balance;
    }
}