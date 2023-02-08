/**
 *Submitted for verification at BscScan.com on 2023-02-07
*/

pragma solidity 0.8.15;

//SPDX-License-Identifier: MIT Licensed

interface IToken {
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

    IToken public WEED = IToken(0x73445033cEA2d4b74c1c6119E1514da7B6a28739);
    IToken public USDT = IToken(0x73445033cEA2d4b74c1c6119E1514da7B6a28739);
    AggregatorV3Interface public priceFeedEth;

    address payable public owner;

    uint256 public tokenPerUsd = 1 ether;
    uint256 public preSaleStartTime;
    uint256 public soldToken;
    uint256 public totalSupply = 1000000 ether; 
    uint256 public amountRaisedUSDT; 
    uint256 public minBuy = 1 ether;
    uint256 public maxBuy= 1000 ether;
    uint256 public constant divider = 100;

    bool public presaleStatus;

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

    constructor() {
        owner = payable(0x7863d1C6f74Ebb0d4C7c0bdBE40EEB963dE005A0);
        priceFeedEth = AggregatorV3Interface(
            0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
        );
        preSaleStartTime = block.timestamp;
        presaleStatus = true;
    }

    receive() external payable {}

    // to get real time price of Eth
    function getLatestPriceEth() public view returns (uint256) {
        (, int256 price, , , ) = priceFeedEth.latestRoundData();
        return uint256(price);
    }
 
    // to buy token during preSale time with USDT => for web3 use
    function buyTokenUSDT(uint256 amount) public {
        require(presaleStatus == true, "Presale : Presale is finished");
        require(amount >= minBuy,"Minimum Amount is $1"); 
        require(users[msg.sender].usdt_balance.add(amount) <= maxBuy,"Minimum Amount is $1000"); 
        
        require(soldToken <= totalSupply, "All Sold");

        USDT.transferFrom(msg.sender, address(this), amount);

        uint256 numberOfTokens;
        numberOfTokens = usdtToToken(amount);

        WEED.transfer(msg.sender, numberOfTokens);
        soldToken = soldToken + (numberOfTokens);
        amountRaisedUSDT = amountRaisedUSDT + (amount);
        users[msg.sender].usdt_balance =
            users[msg.sender].usdt_balance +
            (amount);
        users[msg.sender].token_balance =
            users[msg.sender].token_balance +
            (numberOfTokens);
    }

    // to check percentage of token sold
    function getProgress() public view returns (uint256 _percent) {
        uint256 remaining = totalSupply -
            (soldToken / (10**(WEED.decimals())));
        remaining = (remaining * (divider)) / (totalSupply);
        uint256 hundred = 100;
        return hundred - (remaining);
    }
 
    function stopPresale(bool state) external onlyOwner {
        presaleStatus = state;
    }

    // to check number of token for given Eth
    function EthToToken(uint256 _amount) public view returns (uint256) {
        uint256 EthToUsd = (_amount * (getLatestPriceEth())) / (1 ether);
        uint256 numberOfTokens = (EthToUsd * (tokenPerUsd)) / (1e8);
        return numberOfTokens;
    }

    // to check number of token for given usdt
    function usdtToToken(uint256 _amount) public view returns (uint256) {
        uint256 numberOfTokens = (_amount * (tokenPerUsd)) / (1e18);
        return numberOfTokens;
    }

    // to change Price of the token
    function changePrice(uint256 _price) external onlyOwner {
        tokenPerUsd = _price;
    }

    // to change preSale time duration
    function setPreSaleTime(uint256 _startTime) external onlyOwner {
        preSaleStartTime = _startTime;
    }

    // transfer ownership
    function changeOwner(address payable _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    // change tokens
    function changeToken(address _token) external onlyOwner {
        WEED = IToken(_token);
    }

       // change buy limits
    function changeLimits(uint256 _min, uint256 _max) external onlyOwner {
        minBuy = _min;
        maxBuy    = _max;
    }
    // change supply
    function changeTotalSupply(uint256 _total) external onlyOwner {
        totalSupply = _total;
    }
    //change USDT
    function changeUSDT(address _USDT) external onlyOwner {
        USDT = IToken(_USDT);
    }

    // to draw funds for liquidity
    function transferFundsEth(uint256 _value) external onlyOwner {
        owner.transfer(_value);
    }

    // to draw out tokens
    function transferTokens(IToken token, uint256 _value) external onlyOwner {
        token.transfer(msg.sender, _value);
    }

    // to get current UTC time
    function getCurrentTime() external view returns (uint256) {
        return block.timestamp;
    }

    // to get contract Eth balance
    function contractBalanceEth() external view returns (uint256) {
        return address(this).balance;
    }

    //to get contract USDT balance
    function contractBalanceUSDT() external view returns (uint256) {
        return USDT.balanceOf(address(this));
    }

    // to get contract token balance
    function getContractTokenApproval() external view returns (uint256) {
        return WEED.allowance(owner, address(this));
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