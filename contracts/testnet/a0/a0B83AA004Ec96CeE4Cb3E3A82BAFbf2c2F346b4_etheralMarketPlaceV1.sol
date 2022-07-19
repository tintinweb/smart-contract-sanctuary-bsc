/**
 *Submitted for verification at BscScan.com on 2022-07-18
*/

pragma solidity ^0.8.10;

/**
 * The contractName contract does this and that...
 */

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
} 
contract etheralMarketPlaceV1 {
  
	struct item{
		bytes32 itemid;
		uint256	price;
		address tokenAddress;
		bool sold;
		bool escrowInitiated;
        bool shipped;
        uint256 shippedTimestamp;
		address seller;
		address escrowInitiator;
        bool allowedReward;
        bool disputed;
	}

    address etheralToken=address(0);

    IBEP20 public eTokenInstance = IBEP20(etheralToken);

	mapping(bytes32=>item) listedItems;
    mapping(address=>uint256) successfulSales;
    mapping(address=>uint256) lostDisputes;

    mapping(address=>bool) banned;

    mapping(address=>bool) authorizedToken;

    mapping(address=>bool) hasVotePrivilege;

    uint256 rewardPercent=1;
    uint256 itemNumber =0;

    uint256 listingFee=1;

    uint256 voterFee=0;

    uint256 votersPool=0;
    uint256 nVoters=0;
    uint256 lastAddedToPool=0;
    mapping(address=>uint256) lastClaimed;

    mapping(bytes32=>uint256) sellerVotes;
    mapping(bytes32=>uint256) buyerVotes;
    mapping(bytes32=>uint256) voteEnds;

    mapping(bytes32=>bool) votedFor;

    //Voter privileges

    function availableRewardFromVotersPool() public view returns(uint256){
        require(lastClaimed[msg.sender]<lastAddedToPool,"You do not have any rewards available.");
        require(hasVotePrivilege[msg.sender]==true,"You must vote before being eligible for rewards.");        
        return votersPool/nVoters;
    }

    function claimFromVotersPool() public{
        require(lastClaimed[msg.sender]<lastAddedToPool,"You do not have any rewards available.");
        require(hasVotePrivilege[msg.sender]==true,"You must vote before being eligible for rewards.");
        eTokenInstance.transfer(msg.sender,votersPool/nVoters);

    }



    //Dispute resolutions


    function getDisputeStatus(bytes32 id) public view returns(int256){
        int256 timeLeft=int256(voteEnds[id])-int256(block.timestamp);

        if(timeLeft<0){
            return 0;
        } else {
            return timeLeft;
        }

    }

    function getTotalVotes(bytes32 id) public view returns(uint256){
        return sellerVotes[id]+buyerVotes[id];
    }

    function voteForSeller(bytes32 id) public {
        bytes32 voteid=keccak256(abi.encodePacked(msg.sender,id));
        require(votedFor[voteid]==false,"Already voted.");
        require(block.timestamp<voteEnds[id],"Dispute ended. Winning party can execute verdict.");
        require(listedItems[id].disputed==true,"Not disputed");
        sellerVotes[id]+=1;
        votedFor[voteid]=true;
        hasVotePrivilege[msg.sender]=true;
    }

    function voteForBuyer(bytes32 id) public {
        bytes32 voteid=keccak256(abi.encodePacked(msg.sender,id));
        require(votedFor[voteid]==false,"Already voted.");
        require(block.timestamp<voteEnds[id],"Dispute ended. Winning party can execute verdict.");
        require(listedItems[id].disputed==true,"Not disputed");
        buyerVotes[id]+=1;
        votedFor[voteid]=true;
        hasVotePrivilege[msg.sender]=true;

    }

    function executeVerdict(bytes32 id) public {
        require(block.timestamp>voteEnds[id],"Dispute not finished.");
        require(listedItems[id].disputed==true,"Not disputed");
        
        if(sellerVotes[id]>buyerVotes[id]){
            //seller wins dispute
            if(listedItems[id].allowedReward==true){
            IBEP20 token = IBEP20(listedItems[id].tokenAddress);
            token.transfer(listedItems[id].seller,(listedItems[id].price+((listedItems[id].price/100)*rewardPercent)));          
            listedItems[id].sold=true;        

            } else {
            IBEP20 token = IBEP20(listedItems[id].tokenAddress);
            token.transfer(listedItems[id].seller,listedItems[id].price);  
            listedItems[id].sold=true;        
            }   

            successfulSales[listedItems[id].seller]+=1;
        }

        if(buyerVotes[id]>sellerVotes[id]){
            //buyer wins dispute
            IBEP20 token = IBEP20(listedItems[id].tokenAddress);
            token.transfer(listedItems[id].escrowInitiator,listedItems[id].price); 
            lostDisputes[listedItems[id].seller]+=1;
            
            delete listedItems[id];         


        }

        if(buyerVotes[id]==sellerVotes[id]){
            //stalemate
            IBEP20 token = IBEP20(listedItems[id].tokenAddress);
            token.transfer(listedItems[id].escrowInitiator,listedItems[id].price); 
        }

    }











    address owner=0xa5A0039B60a91b5220E4E5Cd1CdEC02a3C1CC3ee;

    //Marketplace functions
    function authorizeToken(address token) public {
        require(msg.sender==owner);
        authorizedToken[token]=true;
    }

    function setEtheralToken(address token) public {
        require(msg.sender==owner);
        etheralToken=token;
        eTokenInstance = IBEP20(etheralToken);        
    }


    function modifyRewardPercent(uint256 perc) public {
        require(msg.sender==owner);
        rewardPercent=perc;
    }
  function addItem (uint256 price,address selectedToken)  public returns(bytes32)  {
    require(authorizedToken[selectedToken]==true,"Token not authorized");
    require(banned[msg.sender]==false,"You are banned");    
    eTokenInstance.transferFrom(msg.sender,address(this),(price/100)*listingFee);
    votersPool+=(price/100)*listingFee;
    lastAddedToPool=block.timestamp;

    bytes32 genid=keccak256(abi.encodePacked(msg.sender,itemNumber));
  	listedItems[genid].itemid=genid;
  	listedItems[genid].price=price;
  	listedItems[genid].tokenAddress=selectedToken;
  	listedItems[genid].sold=false;
  	listedItems[genid].escrowInitiated=false;
    listedItems[genid].seller=msg.sender;
    listedItems[genid].escrowInitiator=address(0);
    listedItems[genid].shipped=false;
    listedItems[genid].disputed=false;
    if(selectedToken==etheralToken){
        listedItems[genid].allowedReward=true;
    }
    itemNumber+=1;    
    return genid;
  }

  function retrieveItemPrice(bytes32 id) public view returns(uint256){
  	return listedItems[id].price;
  }
  function retrieveItemCurrency(bytes32 id) public view returns(address){
  	return listedItems[id].tokenAddress;
  }
  function retrieveItemSoldStatus(bytes32 id) public view returns(bool){
  	return listedItems[id].sold;
  }
  function retrieveItemEscrowStatus(bytes32 id) public view returns(bool){
  	return listedItems[id].escrowInitiated;
  }    
  function retrieveItemEscrowInitiator(bytes32 id) public view returns(address){
  	return listedItems[id].escrowInitiator;
  }        
  function retrieveItemSeller(bytes32 id) public view returns(address){
  	return listedItems[id].seller;
  }   

  function isSold(bytes32 id) public view returns(bool) {
  	return listedItems[id].sold;
  }

  function isShipped(bytes32 id) public view returns(bool){
    return listedItems[id].shipped;
  }

  function isDisputed(bytes32 id) public view returns(bool){
    return listedItems[id].disputed;
  }

  function getSellerScore(address seller) public view returns(uint256){
    return successfulSales[seller];
  }

  function getSellerDisputes(address seller) public view returns(uint256){
    return lostDisputes[seller];
  }



  function depositEscrow(bytes32 id) public {
    require(banned[msg.sender]==false,"You are banned");    
    IBEP20 token = IBEP20(listedItems[id].tokenAddress);
    token.transferFrom(msg.sender,address(this),listedItems[id].price);
    listedItems[id].escrowInitiated=true;
    listedItems[id].escrowInitiator=msg.sender;
  }

  function isFundsDeposited(bytes32 id) public view returns(bool){
  	return listedItems[id].escrowInitiated;
  }

  function markShipped(bytes32 id) public {
    require(msg.sender==listedItems[id].seller,"Not seller");
    listedItems[id].shipped=true;
    listedItems[id].shippedTimestamp=block.timestamp;
  }




  function openDispute(bytes32 id) public{
    require(listedItems[id].escrowInitiated==true);
    require(msg.sender==listedItems[id].escrowInitiator);
    listedItems[id].disputed=true;
    voteEnds[id]=block.timestamp+(86400*7);
  }

  function claimEscrow(bytes32 id) public {
    require(msg.sender==listedItems[id].seller);
    require(listedItems[id].shipped==true);
    require(listedItems[id].disputed==false);
    require(listedItems[id].sold==false);
    require(listedItems[id].escrowInitiated==true);
    uint256 daysPassed=(block.timestamp-listedItems[id].shippedTimestamp)/86400;
    require(daysPassed>14);

    if(listedItems[id].allowedReward==true){
    IBEP20 token = IBEP20(listedItems[id].tokenAddress);
    token.transfer(listedItems[id].seller,(listedItems[id].price+((listedItems[id].price/100)*rewardPercent)));          
    listedItems[id].sold=true;        

    } else {
    IBEP20 token = IBEP20(listedItems[id].tokenAddress);
    token.transfer(listedItems[id].seller,listedItems[id].price);  
    listedItems[id].sold=true;        

    }
    successfulSales[listedItems[id].seller]+=1;

  }

  function releaseEscrow(bytes32 id) public {
    require(listedItems[id].escrowInitiated==true);  
    require(listedItems[id].sold==false);

    require(listedItems[id].disputed==false);  
  	require(msg.sender==listedItems[id].escrowInitiator);
    if(listedItems[id].allowedReward==true){
    IBEP20 token = IBEP20(listedItems[id].tokenAddress);
    token.transfer(listedItems[id].seller,(listedItems[id].price+((listedItems[id].price/100)*rewardPercent)));          
    listedItems[id].sold=true;        

    } else {
    IBEP20 token = IBEP20(listedItems[id].tokenAddress);
    token.transfer(listedItems[id].seller,listedItems[id].price);  
    listedItems[id].sold=true;        

    }
    successfulSales[listedItems[id].seller]+=1;

  }



  function removeItem(bytes32 id) public {
  	require(msg.sender==listedItems[id].seller);
  	require(listedItems[id].escrowInitiated==false);
  	require(listedItems[id].sold==false);
  	delete listedItems[id];
  }


}