// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DevWallet {
    
    IERC20 public BUSD;

    address[] public dev_wallets;
    uint[] public percents;

    uint public dev_count;

    constructor(IERC20 _BUSD) {
        BUSD = _BUSD;
    }

    function set_dev_wallets(address[] memory _dev_wallets, uint[] memory _percents) external {
        uint current_wallet_count = dev_wallets.length;
        uint new_wallet_count = _dev_wallets.length;
        uint i;
        uint total_percent;
        for(i = 0; i < new_wallet_count; i ++) {
            total_percent += _percents[i];   
        }
        require(total_percent == 1e4, "Percent sum should be 100%");
        for(i = 0; i < _min(current_wallet_count, new_wallet_count); i++) {
            dev_wallets[i] = _dev_wallets[i];
            percents[i] = _percents[i];
        }
        for(; i < new_wallet_count; i++) {
            dev_wallets.push(_dev_wallets[i]);
            percents.push(_percents[i]);
        }
        dev_count = new_wallet_count;
    }

    function withdraw() external {
        uint balance = BUSD.balanceOf(address(this));
        uint balance_for_dev;
        uint i;
        for(i = 0; i < dev_count; i++) {
            balance_for_dev = percents[i] * balance / 1e4;
            BUSD.transfer(dev_wallets[i], balance_for_dev);
        }
    }

}

function _min(uint a, uint b) pure returns(uint) {
    return a < b ? a : b;
}

function _max(uint a, uint b) pure returns(uint) {
    return a > b ? a : b;
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