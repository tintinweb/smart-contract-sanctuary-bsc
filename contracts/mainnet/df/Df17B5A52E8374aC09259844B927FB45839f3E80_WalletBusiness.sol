/**
 *Submitted for verification at BscScan.com on 2023-02-15
*/

// File: EthEvent.sol


pragma solidity ^0.8.0;
interface EthEvent {
    event WithdrawEvent(address indexed account, uint256 amount, uint256 value, uint256 timestamp);
    event RechargeEvent(address indexed account, uint256 value, uint256 timestamp);
    event BuyNodeEvent(address indexed account, uint256 _type, uint256 amount, uint256 timestamp);
    event BuyNftEvent(address indexed buyer, address indexed owner, uint256 cost, uint256 timestamp);
}
// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol


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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol


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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol


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

pragma solidity ^0.8.0;


//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/SignatureChecker.sol";


contract WalletBusiness is EthEvent, Ownable {

    //0 normal, 1 close
    uint public state;

    address immutable private USDT;

    uint256 private node1Price = 10000 * 10 ** 18;
    uint256 private node2Price = 2000 * 10 ** 18;

    address private node1RecAddress;
    address private node2RecAddress;
    address private nftRecAddress;

    uint256 private nftPrice = 300 * 10 ** 18;

    constructor(address _usdt){

        USDT = _usdt;


        // node1RecAddress = 0x37a26d837aC9E72e0c12Ad04EFF6052919e23d1C;
        // node2RecAddress = 0xcD1368085d1CBdca66e8073B60A90b7857091913;
        // nftRecAddress = 0x30BA49C792fd90670eCd746aB31032292dd98A24;

        node1RecAddress = msg.sender;
        node2RecAddress = msg.sender;
        nftRecAddress = msg.sender;
    }

    function changeState(uint _state) external onlyOwner() {
        state = _state;
    }

    function getNft() view external returns(uint256, address){
        return (nftPrice, nftRecAddress);
    }

    function configNft(uint256 _price, address _rec) external onlyOwner() {
        nftPrice = _price;
        nftRecAddress = _rec;
    }

    function getNode1() view external returns(uint256, address){
        return (node1Price, node1RecAddress);
    }

    function setNode1(uint256 _p, address _rec) external onlyOwner() {
        node1Price = _p;
        node1RecAddress = _rec;
    }

    function getNode2() view external returns(uint256, address){
        return (node2Price, node2RecAddress);
    }

    function setNode2(uint256 _p, address _rec) external onlyOwner() {
        node2Price = _p;
        node2RecAddress = _rec;
    }

    function approve(address token, address sender, uint256 value) external onlyOwner() {
        IERC20(token).approve(sender, value);
    }

    function claimToken(address token) external onlyOwner() {
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(msg.sender, balance);
    }

    function buyNode(uint256 _type) external {
        require(_type == 1 || _type == 2, "Bad param");
        uint256 price = _type == 1 ? node1Price : node2Price;
        address rec = _type == 1 ? node1RecAddress : node2RecAddress;

        require(IERC20(USDT).transferFrom(msg.sender, rec, price), "Transfer Error");
        emit BuyNodeEvent(msg.sender, _type, price, block.timestamp);
    }

    function buyNft(address _owner) external {
        require(IERC20(USDT).transferFrom(msg.sender, nftRecAddress, nftPrice), "Transfer Error");
        emit BuyNftEvent(msg.sender, _owner, nftPrice, block.timestamp);
    }
}