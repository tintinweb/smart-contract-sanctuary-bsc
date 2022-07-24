/**
 *Submitted for verification at BscScan.com on 2022-07-24
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-21
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


contract CAGL is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isSwapLakeAddress;
    mapping(address => address) public inviter;

    address private BurnAddress = 0x0000000000000000000000000000000000000001;

    address private OwnerAddress = 0xB52cc871c8f15579d9C10fEF36fF95E9dA3fDe69;
    address private CardHolderAwardAddress = 0xB52cc871c8f15579d9C10fEF36fF95E9dA3fDe69;
    address private LPAddress = 0xB52cc871c8f15579d9C10fEF36fF95E9dA3fDe69;
    address private BackAddress = 0xDB5Cc349F11F852BCA169A10D97Bc89d5B489067;
    address private FoundationAddress = 0xB52cc871c8f15579d9C10fEF36fF95E9dA3fDe69;

    address private USDTAddress = 0x55d398326f99059fF775485246999027B3197955;

    uint256 private _tFeeTotal;

    string private _name = "Cosmic Angel";
    string private _symbol = "CAGL";
    uint8 private _decimals = 18;

    uint256 public _burnFee = 100;
    uint256 public _previousBurnFee;

    uint256 public _cardFee = 300;
    uint256 public _previousCardFee;

    uint256 public _inviteFee = 500;
    uint256 public _previousInviteFee;

    uint256 public _inBackFee = 8000;
    uint256 public _previousInBackFee;

    uint256 public _outBackFee = 8000;
    uint256 public _previousOutBackFee;


    uint256 private _tTotal = 27 * 10 ** 7 * 10 ** _decimals;

    uint256 public numTokensSellToAddToLiquidity = 10 ** 4 * 10 ** _decimals;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    bool public swapAndLiquifyEnabled = true;

    bool inSwapAndLiquify;
    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {
        _tOwned[address(this)] = 189 * 10 ** 6 * 10 ** _decimals;
        _tOwned[FoundationAddress] = 81 * 10 ** 6 * 10 ** _decimals;
        _owner = OwnerAddress;

        _isExcludedFromFee[FoundationAddress] = true;
        _isExcludedFromFee[OwnerAddress] = true;
        _isExcludedFromFee[BurnAddress] = true;
        _isExcludedFromFee[BackAddress] = true;
        _isExcludedFromFee[CardHolderAwardAddress] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[address(0)] = true;


        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );

        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), address(USDTAddress));

        uniswapV2Router = _uniswapV2Router;

        uint256 amount = ~uint256(0);

        _allowances[OwnerAddress][OwnerAddress] = amount;
        _allowances[FoundationAddress][OwnerAddress] = amount;
        _allowances[BurnAddress][OwnerAddress] = amount;
        _allowances[CardHolderAwardAddress][OwnerAddress] = amount;
        _allowances[address(this)][OwnerAddress] = amount;
        _allowances[BackAddress][OwnerAddress] = amount;
        _allowances[BackAddress][address(this)] = amount;
        emit Approval(OwnerAddress, OwnerAddress, amount);
        emit Approval(BurnAddress, OwnerAddress, amount);
        emit Approval(FoundationAddress, OwnerAddress, amount);
        emit Approval(CardHolderAwardAddress, OwnerAddress, amount);
        emit Approval(address(this), OwnerAddress, amount);
        emit Approval(BackAddress, OwnerAddress, amount);
        emit Approval(BackAddress, address(this), amount);

        emit OwnershipTransferred(address(0), _owner);
        emit Transfer(address(0), address(this), 189 * 10 ** 6 * 10 ** _decimals);
        emit Transfer(address(0), FoundationAddress, 81 * 10 ** 6 * 10 ** _decimals);
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

    function burnFrom(address sender, uint256 amount) public returns (bool)
    {
        _takeBurnFee(sender, amount);
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

    function burn(uint256 amount) public returns (bool)
    {
        _takeBurnFee(msg.sender, amount);
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

    function isSwapLakeAddress(address account) public view returns (bool) {
        return _isSwapLakeAddress[account];
    }

    function excludeFromSwapLakeAddress(address account) public onlyOwner {
        _isSwapLakeAddress[account] = false;
    }

    function includeInSwapLakeAddress(address account) public onlyOwner {
        _isSwapLakeAddress[account] = true;
    }

    function setRate(uint256 burnFee, uint256 cardFee, uint256 inFee, uint256 outFee, uint256 inviteFee) public onlyOwner {
        _burnFee = burnFee;
        _cardFee = cardFee;
        _inBackFee = inFee;
        _outBackFee = outFee;
        _inviteFee = inviteFee;
    }

    function setLiquidityLimit(uint256 amountToAddLiquidity) public onlyOwner {
        numTokensSellToAddToLiquidity = amountToAddLiquidity;
    }

    receive() external payable {}

    function removeAllFee() private {
        _previousBurnFee = _burnFee;
        _previousCardFee = _cardFee;
        _previousInBackFee = _inBackFee;
        _previousOutBackFee = _outBackFee;
        _previousInviteFee = _inviteFee;
        _burnFee = 0;
        _cardFee = 0;
        _inBackFee = 0;
        _outBackFee = 0;
        _inviteFee = 0;
    }

    function restoreAllFee() private {
        _burnFee = _previousBurnFee;
        _cardFee = _previousCardFee;
        _inBackFee = _previousInBackFee;
        _outBackFee = _previousOutBackFee;
        _inviteFee = _previousInviteFee;
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
        require(amount > 0, "Transfer amount must be greater than one");

        uint256 contractTokenBalance = balanceOf(BackAddress);

        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            !_isSwapLakeAddress[from] &&
            !(from == address(this)) &&
            !(from == BackAddress) &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            //add liquidity
            swapAndLiquify(contractTokenBalance);
        }

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        bool shouldSetInviter = balanceOf(to) == 0 && inviter[to] == address(0) && !_isSwapLakeAddress[from] && !_isSwapLakeAddress[to];

        _tokenTransfer(from, to, amount, takeFee);

        if (shouldSetInviter) {
            inviter[to] = from;
        }
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if (!takeFee) removeAllFee();

        _transferStandard(sender, recipient, amount);

        if (!takeFee) restoreAllFee();
    }

    function _takeBurnFee(address sender, uint256 tAmount) private {
        if (_burnFee == 0) return;
        _tOwned[BurnAddress] = _tOwned[BurnAddress].add(tAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
        emit Transfer(sender, BurnAddress, tAmount);
    }

    function _takeCardFee(address sender, uint256 tAmount) private {
        if (_cardFee == 0) return;
        _tOwned[CardHolderAwardAddress] = _tOwned[CardHolderAwardAddress].add(tAmount);
        emit Transfer(sender, CardHolderAwardAddress, tAmount);
    }

    function _takeInFee(address sender, uint256 tAmount) private {
        if (_inBackFee == 0) return;
        _tOwned[BackAddress] = _tOwned[BackAddress].add(tAmount);
        emit Transfer(sender, BackAddress, tAmount);
    }

    function _takeOutFee(address sender, uint256 tAmount) private {
        if (_outBackFee == 0) return;
        _tOwned[BackAddress] = _tOwned[BackAddress].add(tAmount);
        emit Transfer(sender, BackAddress, tAmount);
    }

    function _takeInviteFee(address sender, address to, uint256 tAmount) private {
        if (_inviteFee == 0) return;
        if (inviter[to] == address(0)) {
            _tOwned[address(this)] = _tOwned[address(this)].add(tAmount);
            emit Transfer(sender, address(this), tAmount);
        } else {
            _tOwned[inviter[to]] = _tOwned[inviter[to]].add(tAmount);
            emit Transfer(sender, inviter[to], tAmount);
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {

        _tOwned[sender] = _tOwned[sender].sub(tAmount);


        uint256 fee = 0;
        if (_isSwapLakeAddress[sender]) {
            _takeInviteFee(sender, recipient, tAmount.div(10000).mul(_inviteFee));
            _takeInFee(sender, tAmount.div(10000).mul(_inBackFee));
            fee = _inviteFee.add(_inBackFee);
        } else if (_isSwapLakeAddress[recipient]) {
            _takeBurnFee(sender, tAmount.div(10000).mul(_burnFee));
            _takeCardFee(sender, tAmount.div(10000).mul(_cardFee));
            _takeOutFee(sender, tAmount.div(10000).mul(_outBackFee));
            fee = fee.add(_burnFee).add(_cardFee).add(_outBackFee);
        } else {
            fee = 0;
        }

        uint256 recipientRate = 10000 - fee;
        _tOwned[recipient] = _tOwned[recipient].add(
            tAmount.div(10000).mul(recipientRate)
        );
        emit Transfer(sender, recipient, tAmount.div(10000).mul(recipientRate));
    }


    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {

        _tOwned[BackAddress] = _tOwned[BackAddress].sub(contractTokenBalance);
        _tOwned[address(this)] = _tOwned[address(this)].add(contractTokenBalance);
        emit Transfer(BackAddress, address(this), contractTokenBalance);

        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);


        swapTokensForTokens(address(this), USDTAddress, half, 0, address(this));

        IERC20 USDT = IERC20(USDTAddress);

        uint256 USDTAmount = USDT.balanceOf(address(this));

        addLiquidity(address(this), USDTAddress, otherHalf, USDTAmount, OwnerAddress);
    }

    function swapTokensForTokens(address tokenA, address tokenB, uint256 tokenAmount, uint256 getMin, address to) private {

        address[] memory path = new address[](2);
        path[0] = tokenA;
        path[1] = tokenB;

        IERC20 USDT = IERC20(tokenA);
        USDT.approve(address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            getMin,
            path,
            to,
            block.timestamp
        );
    }

    function addLiquidity(address tokenA, address tokenB, uint256 tokenAAmount, uint256 tokenBAmount, address to) private returns (uint256, uint256, uint256) {

        IERC20 TokenA = IERC20(tokenA);
        IERC20 TokenB = IERC20(tokenB);
        TokenA.approve(address(uniswapV2Router), tokenAAmount);
        TokenB.approve(address(uniswapV2Router), tokenBAmount);

        return uniswapV2Router.addLiquidity(
            tokenA,
            tokenB,
            tokenAAmount,
            tokenBAmount,
            0,
            0,
            to,
            block.timestamp
        );
    }
}