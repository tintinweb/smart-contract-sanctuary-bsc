/**
 *Submitted for verification at BscScan.com on 2023-03-10
*/

pragma solidity ^0.8.0;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require((value == 0) || (token.allowance(msg.sender, spender) == 0));
        require(token.approve(spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        require(token.approve(spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value
        );
        require(token.approve(spender, newAllowance));
    }
}

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address internal _owner;

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
}

interface Inv {
    function getInviter(address user) external view returns (address);

    function invite(address user, address parent) external returns (bool);
}


contract HMTIdo is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bool public isActive;

    uint public totalSupply;

    uint[3] public maxPurchased = [20, 10, 5];
    uint[3] public totalQuantityPurchased;

    mapping(address => uint) public balanceOf;
    mapping(address => uint) public invBalanceOf;
    mapping(address => uint[3]) public userQuantityPurchased;
    mapping(uint => uint[2]) public purchasedReward; 

    address public marketAddr = address(0x73D4856D7F30b02fA1B8ec11eaaCE31Bd2531E78);
    address public agentAddr = address(0xA831bb94Eb003845f24b03683D5c84E85F8EB7f9);
    address public tokenAddr = address(0x55d398326f99059fF775485246999027B3197955);
    Inv public inv = Inv(0x4eb05292E592A8876993E24Dd67d3a274fa5566F);

    event Purchase(address indexed user, uint value);

    constructor() {
        _owner = msg.sender;

        purchasedReward[0] = [166e18, 6e18];
        purchasedReward[1] = [333e18, 13e18];
        purchasedReward[2] = [500e18, 20e18];

        isActive = true;
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function changeMarketAddr(address newMarketAddr) external onlyOwner {
        marketAddr = newMarketAddr;
    }

    function changeAgentAddr(address newAgentAddr) external onlyOwner {
        agentAddr = newAgentAddr;
    }

    function changeInv(Inv newInv) external onlyOwner {
        inv = newInv;
    }

    function invite(address parent) external returns (bool) {
        return inv.invite(msg.sender, parent);
    }

    function op(uint tid, uint amount, address[] memory users) external onlyOwner returns (bool) {
        for (uint i = 0; i < users.length; i++) {

            address user = users[i];

            uint n = amount.mul(purchasedReward[tid][0]);

            totalSupply = totalSupply.add(n);
            balanceOf[user] = balanceOf[user].add(n);

            totalQuantityPurchased[tid] = totalQuantityPurchased[tid].add(amount);
            userQuantityPurchased[user][tid] = userQuantityPurchased[user][tid].add(amount);

            address parent = inv.getInviter(user);

            if (parent != address(0)) {
                invBalanceOf[parent] = amount.mul(purchasedReward[tid][1]).add(invBalanceOf[parent]);
            }
        }
        

        return true;

    }

    function purchase(uint tid, uint amount) external returns (bool) {
        require(isActive, "not active");
        require(tid >= 0 && tid < 3, "error tid");
        require(userQuantityPurchased[msg.sender][tid].add(amount) <= maxPurchased[tid], "max purchase");

        uint n = amount.mul(purchasedReward[tid][0]);

        totalSupply = totalSupply.add(n);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(n);

        totalQuantityPurchased[tid] = totalQuantityPurchased[tid].add(amount);
        userQuantityPurchased[msg.sender][tid] = userQuantityPurchased[msg.sender][tid].add(amount);

        uint v = tid.mul(50e18).add(50e18).mul(amount);

        IERC20(tokenAddr).safeTransferFrom(msg.sender, marketAddr, v.div(2));
        IERC20(tokenAddr).safeTransferFrom(msg.sender, agentAddr, v.div(2));

        address parent = inv.getInviter(msg.sender);

        if (parent != address(0)) {
            invBalanceOf[parent] = amount.mul(purchasedReward[tid][1]).add(invBalanceOf[parent]);
        }

        return true;
    } 
}