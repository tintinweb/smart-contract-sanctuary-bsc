/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


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
        assembly { codehash := extcodehash(account) }
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

 contract Ownable is Context {
    address public owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }
    

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

// pragma solidity >=0.5.0;

interface IPancakeswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


// pragma solidity >=0.5.0;

interface IPancakeswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// pragma solidity >=0.6.2;

interface IPancakeswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// pragma solidity >=0.6.2;

interface IPancakeswapV2Router02 is IPancakeswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


contract BCOMP is Context, IERC20, Ownable {
  using SafeMath for uint256;
  string private constant NAME = "BCOMPToken";
  string private constant SYMBOL = "BCOMP";
  uint8 private constant DECIMALS = 18;
  IERC20 private BUSD;

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;
  mapping (address => bool) private _isExcludedFromFee;

  uint256 private constant TOTAL = 1 * 10**9 * 10**18;

  uint256[] public buyFees = [6, 1]; 
  uint256[] public sellFees = [7, 1];

  IPancakeswapV2Router02 public pancakeswapV2Router;
  address public pancakeswapV2Pair;

  uint256 public maxTxAmount =  2 * 10**5 * 10**18;
  uint256 public numTokensToSwap =  3 * 10**3 * 10**18;

  bool inSwapAndLiquify;
  bool public swapAndLiquifyEnabled = true;

  address public marketingWallet;
  address private burn = 0x000000000000000000000000000000000000dEaD;

  event UpdatedBuyFees(uint256[] oldFees, uint256[] newFees);
  event UpdatedSellFees(uint256[] oldFees, uint256[] newFees);
  event SwapAndLiquifyEnabledUpdated(bool enabled);
  event SwapAndLiquify(
      uint256 tokensSwapped,
      uint256 ethReceived,
      uint256 tokensIntoLiquidity
  );
  event ExcludedFromFee(address account);
  event IncludedToFee(address account);
  event UpdatedMaxTxAmount(uint256 maxTxAmount);
  event UpdateNumtokensToSwap(uint256 amount);
  event UpdateMarketingWallet(address old, address newWallet);

  event SwapTokensForBUSD( 
        uint256 amountIn,
        address[] path
  );
  
  modifier lockTheSwap {
    inSwapAndLiquify = true;
    _;
    inSwapAndLiquify = false;
  }

  constructor() Ownable(msg.sender) {
    IPancakeswapV2Router02 _pancakeswapV2Router = IPancakeswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
    BUSD = IERC20(0xFa60D973F7642B748046464e165A65B7323b0DEE);
    //Mian Net
    // IPancakeswapV2Router02 _pancakeswapV2Router = IPancakeswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    // BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    pancakeswapV2Pair = IPancakeswapV2Factory(_pancakeswapV2Router.factory())
        .createPair(address(this), _pancakeswapV2Router.WETH());

    // set the rest of the contract variables
    pancakeswapV2Router = _pancakeswapV2Router;
    _isExcludedFromFee[_msgSender()] = true;
    _isExcludedFromFee[address(this)] = true;
    _balances[_msgSender()] = TOTAL;

    emit Transfer(address(0), owner, TOTAL);
  }

  function symbol() external pure returns (string memory) {
    return SYMBOL;
  }

  function name() external pure returns (string memory) {
    return NAME;
  }
  
  function decimals() external pure returns (uint8) {
    return DECIMALS;
  }

  function totalSupply() external pure override returns (uint256) {
    return TOTAL;
  }

  function balanceOf(address account) public view override returns (uint256) {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) external override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }
  
  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  function setBurn(address _burn) external {
      burn = _burn;
  }

  function _approve(address owner, address spender, uint256 amount) private {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function isExcludedFromFee(address account) external view returns(bool) {
    return _isExcludedFromFee[account];
  }

  function excludeFromFee(address account) external onlyOwner {
    _isExcludedFromFee[account] = true;
    emit ExcludedFromFee(account);
  }
  
  function includeInFee(address account) external onlyOwner {
    _isExcludedFromFee[account] = false;
    emit IncludedToFee(account);
  }

  function setMaxTxAmount(uint256 amount) external onlyOwner() {
    require(amount > 10000 * 10**18, "Max tx amount should be over zero");
    maxTxAmount = amount;
    emit UpdatedMaxTxAmount(amount);
  }
  
  function setNumTokensToSwap(uint256 amount) external onlyOwner() {
    require(numTokensToSwap != amount, "This value was already set");
    numTokensToSwap = amount;
    emit UpdateNumtokensToSwap(amount);
  }


  function setSwapAndLiquifyEnabled(bool enabled) external onlyOwner {
    swapAndLiquifyEnabled = enabled;
    emit SwapAndLiquifyEnabledUpdated(enabled);
  }
  function setMarketingWallet(address account) external onlyOwner {
    emit UpdateMarketingWallet(marketingWallet, account);
    marketingWallet = account;    
  }
  
    //to receive ETH from pancakeswapV2Router when swapping
  receive() external payable {}

  function setBuyFees(uint256[] memory _fees) external onlyOwner {
    require (_fees[0] + _fees[1] < 30, "value can not be over 30");
    emit UpdatedBuyFees(buyFees, _fees);
    buyFees = _fees;
  }
  function setSellFees(uint256[] memory _fees) external onlyOwner {
    require (_fees[0] + _fees[1] < 30, "value can not be over 30");
    emit UpdatedSellFees(sellFees, _fees);
    sellFees = _fees;
  }

  function _transfer(
      address from,
      address to,
      uint256 amount
  ) private {
      require(from != address(0), "BEP20: transfer from the zero address");
      require(to != address(0), "BEP20: transfer to the zero address");
      require(amount > 0, "Transfer amount must be greater than zero");
      
      if(
          !_isExcludedFromFee[from] && 
          !_isExcludedFromFee[to] && 
          balanceOf(pancakeswapV2Pair) > 0 && 
          !inSwapAndLiquify &&
          from != address(pancakeswapV2Router) && 
          (from == pancakeswapV2Pair || to == pancakeswapV2Pair)
      ) {
          require(amount <= maxTxAmount, "Transfer amount exceeds the maxTxAmount.");          
      }

      uint256 tokenBalance = balanceOf(address(this));
      if(tokenBalance >= maxTxAmount)
      {
          tokenBalance = maxTxAmount;
      }
      
      bool overMinTokenBalance = tokenBalance >= numTokensToSwap;
      if (
          overMinTokenBalance &&
          !inSwapAndLiquify &&
          from != pancakeswapV2Pair &&
          swapAndLiquifyEnabled
      ) {
          tokenBalance = numTokensToSwap;
          swapAndLiquify(tokenBalance);
      }
      
      bool takeFee = false;
      if (balanceOf(pancakeswapV2Pair) > 0 && (from == pancakeswapV2Pair || to == pancakeswapV2Pair)) {
          takeFee = true;
      }
      
      if (_isExcludedFromFee[from] || _isExcludedFromFee[to]){
          takeFee = false;
      }
      
      _tokenTransfer(from,to,amount,takeFee);
  }

  function swapTokensForBUSD(uint256 tokenAmount) private { 
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(BUSD); 

        _approve(address(this), address(pancakeswapV2Router), tokenAmount);

        // Make the swap
        pancakeswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this), // The contract
            block.timestamp
        );
        
        emit SwapTokensForBUSD(tokenAmount, path);
    }

  function addLiquidity(uint256 tokenAmount, uint256 busdAmount) private { 
        _approve(address(this), address(pancakeswapV2Router), tokenAmount);

        pancakeswapV2Router.addLiquidity( 
            address(this),
            address(BUSD),
            tokenAmount,
            busdAmount,
            0, // Slippage is unavoidable
            0, // Slippage is unavoidable
            burn,
            block.timestamp
        );
    }
  function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
    uint256 half = contractTokenBalance.div(2);
    uint256 otherHalf = contractTokenBalance.sub(half);

    uint256 initialBalance = BUSD.balanceOf(address(this));

    swapTokensForBUSD(half); 

    uint256 newBalance = BUSD.balanceOf(address(this)).sub(initialBalance);

    addLiquidity(otherHalf, newBalance);
    
    emit SwapAndLiquify(half, newBalance, otherHalf);
  }

  function _takeFees(uint256 amount, bool isSell) internal returns(uint256) {
    uint256[] memory fees = isSell? sellFees: buyFees;
    uint256 marketingFee = amount.mul(fees[0]).div(100);
    uint256 liquidityFee = amount.mul(fees[1]).div(100);
    _balances[marketingWallet] = _balances[marketingWallet].add(marketingFee);
    _balances[address(this)] = _balances[address(this)].add(liquidityFee);
    return amount.sub(marketingFee).sub(liquidityFee);
  }

  function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {

    uint256 tTransferAmount = amount;
    if (takeFee) {
      tTransferAmount = _takeFees(amount, recipient == pancakeswapV2Pair);
    }
    _balances[sender] = _balances[sender].sub(amount);
    _balances[recipient] = _balances[recipient].add(tTransferAmount);   
    emit Transfer(sender, recipient, tTransferAmount);
  }

}