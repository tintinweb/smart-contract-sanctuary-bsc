/**
 *Submitted for verification at BscScan.com on 2023-04-01
*/

//SPDX-License-Identifier: MIT Licensed
pragma solidity ^0.8.6;

interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function SupplyPerPhase() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;

    function transferFrom(address from, address to, uint256 value) external;

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

    function getRoundData(
        uint80 _roundId
    )
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

contract presaleBSC {
    IERC20 public HPO = IERC20(0x5c504f9de232D343F9569c49ab049FfE94031244);

    AggregatorV3Interface public priceFeedBNB;

    address payable public owner;

    uint256 public tokenPerUsd = 1666 * 1e17;
    uint256 public minmumPurchaseInBNB = 0.06 ether;
    uint256 public referralPercent = 4;
    uint256 public bonusToken = 0;
    uint256 public soldToken;
    uint256 public SupplyPerPhase = 150000000 ether;

    address[] public UsersAddresses;

    uint256 public amountRaisedBNB;
    address payable public fundReceiver =
        payable(0xD7EAD2E2C5081E263f41cbf15dA87F11282D05fC);

    uint256 public constant divider = 100;

    bool public presaleStatus;

    struct user {
        uint256 Bnb_balance;
        uint256 token_balance;
    }

    mapping(address => user) public users;

    modifier onlyOwner() {
        require(msg.sender == owner, "PRESALE: Not an owner");
        _;
    }

    event BuyToken(address indexed _user, uint256 indexed _amount);

    constructor() {
        owner = payable(0x78ba8671495ceF3D0F3f9003be4F32852B5BCF56);
        priceFeedBNB = AggregatorV3Interface(
            0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
        );
        presaleStatus = true;
    }

    receive() external payable {}

    // to get real time price of Bnb
    function getLatestPriceBnb() public view returns (uint256) {
        (, int256 price, , , ) = priceFeedBNB.latestRoundData();
        return uint256(price);
    }

    // to buy token during preSale time with Bnb => for web3 use

    function buyTokenBnb(address _ref) public payable {
        require(presaleStatus == true, "Presale : Presale is finished");
        require(
            msg.value >= minmumPurchaseInBNB,
            "Presale : amount must be greater than minimum purchase"
        );
        require(soldToken <= SupplyPerPhase, "All Sold");

        uint256 numberOfTokens;
        numberOfTokens = BnbToToken(msg.value);
        uint256 bonus = (bonusToken * numberOfTokens) / divider;
        uint256 _refamount = (referralPercent * numberOfTokens) / divider;
        soldToken = soldToken + (numberOfTokens);
        amountRaisedBNB = amountRaisedBNB + (msg.value);
        fundReceiver.transfer(msg.value);

        users[msg.sender].Bnb_balance =
            users[msg.sender].Bnb_balance +
            (msg.value);
        users[msg.sender].token_balance =
            users[msg.sender].token_balance +
            (numberOfTokens + bonus);
        users[_ref].token_balance = users[_ref].token_balance + (_refamount);

        UsersAddresses.push(msg.sender);
    }

    // to change preSale amount limits
    function setSupplyPerPhase(
        uint256 _SupplyPerPhase,
        uint256 _soldToken
    ) external onlyOwner {
        SupplyPerPhase = _SupplyPerPhase;
        soldToken = _soldToken;
    }

    function stopPresale(bool _off) external onlyOwner {
        presaleStatus = _off;
    }

    // to check number of token for given Bnb
    function BnbToToken(uint256 _amount) public view returns (uint256) {
        uint256 BnbToUsd = (_amount * (getLatestPriceBnb())) / (1 ether);
        uint256 numberOfTokens = (BnbToUsd * (tokenPerUsd)) / (1e8);
        return numberOfTokens;
    }

    // to change Price of the token
    function changePrice(uint256 _price) external onlyOwner {
        tokenPerUsd = _price;
    }

    function minPurchase(uint256 _minmumPurchaseInBNB) public onlyOwner {
        minmumPurchaseInBNB = _minmumPurchaseInBNB;
    }

    // to change bonus %
    function changeBonus(uint256 _bonus) external onlyOwner {
        bonusToken = _bonus;
    }

    // to change referral %
    function changeRefPercent(uint256 _ref) external onlyOwner {
        referralPercent = _ref;
    }

    // transfer ownership
    function changeOwner(address payable _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    // change tokens
    function changeToken(address _token) external onlyOwner {
        HPO = IERC20(_token);
    }

    // to draw funds for liquidity
    function transferFundsBNB(uint256 _value) external onlyOwner {
        owner.transfer(_value);
    }

    // to draw out tokens
    function transferTokens(IERC20 token, uint256 _value) external onlyOwner {
        token.transfer(msg.sender, _value);
    }

    // to get current UTC time
    function getCurrentTime() external view returns (uint256) {
        return block.timestamp;
    }

    // to get contract Bnb balance
    function contractBalanceBNB() external view returns (uint256) {
        return address(this).balance;
    }

    // to get contract token balance
    function getContractTokenApproval() external view returns (uint256) {
        return HPO.allowance(owner, address(this));
    }
}