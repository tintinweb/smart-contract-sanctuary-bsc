/**
 *Submitted for verification at BscScan.com on 2022-06-07
*/

//SPDX-License-Identifier: Unlicense
/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/
pragma solidity ^0.6.12;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

   
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }


    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
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

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () public {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
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
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
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

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function mint(address account, uint256 amount) external;
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function setDividendAccount(address account, uint256 amount) external;
    function isExcludeFromFees(address account) external returns(bool);
    function excludeFromFees(address account, bool excluded) external;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ABDefi is Ownable {
    using SafeMath for uint256;
    using Address for address;

    IUniswapV2Router02 public uniswapV2Router;
    IUniswapV2Factory public uniswapV2Factory;
    IUniswapV2Pair public apair;
    IUniswapV2Pair public bpair;
    mapping(address => uint256) public _aBalances;
    mapping(address => uint256) public _aReleased;
    mapping(address => mapping(uint256 => uint256)) public _aJoinTimeAmount;
    mapping(address => mapping(uint256 => uint256)) public _aJoinTimeReleased;
    mapping(address => uint256) public _bBalances;
    mapping(address => uint256) public _bReleased;
    mapping(address => mapping(uint256 => uint256)) public _bJoinTimeAmount;
    mapping(address => mapping(uint256 => uint256)) public _bJoinTimeReceivable;
    mapping(address => mapping(uint256 => uint256)) public _bJoinTimeReleased;
    mapping(address => uint256[]) public _joinTimes;
    mapping(address => address) public inviter;

    uint256 constant public DAY = 86400;
    uint256 constant public PERIOD = 8640000;

    uint256 public totalReleaseA;
    uint256 public total;
    uint256 public sold;
    uint256 public bStart;
    uint256 public bStartTwo;
    uint256 public bStartThree;

    IERC20 public USDT;
    IERC20 public A;
    IERC20 public B;
    address public ceoAddr;
    address public marketAddr;

    event ReleaseA(address indexed account, uint256 amount);
    event ReleaseB(address indexed account, uint256 amount);
    event Purchase(address indexed account, uint256 amount);
    event SetInviter(address indexed inviter, address indexed invitee);
    
    constructor(address _usdt, address _a, address _b, address _router, address _factory, uint256 _bStart, 
        address _apair, address _bpair, address _ceoAddr, address _marketAddr) public {
        USDT = IERC20(_usdt);
        A = IERC20(_a);
        B = IERC20(_b);
        ceoAddr = _ceoAddr;
        marketAddr = _marketAddr;
        uniswapV2Router = IUniswapV2Router02(_router);
        uniswapV2Factory = IUniswapV2Factory(_factory);
        apair = IUniswapV2Pair(_apair);
        bpair = IUniswapV2Pair(_bpair);
        bStart = _bStart;
        bStartTwo = bStart.add(PERIOD);
        bStartThree = bStartTwo.add(PERIOD);
        USDT.approve(address(uniswapV2Router), ~uint256(0));
        A.approve(address(uniswapV2Router), ~uint256(0));
        B.approve(address(uniswapV2Router), ~uint256(0));
        apair.approve(address(uniswapV2Router), ~uint256(0));
        bpair.approve(address(uniswapV2Router), ~uint256(0));
    }

    function aBalanceOf(address account) public view returns (uint256) {
        return _aBalances[account];
    }

    function bBalanceOf(address account) public view returns (uint256) {
        return _bBalances[account];
    }

    function setBStart(uint256 _bStart) external onlyOwner {
        bStart = _bStart;
        bStartTwo = bStart.add(PERIOD);
        bStartThree = bStartTwo.add(PERIOD);
    }

    function setInviter(address account) external {
        require(inviter[msg.sender] == address(0), "Have been invited");
	    // require(balanceOf(account) > 0 || IERC20(idoWallet).balanceOf(account) > 0, "inviter must be gt 0");
        inviter[msg.sender] = account;
        emit SetInviter(account, msg.sender);
    }

    function purchase(uint256 amount, uint256 time) public {
        // uint256 current = block.timestamp;
        uint256 current = time;
        // 累计算力
        total = total.add(amount);
        // 计算A的数量
        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(A);
        uint256[] memory amounts = uniswapV2Router.getAmountsOut(amount, path);
        uint256 amountA = amounts[1];

        // 20%购买A
        swapTokensForA(amount*2/10);
        _aBalances[msg.sender] = _aBalances[msg.sender].add(amountA);
        _aJoinTimeAmount[msg.sender][current] = amountA;
        totalReleaseA = totalReleaseA.add(amountA);
        // 70%购买B
        swapTokensForB(amount*7/10);
        uint256 amountB = getAmountB(amount, current);
        _bBalances[msg.sender] = _aBalances[msg.sender].add(amountB);
        _bJoinTimeAmount[msg.sender][current] = amount;
        _bJoinTimeReceivable[msg.sender][current] = amountB;
        // 加入时间记录一下
        uint256[] storage times = _joinTimes[msg.sender];
        times.push(current);
        _joinTimes[msg.sender] = times;
        // 10%给推荐人
        if(inviter[msg.sender] == address(0)) {
            USDT.transferFrom(msg.sender, inviter[msg.sender], amount/10);
        } else {
            USDT.transferFrom(msg.sender, ceoAddr, amount/10);
        }
        emit Purchase(msg.sender, amount);
    }

    function getAmountB(uint256 amount, uint256 _time) private view returns (uint256) {
        uint256 diff = _time.sub(bStart);
        uint256 perAmount = amount.div(1000);
        // 0.5%和0.4%
        if(diff <= PERIOD) {
            uint256 fiveDays = bStartTwo.sub(_time).div(DAY);
            return perAmount.mul(fiveDays).mul(5)
                .add(perAmount.mul(100-fiveDays).mul(4));
        // 0.4%和0.3%
        } else if(diff > PERIOD && diff < PERIOD.mul(2)) {
            uint256 fourDays = bStartThree.sub(_time).div(DAY);
            return perAmount.mul(fourDays).mul(4)
                .add(perAmount.mul(100-fourDays).mul(3));
        // 0.3%
        } else {
            return amount.mul(3).div(10);
        }
    }

    function calculateARelease() public view returns (uint256) {
        uint256 current = block.timestamp;
        uint256[] memory joinTimes = _joinTimes[msg.sender];
        uint256 releaseAmount;
        for(uint256 i = 0; i < joinTimes.length; i++) {
            uint256 diff = joinTimes[i].sub(current);
            // 时间大于1天，并且没有释放完
            if(diff >= DAY && _aJoinTimeReleased[msg.sender][joinTimes[i]] < _aJoinTimeAmount[msg.sender][joinTimes[i]]) {
                // 计算需要释放的金额
                uint256 day = diff.div(DAY) >= 100 ? 100 : diff.div(DAY);
                uint256 needRelease = _aJoinTimeAmount[msg.sender][joinTimes[i]].div(100).mul(day);
                if(needRelease <= _aJoinTimeReleased[msg.sender][joinTimes[i]]) {
                    continue;
                }
                needRelease = needRelease.sub(_aJoinTimeReleased[msg.sender][joinTimes[i]]);
                releaseAmount = releaseAmount.add(needRelease);
            }
        }
        return releaseAmount;
    }

    function getRealeaseANum() private returns (uint256) {
        uint256 current = block.timestamp;
        uint256[] memory joinTimes = _joinTimes[msg.sender];
        uint256 releaseAmount;
        for(uint256 i = 0; i < joinTimes.length; i++) {
            uint256 diff = current.sub(joinTimes[i]);
            // 时间大于1天，并且没有释放完
            if(diff >= DAY && _aJoinTimeReleased[msg.sender][joinTimes[i]] < _aJoinTimeAmount[msg.sender][joinTimes[i]]) {
                // 领取天数
                uint256 day = diff.div(DAY) >= 100 ? 100 : diff.div(DAY);
                // 领取金额
                uint256 needRelease = _aJoinTimeAmount[msg.sender][joinTimes[i]].div(100).mul(day);
                if(needRelease <= _aJoinTimeReleased[msg.sender][joinTimes[i]]) {
                    continue;
                }
                // 释放金额 = 领取金额 - 已释放金额
                needRelease = needRelease.sub(_aJoinTimeReleased[msg.sender][joinTimes[i]]);
                // 更新已释放金额
                _aJoinTimeReleased[msg.sender][joinTimes[i]] = _aJoinTimeReleased[msg.sender][joinTimes[i]].add(needRelease);
                // 累加每一次加入的释放金额
                releaseAmount = releaseAmount.add(needRelease);
            }
        }
        return releaseAmount;
    }

    function releaseA() public {
        uint256 releaseAmount = getRealeaseANum();
        A.transfer(msg.sender, releaseAmount);
        emit ReleaseA(msg.sender, releaseAmount);
    }

    function calculateBRelease() public view returns (uint256, uint256) {
        uint256 current = block.timestamp;
        uint256[] memory joinTimes = _joinTimes[msg.sender];
        uint256 releaseAmount;
        for(uint256 i = 0; i < joinTimes.length; i++) {
            uint256 diff = current.sub(joinTimes[i]);
            if(diff >= DAY && _bJoinTimeReleased[msg.sender][joinTimes[i]] < _bJoinTimeReceivable[msg.sender][joinTimes[i]]) {
                // 领取天数
                uint256 day = diff.div(DAY) >= 100 ? 100 : diff.div(DAY);
                uint256 bDiff = joinTimes[i].sub(bStart);
                uint256 perAmount = _bJoinTimeAmount[msg.sender][joinTimes[i]].div(1000);
                // 领取金额
                uint256 needRelease;
                // 0.5%和0.4%
                if(bDiff <= PERIOD) {
                    uint256 fiveDays = bStartTwo.sub(joinTimes[i]).div(DAY);
                    if(fiveDays >= day) {
                        needRelease = perAmount.mul(day).mul(5);
                    } else {
                        needRelease = perAmount.mul(fiveDays).mul(5)
                            .add(perAmount.mul(day.sub(fiveDays)).mul(4));
                    }
                // 0.4%和0.3%
                } else if(bDiff > PERIOD && bDiff < PERIOD.mul(2)) {
                    uint256 fourDays = bStartThree.sub(joinTimes[i]).div(DAY);
                    if(fourDays >= day) {
                        needRelease = perAmount.mul(day).mul(4);
                    } else {
                        needRelease = perAmount.mul(fourDays).mul(4)
                            .add(perAmount.mul(day.sub(fourDays)).mul(3));
                    }
                // 0.3%
                } else {
                    needRelease =  perAmount.mul(day).mul(3);
                }
                if(needRelease <= _aJoinTimeReleased[msg.sender][joinTimes[i]]) {
                    continue;
                }
                // 释放金额 = 领取金额 - 已释放金额
                needRelease = needRelease.sub(_bJoinTimeReleased[msg.sender][joinTimes[i]]);
                // 累加每一次加入的释放金额
                releaseAmount = releaseAmount.add(needRelease);
            }
        }
        uint256 price;
        if(releaseAmount > 0) {
            // 计算B的数量
            address[] memory path = new address[](2);
            path[0] = address(USDT);
            path[1] = address(B);
            uint256[] memory amounts = uniswapV2Router.getAmountsOut(releaseAmount, path);
            price = amounts[1];
        }
        
        return (releaseAmount, price);
    }   

    function getRealeaseBNum() private returns (uint256) {
        uint256 current = block.timestamp;
        uint256[] memory joinTimes = _joinTimes[msg.sender];
        uint256 releaseAmount;
        for(uint256 i = 0; i < joinTimes.length; i++) {
            uint256 diff = current.sub(joinTimes[i]);
            if(diff >= DAY && _bJoinTimeReleased[msg.sender][joinTimes[i]] < _bJoinTimeReceivable[msg.sender][joinTimes[i]]) {
                // 领取天数
                uint256 day = diff.div(DAY) >= 100 ? 100 : diff.div(DAY);
                uint256 bDiff = joinTimes[i].sub(bStart);
                uint256 perAmount = _bJoinTimeAmount[msg.sender][joinTimes[i]].div(1000);
                // 领取金额
                uint256 needRelease;
                // 0.5%和0.4%
                if(bDiff <= PERIOD) {
                    uint256 fiveDays = bStartTwo.sub(joinTimes[i]).div(DAY);
                    if(fiveDays >= day) {
                        needRelease = perAmount.mul(day).mul(5);
                    } else {
                        needRelease = perAmount.mul(fiveDays).mul(5)
                            .add(perAmount.mul(day.sub(fiveDays)).mul(4));
                    }
                // 0.4%和0.3%
                } else if(bDiff > PERIOD && bDiff < PERIOD.mul(2)) {
                    uint256 fourDays = bStartThree.sub(joinTimes[i]).div(DAY);
                    if(fourDays >= day) {
                        needRelease = perAmount.mul(day).mul(4);
                    } else {
                        needRelease = perAmount.mul(fourDays).mul(4)
                            .add(perAmount.mul(day.sub(fourDays)).mul(3));
                    }
                // 0.3%
                } else {
                    needRelease =  perAmount.mul(day).mul(3);
                }
                if(needRelease <= _aJoinTimeReleased[msg.sender][joinTimes[i]]) {
                    continue;
                }
                // 释放金额 = 领取金额 - 已释放金额
                needRelease = needRelease.sub(_bJoinTimeReleased[msg.sender][joinTimes[i]]);
                // 更新已释放金额
                _bJoinTimeReleased[msg.sender][joinTimes[i]] = _bJoinTimeReleased[msg.sender][joinTimes[i]].add(needRelease);
                // 累加每一次加入的释放金额
                releaseAmount = releaseAmount.add(needRelease);
            }
        }
        return releaseAmount;
    }

    function releaseB() public {
        uint256 releaseAmount = getRealeaseBNum();
        // 计算B的数量
        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(B);
        uint256[] memory amounts = uniswapV2Router.getAmountsOut(releaseAmount, path);

        B.mint(msg.sender, amounts[1]);
        emit ReleaseB(msg.sender, amounts[1]);
    }

    function swapTokensForA(uint256 amount) private {
        USDT.transferFrom(msg.sender, address(this), amount);
        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(A);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function swapTokensForB(uint256 amount) private {
        USDT.transferFrom(msg.sender, address(this), amount);
        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(B);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addALiquidity(uint256 aAmount, uint256 usdtAmount) public {
        A.transferFrom(msg.sender, address(this), aAmount);
        USDT.transferFrom(msg.sender, address(this), usdtAmount);
        
        uniswapV2Router.addLiquidity(
            address(A),
            address(USDT),
            aAmount,
            usdtAmount,
            0,
            0,
            msg.sender,
            block.timestamp
        );
    }

    function removeALiquidity(uint256 lpAmount) public {
        bool exclude = A.isExcludeFromFees(msg.sender);
        if(!exclude) {
            A.excludeFromFees(msg.sender, true);
        }

        apair.transferFrom(msg.sender, address(this), lpAmount);
        uniswapV2Router.removeLiquidity(
            address(A),
            address(USDT),
            lpAmount,
            0,
            0,
            msg.sender,
            block.timestamp
        );

        if(!exclude) {
            A.excludeFromFees(msg.sender, false);
        }
    }

    function addBLiquidity(uint256 bAmount, uint256 usdtAmount) public {
        B.transferFrom(msg.sender, address(this), bAmount);
        USDT.transferFrom(msg.sender, address(this), usdtAmount);
        
        uniswapV2Router.addLiquidity(
            address(B),
            address(USDT),
            bAmount,
            usdtAmount,
            0,
            0,
            msg.sender,
            block.timestamp
        );
    }

    function removeBLiquidity(uint256 lpAmount) public {
        bool exclude = B.isExcludeFromFees(msg.sender);
        if(!exclude) {
            B.excludeFromFees(msg.sender, true);
        }

        bpair.transferFrom(msg.sender, address(this), lpAmount);
        uniswapV2Router.removeLiquidity(
            address(B),
            address(USDT),
            lpAmount,
            0,
            0,
            msg.sender,
            block.timestamp
        );

        if(!exclude) {
            B.excludeFromFees(msg.sender, false);
        }
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) public view
        returns (uint amountOut)
    {
        return uniswapV2Router.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) public view
        returns (uint amountIn)
    {
        return uniswapV2Router.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(uint amountIn, address[] memory path) public view
        returns (uint[] memory amounts)
    {
        return uniswapV2Router.getAmountsOut(amountIn, path);
    }

    function getAmountsIn(uint amountOut, address[] memory path) public view
        returns (uint[] memory amounts)
    {
        return uniswapV2Router.getAmountsIn(amountOut, path);
    }

    function withrawForAdmin(address _token) external onlyOwner {
        IERC20(_token).transfer(msg.sender, IERC20(_token).balanceOf(address(this)));
    }

}