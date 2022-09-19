/**
 *Submitted for verification at BscScan.com on 2022-09-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
interface IERC20 {   
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function decimals() external view returns(uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
contract PriceConsumerV3  { 
    AggregatorV3Interface internal priceFeed;
    /**  
     * Network: Binance
     * Aggregator: BNB/USD
     * Address: 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
     */
    constructor() {
        priceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);
    }      
    /**
     * Returns the latest price
     */
    function getLatestPrice() public view returns (int) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return price;
    }
}
contract Presale  {
    IERC20 public token;
     PriceConsumerV3 parentInstance;    
    //  uint256 decimals =18;
    //  uint256 mult_dec = 10**decimals;
    event Bought(uint256 amount,uint256 Token_num);
    event Sold(uint256 amount, uint256 Token_num);
    address public owner ;
    //uint256 totalSupply_ = 10**18;
    uint256 public setPrice_ =100;  
    uint256 public setdecimals_; 
   // uint public _numToken;  
  // uint256 public oneTokenInWei=6993006900000;
    constructor( address _contractAddress, address _PriceConsumerV3) {
     token = IERC20(_contractAddress);
     owner =msg.sender;
    setdecimals_ = 10** token.decimals();
    parentInstance = PriceConsumerV3 ( _PriceConsumerV3);
    }       
    function setPrice( uint256 _setPrice) public  {
        require ( msg.sender==owner,"only owner can set price ");
        setPrice_= _setPrice;
    }
// parentInstancepping(address=>uint256) balances; 
    // function sendToken(address _owner) public {
    // }
    // modifier onlyOwner(){
    //   require(msg.sender == owner);
    //   _;  
    // }
//     function setEthPrice(uint _etherPrice) public {
//     oneTokenInWei = 1 ether * 2 / _etherPrice / 100;
//    // changed(msg.sender); 
//      }
    function buy() payable public  {                    // sending ethers to the caller of this contract
        int _etherPrice = (parentInstance.getLatestPrice())/10**8;
        // uint256 amount_ether = (msg.value )/ uint(_etherPrice);  
            //  require( msg.value ==  )     
                 uint256 amount_ether = (msg.value )*uint(_etherPrice);     // 698812019566736.5
        
        //  uint256 numToken = ( amount_ether * setPrice_ * setdecimals_) /10**18  ;    // setPrice_ * setdecimals_                 
         uint256 numToken = ( amount_ether * setPrice_ * setdecimals_) /10**18  ;
        require(amount_ether > 0, "send some ether");  
        //token.transfer(msg.sender, _numToken);  // sending number of tokens to the buyer
        token.transferFrom(owner,msg.sender ,numToken);  // sending tokens from owner's address to buyer
     //   emit Bought(amount_ether, numToken);    
    }                         
//   function balanceOf(address _address) public view returns (uint256) {
//         return balances[_address];
//     }
    function sell(uint256 numToken ) public{
     // numToken =(numToken);       //*(10**18)  
      int _etherPrice = (parentInstance.getLatestPrice())/10**8;
    //    uint256 amount_ether = (msg.value )*uint(_etherPrice); 
        require(numToken>0, "sell some tokens ");
        uint256 amount_ether = (numToken * 10**18)/(setPrice_*setdecimals_ * uint(_etherPrice));//();
        require(amount_ether>0, " ");             
        uint256 _allowed= token.allowance(msg.sender,address(this));     // user is allowing this contract 
        require(_allowed >0, " No tokens are allowed by the user "  );
        token.transferFrom(msg.sender,address(this), numToken); // transfering tokens from user address to the contract address 
        payable(msg.sender).transfer(amount_ether);     
    //  emit Sold(amount_ether,numToken);        
    }
}










    // function sell(uint256 amount_Token) public{
    //     require(amount_Token > 0, "You need to sell at least some tokens");
    //     uint256 Allowance = token.allowance(msg.sender, address(this)); // caller is allowing  the contract address
    //     require(Allowance >= amount_Token, "Check the token allowance");
    //     token.transferFrom(msg.sender, address(this), amount_Token); //from caller address to the contract address
    //     payable(msg.sender).transfer(amount_Token);
    //     //emit Sold(amount_Token);
    // }