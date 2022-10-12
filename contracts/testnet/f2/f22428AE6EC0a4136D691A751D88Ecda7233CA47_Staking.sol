// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// interface Token {
//     function transferFrom(
//         address _from,
//         address _to,
//         uint256 _value
//     ) public whenNotPaused returns (bool) {}

//     function balanceOf(address _owner) public view returns (uint256 balance) {}

//     function transfer(address _to, uint256 _value)
//         public
//         whenNotPaused
//         returns (bool)
//     {}
// }

// client token interface
interface Token {
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);
}

contract Staking is Pausable, ReentrancyGuard {
    Token token;

    address public admin;

    struct Stakers {
        uint256 stakerId;
        address stakerAddress;
        uint256 dateCreated;
        uint256 amountStaked;
        bool open;
    }
    Stakers staker;

    uint256 private totalStakers = 0;

    // struct User {
    //     bool referred;
    //     address referred_by;
    // }

    // struct Referal_levels {
    //     uint256 level_1;
    //     uint256 level_2;
    //     uint256 level_3;
    //     uint256 level_4;
    // }

    // mapping(address => Referal_levels) public refer_info;
    // mapping(address => User) public user_info;

    mapping(address => bool) internal referral_info;

    mapping(uint256 => Stakers) public stakers;
    mapping(address => uint256[]) public stakerIdsByAddress;
    mapping(uint256 => uint256) public levels;

    uint256[] public lockPeriods;

    event Staked(address _staker, uint256 _amount);
    event Withdraw(
        address _withdrawer,
        uint256 _amount,
        uint256 _interestEarned
    );

    constructor(Token _address) {
        admin = msg.sender;
        token = _address;

        levels[2] = 300; // 3%
        levels[4] = 600; // 6%
        levels[7] = 1000; // 10%

        lockPeriods.push(2);
        lockPeriods.push(4);
        lockPeriods.push(7);
    }

    modifier onlyOwner() {
        require(admin == msg.sender, "Only owner can change it");
        _;
    }

    function stakePotato(uint256 _amount) external whenNotPaused {
        require(msg.sender != address(0), "Address cannot be 0 address");
        require(_amount >= 0 wei, "Value must be greater than 0");

        token.transferFrom(msg.sender, address(this), _amount);
        // bool success = token.call(
        //     abi.encodeWithSignature(
        //         "transferFrom(address,address,uint256)",
        //         msg.sender,
        //         address(this),
        //         _amount
        //     )
        // );

        stakers[totalStakers] = Stakers(
            totalStakers,
            msg.sender,
            block.timestamp,
            _amount,
            true
        );

        referral(msg.sender);

        stakerIdsByAddress[msg.sender].push(totalStakers);
        totalStakers++;

        emit Staked(msg.sender, stakers[totalStakers - 1].amountStaked);
    }

    function getTotalVolume() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function calculateInterest(uint256 _id, uint256 _amount)
        private
        view
        returns (uint256)
    {
        uint256 totalTimeStaked = (block.timestamp - stakers[_id].dateCreated) /
            60 minutes /
            24 hours;
        uint256 interest = 0;

        for (uint256 i = 0; i <= lockPeriods.length - 1; i++) {
            if (i + 1 > lockPeriods.length - 1) {
                interest = levels[7];
            }
            if (
                totalTimeStaked >= lockPeriods[i] &&
                totalTimeStaked < lockPeriods[i + 1]
            ) {
                interest = levels[lockPeriods[i]];
            }
        }

        return (interest * _amount) / 10000;
    }

    function getInterestRate(uint256 _id) external view returns (uint256) {
        uint256 ans = 0;
        uint256 totalTimeStaked = (block.timestamp - stakers[_id].dateCreated) /
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

    function getStakersById(uint256 _stakerId)
        external
        view
        returns (Stakers memory)
    {
        return stakers[_stakerId];
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
        external
        view
        returns (uint256[] memory)
    {
        return stakerIdsByAddress[_address];
    }

    function withdrawPotato(uint256 _id) external nonReentrant {
        require(
            stakers[_id].stakerAddress == msg.sender,
            "You are not the staker"
        );
        require(stakers[_id].open == true, "Potato already withdrawn");

        unchecked {
            uint256 commissionAmount = 100 wei;

            uint256 interest = calculateInterest(
                _id,
                stakers[_id].amountStaked
            );
            stakers[_id].open = false;

            stakers[_id].amountStaked -= commissionAmount;
            token.transfer(msg.sender, stakers[_id].amountStaked + interest);
            token.transfer(admin, commissionAmount);

            emit Withdraw(
                msg.sender,
                stakers[_id].amountStaked + interest,
                interest
            );
        }

        // payable(msg.sender).transfer(stakers[_id].amountStaked + interest);
    }

    function referral(address ref_add) internal {
        // require(user_info[msg.sender].referred == false, " Already referred ");
        // require(ref_add != msg.sender, " You cannot refer yourself ");
        // user_info[msg.sender].referred_by = ref_add;
        // user_info[msg.sender].referred = true;
        // address level1 = user_info[msg.sender].referred_by;
        // address level2 = user_info[level1].referred_by;
        // address level3 = user_info[level2].referred_by;
        // address level4 = user_info[level3].referred_by;
        // if ((level1 != msg.sender) && (level1 != address(0))) {
        //     refer_info[level1].level_1 += 1;
        // }
        // if ((level2 != msg.sender) && (level2 != address(0))) {
        //     refer_info[level2].level_2 += 1;
        // }
        // if ((level3 != msg.sender) && (level3 != address(0))) {
        //     refer_info[level3].level_3 += 1;
        // }
        // if ((level4 != msg.sender) && (level4 != address(0))) {
        //     refer_info[level4].level_4 += 1;
        // }
        // require(referral_info[ref_add] == false, "referral already paid");
        // if(level == 1) {
        //     token.transferFrom(address(this), level.address, ((stakers[totalStakers].amountStaked * 7) / 100));
        // }
        // if(level == 2) {
        //     token.transferFrom(address(this), level.address, ((stakers[totalStakers].amountStaked * 5) / 100));
        // }
        // if(level == 3) {
        //     token.transferFrom(address(this), level.address, ((stakers[totalStakers].amountStaked * 4) / 100));
        // }
        // if(level == 4) {
        //     token.transferFrom(address(this), level.address, ((stakers[totalStakers].amountStaked * 2) / 100));
        // }
        // if(level == 5) {
        //     token.transferFrom(address(this), level.address, ((stakers[totalStakers].amountStaked * (5 / 10)) / 100));
        // }
        // referral_info[ref_add] = true;
    }

    function pause() external onlyOwner {
        _pause();
    }

    // function to unpause the contract after any issue which occurs gets resolved
    function unpause() external onlyOwner {
        _unpause();
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