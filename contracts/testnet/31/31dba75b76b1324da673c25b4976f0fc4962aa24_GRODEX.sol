/**
 *Submitted for verification at BscScan.com on 2022-12-28
*/

pragma solidity 0.5.4;

interface IBEP20 {
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

contract GRODEX  {
     using SafeMath for uint256;
     
    uint256 public tokenPrice=1e17;
  	
	bool   public  buyOnGNR;    
	bool   public  sellOnGNR;
    bool   public  buyOnGRO;
    bool   public  sellOnGRO;
    
    uint256 public gnrTobusdFee;
    uint256 public groTognrFee;
	
    address public owner;
    address public marketingAddress;
     
    IBEP20 private gnrToken;
    IBEP20 private groToken; 
    IBEP20 private busdToken; 

    event TokenDistribution(address sender, address receiver, IBEP20 tokenFirst, IBEP20 tokenSecond, uint256 tokenIn, uint256 tokenOut);

    constructor(address ownerAddress, address _marketingAddress, IBEP20 _busdToken, IBEP20 _groToken, IBEP20 _gnrToken) public 
    {
        owner = ownerAddress;
        marketingAddress = _marketingAddress;
        gnrToken  = _gnrToken;
        groToken  = _groToken;
        busdToken = _busdToken;
      

        buyOnGNR = true;
        sellOnGNR = true;
        buyOnGRO = true;
        sellOnGRO = true;      
    } 
   
    function updateFee(uint256 _gnrTobusdFee, uint256 _groTognrFee) public {
        gnrTobusdFee = _gnrTobusdFee;       
        groTognrFee = _groTognrFee;
    }
    
    function swapBUSDtoGNR(uint256 busdQty) public payable
	{
	     require(buyOnGNR,"Buy Stopped.");
	     require(!isContract(msg.sender),"Can not be contract");
         busdToken.transferFrom(msg.sender ,address(this), (busdQty));
	     uint256 totalGNR=(busdQty*1e18)/tokenPrice;  
         gnrToken.transfer(msg.sender , totalGNR);
		 emit TokenDistribution(address(this), msg.sender, busdToken, gnrToken, busdQty, totalGNR);					
	 }

    function swapGNRtoBUSD(uint256 tokenQty) public payable
	{
	     require(sellOnGNR,"Sell Stopped.");
	     require(!isContract(msg.sender),"Can not be contract");    
	     gnrToken.transferFrom(msg.sender,address(this),tokenQty);
         uint256 ded=(tokenQty*gnrTobusdFee)/100;
         if(ded>0)
         gnrToken.transfer(marketingAddress, ded);
         uint256 busd_amt=((tokenQty-ded)/1e18)*tokenPrice;	     
	     busdToken.transfer(msg.sender,busd_amt);
         emit TokenDistribution(msg.sender, address(this), gnrToken, busdToken, tokenQty, busd_amt);					
	 } 
	 
     function swapGNRtoGRO(uint256 gnrQty) public payable
	{
	     require(buyOnGRO,"Buy Stopped.");
	     require(!isContract(msg.sender),"Can not be contract");  
	     gnrToken.transferFrom(msg.sender, address(this), gnrQty);
	     uint256 totalGRO=(gnrQty*1e18)/getGROPrice();  
         groToken.transfer(msg.sender , totalGRO);
		 emit TokenDistribution(address(this), msg.sender, gnrToken, groToken, gnrQty, totalGRO);					
	 }


	function swapGROtoGNR(uint256 groQty) public payable
	{
	     require(sellOnGRO,"Sell Stopped.");
	     require(!isContract(msg.sender),"Can not be contract");
	     groToken.transferFrom(msg.sender,address(this),groQty);
         uint256 ded=(groQty*groTognrFee)/100;
         if(ded>0)
         groToken.transfer(marketingAddress, ded);
         uint256 restToken = groQty-ded;
	     uint256 totalGNR = (restToken/1e18)*getGROPrice();
	     gnrToken.transfer(msg.sender,totalGNR);
         emit TokenDistribution(msg.sender, address(this), groToken,  gnrToken, groQty, totalGNR);					
	 } 	

     function getBUSDtoGNR(uint256 busdQty) public view returns(uint256)
     {
	     return (busdQty*1e18)/tokenPrice;  
     }

    function getGNRtoBUSD(uint256 tokenQty) public view returns(uint256)
	{
         uint256 ded=(tokenQty*gnrTobusdFee)/100;
         return ((tokenQty-ded)/1e18)*tokenPrice;
    } 
	 
    function getGNRtoGRO(uint256 gnrQty) public view returns(uint256)
	{
	    return (gnrQty*1e18)/getGROPrice();      
    }


	function getGROtoGNR(uint256 groQty) public view returns(uint256)
	{
	     uint256 ded=(groQty*groTognrFee)/100;
	     return ((groQty-ded)/1e18)*getGROPrice();
    } 	

    function getGROPrice() public view returns(uint256)
    {
       return ((gnrToken.balanceOf(address(this))*1e18)/groToken.balanceOf(address(this)));
    } 
	
	
    function isContract(address _address) public view returns (bool _isContract)
    {
          uint32 size;
          assembly {
            size := extcodesize(_address)
          }
          return (size > 0);
    }   
   
    
    function updatePrice(uint256 _price) public payable
    {
              require(msg.sender==owner,"Only Owner"); 
              tokenPrice=_price;
    }
    
    
    function switchBuyGNR(bool e) public payable
    {
        require(msg.sender==owner,"Only Owner");
            buyOnGNR=e;
    }

    function switchBuyGRO(bool e) public payable
    {
        require(msg.sender==owner,"Only Owner");
            buyOnGRO=e;
    }
    
    function switchSellGNR(bool e) public payable
    {
        require(msg.sender==owner,"Only Owner");
            sellOnGNR=e;
    }
    
    function switchSellGRO(bool e) public payable
    {
        require(msg.sender==owner,"Only Owner");
            sellOnGRO=e;
    }
  
    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
}