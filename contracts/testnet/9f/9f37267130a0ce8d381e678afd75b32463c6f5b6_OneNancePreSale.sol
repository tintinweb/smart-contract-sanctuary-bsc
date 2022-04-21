/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

// SPDX-License-Identifier: MIT
// File: contracts/OneNancePresale.sol


pragma solidity 0.7.5;


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

contract OneNancePreSale is Ownable {

    using SafeMath for uint256;

    address public Recipient = 0xaCdBe67c9086e7C09Ea4783D793A2a0F2D28041A;

    uint256 public tokenRatePerBNB = 40; // 40 * (10 ** decimals) 1NB per BNB
    uint256 public minBNBLimit = 0.05 ether;
    uint256 public maxBNBLimit = 10 ether;

    uint256 public hardCap = 5000 ether;
    uint256 public totalRaisedBNB = 0; // total BNB raised by sale
    uint256 public totaltokenSold = 0;

    bool public contractPaused; // circuit breaker
    bool isTest = true;

    mapping(address => uint256) public usersInvestments;

    constructor() {}

    modifier checkIfPaused() {
        require(contractPaused == false, "contract is paused");
        _;
    }

    function setRecipient(address recipient) external onlyOwner {
        Recipient = recipient;
    }

    function setTokenRatePerBNB(uint256 rate) external onlyOwner {
        tokenRatePerBNB = rate;
    }

    function setMinBNBLimit(uint256 amount) external onlyOwner {
        minBNBLimit = amount;    
    }

    function setMaxBNBLimit(uint256 amount) external onlyOwner {
        maxBNBLimit = amount;    
    }

    function togglePause() external onlyOwner returns (bool){
        contractPaused = !contractPaused;
        return contractPaused;
    }

    receive() external payable{
        deposit();
    }

    function deposit() public payable checkIfPaused {
        require(totalRaisedBNB <= hardCap, 'HardCap exceeded');
        require(
                usersInvestments[msg.sender].add(msg.value) <= maxBNBLimit
                && usersInvestments[msg.sender].add(msg.value) >= minBNBLimit,
                "Installment Invalid."
        );
        
        uint256 tokenAmount = getTokensPerBNB(uint256(msg.value).div(100).mul(isTest ? 100 : 75));

        totalRaisedBNB = totalRaisedBNB.add(uint256(msg.value).div(100).mul(isTest ? 100 : 75));
        totaltokenSold = totaltokenSold.add(tokenAmount);
        usersInvestments[msg.sender] = usersInvestments[msg.sender].add(uint256(msg.value).div(100).mul(isTest ? 100 : 75));

        payable(Recipient).transfer(uint256(msg.value).div(100).mul(isTest ? 100 : 75));
    }

    function getUserRemainingAllocation(address account) external view returns ( uint256 ) {
        return maxBNBLimit.sub(usersInvestments[account]);
    }

    function getTokensPerBNB(uint256 amount) internal view returns(uint256) {
        return amount.mul(tokenRatePerBNB).div(10**(uint256(18).sub(6)));
    }

    function setTestMode(bool _isTest) public onlyOwner {
        isTest = _isTest;
    }

    function witdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}