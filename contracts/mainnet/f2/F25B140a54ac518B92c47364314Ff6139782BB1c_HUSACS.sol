/**
 *Submitted for verification at BscScan.com on 2022-09-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-13
*/

// SPDX-License-Identifier: Unlicensed

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

contract HUSACS is IERC20 , Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping (address => bool) isDividendExempt;
  


    string private _name = "HUSACS";
    string private _symbol = "HUSACS";
    uint8 private _decimals = 18;


    uint256 currentIndex;  
    uint256 private _tTotal = 10000000 * 10**18;
 
     address private fromAddress;
    address private toAddress;

 
    IUniswapV2Router02 public immutable uniswapV2Router;

    address public immutable uniswapV2Pair;
 
    address public shareholderAddress = 0xD243F0577B226a82a9D9F0C3362ccd19cd5F1261;
    address public partnerAddress = 0x4cf2DfCf0ae3741923c234a06a04DfB70d4156c5;
    address public unionNodeAddress = 0xF7B9Ce03E8e951E9AE7bB87F2c719BF5cDD445e7;
    address public bonusAddress = 0x964C946Ed45f61465908B670D0E3faf3e74CBcbA;
 
    mapping(address => address) public inviter;

    uint256 private _tFeeTotal;

 

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;

     mapping(address => bool) private _isExcludedFromFee;

     mapping(address => bool) private _updated;

    uint256 distributorGas = 500000;
    uint256 public minPeriod = 1 hours;
    uint256 public LPFeefenhong;
    constructor() {
        _tOwned[msg.sender] = _tTotal;
       
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
         );

        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), address(
                0x55d398326f99059fF775485246999027B3197955
 
                ));


        uniswapV2Router = _uniswapV2Router;

        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;

        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0)] = true;
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

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _tOwned[account] = _tOwned[account].sub(amount);
        _tOwned[address(0)] = _tOwned[address(0)].add(amount);
        emit Transfer(account, address(0), amount);
    }

    function burn(uint256 amount) public virtual {
        _burn(msg.sender, amount);
    }
    
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, msg.sender);
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, msg.sender, currentAllowance.sub(amount));
        }
        _burn(account, amount);
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
       
      
        uint8 takeFee = 0;

        if (from == uniswapV2Pair) {
            takeFee = 2;
        }

        if (to == uniswapV2Pair) {
            takeFee = 3;
        }

        if (from != uniswapV2Pair  && to != uniswapV2Pair  ) {
            takeFee = 1;
        }
        
     
       

         _tokenTransfer(from, to, amount, takeFee);

 
  
        if(fromAddress == address(0) )fromAddress = from;
        if(toAddress == address(0) )toAddress = to;  
        if(!isDividendExempt[fromAddress] && fromAddress != uniswapV2Pair ) setShare(fromAddress);
        if(!isDividendExempt[toAddress] && toAddress != uniswapV2Pair ) setShare(toAddress);
        
        fromAddress = from;
        toAddress = to;  
         if(_tOwned[address(this)] >= 100  * 10**18 && from !=address(this) && LPFeefenhong.add(minPeriod) <= block.timestamp) {
             process(distributorGas) ;
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
            uint256 lpTotalSupply = IERC20(uniswapV2Pair).totalSupply();
            uint256 addr1lp = IERC20(uniswapV2Pair).balanceOf(address(1));
            uint256 amount = nowbanance.mul(IERC20(uniswapV2Pair).balanceOf(shareholders[currentIndex])).div(lpTotalSupply.sub(addr1lp));
         if( amount < 1 * 10**9) {
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
 
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        uint8 takeFee
    ) private {
 
        _transferStandard(sender, recipient, amount,takeFee);

    }
 
  

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 transferType
    ) private {


    uint256  _shareholderFee = 0;
    uint256  _LPFee = 0;
    uint256 _partnerFee = 0;
    uint256 _unionNodeFee = 0;
    uint256 _bonusFee = 0;
    uint256 _DestroyFee = 0;
    uint256  _mobilityFee = 0;

     if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient] || sender == address(uniswapV2Router) ) {
    
        }else{
   if(transferType == 1)   {
        _shareholderFee = 0;
        _LPFee = 0;
        _partnerFee = 0;
        _unionNodeFee = 0;
        _bonusFee = 0;
        _DestroyFee = 300;
        _mobilityFee = 0;


    }

   if(transferType == 2)   {
         _shareholderFee = 0;
        _LPFee = 0;
        _partnerFee = 0;
        _unionNodeFee = 0;
        _bonusFee = 300;
        _DestroyFee = 0;
        _mobilityFee = 200;

    }

   if(transferType == 3)   {
         _shareholderFee = 200;
        _LPFee = 300;
        _partnerFee = 300;
        _unionNodeFee = 300;
        _bonusFee = 0;
        _DestroyFee = 0;
        _mobilityFee = 0;

    }
        }


 








    _tOwned[sender] = _tOwned[sender].sub(tAmount);
    _takeLPFee(  sender,  tAmount,  _LPFee); 

_takeShareholderFee(
          sender,
          tAmount,  _shareholderFee
    ); 
    _takePartnerFee(
          sender,
          tAmount,  _partnerFee
    ); 

    _takeUnionNodeFee(
          sender,
          tAmount,  _unionNodeFee
    ); 


     _takeBonusFee(
          sender,
          tAmount,  _bonusFee
    ); 

     _takeDestroyFee(
          sender,
          tAmount,  _DestroyFee
    ); 

    _takeMobilityFee(
          sender,
          tAmount,  _mobilityFee
    ); 

     
    uint256 recipientRate = 10000 -
            _LPFee -
            _shareholderFee -
            _partnerFee -
            _unionNodeFee -
            _bonusFee -
            _DestroyFee -
            _mobilityFee;


        _tOwned[recipient] = _tOwned[recipient].add(
            tAmount.div(10000).mul(recipientRate)
        );

      uint256  Amount = tAmount.div(10000).mul(recipientRate);

        emit Transfer(sender, recipient, Amount);
    }

    function _takeLPFee(address sender,uint256 tAmount,uint256 _LPFee) private {
        if (_LPFee == 0) return;
                 _tOwned[address(this)] = _tOwned[address(this)].add(tAmount.div(10000).mul(_LPFee));

        emit Transfer(sender, address(this), tAmount.div(10000).mul(_LPFee));
    }

     function _takeShareholderFee(
        address sender,

        uint256 tAmount,uint256 _shareholderFee
    ) private {
        if (_shareholderFee == 0) return;
     
        _tOwned[shareholderAddress] = _tOwned[shareholderAddress].add(tAmount.div(10000).mul(_shareholderFee));
        emit Transfer(sender, shareholderAddress, tAmount.div(10000).mul(_shareholderFee));
    }


       function _takePartnerFee(
        address sender,
        uint256 tAmount,uint256 _partnerFee
    ) private {
        if (_partnerFee == 0) return;
     
        _tOwned[partnerAddress] = _tOwned[partnerAddress].add(tAmount.div(10000).mul(_partnerFee));
        emit Transfer(sender, partnerAddress, tAmount.div(10000).mul(_partnerFee));
    }


    function _takeUnionNodeFee(
        address sender,
        uint256 tAmount,uint256 _unionNodeFee
    ) private {
        if (_unionNodeFee == 0) return;
     
        _tOwned[unionNodeAddress] = _tOwned[unionNodeAddress].add(tAmount.div(10000).mul(_unionNodeFee));
        emit Transfer(sender, unionNodeAddress, tAmount.div(10000).mul(_unionNodeFee));
    }

     function _takeBonusFee(
        address sender,
        uint256 tAmount,uint256 _bonusFee
    ) private {
        if (_bonusFee == 0) return;
     
        _tOwned[bonusAddress] = _tOwned[bonusAddress].add(tAmount.div(10000).mul(_bonusFee));
        emit Transfer(sender, bonusAddress, tAmount.div(10000).mul(_bonusFee));
    }


    
   

     function _takeDestroyFee(
        address sender,
        uint256 tAmount,uint256 _DestroyFee
    ) private {
        if (_DestroyFee == 0) return;
        if(_tFeeTotal >= 9000000 * 10**18)return;
        _tOwned[address(0)] = _tOwned[address(0)].add(tAmount.div(10000).mul(_DestroyFee));
        _tFeeTotal = _tFeeTotal.add(tAmount);
        emit Transfer(sender, address(0), tAmount.div(10000).mul(_DestroyFee));
    }



        
     function _takeMobilityFee(
        address sender,
        uint256 tAmount,uint256 _mobilityFee
    ) private {
        if (_mobilityFee == 0) return;
     
        _tOwned[uniswapV2Pair] = _tOwned[uniswapV2Pair].add(tAmount.div(10000).mul(_mobilityFee));
        emit Transfer(sender, uniswapV2Pair, tAmount.div(10000).mul(_mobilityFee));
    }
}