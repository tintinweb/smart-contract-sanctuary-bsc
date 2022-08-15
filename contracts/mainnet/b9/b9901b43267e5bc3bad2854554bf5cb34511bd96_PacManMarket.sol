/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        require(b > 0, errorMessage);
        return a / b;
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
        require(b > 0, errorMessage);
        return a % b;
    }
}

// helper methods for interacting with ERC20 tokens and sending BNB that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferBNB: BNB transfer failed');
    }
}

// OpenZeppelin Contracts v4.4.0 (token/ERC1155/IERC1155.sol)

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 {

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}

//
contract PacManMarket is Ownable, Pausable{
    using SafeMath for uint256;

    event Sale(address indexed seller, address indexed buyer, uint256 indexed tokenId, uint256 amount, uint256 priceType, uint256 price);

    event ListingCreated(address indexed seller, address indexed buyer, uint256 indexed tokenId, uint256 amount, uint256 priceType, uint256 price);

    event ListingCancelled(address indexed seller, uint256 indexed tokenId);

    IERC1155 public pacman;

    address public _devAddress;

    struct CoinType {
        address tokenAddress;

        uint256 _devFee;

        uint256 _denominator;

    }

    CoinType[] private payCoins;

    struct PendingList {
        address seller;
        address buyer;
        uint256 tokenId;
        uint256 amount;
        uint256 priceType;
        uint256 price;
        bool exists;
    }

    struct DealList{
        address seller;
        address buyer;
        uint256 tokenId;
        uint256 amount;
        uint256 priceType;
        uint256 price;
        uint256 dealTime;
    }

    mapping(address => mapping(uint256 => PendingList)) private pending;

    mapping(address => mapping(uint256 => DealList[])) private deal;

    constructor(address _pacman, address devAddress, uint256 devFeeBNB, uint256 denominatorBNB) {

        pacman = IERC1155(_pacman);

        _devAddress = devAddress;

        CoinType storage newCoinBNB = payCoins.push();
        newCoinBNB.tokenAddress = address(0);
        newCoinBNB._devFee = devFeeBNB;
        newCoinBNB._denominator = denominatorBNB;
    }

    function addPayCoin(address _tokenAddress, uint256 devFee, uint256 denominator) public onlyOwner {
        CoinType storage newCoin = payCoins.push();
        newCoin.tokenAddress = _tokenAddress;
        newCoin._devFee = devFee;
        newCoin._denominator = denominator;
    }

    function modifyFee(uint256 index, uint256 devFee, uint256 denominator) public onlyOwner {
        payCoins[index]._devFee = devFee;
        payCoins[index]._denominator = denominator;
    }

    function modifyDevAddress(address devAddress) public onlyOwner{

        _devAddress = devAddress;

    }

    function getPayCoinSize() public view returns (uint256) {
        return payCoins.length;
    }

    function getPayConfig(uint256 index) public view returns (address, uint256, uint256) {
        return (payCoins[index].tokenAddress, payCoins[index]._devFee, payCoins[index]._denominator);
    }

    modifier checkBalance(uint256 tokenId, uint256 amount) {
        require(pacman.balanceOf(_msgSender(), tokenId) >= amount, "PacManMarket: insufficient balance for token id");
        _;
    }

    function createPrivateListing(uint256 tokenId, uint256 amount, uint256 priceType, uint256 price, address buyer) external whenNotPaused() checkBalance(tokenId, amount) {
        require(priceType < payCoins.length, "PacManMarket: error price type !");

        require(pacman.isApprovedForAll(_msgSender(), address(this)), "PacManMarket: market must be approved to transfer PacMan");

        pending[_msgSender()][tokenId] = PendingList({seller : _msgSender(), buyer : buyer, tokenId : tokenId, amount : amount, priceType : priceType, price : price, exists : true});

        emit ListingCreated(_msgSender(), buyer, tokenId, amount, priceType, price);
    }

    function createListing(uint256 tokenId, uint256 amount, uint256 priceType, uint256 price) external whenNotPaused() checkBalance(tokenId, amount) {
        require(priceType < payCoins.length, "PacManMarket: error price type !");

        require(pacman.isApprovedForAll(_msgSender(), address(this)), "PacManMarket: market must be approved to transfer PacMan");

        pending[_msgSender()][tokenId] = PendingList({seller: _msgSender(), buyer: address(0), tokenId: tokenId, amount : amount, priceType: priceType, price: price, exists: true});

        emit ListingCreated(_msgSender(), address(0), tokenId, amount, priceType, price);
    }

    function getListing(address _addr, uint256 tokenId) external view returns (address, address, uint256, uint256, uint256, uint256, bool) {
        PendingList memory listing = pending[_addr][tokenId];
        return (listing.seller, listing.buyer, listing.tokenId, listing.amount, listing.priceType, listing.price, listing.exists);
    }

    function getDealSize(address _addr, uint256 tokenId) external view returns(uint256){
        return deal[_addr][tokenId].length;
    }

    function getDealDetail(address _addr, uint256 tokenId, uint256 index) external view returns(address, address, uint256, uint256, uint256, uint256, uint256) {
        DealList memory dealList = deal[_addr][tokenId][index];
        return (dealList.seller, dealList.buyer, dealList.tokenId, dealList.amount, dealList.priceType, dealList.price, dealList.dealTime);
    }

    function cancelListing(uint256 tokenId) external whenNotPaused() {
        require(pending[_msgSender()][tokenId].exists == true, "PacManMarket: PacMan not for sale");

        delete pending[_msgSender()][tokenId];

        emit ListingCancelled(_msgSender(), tokenId);
    }

    function buy(address seller, uint256 tokenId) external payable whenNotPaused() {
        PendingList memory trade = pending[seller][tokenId];
        require(trade.exists == true, "PacManMarket: PacMan not for sale");

        require(pacman.balanceOf(seller, tokenId) >= trade.amount, "PacManMarket: insufficient balance");

        if(trade.buyer != address(0)) {
            require(trade.buyer == _msgSender(), "PacManMarket: listing is not available to the caller");
        }

        CoinType storage payCoin = payCoins[trade.priceType];

        if(payCoin.tokenAddress == address(0)){

            require(msg.value == trade.price, "PacManMarket: must send correct BNB amount to buy");

        }else{

            TransferHelper.safeTransferFrom(payCoin.tokenAddress, _msgSender(), address(this), trade.price);

        }

        uint256 devAmount = trade.price.mul(payCoin._devFee).div(payCoin._denominator);

        uint256 sellAmount = trade.price.sub(devAmount);

        if(payCoin.tokenAddress == address(0)){

            TransferHelper.safeTransferBNB(trade.seller, sellAmount);

            TransferHelper.safeTransferBNB(_devAddress, devAmount);

        }else{

            TransferHelper.safeTransfer(payCoin.tokenAddress, trade.seller, sellAmount);

            TransferHelper.safeTransfer(payCoin.tokenAddress, _devAddress, devAmount);

        }

        pacman.safeTransferFrom(trade.seller, _msgSender(), trade.tokenId, trade.amount, '');

        emit Sale(trade.seller, _msgSender(), tokenId, trade.amount, trade.priceType, trade.price);

        delete pending[trade.seller][tokenId];

        DealList memory dealList = DealList(trade.seller, _msgSender(), tokenId, trade.amount, trade.priceType, trade.price, block.timestamp);
        deal[trade.seller][tokenId].push(dealList);
        deal[_msgSender()][tokenId].push(dealList);

    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function withdraw(address to, uint256 amount) external onlyOwner {
        payable(to).transfer(amount);
    }

    function withdrawToken(address _token, address to, uint256 amount) external onlyOwner {
        TransferHelper.safeTransfer(_token, to, amount);
    }

    receive() external payable {}

}