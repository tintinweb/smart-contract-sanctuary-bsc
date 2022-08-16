/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


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

// File: ShadowFiPresale.sol


pragma solidity ^0.8.4;



interface IShadowFiToken {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function airdropped(address account) external view returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function decimals() external view returns (uint8);
}

contract ShadowFiPresale is Ownable, ReentrancyGuard {
    IShadowFiToken private token;
    uint256 private availableForSale;
    mapping(address => uint256) private totalBoughtByUser;
    uint256 private totalSold;
    uint256 private totalBNBRaised;
    uint256 private tokenCost;
    uint256 private discountPercent;
    uint256 private maxAmount;
    uint32 private startTime;
    uint32 private stopTime;

    event buyTokens(
        address indexed user,
        uint256 amount,
        uint256 bnb,
        bool discounted
    );

    constructor(address _token) {
        token = IShadowFiToken(_token);
        availableForSale = uint256(0);
        totalSold = uint256(0);
        totalBNBRaised = uint256(0);
        tokenCost = uint256(0);
        discountPercent = uint256(0);
        maxAmount = uint256(0);
        startTime = uint32(0);
        stopTime = uint32(0);
    }

    /*******************************************************************************************************/
    /************************************* Admin Functions *************************************************/
    /*******************************************************************************************************/

    function depositTokens(address _tokenAddress, uint256 _amount)
        public
        onlyOwner
    {
        require(address(token) == _tokenAddress, "Invalid token is provided.");
        require(
            _amount <= token.balanceOf(address(msg.sender)),
            "Insufficient token balance in your wallet."
        );

        token.transferFrom(address(msg.sender), address(this), _amount);
        availableForSale += _amount;
    }

    function withdrawTokens(address _tokenAddress, uint256 _amount)
        public
        onlyOwner
    {
        require(address(token) == _tokenAddress, "Invalid token is provided.");
        require(
            _amount <= token.balanceOf(address(this)),
            "Insufficient token balance in contract."
        );
        require(
            _amount <= availableForSale,
            "Insufficient token balance in contract."
        );

        token.transfer(address(msg.sender), _amount);
        availableForSale -= _amount;
    }

    function setCost(uint256 _cost) public onlyOwner {
        tokenCost = _cost;
    }

    function setToken(address _tokenAddress) public onlyOwner {
        require(address(token) != _tokenAddress, "Already set!");

        token = IShadowFiToken(_tokenAddress);
    }

    function setDiscount(uint256 _discountPercent) public onlyOwner {
        require(
            _discountPercent > 1 && _discountPercent < 1001,
            "Invalid percent is provided."
        );

        discountPercent = _discountPercent;
    }

    function setStartandStopTime(uint32 _startTime, uint32 _stopTime)
        public
        onlyOwner
    {
        require(_stopTime > _startTime, "Stop time must be after start time.");
        require(
            _stopTime > block.timestamp,
            "Stop time must be before current time."
        );

        startTime = _startTime;
        stopTime = _stopTime;
    }

    function setMax(uint256 _maxAmount) public onlyOwner {
        maxAmount = _maxAmount;
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    /*******************************************************************************************************/
    /************************************** User Functions *************************************************/
    /*******************************************************************************************************/

    function tokenAddress() public view returns (address) {
        return address(token);
    }

    function availableForSaleTokenAmount() public view returns (uint256) {
        return availableForSale;
    }

    function totalBoughtByUserTokenAmount(address account)
        public
        view
        returns (uint256)
    {
        return totalBoughtByUser[account];
    }

    function totalSoldTokenAmount() public view returns (uint256) {
        return totalSold;
    }

    function tokenCostBNB() public view returns (uint256) {
        return tokenCost;
    }

    function totalBNBRaisedSoFar() public view returns (uint256) {
        return totalBNBRaised;
    }

    function discountPercentage() public view returns (uint256) {
        return discountPercent;
    }

    function maxBuyableTokenAmount() public view returns (uint256) {
        return maxAmount;
    }

    function getStartTime() public view returns (uint32) {
        return startTime;
    }

    function getStopTime() public view returns (uint32) {
        return stopTime;
    }

    function buy(uint256 _amount) external payable {
        require(block.timestamp >= startTime, "Presale is not started.");
        require(block.timestamp <= stopTime, "Presale is ended.");
        require(
            _amount <= token.balanceOf(address(this)),
            "Insufficient token balance in contract"
        );
        require(
            _amount <= availableForSale,
            "Not enough available for sale."
        );
        require(
            _amount + totalBoughtByUser[msg.sender] <= maxAmount,
            "Can not buy this many tokens."
        );

        uint8 decimals = token.decimals();
        uint256 cost = tokenCost;
        bool discounted = false;
        if (token.airdropped(msg.sender)) {
            cost = (tokenCost * (10000 - discountPercent)) / 10000;
            discounted = true;
        }
        uint256 totalCost = (_amount / (10**decimals)) * cost;
        require(msg.value >= totalCost, "Not enough to pay for that");

        payable(owner()).transfer(totalCost);

        uint256 excess = msg.value - totalCost;
        if (excess > 0) {
            payable(msg.sender).transfer(excess);
        }

        token.transfer(address(msg.sender), _amount);

        totalBoughtByUser[msg.sender] += _amount;
        availableForSale -= _amount;
        totalSold += _amount;
        totalBNBRaised += totalCost;

        emit buyTokens(msg.sender, _amount, msg.value, discounted);
    }
}