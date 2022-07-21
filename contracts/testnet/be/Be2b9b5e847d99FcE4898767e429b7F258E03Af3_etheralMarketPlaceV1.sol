/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

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
        uint256 price;
        address tokenAddress;
        address seller;
        uint256 subItemID;
        uint256 currentSubItem;
        uint256 activeOrders;
    }

    struct order{
        bytes32 itemid;
        bool shipped;
        bool escrowInitiated;
        uint256 shippedTimestamp;
        address escrowInitiator;
        bool allowedReward;
        bool disputed;
        bool escrowReleased;
    }

    mapping(bytes32=>order) orders;

  event newItem(bytes32 id);
  event newOrder(bytes32 orderid);

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

    function getTotalVotes(bytes32 orderid) public view returns(uint256){
        return sellerVotes[orderid]+buyerVotes[orderid];
    }

    function voteForSeller(bytes32 orderid) public {
        bytes32 voteid=keccak256(abi.encodePacked(msg.sender,orderid));
        require(votedFor[voteid]==false,"Already voted.");
        require(block.timestamp<voteEnds[orderid],"Dispute ended. Winning party can execute verdict.");
        require(orders[orderid].disputed==true,"Not disputed");
        sellerVotes[orderid]+=1;
        votedFor[voteid]=true;
        hasVotePrivilege[msg.sender]=true;
    }

    function voteForBuyer(bytes32 orderid) public {
        bytes32 voteid=keccak256(abi.encodePacked(msg.sender,orderid));
        require(votedFor[voteid]==false,"Already voted.");
        require(block.timestamp<voteEnds[orderid],"Dispute ended. Winning party can execute verdict.");
        require(orders[orderid].disputed==true,"Not disputed");
        buyerVotes[orderid]+=1;
        votedFor[voteid]=true;
        hasVotePrivilege[msg.sender]=true;

    }

    function executeVerdict(bytes32 orderid) public {
        require(block.timestamp>voteEnds[orderid],"Dispute not finished.");
        require(orders[orderid].disputed==true,"Not disputed");
        require(orders[orderid].escrowReleased==false,"Escrow already released");
        if(sellerVotes[orderid]>buyerVotes[orderid]){
            //seller wins dispute
            if(orders[orderid].allowedReward==true){
            IBEP20 token = IBEP20(listedItems[orders[orderid].itemid].tokenAddress);
            token.transfer(listedItems[orders[orderid].itemid].seller,(listedItems[orders[orderid].itemid].price+((listedItems[orders[orderid].itemid].price/100)*rewardPercent)));          
            orders[orderid].escrowReleased=true;

            } else {
            IBEP20 token = IBEP20(listedItems[orders[orderid].itemid].tokenAddress);
            token.transfer(listedItems[orders[orderid].itemid].seller,listedItems[orders[orderid].itemid].price);  
            orders[orderid].escrowReleased=true;

            }   

            successfulSales[listedItems[orders[orderid].itemid].seller]+=1;
            listedItems[orders[orderid].itemid].activeOrders-=1;
            delete orders[orderid];

        }

        if(buyerVotes[orderid]>sellerVotes[orderid]){
            //buyer wins dispute
            IBEP20 token = IBEP20(listedItems[orders[orderid].itemid].tokenAddress);
            token.transfer(orders[orderid].escrowInitiator,listedItems[orders[orderid].itemid].price); 
            lostDisputes[listedItems[orders[orderid].itemid].seller]+=1;
            listedItems[orders[orderid].itemid].currentSubItem-=1;
            listedItems[orders[orderid].itemid].activeOrders-=1;
            delete orders[orderid];


        }

        if(buyerVotes[orderid]==sellerVotes[orderid]){
            //stalemate
            IBEP20 token = IBEP20(listedItems[orders[orderid].itemid].tokenAddress);
            token.transfer(orders[orderid].escrowInitiator,listedItems[orders[orderid].itemid].price); 
            listedItems[orders[orderid].itemid].currentSubItem-=1;
            listedItems[orders[orderid].itemid].activeOrders-=1;
            delete orders[orderid];

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
  function addItem (uint256 price,address selectedToken,uint256 stock)  public {
    require(authorizedToken[selectedToken]==true,"Token not authorized");
    require(banned[msg.sender]==false,"You are banned"); 
    require(stock>0,"Stock cannot be 0");   
    eTokenInstance.transferFrom(msg.sender,address(this),(price/100)*listingFee);
    votersPool+=(price/100)*listingFee;
    lastAddedToPool=block.timestamp;


    bytes32 genid=keccak256(abi.encodePacked(msg.sender,itemNumber));
    listedItems[genid].itemid=genid;
    listedItems[genid].price=price;
    listedItems[genid].tokenAddress=selectedToken;
    listedItems[genid].seller=msg.sender;
    listedItems[genid].subItemID=stock;
    listedItems[genid].currentSubItem=0;
    listedItems[genid].activeOrders=0;

    itemNumber+=1;    
    emit newItem(genid);
  }

  function retrieveItemPrice(bytes32 id) public view returns(uint256){
    return listedItems[id].price;
  }
  function retrieveItemCurrency(bytes32 id) public view returns(address){
    return listedItems[id].tokenAddress;
  }

  function retrieveOrderEscrowStatus(bytes32 orderid) public view returns(bool){
    return orders[orderid].escrowInitiated;
  }    
  function retrieveItemEscrowInitiator(bytes32 orderid) public view returns(address){
    return orders[orderid].escrowInitiator;
  }        
  function retrieveItemSeller(bytes32 id) public view returns(address){
    return listedItems[id].seller;
  }   

  function retrieveStockLeft(bytes32 id) public view returns(uint256){
   return(listedItems[id].subItemID-listedItems[id].currentSubItem);
  }

  function isShipped(bytes32 orderid) public view returns(bool){
    return orders[orderid].shipped;
  }

  function getShippedTimestamp(bytes32 orderid) public view returns(uint256){
    return orders[orderid].shippedTimestamp;
  }

  function getOrderedItemID(bytes32 orderid) public view returns(bytes32){
    return orders[orderid].itemid;
  }

  function isDisputed(bytes32 orderid) public view returns(bool){
    return orders[orderid].disputed;
  }

  function getSellerScore(address seller) public view returns(uint256){
    return successfulSales[seller];
  }

  function getSellerDisputes(address seller) public view returns(uint256){
    return lostDisputes[seller];
  }

  function getDaysPassedSinceShipped(bytes32 orderid) public view returns(uint256){
    uint256 daysPassed=(block.timestamp-orders[orderid].shippedTimestamp)/86400;
    return daysPassed;    
  }


  function depositEscrow(bytes32 id) public {
    require(listedItems[id].currentSubItem<=listedItems[id].subItemID,"Out of stock");
    require(banned[msg.sender]==false,"You are banned");    
    IBEP20 token = IBEP20(listedItems[id].tokenAddress);
    token.transferFrom(msg.sender,address(this),listedItems[id].price);


    //Generating order id 
    bytes32 thisOrderId=keccak256(abi.encodePacked(msg.sender,id,listedItems[id].currentSubItem));
    emit newOrder(thisOrderId);
    if(listedItems[id].tokenAddress==etheralToken){
        orders[thisOrderId].allowedReward=true;
    } else {
        orders[thisOrderId].allowedReward=false;

    }
    orders[thisOrderId].escrowInitiated=true;
    orders[thisOrderId].escrowInitiator=msg.sender;
    orders[thisOrderId].itemid=id;
    orders[thisOrderId].shipped=false;
    orders[thisOrderId].disputed=false;
    orders[thisOrderId].escrowReleased=false;

    listedItems[id].currentSubItem+=1;
    listedItems[id].activeOrders+=1;
  }

  function isFundsDeposited(bytes32 orderid) public view returns(bool){
    return orders[orderid].escrowInitiated;
  }

  function markShipped(bytes32 orderid) public {
    require(msg.sender==listedItems[orders[orderid].itemid].seller,"Not seller");
    orders[orderid].shipped=true;
    orders[orderid].shippedTimestamp=block.timestamp;
  }




  function openDispute(bytes32 orderid) public{
    require(orders[orderid].escrowInitiated==true);
    require(msg.sender==orders[orderid].escrowInitiator);
    orders[orderid].disputed=true;
    voteEnds[orderid]=block.timestamp+(86400*7);
  }

  function claimEscrow(bytes32 orderid) public {
    require(msg.sender==listedItems[orders[orderid].itemid].seller,"Not seller");
    require(orders[orderid].shipped==true,"Item not shipped");
    require(orders[orderid].escrowReleased==false,"Escrow already released");
    require(orders[orderid].disputed==false,"You have an ongoing dispute for this order");
    require(orders[orderid].escrowInitiated==true,"No escrow deposited");
    uint256 daysPassed=(block.timestamp-orders[orderid].shippedTimestamp)/86400;
    require(daysPassed>14);

    if(orders[orderid].allowedReward==true){
    IBEP20 token = IBEP20(listedItems[orders[orderid].itemid].tokenAddress);
    token.transfer(listedItems[orders[orderid].itemid].seller,(listedItems[orders[orderid].itemid].price+((listedItems[orders[orderid].itemid].price/100)*rewardPercent)));          

    } else {
    IBEP20 token = IBEP20(listedItems[orders[orderid].itemid].tokenAddress);
    token.transfer(listedItems[orders[orderid].itemid].seller,listedItems[orders[orderid].itemid].price);  

    }
    successfulSales[listedItems[orders[orderid].itemid].seller]+=1;
    listedItems[orders[orderid].itemid].activeOrders-=1;
    orders[orderid].escrowReleased=true;
    delete orders[orderid];

  }

  function releaseEscrow(bytes32 orderid) public {
    require(orders[orderid].escrowInitiated==true);  
    require(orders[orderid].escrowReleased==false,"Escrow already released");

    require(orders[orderid].disputed==false);  
    require(msg.sender==orders[orderid].escrowInitiator);
    if(orders[orderid].allowedReward==true){
    IBEP20 token = IBEP20(listedItems[orders[orderid].itemid].tokenAddress);
    token.transfer(listedItems[orders[orderid].itemid].seller,(listedItems[orders[orderid].itemid].price+((listedItems[orders[orderid].itemid].price/100)*rewardPercent)));          

    } else {
    IBEP20 token = IBEP20(listedItems[orders[orderid].itemid].tokenAddress);
    token.transfer(listedItems[orders[orderid].itemid].seller,listedItems[orders[orderid].itemid].price);  

    }
    successfulSales[listedItems[orders[orderid].itemid].seller]+=1;
    listedItems[orders[orderid].itemid].activeOrders-=1;
    orders[orderid].escrowReleased=true;
    delete orders[orderid];

  }



}