// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
pragma solidity 0.8.15;

import "./interfaces/IGauge.sol";
import "./interfaces/IExtraReward.sol";
import "./interfaces/IGaugeFactory.sol";

/** @title  GaugeFactory
    @notice Creates Gauge and ExtraReward
    @dev Uses clone to create new contracts
 */
contract GaugeFactory is IGaugeFactory {
    address public immutable deployedGauge;

    event GaugeCreated(address indexed gauge);
    event ExtraRewardCreated(address indexed extraReward);

    constructor(address _deployedGauge) {
        deployedGauge = _deployedGauge;
    }

    /** @notice Create a new reward Gauge clone
        @param _vault the vault address.
        @param _owner owner
        @return gauge address
    */
    function createGauge(
        address _vault,
        address _owner
    ) external override returns (address) {
        address newGauge = _clone(deployedGauge);
        emit GaugeCreated(newGauge);
        IGauge(newGauge).initialize(_vault, _owner);

        return newGauge;
    }

    function _clone(address _source) internal returns (address result) {
        bytes20 targetBytes = bytes20(_source);
        assembly {
            let clone := mload(0x40)
            mstore(
                clone,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(clone, 0x14), targetBytes)
            mstore(
                add(clone, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            result := create(0, clone, 0x37)
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
import "@openzeppelin/contracts-v4/token/ERC20/IERC20.sol";

interface IBaseGauge {
    function queueNewRewards(uint256 _amount) external returns (bool);

    function earned(address _account) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-v4/token/ERC20/IERC20.sol";

/**
 * @title EIP 4626 specification
 * @notice Interface of EIP 4626 Interface
 * as defined in https://eips.ethereum.org/EIPS/eip-4626
 */
interface IERC4626 is IERC20Upgradeable {
    /**
     * @notice Event indicating that `caller` exchanged `assets` for `shares`, and transferred those `shares` to `owner`
     * @dev Emitted when tokens are deposited into the vault via {mint} and {deposit} methods
     */
    event Deposit(
        address indexed caller,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    /**
     * @notice Event indicating that `caller` exchanged `shares`, owned by `owner`, for `assets`, and transferred those
     * `assets` to `receiver`
     * @dev Emitted when shares are withdrawn from the vault via {redeem} or {withdraw} methods
     */
    event Withdraw(
        address indexed caller,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    /**
     * @notice Returns the address of the underlying token used by the Vault
     * @return assetTokenAddress The address of the underlying ERC20 Token
     * @dev MUST be an ERC-20 token contract
     *
     * MUST not revert
     */
    function asset() external view returns (IERC20 assetTokenAddress);

    /**
     * @notice Returns the total amount of the underlying asset managed by the Vault
     * @return totalManagedAssets Amount of the underlying asset
     * @dev Should include any compounding that occurs from yield.
     *
     * Should be inclusive of any fees that are charged against assets in the vault.
     *
     * Must not revert
     *
     */
    function totalAssets() external view returns (uint256 totalManagedAssets);

    /**
     *
     * @notice Returns the amount of shares that, in an ideal scenario, the vault would exchange for the amount of assets
     * provided
     *
     * @param _assets Amount of assets to convert
     * @return shares Amount of shares that would be exchanged for the provided amount of assets
     *
     * @dev MUST NOT be inclusive of any fees that are charged against assets in the Vault.
     *
     * MUST NOT show any variations depending on the caller.
     *
     * MUST NOT reflect slippage or other on-chain conditions, when performing the actual exchange.
     *
     * MUST NOT revert unless due to integer overflow caused by an unreasonably large input.
     *
     * MUST round down towards 0.
     *
     * This calculation MAY NOT reflect the “per-user” price-per-share, and instead should reflect the
     * “average-user’s” price-per-share, meaning what the average user should expect to see when exchanging to and from.
     */
    function convertToShares(
        uint256 _assets
    ) external view returns (uint256 shares);

    /**
     *
     * @notice Returns the amount of assets that the vault would exchange for the amount of shares provided
     *
     * @param _shares Amount of vault shares to convert
     * @return assets Amount of assets that would be exchanged for the provided amount of shares
     *
     * @dev MUST NOT be inclusive of any fees that are charged against assets in the Vault.
     *
     * MUST NOT show any variations depending on the caller.
     *
     * MUST NOT reflect slippage or other on-chain conditions, when performing the actual exchange.
     *
     * MUST NOT revert unless due to integer overflow caused by an unreasonably large input.
     *
     * MUST round down towards 0.
     *
     * This calculation MAY NOT reflect the “per-user” price-per-share, and instead should reflect the
     * “average-user’s” price-per-share, meaning what the average user should expect to see when exchanging to and from.
     */
    function convertToAssets(
        uint256 _shares
    ) external view returns (uint256 assets);

    /**
     *
     * @notice Returns the maximum amount of the underlying asset that can be deposited into the vault for the `receiver`
     * through a {deposit} call
     *
     * @param _receiver Address whose maximum deposit is being queries
     * @return maxAssets
     *
     * @dev MUST return the maximum amount of assets {deposit} would allow to be deposited for receiver and not cause a
     * revert, which MUST NOT be higher than the actual maximum that would be accepted (it should underestimate if
     *necessary). This assumes that the user has infinite assets, i.e. MUST NOT rely on {balanceOf} of asset.
     *
     * MUST factor in both global and user-specific limits, like if deposits are entirely disabled (even temporarily)
     * it MUST return 0.
     *
     * MUST return 2 ** 256 - 1 if there is no limit on the maximum amount of assets that may be deposited.
     *
     * MUST NOT revert.
     */
    function maxDeposit(
        address _receiver
    ) external view returns (uint256 maxAssets);

    /**
     * @notice Simulate the effects of a user's deposit at the current block, given current on-chain conditions
     * @param _assets Amount of assets
     * @return shares Amount of shares
     * @dev MUST return as close to and no more than the exact amount of Vault shares that would be minted in a {deposit}
     * call in the same transaction. I.e. deposit should return the same or more shares as {previewDeposit} if called in
     * the same transaction. (I.e. {previewDeposit} should underestimate or round-down)
     *
     * MUST NOT account for deposit limits like those returned from maxDeposit and should always act as though the
     * deposit would be accepted, regardless if the user has enough tokens approved, etc.
     *
     * MUST be inclusive of deposit fees. Integrators should be aware of the existence of deposit fees.
     *
     * MUST NOT revert due to vault specific user/global limits. MAY revert due to other conditions that would also
     * cause deposit to revert.
     *
     * Note that any unfavorable discrepancy between convertToShares and previewDeposit SHOULD be considered slippage
     * in share price or some other type of condition, meaning the depositor will lose assets by depositing.
     */
    function previewDeposit(
        uint256 _assets
    ) external view returns (uint256 shares);

    /**
     * @notice Mints `shares` Vault shares to `receiver` by depositing exactly `amount` of underlying tokens
     * @param _assets Amount of assets
     * @param _receiver Address to deposit underlying tokens into
     * @dev Must emit the {Deposit} event
     *
     * MUST support ERC-20 {approve} / {transferFrom} on asset as a deposit flow. MAY support an additional flow in
     * which the underlying tokens are owned by the Vault contract before the {deposit} execution, and are accounted for
     * during {deposit}.
     *
     * MUST revert if all of `assets` cannot be deposited (due to deposit limit being reached, slippage, the user not
     * approving enough underlying tokens to the Vault contract, etc).
     *
     * Note that most implementations will require pre-approval of the Vault with the Vault’s underlying asset token.
     */
    function deposit(
        uint256 _assets,
        address _receiver
    ) external returns (uint256 shares);

    /**
     * @notice Returns the maximum amount of shares that can be minted from the vault for the `receiver``, via a `mint`
     * call
     * @param _receiver Address to deposit minted shares into
     * @return maxShares The maximum amount of shares
     * @dev MUST return the maximum amount of shares mint would allow to be deposited to receiver and not cause a revert,
     * which MUST NOT be higher than the actual maximum that would be accepted (it should underestimate if necessary).
     * This assumes that the user has infinite assets, i.e. MUST NOT rely on balanceOf of asset.
     *
     * MUST factor in both global and user-specific limits, like if mints are entirely disabled (even temporarily) it
     *
     * MUST return 0.
     *
     * MUST return 2 ** 256 - 1 if there is no limit on the maximum amount of shares that may be minted.
     *
     * MUST NOT revert.
     */
    function maxMint(
        address _receiver
    ) external view returns (uint256 maxShares);

    /**
     * @notice Simulate the effects of a user's mint at the current block, given current on-chain conditions
     * @param _shares Amount of shares to mint
     * @return assets Amount of assets required to mint `mint` amount of shares
     * @dev MUST return as close to and no fewer than the exact amount of assets that would be deposited in a mint call
     * in the same transaction. I.e. mint should return the same or fewer assets as previewMint if called in the same
     * transaction. (I.e. {previewMint} should overestimate or round-up)
     *
     * MUST NOT account for mint limits like those returned from maxMint and should always act as though the mint
     * would be accepted, regardless if the user has enough tokens approved, etc.
     *
     * MUST be inclusive of deposit fees. Integrators should be aware of the existence of deposit fees.
     *
     * MUST NOT revert due to vault specific user/global limits. MAY revert due to other conditions that would also
     * cause mint to revert.
     *
     * Note that any unfavorable discrepancy between convertToAssets and previewMint SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by minting.
     */
    function previewMint(
        uint256 _shares
    ) external view returns (uint256 assets);

    /**
     * @notice Mints exactly `shares` vault shares to `receiver` by depositing `amount` of underlying tokens
     * @param _shares Amount of shares to mint
     * @param _receiver Address to deposit minted shares into
     * @return assets Amount of assets transferred to vault
     * @dev Must emit the {Deposit} event
     *
     * MUST support ERC-20 {approve} / {transferFrom} on asset as a mint flow. MAY support an additional flow in
     *  which the underlying tokens are owned by the Vault contract before the mint execution, and are accounted for
     * during mint.
     *
     * MUST revert if all of `shares` cannot be minted (due to deposit limit being reached, slippage, the user not
     * approving enough underlying tokens to the Vault contract, etc).
     *
     * Note that most implementations will require pre-approval of the Vault with the Vault’s underlying asset token.
     */
    function mint(
        uint256 _shares,
        address _receiver
    ) external returns (uint256 assets);

    /**
     * @notice Returns the maximum amount of the underlying asset that can be withdrawn from the `owner` balance in the
     * vault, through a `withdraw` call.
     * @param _owner Address of the owner whose max withdrawal amount is being queries
     * @return maxAssets Maximum amount of underlying asset that can be withdrawn
     * @dev MUST return the maximum amount of assets that could be transferred from `owner` through {withdraw} and not
     * cause a revert, which MUST NOT be higher than the actual maximum that would be accepted (it should underestimate if
     * necessary).
     *
     * MUST factor in both global and user-specific limits, like if withdrawals are entirely disabled
     * (even temporarily)  it MUST return 0.
     *
     * MUST NOT revert.
     */
    function maxWithdraw(
        address _owner
    ) external view returns (uint256 maxAssets);

    /**
     * @notice Simulate the effects of a user's withdrawal at the current block, given current on-chain conditions.
     * @param _assets Amount of assets
     * @return shares Amount of shares
     * @dev MUST return as close to and no fewer than the exact amount of Vault shares that would be burned in a
     * {withdraw} call in the same transaction. I.e. {withdraw} should return the same or fewer shares as
     * {previewWithdraw} if called in the same transaction. (I.e. {previewWithdraw should overestimate or round-up})
     *
     * MUST NOT account for withdrawal limits like those returned from {maxWithdraw} and should always act as though
     * the withdrawal would be accepted, regardless if the user has enough shares, etc.
     *
     * MUST be inclusive of withdrawal fees. Integrators should be aware of the existence of withdrawal fees.
     *
     * MUST NOT revert due to vault specific user/global limits. MAY revert due to other conditions that would also
     * cause {withdraw} to revert.
     *
     * Note that any unfavorable discrepancy between convertToShares and previewWithdraw SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by depositing.
     */
    function previewWithdraw(
        uint256 _assets
    ) external view returns (uint256 shares);

    /**
     * @notice Burns `shares` from `owner` and sends exactly `assets` of underlying tokens to `receiver`
     * @param _assets Amount of underling assets to withdraw
     * @return shares Amount of shares that will be burned
     * @dev Must emit the {Withdraw} event
     *
     * MUST support a withdraw flow where the shares are burned from `owner` directly where `owner` is `msg.sender`
     * or `msg.sender` has ERC-20 approval over the shares of `owner`. MAY support an additional flow in which the shares
     * are transferred to the Vault contract before the withdraw execution, and are accounted for during withdraw.
     *
     * MUST revert if all of assets cannot be withdrawn (due to withdrawal limit being reached, slippage, the owner
     * not having enough shares, etc).
     *
     * Note that some implementations will require pre-requesting to the Vault before a withdrawal may be performed.
     *  Those methods should be performed separately.
     */
    function withdraw(
        uint256 _assets,
        address _receiver,
        address _owner
    ) external returns (uint256 shares);

    /**
     * @notice Returns the maximum amount of vault shares that can be redeemed from the `owner` balance in the vault, via
     * a `redeem` call.
     * @param _owner Address of the owner whose shares are being queries
     * @return maxShares Maximum amount of shares that can be redeemed
     * @dev MUST return the maximum amount of shares that could be transferred from `owner` through `redeem` and not cause
     * a revert, which MUST NOT be higher than the actual maximum that would be accepted (it should underestimate if
     * necessary).
     *
     * MUST factor in both global and user-specific limits, like if redemption is entirely disabled
     * (even temporarily) it MUST return 0.
     *
     * MUST NOT revert
     */
    function maxRedeem(
        address _owner
    ) external view returns (uint256 maxShares);

    /**
     * @notice Simulate the effects of a user's redemption at the current block, given current on-chain conditions
     * @param _shares Amount of shares that are being simulated to be redeemed
     * @return assets Amount of underlying assets that can be redeemed
     * @dev MUST return as close to and no more than the exact amount of `assets `that would be withdrawn in a {redeem}
     * call in the same transaction. I.e. {redeem} should return the same or more assets as {previewRedeem} if called in
     * the same transaction. I.e. {previewRedeem} should underestimate/round-down
     *
     * MUST NOT account for redemption limits like those returned from {maxRedeem} and should always act as though
     * the redemption would be accepted, regardless if the user has enough shares, etc.
     *
     * MUST be inclusive of withdrawal fees. Integrators should be aware of the existence of withdrawal fees.
     *
     * MUST NOT revert due to vault specific user/global limits. MAY revert due to other conditions that would also
     * cause {redeem} to revert.
     *
     * Note that any unfavorable discrepancy between {convertToAssets} and {previewRedeem} SHOULD be considered
     * slippage in share price or some other type of condition, meaning the depositor will lose assets by redeeming.
     */
    function previewRedeem(
        uint256 _shares
    ) external view returns (uint256 assets);

    /**
     * @notice Burns exactly `shares` from `owner` and sends `assets` of underlying tokens to `receiver`
     * @param _shares Amount of shares to burn
     * @param _receiver Address to deposit redeemed underlying tokens to
     * @return assets Amount of underlying tokens redeemed
     * @dev Must emit the {Withdraw} event
     * MUST support a {redeem} flow where the shares are burned from owner directly where `owner` is `msg.sender` or
     *
     * `msg.sender` has ERC-20 approval over the shares of `owner`. MAY support an additional flow in which the shares
     * are transferred to the Vault contract before the {redeem} execution, and are accounted for during {redeem}.
     *
     * MUST revert if all of {shares} cannot be redeemed (due to withdrawal limit being reached, slippage, the owner
     * not having enough shares, etc).
     *
     * Note that some implementations will require pre-requesting to the Vault before a withdrawal may be performed.
     * Those methods should be performed separately.
     */
    function redeem(
        uint256 _shares,
        address _receiver,
        address _owner
    ) external returns (uint256 assets);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
import "@openzeppelin/contracts-v4/token/ERC20/IERC20.sol";
import "./IBaseGauge.sol";

interface IExtraReward is IBaseGauge {
    function initialize(
        address _gauge,
        address _reward,
        address _owner
    ) external;

    function rewardCheckpoint(address _account) external returns (bool);

    function getReward() external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
import "./IBaseGauge.sol";
import "./IERC4626.sol";

interface IGauge is IBaseGauge, IERC4626 {
    function initialize(address _stakingToken, address _owner) external;

    function boostedBalanceOf(address _account) external view returns (uint256);

    function getReward(address _account) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IGaugeFactory {
    function createGauge(address, address) external returns (address);
}