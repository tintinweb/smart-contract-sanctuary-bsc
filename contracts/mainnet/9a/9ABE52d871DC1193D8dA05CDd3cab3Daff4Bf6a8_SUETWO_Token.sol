/**
 *Submitted for verification at BscScan.com on 2022-03-13
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.10;

// https://testnet.binance.org/faucet-smart/
// https://pancake.kiemtienonline360.com/#/add/BNB/0x84493C578Dd6Cd3b946827f02c9c9c5bdFF049FF

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ERC20 {
	function name() external view returns (string memory);
	function symbol() external view returns (string memory);
	function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
//    function getOwner() external view returns (address);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
/**   address private _previousOwner; */

    event OwnershipTransferred(address indexed previousOwner ,address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
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

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


library Address {

    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { 
        	codehash := extcodehash(account) 
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


contract SUETWO_Token is Context, ERC20, Ownable {
  using SafeMath for uint256;
  using Address for address;
  
  //mapping (address => uint256) private a_balances;
  mapping (address => uint256) private a_rOwned;
  mapping (address => uint256) private a_tOwned;
  mapping (address => mapping (address => uint256)) private a_allowances;
  mapping(address => bool) private a_isExcludedFromFee;
  mapping(address => bool) private a_isExcluded;
  
//   uint256 private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;
  
  uint256 private _maxTxAmtPct = 1; // 1% Amt per Txn
  uint256 private _maxWalletPct = 3; // 3% Max Token per user
  uint256 private _maxOwnerWalletPct = 5;
  
  uint256 private _maxTxAmount;
  uint256 private _maxWalletToken;
  uint256 private _taxFee;

  uint256 private constant MAX = ~uint256(0);
  
  uint256 private _rTotal;
  uint256 private _tTotal;
  uint256 public _liquidityFee = 4; // 4% to liquidity
  uint256 private _previousLiquidityFee = _liquidityFee;

  uint256 public _burnFee = 2;
  uint256 private _previousBurnFee = _burnFee;
  uint256 private _devFee;
  uint256 private _previousDevFee = _devFee;
  uint256 private _tFeeTotal;
  uint256 private _previousTaxFee;

  
  IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
  
  constructor() {
    _name = "SUETWOV17";
    _symbol = "SUEV17";
    _decimals = 9;
    _tTotal = 10 * 10**9 * 10**9;
    _rTotal = (MAX - (MAX % _tTotal));
    _maxTxAmount = _tTotal.mul(_maxTxAmtPct).div(10**2);
    _maxWalletToken = _tTotal.mul(_maxWalletPct).div(10**2);
    a_isExcludedFromFee[owner()] = true;
    a_isExcludedFromFee[address(this)] = true;

    a_rOwned[_msgSender()] = _rTotal;

    _taxFee = 9;
    
    // TEST : 0xD99D1c33F9fC3444f8101754aBC46c52416550D1 V2 --- V1 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
    // MAIN : 0x10ED43C718714eb63d5aA57B78B54704E256024E 
     IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); //v2 router
         
    // Create a pancake pair for this new token
    uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
            
    // set the rest of the contract variables
    uniswapV2Router = _uniswapV2Router;
    
//    a_balances[_msgSender()] = _totalSupply;
    emit Transfer(address(0), _msgSender(), _tTotal);

  }
  
  function name() public view override returns (string memory) {
        return _name;
    }

  function symbol() public view override returns (string memory) {
        return _symbol;
    }

  function decimals() public view override returns (uint8) {
        return _decimals;
    }

  function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }
    
  function excludeFromFee(address account) public onlyOwner {
        a_isExcludedFromFee[account] = true;
    }

  function includeInFee(address account) public onlyOwner {
        a_isExcludedFromFee[account] = false;
    }
    
  function isExcludedFromFee(address account) public view returns (bool) {
        return a_isExcludedFromFee[account];
    }
    
  function setTaxFee(uint256 newTax) public onlyOwner {
        _taxFee = newTax;
    }
    
  function allowance(address owner, address spender) public view override returns (uint256) {
        return a_allowances[owner][spender];
    }

  function approve(address spender, uint256 amount) public override returns (bool) {
        m_approve(_msgSender(), spender, amount);
        return true;
    }

  function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        m_transfer(sender, recipient, amount);
        m_approve(sender, _msgSender(), a_allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

  function transfer(address recipient, uint256 amount) public override returns (bool) {
        m_transfer(_msgSender(), recipient, amount);
        return true;
    }
    
  function balanceOf(address account) public view override returns (uint256) {
//        if (_isExcluded[account]) return _tOwned[account]; 
        return tokenFromReflection(a_rOwned[account]); 
//        return a_balances[account];
    }
    
    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  m_getRate();
        return rAmount.div(currentRate);
    }
    
    function m_getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = m_getCurrentSupply();
        return rSupply.div(tSupply);
    }
    
    function m_getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      

        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

  function m_approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        a_allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
  function m_transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
		// require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is uniswap pair.
        /*uint256 contractTokenBalance = balanceOf(address(this));        
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            //add liquidity
            swapAndLiquify(contractTokenBalance);
        }*/
        
        //transfer amount, it will take tax, burn, liquidity fee
        m_tokenTransfer(from,to,amount); 
        
        /* bool takeFee = true;
        
        if (a_isExcludedFromFee[from] || a_isExcludedFromFee[to]) {
            takeFee = false;
        }
        
        uint256 tTransAmt = amount;
        if (takeFee){
          uint256 tFee = calculateTaxFee(amount);
          tTransAmt = amount.sub(tFee);
        }

        uint256 contractBalanceRecepient = balanceOf(to);
        uint256 tempMaxWallet = _maxWalletToken;
        
        if (a_isExcludedFromFee[to]){
        	tempMaxWallet = _totalSupply.mul(_maxOwnerWalletPct).div(10**2);
        }
        
		require(contractBalanceRecepient + tTransAmt <= tempMaxWallet, "Exceeds maximum wallet token amount");
		*/
		
        //emit Transfer(from, to, tTransAmt);
    }
    
  function m_tokenTransfer(address sender, address recipient, uint256 amount) private {
        if(a_isExcludedFromFee[sender] || a_isExcludedFromFee[recipient]){
            removeAllFee();
        }
        else if(recipient == uniswapV2Pair){ require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount."); }
        else{
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
            uint256 contractBalanceRecepient = balanceOf(recipient);
            require(contractBalanceRecepient + amount <= _maxWalletToken, "Exceeds maximum wallet token amount");
        }
        
        //Calculate burn amount and dev amount
        uint256 burnAmt = amount.mul(_burnFee).div(100);
//        uint256 devAmt = amount.mul(_devFee).div(100);
		uint256 devAmt = 0;

        if (a_isExcluded[sender] && !a_isExcluded[recipient]) {
            m_transferFromExcluded(sender, recipient, (amount.sub(burnAmt).sub(devAmt)));
        } else if (!a_isExcluded[sender] && a_isExcluded[recipient]) {
            m_transferToExcluded(sender, recipient, (amount.sub(burnAmt).sub(devAmt)));
        } else if (!a_isExcluded[sender] && !a_isExcluded[recipient]) {
            m_transferStandard(sender, recipient, (amount.sub(burnAmt).sub(devAmt)));
        } else if (a_isExcluded[sender] && a_isExcluded[recipient]) {
            m_transferBothExcluded(sender, recipient, (amount.sub(burnAmt).sub(devAmt)));
        } else {
            m_transferStandard(sender, recipient, (amount.sub(burnAmt).sub(devAmt)));
        }

        if(a_isExcludedFromFee[sender] || a_isExcludedFromFee[recipient])
            enableFee();
    }

  function m_transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = getValuesTrf(tAmount);
        a_rOwned[sender] = a_rOwned[sender].sub(rAmount);
        a_tOwned[recipient] = a_tOwned[recipient].add(tTransferAmount);
        a_rOwned[recipient] = a_rOwned[recipient].add(rTransferAmount);           
        //_takeLiquidity(tLiquidity);

        tLiquidity = tLiquidity + 1;

        m_reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

  function m_transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = getValuesTrf(tAmount);
        a_tOwned[sender] = a_tOwned[sender].sub(tAmount);
        a_rOwned[sender] = a_rOwned[sender].sub(rAmount);
        a_rOwned[recipient] = a_rOwned[recipient].add(rTransferAmount);   
        //_takeLiquidity(tLiquidity);

        tLiquidity = tLiquidity + 1;

        m_reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    
  function m_transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = getValuesTrf(tAmount);
        a_rOwned[sender] = a_rOwned[sender].sub(rAmount);
        a_rOwned[recipient] = a_rOwned[recipient].add(rTransferAmount);
        //_takeLiquidity(tLiquidity);

        tLiquidity = tLiquidity + 1;
        m_reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    } 

  function m_transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = getValuesTrf(tAmount);

        a_tOwned[sender] = a_tOwned[sender].sub(tAmount);
        a_rOwned[sender] = a_rOwned[sender].sub(rAmount);
        a_tOwned[recipient] = a_tOwned[recipient].add(tTransferAmount);
        a_rOwned[recipient] = a_rOwned[recipient].add(rTransferAmount);
        //a_takeMarketing(tMarketing);
        tLiquidity = tLiquidity + 1;
        m_reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }   

  function getValuesTrf(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTrfAmount, uint256 tFee, uint256 tLiquidity) = m_getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = m_getRValues(tAmount, tFee, tLiquidity, m_getRate());
        return (rAmount, rTransferAmount, rFee, tTrfAmount, tFee, tLiquidity);
    }
    
  function m_getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        //uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tLiquidity = 0;
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

  function m_getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        //uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rLiquidity = tLiquidity + 1;
        rLiquidity = 0;
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
        return (rAmount, rTransferAmount, rFee);
    }

  function m_reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }
    
  function removeAllFee() private {
        if(_taxFee == 0 && _liquidityFee == 0) return;
        savePrevFee();
        
        _taxFee = 0;
        _liquidityFee = 0;
        _burnFee = 0;
        _devFee = 0;
    }
    
  function savePrevFee() private {
        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;
        _previousBurnFee = _taxFee;
        _previousDevFee = _devFee;
    }
    
  function enableFee() private {
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
        _burnFee = _previousBurnFee;
        _devFee = _previousDevFee;
    }
    
  function calculateTaxFee(uint256 amt) private view returns (uint256) {
        return amt.mul(_taxFee).div(10**2);
    }
    
  //to receive BNB from uniswapV2Router when swaping
  receive() external payable {}

  function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        m_approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }
    
  function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        m_approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        m_approve(
            _msgSender(),
            spender,
            a_allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        m_approve(
            _msgSender(),
            spender,
            a_allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

}