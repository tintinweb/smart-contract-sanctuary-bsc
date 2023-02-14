// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract XPROFuturesSale is ReentrancyGuard, Ownable {
    uint256 public futuressaleId;
    uint256 public DISCOUNT_RATE = 5;
    uint256 public DISCOUNT_MONTHS = 4;
    uint256 public MONTH = (30 * 24 * 3600);

    struct FuturesSale {
        address saleToken;
        uint256 amountPerBNB;
        uint256 tokensToSellAmount;
        uint256 inSale;
    }

    struct Vesting {
        uint256 totalAmount;
        uint256 claimedAmount;
        uint256 buyTime;
        uint256 claimTime;
    }

    mapping(address => bool) private _BlackList;
    mapping(uint256 => bool) public paused;
    mapping(uint256 => FuturesSale) public futuressale;
    mapping(address => mapping(uint256 => Vesting)) public userVesting;

    event FuturesSaleCreated(
        uint256 indexed _id,
        uint256 _totalTokens
    );

    event FuturesSaleUpdated(
        bytes32 indexed key,
        uint256 prevValue,
        uint256 newValue,
        uint256 timestamp
    );

    event TokensBought(
        address indexed user,
        uint256 indexed id,
        address indexed purchaseToken,
        uint256 tokensBought,
        uint256 amountPaid,
        uint256 timestamp
    );

    event TokensClaimed(
        address indexed user,
        uint256 indexed id,
        uint256 amount,
        uint256 timestamp
    );

    event FuturesSaleTokenAddressUpdated(
        address indexed prevValue,
        address indexed newValue,
        uint256 timestamp
    );

    event FuturesSalePaused(uint256 indexed id, uint256 timestamp);
    event FuturesSaleUnpaused(uint256 indexed id, uint256 timestamp);
    event Withdrawn(address token, uint256 amount);

    /**
     * @dev Creates a new futuressale
     * @param _amountPerBNB amount Per 1 BNB
     * @param _tokensToSellAmount No of tokens to sell without denomination. If 1 million tokens to be sold then - 1_000_000 has to be passed
     */
    function createFuturesSale(uint256 _amountPerBNB, uint256 _tokensToSellAmount) external onlyOwner {
        require(_amountPerBNB > 0, "Zero amount per 1 BNB");
        require(_tokensToSellAmount > 0, "Zero tokens to sell");

        futuressaleId++;

        futuressale[futuressaleId] = FuturesSale(
            address(0),
            _amountPerBNB,
            _tokensToSellAmount,
            _tokensToSellAmount
        );

        emit FuturesSaleCreated(futuressaleId, _tokensToSellAmount);
    }

    /**
     * @dev To update the sale token address
     * @param _id FuturesSale id to update
     * @param _newAddress Sale token address
     */
    function changeSaleTokenAddress(uint256 _id, address _newAddress) external checkFuturesSaleId(_id) onlyOwner
    {
        require(_newAddress != address(0), "Zero token address");
        address prevValue = futuressale[_id].saleToken;
        futuressale[_id].saleToken = _newAddress;
        emit FuturesSaleTokenAddressUpdated(
            prevValue,
            _newAddress,
            block.timestamp
        );
    }

    /**
     * @dev To update the token amount per BNB
     * @param _id FuturesSale id to update
     * @param _newAmountPerBNB New amount per BNB
     */
    function changeAmountPerBNB(uint256 _id, uint256 _newAmountPerBNB) external checkFuturesSaleId(_id) onlyOwner
    {
        require(_newAmountPerBNB > 0, "Zero amount per 1 BNB");
        uint256 prevValue = futuressale[_id].amountPerBNB;
        futuressale[_id].amountPerBNB = _newAmountPerBNB;
        emit FuturesSaleUpdated(
            bytes32("AMOUNTPERBNB"),
            prevValue,
            _newAmountPerBNB,
            block.timestamp
        );
    }

    /**
     * @dev To pause the futuressale
     * @param _id FuturesSale id to update
     */
    function pauseFuturesSale(uint256 _id) external checkFuturesSaleId(_id) onlyOwner {
        require(!paused[_id], "Already paused");
        paused[_id] = true;
        emit FuturesSalePaused(_id, block.timestamp);
    }

    /**
     * @dev To unpause the futuressale
     * @param _id FuturesSale id to update
     */
    function unPauseFuturesSale(uint256 _id) external checkFuturesSaleId(_id) onlyOwner
    {
        require(paused[_id], "Not paused");
        paused[_id] = false;
        emit FuturesSaleUnpaused(_id, block.timestamp);
    }

    modifier checkFuturesSaleId(uint256 _id) {
        require(_id > 0 && _id <= futuressaleId, "Invalid futuressale id");
        _;
    }

    function setBlacklistStatus(address _account, bool status) external onlyOwner {
        _BlackList[_account] = status;
    }

    function isBlackList(address _account) external view returns (bool) {
        return _BlackList[_account];
    }

    /**
     * @dev To buy into a futuressale using BNB
     * @param _id FuturesSale id
     * @param period Claim Period
     */
    function buyToken(uint256 _id, uint256 period) external payable checkFuturesSaleId(_id) nonReentrant returns (bool)
    {
        require(!paused[_id], "FuturesSale paused");
        require(!_BlackList[_msgSender()], "The wallet has been blacklisted for suspicious transaction");
        require(period % 4 == 0, "Period is not allowed");

        uint256 discount = (period / DISCOUNT_MONTHS) * DISCOUNT_RATE;
        uint256 transferFee = 5; // 5% fee for XPRO Token
        uint256 totalBNB = msg.value;
        uint256 amount = totalBNB * futuressale[_id].amountPerBNB;
        amount = amount + (amount * ((discount+transferFee) / 100));

        require(
            amount > 0 && amount <= futuressale[_id].inSale,
            "Invalid sale amount"
        );

        futuressale[_id].inSale -= amount;

        if (userVesting[_msgSender()][_id].totalAmount > 0) {
            userVesting[_msgSender()][_id].totalAmount += amount;
        } else {
            userVesting[_msgSender()][_id] = Vesting(
                amount,
                0,
                block.timestamp,
                block.timestamp + (period * MONTH)
            );
        }
        sendValue(payable(owner()), totalBNB);

        emit TokensBought(
            _msgSender(),
            _id,
            address(0),
            amount,
            totalBNB,
            block.timestamp
        );
        return true;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Low balance");
        (bool success,) = recipient.call{value : amount}("");
        require(success, "BNB Transfer failed");
    }

    /**
     * @dev Helper funtion to get claimable tokens
     * @param user User address
     * @param _id FuturesSale id
     */
    function claimableAmount(address user, uint256 _id) public view checkFuturesSaleId(_id) returns (uint256)
    {
        Vesting memory _user = userVesting[user][_id];
        require(!_BlackList[_msgSender()], "The wallet has been blacklisted for suspicious transaction");
        require(_user.totalAmount > 0, "Nothing to claim");
        uint256 amount = _user.totalAmount - _user.claimedAmount;
        require(amount > 0, "Already claimed");
        return amount;
    }

    /**
     * @dev To claim tokens
     * @param user User address
     * @param _id FuturesSale id
     */
    function claim(address user, uint256 _id) public returns (bool) {
        require(!_BlackList[_msgSender()], "The wallet has been blacklisted for suspicious transaction");
        uint256 amount = claimableAmount(user, _id);
        require(amount > 0, "Zero claim amount");
        require(futuressale[_id].saleToken != address(0), "FuturesSale token address not set");
        require(
            amount <= IERC20(futuressale[_id].saleToken).balanceOf(address(this)),
            "Not enough tokens in the contract"
        );
        require(
            userVesting[user][_id].claimTime >= block.timestamp,
            "The time required for the claim has not expired"
        );
        userVesting[user][_id].claimedAmount += amount;
        bool status = IERC20(futuressale[_id].saleToken).transfer(user, amount);
        require(status, "Token transfer failed");
        emit TokensClaimed(user, _id, amount, block.timestamp);
        return true;
    }

    function transferAmount(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        IERC20(tokenAddress).transfer(this.owner(), tokenAmount);
        emit Withdrawn(tokenAddress, tokenAmount);
    }
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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