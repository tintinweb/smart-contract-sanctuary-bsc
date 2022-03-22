/**
 *Submitted for verification at BscScan.com on 2022-03-22
*/

// File: contracts/IERC20.sol

pragma solidity ^0.4.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/escrow1Erc20.sol

pragma solidity ^0.4.24;


contract Escrow {
    uint256 public escrowTime;

    constructor(uint256 _escrowTime) public {
        escrowTime = _escrowTime;
    }

    mapping(address => mapping(address => uint256)) public escrowBalance;
    mapping(address => mapping(address => uint256)) public escrowExpiration;

    function deposit(IERC20 token, uint256 amount) public {
        require(token.transferFrom(msg.sender, this, amount));
        escrowBalance[msg.sender][token] += amount;
        escrowExpiration[msg.sender][token] = 2**256-1;
    }

    event StartWithdrawal(address indexed account, address token, uint256 time);

    function startWithdrawal(IERC20 token) public {
        uint256 expiration = now + escrowTime;
        escrowExpiration[msg.sender][token] = expiration;
        emit StartWithdrawal(msg.sender, token, expiration);
    }

    function withdraw(IERC20 token) public {
        require(now > escrowExpiration[msg.sender][token],
            "Funds still in escrow.");

        uint256 amount = escrowBalance[msg.sender][token];
        escrowBalance[msg.sender][token] = 0;
        require(token.transfer(msg.sender, amount));
    }

    function transfer(
        address from,
        address to,
        IERC20 token,
        uint256 tokens
    )
        internal
    {
        require(escrowBalance[from][token] >= tokens, "Insufficient balance.");

        escrowBalance[from][token] -= tokens;
        escrowBalance[to][token] += tokens;
    }
}