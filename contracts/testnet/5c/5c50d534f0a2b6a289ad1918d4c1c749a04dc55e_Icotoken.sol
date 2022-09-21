/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol


pragma solidity ^0.8.0;

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

// File: presale token price in dollar.sol


pragma solidity 0.8.7;


interface IERC20 {

//Fuction that use in ERC20 token    
    function totalSupply() external view returns(uint);
    function balanceOf(address Owner) external view returns (uint);
    function allowance(address tokenOwner, address spender) external view returns(uint);
    function transfer(address to, uint token) external returns(bool);
    function approve (address spender , uint token ) external returns (bool);
    function transferFrom(address from, address to , uint token) external returns(bool); 

//Events use in ERC20
    event approval(address indexed Owner, address indexed to, uint token);
    event Transfer(address from ,address to , uint token);
   
} 

contract Icotoken {
    
   IERC20 token;
   

   uint public tokenInOneDollar;

   address public  tokenOwner;
//    uint public oneEther=1e18;

AggregatorV3Interface internal priceFeed;

  constructor(address tokenaddress,address _tokenOwner,uint _tokenInOneDollar ){
       token=IERC20(tokenaddress);
       tokenOwner=_tokenOwner;
       tokenInOneDollar=_tokenInOneDollar;
       priceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);

   }
 function getLatestPrice() public view returns (int) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
        ) = priceFeed.latestRoundData();
        return price;
    }
   

//    function buy1() payable external {
//      uint  amount=tokenInOneEther*msg.value;
//        token.transfer(msg.sender,amount);

//     }
     function buy() payable external {
        
     uint  dollarInEther=msg.value*uint(getLatestPrice())/1 ether;
     uint amount=(dollarInEther*tokenInOneDollar)/1e8;
       token.transferFrom(tokenOwner,msg.sender,amount);

    }
 
    // function sell( uint amountOfToken) public {
   
    //       uint totalToken = (amountOfToken * 1 ether)/26909000000;
    //         uint totalAmount=(totalToken/tokenInOneDollar)*1e8;
    //       payable(msg.sender).transfer(totalAmount);
    //         token.transferFrom(msg.sender,tokenOwner,amountOfToken);

    // }

    function checkBalance() external view  returns(uint) {
        return address(this).balance;
    }
}