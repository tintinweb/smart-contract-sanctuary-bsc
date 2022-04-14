pragma solidity ^0.8.9;
//SPDX-License-Identifier: MIT Licensed

interface IBEP20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender)external view returns (uint256);
    function approve(address spender, uint256 value) external;
    function transfer(address to, uint256 value) external;
    function transferFrom(address from,address to,uint256 value) external;
    event Approval(address indexed owner,address indexed spender,uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract PreSale {

    IBEP20 public token;

    address payable public owner;

    uint256 public tokenPrice;
    uint256 public minAmount;
    uint256 public maxAmount;
    bool public preSaleEnabled;
    uint256 public boughtToken;
    uint256 public soldToken;
    uint256 public amountRaisedBNB;
    uint256 public totalUsers;
    address [] public users;
    
    struct User{
        uint256 buytime;
        uint256 selltime;
        uint256 personalAmount;
        bool registerd;
    }
    mapping(address => User) public userData;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "PRESALE: Not an owner");
        _;
    }

    event BuyToken(address indexed _user, uint256 indexed _amount);
    event SellToken(address indexed _user, uint256 indexed _amount);
    
    constructor() {
        owner = payable(msg.sender);
        tokenPrice = 33_000_000;
        minAmount = 0.001 ether;
        maxAmount =  10 ether;
        preSaleEnabled = true;
        totalUsers = 0;
    }

    receive() external payable {}
    // to buy token during preSale time => for web3 use

    function buy() public payable {
        require(
            preSaleEnabled,
            "PRESALE: PreSale not Enabled"
        );
        require(
            msg.value >= minAmount && msg.value <= maxAmount,
            "PRESALE: Amount not correct"
        );
        if(!userData[msg.sender].registerd){
            userData[msg.sender].registerd = true;
            users.push(msg.sender);
            totalUsers++;
        }
        uint256 numberOfTokens = bnbToToken(msg.value);
        soldToken += numberOfTokens;
        token.transferFrom(owner,msg.sender, numberOfTokens);
        boughtToken = boughtToken+(numberOfTokens);
        amountRaisedBNB = amountRaisedBNB+(msg.value);
        userData[msg.sender].personalAmount = userData[msg.sender].personalAmount+(numberOfTokens);
        userData[msg.sender].buytime = block.timestamp;
        
        emit BuyToken(msg.sender, numberOfTokens);
    }

    function bnbToToken(uint256 _amount) public view returns(uint256){
        uint256 numberOfTokens = _amount*(tokenPrice)*(1e9)/(1e18);
        return numberOfTokens*(10 ** (token.decimals()))/(1e9);
    }
    // to change Price of the token
    function changePrice(uint256 _price) external onlyOwner {
        tokenPrice = _price;
    }
    // to change preSale amount limits
    function setPreSaletLimits(uint256 _minAmount, uint256 _maxAmount)
        external
        onlyOwner
    {
        minAmount = _minAmount;
        maxAmount = _maxAmount;
    }

    // to change preSale time duration
    function setPreSale(bool _set)
        external
        onlyOwner
    {
        preSaleEnabled = _set;
    }

    // transfer ownership
    function changeOwner(address payable _newOwner) external onlyOwner {
        owner = _newOwner;
    }
    
    // change tokens
    function changeToken(address _token) external onlyOwner{
        token = IBEP20(_token);
    }

    // to draw funds for liquidity
    function transferFunds(uint256 _value) external onlyOwner {
        owner.transfer(_value);
    }

    // to draw out tokens
    function transferTokens(uint256 _value) external onlyOwner {
        token.transfer(owner, _value);
    }

    // to get current UTC time
    function getCurrentTime() external view returns (uint256) {
        return block.timestamp;
    }

    function contractBalanceBNB() external view returns (uint256) {
        return address(this).balance;
    }

    function getContractTokenApproval() external view returns (uint256) {
        return token.allowance(owner, address(this));
    }

    function getContractTokenBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }
}