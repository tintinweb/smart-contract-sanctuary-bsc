//SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "../utils/Ownable.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/IReflectionsDistributor.sol";

contract StakingTreasury is Ownable {
    address public stakingVault;
    uint256 public totalStakedBalance;
    uint256 public minAmountReflection = 1000 * 10**9;

    IReflectionsDistributor public reflectionsDistributor;
    IERC20 public stakeToken;

    event LogDeposit(address user, uint256 amount);
    event LogWithdrawal(address user, uint256 amount);
    event LogSetStakingVault(address stakingVault);
    event LogSetStakeToken(address indexed stakeToken);
    event LogSetMinAmountReflection(uint256 minAmountReflection);
    event LogSetReflectionsDistributor(address reflectionsDistributor);

    constructor(
        address _stakingVault,
        IERC20 _stakeToken,
        IReflectionsDistributor _reflectionsDistributor
    ) {
        require(
            _stakingVault != address(0) && 
            address(_stakeToken) != address(0) && 
            address(_reflectionsDistributor) != address(0), 
            "ZERO_ADDRESS"
        );
        stakeToken = _stakeToken;
        stakingVault = _stakingVault;
        reflectionsDistributor = _reflectionsDistributor;
    }

    /**
     * @dev Throws if called by any account other than the owner or deployer.
     */
    modifier onlyStakingVault() {
        require(
            _msgSender() == stakingVault,
            "StakingTresuary: caller is not the stakingVault"
        );
        _;
    }

    function transferReflections() internal {
        uint256 reflections = stakeToken.balanceOf(address(this)) -
            totalStakedBalance;

        /**
         * @notice Transfers accumulated reflections to the reflectionsDistributor
         * if the amount is reached
         */
        if (reflections >= minAmountReflection) {
            require(
                stakeToken.transfer(
                    address(reflectionsDistributor),
                    reflections
                ),
                "Transfer fail"
            );
        }
    }

    function deposit(address staker, uint256 amount, uint256 stakeAmount) external onlyStakingVault {
        transferReflections();

        require(
            stakeToken.transferFrom(staker, address(this), amount),
            "TransferFrom fail"
        );
        totalStakedBalance += amount;

        reflectionsDistributor.deposit(staker, amount, stakeAmount);

        emit LogDeposit(staker, amount);
    }

    function withdraw(address staker, uint256 amount, uint256 stakeAmount)
        external
        onlyStakingVault
    {
        transferReflections();

        require(stakeToken.transfer(staker, amount), "Transfer fail");
        totalStakedBalance -= amount;

        reflectionsDistributor.withdraw(staker, amount, stakeAmount);
        emit LogWithdrawal(staker, amount);
    }

    function setStakingVault(address _stakingVault) external onlyMultiSig {
        require(_stakingVault != address(0), "ZERO_ADDRESS");
        require(_stakingVault != address(stakingVault), "SAME_ADDRESS");
        stakingVault = _stakingVault;
        emit LogSetStakingVault(stakingVault);
    }

    function setStakeToken(address _stakeToken) external onlyMultiSig {
        require(_stakeToken != address(0), "ZERO_ADDRESS");
        require(_stakeToken != address(stakeToken), "SAME_ADDRESS");
        stakeToken = IERC20(_stakeToken);

        emit LogSetStakeToken(_stakeToken);
    }

    function setMinAmountReflection(uint256 _minAmountReflection)
        external
        onlyMultiSig
    {
        require(minAmountReflection != _minAmountReflection, "SAME_VALUE");
        minAmountReflection = _minAmountReflection;
        emit LogSetMinAmountReflection(minAmountReflection);
    }

    function setReflectionsDistributor(
        IReflectionsDistributor _reflectionsDistributor
    ) external onlyMultiSig {
        require(address(_reflectionsDistributor) != address(0), "ZERO_ADDRESS");
        require(address(_reflectionsDistributor) != address(reflectionsDistributor), "SAME_ADDRESS");
        reflectionsDistributor = _reflectionsDistributor;
        emit LogSetReflectionsDistributor(address(reflectionsDistributor));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity 0.8.7;

import "./Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyMultiSig`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    /**
     * @dev Must be Multi-Signature Wallet.
     */
    address private _multiSigOwner;

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
    modifier onlyMultiSig() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _multiSigOwner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyMultiSig` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() external virtual onlyMultiSig {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external virtual onlyMultiSig {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _multiSigOwner;
        _multiSigOwner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity 0.8.7;

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
pragma solidity 0.8.7;

interface IReflectionsDistributor {
    function deposit(address _user, uint256 _amount, uint256 _userAmount) external;

    function withdraw(address _user, uint256 _amount, uint256 _userAmount) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity 0.8.7;

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
}