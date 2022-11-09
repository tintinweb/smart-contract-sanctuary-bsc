pragma solidity ^0.8.17;

//SPDX-License-Identifier: MIT Licensed

interface IToken {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function mint(address to, uint256 amount) external returns (bool);

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

contract COFFEE_PROJECT {
    IToken public CREST;
    // IToken public BUSD = IToken(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);//main
    IToken public BUSD = IToken(0xf5265b3DAbD3Ca2619B9002a9929CD1c606CEa00); //test
    AggregatorV3Interface public priceFeedbnb;

    address payable public owner =
        payable(0x9fa583D36Fd653c27c58C42f7DeA4F9b4c2f8337);
    address payable public marketingWallet =
        payable(0x9Af346e518a50930AcB3701e30893b18bdD4bA48);

    uint256 public tokenPerUsd = 10;
    uint256 public soldToken;
    uint256 public amountRaisedBNB;
    uint256 public amountRaisedBUSD;
    uint256 public totalSupply;

    bool public CanMint;
    bool public CanBuy;

    struct user {
        uint256 bnb_balance;
        uint256 busd_balance;
        uint256 token_balance;
    }

    mapping(address => user) public users;

    modifier onlyOwner() {
        require(msg.sender == owner, "COFFEE_PROJECT: Not an owner");
        _;
    }

    event BuyToken(address indexed _user, uint256 indexed _amount);

    constructor(IToken _CREST) {
        // mainnet BSC
        // priceFeedbnb = AggregatorV3Interface(
        //     0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
        // );

        //testnet BSC
        priceFeedbnb = AggregatorV3Interface(
            0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
        );
        CREST = _CREST;
        totalSupply = CREST.totalSupply();
        CanBuy = true;
        CanMint = false;
    }

    receive() external payable {}

    // to get real time price of bnb
    function getLatestPricebnb() public view returns (uint256) {
        (, int256 price, , , ) = priceFeedbnb.latestRoundData();
        return uint256(price);
    }

    // to buy token during COFFEE_PROJECT time with BNB => for web3 use

    function buyTokenbnb() public payable {
        require(CanBuy == true, "COFFEE_PROJECT: Can't buy token");

        uint256 numberOfTokens;
        numberOfTokens = bnbToToken(msg.value);

        soldToken = soldToken + (numberOfTokens);
        amountRaisedBNB = amountRaisedBNB + (msg.value);
        users[msg.sender].bnb_balance =
            users[msg.sender].bnb_balance +
            (msg.value);
        users[msg.sender].token_balance =
            users[msg.sender].token_balance +
            (numberOfTokens);
        if (!CanMint) {
            require(
                soldToken + numberOfTokens <= totalSupply,
                "COFFEE_PROJECT: Sold out Enable minting"
            );
        }
        if (CanMint || soldToken >= totalSupply) {
            CREST.mint(msg.sender, numberOfTokens);
        } else {
            CREST.transferFrom(owner, msg.sender, numberOfTokens);
        }
    }

    // to buy token during COFFEE_PROJECT time with BUSD => for web3 use
    function buyTokenbusd(uint256 _amount) public {
        require(CanBuy == true, "COFFEE_PROJECT: Can't buy token");

        uint256 numberOfTokens;
        numberOfTokens = busdToToken(_amount);
        BUSD.transferFrom(msg.sender, owner, _amount);
        soldToken = soldToken + (numberOfTokens);
        amountRaisedBUSD = amountRaisedBUSD + (_amount);
        users[msg.sender].busd_balance =
            users[msg.sender].busd_balance +
            (_amount);
        users[msg.sender].token_balance =
            users[msg.sender].token_balance +
            (numberOfTokens);
        if (CanMint || soldToken >= totalSupply) {
            CREST.mint(msg.sender, numberOfTokens);
        } else {
            CREST.transferFrom(owner, msg.sender, numberOfTokens);
        }
    }

    // to check number of token for given bnb
    function bnbToToken(uint256 _amount) public view returns (uint256) {
        uint256 bnbToUsd = (_amount * (getLatestPricebnb())) / (1 ether);
        uint256 numberOfTokens = bnbToUsd * (tokenPerUsd);
        return (numberOfTokens * (10**(CREST.decimals()))) / (1e8);
    }

    // to check number of token for given BUSD
    function busdToToken(uint256 _amount) public view returns (uint256) {
        uint256 numberOfTokens = (_amount *
            (tokenPerUsd) *
            (10**(CREST.decimals()))) / (10**(BUSD.decimals()));
        return numberOfTokens;
    }

    // to change Price of the token
    function changePrice(uint256 _price) external onlyOwner {
        tokenPerUsd = _price;
    }

    // to change COFFEE_PROJECT amount limits
    function settotalSupply(uint256 _totalSupply) external onlyOwner {
        totalSupply = _totalSupply;
    }

    // transfer ownership
    function changeOwner(address payable _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    // change tokens
    function changeToken(address _token) external onlyOwner {
        CREST = IToken(_token);
    }

    // to draw funds for liquidity
    function transferFundsBNB(uint256 _value) external onlyOwner {
        owner.transfer(_value);
    }

    // to draw funds for liquidity
    function transferFundsBUSD(uint256 _value) external onlyOwner {
        BUSD.transfer(owner, _value);
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

    // to get contract busd balance
    function contractBalancebusd() external view returns (uint256) {
        return BUSD.balanceOf(address(this));
    }

    // to get contract token balance
    function getContractTokenApproval() external view returns (uint256) {
        return CREST.allowance(owner, address(this));
    }

    // Set Miniting
    function SetMinting(bool enable) external onlyOwner {
        require(enable != CanMint, "COFFEE_PROJECT: Already in that state");
        CanMint = enable;
    }

    // Set Buying
    function SetBuying(bool enable) external onlyOwner {
        require(enable != CanBuy, "COFFEE_PROJECT: Already in that state");
        CanBuy = enable;
    }
}