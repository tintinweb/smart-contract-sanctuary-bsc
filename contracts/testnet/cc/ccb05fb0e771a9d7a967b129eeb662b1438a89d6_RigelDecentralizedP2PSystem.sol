/**
 *Submitted for verification at BscScan.com on 2022-05-04
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

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
    
    mapping(address => bool) public isAdminAddress;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
        isAdminAddress[_msgSender()] = true;
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

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface rigelStruct {

    /** @dev Struct that stores buyers data 
	 * @param buyer the buyer 
	 * @param seller the seller 
	 * @param token purchase token
     * @param status status of transaction
	 * @param amount amount of token purchase 
	 * @param time purchase time  
	 */	
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
	struct DisputeRank {
		address[] NFTaddresses;        
        string[] mustHaveNFTID;
		uint256 pairTokenID; 
		uint256 pairTokenAmountToStake;
        uint256 merchantFeeToRaiseDispute;
        uint256 buyerFeeToRaiseDisputeNoDecimal;
		uint256 numbersOfCouncilMembers;
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
		uint256 amount;
		uint256 payment;
		uint256 ranks;
		uint256 time;
		bool 	isResolved;
	}

	/** @dev Struct For Counsil Members
	 * @param forBuyer How many Tips the buyer has accumulated 
	 * @param forSeller How many Tips the seller has accumulated 
     * @param tippers arrays of tippers
	 * @param whoITip arrays of whom Tippers tips
	 */	
	struct CounsilMembersTips {
		uint256 forBuyer;
		uint256 forSeller;
		address qualified;
		address[] tippers;
		address[] whoITip;
	}
}

interface IRigelDecentralizedP2PSystem is rigelStruct {

    /** @dev makeBuyPurchase access to a user
     * @param purchaseToken address of token contract address to check for approval
     * @param amount amount of the token to purchase by 'to' from 'from'
     * @param from address of the seller
     * @param to address of the buyer
     */ 
    function makeBuyPurchase(IERC20 purchaseToken, uint256 amount, address from, address to) external;

    /** @dev grant access to a user for the sell of token specified.
     * @param purchaseToken address of token contract address to check for approval
     * @param from address of the seller
     * @param productID the product id
     * @param fee provide gas fee must be less than minimum gas specified by owner
     */ 
    function makeSellPurchase(IERC20 purchaseToken, address from, uint256 productID, uint256 fee) external;

    /** @dev raiseDispute serve to ensure justice is raised for `who`.
     * Returns a boolean value indicating whether the operation succeeded.
     * @param rank parties to resolve dispute
     * @param productID the product id
     * @param who address of the seller
     * Emits a {dispute} event.
     */  
    function raiseDispute(uint256 rank, uint256 productID, address who) external;

    /** @dev Council Members can vote for `who` when a dispute has been raised.
    * Returns a boolean value indicating whether the operation succeeded.
     * @param rank parties to resolve dispute
     * @param productID the product id
     * @param indexedOf check dispute raised     
     * @param tokenIDOwned NFTs owned to qualify for dispute
     * @param who address of the seller
     * Emits a {councilVote} event.
     */ 
    function councilsMembersVote(uint256 rank, uint256 productID, uint256 indexedOf, uint256 tokenIDOwned, address who) external returns (bool);

    /** @dev isQualifiedWithNFTs is serve to check if `account` is qualified with `tokenID` to vote.
     * @param rank parties to resolve dispute
     * @param account address of council
     * @param tokenID NFTs owned to qualify for dispute
     */
    function isQualifiedWithNFTs(uint256 rank, address account, uint256 tokenID) external view returns(bool whatIhave);

    /** @dev isQualifiedWithNFTs is serve to check if `account` is qualified with `tokenID` to vote.
     * @param productID parties to resolve dispute
     * @param account address of council
     */
    function iVoted(uint256 productID, address account) external view returns(bool isTrue);

    /** @dev isQualifiedWithAmountStaked is serve to check if `account` is qualified with `tokenID` to vote.
     * @param rank parties to resolve dispute
     * @param account address of council
     */ 
    function isQualifiedWithAmountStaked(uint256 rank, address account) external view returns(bool isTrue);

    /** @dev checkAmountStaked is serve to check the amount `account` staded of a `pid`.
     * @param account address of council.
     * @param pid check masterChef contract
     */ 
    function checkAmountStaked(address account, uint256 pid) external view returns(uint256 amountStaked);

    /**
     * @dev Returns the amount in token decimals
     */
    function getAmountInDecimalsOfToken(IERC20 token, uint256 amount) external view returns(uint256);

    /**
     * @dev Returns the details on how council Members are voting
     */
    function getWhoIsleading(uint256 productID) external view returns(CounsilMembersTips memory tip);

    /**
     * @dev Returns `uint256` accummulated balance of CouncilMember;
     */
    function getCouncilMemberBalance(address account) external view returns(uint256);

    /**
     * @dev Returns the data for an ID on sales if exist
     */
    function getBuyersInfor(address _seller, uint256 productID) external view returns(SellProduct memory sales);

    /**
     * @dev Returns the data for an ID on sales if exist
     */
    function getSellersInfor(address _seller, uint256 productID) external view returns(BuyProduct memory buys);

    /**
     * @dev Returns the data for an ID on sales if exist
     */
    function productDetails(uint256 productID) external view returns(AllProducts memory all);

    /**
     * @dev Returns the on the level of Dispute
     */
    function getDisputRanks(uint256 level) external view returns(DisputeRank memory disputes);

    /**
     * @dev Returns information about disputes raised
     */
    function getDisputeRaised(uint256 rank, uint256 indexedID) external view returns(DisputeRaised memory disputeRaise);

    /**
     * @dev Returns the remaining number of `IERC20 token` that `address(this)` will be
     * allowed to spend on behalf of `user` through {makeBuyPurchase}. This is
     * zero by default.
     *
     * This value changes when {approve} or {makeBuyPurchase} are called.
     */
    function getUserTokenAllowance(IERC20 token, address user) external view returns (uint256);

    /**
     * @dev Returns the remaining number of `RGP` that `address(this)` will be
     * allowed to spend on behalf of `Merchant` through {makeBuyPurchase}. This is
     * zero by default.
     *
     * This value changes when {approve} or {makeBuyPurchase} are called.
     */
    function getUserRGPAllowance(address user) external view returns (uint256);

    /**
     * @dev Returns the amount of `IERC20 token` owned by `user`.
     */
    function getUserTokenBalance(IERC20 token, address user) external view returns (uint256);

    /**
     * @dev Returns the amount of RGP Merchant will pay through {makeBuyPurchase}.
     */
    function getMerchantProcessingFee() external view returns (uint256);

    /**
     * @dev Returns the amount of gas fee that will be debited from Buyer through {makeSellPurchase}.
     */
    function getbuyersFee() external view returns (uint256);

    /**
     * @dev Returns the current ID of all transactions increemental through {makeBuyPurchase}.
     */
    function getTransactionID() external view returns (uint256);

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
    event councilVote(address indexed councilMember, address indexed who, uint256 rank, uint256 productID, uint256 indexedOfID, uint256 time);   
}
/**
 * @dev silently declare mapping for the products on Rigel's Protocol Decentralized P2P network
 */
abstract contract rigelMapped is IRigelDecentralizedP2PSystem {
    mapping(address => BuyProduct[]) internal buyProduct;
    mapping(address => SellProduct[]) internal sellProduct;
    mapping(uint256 => AllProducts) internal allProducts;
    mapping(uint256 => DisputeRank) internal disputeRanks;    
    mapping(uint256 => CounsilMembersTips) internal tips;
    mapping(uint256 => DisputeRaised[]) internal raisedDispute;
    mapping(address => uint256) internal councilBalance;
    mapping(uint256 => mapping(address => uint256)) internal votes;
}

interface IMasterChef {
    function userInfo(uint256 pid, address user) external view returns(uint256 amount, uint256 rewardDebt); 
}

interface IERC1155 {
    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function setUri(uint256 id) external view returns (string memory);
}

contract RigelDecentralizedP2PSystem is Ownable, rigelMapped  {
    uint256 private MerchantProcessingFee;
    uint256 private buyersFee;
    uint256 private transactionID;
    IERC20 public RGP;
    IMasterChef public MasterChef;
    address public devAddress;

    /** @dev Constructor. Links with RigelDecentralizedP2PSystem contract
	 * @param _buyersFee this fee should not be included with decimals;
     * @param _merchantProcessingFee should be included with decimals as this is the fee paid in RGP token;
     * @param rgpToken address of RGP token Contract;
	 */
    constructor(uint256 _buyersFee, uint256 _merchantProcessingFee, address rgpToken, address _masterChefContract) {
        MerchantProcessingFee = _merchantProcessingFee;
        buyersFee = _buyersFee;
        MasterChef = IMasterChef(_masterChefContract);
        RGP = IERC20(rgpToken);
        devAddress = _msgSender();
    }

    function addDisputeRanks(
        uint256 rank,
        uint256 stakedTokenPID,
        uint256 mustStakedAmount,
        uint256 merchantDisputeFee,
        uint256 buyerDisputeFeeNoDecimal,
        uint256 howManyCouncilMembers,
        string[] memory mustHaveNFTIDs,
        address[] memory contractAddressOfNFTs
        ) external onlyAdmin 
    {
        DisputeRank storage disRanks = disputeRanks[rank];
        disRanks.NFTaddresses = contractAddressOfNFTs;
        disRanks.mustHaveNFTID = mustHaveNFTIDs;
        disRanks.pairTokenID = stakedTokenPID;
        disRanks.pairTokenAmountToStake = mustStakedAmount;
        disRanks.merchantFeeToRaiseDispute = merchantDisputeFee;
        disRanks.buyerFeeToRaiseDisputeNoDecimal = buyerDisputeFeeNoDecimal;
        disRanks.numbersOfCouncilMembers = howManyCouncilMembers;
    }

    /** @dev makeBuyPurchase access to a user
     * @param purchaseToken address of token contract address to check for approval
     * @param amount amount of the token to purchase by 'to' from 'from'
     * @param from address of the seller
     * @param to address of the buyer
     */ 
    function makeBuyPurchase(IERC20 purchaseToken, uint256 amount, address from, address to) external {        
        uint256 tokenBalance = getUserTokenBalance(purchaseToken, from);        
        uint256 id = _id();
        uint256 tDecimals = _tDecimals(purchaseToken, amount);
        _chkRGPAllowForGas(from, MerchantProcessingFee);
        _chkTokenAllowForGas(purchaseToken, from, amount);       
        require(tokenBalance >= tDecimals, "Rigel's Protocol: Balance of 'from' is less than amount to sell" );
        _merchantChargesDibited(from, MerchantProcessingFee);
        require(purchaseToken.transferFrom(from, address(this), tDecimals), "Rigel's Protocol: Unable to withdraw from 'from' address");
        SellProduct memory _prod = SellProduct(to, from, address(purchaseToken), tDecimals, id, block.timestamp);
        sellProduct[from].push(_prod);
        allProducts[id] =  AllProducts(to, from, address(purchaseToken), tDecimals, id, block.timestamp, 0, false, false);
        emit Buy(from, to, address(purchaseToken), amount, id, block.timestamp);
    }

    /** @dev grant access to a user for the sell of token specified.
     * @param purchaseToken address of token contract address to check for approval
     * @param from address of the seller
     * @param productID the product id
     * @param fee provide gas fee must be less than minimum gas specified by owner
     */ 
    function makeSellPurchase(IERC20 purchaseToken, address from, uint256 productID, uint256 fee) external onlyAdmin{
        SellProduct storage sales = sellProduct[from][productID];
        AllProducts storage all = allProducts[productID];
        require(address(purchaseToken) == sales.token, "Rigel's Protocol: Token Specify is not valid with ID");
        require(!all.isCompleted, "Rigel's Protocol: Transaction has been completed ");
        require(!all.isOnDispute, "Rigel's Protocol: This Product is on dispute");
        require(fee >= buyersFee, "Rigel's Protocol: Amount Secify for gas is less than min fee");
        uint256 bFee = _tDecimals(purchaseToken, fee);
        uint256 subGas = (sales.amount) - bFee;
        all.isCompleted = true;
        all.endSales = block.timestamp;
        BuyProduct memory _prod = BuyProduct(sales.buyer, from, sales.token, sales.amount, block.timestamp);
        buyProduct[sales.buyer].push(_prod);
        IERC20(sales.token).transfer( sales.buyer, subGas);
        emit Buy(sales.buyer, from, sales.token, subGas, productID, block.timestamp);
    }

    function _id() internal returns(uint256) {
        return transactionID++;
    }

    /** @dev raiseDispute serve to ensure justice is raised for `who`.
     * Returns a boolean value indicating whether the operation succeeded.
     * @param rank parties to resolve dispute
     * @param productID the product id
     * @param who address of the seller
     * Emits a {dispute} event.
     */ 
    function raiseDispute(uint256 rank, uint256 productID, address who) external {
        bool canIProceed;
        AllProducts memory all = allProducts[productID];
        require(!all.isOnDispute, "Rigel's Protocol: Dispute already raised for this Product");
        require(productID <= transactionID, "Rigel's Protocol: Invalid Product ID");
        if(isAdminAddress[_msgSender()] == true) {
            canIProceed = true;
        }else {
            require(who == _msgSender(), "Rigel's Protocol: You don't have permission to raise a dispute for `who` ");
            canIProceed = true;
        }
        require(!all.isCompleted, "Rigel's Protocol: Transaction has been completed ");
        if(canIProceed == true) {
            if (all.seller == who) {
                _isRaisedForSeller(who, rank, productID);
            } else if(all.buyer == who) {                
                _isRaisedForBuyer(who, rank, productID);
            }
            all.isOnDispute = true;
        } else{
            return;
        }
    }

    /** @dev Council Members can vote for `who` when a dispute has been raised.
     * Returns a boolean value indicating whether the operation succeeded.
     * @param rank parties to resolve dispute
     * @param productID the product id
     * @param indexedOf check dispute raised     
     * @param tokenIDOwned NFTs owned to qualify for dispute
     * @param who address of the seller
     * Emits a {councilVote} event.
     */ 
    function councilsMembersVote(uint256 rank, uint256 productID, uint256 indexedOf, uint256 tokenIDOwned, address who) external returns(bool) {
        AllProducts memory all = allProducts[productID];
        DisputeRaised memory disputeRaise = raisedDispute[rank][indexedOf];
        require(who == disputeRaise.who || who == disputeRaise.against, "Rigel's Protocol: `who` is not a participant");
        require(!(iVoted(productID, _msgSender())), "Rigel's Protocol: msg.sende has already voted for this `product ID` ");
        require(all.isOnDispute, "Rigel's Protocol: Dispute on this product doesn't Exist");        
        if (tokenIDOwned != 0) {
            require(isQualifiedWithNFTs(rank,_msgSender(), tokenIDOwned), "Rigel's Protocol: Not Qualified for this rank");
            _tip(rank, productID, indexedOf, who);
        } else if (tokenIDOwned == 0) {
            require(isQualifiedWithAmountStaked(rank, _msgSender()), "Rigel's Protocol: staked Amount is less than required Amount to qualify for this rank");
            _tip(rank, productID, indexedOf, who);
        }
        return true;
    }

    /** @dev isQualifiedWithNFTs is serve to check if `account` is qualified with `tokenID` to vote.
     * Returns a boolean value indicating if `account` has require `tokenID` on any NFT contract address
     * @param rank parties to resolve dispute
     * @param account address of council
     * @param tokenID NFTs owned to qualify for dispute
     */ 
    function isQualifiedWithNFTs(uint256 rank, address account, uint256 tokenID) public view returns(bool whatIhave) {
        DisputeRank memory disRanks = disputeRanks[rank];    
        uint256 len = disRanks.NFTaddresses.length; 
        for(uint256 i; i < len; i++) {
            uint256 bal = IERC1155(disRanks.NFTaddresses[i]).balanceOf(account, tokenID);
            if (bal != 0) {
                string memory set = IERC1155(disRanks.NFTaddresses[i]).setUri(tokenID);
                if (_internalCheck(set, disRanks.mustHaveNFTID[i])) {
                    whatIhave = true;
                    break;
                } else {
                    whatIhave = false;
                }
            } else {
                whatIhave = false;
            }
        }
    }

    /** @dev isQualifiedWithAmountStaked is serve to check if `account` is qualified with `tokenID` to vote.
     * Returns a boolean value indicating whether `account` is qualified on `rank` 
     * @param rank parties to resolve dispute
     * @param account address of council
     */ 
    function isQualifiedWithAmountStaked(uint256 rank, address account) public view returns(bool isTrue) {
        DisputeRank memory disRanks = disputeRanks[rank];
        uint256 myStakedToken = checkAmountStaked(account, disRanks.pairTokenID);
        if (myStakedToken >= disRanks.pairTokenAmountToStake) {
            isTrue = true; 
        } else { isTrue = false;}        
    }

    /** @dev checkAmountStaked is serve to check the amount `account` staded of a `pid`.
     * Returns a uint256 value indicating the amount `account` stake on `pid`
     * @param account address of council.
     * @param pid check masterChef contract
     */ 
    function checkAmountStaked(address account, uint256 pid) public view returns(uint256 amountStaked) {
        (amountStaked, ) = MasterChef.userInfo(pid, account);
    }

    function multipleAdmin(address[] calldata _adminAddress, bool status) external onlyOwner {
        if (status == true) {
           for(uint256 i = 0; i < _adminAddress.length; i++) {
            isAdminAddress[_adminAddress[i]] = status;
            } 
        } else{
            for(uint256 i = 0; i < _adminAddress.length; i++) {
                delete(isAdminAddress[_adminAddress[i]]);
            }
        }
    }

    /**
     * @dev Returns a boolean value indicating whether `account` has cast a vote in  `productID` 
     */
    function iVoted(uint256 productID, address account) public view returns(bool isTrue) {
        CounsilMembersTips memory tipMe = tips[productID];
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

    /**
     * @dev Returns `uint256` accummulated balance of CouncilMember;
     */
    function getCouncilMemberBalance(address account) external view returns(uint256) {
        return(councilBalance[account]);
    }

    /**
     * @dev Returns `uint256` the amount in token decimals
     */
    function getAmountInDecimalsOfToken(IERC20 token, uint256 amount) public view returns(uint256) {
        return (amount * 10**token.decimals());
    }

    /**
     * @dev Returns the details on how council Members are voting
     */
    function getWhoIsleading(uint256 productID) external view returns(CounsilMembersTips memory tip) {
        tip = tips[productID];
    }

    /**
     * @dev Returns the data for an ID on sales if exist
     */
    function getBuyersInfor(address _seller, uint256 productID) external view returns(SellProduct memory sales) {
        sales = sellProduct[_seller][productID];
    }

    /**
     * @dev Returns the data for an ID on sales if exist
     */
    function getSellersInfor(address _seller, uint256 productID) external view returns(BuyProduct memory buys) {
        buys = buyProduct[_seller][productID];
    }

    /**
     * @dev Returns the data for an ID on sales if exist
     */
    function productDetails(uint256 productID) external view returns (AllProducts memory all) {
        all = allProducts[productID];
    }

    /**
     * @dev Returns the on the level of Dispute
     */
    function getDisputRanks(uint256 level) external view returns(DisputeRank memory disputes) {
        disputes = disputeRanks[level];
    }

    /**
     * @dev Returns information about disputes raised for a `rank`
     */
    function getDisputeRaised(uint256 rank, uint256 indexedID) external view returns(DisputeRaised memory disputeRaise) {
        disputeRaise = raisedDispute[rank][indexedID];
    }

    /**
     * @dev Returns `uint256` the remaining number of `IERC20 token` that `address(this)` will be
     * allowed to spend on behalf of `user` through {makeBuyPurchase}. This is
     * zero by default.
     *
     * This value changes when {approve} or {makeBuyPurchase} are called.
     */
    function getUserTokenAllowance(IERC20 token, address user) public view returns (uint256) {
        return (token.allowance(user, address(this)));
    }

    /**
     * @dev Returns `uint256` the remaining number of `RGP` that `address(this)` will be
     * allowed to spend on behalf of `Merchant` through {makeBuyPurchase}. This is
     * zero by default.
     *
     * This value changes when {approve} or {makeBuyPurchase} are called.
     */
    function getUserRGPAllowance(address user) public view returns (uint256) {
        return (RGP.allowance(user, address(this)));
    }

    /**
     * @dev Returns `uint256` the amount of `IERC20 token` owned by `user`.
     */
    function getUserTokenBalance(IERC20 token, address user) public view returns (uint256) {
        return (token.balanceOf(user));
    }

    /**
     * @dev Returns `uint256` the amount of RGP Merchant will pay through {makeBuyPurchase}.
     */
    function getMerchantProcessingFee() external view returns (uint256) {
        return MerchantProcessingFee;
    }

    /**
     * @dev Returns the amount of gas fee that will be debited from Buyer through {makeSellPurchase}.
     */
    function getbuyersFee() external view returns (uint256) {
        return buyersFee;
    }

    /**
     * @dev Returns `uint256` the current ID of all transactions increemental through {makeBuyPurchase}.
     */
    function getTransactionID() external view returns (uint256) {
        return transactionID;
    }

    // Internal Functions.
    function _tip(uint256 rank, uint256 productID, uint256 indexedOf, address who) internal {        
        CounsilMembersTips storage tipMe = tips[productID];
        AllProducts memory all = allProducts[productID];
        DisputeRank memory disRanks = disputeRanks[rank];
        require(tipMe.qualified == address(0), "Rigel's Protocol: Max amount of require Tip Met.");
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
        uint256 num = disRanks.numbersOfCouncilMembers;
        uint256 div2 = num / 2 ;
        if (tipMe.forBuyer >= (div2 + 1)) {
            tipMe.qualified = who;
        } 
        if(tipMe.forSeller >= (div2 + 1)) {
            tipMe.qualified = who;
        }
        if(tipMe.qualified != address(0)) {            
            _cShare(productID, tipMe.qualified);
            _dst(rank, productID, tipMe.qualified);
        }
        emit councilVote(_msgSender(), who,rank , productID, indexedOf, block.timestamp);
    }

    function _dst(uint256 rank, uint256 productID, address who) internal {
        AllProducts memory all = allProducts[productID];
        DisputeRank memory ranks = disputeRanks[rank];
        uint256 devReward;
        uint256 sharableRewards;
        uint256 inDec = _tDecimals(IERC20(all.token), ranks.buyerFeeToRaiseDisputeNoDecimal);
        uint256 _tPercent = _tDecimals(IERC20(all.token), 20);
        uint256 _eiPercent = _tDecimals(IERC20(all.token), 80);
        uint256 _huPercent = _tDecimals(IERC20(all.token), 100);
        if(who == all.buyer) { 
            devReward = (inDec * _tPercent) / _huPercent;
            sharableRewards = (inDec * _eiPercent) / _huPercent;
        } else {
            devReward = (ranks.merchantFeeToRaiseDispute * 20E18) / 100E18;
            sharableRewards = (ranks.merchantFeeToRaiseDispute * 80E18) / 100E18;
        }
        councilBalance[devAddress] = councilBalance[devAddress] + devReward;  
        _l(productID, sharableRewards, who);
        
    }

    address[]  member;
    function _l(uint256 productID, uint256 amountShared, address who) internal {
        address[] memory qua = _cShare(productID, who);
        for (uint256 i; i < qua.length; i++) {
            address cons = qua[i];
            if (cons != address(0)) {       
                member.push(cons); 
            }
        }
        uint256 meme = member.length;
        for (uint256 j = 0; j < meme; j++) {
            uint256 forEach = amountShared / meme;
            address consM = member[j];
            councilBalance[consM] = councilBalance[consM] + forEach;
        }
        delete member;
    }

    function _cShare(uint256 productID, address who) internal view returns(address[] memory ) {
        CounsilMembersTips memory tipMe = tips[productID];
        uint256 lenWho = tipMe.whoITip.length;      
        address[] memory won = new address[](lenWho);
        address[] memory lost = new address[](lenWho);
        if (who != address(0)) {
            for (uint256 i; i < lenWho; i++ ) {
                address l = tipMe.whoITip[i];
                address c = tipMe.tippers[i];
                if (l == who) {
                    won[i] = c;
                } else if(l != who) {
                    lost[1] = c;
                }
            }
        }
        return won;        
    }
    
    function _internalCheck(string memory token1, string memory token2) internal pure returns(bool status) {
        if (keccak256(abi.encodePacked(token1)) == keccak256(abi.encodePacked(token2))) {
            status = true;
        } else {
            status =false;
        }
    }

    function _merchantChargesDibited(address from, uint256 amount) internal {
        require(RGP.transferFrom(from, address(this), amount), "Rigel's Protocol: Unable to withdraw gasFee from 'from' address");
    }

    function _tDecimals(IERC20 purchaseToken, uint256 amount) internal view returns (uint256 tDecimals) {
        tDecimals = getAmountInDecimalsOfToken(purchaseToken, amount);
    }

    function _chkTokenAllowForGas(IERC20 purchaseToken, address from, uint256 amount) internal view{
        uint256 tokenAllowed = getUserTokenAllowance(purchaseToken, from);
        uint256 tDecimals = _tDecimals(purchaseToken, amount);
        require(tokenAllowed >= tDecimals, "Rigel's Protocol: Amount approve to be spent is less than amount to sell" );
    }

    function _chkRGPAllowForGas(address from, uint256 amount) internal view {
        uint256 rgpAllowForGas = getUserRGPAllowance(from);
        require(rgpAllowForGas >= amount, "Rigel's Protocol: Fee Allow to process transaction is too low");
    }

    function _isRaisedForBuyer(address who, uint256 rank, uint256 productID) internal {
        AllProducts storage all = allProducts[productID];
        DisputeRank memory ranks = disputeRanks[productID];
        uint256 tDecimals = _tDecimals(IERC20(all.token), ranks.buyerFeeToRaiseDisputeNoDecimal);
        all.amount = (all.amount - tDecimals);
        all.isOnDispute = true;
        DisputeRaised memory rDispute = DisputeRaised(who, all.seller, all.token, all.amount, tDecimals , rank,  block.timestamp, false);
        raisedDispute[rank].push(rDispute);
        emit dispute(who, all.seller, all.token, all.amount, productID, block.timestamp);
    }

    function _isRaisedForSeller(address who, uint256 rank, uint256 productID) internal {
        AllProducts storage all = allProducts[productID];
        DisputeRank memory ranks = disputeRanks[productID];
        _chkRGPAllowForGas(who, ranks.merchantFeeToRaiseDispute);
        _merchantChargesDibited(who, ranks.merchantFeeToRaiseDispute);        
        all.isOnDispute = true;
        DisputeRaised memory rDispute = DisputeRaised(who, all.buyer, all.token, all.amount, ranks.merchantFeeToRaiseDispute, rank,  block.timestamp, false);
        raisedDispute[rank].push(rDispute);
        emit dispute(who, all.buyer, all.token, all.amount, productID, block.timestamp);
    }

    receive() external payable{}

    function emmergencyWithdrawalOfETH(uint256 amount) external onlyOwner{
        require(address(this).balance > amount, "Balance of contract is less than inPut amount");
        payable(owner()).transfer(amount);
    }

    function withdrawTokenFromContract(address tokenAddress, uint256 _amount, address _receiver) external onlyOwner {
        IERC20(tokenAddress).transfer(_receiver, _amount);
    }

}