// SPDX-License-Identifier: MIT
pragma solidity =0.8.14;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../interfaces/IDataProvider.sol";

contract DataProvider is IDataProvider {
    /* ----- View Functions ----- */

    function infos(
        address user,
        address masterChefWoo,
        address[] memory vaults,
        address[] memory tokens,
        address[] memory superChargerVaults,
        address[] memory withdrawManagers,
        uint256[] memory pids
    )
        public
        view
        override
        returns (
            VaultInfos memory vaultInfos,
            TokenInfos memory tokenInfos,
            MasterChefWooInfos memory masterChefWooInfos,
            SuperChargerRelatedInfos memory superChargerRelatedInfos
        )
    {
        vaultInfos.balancesOf = balancesOf(user, vaults);
        vaultInfos.sharePrices = sharePrices(vaults);
        vaultInfos.costSharePrices = costSharePrices(user, vaults);

        tokenInfos.nativeBalance = user.balance;
        tokenInfos.balancesOf = balancesOf(user, tokens);

        (masterChefWooInfos.amounts, masterChefWooInfos.rewardDebts) = userInfos(user, masterChefWoo, pids);
        (masterChefWooInfos.pendingXWooAmounts, masterChefWooInfos.pendingWooAmounts) = pendingXWoos(
            user,
            masterChefWoo,
            pids
        );

        superChargerRelatedInfos.requestedWithdrawAmounts = requestedWithdrawAmounts(user, superChargerVaults);
        superChargerRelatedInfos.withdrawAmounts = withdrawAmounts(user, withdrawManagers);
    }

    function balancesOf(address user, address[] memory tokens) public view override returns (uint256[] memory results) {
        uint256 length = tokens.length;
        results = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            results[i] = IERC20(tokens[i]).balanceOf(user);
        }
    }

    function sharePrices(address[] memory vaults) public view override returns (uint256[] memory results) {
        uint256 length = vaults.length;
        results = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            results[i] = IVaultInfo(vaults[i]).getPricePerFullShare();
        }
    }

    function costSharePrices(address user, address[] memory vaults)
        public
        view
        override
        returns (uint256[] memory results)
    {
        uint256 length = vaults.length;
        results = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            results[i] = IVaultInfo(vaults[i]).costSharePrice(user);
        }
    }

    function userInfos(
        address user,
        address masterChefWoo,
        uint256[] memory pids
    ) public view override returns (uint256[] memory amounts, uint256[] memory rewardDebts) {
        uint256 length = pids.length;
        amounts = new uint256[](length);
        rewardDebts = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            (amounts[i], rewardDebts[i]) = IMasterChefWooInfo(masterChefWoo).userInfo(pids[i], user);
        }
    }

    function pendingXWoos(
        address user,
        address masterChefWoo,
        uint256[] memory pids
    ) public view override returns (uint256[] memory pendingXWooAmounts, uint256[] memory pendingWooAmounts) {
        uint256 length = pids.length;
        pendingXWooAmounts = new uint256[](length);
        pendingWooAmounts = new uint256[](length);
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        if (chainId == 10) {
            for (uint256 i = 0; i < length; i++) {
                (pendingWooAmounts[i], ) = IMasterChefWooInfo(masterChefWoo).pendingReward(pids[i], user);
                pendingXWooAmounts[i] = pendingWooAmounts[i];
            }
        } else {
            for (uint256 i = 0; i < length; i++) {
                (pendingXWooAmounts[i], pendingWooAmounts[i]) = IMasterChefWooInfo(masterChefWoo).pendingXWoo(
                    pids[i],
                    user
                );
            }
        }
    }

    function requestedWithdrawAmounts(address user, address[] memory superChargerVaults)
        public
        view
        override
        returns (uint256[] memory results)
    {
        uint256 length = superChargerVaults.length;
        results = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            results[i] = ISuperChargerVaultInfo(superChargerVaults[i]).requestedWithdrawAmount(user);
        }
    }

    function withdrawAmounts(address user, address[] memory withdrawManagers)
        public
        view
        override
        returns (uint256[] memory results)
    {
        uint256 length = withdrawManagers.length;
        results = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            results[i] = IWithdrawManagerInfo(withdrawManagers[i]).withdrawAmount(user);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.14;

interface IVaultInfo {
    function costSharePrice(address user) external view returns (uint256 sharePrice);

    function getPricePerFullShare() external view returns (uint256 sharePrice);
}

interface ISuperChargerVaultInfo {
    function requestedWithdrawAmount(address user) external view returns (uint256 amount);
}

interface IWithdrawManagerInfo {
    function withdrawAmount(address user) external view returns (uint256 amount);
}

interface IMasterChefWooInfo {
    function userInfo(uint256 pid, address user) external view returns (uint256 amount, uint256 rewardDebt);

    function pendingXWoo(uint256 pid, address user)
        external
        view
        returns (uint256 pendingXWooAmount, uint256 pendingWooAmount);

    function pendingReward(uint256 pid, address user)
        external
        view
        returns (uint256 pendingRewardAmount, uint256 pendingRewarderTokens);
}

interface IDataProvider {
    /* ----- Struct ----- */

    struct VaultInfos {
        uint256[] balancesOf;
        uint256[] sharePrices;
        uint256[] costSharePrices;
    }

    struct TokenInfos {
        uint256 nativeBalance;
        uint256[] balancesOf;
    }

    struct MasterChefWooInfos {
        uint256[] amounts;
        uint256[] rewardDebts;
        uint256[] pendingXWooAmounts;
        uint256[] pendingWooAmounts;
    }

    struct SuperChargerRelatedInfos {
        uint256[] requestedWithdrawAmounts;
        uint256[] withdrawAmounts;
    }

    /* ----- View Functions ----- */

    function infos(
        address user,
        address masterChefWoo,
        address[] memory vaults,
        address[] memory tokens,
        address[] memory superChargerVaults,
        address[] memory withdrawManagers,
        uint256[] memory pids
    )
        external
        view
        returns (
            VaultInfos memory vaultInfos,
            TokenInfos memory tokenInfos,
            MasterChefWooInfos memory masterChefWooInfos,
            SuperChargerRelatedInfos memory superChargerRelatedInfos
        );

    function balancesOf(address user, address[] memory tokens) external view returns (uint256[] memory results);

    function sharePrices(address[] memory vaults) external view returns (uint256[] memory results);

    function costSharePrices(address user, address[] memory vaults) external view returns (uint256[] memory results);

    function userInfos(
        address user,
        address masterChefWoo,
        uint256[] memory pids
    ) external view returns (uint256[] memory amounts, uint256[] memory rewardDebts);

    function pendingXWoos(
        address user,
        address masterChefWoo,
        uint256[] memory pids
    ) external view returns (uint256[] memory pendingXWooAmounts, uint256[] memory pendingWooAmounts);

    function requestedWithdrawAmounts(address user, address[] memory superChargerVaults)
        external
        view
        returns (uint256[] memory results);

    function withdrawAmounts(address user, address[] memory withdrawManagers)
        external
        view
        returns (uint256[] memory results);
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