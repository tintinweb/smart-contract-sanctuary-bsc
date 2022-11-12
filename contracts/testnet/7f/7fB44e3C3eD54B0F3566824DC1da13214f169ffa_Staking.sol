// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface Token {
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);
}

contract Staking is Pausable, ReentrancyGuard {
    Token token;

    address public admin;
    uint256 totalAmountStaked;
    uint256 stakerId;

    struct Stakers {
        address staker;
        uint256 stakerId;
        uint256 dateCreated;
        uint256 amountStaked;
        bool claimed;
    }

    mapping(uint256 => Stakers) public stakers;
    mapping(address => uint256[]) public stakerIdsByAddress;
    mapping(uint256 => uint256) public levels;

    uint256[] public lockPeriods;

    event Staked(address _staker, uint256 _amount);
    event Withdraw(address _withdrawer, uint256 _amount);

    constructor(Token _address) {
        admin = msg.sender;
        token = _address;

        levels[2] = 300; // 3%
        levels[4] = 600; // 6%
        levels[7] = 1000; // 10%

        lockPeriods.push(2);
        lockPeriods.push(4);
        lockPeriods.push(7);

        totalAmountStaked = 0;
        stakerId = 0;
    }

    receive() external payable {
        revert("No known transaction");
    }

    function stakeChakra(uint256 _amount) external {
        require(msg.sender != address(0), "Address cannot be the zero address");
        require(_amount >= 1 ether, "Value must be greater than 0");

        token.transferFrom(msg.sender, address(this), _amount);
        stakerId += 1;
        stakers[stakerId] = Stakers(
            msg.sender,
            stakerId,
            block.timestamp,
            _amount,
            false
        );

        stakerIdsByAddress[msg.sender].push(stakerId);
        totalAmountStaked += _amount;

        emit Staked(msg.sender, stakers[stakerId].amountStaked);
    }

    function calculateInterest(uint256 _amount, uint256 _stakerId)
        private
        view
        returns (uint256)
    {
        uint256 totalTimeStaked = (block.timestamp -
            stakers[_stakerId].dateCreated) /
            60 /
            60 /
            24;
        uint256 interest = 0;

        for (uint256 i = 0; i <= lockPeriods.length - 1; i++) {
            if (
                totalTimeStaked >= lockPeriods[i] &&
                totalTimeStaked < lockPeriods[i + 1]
            ) {
                interest = levels[lockPeriods[i]];
            }

            if (i + 1 > lockPeriods.length - 1) {
                interest = levels[7];
            }
        }

        return (interest * _amount) / 10000;
    }

    function getInterestRate(uint256 _stakerId)
        external
        view
        returns (uint256)
    {
        uint256 ans = 0;
        uint256 totalTimeStaked = (block.timestamp -
            stakers[_stakerId].dateCreated) /
            60 minutes /
            24 hours;
        for (uint256 i = 0; i < lockPeriods.length - 1; i++) {
            if (
                i == lockPeriods.length - 1 && totalTimeStaked > lockPeriods[i]
            ) {
                ans = levels[i];
            }
            if (
                totalTimeStaked >= lockPeriods[i] &&
                totalTimeStaked < lockPeriods[i + 1]
            ) {
                ans = levels[i];
            }
        }
        return ans;
    }

    function updateStakePeriod(uint256 _numOfDays, uint256 _interest)
        external
        onlyOwner
    {
        levels[_numOfDays] = _interest;
        lockPeriods.push(_numOfDays);
    }

    function getStakeperiods()
        external
        view
        onlyOwner
        returns (uint256[] memory)
    {
        return lockPeriods;
    }

    function getStakerIdsByAddresses(address _address)
        internal
        view
        returns (uint256[] memory)
    {
        return stakerIdsByAddress[_address];
    }

    function amountEarned(address _staker)
        external
        view
        returns (uint256 amount)
    {
        uint256[] memory stakersIds = getStakerIdsByAddresses(_staker);
        for (uint256 i; i < stakersIds.length; ) {
            amount =
                amount +
                (stakers[stakersIds[i]].amountStaked +
                    calculateInterest(
                        stakers[stakersIds[i]].amountStaked,
                        stakersIds[i]
                    ));
            unchecked {
                ++i;
            }
        }
        return amount;
    }

    function withdrawChakra() external nonReentrant {
        address staker = msg.sender;
        uint256 amount;
        uint256 comission = 0;

        unchecked {
            uint256[] memory stakersIds = getStakerIdsByAddresses(staker);

            for (uint256 i; i < stakersIds.length; ++i) {
                if (stakers[stakersIds[i]].claimed == false) {
                    amount =
                        amount +
                        (stakers[stakersIds[i]].amountStaked +
                            calculateInterest(
                                stakers[stakersIds[i]].amountStaked,
                                stakersIds[i]
                            ));
                    amount = amount - 100 wei;
                    comission += 100 wei;
                    stakers[stakersIds[i]].claimed = true;
                }
            }
            token.transfer(msg.sender, amount);
            token.transfer(admin, comission);
        }

        emit Withdraw(staker, amount);

        // payable(msg.sender).transfer(stakers[_id].amountStaked + interest);
    }

    function getTotalVolume() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function totalStakedAmount() external view returns (uint256) {
        return totalAmountStaked;
    }

    function pause() external onlyOwner {
        _pause();
    }

    // function to unpause the contract after any issue which occurs gets resolved
    function unpause() external onlyOwner {
        _unpause();
    }

    modifier onlyOwner() {
        require(admin == msg.sender, "Only owner can change it");
        _;
    }

    fallback() external payable {
        revert("No known transaction");
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

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