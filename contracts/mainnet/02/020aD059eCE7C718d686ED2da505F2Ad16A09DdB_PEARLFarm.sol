/**
 *Submitted for verification at BscScan.com on 2022-12-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IERC20 {
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);


    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IPEARL is IERC20 {
    function miningPeriod() external view returns (uint256);
    function miningStartTime() external view returns (uint256);
    function getMiningId() external view returns (uint256);
    function tradingVolume(uint256) external view returns (uint256);
    function topInviter(address) external view returns (address);
}

contract PEARLFarm is Ownable {
    using SafeMath for uint256;

    IERC20 public lpToken;
    IPEARL public pearl;
    struct IStack{
        uint256 totalAmount;
        uint256 withdrawAmount;
        uint256 startTime;
    }

    struct IStackItem{
        uint256 totalAmount;
        uint256 withdrawAmount;
        uint256 startTime;
        uint256 index;
        uint256 availableWithdrawAmount;
        uint256 availableClaimeAmount;
    }

    mapping(address => IStack[]) public stacks;
    mapping (uint256 => mapping (address => mapping (uint256 => bool))) public claimed;

    constructor(address _pearl, address _lpToken) {
        pearl = IPEARL(_pearl);
        lpToken = IERC20(_lpToken);
    }

    function getStacks(address _account) public view returns (IStackItem[] memory) {
        IStack[] memory _stacks = stacks[_account];
        IStackItem[] memory _stackItems = new IStackItem[](_stacks.length);
        for (uint256 i = 0; i < _stacks.length; i++) {
            IStack memory _stack = _stacks[i];
            uint256 _availableWithdrawAmount = withdrawAmount(_account,i);
            uint256 _availableClaimeAmount = claimeAmount(_account,i);
            _stackItems[i] = IStackItem(_stack.totalAmount, _stack.withdrawAmount, _stack.startTime, i, _availableWithdrawAmount, _availableClaimeAmount);
        }
        return _stackItems;
    }

    function lpStack(uint256 _amount) public {
        require(lpToken.balanceOf(msg.sender) >= _amount, "Not enough balance");
        require(lpToken.allowance(msg.sender, address(this)) >= _amount, "Not enough allowance");
        lpToken.transferFrom(msg.sender, address(this), _amount);
        stacks[msg.sender].push(IStack(_amount, 0, block.timestamp));
    }

    function withdrawAmount(address _account, uint256 _index) public view returns (uint256) {
        IStack memory stack = stacks[_account][_index];
        uint256 months = block.timestamp.sub(stack.startTime).div(10 minutes);
        uint256 amountRelease= stack.totalAmount.mul(months).div(20);
        if(amountRelease > stack.totalAmount) amountRelease = stack.totalAmount;
        return amountRelease.sub(stack.withdrawAmount);
    }

    function lpWithdraw(uint256 _index) public {
        require(stacks[msg.sender].length > _index, "Invalid index");

        uint256 amount = withdrawAmount(msg.sender, _index);
        require(amount > 0, "Nothing to withdraw");

        stacks[msg.sender][_index].withdrawAmount += amount;
        lpToken.transfer(msg.sender, amount);
    }

    function claimeAmount(address _account, uint256 _index) public view returns (uint256) {
        uint256 miningId = pearl.getMiningId();
        if(miningId == 0) return 0;

        bool _isClaimed = isClaimed(_account, _index);
        if(_isClaimed) return 0;

        IStack memory stack = stacks[_account][_index];

        uint256 userAmount = stack.totalAmount.sub(stack.withdrawAmount);
        uint256 lpAmount = lpToken.balanceOf(address(this));
        if(userAmount == 0 || lpAmount == 0) return 0;

        return pearl.tradingVolume(miningId-1).mul(userAmount).div(lpAmount);
    }

    function emergencyWithdraw(address account, uint256 amount) public onlyOwner {
        pearl.transfer(account, amount);
    }

    function isClaimed(address account,uint256 _index) public view returns (bool) {
        uint256 miningId = pearl.getMiningId();
        return claimed[miningId][account][_index];
    }

    function claime(uint256 _index) public {
        uint256 miningId = pearl.getMiningId();
        require(miningId > 0, "No reward");

        uint256 reward = claimeAmount(msg.sender, _index);
        require(reward > 0, "No reward");

        require(pearl.balanceOf(address(this)) >= reward, "Not enough balance");

        claimed[miningId][msg.sender][_index] = true;

        uint256 rewardFinal = reward;
        address inviterAddress1 = pearl.topInviter(msg.sender);
        if(inviterAddress1 != address(0)){
            uint256 inviterReward = reward.mul(10).div(100);
            
            pearl.transfer(inviterAddress1, inviterReward);
            rewardFinal = rewardFinal.sub(inviterReward);

            address inviterAddress2 = pearl.topInviter(inviterAddress1);
            if(inviterAddress2 != address(0)){
                pearl.transfer(inviterAddress2, inviterReward);
                rewardFinal = rewardFinal.sub(inviterReward);
            }
        }
        pearl.transfer(msg.sender, rewardFinal);
    }

}