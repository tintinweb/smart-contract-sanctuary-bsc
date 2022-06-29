/**
 *Submitted for verification at BscScan.com on 2022-06-29
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-29
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


contract Vemate is IBEP20, Ownable{

    struct FeeWallet {
        address payable treasury;
        address payable charity;
    }

    struct FeePercent {
        uint8 treasury;
        uint8 charity;
        uint8 total;
        bool enabledOnBuy;
        bool enabledOnSell;
    }

    FeeWallet public feeWallets;
    FeePercent public fee = FeePercent(4, 1, 5, false, true);

    IUniswapV2Router02 public uniswapV2Router;

    string private constant _NAME = "Vemate";
    string private constant _SYMBOL = "VMT";

    uint8 private constant _DECIMALS = 18;
    uint8 public constant MAX_FEE_PERCENT = 5;
    bool private inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    address public uniswapV2Pair;

    uint256 private constant TOTAL_SUPPLY = 15 * 10**7 * 10**_DECIMALS; // 150 million; 

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public automatedMarketMakerPairs;
    mapping(address => bool) private _isPrivileged;

    uint256 public minTokensToSwapAndLiquify;

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor(
        address router,
        address payable treasuryAddress,
        address payable charityAddress
    ){
        require(router != address(0), "Router must be set");
        require(treasuryAddress != address(0), "Treasury wallet must be set");
        require(charityAddress != address(0), "Charity wallet must be set");

        _isPrivileged[owner()] = true;
        _isPrivileged[address(this)] = true;

        feeWallets = FeeWallet(treasuryAddress, charityAddress);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        _setAutomatedMarketMakerPair(uniswapV2Pair, true);

        minTokensToSwapAndLiquify = 10000 * 10**_DECIMALS;

        _balances[_msgSender()] = TOTAL_SUPPLY;

        emit Transfer(address(0), _msgSender(), TOTAL_SUPPLY);
    }

    function setRouterAddress(address newRouter) external onlyOwner {
        IUniswapV2Router02 _newPancakeRouter = IUniswapV2Router02(newRouter);
        IUniswapV2Factory factory = IUniswapV2Factory(_newPancakeRouter.factory());
        address pair = factory.getPair(address(this), _newPancakeRouter.WETH());

        if (pair == address(0)) {
            uniswapV2Pair = factory.createPair(address(this), _newPancakeRouter.WETH());
        } else {
            uniswapV2Pair = pair;
        }

        uniswapV2Router = _newPancakeRouter;

        emit UpdatePancakeRouter(uniswapV2Router, uniswapV2Pair);
    }

    function setTreasuryWallet(address payable treasuryWallet) external onlyOwner{
        require(treasuryWallet != address(0),  "Error: zero address");
        address treasuryWalletPrev = feeWallets.treasury;
        feeWallets.treasury = treasuryWallet;

        emit UpdateTreasuryWallet(treasuryWallet, treasuryWalletPrev);
    }

    function setCharityWallet(address payable charityWallet) external onlyOwner{
        require(charityWallet != address(0),  "Error: zero address");
        address charityWalletPrev = feeWallets.charity;
        feeWallets.charity = charityWallet;

        emit UpdateCharityWallet(charityWallet, charityWalletPrev);
    }

    function addPrivilegedWallet(address newPrivilegedAddress) external onlyOwner {
        require(newPrivilegedAddress != address(0), "Error: zero address");
        require(!_isPrivileged[newPrivilegedAddress], "Already privileged");
        _isPrivileged[newPrivilegedAddress] = true;

        emit PrivilegedWallet(newPrivilegedAddress, true);
    }

    function removePrivilegedWallet(address prevPrivilegedAddress) external onlyOwner {
        require(_isPrivileged[prevPrivilegedAddress], "Not privileged address");
        delete _isPrivileged[prevPrivilegedAddress];

        emit PrivilegedWallet(prevPrivilegedAddress, false);
    }

    function setAutomatedMarketMakerPair(address pair, bool value) external onlyOwner {
        require(pair != uniswapV2Pair, "PancakeSwap pair cannot be removed");

        _setAutomatedMarketMakerPair(pair, value);
    }

    function privilegedAddress(address existingPrivilegedAddress) public view returns(bool){
        return _isPrivileged[existingPrivilegedAddress];
    }

    function setTreasuryFeePercent(uint8 treasuryFeePercent) external onlyOwner {
        FeePercent memory currentFee = fee;
        uint8 totalFeePercent = currentFee.charity + treasuryFeePercent;
        require(totalFeePercent <= MAX_FEE_PERCENT, "Total fee percent cannot be greater than maxFeePercent");
        uint8 previousFee = currentFee.treasury;

        fee.treasury = treasuryFeePercent;
        fee.total = totalFeePercent;

        emit UpdateTreasuryFeePercent(treasuryFeePercent, previousFee);
    }

    function setCharityFeePercent(uint8 charityFeePercent) external onlyOwner {
        FeePercent memory currentFee = fee;
        uint8 totalFeePercent = currentFee.treasury + charityFeePercent;
        require(totalFeePercent <= MAX_FEE_PERCENT, "Total fee percent cannot be greater than maxFeePercent");
        uint8 previousFee = currentFee.charity;

        fee.charity = charityFeePercent;
        fee.total = totalFeePercent;

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

    function toggleSwapAndLiquify() external onlyOwner{
        swapAndLiquifyEnabled = !swapAndLiquifyEnabled;
        emit UpdateSwapAndLiquify(swapAndLiquifyEnabled);
    }

    function setMinTokenToSwapAndLiquify(uint256 amount) external onlyOwner{
        require(amount > 0, "amount cannot be zero");
        uint256 minTokensToSwapAndLiquifyPrev = minTokensToSwapAndLiquify;
        minTokensToSwapAndLiquify = amount;
        emit UpdateMinTokenToSwapAndLiquify(minTokensToSwapAndLiquify, minTokensToSwapAndLiquifyPrev);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "AMM pair is already set");
        automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function withdrawResidualBNB(address newAddress) external onlyOwner() {
        require(newAddress != address(0),  "Error: zero address");
        uint amount = address(this).balance;
        payable(newAddress).transfer(amount);
        emit WithdrawBNB(amount);
    }

    function withdrawResidualToken(address newAddress) external onlyOwner() {
        require(newAddress != address(0),  "Error: zero address");
        uint amount = _balances[address(this)];
        _transfer(address(this), newAddress, amount);
        emit WithdrawToken(amount);
    }

    /**
    * @dev Returns the token decimals.
    */
    function decimals() external override view returns (uint8) {
        return _DECIMALS;
    }

    /**
    * @dev Returns the token symbol.
    */
    function symbol() external override view returns (string memory) {
        return _SYMBOL;
    }

    /**
    * @dev Returns the token name.
    */
    function name() external override view returns (string memory) {
        return _NAME;
    }

    /**
    * @dev See {BEP20-totalSupply}.
    */
    function totalSupply() external override view returns (uint256) {
        return TOTAL_SUPPLY;
    }

    /**
    * @dev See {BEP20-balanceOf}.
    */
    function balanceOf(address account) external override view returns(uint256){
        return _balances[account];
    }

    /**
    * @dev Returns the bep token owner.
    */
    function getOwner() external override view returns (address) {
        return owner();
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
    function allowance(address owner_, address spender) external override view returns (uint256) {
        return _allowances[owner_][spender];
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
        unchecked {
            _approve(sender, _msgSender(), _currentAllowance - amount);
        }
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
        unchecked {
            _approve(_msgSender(), spender, _currentAllowance - subtractedValue);
        }
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
        } else if (automatedMarketMakerPairs[recipient] && fee.enabledOnSell) { // sell
            takeFee = true;
            if (shouldSwap()){
                uint256 contractTokenBalance = _balances[(address(this))];
                swapAndLiquify(contractTokenBalance);
            }
        } else if (automatedMarketMakerPairs[sender] && fee.enabledOnBuy){ // buy
            takeFee = true;
        }

        _tokenTransfer(sender, recipient, amount, takeFee);
    }

    function shouldSwap() private view returns(bool) {
        uint256 contractTokenBalance = _balances[(address(this))];
        bool overMinTokenBalance = contractTokenBalance >= minTokensToSwapAndLiquify;

        if (overMinTokenBalance && !inSwapAndLiquify && swapAndLiquifyEnabled) {
            return true;
        }
        return false;
    }

    receive() external payable {}

    function swapAndLiquify(uint256 amount) private lockTheSwap {

        swapTokensForBnb(amount);

        uint256 contractBnbBalance = address(this).balance;

        uint256 treasuryBnbShare = contractBnbBalance * fee.treasury / fee.total;
        uint256 charityBnbShare = contractBnbBalance * fee.charity / fee.total;

        feeWallets.treasury.transfer(treasuryBnbShare);
        feeWallets.charity.transfer(charityBnbShare);

        emit FeesDistributed(treasuryBnbShare, charityBnbShare);
    }

    function swapTokensForBnb(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> wbnb
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        try uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp
        ){
            emit SwapAndLiquifyStatus("Success");
        } catch {
            emit SwapAndLiquifyStatus("Failed");
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) internal {
        uint256 transferAmount = amount;
        if (takeFee) {
            uint256 totalFee = amount * fee.total / 100;

            // send the fee token to the contract address.
            _balances[address(this)] = _balances[address(this)] + totalFee;
            transferAmount = transferAmount - totalFee;
            emit Transfer(sender, address(this), totalFee);
        }
        unchecked {
            _balances[sender] = _balances[sender] - amount;
        }
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
    function _approve(address owner_, address spender, uint256 amount) internal {
        require(owner_ != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }

    event UpdatePancakeRouter(IUniswapV2Router02 router, address pair);
    event UpdateTreasuryWallet(address current, address previous);
    event UpdateCharityWallet(address current, address previous);

    event PrivilegedWallet(address _privilegedAddress, bool isPrivileged);

    event UpdateTreasuryFeePercent(uint8 current, uint8 previous);
    event UpdateCharityFeePercent(uint8 current, uint8 previous);

    event UpdateSellingFee(bool isEnabled);
    event UpdateBuyingFee(bool isEnabled);

    event UpdateSwapAndLiquify(bool swapAndLiquifyEnabled);
    event UpdateSwapTolerancePercent(uint8 swapTolerancePercent, uint8 swapTolerancePercentPrev);
    event UpdateMinTokenToSwapAndLiquify(uint256 minTokensToSwapAndLiquify, uint256 minTokensToSwapAndLiquifyPrev);
    event FeesDistributed(uint256 treasuryBnbShare, uint256 charityBnbShare);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event SwapAndLiquifyStatus(string status);

    event WithdrawBNB(uint amount);
    event WithdrawToken(uint amount);
}