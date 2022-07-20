/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

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




/** 
 *  SourceUnit: /media/encryption/Encrypt/Projects/RigelProtocol/RigelDecentralizedP2PSystem/contracts/RigelDecentralizedP2PSystem.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT

pragma solidity 0.8.13;

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
    uint96 id; 
    address token;
    bool    isCompleted;
    bool 	isOnDispute;
    uint256 amount;
    uint128 startSales;
    uint128 endSales;
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
    bool 	isResolved;
    uint256 amount;
    uint256 payment;
    uint256 time;
    uint128 votesCommence;
    uint128 votesEnded;
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

struct TokenDetails {
    uint256 tradeAmount;
    bytes   rank;
    address token;
    uint256 sellerFee;
    uint256 buyerFee;
}

/**
 * @dev silently declare mapping for the products on Rigel's Protocol Decentralized P2P network
 */
library rigelMapped {
    struct libStorage {
        mapping(uint96 => AllProducts)  allProducts;  
        mapping(uint256 => MembersTips)  tips;
        mapping(uint256 => DisputeRaised[])  raisedDispute;
        mapping(address => mapping(address => uint256))  balance;
        mapping(address => Store)  store;
        mapping(address => bool)   refWhitelist;
        mapping(address => bool) isAdded;
        mapping(address => uint256)  buyer;
        mapping(address => uint256) allTrade;
        mapping(address => uint256) refSpecialWhitelist;
        mapping(address => bool) hasBeenReferred;
        mapping(address => bool) hasReferral;
        mapping(address => address) whoIreferred;
        TokenDetails[]  tokenDetails;
        address[]  member;
        address  RGP;
        address  RGPStake;
        address  devAddress;
        uint256  refWithoutWhitelistPercent;
        uint256  beforeVotesStart;
        uint256  votingEllapseTime;
        uint256  maxNumbersofCouncils;
        uint256  unlistedTokenFees;
        uint256  sellerFee;
        uint96  transactionID; // if 79228162514264337593543950335 require upgrade
    }

    function diamondStorage() internal pure returns(libStorage storage ds) {
        bytes32 storagePosition = keccak256("Rigel Decentralized P2P System.");
        assembly {ds.slot := storagePosition}
    }

    function _isOnDispute(
        address who, 
        address against, 
        address token, 
        uint256 productID,  
        uint256 amount, 
        uint256 fee,
        uint256 _join
    ) internal {
        libStorage storage ds = diamondStorage();
        DisputeRaised memory rDispute = DisputeRaised(
            who, against, token, false, amount, fee , block.timestamp, uint128(block.timestamp + _join), 0
        );
        ds.raisedDispute[productID].push(rDispute);
    }

}




/** 
 *  SourceUnit: /media/encryption/Encrypt/Projects/RigelProtocol/RigelDecentralizedP2PSystem/contracts/RigelDecentralizedP2PSystem.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.13;

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
// "Rigel's Protocol: Minimum Council Members require for this vote not met"
error More_Members_Needed();
// "Rigel's Protocol: Unable to withdraw gasFee from 'from' address"
error Unable_To_Withdraw();
// "Balance of contract is less than inPut amount"
error Low_Contract_Balance();
// funds are currently locked
error currentlyLocked();
// "Rigel's Protocol: Permission Denied, address not qualified for this `rank`"
error Not_Qualify();
// "Rigel's Protocol: Votes already stated"
error VoteCommence();
// "Rigel's Protocol: Permission Denied, due to numbers completed numbers of council members require for the dispute"
error CompletedMember();
// "Rigel's Protocol: Length of arg invalid"
error invalidLength();
// "Rigel's Protocol: input amount can't be greater than amount of token to sell"
error invalidAmount();




/** 
 *  SourceUnit: /media/encryption/Encrypt/Projects/RigelProtocol/RigelDecentralizedP2PSystem/contracts/RigelDecentralizedP2PSystem.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT

pragma solidity 0.8.13;

// ////import "./rigelStruct.sol";


/**
 * @dev silently declare mapping for the products on Rigel's Protocol Decentralized P2P network
 */
interface events {
   /**
     * @dev Emitted when the Buyer makes a call to Lock Merchant Funds, is set by
     * a call to {makeBuyPurchase}. `value` is the new allowance.
     */
    event Buy(address indexed merchant, address indexed buyer, address token, uint256 amount, uint96 productID, uint256 time);

    /**
     * @dev Emitted when the Merchant Comfirmed that they have recieved their Funds, is set by
     * a call to {makeSellPurchase}. `value` is the new allowance.
     */
    event Sell(address indexed buyer, address indexed merchant, address token, uint256 amount, uint96 productID, uint256 time);

    /**
     * @dev Emitted when Dispute is raise.
     */
    event dispute(address indexed who, address indexed against, address token, uint256 amount, uint256 ID, uint256 time);  

    /**
     * @dev Emitted when a vote has been raise.
     */
    event councilVote(address indexed councilMember, address indexed who, uint96 productID, uint256 indexedOfID, uint256 time);  

    event SetStakeAddr(address indexed rgpStake);

    event SetWhiteList(address[] indexed accounts, bool status);

    event ResolveVotes( uint96 productID, uint256 indexedOf, address indexed who);

    event JoinDispute( address indexed account, uint96 productID, uint256 indexedOf);

    event CancelDebt(uint256 amount, address indexed account);

    event CastVote(uint96 productID, uint256 indexedOf, address who);

    event rewards(address token, address[] indexed memmber, uint256 amount, uint256 withdrawTime);

    event MultipleAdmin(address[] indexed _adminAddress, bool status);

    event EmmergencyWithdrawalOfETH(uint256 amount);

    event WithdrawTokenFromContract(address indexed tokenAddress, uint256 _amount, address indexed _receiver);
    
    event newAssetAdded(address indexed newAsset, uint256 seller, uint256 buyer);
    event delist(address indexed removed);
}




/** 
 *  SourceUnit: /media/encryption/Encrypt/Projects/RigelProtocol/RigelDecentralizedP2PSystem/contracts/RigelDecentralizedP2PSystem.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

////import "./Context.sol";

abstract contract Ownable {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
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
        Context.context storage ds = Context.diamondContext();
        address oldOwner = ds._owner;
        ds._owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}




/** 
 *  SourceUnit: /media/encryption/Encrypt/Projects/RigelProtocol/RigelDecentralizedP2PSystem/contracts/RigelDecentralizedP2PSystem.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.13;
////import "./ownable/Ownable.sol";
////import "./events/events.sol";
////import "./errors/p2pError.sol";
////import "./libStore/rigelMapped.sol";

abstract contract Rigelp2pPriceSet is Ownable, events {    

    function setAssetPriceForDisputes(
        address _asset, 
        uint256[] memory _tadeAmount, 
        bytes[] memory _ranks, 
        uint256[] memory sellerFee, 
        uint256[] memory buyerFee
    ) external onlyOwner {
        if (
            _tadeAmount.length != _ranks.length &&
            sellerFee.length != buyerFee.length
        ) revert invalidLength();
        for (uint256 i; i < _ranks.length; i++) {
            _setTokenPrice(_tadeAmount[i], _ranks[i], _asset, sellerFee[i], buyerFee[i]);
        }
    }

    function setFeeForBuyers(address[] memory asset, uint256[] memory fee) external onlyOwner {
        if (asset.length != fee.length) revert invalidLength();
        for (uint256 i; i < asset.length; i++) {
            _setBuyersFee(asset[i], fee[i]);
        }
    }

    function setDeploy(
        uint256 sellersFeeInRGP, 
        uint256 unWhitelistedAddressReferralFeeInPercent, 
        uint256 unListedTokenRewardPercent) 
    external onlyOwner {        
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        ds.sellerFee = sellersFeeInRGP;
        ds.refWithoutWhitelistPercent = unWhitelistedAddressReferralFeeInPercent;
        ds.unlistedTokenFees = unListedTokenRewardPercent;
    }

    /** @notice setWhiteList. Enabling the owner to be able to set and reset whitelisting accounts status.
	 * @param accounts arrays of `accounts` to update their whitelisting `status`
	 * @param status the status could be true or false.
     * Function signature e43f696e  =>  setWhiteList(address[],bool)   
     */
    function setSpecialWhiteList(address[] memory accounts, uint256[] memory percent, bool status) external onlyOwner {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        uint256 len = accounts.length;
        if (status == true) {
           for(uint256 i = 0; i < len; i++) {
            ds.refWhitelist[accounts[i]] = status;
            ds.refSpecialWhitelist[accounts[i]] = percent[i];
            } 
        } else{
            for(uint256 i = 0; i < len; i++) {
                delete(ds.refWhitelist[accounts[i]]);
            }
        }

        emit SetWhiteList(accounts, status);
    }



    function delistAsset(uint256[] memory _assets) external onlyOwner {
        for (uint256 i; i < _assets.length; i++) {
            _delistAsset(_assets[i]);
        }
    }
    
    function getUnlistedTokenChargePercent() public view returns(uint256) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        return ds.unlistedTokenFees;
    }

    function lengthOfListedAsset() public view returns(uint256) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        return ds.tokenDetails.length;
    }

    function getBatchTokenFeeForBuyer(address[] memory _asset) external view returns(uint256[] memory _fee) {
        _fee = new uint256[](_asset.length);
        for ( uint256 i; i < _asset.length; i++) {
            _fee[i] = _getTokenFeeForBuyer(_asset[i]);
        }
        return _fee;
    }

    /**
     * @dev Returns `uint256` the amount of RGP Merchant will pay through {makeBuyPurchase}.
     */
     function getFees() public view returns (uint256 _sellerFee, uint256 unwhitelistRef) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        _sellerFee = ds.sellerFee;
        unwhitelistRef = ds.refWithoutWhitelistPercent;
    }

    function getAssetPriceOnDispute(uint256[] memory assetID) external view returns(TokenDetails[] memory tD, bool[] memory) {
        uint256 _assetLength = assetID.length;
        bool[] memory _added = new bool[](_assetLength);
        for (uint256 i; i < _assetLength; i++) {
            tD[i] = _getAssetPriceOnDispute(assetID[i]);
            _added[i] = _isAssestAdded(tD[i].token);
        }
        return (tD, _added);
    }

    function _setBuyersFee(address token, uint256 fee) internal {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        ds.buyer[token] = fee;

    }

    function _getTokenFeeForBuyer(address _asset) internal view returns(uint256) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        return ds.buyer[_asset];
    }

    function _isAssestAdded(address _asset) internal view returns(bool _isAdded)  {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        _isAdded = ds.isAdded[_asset];
    }

    function _getAssetPriceOnDispute(uint256 assetID) internal view returns(TokenDetails memory tD) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        tD = ds.tokenDetails[assetID];
        return tD;
    }

    function _setTokenPrice(uint256 _trade, bytes memory _ranks, address _asset, uint256 sellerFee, uint256 buyesFee) internal {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        TokenDetails memory tD = TokenDetails(_trade, _ranks, _asset, sellerFee, buyesFee);
        ds.tokenDetails.push(tD);
        ds.isAdded[_asset] = true;
        emit newAssetAdded(_asset, sellerFee, buyesFee);
    }

    function _delistAsset(uint256 assetID) internal {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        TokenDetails storage tD = ds.tokenDetails[assetID];
        ds.isAdded[tD.token] = false;

        emit delist(tD.token);
    }
}



/** 
 *  SourceUnit: /media/encryption/Encrypt/Projects/RigelProtocol/RigelDecentralizedP2PSystem/contracts/RigelDecentralizedP2PSystem.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.13;

interface IStakeRIgel {

    function getMyRank(address account) external view returns(uint256);

    function getLockPeriodData() external view returns(uint256, uint256);

    function getSetsBadgeForMerchant(bytes memory _badge) external view returns(
        bytes  memory   Rank,
        bytes  memory   otherRank,
        address[] memory tokenAddresses,
        uint256[] memory requireURI,
        uint256 maxRequireJoin,
        uint256 wrongVotesFees
    );
}



/** 
 *  SourceUnit: /media/encryption/Encrypt/Projects/RigelProtocol/RigelDecentralizedP2PSystem/contracts/RigelDecentralizedP2PSystem.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity 0.8.13;

interface IERC20 {
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


/** 
 *  SourceUnit: /media/encryption/Encrypt/Projects/RigelProtocol/RigelDecentralizedP2PSystem/contracts/RigelDecentralizedP2PSystem.sol
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.13;
////import "./interface/IERC20.sol";
////import "./interface/IStakeRIgel.sol";
////import "./Rigelp2pPriceSet.sol";

contract FRigelDecentralizedP2PSystem is Rigelp2pPriceSet {
    uint256 private constant pow16 = 10 ** 16;
    // ******************* //
    // *** CONSTRUCTOR *** //
    // ******************* //
    
    /** @notice Constructor. Links with RigelDecentralizedP2PSystem contract
     * @param dev dev address;
     * @param rgpToken address of RGP token Contract;
    */
    constructor (
        address dev,
        address rgpToken
    ) { 
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        ds.RGP = rgpToken;
        ds.devAddress = dev;
    }

    // ********************************* //
    // *** EXTERNAL WRITE FUNCTIONS *** //
    // ******************************* //
    
    /** @notice makeBuyPurchase access to a user
     * @param purchaseToken address of token contract address to check for approval
     * @param amount amount of the token to purchase by 'to' from 'from' not in decimal
     * @param from address of the seller
     * @param referral referral address
     */ 
    function makeSellOrder(IERC20 purchaseToken, uint256 amount, address from, address referral) external returns(uint256){   
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();     
        uint256 tokenBalance = purchaseToken.balanceOf(from);
        uint256 tDecimals = getAmountInTokenDecimal(purchaseToken, amount);
        if (tokenBalance < tDecimals)  revert Insufficient_Balalnce();
        uint256 _s_seller = ds.sellerFee;
        _merchantChargesDibited(from, _s_seller);
        if (!purchaseToken.transferFrom(from, address(this), tDecimals)) revert Insufficient_Balalnce();     
        uint96 id = ds.transactionID++;
        address referred = ds.whoIreferred[referral];
        uint256 refShare = (_s_seller * (ds.refWithoutWhitelistPercent * pow16)) / 100E18;
        _settleBuyReferralRewards(_s_seller, refShare, from, referral, referred);
        if (referred != address(0)) {            
            _contractTransfer(address(ds.RGP), referred, refShare);
        }
        ds.allTrade[address(purchaseToken)] += amount;
        ds.allProducts[id] =  AllProducts(address(this), from, id, address(purchaseToken), false, false, tDecimals, uint128(block.timestamp), 0);
        emit Buy(from, address(this), address(purchaseToken), tDecimals, id, block.timestamp);
        return id;
    }

    function _settleBuyReferralRewards(uint256 s_seller, uint256 isRefRew, address from,  address referral, address isRef) internal {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage(); 
        uint256 refShare;  
        if (referral != address(0)) {
            ds.hasBeenReferred[referral] = true;
            ds.whoIreferred[referral] = from;
            if(!ds.refWhitelist[referral]) {
                refShare = (s_seller * (ds.refWithoutWhitelistPercent) * pow16) / 100E18;
                _contractTransfer(address(ds.RGP), referral, refShare);  
            } else {
                uint256 specialReferral = ds.refSpecialWhitelist[referral];
                refShare = (s_seller * (specialReferral * pow16)) / 100E18;
                _contractTransfer(address(ds.RGP), referral, refShare); 
                
            }
        }
        if (isRef != address(0)) {
            _contractTransfer(address(ds.RGP), ds.devAddress, (s_seller - (refShare + isRefRew))); 
        } else {_contractTransfer(address(ds.RGP), ds.devAddress, (s_seller - (refShare)));  }
        
    }

    function _settleSellReferralRewards(IERC20 purchaseToken, uint256 subGas, address to,  address referral, address isRef) internal {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage(); 
        uint256 refShare; 
        (, uint256 unWhiteList) = getFees();
        uint256 isRefRew = _share(purchaseToken, subGas, unWhiteList);
        if (referral != address(0)) {
            ds.hasBeenReferred[referral] = true;
            ds.whoIreferred[referral] = to;
            if(!ds.refWhitelist[referral]) {
                refShare = _share(purchaseToken, subGas, unWhiteList);
                _contractTransfer(address(purchaseToken), referral, refShare);  
            } else {
                uint256 specialReferral = ds.refSpecialWhitelist[referral];
                refShare = _share(purchaseToken, subGas, specialReferral);
                _contractTransfer(address(purchaseToken), referral, refShare);                 
            }
        }
        if (isRef != address(0)) {
            _contractTransfer(address(purchaseToken), isRef, isRefRew);
            _contractTransfer(address(purchaseToken), ds.devAddress, (subGas - (refShare + isRefRew))); 
        } else {
            _contractTransfer(address(purchaseToken), ds.devAddress, (subGas - (refShare)));  
        }
        
    }

    function _checks(address purchaseToken,  uint96 productID) internal view { 
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage(); 
        AllProducts storage all = ds.allProducts[productID];
        if (address(purchaseToken) != all.token)  revert Invalid_Token();
        if (all.isCompleted) revert Transaction_completed();
        if (all.isOnDispute)  revert Product_On_Dispute(); 
    }
    

    // /** @dev grant access to a user for the sell of token specified.
    //  * @param purchaseToken address of token contract address to check for approval
    //  * @param from address of the seller
    //  * @param productID the product id
    //  */ 
    function completeBuyOrder(IERC20 purchaseToken,  uint96 productID, address to, uint256 _howMuch, address referral) external onlyAdmin {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage(); 
        AllProducts storage all = ds.allProducts[productID];
        if (_howMuch > all.amount) revert invalidAmount();
        _checks(address(purchaseToken), productID);
        (uint256 subGas,uint256 remnant) = _getGas(purchaseToken, productID);
        _updateBuy(productID, _howMuch, to);        
        address s_token = all.token;
        address referred = ds.whoIreferred[referral];
        _settleSellReferralRewards(purchaseToken, subGas, to, referral, referred);
        _contractTransfer(s_token, to, remnant);
        // _contractTransfer(s_token, ds.devAddress, remnant);
        emit Buy(to, all.seller, s_token, subGas, productID, block.timestamp);
    }

    function raiseDispute(uint96 productID, address who) external onlyAdmin{
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();  
        AllProducts storage all = ds.allProducts[productID];
        if (all.isOnDispute)  revert Dispute_Raised(); 
        if (all.isCompleted)  revert Transaction_completed(); 
        if (productID > getTransactionID())  revert Invalid_ProductID(); 
        uint256 commence = ds.beforeVotesStart;
        address s_token = all.token;
        uint256 s_amount = all.amount;
        (,uint256 buyersDisputeFee, uint256 sellerDisputeFee,)= getDisputeFees(s_amount, s_token);       
        
        bool _who = isForBuyerOrSeller(productID, who);
        if (_who) {
            all.amount = (s_amount - buyersDisputeFee);
            rigelMapped._isOnDispute(
                who, 
                all.seller, 
                s_token, 
                productID, 
                all.amount, 
                buyersDisputeFee, 
                commence
            );
            emit dispute(who, all.seller, s_token, all.amount, productID, block.timestamp);
        } else {
            _merchantChargesDibited(who, sellerDisputeFee); 
            rigelMapped._isOnDispute( 
                all.seller, 
                who, 
                s_token, 
                productID, 
                all.amount, 
                sellerDisputeFee,
                commence
            );
            emit dispute(who, all.buyer, s_token, all.amount, productID, block.timestamp);
        }
    }

    function resolveVotes(uint96 productID, address who) external onlyAdmin{
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();  
        AllProducts storage all = ds.allProducts[productID];
        DisputeRaised storage disputeRaise = ds.raisedDispute[productID][0];
        address s_token = all.token;
        _checks(s_token, productID);
        (,uint256 buyersDisputeFee, uint256 sellerDisputeFee,)= getDisputeFees(all.amount, s_token);  
        bool _who = isForBuyerOrSeller(productID, who);
        all.isCompleted = true;
        all.endSales = uint128(block.timestamp);
        MembersTips memory tipMe = ds.tips[productID];
        
        uint256 len = tipMe.joinedCouncilMembers.length;
        if (_who) {
            all.amount = (all.amount - buyersDisputeFee);
            uint256 forEach = buyersDisputeFee / len;
            if (len > 0) {
                for (uint256 i; i < len; i++){
                    address voters = tipMe.joinedCouncilMembers[i];
                    _update(voters);
                    _contractTransfer(s_token, voters, forEach);
                }
            }   
            _contractTransfer(s_token, who, all.amount);  
            emit rewards(s_token, tipMe.joinedCouncilMembers , buyersDisputeFee, block.timestamp);         
        } else {
            _merchantChargesDibited(who, sellerDisputeFee);  
            uint256 forEach = sellerDisputeFee / len;           
            if (len > 0) {
                for (uint256 i; i < len; i++) {
                    address voters = tipMe.joinedCouncilMembers[i];  
                    _update(voters);
                    _contractTransfer(ds.RGP, voters, forEach);        
                } 
            } 
            _contractTransfer(s_token, who, all.amount);  
            emit rewards(ds.RGP, tipMe.joinedCouncilMembers , sellerDisputeFee, block.timestamp);
        }
        all.isCompleted = true;
        all.isOnDispute = false;
        all.endSales = uint128(block.timestamp);
        disputeRaise.isResolved = true;

        emit ResolveVotes(productID, 0, who);

    }

    function joinDispute(uint96 productID) external {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage(); 
        DisputeRaised storage disputeRaise = ds.raisedDispute[productID][0];
        AllProducts memory all = ds.allProducts[productID];
        MembersTips storage tipMe = ds.tips[productID];

        if (all.isCompleted) revert Transaction_completed();
        bool hasJoined;
        uint256 lent = tipMe.joinedCouncilMembers.length;
        for(uint256 i; i < lent; i++) {
            address joined = tipMe.joinedCouncilMembers[i];
            if (_msgSender() == joined) {
                hasJoined = true;
                break;
            }
        }
        if(hasJoined) revert not_Permitted();
        if (_msgSender() == disputeRaise.who || _msgSender() == disputeRaise.against)  revert not_Permitted(); 
           
        Store storage myBadge = ds.store[_msgSender()];
        (
            uint256 _max
        ) = IStakeRIgel(ds.RGPStake).getMyRank(_msgSender());

        if(myBadge.isLocked) revert currentlyLocked();
        if (tipMe.joinedCouncilMembers.length == ds.maxNumbersofCouncils) {
            uint128 commence = disputeRaise.votesCommence;
            if (block.timestamp < uint256(commence))  revert CompletedMember();
            if (block.timestamp > uint256(commence))  revert VoteCommence();
        }
        if(_max < all.amount) revert Not_Qualify();

        myBadge.isResolving = true;
        myBadge.joined ++;
        tipMe.joinedCouncilMembers.push(_msgSender());
        if (tipMe.joinedCouncilMembers.length == ds.maxNumbersofCouncils) { 
            disputeRaise.votesEnded = uint128(block.timestamp + ds.votingEllapseTime);
        }
        emit JoinDispute(_msgSender(), productID, 0);
    }

    function cancelDebt(uint256 amount) external {        
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage(); 
        Store storage myBadge = ds.store[_msgSender()];
        _merchantChargesDibited(_msgSender(), amount);
        myBadge.tFee4WrongVotes -= amount;
        if (myBadge.tFee4WrongVotes == 0) {
            myBadge.isLocked = false;
        }
        emit CancelDebt(amount, _msgSender());
    }

    function castVote(uint96 productID, address who) external {       
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
        if (!haveRight)  revert Voting_Denied(); 
        if ((iVoted(productID, _msgSender()))) revert Already_voted(); 
        _update(_msgSender());       
        _tip(productID, who);
        emit CastVote(productID, 0, who);
    }

    // *************************** //
    // *** INTERNAL FUNCTIONS *** //
    // ************************* //



    function _share(IERC20 purchaseToken, uint256 subGas, uint256 sharePct) internal view returns(uint256 refShare) {
        return (subGas * (sharePct * 10 ** (purchaseToken.decimals()-2))) / (100 * 10 **(purchaseToken.decimals()));
    }

    function _getGas(IERC20 purchaseToken, uint96 productID) internal view returns(uint256 _gas, uint256 rem) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage(); 
        AllProducts memory all = ds.allProducts[productID];
        uint256 tMount = (purchaseToken.decimals());
        uint256 subGas;
        uint256 amount = (all.amount);
        uint256 gas = _getTokenFeeForBuyer(address(purchaseToken));
        uint256 remnant;
        if (gas == 0) {
            subGas = (amount * (getUnlistedTokenChargePercent() * 10 ** (tMount - 2))) / (100 * 10 ** tMount);
            remnant = amount - subGas;
        } else {
            subGas =  amount - gas;
            remnant = amount - subGas;
        }
        return(subGas, remnant);
    }

    function _updateBuy(uint96 productID, uint256 _howMuch, address to) internal {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage(); 
        AllProducts storage all = ds.allProducts[productID];
        all.amount -= _howMuch;
        all.amount == 0 ? all.isCompleted = true : all.isCompleted = false ;
        all.amount == 0 ? all.endSales = uint128(block.timestamp) : 0;
        all.buyer = to;
    }

    function isForBuyerOrSeller(uint96 productID, address who) internal  returns(bool forBuyer){
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage(); 
        AllProducts storage all = ds.allProducts[productID];
        if (all.seller == who) {
            forBuyer = false;
        } else  {                
            forBuyer = true;
        }
        all.isOnDispute = true;
    }

    function _tip(uint96 productID, address who) internal {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage(); 
        MembersTips storage tipMe = ds.tips[productID];
        AllProducts memory all = ds.allProducts[productID];
        DisputeRaised memory rDispute = ds.raisedDispute[productID][0]; 
        address s_token = all.token;       
        (, , , uint256 wrongVotesFees)= getDisputeFees(all.amount, s_token);  

        require(who == rDispute.who || who == rDispute.against, "Rigel's Protocol: `who` is not a participant");
        if (!all.isOnDispute)  revert No_Dispute(); 
        if (tipMe.qualified != address(0))  revert Tip_Met_Max_Amt(); 
        if (rDispute.votesEnded == 0)  revert Be_Patient();
        if (block.timestamp > uint256(rDispute.votesCommence)) {
            if (tipMe.joinedCouncilMembers.length < ds.maxNumbersofCouncils)  revert More_Members_Needed();              
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
        chkLockStatus();
        address s_qualified = tipMe.qualified;
        if(s_qualified != address(0)) {        
            uint256 devReward;
            uint256 sharableRewards;
            uint256 _huPercent = getAmountInTokenDecimal(IERC20(s_token), 100);
            _contractTransfer(s_token, s_qualified, all.amount);  
            if(s_qualified == all.seller) { 
                devReward = (rDispute.payment * 20E18) / 100E18;
                sharableRewards = (rDispute.payment * 80E18) / 100E18;
            } else {
                devReward = (rDispute.payment * getAmountInTokenDecimal(IERC20(s_token), 20)) / _huPercent;
                sharableRewards = (rDispute.payment * getAmountInTokenDecimal(IERC20(s_token), 80)) / _huPercent;
            }
            ds.balance[ds.devAddress][s_token] += devReward;  
            _l(productID, sharableRewards, wrongVotesFees, s_token, s_qualified);
        }
        emit councilVote(_msgSender(), who, productID, 0, block.timestamp);
    }

    function _l(uint96 productID, uint256 amountShared, uint256 fee,address token, address who) internal {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();         
        AllProducts storage all = ds.allProducts[productID];
        
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
            _contractTransfer(token, consM, forEach);   
            emit rewards(token,ds.member , amountShared, block.timestamp);    

            // ds.balance[consM][token] += forEach;
        }
        delete ds.member;

        for (uint256 x = 0; x < lst.length; x++) {
            address ls = lst[x];
            if (ls != address(0)) {
                Store storage myBadge = ds.store[ls];
                myBadge.tFee4WrongVotes += fee;
                myBadge.wrongVote ++;
            }
        }
        all.isCompleted = true;
        all.isOnDispute = false;
        all.endSales = uint128(block.timestamp);

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

    function _update(address user) internal {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();  
        Store storage myBadge = ds.store[user];
        myBadge.joined --;
        myBadge.totalVotes ++;
        if (myBadge.joined == 0) {
            myBadge.isResolving = false;
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

    function lockPeriod() internal view returns(uint256 tLockCheck, uint256 pLockCheck) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        (tLockCheck, pLockCheck) = IStakeRIgel(ds.RGPStake).getLockPeriodData();
    }

    function _contractTransfer(address token, address user, uint256 amount) internal {
        if (!IERC20(token).transfer(user, amount))  revert Unable_To_Withdraw(); 
    }

    function _merchantChargesDibited(address from, uint256 amount) internal {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        if (!IERC20(ds.RGP).transferFrom(from, address(this), amount))  revert Unable_To_Withdraw(); 
    }

    // ****************************** //
    // *** PUBLIC VIEW FUNCTIONS *** //
    // **************************** //
    function getDisputeFees(uint256 _amountBeenTraded, address token) public view returns(
        bytes memory rank, 
        uint256 buyersDisputeFee, 
        uint256 sellerDisputeFee, 
        uint256 wrongVote) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();  

        uint256 lent = lengthOfListedAsset();
        for (uint256 i; i < lent; i++) {
            TokenDetails memory tD = ds.tokenDetails[i];
            (
                ,,, ,, uint256 wVote
            ) = IStakeRIgel(ds.RGPStake).getSetsBadgeForMerchant(tD.rank);
            if (_amountBeenTraded <= tD.tradeAmount && tD.token == token) {
                buyersDisputeFee = tD.buyerFee;
                sellerDisputeFee = tD.sellerFee;
                rank = tD.rank;
                wrongVote = wVote;   
                break;
            }
            //  else {
            //     uint256 unlistedFee = 
            //         (ds.unlistedTokenFees) * 10 ** (IERC20(token).decimals() - 2) / (100 * 10 ** IERC20(token).decimals());
            //     buyersDisputeFee = unlistedFee;
            //     sellerDisputeFee = unlistedFee;
            // }
        }
    }

    function getTransactionID() public view returns (uint96) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        return ds.transactionID;
    }

    function getAmountInTokenDecimal(IERC20 purchaseToken, uint256 amount) public view returns (uint256 tDecimals) {
        tDecimals = amount * 10**purchaseToken.decimals();
    }

    function viewStateManagement() public view returns(uint256 beforeVoteCommence, uint256 voteEllapseTime, uint256 numOfCouncils) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();   
        beforeVoteCommence = ds.beforeVotesStart;
        voteEllapseTime = ds.votingEllapseTime;
        numOfCouncils = ds.maxNumbersofCouncils;
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

    // ******************************** //
    // *** EXTERNAL VIEW FUNCTIONS *** //
    // ****************************** //

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
    function productDetails(uint96 productID) external view returns (AllProducts memory all) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        all = ds.allProducts[productID];
    }
    
    /**
     * @dev Returns information about disputes raised for a `rank`
     */
    function getDisputeRaised(uint256 productID) external view returns(DisputeRaised memory disputeRaise) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        disputeRaise = ds.raisedDispute[productID][0];
    }

    function getWhoIsleading(uint256 productID) external view returns(MembersTips memory tip) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        tip = ds.tips[productID];
    }

    function rigelToken() external view returns(address) {        
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        return ds.RGP;
    }

    function devAddress() external view returns(address) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        return ds.devAddress;
    }

    function stakesContractAddress() external view returns(address) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        return ds.RGPStake;
    }

    function getSetRefPercent(address account) external view returns(uint256) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        return ds.refSpecialWhitelist[account];
    }

    function getAmountTradedFor(address _asset) external view returns(uint256) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        return ds.allTrade[_asset];
    }


    function multipleAdmin(address[] calldata _adminAddress, bool status) external onlyOwner {
        Context.context storage dc = Context.diamondContext();
        if (status == true) {
           for(uint256 i = 0; i < _adminAddress.length; i++) {
            dc.isAdminAddress[_adminAddress[i]] = status;
            } 
            emit MultipleAdmin(_adminAddress, status);
        } else{
            for(uint256 i = 0; i < _adminAddress.length; i++) {
                delete(dc.isAdminAddress[_adminAddress[i]]);
            }
        }
        emit MultipleAdmin(_adminAddress, status);
    }

    /** @notice setStakeAddr. Enabling the owner to be able to reset sets fees for buyes and sellers
	 * @param rgpStake Updating the staking contract address by the owner.
     * Function signature a9e51d32  =>  setStakeAddr(address)  
     */
    function setStakeAddr(address rgpStake) external onlyOwner {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        ds.RGPStake = rgpStake;
        emit SetStakeAddr(rgpStake);
    }
    
    function stakeManagement(uint256 beforeVoteCommence, uint256 voteEllapseTime, uint256 numOfCouncils) external onlyOwner {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();        
        ds.beforeVotesStart = beforeVoteCommence;
        ds.votingEllapseTime = voteEllapseTime;
        ds.maxNumbersofCouncils = numOfCouncils;
    }

    receive() external payable{}

    function emmergencyWithdrawalOfETH(uint256 amount) external onlyOwner{
        payable(owner()).transfer(amount);
        emit EmmergencyWithdrawalOfETH(amount);
    }

    function withdrawTokenFromContract(address tokenAddress, uint256 _amount, address _receiver) external onlyOwner {
        IERC20(tokenAddress).transfer(_receiver, _amount);
        emit WithdrawTokenFromContract(tokenAddress, _amount, _receiver);
    }

}