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
    IToken public SNOW = IToken(0x10A8B0018d48ff50a7c597de615f553E347D9cb8);
    IToken public BUSD = IToken(0xf5265b3DAbD3Ca2619B9002a9929CD1c606CEa00);
    IToken public USDT = IToken(0xf5265b3DAbD3Ca2619B9002a9929CD1c606CEa00);
    IToken public BTC = IToken(0x0C2516dFFfC7f03b71975aF25Be2ec395d44B846);
    IToken public ETH = IToken(0x04128d1422b76EAd289777aBc440f627f1e6ae17);
    AggregatorV3Interface public priceFeedbnb;
    AggregatorV3Interface public priceFeedbtc;
    AggregatorV3Interface public priceFeedeth;

    address payable public owner;

    uint256 public tokenPerUsd;
    uint256 public preSaleStartTime;
    uint256 public preSaleEndTime;
    uint256 public soldToken;
    uint256 public amountRaisedBNB;
    uint256 public amountRaisedBUSD;
    uint256 public amountRaisedBTC;
    uint256 public amountRaisedETH;
    uint256 public amountRaisedUSDT;
    uint256 public totalSupply;
    uint256 public uplineBonus = 15;
    uint256 public downlineBonus = 15;

    struct user {
        uint256 bnb_balance;
        uint256 busd_balance;
        uint256 btc_balance;
        uint256 eth_balance;
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
        owner = payable(msg.sender);
        //mainnet BSC
        // priceFeedbnb = AggregatorV3Interface(
        //     0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
        // );
        // priceFeedbtc = AggregatorV3Interface(
        //     0x264990fbd0A4796A3E3d8E37C4d5F87a3aCa5Ebf
        // );
        // priceFeedeth = AggregatorV3Interface(
        //     0x9ef1B8c0E4F7dc8bF5719Ea496883DC6401d5b2e
        // );

        //testnet BSC
        priceFeedbnb = AggregatorV3Interface(
            0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
        );
        priceFeedbtc = AggregatorV3Interface(
            0x5741306c21795FdCBb9b265Ea0255F499DFe515C
        );
        priceFeedeth = AggregatorV3Interface(
            0x143db3CEEfbdfe5631aDD3E50f7614B6ba708BA7
        );

        tokenPerUsd = 200;
        totalSupply = SNOW.totalSupply();
        preSaleStartTime = block.timestamp;
        preSaleEndTime = preSaleStartTime + 2 days;
    }

    receive() external payable {}

    // to get real time price of bnb
    function getLatestPricebnb() public view returns (uint256) {
        (, int256 price, , , ) = priceFeedbnb.latestRoundData();
        return uint256(price) / (1e8);
    }

    // to get real time price of btc
    function getLatestPricebtc() public view returns (uint256) {
        (, int256 price, , , ) = priceFeedbtc.latestRoundData();
        return uint256(price) / (1e8);
    }

    // to get real time price of eth
    function getLatestPriceeth() public view returns (uint256) {
        (, int256 price, , , ) = priceFeedeth.latestRoundData();
        return uint256(price) / (1e8);
    }

    // to buy token during preSale time with BNB => for web3 use

    function buyTokenbnb(address ref) public payable {
        require(msg.sender != ref, "PRESALE: You can't refer yourself");
        require(address(0) != ref, "PRESALE: Invalid refer address");
        
        require(
            block.timestamp >= preSaleStartTime &&
                block.timestamp < preSaleEndTime,
            "PRESALE: PreSale time not met"
        );
        uint256 numberOfTokens;
        numberOfTokens = bnbToToken(msg.value);
        owner.transfer(msg.value);
        
        soldToken = soldToken + (numberOfTokens);
        amountRaisedBNB = amountRaisedBNB + (msg.value);
        users[msg.sender].bnb_balance =
            users[msg.sender].bnb_balance +
            (msg.value);
        users[msg.sender].token_balance =
            users[msg.sender].token_balance +
            (numberOfTokens);

        if(ref != owner){
            users[ref].token_balance =
            users[ref].token_balance +
            (numberOfTokens * uplineBonus / 100);
            users[msg.sender].token_balance =
            users[msg.sender].token_balance +
            (numberOfTokens * downlineBonus / 100);
        }
    }

    //to buy token during preSale time with BTC => for web3 use
    function buyTokenbtc(uint256 amount,address ref) public {
        require(msg.sender != ref, "PRESALE: You can't refer yourself");
        require(address(0) != ref, "PRESALE: Invalid refer address");
        require(
            block.timestamp >= preSaleStartTime &&
                block.timestamp < preSaleEndTime,
            "PRESALE: PreSale time not met"
        );
        BTC.transferFrom(msg.sender, owner, amount);
        uint256 numberOfTokens;
        numberOfTokens = btcToToken(amount);
        
        soldToken = soldToken + (numberOfTokens);
        amountRaisedBTC = amountRaisedBTC + (amount);
        users[msg.sender].btc_balance =
            users[msg.sender].btc_balance +
            (amount);
        users[msg.sender].token_balance =
            users[msg.sender].token_balance +
            (numberOfTokens);
        if(ref != owner){
            users[ref].token_balance =
            users[ref].token_balance +
            (numberOfTokens * uplineBonus / 100);
            users[msg.sender].token_balance =
            users[msg.sender].token_balance +
            (numberOfTokens * downlineBonus / 100);
        }
    }

    //to buy token during preSale time with ETH => for web3 use
    function buyTokeneth(uint256 amount,address ref) public {
        require(msg.sender != ref, "PRESALE: You can't refer yourself");
        require(address(0) != ref, "PRESALE: Invalid refer address");
        require(
            block.timestamp >= preSaleStartTime &&
                block.timestamp < preSaleEndTime,
            "PRESALE: PreSale time not met"
        );
        ETH.transferFrom(msg.sender, owner, amount);
        uint256 numberOfTokens;
        numberOfTokens = ethToToken(amount);
        
        soldToken = soldToken + (numberOfTokens);
        amountRaisedETH = amountRaisedETH + (amount);
        users[msg.sender].eth_balance =
            users[msg.sender].eth_balance +
            (amount);
        users[msg.sender].token_balance =
            users[msg.sender].token_balance +
            (numberOfTokens);

        if(ref != owner){
            users[ref].token_balance =
            users[ref].token_balance +
            (numberOfTokens * uplineBonus / 100);
            users[msg.sender].token_balance =
            users[msg.sender].token_balance +
            (numberOfTokens * downlineBonus / 100);
        }
    }

    // to buy token during preSale time with BUSD => for web3 use
    function buyTokenbusd(uint256 amount,address ref) public {
        require(msg.sender != ref, "PRESALE: You can't refer yourself");
        require(address(0) != ref, "PRESALE: Invalid refer address");
        require(
            block.timestamp >= preSaleStartTime &&
                block.timestamp < preSaleEndTime,
            "PRESALE: PreSale time not met"
        );
        BUSD.transferFrom(msg.sender, owner, amount);
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
        if(ref != owner){
            users[ref].token_balance =
            users[ref].token_balance +
            (numberOfTokens * uplineBonus / 100);
            users[msg.sender].token_balance =
            users[msg.sender].token_balance +
            (numberOfTokens * downlineBonus / 100);
        }
    }

    function buyTokenUSDT(uint256 amount,address ref) public {
        require(msg.sender != ref, "PRESALE: You can't refer yourself");
        require(address(0) != ref, "PRESALE: Invalid refer address");
        require(
            block.timestamp >= preSaleStartTime &&
                block.timestamp < preSaleEndTime,
            "PRESALE: PreSale time not met"
        );
        USDT.transferFrom(msg.sender, owner, amount);
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
        if(ref != owner){
            users[ref].token_balance =
            users[ref].token_balance +
            (numberOfTokens * uplineBonus / 100);
            users[msg.sender].token_balance =
            users[msg.sender].token_balance +
            (numberOfTokens * downlineBonus / 100);
        }
    }

    function claimToken() public {
        require(
            block.timestamp >= preSaleEndTime,
            "PRESALE: PreSale time not met"
        );
        uint256 tokenBalance = users[msg.sender].token_balance;
        require(tokenBalance > 0, "PRESALE: No token to claim");
        users[msg.sender].token_balance = 0;
        SNOW.transferFrom(owner, msg.sender, tokenBalance);
    }

    // to check number of token for given bnb
    function bnbToToken(uint256 _amount) public view returns (uint256) {
        uint256 bnbToUsd = (_amount * (getLatestPricebnb())) / (1 ether);
        uint256 numberOfTokens = bnbToUsd * (tokenPerUsd);
        return numberOfTokens * (10**(SNOW.decimals()));
    }

    // to check number of token for given btc
    function btcToToken(uint256 _amount) public view returns (uint256) {
        uint256 btcToUsd = (_amount * (getLatestPricebtc())) / (1 ether);
        uint256 numberOfTokens = btcToUsd * (tokenPerUsd);
        return numberOfTokens * (10**(SNOW.decimals()));
    }

    // to check number of token for given eth
    function ethToToken(uint256 _amount) public view returns (uint256) {
        uint256 ethToUsd = (_amount * (getLatestPriceeth())) / (1 ether);
        uint256 numberOfTokens = ethToUsd * (tokenPerUsd);
        return numberOfTokens * (10**(SNOW.decimals()));
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

    function getProgress() public view returns (uint256 _percent) {
        uint256 remaining = totalSupply - (soldToken / (10**(SNOW.decimals())));
        remaining = (remaining * (100)) / (totalSupply);
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

    // transfer ownership
    function changeOwner(address payable _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    // change tokens
    function changeToken(address _token) external onlyOwner {
        SNOW = IToken(_token);
    }

    //change BUSD
    function changeBUSD(address _BUSD) external onlyOwner {
        BUSD = IToken(_BUSD);
    }

    //change USDT
    function changeUSDT(address _USDT) external onlyOwner {
        USDT = IToken(_USDT);
    }

    //change BTC
    function changeBTC(address _BTC) external onlyOwner {
        BTC = IToken(_BTC);
    }

    //change ETH
    function changeETH(address _ETH) external onlyOwner {
        ETH = IToken(_ETH);
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

    //to get contract BTC balance
    function contractBalanceBTC() external view returns (uint256) {
        return BTC.balanceOf(address(this));
    }

    //to get contract ETH balance
    function contractBalanceETH() external view returns (uint256) {
        return ETH.balanceOf(address(this));
    }

    // to get contract token balance
    function getContractTokenApproval() external view returns (uint256) {
        return SNOW.allowance(owner, address(this));
    }
}