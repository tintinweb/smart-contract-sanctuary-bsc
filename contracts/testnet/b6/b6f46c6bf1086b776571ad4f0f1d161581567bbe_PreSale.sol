/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

pragma solidity ^0.6.12;

// SPDX-License-Identifier: MIT

interface IBEP20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
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

contract PreSale {
    IBEP20 public token;
    using SafeMath for uint256;

    AggregatorV3Interface public priceFeedBnb;
    address payable public owner;

    uint256 public tokenPerUsd;
    uint256 public minAmount;
    uint256 public maxAmount;
    uint256 public preSaleTime;
    uint256 public soldToken;
    uint256 public tokenDecimals;

    mapping(address => uint256) public balances;
    mapping(address => bool) public claimed;

    modifier onlyOwner() {
        require(msg.sender == owner,"BEP20: Not an owner");
        _;
    }

    event BuyToken(address _user, uint256 _amount);

    constructor(address _owner, IBEP20 _tokenForSale, uint256 _tokenDecimals) public {
        owner = payable(_owner);
        token = _tokenForSale;
        tokenDecimals = _tokenDecimals;
        priceFeedBnb = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);
        tokenPerUsd = uint256(11);
        minAmount = 0.1 ether;
        maxAmount = 10 ether;
        preSaleTime = block.timestamp + 365 days;
    }

    receive() external payable{}

    function getLatestPriceBnb() public view returns (uint256) {
        (,int price,,,) = priceFeedBnb.latestRoundData();
        return uint256(price).div(1e8);
    }

    function buyToken() payable public {
        uint256 numberOfTokens = bnbToToken(msg.value);
        uint256 maxToken = bnbToToken(maxAmount);

        require(msg.value >= minAmount && msg.value <= maxAmount,"BEP20: Amount not correct");
        require(numberOfTokens.add(token.balanceOf(msg.sender)) <= maxToken,"BEP20: Amount exceeded max limit");
        require(block.timestamp < preSaleTime,"BEP20: PreSale over");


        token.transferFrom(owner, msg.sender, numberOfTokens);
        soldToken = soldToken.add(numberOfTokens);
        emit BuyToken(msg.sender, balances[msg.sender]);
    }

    function bnbToToken(uint256 _amount) public view returns(uint256){
        uint256 precision = 1e4;
        uint256 bnbToUsd = precision.mul(_amount).mul(getLatestPriceBnb()).div(1e18);
        uint256 numberOfTokens = bnbToUsd.mul(tokenPerUsd);
        return numberOfTokens.mul(10 ** tokenDecimals).div(precision);
    }

    function changePrice(uint256 _tokenPerUsd) external onlyOwner{
        tokenPerUsd = _tokenPerUsd;
    }

    function setPreSaleAmount(uint256 _minAmount, uint256 _maxAmount) external onlyOwner{
        minAmount = _minAmount;
        maxAmount = _maxAmount;
    }

    function setPresaleTime(uint256 _time) external onlyOwner{
        preSaleTime = _time;
    }

    function changeOwner(address payable _newOwner) external onlyOwner{
        owner = _newOwner;
    }

    function transferFunds(uint256 _value) external onlyOwner returns(bool){
        owner.transfer(_value);
        return true;
    }

    function withdraw(address _tokenToWithdraw, uint _amount, address _to) external onlyOwner {
        if(_tokenToWithdraw == address(0)) {
            payable(_to).transfer(_amount);
        } else {
            IBEP20(_tokenToWithdraw).transfer(_to, _amount);
        }
    }

    function getCurrentTime() public view returns(uint256){
        return block.timestamp;
    }

    function contractBalanceBnb() external view returns(uint256){
        return address(this).balance;
    }

    function getContractTokenBalance() external view returns(uint256){
        return token.allowance(owner, address(this));
    }
}