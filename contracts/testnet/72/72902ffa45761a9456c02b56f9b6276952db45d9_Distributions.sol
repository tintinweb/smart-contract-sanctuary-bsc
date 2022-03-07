// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract Distributions is OwnableUpgradeable {
    uint16 public exerciseFeeRatio;
    uint16 public withdrawFeeRatio;
    uint16 public redeemFeeRatio;
    uint8 public bulletToRewardRatio;
    uint16 public hodlWithdrawFeeRatio;

    struct Distribution {
        uint8 percentage;
        address to;
    }

    Distribution[] public feeDistribution;
    Distribution[] public bulletDistribution;
    Distribution[] public hodlWithdrawFeeDistribution;

    uint256 public feeDistributionLength;
    uint256 public bulletDistributionLength;
    uint256 public hodlWithdrawFeeDistributionLength;

    event ExerciseFeeRatioChanged(uint16 oldExerciseFeeRatio, uint16 newExerciseFeeRatio);
    event WithdrawFeeRatioChanged(uint16 oldWithdrawFeeRatio, uint16 newWithdrawFeeRatio);
    event RedeemFeeRatioChanged(uint16 oldRedeemFeeRatio, uint16 newRedeemFeeRatio);
    event HodlWithdrawFeeRatioChanged(uint16 oldHodlWithdrawFeeRatio, uint16 newHodlWithdrawFeeRatio);
    event BulletToRewardRatioChanged(uint8 oldBulletToRewardRatio, uint8 newBulletToRewardRatio);
    event FeeDistributionSetted(uint8[] percentage, address[] to);
    event BulletDistributionSetted(uint8[] percentage, address[] to);
    event HodlWithdrawFeeDistributionSetted(uint8[] percentage, address[] to);

    function __Distributions_init() public initializer {
        __Ownable_init();
        bulletToRewardRatio = 80;
    }

    function setExerciseFee(uint16 _feeRatio) external onlyOwner {
        require(0 <= _feeRatio && _feeRatio < 10000, "Distributions: Illegal value range");

        uint16 oldFeeRatio = exerciseFeeRatio;
        exerciseFeeRatio = _feeRatio;
        emit ExerciseFeeRatioChanged(oldFeeRatio, exerciseFeeRatio);
    }

    function setWithdrawFee(uint16 _feeRatio) external onlyOwner {
        require(0 <= _feeRatio && _feeRatio < 10000, "Distributions: Illegal value range");

        uint16 oldFeeRatio = withdrawFeeRatio;
        withdrawFeeRatio = _feeRatio;
        emit WithdrawFeeRatioChanged(oldFeeRatio, withdrawFeeRatio);
    }

    function setRedeemFee(uint16 _feeRatio) external onlyOwner {
        require(0 <= _feeRatio && _feeRatio < 10000, "Distributions: Illegal value range");

        uint16 oldFeeRatio = redeemFeeRatio;
        redeemFeeRatio = _feeRatio;
        emit RedeemFeeRatioChanged(oldFeeRatio, redeemFeeRatio);
    }

    function setHodlWithdrawFee(uint16 _feeRatio) external onlyOwner {
        require(0 <= _feeRatio && _feeRatio < 10000, "Distributions: Illegal value range");

        uint16 oldFeeRatio = hodlWithdrawFeeRatio;
        hodlWithdrawFeeRatio = _feeRatio;
        emit HodlWithdrawFeeRatioChanged(oldFeeRatio, hodlWithdrawFeeRatio);
    }

    function setBulletToRewardRatio(uint8 _bulletToRewardRatio) external onlyOwner {
        require(0 <= _bulletToRewardRatio && _bulletToRewardRatio <= 80, "Distributions: Illegal value range");

        uint8 oldBulletToRewardRatio = bulletToRewardRatio;
        bulletToRewardRatio = _bulletToRewardRatio;
        emit BulletToRewardRatioChanged(oldBulletToRewardRatio, bulletToRewardRatio);
    }

    function setFeeDistribution(uint8[] memory _percentage, address[] memory _to) external onlyOwner {
        require(_percentage.length == _to.length, "Distributions: array length not match");
        uint8 sum;
        for (uint8 i = 0; i < _percentage.length; i++) {
            sum += _percentage[i];
        }
        require(sum == 100, "Distributions: sum of percentage not 100");
        delete feeDistribution;
        for (uint8 j = 0; j < _percentage.length; j++) {
            uint8 percentage = _percentage[j];
            address to = _to[j];
            Distribution memory distribution = Distribution({percentage: percentage, to: to});
            feeDistribution.push(distribution);
        }
        feeDistributionLength = _percentage.length;
        emit FeeDistributionSetted(_percentage, _to);
    }

    function setBulletDistribution(uint8[] memory _percentage, address[] memory _to) external onlyOwner {
        require(_percentage.length == _to.length, "Distributions: array length not match");
        uint8 sum;
        for (uint8 i = 0; i < _percentage.length; i++) {
            sum += _percentage[i];
        }
        require(sum == 100, "Distributions: sum of percentage not 100");
        delete bulletDistribution;
        for (uint8 j = 0; j < _percentage.length; j++) {
            uint8 percentage = _percentage[j];
            address to = _to[j];
            Distribution memory distribution = Distribution({percentage: percentage, to: to});
            bulletDistribution.push(distribution);
        }
        bulletDistributionLength = _percentage.length;
        emit BulletDistributionSetted(_percentage, _to);
    }

    function setHodlWithdrawFeeDistribution(uint8[] memory _percentage, address[] memory _to) external onlyOwner {
        require(_percentage.length == _to.length, "Distributions: array length not match");
        uint8 sum;
        for (uint8 i = 0; i < _percentage.length; i++) {
            sum += _percentage[i];
        }
        require(sum == 100, "Distributions: sum of percentage not 100");
        delete hodlWithdrawFeeDistribution;
        for (uint8 j = 0; j < _percentage.length; j++) {
            uint8 percentage = _percentage[j];
            address to = _to[j];
            Distribution memory distribution = Distribution({percentage: percentage, to: to});
            hodlWithdrawFeeDistribution.push(distribution);
        }
        hodlWithdrawFeeDistributionLength = _percentage.length;
        emit HodlWithdrawFeeDistributionSetted(_percentage, _to);
    }
}

// SPDX-License-Identifier: MIT

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
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

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
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}