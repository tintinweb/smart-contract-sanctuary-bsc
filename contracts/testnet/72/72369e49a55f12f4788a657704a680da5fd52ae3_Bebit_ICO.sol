/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IBEBIT {
    function transfer(address _to, uint256 _value) external returns (bool);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transferFrom(
        address from,
        address _to,
        uint256 _value
    ) external returns (bool);
}

contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
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

contract Bebit_ICO is Ownable {
    using SafeMath for uint256;
    IBEBIT TokenAddress;
    uint256 public RATE = 10 * 10 ** 18;
    uint256 public SoftCap = 1000; // Cap in BNB.   1.0
    uint256 public StartTime;
    uint256 public EndTime;
    // The minimum amount of Wei you must pay to participate in the _ICO
    uint256 public MinPurchase = 0.04 ether; // 0.04 BNB
    uint256 public MaxPurchase = 0.09 ether; // 0.09 BNB
    uint256 public initialTokens; // Initial number of tokens available
    bool public initialized = false;
    uint256 public raisedAmount = 0;
    event BoughtTokens(address indexed to, uint256 value);

    constructor() {
        owner = payable(msg.sender);
    }

    function initializeICO(
        IBEBIT _TokenAddress,
        uint256 _initialTokens,
        uint256 _EndTime
    ) public onlyOwner {
        require(initialized == false, "Can only be initialized once"); // Can only be initialized once
        require(
            _initialTokens > 0,
            "initial token should always greater than 0 "
        );
        initialTokens = _initialTokens;
        initialized = true;
        TokenAddress = _TokenAddress;
        StartTime = block.timestamp;
        EndTime = block.timestamp + _EndTime;
        TokenAddress.transferFrom(msg.sender, address(this), _initialTokens);
    }

    function transfertoken(uint256 amount) public onlyOwner {
        TokenAddress.transferFrom(msg.sender, address(this), amount);
        uint256 balance = TokenAddress.balanceOf(address(this));
        balance = TokenAddress.balanceOf(address(this)) + amount;
    }

    function goalReached() public view returns (bool) {
        return (raisedAmount >= SoftCap * 1 ether);
    }

    receive() external payable {}

    // if user pay 1 wei then he will get 1 token
    function buyTokens() public payable returns (bool) {
        require(msg.value > 0, "Enter a Non-Zero amount.");
        require(
            msg.value >= MinPurchase,
            "Please Enter the amount more than the minimum allowed investment"
        );
        require(goalReached() == false, "goal not achieve");
        require(initialized == true, "ICO should be initailized");
        require(
            EndTime > StartTime,
            "end time should be greater than start time"
        );
        require(
            msg.value <= MaxPurchase,
            "Please Enter the amount more than the minimum allowed investment"
        );
        uint256 weiAmount = msg.value; // Calculate tokens to sell
        uint256 n = weiAmount / MinPurchase;
        uint256 tokens = n.mul(RATE); // according to this line
        raisedAmount = raisedAmount.add(msg.value); // Increment raised amount
        TokenAddress.transferFrom(address(this), msg.sender, tokens); // Send tokens to buyer
        payable(owner).transfer(msg.value); // Send money to owner
        // emit BoughtTokens(msg.sender, tokens); // log event onto the blockchain
        return true;
    }

    function SetTokenRate(uint256 _rate) external onlyOwner {
        RATE = _rate;
    }

    function updateStartTime(uint256 _startTime) external onlyOwner {
        StartTime = _startTime;
    }

    function updateEndTime(uint256 _EndTime) external onlyOwner {
        EndTime = _EndTime;
    }

    function tokensAvailable() public view returns (uint256) {
        return TokenAddress.balanceOf(address(this));
    }

    function tokenbalance(address user) public view returns (uint256) {
        return TokenAddress.balanceOf(user);
    }

    function destroy() public onlyOwner {
        require(
            TokenAddress.balanceOf(address(this)) > 0,
            "token amount is greater than 0"
        );
        // Transfer tokens back to owner
        uint256 balance = TokenAddress.balanceOf(address(this));
        TokenAddress.transfer(owner, balance);
    }
}