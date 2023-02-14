/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;
}

contract Presale {
    using SafeMath for uint256;

    struct User {
        uint256 balance;
        uint256 claimed;
        uint256 weeklyClaim;
        uint256 claimCount;
        bool bought;
        uint256 lastClaimed;
    }
    mapping(address => User) public userRecord;

    uint256 public presaleSupply;
    uint256 public soldTokens;

    address payable public owner;
    uint256 public decimal = 10**18;
    uint256 public weeklyRelease = 100;
    uint256 public feeDenominator = 1000;
    uint256 public price = 0.00000067 ether;
    uint256 public vestingTime = 7 days;
    ERC20 public token;
    ERC20 public token3;

    event BUY(address user, uint256 amount);
    event CLAIM(address user, uint256 amount);

    modifier onlyOwner() {
        require(owner == msg.sender, "only owner");
        _;
    }

    constructor(address payable _owner, address _token) public {
        presaleSupply = 1500000000; // total token supply
        token = ERC20(_token);
        owner = _owner;
    }

    function buy(uint256 amount) public payable {
        require(amount * price == msg.value, "Must send a positive value");
        require(userRecord[msg.sender].balance == 0, "Cannot purchase more than once");
        require(amount < presaleSupply, "Cannot buy whole presale supply");
        require(amount > 0, "Must send a positive value");

        uint256 tokens = (amount.mul(decimal)).div(2);
        token.transfer(msg.sender, tokens);
        userRecord[msg.sender].balance = tokens.mul(2);
        userRecord[msg.sender].claimed = tokens;
        userRecord[msg.sender].weeklyClaim = userRecord[msg.sender].balance / 10;
        userRecord[msg.sender].lastClaimed = block.timestamp;
        userRecord[msg.sender].bought = true;

        soldTokens = soldTokens + amount.mul(decimal);

        emit BUY(msg.sender, amount);
    }

    function claim() public {
        require(userRecord[msg.sender].claimed != userRecord[msg.sender].balance, "Claimed 100%");
        require(userRecord[msg.sender].claimCount <= 5, "Max claim count has exceeded 5, 5 weeks");
        require(block.timestamp > userRecord[msg.sender].lastClaimed + vestingTime);

        token.transfer(msg.sender, userRecord[msg.sender].weeklyClaim);
        userRecord[msg.sender].lastClaimed = block.timestamp;
        userRecord[msg.sender].claimed = userRecord[msg.sender].claimed + userRecord[msg.sender].weeklyClaim;
        userRecord[msg.sender].claimCount++;

        emit CLAIM(msg.sender, userRecord[msg.sender].weeklyClaim);
    }

    function availableTokens() public view returns (uint256) {
        if (block.timestamp >= userRecord[msg.sender].lastClaimed + vestingTime) {
            return userRecord[msg.sender].weeklyClaim;
        } else {
            return 0;
        }
    }

    function changeVesting(uint256 _vestingTime) public onlyOwner {
        vestingTime = _vestingTime;
    }

    function withdrawBNB() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "does not have any balance");
        payable(msg.sender).transfer(balance);
    }

    function initToken(address addr) public onlyOwner {
        token3 = ERC20(addr);
    }

    function withdrawToken(uint256 amount) public onlyOwner {
        token3.transfer(msg.sender, amount);
    }

    function withdrawPresaleToken(uint256 amount) public onlyOwner {
        token.transfer(msg.sender, amount);
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}