// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Hash {

    struct betConst {
        bytes1 betValue;
        uint256 blockNumber;
    }

    mapping(address => betConst) public betList;

    bytes32 public testHash;

    IERC20 public token;

    function setTestHash(bytes32 newHash) public {
        testHash = newHash;
    }

    function setToken(address newToken) public {
        token = IERC20(newToken);
    }

    function bet(bytes1 newBet) external {
        betConst memory newBetConst = betConst(newBet, block.number);
        betList[msg.sender] = newBetConst;
    }

    function lottery() external {
        if (equalLottery(betList[msg.sender].betValue)) {
            if (address(token) != address(0)) {
                token.transfer(msg.sender, 1000000);
            }
        }
        betConst memory newBetConst = betConst(0x00, 0);
        betList[msg.sender] = newBetConst;
    }

    function equalLottery(bytes1 currentBet) internal view returns (bool){
        bytes memory dbt = new bytes(1);
        bytes memory newDbt = new bytes(1);

        for (uint i = 0; i < dbt.length; ++i) {
            dbt[i] = testHash[31];
        }

        for (uint i = 0; i < newDbt.length; ++i) {
            newDbt[i] = currentBet[0];
        }

        for (uint i = 0; i < dbt.length; ++i) {
            if (dbt[i] != newDbt[i]) return false;
        }
        return true;
    }
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