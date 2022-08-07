// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


import "./SafeMath.sol";
import "./interface/IBEP20.sol";
import "./interface/INFTMarketplaceV1.sol";

contract NFTMarketplaceV1 is 
    INFTMarketplaceV1,
    IERC721Receiver,
    Ownable, 
    ReentrancyGuard{
    
    using SafeMath for uint256;

    using Counters for Counters.Counter;

    //ERC721 (0x80ac58cd)
    //ERC721Metadata (0x5b5e139f) (optional)
    //ERC721Enumerable (0x780e9d63) (optional)
    bytes4 private constant INTERFACE_ID_ERC721 = 0x80ac58cd;

    Counters.Counter private _itemIds;
    /// @notice TokenAddress => bool
    mapping(address => bool) public tokenRegistry;

    /// @notice NftAddress => Token ID => Owner => Listing item
    mapping(address => mapping(uint256 => mapping(address => uint256))) public offers;
    /// @notice ItemId => address => TokenId
    mapping(uint256 => ItemInfo) public listings;

    /// @notice Platform Fee
    uint16 private platformFee;
    /// @notice Platform fee receipient
    address payable public feeReceipient;
    //30day
    uint256 public expireTime = 2592000;

    constructor(
        uint16 _platformFee
    ){
        platformFee = _platformFee;
        feeReceipient = payable(msg.sender);
    }

    modifier isListed(
        address _nftAddress,
        uint256 _tokenId
    ){
        uint256 itemId = offers[_nftAddress][_tokenId][msg.sender];
        require(itemId > 0, "not exist");
        ItemInfo memory itemInfo = listings[itemId];
        require(itemInfo.tokenId > 0, "not listed item");
        _;
    }

    function offerItem(        
        address _nftAddress,
        uint256 _tokenId,
        address _currency,
        uint256 _itemPrice
    )
    override
    external
    nonReentrant
    {
        if (IERC165(_nftAddress).supportsInterface(INTERFACE_ID_ERC721)){
            IERC721 nft = IERC721(_nftAddress);
            require(nft.ownerOf(_tokenId) == msg.sender, "not owning item");
            require(
                _isTokenApproved(_nftAddress, _tokenId) || _isAllTokenApproved(_nftAddress, msg.sender),
                "This token is not allowed to transfer by this contract"
            );
        }else{
            revert("invalid nft address");
        }

        _validPayToken(_currency);

        IERC721(_nftAddress).safeTransferFrom(msg.sender, address(this), _tokenId);

        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        uint256 onShopTime = _getNow();

        listings[itemId]= ItemInfo(
            _nftAddress,
            _tokenId,
            itemId,
            _currency,
            _itemPrice,
            msg.sender,
            onShopTime
        );

        offers[_nftAddress][_tokenId][msg.sender] = itemId;

        emit ItemListed(
            msg.sender, 
            _nftAddress,
            _tokenId,
            itemId,
            _currency,
            _itemPrice,
            onShopTime
        );
    }

    function cancelItem(
        address _nftAddress,
        uint256 _tokenId
    ) override external nonReentrant{
        uint256 itemId = offers[_nftAddress][_tokenId][msg.sender];
        require(itemId > 0, "not exist");
        ItemInfo storage itemInfo = listings[itemId];
        require(itemInfo.nftAddress != address(0), "item not exist");
        require(itemInfo.owner == msg.sender, "not owner");
        //return to owner
        IERC721(itemInfo.nftAddress).safeTransferFrom(address(this), itemInfo.owner, itemInfo.tokenId);

        delete(offers[itemInfo.nftAddress][itemInfo.tokenId][msg.sender]);
        delete(listings[itemId]);

        emit ItemCanceled(msg.sender, _nftAddress, _tokenId, itemId);
    }

    function buyItem(
        address _nftAddress,
        uint256 _tokenId,
        address _owner
    )override external payable nonReentrant{
        uint256 itemId = offers[_nftAddress][_tokenId][_owner];
        require(itemId > 0, "not exist");
        ItemInfo memory itemInfo = listings[itemId];
        require(itemInfo.tokenId > 0, "not listed item");
        require(itemInfo.owner != msg.sender, "Buy error");
        uint256 itemExpireTime = itemInfo.onShopTime.add(expireTime);
        require(_getNow() <= itemExpireTime, "time expire error");
        //BNB Or ETH
        if (itemInfo.currency == address(0)){
            require(msg.value >= itemInfo.itemPrice, "not enough");
            uint256 feeAmount = itemInfo.itemPrice.mul(platformFee).div(1e3);
            uint256 price = itemInfo.itemPrice.sub(feeAmount);
            feeReceipient.transfer(feeAmount);
            payable(itemInfo.owner).transfer(price);
            IERC721(itemInfo.nftAddress).safeTransferFrom(address(this), msg.sender, itemInfo.tokenId);
            emit ItemSold(
                itemInfo.owner,
                msg.sender,
                itemInfo.nftAddress,
                itemInfo.tokenId,
                itemInfo.itemId,
                itemInfo.currency,
                itemInfo.itemPrice,
                feeAmount,
                _getNow()        
            );
        }else{ //ERC20
            //Check Buyer Balance
            require(IBEP20(itemInfo.currency).balanceOf(msg.sender) >= itemInfo.itemPrice, "Not enought to cover item price.");
            //Check Buyer is approve address(this) to transfer
            uint256 allowance = IBEP20(itemInfo.currency).allowance(
                msg.sender,
                address(this)
            );
            require(allowance >= itemInfo.itemPrice, "Check the token allowance");
            //Platform Fee
            uint256 feeAmount = itemInfo.itemPrice.mul(platformFee).div(1e3);
            IBEP20(itemInfo.currency).transferFrom(
                msg.sender,
                feeReceipient,
                feeAmount
            );
            //Item price
            uint256 price = itemInfo.itemPrice.sub(feeAmount);
            IBEP20(itemInfo.currency).transferFrom(
                msg.sender,
                itemInfo.owner,
                price
            );
            IERC721(itemInfo.nftAddress).safeTransferFrom(address(this), msg.sender, itemInfo.tokenId);
            emit ItemSold(
                itemInfo.owner,
                msg.sender,
                itemInfo.nftAddress,
                itemInfo.tokenId,
                itemInfo.itemId,
                itemInfo.currency,
                itemInfo.itemPrice,
                feeAmount,
                _getNow()        
            );
        }

        delete(offers[itemInfo.nftAddress][itemInfo.tokenId][itemInfo.owner]);
        delete(listings[itemId]);
    }

    function fetchMyNFTs(address _nftOwner) override external view returns(ItemInfo[] memory){
        uint totalItemCount = _itemIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for (uint i = 0;i < totalItemCount;i++){
            if(listings[i+1].owner == _nftOwner){
                itemCount += 1;
            }
        }

        ItemInfo[] memory items = new ItemInfo[](itemCount);
        for(uint i = 0;i < totalItemCount;i++){
            if(listings[i+1].owner == _nftOwner){
                ItemInfo storage currentItem = listings[i+1];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function updatePlatformFee(uint16 _platformFee) external onlyOwner{
        platformFee = _platformFee;
    }

    function updateFeeReceipient(address _feeReceipient) external onlyOwner{
        feeReceipient = payable(_feeReceipient);
    }

    function updateExpireTime(uint256 _expireTime) external onlyOwner{
        expireTime = _expireTime;
    }

    function addToken(address token) external onlyOwner{
        require(!tokenRegistry[token], "token already added");
        tokenRegistry[token] = true;
    }

    function removeToken(address token) external onlyOwner{
        require(tokenRegistry[token], "token not exist");
        tokenRegistry[token] = false;
    }

    function getItemInfoById(uint256 itemId) override external view returns(ItemInfo memory){
        return listings[itemId];
    }

    function getItemInfoByAddress(address nftAddress, uint256 tokenId, address owner) override external view returns(ItemInfo memory){
        uint256 itemId = offers[nftAddress][tokenId][owner];
        return listings[itemId];
    }

    function getPlatformFee() external view returns(uint16){
        return platformFee;
    }

    function validateExpireTime(uint256 startTime) external pure returns(uint256){
        return startTime.add(startTime);
    }

    function _validPayToken(address _currency) internal view{
        if (_currency == address(0)){

        }else{
            require(tokenRegistry[_currency], "invalid pay token");
        }
    }

    /**
     * @dev check if this contract has approved to all of this owner's erc721 tokens
     */
    function _isAllTokenApproved(address _nftAddress, address _owner) private view returns (bool) {
        return IERC721(_nftAddress).isApprovedForAll(_owner, address(this));
    }

    /**
     * @dev check if this contract has approved to transfer this erc721 token
     */
    function _isTokenApproved(address _nftAddress, uint256 _tokenId) private view returns (bool) {
        try IERC721(_nftAddress).getApproved(_tokenId) returns (address tokenOperator) {
            return tokenOperator == address(this);
        } catch {
            return false;
        }
    }

    function _getNow() internal view returns (uint256) {
        return block.timestamp;
    }

    function onERC721Received(address, address , uint256, bytes calldata) public pure override returns(bytes4) {
        return this.onERC721Received.selector;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @dev Interface of the BEP20 standard as defined in the BIP.
 */
interface IBEP20 {
    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

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

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.4;


interface INFTMarketplaceV1 {

    struct ItemInfo{
        address nftAddress;
        uint256 tokenId;
        uint256 itemId;
        address currency;
        uint256 itemPrice;
        address owner;
        uint256 onShopTime;
    }

    event ItemListed(
        address indexed owner,
        address indexed nft,
        uint256 tokenId,
        uint256 itemId,
        address currency,
        uint256 itemPrice,
        uint256 onShopTime
    );

    event ItemSold(
        address indexed seller,
        address indexed buyer,
        address indexed nft,
        uint256 tokenId,
        uint256 itemId,
        address currency,
        uint256 itemPrice,
        uint256 fee,
        uint256 soldTime
    );

    event ItemCanceled(
        address indexed creator,
        address indexed nft,
        uint256 tokenId,
        uint256 itemId
    );

    function offerItem(
        address _nftAddress,
        uint256 _tokenId,
        address _currency,
        uint256 _itemPrice
    )external;

    function cancelItem(address nftAddress, uint256 tokenId) external;

    function buyItem(address nftAddress, uint256 tokenId, address owner) external payable;

    function getItemInfoById(uint256 itemId) external view returns(ItemInfo memory);

    function getItemInfoByAddress(address nftAddress, uint256 tokenId, address owner) external view returns(ItemInfo memory);

    function fetchMyNFTs(address _nftOwner) external view returns(ItemInfo[] memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
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