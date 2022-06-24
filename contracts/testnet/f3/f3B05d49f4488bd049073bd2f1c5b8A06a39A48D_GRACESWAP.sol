/**
 *Submitted for verification at BscScan.com on 2022-06-23
*/

// SPDX-License-Identifier: MIT

// 0x6dA4867268c80BFcc1Fe4515A841eCa6299557Fb  owner
// 0x4416f4534de2D7B9703bd4252012326b902bd7C0  token
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

contract GRACESWAP {
     using SafeMath for uint256;
     
    struct Pair {
        ERC20 pairedWithAddress;
        uint256 liveRate;
        uint256 buyFee;
        uint256 sellFee;
        uint256 incPricePer;
        uint256 decPricePer;
        uint256 minBuy;
        uint256 minSell;
        uint256 maxBuy;
        uint256 maxSell;
        bool    buyOn;
        bool    sellOn;
    }
  
    address public owner;    
    mapping(string => Pair)  pairs;
    uint256 public  maxImpact;	
 
    ERC20 private GraceToken; 

    constructor(address ownerAddress, ERC20 _GraceToken) public 
    {
        owner = ownerAddress;        
        GraceToken = _GraceToken;      
    } 

    function withdrawBalance(address payable reciever,ERC20 token,uint256 amt,uint8 _type) public 
    {
        require(msg.sender == owner, "onlyOwner");
        if(_type==1)
        reciever.transfer(amt);
        else
        token.transfer(msg.sender,amt);       
    }

    function makePairs(string memory _name, ERC20 _token, uint256 _liveRate, uint256 _buyFee, uint256 _sellFee, uint256 _incPricePer, uint256 _decPricePer, uint256 _minBuy, uint256 _minSell, uint256 _maxBuy, uint256 _maxSell) public{
        require(msg.sender==owner);
        pairs[_name].pairedWithAddress=_token;
        pairs[_name].liveRate=_liveRate;
        pairs[_name].buyFee=_buyFee;
        pairs[_name].sellFee=_sellFee;
        pairs[_name].incPricePer=_incPricePer;
        pairs[_name].decPricePer=_decPricePer;
        pairs[_name].minBuy=_minBuy;
        pairs[_name].minSell=_minSell;
        pairs[_name].maxBuy=_maxBuy;
        pairs[_name].maxSell=_maxSell;
        pairs[_name].buyOn=true;
        pairs[_name].sellOn=true;
    }

    function getPairs(string memory _name) public view returns(Pair memory){
            return pairs[_name];
    }

    function setMaxImpact(uint256 _impact) public {
            maxImpact=_impact;
    }
    


    function calcBuy(string memory _coin, uint256 amount) public view returns(uint256 _newRate, uint256 _priceImpact, uint256 _liquidityFee, uint256 _amount, uint256 _recieved_amt, uint256 _min_recieved_amt)
	{
           uint256 priceImpact=(amount.div(pairs[_coin].minBuy)).mul(pairs[_coin].incPricePer);
           
           if(priceImpact>maxImpact)
              priceImpact=maxImpact;

           uint256 newRate=pairs[_coin].liveRate.add((pairs[_coin].liveRate.mul(priceImpact)).div(1e20)); 
           uint256 liquidityFee=(amount.mul(pairs[_coin].buyFee)).div(1e20); 
                 
           uint256 recieved_amt=(amount.mul(1e18)).div(newRate);
           amount=amount-liquidityFee; 
           uint256 min_recieved_amt=(amount.mul(1e18)).div(newRate);
           return(newRate,priceImpact,liquidityFee,amount,recieved_amt,min_recieved_amt);        				
	 }


      function calcSell(string memory _coin, uint256 amount) public view returns(uint256 _newRate, uint256 _priceImpact, uint256 _liquidityFee, uint256 _amount, uint256 _recieved_amt, uint256 _min_recieved_amt)
	{
           uint256 priceImpact=(amount.div(pairs[_coin].minSell)).mul(pairs[_coin].decPricePer);
           
           if(priceImpact>maxImpact)
              priceImpact=maxImpact;

           uint256 newRate=pairs[_coin].liveRate.sub((pairs[_coin].liveRate.mul(priceImpact)).div(1e20)); 
           uint256 liquidityFee=(amount.mul(pairs[_coin].sellFee)).div(1e20); 
                 
           uint256 recieved_amt=(amount).mul(newRate);
           amount=amount-liquidityFee; 
           uint256 min_recieved_amt=(amount.mul(1e18)).div(newRate);
           return(newRate,priceImpact,liquidityFee,amount,recieved_amt,min_recieved_amt);        				
	 }

     function swapBuy(string memory _coin, uint256 amount) public payable
	{
        require(!isContract(msg.sender),"Can not be contract!");
        require(amount>=pairs[_coin].minBuy,"Minimum Quantity Error!");
        require(amount<=pairs[_coin].maxBuy,"Maximum Quantity Error!");

        uint256 priceImpact=(amount.div(pairs[_coin].minBuy)).mul(pairs[_coin].incPricePer);
           
           if(priceImpact>maxImpact)
              priceImpact=maxImpact;

           uint256 newRate=pairs[_coin].liveRate.add((pairs[_coin].liveRate.mul(priceImpact)).div(1e20)); 
           uint256 liquidityFee=(amount.mul(pairs[_coin].buyFee)).div(1e20); 
           amount=amount-liquidityFee; 
           uint256 min_recieved_amt=(amount.mul(1e18)).div(newRate);
           
           pairs[_coin].liveRate=newRate;
           pairs[_coin].pairedWithAddress.transferFrom(msg.sender,address(this),(amount+liquidityFee));	
           GraceToken.transfer(msg.sender,min_recieved_amt);				
	 }


     function swapSell(string memory _coin, uint256 amount) public payable
	{
        require(!isContract(msg.sender),"Can not be contract!");
        require(amount>=pairs[_coin].minSell,"Minimum Quantity Error!");
        require(amount<=pairs[_coin].maxSell,"Maximum Quantity Error!");

        uint256 priceImpact=(amount.div(pairs[_coin].minSell)).mul(pairs[_coin].decPricePer);
           
           if(priceImpact>maxImpact)
              priceImpact=maxImpact;

           uint256 newRate=pairs[_coin].liveRate.sub((pairs[_coin].liveRate.mul(priceImpact)).div(1e20)); 
           uint256 liquidityFee=(amount.mul(pairs[_coin].sellFee)).div(1e20); 
           amount=amount-liquidityFee; 
           uint256 min_recieved_amt=(amount.mul(1e18)).div(newRate);
           
           pairs[_coin].liveRate=newRate;
           GraceToken.transferFrom(msg.sender,address(this),(amount+liquidityFee));	
           pairs[_coin].pairedWithAddress.transfer(msg.sender,min_recieved_amt);				
	 }
    
    function switchSell(string memory _coin, uint8 _type) public payable
    {
        require(msg.sender==owner,"Only Owner");
            if(_type==1)
            pairs[_coin].sellOn=true;
            else
            pairs[_coin].sellOn=false;
    }

     function switchBuy(string memory _coin, uint8 _type) public payable
    {
        require(msg.sender==owner,"Only Owner");
            if(_type==1)
            pairs[_coin].buyOn=true;
            else
            pairs[_coin].buyOn=false;
    }

    function isContract(address _address) public view returns (bool _isContract)
    {
          uint32 size;
          assembly {
            size := extcodesize(_address)
          }
          return (size > 0);
    }    
    
}