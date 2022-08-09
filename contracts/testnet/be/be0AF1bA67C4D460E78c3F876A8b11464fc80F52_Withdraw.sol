/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

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

// File: ProxySmart.sol



//    ,adPPYYba, 88       88 8b,dPPYba,  ,adPPYba,  8b,dPPYba, ,adPPYYba,  
//    ""     `Y8 88       88 88P'   "Y8 a8"     "8a 88P'   "Y8 ""     `Y8  
//    ,adPPPPP88 88       88 88         8b       d8 88         ,adPPPPP88  
//    88,    ,88 "8a,   ,a88 88         "8a,   ,a8" 88         88,    ,88  
//    `"8bbdP"Y8  `"YbbdP"'  88          `"YbbdP"'  88         `"8bbdP"Y8  

pragma solidity ^0.8.0;



contract Withdraw is Ownable {

    address private _ERC20TokenAddress;
    IERC20 private _token;

    mapping(address => uint24) private _royaltyOwners;

    event TransferTo(uint256 amount, address indexed to);

    address[] private _ownersAddresses = [
        0xC154D60c47c1D58106856f2F117d94f722AB182d, // 0
        0xC300638dEDd7a0ce09C88c2D63679Bf4aC3FFb36, // 1
        0x6fd5Ffda42EDE529532FF16Ed77a9E4CEB832baD, // 2
        0x206258d3064EEEB38d0BCa991197b43e3D57C507, // 3
        0x8853fa76B0117B6403CFf58b556e6cB5853b34c3, // 4
        0x0f552eA1eBF83BfBe5C3f80500Fb152e66cAdb66, // 5
        0xed55e1795A87eA7140b5F35977f21d6924BCDfe9  // 6
    ];

    constructor(address ERC20TokenAddress){
        _ERC20TokenAddress = ERC20TokenAddress;
        _token = IERC20(_ERC20TokenAddress);

        _royaltyOwners[_ownersAddresses[0]] = 10;
        _royaltyOwners[_ownersAddresses[1]] = 10;
        _royaltyOwners[_ownersAddresses[2]] = 30;
        _royaltyOwners[_ownersAddresses[3]] = 20;
        _royaltyOwners[_ownersAddresses[4]] = 10;
        _royaltyOwners[_ownersAddresses[5]] = 10;
        _royaltyOwners[_ownersAddresses[6]] = 10;


    }

    function getBalanceOnERC20() public view  returns(uint256){
        uint256 balance = _token.balanceOf(address(this));
        return balance;
    }

    function withdrawERC20ToAddresses() external payable returns(bool) {
        uint256 balance = getBalanceOnERC20();
        for (uint i; i < _ownersAddresses.length; i++){
            address addressReceiver = _ownersAddresses[i];
            _token.transfer(addressReceiver, balance * _royaltyOwners[addressReceiver] / 100 );
            emit TransferTo(balance * _royaltyOwners[addressReceiver] / 100, addressReceiver);
        }
        return true; 
    }
}