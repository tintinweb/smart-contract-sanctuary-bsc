// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./IPresale.sol";

contract Presale is IPresale, ReentrancyGuard, Ownable {
    uint256 public constant DECIMALS = 18;
    uint256 public constant DENOMINATOR = 10**DECIMALS;
    uint256 public constant INITIAL_PRICE = (7 * DENOMINATOR) / 10**3; //Initial price to be 0.007 USD

    /**
     * @dev price must be set with `DENOMINATOR` decimals
     */
    uint256 public price = INITIAL_PRICE;

    address payable public receiverOfEarnings;

    IERC20Metadata public paidWithToken;
    IERC20Metadata public presaleToken;
    uint8 internal tokenDecimals;

    bool public paused;

    //mapping referral code => amount of presale tokens sold via the referral code
    mapping(uint256 => uint256) public referrals;

    uint256 public bnbPrice; // @dev bnbPrice needs to be set with `DENOMINATOR` decimal points
    address public bnbPriceSetter;

    event BNBPriceChange(uint256 oldPrice, uint256 newPrice);
    event PriceSetterChange(address oldPriceSetter, address newPriceSetter);
    event PriceChange(uint256 oldPrice, uint256 newPrice);
    event NewReferral(uint256 indexed referral, uint256 amount, uint256 total);
    event BoughtWithBNB(uint256 amount);
    event BoughtWithToken(uint256 amount);

    /**
     * @dev Throws is the presale is paused
     */
    modifier notPaused() {
        require(!paused, "Presale is paused");
        _;
    }

    /**
     * @dev Throws is presale is NOT paused
     */
    modifier isPaused() {
        require(paused, "Presale is not paused");
        _;
    }

    /**
     * @param _presaleToken adress of the token to be purchased through preslae
     * @param _paidWithToken address of the token to be used for payment
     * @param _receiverOfEarnings address of the wallet to be allowed to withdraw the proceeds
     */
    constructor(
        address _presaleToken,
        address _paidWithToken,
        address payable _receiverOfEarnings,
        uint256 _initialBnbPrice
    ) {
        require(
            _receiverOfEarnings != address(0),
            "Receiver wallet cannot be 0"
        );
        bnbPriceSetter = msg.sender;
        receiverOfEarnings = _receiverOfEarnings;
        presaleToken = IERC20Metadata(_presaleToken);
        paidWithToken = IERC20Metadata(_paidWithToken);
        tokenDecimals = presaleToken.decimals();
        setBNBPrice(_initialBnbPrice);

        paused = true; //@dev start as paused
    }

    /**
     * @notice Sets the address allowed to withdraw the proceeds from presale
     * @param _receiverOfEarnings address of the reveiver
     */
    function setReceiverOfEarnings(address payable _receiverOfEarnings)
        external
        onlyOwner
    {
        require(
            _receiverOfEarnings != receiverOfEarnings,
            "Receiver already configured"
        );
        require(_receiverOfEarnings != address(0), "Receiver cannot be 0");
        receiverOfEarnings = _receiverOfEarnings;
    }

    /**
     * @notice Sets new price for the presale token
     * @param _price new price of the presale token - uses `DECIMALS` for precision
     */
    function setPrice(uint256 _price) external onlyOwner {
        require(_price != price, "New price cannot be same");
        uint256 _oldPrice = price;
        price = _price;
        emit PriceChange(_oldPrice, _price);
    }

    /**
     * @notice Sets address of a wallet allowed to set the price of BNB
     * @param _newPriceSetter address of the new price setter wallet
     */
    function setBnbPriceSetterAddr(address _newPriceSetter) external onlyOwner {
        require(
            _newPriceSetter != address(0),
            "Price setter cannot be 0 address"
        );
        require(
            _newPriceSetter != bnbPriceSetter,
            "Price setter already configured"
        );

        address oldPriceSetter = bnbPriceSetter;
        bnbPriceSetter = _newPriceSetter;
        emit PriceSetterChange(oldPriceSetter, _newPriceSetter);
    }

    /**
     * @notice Sets the new price of BNB
     * @param _price new BNB price in $ multiplied by `DENOMINATOR`
     */
    function setBNBPrice(uint256 _price) public {
        require(msg.sender == bnbPriceSetter, "Sender cannot set BNB price");
        require(_price > 0, "Price cannot be 0");
        uint256 oldPrice = bnbPrice;
        bnbPrice = _price;

        emit BNBPriceChange(oldPrice, _price);
    }

    /**
     * @notice Releases presale tokens to the recipient
     * @param _recipient recipient of the presale tokens
     * @param _paidAmount amount paid by recipient
     * @param _ref referral code used in presale, ignored is 0
     */
    function _releasePresaleTokens(
        address _recipient,
        uint256 _paidAmount,
        uint256 _ref
    ) internal {
        uint256 tokensToReceive = calculateTokensToReceive(_paidAmount);

        _setReferral(_ref, tokensToReceive);

        require(
            tokensToReceive <= presaleToken.balanceOf(address(this)),
            "Contract balance too low"
        );

        require(
            presaleToken.transfer(_recipient, tokensToReceive),
            "Token transfer failed"
        );
    }

    /**
     * @notice Adds amount of purchased tokens to the referral code
     * @param _ref referral code, no action if 0
     * @param _amount amount of purchased tokens
     */
    function _setReferral(uint256 _ref, uint256 _amount) internal {
        if (_ref > 0) {
            uint256 total = referrals[_ref] + _amount;
            referrals[_ref] = total;
            emit NewReferral(_ref, _amount, total);
        }
    }

    receive() external payable {
        buyTokensWithBNB(0);
    }

    /**
     * @notice Allows purchase of presale tokens using BNB
     * @param _ref referral code, ignored if 0
     */
    function buyTokensWithBNB(uint256 _ref)
        public
        payable
        override
        notPaused
        nonReentrant
    {
        require(msg.value > 0, "No BNB sent");
        uint256 _amount = _bnbToPayToken(msg.value);
        _releasePresaleTokens(msg.sender, _amount, _ref);
        emit BoughtWithBNB(_amount);
    }

    /**
     * @notice Allows purchase of presale tokens with a `paidWithToken`, requires previous allowance approval
     * @param _amount amount of `paidWithToken` to be used for purchase
     * @param _ref referral code, ignored if 0
     */
    function buyTokensWithToken(uint256 _amount, uint256 _ref)
        external
        override
        notPaused
        nonReentrant
    {
        require(_amount > 0, "Cannot buy with 0 tokens");
        require(
            paidWithToken.transferFrom(msg.sender, address(this), _amount),
            "Transfare failed"
        );

        _releasePresaleTokens(msg.sender, _amount, _ref);
        emit BoughtWithToken(_amount);
    }

    /**
     * @notice Transfers collected funds to `receiverOfEarnings` address
     */
    function withdraw() external {
        require(
            msg.sender == receiverOfEarnings,
            "Sender not allowed to withdraw"
        );

        uint256 bnbBalance = address(this).balance;
        uint256 tokenBalance = paidWithToken.balanceOf(address(this));

        if (bnbBalance > 0) {
            require(
                paidWithToken.transfer(receiverOfEarnings, tokenBalance),
                "Token transfer failed"
            );
        }

        if (tokenBalance > 0) {
            payable(receiverOfEarnings).transfer(bnbBalance);
        }
    }

    /**
     * @notice Transfers all remaining `presaleToken` balance to owner when presale is over
     */
    function rescuePresaleTokens() external onlyOwner isPaused {
        uint256 balance = presaleToken.balanceOf(address(this));
        require(balance > 0, "No tokens to rescue");

        require(
            presaleToken.transfer(owner(), balance),
            "Token transfer failed"
        );
    }

    function _bnbToPayToken(uint256 _value) internal view returns (uint256) {
        uint256 _amount = (_value * bnbPrice) / DENOMINATOR;

        return _amount;
    }

    /**
     * @notice Calculates the amount of `presaleToken` based on the amount of `paidWithToken`
     * @param _amount amount of `paidWithToken` used in purchase
     */
    function calculateTokensToReceive(uint256 _amount)
        public
        view
        returns (uint256)
    {
        //100*10**18, price 0.01 (1000)
        //uint256 tokensInWeiToReceive = (_amount / priceForOneMWei) * 10 ** MWeiFactor;
        uint256 amountToTransfer = (_amount * DENOMINATOR) / price;
        return amountToTransfer;
    }

    /**
     * @notice Pauses the presale
     */
    function pause() external onlyOwner notPaused {
        paused = true;
    }

    /**
     * @notice Unpauses the presale
     */
    function unpause() external onlyOwner isPaused {
        paused = false;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
pragma solidity ^0.8.0;

interface IPresale {
    function buyTokensWithBNB(uint256 _ref) external payable;
    function buyTokensWithToken(uint256 _amount, uint256 _ref) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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