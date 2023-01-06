/**
 *Submitted for verification at BscScan.com on 2023-01-06
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

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

interface IPancakeERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;
}

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

interface IWe2netToken is IERC20Metadata {
    function mint(address account, uint256 amount) external;
    function burn(uint256 amount) external;
    
    function setClaimAmount(address node, uint256 amount, bool addOrNot) external;
    //function setParentNodeByManager(address _node, address _parent) external;
    function parentNode(address node) external view returns (address);
    function levelOf(address node) external view returns (uint256);
    function rootNode() external view returns (address);
}

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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint256);

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint256);
    function price1CumulativeLast() external view returns (uint256);
    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);
    function burn(address to) external returns (uint256 amount0, uint256 amount1);
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract LiquidityHub is Ownable {
    using SafeMath for uint256;

    address public we2netToken;
    address public usdtToken;
    address public pair;

    uint256 public endTime = 1703670006;

    mapping(address => uint256) public liquidity;
    uint256 public holderCount;

    uint256 public taxRate;
    uint256 private _taxBase = 10000;
    uint256 private _rewardBase = 10000;

    address private _taxManager;
    address private _feeManager;
    address private _recycleManager;
    mapping(address => uint256) public rewardOf;

    mapping(uint256 => uint256) public rewardRate;
    uint256 private _topRewardRate = 10000;

    uint256 private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'LiquidityHub: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    event ClaimReward(address indexed account, uint256 value);
    event AddLiquidity(address indexed account, uint256 amountUsdt, uint256 amountLiquidity);
    event RemoveLiquidity(address indexed account, uint256 amountLiquidity, uint256 amountUsdt);

    constructor(address _we2netToken, address _usdtToken, address _pair) {
        we2netToken = _we2netToken;
        usdtToken = _usdtToken;
        pair = _pair;
        _taxManager = _msgSender();
        _feeManager = _msgSender();
        _recycleManager = _msgSender();
    }

    function addLiquidity(uint256 amountUsdt) public lock {
        require(block.timestamp < endTime, "LiquidityHub: time is end.");
        require(amountUsdt > 10**10, "LiquidityHub: the quantity is too little.");

        if(liquidity[_msgSender()] == 0) holderCount++;

        uint256 liquidityMint;
        if(taxRate == 0) {
            TransferHelper.safeTransferFrom(usdtToken, _msgSender(), pair, amountUsdt);
            IWe2netToken(we2netToken).mint(pair, amountUsdt.mul(10));
            liquidityMint = IPancakePair(pair).mint(address(this));
            liquidity[_msgSender()] = liquidity[_msgSender()].add(liquidityMint);
        } else {
            uint256 taxUsdt = amountUsdt.mul(taxRate).div(_taxBase);
            uint256 remainUsdt = amountUsdt.sub(taxUsdt);
            address parentAddress = IWe2netToken(we2netToken).parentNode(_msgSender());
            if(parentAddress == address(0)) {
                TransferHelper.safeTransferFrom(usdtToken, _msgSender(), _taxManager, taxUsdt);
            } else {
                TransferHelper.safeTransferFrom(usdtToken, _msgSender(), address(this), taxUsdt);
                rewardOf[parentAddress] = rewardOf[parentAddress].add(taxUsdt);
            }

            TransferHelper.safeTransferFrom(usdtToken, _msgSender(), pair, remainUsdt);
            IWe2netToken(we2netToken).mint(pair, remainUsdt.mul(10));
            liquidityMint = IPancakePair(pair).mint(address(this));
            liquidity[_msgSender()] = liquidity[_msgSender()].add(liquidityMint);
        }
        emit AddLiquidity(_msgSender(), amountUsdt, liquidityMint);
    }

    function removeLiquidity(uint256 amount) public lock {
        require(liquidity[_msgSender()] >= amount, "LiquidityHub: liquidity is not enough.");

        liquidity[_msgSender()] = liquidity[_msgSender()].sub(amount);
        if(liquidity[_msgSender()] == 0) holderCount--;
        TransferHelper.safeTransfer(pair, pair, amount); // send liquidity to pair
        (uint256 amount0, uint256 amount1) = IPancakePair(pair).burn(address(this));
        if(we2netToken < usdtToken) {
            TransferHelper.safeTransfer(we2netToken, _recycleManager, amount0);
            TransferHelper.safeTransfer(usdtToken, _msgSender(), amount1);
            emit RemoveLiquidity(_msgSender(), amount, amount1);
        } else {
            TransferHelper.safeTransfer(we2netToken, _recycleManager, amount1);
            TransferHelper.safeTransfer(usdtToken, _msgSender(), amount0);
            emit RemoveLiquidity(_msgSender(), amount, amount0);
        }
    }

    function calcUsdt(address account) public view returns (uint256) {
        uint256 totalSupply = IPancakeERC20(pair).totalSupply();
        uint256 usdtPool = IERC20(usdtToken).balanceOf(pair);
        uint256 usdtAmount = liquidity[account].mul(usdtPool).div(totalSupply);
        return usdtAmount;
    }

    function setEndTime(uint256 _endTime) public onlyOwner {
        endTime = _endTime;
    }

    function setManger(address taxManager, address feeManager, address recycleManager) public onlyOwner {
        _taxManager = taxManager;
        _feeManager = feeManager;
        _recycleManager = recycleManager;
    }

    function setTaxRate(uint256 _taxRate) public onlyOwner {
        require(_taxRate < _taxBase, "LiquidityHub: taxRate is too high.");
        taxRate = _taxRate;
    }

    function setTaxAndRewardBase(uint256 taxBase, uint256 rewardBase) public onlyOwner {
        require(taxRate < taxBase, "LiquidityHub: taxBase is too low.");
        require(_topRewardRate <= rewardBase, "LiquidityHub: rewardBase is too low.");
        _taxBase = taxBase;
        _rewardBase = rewardBase;
    }

    function setTopRewardRate(uint256 topRewardRate) public onlyOwner {
        require(topRewardRate <= _rewardBase, "LiquidityHub: topRewardRate is too high.");
        _topRewardRate = topRewardRate;
    }

    function setRewardRate(uint256 level, uint256 rate) public onlyOwner {
        require(rate <= _rewardBase, "LiquidityHub: rewardRate is too high.");
        rewardRate[level] = rate;
    }

    function claimReward(address account) public {
        uint256 totalReward = rewardOf[account];
        require(totalReward > 0, "LiquidityHub: reward is null.");
        delete rewardOf[account];
        if (account == IWe2netToken(we2netToken).rootNode()) {
            TransferHelper.safeTransfer(usdtToken, account, totalReward);
            return;
        }

        uint256 topReward = totalReward.mul(_topRewardRate).div(_rewardBase);
        uint256 nodeLevel = IWe2netToken(we2netToken).levelOf(account);
        uint256 nodeReward = topReward.mul(rewardRate[nodeLevel]).div(_rewardBase);
        uint256 feeReward = topReward.sub(nodeReward);
        uint256 parentReward = totalReward.sub(topReward);

        TransferHelper.safeTransfer(usdtToken, account, nodeReward);
        IWe2netToken(we2netToken).setClaimAmount(account, nodeReward.mul(10), true);

        if(feeReward > 0) TransferHelper.safeTransfer(usdtToken, _feeManager, feeReward);
        if(parentReward > 0) {
            address parentAddress = IWe2netToken(we2netToken).parentNode(account);
            rewardOf[parentAddress] = rewardOf[parentAddress].add(parentReward);
        }

        emit ClaimReward(account, nodeReward);
    }

    function calcReward(address account) public view returns (uint256) {
        uint256 totalReward = rewardOf[account];
        if (account == IWe2netToken(we2netToken).rootNode()) {
            return totalReward;
        }

        uint256 topReward = totalReward.mul(_topRewardRate).div(_rewardBase);
        uint256 nodeLevel = IWe2netToken(we2netToken).levelOf(account);
        uint256 nodeReward = topReward.mul(rewardRate[nodeLevel]).div(_rewardBase);
        return nodeReward;
    }
}