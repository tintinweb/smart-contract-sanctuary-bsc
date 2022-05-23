/**
 *Submitted for verification at BscScan.com on 2022-05-22
*/

// SPDX-License-Identifier: MIT
/** 
 *  SourceUnit: /media/encryption/Encrypt/Projects/RigelProtocol/RigelDecentralizedP2PSystem/contracts/RigelDecentralizedP2PSystem.sol
*/

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)


library Context {

    struct context {
        mapping(address => bool) isAdminAddress;
        address _owner;
    }

    function diamondContext() internal pure returns(context storage ds) {
        bytes32 storagePosition = keccak256("Rigel Decentralized P2P Context.");
        assembly {ds.slot := storagePosition}
    }
}


pragma solidity 0.8.13;

interface IStakeRIgel {

    function getMyRank(address account) external view returns(bytes memory  Rank, bytes  memory voteRank);

    function getLockPeriodData() external view returns(uint256, uint256);

    function getSetsBadgeForMerchants(bytes memory _badge) external view returns(
        bytes  memory   rank,
        bytes  memory   otherRank,
        address[] memory tokenAddresses,
        uint256[] memory requireURI,
        uint256 sellerFee,
        uint256 buyerFee,
        uint256 numbersOfCouncilMembers,
        uint256 beforeVote,
        uint256 votesPeriod,
        uint256 wrongVotesFees
    );
}

interface events {
   /**
     * @dev Emitted when the Buyer makes a call to Lock Merchant Funds, is set by
     * a call to {makeBuyPurchase}. `value` is the new allowance.
     */
    event Buy(address indexed merchant, address indexed buyer, address token, uint256 amount, uint256 ID, uint256 time);

    /**
     * @dev Emitted when the Merchant Comfirmed that they have recieved their Funds, is set by
     * a call to {makeSellPurchase}. `value` is the new allowance.
     */
    event Sell(address indexed buyer, address indexed merchant, address token, uint256 amount, uint256 ID, uint256 time);

    /**
     * @dev Emitted when Dispute is raise.
     */
    event dispute(address indexed who, address indexed against, address token, uint256 amount, uint256 ID, uint256 time);  

    /**
     * @dev Emitted when a vote has been raise.
     */
    event councilVote(address indexed councilMember, address indexed who, bytes rank, uint256 productID, uint256 indexedOfID, uint256 time);  

    event EarnBadge(bytes badge, address indexed user, uint256 amount, uint256 time);
    
    event EarnNFTBadge(bytes badge, address indexed user, uint256 amount, uint256 time);
}

struct BuyProduct {
    address buyer; 
    address seller; 
    address token;
    uint256 amount; 
    uint256 time;
}

/** @dev Struct that stores buyers data 
    * @param buyer the buyer 
    * @param seller the seller 
    * @param token purchase token
    * @param status status of transaction
    * @param amount amount of token purchase 
    * @param id id specified to the product 
    * @param time purchase time  
    */
struct SellProduct {
    address buyer; 
    address seller; 
    address token; 
    uint256 amount;
    uint256 id;
    uint256 time; 
}

/** @dev Struct that stores the list of all products
    * @param buyer the buyer 
    * @param seller the seller 
    * @param token purchase token
    * @param amount amount of token purchase 
    * @param id id specified to the product 
    * @param startSales when sale start
    * @param endSales when sale end
    * @param isCompleted status of transaction
    */
struct AllProducts{
    address buyer;
    address seller;
    address token;
    uint256 amount;
    uint256 id;
    uint256 startSales;
    uint256 endSales;
    bool    isCompleted;
    bool 	isOnDispute;
}

/** @dev Struct For Dispute Ranks Requirements
    * @param NFTaddresses Addresses of the NFT token contract 
    * @param mustHaveNFTID IDs of the NFTs token 
    * @param pairTokenID pid on masterChef Contract that disputer must staked must have
    * @param pairTokenAmountToStake The Minimum amount of s `pair` to stake
    * @param merchantFeeToRaiseDispute The fee for a merchant to raise a dispute
    * @param buyerFeeToRaiseDisputeNoDecimal The fee for a buyer to raise a dispute without decimal
    */	
struct DisputeRaised {
    address who;
    address against;
    address token;
    bytes 	badge;
    uint256 amount;
    uint256 payment;
    uint256 time;
    uint256 votesCommence;
    uint256 votesEnded;
    bool 	isResolved;
}

/** @dev Struct For Counsil Members
    * @param forBuyer How many Tips the buyer has accumulated 
    * @param forSeller How many Tips the seller has accumulated 
    * @param tippers arrays of tippers
    * @param whoITip arrays of whom Tippers tips
    */	
struct MembersTips {
    uint256 forBuyer;
    uint256 forSeller;
    address qualified;
    address[] joinedCouncilMembers;
    address[] tippers;
    address[] whoITip;
}

struct Store {
    bool    isResolving;
    bool isLocked;
    uint256 joined;
    uint256 totalVotes;
    uint256 wrongVote;
    uint256 tFee4WrongVotes;
}

/**
 * @dev silently declare mapping for the products on Rigel's Protocol Decentralized P2P network
 */
library rigelMapped {
    struct libStorage {
        mapping(address => BuyProduct[])  buyProduct;
        mapping(address => SellProduct[])  sellProduct;
        mapping(uint256 => AllProducts)  allProducts;  
        mapping(uint256 => MembersTips)  tips;
        mapping(uint256 => DisputeRaised[])  raisedDispute;
        mapping(address => uint256)  balance;
        mapping(address => Store)  store;
        mapping(address => bool) refWhitelist;
        address[]  member;
        address RGP;
        address RGPStake;
        address  devAddress;
        uint256 refWithoutWhitelistPercent;
        uint256 refWithWhitelistPercent;
        uint256  seller;
        uint256  buyersFee;
        uint256  transactionID;
    }

    function diamondStorage() internal pure returns(libStorage storage ds) {
        bytes32 storagePosition = keccak256("Rigel Decentralized P2P System.");
        assembly {ds.slot := storagePosition}
    }

    function _isOnDispute(
        address who, 
        address against, 
        address token, 
        bytes   memory badge,
        uint256 productID,  
        uint256 amount, 
        uint256 fee,
        uint256 _join,
        uint256 _bfVote
    ) internal {
        libStorage storage ds = diamondStorage();
        DisputeRaised memory rDispute = DisputeRaised(
            who, against, token, badge, amount, fee , block.timestamp, block.timestamp - _join, block.timestamp + _bfVote, false
        );
        ds.raisedDispute[productID].push(rDispute);
    }
}

abstract contract Ownable {

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {        
        Context.context storage ds = Context.diamondContext();
        ds.isAdminAddress[_msgSender()] = true;
        ds._owner = _msgSender();
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        Context.context storage ds = Context.diamondContext();
        return ds._owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlyAdmin() {
        Context.context storage ds = Context.diamondContext();
        require(ds.isAdminAddress[_msgSender()], "Access Denied: Need Admin Accessibility");
        _;
    }
}

interface IERC20 {
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract RigelDecentralizedP2PSystem is Ownable, events{
    // "Rigel's Protocol: Balance of 'from' is less than amount to sell"
    error Insufficient_Balalnce();
    // "Rigel's Protocol: Unable to withdraw from 'from' address"
    error Withdrawal_denied();
    // "Rigel's Protocol: Token Specify is not valid with ID"
    error Invalid_Token();
    // "Rigel's Protocol: Transaction has been completed "
    error Transaction_completed();
    // "Rigel's Protocol: This Product is on dispute"
    error Product_On_Dispute();
    // "Rigel's Protocol: Amount Secify for gas is less than min fee"
    error Low_Gas();
    // "Rigel's Protocol: A party to a dispute cant join Voting session"
    error not_Permitted();
    // "Rigel's Protocol: Patience is a Virtue"
    error Be_Patient();
    // "Rigel's Protocol: Permission Denied, address not qualified for this `rank`"
    error Permission_Denied();
    // "Rigel's Protocol: Dispute already raised for this Product"
    error Dispute_Raised();
    // "Rigel's Protocol: You have No Right to vote "
    error Voting_Denied();
    // "Rigel's Protocol: Invalid Product ID"
    error Invalid_ProductID();
    // "Rigel's Protocol: You don't have permission to raise a dispute for `who` "
    error cannot_Raise_Dispute();
    // "Rigel's Protocol: msg.sender has already voted for this `product ID` "
    error Already_voted();
    // "Rigel's Protocol: `who` is not a participant"
    error Not_a_Participant();
    // "Rigel's Protocol: Dispute on this product doesn't Exist"
    error No_Dispute();
    // "Rigel's Protocol: Max amount of require Tip Met."
    error Tip_Met_Max_Amt();
    // "Rigel's Protocol: Time Expire"
    error Time_Expired();
    // "Rigel's Protocol: Minimum Council Members require for this vote not met"
    error More_Members_Needed();
    // "Rigel's Protocol: Unable to withdraw gasFee from 'from' address"
    error Unable_To_Withdraw();
    // "Balance of contract is less than inPut amount"
    error Low_Contract_Balance();
    // funds are currently locked
    error currentlyLocked();


    /** @dev Constructor. Links with RigelDecentralizedP2PSystem contract
	 * @param _buyersFee this fee should not be included with decimals;
     * @param _merchantProcessingFee should be included with decimals as this is the fee paid in RGP token;
     * @param rgpToken address of RGP token Contract;
	 */
    constructor(
        uint256 _buyersFee, 
        uint256 _merchantProcessingFee,
        uint256 whitelist, 
        uint256 nonWhitelist,
        address rgpToken
    ) { 
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        ds.RGP = rgpToken;
        ds.seller = _merchantProcessingFee;
        ds.refWithoutWhitelistPercent = nonWhitelist;
        ds.refWithWhitelistPercent = whitelist;
        ds.buyersFee = _buyersFee;
        ds.devAddress = _msgSender();
    }

    function setStakeAddr(address rgpStake) external onlyOwner {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        ds.RGPStake = rgpStake;
    }

    function setRefFeesPercent(uint256 whitelist, uint256 nonWhitelist) external onlyOwner {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        ds.refWithoutWhitelistPercent = nonWhitelist;
        ds.refWithWhitelistPercent = whitelist;
    }

    function setWhiteList(address[] memory accounts, bool status) external onlyOwner {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        uint256 len = accounts.length;
        if (status == true) {
           for(uint256 i = 0; i < len; i++) {
            ds.refWhitelist[accounts[i]] = status;
            } 
        } else{
            for(uint256 i = 0; i < len; i++) {
                delete(ds.refWhitelist[accounts[i]]);
            }
        }
    }

    /** @dev makeBuyPurchase access to a user
     * @param purchaseToken address of token contract address to check for approval
     * @param amount amount of the token to purchase by 'to' from 'from'
     * @param from address of the seller
     * @param to address of the buyer
     */ 
    function makeSellOrder(IERC20 purchaseToken, uint256 amount, address from, address to, address referral) external {   
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();     
        uint256 tokenBalance = purchaseToken.balanceOf(from);      
        uint256 id = ds.transactionID++;
        uint256 tDecimals = _tDecimals(purchaseToken, amount);
        // require(tokenBalance >= tDecimals, "Rigel's Protocol: Balance of 'from' is less than amount to sell" );
        if (tokenBalance < tDecimals)  revert Insufficient_Balalnce();
        _merchantChargesDibited(from, ds.seller);
        // require(purchaseToken.transferFrom(from, address(this), tDecimals), "Rigel's Protocol: Unable to withdraw from 'from' address");
        if (!purchaseToken.transferFrom(from, address(this), tDecimals))
        if (referral != address(0)) {
            if(!ds.refWhitelist[referral]) {
                uint256 refShare = (ds.seller * ds.refWithoutWhitelistPercent) / 100E18;
                IERC20(ds.RGP).transfer(referral, refShare);
            } else {
                uint256 refWShare = (ds.seller * ds.refWithWhitelistPercent) / 100E18;
                IERC20(ds.RGP).transfer(referral, refWShare);
            }
        }
        SellProduct memory _prod = SellProduct(to, from, address(purchaseToken), tDecimals, id, block.timestamp);
        ds.sellProduct[from].push(_prod);
        ds.allProducts[id] =  AllProducts(to, from, address(purchaseToken), tDecimals, id, block.timestamp, 0, false, false);
        emit Buy(from, to, address(purchaseToken), amount, id, block.timestamp);
    }

    // /** @dev grant access to a user for the sell of token specified.
    //  * @param purchaseToken address of token contract address to check for approval
    //  * @param from address of the seller
    //  * @param productID the product id
    //  * @param fee provide gas fee must be less than minimum gas specified by owner
    //  */ 
    function makeBuyPurchase(IERC20 purchaseToken, address from, uint256 productID, uint256 fee) external onlyAdmin{
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage(); 
        SellProduct storage sales = ds.sellProduct[from][productID];
        AllProducts storage all = ds.allProducts[productID];
        // require(address(purchaseToken) == sales.token, "Rigel's Protocol: Token Specify is not valid with ID");
        if (address(purchaseToken) != sales.token)  revert Invalid_Token();
        // require(!all.isCompleted, "Rigel's Protocol: Transaction has been completed ");
        if (all.isCompleted) revert Transaction_completed();
        // require(!all.isOnDispute, "Rigel's Protocol: This Product is on dispute");
        if (all.isOnDispute)  revert Product_On_Dispute(); 
        // require(fee >= ds.buyersFee, "Rigel's Protocol: Amount Secify for gas is less than min fee");
        if (fee < ds.buyersFee)  revert Low_Gas(); 
        uint256 bFee = _tDecimals(purchaseToken, fee);
        uint256 subGas = (sales.amount) - bFee;
        all.isCompleted = true;
        all.endSales = block.timestamp;
        BuyProduct memory _prod = BuyProduct(sales.buyer, from, sales.token, sales.amount, block.timestamp);
        ds.buyProduct[sales.buyer].push(_prod);
        IERC20(sales.token).transfer( sales.buyer, subGas);
        emit Buy(sales.buyer, from, sales.token, subGas, productID, block.timestamp);
    }

    function raiseDispute(bytes memory resolveBadge, uint256 productID, address who) external {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();  
        AllProducts storage all = ds.allProducts[productID];
        (
            uint256 sellFee, 
            uint256 buyFee, 
            , 
            uint256 bVote, 
            uint256 vPeriod,
        )  = getStakeInfor(resolveBadge, all.token, all.amount);
        bool _who = isForBuyerOrSeller(productID, who);
        if (_who) {
            all.amount = (all.amount - buyFee);
            rigelMapped._isOnDispute(
                who, 
                all.seller, 
                all.token, 
                resolveBadge,
                productID, 
                all.amount, 
                buyFee, 
                bVote, 
                vPeriod
            );
            emit dispute(who, all.seller, all.token, all.amount, productID, block.timestamp);
        } else {
            _merchantChargesDibited(who, sellFee);   
            rigelMapped._isOnDispute( 
                who, 
                all.buyer, 
                all.token, 
                resolveBadge,
                productID, 
                all.amount, 
                sellFee,
                bVote, 
                vPeriod
            );
            emit dispute(who, all.buyer, all.token, all.amount, productID, block.timestamp);
        }
    }

    function joinDispute(uint256 productID, uint256 indexedOf) external {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage(); 
        DisputeRaised memory disputeRaise = ds.raisedDispute[productID][indexedOf];
        // require(_msgSender() != disputeRaise.who || _msgSender() != disputeRaise.against,
        //     "Rigel's Protocol: A party to a dispute cant join Voting session"    
        // );
        if (_msgSender() == disputeRaise.who || _msgSender() == disputeRaise.against)  revert not_Permitted(); 
           
        Store storage myBadge = ds.store[_msgSender()];
        (
            bytes memory  Rank,
            bytes  memory voteRank
        ) = IStakeRIgel(ds.RGPStake).getMyRank(_msgSender());
        // require(!myBadge.isLocked, "Rigel's Protocol: Lock Status activated.");
        if(myBadge.isLocked) revert currentlyLocked();
        // require(block.timestamp > disputeRaise.votesCommence, "Rigel's Protocol: Patience is a Virtue");
        if (block.timestamp < disputeRaise.votesCommence)  revert Be_Patient(); 
        require(keccak256(abi.encodePacked(Rank)) == keccak256(abi.encodePacked(disputeRaise.badge)) || 
            keccak256(abi.encodePacked(voteRank)) == keccak256(abi.encodePacked(disputeRaise.badge)),
            "Rigel's Protocol: Permission Denied, address not qualified for this `rank`"
        );
        // if (keccak256(abi.encodePacked(Rank)) != keccak256(abi.encodePacked(disputeRaise.badge)) || 
        //     keccak256(abi.encodePacked(voteRank)) != keccak256(abi.encodePacked(disputeRaise.badge)))  revert Permission_Denied();              
         
        MembersTips storage tipMe = ds.tips[productID];
        myBadge.isResolving = true;
        myBadge.joined ++;
        tipMe.joinedCouncilMembers.push(_msgSender());
    }

    function cancelDebt(uint256 amount) external {        
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage(); 
        Store storage myBadge = ds.store[_msgSender()];
        _merchantChargesDibited(_msgSender(), amount);
        myBadge.tFee4WrongVotes = myBadge.tFee4WrongVotes - amount;
        if (myBadge.tFee4WrongVotes == 0) {
            myBadge.isLocked = false;
        }
    }

    function isForBuyerOrSeller(uint256 productID, address who) internal  returns(bool forBuyer){
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage(); 
        Context.context storage dc = Context.diamondContext();
        AllProducts storage all = ds.allProducts[productID];
        // require(!all.isOnDispute, "Rigel's Protocol: Dispute already raised for this Product");
        if (all.isOnDispute)  revert Dispute_Raised(); 
        // require(!all.isCompleted, "Rigel's Protocol: Transaction has been completed ");  
        if (all.isCompleted)  revert Transaction_completed(); 
        // require(productID <= getTransactionID(), "Rigel's Protocol: Invalid Product ID");
        if (productID > getTransactionID())  revert Invalid_ProductID(); 
        require(_msgSender() == all.seller || _msgSender() == all.buyer || dc.isAdminAddress[_msgSender()] == true,
         "Rigel's Protocol: You don't have permission to raise a dispute for `who` "
        );  
        // if (_msgSender() != all.seller || _msgSender() != all.buyer || dc.isAdminAddress[_msgSender()] != true)  revert cannot_Raise_Dispute();
              
        if (all.seller == who) {
            forBuyer = false;
        } else if(all.buyer == who) {                
            forBuyer = true;
        }
        all.isOnDispute = true;
    }

    function castVote(uint256 productID, uint256 indexedOf, address who) external {       
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();  
        MembersTips memory tipMe = ds.tips[productID];
        
        uint256 len = tipMe.joinedCouncilMembers.length;
        bool haveRight;
        for (uint256 i; i < len; i++) {
            address voters = tipMe.joinedCouncilMembers[i];
            if (voters == _msgSender()) {
                haveRight = true;
                break;
            } else {haveRight = false;}
        }     
         
        // require(haveRight, "Rigel's Protocol: You have No Right to vote ");
        if (!haveRight)  revert Voting_Denied(); 
        // require(!(iVoted(productID, _msgSender())), "Rigel's Protocol: msg.sende has already voted for this `product ID` ");
        if ((iVoted(productID, _msgSender()))) revert Already_voted();
        
        _tip(productID, indexedOf, who);
    }

    /**
     * @dev Returns a boolean value indicating whether `account` has cast a vote in  `productID` 
     */
    function iVoted(uint256 productID, address account) public view returns(bool isTrue) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage(); 
        MembersTips memory tipMe = ds.tips[productID];
        uint256 lent = tipMe.tippers.length;
        for (uint256 i; i < lent; i++) {
            address chk = tipMe.tippers[i];
            if (account == chk) {
                isTrue = true;
                break;
            } else {
                isTrue = false;
            }
        }
    }

    function multipleAdmin(address[] calldata _adminAddress, bool status) external onlyOwner {
        Context.context storage dc = Context.diamondContext();
        if (status == true) {
           for(uint256 i = 0; i < _adminAddress.length; i++) {
            dc.isAdminAddress[_adminAddress[i]] = status;
            } 
        } else{
            for(uint256 i = 0; i < _adminAddress.length; i++) {
                delete(dc.isAdminAddress[_adminAddress[i]]);
            }
        }
    }

    function _tip(uint256 productID, uint256 indexedOf, address who) internal {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage(); 
        MembersTips storage tipMe = ds.tips[productID];
        Store storage myBadge = ds.store[_msgSender()];
        AllProducts memory all = ds.allProducts[productID];
        DisputeRaised memory rDispute = ds.raisedDispute[productID][indexedOf];        
        (, ,  uint256 numbersOfCouncilMembers, , , uint256 lFee)  = 
            getStakeInfor(rDispute.badge, all.token, _tDecimals(IERC20(all.token), all.amount)
        );
        require(who == rDispute.who || who == rDispute.against, "Rigel's Protocol: `who` is not a participant");
        // if (who != rDispute.who || who != rDispute.against)  revert Not_a_Participant(); 
        // require(all.isOnDispute, "Rigel's Protocol: Dispute on this product doesn't Exist");          
        if (!all.isOnDispute)  revert No_Dispute(); 
        // require(tipMe.qualified == address(0), "Rigel's Protocol: Max amount of require Tip Met.");
        if (tipMe.qualified != address(0))  revert Tip_Met_Max_Amt(); 
        // require(block.timestamp > rDispute.votesCommence, "Rigel's Protocol: Patience is a Virtue");
        if (block.timestamp < rDispute.votesCommence)  revert Be_Patient(); 
        // require(block.timestamp < rDispute.votesEnded, "Rigel's Protocol: Time Expire");
        if (block.timestamp > rDispute.votesEnded)  revert Time_Expired();
        if (block.timestamp > rDispute.votesCommence) {
            // require(tipMe.joinedCouncilMembers.length >= numbersOfCouncilMembers, 
            //     "Rigel's Protocol: Minimum Council Members require for this vote not met"
            // );
            if (tipMe.joinedCouncilMembers.length < numbersOfCouncilMembers)  revert More_Members_Needed(); 
             
        }
        if (who == all.buyer) {
            tipMe.tippers.push(_msgSender());
            tipMe.whoITip.push(who);
            tipMe.forBuyer++;
        }
        if (who == all.seller) {
            tipMe.tippers.push(_msgSender());
            tipMe.whoITip.push(who);
            tipMe.forSeller++;
        }
        uint256 div2 = tipMe.joinedCouncilMembers.length / 2;
        if (tipMe.forBuyer >= (div2 + 1)) {
            tipMe.qualified = who;
        } 
        if(tipMe.forSeller >= (div2 + 1)) {
            tipMe.qualified = who;
        }
        // Store storage myBadge = ds.store[_msgSender()];
        myBadge.joined--;
        if (myBadge.joined == 0) {
            myBadge.isResolving = false;
        }
        myBadge.totalVotes ++;
        chkLockStatus();
        if(tipMe.qualified != address(0)) {        
            uint256 devReward;
            uint256 sharableRewards;
            uint256 _huPercent = _tDecimals(IERC20(all.token), 100);
            if(tipMe.qualified == all.buyer) { 
                devReward = (rDispute.payment * _tDecimals(IERC20(all.token), 20)) / _huPercent;
                sharableRewards = (rDispute.payment * _tDecimals(IERC20(all.token), 80)) / _huPercent;
            } else {
                devReward = (rDispute.payment * 20E18) / 100E18;
                sharableRewards = (rDispute.payment * 80E18) / 100E18;
            }
            ds.balance[ds.devAddress] = ds.balance[ds.devAddress] + devReward;  
            _l(productID, sharableRewards, lFee, tipMe.qualified);
        }
        emit councilVote(_msgSender(), who, rDispute.badge , productID, indexedOf, block.timestamp);
    }

    function _l(uint256 productID, uint256 amountShared, uint256 fee, address who) internal {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage(); 
        
        
        (address[] memory qua, address[] memory lst) = _cShare(productID, who);
        for (uint256 i; i < qua.length; i++) {
            address cons = qua[i];
            if (cons != address(0)) {       
                ds.member.push(cons); 
            }
        }
        uint256 meme = ds.member.length;
        for (uint256 j = 0; j < meme; j++) {
            uint256 forEach = amountShared / meme;
            address consM = ds.member[j];
            ds.balance[consM] = ds.balance[consM] + forEach;
        }
        delete ds.member;

        for (uint256 x = 0; x < lst.length; x++) {
            address ls = lst[x];
            if (ls != address(0)) {
                Store storage myBadge = ds.store[ls];
                myBadge.tFee4WrongVotes = myBadge.tFee4WrongVotes + fee;
                myBadge.wrongVote ++;
            }
        }

    }

    function chkLockStatus() internal {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage(); 
        Store storage myBadge = ds.store[_msgSender()];
        (uint256 tLockCheck, uint256 pLockCheck) = lockPeriod();
        if (myBadge.totalVotes >= tLockCheck) {
            if (myBadge.wrongVote >= pLockCheck) {
                myBadge.isLocked = true;
                myBadge.totalVotes = 0;
                myBadge.wrongVote = 0;
            }else {
                myBadge.totalVotes = 0;
                myBadge.wrongVote = 0;
            }
        }
    }

    function _cShare(uint256 productID, address who) internal view returns(address[] memory, address[] memory) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage(); 
        MembersTips memory tipMe = ds.tips[productID];
        uint256 lenWho = tipMe.whoITip.length;      
        address[] memory won = new address[](lenWho);
        address[] memory lost = new address[](lenWho);
        if (who != address(0)) {
            for (uint256 i; i < lenWho; i++ ) {
                address l = tipMe.whoITip[i];
                address c = tipMe.tippers[i];
                if (l == who) {
                    won[i] = c;
                }
                 else if(l != who) {
                    lost[i] = c;
                }
            }
        }
        return (won, lost);        
    }

    function getStakeInfor(bytes memory resolveBadge, address token, uint256 amt) public view returns(
        uint256 sellerFee,
        uint256 buyerFee,
        uint256 numbersOfCouncilMembers,
        uint256 beforeVote,
        uint256 votesPeriod,
        uint256 lockFee
    ) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        (
            ,
            ,
            ,
            ,
            sellerFee,
            buyerFee,
            numbersOfCouncilMembers,
            beforeVote,
            votesPeriod,
            lockFee
        ) = IStakeRIgel(ds.RGPStake).getSetsBadgeForMerchants(resolveBadge);
        uint256 tDecimals = _tDecimals(IERC20(token), sellerFee);
        uint256 bDecimals = _tDecimals(IERC20(token), buyerFee);
        uint256 tDecimal = _tDecimals(IERC20(token), 100);
        uint256 sFee = (amt * tDecimals) / tDecimal;
        uint256 bFee = (amt * bDecimals) / tDecimal;
        return(sFee, bFee, numbersOfCouncilMembers, beforeVote, votesPeriod,lockFee);
    }

    function lockPeriod() internal view returns(uint256 tLockCheck, uint256 pLockCheck) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        (tLockCheck, pLockCheck) = IStakeRIgel(ds.RGPStake).getLockPeriodData();
    }

    function disputesPersonnel(address account ) external view returns(Store memory userInfo) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        userInfo = ds.store[account];
    }

    function getTotalUserLock(address account ) external view returns(bool, bool) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        Store memory userInfo = ds.store[account];
        return(userInfo.isResolving, userInfo.isLocked);
    }

    /**
     * @dev Returns the data for an ID on sales if exist
     */
    function getBuyersInfor(address buyer, uint256 productID) external view returns(BuyProduct memory buy) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        buy = ds.buyProduct[buyer][productID];
    }

    /**
     * @dev Returns the data for an ID on sales if exist
     */
    function getSellersInfor(address _seller, uint256 productID) external view returns(SellProduct memory sell) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        sell = ds.sellProduct[_seller][productID];
    }
    
    /**
     * @dev Returns the data for an ID on sales if exist
     */
    function productDetails(uint256 productID) external view returns (AllProducts memory all) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        all = ds.allProducts[productID];
    }
    
    /**
     * @dev Returns information about disputes raised for a `rank`
     */
    function getDisputeRaised(uint256 productID, uint256 indexedID) external view returns(DisputeRaised memory disputeRaise) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        disputeRaise = ds.raisedDispute[productID][indexedID];
    }

    /**
     * @dev Returns `uint256` the amount of RGP Merchant will pay through {makeBuyPurchase}.
     */
    function getFees() external view returns (uint256 _seller, uint256 _buyerFees) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        _seller =  ds.seller;
        _buyerFees = ds.buyersFee;
    }

    /**
     * @dev Returns `uint256` accummulated balance of CouncilMember;
     */
    function getMemberBalance(address account) external view returns(uint256) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        return(ds.balance[account]);
    }
    
    /**
     * @dev Returns the details on how council Members are voting
     */
    function getWhoIsleading(uint256 productID) external view returns(MembersTips memory tip) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        tip = ds.tips[productID];
    }

    function getTransactionID() public view returns (uint256) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        return ds.transactionID;
    }

    function _merchantChargesDibited(address from, uint256 amount) internal {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        // require(IERC20(ds.RGP).transferFrom(from, address(this), amount), "Rigel's Protocol: Unable to withdraw gasFee from 'from' address");
        if (!IERC20(ds.RGP).transferFrom(from, address(this), amount))  revert Unable_To_Withdraw(); 
    }

    function _tDecimals(IERC20 purchaseToken, uint256 amount) internal view returns (uint256 tDecimals) {
        tDecimals = amount * 10**purchaseToken.decimals();
    }

    receive() external payable{}

    function emmergencyWithdrawalOfETH(uint256 amount) external onlyOwner{
        // require(address(this).balance > amount, "Balance of contract is less than inPut amount");
        // if (address(this).balance < amount)  revert Low_Contract_Balance(); 
        payable(owner()).transfer(amount);
    }

    function withdrawTokenFromContract(address tokenAddress, uint256 _amount, address _receiver) external onlyOwner {
        IERC20(tokenAddress).transfer(_receiver, _amount);
    }

}