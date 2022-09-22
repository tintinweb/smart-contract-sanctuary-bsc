// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./IPair.sol";
import "./IFactory.sol";

// import "hardhat/console.sol";
abstract contract IERC20Extended is IERC20Upgradeable {
    function decimals() public view virtual returns (uint8);
}

contract SatoshiController is
    Initializable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable
{
    /*
     * @desc : This struct holds the data of the allowed token details
     * @param status : checks if the token address is allowed in this contract true/false
     * @param isDiscountActive :  to check if a discount is set on payment made with this token
     * @param tokenAddress :  for the token address
     * @param discountPercent :  the discount to be given if someone pays with this token
     */
    struct PaymentTokenDetail {
        bool status;
        bool isDiscountActive;
        address tokenAddress;
        uint256 discountPercent;
        address proxy;
    }

    struct NativeTokenDetail {
        bool status;
        bool isDiscountActive;
        uint256 discountPercent;
        address proxy;
        uint256 decimal;
    }

    struct ProductDetail {
        bool status;
        bytes32 productId;
        address creator;
    }

    mapping(address => PaymentTokenDetail) public supportedPaymentTokens;
    mapping(address => mapping(address => uint256)) public users;
    mapping(address => uint256) public totalSatoshiReceivedPerUser;
    mapping(bytes32 => ProductDetail) public products;
    address public SatoshiToken;
    address public FeeCollector;
    address public StableCoin;
    address public Factory;
    uint256 public totalSatoshiDistributed;
    uint256 public totalSalesInUSD;
    uint256 public minSatoshiAmountToSendPerTransaction;
    uint256 public scale;
    NativeTokenDetail public nativeToken;
    event PaymentComplete(
        address indexed userAddress,
        address indexed paymentTokenAddress,
        uint256 indexed amount,
        uint256 satoshiReceived
    );

    function initialize() external initializer {
        __Ownable_init();
        __ReentrancyGuard_init_unchained();
        __Pausable_init();
        scale  = 100000000;
    }

    /**
     * @dev returns the latest price of a particular coin using its chainlink proxy address
     */
    function getLatestPrice(address _proxy) public view isAddress(_proxy) returns (uint) {
        uint price = _getPrice(_proxy);
        return price;
    }


    function _getPrice(address paymentToken)
        internal
        view
        returns (uint)
    {
        uint tokenUsdPrice;
        {  //preventing stack too deep
            if (paymentToken == StableCoin) {
                tokenUsdPrice = 1 * scale; // scalling price
            } else {
                address pair = IFactory(Factory).getPair(
                    paymentToken,
                    StableCoin
                );
                require(pair != address(0), "INVALID_PAIR_ADDRESSES");
                (
                    uint112 reserve0,
                    uint112 reserve1,
                    uint256 blockTimestampLast
                ) = IPair(pair).getReserves();
                address token0 = IPair(pair).token0();
                tokenUsdPrice = (token0 == paymentToken)
                    ? (reserve1 * scale) / reserve0  // scalling
                    : (reserve0 * scale) / reserve1;
            }
        }
        return tokenUsdPrice;
    }



    /**
     * @dev returns the latest price of a particular coin using its chainlink proxy address
     */
    function getProduct(bytes32 productId) public view  returns (bool, bytes32 , address) {
        ProductDetail memory product = products[productId];
        require(product.status, "SATOSHICONTROLLER: Product does not exists");
        return (product.status , product.productId , product.creator);
    }

    /**
     * @dev processes payment if the user pays with both erc20 or native token
     */
    function makePayment(address _paymentToken, uint256 _amountInUSD)
        external
        payable
        isZero(_amountInUSD)
        nonReentrant
        whenNotPaused
    {
        //check if user is paying with a native or normal erc20
        if (msg.value > 0) {
            _chargeNative(_amountInUSD);
        } else {
            PaymentTokenDetail memory paymentTokenInfo = supportedPaymentTokens[_paymentToken];
            require(paymentTokenInfo.status, "SATOSHICONTROLLER: Payment token not supported");
            _chargeERC2O(paymentTokenInfo, _amountInUSD);
        }
        _transferSatoshi();
    }

    /**
     * @dev handles the erc20 payment
     */
    function _chargeERC2O(PaymentTokenDetail memory paymentTokenInfo, uint256 _amountInUSD)
        internal
    {
        IERC20Extended tokenInstance = IERC20Extended(paymentTokenInfo.tokenAddress);
        uint8 decimal = tokenInstance.decimals();
        uint256 tokenPriceInUsd = uint256(getLatestPrice(paymentTokenInfo.proxy));
        require(tokenPriceInUsd > 0 , "SATOSHICONTROLLER : Token price is zero");

        uint256 tokenAmountToPay = (((_amountInUSD * (10**decimal)) / (tokenPriceInUsd))/scale);
        {
            if (paymentTokenInfo.isDiscountActive && paymentTokenInfo.discountPercent > 0) {
                uint256 discount = ((paymentTokenInfo.discountPercent * tokenAmountToPay) / 100);
                require(
                    tokenAmountToPay > discount,
                    "SATOSHICONTROLLER: Discount exceeds amount to pay "
                );
                tokenAmountToPay = tokenAmountToPay - discount;
            }
        }
        uint256 allowance = tokenInstance.allowance(_msgSender(), address(this));
        require(
            allowance >= tokenAmountToPay,
            "SATOSHICONTROLLER: Insufficient allowance given to rounter contract"
        );
        tokenInstance.transferFrom(_msgSender(), FeeCollector, tokenAmountToPay);
        users[_msgSender()][paymentTokenInfo.tokenAddress] += tokenAmountToPay;
        totalSalesInUSD += _amountInUSD;

        emit PaymentComplete(
            _msgSender(),
            paymentTokenInfo.tokenAddress,
            tokenAmountToPay,
            minSatoshiAmountToSendPerTransaction
        );
    }

    /**
     * @dev handles the native payment
     */
    function _chargeNative(uint256 _amountInUSD) internal { 
        uint256 tokenPriceInUsd = uint256(getLatestPrice(nativeToken.proxy));
        require(tokenPriceInUsd > 0 , "SATOSHICONTROLLER : Native Token price is zero");
        uint256 tokenAmountToPay = (((_amountInUSD * (10**nativeToken.decimal)) / (tokenPriceInUsd))/scale);
        {
            if (nativeToken.isDiscountActive && nativeToken.discountPercent > 0) {
                uint256 discount = ((nativeToken.discountPercent * tokenAmountToPay) / 100);
                require(
                    tokenAmountToPay > discount,
                    "SATOSHICONTROLLER: Discount exceeds amount to pay "
                );
                tokenAmountToPay = tokenAmountToPay - discount;
            }
        }
        require(
            msg.value >= tokenAmountToPay,
            "SATOSHICONTROLLER: Insufficient insufficient amount provided for payment"
        );
        (bool success, ) = payable(FeeCollector).call{value: msg.value}("");
        require(success, "SATOSHICONTROLLER: Ether transfer failed");
        totalSalesInUSD += _amountInUSD;
        emit PaymentComplete(
            _msgSender(),
            address(0),
            tokenAmountToPay,
            minSatoshiAmountToSendPerTransaction
        );
    }

    /**
     * @dev transfers some satoshi token to the buyer
     */
    function _transferSatoshi() internal {
        IERC20Extended satoshiToken = IERC20Extended(SatoshiToken);
        uint256 balance = satoshiToken.balanceOf(address(this));
        require(
            balance >= minSatoshiAmountToSendPerTransaction,
            "SATOSHICONTROLLER: Insufficient allowance given to rounter contract"
        );
        satoshiToken.transfer(
            _msgSender(),
            minSatoshiAmountToSendPerTransaction
        );
        totalSatoshiReceivedPerUser[_msgSender()] += minSatoshiAmountToSendPerTransaction;
        totalSatoshiDistributed += minSatoshiAmountToSendPerTransaction;
    }

    /**
     * @dev used to add another supported payment token
     */
    function addToken(
        bool status,
        bool isDiscountActive,
        address tokenAddress,
        uint256 discountPercent,
        address proxy
    ) external isAddress(tokenAddress) isAddress(proxy) onlyOwner {
        PaymentTokenDetail memory paymentTokenInfo = supportedPaymentTokens[tokenAddress];
        require(!paymentTokenInfo.status, "SATOSHICONTROLLER: Token already exist");
        supportedPaymentTokens[tokenAddress] = PaymentTokenDetail(
            status,
            isDiscountActive,
            tokenAddress,
            discountPercent,
            proxy
        );
    }

    /**
     * @dev used to add another product by vendor
     */
    function addProduct(
        bytes32 _productId
    ) external {
        ProductDetail memory product = products[_productId];
        require(!product.status, "SATOSHICONTROLLER: Product already exists");
        products[_productId] = ProductDetail(
            true,
            _productId,
           msg.sender
        );
    }

    /**
     * @dev updates the native token state
     */
    function setNativeTokenData(
        bool status,
        bool isDiscountActive,
        uint256 discountPercent,
        address proxy,
        uint256 decimal
    ) external isAddress(proxy) isZero(decimal) onlyOwner {
        nativeToken = NativeTokenDetail(status, isDiscountActive, discountPercent, proxy, decimal);
    }

    /**
     * @dev removes a token from supportedPaymentTokens
     */
    function removeToken(address _tokenAddress) external isAddress(_tokenAddress) onlyOwner {
        PaymentTokenDetail memory paymentTokenInfo = supportedPaymentTokens[_tokenAddress];
        require(paymentTokenInfo.status, "SATOSHICONTROLLER: Token does not  exist");
        supportedPaymentTokens[_tokenAddress].status = false;
    }

    /**
     * @dev removes a product from productd
     */
    function removeProduct(bytes32 productd) external {
        ProductDetail memory product = products[productd];
        require(product.status, "SATOSHICONTROLLER: Product does not  exist");
        products[productd].status = false;
    }

    /**
     * @dev sets discount status for a payment token
     */
    function changeDiscountStatus(address _tokenAddress, bool _isDiscountActive)
        external
        isAddress(_tokenAddress)
        onlyOwner
    {
        PaymentTokenDetail memory paymentTokenInfo = supportedPaymentTokens[_tokenAddress];
        require(paymentTokenInfo.status, "SATOSHICONTROLLER: Token does not  exist");
        supportedPaymentTokens[_tokenAddress].isDiscountActive = _isDiscountActive;
    }

    /**
     * @dev updates USD chainlink proxy record for a payment token
     */
    function changeProxy(address _tokenAddress, address _proxy)
        external
        isAddress(_tokenAddress)
        isAddress(_proxy)
        onlyOwner
    {
        PaymentTokenDetail memory paymentTokenInfo = supportedPaymentTokens[_tokenAddress];
        require(paymentTokenInfo.status, "SATOSHICONTROLLER: Token does not  exist");
        supportedPaymentTokens[_tokenAddress].proxy = _proxy;
    }

    /**
     * @dev sets the discount percent for a supportedPaymentTokens
     */
    function changeDiscountPercent(address _tokenAddress, uint256 _discountPercent)
        external
        isAddress(_tokenAddress)
        onlyOwner
    {
        PaymentTokenDetail memory paymentTokenInfo = supportedPaymentTokens[_tokenAddress];
        require(paymentTokenInfo.status, "SATOSHICONTROLLER: Token does not  exist");
        supportedPaymentTokens[_tokenAddress].discountPercent = _discountPercent;
    }

    /**
     * @dev gets all the total amount user has paid using a supportedPaymentTokens
     */
    function getUserPaymentsPerToken(address _user, address _token)
        external
        view
        isAddress(_user)
        isAddress(_token)
        onlyOwner
        returns (uint256)
    {
        return users[_user][_token];
    }

    /**
     * @dev this returns details of a native token
     */
    function getNativeTokenDetail()
        external
        view
        returns (
            bool status,
            bool isDiscountActive,
            uint256 discountPercent,
            address proxy,
            uint256 decimal
        )
    {
        return (
            nativeToken.status,
            nativeToken.isDiscountActive,
            nativeToken.discountPercent,
            nativeToken.proxy,
            nativeToken.decimal
        );
    }

    /**
     * @dev this returns details of a payment token
     */
    function getPaymentTokenDetail(address _tokenAddress)
        external
        view
        isAddress(_tokenAddress)
        returns (
            bool status,
            bool isDiscountActive,
            address tokenAddress,
            uint256 discountPercent,
            address proxy
        )
    {
        PaymentTokenDetail memory paymentTokenInfo = supportedPaymentTokens[_tokenAddress];
        return (
            paymentTokenInfo.status,
            paymentTokenInfo.isDiscountActive,
            paymentTokenInfo.tokenAddress,
            paymentTokenInfo.discountPercent,
            paymentTokenInfo.proxy
        );
    }

    /**
     * @dev pauses the trade
     */
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    /**
     * @dev updates the variable of fee collector
     */
    function changeFeeCollector(address _feeCollector) external isAddress(_feeCollector) onlyOwner {
        FeeCollector = _feeCollector;
    }

    /**
     * @dev change the satoshi token address
     */
    function changeSatoshiToken(address _satoshiToken) external isAddress(_satoshiToken) onlyOwner {
        SatoshiToken = _satoshiToken;
    }

    /**
     * @dev reset the minimum amount of satoshi tokens user can earn per purchase
     */
    function changeMinSatoshiAmountPerTransaction(uint256 _minSatoshiInWei) external onlyOwner {
        minSatoshiAmountToSendPerTransaction = _minSatoshiInWei;
    }

    function changeStableCoin(address _token) external isAddress(_token) onlyOwner
    {
        StableCoin = _token;
    }

    function changeFactory(address _factory) external isAddress(_factory) onlyOwner
    {
        Factory = _factory;
    }

    /**
     * @dev handles erc withdrawal
     */
    function withdrawERC20(
        address _erc20,
        address _receiver,
        uint256 _amount
    ) external isAddress(_erc20) isAddress(_receiver) isZero(_amount) onlyOwner {
        IERC20Extended tokenInstance = IERC20Extended(_erc20);
        require(
            tokenInstance.balanceOf(address(this)) >= _amount,
            "SATOSHICONTROLLER: Insufficient amount for transfer"
        );
        tokenInstance.transfer(_receiver, _amount);
    }

    /**
     * @dev handles eth withdrawal
     */
    function withdrawEth(uint256 _amount) external view isZero(_amount) onlyOwner {
        require(address(this).balance >= _amount);
        payable(_msgSender()).call{value: _amount};
    }

    modifier isAddress(address value) {
        require(address(value) != address(0), "SATOSHICONTROLLER: Address provided not valid");
        _;
    }

    modifier isZero(uint256 value) {
        require(value > 0, "SATOSHICONTROLLER: Amount must be above zero");
        _;
    }

    receive() external payable {}

    fallback() external {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
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
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "hardhat/console.sol";

interface IPair {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFactory {

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}