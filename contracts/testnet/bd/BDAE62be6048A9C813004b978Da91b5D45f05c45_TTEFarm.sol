/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;


 abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
 
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _creator;
    address private _previousOwner;
    uint256 private _lockTime;
 
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        _creator = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
 
    function owner() public view returns (address) {
        return _owner;
    }
 
    function creator() public view returns (address) {
        return _creator;
    }
 
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
 
    modifier onlyCreator() {
        require(_creator == _msgSender(), "Ownable: caller is not the creator");
        _;
    }
 
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
 
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
 
    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }
 
    function getTime() public view returns (uint256) {
        return now;
    }
 
}

interface IERC20 {
 
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
 
}

contract TTEFarm is Ownable{

    mapping(address => uint256) public stakingBalance;
    mapping(address => bool) public isStaking;
    mapping(address => uint256) public startTime;
    mapping(address => uint256) public tteBalance;
    mapping(address => uint256) public withdrawTime;

    uint256 rate = 864;
    uint256 public withdrawCooldown = 10 days; 


    string public name = "Tweet2Earn Farm";

    IERC20 public _lpToken;
    IERC20 public tteToken;


    event Stake(address indexed from, uint256 amount);
    event Unstake(address indexed from, uint256 amount);
    event YieldWithdraw(address indexed to, uint256 amount);

    constructor (IERC20 lpToken, IERC20 _tteToken) public {
            _lpToken = lpToken;
            _tteToken = tteToken;
        }

    function stake(uint256 amount) public {
        require(
            amount > 0 &&
            _lpToken.balanceOf(msg.sender) >= amount, 
            "TTE Farm : You cannot stake zero tokens");

        if(isStaking[msg.sender] == true){
            uint256 toTransfer = calculateYieldTotal(msg.sender);
            tteBalance[msg.sender] += toTransfer;
        }

        _lpToken.transferFrom(msg.sender, address(this), amount);
        stakingBalance[msg.sender] += amount;
        startTime[msg.sender] = block.timestamp;
        isStaking[msg.sender] = true;
        emit Stake(msg.sender, amount);
    }

    function unstake(uint256 amount) public {
        require(
            isStaking[msg.sender] = true &&
            stakingBalance[msg.sender] >= amount, 
            "TTE Farm : Nothing to unstake"
        );

        require(withdrawTime[msg.sender] > withdrawCooldown, "TTEFarm : Withdraw cooldown is not reached yet");

        uint256 yieldTransfer = calculateYieldTotal(msg.sender);
        startTime[msg.sender] = block.timestamp;
        uint256 balTransfer = amount;
        amount = 0;
        stakingBalance[msg.sender] -= balTransfer;
        _lpToken.transfer(msg.sender, balTransfer);
        tteBalance[msg.sender] += yieldTransfer;
        if(stakingBalance[msg.sender] == 0){
            isStaking[msg.sender] = false;
        }
        emit Unstake(msg.sender, balTransfer);
    }

    function calculateYieldTime(address user) public view returns(uint256){
        uint256 end = block.timestamp;
        uint256 totalTime = end - startTime[user];
        return totalTime;
    }

    function calculateYieldTotal(address user) public view returns(uint256) {
        uint256 time = calculateYieldTime(user) * 10**18;
        uint256 timeRate = time / rate;
        uint256 rawYield = (stakingBalance[user] * timeRate) / 10**18;
        return rawYield;
    } 

    function withdrawYield() public {
        uint256 toTransfer = calculateYieldTotal(msg.sender);

        require(
            toTransfer > 0 ||
            tteBalance[msg.sender] > 0,
            "TTE Farm : Nothing to withdraw"
            );
            
        if(tteBalance[msg.sender] != 0){
            uint256 oldBalance = tteBalance[msg.sender];
            tteBalance[msg.sender] = 0;
            toTransfer += oldBalance;
        }

        startTime[msg.sender] = block.timestamp;
        tteToken.transfer(msg.sender, toTransfer);
        emit YieldWithdraw(msg.sender, toTransfer);
    } 

 function setCooldown(uint256 _cooldown) public onlyOwner {
        withdrawCooldown = _cooldown;
    }

    function setRate(uint256 _rate) public onlyOwner{
        rate = _rate;
    }

  function rescueToken(address tokenAddress, uint256 tokens) external onlyOwner returns (bool success){
        return IERC20(tokenAddress).transfer(msg.sender, tokens);
    }

    function clearStuckBalance(address _receiver) external onlyOwner {
        uint256 balance = address(this).balance;
        payable(_receiver).transfer(balance);
    }

}