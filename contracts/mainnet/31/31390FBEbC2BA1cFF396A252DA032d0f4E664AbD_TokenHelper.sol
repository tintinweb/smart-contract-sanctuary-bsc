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

pragma solidity ^0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenHelper {
    struct AccountBalance {
        address account;
        address token;
        uint256 balance;
    }

    function allowances(
        address account,
        address spender,
        address[] memory tokens
    ) external view returns (uint256[] memory) {
        uint256[] memory accountAllowances = new uint256[](tokens.length);

        for (uint256 i = 0; i < tokens.length; ++i) {
            accountAllowances[i] = IERC20(tokens[i]).allowance(
                account,
                spender
            );
        }

        return accountAllowances;
    }

    /**
     * @dev Check the token balances of a wallet for multiple tokens.
     * Pass 0x0 as a "token" address to get ETH balance.
     *
     * Possible error throws:
     *  - extremely large arrays for user and or tokens (gas cost too high)
     *
     * Returns a one-dimensional that's user.length * tokens.length long. The
     * array is ordered by all of the 0th accounts token balances, then the 1th
     * user, and so on.
     */
    function balances(
        address[] memory accounts,
        address[] memory tokens
    ) external view returns (uint256[] memory) {
        uint256[] memory accountBalances = new uint256[](
            tokens.length * accounts.length
        );

        for (uint256 i = 0; i < accounts.length; i++) {
            for (uint256 j = 0; j < tokens.length; j++) {
                uint256 addrIdx = j + tokens.length * i;
                if (tokens[j] != address(0x0)) {
                    accountBalances[addrIdx] = IERC20(tokens[j]).balanceOf(
                        accounts[i]
                    );
                } else {
                    accountBalances[addrIdx] = accounts[i].balance; // ETH balance
                }
            }
        }

        return accountBalances;
    }

    /**
     * @dev Check the token balances of a wallet for multiple tokens.
     * Pass 0x0 as a "token" address to get ETH balance.
     *
     * Possible error throws:
     *  - extremely large arrays for user and or tokens (gas cost too high)
     *
     * Returns a one-dimensional array that's user.length * tokens.length long. The
     * array is ordered by all of the 0th accounts token balances, then the 1th
     * user, and so on.
     */
    function balancesStruct(
        address[] memory accounts,
        address[] memory tokens
    ) external view returns (AccountBalance[] memory) {
        AccountBalance[] memory accountBalances = new AccountBalance[](
            tokens.length * accounts.length
        );

        for (uint256 i = 0; i < accounts.length; i++) {
            for (uint256 j = 0; j < tokens.length; j++) {
                uint256 addrIdx = j + tokens.length * i;
                if (tokens[j] != address(0x0)) {
                    accountBalances[addrIdx] = AccountBalance({
                        account: accounts[i],
                        token: tokens[j],
                        balance: IERC20(tokens[j]).balanceOf(accounts[i])
                    });
                } else {
                    accountBalances[addrIdx] = AccountBalance({
                        account: accounts[i],
                        token: tokens[j],
                        balance: accounts[i].balance
                    });
                }
            }
        }

        return accountBalances;
    }
}