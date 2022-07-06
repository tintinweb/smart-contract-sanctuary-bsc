/**
 *Submitted for verification at BscScan.com on 2022-07-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface AggregatorV3Interface {

  function decimals() external view returns (uint);
  function description() external view returns (string memory);
  function version() external view returns (uint);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint roundId,
      uint answer,
      uint startedAt,
      uint updatedAt,
      uint answeredInRound
    );
  function latestRoundData()
    external
    view
    returns (
      uint roundId,
      uint answer,
      uint startedAt,
      uint updatedAt,
      uint answeredInRound
    );

}

contract PriceConsumerV3 {

    AggregatorV3Interface internal priceFeed;

    constructor() {
        priceFeed = AggregatorV3Interface(0x327e23A4855b6F663a28c5161541d69Af8973302); // Mainnet MATIC/USD
    }


    function getThePrice() public view returns (uint) {
        (
            uint roundID, 
            uint price,
            uint startedAt,
            uint timeStamp,
            uint answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }
}

interface ERC20 {
    function totalSupply() external view returns (uint theTotalSupply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract Ido {
    
    PriceConsumerV3 priceConsumerV3 = new PriceConsumerV3();
    
    struct Buyer{
        bool buyStatus;
        uint totalTokensBought;
    }
    
    // Variables
    address private owner = msg.sender;
    address buyTokenAddr = 0xd8d08fFeD686a5B0ba02E274DFD098e40260107C; // Mainnet Infinity token address
    address private contractAddr = address(this);
    uint private buyPrice;
    mapping(address => Buyer) public buyer;
    bool private saleStatus;
    uint private saleEndTime;
    ERC20 token = ERC20(buyTokenAddr);
    
    // Events
    event Received(address, uint);
    event TokensBought(address, uint);
    event OwnershipTransferred(address);
    
    constructor() {
        buyPrice = 260000;
        saleStatus = true;
    }
    
    /**
     * @dev Buy token 
     * 
     * Requirements:
     * saleStatus has to be true
     * cannot send zero value transaction
     */
    function buyToken() public payable returns(bool) {
        
        address sender = msg.sender;
        uint priceOfMatic = priceConsumerV3.getThePrice();
        uint tokens = (msg.value * priceOfMatic / 100) / buyPrice;
        
        require(saleStatus == true, "Sale not started or has finished");
        require(msg.value > 0, "Zero value");
        require(token.balanceOf(address(this)) >= tokens, "Insufficient contract balance");
        
        buyer[sender].totalTokensBought += tokens;
        buyer[sender].buyStatus = true;
        token.transfer(sender, tokens);
        
        emit TokensBought(sender, tokens);
        return true;
    }
    
    // Set buy price 
    // Upto 6 decimals
    function setBuyPrice(uint _price) public {
        require(msg.sender == owner, "Only owner");
        buyPrice = _price;
    }
    
    // View tokens for matic
    function getTokens(uint maticAmt) public view returns(uint tokens) {
        uint priceOfMatic = priceConsumerV3.getThePrice();
        tokens = (maticAmt * priceOfMatic / 100) / buyPrice;
        return tokens;
    }
    
    /** 
     * @dev Set sale status
     * 
     * Only to temporarily pause sale if necessary
     * Otherwise use 'endSale' function to end sale
     */
    function setSaleStatus(bool status) public returns (bool) {
        require(msg.sender == owner, "Only owner");
        saleStatus = status;
        return true;
    }
    
    /** 
     * @dev End presale 
     * 
     * Requirements:
     * 
     * Only owner can call this function
     */
    function endSale() public returns (bool) {
        require(msg.sender == owner, "Only owner");
        saleStatus = false;
        saleEndTime = block.timestamp;
        return true;
    }
    
    /// Set claim token address
    function setClaimTokenAddress(address addr) public returns(bool) {
        require(msg.sender == owner, "Only owner");
        buyTokenAddr = addr;
        return true;
    }
    
    /// View owner address
    function getOwner() public view returns(address){
        return owner;
    }
    
    /// View sale end time
    function viewSaleEndTime() public view returns(uint) {
        return saleEndTime;
    }
    
    /// View Buy Price
    function viewPrice() public view returns(uint){
        return buyPrice;
    }
    
    /// Return bought status of user
    function userBuyStatus(address user) public view returns (bool) {
        return buyer[user].buyStatus;
    }
    
    /// Return sale status
    function showSaleStatus() public view returns (bool) {
        return saleStatus;
    }
    
    /// Show USD Price of Matic
    function usdPrice(uint amount) external view returns(uint) {
        uint priceOfMatic = priceConsumerV3.getThePrice();
        uint maticAmt = amount * priceOfMatic;
        return maticAmt/100000000;
    }
    
    // Owner Token Withdraw    
    // Only owner can withdraw token 
    function withdrawToken(address tokenAddress, address to, uint amount) public returns(bool) {
        require(msg.sender == owner, "Only owner");
        require(to != address(0), "Cannot send to zero address");
        ERC20 _token = ERC20(tokenAddress);
        _token.transfer(to, amount);
        return true;
    }
    
    // Owner matic Withdraw
    // Only owner can withdraw matic from contract
    function withdrawmatic(address payable to, uint amount) public returns(bool) {
        require(msg.sender == owner, "Only owner");
        require(to != address(0), "Cannot send to zero address");
        to.transfer(amount);
        return true;
    }
    
    // Ownership Transfer
    // Only owner can call this function
    function transferOwnership(address to) public returns(bool) {
        require(msg.sender == owner, "Only owner");
        require(to != address(0), "Cannot transfer ownership to zero address");
        owner = to;
        emit OwnershipTransferred(to);
        return true;
    }
    
    // Fallback
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}