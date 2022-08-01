// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./libs/Owner.sol";
import "./interfaces/IKnightPool.sol";

contract KnightPool is Owner, IKnightPool {
    uint256 poolBalance;
    address poolAddress = address(this);
    address whiteKnightAddress;
    IERC20 public KINGDOMToken;

    constructor(address KINGDOM) {
        KINGDOMToken = IERC20(KINGDOM);
    }

    function getContractAddress() public view returns (address) {
        return poolAddress;
    }

    function getWhiteKnightAddress() public view returns (address) {
        return whiteKnightAddress;
    }

    function getPoolBalance() public view override returns (uint256) {
        return KINGDOMToken.balanceOf(poolAddress);
    }

    function withdrawFromPool(uint256 amount)
        public
        onlyOperator
        returns (bool success)
    {
        require(amount > 0, "Withdraw amount can't be zero");
        KINGDOMToken.transfer(operator, amount);

        emit WithdrawFromPool(amount);

        return true;
    }

    function transferFromPoolForWithdraw(uint256 amount)
        public
        override
        returns (uint256)
    {
        require(amount > 0, "transfer amount can't be zero");
        require(
            msg.sender == whiteKnightAddress,
            "only whiteknight can call this function"
        );

        KINGDOMToken.transfer(msg.sender, amount);

        return amount;
    }

    function depositeToPool(uint256 amount)
        public
        override
        returns (bool success)
    {
        require(amount > 0, "Deposite amount can't be zero");
        KINGDOMToken.transferFrom(msg.sender, poolAddress, amount);

        emit DepositeToPool(amount);

        return true;
    }

    function setWhiteKnightAddress(address whiteKnight) public onlyOperator {
        whiteKnightAddress = whiteKnight;
    }
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

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

contract Owner {
    address public operator;

    constructor() {
        operator = msg.sender;
    }

    function getOperator() public view returns (address) {
        return operator;
    }

    function transferOwnership(address newOperator)
        public
        onlyOperator
        returns (bool success)
    {
        require(
            newOperator != address(0) || operator != newOperator,
            "Ownable: new operator is the zero address, new operator can't be same with current operator"
        );
        operator = newOperator;

        return true;
    }

    modifier onlyOperator() {
        require(msg.sender == operator);
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IKnightPool {
    function getPoolBalance() external view returns (uint256);

    function depositeToPool(uint256 amount) external returns (bool success);

    function transferFromPoolForWithdraw(uint256 amount)
        external
        returns (uint256);

    event WithdrawFromPool(uint256 amount);
    event DepositeToPool(uint256 amount);
}