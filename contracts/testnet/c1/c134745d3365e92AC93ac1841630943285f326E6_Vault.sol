// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title A vault for storing ether and tokens
/// @author Pedro Reyes
/// @notice This contract is for those weak hands that cannot hold!!
contract Vault {
    // Owner => Token => Deposit
    mapping(address => VaultDeposit[]) public vaultDeposits;

    struct VaultDeposit {
        uint256 amount;
        uint256 lockEndTime;
        address token;
    }

    constructor() {}

    /// @dev Only the first user will be able to use the vault
    /// @param _token - ERC20 token address. address(0) if sending ether
    /// @param _amount - bigger than zero if sending ERC20 tokens
    /// @param _lockedTime - bigger than zero if sending ERC20 tokens
    function deposit(
        address _token,
        uint256 _amount,
        uint256 _lockedTime
    ) external payable {
        require(msg.sender != address(0), "Vault already has an onwer");
        require(_token != address(0), "Token provided not valid");
        require(_amount > 0, "Amount to deposit must be bigger than zero");
        require(_lockedTime > 0, "Locked time must be bigger than zero");

        IERC20(_token).transferFrom(msg.sender, address(this), _amount);

        VaultDeposit memory newUserDeposit;
        newUserDeposit.token = _token;
        newUserDeposit.amount = _amount;
        newUserDeposit.lockEndTime = block.timestamp + _lockedTime;
        vaultDeposits[msg.sender].push(newUserDeposit);

        emit Deposit(msg.sender, _token, _amount);
    }

    /// @dev You can withdraw ERC20
    function withdraw(
        address _token,
        uint256 _amount,
        uint256 _depositIndex
    ) external payable {
        VaultDeposit storage userDeposit = vaultDeposits[msg.sender][
            _depositIndex
        ];

        require(
            _amount <= userDeposit.amount,
            "Amount to withdraw exceeds deposit amount"
        );
        require(
            block.timestamp >= userDeposit.lockEndTime,
            "Deposit not available"
        );

        IERC20(_token).transfer(msg.sender, _amount);

        userDeposit.amount -= _amount;
        emit Withdraw(msg.sender, _token, _amount);
    }

    /// @dev Get the deposits of a specific user
    function getUserDeposits(address user)
        external
        view
        returns (VaultDeposit[] memory)
    {
        return vaultDeposits[user];
    }

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Deposit(address indexed from, address token, uint256 value);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Withdraw(address indexed to, address token, uint256 value);

    /// @dev this contract should not receive ether directly from a wallet.
    /// The only way to receive ether should be via the deposit method.
    // receive() external payable{}
    // fallback() external payable{}
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