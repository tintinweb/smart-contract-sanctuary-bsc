// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../uniswap/UniswapInterface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IUniswapOracle.sol";
import "./interfaces/IStaking.sol";
import "./interfaces/ICentralBank.sol";
import "./interfaces/IUSDB.sol";

contract USDBInterface is Ownable,UniswapInterface{
  address usdb;
  address staking;
  address bank;
  address oracle;
  mapping(address => bool) public stakingTokens;
  address[] public historyStakingTokens;
  address[] public reserveTokens;

  struct Reserve{
    address token;
    uint256 price;
    uint256 balance;
  }

  constructor(address _usdb,address _router, address _staking, address _bank,address _oracle) UniswapInterface(_router){
    usdb = _usdb;
    staking = _staking;
    bank = _bank;
    oracle = _oracle;
  }

  function setRouter(address _router) public onlyOwner{
    router = _router;
  }
  function setStaking(address _staking) public onlyOwner {
    staking = _staking;
  }
  function setBank(address _bank) public onlyOwner{
    bank = _bank;
  }
  function setOracle(address _oracle) public onlyOwner {
    oracle = _oracle;
  }

  function usdbPrice(address _otherToken) public view returns(uint256){
    IUniswapV2Pair pair = IUniswapV2Pair(getPair(_otherToken, usdb));
    (uint112 reserve0,uint112 reserve1,) = pair.getReserves();
    if(pair.token0() == usdb){
      return 1e18*reserve1/reserve0;
    }else{
      return 1e18*reserve0/reserve1;
    }
    // return uint256(IUniswapOracle(oracle).consult(usdb, 1e18, _otherToken));
  }

  function addStakingTokens(address[] memory _tokens) public onlyOwner{
    for (uint256 i = 0; i < _tokens.length; i++) {
      if(!stakingTokens[_tokens[i]]){
        historyStakingTokens.push(_tokens[i]);
        stakingTokens[_tokens[i]] = true;
      }
    }
  }
  function setReserveToken(address[] memory _tokens) public onlyOwner{
    reserveTokens = _tokens;
  }

  function tvl() public view returns(uint256){
    uint256 totalLockUSDB = 0;
    for (uint256 i = 0; i < historyStakingTokens.length; i++) {
      address pair = historyStakingTokens[i];
      PairInfo memory pairInfo = getReservesWithPair(pair, address(0));
      uint256 lockedLp = IStaking(staking).tokenLiquidityLocked(pair);
      if(pairInfo.totalSupply > 0){
        if(pairInfo.token0 == usdb){
          totalLockUSDB = totalLockUSDB + pairInfo.reserve0*lockedLp/pairInfo.totalSupply;
        }else{
          totalLockUSDB = totalLockUSDB + pairInfo.reserve1*lockedLp/pairInfo.totalSupply;
        }
      }
    }
    return totalLockUSDB;
  }

  function usdbMarketcap(address _oracleToken) public view returns(uint256){
    uint256 totalSupply = IUSDB(usdb).totalSupply();
    uint256 totalCap = totalSupply * usdbPrice(_oracleToken)/1e18;
    return totalCap;
  }

  function treasuryBalance() public view returns(Reserve[] memory){
    Reserve[] memory reserves = new Reserve[](reserveTokens.length);
    for (uint256 i = 0; i < reserveTokens.length; i++) {
      uint256 balance = IERC20(reserveTokens[i]).balanceOf(address(this));
      uint256 price;
      if(reserveTokens[i] == usdb){
        price = 1;
      }else{
        price = usdbPrice(reserveTokens[i]);
      }
      reserves[i] = Reserve(reserveTokens[i],balance,price);
    }
    return reserves;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./v2-periphery/interfaces/IUniswapV2Router02.sol";
import "./v2-core/interfaces/IUniswapV2Factory.sol";
import "./v2-core/interfaces/IUniswapV2Pair.sol";
import "./v2-core/interfaces/IERC20.sol";

pragma abicoder v2;

contract UniswapInterface is Ownable{
  address public router;

  struct PairInfo{
    address pair;
    address token0;
    address token1;
    uint112 reserve0;
    uint112 reserve1;
    uint    totalSupply;
    uint    balance;
    uint32  blockTimestampLast;
  }

  constructor(address _router){
    router = _router;
  }

  function getPair(address token0,address token1) public view returns(address){
     return IUniswapV2Factory(IUniswapV2Router02(router).factory()).getPair(token0, token1);
  }
  
  function getReservesWithPair(address _pair,address _owner) public view returns(PairInfo memory result){
    result.pair = _pair;
    if(_pair == address(0)){
      result.token0 = address(0);
      result.token1 = address(0);
      result.reserve0 = 0;
      result.reserve1 = 0;
      result.totalSupply = 0;
      result.balance = 0;
      result.blockTimestampLast = uint32(block.timestamp % 2**32);
    }else{
      result.token0 = IUniswapV2Pair(_pair).token0();
      result.token1 = IUniswapV2Pair(_pair).token1();
      (uint112 reserve0,uint112 reserve1,uint32 blockTimestampLast) = IUniswapV2Pair(_pair).getReserves();
      result.reserve0 = reserve0;
      result.reserve1 = reserve1;
      result.blockTimestampLast = blockTimestampLast;
      result.totalSupply = IUniswapV2Pair(_pair).totalSupply();
      result.balance = IUniswapV2Pair(_pair).balanceOf(_owner);
    }
  }

  function getReservesWithToken(address _token0, address _token1,address _owner) public view returns(PairInfo memory result){
    address pair = getPair(_token0, _token1);
    return getReservesWithPair(pair,_owner);
  }

  struct Call {
        address target;
        uint256 gasLimit;
        bytes callData;
    }

    struct Result {
        bool success;
        uint256 gasUsed;
        bytes returnData;
    }

    function getCurrentBlockTimestamp() public view returns (uint256 timestamp) {
        timestamp = block.timestamp;
    }

    function getEthBalance(address addr) public view returns (uint256 balance) {
        balance = addr.balance;
    }

    function multicall(Call[] memory calls) public returns (uint256 blockNumber, Result[] memory returnData) {
        blockNumber = block.number;
        returnData = new Result[](calls.length);
        for (uint256 i = 0; i < calls.length; i++) {
            (address target, uint256 gasLimit, bytes memory callData) =
                (calls[i].target, calls[i].gasLimit, calls[i].callData);
            uint256 gasLeftBefore = gasleft();
            (bool success, bytes memory ret) = target.call{gas: gasLimit}(callData);
            uint256 gasUsed = gasLeftBefore - gasleft();
            returnData[i] = Result(success, gasUsed, ret);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

pragma solidity ^0.8.4;

interface IUniswapOracle{
  function consult(address tokenIn, uint amountIn, address tokenOut) external view returns (uint amountOut);
  function update(address tokenA, address tokenB) external;
}

pragma solidity ^0.8.4;

interface IStaking{
  function tokenLiquidityLocked(address _token) external view returns(uint256);
  function catchUp(address _token, uint256 _amount, uint256 _nonce, uint256 _startAt, uint256 _endAt) external;
}

pragma solidity ^0.8.4;

interface ICentralBank {
  function claim(address staker, uint256 liquidityMultiplier, uint256 totalMultiplier) external returns(bool);
  // function swap(uint amountIn,uint amountOutMin,address[] calldata path,uint deadline) external;
  function catchUp() external;
}

pragma solidity ^0.8.4;

interface IUSDB {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function mint(address to, uint256 amount) external;

    function burn(uint256 amount) external;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    
}

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

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

pragma solidity >=0.5.0;

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

pragma solidity >=0.5.0;

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

pragma solidity >=0.5.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity >=0.6.2;

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