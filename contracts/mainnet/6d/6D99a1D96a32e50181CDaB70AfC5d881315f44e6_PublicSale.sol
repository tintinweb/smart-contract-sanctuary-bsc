// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// SafeMath library is not needed since we compile with solidity > 0.8.0

//import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract PublicSale is Ownable, Pausable, ReentrancyGuard {
    // Limits
    uint public maxInvest = 1_000_000_000 * 1e18; // 1 billion USD
    uint public minInvest = 0;

    // Tokens
    IERC20 public investToken;  // what buyers receive
    address[] public stables;   // addresses of stable coins accepted (ie: BUSD, USDT)
    mapping(address => bool) public stableAccepted;

    // Totals
    uint public totalInvested;      // total USD invested
    uint public investmentsCount;   // investments count
    uint public investorsCount;     // unique investors count

    // Investors
    struct InvestorInfo {
        uint totalInvested;
        uint investmentsCount;
    }
    mapping(address => InvestorInfo) public investorMap;
    address[] public investorList;

    // Price increase
    uint public incrementRange = 100 * 1e18;      // 100 USD
    uint public incrementStep = 1 * 1e18 / 10000; // 0,0001 USD
    uint public price = 1 * 1e18; // 1 USD
    uint public amountTowardsNextIncrement; // if we don't track this everyone could invest < $100 per transaction and price would not increase // todo reset when price is overwritten

    // Fee
    uint public constant FEE_THRESHOLD = 2_000_000 * 1e18;
    uint public constant FEE_PERCENT = 1; // 1%
    uint public constant FEE_PERCENT_DIVISOR = 100;
    address public feeOwner;

    event MinInvestChanged(uint newMinInvest);
    event MaxInvestChanged(uint newMaxInvest);
    event PriceChanged(uint newPrice);
    event IncrementRangeChanged(uint newIncrementRange);
    event IncrementStepChanged(uint newIncrementStep);
    event WithdrawalToken(uint amount, address indexed token);
    event Withdrawal(uint amount);
    event Invest(address indexed investor, uint amountInvested, uint tokensPurchased, uint price);
    event FeePayed(uint fee);
    event OwnerPayed(uint amount);

    constructor(address _newOwner, address _investToken, address[] memory _stables) {
        require(_stables.length > 0);

        transferOwnership(_newOwner);
        investToken = IERC20(_investToken);
        feeOwner = msg.sender;

        for (uint i = 0; i < _stables.length; i++) {
            stableAccepted[_stables[i]] = true;
            stables.push(_stables[i]);
        }
    }

    modifier validStable(address _tokenAddress) {
        require(stableAccepted[_tokenAddress], "Unrecognized token");
        _;
    }

    receive() external payable {}
    fallback() external payable {}

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function getStables() external view returns (address[] memory) {
        return stables;
    }

    function overwritePrice(uint n) external onlyOwner {
        price = n;
        amountTowardsNextIncrement = 0;

        emit PriceChanged(price);
    }

    function setIncrementRange(uint n) external onlyOwner {
        require(n > 0, "New range must bigger than 0");
        incrementRange = n;
        emit IncrementRangeChanged(n);
    }

    function setIncrementStep(uint n) external onlyOwner {
        incrementStep = n;
        emit IncrementStepChanged(n);
    }

    function setMinInvest(uint n) external onlyOwner {
        minInvest = n;
        emit MinInvestChanged(n);
    }

    function setMaxInvest(uint n) external onlyOwner {
        maxInvest = n;
        emit MaxInvestChanged(n);
    }

    function investTokenBalance() public view returns (uint) {
        return investToken.balanceOf(address(this));
    }

    function calculateFee(uint total, uint amount) public pure returns (uint) {
        uint taxableAmount = 0;
        if (total >= FEE_THRESHOLD) {
            // apply fee to entire amount
            taxableAmount = amount;
        } else if (total + amount > FEE_THRESHOLD) {
            // apply fee only to amount that exceeds FEE_THRESHOLD
            taxableAmount = total + amount - FEE_THRESHOLD;
        }
        return (taxableAmount * FEE_PERCENT) / FEE_PERCENT_DIVISOR;
    }

    function calculatePriceIncrement(uint amount, uint dust) public view returns (uint priceIncrement, uint remainder) {
        uint total = amount + dust;
        remainder = total % incrementRange;
        priceIncrement = (total / incrementRange) * incrementStep;
    }

    function investMaxPrice(address tokenAddress, uint amount, uint maxPrice) public nonReentrant whenNotPaused validStable(tokenAddress) {
        require(amount >= minInvest, "Below min invest");
        require(amount <= maxInvest, "Above max invest");
        require(price <= maxPrice, "Current price is above maxPrice");
        IERC20 stablecoin = IERC20(tokenAddress);

        // Calculate tokens purchased and ensure there are enough in contract
        uint purchasePrice = price;
        uint tokensPurchased = amount * 1e18 / price;
        require(tokensPurchased > 0, "You can't purchase zero tokens");
        require(investTokenBalance() >= tokensPurchased, "Not enough tokens to purchase");

        // Get tokens from investor
        bool tokensReceived = stablecoin.transferFrom(msg.sender, address(this), amount);
        require(tokensReceived, "Failed to get stablecoins from investor");

        // Update totals
        if (investorMap[msg.sender].investmentsCount == 0) {
            investorList.push(msg.sender);
            investorsCount += 1;
        }
        investorMap[msg.sender].investmentsCount += 1;
        investorMap[msg.sender].totalInvested += amount;
        investmentsCount += 1;
        totalInvested += amount;

        // Apply fee if above FEE_THRESHOLD
        uint fee = calculateFee(totalInvested, amount);
        if (fee > 0) {
            bool feePayed = stablecoin.transfer(feeOwner, fee);
            require(feePayed, "Fee transfer failed");
            emit FeePayed(fee);
        }

        // Set new price
        (uint priceIncrement, uint remainder) = calculatePriceIncrement(amount, amountTowardsNextIncrement);
        price += priceIncrement;
        amountTowardsNextIncrement = remainder;

        // Send remaining stablecoin to owner
        uint balance = stablecoin.balanceOf(address(this));
        require(balance > 0, "Nothing left for owner");
        bool ownerPayed = stablecoin.transfer(owner(), balance);
        require(ownerPayed, "Transfer to owner failed");
        emit OwnerPayed(balance);

        // Send purchased tokens to investor
        require(investToken.transfer(msg.sender, tokensPurchased), "Invest token transfer failed");

        emit Invest(msg.sender, amount, tokensPurchased, purchasePrice);
    }

    function invest(address tokenAddress, uint amount) external {
        investMaxPrice(tokenAddress, amount, price);
    }

    // Allow owner to withdraw all for given token
    function withdrawToken(address tokenAddr) public nonReentrant onlyOwner {
        uint amount = IERC20(tokenAddr).balanceOf(address(this));
        require(amount > 0, "Nothing to withdraw");

        bool success = IERC20(tokenAddr).transfer(owner(), amount);
        require(success, "Transfer failed");

        emit WithdrawalToken(amount, tokenAddr);
    }

    // Allow owner to withdraw all for invest token
    function withdrawInvestToken() external onlyOwner {
        withdrawToken(address(investToken));
    }

    // Allow owner to withdraw all BNB
    function withdraw() external onlyOwner {
        uint amount = address(this).balance;
        require(amount > 0, "No BNB to withdraw");

        (bool success, ) = payable(owner()).call{value: amount}("");
        require(success, "BNB transfer failed");

        emit Withdrawal(amount);
    }

    function setFeeOwner(address newFeeOwner) external {
        require(msg.sender == feeOwner, "Only current feeOwner can change this");
        feeOwner = newFeeOwner;
    }
}

// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
    constructor() {
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

// SPDX-License-Identifier: MIT

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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
     * by making the `nonReentrant` function external, and make it call a
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