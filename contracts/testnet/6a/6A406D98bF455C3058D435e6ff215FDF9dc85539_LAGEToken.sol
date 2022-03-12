/**
 *Submitted for verification at BscScan.com on 2022-03-12
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

contract LAGEToken is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping (address => bool) isDividendExempt;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _updated;

    address private satbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;//BNB代币地址
  
   

    uint256 private _tFeeTotal;

    string private _name = "PPU";
    string private _symbol = "PPU";
    uint8 private _decimals = 8;

    uint256 public _burnFee = 0;//销毁比例
    uint256 private _previousburnFee;

    uint256 public _LPFee = 300;//LP分红
    uint256 private _previousLPFee;

    uint256 public _satFee = 0;
    uint256 private _previousatFee;

    uint256 public _inviterFee = 600;//邀请，推广分红
    uint256 private _previousInviterFee;
    uint256 currentIndex;  
    uint256 private _tTotal = 1000 * 10**8 * 10**_decimals;//1000亿
    uint256 distributorGas = 500000;
    uint256 public minPeriod = 1 hours;
    uint256 public LPFeefenhong;
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    address private fromAddress;
    address private toAddress;
    address _noInviterAddress;//没有上级的时候的接受币地址

    address _luckyAddress;//幸运池地址
    uint256 _luckyFee =400;//幸运池分红
    uint256 _previousluckyFee;//先前的数目

    uint256 public _lastDay;
    
    uint256 public _lastIndx ;

    uint256  randNonce = 0;

    uint256 luckyTime  = 600;

    struct luckyTransferItem
    {
        uint256 amount;//金钱
        address sender;//

    }
    luckyTransferItem[] _luckyTransferList;

    // mapping(address => luckyItem) public luckyMap;//记录幸运池发生的事情

    mapping(address => address) public inviter;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;

    bool inSwapAndLiquify;
    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    

    constructor(address lyaddr,address noInviter) {
        _tOwned[msg.sender] = _tTotal;
       
        // 0x10ED43C718714eb63d5aA57B78B54704E256024E PancakeSwap（薄饼）地址  测试地址 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        );

        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
        _luckyAddress =lyaddr;
        //exclude owner and this contract from fee
        _isExcludedFromFee[msg.sender] = true;
       
        _isExcludedFromFee[address(this)] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0)] = true;
        _lastDay = block.timestamp /luckyTime;
        _lastIndx = 0;
       _noInviterAddress = noInviter;//没有上级的时候的接受币地址
        transferFee();//设置分红点
        emit Transfer(address(0), msg.sender, _tTotal);
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

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    //买入/转账：13%
    function transferFee() private
    {
        _burnFee = 0;
        _LPFee = 300;
        _inviterFee = 600;
        _satFee = 0;
        _luckyFee = 400;
    }
    //卖出：4%
    function saleFee() private
    {
        _burnFee = 0;
        _LPFee = 0;
        _inviterFee = 0;
        _satFee = 0;
        _luckyFee = 400;
    }

    function removeAllFee() private {
        _previousburnFee = _burnFee;
        _previousLPFee = _LPFee;
        _previousatFee = _satFee;
        _previousInviterFee = _inviterFee;
        _previousluckyFee = _luckyFee;

        _burnFee = 0;
        _LPFee = 0;
        _inviterFee = 0;
        _satFee = 0;
        _luckyFee = 0;
    }

    function restoreAllFee() private {
        _burnFee = _previousburnFee;
        _LPFee = _previousLPFee;
        _inviterFee = _previousInviterFee;
        _satFee = _previousatFee;
        _luckyFee = _previousluckyFee;
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
    //买入/转账：13%   卖出：4%
//     买入：从薄饼交易所买入。
// 卖出：从薄饼交易所卖出。
// 转账：将代币转给其它地址。
// 注入lp池子：在薄饼交易所拿代币和bnb组成lp。
// 撤回lp池子：在薄饼交易所将lp撤掉拿回代币和bnb。
// 转账lp：将lp转给其它地址。

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        //indicates if fee should be deducted from transfer
        bool takeFee = true;
       
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to] || to == uniswapV2Pair || from == address(uniswapV2Router)  ) {
            takeFee = false;
        }

        bool shouldSetInviter = balanceOf(to) == 0 &&
            inviter[to] == address(0) &&
            from != uniswapV2Pair;

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);

        if (shouldSetInviter) {
            inviter[to] = from;
        }
        if(fromAddress == address(0) )fromAddress = from;
        if(toAddress == address(0) )toAddress = to;  
        if(!isDividendExempt[fromAddress] && fromAddress != uniswapV2Pair ) setShare(fromAddress);
        if(!isDividendExempt[toAddress] && toAddress != uniswapV2Pair ) setShare(toAddress);
        
        fromAddress = from;
        toAddress = to;  
         if(_tOwned[address(this)] >= 1 * 10**5 * 10**_decimals && from !=address(this) && LPFeefenhong.add(minPeriod) <= block.timestamp) {
             process(distributorGas) ;//处理LP分红的
             LPFeefenhong = block.timestamp;
        }
    }
    function process(uint256 gas) private {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0)return;
        uint256 nowbanance = _tOwned[address(this)];
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

          uint256 amount = nowbanance.mul(IERC20(uniswapV2Pair).balanceOf(shareholders[currentIndex])).div(IERC20(uniswapV2Pair).totalSupply());
         if( amount < 1 * 10**_decimals) {
             currentIndex++;
             iterations++;
             return;
         }
         if(_tOwned[address(this)]  < amount )return;
            distributeDividend(shareholders[currentIndex],amount);
            
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
   

    function distributeDividend(address shareholder ,uint256 amount) internal {
            
            _tOwned[address(this)] = _tOwned[address(this)].sub(amount);
            _tOwned[shareholder] = _tOwned[shareholder].add(amount);
             emit Transfer(address(this), shareholder, amount);
    }
    function setShare(address shareholder) private {
           if(_updated[shareholder] ){      
                if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);              
                return;  
           }
           if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) return;  
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
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
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

    function _takeburnFee(
        address sender,
        uint256 tAmount
    ) private {
        // if (_burnFee == 0) return;
        if(_tFeeTotal >= 999 * 10**8 * 10**_decimals)
        {
            return;
        }
        if(tAmount ==0)
        {
            return;
        }
      
        _tOwned[address(0)] = _tOwned[address(0)].add(tAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
        emit Transfer(sender, address(0), tAmount);
    }

    function _takeLPFee(address sender,uint256 tAmount) private {
        if (_LPFee == 0 && _satFee ==0) return;
        _tOwned[address(this)] = _tOwned[address(this)].add(tAmount);
        emit Transfer(sender, address(this), tAmount);
    }

     function _takeLuckyFee(address sender,uint256 tAmount) private {
        if (_luckyFee == 0) return;
        _tOwned[_luckyAddress] = _tOwned[_luckyAddress].add(tAmount);
        emit Transfer(sender, _luckyAddress, tAmount);
    }

    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        if (_inviterFee == 0) return;
         address cur;
        if (sender == uniswapV2Pair) {//从LP中撤销 或者 买入
            cur = recipient;
        } else if (recipient == uniswapV2Pair) {//从你质押代币到LP 或者卖出代币给LP
            cur = sender;
        } else {
            cur =sender;
            // _tOwned[address(this)] = _tOwned[address(this)].add(tAmount.div(10000).mul(_inviterFee));
            // emit Transfer(sender, address(this), tAmount.div(10000).mul(_inviterFee));
            // return;
        }
     
        uint256 accurRate;
        for (int256 i = 0; i < 7; i++) {
            uint256 rate;
            if (i == 0) {
                rate = 200;
            } else if(i == 1 || i == 2){
                rate = 100;
            } else {
                rate = 50;
            }
            cur = inviter[cur];
            if (cur == address(0)) {
                break;
            }
            accurRate = accurRate.add(rate);
            uint256 curTAmount = tAmount.div(10000).mul(rate);
            _tOwned[cur] = _tOwned[cur].add(curTAmount);
            emit Transfer(sender, cur, curTAmount);
        }
        //剩余的没有上级的都打到官方账号
         _tOwned[_noInviterAddress] = _tOwned[_noInviterAddress].add(tAmount.div(10000).mul(_inviterFee.sub(accurRate)));
         emit Transfer(sender,_noInviterAddress, tAmount.div(10000).mul(_inviterFee.sub(accurRate)));
    }

    
    function _takesatFee (
        address sender,
        address recipient,
        uint256 tAmount
    ) private lockTheSwap {
        if (_satFee == 0) return; 
        if(_tOwned[address(this)]  < tAmount)return; 
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = satbnb; 
        address getsat = recipient;
        if(sender != uniswapV2Pair)getsat = sender;
        _approve(address(this), address(uniswapV2Router), tAmount);

       
        swapThisTokenForToken(tAmount,getsat);
}   

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETH(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

    }

    function swapEthForToken(uint256 ethAmount,address receiver) private{
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        IERC20 BNB = IERC20(satbnb);//BNB地址
        path[1] = address(BNB);//代币地址
        path[0] = uniswapV2Router.WETH();//主币地址

        // make the swap
        uniswapV2Router.swapExactETHForTokens{value:ethAmount}(
            0, // accept any amount of token
            path,
            receiver,
            block.timestamp
        );

    }

    function swapThisTokenForToken(uint256 thisTokenAmount,address receiver) private{
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        IERC20 BNB = IERC20(satbnb);//BNB代币地址--
        path[0] = address(this);//本币地址
        path[1] = address(BNB);//代币地址
        
        _approve(address(this), address(uniswapV2Router), thisTokenAmount);
        
        // make the swap
        uniswapV2Router.swapExactTokensForTokens(
            thisTokenAmount,
            0, // accept any amount of token
            path,
            receiver,
            block.timestamp
        );

    }
    function getRand(uint num) internal returns(uint)//0-num-1
    {
        uint _modulus =  num;
        if( _modulus <=0)
        {
            return 0;
        }
        randNonce++;
        return uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,randNonce))) % _modulus;
    }
    
  
    function processLucky(address sender,address recipient,uint256 amount) private 
    {
        if(recipient != _luckyAddress)//如果不是转给幸运池地址，return
        {
            return;
        }
        _luckyTransferList.push(luckyTransferItem(amount,sender));//每次进来都记录
        uint256 failProbability = 52;

        uint256 mulNum =1;
        uint256  rand = getRand(100)+1;
        bool iswin = true;
        if(rand <= failProbability)//52%概率不中奖
        {
           iswin = false; 
        }
        if(iswin)//如果中
        {
            uint256 r = getRand(100)+1;
            if(r<=70){
                mulNum = 2;
            }else if(r>70 && r<=95)
            {
                mulNum = 3;
            }
            else if(r>95 && r<=99)
            {
                mulNum = 4;
            }else{
                mulNum = 10;
            }
            uint256 tAmount =  amount.mul(mulNum);
            if(_tOwned[_luckyAddress] < tAmount )//是否超出幸运池的数量
            {
                tAmount =  _tOwned[_luckyAddress];
            }
            _tOwned[_luckyAddress] = _tOwned[_luckyAddress].sub(tAmount);
            _tOwned[sender] = _tOwned[sender].add(tAmount);
            emit Transfer(_luckyAddress, sender, tAmount);
        }
        else{
            //20%的代币直接转入黑洞销毁，80%留在幸运池。
             _tOwned[_luckyAddress] = _tOwned[_luckyAddress].sub(amount.div(10000).mul(1000));//因为已经加过进去了，要减出来
            //  _takeburnFee(sender, amount.div(10000).mul(1000));//销毁
            _takeburnFee(_luckyAddress, amount.div(10000).mul(1000));//销毁
          
        }

    }

    //每天24时整，将从当天（00:00—24:00）参与活动的所有交易列中，随机选择10个交易发放所参与数量的200%奖励。
    function _transferLuckyEveryDay() private 
    {
        uint256 nowday =  block.timestamp/luckyTime;

        if(_lastDay == nowday)
        {
            return;
        }
        //隔天了
        _lastDay = nowday;
        uint256 len = _luckyTransferList.length;
        uint256 n = len - _lastIndx;
     
        if(n >= 10){//昨天交易的笔数要大10次
            for(uint i = 0;i<10;i++)//随机10次选择
            {
                uint256 num = _luckyTransferList.length - _lastIndx;
                uint256 randindx = getRand(num);
                uint256 indx = _lastIndx+randindx;
                uint256 tAmount = _luckyTransferList[indx].amount*2  ;
                address to = _luckyTransferList[indx].sender;
                if(_tOwned[_luckyAddress] < tAmount )//是否超出幸运池的数量
                {
                    tAmount =  _tOwned[_luckyAddress];
                }
                _tOwned[_luckyAddress] = _tOwned[_luckyAddress].sub(tAmount);
                _tOwned[to] = _tOwned[to].add(tAmount);
                emit Transfer(_luckyAddress, to, tAmount);
                removeAtIndex(indx);
            }
             
        }
       
        _lastIndx = _luckyTransferList.length;
      
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
       
        _takeburnFee(sender, tAmount.div(10000).mul(_burnFee));//销毁

        _takeLPFee(sender, tAmount.div(10000).mul(_LPFee.add(_satFee)));//lp分红

       _takeLuckyFee(sender, tAmount.div(10000).mul(_luckyFee));//转入幸运池的
        _takeInviterFee(sender, recipient, tAmount);//推广分红

      
       _takesatFee(sender, recipient,tAmount.div(10000).mul(_satFee));//sat的
       _transferLuckyEveryDay();//处理昨天幸运池的交易笔数触发的幸运儿
        uint256 recipientRate = 10000 -
            _burnFee -
            _LPFee -
            _satFee -
            _inviterFee-
            _luckyFee
            ;
        _tOwned[recipient] = _tOwned[recipient].add(
            tAmount.div(10000).mul(recipientRate)
        );

        emit Transfer(sender, recipient, tAmount.div(10000).mul(recipientRate));

        bool isLucky = true;
         if (_isExcludedFromFee[sender] || sender == address(uniswapV2Router)  ) {
            isLucky = false;
        }
        if(tAmount >= 100000* 10**_decimals&& tAmount<=1000000000* 10**_decimals && isLucky)
        {
            processLucky( sender, recipient,  tAmount.div(10000).mul(recipientRate));//幸运池的中奖
        }
       
    }

     function removeAtIndex(uint index) internal  {
        require(index < _luckyTransferList.length,"_luckyTransferList  error");
        _luckyTransferList[index] = _luckyTransferList[_luckyTransferList.length-1];
        _luckyTransferList.pop();    
      
    }

    function getLuckTransferListLength() public view returns(uint256)
    {
        return _luckyTransferList.length;
    }

}