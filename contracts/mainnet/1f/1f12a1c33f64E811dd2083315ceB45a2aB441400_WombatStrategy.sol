// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

import "./IStrategy.sol";
import "../protocols/BnbX/IStakeManager.sol";
import "../protocols/Wombat/IWombatPool.sol";
import "../protocols/Wombat/IWombatMaster.sol";

contract WombatStrategy is IStrategy {
    IERC20Upgradeable public bnbX;
    IStakeManager public stakeManager;
    IWombatPool public wombatPool;
    IWombatMaster public wombatMaster;

    // Accounting
    uint256 public totalDepositsInBnb;
    uint256 public totalDepositsInBnbX;
    uint256 public totalWombatLP;
    uint256 public totalRewardsInBnbX;
    mapping(address => uint256) public userDepositsInBnb;
    mapping(address => uint256) public userBalances;

    constructor(
        address _bnbX,
        address _stakeManager,
        address _wombatPool,
        address _wombatMaster
    ) {
        bnbX = IERC20Upgradeable(_bnbX);
        stakeManager = IStakeManager(_stakeManager);
        wombatPool = IWombatPool(_wombatPool);
        wombatMaster = IWombatMaster(_wombatMaster);
    }

    // 1. Deposit BNB
    // 2. Convert BNB -> BNBX through Stader StakeManager
    // 3. Deposit BNBX to Wombat Pool. Receive Wombat LP token
    // 4. Deposit and stake Wombat LP token to Wombat Master
    function deposit() external payable override {
        require(msg.value > 0, "Zero BNB");

        uint256 depositInBnb = msg.value;
        uint256 bnbxAmountBefore = bnbX.balanceOf(address(this));
        stakeManager.deposit{value: depositInBnb}();
        uint256 bnbxAmountAfter = bnbX.balanceOf(address(this)) -
            bnbxAmountBefore;

        // Deposit bnbX to Wombat Liquidity Pool and get Wombat Liquidity Pool token back
        require(bnbxAmountAfter > bnbxAmountBefore, "No new bnbx minted");
        uint256 bnbxAmount = bnbxAmountAfter - bnbxAmountBefore;
        bnbX.approve(address(wombatPool), bnbxAmount);
        uint256 wombatLPAmount = wombatPool.deposit(
            address(bnbX),
            bnbxAmount,
            0,
            address(this),
            block.timestamp,
            false // Is is an experimental feature therefore we do it ourselves below.
        );

        // Deposit and stake Wombat Liquidity Pool token on Wombat Master
        uint256 pid = wombatMaster.getAssetPid(address(bnbX));
        wombatMaster.deposit(pid, wombatLPAmount);

        totalDepositsInBnb += depositInBnb;
        totalDepositsInBnbX += bnbxAmount;
        totalWombatLP += wombatLPAmount;
        userDepositsInBnb[msg.sender] += depositInBnb;
        userBalances[msg.sender] += convertBnbToVault(depositInBnb);
    }

    // 1. Convert Vault balance to BnbX
    // 2. Convert BnbX to Bnb
    function withdraw(uint256 _amount) external override returns (uint256) {
        uint256 amountInBnbX = _withdrawInBnbX(_amount);

        return amountInBnbX;
    }

    // 1. Withdraw Vault in BnbX
    // 2. Send BnbX to user
    function withdrawInBnbX(uint256 _amount) external returns (uint256) {
        uint256 amountInBnbX = _withdrawInBnbX(_amount);
        bnbX.transfer(msg.sender, amountInBnbX);

        return amountInBnbX;
    }

    // 1. Convert Vault balance to Wombat LP token amount
    // 2. Withdraw Wombat LP token from Wombat Master
    // 3. Withdraw BNBX from Wombat Pool via sending the Wombat LP token
    function _withdrawInBnbX(uint256 _amount) private returns (uint256) {
        require(userBalances[msg.sender] >= _amount, "Insufficient balance");

        userBalances[msg.sender] -= _amount;
        uint256 pid = wombatMaster.getAssetPid(address(bnbX));
        wombatMaster.withdraw(pid, _amount);
        uint256 amountInBnbXBefore = bnbX.balanceOf(address(this));
        uint256 bnbxAmount = wombatPool.withdraw(
            address(bnbX),
            _amount,
            0,
            address(this),
            block.timestamp
        );
        require(
            amountInBnbXBefore - bnbxAmount == bnbX.balanceOf(address(this)),
            "Invalid bnbx amount"
        );

        return bnbxAmount;
    }

    function harvest() external override returns (uint256) {
        // Deposit and stake Wombat Liquidity Pool token on Wombat Master
        uint256 pid = wombatMaster.getAssetPid(address(bnbX));
        (uint256 pending, uint256[] memory rewards) = wombatMaster.deposit(
            pid,
            0
        );
        return pending;
    }

    function convertBnbToVault(uint256 _amount) public view returns (uint256) {
        uint256 amountInBnbX = stakeManager.convertBnbToBnbX(_amount);
        return
            (amountInBnbX * totalDepositsInBnbX) /
            (totalDepositsInBnbX + totalRewardsInBnbX);
    }

    function convertVaultToBnbX(uint256 _amount) public view returns (uint256) {
        return
            (_amount * (totalDepositsInBnbX + totalRewardsInBnbX)) /
            totalDepositsInBnbX;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IStrategy {
    function deposit() external payable;

    function withdraw(uint256 _amount) external returns (uint256);

    function harvest() external returns (uint256);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

interface IWombatPool {
    /**
     * @notice Deposits amount of tokens into pool ensuring deadline
     * @dev Asset needs to be created and added to pool before any operation. This function assumes tax free token.
     * @param token The token address to be deposited
     * @param amount The amount to be deposited
     * @param to The user accountable for deposit, receiving the Wombat assets (lp)
     * @param deadline The deadline to be respected
     * @return liquidity Total asset liquidity minted
     */
    function deposit(
        address token,
        uint256 amount,
        uint256 minimumLiquidity,
        address to,
        uint256 deadline,
        bool shouldStake
    ) external returns (uint256 liquidity);

    /**
     * @notice Withdraws liquidity amount of asset to `to` address ensuring minimum amount required
     * @param token The token to be withdrawn
     * @param liquidity The liquidity to be withdrawn
     * @param minimumAmount The minimum amount that will be accepted by user
     * @param to The user receiving the withdrawal
     * @param deadline The deadline to be respected
     * @return amount The total amount withdrawn
     */
    function withdraw(
        address token,
        uint256 liquidity,
        uint256 minimumAmount,
        address to,
        uint256 deadline
    ) external returns (uint256 amount);
}

//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IStakeManager {
    struct WithdrawalRequest {
        uint256 uuid;
        uint256 amountInBnbX;
        uint256 startTime;
    }

    function deposit() external payable;

    function requestWithdraw(uint256 _amountInBnbX) external;

    function claimWithdraw(uint256 _idx) external;

    function getUserWithdrawalRequests(address _address)
        external
        view
        returns (WithdrawalRequest[] memory);

    function getUserRequestStatus(address _user, uint256 _idx)
        external
        view
        returns (bool _isClaimable, uint256 _amount);

    function getBnbXWithdrawLimit()
        external
        view
        returns (uint256 _bnbXWithdrawLimit);

    function getExtraBnbInContract() external view returns (uint256 _extraBnb);

    function convertBnbToBnbX(uint256 _amount) external view returns (uint256);

    function convertBnbXToBnb(uint256 _amountInBnbX)
        external
        view
        returns (uint256);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

interface IWombatMaster {
    /// @notice Deposit LP tokens to MasterChef for WOM allocation.
    /// @dev it is possible to call this function with _amount == 0 to claim current rewards
    /// @param _pid the pool id
    /// @param _amount amount to deposit
    function deposit(uint256 _pid, uint256 _amount)
        external
        returns (uint256, uint256[] memory);

    /// @notice Withdraw LP tokens from MasterWombat.
    /// @notice Automatically harvest pending rewards and sends to user
    /// @param _pid the pool id
    /// @param _amount the amount to withdraw
    function withdraw(uint256 _pid, uint256 _amount)
        external
        returns (uint256, uint256[] memory);

    // revert if asset not exist
    function getAssetPid(address asset) external view returns (uint256);
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