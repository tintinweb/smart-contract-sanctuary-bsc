/**
 *Submitted for verification at BscScan.com on 2022-07-11
*/

// SPDX-License-Identifier: MIT

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

contract Owned {

    address payable public owner;
    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner,"Only Owner!");
        _;
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {
        owner = _newOwner;
        emit OwnershipTransferred(msg.sender, _newOwner);
    }
}

interface IERC20 {

    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract iDotFinanceSale is Owned {

    using SafeMath for uint256;

    IERC20 public IDOT = IERC20(0x9650Fd508E47c0f8787237f06E293fc299332603);
    address public Recipient = 0xc005eF0Ebf220e3824a5739F5085885dC8A00115;

    uint256 public TokenRatePerBnb = 300; // 300 * (10 ** decimals) IDOT per BNB
    uint256 public minBNBLimit = 0.01 ether;
    uint256 public maxBNBLimit = 5 ether;

    uint256 public hardCap = 500 ether;
    uint256 public softCap = 250 ether;

    uint256 public totalRaisedBNB = 0; // total BNB raised by sale
    uint256 public totaltokenSold = 0;

    uint256 public startTime; // 1657807200
    uint256 public endTime; // 1657832400
    bool public contractPaused; // circuit breaker

    mapping(address => uint256) public usersInvestments;

    constructor(uint256 _startTime, uint256 _endTime) {
        require(_startTime > block.timestamp, 'past timestamp');
        startTime = _startTime;
        if(_endTime > _startTime + 1 minutes) {
            endTime = _endTime;
        } else {
            endTime = _startTime + 1 minutes;
        }
    }

    modifier checkIfPaused() {
        require(contractPaused == false, "contract is paused");
        _;
    }

    function setSaleToken(address tokenaddress) external onlyOwner {
        require( tokenaddress != address(0) );
        IDOT = IERC20(tokenaddress);
    }

    function setRecipient(address recipient) external onlyOwner {
        Recipient = recipient;
    }

    function setTokenRatePerBnb(uint256 rate) external onlyOwner {
        TokenRatePerBnb = rate;
    }

    function setminBNBLimit(uint256 amount) external onlyOwner {
        minBNBLimit = amount;    
    }

    function setmaxBNBLimit(uint256 amount) external onlyOwner {
        maxBNBLimit = amount;    
    }

    function setStartTime(uint256 _startTime) external onlyOwner {
        require(_startTime > block.timestamp, 'past timestamp');
        startTime = _startTime;
    }

    function setEndTime(uint256 _endTime) external onlyOwner {
        require(_endTime > startTime + 1 minutes, 'too short period');
        endTime = _endTime;
    }

    function setCap(uint256 _softCap, uint256 _hardCap) external onlyOwner {
        hardCap = _hardCap;
        softCap = _softCap;
    }

    function togglePause() external onlyOwner returns (bool){
        contractPaused = !contractPaused;
        return contractPaused;
    }

    receive() external payable{
        deposit();
    }

    function deposit() public payable checkIfPaused {
        require(block.timestamp > startTime, 'Sale has not started');
        require(block.timestamp < endTime, 'Sale has ended');
        require(totalRaisedBNB <= hardCap, 'HardCap exceeded');
        require(
                usersInvestments[msg.sender].add(msg.value) <= maxBNBLimit
                && usersInvestments[msg.sender].add(msg.value) >= minBNBLimit,
                "Installment Invalid."
        );
        
        uint256 tokenAmount = getTokensPerBnb(msg.value);
        require(IDOT.transfer(msg.sender, tokenAmount), "Insufficient balance of sale contract!");

        totalRaisedBNB = totalRaisedBNB.add(msg.value);
        totaltokenSold = totaltokenSold.add(tokenAmount);
        usersInvestments[msg.sender] = usersInvestments[msg.sender].add(msg.value);

        payable(Recipient).transfer(msg.value);
    }

    function getUnsoldTokens(address token, address to) external onlyOwner {
        require(block.timestamp > endTime + 1 minutes, "You cannot get tokens until the sale is closed.");
        IERC20(token).transfer(to, IERC20(token).balanceOf(address(this)) );
        payable(to).transfer(address(this).balance);
    }

    function getUserRemainingAllocation(address account) external view returns ( uint256 ) {
        return maxBNBLimit.sub(usersInvestments[account]);
    }

    function getTokensPerBnb(uint256 amount) internal view returns(uint256) {
        return amount.mul(TokenRatePerBnb).div(10**(uint256(18).sub(IDOT.decimals())));
    }
}