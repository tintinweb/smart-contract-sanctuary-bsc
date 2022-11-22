/**
 *Submitted for verification at BscScan.com on 2022-11-22
*/

//SPDX-License-Identifier: MIT Licensed
pragma solidity ^0.8.6;

interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);
}

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

contract presale {
    using SafeMath for uint256;

    IERC20 public IMTC = IERC20(0xb2E971AdDF4A74c4D719bb2391D6993F0bE71C35);
    IERC20 public USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
    AggregatorV3Interface public priceFeedbnb;

    address payable public owner;

    uint256 public tokenPerUsd = 250000000000;
    uint256 public preSaleStartTime;
    uint256 public soldToken;
    uint256 public amountRaisedUSDT;
    uint256 public totalSupply = 75000000000000000;
    uint256 public constant divider = 100;
    struct user {
        uint256 usdt_balance;
        uint256 token_balance;
    }

    mapping(address => user) public users;

    modifier onlyOwner() {
        require(msg.sender == owner, "PRESALE: Not an owner");
        _;
    }

    event BuyToken(address indexed _user, uint256 indexed _amount);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event UpdateTotalSupply(uint256 indexed newsupply);
    event UpdateSoldTokens(uint256 indexed newsold);
    event UpdatePrice(uint256 indexed _newPrice);
    event UpdateTime(uint256 indexed _newTime);

    constructor() {
        owner = payable(0x44F5933a5fAa67cAd6958b79cFb9015a1A7D24B4);
        //mainnet BSC
        priceFeedbnb = AggregatorV3Interface(
            0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
        );

        // //testnet BSC
        // priceFeedbnb = AggregatorV3Interface(
        //     0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
        //);
        preSaleStartTime = block.timestamp;
    }

    receive() external payable {}

    // to get real time price of bnb
    function getLatestPricebnb() public view returns (uint256) {
        (, int256 price, , , ) = priceFeedbnb.latestRoundData();
        return uint256(price) / (1e8);
    }

    // to buy token during preSale time with USDT => for web3 use
    function buyTokenUSDT(uint256 amount) public {
        require(
            block.timestamp >= preSaleStartTime,
            "PRESALE: PreSale Not Started Yet"
        );
        require(soldToken <= totalSupply, "All Sold");
        uint256 numberOfTokens;
        numberOfTokens = usdtToToken(amount);
        IMTC.transferFrom(owner, msg.sender, numberOfTokens);
        USDT.transferFrom(msg.sender, owner, amount);

        soldToken = soldToken + (numberOfTokens);
        amountRaisedUSDT = amountRaisedUSDT + (amount);
        users[msg.sender].usdt_balance =
            users[msg.sender].usdt_balance +
            (amount);
        users[msg.sender].token_balance =
            users[msg.sender].token_balance +
            (numberOfTokens);
    }

    // to check number of token for given usdt
    function usdtToToken(uint256 _amount) public view returns (uint256) {
        uint256 numberOfTokens = (_amount * (tokenPerUsd)) / 1e18;
        return numberOfTokens;
    }

    // to check percentage of token sold
    function getProgress() public view returns (uint256 _percent) {
        uint256 remaining = totalSupply - (soldToken / (10**(IMTC.decimals())));
        remaining = (remaining * (divider)) / (totalSupply);
        uint256 hundred = 100;
        return hundred - (remaining);
    }

    // to change Price of the token
    function changePrice(uint256 _price) external onlyOwner {
        tokenPerUsd = _price;
        emit UpdatePrice(_price);
    }

    // to change preSale amount limits
    function settotalSupply(uint256 _totalSupply, uint256 _soldToken)
        external
        onlyOwner
    {
        totalSupply = _totalSupply;
        soldToken = _soldToken;

        emit UpdateTotalSupply(_totalSupply);
        emit UpdateSoldTokens(_soldToken);
    }

    // to change preSale time duration
    function setPreSaleTime(uint256 _startTime) external onlyOwner {
        preSaleStartTime = _startTime;

        emit UpdateTime(_startTime);
    }

    // transfer ownership
    function changeOwner(address payable _newOwner) external onlyOwner {
        require(
            _newOwner != address(0),
            "_newOwner wallet cannot be address zero"
        );
        owner = _newOwner;
        emit OwnershipTransferred(owner, _newOwner);
    }

    // change tokens
    function changeToken(address _token) external onlyOwner {
        IMTC = IERC20(_token);
    }

    //change USDT
    function changeUSDT(address _USDT) external onlyOwner {
        USDT = IERC20(_USDT);
    }

    // to draw funds for liquidity
    function transferFundsBNB(uint256 _value) external onlyOwner {
        owner.transfer(_value);
    }

    // to draw out tokens
    function transferStuckTokens(IERC20 token, uint256 _value)
        external
        onlyOwner
    {
        token.transfer(msg.sender, _value);
    }

    // to get current UTC time
    function getCurrentTime() external view returns (uint256) {
        return block.timestamp;
    }

    // to get contract bnb balance
    function contractBalancebnb() external view returns (uint256) {
        return address(this).balance;
    }

    //to get contract USDT balance
    function contractBalanceUSDT() external view returns (uint256) {
        return USDT.balanceOf(address(this));
    }

    // to get contract token balance
    function getContractTokenApproval() external view returns (uint256) {
        return IMTC.allowance(owner, address(this));
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