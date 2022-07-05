/**
 *Submitted for verification at BscScan.com on 2022-07-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-27
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-16
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
     * @dev Moves `amount` tokens  caller's account to `recipient`.
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
     * allowance mechanism. `amount` is then deducted  caller's
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

abstract contract Ownable {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

interface IToken {
    function release() external;
}
interface IPEToken {
    function release() external;
    function  totalPE() external view   returns (uint256);
    function setEndPE() external; 
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



// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))

// range: [0, 2**112 - 1]
// resolution: 1 / 2**112

 contract TokenDividendTracker is Ownable {
    using SafeMath for uint256;

    address[] public shareholders;
    uint256 public currentIndex;  
    mapping(address => bool) public _updated;
    mapping (address => uint256) public shareholderIndexes;
    uint256 distributorGas = 200000;
    address public  uniswapV2Pair;
    address public lpRewardToken;
    // 上次分红时间
    uint256 public LPRewardLastSendTime;
     mapping(address => uint256) public LPUserRewardLastSendTime; //私募金额
     uint256 public minPeriod = 86400;
    constructor(address uniswapV2Pair_, address lpRewardToken_){
        uniswapV2Pair = uniswapV2Pair_;
        lpRewardToken = lpRewardToken_;
    }
    function setMinPeriod(uint256 number) public onlyOwner {
         minPeriod = number;
    
    }
    function setLPRewardLastSendTime(uint256 uSentTime) public onlyOwner {
        LPRewardLastSendTime = uSentTime;
    }
    function getshareholders() external view returns (address[] memory)
      {
           return shareholders;

      }

       // LP分红发放
    function lpprocess(address iaddr) external onlyOwner {
      if(LPUserRewardLastSendTime[iaddr].add(minPeriod) <= LPRewardLastSendTime)  {
       // uint256 shareholderCount = shareholders.length;	
       uint256 nowbanance = IERC20(lpRewardToken).balanceOf(address(this));
       //shareholderCount == 0 || 
        if(nowbanance<1*10**18 ) return;
     
  
            uint256 amount = nowbanance.mul(IERC20(uniswapV2Pair).balanceOf(iaddr)).div(IERC20(uniswapV2Pair).totalSupply());
            if( amount == 0) {
                  return;
            }
            if(IERC20(lpRewardToken).balanceOf(address(this))  < amount ) return;
            IERC20(lpRewardToken).transfer(iaddr, amount);
           LPUserRewardLastSendTime[iaddr]=LPRewardLastSendTime+minPeriod ;
       
      }
    }
  
    // 根据条件自动将交易账户加入、退出流动性分红
    function setShare(address shareholder) external onlyOwner {
        if(_updated[shareholder] ){      
            if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);           
            return;  
        }
        if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) return;  
        addShareholder(shareholder);	
        _updated[shareholder] = true;
          
      }
    function quitShare(address shareholder) internal {
        removeShareholder(shareholder);   
        _updated[shareholder] = false; 
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
    
}
 contract NodeTokenDividendTracker is Ownable {
    using SafeMath for uint256;

    address[] public shareholders;
    uint256 public currentIndex;  
    mapping(address => bool) public _updated;
    mapping (address => uint256) public shareholderIndexes;
     uint256 awardamount;
    address public  uniswapV2Pair;
    address public lpRewardToken;
    uint256 public minlpu=100*10**18;
    uint256 distributorGas = 200000;
    uint256 public minPeriod = 86400;
    // 上次分红累计分红时间
    uint256 public LPRewardLastSendTime;
    // 上次分红累计分红时间
    // 上次分红时间
     mapping(address => uint256) public NodeRewardLastSendTime; //私募金额
    constructor(address uniswapV2Pair_, address lpRewardToken_){
        uniswapV2Pair = uniswapV2Pair_;
        lpRewardToken = lpRewardToken_;
    }
    function setMinPeriod(uint256 number) public onlyOwner {
         minPeriod = number;
    
    }
    function setLPRewardLastSendTime(uint256 uSentTime) public onlyOwner {
        LPRewardLastSendTime = uSentTime;
        
        uint256 nowbanance = IERC20(lpRewardToken).balanceOf(address(this));
             uint256 shareholderCount = shareholders.length;
              awardamount=0;
             if(shareholderCount>0){
             uint256 famount = nowbanance.div(2);
           awardamount=famount.div(shareholderCount); 
        
            }
          
    }
    function getLPU(address iaddr)   public  view returns (uint256){
        address token0=IUniswapV2Pair(uniswapV2Pair).token0();
        (uint reserve0, uint reserve1, ) = IUniswapV2Pair(uniswapV2Pair).getReserves();
        if(reserve0==0 ||IERC20(uniswapV2Pair).balanceOf(iaddr)==0){
            return 0;
        }
        //BT   USDT
        //(uint reserveA,  uint reserveB) =  lpRewardToken == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint reserveB =  lpRewardToken == token0 ? reserve1 : reserve0;       
        uint256 uB=reserveB.mul(IERC20(uniswapV2Pair).balanceOf(iaddr)).div(IERC20(uniswapV2Pair).totalSupply());
           
        return  uB;
    }
   // Node分红发放
    function nodeprocess(address iaddr) external onlyOwner {
        if( NodeRewardLastSendTime[iaddr].add(minPeriod)<=LPRewardLastSendTime ) {
            uint256 nowbanance = IERC20(lpRewardToken).balanceOf(address(this));
            if(nowbanance<1*10**18||awardamount==0 || IERC20(lpRewardToken).balanceOf(address(this))  < awardamount || getLPU(iaddr)<minlpu ) return;
            IERC20(lpRewardToken).transfer(iaddr, awardamount);
            NodeRewardLastSendTime[iaddr]=LPRewardLastSendTime.add(minPeriod);
        }
    }
  
      function getshareholders() external view returns (address[] memory)
      {
           return shareholders;

      }
    // 根据条件自动将交易账户加入、退出流动性分红
    function setShare(address shareholder) external onlyOwner {
       if(_updated[shareholder] ){      
         //  if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);           
           return;  
       }
     //   if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) return;  
       NodeRewardLastSendTime[shareholder]=LPRewardLastSendTime.add(minPeriod);
        addShareholder(shareholder);	
        _updated[shareholder] = true;
          
      }
    function quitShare(address shareholder) internal {
        removeShareholder(shareholder);   
        _updated[shareholder] = false; 
    }

    function addShareholder(address shareholder) internal {
      //  shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
    
}
 contract PETokenDividendTracker is Ownable {
    using SafeMath for uint256;
    address[] public shareholders;
    address[] public removeshareholders;
    uint256 public currentIndex;  
    mapping(address => bool) public _updated;
    mapping (address => uint256) public shareholderIndexes;
   uint256 private _minPEmount = 2000*10**18;  //最小私幕币数
   mapping(address => uint256) public _awardOwned; //已奖励数量
    address public  uniswapV2Pair;
    address public lpRewardToken;
      uint256 private _tPE=0;
     mapping(address => uint256) public _releasabletOwned; //私募金额
       uint256 private _PEpro = 100;
    // 上次分红时间
     uint256  public LPRewardLastSendTime;  
     mapping(address => uint256) public LPUserRewardLastSendTime; //私募金额
     uint256 public minPeriod = 86400;

    constructor(address uniswapV2Pair_, address lpRewardToken_){
        uniswapV2Pair = uniswapV2Pair_;
        lpRewardToken = lpRewardToken_;
    }
  function addAwardMount(address uAddress, uint256 amount)   external  onlyOwner  {
          _releasabletOwned[uAddress]=_releasabletOwned[uAddress]+amount;
          setShare(uAddress);
      }
  function firstbalanceOf(address account) public view returns (uint256) {
        return _releasabletOwned[account];
    }
    function getpMount(address uAddress)   public  view returns (uint256){
        address token0=IUniswapV2Pair(uniswapV2Pair).token0();
        (uint reserve0, uint reserve1, ) = IUniswapV2Pair(uniswapV2Pair).getReserves();
        //BT   USDT
        //(uint reserveA,  uint reserveB) =  lpRewardToken == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint reserveA =  lpRewardToken == token0 ? reserve0 : reserve1;
         uint256  uSupply =  IERC20(uniswapV2Pair).totalSupply();
        uint256 pMount=reserveA.mul(IERC20(uniswapV2Pair).balanceOf(uAddress)).div(uSupply);
          
        return  pMount;
    }
      function setMinPeriod(uint256 number) public onlyOwner {
         minPeriod = number;
    
    }
    function getshareholders() external view returns (address[] memory)
      {
           return shareholders;

      }
      function  totalPE() public view   returns (uint256) {
        return _tPE;
    }
   function setLPRewardLastSendTime(uint256 uSentTime) public onlyOwner {
        LPRewardLastSendTime = uSentTime;
             
    }
 
  function removeAllShareholder() internal {
     uint256   shareholderCount = removeshareholders.length;

        if(shareholderCount == 0)return;
       uint256 iterations = 0;
        while( iterations < shareholderCount) {
            quitShare(removeshareholders[iterations]);
              iterations++;

        }
        delete removeshareholders;
    }
     function setPEPro(uint256 _pepro) public onlyOwner {
       _PEpro = _pepro;
    }
    function peprocess(address iaddr) public onlyOwner {
        if(LPUserRewardLastSendTime[iaddr].add(minPeriod) <= LPRewardLastSendTime)  {
            
         uint256 nowbanance = IERC20(lpRewardToken).balanceOf(address(this));
          if(nowbanance<1*10**18) return;
         uint256 amount=  getpMount(iaddr).mul(_PEpro).div(1000); //应分红金额
           if(amount==0) return;
        uint256 tawardmount=_releasabletOwned[iaddr]; //兑奖励
        uint256 maxamount=_releasabletOwned[iaddr].mul(_PEpro).div(1000); //最大分红金额
        uint256 notamount=tawardmount.sub(_awardOwned[iaddr]);//还有多少无分红
          if(amount>=maxamount) amount=maxamount;
          if( amount >= notamount)  amount=notamount;   
             if(notamount==0){
             quitShare(iaddr);            
        }          
        if( nowbanance < amount ) return;
            IERC20(lpRewardToken).transfer(iaddr, amount);
            _awardOwned[iaddr]=_awardOwned[iaddr].add(amount);
          LPUserRewardLastSendTime[iaddr]=LPRewardLastSendTime.add(minPeriod);
         }
       
    }
     
  
    function setShare(address shareholder) public onlyOwner {
        if(_updated[shareholder] ){      
         
            return;  
        }
        
        addShareholder(shareholder);	
        _updated[shareholder] = true;
          
      }
    function quitShare(address shareholder) public  onlyOwner{
        removeShareholder(shareholder);   
        _updated[shareholder] = false; 
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
    
}
contract InviterToken{
    using SafeMath for uint256;

    address public _lpRewardToken;
    uint256 constant public _buyinviterFee = 350;
    uint256 constant public _sellinviterFee = 350;
    uint256[10] public _buypInviterFee = [100,125,150,175,200,225,250,275,300,350];
    uint256[10] public _sellpInviterFee = [100,125,150,175,200,225,250,275,300,350];
    uint256 constant private mininviter = 10 * 10**18;
    uint256 constant private minAdd = 1 * 10**17;
    mapping(address=>address[]) _pInviters; //上级查下级
    mapping(address=>address) _Inviters;//下级查上级
    constructor(address lpRewardToken_){
        _lpRewardToken = lpRewardToken_;
    }

    function setInviter(address from,address to,uint256 amount) public {
        if(amount >= mininviter && _Inviters[to] == address(0)){
            _Inviters[to] = from;
            if(_pInviters[from].length>0) _pInviters[from]=[to];
            else _pInviters[from].push(to);
        }
    }

    function Inviter(address from,address to,uint256 amount,bool k) public view returns(address, uint256, uint256){
        address cur;
        uint256 afee;
        uint256 rfee;
        if(k){
            cur = _Inviters[from];
            afee = amount.div(10000).mul(_sellinviterFee);
            if(cur!=address(0) && IERC20(_lpRewardToken).balanceOf(cur)>=mininviter){
                uint256 count = _pInviters[cur].length;
                if(count>_sellpInviterFee.length) count = 10;            
                rfee = amount.div(10000).mul(_sellpInviterFee[count-1]);
            }
        }else{
            cur = _Inviters[to];
            afee = amount.div(10000).mul(_buyinviterFee);
            if(cur!=address(0) && IERC20(_lpRewardToken).balanceOf(cur)>=mininviter){
                uint256 count = _pInviters[cur].length;
                if(count > _buypInviterFee.length) count = 10;            
                rfee = amount.div(10000).mul(_buypInviterFee[count-1]);
            }
        }
        return (cur, afee, rfee);
    }
    function getpInviters(address addr) public view returns(address[] memory){return _pInviters[addr];}
    function getInviter(address addr) public view returns(address){return _Inviters[addr];}
    function getpBuyInvitersFee() public view returns(uint256, uint256[10] memory){return (_buyinviterFee,_buypInviterFee);}
    function getpSellInvitersFee() public view returns(uint256, uint256[10] memory){return (_sellinviterFee,_sellpInviterFee);}
}

contract otherToken{
    using SafeMath for uint256;
    uint256 buyotherFee=0;
    uint256 sellotherFee=0;
    mapping(address=>uint256) _buyaddr;
    mapping(address=>uint256) _selladdr;
    address[] _paddr;
    function setaddress(address addr,uint256 fee,uint256 fee1) public {
        _paddr.push(addr);
        _buyaddr[addr] = fee;
        buyotherFee = buyotherFee.add(fee);

        _selladdr[addr] = fee1;        
        sellotherFee = sellotherFee.add(fee1);
    }
    function other(uint256 amount,bool k) public view returns(address[] memory, uint256[] memory){
        address[] memory addr = new address[](_paddr.length);
        uint256[] memory m = new uint256[](_paddr.length);        
        for(uint256 i=0;i<_paddr.length;i++){
            m[i] = amount.div(10000).mul(k ? _buyaddr[_paddr[i]] : _selladdr[_paddr[i]]);
            addr[i] = _paddr[i];
        }
        return (addr,m);
    }
}

contract BTToken is IERC20, Ownable {
    using SafeMath for uint256;

    uint256 private _poolburn=0;
    uint256  public lprice=0;
    uint256  public ltime=0;
    bool private sale = false;
    mapping(address => uint256) private _tOwned;
    mapping(address => bool) private _firstaward;

    uint256 private fTMount=0;
    mapping(address=>bool) public blacklist;
    bool private closeaaward=false;
    
    uint256 constant private _minusdtbyb=10*10**18;
    uint256 constant private _minusdtfistbuy=100*10**18;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    string private _name = "DBT";
    string private _symbol = "DBT";
    uint8 private _decimals = 18;
    //销毁
  
    //2-9邀请
    InviterToken _Inviter;
    
    // 营销
    otherToken _other;

    //节点
 
    address public nodegetAdd = 0x5E571c8C4967a08608e7fcDcada6442Bb05E4562;
    uint256 constant private _previousnodeFee = 500;
    uint256 private maxcount = 0; //节点最大值
    uint256 private minmount = 10000*10**18;
    uint256 private _tTotal = 36599998 * 10**18;

    address public _USDT = 0x7E0D7Eb274e0E5C4362422C50506DC22eDbF5A06;

    uint256 constant public buyDeadFee = 100;
    uint256 constant public sellDeadFee = 100;
    address constant public deadWallet = 0x000000000000000000000000000000000000dEaD;
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    address private fromAddress;
    uint256 public LPRewardLastSendTime;
    address private toAddress;
    mapping (address => bool) isDividendExempt;
    uint256 constant _buyLpFee = 150;
    uint256 constant _sellLpFee = 150;
    TokenDividendTracker public  immutable dividendTracker;
    uint256 constant _buyNodeFee = 50;
    uint256 constant _sellNodeFee = 50;
    NodeTokenDividendTracker public   immutable nodedividendTracker;

    PETokenDividendTracker public  immutable  pedividendTracker;
    mapping(address => address) public inviter;
    mapping(address => uint256) public invitercount;
    uint256 public minPeriod = 300;
   
    bool inlock=false;
    modifier lockThe() {
        inlock = true;
        _;
        inlock = false;
    }
    //
    constructor() {
        _tOwned[msg.sender] = _tTotal;
        _USDT = address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(address(0xCDe540d7eAFE93aC5fE6233Bee57E1270D3E330F));
        address iadd= IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _USDT);
        // Create a uniswap pair for this new token
        uniswapV2Pair = iadd;
        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
        //exclude owner and this contract from fee
        
        dividendTracker = new TokenDividendTracker(iadd, address(this));
        nodedividendTracker = new NodeTokenDividendTracker(iadd, address(this));
        pedividendTracker = new PETokenDividendTracker(iadd, address(this));
        _Inviter = new InviterToken(address(this));        

        uint256 fee = _tTotal.div(100).mul(90);
        _tOwned[address(this)] = fee;
        emit Transfer(address(0), address(this), fee);
        fee = _tTotal.sub(fee);
        _tOwned[address(0x1a5a02f162E47D4FE5D672b7d76de5b0c66A5FbC)] = fee;
        emit Transfer(address(0), address(0x1a5a02f162E47D4FE5D672b7d76de5b0c66A5FbC), fee);//0xf021fA60663629A5e70d6c2EA7a97FA932DE0c1C

        _other = new otherToken();
        _other.setaddress(0xA98cE440F86AEDaf082B98c20d2CdeDc6244C326,25,25);
        _other.setaddress(0xc0eb3A647ab4779F5b7b2e36860Bd018ea366b81,25,25);
        _other.setaddress(0x061F684aFf1CBF281cD188F42Dafaa21b3fB3A07,25,25);
        _other.setaddress(0x3369d88BC320E89c4270302AB38b0E7F66dd339e,25,25);
        _other.setaddress(0xc8Cb966F9F28c1a5b13b6509C589741FD5664355,25,25);
        _other.setaddress(0xd9EEdF15b63e2cA357C7BF9eFf834dAe474d96d5,25,25);

        _other.setaddress(0x1a5a02f162E47D4FE5D672b7d76de5b0c66A5FbC,34,34);
        _other.setaddress(0xc6727DB9338EF6FE2F1b778FB8E23b707b2d0D37,33,33);
        _other.setaddress(0xaeA35C376B80B77E39fCe57E49cc464134FC00c7,33,33);
    }

    function name() public view returns (string memory)  {
        return _name;
    }
   function set_blacklist(address pool,bool flag) public onlyOwner{
      
        blacklist[pool]=flag;
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
 
   function setMinPeriod(uint256 number) public onlyOwner {
             minPeriod = number;
             dividendTracker.setMinPeriod(number);
             nodedividendTracker.setMinPeriod(number);
            pedividendTracker.setMinPeriod(number);
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
                "transfer  allowance"
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
    function getPrice(uint256 amount)   public  view returns (uint256){
        address token0=IUniswapV2Pair(uniswapV2Pair).token0();
        (uint reserve0, uint reserve1, ) = IUniswapV2Pair(uniswapV2Pair).getReserves();
        if(reserve0==0){
            return 0;
        }
        //BT   USDT
        (uint reserveA,  uint reserveB) =  address(this) == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
        
       // reserveA=reserveA.mul(1000000);
        reserveB=reserveB.mul(1000000);
        uint priceAtoB = reserveB.div(reserveA).mul(amount).div(1000000); 
       
        return  priceAtoB;
    }
        
    function getIsPrice(address useradd, uint256 ucount)
            private
            view
            returns (bool)
        {
             
        uint256 myu = getPrice( _tOwned[useradd]);
        if (myu >= _minusdtbyb && ucount <= invitercount[useradd]) {
            return true;
        } else {
            return false;
        }
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
                "allowance   zero"
            )
        );
        return true; 
    }
     
    //设置最高奖励比例
   function setPEPro(uint256 _pepro) public onlyOwner {
         pedividendTracker.setPEPro(_pepro);
    }
     

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _approve(
            address owner,
            address spender,
            uint256 amount
        ) private {
        require(owner != address(0), "zero a");
        require(spender != address(0), "zero a");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
            address from,
            address to,
            uint256 amount
        ) private {
            require(from != address(0), "tr  zero");
            require(to != address(0), "tr to   zero");
            require(amount > 0, " greater  zero");
            require(!blacklist[from],"b");
            //indicates if fee should be deducted from transfer
            bool takeFee = false;
            bool firstYes=false;
            sale=false;
            if(to == nodegetAdd && from!=uniswapV2Pair)  autoaddnode(from,  amount);

            if (  to == uniswapV2Pair || from == address(uniswapV2Router) || from == uniswapV2Pair) {
                takeFee = true;  
                if( to == uniswapV2Pair){ sale=true; }
                if ( from == uniswapV2Pair && !closeaaward && !_firstaward[to] && IERC20(uniswapV2Pair).balanceOf(to) == 0 ){firstYes= true;} 
            }
    
            _tokenTransfer(from, to, amount, takeFee);

            if(to != uniswapV2Pair && from != address(uniswapV2Router) && from != uniswapV2Pair){
                _Inviter.setInviter(from,to,amount);
            }
        
            if (fromAddress == address(0)) fromAddress = from;
            if (toAddress == address(0)) toAddress = to;
    
            if (fromAddress != uniswapV2Pair) dividendTracker.setShare(fromAddress);
            if (toAddress != uniswapV2Pair) dividendTracker.setShare(toAddress);
            fromAddress = from;
            toAddress = to;                   
        
            if( firstYes ) {  //次购买奖励
                setFirstShare(to, amount);
                _firstaward[to]=true; 
            }
        
            if(!inlock) process(from);     
    }
 
    function process(address iaddr) private   lockThe {
         uint256 nowt=block.timestamp;
         if(  LPRewardLastSendTime.add(minPeriod)<= nowt)
         {
          LPRewardLastSendTime= nowt-nowt % minPeriod;
          pedividendTracker.setLPRewardLastSendTime(LPRewardLastSendTime);
          dividendTracker.setLPRewardLastSendTime(LPRewardLastSendTime);
           nodedividendTracker.setLPRewardLastSendTime(LPRewardLastSendTime);
         }
      
        if( pedividendTracker._updated(iaddr)) {
     
         pedividendTracker.peprocess(iaddr) ;  

          }
          if( dividendTracker._updated(iaddr)) {
   
        dividendTracker.lpprocess(iaddr)  ;

          }
         
         if( nodedividendTracker._updated(iaddr)) {
         
         nodedividendTracker.nodeprocess(iaddr)   ; 

          }       
    }
 
   
    function setPE(address shareholder, uint256 amount) public onlyOwner {
      
           pedividendTracker.addAwardMount(shareholder,amount);
    }

    function setFirstShare(address shareholder, uint256 amount) private {
         uint256 myu =   getPrice(amount)  ;
        if(myu <_minusdtfistbuy ) return;
      pedividendTracker.addAwardMount(shareholder,amount);
      
    }
    
    function setUserNode(address shareholder, uint256 amount) public onlyOwner {
         setnode(shareholder,amount);
    }
     
    function autoaddnode(
            address fromAdd,
            uint256 amount
        ) private {
            uint256 counti=nodedividendTracker.getshareholders().length ;
            if (
            counti >= maxcount ||
                amount < minmount ||
                fromAdd == uniswapV2Pair
            ) {
                return;
            }
            setnode(fromAdd,minmount);
    }
    function setnode(
            address fromAdd,
            uint256 amount
        ) private {
            pedividendTracker.addAwardMount(fromAdd,amount);
            nodedividendTracker.setShare(fromAdd) ;
    }
    function setnodeShareholder(
        address _shareholder,
        uint256 _amount,
        uint256 _maxcount
    ) public onlyOwner {
        maxcount = _maxcount;
        minmount = _amount;
        nodegetAdd = _shareholder;
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender_, address recipient_, uint256 amount_, bool takeFee_) private {        
        _transferStandard(sender_, recipient_, amount_, takeFee_);
    }    
    function _takeburnFee(address sender, uint256 tAmount) private returns(uint256) {
        uint256 dead = tAmount.div(10000).mul(sale ? sellDeadFee : buyDeadFee);
        if (dead>0){
            _tOwned[deadWallet] = _tOwned[deadWallet].add(tAmount);
            _tTotal = _tTotal.sub(tAmount);
            emit Transfer(sender, deadWallet, tAmount);
        }
        return dead;
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount, bool takeFee) private {        
        uint256 uAmount = tAmount;
        if(takeFee){
            uAmount = uAmount.sub(_takeburnFee(sender,tAmount));
            uint256 lpFee=0;
            uint256 newprice =   getPrice(1000000);
            if(ltime.add(minPeriod) <= block.timestamp){
                lprice=newprice;
                ltime= block.timestamp;
            }
            uint256 sprice=lprice.mul(87).div(100);
            //_poolburn>0 &&
            if( newprice<sprice && !takeFee){
                address token0=IUniswapV2Pair(uniswapV2Pair).token0();
                (uint reserve0, uint reserve1, ) = IUniswapV2Pair(uniswapV2Pair).getReserves();            
                //BT   USDT
                (uint reserveA,  uint reserveB) =  address(this) == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
                uint256  bA=reserveA-reserveB.div(sprice).mul(1000000);
                _tOwned[deadWallet] = _tOwned[deadWallet].add(bA);                
                _tOwned[uniswapV2Pair] = _tOwned[uniswapV2Pair].sub(bA);
                _tTotal = _tTotal.sub(bA);
                emit Transfer(uniswapV2Pair, deadWallet, bA);
                IUniswapV2Pair(uniswapV2Pair).sync();
                //_poolburn=0;
            }            
            (address addr, uint256 afee, uint256 rfee) = _Inviter.Inviter(sender, recipient, tAmount, sale);            
            if(addr!=address(0)){
                uAmount = uAmount.sub(afee);
                _tOwned[addr] = _tOwned[addr].add(rfee);
                emit Transfer(sender, addr, rfee);
                if(afee>rfee){
                    lpFee = lpFee.add(afee).sub(rfee);
                }
            }

            lpFee = lpFee.add(tAmount.div(10000).mul(sale ? _sellLpFee : _buyLpFee));
            if(lpFee>0){
                _tOwned[address(dividendTracker)] = _tOwned[address(dividendTracker)].add(lpFee);
                emit Transfer(sender, address(dividendTracker), lpFee);
                uAmount = uAmount.sub(lpFee);
            }
            uint256 nfee = tAmount.div(10000).mul(sale ? _sellNodeFee : _buyNodeFee);
            if(nfee > 0){
                _tOwned[address(nodedividendTracker)] = _tOwned[address(nodedividendTracker)].add(nfee);
                emit Transfer(sender, address(nodedividendTracker), nfee);
                uAmount = uAmount.sub(nfee);
            }
            (address[] memory a,uint256[] memory b) = _other.other(tAmount,sale);
            for(uint256 i=0;i<a.length;i++){
                if(b[i]>0){
                    _tOwned[a[i]] = _tOwned[a[i]].sub(b[i]);
                    emit Transfer(sender, a[i], b[i]);
                    uAmount = uAmount.sub(b[i]);
                }
            }
        }    

        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(uAmount);        
        emit Transfer(sender, recipient, uAmount);
        
    }
}