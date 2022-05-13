/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

// File: node_modules\@openzeppelin\contracts\utils\introspection\IERC165.sol

// SPDX-License-Identifier: MIT
/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}


/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}

/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}

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
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address account, address operator) external view returns (bool);
}

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
struct DisputeRaised {
    address who;
    address against;
    address token;
    bytes 	badge;
    uint256 amount;
    uint256 payment;
    uint256 time;
    uint256 joinVote;
    uint256 startVote;
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
    address user;
    address NFT;
    bytes   Badge;
    uint256 TokenID;
    uint256 Amount;
    bool    isResolving;
    uint256 totalVotes;
    uint256 wrongVote;
    uint256 time;
}

struct Badge {
    bytes name;
    address[] tokenAddresses;
    uint256[] requireURI;
    uint256 StakeAmount;
    uint256 sellerFeeToRaiseDispute;
    uint256 buyerFeeToRaiseDisputeNoDecimal;
    uint256 numbersOfCouncilMembers;
    uint256 beforeJoin;
    uint256 beforeVote;
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
        mapping(uint256 => mapping(address => uint256))  votes;
        mapping(address => Store)  store;
        mapping(bytes => Badge)  badge; 
        address[]  member;
        address RGP;
        uint256  seller;
        uint256  buyersFee;
        uint256  transactionID;
        address  devAddress;
    }

    function diamondStorage() internal pure returns(libStorage storage ds) {
        bytes32 storagePosition = keccak256("Rigel Decentralized P2P System.");
        assembly {ds.slot := storagePosition}
    }

    function _UserStakeBadge( address user, bytes memory badge, uint256 amount) internal {
        libStorage storage ds = diamondStorage();
        Store storage userInfo = ds.store[user];
        userInfo.Badge = badge;
        userInfo.Amount = amount;
        userInfo.time = block.timestamp;
    }

    function _UserNFTBadge(address user, address tokenAddr, bytes calldata badge, uint256 tokenID) internal {
        libStorage storage ds = diamondStorage();
        Store storage userInfo = ds.store[user];
        userInfo.Badge = badge;
        userInfo.TokenID = tokenID;
        userInfo.NFT = tokenAddr;
        userInfo.time = block.timestamp;
    }

    // function CMVotesCounts(address user, bool wrong) internal {
    //     libStorage storage ds = diamondStorage();
    //     Store storage userInfo = ds.store[user];
    //     if (wrong) {
    //         userInfo.totalVotes ++;
    //         userInfo.wrongVote ++;
    //     } else {
    //         userInfo.totalVotes ++;
    //     }
    // }

    function _isOnDispute(
        address who, 
        address against, 
        address token, 
        bytes memory badge,
        uint256 productID,  
        uint256 amount, 
        uint256 fee,
        uint256 _join,
        uint256 _bfVote
    ) internal {
        libStorage storage ds = diamondStorage();
        DisputeRaised memory rDispute = DisputeRaised(
            who, against, token, badge, amount, fee , block.timestamp, block.timestamp + _join, block.timestamp + _bfVote, false
        );
        ds.raisedDispute[productID].push(rDispute);
    }
}

/**
 * @dev silently declare mapping for the products on Rigel's Protocol Decentralized P2P network
 */
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


pragma solidity 0.8.13;

contract councilMemberStakes is Ownable, ERC1155Holder, events {
    
    // function _setRGPAddress(address _rigelToken) internal {
    //     rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
    //     ds.RGP = _rigelToken;
    // }

    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, "Rigel's Protocol: Locked");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function setDisputeBadge(
        bytes calldata _name, 
        address[] memory tokenRequire, 
        uint256[] memory _uri,
        uint256 _stakeAmountRequire,
        uint256 _sellersFee, 
        uint256 _buyersFeeWithoutDecimal,
        uint256 daysBeforeJoining,
        uint256 daysBeforeVoting,
        uint256 minCouncilMembers
        ) external onlyOwner {            
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        Badge memory tradeMine = Badge(
            _name, 
            tokenRequire, 
            _uri,
            _stakeAmountRequire,
            _sellersFee, 
            _buyersFeeWithoutDecimal, 
            minCouncilMembers,
            daysBeforeJoining,
            daysBeforeVoting
        );
        ds.badge[_name] = tradeMine;
    }

    function earnBadgeWithStake(bytes calldata _badge, uint256 amount) external {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        Badge memory readDispute = ds.badge[_badge];
        require(amount >= readDispute.StakeAmount, "Rigel's Protocol: Amount too Low to Earn Badge.");
        IERC20(ds.RGP).transferFrom(_msgSender(), address(this), amount);
        rigelMapped._UserStakeBadge(_msgSender(), readDispute.name, amount);
        emit EarnBadge(readDispute.name, _msgSender(), amount, block.timestamp);
    }

    function looseStakeBadge() external lock{
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        Store storage userInfo = ds.store[_msgSender()];
        require(userInfo.Amount != 0, "Rigel's Protocol: You don't have any stake here.");
        require(!userInfo.isResolving, "Rigel's Protocol: You Current resolving dispute.");
        IERC20(ds.RGP).transfer(_msgSender(), userInfo.Amount);
        userInfo.Amount = 0;
        userInfo.time = block.timestamp;   
        emit EarnBadge(userInfo.Badge, _msgSender(), userInfo.Amount, userInfo.time);
    }
    
    function earnNFTBadge(bytes calldata _badge, uint256 tokenID) external {
        (bool wiH, address tokenAddr) = isQualifiedWithNFTs(_badge, _msgSender(), tokenID);
        require(wiH == true, "Rigel's Protocol: Can't stake token with Zero Balance.");
        require(tokenAddr != address(0), "Rigel's Protocol: Invalid own token.");
        IERC1155(tokenAddr).safeTransferFrom(_msgSender(), address(this), tokenID, 1, "");
        rigelMapped._UserNFTBadge(_msgSender(), tokenAddr, _badge, tokenID );
        emit EarnNFTBadge(_badge, _msgSender(), tokenID, block.timestamp);
    }

    function looseNFTBadge() external lock{
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        Store storage userInfo = ds.store[_msgSender()];
        require(!userInfo.isResolving, "Rigel's Protocol: You Current resolving dispute.");
        require(userInfo.TokenID != 0, "Rigel's Protocol: Invalid tokenID.");
        if (!(IERC1155(userInfo.NFT).isApprovedForAll(userInfo.NFT, address(this)))) {
            IERC1155(userInfo.NFT).setApprovalForAll(userInfo.NFT, true);
        }
        IERC1155(userInfo.NFT).safeTransferFrom(address(this), _msgSender(), userInfo.TokenID, 1, "");
        userInfo.NFT = address(0);
        userInfo.TokenID = 0;
        userInfo.time = block.timestamp;
    }

    function isQualifiedWithNFTs(bytes calldata _name, address account, uint256 tokenID) public view returns(bool whatIhave, address iHave) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        Badge memory tradeMine = ds.badge[_name]; 
        uint256 len = tradeMine.tokenAddresses.length; 
        uint256 lenID = tradeMine.requireURI.length;
        uint256 myID;
        for(uint256 i; i < lenID; i++) {
            if (tradeMine.requireURI[i] == tokenID) {
                myID = tradeMine.requireURI[i];
                break;
            } else {
                if(i == lenID - 1) {
                    return (false, address(0));
                }
            }
        }
        for(uint256 j; j < len; j++) {
            uint256 bal = IERC1155(tradeMine.tokenAddresses[j]).balanceOf(account, myID);
            if (bal != 0) {
                string memory set = IERC1155(tradeMine.tokenAddresses[j]).setUri(myID);
                string memory setURI = IERC1155(tradeMine.tokenAddresses[j]).setUri(tradeMine.requireURI[j]);
                if (_internalCheck(set, setURI )) {
                    whatIhave = true;
                    iHave = tradeMine.tokenAddresses[j];
                    break;
                } else {
                    whatIhave = false;
                    iHave = address(0);
                }
            } else {
                whatIhave = false;
                iHave = address(0);
            }
        }
    }

    function _internalCheck(string memory token1, string memory token2) internal pure returns(bool status) {
        if (keccak256(abi.encodePacked(token1)) == keccak256(abi.encodePacked(token2))) {
            status = true;
        } else {
            status =false;
        }
    }

    function getMemberBadge(address account) public view returns(Store memory trade) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        trade = ds.store[account];
    }
    
    function getSetsBadge(bytes memory _badge) external view returns(Badge memory trade) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        trade = ds.badge[_badge];
    }

}
contract RigelDecentralizedP2PSystem is councilMemberStakes {
    
    /** @dev Constructor. Links with RigelDecentralizedP2PSystem contract
	 * @param _buyersFee this fee should not be included with decimals;
     * @param _sellerProcessingFee should be included with decimals as this is the fee paid in RGP token;
     * @param rgpToken address of RGP token Contract;
	 */
    constructor(uint256 _buyersFee, uint256 _sellerProcessingFee, address rgpToken) {        
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        // _setRGPAddress(rgpToken);
        ds.RGP = rgpToken;
        ds.seller = _sellerProcessingFee;
        ds.buyersFee = _buyersFee;
        ds.devAddress = _msgSender();
    }

    /** @dev makeBuyPurchase access to a user
     * @param purchaseToken address of token contract address to check for approval
     * @param amount amount of the token to purchase by 'to' from 'from'
     * @param from address of the seller
     * @param to address of the buyer
     */ 
    function makeSellOrder(IERC20 purchaseToken, uint256 amount, address from, address to) external {   
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();     
        uint256 tokenBalance = purchaseToken.balanceOf(from);      
        uint256 id = ds.transactionID++;
        uint256 tDecimals = _tDecimals(purchaseToken, amount);  
        require(tokenBalance >= tDecimals, "Rigel's Protocol: Balance of 'from' is less than amount to sell" );
        _merchantChargesDibited(from, ds.seller);
        require(purchaseToken.transferFrom(from, address(this), tDecimals), "Rigel's Protocol: Unable to withdraw from 'from' address");
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
        require(address(purchaseToken) == sales.token, "Rigel's Protocol: Token Specify is not valid with ID");
        require(!all.isCompleted, "Rigel's Protocol: Transaction has been completed ");
        require(!all.isOnDispute, "Rigel's Protocol: This Product is on dispute");
        require(fee >= ds.buyersFee, "Rigel's Protocol: Amount Secify for gas is less than min fee");
        uint256 bFee = _tDecimals(purchaseToken, fee);
        uint256 subGas = (sales.amount) - bFee;
        all.isCompleted = true;
        all.endSales = block.timestamp;
        BuyProduct memory _prod = BuyProduct(sales.buyer, from, sales.token, sales.amount, block.timestamp);
        ds.buyProduct[sales.buyer].push(_prod);
        IERC20(sales.token).transfer( sales.buyer, subGas);
        emit Buy(sales.buyer, from, sales.token, subGas, productID, block.timestamp);
    }

    //....................................................................................................//

    /** @dev raiseDispute serve to ensure justice is raised for `who`.
     * Returns a boolean value indicating whether the operation succeeded.
     * @param resolveBadge parties to resolve dispute
     * @param productID the product id
     * @param who address of the seller
     * Emits a {dispute} event.
     */ 
    function raiseDispute(bytes calldata resolveBadge, uint256 productID, address who) external {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();      
        Badge memory fromBadge = ds.badge[resolveBadge]; 
        bool _who = isForBuyerOrSeller(productID, who);
        AllProducts memory all = ds.allProducts[productID];
        if (_who) {
            uint256 tDecimals = _tDecimals(IERC20(all.token), fromBadge.buyerFeeToRaiseDisputeNoDecimal);
            all.amount = (all.amount - tDecimals);
            rigelMapped._isOnDispute(
                who, 
                all.seller, 
                all.token, 
                fromBadge.name, 
                productID, 
                all.amount, 
                tDecimals, 
                fromBadge.beforeJoin, 
                fromBadge.beforeVote
            );
            emit dispute(who, all.seller, all.token, all.amount, productID, block.timestamp);
            // _isRaisedForBuyer(
            //     who, 
            //     fromBadge.name,
            //     productID,  
            //     fromBadge.buyerFeeToRaiseDisputeNoDecimal, 
            //     fromBadge.beforeJoin,
            //     fromBadge.beforeVote
            // );
        } else {
            _merchantChargesDibited(who, fromBadge.sellerFeeToRaiseDispute);   
            rigelMapped._isOnDispute( 
                who, 
                all.buyer, 
                all.token, 
                fromBadge.name,
                productID, 
                all.amount, 
                fromBadge.sellerFeeToRaiseDispute,
                fromBadge.beforeJoin, 
                fromBadge.beforeVote
            );
            emit dispute(who, all.buyer, all.token, all.amount, productID, block.timestamp);
            // _isRaisedForSeller(
            //     who, 
            //     fromBadge.name,
            //     productID,  
            //     fromBadge.sellerFeeToRaiseDispute, 
            //     fromBadge.beforeJoin,
            //     fromBadge.beforeVote
            // );
        }
    }
    //  function _isRaisedForBuyer( 
    //     address who, 
    //     bytes memory badge,
    //     uint256 productID,  
    //     uint256 fee, 
    //     uint256 _join,
    //     uint256 _beforeVote
    // ) internal {
    //     rigelMapped.libStorage storage ds = rigelMapped.diamondStorage(); 
    //     AllProducts storage all = ds.allProducts[productID];
    //     uint256 tDecimals = _tDecimals(IERC20(all.token), fee);
    //     all.amount = (all.amount - tDecimals);
    //     rigelMapped._isOnDispute(who, all.seller, all.token, badge,productID, all.amount, tDecimals, _join, _beforeVote);
    //     emit dispute(who, all.seller, all.token, all.amount, productID, block.timestamp);
    // }

    // function _isRaisedForSeller(
    //     address who, 
    //     bytes memory badge,
    //     uint256 productID,  
    //     uint256 fee, 
    //     uint256 _join,        
    //     uint256 _beforeVote
    // ) internal {
    //     rigelMapped.libStorage storage ds = rigelMapped.diamondStorage(); 
    //     AllProducts memory all = ds.allProducts[productID];
    //     _merchantChargesDibited(who, fee);   
    //     rigelMapped._isOnDispute( who, all.buyer, all.token, badge,productID, all.amount, fee, _join, _beforeVote);
    //     emit dispute(who, all.buyer, all.token, all.amount, productID, block.timestamp);
    // }

    function joinDispute(uint256 productID, uint256 indexedOf) external {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage(); 
        DisputeRaised memory disputeRaise = ds.raisedDispute[productID][indexedOf];
        Store storage myBadge = ds.store[_msgSender()];
        require(block.timestamp > disputeRaise.joinVote, "Rigel's Protocol: Patience is a Virtue");
        require(keccak256(abi.encodePacked(myBadge.Badge)) == keccak256(abi.encodePacked(disputeRaise.badge)),
            "Rigel's Protocol: Permission Denied, address not qualified for this `rank`"
        );
        MembersTips storage tipMe = ds.tips[productID];
        myBadge.isResolving = true;
        tipMe.joinedCouncilMembers.push(_msgSender());
    }
    
    function isForBuyerOrSeller(uint256 productID, address who) internal  returns(bool forBuyer){
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage(); 
        Context.context storage dc = Context.diamondContext();
        AllProducts storage all = ds.allProducts[productID];
        require(!all.isOnDispute, "Rigel's Protocol: Dispute already raised for this Product");
        require(!all.isCompleted, "Rigel's Protocol: Transaction has been completed ");  
        require(productID <= getTransactionID(), "Rigel's Protocol: Invalid Product ID");
        require(_msgSender() == all.seller || _msgSender() == all.buyer || dc.isAdminAddress[_msgSender()] == true,
         "Rigel's Protocol: You don't have permission to raise a dispute for `who` ");       
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
        require(haveRight, "Rigel's Protocol: You have No Right to vote ");
        require(!(iVoted(productID, _msgSender())), "Rigel's Protocol: msg.sende has already voted for this `product ID` ");
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

    function _tip(uint256 productID, uint256 indexedOf, address who) internal {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage(); 
        MembersTips storage tipMe = ds.tips[productID];
        AllProducts memory all = ds.allProducts[productID];
        DisputeRaised memory rDispute = ds.raisedDispute[productID][indexedOf];
        Badge memory _badge = ds.badge[rDispute.badge];
        require(who == rDispute.who || who == rDispute.against, "Rigel's Protocol: `who` is not a participant");
        require(all.isOnDispute, "Rigel's Protocol: Dispute on this product doesn't Exist");          
        require(tipMe.qualified == address(0), "Rigel's Protocol: Max amount of require Tip Met.");
        require(block.timestamp > rDispute.startVote, "Rigel's Protocol: Patience is a Virtue");
        if (block.timestamp > rDispute.startVote) {
            require(tipMe.joinedCouncilMembers.length >= _badge.numbersOfCouncilMembers, 
                "Rigel's Protocol: Minimum Council Members require for this vote not met"
            );
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
        uint256 num = _badge.numbersOfCouncilMembers;
        uint256 div2 = num / 2 ;
        if (tipMe.forBuyer >= (div2 + 1)) {
            tipMe.qualified = who;
        } 
        if(tipMe.forSeller >= (div2 + 1)) {
            tipMe.qualified = who;
        }
        if(tipMe.qualified != address(0)) {        
            // _dst(productID, indexedOf, tipMe.qualified);
            uint256 devReward;
            uint256 sharableRewards;
            uint256 _tPercent = _tDecimals(IERC20(all.token), 20);
            uint256 _eiPercent = _tDecimals(IERC20(all.token), 80);
            uint256 _huPercent = _tDecimals(IERC20(all.token), 100);
            if(tipMe.qualified == all.buyer) { 
                devReward = (rDispute.payment * _tPercent) / _huPercent;
                sharableRewards = (rDispute.payment * _eiPercent) / _huPercent;
            } else {
                devReward = (rDispute.payment * 20E18) / 100E18;
                sharableRewards = (rDispute.payment * 80E18) / 100E18;
            }
            ds.balance[ds.devAddress] = ds.balance[ds.devAddress] + devReward;  
            _l(productID, sharableRewards, tipMe.qualified);
        }
        emit councilVote(_msgSender(), who, rDispute.badge , productID, indexedOf, block.timestamp);
    }

    // function _dst( uint256 productID, uint256 indexedOf, address who) internal {
    //     rigelMapped.libStorage storage ds = rigelMapped.diamondStorage(); 
    //     AllProducts memory all = ds.allProducts[productID];
    //     DisputeRaised memory rDispute = ds.raisedDispute[productID][indexedOf];
    //     uint256 devReward;
    //     uint256 sharableRewards;
    //     uint256 _tPercent = _tDecimals(IERC20(all.token), 20);
    //     uint256 _eiPercent = _tDecimals(IERC20(all.token), 80);
    //     uint256 _huPercent = _tDecimals(IERC20(all.token), 100);
    //     if(who == all.buyer) { 
    //         devReward = (rDispute.payment * _tPercent) / _huPercent;
    //         sharableRewards = (rDispute.payment * _eiPercent) / _huPercent;
    //     } else {
    //         devReward = (rDispute.payment * 20E18) / 100E18;
    //         sharableRewards = (rDispute.payment * 80E18) / 100E18;
    //     }
    //     ds.balance[ds.devAddress] = ds.balance[ds.devAddress] + devReward;  
    //     _l(productID, sharableRewards, who);
        
    // }

    
    function _l(uint256 productID, uint256 amountShared, address who) internal {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage(); 
        (address[] memory qua) = _cShare(productID, who);  
        // (address[] memory qua) = _cShare(productID, who);      
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
            // rigelMapped.CMVotesCounts(lst[j], false);
        }
        delete ds.member;

        // for (uint256 j = 0; j < lst.length; j++) {
        //     address ls = lst[j];
        //     if (ls != address(0)) {
        //         rigelMapped.CMVotesCounts(lst[j], true);
        //     }
        // }
    }

    function _cShare(uint256 productID, address who) internal view returns(address[] memory) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage(); 
        MembersTips memory tipMe = ds.tips[productID];
        uint256 lenWho = tipMe.whoITip.length;      
        address[] memory won = new address[](lenWho);
        // address[] memory lost = new address[](lenWho);
        if (who != address(0)) {
            for (uint256 i; i < lenWho; i++ ) {
                address l = tipMe.whoITip[i];
                address c = tipMe.tippers[i];
                if (l == who) {
                    won[i] = c;
                }
                //  else if(l != who) {
                //     lost[i] = c;
                // }
            }
        }
        return (won);        
    }

    //...................................................................................................//

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
     * @dev Returns `uint256` the current ID of all transactions increemental through {makeBuyPurchase}.
     */
    function getTransactionID() public view returns (uint256) {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        return ds.transactionID;
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
   
    function _merchantChargesDibited(address from, uint256 amount) internal {
        rigelMapped.libStorage storage ds = rigelMapped.diamondStorage();
        require(IERC20(ds.RGP).transferFrom(from, address(this), amount), "Rigel's Protocol: Unable to withdraw gasFee from 'from' address");
    }

    function _tDecimals(IERC20 purchaseToken, uint256 amount) internal view returns (uint256 tDecimals) {
        tDecimals = amount * 10**purchaseToken.decimals();
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