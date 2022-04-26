// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract OPV_HOLD {
    using Counters for Counters.Counter;
    Counters.Counter private index;

    struct UserHold {
        address userAddres;
        uint256 totalHold;
        bool is_winner;
    }

    mapping(address => UserHold) public listHold;
    address[] holderAddresses;

    uint256 private idOnSystem;
    uint256 public endHold;
    uint256 public publicSale;
    uint256 public totalWinner = 10;

    address owner;

    IERC20 public OPV;

    event HoldToken(address user, uint256 amount);
    event WithdrawToken(address user, uint256 amount);

    constructor(uint256 timeEndHold, uint256 publicTime, address addressOPV) {
        owner = msg.sender;
        endHold = timeEndHold;
        publicSale = publicTime;
        OPV = IERC20(addressOPV); // Change when deploy
        OPV.approve(
            address(this),
            115792089237316195423570985008687907853269984665640564039457584007913129639935
        );
    }

    modifier onlyOwner(address sender) {
        require(sender == owner, "Is not Owner");
        _;
    }

    function holdToken(uint256 amount) public {
        require(block.timestamp < endHold, "Pass time hold");
        require(OPV.balanceOf(msg.sender) > amount, "Invalid balanceOf");
        require(
            OPV.allowance(msg.sender, address(this)) > amount,
            "Invalid allowance"
        );
        OPV.transferFrom(msg.sender, address(this), amount);
        if (listHold[msg.sender].totalHold == 0) {
            holderAddresses.push(msg.sender);
        }
        listHold[msg.sender].totalHold += amount;

        emit HoldToken(msg.sender, amount);
    }

    function withdrawHold(uint256 amount) public {
        require(listHold[msg.sender].totalHold >= amount, "Invalid amount");
        require(block.timestamp > endHold, "Invalid time");

        OPV.transfer(msg.sender, amount);
        listHold[msg.sender].totalHold -= amount;
        emit WithdrawToken(msg.sender, amount);
    }

    function setTotalWinner(uint256 _total) public onlyOwner(msg.sender) {
        totalWinner = _total;
    }

    function getTotalTokenHold(address userAddress)
        public
        view
        returns (uint256)
    {
        return listHold[userAddress].totalHold;
    }

    function getTimeToPublic() public view returns (uint256) {
        return publicSale;
    }

    function setTimeToPublic(uint256 timestamp) public onlyOwner(msg.sender) {
        publicSale = timestamp;
    }

    function checkWinner(address userAddress) public view returns (bool) {
        uint256 count;
        uint256 amount = listHold[userAddress].totalHold;
        for (uint256 i = 0; i < holderAddresses.length; i++) {
            if (holderAddresses[i] != userAddress) {
                if (listHold[holderAddresses[i]].totalHold > amount) count++;
            }
        }
        if (count >= totalWinner) return false;
        return true;
    }

    function topHolder() public view returns (UserHold[] memory) {
        uint256 userCount = 0;
        UserHold[] memory users = new UserHold[](userCount);
        for (uint256 i = 0; i < holderAddresses.length; i++) {
            if (this.checkWinner(holderAddresses[i]) == true) {
                userCount++;
                users[userCount] = listHold[holderAddresses[i]];
            }
        }
        return users;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
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