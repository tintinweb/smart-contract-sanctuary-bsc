/**
 *Submitted for verification at BscScan.com on 2022-09-14
*/

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol


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

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;


/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// File: @openzeppelin/contracts/interfaces/IERC20.sol


// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;


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


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// File: lib/SafeMath.sol


pragma solidity ^0.8.0;

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}
// File: Trade.sol


pragma solidity ^0.8.0;






interface INFT is IERC721Enumerable{
    function mintTo(uint256 typeNum, address _to) external;
    function getTypeNum(uint256 tokenId) external view returns(uint256);
    function burn(uint256 tokenId) external;
    function tokensOfOwner(address owner, uint256 start, uint256 length) view external returns(uint256[] memory tokenIds);
    function tokensOfOwnerExt(uint256 typeNum, address owner, uint256 start, uint256 length) view external returns(uint256[] memory tokenIds);
    function balanceOfExt(uint256 typeNum, address owner) external view returns (uint256);
}

contract Trade is Ownable,IERC721Receiver {
    using SafeMath for uint256;

    struct Order {
        uint256 id;
        address from;
        address to;
        uint256 tokenIndex;
        uint256 fromIndex;
        uint256 toIndex;
        uint256 startTime;
        uint256 endTime;
        uint256 value;
        uint256 amount;
    }
    struct OrderNFT {
        uint256 id;
        address from;
        address to;
        uint256 tokenIndex;
        uint256 fromIndex;
        uint256 toIndex;
        uint256 startTime;
        uint256 endTime;
        uint256 value;
        uint256 tokenId;
        uint256 typeNum;
    }

    mapping(address => Order[]) public orderSellMap;
    mapping(address => Order[]) public orderBuyMap;
    mapping(address => Order[]) public orderSellFinishMap;
    mapping(address => Order[]) public orderBuyFinishMap;
    mapping(address => OrderNFT[]) public orderNFTSellMap;
    mapping(address => OrderNFT[]) public orderNFTBuyMap;
    mapping(address => OrderNFT[]) public orderNFTSellFinishMap;
    mapping(address => OrderNFT[]) public orderNFTBuyFinishMap;
    uint256 public orderId;

    IERC20[] public _tokens;
    INFT[] public _nfts;
    IERC20 public _usdt;
    address public _team;

    constructor(address usdt, address team, address token, address nft) {
        _usdt = IERC20(usdt);
        _team = team;
        _tokens.push(IERC20(token));
        _nfts.push(INFT(nft));
    }

    function sell(address to, uint256 tokenIndex, uint256 amount, uint256 value) public{
        address from = msg.sender;
        _tokens[tokenIndex].transferFrom(from, address(this), amount);
        orderId++;
        Order memory order = Order({
            id: orderId,
            from: from,
            to: to,
            tokenIndex: tokenIndex,
            fromIndex: orderSellMap[from].length,
            toIndex: orderBuyMap[to].length,
            startTime: block.timestamp,
            endTime: 0,
            value: value,
            amount: amount
        });
        orderSellMap[from].push(order);
        orderBuyMap[to].push(order);
        emit Sell(to, tokenIndex, amount, value, orderId);
    }

    function buy(uint256 toIndex) public{
        address to = msg.sender;
        Order memory order = orderBuyMap[to][toIndex];
        address from = order.from;
        uint256 fromIndex = order.fromIndex;

        _usdt.transferFrom(to, from, order.value.mul(95).div(100));
        _usdt.transferFrom(to, _team, order.value.mul(5).div(100));
        _tokens[order.tokenIndex].transfer(to, order.amount);

        _cancel(from, fromIndex);
        order.fromIndex = orderSellFinishMap[from].length;
        order.toIndex = orderBuyFinishMap[to].length;
        order.endTime = block.timestamp;
        orderSellFinishMap[from].push(order);
        orderBuyFinishMap[to].push(order);
        emit Buy(order.id);
    }

    function cancel(uint256 fromIndex) public{
        address from = msg.sender;
        Order memory order = orderSellMap[from][fromIndex];
        _tokens[order.tokenIndex].transfer(from, order.amount);

        _cancel(from, fromIndex);
        emit Cancel(order.id);
    }

    function _cancel(address from, uint256 fromIndex) private{
        address to = orderSellMap[from][fromIndex].to;
        uint256 toIndex = orderSellMap[from][fromIndex].toIndex;

        Order memory orderSell = orderSellMap[from][orderSellMap[from].length-1];
        orderSell.fromIndex = fromIndex;
        orderBuyMap[orderSell.to][orderSell.toIndex].fromIndex = fromIndex;

        Order memory orderBuy = orderBuyMap[to][orderBuyMap[to].length-1];
        orderBuy.toIndex = toIndex;
        orderSellMap[orderBuy.from][orderBuy.fromIndex].toIndex = toIndex;

        orderSellMap[from][fromIndex] = orderSell;
        orderSellMap[from].pop();
        orderBuyMap[to][toIndex] = orderBuy;
        orderBuyMap[to].pop();
    }

    function sellNFT(address to, uint256 tokenIndex, uint256 tokenId, uint256 value) public{
        address from = msg.sender;
        _nfts[tokenIndex].transferFrom(from, address(this), tokenId);
        orderId++;
        uint256 typeNum = _nfts[tokenIndex].getTypeNum(tokenId);
        OrderNFT memory order = OrderNFT({
            id: orderId,
            from: from,
            to: to,
            tokenIndex: tokenIndex,
            fromIndex: orderNFTSellMap[from].length,
            toIndex: orderNFTBuyMap[to].length,
            startTime: block.timestamp,
            endTime: 0,
            value: value,
            tokenId: tokenId,
            typeNum: typeNum
        });
        orderNFTSellMap[from].push(order);
        orderNFTBuyMap[to].push(order);
        emit SellNFT(to, tokenIndex, tokenId, typeNum, value, orderId);
    }

    function buyNFT(uint256 toIndex) public{
        address to = msg.sender;
        OrderNFT memory order = orderNFTBuyMap[to][toIndex];
        address from = order.from;
        uint256 fromIndex = order.fromIndex;

        _usdt.transferFrom(to, from, order.value.mul(95).div(100));
        _usdt.transferFrom(to, _team, order.value.mul(5).div(100));
        _nfts[order.tokenIndex].transferFrom(address(this), to, order.tokenId);

        _cancelNFT(from, fromIndex);
        order.fromIndex = orderNFTSellFinishMap[from].length;
        order.toIndex = orderNFTBuyFinishMap[to].length;
        order.endTime = block.timestamp;
        orderNFTSellFinishMap[from].push(order);
        orderNFTBuyFinishMap[to].push(order);
        emit BuyNFT(order.id);
    }

    function cancelNFT(uint256 fromIndex) public{
        address from = msg.sender;
        OrderNFT memory order = orderNFTSellMap[from][fromIndex];
        _nfts[order.tokenIndex].transferFrom(address(this), from, order.tokenId);

        _cancelNFT(from, fromIndex);
        emit CancelNFT(order.id);
    }

    function _cancelNFT(address from, uint256 fromIndex) private{
        uint256 toIndex = orderNFTSellMap[from][fromIndex].toIndex;
        address to = orderNFTSellMap[from][fromIndex].to;

        OrderNFT memory orderNFTSell = orderNFTSellMap[from][orderNFTSellMap[from].length-1];
        orderNFTSell.fromIndex = fromIndex;
        orderNFTBuyMap[orderNFTSell.to][orderNFTSell.toIndex].fromIndex = fromIndex;

        OrderNFT memory orderNFTBuy = orderNFTBuyMap[to][orderNFTBuyMap[to].length-1];
        orderNFTBuy.toIndex = toIndex;
        orderNFTSellMap[orderNFTBuy.from][orderNFTBuy.fromIndex].toIndex = toIndex;

        orderNFTSellMap[from][fromIndex] = orderNFTSell;
        orderNFTSellMap[from].pop();
        orderNFTBuyMap[to][toIndex] = orderNFTBuy;
        orderNFTBuyMap[to].pop();
    }

    function getOrderSellLength(address from) public view returns(uint256){
        return orderSellMap[from].length;
    }

    function getOrderSellList(address from, uint256 start, uint256 length) public view returns(address[] memory tos, uint256[] memory tokenIndexes, 
    uint256[] memory startTimes, uint256[] memory endTimes, uint256[] memory values, uint256[] memory amounts){
        Order[] memory orders = orderSellMap[from];
        (, tos, tokenIndexes, startTimes, endTimes, values, amounts) = _getOrderList(orders, start, length);
    }

    function getOrderSellFinishLength(address from) public view returns(uint256){
        return orderSellFinishMap[from].length;
    }

    function getOrderSellFinishList(address from, uint256 start, uint256 length) public view returns(address[] memory tos, uint256[] memory tokenIndexes, 
    uint256[] memory startTimes, uint256[] memory endTimes, uint256[] memory values, uint256[] memory amounts){
        Order[] memory orders = orderSellFinishMap[from];
        (, tos, tokenIndexes, startTimes, endTimes, values, amounts) = _getOrderList(orders, start, length);
    }

    function getOrderBuyLength(address to) public view returns(uint256){
        return orderBuyMap[to].length;
    }

    function getOrderBuyList(address to, uint256 start, uint256 length) public view returns(address[] memory froms, uint256[] memory tokenIndexes, 
    uint256[] memory startTimes, uint256[] memory endTimes, uint256[] memory values, uint256[] memory amounts){
        Order[] memory orders = orderBuyMap[to];
        (froms, , tokenIndexes, startTimes, endTimes, values, amounts) = _getOrderList(orders, start, length);
    }

    function getOrderBuyFinishLength(address to) public view returns(uint256){
        return orderBuyFinishMap[to].length;
    }

    function getOrderBuyFinishList(address to, uint256 start, uint256 length) public view returns(address[] memory froms, uint256[] memory tokenIndexes, 
    uint256[] memory startTimes, uint256[] memory endTimes, uint256[] memory values, uint256[] memory amounts){
        Order[] memory orders = orderBuyFinishMap[to];
        (froms, , tokenIndexes, startTimes, endTimes, values, amounts) = _getOrderList(orders, start, length);
    }

    function _getOrderList(Order[] memory orders, uint256 start, uint256 length) private pure returns(address[] memory froms, address[] memory tos, uint256[] memory tokenIndexes, 
    uint256[] memory startTimes, uint256[] memory endTimes, uint256[] memory values, uint256[] memory amounts){
        uint256 end = start+length;
        uint256 total = orders.length;
        if(end>total) end = total;
        length = end > start ? end - start : 0;
        froms = new address[](length);
        tos = new address[](length);
        tokenIndexes = new uint256[](length);
        startTimes = new uint256[](length);
        endTimes = new uint256[](length);
        values = new uint256[](length);
        amounts = new uint256[](length);
        for(uint i=start; i<end; i++){
            froms[i-start] = orders[i].from;
            tos[i-start] = orders[i].to;
            tokenIndexes[i-start] = orders[i].tokenIndex;
            startTimes[i-start] = orders[i].startTime;
            endTimes[i-start] = orders[i].endTime;
            values[i-start] = orders[i].value;
            amounts[i-start] = orders[i].amount;
        }
    }

    function getOrderNFTSellLength(address from) public view returns(uint256){
        return orderNFTSellMap[from].length;
    }

    function getOrderNFTSellList(address from, uint256 start, uint256 length) public view returns(address[] memory tos, uint256[] memory tokenIndexes, 
    uint256[] memory startTimes, uint256[] memory endTimes, uint256[] memory values, uint256[] memory tokenIds, uint256[] memory typeNums){
        OrderNFT[] memory orders = orderNFTSellMap[from];
        (, tos, tokenIndexes, startTimes, endTimes, values, tokenIds, typeNums) = _getOrderNFTList(orders, start, length);
    }

    function getOrderNFTSellFinishLength(address from) public view returns(uint256){
        return orderNFTSellFinishMap[from].length;
    }

    function getOrderNFTSellFinishList(address from, uint256 start, uint256 length) public view returns(address[] memory tos, uint256[] memory tokenIndexes, 
    uint256[] memory startTimes, uint256[] memory endTimes, uint256[] memory values, uint256[] memory tokenIds, uint256[] memory typeNums){
        OrderNFT[] memory orders = orderNFTSellFinishMap[from];
        (, tos, tokenIndexes, startTimes, endTimes, values, tokenIds, typeNums) = _getOrderNFTList(orders, start, length);
    }

    function getOrderNFTBuyLength(address to) public view returns(uint256){
        return orderNFTBuyMap[to].length;
    }

    function getOrderNFTBuyList(address to, uint256 start, uint256 length) public view returns(address[] memory froms, uint256[] memory tokenIndexes, 
    uint256[] memory startTimes, uint256[] memory endTimes, uint256[] memory values, uint256[] memory tokenIds, uint256[] memory typeNums){
        OrderNFT[] memory orders = orderNFTBuyMap[to];
        (froms, , tokenIndexes, startTimes, endTimes, values, tokenIds, typeNums) = _getOrderNFTList(orders, start, length);
    }

    function getOrderNFTBuyFinishLength(address to) public view returns(uint256){
        return orderNFTBuyFinishMap[to].length;
    }

    function getOrderNFTBuyFinishList(address to, uint256 start, uint256 length) public view returns(address[] memory froms, uint256[] memory tokenIndexes, 
    uint256[] memory startTimes, uint256[] memory endTimes, uint256[] memory values, uint256[] memory tokenIds, uint256[] memory typeNums){
        OrderNFT[] memory orders = orderNFTBuyFinishMap[to];
        (froms, , tokenIndexes, startTimes, endTimes, values, tokenIds, typeNums) = _getOrderNFTList(orders, start, length);
    }

    function _getOrderNFTList(OrderNFT[] memory orders, uint256 start, uint256 length) private pure returns(address[] memory froms, address[] memory tos, uint256[] memory tokenIndexes, 
    uint256[] memory startTimes, uint256[] memory endTimes, uint256[] memory values, uint256[] memory tokenIds, uint256[] memory typeNums){
        uint256 end = start+length;
        uint256 total = orders.length;
        if(end>total) end = total;
        length = end > start ? end - start : 0;
        froms = new address[](length);
        tos = new address[](length);
        tokenIndexes = new uint256[](length);
        startTimes = new uint256[](length);
        endTimes = new uint256[](length);
        values = new uint256[](length);
        tokenIds = new uint256[](length);
        typeNums = new uint256[](length);
        for(uint i=start; i<end; i++){
            froms[i-start] = orders[i].from;
            tos[i-start] = orders[i].to;
            tokenIndexes[i-start] = orders[i].tokenIndex;
            startTimes[i-start] = orders[i].startTime;
            endTimes[i-start] = orders[i].endTime;
            values[i-start] = orders[i].value;
            tokenIds[i-start] = orders[i].tokenId;
            typeNums[i-start] = orders[i].typeNum;
        }
    }

    function getTokenLength() public view returns(uint256){
        return _tokens.length;
    }

    function getTokenList(uint256 start, uint256 length) public view returns(address[] memory tokens){
        uint256 end = start+length;
        uint256 total = _tokens.length;
        if(end>total) end = total;
        length = end > start ? end - start : 0;
        tokens = new address[](length);
        for(uint i=start; i<end; i++){
            tokens[i-start] = address(_tokens[i]);
        }
    }
    
    function setTokens(IERC20[] memory tokens) public onlyOwner{
        _tokens = tokens;
    }

    function changeTokens(uint256 index, address token) public onlyOwner{
        if(index>=_tokens.length){
            _tokens.push(IERC20(token));
        }else{
            _tokens[index] = IERC20(token);
        }
    }

    function getNFTLength() public view returns(uint256){
        return _nfts.length;
    }

    function getNFTList(uint256 start, uint256 length) public view returns(address[] memory nfts){
        uint256 end = start+length;
        uint256 total = _nfts.length;
        if(end>total) end = total;
        length = end > start ? end - start : 0;
        nfts = new address[](length);
        for(uint i=start; i<end; i++){
            nfts[i-start] = address(_nfts[i]);
        }
    }
    
    function setNFTs(INFT[] memory nfts) public onlyOwner{
        _nfts = nfts;
    }

    function changeNFTs(uint256 index, address nft) public onlyOwner{
        if(index>=_tokens.length){
            _nfts.push(INFT(nft));
        }else{
            _nfts[index] = INFT(nft);
        }
    }

    event Sell(address indexed user, uint256 tokenIndex, uint256 amount, uint256 value, uint256 orderId);
    event Buy(uint256 orderId);
    event Cancel(uint256 orderId);
    event SellNFT(address indexed user, uint256 tokenIndex, uint256 tokenId, uint256 typeNum, uint256 value, uint256 orderId);
    event BuyNFT(uint256 orderId);
    event CancelNFT(uint256 orderId);
    event OnERC721Received(address,address,uint256,bytes);

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external override returns (bytes4){
        emit OnERC721Received(operator,from,tokenId,data);
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
        // return IERC721Receiver.onERC721Received.selector;
    }

    function withdrawForeignTokens(address token, address to, uint256 amount) onlyOwner public returns (bool) {
        // require(token!=address(_rewardToken), 'Wrong token!');
        return IERC20(token).transfer(to, amount);
    }

    function withdrawForeignNFT(address nft, address to, uint256[] memory tokenIds) onlyOwner public {
        for(uint256 i;i<tokenIds.length;i++){
            INFT(nft).transferFrom(address(this), to, tokenIds[i]);
        }
    }
}