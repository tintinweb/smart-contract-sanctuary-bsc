pragma solidity ^0.8.17;

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
    IToken public WB = IToken(0xF84ba2A8d7950d2B0C6c9C2D4D7649AF4D11aA1d);
    IToken public BUSD = IToken(0xf5265b3DAbD3Ca2619B9002a9929CD1c606CEa00);
    AggregatorV3Interface public priceFeedbnb;

    address payable public owner;

    uint256 public tokenPerUsd;
    uint256 public preSaleStartTime;
    uint256 public preSaleEndTime;
    uint256 public soldToken;
    uint256 public amountRaisedBNB;
    uint256 public amountRaisedBUSD;
    uint256 public totalSupply;
    uint256 public uplineBonus = 10;
    uint256 public min = 0.05 ether;
    uint256 public max = 5 ether;
    uint256 public constant divider = 100;

    struct user {
        uint256 bnb_balance;
        uint256 busd_balance;
        uint256 token_balance;
    }

    mapping(address => user) public users;

    modifier onlyOwner() {
        require(msg.sender == owner, "PRESALE: Not an owner");
        _;
    }

    event BuyToken(address indexed _user, uint256 indexed _amount);

    constructor() {
        owner = payable(0xaC343A4ab22c7880Dfb24b74F04B79E20d2D1989);
        //mainnet BSC
        // priceFeedbnb = AggregatorV3Interface(
        //     0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
        // );

        //testnet BSC
        priceFeedbnb = AggregatorV3Interface(
            0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
        );

        tokenPerUsd = 125;
        totalSupply = WB.totalSupply();
        preSaleStartTime = block.timestamp;
        preSaleEndTime = preSaleStartTime + 2 days;
    }

    receive() external payable {}

    // to get real time price of bnb
    function getLatestPricebnb() public view returns (uint256) {
        (, int256 price, , , ) = priceFeedbnb.latestRoundData();
        return uint256(price) / (1e8);
    }

    // to buy token during preSale time with BNB => for web3 use

    function buyTokenbnb(address ref) public payable {
        uint256 maxtoken = bnbToToken(max);
        uint256 mintoken = bnbToToken(min);
        require(msg.sender != ref, "PRESALE: You can't refer yourself");
        require(address(0) != ref, "PRESALE: Invalid refer address");
        
        require(
            block.timestamp >= preSaleStartTime &&
                block.timestamp < preSaleEndTime,
            "PRESALE: PreSale time not met"
        );


        uint256 numberOfTokens;
        numberOfTokens = bnbToToken(msg.value);

        require(users[msg.sender].token_balance + numberOfTokens <= maxtoken, "PRESALE: Max token limit reached");
        require(numberOfTokens >= mintoken, "PRESALE: Min token limit not reached");
        owner.transfer(msg.value);
        
        soldToken = soldToken + (numberOfTokens);
        amountRaisedBNB = amountRaisedBNB + (msg.value);
        users[msg.sender].bnb_balance =
            users[msg.sender].bnb_balance +
            (msg.value);
        users[msg.sender].token_balance =
            users[msg.sender].token_balance +
            (numberOfTokens);
        WB.transferFrom(owner, msg.sender, numberOfTokens);

        if(ref != owner){
            users[ref].token_balance =
            users[ref].token_balance +
            (numberOfTokens * uplineBonus / divider);
            WB.transferFrom(owner, ref, numberOfTokens * uplineBonus / divider);
        }
    }


    // to buy token during preSale time with BUSD => for web3 use
    function buyTokenbusd(uint256 amount,address ref) public {
        uint256 maxtoken = bnbToToken(max);
        uint256 mintoken = bnbToToken(min);
        require(msg.sender != ref, "PRESALE: You can't refer yourself");
        require(address(0) != ref, "PRESALE: Invalid refer address");
        require(
            block.timestamp >= preSaleStartTime &&
                block.timestamp < preSaleEndTime,
            "PRESALE: PreSale time not met"
        );
        
        uint256 numberOfTokens;
        numberOfTokens = busdToToken(amount);

        require(users[msg.sender].token_balance + numberOfTokens <= maxtoken, "PRESALE: Max token limit reached");
        require(numberOfTokens >= mintoken, "PRESALE: Min token limit not reached");
        BUSD.transferFrom(msg.sender, owner, amount);

        soldToken = soldToken + (numberOfTokens);
        amountRaisedBUSD = amountRaisedBUSD + (amount);
        users[msg.sender].busd_balance =
            users[msg.sender].busd_balance +
            (amount);
        users[msg.sender].token_balance =
            users[msg.sender].token_balance +
            (numberOfTokens);
        WB.transferFrom(owner, msg.sender, numberOfTokens);
        if(ref != owner){
            users[ref].token_balance =
            users[ref].token_balance +
            (numberOfTokens * uplineBonus / divider);
            WB.transferFrom(owner, ref, numberOfTokens * uplineBonus / divider);
            
        }
    }

    // to check number of token for given bnb
    function bnbToToken(uint256 _amount) public view returns (uint256) {
        uint256 bnbToUsd = (_amount * (getLatestPricebnb())) / (1 ether);
        uint256 numberOfTokens = bnbToUsd * (tokenPerUsd);
        return numberOfTokens * (10**(WB.decimals()));
    }


    // to check number of token for given busd
    function busdToToken(uint256 _amount) public view returns (uint256) {
        uint256 numberOfTokens = _amount * (tokenPerUsd);
        return numberOfTokens;
    }

    // to check percentage of token sold
    function getProgress() public view returns (uint256 _percent) {
        uint256 remaining = totalSupply - (soldToken / (10**(WB.decimals())));
        remaining = (remaining * (divider)) / (totalSupply);
        uint256 hundred = 100;
        return hundred - (remaining);
    }

    // to change Price of the token
    function changePrice(uint256 _price) external onlyOwner {
        tokenPerUsd = _price;
    }

    // to change preSale amount limits
    function settotalSupply(uint256 _totalSupply) external onlyOwner {
        totalSupply = _totalSupply;
    }

    // to change preSale time duration
    function setPreSaleTime(uint256 _startTime, uint256 _endTime)
        external
        onlyOwner
    {
        preSaleStartTime = _startTime;
        preSaleEndTime = _endTime;
    }
    //to change upline and downline bonus
    function setUplineBonus(uint256 _uplineBonus) external onlyOwner {
        uplineBonus = _uplineBonus;
    }

    // transfer ownership
    function changeOwner(address payable _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    // change tokens
    function changeToken(address _token) external onlyOwner {
        WB = IToken(_token);
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

    // to get contract token balance
    function getContractTokenApproval() external view returns (uint256) {
        return WB.allowance(owner, address(this));
    }
}