/**
 *Submitted for verification at BscScan.com on 2022-10-22
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
     * allowance mechanism. `amount` is then deducted  caller's
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
        uint256 ltime= block.timestamp;
      if(LPUserRewardLastSendTime[iaddr].add(minPeriod) <= ltime)  {
       // uint256 shareholderCount = shareholders.length;	
       uint256 nowbanance = IERC20(lpRewardToken).balanceOf(address(this));
       //shareholderCount == 0 || 
         if(nowbanance==0) return;
            uint256  periodTime=ltime-LPUserRewardLastSendTime[iaddr];
             uint256  countPeriod=periodTime.div(minPeriod);
  
            uint256 amount = countPeriod* 2*10**18;   //nowbanance.mul(IERC20(uniswapV2Pair).balanceOf(iaddr)).div(IERC20(uniswapV2Pair).totalSupply());
           
            if(nowbanance  < amount ) {
                 IERC20(lpRewardToken).transfer(iaddr, nowbanance);
                 }else{           
            IERC20(lpRewardToken).transfer(iaddr, amount);
            }
           LPUserRewardLastSendTime[iaddr]=  LPUserRewardLastSendTime[iaddr] +countPeriod*minPeriod;
       
      }
    }
  
    // 根据条件自动将交易账户加入、退出流动性分红
    function setShare(address shareholder) external onlyOwner {
        if(_updated[shareholder] ){      
          //  if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);           
            return;  
        }
      ///  if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) return;  
       LPUserRewardLastSendTime[shareholder]=  block.timestamp;
        addShareholder(shareholder);	
        _updated[shareholder] = true;
          
      }
    function quitShare(address shareholder) external onlyOwner {
         if(_updated[shareholder] ){ 
        removeShareholder(shareholder);   
        _updated[shareholder] = false; 
         }
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
    uint256 public minbof=1000*10**18; //奖历最小持库数
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
                   awardamount=nowbanance.div(shareholderCount); 
        
            }
          
    }
    
   // Node分红发放
    function nodeprocess(address iaddr) external onlyOwner {
        
        if( NodeRewardLastSendTime[iaddr].add(minPeriod)<=LPRewardLastSendTime ) {
           uint256 nowbanance = IERC20(lpRewardToken).balanceOf(address(this));
          //|| getLPU(iaddr)<minlpu
        if(nowbanance<1*10**18||awardamount==0 || IERC20(lpRewardToken).balanceOf(address(this))  < awardamount   || IERC20(lpRewardToken).balanceOf(iaddr)<minbof ) return;
         
                 
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
    function quitShare(address shareholder) external onlyOwner {
         if(_updated[shareholder]  ){ 
        removeShareholder(shareholder);   
        _updated[shareholder] = false; 
         }
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
//   uint256 private _minPEmount = 2000*10**18;  //最小私幕币数
 //  mapping(address => uint256) public _awardOwned; //已奖励数量
    address public  uniswapV2Pair;
    address public lpRewardToken;
    //  uint256 private _tPE=0;
 //    mapping(address => uint256) public _releasabletOwned; //私募金额
     //  uint256 private _PEpro = 100;
    // 上次分红时间
     uint256  public LPRewardLastSendTime;  
     mapping(address => uint256) public LPUserRewardLastSendTime; //私募金额
     uint256 public minPeriod = 86400;

    constructor(address uniswapV2Pair_, address lpRewardToken_){
        uniswapV2Pair = uniswapV2Pair_;
        lpRewardToken = lpRewardToken_;
    }
      function setMinPeriod(uint256 number) public onlyOwner {
         minPeriod = number;
    
    }
    function getshareholders() external view returns (address[] memory)
      {
           return shareholders;

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
   
    function peprocess(address iaddr) public onlyOwner {
        uint256 nowt=block.timestamp;
        if(LPUserRewardLastSendTime[iaddr].add(minPeriod) <= nowt)  {
            
         uint256 nowbanance = IERC20(lpRewardToken).balanceOf(address(this));
         if(nowbanance==0) return;
           uint256  periodTime=nowt-LPUserRewardLastSendTime[iaddr];
          uint256  countPeriod=periodTime.div(minPeriod);
           uint256 amount=countPeriod* 5*10**18;   //  getpMount(iaddr).mul(_PEpro).div(1000); //应分红金额
             
        if( nowbanance < amount ) {
       IERC20(lpRewardToken).transfer(iaddr, nowbanance);
        }else
        {
            IERC20(lpRewardToken).transfer(iaddr, amount);
       }
          LPUserRewardLastSendTime[iaddr]=LPUserRewardLastSendTime[iaddr] +countPeriod*minPeriod;
         }
       
    }
     
  
    function setShare(address shareholder) public onlyOwner {
        if(_updated[shareholder] ){      
         
            return;  
        }
             LPUserRewardLastSendTime[shareholder]=  block.timestamp;
        addShareholder(shareholder);	
        _updated[shareholder] = true;
          
      }
    function quitShare(address shareholder) public  onlyOwner{
        if(_updated[shareholder]  ){ 
        removeShareholder(shareholder);   
        _updated[shareholder] = false; 
          }
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

contract GETToken is IERC20, Ownable {
    using SafeMath for uint256;
    struct FeeV {
       uint256 _burnFee;
       uint256 _burnUserFee;
      uint256 _inviterFee;
      uint256 _Address2Fee;
      uint256 _nodeFee;
 
  }
  //交易控制
    uint256 private _poolburn=0;
    uint256  public lprice=0;
    uint256  public ltime=0;
    bool private sale=false;
    mapping(address => uint256) private _tOwned;
    mapping(address => bool) private _firstaward;
    uint256 private fTMount=0;
 
    bool private closeaaward=false;
    //白名单无手续费
    mapping (address => bool) private _isExcludedFromFee;

    // uint256 private _maxPE;
     uint256 constant private _minusdtbyb=10*10**18;
      uint256 constant private _minusdtfistbuy=100*10**18;
    mapping(address => mapping(address => uint256)) private _allowances;
   ///持币奖励数最小数据量
    uint256 constant private _minowerusermount=500*10**18;
    ///有效推荐人最小数量
    uint256 constant private _minfuser=500*10**18;
    uint256 constant private _musermount=3000*10**18;  //买入后最大持仓量
     mapping(address => uint256) public myfusercount;  //有效用户数
     mapping(address => uint256) public mynodeusercount;  //有效节点数
     uint256 tjusercount  =10;  //最小有 效数用户
      uint256 nodeusercount=7;//最有效节点数
    mapping (address => bool) public _nodeuseradd;  //节点用户
    mapping (address => bool) public _caojinodeuseradd;  //超级节点用户
     
    string private _name = "GET";
    string private _symbol = "GET";
    uint256 private _decimals = 18;
    //用户销毁
   
    address constant private _burnUserAdd = 0x723D8acF0bB871DfdDe85846F583034146051F67;
    //邀请
    uint256 public _inviterFee = 2000;
   // uint16 constant private _previousInviterFee = 3500;
    uint256 constant private mininviter = 1 * 10**17;
    address constant private inviterAdd = 0x723D8acF0bB871DfdDe85846F583034146051F67;
    //1
 
    address[] private inviterAdds;
   
   
    //基金会社区运营费用
    uint256  constant private _previousAddress2Fee = 0;
    address constant public marketAddress2 = 0x723D8acF0bB871DfdDe85846F583034146051F67; //基金会地址
    //节点
 
   // address public nodegetAdd = 0xefe4A5692Cda2382A9EB430bf6D68AeD6091B8f9;
     uint256 constant private _previousnodeFee = 3000;
    uint256 private maxcount = 0; //节点最大值
    uint256 private minmount = 10000*10**18;

    ///总发行量
    uint256 private _tTotal = 16970000 * 10**18;

    // 销毁到总量
    uint256  constant private _thTotal = 10 * 10**18; //10* 10**18 ;
    //流通总量
     uint256   public _tnTotal = 16970000 * 10**18; //15* 10**18 ; //
    address public   _USDT = 0x7E0D7Eb274e0E5C4362422C50506DC22eDbF5A06;
   address constant public deadWallet = 0x000000000000000000000000000000000000dEaD;
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    address private fromAddress;
      uint256 public LPRewardLastSendTime;
    address private toAddress;
    mapping (address => bool) isDividendExempt;
   TokenDividendTracker public   dividendTracker;
    NodeTokenDividendTracker  public     nodedividendTracker;
    PETokenDividendTracker public     pedividendTracker;
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
    constructor(address _router, address _cUSDT) {
        _tOwned[msg.sender] = _tTotal;
        _USDT = _cUSDT;
          IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_router);
    address iadd= IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _USDT);
        //    _maxPE=pe;
        // Create a uniswap pair for this new token
        uniswapV2Pair = iadd;
        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
        //exclude owner and this contract from fee
        
         dividendTracker = new TokenDividendTracker(iadd, address(this));
        nodedividendTracker = new NodeTokenDividendTracker(iadd, address(this));
        pedividendTracker = new PETokenDividendTracker(iadd, address(this));
       // _isExcludedFpedividendTrackerromFee[owner()] = true;
          _isExcludedFromFee[address(this)] = true;
          _isExcludedFromFee[address(pedividendTracker)] = true;
            _isExcludedFromFee[address(nodedividendTracker)] = true;
          _isExcludedFromFee[address(dividendTracker)] = true;
           _isExcludedFromFee[address( msg.sender)] = true;
        emit Transfer(address(0), msg.sender, _tTotal);
    }

    function name() public view returns (string memory)  {
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
  
    
    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    

    function restoreAllFee() private view returns ( FeeV memory ) {
         
      uint256    _burnFee=0;
      uint256  _burnUserFee=0;
        if (  _tnTotal > _thTotal ) {
            _burnFee = 1000;  
            _burnUserFee = 0;
        } else {
            _burnFee = 0;
            _burnUserFee = 1000;
          
        }

      // uint256  _inviterFee = _previousInviterFee / pcount;
   //    uint256 _lpFee = _previousLpFee / pcount;
      uint256  _nodeFee = _previousnodeFee  ;
   //   uint256  _Address1Fee = _previousAddress1Fee / pcount;
      uint256  _Address2Fee = _previousAddress2Fee ;
    
       FeeV memory feev=  FeeV(_burnFee,_burnUserFee,_inviterFee ,_Address2Fee,_nodeFee);
        return feev ;
    }
  function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
  function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }
   
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
      
        //indicates if fee should be deducted from transfer
        bool takeFee = true;
      //  bool firstYes=false;
        bool tuni=false;
          sale=false;
      
        if (  to == uniswapV2Pair || from == address(uniswapV2Router) || from == uniswapV2Pair      ) {
            tuni=true;
          
            if( to == uniswapV2Pair){
               sale=true;
            }
        //     //购买限制1000
         
        if ( from == uniswapV2Pair  ){  
            uint256 usermountall=balanceOf(to)+amount;
            if(usermountall>_musermount)
              revert('over user mount');
             } 
          }
 //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }
         bool shouldSetInviter = amount >= mininviter&& ! tuni &&  inviter[to] == address(0) && !_isExcludedFromFee[from] ;
        if (shouldSetInviter) {
            //invitercount[from] = invitercount[from] + 1;
            inviter[to] = from;
        }
        _tokenTransfer(from, to, amount, takeFee);
       
       

         if (toAddress == address(0)) toAddress = to;
  
             
        fromAddress = from;
        toAddress = to;
     
        if(!inlock) process(from);
     
    }

 
    function process(address iaddr) private   lockThe {
        uint256 nowt=block.timestamp;
         if(  LPRewardLastSendTime.add(minPeriod)<= nowt)
         {
          LPRewardLastSendTime= nowt-nowt % minPeriod;
          pedividendTracker.setLPRewardLastSendTime(LPRewardLastSendTime);
        //  dividendTracker.setLPRewardLastSendTime(LPRewardLastSendTime);
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
 
 

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
      
        _transferStandard(sender, recipient, amount,takeFee);
                
    }
//
  
    //
    function _takeburnFee(address sender, uint256 tAmount,uint256 burnFee) private {
        if (burnFee == 0) return;

        _tOwned[deadWallet] = _tOwned[deadWallet].add(tAmount);
        _tnTotal=_tnTotal.sub(tAmount);
   
        emit Transfer(sender, deadWallet, tAmount);
    }

    //
    function _takeburnUserFee(address sender, uint256 tAmount,uint256 burnUserFee ) private {
        if (burnUserFee == 0) return;
        _tOwned[_burnUserAdd] = _tOwned[_burnUserAdd].add(tAmount);
        emit Transfer(sender, _burnUserAdd, tAmount);
    }

    
    function _takemarketAddress2(address sender, uint256 tAmount ,uint256  Address2Fee) private {
        if (Address2Fee == 0) return;
        _tOwned[marketAddress2] = _tOwned[marketAddress2].add(tAmount);
        emit Transfer(sender, marketAddress2, tAmount);
    }

    function _takenodeAdd(address sender, uint256 tAmount ,uint256 nodeFee) private {
        if (nodeFee == 0) return;
        _tOwned[address(nodedividendTracker)] = _tOwned[address(nodedividendTracker)].add(tAmount);
        emit Transfer(sender, address(nodedividendTracker), tAmount);
    }

   

    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount,uint256 inviterFee
    ) private {
        if (inviterFee == 0) return;
      address   cur;
        if (sender == uniswapV2Pair) {
            cur = recipient;
        } else {
            cur = sender;
        } 
    
       address   caddr= inviter[cur];
     
            if (caddr == address(0)) {
               caddr=inviterAdd;
            } 
            uint256 uAmount=  tAmount.mul(inviterFee).div(100000);
            _updaterecipientuser(caddr,  _tOwned[caddr], uAmount);
            _tOwned[caddr] = _tOwned[caddr].add(uAmount);
            emit Transfer(sender, caddr, uAmount);
         
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount,bool takeFee
    ) private {
        FeeV memory tFee=  FeeV(0,0,0,0,0);
        if(takeFee){
         tFee =restoreAllFee();
        }
        
        uint256 oldsender=_tOwned[sender];
        uint256 newsender=oldsender.sub(tAmount);
        _tOwned[sender] = newsender;
        _updatesenderuser(sender, oldsender, tAmount);
        _takeburnFee(sender, tAmount.div(100000).mul(tFee._burnFee),tFee._burnFee);
        _takeburnUserFee(sender, tAmount.div(100000).mul(tFee._burnUserFee),tFee._burnUserFee);
    
        _takemarketAddress2(sender, tAmount.div(100000).mul(tFee._Address2Fee),tFee._Address2Fee);
        _takenodeAdd(sender, tAmount.div(100000).mul(tFee._nodeFee),tFee._nodeFee);
    
         _takeInviterFee(sender, recipient, tAmount,tFee._inviterFee);
         
        uint256 recipientRate = 100000 -
            tFee._burnFee -
            tFee._burnUserFee -
              tFee._inviterFee -
              tFee._Address2Fee -
            tFee._nodeFee;
          uint256 uAmount=   tAmount.div(100000).mul(recipientRate);
           
      uint256 oldrecipient=_tOwned[recipient];
        uint256 newrecipient=oldrecipient.add(uAmount);
        _tOwned[recipient] = newrecipient;
         _updaterecipientuser(recipient, oldrecipient, uAmount);
        emit Transfer(sender, recipient, uAmount);
    }

    ////tAmount 原用户金额 uAmount 变量金额
   function _updatesenderuser(address sender, uint256 tAmount ,  uint256 uAmount) private {
        uint256 oldsender=tAmount;
        uint256 newsender=oldsender.sub(uAmount);
        _tOwned[sender] = newsender;
 if(!_isExcludedFromFee[sender]){
         ///转出用户
         if( newsender>= _minfuser ){
             dividendTracker.setShare(sender); 
        }else{
               dividendTracker.quitShare(sender); 
        }
          address sendertjAddr=inviter[sender];
           address sendercjnodeAddr=inviter[sendertjAddr];
 
          if(sendertjAddr != address(0) && oldsender >= _minfuser && newsender < _minfuser && myfusercount[sendertjAddr] > 0 && sender != uniswapV2Pair){
                           //旧的节点人数
                   ///扣减有效用户数
                myfusercount[sendertjAddr] = myfusercount[sendertjAddr].sub(1);
                //更新节点数
                if(myfusercount[sendertjAddr]==9&&sendercjnodeAddr!=address(0) && mynodeusercount[sendercjnodeAddr]>0){
                    mynodeusercount[sendercjnodeAddr]=mynodeusercount[sendercjnodeAddr]-1;
                     //变更节点标识
                    if(mynodeusercount[sendercjnodeAddr]< nodeusercount){
                            nodedividendTracker.quitShare(sendercjnodeAddr); 
                    }else{
                         nodedividendTracker.setShare(sendercjnodeAddr) ;
                    }
                }
        //变更推荐用户情况
                if(myfusercount[sendertjAddr]<tjusercount){
                    pedividendTracker.quitShare(sendertjAddr); 
                }else{
                   pedividendTracker.setShare(sendertjAddr);
                }
            }
           }
         
         //转用户判断
         
    }

        ////tAmount 原用户金额 uAmount 变量金额
   function _updaterecipientuser(address recipient, uint256 tAmount ,  uint256 uAmount) private {
       
       uint256 oldrecipient=tAmount;
       uint256 newrecipient=oldrecipient.add(uAmount);
        _tOwned[recipient] = newrecipient;
          

           ///转入用户
               if(!_isExcludedFromFee[recipient]){
        address recipienttjAddr=inviter[recipient];
        address recipientcjnodeAddr=inviter[recipienttjAddr];
        if( newrecipient>= _minfuser ){
             dividendTracker.setShare(recipient); 
        }else{
               dividendTracker.quitShare(recipient); 
        }
         ///有效推荐人最小数量
   
 
          if(recipienttjAddr != address(0) && oldrecipient < _minfuser && newrecipient >= _minfuser && recipient != uniswapV2Pair){
                           //旧的节点人数
                   ///扣减有效用户数
                     myfusercount[recipienttjAddr] = myfusercount[recipienttjAddr].add(1);
                //更新节点数
              if(myfusercount[recipienttjAddr]==tjusercount&&recipientcjnodeAddr!=address(0)  ){
                         mynodeusercount[recipientcjnodeAddr]=mynodeusercount[recipientcjnodeAddr]+1;
                     //变更节点标识
                 if(mynodeusercount[recipientcjnodeAddr]< nodeusercount){
                    nodedividendTracker.quitShare(recipientcjnodeAddr); 
                   }else{
                         nodedividendTracker.setShare(recipientcjnodeAddr) ;
                      }
                }
        //变更推荐用户情况
              if(myfusercount[recipienttjAddr] < tjusercount){
                  pedividendTracker.quitShare(recipienttjAddr); 
              
                }else{
                
                  pedividendTracker.setShare(recipienttjAddr);
                }
          }
               }

         
    }


}