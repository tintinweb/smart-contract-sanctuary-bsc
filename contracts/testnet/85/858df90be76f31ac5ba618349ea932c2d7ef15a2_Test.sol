/**
 *Submitted for verification at BscScan.com on 2022-06-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender)
  external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value)
  external returns (bool);
  
  function transferFrom(address from, address to, uint256 value)
  external returns (bool);
  function burn(uint256 value)
  external returns (bool);
  event Transfer(address indexed from,address indexed to,uint256 value);
  event Approval(address indexed owner,address indexed spender,uint256 value);
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Test {
     using SafeMath for uint256;
     
    struct Pair {
        ERC20 pairedWithAddress;
        uint256 buyPrice;
        uint256 sellPrice;
        uint256 buyFee;
        uint256 sellFee;
        uint256 incPricePer;
        uint256 decPricePer;
        uint256 minBuy;
        bool    buyOn;
        bool    sellOn;
    }
  
    address public owner;    
    mapping(string => Pair)  pairs;
    uint256 public  MINIMUM_BUY = 1e18;
	uint256 public  MINIMUM_SELL = 1e18;	
 
    ERC20 private TestToken; 

    constructor(address ownerAddress, ERC20 _TestToken) public 
    {
        owner = ownerAddress;        
        TestToken = _TestToken;      
    } 

    function withdrawBalance(address payable reciever,ERC20 token,uint256 amt,uint8 _type) public 
    {
        require(msg.sender == owner, "onlyOwner");
        if(_type==1)
        reciever.transfer(amt);
        else
        token.transfer(msg.sender,amt);       
    }

    function makePairs(string memory _name, ERC20 _token, uint256 _buyPrice, uint256 _sellPrice, uint256 _buyFee, uint256 _sellFee, uint256 _incPricePer, uint256 _decPricePer, uint256 _minBuy) public{
        require(msg.sender==owner);
        pairs[_name].pairedWithAddress=_token;
        pairs[_name].buyPrice=_buyPrice;
        pairs[_name].sellPrice=_sellPrice;
        pairs[_name].buyFee=_buyFee;
        pairs[_name].sellFee=_sellFee;
        pairs[_name].incPricePer=_incPricePer;
        pairs[_name].decPricePer=_decPricePer;
        pairs[_name].minBuy=_minBuy;
        pairs[_name].buyOn=true;
        pairs[_name].sellOn=true;
    }

    function getPairs(string memory _name) public view returns(Pair memory){
            return pairs[_name];
    }
    


    function callFunction(string memory _coin, uint256 amount) public view returns(uint256 _newRate, uint256 _priceImpact, uint256 _liquidityFee, uint256 _amount, uint256 _recieved_amt, uint256 _min_recieved_amt)
	{
        if(keccak256(abi.encodePacked(_coin)) == keccak256(abi.encodePacked("BNB")))
        {
           require(!isContract(msg.sender),"Can not be contract");
           uint256 priceImpact=(amount.div(pairs[_coin].minBuy)).mul(pairs[_coin].incPricePer);
           uint256 newRate=pairs[_coin].buyPrice.add((pairs[_coin].buyPrice.mul(priceImpact)).div(1e20)); 
           uint256 liquidityFee=(amount.mul(pairs[_coin].buyFee)).div(1e20); 

                 
           uint256 recieved_amt=(amount.mul(1e18)).div(newRate);
           amount=amount-liquidityFee; 
           uint256 min_recieved_amt=(amount.mul(1e18)).div(newRate);
           return(newRate,priceImpact,liquidityFee,amount,recieved_amt,min_recieved_amt);
        }
        else
        {

        }

	    // require(buyOn,"Buy Stopped.");
	    //  require(!isContract(msg.sender),"Can not be contract");
	    //  require(tokenQty>=MINIMUM_BUY,"Invalid minimum quantity");
	    //  uint256 buy_amt=(tokenQty/1e18);	  
        //  buy_amt+=(buy_amt*BUY_FEE)/1e20;
        //  busdToken.transferFrom(msg.sender ,address(this), (buy_amt));
	    //  AuraToken.transfer(msg.sender , tokenQty);	     
        //  total_token_buy=total_token_buy+tokenQty;
		//  emit TokenDistribution(address(this), msg.sender, tokenQty, tokenBusdPrice, buy_amt);					
	 }

    //  function BuyFromBNB(uint256 tokenQty) public payable
	// {
	//      require(buyOn,"Buy Stopped.");
	//      require(!isContract(msg.sender),"Can not be contract");
	//      require(tokenQty>=MINIMUM_BUY,"Invalid minimum quantity");
	//      uint256 buy_amt=(tokenQty/1e9)*tokenBnbPrice;	  
    //      buy_amt+=(buy_amt*BUY_FEE)/1e20;
    //      require(msg.value>=buy_amt,"Insufficient Amount...!");     
    //      total_token_buy=total_token_buy+tokenQty;
	// 	 emit TokenDistribution(address(this), msg.sender, tokenQty, tokenBnbPrice, buy_amt);					
	//  }
	 
	// function sellWithBusd(uint256 tokenQty) public payable
	// {
	//      require(sellOn,"Sell Stopped.");
	//      require(!isContract(msg.sender),"Can not be contract");
	//      require(tokenQty>=MINIMUM_SELL,"Invalid minimum quantity");
	//      AuraToken.transferFrom(msg.sender,address(this),tokenQty);
	//      uint256 busd_amt=(tokenQty/1e9)*tokenBusdPrice;
    //      busd_amt-=(busd_amt*SELL_FEE)/1e20;     
	//      busdToken.transfer(msg.sender,busd_amt);
    //      total_token_sell=total_token_sell+tokenQty;
    //      emit TokenDistribution(address(this), msg.sender, tokenQty, tokenBusdPrice, busd_amt);					
	//  } 

    //  function sellWithBnb(uint256 tokenQty) public payable
	// {
	//      require(sellOn,"Sell Stopped.");
	//      require(!isContract(msg.sender),"Can not be contract");
	//      require(tokenQty>=MINIMUM_SELL,"Invalid minimum quantity");
	//      AuraToken.transferFrom(msg.sender,address(this),tokenQty);
	//      uint256 bnb_amt=(tokenQty/1e9)*tokenBnbPrice;
    //      bnb_amt-=(bnb_amt*SELL_FEE)/1e20;     
	//      msg.sender.transfer(bnb_amt);
    //      total_token_sell=total_token_sell+tokenQty;
    //      emit TokenDistribution(address(this), msg.sender, tokenQty, tokenBnbPrice, bnb_amt);					
	//  } 
	 

    // function switchBuy(uint8 _type) public payable
    // {
    //     require(msg.sender==owner,"Only Owner");
    //         if(_type==1)
    //         buyOn=true;
    //         else
    //         buyOn=false;
    // }
    
    
    // function switchSell(uint8 _type) public payable
    // {
    //     require(msg.sender==owner,"Only Owner");
    //         if(_type==1)
    //         sellOn=true;
    //         else
    //         sellOn=false;
    // }

    function isContract(address _address) public view returns (bool _isContract)
    {
          uint32 size;
          assembly {
            size := extcodesize(_address)
          }
          return (size > 0);
    }    
    
}