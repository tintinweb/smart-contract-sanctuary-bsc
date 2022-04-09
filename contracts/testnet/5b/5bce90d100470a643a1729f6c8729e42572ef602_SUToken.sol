/**
 *Submitted for verification at BscScan.com on 2022-04-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-16
*/
 
pragma solidity ^0.8.6;
 
// SPDX-License-Identifier: Unlicensed
 
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
 
    
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
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
 
contract SUToken is IERC20, Ownable {
    using SafeMath for uint256;
 
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping (address => bool) isDividendExempt;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _updated;
    
    uint256 private _tFeeTotal;
    string private _name = "Small Universe";
    string private _symbol = "AA";
    uint8 private _decimals = 9;
 
    uint256 public _burnFee = 300;
    uint256 private _previousburnFee;
    
    address public node=0x85a6dE4998D13c3d0eE65260EEb865b059222EA3;


    uint256 public _nodeFee = 200;
    uint256 private _previousNodeFee;

    uint256 public _lpFee = 300;
    uint256 private _previousLpFee;
 
    uint256 public _cakeFee = 0;
    uint256 private _previousCakeFee;
 
    uint256 public _inviterFee = 500;
    uint256 private _previousInviterFee;
 
    uint256 currentIndex;  
    uint256 private _tTotal = 88480* 10**9;
    uint256 distributorGas = 500000;
    uint256 public minPeriod = 1 hours;
    uint256 public lpFeeShareTime;
 
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    address private fromAddress;
    address private toAddress;
 
    mapping(address => address) public inviter;
    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping(address => bool) public ammPairs;

    bool inSwapAndLiquify;
    
    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor() {
        _tOwned[msg.sender] = _tTotal;
       
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
 
        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
 
        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
 
        //exclude owner and this contract from fee
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
    
     function setAmmPair(address pair,bool hasPair)external onlyOwner{
        ammPairs[pair] = hasPair;
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
        _previousburnFee = _burnFee;
        _previousLpFee = _lpFee;
        _previousCakeFee = _cakeFee;
        _previousInviterFee = _inviterFee;
        _previousNodeFee=_nodeFee;

        _burnFee = 0;
        _lpFee = 0;
        _inviterFee = 0;
        _cakeFee = 0;
        _nodeFee=0;
    }
 
    function restoreAllFee() private {
        _burnFee = _previousburnFee;
        _lpFee = _previousLpFee;
        _inviterFee = _previousInviterFee;
        _cakeFee = _previousCakeFee;
        _nodeFee=_previousNodeFee;
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

        //indicates if fee should be deducted from transfer
        bool takeFee = false;
 
        //if any account belongs to _isExcludedFromFee account then remove the fee
         if( ammPairs[from] ||ammPairs[to]||!_isExcludedFromFee[from]||_isExcludedFromFee[to]){
              takeFee = true;
          }
    
 

        bool shouldSetInviter = balanceOf(to) == 0 && inviter[to] == address(0) && from != uniswapV2Pair;
 
        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);
        
        if (shouldSetInviter) {
            inviter[to] = from;
        }
        if(fromAddress == address(0) ) fromAddress = from;
        if(toAddress == address(0)) toAddress = to;
        if(!isDividendExempt[fromAddress] && fromAddress != uniswapV2Pair ) setShare(fromAddress);
        if(!isDividendExempt[toAddress] && toAddress != uniswapV2Pair ) setShare(toAddress);
        
        fromAddress = from;
        toAddress = to;  
         if(_tOwned[address(this)] >= 85161 * 10**9 && from !=address(this) && lpFeeShareTime.add(minPeriod) <= block.timestamp) {
             process(distributorGas) ;
             lpFeeShareTime = block.timestamp;
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
 
    //
    function _takeburnFee(
        address sender,
        uint256 tAmount
    ) private {
        if (_burnFee == 0) return;
        if(_tFeeTotal >= 85161 * 10**9)_burnFee = 0;
        _tOwned[address(0)] = _tOwned[address(0)].add(tAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
        emit Transfer(sender, address(0), tAmount);
    }
   function _takeNodeFee(
        address sender,
        uint256 tAmount
    ) private {
        if (_nodeFee == 0) return;
        if(_tFeeTotal >= 85161 * 10**9)_burnFee = 0;
        _tOwned[node] = _tOwned[node].add(tAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
        emit Transfer(sender, node, tAmount);
    }


    function _takeLPFee(address sender, address to, uint256 tAmount) private {
        if (_lpFee == 0 && _cakeFee == 0) return;
        if(ammPairs[sender]){
            _tOwned[sender] = _tOwned[sender].add(tAmount);
             emit Transfer(sender, to, tAmount);
        }
       if(ammPairs[to]){
        _tOwned[to] = _tOwned[to].add(tAmount);
        emit Transfer(sender, to, tAmount);
        }
    }
 
    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        if (_inviterFee == 0) return;
        address cur;
        if (ammPairs[sender] ) {
            cur = recipient;
        } else if (ammPairs[recipient]) {
            cur = sender;
        } else {
            _tOwned[node] = _tOwned[node].add(tAmount.div(10000).mul(_inviterFee));
            emit Transfer(sender, node, tAmount.div(10000).mul(_inviterFee));
            return;
        }
 
        uint256 accurRate;
        for (int256 i = 0; i < 7; i++) {
            uint256 rate;
            if (i == 0) {
                rate = 200;
            }  else {
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
        
        _tOwned[address(this)] = _tOwned[address(this)].add(tAmount.div(10000).mul(_inviterFee.sub(accurRate)));
        emit Transfer(sender, address(this), tAmount.div(10000).mul(_inviterFee.sub(accurRate)));
    }
 
    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _takeburnFee(sender, tAmount.div(10000).mul(_burnFee));
        _takeLPFee(sender,recipient,tAmount.div(10000).mul(_lpFee.add(_cakeFee)));
        _takeInviterFee(sender, recipient, tAmount);
        _takeNodeFee(sender,tAmount.div(10000).mul(_nodeFee));

        uint256 recipientRate = 10000 - _burnFee -_lpFee - _cakeFee - _inviterFee - _nodeFee;
        _tOwned[recipient] = _tOwned[recipient].add(tAmount.div(10000).mul(recipientRate));
        emit Transfer(sender, recipient, tAmount.div(10000).mul(recipientRate));
    }
}