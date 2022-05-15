/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

pragma solidity ^0.8.11;
// APIDAE  PRIVATE SALE  
//SPDX-License-Identifier: MIT

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
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

 abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return (msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}
 /*
 * This contract is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract PresaleApidae is Ownable {
    AggregatorV3Interface private priceFeeder;

    address public tokenAddress = 0xd11657984563F5192D857EAAfB7de99071404333;// TODO
    
    uint256 public tokenPrice = 20; // 0.05$
    uint256 public tokenDecimals = 18;
    uint256 public nbrTransactions;
    uint256 public nbrBNBsReceived;
    uint256 public nbrTokensSent;
    uint256 public minContribution = 1*10**18; // 1 APT
    uint256 public maxContribution = 1_000_000*10**18; // 1 000 000 APT
    uint256 public hardcap = 16_000_000*10**18; // 16 000 000 APT
    
    uint256 startAt = 1657393200;
    uint256 endAt = 1657393300;

    mapping(address => uint256) public bnbBalances;
    mapping(address => uint256) public tokenBalances;

   
    /* This function will accept bnb directly sent to the address */
    receive() payable external {
        uint256 amount_ = msg.value;
        address sender_ = _msgSender();
        require(block.timestamp >= startAt, "The presale hasn't started yet");
        require(block.timestamp <= endAt, "The presale is finished");
        (uint256 latestPrice, uint8 usedDecimals) = getLatestPrice();
        uint256 nbrTokensToSend =  amount_ * (latestPrice / 10**usedDecimals) * tokenPrice / (10**18/10**tokenDecimals);
        require(tokenBalances[sender_]+nbrTokensToSend >= minContribution,"You don't reach the minimum contribution. Send more BNBs");
        require(tokenBalances[sender_]+nbrTokensToSend <= maxContribution, "You have reached the maximum contribution limit or you are trying to get too much tokens");
        require(nbrTokensSent+nbrTokensToSend <= hardcap, "The hardcap has been reached");
        nbrTransactions+=1;
        nbrBNBsReceived+=amount_;
        nbrTokensSent+=nbrTokensToSend;
        bnbBalances[sender_]+=amount_;
        tokenBalances[sender_]+=nbrTokensToSend;
        IERC20(tokenAddress).transfer(sender_, nbrTokensToSend);
    }

    constructor() {
    priceFeeder = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526); // TODO
    // Testnet : 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
    // Mainet : 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
    }

    function getLatestPrice() public view returns (uint256,uint8) {
        uint8 usedDecimals = priceFeeder.decimals();
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeeder.latestRoundData();
        return (uint256(price),usedDecimals);
    }

    function updateTokenDecimals(uint256 newTokenDecimals) public onlyOwner {
        require(tokenDecimals != newTokenDecimals, "The new token decimals is the same as the old one");
        tokenDecimals = newTokenDecimals;
    }

    function updateTokenAddress(address newTokenAddress) public onlyOwner {
        require(tokenAddress != newTokenAddress, "The new token address is the same as the old one");
        tokenAddress = newTokenAddress;
    }

    // Nbr tokens for one dollar
    function updateTokenPrice(uint256 newTokenPrice) public onlyOwner {
        require(tokenPrice != newTokenPrice, "The new token price is the same as the old one");
        tokenPrice = newTokenPrice;
    }

    function updateMinContribution(uint256 newMinContribution) public onlyOwner {
        require(minContribution != newMinContribution*10**tokenDecimals, "The new min contribution is the same as the old one");
        require(newMinContribution*10**tokenDecimals <= maxContribution, "The new min contribution is greater than max contribution");
        minContribution = newMinContribution*10**tokenDecimals;
    }

    function updateMaxContribution(uint256 newMaxContribution) public onlyOwner {
        require(maxContribution != newMaxContribution*10**tokenDecimals, "The new max contribution is the same as the old one");
        require(newMaxContribution*10**tokenDecimals >= minContribution, "The new max contribution is lower than min contribution");
        maxContribution = newMaxContribution*10**tokenDecimals;
    }

    function updateHardcap(uint256 newHardcap) public onlyOwner {
        require(hardcap != newHardcap*10**tokenDecimals, "The new hardcap is the same as the old one");
        require(block.timestamp < startAt, "The presale has already begun");
        hardcap = newHardcap*10**tokenDecimals;
    }

    function updateStartAt(uint256 newStartAt) public onlyOwner {
        require(startAt != newStartAt, "The new start date is the same as the old one");
        require(block.timestamp < startAt, "The presale has already begun");
        startAt = newStartAt;
    }

    function updateEndAt(uint256 newEndAt) public onlyOwner {
        require(endAt != newEndAt, "The new end date is the same as the old one");
        require(block.timestamp < endAt, "The presale is already finished");
        endAt = newEndAt;
    }

    // Withdraw remaining token after the presale
    function withdrawTokens(address to) public onlyOwner {
        require(IERC20(tokenAddress).transfer(to, IERC20(tokenAddress).balanceOf(address(this))));
    }

    // Withdraw BNBs get during the presale
    function withdrawBNB(address payable to) public onlyOwner {
        to.transfer(address(this).balance);
    }

}