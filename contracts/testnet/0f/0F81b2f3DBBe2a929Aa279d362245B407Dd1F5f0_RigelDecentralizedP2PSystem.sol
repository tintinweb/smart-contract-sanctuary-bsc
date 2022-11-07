// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * As of v2.5.0, only `address` sets are supported.
 *
 * Include with `using EnumerableSet for EnumerableSet.AddressSet;`.
 *
 * @author Alberto Cuesta Cañada
 */
library EnumerableSet {

    struct AddressSet {
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (address => uint256) index;
        address[] values;
    }

    /**
     * @dev Add a value to a set. O(1).
     * Returns false if the value was already in the set.
     */
    function add(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        if (!contains(set, value)) {
            set.values.push(value);
            // The element is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set.index[value] = set.values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     * Returns false if the value was not present in the set.
     */
    function remove(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        if (contains(set, value)){
            uint256 toDeleteIndex = set.index[value] - 1;
            uint256 lastIndex = set.values.length - 1;

            // If the element we're deleting is the last one, we can just remove it without doing a swap
            if (lastIndex != toDeleteIndex) {
                address lastValue = set.values[lastIndex];

                // Move the last value to the index where the deleted value is
                set.values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set.index[lastValue] = toDeleteIndex + 1; // All indexes are 1-based
            }

            // Delete the index entry for the deleted value
            delete set.index[value];

            // Delete the old entry for the moved value
            set.values.pop();

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value)
        internal
        view
        returns (bool)
    {
        return set.index[value] != 0;
    }

    /**
     * @dev Returns an array with all values in the set. O(N).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.

     * WARNING: This function may run out of gas on large sets: use {length} and
     * {get} instead in these cases.
     */
    function enumerate(AddressSet storage set)
        internal
        view
        returns (address[] memory)
    {
        address[] memory output = new address[](set.values.length);
        for (uint256 i; i < set.values.length; i++){
            output[i] = set.values[i];
        }
        return output;
    }

    /**
     * @dev Returns the number of elements on the set. O(1).
     */
    function length(AddressSet storage set)
        internal
        view
        returns (uint256)
    {
        return set.values.length;
    }

   /** @dev Returns the element stored at position `index` in the set. O(1).
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function get(AddressSet storage set, uint256 index)
        internal
        view
        returns (address)
    {
        return set.values[index];
    }
}


abstract contract Ownable {

    mapping(address => bool) private isAdminAddress;
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {        
        isAdminAddress[_msgSender()] = true;
        _owner = _msgSender();
    }

    function _adminSet(address _admin, bool status) internal {
        isAdminAddress[_admin] = status;
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

    modifier onlyAdmin() {
        require(isAdminAddress[_msgSender()], "Access Denied: Need Admin Accessibility");
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
    uint256 id; 
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
    uint256 votesCommence;
    uint256 votesEnded;
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
    address[] tippers;
    address[] whoITip;
}

struct Store {
    bool    isResolving;
    bool    isLocked;
    uint64 joined;
    uint64 totalVotes;
    uint64 wrongVote;
    uint256 tFee4WrongVotes;
    uint256 nextWithdrawalTime;
}

struct TokenDetails {
    uint256 tradeAmount;
    bytes   rank;
    uint256 sellerFee;
    uint256 buyerFee;
}

struct BuyersTick {
    uint256 hasBuyerTick;
}



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
// error CompletedMember();
// "Rigel's Protocol: Length of arg invalid"
error invalidLength();
// "Rigel's Protocol: input amount can't be greater than amount of token to sell"
error invalidAmount();

error accountBlacklisted();

error InvalidCallTime();

error UnableToRemove();
error UnableToAdd();



/**
 * @dev silently declare mapping for the products on Rigel's Protocol Decentralized P2P network
 */
interface events {
   /**
     * @dev Emitted when the Buyer makes a call to Lock Merchant Funds, is set by
     * a call to {makeBuyPurchase}. `value` is the new allowance.
     */
    event Buy(address indexed merchant, address indexed buyer, address token, uint256 amount, uint256 productID, uint256 time);

    /**
     * @dev Emitted when the Merchant Comfirmed that they have recieved their Funds, is set by
     * a call to {makeSellPurchase}. `value` is the new allowance.
     */
    event Sell(address indexed buyer, address indexed merchant, address token, uint256 amount, uint256 productID, uint256 time);

    /**
     * @dev Emitted when Dispute is raise.
     */
    event dispute(address indexed who, address indexed against, address token, uint256 amount, uint256 ID, uint256 time);

    /**
     * @dev Emitted when a vote has been raise.
     */
    event councilVote(address indexed councilMember, address indexed who, uint256 productID, uint256 indexedOfID, uint256 time);

    event SetStakeAddr(address indexed rgpStake);

    event SetWhiteList(address[] indexed accounts, bool status);

    event ResolveVotes( uint256 productID, uint256 indexedOf, address indexed who);

    event JoinDispute( address indexed account, uint256 productID, uint256 indexedOf);

    event CancelDebt(uint256 amount, address indexed account);

    event CastVote(uint256 productID, uint256 indexedOf, address indexed who);

    event BuyerCancelledTrade(uint256 tokenID, address indexed user, bool releaseStatus, uint256 time);

    event BuyerConfirmSaleStatus(uint256 tokenID, address indexed user, uint256 time);
    
    event BuyerRevertSaleStatus(uint256 tokenID, address indexed user, uint256 time);

    event rewards(address indexed token, address[] indexed memmber, uint256 amount, uint256 withdrawTime);

    event MultipleAdmin(address[] indexed _adminAddress, bool status);

    event EmmergencyWithdrawalOfETH(uint256 amount);

    event WithdrawTokenFromContract(address indexed tokenAddress, uint256 _amount, address indexed _receiver);
    
    event newAssetAdded(address indexed newAsset, uint256 seller, uint256 buyer);

    event initBuyAndSellFee(uint256 sellerFee, uint256 buyerFee);

    event initWhitelist(uint256 init);
    
    event delist(address indexed removed);
}


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

contract Storage is events, Ownable {

    using EnumerableSet for EnumerableSet.AddressSet;
    mapping(uint256 => EnumerableSet.AddressSet) internal joinMembers;

    mapping(uint256 => AllProducts) private allProducts;
    mapping(uint256 => MembersTips) private  tips;
    mapping(uint256 => DisputeRaised) private  raisedDispute;
    mapping(address => Store) private store;
    mapping(address => TokenDetails) private tokenDetails;
    mapping(uint256 => BuyersTick) private hasBuyerTick;
    mapping(address => bool)  private refWhitelist;
    mapping(address => bool) private isAdded;
    mapping(address => uint256) private buyer;
    mapping(address => uint256) private allTrade;
    mapping(address => uint256) private refSpecialWhitelist;
    mapping(address => bool) private hasBeenReferred;
    mapping(address => address) private whoIreferred;
    mapping(address => bool) private isBlacklisted;
    mapping (address => mapping (uint256 => bool)) private hasVote;
    mapping(uint256 => address[]) private membersSet;
    address[] private member;
    address private immutable RGP;
    address private immutable devAddress;
    address private immutable vaultAddress;
    address private RGPStake;
    uint256 private refWithoutWhitelistPercent;
    uint256 private beforeVotesStart;
    uint256 private votingEllapseTime;
    uint256 private maxNumbersofCouncils;
    uint256 private unlistedTokenFees;
    uint256 private sellerFee;
    uint256 private defaultDisputeFeeUnlistedTokensBuyer;
    uint256 private defaultDisputeFeeUnlistedTokensSeller;
    uint256 private defaultFeeForWrongVotes;
    uint256 private transactionID; 
    uint256 private pendingTime;
    uint256 private sellerClaimTime;

    constructor(address _dev, address save, address _rgp) {
        RGP = _rgp;
        vaultAddress = save;
        devAddress = _dev;
    }

    modifier completed(uint256 productID) {
        if (allProducts[productID].isCompleted) revert Transaction_completed();
        _;
    }

    modifier invalid(uint256 productID) {
        if (productID > transactionID)  revert Invalid_ProductID(); 
        if (allProducts[productID].isOnDispute)  revert Dispute_Raised(); 
        _;
    }

    modifier noPermit(uint256 productID) {
        if (msg.sender == raisedDispute[productID].who)  revert not_Permitted();
        if (msg.sender == raisedDispute[productID].against)  revert not_Permitted();
        if(store[msg.sender].isLocked) revert currentlyLocked();
        _;
    }

    modifier checkBlacklist(uint256 productID) {
        if(isBlacklisted[allProducts[productID].seller]) revert accountBlacklisted();
        _;
    }

    function _blacklisted(address account, bool status) internal {
        isBlacklisted[account] = status;
    }

    
    function _storeProducts(address purchaseToken, address from, address to, uint256 amountInDecimals) internal returns(uint256) {
        uint256 id = transactionID++;
        allTrade[purchaseToken] += amountInDecimals;
        allProducts[id] =  AllProducts(to, from, id, purchaseToken, false, false, amountInDecimals, uint128(block.timestamp), 0);
        return id;
    }

    function isBlackListed(IERC20 purchaseToken, address account, uint256 amount) internal {
        if(isBlacklisted[account]) {
            uint256 amountInDecimals = amount * 10**purchaseToken.decimals();
            purchaseToken.transferFrom(account, vaultAddress, amountInDecimals);
            return;
        }
    }

    function _buyerConfirmTradeStatus(uint256 productID) internal {
        address _buyer = allProducts[productID].buyer;
        require(msg.sender == _buyer, "Not_Found" );
        hasBuyerTick[productID].hasBuyerTick = 2;
        emit BuyerConfirmSaleStatus(productID, msg.sender, block.timestamp);
    }

    function _buyerRevertTradeStatus(uint256 productID) internal {
        address _buyer = allProducts[productID].buyer;
        require(msg.sender == _buyer, "Not_Found" );
        hasBuyerTick[productID].hasBuyerTick = 1;
        _contractTransfer(allProducts[productID].token, allProducts[productID].seller, allProducts[productID].amount);
        allProducts[productID].isCompleted = true;
        emit BuyerRevertSaleStatus(productID, msg.sender, block.timestamp);
    }

    function _cancelTrx(uint256 productID) internal {
        address seller = allProducts[productID].seller;
        require(msg.sender == seller, "Not_Found" );
        if (
            msg.sender == seller && 
            hasBuyerTick[productID].hasBuyerTick == 0 && 
            block.timestamp > allProducts[productID].startSales + sellerClaimTime
            ) {
                allProducts[productID].isCompleted = true;
                _contractTransfer(allProducts[productID].token, seller, allProducts[productID].amount);
                emit BuyerCancelledTrade(productID, msg.sender, true, block.timestamp);
        } else {
            revert InvalidCallTime();
        }
    }

    /** @notice getPercentageForPointZeroes give access to be able to get the percentage of an `amount`
     * for values and supports decimal numbers too.
     * @dev Returns the `percentage` of the input `amount`.
     * @param amount The `amount` you want to get the percent from.
     * @param percentage The `percentage` you want to derive from the `amount` inputed
     * 1% = 10 why 100% = 1000
     */ 
    function getPercentageForPointZeroes(uint256 amount, uint256 percentage) internal pure returns(uint256) {
        return (amount * percentage) / 1000;
    }

    function _initializedDispute(
        uint256 unlistedDisputeTokensForSeller,
        uint256 unlistedDisputeTokensForBuyer,
        uint256 defaultWrongVote,
        uint256 _pendingTime,
        uint256 _sellerClaimTime
    ) internal {
        defaultDisputeFeeUnlistedTokensBuyer = unlistedDisputeTokensForBuyer;
        defaultDisputeFeeUnlistedTokensSeller = unlistedDisputeTokensForSeller;
        defaultFeeForWrongVotes= defaultWrongVote;
        pendingTime = _pendingTime;
        sellerClaimTime = _sellerClaimTime;
    }

    function _initializedBuyAndSellFee(uint256 sellersFeeInRGP, uint256 unListedTokenRewardPercent) internal {
        sellerFee = sellersFeeInRGP;
        unlistedTokenFees = unListedTokenRewardPercent;
        emit initBuyAndSellFee(sellersFeeInRGP, unListedTokenRewardPercent);
    }

    function _initializedWhitelisted(uint256 unWhitelistedAddressReferralFeeInPercent) internal {
        refWithoutWhitelistPercent = unWhitelistedAddressReferralFeeInPercent;
        emit initWhitelist(unWhitelistedAddressReferralFeeInPercent);
    }

    function _specialAddresses(address account, uint256 percentageValue, bool status) internal {
        refWhitelist[account] = status;
        refSpecialWhitelist[account] = percentageValue;
    }

    function _setBuyersFeeForAToken(address token, uint256 fee) internal {
        buyer[token] = fee;
    }

    function getTokenFeeForBuyer(address _asset) external view returns(uint256) {
        return _getTokenFeeForBuyer(_asset);
    }

    function _getTokenFeeForBuyer(address _asset) internal view returns(uint256) {
        if (buyer[_asset] != 0) {
            return buyer[_asset];
        } else {
            return unlistedTokenFees;
        }
    }

    function _getAssetPriceOnDispute(address asset) internal view returns(TokenDetails memory tD) {
        tD = tokenDetails[asset];
    }

    function _sellerFeeDebit(address from) internal {
        _merchantChargesDibited(from, sellerFee);
    }

    function _merchantChargesDibited(address from, uint256 amount) internal {
        IERC20(RGP).transferFrom(from, address(this), amount); 
    }

    function _contractTransfer(address token, address user, uint256 amount) internal {
        IERC20(token).transfer(user, amount); 
    }

    function _transferAndEmit(uint256 productID, address to, uint256 remnant,uint256 subGas) internal {
        address s_token = allProducts[productID].token;
        _contractTransfer(s_token, to, remnant);
        emit Buy(to, allProducts[productID].seller, s_token, subGas, productID, block.timestamp);
    }


    function devReward(address token, uint256 amount) internal {
        _contractTransfer(token, devAddress, amount); 
    }


    function _setTokenPrice(uint256 _tradeAmount, bytes memory _ranks, address _asset, uint256 _sellerFee, uint256 buyesFee) internal {
        TokenDetails memory _tokenDetails = TokenDetails(_tradeAmount, _ranks, _sellerFee, buyesFee);
        tokenDetails[_asset] = _tokenDetails;
        isAdded[_asset] = true;
    }

    function _getGas(address purchaseToken, uint256 _howMuch) internal view returns(uint256 _gas, uint256 rem) {
        uint256 subGas;
        uint256 gas = buyer[purchaseToken];
        uint256 remnant;
        if (gas == 0) {
            subGas = getPercentageForPointZeroes(_howMuch,unlistedTokenFees);
            remnant = _howMuch - subGas;
        } else {
            remnant =  _howMuch - gas;
            subGas = gas;
        }
        return(subGas, remnant);
    }

    function _isForBuyerOrSeller(uint256 productID, address who) internal  returns(bool forBuyer){
        address seller = allProducts[productID].seller;
        address _buyer = allProducts[productID].buyer;
        require(who == seller || who == _buyer, "Not_Found" );
        if (seller == who) {
            forBuyer = false;
        } else  {          
            forBuyer = true;
        }
        allProducts[productID].isOnDispute = true;
    }

    function _getDisputeFees(uint256 _amountBeenTraded, address token) internal view returns(
        uint256 buyersDisputeFee, 
        uint256 sellerDisputeFee, 
        uint256 wrongVote) {

        if(isAdded[token]) {
            (
                ,,, ,, wrongVote
            ) = IStakeRIgel(RGPStake).getSetsBadgeForMerchant(tokenDetails[token].rank);
            buyersDisputeFee = tokenDetails[token].buyerFee;
            sellerDisputeFee = tokenDetails[token].sellerFee;
        }else {
            buyersDisputeFee = getPercentageForPointZeroes(_amountBeenTraded,defaultDisputeFeeUnlistedTokensBuyer);
            sellerDisputeFee = getPercentageForPointZeroes(_amountBeenTraded,defaultDisputeFeeUnlistedTokensSeller);
            wrongVote = getPercentageForPointZeroes(_amountBeenTraded,defaultFeeForWrongVotes);
        }
    }

    function _sortRewards(address from, address referral) internal {
        address getWhoReferredSeller = whoIreferred[from];
        uint256 refShare = getPercentageForPointZeroes(sellerFee, refWithoutWhitelistPercent);
        _settleBuyReferralRewards(sellerFee, refShare, from, referral, getWhoReferredSeller);
    }


    function _settleBuyReferralRewards(uint256 s_seller, uint256 isRefRew, address from,  address referral, address getWhoReferredReferral) internal {
        uint256 refShare;  
        if (referral != address(0)) {
            hasBeenReferred[referral] = true;
            whoIreferred[referral] = from;
            if(!refWhitelist[referral]) {
                refShare = getPercentageForPointZeroes(s_seller, refWithoutWhitelistPercent);
                _contractTransfer(RGP, referral, refShare);  
            } else {
                uint256 specialReferral = refSpecialWhitelist[referral];
                refShare = getPercentageForPointZeroes(s_seller, specialReferral);
                _contractTransfer(RGP, referral, refShare); 
                
            }
        }
        if (getWhoReferredReferral != address(0)) {
            devReward(RGP, (s_seller - (refShare + isRefRew)));
            _contractTransfer(RGP, getWhoReferredReferral, isRefRew); 
        } else {_contractTransfer(RGP, devAddress, (s_seller - (refShare)));  }
        
    }

    function _check(uint256 productID, address purchaseToken) internal view {
        if (purchaseToken != allProducts[productID].token)  revert Invalid_Token();
        if (allProducts[productID].isOnDispute)  revert Product_On_Dispute(); 
    }

    function _updateBuy(uint256 productID) internal returns(uint256 subGas,uint256 remnant, address to) {

        allProducts[productID].isCompleted = true;
        allProducts[productID].endSales = uint128(block.timestamp);

        ( subGas, remnant) = _getGas(allProducts[productID].token, allProducts[productID].amount);
        return(subGas, remnant, allProducts[productID].buyer);
    }

    function _settleSellReferralRewards(IERC20 purchaseToken, uint256 subGas, address to,  address referral) internal {
        uint256 refShare; 
        address getWhoReferredBuyer = whoIreferred[to];

        uint256 isRefRew = getPercentageForPointZeroes(subGas, refWithoutWhitelistPercent);
        if (referral != address(0)) {
            hasBeenReferred[referral] = true;
            whoIreferred[referral] = to;
            if(!refWhitelist[referral]) {
                refShare = isRefRew;
                _contractTransfer(address(purchaseToken), referral, refShare);  
            } else {
                uint256 specialReferral = refSpecialWhitelist[referral];
                refShare = getPercentageForPointZeroes(subGas, specialReferral);
                _contractTransfer(address(purchaseToken), referral, refShare);                 
            }
        }
        if (getWhoReferredBuyer != address(0)) {
            _contractTransfer(address(purchaseToken), getWhoReferredBuyer, isRefRew);
            devReward(address(purchaseToken), (subGas - (refShare + isRefRew)));
        } else {
            devReward(address(purchaseToken), (subGas - refShare));
        }        
    }

    // Dispute section

    function _whenBuyersIsOnDispute(uint256 productID) internal {
        address s_token = allProducts[productID].token;
        address who = allProducts[productID].buyer;
        address _seller = allProducts[productID].seller;
        uint256 s_amount = allProducts[productID].amount;
        (uint256 buyersDisputeFee, ,)= _getDisputeFees( s_amount, s_token); 

        allProducts[productID].amount = (s_amount - buyersDisputeFee);
        _isOnDispute(
            who, 
            _seller, 
            s_token, 
            productID, 
            allProducts[productID].amount, 
            buyersDisputeFee, 
            beforeVotesStart
        );
        emit dispute(who, _seller, s_token, s_amount, productID, block.timestamp);
    }

    function _sellerIsOnDispute(uint256 productID) internal {
        address s_token = allProducts[productID].token;
        address who = allProducts[productID].seller;
        address _buyer = allProducts[productID].buyer;
        uint256 s_amount = allProducts[productID].amount;
        (,uint256 sellerDisputeFee,)= _getDisputeFees( s_amount, s_token); 

        _merchantChargesDibited(who, sellerDisputeFee); 
        _isOnDispute(
            who, 
            _buyer, 
            s_token, 
            productID, 
            s_amount, 
            sellerDisputeFee, 
            beforeVotesStart
        );
        emit dispute(who, _buyer, s_token, s_amount, productID, block.timestamp);
    }

    function _userRankQualification(uint256 productID) internal view {
        (
            uint256 _max
        ) = IStakeRIgel(RGPStake).getMyRank(msg.sender);

        if(_max < allProducts[productID].amount) revert Not_Qualify();    
    }

    
    function _updateAndEmit(uint256 productID) internal {
        store[msg.sender].isResolving = true;
        store[msg.sender].joined ++;

        uint256 lent =  joinMembers[productID].length();

        if ((lent + 1) > maxNumbersofCouncils) {

            if (block.timestamp < raisedDispute[productID].votesEnded) revert VoteCommence();

            if (tips[productID].qualified == address(0)) {
                for (uint256 i; i < (lent); ) {
                    address joinnedUser =  joinMembers[productID].get(i);
                    if (!_checkIfAccountHasVote(productID, joinnedUser)) {
                        if (store[joinnedUser].joined == 0) {
                            store[joinnedUser].isResolving = false;
                        }
                        store[joinnedUser].joined --;
                        if(!joinMembers[productID].remove(joinnedUser)) revert UnableToRemove();
                    }
                    unchecked {
                        i++;
                    }
                }
            } else {
                revert Permission_Denied();
            }
        } 
        if (joinMembers[productID].length() < maxNumbersofCouncils) {
            if(!joinMembers[productID].add(msg.sender)) revert UnableToAdd();
        }

        if (joinMembers[productID].length() == maxNumbersofCouncils) {
            raisedDispute[productID].votesEnded = block.timestamp + votingEllapseTime;
        }
        emit JoinDispute(msg.sender, productID, 0);
    }

    function _checkIfAccountHasJoined(uint256 productID) internal view {
        if(joinMembers[productID].contains(msg.sender)) revert not_Permitted();
    }

    function _checkIfAccountHasVote(uint256 productID, address account) internal view returns(bool isTrue) {
        return hasVote[account][productID];
    }


    function _update(address user) internal {
        store[user].joined --;
        store[user].totalVotes ++;
        if (store[user].joined == 0) {
            store[user].isResolving = false;
        }
    }

    function _tip(uint256 productID, address who) internal {
        address s_token = allProducts[productID].token;       
        uint256 s_amount = allProducts[productID].amount;
        (, , uint256 wrongVotesFees)= _getDisputeFees(s_amount, s_token);  

        hasVote[msg.sender][productID] = true;
        require(who == raisedDispute[productID].who || who == raisedDispute[productID].against, "Not_A_Participant");

        if (!allProducts[productID].isOnDispute)  revert No_Dispute(); 
        if (raisedDispute[productID].votesEnded == 0)  revert Be_Patient();

        if (block.timestamp < uint256(raisedDispute[productID].votesCommence)) revert Be_Patient();

        if (tips[productID].qualified != address(0))  revert Tip_Met_Max_Amt(); 
        _updateTipForBuyerAndSeller(productID, who);

        address s_qualified = tips[productID].qualified;
        
        _chkLockStatus();
        uint256 _payment = raisedDispute[productID].payment;

        if(s_qualified != address(0)) {  
            raisedDispute[productID].votesEnded = block.timestamp;
            _contractTransfer(s_token, s_qualified, s_amount);  
            uint256 _devReward = (_payment* 20) / 100;
            uint256 sharableRewards = (_payment * 80) / 100;

            devReward(s_token, _devReward);

            _l(productID, sharableRewards, wrongVotesFees, s_token, s_qualified);
        }
        emit councilVote(msg.sender, who, productID, 0, block.timestamp);
    }


    function _chkLockStatus() internal {
        (uint256 tLockCheck, uint256 pLockCheck) = _lockPeriod();
        if (store[msg.sender].totalVotes >= tLockCheck) {
            if (store[msg.sender].wrongVote >= pLockCheck) {
                store[msg.sender].isLocked = true;
                store[msg.sender].totalVotes = 0;
                store[msg.sender].wrongVote = 0;
            }else {
                store[msg.sender].totalVotes = 0;
                store[msg.sender].wrongVote = 0;
            }
        }
    }


    function _lockPeriod() internal view returns(uint256 tLockCheck, uint256 pLockCheck) {
        (tLockCheck, pLockCheck) = IStakeRIgel(RGPStake).getLockPeriodData();
    }

    function _l(uint256 productID, uint256 amountShared, uint256 fee,address token, address who) internal {       
        (address[] memory qua, address[] memory lst) = _cShare(productID, who);
        uint256 lent = qua.length;
        for (uint256 i; i < lent; ) {
            address cons = qua[i];
            if (cons != address(0)) {    
                membersSet[productID].push(cons);   
            }
            unchecked {
                i++;
            }
        }
        uint256 mem = membersSet[productID].length;
        for (uint256 j; j < mem; ) {
            uint256 forEach = amountShared / mem;
            address consM = membersSet[productID][j];
            _contractTransfer(token, consM, forEach); 
            store[consM].nextWithdrawalTime = block.timestamp + pendingTime;
            emit rewards(token,membersSet[productID] , amountShared, block.timestamp);
            unchecked {
                j++;
            }                
        }
        delete membersSet[productID];
        uint256 lstLength = lst.length;
        for (uint256 x; x < lstLength;) {
            address ls = lst[x];
            if (ls != address(0)) {
                store[ls].tFee4WrongVotes += fee;
                store[ls].wrongVote ++;
                store[ls].nextWithdrawalTime = block.timestamp + pendingTime;
            }
            unchecked {
                x++;
            } 
        }
        allProducts[productID].isCompleted = true;
        allProducts[productID].isOnDispute = false;
        allProducts[productID].endSales = uint128(block.timestamp);

    }

    function _cShare(uint256 productID, address who) internal view returns(address[] memory, address[] memory) {
        uint256 lenWho = tips[productID].whoITip.length;      
        address[] memory won = new address[](lenWho);
        address[] memory lost = new address[](lenWho);
        if (who != address(0)) {
            for (uint256 i; i < lenWho; ) {
                address l = tips[productID].whoITip[i];
                address c = tips[productID].tippers[i];
                if (l == who) {
                    won[i] = c;
                }
                 else if(l != who) {
                    lost[i] = c;
                }
                unchecked {
                    i++;
                }
            }
        }
        return (won, lost);        
    }

    function _updateTipForBuyerAndSeller(uint256 productID, address who) private {
        tips[productID].tippers.push(msg.sender);
        tips[productID].whoITip.push(who);
        if (who == allProducts[productID].buyer) {
            tips[productID].forBuyer++;
        }
        if (who == allProducts[productID].seller) {
            tips[productID].forSeller++;
        }
        uint256 div2 = joinMembers[productID].length() / 2;
        if (tips[productID].forBuyer >= (div2 + 1)) {
            tips[productID].qualified = who;
        } 
        if(tips[productID].forSeller >= (div2 + 1)) {
            tips[productID].qualified = who;
        }
    }

    function _cancelDebt(uint256 amount) internal {        
        
        store[msg.sender].tFee4WrongVotes -= amount;
        if (store[msg.sender].tFee4WrongVotes == 0) {
            store[msg.sender].isLocked = false;
        }
        emit CancelDebt(amount, msg.sender);
    }

    function _buyerAndSellerConsensus(uint256 productID,address who) internal {
        bool _who = _isForBuyerOrSeller(productID, who);
        allProducts[productID].isCompleted = true;
        allProducts[productID].endSales = uint128(block.timestamp);
        
        uint256 len = joinMembers[productID].length();
        uint256 s_amount = allProducts[productID].amount;
        address s_token = allProducts[productID].token;

        (uint256 buyersDisputeFee, uint256 sellerDisputeFee, ) = _getDisputeFees(s_amount, s_token);
        if (_who) {
            allProducts[productID].amount = (s_amount - buyersDisputeFee);
            uint256 forEach = buyersDisputeFee / len;
            if (len > 0) {
                for (uint256 i; i < len; ){
                    address voters = joinMembers[productID].get(i);
                    _update(voters);
                    _contractTransfer(s_token, voters, forEach);
                    unchecked {
                        i++;
                    }
                }
            }   
            _contractTransfer(s_token, who, allProducts[productID].amount);  
            emit rewards(s_token, joinMembers[productID].enumerate(), buyersDisputeFee, block.timestamp);         
        } else {
            _merchantChargesDibited(who, sellerDisputeFee);  
            uint256 forEach = sellerDisputeFee / len;           
            if (len > 0) {
                for (uint256 i; i < len; ) {
                    address voters = joinMembers[productID].get(i);
                    _update(voters);
                    _contractTransfer(RGP, voters, forEach);   
                    unchecked {
                        i++;
                    }     
                } 
            } 
            _contractTransfer(s_token, who, allProducts[productID].amount);  
            emit rewards(RGP, joinMembers[productID].enumerate(), sellerDisputeFee, block.timestamp);
        }
        allProducts[productID].isCompleted = true;
        allProducts[productID].isOnDispute = false;
        allProducts[productID].endSales = uint128(block.timestamp);
        raisedDispute[productID].isResolved = true;

        emit ResolveVotes(productID, 0, who);
    }

    function setStakeAddr(address rgpStake) external onlyOwner {
        RGPStake = rgpStake;
        emit SetStakeAddr(rgpStake);
    }
    
    function _stakeManagement(uint256 beforeVoteCommence, uint256 voteEllapseTime, uint256 numOfCouncils) internal {
        beforeVotesStart = beforeVoteCommence;
        votingEllapseTime = voteEllapseTime;
        maxNumbersofCouncils = numOfCouncils;
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
        DisputeRaised memory rDispute = DisputeRaised(
            who, against, token, false, amount, fee , block.timestamp, uint128(block.timestamp + _join), 0
        );
        raisedDispute[productID] = rDispute;
    }


    function isAssestAdded(address _asset) external view returns(bool _isAdded)  {
        _isAdded = isAdded[_asset];
    }

    function viewStateManagement() external view returns(uint256 , uint256 , uint256 ) {
        return (
            beforeVotesStart,
            votingEllapseTime,
            maxNumbersofCouncils
        );
    }

    function disputesPersonnel(address account ) external view returns(Store memory userInfo) {
        userInfo = store[account];
    }

    function getTotalUserLock(address account ) external view returns(bool, bool, uint256) {
        return(store[account].isResolving, store[account].isLocked, store[account].nextWithdrawalTime);
    }

    function productDetails(uint256 productID) external view returns (AllProducts memory all) {
        all = allProducts[productID];
    }

    function getDisputeRaised(uint256 productID) external view returns(DisputeRaised memory disputeRaise) {
        disputeRaise = raisedDispute[productID];
    }

    function getWhoIsleading(uint256 productID) external view returns(MembersTips memory, address[] memory) {
        return (tips[productID], joinMembers[productID].enumerate());
    }

    function rigelToken() external view returns(address) {        
        return RGP;
    }

    function dev() external view returns(address) {
        return devAddress;
    }

    function stakesContractAddress() external view returns(address) {
        return RGPStake;
    }

    function getSetRefPercent(address account) external view returns(uint256) {
        return refSpecialWhitelist[account];
    }

    function getAmountTradedOn(address _asset) external view returns(uint256) {
        return allTrade[_asset];
    }

    function hasBuyerConfirmed(uint256 productID) external view returns(uint256) {
        return hasBuyerTick[productID].hasBuyerTick;
    }


    function getUnlistedTokenChargePercent() external view returns(uint256) {
        return unlistedTokenFees;
    }

    /**
     * @dev Returns `uint256` the amount of RGP Merchant will pay through {makeBuyPurchase}.
     */
    function getFees() external view returns (uint256 _sellerFee, uint256 unwhitelistRef) {
        _sellerFee = sellerFee;
        unwhitelistRef = refWithoutWhitelistPercent;
    }

    function getTransactionID() external view returns (uint256) {
        return transactionID;
    }

    function blacklistStatus(address account) external view returns(bool) {
        return isBlacklisted[account];
    }

    function waitingTime() external view returns(uint256) {
        return pendingTime;
    }

    function getWhoReferredUser(address _user) external view returns(bool _referred, address who) {
        return (hasBeenReferred[_user], whoIreferred[_user]);
    }

    function checkIfWhitelisted(address user) external view returns(bool) {
        return refWhitelist[user];
    }

    function getVaultAddress() external view returns(address) {
        return vaultAddress;
    }

    function getSellerClaimTime() external view returns(uint256) {
        return sellerClaimTime;
    }

}

abstract contract Rigelp2pPriceSet is Storage {

    constructor (address _dev, address save, address rgpToken) Storage(_dev, save, rgpToken) {}


    function setAssetPriceForDisputes(
        address _asset, 
        uint256[] calldata _tadeAmount, 
        bytes[] calldata _ranks, 
        uint256[] calldata sellerFee, 
        uint256[] calldata buyerFee
    ) external onlyOwner {
        uint256 lent = _tadeAmount.length;
        if (
            lent != _ranks.length &&
            sellerFee.length != buyerFee.length
        ) revert invalidLength();
        for (uint256 i; i < lent; ) {
            _setTokenPrice(_tadeAmount[i], _ranks[i], _asset, sellerFee[i], buyerFee[i]);
            emit newAssetAdded(_asset, sellerFee[i], buyerFee[i]);
            unchecked {
                i++;
            }
        }
    }

    function setFeeForBuyers(address[] memory asset, uint256[] memory fee) external onlyOwner {
        uint256 lent = asset.length;
        if (lent != fee.length) revert invalidLength();
        for (uint256 i; i < lent; ) {
            _setBuyersFeeForAToken(asset[i], fee[i]);
            unchecked {
                i++;    
            }
        }
    }

    function initializedDispute(  
        uint256 unlistedDisputeTokensForSeller,
        uint256 unlistedDisputeTokensForBuyer,
        uint256 defaultWrongVote,
        uint256 _pendingTime,
        uint256 _sellerClaimTime
    )  external onlyOwner {        
        _initializedDispute(
            unlistedDisputeTokensForSeller,
            unlistedDisputeTokensForBuyer,
            defaultWrongVote,
            _pendingTime,
            _sellerClaimTime
        );
    }

    function initializedBuyAndSellFee(uint256 sellersFeeInRGP, uint256 unListedTokenRewardPercent) external onlyOwner {
        _initializedBuyAndSellFee(sellersFeeInRGP, unListedTokenRewardPercent);
    }

    function initializedWhitelisted(uint256 unWhitelistedAddressReferralFeeInPercent) external onlyOwner {
        _initializedWhitelisted(unWhitelistedAddressReferralFeeInPercent);
    }

    function setSpecialWhiteList(address[] memory accounts, uint256[] memory percent, bool status) external onlyOwner {
        uint256 len = accounts.length;
        if (len != percent.length) revert invalidLength();
        for(uint256 i = 0; i < len; ) {
            _specialAddresses(accounts[i], percent[i], status);
            emit SetWhiteList(accounts, status);
            unchecked {
                i++;
            }
        } 
    }

    function getBatchTokenFeeForBuyer(address[] memory _asset) external view returns(uint256[] memory _fee) {
        _fee = new uint256[](_asset.length);

        for ( uint256 i; i < _asset.length; ) {

            _fee[i] = _getTokenFeeForBuyer(_asset[i]);

            unchecked {
                i++;
            }
        }
        return _fee;
    }

    function getAssetPriceOnDispute(address asset) external view returns(TokenDetails memory _tokenDetails) {
        _tokenDetails = _getAssetPriceOnDispute(asset);
    }

}

contract RigelDecentralizedP2PSystem is Rigelp2pPriceSet {
    // ******************* //
    // *** CONSTRUCTOR *** //
    // ******************* //
    
    /** @notice Constructor. Links with RigelDecentralizedP2PSystem contract
     * @param _dev dev address;
     * @param rgpToken address of RGP token Contract;
    */
    constructor (address _dev, address save, address rgpToken) Rigelp2pPriceSet(_dev, save, rgpToken) {}

    // ********************************* //
    // *** EXTERNAL WRITE FUNCTIONS *** //
    // ******************************* //
    
    function makeSellOrder(IERC20 purchaseToken, uint256 amount, address from, address to, address referral) external returns(uint256){   
        isBlackListed(purchaseToken,  from, amount);
        uint256 amountInDecimals = getAmountInTokenDecimal(purchaseToken, amount);
        purchaseToken.transferFrom(from, address(this), amountInDecimals);
        _sellerFeeDebit(from);
        _sortRewards(from, referral);
        uint256 id = _storeProducts(address(purchaseToken), from, to, amountInDecimals);
        emit Buy(from, address(this), address(purchaseToken), amountInDecimals, id, block.timestamp);
        return id;

    }

   
    function completeBuyOrder(
        IERC20 purchaseToken,  
        uint256 productID, 
        address referral
    ) 
        external 
        onlyAdmin
        checkBlacklist(productID)
        completed(productID)
    {
        _check(productID, address(purchaseToken));
        (uint256 subGas, uint256 remnant, address to) = _updateBuy(productID);

        _settleSellReferralRewards(purchaseToken, subGas, to, referral);

        _transferAndEmit(productID, to, remnant, subGas);
    }

    function buyerRevertTradeStatus(uint256 productID) external completed(productID) invalid(productID) {
        _buyerRevertTradeStatus(productID);
    }

    function buyerConfirmTradeStatus(uint256 productID) external completed(productID) invalid(productID) {
        _buyerConfirmTradeStatus(productID);
    }

    function sellerRevertTrade(uint256 productID) external completed(productID) invalid(productID) {
        _cancelTrx(productID);
    }

    function raiseDispute(uint256 productID, address who) external onlyAdmin completed(productID) invalid(productID) {        
        bool _who = _isForBuyerOrSeller(productID, who);
        if (_who) {
            _whenBuyersIsOnDispute(productID);
        } else {
            _sellerIsOnDispute(productID);
        }
    }

    function resolveVotes(uint256 productID, address who) external onlyAdmin {
        _buyerAndSellerConsensus(productID, who);
    }

    function joinDispute(uint256 productID) external completed(productID) noPermit(productID){

        _checkIfAccountHasJoined(productID);
           
        _userRankQualification(productID);
        
        _updateAndEmit(productID);   
    }

    function cancelDebt(uint256 amount) external {       
        
        _merchantChargesDibited(_msgSender(), amount);

        _cancelDebt(amount);

    }

    function castVote(uint256 productID, address who) external {   
        _checkIfAccountHasJoined(productID);

        if ((_checkIfAccountHasVote(productID, _msgSender()))) revert Already_voted(); 
        
        _update(_msgSender());       
        _tip(productID, who);
        emit CastVote(productID, 0, who);
    }

    function blackList(address account, bool status) external onlyOwner {
        _blacklisted(account, status);
    }

    // ****************************** //
    // *** PUBLIC VIEW FUNCTIONS *** //
    // **************************** //
    function getDisputeFees(uint256 _amountBeenTraded, address token) public view returns(
        uint256 buyersDisputeFee, 
        uint256 sellerDisputeFee, 
        uint256 wrongVote) {

        (buyersDisputeFee, sellerDisputeFee, wrongVote) = _getDisputeFees(_amountBeenTraded, token);
    }

    function getAmountInTokenDecimal(IERC20 purchaseToken, uint256 amount) private view returns (uint256 tDecimals) {
        tDecimals = amount * 10**purchaseToken.decimals();
    }

    // ******************************** //
    // *** EXTERNAL VIEW FUNCTIONS *** //
    // ****************************** //

    function iVoted(uint256 productID, address account) external view returns(bool isTrue) {
        isTrue = _checkIfAccountHasVote(productID, account);
    }

    function multipleAdmin(address[] calldata _adminAddress, bool status) external onlyOwner {
        uint256 lent = _adminAddress.length;
        if (status == true) {
           for(uint256 i; i < lent; ) {
                _adminSet(_adminAddress[i], status);
                unchecked {
                    i++;
                }
            } 
            emit MultipleAdmin(_adminAddress, status);
        } else{
            for(uint256 i; i < lent; ) {
                _adminSet(_adminAddress[i], false);
                unchecked {
                    i++;
                }
            }
        }
        emit MultipleAdmin(_adminAddress, status);
    }
    
    function stakeManagement(uint256 beforeVoteCommence, uint256 voteEllapseTime, uint256 numOfCouncils) external onlyOwner {
        _stakeManagement(beforeVoteCommence, voteEllapseTime,numOfCouncils);
    }

    receive() external payable{}

    function emmergencyWithdrawalOfETH(uint256 amount) external onlyOwner{
        payable(owner()).transfer(amount);
        emit EmmergencyWithdrawalOfETH(amount);
    }

    function withdrawTokenFromContract(address tokenAddress, uint256 _amount, address _receiver) external onlyOwner {
        IERC20(tokenAddress).transferFrom(address(this),_receiver, _amount);
    }

}