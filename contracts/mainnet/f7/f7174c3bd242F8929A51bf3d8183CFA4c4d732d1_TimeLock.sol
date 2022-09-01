/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract TimeLock{
    address constant TOKEN_ADDRESS = 0x7Ad708eAD2BDA04f4DC25783aAF9f5cB25E534D0;
    
    struct User {
        uint40 deposit_time;
        uint256 total_deposit;
        uint256 total_withdraw;
    }

    IERC20 token;
    
    address public owner;
    uint256 public balance;
    
    uint256 public total_users;
    address[] public locked_users;
    
    mapping(address => User) public users;
    
    event Deposit(address indexed addr, uint256 indexed amount);
    event Withdraw(address indexed addr, uint256 indexed amount);
    
    constructor() {
        owner = msg.sender;
        token = IERC20(TOKEN_ADDRESS);

        token.approve(address(this), token.totalSupply());
    }
    
    function lockFor(address _addr, uint256 _amount) public {
        require(msg.sender == owner, "Error: Insufficient permission.");
        
        token.transferFrom(msg.sender, address(this), _amount);
        
        users[_addr].deposit_time = uint40(block.timestamp);
        users[_addr].total_deposit = _amount;
        
        locked_users.push(_addr);
        total_users++;
        
        balance += _amount;
        emit Deposit(_addr, _amount);
    }
    
    function calculateUnlockedTokens(address _addr) view external returns(uint256) {
        uint256 unlocked = 0;
        if(users[_addr].total_withdraw < users[_addr].total_deposit) {
            unlocked = (users[_addr].total_deposit * ((block.timestamp - users[_addr].deposit_time) / 30 days) * 1000 / 100000) - users[_addr].total_withdraw;
            
            if(users[_addr].total_withdraw + unlocked > users[_addr].total_deposit) {
                unlocked = users[_addr].total_deposit - users[_addr].total_withdraw;
            }
        }
        
        return unlocked;
    }
    
    function claim() public {
        require(users[msg.sender].total_deposit > 0, "Error: Insufficient permission.");
        require(this.calculateUnlockedTokens(msg.sender) > 0, "Error: No withdrawable balance.");
        
        uint256 amount = this.calculateUnlockedTokens(msg.sender);
        
        users[msg.sender].total_withdraw += amount;
        balance -= amount;

        token.transferFrom(address(this), msg.sender, amount);
        
        emit Withdraw(msg.sender, amount);
    }
    
}