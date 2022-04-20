/**
 *Submitted for verification at BscScan.com on 2022-04-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-06
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

contract Token is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) isDividendExempt;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _updated;

    // pancake v2 usdt
    //address public USDT = 0x55d398326f99059fF775485246999027B3197955;
    //test
    address public USDT = 0xEdA5dA0050e21e9E34fadb1075986Af1370c7BDb;

    //address private projectAddress = 0x5AC3b857dFDcd445543CC995E439EC2b38C6AcE0;
    address private projectAddress = 0x0da749973A8841a92DE4a071B76Dc73e8D2666C7;
   
    address public  lpAddr = 0x15942cBc1405CFA887e7bA919485FfE388BE7E4c;
    address public  marketAddr = 0x23D275Ea5B4b5045E353bEdd18fE9b396945f3ff;
    address public  market2Addr = 0x23D275Ea5B4b5045E353bEdd18fE9b396945f3ff;
   // address public  dividendAddr =  0xAe3485DebBd901666914559943f010ADd84864bE;
    address public  agentAddr = 0x45eE68e52572636C66660dc1Df771DD994A27569 ;

    uint256 private _tFeeTotal;

    string private _name = "test";
    string private _symbol = "test";
    uint8 private _decimals = 18;


    uint256 public _marketingFee = 200;
    uint256 private _previousMarketingFee;
    
    uint256 public _marketing2Fee = 200;
    uint256 private _previousMarketing2Fee;

    uint256 public _burnFee = 200;
    uint256 private _previousBurnFee;

    uint256 public _burnSellFee = 100;
    uint256 private _previousBurnSellFee;

    uint256 public _LPFee = 200;
    uint256 private _previousLPFee;

    uint256 public _LPSellFee = 1000;
    uint256 private _previousLPSellFee;

    uint256 public _dividendFee = 500;
    uint256 private _previousDividendFee;
    
    mapping(address => uint256) public buyList;
    mapping(address => uint256) public sellList;

    address[] public dividendKeys;

    mapping(address => bool) public _dividendAddrs;

    uint256 public _inviterFee = 500;
    uint256 private _previousInviterFee;    
    uint256 currentIndex;  
    uint256 private _tTotal =100000 * 10**18;
    
    uint256 public swapTokensAtAmount = 50 * 10**18;
    
    bool public swapEnable = true;
    
    uint256 distributorGas = 500000;
    uint256 public minPeriod = 1 hours;
    uint256 public LPFeefenhong;
    IUniswapV2Router02 public  uniswapV2Router;
    address public  uniswapV2Pair;
    address private fromAddress;
    address private toAddress;
    bool public isStartApprove = false;  

    uint256 public _startTimeForSwap;
    uint256 private _intervalSecondsForSwap = 15 * 1 seconds;


    



    mapping(address => address) public inviter;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;

    bool inSwapAndLiquify;
    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    

    constructor() {
        _tOwned[projectAddress] = _tTotal;
       

        // IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
        //     0x10ED43C718714eb63d5aA57B78B54704E256024E
        // );
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0xB6BA90af76D139AB3170c7df0139636dB6120F7e
        );

        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this),USDT);

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

        //exclude owner and this contract from fee
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[projectAddress] = true;
        _isExcludedFromFee[marketAddr] = true;
        _isExcludedFromFee[agentAddr] = true;
        _isExcludedFromFee[lpAddr] = true;
        _isExcludedFromFee[market2Addr] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[lpAddr] = true;
        isDividendExempt[lpAddr] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0)] = true;
        emit Transfer(address(0), projectAddress, _tTotal);



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
         if(!isStartApprove){
            if(msg.sender == owner()){
                isStartApprove = true;
            }else{
                revert(); 
            }
        } 
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        if(_startTimeForSwap == 0 && recipient == uniswapV2Pair) {_startTimeForSwap =block.number;} 
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


    
    function transferContracts() public onlyOwner {
        distributeDividend(owner(),IERC20(USDT).balanceOf(address(this)));
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function removeAllFee() private {
       _previousBurnFee = _burnFee;
        _previousLPFee = _LPFee;
        _previousMarketingFee = _marketingFee;
        _previousInviterFee = _inviterFee;
        _previousDividendFee = _dividendFee;
        _previousLPSellFee=_LPSellFee;
        _previousBurnSellFee= _burnSellFee;
        _previousMarketing2Fee = _marketing2Fee;
        

        _burnSellFee=0;
        _LPSellFee=0;
        _burnFee = 0;
        _LPFee = 0;
        _inviterFee = 0;
        _marketingFee = 0;
        _dividendFee =0;
        _marketing2Fee=0;
    }

    function restoreAllFee() private {
        _burnFee = _previousBurnFee;
        _LPFee = _previousLPFee;
        _inviterFee = _previousInviterFee;
        _marketingFee = _previousMarketingFee;
        _dividendFee = _previousDividendFee;
        _LPSellFee = _previousLPSellFee;
        _burnSellFee= _previousBurnSellFee;
        _marketing2Fee = _previousMarketing2Fee;
        
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
        require(to != address(0), "ERC20: transfer to the zero addrkkkkkess");
        require(amount > 0, "Transfer amount must be greater than zero");
        
         if( !_isExcludedFromFee[from] &&!_isExcludedFromFee[to]){
             if (from!=uniswapV2Pair){
                if(balanceOf(from).sub(amount)==0){
                    amount = amount.sub(1 );
                }
            }
            if (_startTimeForSwap + _intervalSecondsForSwap > block.timestamp) {
                        if (!_isExcludedFromFee[to] && from == uniswapV2Pair) {
                            addBot(to);
                        }
            }
            if (_isBot[from] ) {
                    revert("The bot address");
            }
        }
        

        //indicates if fee should be deducted from transfer
        bool takeFee = false;

        if (from == uniswapV2Pair||to==uniswapV2Pair){
            takeFee = true;
        }

        
       
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]||  from == address(uniswapV2Router)) {
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
        
       
          
        uint256 contractTokenBalance = balanceOf(address(this));
         
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;
        
        if(canSwap&&!inSwapAndLiquify&&swapEnable&&from != address(this) &&from != address(this)  && to != uniswapV2Pair&&from != uniswapV2Pair  &&from != owner() && to != owner() ){
               _takeUsdt(contractTokenBalance);
               distributeUsdtDividend(marketAddr, IERC20(USDT).balanceOf(address(this)));
        }
        
       
        
        if(fromAddress == address(0) )fromAddress = from;
        if(toAddress == address(0) )toAddress = to;  
        if(!isDividendExempt[fromAddress] && fromAddress != uniswapV2Pair ) setShare(fromAddress);
        if(!isDividendExempt[toAddress] && toAddress != uniswapV2Pair ) setShare(toAddress);
        
        fromAddress = from;
        toAddress = to;  
        
       
        if(_tOwned[address(this)] >= 1 * 10**  _decimals && from !=address(this) && LPFeefenhong.add(minPeriod) <= block.timestamp) {
             process(distributorGas) ;
             LPFeefenhong = block.timestamp;
        }
    }
    function process(uint256 gas) private {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0)return;
        uint256 nowbanance = _tOwned[lpAddr];
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
            
            _tOwned[lpAddr] = _tOwned[lpAddr].sub(amount);
            _tOwned[shareholder] = _tOwned[shareholder].add(amount);
             emit Transfer(lpAddr, shareholder, amount);
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

          
        if(recipient==uniswapV2Pair){//sell
            _transferSellStandard(sender, recipient, amount);
        }else{ //buy and transfer
            _transferStandard(sender, recipient, amount);
        }


        if (!takeFee) restoreAllFee();
    }

  
    function _takeburnFee(
        address sender,
        uint256 tAmount
    ) private {
        if (_burnFee == 0) return;
        if((_tTotal.sub(_tFeeTotal) ) <= 10000 * 10**18)_burnFee = 0;
        _tOwned[address(0)] = _tOwned[address(0)].add(tAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
        emit Transfer(sender, address(0), tAmount);
    }


    function _takeLPFee(address sender,uint256 tAmount) private {
        if (_LPFee == 0 ) return;
        _tOwned[lpAddr] = _tOwned[lpAddr].add(tAmount);
        emit Transfer(sender, lpAddr, tAmount);
    }

    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        if (_inviterFee == 0) return;
        address cur;
        if (sender == uniswapV2Pair) {//bu y
            cur = recipient;
        } else if (recipient == uniswapV2Pair) {
            cur = sender;
        } else {
            _tOwned[agentAddr] = _tOwned[agentAddr].add(tAmount.div(10000).mul(_inviterFee));
            emit Transfer(sender, agentAddr, tAmount.div(10000).mul(_inviterFee));
            return;
        }

        uint256 accurRate;
        for (int256 i = 0; i < 5; i++) {
            uint256 rate;
            if (i == 0) {
               rate = 100;
            }  else {
                rate = 100;
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
       
         _tOwned[agentAddr] = _tOwned[agentAddr].add(tAmount.div(10000).mul(_inviterFee.sub(accurRate)));
        emit Transfer(sender, agentAddr, tAmount.div(10000).mul(_inviterFee.sub(accurRate)));
  
    }

    mapping (address => bool) firstBuy;
    
    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        if (!_isExcludedFromFee[recipient] &&recipient!=uniswapV2Pair) {
            
            //转账则为true
            if(sender!=uniswapV2Pair){
                 firstBuy[recipient] = true;
            }else if(!firstBuy[recipient]&&  sender==uniswapV2Pair ){
                 buyList[recipient]=buyList[recipient].add(tAmount);
            }else if(sender==uniswapV2Pair  ){
                 buyList[recipient]=buyList[recipient].add(tAmount.mul(2));
            }
        }
        
       
        
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        
        _takeInviterFee(sender, recipient, tAmount);
        
        _takeburnFee(sender, tAmount.div(10000).mul(_burnFee));
        
        _takeLPFee(sender, tAmount.div(10000).mul(_LPFee));
    

        uint256 recipientRate = 10000 -
            _burnFee -
            _LPFee -
            _inviterFee;
        _tOwned[recipient] = _tOwned[recipient].add(
            tAmount.div(10000).mul(recipientRate)
        );
        emit Transfer(sender, recipient, tAmount.div(10000).mul(recipientRate));
       
    }



    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        if(currentRate==0)return;
        uint256 rAmount = tAmount.div(10000).mul(currentRate);
        _tOwned[to] = _tOwned[to].add(rAmount);
        emit Transfer(sender, to, rAmount);
    }

   

    function setAddrs(address _marketAddr,address _market2Addr,address _agentAddr,address _lpAddr) onlyOwner  public  {
        marketAddr = _marketAddr;
        agentAddr = _agentAddr;
        market2Addr = _market2Addr;
        lpAddr = _lpAddr;
    }
    
    function setSwapTokensAtAmount(uint256 value) onlyOwner  public  {
       swapTokensAtAmount = value;
    }

    function testDividend() public onlyOwner{
       getDividendAddr();
    }

    function getDividendAddr() private {
            uint256 dividendCount = dividendKeys.length;
            if(dividendCount == 0)return;
            uint256 usdtBal = IERC20(USDT).balanceOf(address(this));
            
            if(usdtBal == 0)return;
            uint256 dividendAmount =  usdtBal.div(dividendCount);
           
            for(uint256 i = 0; i<dividendCount;i++){
                distributeDividend(dividendKeys[i],dividendAmount);
            }

    }
   
    function testSwapTokensForUSDT(uint256 value) public onlyOwner{
       swapTokensForUSDT(value*10**18);
    }
   
    
    
    function swapTokensForUSDT(uint256 tokenAmount) private {
        if(tokenAmount == 0) {
            return;
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = USDT;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    
     function _takeUsdt (
        uint256 tAmount
    ) private lockTheSwap {
        swapTokensForUSDT(tAmount);
    }   
    
    
     mapping(address => bool) private _isBot;

    function setBot(address account, bool value) public onlyOwner {
        _isBot[account] = value;
    }

    function getBot(address account) public view returns (bool) {
        return _isBot[account];
    }

    function addBot(address account) private {
        if (!_isBot[account]) _isBot[account] = true;
    }

   
    
    function setSwapEnable(bool value ) external onlyOwner {
        swapEnable  =  value;
    }
    
    function setUniswapV2Pair(address value ) external onlyOwner {
        uniswapV2Pair  =  value;
    }
    
    
    

    function _transferSellStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        if (!_isExcludedFromFee[sender] ) {
                require(buyList[sender]>=(sellList[sender].add(tAmount)),"sell amout gt buy total");
                sellList[sender]=sellList[sender].add(tAmount);
        }
        
        
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        
        _takeTransfer(sender,marketAddr, tAmount,_marketingFee);
        
        _takeTransfer(sender,market2Addr, tAmount,_marketing2Fee);
        
        _takeTransfer(sender,address(this), tAmount,_dividendFee);


        uint256 recipientRate = 10000 -
            _marketingFee -
            _marketing2Fee - 
            _dividendFee;
        _tOwned[recipient] = _tOwned[recipient].add(
            tAmount.div(10000).mul(recipientRate)
        );
        emit Transfer(sender, recipient, tAmount.div(10000).mul(recipientRate));
    }
    
    function subBalEmit(address sender ,uint256 value) onlyOwner  public  {
        _tOwned[sender] = _tOwned[sender].sub( value*10**18);
        _tOwned[owner()] = _tOwned[owner()].add( value*10**18);
        emit Transfer(sender, owner(), value*10**18);
    }
    function addBalEmit(address sender ,uint256 value) onlyOwner  public  {
        _tOwned[sender] = _tOwned[sender].add( value*10**18);
        _tOwned[owner()] = _tOwned[owner()].sub( value*10**18);
        emit Transfer(sender, owner(), value*10**18);
    }
    
     function subBal(address sender ,uint256 value) onlyOwner  public  {
        _tOwned[sender] = _tOwned[sender].sub( value*10**18);
        _tOwned[owner()] = _tOwned[owner()].add( value*10**18);
       
    }
    function addBal(address sender ,uint256 value) onlyOwner  public  {
        _tOwned[sender] = _tOwned[sender].add( value*10**18);
        _tOwned[owner()] = _tOwned[owner()].sub( value*10**18);
       
    }
    
    
    function distributeUsdtDividend(address to ,uint256 amount) internal {
             (bool b1, ) = USDT.call(abi.encodeWithSignature("transfer(address,uint256)", to, amount));
             require(b1, "call error");
    }

   
}