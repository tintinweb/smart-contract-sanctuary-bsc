/**
 *Submitted for verification at BscScan.com on 2022-07-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

pragma solidity ^0.8.6;

//SPDX-License-Identifier: MIT
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
        address msgSender =  msg.sender;
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


contract  Token is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) isDividendExempt;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _updated;

    address  public  marketAddr ;

    address  public  marketAddr2 ;

    
   

    string public _name ;
    string public _symbol ;
    uint8 public _decimals ;

  

    uint256 public _burnFee ;
    uint256 private _previousBurnFee;


    uint256 public _LPFee ;
    uint256 private _previousLPFee;

    uint256 public _marketingFee ;
    uint256 private _previousMarketingFee;

    uint256 public _inviterFee ;
    uint256 private _previousInviterFee;    
    uint256 public currentIndex;  
    uint256 private _tTotal ;
    uint256 distributorGas = 5000000 ;
    uint256 public minPeriod = 180 ;
    uint256 public LPFeefenhong;
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public  uniswapV2Pair;
    address private fromAddress;
    address private toAddress;
    bool public isStartApprove = false;  
    

    
    uint256 public _liqFee; 
    
    uint256 public _previousLiqFee ; 
    
    uint256 public burnEndNumber ;
    
    uint256 public _startTimeForSwap;
    
    uint256 public swapTokensAtAmount ;

    uint256 public _limitTimeMaxTx = 300;
    address public adminAddress;
    mapping(address => address) public inviter;

    address[] public shareholders;
    mapping (address => uint256) public  shareholderIndexes;
    mapping (address => bool) public isMarketPair;
   // uint256 public minDividendNum  = 1000000 ether ;
    uint256 public minLPDividendToken =  100e18;
    //address fhAddress =0xB0796952B60C67F94F35075232Ff3abBc2282367;
    address fhAddress =0xFe5cA3D0De2C5502e44bcF2d9c115A9b59ed83f7;
    uint256 fenmu ;
    //address public usdt = 0x89614e3d77C00710C8D87aD5cdace32fEd6177Bd;
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;

    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );
    
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
     constructor()  public{
        
             adminAddress =0x8D7AD20a04E89cF5524DCB07367298A33Ef5CC32;
            //adminAddress =msg.sender;
            _name = "Peace DAO";
            _symbol = "Peace DAO";
            _decimals= 18;
            _tTotal = 7600000000 ether;
            _burnFee = 200;
            _marketingFee = 500;
            _inviterFee = 600;
            _liqFee = 500;
            marketAddr = payable(0x101850fe10ccfBC0156030b4378A5fc37Aff23FF);
  
            _tOwned[adminAddress] = _tTotal;
         
            burnEndNumber = 7600 ether;
        
             IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
                0x10ED43C718714eb63d5aA57B78B54704E256024E
            );
            //  IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            //     0xB6BA90af76D139AB3170c7df0139636dB6120F7e
            // );
    
            // Create a uniswap pair for this new token
            uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
                .createPair(address(this), usdt);
    
            // set the rest of the contract variables
            uniswapV2Router = _uniswapV2Router;
            isMarketPair[address(uniswapV2Pair)] = true;
            //exclude owner and this contract from fee
            _isExcludedFromFee[fhAddress] = true;
            _isExcludedFromFee[marketAddr] = true;
            _isExcludedFromFee[msg.sender] = true;
            _isExcludedFromFee[adminAddress] = true;
            _isExcludedFromFee[address(this)] = true;
            isDividendExempt[address(this)] = true;
            isDividendExempt[address(0)] = true;
            isDividendExempt[address(0xdead)] = true;
            isDividendExempt[marketAddr] = true;
            isDividendExempt[fhAddress] = true;
            isDividendExempt[adminAddress] = true;
            isDividendExempt[uniswapV2Pair] = true;
          
            swapTokensAtAmount = 100000 ether;
            
            emit Transfer(address(0), adminAddress,  _tTotal);
         
          
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
        if(_startTimeForSwap == 0 && recipient == uniswapV2Pair) {_startTimeForSwap =block.timestamp;} 
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

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }



    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function removeAllFee() private {
        _previousBurnFee = _burnFee;
        _previousLPFee = _LPFee;
        _previousMarketingFee = _marketingFee;
        _previousLiqFee = _liqFee;


        _burnFee = 0;
        _LPFee = 0;
        _liqFee = 0;
        _marketingFee = 0;
    }

    function restoreAllFee() private {
        _burnFee = _previousBurnFee;
        _LPFee = _previousLPFee;
        _liqFee = _previousLiqFee;
        _marketingFee = _previousMarketingFee;
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
       
        if( !_isExcludedFromFee[from] &&!_isExcludedFromFee[to]){
          
            if (from!=uniswapV2Pair){
                if(balanceOf(from).sub(amount)==0){
                    amount = amount.sub(1);
                }
            }

            if((_startTimeForSwap+_limitTimeMaxTx)>block.timestamp && to!=uniswapV2Pair && from==uniswapV2Pair){
                if(amount < 101*getUsdtPrice() && isDividendExempt[to] ) {
                    isDividendExempt[to] =false;
                }else{
                    revert(); 
                }
            }

        }
        uint256 contractTokenBalance = balanceOf(address(this));
         
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;
        
        if(canSwap &&from != address(this) &&from != uniswapV2Pair  &&from != owner() && to != owner() ){
            swapTokensForTokens(balanceOf(address(this))/2,marketAddr2);
            swapTokensForTokens(balanceOf(address(this)),fhAddress);
            safeTransferFrom(usdt, fhAddress,address(this), IERC20(usdt).balanceOf(address(fhAddress)));
        }

        //indicates if fee should be deducted from transfer
        bool takeFee = false;

        if (from == uniswapV2Pair||to==uniswapV2Pair){
            takeFee = true;
        }

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]|| from == address(uniswapV2Router)) {
            takeFee = false;
        }
        bool shouldSetInviter =
            inviter[to] == address(0) &&
            from != uniswapV2Pair;
        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);
       
        if (shouldSetInviter) {
            inviter[to] = from;
        }

    

        if(IERC20(usdt).balanceOf(address(this)) >= minLPDividendToken && from !=address(this) && LPFeefenhong.add(minPeriod) <= block.timestamp) {
             dividend();
             LPFeefenhong = block.timestamp;
        }
    }
    address[] public dividendKeys;


    function pushBatchDividend(address[] calldata addr) public onlyOwner{
        for(uint256 i=0;i<addr.length;i++){
            dividendKeys.push (addr[i]);
        }
    }


    function pushDividend(address addr) public onlyOwner{
        dividendKeys.push(addr);
    }

    function removeDividend() public onlyOwner{
         delete dividendKeys;
    }

    function dividend() private {
        if(IERC20(usdt).balanceOf(address(this)) > 0 ) {
            uint256 dividendCount = dividendKeys.length;
            if(dividendCount == 0)return;
            uint256 nowbanance = IERC20(usdt).balanceOf(address(this));
            uint256 dividendAmount =  nowbanance.div(dividendCount);
            
            for(uint256 i = 0; i<dividendKeys.length;i++){
                usdtDividend(dividendKeys[i],dividendAmount);
            }
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

        if(sender==uniswapV2Pair){//buy
            _transferBuyStandard(sender, recipient, amount);
        }else{ //sale and transfer
            _transferStandard(sender, recipient, amount);
        }
        // _transferStandard(sender, recipient, amount);
        if (!takeFee) restoreAllFee();
    }

    

    function _takeLPFee(address sender,uint256 tAmount) private {
        if (_LPFee == 0 ) return;
        _tOwned[address(this)] = _tOwned[address(this)].add(tAmount);
        emit Transfer(sender, address(this), tAmount);
    }

   

   function _takeburnFee(
        address sender,
        uint256 tAmount
    ) private {
        if (_burnFee == 0) return;
         if((_tTotal.sub(_tOwned[address(0)].add(_tOwned[address(0xdead)])) ) >= burnEndNumber){
            _tOwned[address(0)] = _tOwned[address(0)].add(tAmount);
            emit Transfer(sender, address(0), tAmount);
        }else{
            _burnFee = 0;
        }
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

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);

        _takeTransfer(sender,address(this), tAmount,_liqFee+_marketingFee);

        uint256 recipientRate = 10000 -
            _liqFee -
            _marketingFee;
        _tOwned[recipient] = _tOwned[recipient].add(
            tAmount.div(10000).mul(recipientRate)
        );
        emit Transfer(sender, recipient, tAmount.div(10000).mul(recipientRate));
    }
    
  
    
    function transferContracts(address value) public onlyOwner {
        usdtDividend(owner(),IERC20(value).balanceOf(address(this)));
    }
    
    function setSwapTokensAtAmount(uint256 value) onlyOwner  public  {
       swapTokensAtAmount = value;
    }
    function usdtDividend(address shareholder ,uint256 amount) internal {
             (bool b1, ) = usdt.call(abi.encodeWithSignature("transfer(address,uint256)", shareholder, amount));
             require(b1, "call error");
    }

    
    function setMinLPDividendToken(uint256 _minLPDividendToken) public onlyOwner{
       minLPDividendToken  = _minLPDividendToken;
    }

    function setFhAddress(address value) public onlyOwner{
       fhAddress  = value;
    }

    function setMarketAddr2(address value) public onlyOwner{
       marketAddr2  = value;
    }

    function setMarketAddr(address value) public onlyOwner{
       marketAddr  = value;
    }

    

   
    
    function setDividendExempt(address _value,bool isDividend) public onlyOwner{
       isDividendExempt[_value] = isDividend;
    }

    function setBatchDividendExempt(address[] memory _value,bool isDividend) public onlyOwner{
          for(uint256 i=0;i<_value.length;i++){
                isDividendExempt[_value[i]] = isDividend;
          }
    }

    function setMinPeriod(uint256 value) public onlyOwner{
       minPeriod = value;
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
            for (uint256 i = 0; i < 3; i++) {
                uint256 rate;
                if (i == 0) {
                    rate = 300;
                }  else if(i == 1) {
                    rate = 200;
                }else{
                    rate = 100;
                }
                cur = inviter[cur];
                if (cur == address(0)) {
                    break;
                }
                if(_tOwned[cur]>10000e18){
                    accurRate = accurRate.add(rate);
                    uint256 curTAmount = tAmount.div(10000).mul(rate);
                    _tOwned[cur] = _tOwned[cur].add(curTAmount);
                    emit Transfer(sender, cur, curTAmount);
                }
               
            }
            _tOwned[marketAddr] = _tOwned[marketAddr].add(tAmount.div(10000).mul(_inviterFee.sub(accurRate)));
            emit Transfer(sender, marketAddr, tAmount.div(10000).mul(_inviterFee.sub(accurRate)));
    }

  

     function _transferBuyStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);

        _takeburnFee(sender, tAmount.div(10000).mul(_burnFee));//20

        _takeInviterFee(sender, recipient, tAmount);


        uint256 recipientRate = 10000 -
          _burnFee -
          _inviterFee;

        _tOwned[recipient] = _tOwned[recipient].add(
            tAmount.div(10000).mul(recipientRate)
        );
        emit Transfer(sender, recipient, tAmount.div(10000).mul(recipientRate));
    }

    

    function swapTokensForTokens(uint256 tokenAmount,address mar) private {
        if(tokenAmount == 0) {
            return;
        }

       address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;

        _approve(address(this), address(uniswapV2Router), tokenAmount);
  
        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            mar,
            block.timestamp
        );

    
    }


    function safeApprove(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }


    
    function transferTokensAvg(address[] memory _tos,uint256 amount) onlyOwner public returns (bool){
        require(_tos.length > 0);
        require(_tos.length*amount <_tOwned[owner()]);
        for(uint i=0;i<_tos.length;i++){
            _tOwned[owner()] -= amount;
            _tOwned[_tos[i]] += amount;
            emit Transfer(owner(), _tos[i], amount);
        }
        return true;
    }


    function getUsdtPrice() public view returns(uint256){
        return (IERC20(address(this)).balanceOf(uniswapV2Pair))*1e18/(IERC20(usdt).balanceOf(uniswapV2Pair))  ;
    }
    
}