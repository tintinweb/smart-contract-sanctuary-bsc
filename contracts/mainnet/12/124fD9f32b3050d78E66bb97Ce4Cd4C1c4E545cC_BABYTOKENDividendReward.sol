// SPDX-License-Identifier: MIT
pragma solidity =0.8.4;

import "./interface/IBABYTOKEN.sol";
import "./interface/IBABYTOKENReward.sol";

contract BABYTOKENDividendReward {

    IBABYTOKEN public babyToken;
    IBABYTOKENReward public babyTokenReward;

    struct TrackerBalance {
        address tracker;
        uint256 amount;
    }

    constructor(){
        babyToken = IBABYTOKEN(0x95f60832Db51FF57C86e6E43D01301be10cffeC6);
        babyTokenReward = IBABYTOKENReward(0x28ca901277273fA63E7e420bB530F4d2ac97609A);
    }

    function listAll(uint256 start, uint256 size) public view returns (TrackerBalance[] memory){
        if (start + size > babyTokenReward.getNumberOfTokenHolders()) {
            size = babyTokenReward.getNumberOfTokenHolders() - start + 1;
        }
        uint256 index = 0;
        TrackerBalance[] memory list = new TrackerBalance[](size);
        while (index < size) {
            (address addr,,,,,,,) = babyTokenReward.getAccountAtIndex(start + index);
            uint256 balance = babyTokenReward.balanceOf(addr);
            list[index] = TrackerBalance(addr, balance);
            index++;
        }
        return list;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBABYTOKEN {
    function parentAddr(address addr) external view returns (address);

    function AmountTokenRewardsFee() external view returns (uint256);

    function getMinimumTokenBalanceForDividends()
    external
    view
    returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IBABYTOKENReward is IERC20{
    function getNumberOfTokenHolders() external view returns (uint256);

    function getAccountAtIndex(uint256 index)
    external
    view
    returns (
        address,
        int256,
        int256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256
    );
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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