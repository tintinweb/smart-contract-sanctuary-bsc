/**
 *Submitted for verification at BscScan.com on 2022-05-19
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;


interface IBEP20 {
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
    function balanceOf(address account) external view returns(uint256);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
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
        require(c >= a, 'SafeMath: addition overflow');

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
        return sub(a, b, 'SafeMath: subtraction overflow');
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
        require(c / a == b, 'SafeMath: multiplication overflow');

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
        return div(a, b, 'SafeMath: division by zero');
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
        return mod(a, b, 'SafeMath: modulo by zero');
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))
library FixedPoint {
    // range: [0, 2**112 - 1]
    // resolution: 1 / 2**112
    struct uq112x112 {
        uint224 _x;
    }

    // range: [0, 2**144 - 1]
    // resolution: 1 / 2**112
    struct uq144x112 {
        uint256 _x;
    }

    uint8 private constant RESOLUTION = 112;
    uint256 private constant Q112 = uint256(1) << RESOLUTION;
    uint256 private constant Q224 = Q112 << RESOLUTION;

    // encode a uint112 as a UQ112x112
    function encode(uint112 x) internal pure returns (uq112x112 memory) {
        return uq112x112(uint224(x) << RESOLUTION);
    }

    // encodes a uint144 as a UQ144x112
    function encode144(uint144 x) internal pure returns (uq144x112 memory) {
        return uq144x112(uint256(x) << RESOLUTION);
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function div(uq112x112 memory self, uint112 x) internal pure returns (uq112x112 memory) {
        require(x != 0, 'FixedPoint: DIV_BY_ZERO');
        return uq112x112(self._x / uint224(x));
    }

    // multiply a UQ112x112 by a uint, returning a UQ144x112
    // reverts on overflow
    function mul(uq112x112 memory self, uint256 y) internal pure returns (uq144x112 memory) {
        uint256 z;
        require(y == 0 || (z = uint256(self._x) * y) / y == uint256(self._x), 'FixedPoint: MULTIPLICATION_OVERFLOW');
        return uq144x112(z);
    }

    // returns a UQ112x112 which represents the ratio of the numerator to the denominator
    // equivalent to encode(numerator).div(denominator)
    function fraction(uint112 numerator, uint112 denominator) internal pure returns (uq112x112 memory) {
        require(denominator > 0, 'FixedPoint: DIV_BY_ZERO');
        return uq112x112((uint224(numerator) << RESOLUTION) / denominator);
    }

    // decode a UQ112x112 into a uint112 by truncating after the radix point
    function decode(uq112x112 memory self) internal pure returns (uint112) {
        return uint112(self._x >> RESOLUTION);
    }

    // decode a UQ144x112 into a uint144 by truncating after the radix point
    function decode144(uq144x112 memory self) internal pure returns (uint144) {
        return uint144(self._x >> RESOLUTION);
    }

    // take the reciprocal of a UQ112x112
    function reciprocal(uq112x112 memory self) internal pure returns (uq112x112 memory) {
        require(self._x != 0, 'FixedPoint: ZERO_RECIPROCAL');
        return uq112x112(uint224(Q224 / self._x));
    }

    // square root of a UQ112x112
    function sqrt(uq112x112 memory self) internal pure returns (uq112x112 memory) {
        return uq112x112(uint224(SafeMath.sqrt(uint256(self._x)) << 56));
    }
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


contract Vemate is  IBEP20, Ownable{
    using FixedPoint for *;

    struct FeeWallet {
        address  payable dev;
        address  payable marketing;
        address  payable charity;
    }

    struct FeePercent {
        uint8  lp;
        uint8  dev;
        uint8  marketing;
        uint8  charity;
        bool enabledOnBuy;
        bool enabledOnSell;
    }

    FeeWallet public feeWallets;
    FeePercent public fee  = FeePercent(2, 1, 1, 1, false, true);

    IUniswapV2Router02 public uniswapV2Router;

    string private  _name = "Vemate";
    string private _symbol = "V";

    // Pack variables together for gas optimization
    uint8   private _decimals = 18;
    uint8   public constant maxFeePercent = 5;
    uint8   public swapSlippageTolerancePercent = 10;
    bool    private antiBot = true;
    bool    private inSwapAndLiquify;
    bool    public swapAndLiquifyEnabled = true;
    uint32  private blockTimestampLast;

    address public uniswapV2Pair;

    uint256 private _totalSupply = 150000000 * 10**_decimals; // 150 million;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isPrivileged;
    mapping (address => uint) private _addressToLastSwapTime;

    uint256 public lockedBetweenSells = 60;
    uint256 public lockedBetweenBuys = 60;
    uint256 public maxTxAmount = _totalSupply;
    uint256 public numTokensSellToAddToLiquidity = 10000 * 10**_decimals; // 10 Token

    // We will depend on external price for the token to protect the sandwich attack.
    uint256 public tokenPerBNB = 23810;


    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor(
        address router,
        address payable devAddress,
        address payable marketingAddress,
        address payable charityAddress
    ){
        require(owner() != address(0), "Owner must be set");
        require(router != address(0), "Router must be set");
        require(devAddress != address(0), "Dev wallet must be set");
        require(marketingAddress != address(0), "Marketing wallet must be set");
        require(charityAddress != address(0), "Charity wallet must be set");

        _isPrivileged[owner()] = true;
        _isPrivileged[devAddress] = true;
        _isPrivileged[marketingAddress] = true;
        _isPrivileged[charityAddress] = true;
        _isPrivileged[address(this)] = true;

        // set wallets for collecting fees
        feeWallets = FeeWallet(devAddress, marketingAddress, charityAddress);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        _balances[_msgSender()] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function setRouterAddress(address newRouter) external onlyOwner {
        IUniswapV2Router02 _newPancakeRouter = IUniswapV2Router02(newRouter);
        IUniswapV2Factory factory = IUniswapV2Factory(_newPancakeRouter.factory()
        );
        address pair = factory.getPair(address(this), _newPancakeRouter.WETH());
        if (pair == address(0)) {
            uniswapV2Pair = factory.createPair(address(this), _newPancakeRouter.WETH());
        } else {
            uniswapV2Pair = pair;
        }

        uniswapV2Router = _newPancakeRouter;

        emit UpdatePancakeRouter(uniswapV2Router, uniswapV2Pair);
    }

    function setDevWallet(address payable devWallet) external onlyOwner{
        require(devWallet != address(0),  "Dev wallet must be set");
        address devWalletPrev = feeWallets.dev;
        feeWallets.dev = devWallet;

        _isPrivileged[devWallet] = true;
        delete _isPrivileged[devWalletPrev];

        emit UpdateDevWallet(devWallet, devWalletPrev);
    }

    function setMarketingWallet(address payable marketingWallet) external onlyOwner{
        require(marketingWallet != address(0),  "Marketing wallet must be set");
        address marketingWalletPrev = feeWallets.marketing;
        feeWallets.marketing = marketingWallet;

        _isPrivileged[marketingWallet] = true;
        delete _isPrivileged[marketingWalletPrev];

        emit UpdateMarketingWallet(marketingWallet, marketingWalletPrev);
    }

    function setCharityWallet(address payable charityWallet) external onlyOwner{
        require(charityWallet != address(0),  "Charity wallet must be set");
        address charityWalletPrev = feeWallets.charity;
        feeWallets.charity = charityWallet;

        _isPrivileged[charityWallet] = true;
        delete _isPrivileged[charityWalletPrev];

        emit UpdateCharityWallet(charityWallet, charityWalletPrev);
    }

    function addPrivilegedWallet(address newPrivilegedAddress) external onlyOwner {
        require(newPrivilegedAddress != address(0), "privileged address can not be set zero address");
        require(_isPrivileged[newPrivilegedAddress] != true, "already privileged");
        _isPrivileged[newPrivilegedAddress] = true;

        emit PrivilegedWallet(newPrivilegedAddress, true);
    }

    function removePrivilegedWallet(address prevPrivilegedAddress) external onlyOwner {
        require(_isPrivileged[prevPrivilegedAddress] != false, "not privileged address");    
        delete _isPrivileged[prevPrivilegedAddress];

        emit PrivilegedWallet(prevPrivilegedAddress, false);
    }

    function privilegedAddress(address existingPrivilegedAddress) public view returns(bool){
        return _isPrivileged[existingPrivilegedAddress];
    }

    function setLpFeePercent(uint8 lpFeePercent) external onlyOwner {
        FeePercent memory currentFee = fee;
        uint8 totalFeePercent = currentFee.marketing + currentFee.dev + currentFee.charity + lpFeePercent;
        require(totalFeePercent <= maxFeePercent, "Total fee percent cannot be greater than maxFeePercent");
        uint8 previousFee = currentFee.lp;
        currentFee.lp = lpFeePercent;
        fee = currentFee;

        emit UpdateLpFeePercent(lpFeePercent, previousFee);
    }

    function setDevFeePercent(uint8 devFeePercent) external onlyOwner {
        FeePercent memory currentFee = fee;
        uint8 totalFeePercent = currentFee.marketing + currentFee.lp + currentFee.charity + devFeePercent;
        require(totalFeePercent <= maxFeePercent, "Total fee percent cannot be greater than maxFeePercent");
        uint8 previousFee = currentFee.dev;
        currentFee.dev = devFeePercent;
        fee = currentFee;

        emit UpdateDevFeePercent(devFeePercent, previousFee);
    }

    function setMarketingFeePercent(uint8 marketingFeePercent) external onlyOwner {
        FeePercent memory currentFee = fee;
        uint8 totalFeePercent = currentFee.lp + currentFee.dev + currentFee.charity + marketingFeePercent;
        require(totalFeePercent <= maxFeePercent, "Total fee percent cannot be greater than maxFeePercent");
        uint8 previousFee = currentFee.marketing;
        currentFee.marketing = marketingFeePercent;
        fee = currentFee;

        emit UpdateMarketingFeePercent(marketingFeePercent, previousFee);
    }

    function setCharityFeePercent(uint8 charityFeePercent) external onlyOwner {
        FeePercent memory currentFee = fee;
        uint8 totalFeePercent = currentFee.marketing + currentFee.dev + currentFee.lp + charityFeePercent;
        require(totalFeePercent <= maxFeePercent, "Total fee percent cannot be greater than maxFeePercent");
        uint8 previousFee = currentFee.charity;
        currentFee.charity = charityFeePercent;
        fee = currentFee;

        emit UpdateCharityFeePercent(charityFeePercent, previousFee);
    }

    function togglePauseBuyingFee() external onlyOwner{
        fee.enabledOnBuy = !fee.enabledOnBuy;
        emit UpdateBuyingFee(fee.enabledOnBuy);
    }

    function togglePauseSellingFee() external onlyOwner{
        fee.enabledOnSell = !fee.enabledOnSell;
        emit UpdateSellingFee(fee.enabledOnSell);
    }

    function setLockTimeBetweenSells(uint256 newLockSeconds) external onlyOwner {
        require(newLockSeconds <= 30, "Time between sells must be less than 30 seconds");
        uint256 _previous = lockedBetweenSells;
        lockedBetweenSells = newLockSeconds;
        emit UpdateLockedBetweenSells(lockedBetweenSells, _previous);
    }

    function setLockTimeBetweenBuys(uint256 newLockSeconds) external onlyOwner {
        require(newLockSeconds <= 30, "Time between buys be less than 30 seconds");
        uint256 _previous = lockedBetweenBuys;
        lockedBetweenBuys = newLockSeconds;
        emit UpdateLockedBetweenBuys(lockedBetweenBuys, _previous);
    }

    function toggleAntiBot() external onlyOwner {
        antiBot = !antiBot;
        emit UpdateAntibot(antiBot);
    }

    function setMaxTxAmount(uint256 amount) external onlyOwner{
        uint256 prevTxAmount = maxTxAmount;
        maxTxAmount = amount;
        emit UpdateMaxTxAmount(maxTxAmount, prevTxAmount);
    }

    function updateTokenPrice(uint256 _tokenPerBNB) external onlyOwner {
        tokenPerBNB = _tokenPerBNB;
        emit UpdateTokenPerBNB(tokenPerBNB);
    }

    function toggleSwapAndLiquify() external onlyOwner{
        swapAndLiquifyEnabled = !swapAndLiquifyEnabled;
        emit UpdateSwapAndLiquify(swapAndLiquifyEnabled);
    }

    function setSwapTolerancePercent(uint8 newTolerancePercent) external onlyOwner{
        require(newTolerancePercent <= 100, "Swap tolerance percent cannot be more than 100");
        uint8 swapTolerancePercentPrev = swapSlippageTolerancePercent;
        swapSlippageTolerancePercent = newTolerancePercent;
        emit UpdateSwapTolerancePercent(swapSlippageTolerancePercent, swapTolerancePercentPrev);
    }

    function setMinTokenToSwapAndLiquify(uint256 amount) external onlyOwner{
        uint256 numTokensSellToAddToLiquidityPrev = numTokensSellToAddToLiquidity;
        numTokensSellToAddToLiquidity = amount;
        emit UpdateMinTokenToSwapAndLiquify(numTokensSellToAddToLiquidity, numTokensSellToAddToLiquidityPrev);
    }

    function withdrawResidualBNB(address newAddress) external onlyOwner() {
        payable(newAddress).transfer(address(this).balance);
    }

    function withdrawResidualToken(address newAddress) external onlyOwner() {
        _transfer(address(this), newAddress, _balances[address(this)]);
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
    function balanceOf(address account) external override view returns(uint256){
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
        uint256 _currentAllowance = _allowances[sender][_msgSender()];
        // this check is not mandatory. but to return exact overflow reason we can use it.
        require(_currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), _currentAllowance - amount);
        return true;
    }

    /**
    * @dev Atomically increases the allowance granted to `spender` by the caller.
    *
    * This is an alternative to {approve} that can be used as a mitigation for
    * problems described in {BEP20-approve}.
    *
    * Emits an {Approval} event indicating the updated allowance.
    *
    * Requirements:
    *
    * - `spender` cannot be the zero address.
    */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
    * @dev Atomically decreases the allowance granted to `spender` by the caller.
    *
    * This is an alternative to {approve} that can be used as a mitigation for
    * problems described in {BEP20-approve}.
    *
    * Emits an {Approval} event indicating the updated allowance.
    *
    * Requirements:
    *
    * - `spender` cannot be the zero address.
    * - `spender` must have allowance for the caller of at least
    * `subtractedValue`.
    */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 _currentAllowance = _allowances[_msgSender()][spender];
        // this check is not mandatory. but to return exact overflow reason we can use it.
        require(_currentAllowance >= subtractedValue, "BEP20: decreased allowance below zero");
        _approve(_msgSender(), spender, _currentAllowance - subtractedValue);
        return true;
    }

    /**
    * @dev Moves tokens `amount` from `sender` to `recipient`.
    *
    * This is internal function is equivalent to {transfer}, and can be used to
    * e.g. implement automatic token fees, slashing mechanisms, etc.
    *
    * Emits a {Transfer} event.
    *
    * Requirements:
    *
    * - `sender` cannot be the zero address.
    * - `recipient` cannot be the zero address.
    * - `sender` must have a balance of at least `amount`.
    */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_balances[sender] >= amount, "BEP20: transfer amount exceeds balance");

        bool takeFee = false;

        if (_isPrivileged[sender] || _isPrivileged[recipient]){
            // takeFee already false. Do nothing and reduce gas fee.
        } else if (recipient == uniswapV2Pair) { // sell : fee and restrictions for non-privileged wallet
            require(amount <= maxTxAmount, "Amount larger than max tx amount!");
            checkSwapFrequency(sender);
            if (fee.enabledOnSell){
                takeFee = true;
                if (shouldSwap()){
                    swapAndLiquify(numTokensSellToAddToLiquidity);
                }
            }
        } else if (sender == uniswapV2Pair){  // buy : fee and restrictions for non-privileged wallet
            require(amount <= maxTxAmount, "Amount larger than max tx amount!");
            checkSwapFrequency(recipient);
            if (fee.enabledOnBuy){
                takeFee = true;
                if (shouldSwap()){
                    swapAndLiquify(numTokensSellToAddToLiquidity);
                }
            }
        }
        _tokenTransfer(sender, recipient, amount, takeFee);
    }

    function shouldSwap() private view returns(bool)  {
        uint256 contractTokenBalance = _balances[(address(this))];
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;

        if (overMinTokenBalance && !inSwapAndLiquify && swapAndLiquifyEnabled) {
            return true;
        }
        return false;
    }

    // to recieve ETH from uniswapV2Router when swapping
    receive() external payable {}

    function swapAndLiquify(uint256 amount) private lockTheSwap {
        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // We need to collect Bnb from the token amount
        // dev + marketing + charity will be send to the wallet
        // the rest(for liquid pool) will be divided into two and be used to addLiquidity
        uint8 totalFee = fee.dev + fee.lp + fee.charity + fee.marketing;
        uint256 lpHalf =  (amount*fee.lp)/(totalFee*2);

        // swap dev + marketing + charity + lpHalf
        swapTokensForEth(amount - lpHalf);

        // how much ETH did we just swap into?
        uint256 receivedBnb = address(this).balance - initialBalance;

        // get the Bnb amount for lpHalf
        uint256 lpHalfBnbShare = (receivedBnb*fee.lp)/(totalFee*2 - fee.lp); // to avoid possible floating point error
        uint256 devBnbShare = (receivedBnb*2*fee.dev)/(totalFee*2 - fee.lp);
        uint256 marketingBnbShare = (receivedBnb*2*fee.marketing)/(totalFee*2 - fee.lp);
        uint256 charityBnbShare = (receivedBnb*2*fee.charity)/(totalFee*2 - fee.lp);


        // feeWallets.lp.transfer(lpHalfBnbShare);
        feeWallets.dev.transfer(devBnbShare);
        feeWallets.marketing.transfer(marketingBnbShare);
        feeWallets.charity.transfer(charityBnbShare);

        addLiquidity(lpHalf, lpHalfBnbShare);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uint ethAmount = tokenAmount/tokenPerBNB;

        uint minETHAmount = ethAmount - (ethAmount* swapSlippageTolerancePercent)/100;

        // make the swap
        try uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            minETHAmount, // this will protect sandwich attack
            path,
            address(this),
            getCurrentTime()
        ){
            emit SwapAndLiquifyStatus("Success");
        }catch {
            emit SwapAndLiquifyStatus("Failed");
        }
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // require(msg.value>0, "No eth found in this account");
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uint minETHAmount = ethAmount - (ethAmount* swapSlippageTolerancePercent)/100;
        uint minTokenAmount = tokenAmount - (tokenAmount* swapSlippageTolerancePercent)/100;

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            minTokenAmount,
            minETHAmount,
            address(this),
            getCurrentTime()
        );
        emit LiquidityAdded(tokenAmount, ethAmount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) internal {
        uint256 transferAmount = amount;
        if (takeFee) {
            uint8 totalFeePercent = fee.lp + fee.marketing + fee.charity + fee.dev;
            uint256 totalFee = (amount*totalFeePercent)/100;

            // send the fee token to the contract address.
            _balances[address(this)] = _balances[address(this)] + totalFee;
            transferAmount = transferAmount - totalFee;
            emit Transfer(sender, address(this), totalFee);
        }
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + transferAmount;
        emit Transfer(sender, recipient, transferAmount);
    }

    /**
    * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
    *
    * This is internal function is equivalent to `approve`, and can be used to
    * e.g. set automatic allowances for certain subsystems, etc.
    *
    * Emits an {Approval} event.
    *
    * Requirements:
    *
    * - `owner` cannot be the zero address.
    * - `spender` cannot be the zero address.
    */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function checkSwapFrequency(address whom) internal{
        uint currentTime = getCurrentTime();
        if (antiBot) {
            uint lastSwapTime = _addressToLastSwapTime[whom];
            require(currentTime - lastSwapTime >= lockedBetweenSells, "Lock time has not been released from last swap"
            );
        }
        _addressToLastSwapTime[whom] = currentTime;
    }

    function getCurrentTime() internal virtual view returns(uint){
        return block.timestamp;
    }

    event UpdatePancakeRouter(IUniswapV2Router02 router, address pair);
    event UpdateDevWallet(address current, address previous);
    event UpdateMarketingWallet(address current, address previous);
    event UpdateCharityWallet(address current, address previous);

    event PrivilegedWallet(address _privilegedAddress, bool isPrivileged);

    event UpdateLpFeePercent(uint8 current, uint8 previous);
    event UpdateDevFeePercent(uint8 current, uint8 previous);
    event UpdateMarketingFeePercent(uint8 current, uint8 previous);
    event UpdateCharityFeePercent(uint8 current, uint8 previous);

    event UpdateSellingFee(bool isEnabled);
    event UpdateBuyingFee(bool isEnabled);

    event UpdateLockedBetweenBuys(uint256 cooldown, uint256 previous);
    event UpdateLockedBetweenSells(uint256 cooldown, uint256 previous);

    event UpdateAntibot(bool isEnabled);

    event UpdateMaxTxAmount(uint256 maxTxAmount, uint256 prevTxAmount);

    event UpdateTokenPerBNB(uint256 tokenPerBNB);
    event UpdateSwapAndLiquify(bool swapAndLiquifyEnabled);
    event UpdateSwapTolerancePercent(uint8 swapTolerancePercent, uint8 swapTolerancePercentPrev);
    event UpdateMinTokenToSwapAndLiquify(uint256 numTokensSellToAddToLiquidity, uint256 numTokensSellToAddToLiquidityPrev);
    event LiquidityAdded(uint256 tokenAmount, uint256 bnbAmount);
    event SwapAndLiquifyStatus(string status);
}