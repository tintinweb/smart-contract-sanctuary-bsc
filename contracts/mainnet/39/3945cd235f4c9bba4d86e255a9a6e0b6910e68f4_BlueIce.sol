/**
 *Submitted for verification at BscScan.com on 2022-08-24
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

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
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

contract TokenDistributor {
    constructor (address token) {
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}

contract BlueIceToken is IERC20, Ownable {
    using SafeMath for uint256;
    uint256 private constant MAX = ~uint256(0);
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    //#######################BASE INFO#################################
    //market address.
    address public marketAddress;
    IERC20 public usdt;
    bool public swapAndLiquifyEnabled = true; // should be true
    string private _name = "Blue Ice";
    string private _symbol = "BLC";
    uint8 private _decimals = 9;
    uint256 private _tTotal = 2100 * 10 ** _decimals;
    TokenDistributor _tokenDistributor;
    //#######################FEE CONFIG#################################
    //tax fee.
    uint256 public buyFee = 150;
    uint256 public fundFee = 150;
    uint256 public sellFee = 150;
    uint256 public lpFee = 150;
    uint256 public dividendFee = 150;
    uint256 public feeDenominator = 10000;
    IUniswapV2Router02 public immutable uniswapV2Router;
    address private usdtAddress;
    address public immutable uniswapV2Pair;
    bool inSwapAndLiquify;
    uint256 private startTradeBlock;
    IERC20 private _usdtPair;
    uint256 public numTokensSellToFund;

    address[] private lpProviders;
    mapping(address => uint256) lpProviderIndex;

    mapping(address => bool) excludeLpProvider;

    bool private inSwap;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(IERC20 _usdt, address _marketAddress) {
        usdt = _usdt;
        usdtAddress = address(_usdt);
        marketAddress = _marketAddress;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(address(0x10ED43C718714eb63d5aA57B78B54704E256024E));
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), address(_usdt));
        uniswapV2Router = _uniswapV2Router;
        _approve(address(this), address(_uniswapV2Router), MAX);
        usdt.approve(address(_uniswapV2Router), MAX);
        //excludeLpProvider---
        excludeLpProvider[address(0)] = true;
        excludeLpProvider[address(0x000000000000000000000000000000000000dEaD)] = true;
        excludeLpProvider[address(0x7ee058420e5937496F5a2096f04caA7721cF70cc)] = true;
        //excludeFromFee------
        numTokensSellToFund = _tTotal / 10000;
        //===================================
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[_marketAddress] = true;
        _isExcludedFromFee[address(this)] = true;
        _tOwned[_marketAddress] = _tTotal;
        _tokenDistributor = new TokenDistributor(address(_usdt));
        emit Transfer(address(0), msg.sender, _tTotal);
    }

    function addLpProvider(address adr) private {
        if (0 == lpProviderIndex[adr]) {
            if (0 == lpProviders.length || lpProviders[0] != adr) {
                lpProviderIndex[adr] = lpProviders.length;
                lpProviders.push(adr);
            }
        }
    }

    uint256 private currentIndex;
    uint256 private lpRewardCondition = 50*1e18;
    uint256 private progressLPBlock;

    function processLP(uint256 gas) private {

        if (progressLPBlock + 200 > block.number) {
            return;
        }

        uint totalPair = _usdtPair.totalSupply();
        if (0 == totalPair) {
            return;
        }

        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(address(this));

        if (usdtBalance < lpRewardCondition) {
            return;
        }

        address shareHolder;
        uint256 pairBalance;
        uint256 amount;

        uint256 shareholderCount = lpProviders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;


        uint256 gasLeft = gasleft();


        while (gasUsed < gas && iterations < shareholderCount) {

            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = lpProviders[currentIndex];

            pairBalance = _usdtPair.balanceOf(shareHolder);

            if (pairBalance > 0 && !excludeLpProvider[shareHolder]) {
                amount = usdtBalance * pairBalance / totalPair;

                if (amount > 0) {
                    USDT.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
        progressLPBlock = block.number;
    }

    // view function
    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function setFeeDenominator(uint256 _feeDenominator) public onlyOwner {
        require(_feeDenominator >= 0, "feeDenominator not allowed");
        feeDenominator = _feeDenominator;
    }

    function setLpRewardCondition(uint256 _lpRewardCondition) public onlyOwner{
        lpRewardCondition = _lpRewardCondition;
    }

    function contractConfig(uint256 _buyFee,uint256 _sellFee, uint256 _fundFee, uint256 _lpFee, uint256 _dividendFee) public onlyOwner {
        require(_buyFee >= 0, "fee not allowed");
        require(_sellFee >= 0, "fee not allowed");
        require(_fundFee >= 0, "fee not allowed");
        require(_lpFee >= 0, "fee not allowed");
        require(_dividendFee >= 0, "fee not allowed");
        buyFee = _buyFee;
        sellFee = _sellFee;
        fundFee = _fundFee;
        lpFee = _lpFee;
        dividendFee = _dividendFee;
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setAddress(address addr2) public onlyOwner {
        marketAddress = addr2;
        _isExcludedFromFee[marketAddress] = true;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
    }

    function rescueToken(
        address token,
        address recipient,
        uint256 amount
    ) public onlyOwner {
        IERC20(token).transfer(recipient, amount);
    }

    function setNumTokensSellToFund(uint256 _numTokensSellToFund) public onlyOwner{
        numTokensSellToFund = _numTokensSellToFund;
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

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

        if (inSwapAndLiquify || _isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            _tOwned[from] = _tOwned[from].sub(amount);
            _tOwned[to] = _tOwned[to].add(amount);
            if (0 == startTradeBlock) {
                startTradeBlock = block.number;
            }
            emit Transfer(from, to, amount);
            return;
        }

        if (
            swapAndLiquifyEnabled &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair
        ) {
            inSwapAndLiquify = false;
        }

        if (from == uniswapV2Pair) {
            if (0 == startTradeBlock) {
                startTradeBlock = block.number;
            }
            addLpProvider(to);
        } else {
            if (0 == startTradeBlock) {
                startTradeBlock = block.number;
            }
            addLpProvider(from);
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToFund;
        if (
            overMinTokenBalance &&
            !inSwap &&
            from != uniswapV2Pair
        ) {
            swapTokenForFund(numTokensSellToFund);
        }

        _tokenTransfer(from, to, amount);

        if (from != address(this) && startTradeBlock > 0) {
            processLP(500000);
        }
    }

    //tax
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        _tOwned[sender] = _tOwned[sender].sub(amount);
        uint256 taxFee = 0;
        uint256 taxFeeAmount = 0;
        if (sender == uniswapV2Pair) {
            // buy order.
            taxFee = dividendFee + lpFee;
            uint256 lpRewardFee = amount.mul(taxFee).div(feeDenominator);
            _tOwned[address(this)] = _tOwned[address(this)].add(lpRewardFee);
            emit Transfer(sender, address(this), lpRewardFee);
            taxFeeAmount = lpFee.add(lpRewardFee);
        } else if (recipient == uniswapV2Pair) {
            // sell order.
            taxFee = sellFee;
            //send to marketAddress.
            uint256 marketFee = amount.mul(sellFee).div(feeDenominator);
            _tOwned[marketAddress] = _tOwned[marketAddress].add(marketFee);
            emit Transfer(sender, marketAddress, marketFee);
            //lp rewards.
            uint256 lpRewardFee = amount.mul(taxFee).div(feeDenominator);
            _tOwned[address(this)] = _tOwned[address(this)].add(lpRewardFee);
            emit Transfer(sender,address(this), lpRewardFee);
            taxFeeAmount = marketFee.add(lpRewardFee);
        }
        uint256 recipientAmount = amount.sub(taxFeeAmount);
        _tOwned[recipient] = _tOwned[recipient].add(recipientAmount);
        emit Transfer(sender, recipient, recipientAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        //预留加LP池子部分的代币
        uint256 lpAmount = tokenAmount * lpFee / (lpFee + dividendFee + fundFee) / 2;
        IERC20 USDT = IERC20(usdt);
        uint256 initialBalance = USDT.balanceOf(address(_tokenDistributor));
        //将代币兑换为USDT
        swapTokensForUsdt(tokenAmount - lpAmount);
        uint256 newBalance = USDT.balanceOf(address(_tokenDistributor)) - initialBalance;
        uint256 totalUsdtFee = lpFee / 2 + dividendFee + fundFee;
        uint256 lpUsdt = newBalance * lpFee / 2 / totalUsdtFee;
        USDT.transferFrom(address(_tokenDistributor), address(this), lpUsdt);
        //添加流动性
        addLiquidityUsdt(lpAmount, lpUsdt);
    }

    //添加USDT交易对
    function addLiquidityUsdt(uint256 tokenAmount, uint256 usdtAmount) private {
        uniswapV2Router.addLiquidity(
            address(this),
            usdtAddress,
            tokenAmount,
            usdtAmount,
            0,
            0,
            marketAddress,
            block.timestamp
        );
    }

    //将代币兑换为USDT
    function swapTokensForUsdt(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdtAddress;
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(_tokenDistributor),
            block.timestamp
        );
    }

    //#################COMMON FUNCTIONS###########################
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


    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

}

contract BlueIce is BlueIceToken {
    constructor() BlueIceToken(
    IERC20(0x55d398326f99059fF775485246999027B3197955),
    address(0x320Ea38D54f60Cf3a8c0C214dcEDDd98dB148057)
    ){

    }
}