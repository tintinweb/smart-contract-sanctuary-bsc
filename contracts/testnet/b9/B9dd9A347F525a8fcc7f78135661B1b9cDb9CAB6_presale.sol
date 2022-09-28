/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

pragma solidity ^0.8.6;

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

    IToken public DEXOToken =
        IToken(0xb0a1736936139dFea4d12CE58155C716D7775fec);
    IToken public BUSD = IToken(0x73445033cEA2d4b74c1c6119E1514da7B6a28739);
    IToken public USDT = IToken(0x73445033cEA2d4b74c1c6119E1514da7B6a28739);
    AggregatorV3Interface public priceFeedbnb;

    address payable public owner;
    address payable public wallet1 =
        payable(0x297fcf8C5dc96A75d77944a457D9Dd31f6067457); // (35%)
    address payable public wallet2 =
        payable(0xE2bc893DEa07a131b0735493d07250095a5A276F); //(65%)

    uint256 public tokenPerUsd;
    uint256 public preSaleStartTime;
    uint256 public soldToken;
    uint256 public amountRaisedBNB;
    uint256 public amountRaisedBUSD;
    uint256 public amountRaisedUSDT;
    uint256 public totalSupply = 80000000 ether;
    uint256 public constant divider = 100;

    bool public isclaimactive;

    struct user {
        uint256 bnb_balance;
        uint256 busd_balance;
        uint256 usdt_balance;
        uint256 token_balance;
    }

    mapping(address => user) public users;
    mapping(address => bool) public claimed;

    modifier onlyOwner() {
        require(msg.sender == owner, "PRESALE: Not an owner");
        _;
    }

    event BuyToken(address indexed _user, uint256 indexed _amount);

    constructor() {
        owner = payable(0x7863d1C6f74Ebb0d4C7c0bdBE40EEB963dE005A0);
        //mainnet BSC
        // priceFeedbnb = AggregatorV3Interface(
        //     0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
        // );

        // //testnet BSC
        priceFeedbnb = AggregatorV3Interface(
            0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
        );
        preSaleStartTime = block.timestamp;
    }

    receive() external payable {}

    // to get real time price of bnb
    function getLatestPricebnb() public view returns (uint256) {
        (, int256 price, , , ) = priceFeedbnb.latestRoundData();
        return uint256(price) / (1e8);
    }

    // to buy token during preSale time with BNB => for web3 use

    function buyTokenbnb() public payable {
        require(soldToken <= totalSupply, "All Sold");
        require(
            block.timestamp >= preSaleStartTime,
            "PRESALE: PreSale Not Started Yet"
        );
        uint256 numberOfTokens;
        numberOfTokens = bnbToToken(msg.value);

        uint256 totalfund = msg.value;
        wallet1.transfer(totalfund.mul(35).div(100));
        wallet2.transfer(totalfund.mul(65).div(100));

        soldToken = soldToken + (numberOfTokens);
        amountRaisedBNB = amountRaisedBNB + (msg.value);
        users[msg.sender].bnb_balance =
            users[msg.sender].bnb_balance +
            (msg.value);
        users[msg.sender].token_balance =
            users[msg.sender].token_balance +
            (numberOfTokens);
    }

    // to buy token during preSale time with BUSD => for web3 use
    function buyTokenbusd(uint256 amount) public {
        require(soldToken <= totalSupply, "All Sold");
        require(
            block.timestamp >= preSaleStartTime,
            "PRESALE: PreSale Not Started Yet"
        );

        BUSD.transferFrom(msg.sender, wallet1, amount.mul(35).div(100));
        BUSD.transferFrom(msg.sender, wallet2, amount.mul(65).div(100));

        uint256 numberOfTokens;
        numberOfTokens = busdToToken(amount);

        soldToken = soldToken + (numberOfTokens);
        amountRaisedBUSD = amountRaisedBUSD + (amount);
        users[msg.sender].busd_balance =
            users[msg.sender].busd_balance +
            (amount);
        users[msg.sender].token_balance =
            users[msg.sender].token_balance +
            (numberOfTokens);
    }

    // to buy token during preSale time with USDT => for web3 use
    function buyTokenUSDT(uint256 amount) public {
        require(
            block.timestamp >= preSaleStartTime,
            "PRESALE: PreSale Not Started Yet"
        );
        require(soldToken <= totalSupply, "All Sold");

        USDT.transferFrom(msg.sender, wallet1, amount.mul(35).div(100));
        USDT.transferFrom(msg.sender, wallet2, amount.mul(65).div(100));

        uint256 numberOfTokens;
        numberOfTokens = usdtToToken(amount);

        soldToken = soldToken + (numberOfTokens);
        amountRaisedUSDT = amountRaisedUSDT + (amount);
        users[msg.sender].usdt_balance =
            users[msg.sender].usdt_balance +
            (amount);
        users[msg.sender].token_balance =
            users[msg.sender].token_balance +
            (numberOfTokens);
    }

    // to claim token after preSale time => for web3 use
    function claimToken() public {
        require(isclaimactive, "preSale: Claim not active");
        require(claimed[msg.sender] == false, "preSale: Already claimed");
        uint256 tokenBalance = users[msg.sender].token_balance;
        require(tokenBalance > 0, "PRESALE: No token to claim");
        users[msg.sender].token_balance = 0;
        DEXOToken.transferFrom(owner, msg.sender, tokenBalance);
     //   claimed[msg.sender] = true;
    }

    // to check number of token for given bnb
    function bnbToToken(uint256 _amount) public view returns (uint256) {
        uint256 bnbToUsd = (_amount * (getLatestPricebnb())) / (1 ether);
        uint256 numberOfTokens = bnbToUsd * (tokenPerUsd);
        return numberOfTokens * (10**(DEXOToken.decimals()));
    }

    // to check number of token for given busd
    function busdToToken(uint256 _amount) public view returns (uint256) {
        uint256 numberOfTokens = _amount * (tokenPerUsd);
        return numberOfTokens;
    }

    // to check number of token for given usdt
    function usdtToToken(uint256 _amount) public view returns (uint256) {
        uint256 numberOfTokens = _amount * (tokenPerUsd);
        return numberOfTokens;
    }

    // to check percentage of token sold
    function getProgress() public view returns (uint256 _percent) {
        uint256 remaining = totalSupply -
            (soldToken / (10**(DEXOToken.decimals())));
        remaining = (remaining * (divider)) / (totalSupply);
        uint256 hundred = 100;
        return hundred - (remaining);
    }

    //to enable claim
    function enableClaim() public onlyOwner {
        require(isclaimactive == false, "preSale: Already enabled");
        //   require(block.timestamp > preSaleEndTime, "preSale: PreSale not over");
        isclaimactive = true;
    }

    // to change Price of the token
    function changePrice(uint256 _price) external onlyOwner {
        tokenPerUsd = _price.div(divider);
    }

    // to change preSale amount limits
    function settotalSupply(uint256 _totalSupply, uint256 _soldToken)
        external
        onlyOwner
    {
        totalSupply = _totalSupply;
        soldToken = _soldToken;
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
        DEXOToken = IToken(_token);
    }

    //change BUSD
    function changeBUSD(address _BUSD) external onlyOwner {
        BUSD = IToken(_BUSD);
    }

    // to change fund receiving wallets
    function changewallets(address payable _w1, address payable _w2)
        external
        onlyOwner
    {
        wallet1 = _w1;
        wallet2 = _w2;
    }

    //change USDT
    function changeUSDT(address _USDT) external onlyOwner {
        USDT = IToken(_USDT);
    }

    // to draw funds for liquidity
    function transferFundsBNB(uint256 _value) external onlyOwner {
        owner.transfer(_value);
    }

    // to draw out tokens
    function transferStuckTokens(IToken token, uint256 _value)
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

    //to get contract BUSD balance
    function contractBalanceBUSD() external view returns (uint256) {
        return BUSD.balanceOf(address(this));
    }

    //to get contract USDT balance
    function contractBalanceUSDT() external view returns (uint256) {
        return USDT.balanceOf(address(this));
    }

    // to get contract token balance
    function getContractTokenApproval() external view returns (uint256) {
        return DEXOToken.allowance(owner, address(this));
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