/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

// Sources flattened with hardhat v2.12.2 https://hardhat.org

// File @openzeppelin/contracts/utils/[email protected]

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


// File @openzeppelin/contracts/access/[email protected]


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


// File @openzeppelin/contracts/token/ERC20/[email protected]


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


// File @openzeppelin/contracts/interfaces/[email protected]


// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;


// File @openzeppelin/contracts/security/[email protected]


// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


// File contracts/Bridge.sol


pragma solidity ^0.8.0;



contract Bridge is Context, Ownable, ReentrancyGuard {
    address public bridge;
    address public token;
    uint256 public fee;
    uint256 public minBridgeAmount; //
    uint256 public maxBridgeAmount; // 50 000 000 Strat

    mapping(address => uint256) public claimable;
    uint256 public totalClaimable;

    bool public paused;
    event BridgeTokens(address from, address to, uint256 amount);
    event ClaimTokens(address to, uint256 amount);
    event TransferedBack(address to, uint256 amount);

    constructor(
        address _bridge,
        address _token,
        uint256 _minBridgeAmount,
        uint256 _maxBridgeAmount,
        uint256 _fee
    ) {
        bridge = _bridge;
        token = _token;
        minBridgeAmount = _minBridgeAmount;
        maxBridgeAmount = _maxBridgeAmount;
        fee = _fee;
    }

    function setMinBridgeAmount(uint256 _minBridgeAmount) external onlyOwner {
        minBridgeAmount = _minBridgeAmount;
    }

    function setMaxBridgeAmount(uint256 _maxBridgeAmount) external onlyOwner {
        maxBridgeAmount = _maxBridgeAmount;
    }

    function setFee(uint256 _fee) public onlyOwner {
        fee = _fee;
    }

    function setBridge(address _bridge) public onlyOwner {
        bridge = _bridge;
    }

    function setToken(address _token) public onlyOwner {
        token = _token;
    }

    function setPaused(bool _paused) public onlyBridgeOrOwner {
        paused = _paused;
    }

    modifier onlyBridgeOrOwner() {
        require(
            msg.sender == bridge || msg.sender == owner(),
            "Bridge: caller is not the bridge or owner"
        );
        _;
    }

    modifier onlyBridge() {
        require(_msgSender() == bridge, "Bridge: caller is not the bridge");
        _;
    }

    modifier notPaused() {
        require(!paused, "Bridge: paused");
        _;
    }

    function withdraw(
        address _token,
        address to,
        uint256 amount
    ) public onlyOwner {
        IERC20(_token).transfer(to, amount);
    }

    function unlock(address to, uint256 amount) public onlyBridge nonReentrant {
        claimable[to] += amount;
        totalClaimable += amount;
    }

    function bridgeTokens(
        address to,
        uint256 amount
    ) public payable notPaused nonReentrant {
        require(msg.value == fee, "Bridge: fee is not correct");
        require(amount > 0, "Bridge: amount must be greater than 0");
        require(
            amount >= minBridgeAmount,
            "Bridge: amount must be greater than minBridgeAmount"
        );
        require(
            amount <= maxBridgeAmount,
            "Bridge: amount must be less than maxBridgeAmount"
        );
        require(
            IERC20(token).balanceOf(_msgSender()) >= amount,
            "Bridge: insufficient balance"
        );
        bool transfered = IERC20(token).transferFrom(
            _msgSender(),
            address(this),
            amount
        );

        bool feeSent = payable(bridge).send(msg.value);
        require(transfered && feeSent, "Bridge: transfer failed");
        emit BridgeTokens(_msgSender(), to, amount);
    }

    function transferBack(address to, uint256 amount) public onlyBridge {
        bool transfered = IERC20(token).transfer(to, amount);
        require(transfered, "Bridge: transfer failed");
        emit TransferedBack(to, amount);
    }

    function claim() public nonReentrant {
        require(
            claimable[_msgSender()] > 0,
            "Bridge: insufficient claimable balance"
        );
        require(
            bridgeBalanceWithoutClaimable() >= claimable[_msgSender()],
            "Bridge: insufficient bridge balance"
        );
        require(totalClaimable >= claimable[_msgSender()], "Bridge: overflow");
        bool transfered = IERC20(token).transfer(
            _msgSender(),
            claimable[_msgSender()]
        );
        require(transfered, "Bridge: transfer failed");
        emit ClaimTokens(_msgSender(), claimable[_msgSender()]);
        totalClaimable -= claimable[_msgSender()];
        claimable[_msgSender()] = 0;
    }

    function bridgeBalanceWithoutClaimable() internal view returns (uint256) {
        return bridgeBalance() - totalClaimable;
    }

    function bridgeBalance() public view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }
}