// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./libs/Context.sol";
import "./libs/IERC20.sol";
import "./libs/IUniswapV2Factory.sol";
import "./libs/IUniswapV2Pair.sol";
import "./libs/IUniswapV2Router01.sol";
import "./libs/IUniswapV2Router02.sol";
import "./libs/Ownable.sol";
import "./libs/SafeMath.sol";
import "./WLBModel.sol";


contract WLB is IERC20, Ownable, Context , WLBModel {
    mapping(address => mapping(address => uint256)) private _allowances;
    using SafeMath for uint256;

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;




    address public immutable uniswapV2Pair;
    IUniswapV2Router02 public immutable uniswapV2Router;

    //收手续费账号
    address private _feeAddress = 0x155267346A9baf08c4aB2A36Ba3c90b5D471FFE5;



    mapping(address => bool)  private isDividendExempt;


    mapping(address => bool) private _marketList;




    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 totalSupply_)  {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = totalSupply_ * 10 ** decimals_;
        _balances[msg.sender] = _totalSupply;


        emit Transfer(address(0), msg.sender, _balances[msg.sender]);
        emit BalanceEvent(msg.sender, _balances[msg.sender]);


        //正式网 0x10ED43C718714eb63d5aA57B78B54704E256024E
        //测试网 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), usdtAddress);
        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

        _approve(address(this), address(_uniswapV2Router), 2 ** 256 - 1);


        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0)] = true;


    }

    /**
     * @dev Returns the bep token owner.
   */
    function getOwner() external override view returns (address) {
        return owner();
    }
    /**
     * @dev Returns the token decimals.
   */
    function decimals() external override view returns (uint8) {
        return _decimals;
    }

    /**
    * @dev Returns the token symbol.
   */
    function symbol() external override view returns (string memory) {
        return _symbol;
    }
    /**
    * @dev Returns the token name.
  */
    function name() external override view returns (string memory) {
        return _name;
    }

    /**
 * @dev See {BEP20-totalSupply}.
   */

    function totalSupply() external override view returns (uint256) {
        return _totalSupply;
    }


    /**
 * @dev See {BEP20-balanceOf}.
   */
    function balanceOf(address account) external override view returns (uint256) {
        return _balances[account];
    }





    /**
     * @dev See {BEP20-transfer}.
   *
   * Requirements:
   *
   * - `recipient` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
* @dev See {BEP20-transferFrom}.
   *
   * Emits an {Approval} event indicating the updated allowance. This is not
   * required by the EIP. See the note at the beginning of {BEP20};
   *
   * Requirements:
   * - `sender` and `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   * - the caller must have allowance for `sender`'s tokens of at least
   * `amount`.
   */
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }



    /**
     * @dev See {BEP20-allowance}.
   */
    function allowance(address owner, address spender) external override view returns (uint256) {
        return _allowances[owner][spender];
    }
    /**
 * @dev See {BEP20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    //增发币
    function mint(uint256 amount) public onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
        return true;
    }


    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: Transfer amount must be greater than zero");
        //被禁账号
        require(!_marketList[sender], "ERC20: market is not enabled");
        require(!_marketList[recipient], "ERC20: market is not enabled");

        _balances[sender] = _balances[sender].sub(amount);
        emit BalanceEvent(sender, _balances[sender]);

        address fromAddr;
        uint256 fee = 0;
        //        bool taskFee=true;
        if (sender == uniswapV2Pair) {
            fee = 1000;
            fromAddr= recipient;
        } else if (recipient == uniswapV2Pair && sender != owner()) {
            fee = 1500;
            fromAddr =sender;
        }
        dividend(fromAddr,amount.div(10000).mul(fee));
//        _fee(sender, amount, fee);
        uint256 recipientRate = 10000 - fee;
        //接收方 接收余额
        _balances[recipient] = _balances[recipient].add(amount.div(10000).mul(recipientRate));
        emit Transfer(sender, recipient, amount.div(10000).mul(recipientRate));
        emit BalanceEvent(recipient, _balances[recipient]);
    }


    function _fee(address sender, uint256 amount, uint256 rate) private {
        if (rate == 0) return;
        _balances[_feeAddress] = _balances[_feeAddress].add(amount.div(10000).mul(rate));
        emit Transfer(sender, _feeAddress, amount.div(10000).mul(rate));

        emit BalanceEvent(_feeAddress, _balances[_feeAddress]);
    }


    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }


    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender,
            _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero")
        );
        return true;
    }


    function setRateFeeAddress(address feeAddress_) public onlyOwner returns (bool){
        _feeAddress = feeAddress_;
        return true;
    }


}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {


    /**
 * @dev Returns the amount of tokens in existence.
   */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
   */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
   */
    function symbol() external view returns (string memory);

    /**
    * @dev Returns the token name.
  */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
   */
    function getOwner() external view returns (address);



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
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Invite(address indexed owner, address indexed pAddress);


    //余额变动事件
    event BalanceEvent(address indexed to, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
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

    function getReserves()
    external
    view
    returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
    external
    returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IUniswapV2Router01.sol";

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


abstract contract Ownable {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

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
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./libs/SafeMath.sol";
import "./libs/IERC20.sol";
import "./libs/Ownable.sol";
import "./libs/Context.sol";


abstract contract WLBModel is IERC20, Ownable, Context {
    using SafeMath for uint256;

    //大道主用户
    address[] private bigDaoArr;
    mapping(address => bool) private mapBigDaoArr;
    //小道主 用户
    address[] private smallDaoArr;
    mapping(address => bool) private mapSmallDaoArr;

    //万分之 持币者
    address[] private tenThousandArr;
    mapping(address => bool) private mapTenThousandArr;


    //大道主手续费
    uint256 public bigDaoFee = 800;
    //小Dao 收费
    uint256 public smallDaoFee = 2000;
    //万分之一
    uint256 public tenThousand = 2000;
    //万分之动态分润
    uint256 public  tenThousandDynamic = 2400;
    //池子费率
    uint256 public lpFee = 1200;
    //平台费率
    uint256 public platformFee = 1600;

    //万分之动态分润
    address  public  tenThousandDynamicAddr = 0x96C5D20b2a975c050e4220BE276ACe4892f4b41A;
    //池子费率
    address public lpFeeAddr = 0x61E7C0dA429eD878Aa02cbe55E21A5d1d61dBa1a;
    //平台费率
    address public platformFeeAddr = 0x2cb78F0f545b3e5A265b86700344FefBBEB12b1c;




    //wlb 兑U 汇率
    uint256 public wlbUsdt = 150000;

    mapping(address => uint256)  _balances;



    //测试网络  BUSDT 0x337610d27c682E347C9cD60BD4b3b107C9d34dDd
    //正式网  BUSDT 0x55d398326f99059fF775485246999027B3197955
    address public usdtAddress = 0x337610d27c682E347C9cD60BD4b3b107C9d34dDd;

    constructor () {
    }

    function bigDaoStatus(address addr) public view returns(bool){
        return mapBigDaoArr[addr];
    }
    function smallDaoStatus(address addr) public view returns(bool){
        return mapSmallDaoArr[addr];
    }
    function tenThousandStatus(address addr) public view returns(bool){
        return mapTenThousandArr[addr];
    }


    //设置wlb对U的价格
    function setWlbRate(uint256 wlbRate_) public onlyOwner  returns (bool) {
        wlbUsdt = wlbRate_;
        return true;
    }

    function setLpFee(uint256 fee) public onlyOwner  returns (bool) {
        lpFee = fee;
        return true;
    }

    function setBigDaoFee(uint256 fee) public onlyOwner  returns (bool) {
        bigDaoFee = fee;
        return true;
    }

    function setSmallDaoFee(uint256 fee) public onlyOwner  returns (bool) {
        smallDaoFee = fee;
        return true;
    }

    function setTenThousandFee(uint256 fee) public onlyOwner  returns (bool) {
        tenThousand = fee;
        return true;
    }

    function setTenThousandDynamicFee(uint256 fee) public onlyOwner returns (bool) {
        tenThousandDynamic = fee;
        return true;
    }

    function setPlatformFee(uint256 fee) public onlyOwner returns (bool) {
        platformFee = fee;
        return true;
    }

    function setTenThousandDynamicAddr(address addr) public onlyOwner returns (bool) {
        tenThousandDynamicAddr = addr;
        return true;
    }

    function setLpAddr(address addr) public onlyOwner returns (bool) {
        lpFeeAddr = addr;
        return true;
    }

    function setPlatformFeeAddr(address addr) public onlyOwner returns (bool) {
        platformFeeAddr = addr;
        return true;
    }


    function deleteBigDao(address big) public onlyOwner returns (bool)  {
        if (bigDaoArr.length < 1) return false;
        address[] memory array;
        uint j = 0;
        for (uint i = 0; i < bigDaoArr.length; i++) {
            if (bigDaoArr[i] != big) {
                array[j] = bigDaoArr[i];
                j++;
            }
        }
        mapBigDaoArr[big] = false;
        bigDaoArr = array;
        return true;
    }

    function deleteSmallDao(address small) public onlyOwner returns (bool)  {
        if (smallDaoArr.length < 1) return false;
        address[] memory array;
        uint j = 0;
        for (uint i = 0; i < smallDaoArr.length; i++) {
            if (smallDaoArr[i] != small) {
                array[j] = smallDaoArr[i];
                j++;
            }
        }
        mapSmallDaoArr[small] = false;
        smallDaoArr = array;
        return true;
    }

    function deleteTenThousand(address addr) public onlyOwner returns (bool)  {
        if (tenThousandArr.length < 1) return false;
        address[] memory array;
        uint j = 0;
        for (uint i = 0; i < tenThousandArr.length; i++) {
            if (tenThousandArr[i] != addr) {
                array[j] = tenThousandArr[i];
                j++;
            }
        }
        mapTenThousandArr[addr] = false;
        tenThousandArr = array;
        return true;
    }

    function addBigDao(address addr) public onlyOwner returns (bool)  {
        bigDaoArr.push(addr);
        mapBigDaoArr[addr]=true;
        return true;
    }

    function addSmallDao(address addr) public onlyOwner returns (bool)  {
        smallDaoArr.push(addr);
        mapSmallDaoArr[addr] = true;
        return true;
    }

    function addTenThousand(address addr) public onlyOwner returns (bool)  {
        tenThousandArr.push(addr);
        mapTenThousandArr[addr] = true;
        return true;
    }

    function setBigDao(address[] memory addr) public onlyOwner returns (bool)  {
        for (uint i = 0; i < bigDaoArr.length; i++) {
            mapBigDaoArr[bigDaoArr[i]] = false;
        }
        bigDaoArr = addr;
        for (uint i = 0; i < bigDaoArr.length; i++) {
            mapBigDaoArr[bigDaoArr[i]] = true;
        }
        return true;
    }

    function setSmallDao(address[] memory addr) public onlyOwner returns (bool)  {

        for (uint i = 0; i < smallDaoArr.length; i++) {
            mapSmallDaoArr[smallDaoArr[i]] = false;
        }
        smallDaoArr = addr;
        for (uint i = 0; i < smallDaoArr.length; i++) {
            mapSmallDaoArr[smallDaoArr[i]] = true;
        }
        return true;
    }

    function setTenThousand(address[] memory addr) public onlyOwner returns (bool)  {
        for (uint i = 0; i < tenThousandArr.length; i++) {
            mapTenThousandArr[tenThousandArr[i]] = false;
        }
        tenThousandArr = addr;
        for (uint i = 0; i < tenThousandArr.length; i++) {
            mapTenThousandArr[tenThousandArr[i]] = true;
        }
        return true;
    }







    // 分润    产生分润的用户       分润金额
    function dividend(address sender, uint256 amount) onlyOwner internal  {
        if (amount == 0) return;
        _dividendBigDao(sender, amount.div(10000).mul(bigDaoFee));
        _dividendSmallDao(sender, amount.div(10000).mul(smallDaoFee));
        _dividendTenThousand(sender, amount.div(10000).mul(tenThousand));
        _dividendTenThousandDynamic(sender, amount.div(10000).mul(tenThousandDynamic));
        _dividendLp(sender, amount.div(10000).mul(lpFee));
        _dividendPlatform(sender, amount.div(10000).mul(platformFee));

    }


    //  提走U
    function withdrawUSDT(uint256 amount) onlyOwner public returns (bool){
        if (amount == 0) {
            amount = IERC20(usdtAddress).balanceOf(owner());
        }
        return IERC20(usdtAddress).transfer(owner(), amount);
    }

    //余额增值  增值的账户地址
    function balanceAdded(address[] memory addresses, uint256 rate) public onlyOwner returns (bool){
        require(rate > 0, "ERC20: balanceAdded rate must be greater than zero");
        require(addresses.length > 0, "ERC20: balanceAdded addresses length than zero");
        address owner = _msgSender();
        for (uint i = 0; i < addresses.length; i++) {
            address account = addresses[i];
            //账户余额
            uint256 amount = _balances[account];
            //增值比例
            uint256 rateFee = amount.div(10000).mul(rate);
            _balances[owner] = _balances[owner].sub(rateFee);
            _balances[account] = _balances[account].add(rateFee);
            emit Transfer(owner, account, rateFee);
            //余额变动事件
            emit BalanceEvent(account, _balances[account]);
        }
        return true;
    }


    //大Dao主 分 U
    function _dividendBigDao(address sender, uint256 amount) private {
        if (amount == 0) return;
        _balances[address(0)] = _balances[address(0)].add(amount);
        emit Transfer(sender, address(0), amount);

        if (bigDaoArr.length == 0) {
            return;
        }
        //平均没人分红
        uint256 div = amount.div(wlbUsdt).div(bigDaoArr.length);
        for (uint i = 0; i < bigDaoArr.length; i++) {
            address addr = bigDaoArr[i];
            //给大Dao主 分U
            IERC20(usdtAddress).transfer(addr, div);
        }
    }

    //小dao分 wlb
    function _dividendSmallDao(address sender, uint256 amount) private {
        if (amount == 0) return;
        if (smallDaoArr.length == 0) {
            _balances[address(0)] = _balances[address(0)].add(amount);
            emit Transfer(sender, address(0), amount);
            return;
        }
        //平均没人分红
        uint256 div = amount.div(smallDaoArr.length);
        for (uint i = 0; i < smallDaoArr.length; i++) {
            address addr = smallDaoArr[i];
            _balances[addr] = _balances[addr].add(div);
            emit Transfer(sender, addr, div);
            emit BalanceEvent(addr, _balances[addr]);
        }
    }

    //万分之一  分 usdt
    function _dividendTenThousand(address sender, uint256 amount) private {
        if (amount == 0) return;
        _balances[address(0)] = _balances[address(0)].add(amount);
        emit Transfer(sender, address(0), amount);

        if (tenThousandArr.length == 0) {
            return;
        }
        //平均没人分红
        uint256 div = amount.div(wlbUsdt).div(tenThousandArr.length);
        for (uint i = 0; i < tenThousandArr.length; i++) {
            address addr = tenThousandArr[i];
            //给大Dao主 分U
            IERC20(usdtAddress).transfer(addr, div);
        }
    }

    //万分之一 动态分润
    function _dividendTenThousandDynamic(address sender, uint256 amount) private {
        if (amount == 0) return;

        _balances[tenThousandDynamicAddr] = _balances[tenThousandDynamicAddr].add(amount);
        emit Transfer(sender, tenThousandDynamicAddr, amount);
        emit BalanceEvent(tenThousandDynamicAddr, _balances[tenThousandDynamicAddr]);

    }
    //流动池
    function _dividendLp(address sender, uint256 amount) private {
        if (amount == 0) return;
        _balances[lpFeeAddr] = _balances[lpFeeAddr].add(amount);
        emit Transfer(sender, lpFeeAddr, amount);
        emit BalanceEvent(lpFeeAddr, _balances[lpFeeAddr]);
    }

    //平台分红
    function _dividendPlatform(address sender, uint256 amount) private {
        if (amount == 0) return;
        _balances[platformFeeAddr] = _balances[platformFeeAddr].add(amount);
        emit Transfer(sender, platformFeeAddr, amount);
        emit BalanceEvent(platformFeeAddr, _balances[platformFeeAddr]);
    }


}