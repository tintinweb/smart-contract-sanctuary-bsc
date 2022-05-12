/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

pragma solidity ^0.8.13;
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

contract PrivatePreSale {

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
    uint256 public maxSupply;
    address [] public users;
    
    struct User{
        uint256 personalAmount;
        bool registerd;
    }
    mapping(address => User) public userData;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "PRESALE: Not Owner");
        _;
    }

    event BuyToken(address indexed _user, uint256 indexed _amount);
    event SellToken(address indexed _user, uint256 indexed _amount);
    
    constructor(){
    // (IBEP20 _token, address payable _owner, uint256 _tokenPrice, uint256 _minAmount, uint256 _maxAmount,uint256 _maxSupply) {
        token = IBEP20(0x8AC6961635F3F3F9d344f843AA6Cdd7273B8dE16);
        owner = payable(msg.sender);
        tokenPrice = 22 ether;
        minAmount = 0.1 ether;
        maxAmount = 5 ether;
        preSaleEnabled = true;
        maxSupply = token.totalSupply();
    }

    receive() external payable {}
    // to buy token during preSale time => for web3 use

    function buy() public payable {
        require(
            preSaleEnabled,
            "PRESALE: PreSale not Started"
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
        require(boughtToken + numberOfTokens <= maxSupply, "PRESALE: Max Supply Reached");
        boughtToken = boughtToken+(numberOfTokens);
        amountRaisedBNB = amountRaisedBNB+(msg.value);
        userData[msg.sender].personalAmount = userData[msg.sender].personalAmount+(numberOfTokens);
        
        emit BuyToken(msg.sender, numberOfTokens);
    }
    function claim() public {
        require(!preSaleEnabled, "PRESALE: PreSale not Ended");
        require(userData[msg.sender].registerd, "PRESALE: User not registered");
        require(userData[msg.sender].personalAmount > 0, "PRESALE: User has no tokens");
        uint256 numberOfTokens = userData[msg.sender].personalAmount;
        userData[msg.sender].personalAmount = 0;
        soldToken = soldToken+(numberOfTokens);
        token.transferFrom(owner, msg.sender, numberOfTokens);
        emit SellToken(msg.sender, numberOfTokens);
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

    function setMaxSupply(uint256 _maxSupply) external onlyOwner {
        maxSupply = _maxSupply;
    }
}