/**
 *Submitted for verification at BscScan.com on 2022-09-04
*/

// SPDX-License-Identifier: MIT



pragma solidity ^0.8.6;


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
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
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

interface Ido {
    function getInvitor(address owner) view external returns (address);
}

contract DuckToken is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public isDividendExempt;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _updated;

    address public  marketAddr;

    string public _name;
    string public _symbol;
    uint8 public _decimals;


    uint256 public _burnFee;
    uint256 private _previousBurnFee;

    uint256 public _nftFee;
    uint256 private _previousNftFee;

    uint256 public _liquidityFee;
    uint256 private _previousLiquidityFee;

    uint256 public _marketingFee;
    uint256 private _previousMarketingFee;

    uint256 public _inviterFee;
    uint256 private _previousInviterFee;


    uint256 currentIndex;
    uint256 private _tTotal;
    uint256 distributorGas = 500000;
    uint256 public minPeriod = 1 hours;
    uint256 public LPFeefenhong;
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    address private fromAddress;
    address private toAddress;

    uint256 public burnEndNumber;
    uint256 public swapTokensAtAmount;

    //mapping(address => address) public inviter;

    address[] shareholders;
    mapping(address => uint256) shareholderIndexes;

    uint256 public minLPDividendToken = 1 ether;

    address public _token = 0x55d398326f99059fF775485246999027B3197955;
    address public _router;
    uint256[] public _inviters;
    uint256 _nftMarketBalance;
    address _nft;
    address _sonAddress;
    address _ido;

    constructor(
    )  {
        _inviters = [120, 80];
        address adminAddress = msg.sender;
        _name = "life";
        _symbol = "life";
        _decimals = 18;
        _tTotal = 55000 * (10 ** uint256(_decimals));
        _burnFee = 200;
        _marketingFee = 300;
        _nftFee = 300;
        _liquidityFee = 500;
        _inviterFee = 200;

        marketAddr = 0x5fcB1aBBc5A49FFC5c0dd0Fd0474B2B828280012;
        _ido = 0x4D251048A62B00534c37e7d41693E86c89c86796;
        _nft = 0xA9CACADEb80162496838435c0Db0E45B3A4cc4C0;
        _sonAddress = 0x1C947E9E01eee9E7071eF088891dA5229A2E55c2;
        _tOwned[adminAddress] = _tTotal;

        burnEndNumber = 100 * (10 ** uint256(_decimals));
        address router;
        if (block.chainid == 56) {
            router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
            _token = 0x55d398326f99059fF775485246999027B3197955;
        } else {
            router = 0xB6BA90af76D139AB3170c7df0139636dB6120F7e;
            _token = 0x89614e3d77C00710C8D87aD5cdace32fEd6177Bd;
        }

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            router
        );

        URoter rou = new URoter(_token, address(this));
        _router = address(rou);

        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _token);

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

        //exclude owner and this contract from fee
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[adminAddress] = true;
        _isExcludedFromFee[address(this)] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0)] = true;
        isDividendExempt[address(0xdead)] = true;

        swapTokensAtAmount = _tTotal.mul(1).div(10 ** 6);

        _token.call(abi.encodeWithSelector(0x095ea7b3, uniswapV2Router, ~uint256(0)));

        address(this).call(abi.encodeWithSelector(0x095ea7b3, uniswapV2Router, ~uint256(0)));

        emit Transfer(address(0), adminAddress, _tTotal);

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

    function transfer(address recipient, uint256 amount)
    public
    override
    returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
    public
    view
    override
    returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
    public
    override
    returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
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

    function increaseAllowance(address spender, uint256 addedValue)
    public
    virtual
    returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    virtual
    returns (bool)
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


    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function setNft(address nft_) public onlyOwner {
        _nft = nft_;
    }

    function setIdo(address ido_) public onlyOwner {
        _ido = ido_;
    }

    function setSon(address son_) public onlyOwner {
        _sonAddress = son_;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function removeAllFee() private {
        _previousBurnFee = _burnFee;
        _previousNftFee = _nftFee;
        _previousMarketingFee = _marketingFee;
        _previousInviterFee = _inviterFee;
        _previousLiquidityFee = _liquidityFee;

        _burnFee = 0;
        _nftFee = 0;
        _inviterFee = 0;
        _marketingFee = 0;
        _liquidityFee = 0;
    }

    function restoreAllFee() private {
        _burnFee = _previousBurnFee;
        _nftFee = _previousNftFee;
        _inviterFee = _previousInviterFee;
        _marketingFee = _previousMarketingFee;
        _liquidityFee = _previousLiquidityFee;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {

            if (from != uniswapV2Pair) {
                if (balanceOf(from).sub(amount) == 0) {
                    amount = amount.sub(1);
                }
            }
        }
        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        // if (from == uniswapV2Pair||to==uniswapV2Pair){
        //     takeFee = true;
        // }

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to] || from == address(uniswapV2Router)) {
            takeFee = false;
        }


        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (canSwap && from != address(this) && from != address(this) && to != uniswapV2Pair && from != uniswapV2Pair && from != owner() && to != owner()) {
            swapTokensForTokens(contractTokenBalance);
            uint tokenBal = IERC20(_token).balanceOf(address(this));
            _nftMarketBalance += tokenBal * _nftFee / (_nftFee + _marketingFee + _liquidityFee);
            //nft
            distributeDividend(_nft, tokenBal * _nftFee / (_nftFee + _marketingFee + _liquidityFee));
            //market
            distributeDividend(marketAddr, tokenBal * _marketingFee / (_nftFee + _marketingFee + _liquidityFee));
            //wcc
            swapTokensForTokenSon(IERC20(_token).balanceOf(address(this)));
            //dividendMarketAddr(tokenBal.mul(_marketingFee).div(_LPFee.add(_marketingFee)));
        }
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (!takeFee) removeAllFee();

        _transferStandard(sender, recipient, amount);

        if (!takeFee) restoreAllFee();
    }

    function distributeDividend(address shareholder, uint256 amount) internal {
        (bool b1,) = _token.call(abi.encodeWithSignature("transfer(address,uint256)", shareholder, amount));
        require(b1, "call error");
    }

    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        if (_inviterFee == 0) return;
        address cur;
        if (sender == uniswapV2Pair) {
            cur = recipient;
        } else if (recipient == uniswapV2Pair) {
            cur = sender;
        } else {
            _tOwned[marketAddr] = _tOwned[marketAddr].add(tAmount.div(10000).mul(_inviterFee));
            emit Transfer(sender, marketAddr, tAmount.div(10000).mul(_inviterFee));
            return;
        }
        uint256 accurRate;
        for (uint256 i = 0; i < _inviters.length; i++) {
            cur = Ido(_ido).getInvitor(cur);
            if (cur == address(0)) {
                break;
            }
            accurRate = accurRate.add(_inviters[i]);
            uint256 curTAmount = tAmount.div(10000).mul(_inviters[i]);
            _tOwned[cur] = _tOwned[cur].add(curTAmount);
            emit Transfer(sender, cur, curTAmount);
        }
        _tOwned[marketAddr] = _tOwned[marketAddr].add(tAmount.div(10000).mul(_inviterFee.sub(accurRate)));
        emit Transfer(sender, marketAddr, tAmount.div(10000).mul(_inviterFee.sub(accurRate)));
    }

    function _takeburnFee(
        address sender,
        uint256 tAmount
    ) private {
        if (_burnFee == 0) return;
        if ((_tTotal.sub(_tOwned[address(0)].add(_tOwned[address(0xdead)]))) >= burnEndNumber) {
            _tOwned[address(0)] = _tOwned[address(0)].add(tAmount);
            emit Transfer(sender, address(0), tAmount);
        } else {
            _burnFee = 0;
        }
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        if (currentRate == 0) return;
        uint256 rAmount = tAmount.div(10000).mul(currentRate);
        _tOwned[to] = _tOwned[to].add(rAmount);
        emit Transfer(sender, to, rAmount);
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _takeburnFee(sender, tAmount.div(10000).mul(_burnFee));
        _takeTransfer(sender, address(this), tAmount, _marketingFee + _nftFee + _liquidityFee);
        _takeInviterFee(sender, recipient, tAmount);
        uint256 recipientRate = 10000 -
        _burnFee -
        _marketingFee -
        _nftFee -
        _liquidityFee -
        _inviterFee;
        _tOwned[recipient] = _tOwned[recipient].add(
            tAmount.div(10000).mul(recipientRate)
        );
        emit Transfer(sender, recipient, tAmount.div(10000).mul(recipientRate));
    }

    function setRouter(address router_) public onlyOwner {
        _router = router_;
    }

    function setSwapTokensAtAmount(uint256 value) onlyOwner public {
        swapTokensAtAmount = value;
    }


    function setAddr(address value) external onlyOwner {
        marketAddr = value;
    }

    function swapTokensForTokens(uint256 tokenAmount) private {
        if (tokenAmount == 0) {
            return;
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _token;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            _router,
            block.timestamp
        );
        IERC20(_token).transferFrom(_router, address(this), IERC20(_token).balanceOf(address(_router)));
    }

    function swapTokensForTokenSon(uint256 tokenAmount) private {
        if (tokenAmount == 0) {
            return;
        }
        address[] memory path = new address[](2);
        path[0] = _token;
        path[1] = _sonAddress;

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            marketAddr,
            block.timestamp
        );
    }

    function transferTokensAvg(address[] memory _tos, uint256 amount) onlyOwner public returns (bool){
        require(_tos.length > 0);
        require(_tos.length * amount < _tOwned[owner()]);
        for (uint i = 0; i < _tos.length; i++) {
            _tOwned[owner()] -= amount;
            _tOwned[_tos[i]] += amount;
            emit Transfer(owner(), _tos[i], amount);
        }
        return true;
    }

    function getMarketBalance() public view returns (uint256){
        return _nftMarketBalance;
    }

    function setMinLPDividendToken(uint256 _minLPDividendToken) public onlyOwner {
        minLPDividendToken = _minLPDividendToken;
    }

    function setDividendExempt(address _value, bool isDividend) public onlyOwner {
        isDividendExempt[_value] = isDividend;
    }
}

contract URoter {
    constructor(address token, address to){
        token.call(abi.encodeWithSelector(0x095ea7b3, to, ~uint256(0)));
    }
}