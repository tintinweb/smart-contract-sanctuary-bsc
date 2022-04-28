/**
 *Submitted for verification at BscScan.com on 2022-04-28
*/

// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}





pragma solidity ^0.8.0;


interface IMain {
   
function transferFrom( address from,   address to, uint256 tokenId) external;
function ownerOf( uint _tokenid) external view returns (address);
}

interface IMain2 {
   
function transferFrom( address from,   address to, uint256 tokenId) external;
function ownerOf( uint _tokenid) external view returns (address);
}
interface IMain3 {
   
function transferFrom( address from,   address to, uint256 tokenId) external;
function ownerOf( uint _tokenid) external view returns (address);
}




interface IMB{
function burn(address holder, uint amount) external;
function mint(address _address , uint amount) external;
function balanceOf(address _address) external returns (uint);
function transferFrom( address from,   address to, uint256 amount) external;
}

interface IMC{
function burn(address holder, uint amount) external;
function mint(address _address , uint amount) external;
function balanceOf(address _address) external returns (uint);
function transferFrom( address from,   address to, uint256 amount) external;
}

contract Staking is Ownable{
     

  
  

   uint16 public totalNFTStaked ;
  

   
   struct stakeOwner{
     
      uint16[] tokens ;  
      
      uint rewards;
   }
   
    
  struct tokenInfo{
     
      uint64 stakingstartingtime ;
      uint64 rewardstartingtime ;
      uint8 period;
      // 1 for 6 months
      // 2 for 9 months
      // 3 for 12 months
      uint rewardtokens;
      uint MBtoken;
   }
   //stakedNft []staked;
   mapping(address => stakeOwner) public stakeOwners ;
   mapping(uint16 => tokenInfo) public tokensInfo ;
 
  // uint startTime = block.timestamp;
   
   uint public fees = 0.0025 ether ; 
   
   uint public multiplier = 2 ;


   
address public mainAddress = 0x97109363CC0F418ec3BdbD46f56009c03C0ce1A9; 

address public main2;
address public main3;
address public MBcontract =  0x07Cb5e4762F51804f83E21C5a3592D689e06E019;
address public MCcontract =  0x1410b56276A5219B1b83b48E303781bDa970Fcf9;


IMain Main = IMain(mainAddress);
IMain2 Main2 = IMain2(main2);
IMain3 Main3 = IMain3(main3);
IMB MB= IMB(MBcontract);
IMC MC= IMC(MCcontract);


 constructor() {
  
 }

 


  function checkTime (uint16 _tokenID) public view returns (uint64) {
     return uint64(block.timestamp) - tokensInfo[_tokenID].rewardstartingtime;
  }

  function setFees (uint _fees) external onlyOwner{
     fees= _fees;
     delete _fees;
  }
 
 

 function stake(uint16 [] calldata data , uint8 _period) external payable{
     require(msg.value >= fees , "insufficient balance");
    uint16 _number= uint16(data.length );
    require(_number > 0 , "Invalid Number");
   
    
 
      totalNFTStaked += _number;
      storeTokens(_number , data , _period);
    
      for(uint16 i ; i< _number ; i++)
    {  
       require(Main.ownerOf(data[i]) == msg.sender, "Not the owner");
    Main.transferFrom( msg.sender, address(this),data[i]);
    }
   

 }

  
 function storeTokens(uint16 _number , uint16 [] calldata data , uint8 _period ) internal {
    uint16 tokenID;
    for(uint16 i; i< _number ; i++)
    {
     tokenID=data[i];
      stakeOwners[ msg.sender].tokens.push(tokenID);
      tokensInfo[tokenID].rewardstartingtime = uint64(block.timestamp);
      tokensInfo[tokenID].stakingstartingtime = uint64(block.timestamp);
      tokensInfo[tokenID].period = _period;
      if(tokensInfo[tokenID].period == 1) 
      {
          tokensInfo[tokenID].MBtoken = 500 ether;
         tokensInfo[tokenID].rewardtokens = (tokensInfo[tokenID].MBtoken  * multiplier) / 10;
         
      }
      else if(tokensInfo[tokenID].period == 2) 
      {
          tokensInfo[tokenID].MBtoken = 800 ether;
         tokensInfo[tokenID].rewardtokens = (tokensInfo[tokenID].MBtoken  * multiplier) / 10;
      }
       else if(tokensInfo[tokenID].period == 3) 
      {
          tokensInfo[tokenID].MBtoken = 1000 ether;
         tokensInfo[tokenID].rewardtokens =(tokensInfo[tokenID].MBtoken  * multiplier) / 10;
      }
    }

 delete tokenID;
 }


   
 

function topup(uint16 tokenID , uint tokens) external {
    uint amount = MB.balanceOf(msg.sender);
    require(amount >= 0 && tokens <= amount, "Not enough balance");
    MB.burn(msg.sender ,tokens);
    
 
    tokensInfo[tokenID].MBtoken = tokensInfo[tokenID].MBtoken + tokens;
    if(tokensInfo[tokenID].period == 1) 
      {
          
         tokensInfo[tokenID].rewardtokens =(tokensInfo[tokenID].MBtoken  * multiplier) / 10;
         
      }
      else if(tokensInfo[tokenID].period == 2) 
      {
      
         tokensInfo[tokenID].rewardtokens = (tokensInfo[tokenID].MBtoken  * multiplier) / 10;
      }
       else if(tokensInfo[tokenID].period == 3) 
      {
         
         tokensInfo[tokenID].rewardtokens = (tokensInfo[tokenID].MBtoken  * multiplier) / 10;
      }
}




  function getFulltokenOf(address _address) external view returns(uint16 [] memory)
 {
    return stakeOwners[_address].tokens;
   
 }

 

  function checkIfStaked(address _address) external view returns (bool){
     if(stakeOwners[_address].tokens.length > 0){
     return  true;
     }
     else
      return false;
  }
 
  


 
   

   
   


 
  function checkHowManyStaked(address _address) external view returns(uint){
  return stakeOwners[_address].tokens.length;
  }

function checkStakedtokenIDs(address _address) external view returns(uint16 [] memory){
  return stakeOwners[_address].tokens;
  }

 
  
  
 
  function getStakingEndTime(uint16 _tokenID) public view returns(uint64){
     if(tokensInfo[_tokenID].period == 1)
     {
         return tokensInfo[_tokenID].stakingstartingtime + 180  ;
     }
     else if(tokensInfo[_tokenID].period == 2)
     {
         return tokensInfo[_tokenID].stakingstartingtime + 180;
     }
     else if(tokensInfo[_tokenID].period == 3)
     {
         return tokensInfo[_tokenID].stakingstartingtime + 180;
     }
     else
     {
         return 0;
     }
     
 }

 



 function calculateReward(address _address) public view returns (uint){
     
   uint _reward;
    for( uint i ; i < stakeOwners[_address].tokens.length ; i++)
    {
       uint16 _tokenID = stakeOwners[_address].tokens[i];
         _reward = _reward + ( (tokensInfo[_tokenID].rewardtokens /86400) * checkTime(_tokenID));
         
    }
    
    return _reward;
  
 }
 function calculateRewardfortoken(uint16 _tokenID) public view returns (uint){
   uint _reward;
    
    
       
         _reward =  ( (tokensInfo[_tokenID].rewardtokens /86400) * checkTime(_tokenID));
         
    
    
    return _reward ;
  
 }

 

 function checkStakingPeriod(uint8 _tokenID) public view returns (uint8){
     if(tokensInfo[_tokenID].period == 1)
     {
         return 6;
     }
     else if(tokensInfo[_tokenID].period == 2)
     {
         return 9;
     }
     else if(tokensInfo[_tokenID].period == 3)
     {
         return 12;
     }
     else
     {
         return 0;
     }
 }
 function checkMBstaked(uint16 _tokenID) public view returns (uint){
return tokensInfo[_tokenID].MBtoken;
 }
 


 
 function claimMTCtoken(uint16 _tokenID) external payable {
     require(stakeOwners[ msg.sender].tokens.length> 0, "You have not staked any NFTs"); 
     require(msg.value >= fees , "insufficient balance");
    uint _reward = calculateRewardfortoken(_tokenID);
    require(_reward > 0 , "No balance to claim");
    tokensInfo[_tokenID].rewardstartingtime = uint64 (block.timestamp);
    
    MC.mint(msg.sender, _reward );
 }
 function claimAllMTCtokens(address _address) external payable {
     require(stakeOwners[ msg.sender].tokens.length> 0, "You have not staked any NFTs"); 
     require(msg.value >= fees , "insufficient balance");
    uint _reward = calculateReward(msg.sender);
    require(_reward > 0 , "No balance to claim");
   
     toggleRewardStartingTime(_address);
    MC.mint(msg.sender, _reward );
 }
 function toggleRewardStartingTime(address _address) internal  {
     
    for( uint i ; i < stakeOwners[_address].tokens.length ; i++)
    {

       uint16 _tokenID = stakeOwners[_address].tokens[i];
       tokensInfo[_tokenID].rewardstartingtime = uint64(block.timestamp);
    }
    
  
  
 }




 function getRewardforUnstaking(uint16 [] calldata data,uint16 tokens) internal {
   uint _rewards;
   for(uint i ; i < tokens ; i++)
   {
      uint16 _token = data[i];
    _rewards = _rewards + tokensInfo[_token].MBtoken;
   }
   MB.mint(address(this) , _rewards);
   MB.burn(address(this) , _rewards);
   uint _reward = calculateReward(msg.sender);
    require(_reward > 0 , "No balance to claim");
    MC.mint(msg.sender, _reward);

 }





 function checkIfPeriodOver(uint16 [] calldata data) public view returns (bool)
 {
     uint64 endtime = uint64(block.timestamp);
     bool period = false;
     for (uint i ; i < data.length ; i ++)
      {
          uint16 _token= data[i];
          if(tokensInfo[_token].period == 1)
          {
          uint64 time =tokensInfo[_token].stakingstartingtime + 180;
          if( endtime >=  time )
          {
              period = true;
          }
          }
           else if(tokensInfo[_token].period == 2)
          {
          uint64 time =tokensInfo[_token].stakingstartingtime + 180;
          if( endtime >=  time )
          {
              period = true;
          }
          }
          
           else if(tokensInfo[_token].period == 3)
          {
          uint64 time =tokensInfo[_token].stakingstartingtime + 180;
          if( endtime >=  time )
          {
              period = true;
          }
          }
        

      }
      return period;
 }

 
 function unstake(uint16 [] calldata data) external payable{
    require(stakeOwners[ msg.sender].tokens.length> 0, "You have not staked any NFTs");
     require(msg.value >= fees , "insufficient balance"); 
    uint16 tokens =uint16(data.length);
    bool periodOver = checkIfPeriodOver(data);
    require( periodOver , "Staking Period is still not over");
   getRewardforUnstaking(data , tokens);
  
    
    uint16 tokenID;
    for(uint16 i; i<tokens; i++)
    {
    tokenID=data[i];
    Main.transferFrom(address(this),msg.sender,tokenID);
    removeToken(tokenID);
     delete tokensInfo[tokenID];
    }
   
   totalNFTStaked -= tokens;
  

    
    delete tokenID;
 }
 


   function removeToken(uint16 token) internal {
   uint x=   stakeOwners[ msg.sender].tokens.length  ;
   if (token == stakeOwners[ msg.sender].tokens[x-1])
   {
        stakeOwners[ msg.sender].tokens.pop();
   }
   else{
    for (uint i ; i < stakeOwners[ msg.sender].tokens.length ; i ++)
    {

      if(token == stakeOwners[ msg.sender].tokens[i] )
      {
        uint16 temp = stakeOwners[ msg.sender].tokens[x-1];
        stakeOwners[ msg.sender].tokens[x-1]   =  stakeOwners[ msg.sender].tokens[i];
        stakeOwners[ msg.sender].tokens[i] = temp;
        stakeOwners[ msg.sender].tokens.pop();
      }
    }
   }
   }

	function setMainAddress(address contractAddr) external onlyOwner {
		mainAddress = contractAddr;
        Main= IMain(mainAddress);
	}  
    function setMBTokenAddress (address contractAddr) external onlyOwner {
	
         
       MB= IMB(contractAddr) ; 
	}  
     function setMCTokenAddress (address contractAddr) external onlyOwner {
	
         
       MC= IMC(contractAddr) ; 
	}
    function setMultiplier (uint _multiplier) external onlyOwner {
	
         
     multiplier = _multiplier  ; 
	}

   function withdraw() external onlyOwner{
      uint _balance = address(this).balance;
     payable(msg.sender).transfer(_balance ); 
   }

}