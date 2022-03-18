//SPDX-License-Identifier: No License
pragma solidity ^0.8.0;

import "./interfaces/IBEP20.sol";
import "./interfaces/ReentrancyGuard.sol";
import "./interfaces/Ownable.sol";
import "./interfaces/Pausable.sol";

contract NextEarlyAdaptersSale is ReentrancyGuard, Ownable, Pausable {
    // Payment Token (BUSD)
    IBEP20 public paymentToken;

    // Token to be sold
    IBEP20 public projectToken;

    // Total amount of token distributed
    uint256 public totalTokenBuyed;

    // Total amount of token withdrawn by participants
    uint256 public totalTokenWithdrawn;

    // Participant struct for users
    struct Participant {
        uint256 vestedAmount;
        uint256 withdrawnAmount;
        uint256 amountPerPortions;
        bool[] isPortionWithdrawn;
    }

    // Info struct to get claim data
    struct Info {
        uint256 amount;
        uint256 unlockTime;
        bool isClaimed;
    }

    // Fund address
    address public fundAddress;

    // Participant mapping
    mapping(address => Participant) public addressToParticipant;

    // Whitelist mapping
    mapping(address => bool) public whitelist;

    // Number of portions for locking
    uint256 public numberOfPortions;

    // Time between portions
    uint256 public timeBetweenPortions;

    // Distribution dates
    uint256[] public distributionDates;

    // Sale start && end time
    uint256 public saleStartTime;
    uint256 public saleEndTime;

    // Price per token in payment token
    uint256 public price = 0.06 ether;

    uint256 public maxPurchaseLimit = 25000 ether;
    uint256 public minPurchaseLimit = 5000 ether;

    // EVENTS

    event Buy(address indexed user, uint256 boughtAmount, uint256 totalBalance);
    event Withdraw(
        address indexed user,
        uint256 withdrawedAmount,
        uint256 totalBalance
    );

    constructor(
        uint256 _numberOfPortions,
        uint256 _timeBetweenPortions,
        uint256 _unlockStartTime,
        uint256 _saleStartTime,
        uint256 _saleEndTime,
        address _fundAddress,
        IBEP20 _paymentToken,
        IBEP20 _projectToken
    ) {
        // Setting NextDream wallet
        fundAddress = _fundAddress;

        // Sets distribution information
        numberOfPortions = _numberOfPortions;
        timeBetweenPortions = _timeBetweenPortions;

        // Initialize Distributions Dates
        for (uint256 i; i < _numberOfPortions; i++) {
            distributionDates.push(_unlockStartTime + i * timeBetweenPortions);
        }

        // Initialize NXR token for distribution
        projectToken = _projectToken;

        // Payment token for sale
        paymentToken = _paymentToken;

        // Sale start & end times
        saleStartTime = _saleStartTime;
        saleEndTime = _saleEndTime;
    }

    // MODIFIERS

    // to check if it's time to sell
    modifier whenInSale() {
        require(block.timestamp <= saleEndTime, "Sale ended");
        require(block.timestamp >= saleStartTime, "Sale not started");
        _;
    }

    // SETTERS

    // To set sell price of token
    function setSaleEndTime(uint256 _saleEndTime) public onlyOwner {
        saleEndTime = _saleEndTime;
    }

    function setSaleStartTime(uint256 _saleStartTime) public onlyOwner {
        saleStartTime = _saleStartTime;
    }

    // Set distributon dates
    function setDistributionDates(
        uint256 _startTime,
        uint256 _timeBetweenPortions
    ) public onlyOwner {
        // Initialize Distributions Dates
        for (uint256 i; i < numberOfPortions; i++) {
            distributionDates[i] = _startTime + i * _timeBetweenPortions;
        }
    }

    // To set sell price of token
    function setPrice(uint256 newPrice) public onlyOwner {
        price = newPrice;
    }

    // To set fund address
    function setFundAddress(address newFundAddress) public onlyOwner {
        fundAddress = newFundAddress;
    }

    // To set payment token
    function setPaymentToken(IBEP20 newPaymentToken) public onlyOwner {
        paymentToken = newPaymentToken;
    }

    // To change allocations of addresses
    function setWhitelist(address[] memory users) public onlyOwner {
        for (uint256 i; i < users.length; i++) {
            whitelist[users[i]] = true;
        }
    }

    function removeFromWhitelist(address[] memory users) public onlyOwner {
        for (uint256 i; i < users.length; i++) {
            whitelist[users[i]] = false;
        }
    }

    // INTERNAL FUNCTIONS

    // Updates participants' vested amounts and unlock times
    function updateParticipant(address participant, uint256 amount) internal {
        require(
            totalTokenBuyed - totalTokenWithdrawn + amount <=
                projectToken.balanceOf(address(this)),
            "Not enough tokens for distribution."
        );
        uint256 prevVestedAmount = addressToParticipant[participant]
            .vestedAmount;
        uint256 totalAmount = amount + prevVestedAmount;
        require(
            totalAmount * 0.06 ether <= maxPurchaseLimit,
            "user exceeds maximum limit"
        );

        uint256 portionAmount = totalAmount / numberOfPortions;
        bool[] memory isPortionWithdrawn = new bool[](numberOfPortions);

        Participant memory p = Participant({
            vestedAmount: totalAmount,
            withdrawnAmount: 0,
            amountPerPortions: portionAmount,
            isPortionWithdrawn: isPortionWithdrawn
        });
        totalTokenBuyed += amount;

        addressToParticipant[participant] = p;
        emit Buy(participant, amount, totalAmount);
    }

    function buy(uint256 amountInBUSD)
        external
        nonReentrant
        whenNotPaused
        whenInSale
    {
        address user = msg.sender;
        require(whitelist[user], "no such allocation");
        if (projectToken.balanceOf(address(this)) >= minPurchaseLimit)
            require(
                amountInBUSD >= minPurchaseLimit,
                "amount must be greather then minimum limit"
            );

        uint256 projectAmount = (amountInBUSD / price) * 10**18;

        require(paymentToken.transferFrom(user, fundAddress, amountInBUSD));
        updateParticipant(user, projectAmount);
    }

    function withdraw() external nonReentrant {
        address user = msg.sender;
        Participant storage p = addressToParticipant[user];

        require(p.vestedAmount != 0, "no claim available");

        uint256 totalToWithdraw;

        for (uint256 i; i < numberOfPortions; i++) {
            if (isPortionUnlocked(i) && !p.isPortionWithdrawn[i]) {
                // Add this portion to withdraw amount
                totalToWithdraw += p.amountPerPortions;

                // Mark portion as withdrawn
                p.isPortionWithdrawn[i] = true;
            }
        }

        require(totalToWithdraw != 0, "no claim available");
        p.vestedAmount -= totalToWithdraw;
        p.withdrawnAmount += totalToWithdraw;

        // Account total tokens withdrawn.
        totalTokenWithdrawn += totalToWithdraw;

        // Transfer all tokens to user
        projectToken.transfer(user, totalToWithdraw);
        emit Withdraw(user, totalToWithdraw, p.vestedAmount);
    }

    // GETTERS
    function isPortionUnlocked(uint256 portionId) public view returns (bool) {
        return block.timestamp >= distributionDates[portionId];
    }

    function claimableBalance(address user) public view returns (uint256) {
        uint256 balance;

        Participant storage p = addressToParticipant[user];

        if (p.vestedAmount == 0) return 0;

        for (uint256 i; i < numberOfPortions; i++) {
            if (isPortionUnlocked(i))
                if (!p.isPortionWithdrawn[i]) balance += p.amountPerPortions;
        }

        return balance;
    }

    function remainingAllocation(address user) public view returns (uint256) {
        return
            maxPurchaseLimit -
            addressToParticipant[user].vestedAmount +
            addressToParticipant[user].withdrawnAmount;
    }

    function remainingAllocation_msgSender() public view returns (uint256) {
        return remainingAllocation(msg.sender);
    }

    function claimableBalance_msgSender() public view returns (uint256) {
        return claimableBalance(msg.sender);
    }

    function totalBalance(address user) public view returns (uint256) {
        return addressToParticipant[user].vestedAmount;
    }

    function totalBalance_msgSender() public view returns (uint256) {
        return totalBalance(msg.sender);
    }

    function totalVestedBalance(address user) public view returns (uint256) {
        return
            addressToParticipant[user].vestedAmount +
            addressToParticipant[user].withdrawnAmount;
    }

    function totalVestedBalance_msgSender() public view returns (uint256) {
        return totalVestedBalance(msg.sender);
    }

    function lockedBalance(address user) public view returns (uint256) {
        uint256 balance;

        Participant storage p = addressToParticipant[user];

        if (p.vestedAmount == 0) return 0;

        for (uint256 i; i < numberOfPortions; i++) {
            if (!isPortionUnlocked(i)) balance += p.amountPerPortions;
        }
        return balance;
    }

    function lockedBalance_msgSender() public view returns (uint256) {
        return lockedBalance(msg.sender);
    }

    function getInfo(address user) public view returns (Info[] memory) {
        Participant storage p = addressToParticipant[user];
        Info[] memory info = new Info[](numberOfPortions);
        for (uint256 i; i < numberOfPortions; i++) {
            info[i] = Info(
                p.amountPerPortions,
                distributionDates[i],
                p.isPortionWithdrawn[i]
            );
        }
        return info;
    }

    function getInfo_msgSender() public view returns (Info[] memory) {
        return getInfo(msg.sender);
    }

    function withdrawRemainingBalance() public onlyOwner {
        require(
            saleEndTime <= block.timestamp,
            "The remaining balance cannot be withdrawn before the sale ends."
        );
        uint256 withdrawAmount = projectToken.balanceOf(address(this)) +
            totalTokenWithdrawn -
            totalTokenBuyed;
        require(withdrawAmount != 0);
        projectToken.transfer(owner(), withdrawAmount);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unPause() public onlyOwner {
        _unpause();
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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}