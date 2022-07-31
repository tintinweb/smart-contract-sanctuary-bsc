// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./interfaces/IGymMLM.sol";

/**
 * @notice Turnover pool contract:
 * Stores information about
 */
contract TurnoverPool is ReentrancyGuardUpgradeable, OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    event DistributeRewards(address indexed user, uint256 amount);

    event UpdateUserLvl(address indexed user, uint8 level);

    event Whitelisted(address indexed wallet, bool whitelist);

    /**
     * @notice Information of qualification parametrs
     * @param regionalNumber: number of users with regional qualification
     * @param nationalNumber: number of users with national qualification
     * @param internationalNumber: number of users with international qualification
     */
    struct QualificationInfo {
        uint256 valueAmount;
        uint8 percent;
    }

    address public tokenAddress;
    address public mlmAddress;
    address public bankAddress;
    address public farmingAddress;
    address public singlePoolAddress;

    // mapping for store qualification info by level (1 - Regional, 2 - National, 3 - International)
    mapping(uint256 => QualificationInfo) public qualificationInfoByLevel;
    // mapping for store number of qualified users (1 - Regional, 2 - National, 3 - International)
    mapping(uint256 => uint256) public usersQualifiedNumber;
    // mapping for store user qualification level (1 - Regional, 2 - National, 3 - International)
    mapping(address => uint256) public userQualificationLevel;
    // mapping for store user tree investment by address and level (0 - Own, 1 - Regional, 2 - National, 3 - International)
    mapping(address => mapping(uint8 => uint256)) public userTreeInvestment;
    // mapping for store user address for distribute rewards by mount
    mapping(uint256 => address[]) private usersForDistribution;

    mapping(address => bool) private whitelist;

    modifier onlyWhitelisted() {
        require(
            whitelist[msg.sender] || msg.sender == owner(),
            "GymTurnoverPool: not whitelisted or owner"
        );
        _;
    }

    modifier onlyRelatedContracts() {
        require(
            msg.sender == bankAddress ||
                msg.sender == singlePoolAddress ||
                msg.sender == farmingAddress,
            "GymTurnoverPool:: Only related accounts can call the method"
        );
        _;
    }

    function initialize() external initializer {
        qualificationInfoByLevel[1] = QualificationInfo({valueAmount: 500, percent: 50});
        qualificationInfoByLevel[2] = QualificationInfo({valueAmount: 1000, percent: 33});
        qualificationInfoByLevel[3] = QualificationInfo({valueAmount: 5000, percent: 17});

        __Ownable_init();
        __ReentrancyGuard_init();
    }

    receive() external payable {}

    fallback() external payable {}

    function setTokenAddress(address _address) external onlyOwner {
        tokenAddress = _address;
    }

    function setMLMAddress(address _address) external onlyOwner {
        mlmAddress = _address;
    }

    function setBankAddress(address _address) external onlyOwner {
        bankAddress = _address;
    }

    function setSinglePoolAddress(address _address) external onlyOwner {
        singlePoolAddress = _address;
    }

    function setFarmingAddress(address _address) external onlyOwner {
        farmingAddress = _address;
    }

    /**
     * @notice Add or remove wallet to/from whitelist, callable only by contract owner
     *         whitelisted wallet will be able to call functions
     *         marked with onlyWhitelisted modifier
     * @param _wallet wallet to whitelist
     * @param _whitelist boolean flag, add or remove to/from whitelist
     */
    function whitelistWallet(address _wallet, bool _whitelist) external onlyOwner {
        whitelist[_wallet] = _whitelist;

        emit Whitelisted(_wallet, _whitelist);
    }

    /**
     * @notice Function to set qualification inforamtion by level
     * @param _level: level type (
                1 - Regional,
                2 - National,
                3 - International
       )
     * @param _valueAmount: amount of minimum value in BNB
     * @param _percent: percent of amount
     */
    function setQualificationInfoByLevel(
        uint8 _level,
        uint256 _valueAmount,
        uint8 _percent
    ) external onlyOwner {
        require(_level > 0, "GymTurnoverPool:: level type must more than zero");
        qualificationInfoByLevel[_level] = QualificationInfo({
            valueAmount: _valueAmount,
            percent: _percent
        });
    }

    /**
     * @notice Function to set user for distributions in this month
     * @param _month: month
     * @param _users: users array
     */
    function setUsersForDistribution(uint256 _month, address[] calldata _users)
        external
        onlyWhitelisted
    {
        for (uint256 i; i < _users.length; i++) {
            usersForDistribution[_month].push(_users[i]);
        }
    }

    /**
     * @notice Function to distrubute rewards
     * @param _month: month id fo distribution
     */
    function distributeRewards(uint256 _month) external onlyWhitelisted {
        require(usersForDistribution[_month].length != 0, "GymTurnoverPool:: Invalid month");
        _distributeRewards(_month);
    }

    function updateInvestment(
        address _userAddress,
        uint256 _amount,
        bool _increase
    ) external onlyRelatedContracts {
        address[] memory _referrers = IGymMLM(mlmAddress).getReferrals(_userAddress);
        _updateInvestment(_referrers, _userAddress, _amount, _increase);
        _updateUserLevel(_referrers);
    }

    /**
     * @notice Function to get user number by qualification
     * @return regionalNumber number of users with regional qualification
     * @return nationalNumber number of users with national qualification
     * @return internationalNumber number of users with international qualification
     */
    function calculateQualifiedCandidates()
        external
        view
        returns (
            uint256 regionalNumber,
            uint256 nationalNumber,
            uint256 internationalNumber
        )
    {
        return (usersQualifiedNumber[1], usersQualifiedNumber[2], usersQualifiedNumber[3]);
    }

    /**
     * @notice  Function to get all pending rewards
     * @return all pending rewards
     */
    function getPendingRewardsTotal() external view returns (uint256) {
        return _getPendingRewardsTotal();
    }

    /**
     * @notice  Function to get all pending rewards by user
     * @return user pending rewards
     */
    function getUserPendingRewards() external view returns (uint256) {
        uint256 _type = userQualificationLevel[msg.sender];
        uint256 _totalRewardsByType = _getPendingRewardsByType(_type);
        return _getAmountByNumberAndType(_type, _totalRewardsByType);
    }

    /**
     * @notice Private function to get pending reards by type
     * @param _type: type of pending rewards (
                1 - Regional,
                2 - National,
                3 - International
       )
     */
    function getPendingRewardsByType(uint256 _type) external view returns (uint256) {
        return _getPendingRewardsByType(_type);
    }

    /**
     * @notice Function to distribute rewards
     * @param _month: month id fo distribution
     */
    function _distributeRewards(uint256 _month) private {
        address[] memory _users = usersForDistribution[_month];
        uint256[3] memory _pendingAmount = [
            _getPendingRewardsByType(1),
            _getPendingRewardsByType(2),
            _getPendingRewardsByType(3)
        ];
        for (uint256 i; i < _users.length; i++) {
            uint256 _userType = userQualificationLevel[_users[i]];
            if (_userType > 0) {
                uint256 _amount = _getAmountByNumberAndType(
                    _userType,
                    _pendingAmount[_userType - 1]
                );
                IERC20Upgradeable(tokenAddress).safeTransfer(_users[i], _amount);
                emit DistributeRewards(_users[i], _amount);
            }
        }
    }

    /**
     * @notice Private function to update investment
     * @param _referrers: array of referres address
     * @param _userAddress: user address
     * @param _amount: amount
     * @param _increase: boolean flag
     */
    function _updateInvestment(
        address[] memory _referrers,
        address _userAddress,
        uint256 _amount,
        bool _increase
    ) private {
        uint256 _oldInvestment = userTreeInvestment[_userAddress][0];
        uint256 _newInvestment;
        if (_increase) {
            _newInvestment = _oldInvestment + _amount;
            _updateInverstmentWithIncrease(_referrers, _newInvestment, _amount, _oldInvestment);
        } else {
            _newInvestment = _oldInvestment - _amount;
            _updateInverstmentWithDecrease(_referrers, _newInvestment, _amount, _oldInvestment);
        }
        userTreeInvestment[_userAddress][0] = _newInvestment;
    }

    /**
     * @notice Private function to helt update investment with increase
     * @param _referrers: array of referres address
     * @param _newInvestment: amount of new investment
     * @param _amount: amount
     * @param _oldInvestment: amount of old investment
     */
    function _updateInverstmentWithIncrease(
        address[] memory _referrers,
        uint256 _newInvestment,
        uint256 _amount,
        uint256 _oldInvestment
    ) private {
        for (uint8 i = 1; i <= 3; i++) {
            if (_newInvestment <= qualificationInfoByLevel[i].valueAmount / 2) {
                for (uint256 j = 0; j < _referrers.length; j++) {
                    userTreeInvestment[_referrers[j]][i] =
                        userTreeInvestment[_referrers[j]][i] +
                        _amount;
                }
            } else if (
                _oldInvestment < qualificationInfoByLevel[i].valueAmount / 2 &&
                _newInvestment > qualificationInfoByLevel[i].valueAmount / 2
            ) {
                for (uint256 j = 0; j < _referrers.length; j++) {
                    userTreeInvestment[_referrers[j]][i] =
                        userTreeInvestment[_referrers[j]][i] +
                        (qualificationInfoByLevel[i].valueAmount / 2 - _oldInvestment);
                }
            }
        }
    }

    /**
     * @notice Private function to helt update investment with decrease
     * @param _referrers: array of referres address
     * @param _newInvestment: amount of new investment
     * @param _amount: amount
     * @param _oldInvestment: amount of old investment
     */
    function _updateInverstmentWithDecrease(
        address[] memory _referrers,
        uint256 _newInvestment,
        uint256 _amount,
        uint256 _oldInvestment
    ) private {
        for (uint8 i = 1; i <= 3; i++) {
            if (
                _oldInvestment >= qualificationInfoByLevel[i].valueAmount / 2 &&
                _newInvestment < qualificationInfoByLevel[i].valueAmount / 2
            ) {
                for (uint256 j = 0; j < _referrers.length; j++) {
                    userTreeInvestment[_referrers[j]][i] =
                        userTreeInvestment[_referrers[j]][i] -
                        (qualificationInfoByLevel[i].valueAmount / 2 - _newInvestment);
                }
            } else {
                for (uint256 j = 0; j < _referrers.length; j++) {
                    userTreeInvestment[_referrers[j]][i] =
                        userTreeInvestment[_referrers[j]][i] -
                        _amount;
                }
            }
        }
    }

    /**
     * @notice Function to update user level
     * @param _userAddresses: array of user address
     */
    function _updateUserLevel(address[] memory _userAddresses) private {
        for (uint256 i = 0; i < _userAddresses.length; i++) {
            uint8 _level = _calculateQualification(_userAddresses[i]);
            uint256 _oldUserLevel = userQualificationLevel[_userAddresses[i]];
            if (_level != _oldUserLevel) {
                usersQualifiedNumber[_level] = ++usersQualifiedNumber[_level];
                if (_oldUserLevel != 0) {
                    usersQualifiedNumber[_oldUserLevel] = --usersQualifiedNumber[_oldUserLevel];
                }
                userQualificationLevel[_userAddresses[i]] = _level;
                emit UpdateUserLvl(_userAddresses[i], _level);
            }
        }
    }

    /**
     * @notice Private function to get calculate user level qualification
     * @param _userAddress: user address
     * @return  user qualification level
     */
    function _calculateQualification(address _userAddress) private view returns (uint8) {
        uint8 _userLevel;
        for (uint8 i = 1; i <= 3; i++) {
            if (userTreeInvestment[_userAddress][i] >= qualificationInfoByLevel[i].valueAmount) {
                _userLevel = i;
            } else {
                break;
            }
        }
        return _userLevel;
    }

    /**
     * @notice Private function to amount by type and users number
     * @param _type: type of  rewards (
                1 - Regional,
                2 - National,
                3 - International
       )
     * @param _amount: amount
     * @return amount
     */
    function _getAmountByNumberAndType(uint256 _type, uint256 _amount)
        private
        view
        returns (uint256)
    {
        uint256 _usersNumber;
        if (_type == 1) {
            _usersNumber =
                usersQualifiedNumber[1] +
                usersQualifiedNumber[2] +
                usersQualifiedNumber[3];
        } else if (_type == 2) {
            _usersNumber = usersQualifiedNumber[2] + usersQualifiedNumber[3];
        } else if (_type == 3) {
            _usersNumber = usersQualifiedNumber[3];
        } else {
            return 0;
        }

        return _amount / _usersNumber;
    }

    /**
     * @notice Private function to get total pending rewards
     * @return total pending rewards
     */
    function _getPendingRewardsTotal() private view returns (uint256) {
        return IERC20Upgradeable(tokenAddress).balanceOf(address(this));
    }

    /**
     * @notice Private function to get pending rewards by type
     * @param _type: type of pending rewards (
                1 - Regional,
                2 - National,
                3 - International
       )
     */
    function _getPendingRewardsByType(uint256 _type) private view returns (uint256) {
        uint256 _amount = _getPendingRewardsTotal();
        return (_amount * qualificationInfoByLevel[_type].percent) / 100;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IGymMLM {
    function addGymMLM(address, uint256) external;

    function addGymMLMNFT(address, uint256) external;

    function distributeRewards(
        uint256,
        address,
        address,
        uint32
    ) external;

    function updateInvestment(address _user, bool _isInvesting) external;

    function getPendingRewards(address, uint32) external view returns (uint256);

    function getReferrals(address) external view returns (address[] memory);

    function hasInvestment(address) external view returns (bool);

    function addressToId(address) external view returns (uint256);
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

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
        bool isTopLevelCall = _setInitializedVersion(1);
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
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
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
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
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