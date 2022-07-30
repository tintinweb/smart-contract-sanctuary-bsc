/**
 *Submitted for verification at BscScan.com on 2022-07-30
*/

// SPDX-License-Identifier: MIT

pragma solidity =0.8.11;

// import "hardhat/console.sol";

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


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }
    
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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


abstract contract Ownable is Context {
    address internal _owner;
    // address private _previousOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }
    
    function owner() public view virtual returns (address) {
        return _owner;
    }
    
    modifier onlyOwner() {
        require(owner() == _msgSender(), "");
        _;
    }
    
    // function renounceOwnership() public virtual onlyOwner {
    //     emit OwnershipTransferred(_owner, address(0));
    //     _owner = address(0);
    // }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface IUniswapV2Factory {
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


interface IUniswapV2Pair {
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
    event Mint(address indexed sender, uint amount0, uint amount1);
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
    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
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


interface IUniswapV2Router02 is IUniswapV2Router01 {
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


abstract contract Jackpot_LiquidityTokenBaseMixin is Context, IERC20, Ownable {
  bool internal inSwapAndLiquify;
  bool public swapAndLiquifyEnabled = true;
  uint256 public numTokensSellToAddToLiquidity;

  uint256 public constant TOKEN_DECIMALS = 18;

  uint256 internal totalTokens = 1_000_000 * 10 ** TOKEN_DECIMALS;
  mapping (address => uint256) internal balances;
  mapping (address => mapping (address => uint256)) internal allowances;
  mapping (address => bool) internal isExcludedFromFee;
  
  event SwapAndLiquify(
    uint256 tokensSwapped,
    uint256 ethReceived,
    uint256 tokensIntoLiqudity
  );
  
  modifier lockTheSwap {
    inSwapAndLiquify = true;
    _;
    inSwapAndLiquify = false;
  }

  IUniswapV2Router02 public uniswapV2Router;
  address public uniswapV2Pair;

  constructor(address _uniswapV2RouterAddress) {
    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_uniswapV2RouterAddress); // pancakeswap v2 mainnet

    uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
    uniswapV2Router = _uniswapV2Router;
  }

  function setNumTokensSellToAddToLiquidity(uint256 amountToUpdate) external onlyOwner {
    require(amountToUpdate >= totalTokens/1_000_000, "too small amount");
    numTokensSellToAddToLiquidity = amountToUpdate;
  }

  // 1) Owner can't change router address, it may cause to pause sell trading
  // commented out. although if the pair already exists on another router, the new method will fail. is it okay ?
  // function setRouterAddress(address newRouter) external onlyOwner {
  //   uniswapV2Router = IUniswapV2Router02(newRouter);
  // }

  function setRouterAddress(address newRouter) external onlyOwner {
    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(newRouter);
    uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
    uniswapV2Router = _uniswapV2Router;
  }

  event SwapAndLiquifyEnabledUpdated(bool enabled);
  function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
    swapAndLiquifyEnabled = _enabled;
    emit SwapAndLiquifyEnabledUpdated(_enabled);
  }

  function _swapTokensForBnb(uint256 _tokenAmount) internal {
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = uniswapV2Router.WETH();
    _approve(address(this), address(uniswapV2Router), _tokenAmount);
    uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
      _tokenAmount,
      0, // accept any amount of ETH
      path,
      address(this),
      block.timestamp
    );
  }

  function _addLiquidity(uint256 _tokenAmount, uint256 _ethAmount) internal {
    _approve(address(this), address(uniswapV2Router), _tokenAmount);
    uniswapV2Router.addLiquidityETH{value: _ethAmount}(
      address(this),
      _tokenAmount,
      0, // slippage is unavoidable
      0, // slippage is unavoidable
      0x000000000000000000000000000000000000dEaD,
      block.timestamp
    );
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");

    allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function _transferBasic(address sender, address recipient, uint256 amount) internal {
    require(balances[sender] - amount >= 0, "Can't go lower than 0");
    balances[sender] -= amount;
    balances[recipient] += amount;

    emit Transfer(sender, recipient, amount);
  }

  function excludeFromFee(address account) public onlyOwner {
    isExcludedFromFee[account] = true;
  }
  
  function includeInFee(address account) public onlyOwner {
    isExcludedFromFee[account] = false;
  }

  function isExcluded(address account) public view returns(bool) {
    return isExcludedFromFee[account];
  }
}


contract Jackpot_TaxesAndWalletsMixin is Ownable {
  using Address for address;

  // wallets
  address payable private devWalletAddress;
  address payable private marketingWalletAddress;
  address payable private buybackWalletAddress;
  address private earnPoolAddress;
  address private stakingAddress;

  constructor (address payable _devWalletAddress, address payable _marketingWalletAddress, address payable _buybackWalletAddress, address _earnPoolAddress, address _stakingAddress) {
    devWalletAddress = _devWalletAddress;
    marketingWalletAddress = _marketingWalletAddress;
    buybackWalletAddress = _buybackWalletAddress;
    earnPoolAddress = _earnPoolAddress;
    stakingAddress = _stakingAddress;
  }

  event DevWalletChanged(address indexed from, address indexed to);
  event MarketingWalletChanged(address indexed from, address indexed to);
  event BuybackWalletChanged(address indexed from, address indexed to);
  event EarnPoolAddressChanged(address indexed from, address indexed to);
  event StakingAddressChanged(address indexed from, address indexed to);

  function devWallet() public view returns (address payable) { return devWalletAddress; }
  function marketingWallet() public view returns (address payable) { return marketingWalletAddress; }
  function buybackWallet() public view returns (address payable) { return buybackWalletAddress; }
  function earnPoolWallet() public view returns (address) { return earnPoolAddress; }
  function stakingWallet() public view returns (address) { return stakingAddress; }

  function setDevWalletAddress(address payable _devWalletAddress) public virtual onlyOwner {
    require(_devWalletAddress != address(0), "You must supply a non-zero address");
    emit DevWalletChanged(devWalletAddress, _devWalletAddress);
    devWalletAddress = _devWalletAddress;
  }

  function setMarketingWalletAddress(address payable _marketingWalletAddress) public virtual onlyOwner {
    require(_marketingWalletAddress != address(0), "You must supply a non-zero address");
    emit MarketingWalletChanged(marketingWalletAddress, _marketingWalletAddress);
    marketingWalletAddress = _marketingWalletAddress;
  }

  function setBuybackWallet(address payable _buybackWalletAddress) public virtual onlyOwner {
    require(_buybackWalletAddress != address(0), "You must supply a non-zero address");
    require(!address(_buybackWalletAddress).isContract(), "Shouldn't be a contract");
    emit BuybackWalletChanged(buybackWalletAddress, _buybackWalletAddress);
    buybackWalletAddress = _buybackWalletAddress;
  }

  function setEarnPoolAddress(address payable _earnPoolAddress) public virtual onlyOwner {
    require(_earnPoolAddress != address(0), "You must supply a non-zero address");
    emit EarnPoolAddressChanged(earnPoolAddress, _earnPoolAddress);
    earnPoolAddress = _earnPoolAddress;
  }

  function setStakingAddress(address payable _stakingAddress) public virtual onlyOwner {
    require(_stakingAddress != address(0), "You must supply a non-zero address");
    emit StakingAddressChanged(stakingAddress, _stakingAddress);
    stakingAddress = _stakingAddress;
  }

  // Fees
  struct Fee {
    uint256 jackpotFee;
    uint256 earnPoolFee;
    uint256 stakingFee;
    uint256 marketingFee;
    uint256 devFee;
    uint256 liquidityFee;  
  }

  Fee public buyFee = Fee({
    jackpotFee: 400,
    earnPoolFee: 0,
    stakingFee: 0,
    marketingFee: 200,
    devFee: 100,
    liquidityFee: 0
  });

  Fee public sellFee = Fee({
    jackpotFee: 400,
    earnPoolFee: 200,
    stakingFee: 100,
    marketingFee: 300,
    devFee: 200,
    liquidityFee: 200
  });

  Fee public noFee = Fee({
    jackpotFee: 0,
    earnPoolFee: 0,
    stakingFee: 0,
    marketingFee: 0,
    devFee: 0,
    liquidityFee: 0
  });

  event BuyFeesChanged(uint256 jackpotFee, uint256 earnPoolFee, uint256 stakingFee, uint256 marketingFee, uint256 devFee, uint256 liquidityFee);
  function setBuyFees(uint256 _jackpotFee, uint256 _earnPoolFee, uint256 _stakingFee, uint256 _marketingFee, uint256 _devFee, uint256 _liquidityFee) public onlyOwner
  {
    require(_jackpotFee + _marketingFee + _devFee + _liquidityFee + _earnPoolFee + _stakingFee <= 2000, "Maximum fees are 20%");
    buyFee = Fee({
      jackpotFee: _jackpotFee,
      earnPoolFee: _earnPoolFee,
      stakingFee: _stakingFee,
      marketingFee: _marketingFee,
      devFee: _devFee,
      liquidityFee: _liquidityFee
    });
    emit BuyFeesChanged(_jackpotFee, _earnPoolFee, _stakingFee, _marketingFee, _devFee, _liquidityFee);
  }

  event SellFeesChanged(uint256 jackpotFee, uint256 earnPoolFee, uint256 stakingFee, uint256 marketingFee, uint256 devFee, uint256 liquidityFee);
  function setSellFees(uint256 _jackpotFee, uint256 _earnPoolFee, uint256 _stakingFee, uint256 _marketingFee, uint256 _devFee, uint256 _liquidityFee) public onlyOwner
  {
    require(_jackpotFee + _marketingFee + _devFee + _liquidityFee + _earnPoolFee + _stakingFee <= 2000, "Maximum fees are 20%");
    sellFee = Fee({
      jackpotFee: _jackpotFee,
      earnPoolFee: _earnPoolFee,
      stakingFee: _stakingFee,
      marketingFee: _marketingFee,
      devFee: _devFee,
      liquidityFee: _liquidityFee
    });
    emit SellFeesChanged(_jackpotFee, _earnPoolFee, _stakingFee, _marketingFee, _devFee, _liquidityFee);
  }

  function getBuyTax() public view returns (uint256) {
      return buyFee.jackpotFee + buyFee.earnPoolFee + buyFee.stakingFee + buyFee.marketingFee + buyFee.devFee + buyFee.liquidityFee;
  }

  function getSellTax() public view returns (uint256) {
    return sellFee.jackpotFee + sellFee.earnPoolFee + sellFee.stakingFee + sellFee.marketingFee + sellFee.devFee + sellFee.liquidityFee;
  }
  
  // Excludable
  
}

contract Jackpot_SettingsMixin is Ownable {
  uint256 constant BNB_DECIMALS = 18;

  struct JackpotSettings {
    uint256 timespan;
    uint256 cashoutPercentage;
    uint256 minBuy;
    uint256 overflowPercentage; // 50% of jackpot value is sent to buyback wallet
    uint256 overflowBNB;
    uint256 activeThresholdBNB;
  }

  JackpotSettings public jackpotSettings = JackpotSettings({
    timespan: 600, // 10 minutes
    cashoutPercentage: 2000, // 20%
    minBuy: 1 * 10**(BNB_DECIMALS - 1), // 0.1 BNB
    overflowPercentage: 5000, // 50%
    overflowBNB: 50 * 10**(BNB_DECIMALS), // 50 BNB
    activeThresholdBNB: 25 * 10**(BNB_DECIMALS) // 25 BNB
  });

  //
  // JackpotSettings public jackpotSettings = JackpotSettings({
  //   timespan: 60, // 1 minutes
  //   cashoutPercentage: 2000, // 20%
  //   minBuy: 1 * 10**(BNB_DECIMALS - 2), // 0.01 BNB
  //   overflowPercentage: 5000, // 50%
  //   overflowBNB: 1 * 10**(BNB_DECIMALS), // 1 BNB
  //   activeThresholdBNB: 1 * 10**(BNB_DECIMALS - 1) // 0.1 BNB
  // });


  uint256 private constant JACKPOT_TIMESPAN_MIN = 30; // seconds
  uint256 private constant JACKPOT_TIMESPAN_MAX = 1200; // seconds
  
  event JackpotTimespanChanged(uint256 jackpotTimespan);
  function setJackpotTimespanInSeconds(uint256 _jackpotTimespan) external onlyOwner {
    require(_jackpotTimespan >= JACKPOT_TIMESPAN_MIN && _jackpotTimespan <= JACKPOT_TIMESPAN_MAX, "Jackpot timespan needs to be between 30 and 1200 seconds (20 minutes)");
    jackpotSettings.timespan = _jackpotTimespan;
    emit JackpotTimespanChanged(_jackpotTimespan);
  }

  // Jackpot cashout percentage
  uint256 private constant JACKPOT_CASHOUT_PERCENTAGE_MIN = 1000; // 10%
  uint256 private constant JACKPOT_CASHOUT_PERCENTAGE_MAX = 9000; // 90%

  // Minimum buy
  uint256 private constant JACKPOT_MINBUY_MIN = 5 * 10**(BNB_DECIMALS - 2); // minimum 0.05 BNB
  uint256 private constant JACKPOT_MINBUY_MAX = 5 * 10**(BNB_DECIMALS - 1); // maximum 0.50 BNB

  event JackpotFeaturesChanged(uint256 jackpotCashoutPercentage, uint256 jackpotMinBuy);
  function setJackpotFeatures(uint256 _jackpotCashoutPercentage, uint256 _jackpotMinBuy) external onlyOwner {
    require(_jackpotCashoutPercentage >= JACKPOT_CASHOUT_PERCENTAGE_MIN && _jackpotCashoutPercentage <= JACKPOT_CASHOUT_PERCENTAGE_MAX, "Jackpot cashout percentage needs to be between 10% and 90%");
    require(_jackpotMinBuy >= JACKPOT_MINBUY_MIN && _jackpotMinBuy <= JACKPOT_MINBUY_MAX, "Jackpot min buy needs to be between 0.05 and 0.5 BNB");
    jackpotSettings.cashoutPercentage = _jackpotCashoutPercentage;
    jackpotSettings.minBuy = _jackpotMinBuy;

    emit JackpotFeaturesChanged(_jackpotCashoutPercentage, _jackpotMinBuy);
  }

  // this is the amount above which the jackpot is concidered overflown, and should be dumped into chart
  uint256 private constant JACKPOT_OVERFLOW_BNB_MIN = 10 * 10**(BNB_DECIMALS); // 10 BNB
  uint256 private constant JACKPOT_OVERFLOW_BNB_MAX = 250 * 10**(BNB_DECIMALS); // 250 BNB

  // this is the amount above which the jackpot is active
  uint256 private constant JACKPOT_ACTIVE_THRESHOLD_MIN = 5 * 10**(BNB_DECIMALS); // minimum 5 BNB
  uint256 private constant JACKPOT_ACTIVE_THRESHOLD_MAX = 100 * 10**(BNB_DECIMALS); // maximum 100 BNB

  event JackpotOverflowChanged(uint256 jackpotOverflowBNB, uint256 jackpotActiveThreshold);
  function setJackpotOverflowFeatures(uint256 _jackpotOverflowBNB, uint256 _jackpotActiveThresholdBNB) external onlyOwner {
    require(_jackpotOverflowBNB >= JACKPOT_OVERFLOW_BNB_MIN && _jackpotOverflowBNB <= JACKPOT_OVERFLOW_BNB_MAX, "Jackpot overflow percentage needs to be between 10 to 100 BNB");
    require(_jackpotActiveThresholdBNB >= JACKPOT_ACTIVE_THRESHOLD_MIN && _jackpotActiveThresholdBNB <= JACKPOT_ACTIVE_THRESHOLD_MAX, "Jackpot min buy needs to be between 10 and 50 BNB");
    jackpotSettings.overflowBNB = _jackpotOverflowBNB;
    jackpotSettings.activeThresholdBNB = _jackpotActiveThresholdBNB;

    emit JackpotFeaturesChanged(_jackpotOverflowBNB, _jackpotActiveThresholdBNB);
  }
}

contract Jackpot_WinningPoolMixin {
  struct MixedBalance {
    uint256 bnb;
    uint256 tokens;
  }
  
  struct LastOverflowStats {
    uint256 bnb;
    uint256 tokens;
    uint256 timestamp;
    uint256 blockNumber;
  }

  struct LastJackpotAwarded {
    uint256 bnb;
    uint256 tokens;
    address winner;
    uint256 timestamp;
    uint256 blockNumber;
  }

  struct LastBuyInfo {
    address payable addr;
    uint256 timestamp;
    uint256 blockNumber;
  }

  struct JackpotInfo {
    MixedBalance pendingAmount;
    MixedBalance totalCashedOut;
    MixedBalance totalBuyBack;
    LastOverflowStats lastOverflowStats;
    LastJackpotAwarded lastJackpotAwarded;
    LastBuyInfo lastBuyInfo;
  }

  function _subJackpot(JackpotInfo storage _jackpotInfo, uint256 _bnbValue, uint256 _tokenValue) internal 
  {
    // subtracting current jackpot
    _jackpotInfo.pendingAmount.bnb -= _bnbValue;
    _jackpotInfo.pendingAmount.tokens -= _tokenValue;

    // increasing jackpot total cashed out values
    _jackpotInfo.totalCashedOut.bnb += _bnbValue;
    _jackpotInfo.totalCashedOut.tokens += _tokenValue;

    // increasing jackpot buyback values
    _jackpotInfo.totalBuyBack.bnb += _bnbValue;
    _jackpotInfo.totalBuyBack.tokens += _tokenValue;
  }
}


abstract contract Jackpot_AwardableMixin is Ownable, Jackpot_TaxesAndWalletsMixin, Jackpot_LiquidityTokenBaseMixin, Jackpot_SettingsMixin, Jackpot_WinningPoolMixin {
  event JackpotAwarded(uint256 timestamp, address winner, uint256 bnbValue, uint256 tokenValue);
  function _emitJackpotAwarded(JackpotInfo storage _jackpotInfo, address payable winner, uint256 _bnbValue, uint256 _tokenValue) private {
    
    _jackpotInfo.lastJackpotAwarded.winner = winner;
    _jackpotInfo.lastJackpotAwarded.timestamp = _jackpotInfo.lastBuyInfo.timestamp;
    _jackpotInfo.lastJackpotAwarded.blockNumber = _jackpotInfo.lastBuyInfo.blockNumber;
    _jackpotInfo.lastJackpotAwarded.bnb = _bnbValue;
    _jackpotInfo.lastJackpotAwarded.tokens = _tokenValue;
    emit JackpotAwarded(_jackpotInfo.lastJackpotAwarded.timestamp, _jackpotInfo.lastJackpotAwarded.winner, _bnbValue, _tokenValue);
  }

  function _isJackpotActive(JackpotInfo storage _jackpotInfo, JackpotSettings memory _jackpotSettings) internal view returns (bool) {
    if (_jackpotInfo.pendingAmount.bnb >= _jackpotSettings.activeThresholdBNB){
      return true;
    } else {
      return false;
    }
  }

  function _isJackpotEligible(JackpotSettings storage _jackpotSettings, uint256 tokensAmount) internal view returns (bool) { // todo: check pure vs view
    if (_jackpotSettings.minBuy == 0) {
      return true;
    }
    address[] memory path = new address[](2);
    path[0] = uniswapV2Router.WETH();
    path[1] = address(this);

    uint256 tokensOut = uniswapV2Router.getAmountsOut(_jackpotSettings.minBuy, path)[1] * (10000 - 25) / 10000; // 25 is router fee
    return tokensAmount >= tokensOut;
  }

  function _awardJackpot(JackpotInfo storage _jackpotInfo, address payable winner, uint256 _jackpotCashout) internal lockTheSwap {
    require(_jackpotInfo.lastBuyInfo.addr != address(0) && _jackpotInfo.lastBuyInfo.addr != address(this), "No last buyer detected");

    uint256 bnbForBuyer = _jackpotInfo.pendingAmount.bnb * _jackpotCashout / 10000;
    uint256 tokensForBuyer = _jackpotInfo.pendingAmount.tokens * _jackpotCashout / 10000;

    _subJackpot(_jackpotInfo, bnbForBuyer, tokensForBuyer);
    _emitJackpotAwarded(_jackpotInfo, winner, bnbForBuyer, tokensForBuyer);

    _jackpotInfo.lastBuyInfo.addr = payable(address(0));
    _jackpotInfo.lastBuyInfo.timestamp = 0;
    _jackpotInfo.lastBuyInfo.blockNumber = block.number;

    _transferBasic(address(this), _jackpotInfo.lastBuyInfo.addr, tokensForBuyer);
    payable(_jackpotInfo.lastBuyInfo.addr).transfer(bnbForBuyer);
  }
}


abstract contract Jackpot_OverflowableMixin is Ownable, Jackpot_TaxesAndWalletsMixin, Jackpot_LiquidityTokenBaseMixin, Jackpot_SettingsMixin, Jackpot_WinningPoolMixin {
  event Overflow(uint256 timestamp, uint256 bnb, uint256 tokens);

  function _emitOverflow(JackpotInfo storage _jackpotInfo, uint256 _bnbValue, uint256 _tokenValue) private {
    _jackpotInfo.lastOverflowStats.bnb = _bnbValue;
    _jackpotInfo.lastOverflowStats.tokens = _tokenValue;
    _jackpotInfo.lastOverflowStats.timestamp = block.timestamp;
    _jackpotInfo.lastOverflowStats.blockNumber = block.number;
    emit Overflow(_jackpotInfo.lastOverflowStats.timestamp, _bnbValue, _tokenValue);
  }

  function _processOverflow(JackpotInfo storage _jackpotInfo, uint256 _jackpotOverflowPercentage) internal lockTheSwap { // 
    uint256 bnbForBuyback = _jackpotInfo.pendingAmount.bnb * _jackpotOverflowPercentage / 10000;
    uint256 tokensForBuyback = _jackpotInfo.pendingAmount.tokens * _jackpotOverflowPercentage / 10000;

    _subJackpot(_jackpotInfo, bnbForBuyback, tokensForBuyback);
    _emitOverflow(_jackpotInfo, bnbForBuyback, tokensForBuyback);

    _transferBasic(address(this), buybackWallet(), tokensForBuyback);
    buybackWallet().transfer(bnbForBuyback);
  }
}


contract JackpotToken is Context, IERC20, Ownable, Jackpot_TaxesAndWalletsMixin, Jackpot_LiquidityTokenBaseMixin, Jackpot_SettingsMixin, Jackpot_OverflowableMixin, Jackpot_AwardableMixin {
  using Address for address;

  uint256 public constant BUSD_DECIMALS = 18;

  uint256 private constant LIQ_SWAP_THRESH = 10 ** (TOKEN_DECIMALS);

  string private tokenName = "ChatAndEarn";
  string private tokenSymbol = "C2E";

  JackpotInfo public jackpotInfo;
  struct DevMarketingInfo {
    uint256 liquidityTokens;
    MixedBalance marketingBalance;
    MixedBalance marketingCollected;
    MixedBalance devBalance;
    MixedBalance devCollected;  
  }
  DevMarketingInfo public devMarketingInfo;

  event MarketingFeesCollected(uint256 bnb);
  function collectMarketingFees() public onlyOwner {
      devMarketingInfo.marketingCollected.bnb += devMarketingInfo.marketingBalance.bnb;
      devMarketingInfo.marketingBalance.bnb = 0;
      marketingWallet().transfer(devMarketingInfo.marketingBalance.bnb);
      emit MarketingFeesCollected(devMarketingInfo.marketingBalance.bnb);
  }

  event DevFeesCollected(uint256 bnb);
  function collectDevFees() public onlyOwner {
      devMarketingInfo.devCollected.bnb += devMarketingInfo.devBalance.bnb;
      devMarketingInfo.devBalance.bnb = 0;
      devWallet().transfer(devMarketingInfo.devBalance.bnb);
      emit DevFeesCollected(devMarketingInfo.devBalance.bnb);
  }
  
  constructor (address payable _devWalletAddress, address payable _marketingWalletAdress, address payable _buybackWalletAddress, address _earnPoolAddress, address _stakingAddress, address _uniswapV2RouterAddress) payable
  Jackpot_TaxesAndWalletsMixin(_devWalletAddress, _marketingWalletAdress, _buybackWalletAddress, _earnPoolAddress, _stakingAddress)
  Jackpot_LiquidityTokenBaseMixin(_uniswapV2RouterAddress)
  {
    numTokensSellToAddToLiquidity = (totalTokens * 5 / 10000) * 10 ** TOKEN_DECIMALS;

    // 0x4c3bDdb06F18f5871F604369Ca669284f7920825 // dev
    // 0x483dB610324532F92954f35632e736a95DD5212D // marketing
    // 0x5353e5Dd3077c2d4384306674Ba9Ce48A0962A8c // buyback
    // 0x10ED43C718714eb63d5aA57B78B54704E256024E; // pancakeswap v2 router mainnet
    // 0xD99D1c33F9fC3444f8101754aBC46c52416550D1; // pancakeswap v2 router testnet
    // 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; // pancakeswap v2 router testnet - with ui
    // 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // uniswap
    
    isExcludedFromFee[msg.sender] = true;
    isExcludedFromFee[address(this)] = true;
    
    _owner = msg.sender;
    balances[msg.sender] = totalTokens;
    emit Transfer(address(0), msg.sender, totalTokens);
  }

  function name() public view returns (string memory) {
    return tokenName;
  }

  function symbol() public view returns (string memory) {
    return tokenSymbol;
  }

  function decimals() public pure returns (uint256) {
    return TOKEN_DECIMALS;
  }

  function totalSupply() public view override returns (uint256) {
    return totalTokens;
  }

  function balanceOf(address account) public view override returns (uint256) {
    return balances[account];
  }

  function transfer(address recipient, uint256 amount) public override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) public view override returns (uint256) {
    return allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) public override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
    _transfer(sender, recipient, amount);
    require(allowances[sender][_msgSender()] >= amount, "ERC20: transfer amount exceeds allowance");
    _approve(sender, _msgSender(), allowances[sender][_msgSender()] - amount);
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
    _approve(_msgSender(), spender, allowances[_msgSender()][spender] + addedValue);
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
    require(allowances[_msgSender()][spender] >= subtractedValue, "ERC20: decreased allowance below zero");
    _approve(_msgSender(), spender, allowances[_msgSender()][spender] - subtractedValue);
    return true;
  }

  //to recieve ETH from uniswapV2Router when swaping
  receive() external payable {}

  // function isJackpotEligible(uint256 tokens) public view returns (bool) {
  //   return _isJackpotEligible(jackpotSettings, tokens);
  // }

  // function isJackpotActive() public view returns (bool) {
  //   return _isJackpotActive(jackpotInfo, jackpotSettings);
  // }

  function _transfer(address from, address to, uint256 amount) private {
    require(from != address(0), "ERC20: transfer from the zero address");
    require(to != address(0), "ERC20: transfer to the zero address");
    require(amount > 0, "Transfer amount must be greater than zero");

    if (!inSwapAndLiquify && jackpotInfo.pendingAmount.bnb >= jackpotSettings.overflowBNB) {
      _processOverflow(jackpotInfo, jackpotSettings.overflowPercentage);
    } else if (
      _isJackpotActive(jackpotInfo, jackpotSettings) &&
      !inSwapAndLiquify &&
      jackpotInfo.lastBuyInfo.addr != address(0) &&
      jackpotInfo.lastBuyInfo.addr != address(this) &&
      (block.timestamp - jackpotInfo.lastBuyInfo.timestamp >= jackpotSettings.timespan)
    ) {
      _awardJackpot(jackpotInfo, jackpotInfo.lastBuyInfo.addr, jackpotSettings.cashoutPercentage);
    }

    uint256 contractTokenBalance = balanceOf(address(this));
    
    bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
    if (
      !inSwapAndLiquify &&
      swapAndLiquifyEnabled &&
      overMinTokenBalance && 
      from != uniswapV2Pair
      ) {
      _swapAndLiquify(contractTokenBalance);
    }
    
    bool takeFee = isExcludedFromFee[from] || isExcludedFromFee[to];

    if (uniswapV2Pair == from) {
      // console.log("checking isjackpot eligible, %s", amount);
      if (
        _isJackpotEligible(jackpotSettings, amount) 
        &&
        _isJackpotActive(jackpotInfo, jackpotSettings)
        &&
        !to.isContract()
      ) {
        jackpotInfo.lastBuyInfo.addr = payable(to);
        jackpotInfo.lastBuyInfo.timestamp = block.timestamp;
      }
      _tokenTransfer(from, to, amount, takeFee ? noFee : buyFee);
    } else if (uniswapV2Pair == to) {
      _tokenTransfer(from, to, amount, takeFee ? noFee : sellFee );
    } else {
      _tokenTransfer(from, to, amount, noFee);
    }
  }
  
  function _tokenTransfer(address _sender, address _recipient, uint256 _amount, Fee memory _fee) private {
    uint256 jackpotFeeAmount = _amount * _fee.jackpotFee / 10000;
    uint256 earnPoolFeeAmount = _amount * _fee.earnPoolFee / 10000;
    uint256 stakingFeeAmount = _amount * _fee.stakingFee / 10000;
    uint256 marketingFeeAmount = _amount * _fee.marketingFee / 10000;
    uint256 devFeeAmount = _amount * _fee.devFee / 10000;
    uint256 liquidityFeeAmount = _amount * _fee.liquidityFee / 10000;
    uint256 transferAmount = _amount - jackpotFeeAmount - earnPoolFeeAmount - stakingFeeAmount - marketingFeeAmount - devFeeAmount - liquidityFeeAmount;

    balances[_sender] -= _amount;
    balances[_recipient] += transferAmount;
    balances[earnPoolWallet()] += earnPoolFeeAmount;
    balances[stakingWallet()] += stakingFeeAmount;
    balances[address(this)] += jackpotFeeAmount + marketingFeeAmount + devFeeAmount + liquidityFeeAmount;

    devMarketingInfo.liquidityTokens += liquidityFeeAmount;
    devMarketingInfo.marketingBalance.tokens += marketingFeeAmount;
    devMarketingInfo.devBalance.tokens += devFeeAmount;
    jackpotInfo.pendingAmount.tokens += jackpotFeeAmount;

    emit Transfer(_sender, _recipient, transferAmount);
  }

  function getUsedTokens(uint256 accSum, uint256 tokenAmount, uint256 tokens) private pure returns (uint256, uint256) {
    if (accSum >= tokenAmount) {
      return (0, accSum);
    }
    uint256 available = tokenAmount - accSum;
    if (tokens <= available) {
      return (tokens, accSum + tokens);
    }
    return (available, accSum + available);
  }

  function getTokenShares(uint256 tokenAmount) private returns (uint256 liquidityToken, uint256 martketingTokens, uint256 devTokens, uint256 jackpotTokens)
  {
    uint256 accSum = 0;
    uint256 lt = 0;
    uint256 mt = 0;
    uint256 dt = 0;
    uint256 jt = 0;

    // Either 0 or 1+ to prevent PCS errors on liq swap
    if (devMarketingInfo.liquidityTokens >= LIQ_SWAP_THRESH) {
      (lt, accSum) = getUsedTokens(accSum, tokenAmount, devMarketingInfo.liquidityTokens);
      devMarketingInfo.liquidityTokens -= lt;
    }

    (mt, accSum) = getUsedTokens(accSum, tokenAmount, devMarketingInfo.marketingBalance.tokens);
    devMarketingInfo.marketingBalance.tokens -= mt;

    (dt, accSum) = getUsedTokens(accSum, tokenAmount, devMarketingInfo.devBalance.tokens);
    devMarketingInfo.devBalance.tokens -= dt;

    (jt, accSum) = getUsedTokens(accSum, tokenAmount, jackpotInfo.pendingAmount.tokens);
    jackpotInfo.pendingAmount.tokens -= jt;

    return (lt, mt, dt, jt);
  }

  function _swapAndLiquify(uint256 tokenAmount) private lockTheSwap {
    (uint256 liqTokens, uint256 marketingTokens, uint256 devTokens, uint256 jackpotTokens) = getTokenShares(tokenAmount);
    uint256 toBeSwapped = liqTokens + marketingTokens + devTokens + jackpotTokens;
    // This variable holds the liquidity tokens that won't be converted
    uint256 pureLiqTokens = liqTokens / 2;

    // Everything else from the tokens should be converted
    uint256 tokensForBnbExchange = toBeSwapped - pureLiqTokens;

    uint256 initialBalance = address(this).balance;
    _swapTokensForBnb(tokensForBnbExchange);

    // How many BNBs did we gain after this conversion?
    uint256 gainedBnb = address(this).balance - initialBalance;

    // Calculate the amount of BNB that's assigned to the marketing wallet
    uint256 balanceToMarketing = gainedBnb * marketingTokens / tokensForBnbExchange;
    devMarketingInfo.marketingBalance.bnb += balanceToMarketing;

    // Same for dev
    uint256 balanceToDev = gainedBnb * devTokens / tokensForBnbExchange;
    devMarketingInfo.devBalance.bnb += balanceToDev;

    // Same for Jackpot
    uint256 balanceToJackpot = gainedBnb * jackpotTokens / tokensForBnbExchange;
    jackpotInfo.pendingAmount.bnb += balanceToJackpot;

    uint256 remainingBnb = gainedBnb - balanceToMarketing - balanceToDev - balanceToJackpot;

    if (liqTokens >= LIQ_SWAP_THRESH) {
      // The leftover BNBs are purely for liquidity here
      // We are not guaranteed to have all the pure liq tokens to be transferred to the pair
      // This is because the uniswap router, PCS in this case, will make a quote based
      // on the current reserves of the pair, so one of the parameters will be fully
      // consumed, but the other will have leftovers.
      uint256 prevBalance = balanceOf(address(this));
      uint256 prevBnbBalance = address(this).balance;
      _addLiquidity(pureLiqTokens, remainingBnb);
      uint256 usedBnbs = prevBnbBalance - address(this).balance;
      uint256 usedTokens = prevBalance - balanceOf(address(this));
      // Reallocate the tokens that weren't used back to the internal liquidity tokens tracker
      if (usedTokens < pureLiqTokens) {
          devMarketingInfo.liquidityTokens += pureLiqTokens - usedTokens;
      }
      // Reallocate the unused BNBs to the pending marketing wallet balance
      if (usedBnbs < remainingBnb) {
          devMarketingInfo.marketingBalance.bnb += remainingBnb - usedBnbs;
      }

      emit SwapAndLiquify(tokensForBnbExchange, usedBnbs, usedTokens);
    } else {
      // We could have some dust, so we'll just add it to the pending marketing wallet balance
      devMarketingInfo.marketingBalance.bnb += remainingBnb;

      emit SwapAndLiquify(tokensForBnbExchange, 0, 0);
    }
  }

  function fundJackpot() payable public onlyOwner {
    require(msg.value > 0, "please send some money");
    jackpotInfo.pendingAmount.bnb += msg.value;
  }
}