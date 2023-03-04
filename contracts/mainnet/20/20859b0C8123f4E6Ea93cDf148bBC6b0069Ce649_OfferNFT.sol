/**
 *Submitted for verification at BscScan.com on 2023-03-04
*/

// File: contracts\openzeppelin-contracts\contracts\utils\Context.sol


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

// File: contracts\openzeppelin-contracts\contracts\access\Ownable.sol


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

// File: contracts\openzeppelin-contracts\contracts\token\ERC20\IERC20.sol


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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// File: contracts\OfferNFT.sol

pragma solidity ^0.8.0;


interface IOracle{
    function getAmountsIn(uint256 amountOut, address tokenIn, address tokenOut) external view returns(uint256 amountIn);
}

interface INFT{
    function mint(address to, uint256 _type, uint256 quantity) external;
}

contract OfferNFT is Ownable{
    struct Round{
        address nft;
        uint32 nftType;
        uint32 startTime;
        uint32 endTime;
        address currency1;
        uint96 price1;
        address currency2;
        uint32 valuePercent;
        uint32 totalSupply;
        uint32 currentSupply;
        uint32 perUserLimit;
    }
    Round[] public rounds;
    IOracle public oracle;
    address public feeTo;
    mapping(uint256 => mapping(address => uint256)) public minted;
    event Mint(address indexed account, address nft, uint256 nftType, uint256 quantity, address currency1, uint256 amount1, address currency2, uint256 amount2);
    
    constructor(IOracle _oracle, address _feeTo){
        oracle = _oracle;
        feeTo = _feeTo;
    }
    
    function roundLength() external view returns(uint256){
        return rounds.length;
    }
    
    function getPrice2(uint256 round) public view returns(uint256){
        Round memory r = rounds[round];
        return oracle.getAmountsIn(r.price1 * r.valuePercent / 100, r.currency2, r.currency1);
    }
    
    function mint(uint256 round, uint32 quantity) external {
        Round memory r = rounds[round];
        require(block.timestamp >= r.startTime && block.timestamp <= r.endTime, "Offer:timeLimit");
        require(quantity > 0, "Offer:zeroQuantity");
        rounds[round].currentSupply -= quantity;
        minted[round][msg.sender] += quantity;
        require(minted[round][msg.sender] <= r.perUserLimit, "Offer:perUserLimit");
        uint256 amount1 = quantity * r.price1;
        uint256 amount2 = quantity * getPrice2(round);
        address _feeTo = feeTo == address(0) ? address(this) : feeTo;
        IERC20(r.currency1).transferFrom(msg.sender, _feeTo, amount1);
        IERC20(r.currency2).transferFrom(msg.sender, _feeTo, amount2);
        INFT(r.nft).mint(msg.sender, r.nftType, quantity);
        emit Mint(msg.sender, r.nft, r.nftType, quantity, r.currency1, amount1, r.currency2, amount2);
    }
    
    function setOracle(IOracle _oracle) external onlyOwner{
        oracle = _oracle;
    }
    
    function setFeeTo(address _feeTo) external onlyOwner{
        feeTo = _feeTo;
    }
    
    function claim(IERC20 token, address to, uint256 amount) external onlyOwner{
        token.transfer(to, amount);
    }
    
    function setTime(uint256 round, uint32 startTime, uint32 endTime) external onlyOwner{
        rounds[round].startTime = startTime;
        rounds[round].endTime = endTime;
    }
    
    function setPrice(uint256 round, uint96 price1, uint32 valuePercent) external onlyOwner{
        rounds[round].price1 = price1;
        rounds[round].valuePercent = valuePercent;
    }
    
    function setCurrentSupply(uint256 round, uint32 currentSupply) external onlyOwner{
        rounds[round].currentSupply = currentSupply;
    }
    
    function setTotalSupply(uint256 round, uint32 totalSupply) external onlyOwner{
        rounds[round].totalSupply = totalSupply;
    }
    
    function setPerUserLimit(uint256 round, uint32 perUserLimit) external onlyOwner{
        rounds[round].perUserLimit = perUserLimit;
    }
    
    function addRound(Round calldata r) external onlyOwner{
        rounds.push(r);
    }
}