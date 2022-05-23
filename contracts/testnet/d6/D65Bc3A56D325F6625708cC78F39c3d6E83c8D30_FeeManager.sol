/**
 *Submitted for verification at BscScan.com on 2022-04-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IUniswapV2Factory {
  event PairCreated(address indexed token0, address indexed token1, address pair, uint256);
  function feeTo() external view returns (address);
  function feeToSetter() external view returns (address);
  function getPair(address tokenA, address tokenB) external view returns (address pair);
  function allPairs(uint256) external view returns (address pair);
  function allPairsLength() external view returns (uint256);
  function createPair(address tokenA, address tokenB) external returns (address pair);
  function setFeeTo(address) external;
  function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);
  function name() external pure returns (string memory);
  function symbol() external pure returns (string memory);
  function decimals() external pure returns (uint8);
  function totalSupply() external view returns (uint256);
  function balanceOf(address owner) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
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
  event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
  event Swap(address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out, address indexed to);
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
  function burn(address to) external returns (uint256 amount0, uint256 amount1);
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
  function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
  function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
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

library Address {
  function isContract(address account) internal view returns (bool) {
    bytes32 codehash;
    bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
    assembly {
      codehash := extcodehash(account)
    }
    return (codehash != accountHash && codehash != 0x0);
  }
  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, "Address: insufficient balance");
    // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
    (bool success, ) = recipient.call{value: amount}("");
    require(success, "Address: unable to send value, recipient may have reverted");
  }
  function functionCall(address target, bytes memory data) internal returns (bytes memory) {
    return functionCall(target, data, "Address: low-level call failed");
  }
  function functionCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal returns (bytes memory) {
    return _functionCallWithValue(target, data, 0, errorMessage);
  }
  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value
  ) internal returns (bytes memory) {
    return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
  }
  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value,
    string memory errorMessage
  ) internal returns (bytes memory) {
    require(address(this).balance >= value, "Address: insufficient balance for call");
    return _functionCallWithValue(target, data, value, errorMessage);
  }
  function _functionCallWithValue(
    address target,
    bytes memory data,
    uint256 weiValue,
    string memory errorMessage
  ) private returns (bytes memory) {
    require(isContract(target), "Address: call to non-contract");
    (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
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

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);
    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);
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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IAloraNode {
  function operatorFee() external view returns (uint32);
  function getAmountOut(uint256) external view returns (uint256);
  function claimTransfer(
    address from,
    address to,
    uint256 amount
  ) external;
}
contract FeeManager {
  // using SafeMath for uint256;
  IERC20 public token;
  IUniswapV2Router02 public router;
  address public treasury;
  address[] public operators;
  mapping(address => bool) private isOperator;
  uint256 public countOperator;
  uint32 public rateTransferFee;
  uint32 public rateRewardsPoolFee;
  uint32 public rateTreasuryFee;
  uint32 public rateOperatorFee;
  bool public enabledTransferETH;
  address public owner;
  address public manager;
  mapping(bytes32 => uint32) public rateUpgradeFee;
  uint32 public rateClaimFee;
  modifier onlyOwner() {
    require(owner == msg.sender, "FeeManager: caller is not the owner");
    _;
  }
  modifier onlyManager() {
    require(manager == msg.sender, "FeeManager: caller is not the manager");
    _;
  }
  constructor() {
    owner = msg.sender;
    rateTransferFee = 0;
    rateRewardsPoolFee = 7000;
    rateTreasuryFee = 2000;
    rateOperatorFee = 1000;
    rateClaimFee = 3000;
    enabledTransferETH = false;
  }
  // receive() external payable {}
//   function transferOwnership(address _owner) public onlyOwner {
//     require(_owner != address(0), "FeeManager: new owner is the zero address");
//     owner = _owner;
//   }
  function bindManager(address _manager) public onlyOwner {
    require(_manager != address(0), "FeeManager: new manager is the zero address");
    manager = _manager;
  }
  function setTreasury(address account) public onlyOwner {
    require(treasury != account, "The same account!");
    treasury = account;
  }
  function setOperator(address account) public onlyOwner {
    if (isOperator[account] == false) {
      operators.push(account);
      isOperator[account] = true;
      countOperator++;
    }
  }
  function enableTransferETH(bool _enabled) public onlyOwner {
    enabledTransferETH = _enabled;
  }
  function removeOperator(address account) public onlyOwner {
    if (isOperator[account] == true) {
      isOperator[account] = false;
      countOperator--;
    }
  }
  function setRateRewardsPoolFee(uint32 _rateRewardsPoolFee) public onlyOwner {
    require(rateOperatorFee + rateTreasuryFee + _rateRewardsPoolFee == 10000, "Total fee must be 100%");
    rateRewardsPoolFee = _rateRewardsPoolFee;
  }
  function setRateTreasuryFee(uint32 _rateTreasuryFee) public onlyOwner {
    require(rateTreasuryFee != _rateTreasuryFee, "The same value!");
    require(rateOperatorFee + _rateTreasuryFee + rateRewardsPoolFee == 10000, "Total fee must be 100%");
    rateTreasuryFee = _rateTreasuryFee;
  }
  function setRateOperatorFee(uint32 _rateOperatorFee) public onlyOwner {
    require(rateOperatorFee != _rateOperatorFee, "The same value!");
    require(_rateOperatorFee + rateTreasuryFee + rateRewardsPoolFee == 10000, "Total fee must be 100%");
    rateOperatorFee = _rateOperatorFee;
  }
  function setRateTransferFee(uint32 _rateTransferFee) public onlyOwner {
    require(rateTransferFee != _rateTransferFee, "The same value!");
    rateTransferFee = _rateTransferFee;
  }
  function setRateClaimFee(uint32 _rateClaimFee) public onlyOwner {
    require(rateClaimFee != _rateClaimFee, "The same value!");
    rateClaimFee = _rateClaimFee;
  }
  function getRateUpgradeFee(string memory tierNameFrom, string memory tierNameTo) public view returns (uint32) {
    bytes32 key = keccak256(abi.encodePacked(tierNameFrom, tierNameTo));
    return rateUpgradeFee[key];
  }
  function setRateUpgradeFee(
    string memory tierNameFrom,
    string memory tierNameTo,
    uint32 value
  ) public onlyOwner {
    bytes32 key = keccak256(abi.encodePacked(tierNameFrom, tierNameTo));
    rateUpgradeFee[key] = value;
  }
  function bindToken(address _token) public onlyOwner {
    token = IERC20(_token);
    // bytes4 uniswapV2Router = bytes4(keccak256(bytes("uniswapV2Router()")));
    // (bool success, bytes memory data) = _token.call(abi.encodeWithSelector(uniswapV2Router));
    // if (success) router = IUniswapV2Router02(abi.decode(data, (address)));
    // else revert("Token address is invalid.");
  }
  function bindRouter(address _router) public onlyOwner {
    router = IUniswapV2Router02(_router);
  }
  function transferTokenToOperator(
    address _sender,
    uint256 _fee,
    address _token
  ) public onlyManager {
    if (countOperator > 0) {
      uint256 _feeEach = _fee / countOperator;
      uint32 j = 0;
      for (uint32 i = 0; i < operators.length; i++) {
        if (!isOperator[operators[i]]) continue;
        if (j == countOperator - 1) {
          IERC20(_token).transferFrom(_sender, operators[i], _fee);
          break;
        } else {
          IERC20(_token).transferFrom(_sender, operators[i], _feeEach);
          _fee = _fee - _feeEach;
        }
        j++;
      }
    } else {
      IERC20(_token).transferFrom(_sender, address(this), _fee);
    }
  }
  function transferFeeToOperator(uint256 _fee) public onlyManager {
    if (countOperator > 0) {
      uint256 _feeEach = _fee / countOperator;
      uint32 j = 0;
      for (uint32 i = 0; i < operators.length; i++) {
        if (!isOperator[operators[i]]) continue;
        if (j == countOperator - 1) {
          transferETH(operators[i], _fee);
          break;
        } else {
          transferETH(operators[i], _feeEach);
          _fee = _fee - _feeEach;
        }
        j++;
      }
    }
  }
  function transferETHToOperator() public payable onlyManager {
    if (countOperator > 0) {
      uint256 _fee = msg.value;
      uint256 _feeEach = _fee / countOperator;
      uint32 j = 0;
      for (uint32 i = 0; i < operators.length; i++) {
        if (!isOperator[operators[i]]) continue;
        if (j == countOperator - 1) {
          payable(operators[i]).transfer(_fee);
          break;
        } else {
          payable(operators[i]).transfer(_feeEach);
          _fee = _fee - _feeEach;
        }
        j++;
      }
    }
  }
  function transferFee(address _sender, uint256 _fee) public onlyManager {
    require(_fee != 0, "Transfer token amount can't zero!");
    require(treasury != address(0), "Treasury address can't Zero!");
    require(address(router) != address(0), "Router address must be set!");
    uint256 _feeTreasury = (_fee * rateTreasuryFee) / 10000;
    token.transferFrom(_sender, address(this), _fee);
    transferETH(treasury, _feeTreasury);
    if (countOperator > 0) {
      uint256 _feeRewardPool = (_fee * rateRewardsPoolFee) / 10000;
      uint256 _feeOperator = _fee - _feeTreasury - _feeRewardPool;
      transferFeeToOperator(_feeOperator);
    }
  }
  function transferETH(address recipient, uint256 amount) public onlyManager {
    if (enabledTransferETH) {
      address[] memory path = new address[](2);
      path[0] = address(token);
      path[1] = router.WETH();
      token.approve(address(router), amount);
      router.swapExactTokensForETHSupportingFeeOnTransferTokens(amount, 0, path, recipient, block.timestamp);
    } else transfer(recipient, amount);
  }
  function claim(address to, uint256 amount) public onlyManager {
    uint256 feeOperator;
    if (rateClaimFee > 0) {
      uint256 fee = (amount * rateClaimFee) / 10000;
      feeOperator = (fee * IAloraNode(address(token)).operatorFee()) / 100;
      if (feeOperator > 0) {
        transferFeeToOperator(feeOperator);
        token.transfer(address(token), fee - feeOperator); // for liquidity
        token.transfer(to, amount - fee);
      } else {
        // token.claimTransfer(to, amount);
        IAloraNode(address(token)).claimTransfer(address(this), to, amount);
      }
    } else {
      if (feeOperator > 0) {
        token.transfer(to, amount);
      }
    }
  }
  function transfer(address to, uint256 amount) public onlyManager {
    token.transfer(to, amount);
  }
  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) public onlyManager {
    token.transferFrom(from, to, amount);
  }
  function withdraw(uint256 amount) public onlyOwner {
    require(token.balanceOf(address(this)) >= amount, "Withdraw: Insufficent balance.");
    token.transfer(address(msg.sender), amount);
  }
  function withdrawETH() public onlyOwner {
    uint256 amount = address(this).balance;
    (bool success, ) = payable(msg.sender).call{value: amount}("");
    require(success, "Failed to send Ether");
  }
  function getAmountETH1(uint256 _amount) public view returns (uint256) {
    if (address(token) == address(0)) return 0;
    return IAloraNode(address(token)).getAmountOut(_amount);
  }
  function getAmountETH2(uint256 _amount) public view returns (uint256) {
    if (address(router) == address(0)) return 0;
    address[] memory path = new address[](2);
    path[0] = address(token);
    path[1] = router.WETH();
    uint256[] memory amountsOut = router.getAmountsOut(_amount, path);
    return amountsOut[1];
  }
  function getAmountETH(uint256 _amount) public view returns (uint256) {
    if (address(router) == address(0)) return 0;
    uint256 amount1 = getAmountETH1(_amount);
    uint256 amount2 = getAmountETH2(_amount);
    if (amount1 > amount2) return amount1;
    return amount2;
  }
  function getTransferFee(uint256 _amount) public view returns (uint256) {
    return (_amount * rateTransferFee) / 10000;
  }
  function getClaimFee(uint256 _amount) public view returns (uint256) {
    return (_amount * rateClaimFee) / 10000;
  }
}