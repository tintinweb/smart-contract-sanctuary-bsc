/**
 *Submitted for verification at BscScan.com on 2023-02-03
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/interfaces/IERC20.sol


// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;


// File: contracts/lock.sol


pragma solidity ^0.8.9;


contract Lock {
    address public owner;
    IERC20 public token;
    address public vault;
    // mapping(address=> bool) public fraudDeposit;
    // mapping(address=>bool) public genuineDeposit;

    // mapping(address=> mapping(bool=>bool)) public isfraud;
    event deposited(address depositer, uint256 amount);
    event spotted(address depositer, bool check, uint256 amount, address vault);

    mapping(address => uint256) public amountDeposited;
    mapping(address => bool) public isSpotter;

    constructor(IERC20 _token) {
        owner = msg.sender;
        token = IERC20(_token);
    }

    struct Transactions {
        address depositer;
        address vault;
        bool check;
    }
    Transactions[] public transactions;

    function deposit(uint256 _amount) external {
        token.transferFrom(msg.sender, address(this), _amount);
        amountDeposited[msg.sender] = _amount;
        emit deposited(msg.sender, _amount);
    }

    function addSpotter(address _spotter) public {
        require(msg.sender == owner);
        isSpotter[_spotter] = true;
    }

    function spotting(
        address _depositer,
        address _vault,
        bool _check
    ) external {
        require(isSpotter[msg.sender]);
        token.transfer(_vault, amountDeposited[_depositer]);
        emit spotted(_depositer, _check, amountDeposited[_depositer], _vault);
        amountDeposited[_depositer] = 0;
    }

    function spottingInBatch(Transactions[] calldata txArray) public {
        require(isSpotter[msg.sender]);
        for (uint256 i = 0; i < txArray.length; i++) {
            Transactions memory x = txArray[i];
            token.transfer(x.vault, amountDeposited[x.depositer]);
            emit spotted(
                x.depositer,
                x.check,
                amountDeposited[x.depositer],
                x.vault
            );
            amountDeposited[x.depositer] = 0;
        }
    }
}