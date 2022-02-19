/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

// SPDX-License-Identifier: none
pragma solidity ^0.8.4;

 
interface BEP20 {
             function totalSupply() external view returns (uint theTotalSupply);
             function balanceOf(address _owner) external view returns (uint balance);
             function transfer(address _to, uint _value) external returns (bool success);
             function transferFrom(address _from, address _to, uint _value) external returns (bool success);
             function approve(address _spender, uint _value) external returns (bool success);
             function allowance(address _owner, address _spender) external view returns (uint remaining);
             event Transfer(address indexed _from, address indexed _to, uint _value);
             event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract Ownable 
{    

  address private _owner;
  
  constructor()
  {
    _owner = msg.sender;
  }
 
  function owner() public view returns(address) 
  {
    return _owner;
  }
  
modifier onlyOwner() 
  {
    require(isOwner(), "Function accessible only by the owner !!");
    _;
}
 
 function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        
        _owner = newOwner;

 }


  function isOwner() public view returns(bool) 
  {
    return msg.sender == _owner;
  }


}

contract PrivateSaleBoss is Ownable {
    
   
    struct Buyer{
        address referer;
        uint tokensBought;
        bool registered;
    }
    
    struct Referral{
        bool refReg;
        uint referred;
        address[] referredUsers;
    }
    
    struct Scratch{
        uint[] tokenAmt;
        uint[] buyAt;
        bool claimed;
    }
      
    address private contractAddr = address(this);
  
    uint startTime = 0;

    uint scratchAmount = 0;

    uint minimumTokenForScratch = 0;

    uint TokenPricePerBNB = 200000 ;
    
    mapping(address => Buyer) buyer;
    mapping(address => Scratch) scratch;
    mapping(address => Referral) ref;
    
    event Received(address, uint);
    event TokensBought(address, uint);
    event OwnershipTransferred(address);
    event Airdrop(address[], uint);
    
    // Set Start Time
    function setStartTime(uint time_) public onlyOwner {
         
        startTime = time_;
    }
    
 
    // BUY TOKEN & Referral Reward
    function buyToken(address referer) public payable returns(bool) {
        
        uint amount = msg.value * TokenPricePerBNB ;
    
        require(startTime > 0, "Start time not defined");
        require(block.timestamp > startTime, "Private Sale not started yet");
     
        require(msg.value > 0, "Zero value");
         
        uint tokens= amount ;
          
        buyer[msg.sender].tokensBought += tokens;
        buyer[msg.sender].registered = true;
        if(buyer[msg.sender].referer == address(0)){
            buyer[msg.sender].referer = referer;
        }

        scratch[msg.sender].tokenAmt.push(tokens);
        scratch[msg.sender].buyAt.push(block.timestamp);
        scratch[msg.sender].claimed = false;
        
        emit TokensBought(msg.sender, tokens);

        return true;
    }
    
    // Set Buy Price
    function setTokenPricePerBNB(uint price) public onlyOwner returns(bool) {
 
        TokenPricePerBNB = price;

        return true;

    }
     
    // View Buy Price
    function viewPrice() public view returns(uint){
        return TokenPricePerBNB;
    }
     
    
    // // Claim Scratch Coupon tokens
    // function claim() public returns (bool) {

    //     require(scratch[msg.sender].claimed == false, "User has already claimed tokens");

    //     require(minimumTokenForScratch != 0, "Minimum limit not set");

    //     require(buyer[msg.sender].tokensBought > minimumTokenForScratch, "Not eligible for scratch");
    //     require(scratchAmount != 0, "Scratch amount not set");

    //     BEP20 token = BEP20(tokenAddr);

    //     token.transfer(msg.sender, scratchAmount);
    //     scratch[msg.sender].claimed = true;
    //     return true;
    // }
    
    // Update buyer Details
    function updateBuyerDetails(address user,
    address[] memory _referrals,
    address _referer,
    uint _tokensBought,
    uint[] memory _tokenBuy,
    uint[] memory _buyTime,
    bool _scratch
    )
    public onlyOwner returns  (bool){
        
        buyer[user].tokensBought = _tokensBought;
        buyer[user].registered = true;
        if(buyer[user].referer == address(0)){
            buyer[user].referer = _referer;
        }
        
        for(uint i = 0; i < _referrals.length; i++){
            ref[user].referredUsers.push(_referrals[i]);
        }
        
        for(uint j = 0; j < _tokenBuy.length; j++){
            scratch[user].tokenAmt.push(_tokenBuy[j]);
            scratch[user].buyAt.push(_buyTime[j]);
            scratch[user].claimed = _scratch;
        }
        
        return true;
    }
    
    // Show Buyer Details
    function buyerDetails(address user) public view returns(bool, address, uint, uint[] memory, uint[] memory, bool){
        bool reg = buyer[user].registered;
        address referer = buyer[user].referer;
        uint totalTokensBought = buyer[user].tokensBought;
        uint[] memory tokensBought = new uint[](scratch[user].tokenAmt.length);
        uint[] memory buyTime = new uint[](scratch[user].tokenAmt.length);
        
        for(uint i = 0; i< scratch[user].tokenAmt.length; i++){
            tokensBought[i] = scratch[user].tokenAmt[i];
            buyTime[i] = scratch[user].buyAt[i];
        }
        
        bool claimStatus = scratch[user].claimed;
        
        return (reg, referer, totalTokensBought, tokensBought, buyTime, claimStatus);
    }
     
     
    
    // Owner Token Withdraw    
    function withdrawToken(address tokenAddress, address to, uint amount) public onlyOwner returns(bool) {
         
        BEP20 token = BEP20(tokenAddress);
        token.transfer(to, amount);
        return true;
    }
    
    // Owner BNB Withdraw
    function withdrawBNB(address payable to, uint amount) public onlyOwner returns(bool) {
   
        to.transfer(amount);
        return true;
    }
     
    // Fallback
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}