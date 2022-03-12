/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-24
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-17
*/

pragma solidity ^0.8.6;

// SPDX-License-Identifier: Unlicensed
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

abstract contract Ownable {
    address public _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    //    constructor ()  {
    //        address msgSender = msg.sender;
    //        _owner = msgSender;
    //        emit OwnershipTransferred(address(0), msgSender);
    //    }

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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

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

interface  InterfaceTokenMintERC20Token{
  function GetRcomde(address account) external view returns(address);
}

contract DLDL is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) isDividendExempt;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcludedFromAward;
    mapping(address => bool) private _updated;

    address private BurnAddress = 0x0000000000000000000000000000000000000001;
    address private OwnerAddress = 0xa844A79EF46962b5b1f10318895B8632B52c5930;
    address private MainAddress = 0xAE3d400B5D33030426C582A038DFe9914A4d2F0C;
    address private FoundationAddress = 0x8A14ec4238B612CA91fB9f841DdD256254897839;
    address private LPLakeAddress = 0x318ab437aA6d97Dea7ea9acE121e7cA3d23f0415;
    address private USDTAddress = 0x55d398326f99059fF775485246999027B3197955;

    uint256 private _tFeeTotal;

    string private _name = "DLDL";
    string private _symbol = "DLDL";
    uint8 private _decimals = 16;

    bool private _LPSwitch = true;
    bool private _AwardSwitch = true;
    bool private _FeeSwitch = true;

    uint256 public _burnFee = 200;
    uint256 private _previousBurnFee;

    uint256 public _LPFee = 400;
    uint256 private _previousLPFee;

    uint256 private _invitePay = 1;

    uint256 public _foundationFee = 200;
    uint256 private _previousFoundationFee;

    uint256 public _RealTradeFee = 9980;


    uint256 [6] _inviterFee = [100, 100, 50, 50, 50, 50];
    uint256 [6] _previousInviterFee;

    uint256 _allInviterFee = _inviterFee[0] + _inviterFee[1] + _inviterFee[2] + _inviterFee[3] + _inviterFee[4] + _inviterFee[5];

    uint256 currentIndex;
    uint256 private _tTotal = 100 * 10 ** 4 * 10 ** 16;

    uint256 distributorGas = 500000;

    uint256 public LPFeefenhong;
    uint256 public addTime = 0;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    address private fromAddress;
    address private toAddress;

    mapping(address => address) public inviter;

    address[] shareholders;
    mapping(address => uint256) shareholderIndexes;

    bool inSwapAndLiquify;
    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {
        _tOwned[MainAddress] = _tTotal;
        _owner = OwnerAddress;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );

        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(USDTAddress, address(this));

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

        //exclude owner and this contract from fee
        _isExcludedFromFee[OwnerAddress] = true;
        _isExcludedFromFee[LPLakeAddress] = true;
        _isExcludedFromFee[BurnAddress] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[address(0)] = true;

        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0)] = true;
        isDividendExempt[BurnAddress] = true;

        emit OwnershipTransferred(address(0), _owner);
        emit Transfer(address(0), MainAddress, _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function isExcludedFromAward(address account) public view returns (bool) {
        return _isExcludedFromAward[account];
    }

    function excludeFromAward(address account) public onlyOwner {
        _isExcludedFromAward[account] = true;
    }

    function includeInAward(address account) public onlyOwner {
        _isExcludedFromAward[account] = false;
    }

    function LPSwitch() public onlyOwner {
        if (_LPSwitch) _LPSwitch = false;
        else _LPSwitch = true;
    }

    function AwardSwitch() public onlyOwner {
        if (_AwardSwitch) _AwardSwitch = false;
        else _AwardSwitch = true;
    }

    function FeeSwitch() public onlyOwner {
        if (_FeeSwitch) _FeeSwitch = false;
        else _FeeSwitch = true;
    }

    function setAwardRate(uint256 burnFee, uint256 lpFee, uint256 foundationFee) public onlyOwner {
        _burnFee = burnFee;

        _LPFee = lpFee;

        _foundationFee = foundationFee;
    }

    function setRealTradeRate(uint256 RealTradeFee) public onlyOwner {
        _RealTradeFee = RealTradeFee;
    }

    function setInvitePay(uint256 invitePay) public onlyOwner {
        _invitePay = invitePay;
    }

    function setInviterAwardRate(uint256 _inviterFee1, uint256 _inviterFee2, uint256 _inviterFee3, uint256 _inviterFee4, uint256 _inviterFee5, uint256 _inviterFee6) public onlyOwner {
        _inviterFee = [_inviterFee1, _inviterFee2, _inviterFee3, _inviterFee4, _inviterFee5, _inviterFee6];

        _allInviterFee = _inviterFee1 + _inviterFee2 + _inviterFee3 + _inviterFee4 + _inviterFee5 + _inviterFee6;
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function removeAllFee() private {
        _previousBurnFee = _burnFee;
        _previousLPFee = _LPFee;
        _previousFoundationFee = _foundationFee;
        _previousInviterFee = _inviterFee;

        _burnFee = 0;
        _LPFee = 0;
        _inviterFee = [0, 0, 0, 0, 0, 0];
        _allInviterFee = 0;
        _foundationFee = 0;
    }

    function restoreAllFee() private {
        _burnFee = _previousBurnFee;
        _LPFee = _previousLPFee;
        _inviterFee = _previousInviterFee;
        _foundationFee = _previousFoundationFee;
        _allInviterFee = _inviterFee[0] + _inviterFee[1] + _inviterFee[2] + _inviterFee[3] + _inviterFee[4] + _inviterFee[5];
    }

    function removeAward() private {
        _previousInviterFee = _inviterFee;
        _inviterFee = [0, 0, 0, 0, 0, 0];
        _allInviterFee = 0;
    }

    function restoreAward() private {
        _inviterFee = _previousInviterFee;
        _allInviterFee = _inviterFee[0] + _inviterFee[1] + _inviterFee[2] + _inviterFee[3] + _inviterFee[4] + _inviterFee[5];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");


        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to] || _tFeeTotal >= 19 * 10 ** 3 * 10 ** 16 || !_FeeSwitch) {
            takeFee = false;
        }

        if (!_isExcludedFromFee[to]) {
            if (block.timestamp < addTime.add(1 days)) {
                require(_tOwned[to].add(amount) > 1000 * 10 ** 16, "You cannot hold more than 1000 tokens today.");
            }
            if (block.timestamp < addTime.add(2 days)) {
                require(_tOwned[to].add(amount) > 2000 * 10 ** 16, "You cannot hold more than 2000 tokens today.");
            }
            if (block.timestamp < addTime.add(3 days)) {
                require(_tOwned[to].add(amount) > 3000 * 10 ** 16, "You cannot hold more than 3000 tokens today.");
            }
        }

        bool shouldSetInviter = (balanceOf(to) == 0 &&
        inviter[to] == address(0) &&
        from != uniswapV2Pair && _invitePay * 10 ** 16 == amount);

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);

        if (shouldSetInviter) {
            inviter[to] = from;
        }

        if ((from == uniswapV2Pair || to == uniswapV2Pair) && addTime == 0) addTime = block.timestamp;

        if (fromAddress == address(0)) fromAddress = from;
        if (toAddress == address(0)) toAddress = to;
        if (!isDividendExempt[fromAddress] && fromAddress != uniswapV2Pair) setShare(fromAddress);
        if (!isDividendExempt[toAddress] && toAddress != uniswapV2Pair) setShare(toAddress);

        fromAddress = from;
        toAddress = to;
        LPFeefenhong.add(1);
        if (_LPSwitch && _tOwned[LPLakeAddress] >= 20 && from != LPLakeAddress && LPFeefenhong == 20) {
            process(distributorGas);
            LPFeefenhong = 0;
        }
    }

    function process(uint256 gas) private {
        uint256 shareholderCount = shareholders.length;

        if (shareholderCount == 0) return;
        uint256 nowbanance = _tOwned[LPLakeAddress];
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }

            uint256 amount = nowbanance.mul(IERC20(uniswapV2Pair).balanceOf(shareholders[currentIndex])).div(IERC20(uniswapV2Pair).totalSupply());
            if (amount < 2) {
                currentIndex++;
                iterations++;
                continue;
            }
            if (_tOwned[LPLakeAddress] < amount) continue;
            distributeDividend(shareholders[currentIndex], amount);

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }


    function distributeDividend(address shareholder, uint256 amount) internal {
        if (_isExcludedFromAward[shareholder])
        {
            return;
        }
        _tOwned[LPLakeAddress] = _tOwned[LPLakeAddress].sub(amount);
        _tOwned[shareholder] = _tOwned[shareholder].add(amount);
        emit Transfer(LPLakeAddress, shareholder, amount);
    }

    function setShare(address shareholder) private {
        if (_updated[shareholder]) {
            if (IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);
            return;
        }
        if (IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) return;
        addShareholder(shareholder);
        _updated[shareholder] = true;

    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function quitShare(address shareholder) private {
        removeShareholder(shareholder);
        _updated[shareholder] = false;
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length - 1];
        shareholderIndexes[shareholders[shareholders.length - 1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if (!takeFee) removeAllFee();

        _transferStandard(sender, recipient, amount);

        if (!takeFee) restoreAllFee();
    }

    function _takeburnFee(address sender, uint256 tAmount) private {
        if (_burnFee == 0) return;
        _tOwned[BurnAddress] = _tOwned[BurnAddress].add(tAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
        emit Transfer(sender, BurnAddress, tAmount);
    }

    function _takeLPFee(address sender, uint256 tAmount) private {
        if (_LPFee == 0) return;
        _tOwned[LPLakeAddress] = _tOwned[LPLakeAddress].add(tAmount);
        emit Transfer(sender, LPLakeAddress, tAmount);
    }

    function GetTJCall(address account) public view returns(address)
    {
        address caddtokencontarc = 0x70be490fDFdAD92f2A59F5B8e380CCfB7fB1e27E;//rcomde
        InterfaceTokenMintERC20Token _tm = InterfaceTokenMintERC20Token(caddtokencontarc);
        address ntj = _tm.GetRcomde(account);
        return ntj;
    }

    function _takeInviterFee(address sender, address recipient, uint256 tAmount) private {
        if (_allInviterFee == 0) return;
        if (!_AwardSwitch) {
            _tOwned[FoundationAddress] = _tOwned[FoundationAddress].add(tAmount.div(10000).mul(_allInviterFee));
            emit Transfer(sender, FoundationAddress, tAmount.div(10000).mul(_allInviterFee));
            return;
        }
        address cur;
        if (recipient == uniswapV2Pair) {
            cur = sender;
        } else {
            cur = recipient;
        }
        uint256 accurRate = 0;
        for (uint256 i = 0; i < 6; i++) {
            uint256 rate = _inviterFee[i];
            cur = GetTJCall(cur);
            if (cur == address(0)) {
                continue;
            }
            if (_isExcludedFromAward[cur] || rate <= 0)
            {
                continue;
            }
            accurRate = accurRate.add(rate);

            uint256 curTAmount = tAmount.div(10000).mul(rate);
            _tOwned[cur] = _tOwned[cur].add(curTAmount);
            emit Transfer(sender, cur, curTAmount);
        }
        _tOwned[FoundationAddress] = _tOwned[FoundationAddress].add(tAmount.div(10000).mul(_allInviterFee.sub(accurRate)));
        emit Transfer(sender, FoundationAddress, tAmount.div(10000).mul(_allInviterFee.sub(accurRate)));
        return;
    }


    function _takeFoundationFee(address sender, uint256 tAmount) private {
        if (_foundationFee == 0) return;
        _tOwned[FoundationAddress] = _tOwned[FoundationAddress].add(tAmount);
        emit Transfer(sender, FoundationAddress, tAmount);
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        tAmount = tAmount.div(10000).mul(_RealTradeFee);
        _tOwned[sender] = _tOwned[sender].add(10000-_RealTradeFee);

        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        uint256 max = _tTotal.sub(_tFeeTotal).div(10);
        require(tAmount < max, "Trade amount is to big.");

        uint256 _burn = tAmount.div(10000).mul(_burnFee);
        uint256 max_burn = 90 * 10 ** 4 * 10 ** 16;
        if (_burn + _tFeeTotal > max_burn) _burn = max_burn.sub(_tFeeTotal);
        _takeburnFee(sender, _burn);

        _takeLPFee(sender, tAmount.div(10000).mul(_LPFee));

        _takeInviterFee(sender, recipient, tAmount);

        _takeFoundationFee(sender, tAmount.div(10000).mul(_foundationFee));

        uint256 recipientRate = 10000 - _LPFee - _foundationFee - _allInviterFee;
        _tOwned[recipient] = _tOwned[recipient].add(
            tAmount.div(10000).mul(recipientRate).sub(_burn)
        );
        emit Transfer(sender, recipient, tAmount.div(10000).mul(recipientRate).sub(_burn));
    }
}