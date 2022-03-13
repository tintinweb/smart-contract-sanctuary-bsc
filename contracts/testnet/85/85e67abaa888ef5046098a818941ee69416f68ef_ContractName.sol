/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

// SPDX-License-Identifier: NO LICENSE

pragma solidity 0.8.10;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

abstract contract Authorization {
    address internal owner;
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

interface IHolderRewarderDistributor {
    function addShare(address shareholder, uint256 amount) external;
    function removeShare(address shareholder, uint256 amount) external returns (uint256, uint256, uint256);
    function getTotalShares(address shareholder) external view returns (uint256);
    function getTotalSharesCount(address shareholder) external view returns (uint256);
    function totalSharesCount() external view returns (uint256);
    function snapshotTotalShares() external returns (bool);
    function getSnapshotTotalShares() external view returns (uint256, uint256);
    function process(uint256 gas) external returns(uint256, uint256);
    function manualClaim(address shareholderAddress) external;
    function addSupply(uint256 tSupply, uint256 mSupply, uint256 sSupply) external;
    function resetSupply() external;
    function setRewardTokenAddress(address _newToken) external;
    function claimStuckTokens(address token, address owner) external;
}

contract HolderRewarderDistributor is IHolderRewarderDistributor {
    using SafeMath for uint256;
    
  address private _token;

  IBEP20 private rewardToken = IBEP20(0x8BaBbB98678facC7342735486C851ABD7A0d17Ca);
  address private WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

  struct Share {
    uint256 amount;
    uint256 txDateTime;
    uint256 rewardDateTime;
  }

  address[] shareholders;
  mapping (address => uint256) private _shareholderIndexes;
  mapping (address => Share[]) private _shareHoldersTxShares;
  mapping (address => uint8) private _shareHoldersTxShareCount;

  uint256 private _tSupply;
  uint256 private _mSupply;
  uint256 private _sSupply;
  uint256 private _snapshotRewardToken;
  uint256 private _snapshotLongTotalShares;
  uint256 private _snapshotMidTotalShares;
  uint256 private _snapshotShortTotalShares;

  uint256 private _shortTermDuration = (1 minutes);
  uint256 private _midTermDuration = (2 minutes);
  uint256 private _longTermDuration = (3 minutes);

  uint256 private _rewardTermDuration = (60 seconds);

  uint256 private currentIndex;
  
  IUniswapV2Router02 private router;
  
  modifier onlyToken() {
      require(msg.sender == _token); _;
  }

  constructor (address _router) 
  {
      router = IUniswapV2Router02(_router);
      _token = msg.sender;
      _tSupply = 0;
      _mSupply = 0;
      _sSupply = 0;
  }
  
  /**
  * @dev if share holder not in list, add to list
  then create share witihn txHolders 
  */

  function setRewardTokenAddress(address newToken) external onlyToken {
    rewardToken = IBEP20(newToken);
  }

  function claimStuckTokens(address token, address owner) external onlyToken {
     if (token == address(0x0)) {
     payable(owner).transfer(address(this).balance);
     return;
    }

     IBEP20 erc20token = IBEP20(token);
     uint256 balance = erc20token.balanceOf(address(this));
     erc20token.transfer(owner, balance);
  }

  function addShare(address shareholder, uint256 amount) external onlyToken 
  {
    if(amount > 0)
    {
        if (_shareHoldersTxShares[shareholder].length == 0) {
          addShareholder(shareholder);
        }
        uint256 blockTimestampLast = getBlockTimestamp();
        _shareHoldersTxShares[shareholder].push(Share(amount, blockTimestampLast, blockTimestampLast));
    }
  }
  
  /**
  * @dev remove shares with amount until 0, then return removed amounts within each term (standard, mid and long)
  */
  function removeShare(address shareholder, uint256 amount) external onlyToken returns (uint256, uint256, uint256) {
    if (gasleft() > 70000000) {
        revert("Gas limit reached");
    }
    uint256 longTerm = 0;
    uint256 midTerm = 0;
    uint256 standardTerm = 0;
    uint256 _shareHoldersTxSharesLength = _shareHoldersTxShares[shareholder].length;
    if(_shareHoldersTxSharesLength == 0)
    {
      return (longTerm, midTerm, standardTerm);
    }

    for (uint256 i = 0; i < _shareHoldersTxSharesLength; i++)
    {
      uint256 tIndex = _shareHoldersTxShares[shareholder].length.sub(1);
      Share memory share = _shareHoldersTxShares[shareholder][tIndex];
      uint256 blockTimestampLast = getBlockTimestamp();
      if (share.txDateTime.add(_midTermDuration) < blockTimestampLast)
      {
        if (share.txDateTime.add(_longTermDuration) < blockTimestampLast)
        {
          longTerm = longTerm.add(share.amount);
          uint256 currentTotal = longTerm.add(midTerm).add(standardTerm);
          if (amount <= currentTotal)
          {
              if (currentTotal == amount)
              {
                popTopOfStack(shareholder);
              }
              else
              {
                uint256 remainer = currentTotal.sub(amount);
                amendShareAmount(shareholder, tIndex, remainer);
                longTerm = longTerm.sub(remainer);
              }
              break;
          }
          else {
            popTopOfStack(shareholder);
          }
        }
        else
        {
          midTerm = midTerm.add(share.amount);
          uint256 currentTotal = longTerm.add(midTerm).add(standardTerm);
          if (amount <= currentTotal)
          {
              if (currentTotal == amount) {
                popTopOfStack(shareholder);
              }
              else {
                uint256 remainer = currentTotal.sub(amount);
                amendShareAmount(shareholder, tIndex, remainer);
                midTerm = midTerm.sub(remainer);
              }
              break;
          }
          else {
            popTopOfStack(shareholder);
          }
        }
      }
      else{
        standardTerm = standardTerm.add(share.amount);
        uint256 currentTotal = longTerm.add(midTerm).add(standardTerm);
        if (amount <= currentTotal)
        {
            if (currentTotal == amount) {
              popTopOfStack(shareholder);
            }
            else {
              uint256 remainer = currentTotal.sub(amount);
              amendShareAmount(shareholder, tIndex, remainer);
              standardTerm = standardTerm.sub(remainer);
            }
            break;
        }
        else {
          popTopOfStack(shareholder);
        }
      }
      if (_shareHoldersTxShares[shareholder].length == 0) {
          break;
      }
    }
    return (longTerm, midTerm, standardTerm);
  }

  /**
  * @dev update share with new amount
  */
  function amendShareAmount(address shareholder, uint256 tIndex, uint256 amount) internal {
    Share storage share = _shareHoldersTxShares[shareholder][tIndex];
    share.amount = amount;
  }
  
  /**
  * @dev update share with new amount
  */
  function amendShareRewardDateTime(address shareholder, uint256 tIndex, uint256 timestamp) internal {
    Share storage share = _shareHoldersTxShares[shareholder][tIndex];
    share.rewardDateTime = timestamp;
  }

  /**
  * @dev remove top of stack, only use within remove shares
  */
  function popTopOfStack(address shareholder) internal {
      _shareHoldersTxShares[shareholder].pop();
  }

  /**
  * @dev calculate total share for share holder
  */
  function calculateShareOfShareHolder(address shareholderAddress) private returns (uint256, uint256, uint256) {
    uint256 longTermHolds = 0;
    uint256 midTermHolds = 0;
    uint256 shortTermHolds = 0;
    
    uint256 blockTimestampLast = getBlockTimestamp();
    for (uint256 i = 0; i < _shareHoldersTxShares[shareholderAddress].length; i++) {
      Share memory share = _shareHoldersTxShares[shareholderAddress][i];
      uint256 txDateTime = share.txDateTime;
      uint256 rewardDateTime = share.rewardDateTime;
    if (txDateTime.add(_shortTermDuration) < blockTimestampLast) {  
      if (txDateTime.add(_midTermDuration) < blockTimestampLast) {
        if (txDateTime.add(_longTermDuration) < blockTimestampLast && rewardDateTime.add(_rewardTermDuration) < blockTimestampLast)
        {
          longTermHolds = longTermHolds.add(share.amount);
          midTermHolds = midTermHolds.add(share.amount);
          shortTermHolds = shortTermHolds.add(share.amount);
          amendShareRewardDateTime(shareholderAddress, i, blockTimestampLast);
          
        }
        else if (rewardDateTime.add(_rewardTermDuration) < blockTimestampLast)
        {
          midTermHolds = midTermHolds.add(share.amount);
          shortTermHolds = shortTermHolds.add(share.amount);
          amendShareRewardDateTime(shareholderAddress, i, blockTimestampLast);
        }
      }else if (rewardDateTime.add(_rewardTermDuration) < blockTimestampLast)
      {
        shortTermHolds = shortTermHolds.add(share.amount);
          amendShareRewardDateTime(shareholderAddress, i, blockTimestampLast);
      }
    }

    }
    return (longTermHolds, midTermHolds, shortTermHolds);
  }

  /**
  * @dev get total share for share holder
  */
  function getTotalShareOfShareHolder(address shareholderAddress) private view returns (uint256, uint256, uint256) {
    uint256 longTermHolds = 0;
    uint256 midTermHolds = 0;
    uint256 shortTermHolds = 0;
    
    uint256 blockTimestampLast = getBlockTimestamp();
    for (uint256 i = 0; i < _shareHoldersTxShares[shareholderAddress].length; i++) {
      Share memory share = _shareHoldersTxShares[shareholderAddress][i];
      uint256 txDateTime = share.txDateTime;
      if (txDateTime.add(_shortTermDuration) < blockTimestampLast) {
        if (txDateTime.add(_midTermDuration) < blockTimestampLast) {
          if (txDateTime.add(_longTermDuration) < blockTimestampLast)
          {
            longTermHolds = longTermHolds.add(share.amount);
            midTermHolds = midTermHolds.add(share.amount);
            shortTermHolds = shortTermHolds.add(share.amount);
          }else{
            midTermHolds = midTermHolds.add(share.amount);
            shortTermHolds = shortTermHolds.add(share.amount);
          }
        }else{
          shortTermHolds = shortTermHolds.add(share.amount); 
        }
      }
    }
    return (longTermHolds, midTermHolds, shortTermHolds);
  }

  // function getTotalShareOfShareHolder(address shareholderAddress) private view returns (uint256, uint256, uint256) {
  //   uint256 longTermHolds = 0;
  //   uint256 midTermHolds = 0;
  //   uint256 shortTermHolds = 0;
    
  //   uint256 blockTimestampLast = getBlockTimestamp();
  //   for (uint256 i = 0; i < _shareHoldersTxShares[shareholderAddress].length; i++) {
  //     Share memory share = _shareHoldersTxShares[shareholderAddress][i];
  //     uint256 txDateTime = share.txDateTime;
  //     if (txDateTime.add(_longTermDuration) < blockTimestampLast){
  //       longTermHolds = longTermHolds.add(share.amount);
  //       midTermHolds = midTermHolds.add(share.amount);
  //       shortTermHolds = shortTermHolds.add(share.amount);
  //     }else if
  //     (txDateTime.add(_midTermDuration) < blockTimestampLast){
  //         midTermHolds = midTermHolds.add(share.amount);
  //         shortTermHolds = shortTermHolds.add(share.amount);
  //       }else if
  //       (txDateTime.add(_shortTermDuration) < blockTimestampLast){
  //         shortTermHolds = shortTermHolds.add(share.amount);
  //         }
  //   }
  //   return (longTermHolds, midTermHolds, shortTermHolds);
  // }

  /**
  * @dev snapshots the total shares for all share holders
  */
  function snapshotTotalShares() external onlyToken returns (bool) {
    uint256 longTermHolds = 0;
    uint256 midTermHolds = 0;
    uint256 shortTermHolds = 0;
    for (uint256 i = 0; i < shareholders.length; i++) {
        address shareholderAddress = shareholders[i];
        (uint256 shareHolderLongTermHold, uint256 shareHolderMidTermHold, uint256 shareHolderShortTermHold) = getTotalShareOfShareHolder(shareholderAddress);
        longTermHolds = longTermHolds.add(shareHolderLongTermHold);
        midTermHolds = midTermHolds.add(shareHolderMidTermHold);
        shortTermHolds = shortTermHolds.add(shareHolderShortTermHold);
    }
    _snapshotLongTotalShares = longTermHolds;
    _snapshotMidTotalShares = midTermHolds;
    _snapshotShortTotalShares = shortTermHolds;
    _snapshotRewardToken = rewardToken.balanceOf(address(this));
    return true;
  }
  
  /**
  * @dev get snapshot shares
  */
  function getSnapshotTotalShares() external view returns (uint256, uint256) {
    return (_snapshotLongTotalShares, _snapshotMidTotalShares);
  }

  /**
  * @dev manual claim for rewards
  */
  function manualClaim(address shareholderAddress) external onlyToken {
    processShareHolder(shareholderAddress);
    _snapshotRewardToken = rewardToken.balanceOf(address(this));
  }
  
  /**
  * @dev processes snap shares for share holders
  */
  function process(uint256 gas) external onlyToken returns (uint256, uint256) {
    if(shareholders.length == 0) { return (0, 0); }
    if(currentIndex >= (shareholders.length - 1)) {
        currentIndex = 0;
    }

    uint256 gasUsed = 0;
    uint256 gasLeft = gasleft();

    while(gasUsed < gas && currentIndex < shareholders.length) 
    {
        address shareholderAddress = shareholders[currentIndex];
        processShareHolder(shareholderAddress);
        gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
        gasLeft = gasleft();
        currentIndex++;
    }
    return (currentIndex, (shareholders.length.sub(currentIndex)));
  }

  /**
  * @dev processes snap shares for share holder
  */
  function processShareHolder(address shareholderAddress) internal {
      (uint256 shareHolderLongTermHold, uint256 shareHolderMidTermHold, uint256 shareHolderShortTermHold) = calculateShareOfShareHolder(shareholderAddress);
      distributeLongDividend(shareholderAddress, shareHolderLongTermHold);
      distributeMidDividend(shareholderAddress, shareHolderMidTermHold);
      distributeShortDividend(shareholderAddress, shareHolderShortTermHold);
  }

  /**
  * @dev Get balance of contract, multiply it by long term rate, then transfer reward token to share holder.
  */
  function distributeLongDividend(address shareholder, uint256 longTermHolds) internal
  {
      if (longTermHolds > 0 && _snapshotLongTotalShares > 0 && _tSupply > 0) {
        uint256 rewardTokenSnaphot = _snapshotRewardToken.div(getLRate()).mul(10**9);
        uint256 rewardTokenAmount = rewardTokenSnaphot.div((_snapshotLongTotalShares).mul(10**9).div(longTermHolds)).mul(10**9);
        rewardToken.transfer(shareholder, rewardTokenAmount);
      }
  }
  
  /**
  * @dev Get balance of contract, multiply it by mid term rate, then transfer reward token to share holder.
  */
  function distributeMidDividend(address shareholder, uint256 midTermHolds) internal {
      if (midTermHolds > 0 && _snapshotMidTotalShares > 0 && _mSupply > 0) {
        uint256 rewardTokenSnaphot = _snapshotRewardToken.div(getMRate()).mul(10**9);
        uint256 rewardTokenAmount = rewardTokenSnaphot.div((_snapshotMidTotalShares).mul(10**9).div(midTermHolds)).mul(10**9);
        rewardToken.transfer(shareholder, rewardTokenAmount);
      }
  }

  /**
  * @dev Get balance of contract, multiply it by short term rate, then transfer reward token to share holder.
  */
  function distributeShortDividend(address shareholder, uint256 shortTermHolds) internal {
      if (shortTermHolds > 0 && _snapshotShortTotalShares > 0 && _sSupply > 0) {
        uint256 rewardTokenSnaphot = _snapshotRewardToken.div(getSRate()).mul(10**9);
        uint256 rewardTokenAmount = rewardTokenSnaphot.div((_snapshotShortTotalShares).mul(10**9).div(shortTermHolds)).mul(10**9);
        rewardToken.transfer(shareholder, rewardTokenAmount);
      }
  }
  
  /**
  * @dev add shareholder
  */
  function addShareholder(address shareholder) internal {
      _shareholderIndexes[shareholder] = shareholders.length;
      shareholders.push(shareholder);
  }

  /**
  * @dev remove shareholder
  */
  function removeShareholder(address shareholder) internal {
      shareholders[_shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
      delete _shareholderIndexes[shareholder];
      shareholders.pop();
  }

  /**
  * @dev get total shares without date stamp with claim reward 
  */
  function getTotalShares(address shareholder) external view returns (uint256) {
    uint256 amount = 0;
    if(_shareHoldersTxShares[shareholder].length == 0)
    {
      return amount;
    }
    (uint256 shareHolderLongTermHold, uint256 shareHolderMidTermHold, uint256 shareHolderShortTermHold) = getTotalShareOfShareHolder(shareholder);
    amount = shareHolderLongTermHold.add(shareHolderMidTermHold).add(shareHolderShortTermHold);
    return amount;
  }

  /**
  * @dev get total shares count for address
  */
  function getTotalSharesCount(address shareholder) public view returns (uint256){
    return _shareHoldersTxShares[shareholder].length;
  }
  
  /**
  * @dev get total shares count 
  */
  function totalSharesCount() public view returns (uint256) {
    return shareholders.length;
  }
  
  /**
   * @dev Returns the current block timestamp.
   */
  function getBlockTimestamp() internal view returns (uint256) {
    return block.timestamp;
  }

  /**
   * @dev Returns mid term rate.
   */
  function getSRate() internal view returns (uint256) {
    return (_tSupply.add(_mSupply).add(_sSupply)).mul(10**9).div(_sSupply);
  }

  /**
   * @dev Returns mid term rate.
   */
  function getMRate() internal view returns (uint256) {
    return (_tSupply.add(_mSupply).add(_sSupply)).mul(10**9).div(_mSupply);
  }
  
  /**
   * @dev Returns long term rate.
   */
  function getLRate() internal view returns (uint256) {
    return (_tSupply.add(_mSupply).add(_sSupply)).mul(10**9).div(_tSupply);
  }

  /**
   * @dev Update reward term supply and swaps BNB into rewardToken for distribution.
  */
  function addSupply(uint256 tSupply, uint256 mSupply, uint256 sSupply) external onlyToken {
    address[] memory path = new address[](2);
    path[0] = WBNB;
    path[1] = address(rewardToken);
    router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: address(this).balance}(
            0,
            path,
            address(this),
            block.timestamp
    );
    _tSupply = _tSupply.add(tSupply);
    _mSupply = _mSupply.add(mSupply);
    _sSupply = _sSupply.add(sSupply);
  }

  /**
   * @dev Reset reward term supply after weekly rewards.
  */
  function resetSupply() external onlyToken {
    _tSupply = 0;
    _mSupply = 0;
    _sSupply = 0;
  }
  
  //to recieve BNB from contract
  receive() external payable {}
}

contract ContractName is IBEP20, Authorization {
  using SafeMath for uint256;

  struct TaxFees {
    uint256 _longTermFee;
    uint256 _midTermFee;
    uint256 _shortTermFee;
    uint256 _operationFee;
    uint256 _stakingFee;
    uint256 _liquidityFee;
  }

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) public _allowances;
  
  mapping (address => bool) private _isExcludedFromFee;
  mapping (address => bool) private _isExcludedMaxTxAmount;
  mapping (address => bool) private _isExcluded;
  mapping (address => bool) public isStakingContract;

  /**
   * @dev Tax matrix, contains all fees.
   */
  mapping (string => TaxFees) private _taxMatrix;

  uint256 private _totalSupply;
  uint256 private _tSupply;
  uint256 private _mSupply;
  uint256 private _sSupply;
  
  uint8 private _decimals = 9;
  uint256 private _initalFragmentsSupply = 5000000000 * 10**_decimals;
  uint256 private _maxSellPercentage = 2000; //10^5
  uint256 private _numTokensSellToAddToLiquidity = (_initalFragmentsSupply.mul(20)).div(100000); //0.02%
  uint256 private _maxTokensSellToAddToLiquidity = (_initalFragmentsSupply.mul(100)).div(100000); //0.1%
  uint256 private _numTokensSellDistributor = (_initalFragmentsSupply.mul(25)).div(100000); //0.025%
  uint256 private _numTokensSellToSendTaxes = (_initalFragmentsSupply.mul(25)).div(100000); //0.025%

  string private _symbol = "Symbol"; 
  string private _name = "Token Name";

  address public _operationsAddress = (0x8ACD539223B2E4b2b9096109C0637c99B13BA463);
  address public _stakingFeeAddress = (0x3E0a34E74cF223348226C1a9aE66b6D735cdC1Fa);

  IBEP20 public rewardToken = IBEP20(0x8BaBbB98678facC7342735486C851ABD7A0d17Ca);

  address private WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
  address private deadWallet = 0x000000000000000000000000000000000000dEaD;

  bool public _canManualClaim;
  bool private _snapShotTaken;

  IHolderRewarderDistributor public distributor;
  IUniswapV2Router02 public uniswapV2Router;
  address public uniswapV2Pair;
  
  bool inSwapAndLiquify;
  bool public swapAndLiquifyEnabled = true;
  uint256 distributorGas = 500000;

  // max wallet tools
  mapping(address => bool) private _isExcludedFromMaxWallet;
  bool private enableMaxWallet = true;
  uint256 private maxWalletRate = 10;
  
  event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
  event ProcessRewards(uint256 index, uint256 shareHoldersToProcess);
  event SwapAndLiquifyEnabledUpdated(bool enabled);
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

  constructor(address _newOwner) Authorization(_newOwner) {
    _totalSupply =_initalFragmentsSupply;
    _balances[_newOwner] = _totalSupply;

    address pancakeSwapAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(pancakeSwapAddress);
    uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WETH());
    uniswapV2Router = _uniswapV2Router;
    
    distributor = new HolderRewarderDistributor(pancakeSwapAddress);

      //exclude owner and this contract from fee
    _isExcludedFromFee[_newOwner] = true;
    _isExcludedFromFee[address(this)] = true;
    _isExcludedFromFee[_operationsAddress] = true;
    _isExcludedFromFee[_stakingFeeAddress] = true;
    
    //exclude from rewards
    _isExcluded[address(this)] = true;
    _isExcluded[uniswapV2Pair] = true;
    _isExcluded[address(uniswapV2Router)] = true;
    _isExcluded[_newOwner] = true;
    _isExcluded[_operationsAddress] = true;
    _isExcluded[_stakingFeeAddress] = true;
    _isExcluded[deadWallet] = true;

    // exclude from max wallet limit
    _isExcludedFromMaxWallet[_newOwner] = true;
    _isExcludedFromMaxWallet[address(0)] = true;
    _isExcludedFromMaxWallet[address(this)] = true;
    _isExcludedFromMaxWallet[deadWallet] = true;

    _canManualClaim = false;
    _snapShotTaken = false;

    //FEE SETUP
    _taxMatrix["longTerm"] = (TaxFees(150, 450, 200, 150, 100, 200));
    _taxMatrix["midTerm"] = (TaxFees(125, 225, 300, 125, 50, 200));
    _taxMatrix["standard"] = (TaxFees(100, 100, 100, 25, 50, 0));

    emit Transfer(address(0), _newOwner, _totalSupply);
  }

  function updateRewardToken(address _newToken) external onlyOwner{
    rewardToken = IBEP20(_newToken);
    distributor.setRewardTokenAddress(_newToken);

  }
  
  function claimStuckTokens(address _token) external onlyOwner {
     require(_token != address(rewardToken));
     distributor.claimStuckTokens(_token, owner);
  }

  /**
   * @dev Returns the current block timestamp.
   */
  function getBlockTimestamp() internal view returns (uint256) {
    return block.timestamp;
  }

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() public override view returns (address) {
    return owner;
  }

 /**
  * @dev Returns the number of decimals used to get its user representation.
  * For example, if `decimals` equals `2`, a balance of `505` tokens should
  * be displayed to a user as `5,05` (`505 / 10 ** 2`).
  *
  */
  function decimals() public override view returns (uint8) {
    return _decimals;
  }

  /**
  * @dev Returns the symbol of the token, usually a shorter version of the
  * name.
  */
  function symbol() public override view returns (string memory) {
    return _symbol;
  }

  /**
    * @dev Returns the name of the token.
    */
  function name() public override view returns (string memory) {
    return _name;
  }

  /**
    * @dev See {IBEP20-totalSupply}.
    */
  function totalSupply() public override view returns (uint256) {
    return _totalSupply;
  }
  

  /**
    * @dev See {IBEP20-totalSupply}.
    */
  function rtotalSupply() public view returns (uint256) {
    return _tSupply.add(_mSupply).add(_sSupply);
  }

  /**
    * @dev See {IBEP20-balanceOf}.
    */
  function balanceOf(address account) public override view returns (uint256) {
    return _balances[account];
  }
  
  /**
  * @dev Total shares of address within holders shares
  */
  function rewardsOf(address account) public view returns (uint256) {
    return distributor.getTotalShares(account);
  }
  
  /**
  * @dev Count of shares of address within holders shares
  */
  function rewardCountOf(address account) public view returns (uint256) {
    return distributor.getTotalSharesCount(account);
  }
  
  /**
  * @dev Total shares holders
  */
  function shareHolderCount() public view returns (uint256) {
    return distributor.totalSharesCount();
  }
  
  /**
  * @dev Total shares of address within holders shares
  */
  function getSnapshotTermRewards() public view returns (uint256, uint256) {
    return distributor.getSnapshotTotalShares();
  }

  /**
  * @dev Includes address in fees
  */
  function includeInFee(address account) public authorized {
        _isExcludedFromFee[account] = false;
  }
  
  /**
  * @dev Exclude address in fees
  */
  function excludeInFee(address account) public authorized {
        _isExcludedFromFee[account] = true;
  }
  
  /**
  * @dev Include address in rewards
  */
  function includeInRewards(address account) public authorized {
        _isExcluded[account] = false;
  }
  
  /**
  * @dev Exclude address in rewards
  */
  function excludeInRewards(address account) public authorized {
        _isExcluded[account] = true;
  }
  
  /**
  * @dev Include address in MaxTxAmount
  */
  function includeInMxTxAmount(address account) public authorized {
        _isExcludedMaxTxAmount[account] = false;
  }
  
  /**
  * @dev Exclude address in MaxTxAmount
  */
  function excludeInMxTxAmount(address account) public authorized {
        _isExcludedMaxTxAmount[account] = true;
  }

  function isExcludedFromMaxWallet(address account) public view returns(bool) {
        return _isExcludedFromMaxWallet[account];
  }

  function maxWalletAmount() public view returns (uint256) {
        return totalSupply().mul(maxWalletRate).div(1000);
  }

  function setmaxWalletAmountRateDenominator1000(uint256 _val) public onlyOwner {
        require(_val >= 10, "Max wallet percentage cannot be lower than 1%");
        maxWalletRate = _val;
  }

  function setExcludeFromMaxWallet(address account, bool exclude) public onlyOwner {
          _isExcludedFromMaxWallet[account] = exclude;
  }

  function setenableMaxWallet(bool _val) public onlyOwner {
        enableMaxWallet = _val;
  }
  
 /**
  * @dev Returns the total supply
  */
  function getCirculatingSupply() public view returns (uint256) {
      return _totalSupply.sub(balanceOf(address(0)));
  }
  
  /**
  * @dev Set if Manual Claim is true or false
  */
  function setManualClaim(bool val) public onlyOwner {
    _canManualClaim = val;
  }

  /**
  * @dev BEP20: transfer
  */
  function transfer(address recipient, uint256 amount) external override returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }

  /**
  * @dev BEP20: allowance
  */
  function allowance(address owner, address spender) external override view returns (uint256) {
    return _allowances[owner][spender];
  }

  /**
  * @dev BEP20: approve
  */
  function approve(address spender, uint256 amount) external override returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }

  /**
  * @dev BEP20: transfer from
  */
  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }

  /**
  * @dev increase allowances for spender with msg.sender
  */
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
    return true;
  }

  /**
  * @dev decreases allowances for spender with msg.sender
  */
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  /**
  * @dev checks -
  Check if amount is greater than zero
  Checks if addresses are dead
  Checks antiWahle if sender or recipient are not owners
  */
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(amount > 0, "Transfer amount must be greater than zero");
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    if (sender != owner && recipient != owner) {
      if (!_isExcludedMaxTxAmount[sender] && recipient == uniswapV2Pair) {
        require(getCirculatingSupply().mul(_maxSellPercentage).div(
          10**5
        ) > amount, "BEP20: Sell amount exceeds the max sell amount");
      }
    }

    if (enableMaxWallet && maxWalletAmount() > 0) {
      if (_isExcludedFromMaxWallet[sender] == false && 
          _isExcludedFromMaxWallet[recipient] == false &&
          recipient != uniswapV2Pair) {
            uint balance  = balanceOf(recipient);
            require(balance + amount <= maxWalletAmount(), "MaxWallet: Transfer amount exceeds the maxWalletAmount");
      }
    }
    
    uint256 contractTokenBalance = balanceOf(address(this));
    uint256 totalRewardSupply = _tSupply.add(_mSupply).add(_sSupply);
    
    if(contractTokenBalance >= _maxTokensSellToAddToLiquidity)
    {
        contractTokenBalance = _maxTokensSellToAddToLiquidity;
    }
    bool overMinTokenBalance = contractTokenBalance >= _numTokensSellToAddToLiquidity;
    bool overMinTokenDistributorBalance = totalRewardSupply >= _numTokensSellDistributor;
    bool overMinTokenBalanceToSwapTaxes = _numTokensSellToSendTaxes >= balanceOf(_operationsAddress).add(balanceOf(_stakingFeeAddress));
    if (!inSwapAndLiquify &&
        sender != uniswapV2Pair &&
        swapAndLiquifyEnabled) {
          if (overMinTokenBalance)
          {
            contractTokenBalance = _numTokensSellToAddToLiquidity;
            //add liquidity
            swapAndLiquify(contractTokenBalance);
          }
          if (overMinTokenBalanceToSwapTaxes){
            inSwapAndLiquify = true;
            _depositWallets();
            inSwapAndLiquify = false;
          }

          if (overMinTokenDistributorBalance)
          {
            sendBNBToDistributor(totalRewardSupply);
          }
    }
    
    //indicates if fee should be deducted from transfer
    bool takeFee = true;
    
    //if any account belongs to _isExcludedFromFee account then remove the fee
    if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]){
        takeFee = false;
    }
    if(isStakingContract[sender] || isStakingContract[recipient]){
      transferWithStakingAddress(sender, recipient, amount);
    }else{
      //transfer amount, it will take tax, liquidity fee
      _tokenTransfer(sender,recipient,amount,takeFee);
    }
  }  
  
  function transferWithStakingAddress(address _sender, address _recipient, uint256 _amount) private {
    require(_sender != address(0), "ERC20: transfer from the zero address");
    require(_recipient != address(0), "ERC20: transfer to the zero address");
 
    _balances[_sender] = _balances[_sender].sub(_amount, "ERC20: transfer amount exceeds balance");
    _balances[_recipient] = _balances[_recipient].add(_amount);
  }

  function setIsStakingContract(address acc, bool value) public onlyOwner{
    isStakingContract[acc] = value;
    _isExcluded[acc] = value;
    _isExcludedFromMaxWallet[acc] = value;       
  }

  function _burn(address account, uint256 amount) public authorized {
    require(account != address(0), "BEP20: burn from the zero address");
    require(account == msg.sender, "BEP20: You can only burn your own tokens");

    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }
  
  //to recieve ETH from uniswapV2Router when swaping
  receive() external payable {}
  
  function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
      swapAndLiquifyEnabled = _enabled;
      emit SwapAndLiquifyEnabledUpdated(_enabled);
  }
  
  function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
      // split the contract balance into halves
      uint256 half = contractTokenBalance.div(2);
      uint256 otherHalf = contractTokenBalance.sub(half);

      // capture the contract's current ETH balance.
      // this is so that we can capture exactly the amount of ETH that the
      // swap creates, and not make the liquidity event include any ETH that
      // has been manually sent to the contract
      uint256 initialBalance = address(this).balance;

      // swap tokens for ETH
      swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

      // how much ETH did we just swap into?
      uint256 newBalance = address(this).balance.sub(initialBalance);

      // add liquidity to uniswap
      addLiquidity(otherHalf, newBalance);
      
      emit SwapAndLiquify(half, newBalance, otherHalf);
  }
  
  function swapTokensForEth(uint256 tokenAmount) private {
      // generate the uniswap pair path of token -> weth
      address[] memory path = new address[](2);
      path[0] = address(this);
      path[1] = uniswapV2Router.WETH();

      _approve(address(this), address(uniswapV2Router), tokenAmount);

      // make the swap
      uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
          tokenAmount,
          0, // accept any amount of ETH
          path,
          address(this),
          block.timestamp
      );
  }
  
  function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
      // approve token transfer to cover all possible scenarios
      _approve(address(this), address(uniswapV2Router), tokenAmount);

      // add the liquidity
      uniswapV2Router.addLiquidityETH{value: ethAmount}(
          address(this),
          tokenAmount,
          0, // slippage is unavoidable
          0, // slippage is unavoidable
          deadWallet,
          block.timestamp
      );
  }

  /**
    @dev sender BNB to distributor
   */
  function sendBNBToDistributor(uint256 rewardFee) private lockTheSwap {
    _balances[address(this)] = _balances[address(this)].add(rewardFee);
    swapTokensForEth(rewardFee); 
    address payable distributorWallet = payable(address(distributor));
    distributorWallet.transfer(address(this).balance);
    distributor.addSupply(_tSupply, _mSupply, _sSupply);
    _tSupply = 0;
    _mSupply = 0;
    _sSupply = 0;
  }
  
  /**
    @dev if sender is not excludeInRewards, then remove the amount to transfer.
    distributor will return a break down of the amount into 3 terms, long, mid and standard.
    All 3 terms have different tax brackets. Each term amount is taxed and then added together at the end.
    The amount is deducted from sender, and transferAmount is added to recipient.
    Fees are then taken into wallets and total variables.
   */
  function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) internal {
      uint256 longTermFee = 0;
      uint256 midTermFee = 0;
      uint256 shortTermFee = 0;
      uint256 operationsFee = 0;
      uint256 stakingFee = 0;
      uint256 liquidityFee = 0;
      if(!_isExcluded[sender])
      { 
        (uint256 longTerm, uint256 midTerm, uint256 standardTerm) = distributor.removeShare(sender, amount);
        if (longTerm > 0 && takeFee)
        {
          TaxFees storage longTaxFee = _taxMatrix["longTerm"];
          TaxFees memory calcTax = calculateFeeTier(longTaxFee, longTerm);
          longTermFee = longTermFee.add(calcTax._longTermFee);
          midTermFee = midTermFee.add(calcTax._midTermFee);
          shortTermFee = shortTermFee.add(calcTax._shortTermFee);
          operationsFee = operationsFee.add(calcTax._operationFee);
          stakingFee = stakingFee.add(calcTax._stakingFee);
          liquidityFee = liquidityFee.add(calcTax._liquidityFee);
        }
        if (midTerm > 0 && takeFee)
        {
          TaxFees storage midTaxFee = _taxMatrix["midTerm"];
          TaxFees memory calcTax = calculateFeeTier(midTaxFee, midTerm);
          longTermFee = longTermFee.add(calcTax._longTermFee);
          midTermFee = midTermFee.add(calcTax._midTermFee);
          shortTermFee = shortTermFee.add(calcTax._shortTermFee);
          operationsFee = operationsFee.add(calcTax._operationFee);
          stakingFee = stakingFee.add(calcTax._stakingFee);
          liquidityFee = liquidityFee.add(calcTax._liquidityFee);
        }
        if (standardTerm > 0 && takeFee)
        {
          TaxFees storage standard = _taxMatrix["standard"];
          TaxFees memory calcTax = calculateFeeTier(standard, standardTerm);
          longTermFee = longTermFee.add(calcTax._longTermFee);
          midTermFee = midTermFee.add(calcTax._midTermFee);
          shortTermFee = shortTermFee.add(calcTax._shortTermFee);
          operationsFee = operationsFee.add(calcTax._operationFee);
          stakingFee = stakingFee.add(calcTax._stakingFee);
        }
      } else if (takeFee) {
        TaxFees storage standard = _taxMatrix["standard"];
        TaxFees memory calcTax = calculateFeeTier(standard, amount);
        longTermFee = longTermFee.add(calcTax._longTermFee);
        midTermFee = midTermFee.add(calcTax._midTermFee);
        shortTermFee = shortTermFee.add(calcTax._shortTermFee);
        operationsFee = operationsFee.add(calcTax._operationFee);
        stakingFee = stakingFee.add(calcTax._stakingFee);
      }
      
      uint256 transferAmount = amount.sub(longTermFee).sub(midTermFee).sub(shortTermFee);
      transferAmount = transferAmount.sub(operationsFee).sub(stakingFee).sub(liquidityFee);

      if(!_isExcluded[recipient])
      { 
        distributor.addShare(recipient, transferAmount); 
      }

      _balances[sender] = _balances[sender].sub(amount, "BEP20: Insufficient Balance");
      _balances[recipient] = _balances[recipient].add(transferAmount);
      if (takeFee)
      {
        _takeOperations(sender, operationsFee);
        _takeStakingFee(sender, stakingFee);
        _takeRewardFee(longTermFee, midTermFee, shortTermFee);
        _takeLiquidity(liquidityFee);
      }

      emit Transfer(sender, recipient, transferAmount);
  }

  function _takeOperations(address sender, uint256 tFee) private {
    if (tFee > 0){
      _balances[_operationsAddress] = _balances[_operationsAddress].add(tFee);
      emit Transfer(sender, _operationsAddress, tFee);
    }
  }
  
  function _takeRewardFee(uint256 tFee, uint256 mFee, uint256 sFee) private {
    _tSupply = _tSupply.add(tFee);
    _mSupply = _mSupply.add(mFee);
    _sSupply = _sSupply.add(sFee);
  }
  
  function _takeStakingFee(address sender, uint256 tFee) private {
    if (tFee > 0){
      _balances[_stakingFeeAddress] = _balances[_stakingFeeAddress].add(tFee);
      emit Transfer(sender, _stakingFeeAddress, tFee);
    }
  }

  function _takeLiquidity(uint256 tLiquidity) private {
      _balances[address(this)] = _balances[address(this)].add(tLiquidity);
  }

  function calculateFeeTier(TaxFees memory taxFee, uint256 amount) internal pure returns (TaxFees memory) {
    return TaxFees(
      calculateFee(amount, taxFee._longTermFee), 
      calculateFee(amount, taxFee._midTermFee),
      calculateFee(amount, taxFee._shortTermFee), 
      calculateFee(amount, taxFee._operationFee),
      calculateFee(amount, taxFee._stakingFee), 
      calculateFee(amount, taxFee._liquidityFee));
  }

  function calculateFee(uint256 amount, uint256 fee) private pure returns (uint256) {
    if (fee > 0) {
      return amount.mul(fee).div(
          10**4
      );
    }
    return 0;
  }
  
  /**
  * @dev takes a snapshot of the total shares within the distributor contract
  */
  function snapshotRewards () public authorized {
    distributor.snapshotTotalShares();
    _snapShotTaken = true;
  }
  
  /**
  * @dev Will distribute rewards for mid or long 
  */
  function processRewards() public authorized returns(uint256, uint256) {
    require(_snapShotTaken, "Snapshot needs to be taken before processing rewards");
    (uint256 index, uint256 shareHoldersToProcess) = distributor.process(distributorGas);
    if (shareHoldersToProcess == 0) {
      distributor.resetSupply();
      _snapShotTaken = false;
    }
    emit ProcessRewards(index, shareHoldersToProcess);
    return (index, shareHoldersToProcess);
  }
  
  /**
  * @dev depending on the msg sender, will distribute rewards for address
  */
  function manualClaimRewards() public {
    require(_canManualClaim, "Manual claim is not allowed");
    distributor.manualClaim(msg.sender);
  }
  
  function depositWallets() external authorized {
    _depositWallets();
  }

  /**
  * @dev Swaps token within fee wallets 
  */
  function _depositWallets() private {
    uint256 stakingBalance = balanceOf(_stakingFeeAddress);
    if (stakingBalance > 0) {
      _balances[_stakingFeeAddress] = _balances[_stakingFeeAddress].sub(stakingBalance);
      _balances[address(this)] = _balances[address(this)].add(stakingBalance);
      swapAndSendStakingFeeBNB(stakingBalance);
    }
    uint256 operationBalance = balanceOf(_operationsAddress);
    if (operationBalance > 0) {
      _balances[_operationsAddress] = _balances[_operationsAddress].sub(operationBalance);
      _balances[address(this)] = _balances[address(this)].add(operationBalance);
      swapAndSendOperationsBNB(operationBalance);
    }
  }
  
  function swapAndSendStakingFeeBNB(uint256 tokenAmount) private {
      // generate the uniswap pair path of token -> weth
      address[] memory path = new address[](2);
      path[0] = address(this);
      path[1] = uniswapV2Router.WETH();

      _approve(address(this), address(uniswapV2Router), tokenAmount);

      // make the swap
      uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
          tokenAmount,
          0, // accept any amount of ETH
          path,
          _stakingFeeAddress,
          block.timestamp
      );
  }

  function swapAndSendOperationsBNB(uint256 tokenAmount) private {
      // generate the uniswap pair path of token -> weth
      address[] memory path = new address[](2);
      path[0] = address(this);
      path[1] = uniswapV2Router.WETH();

      _approve(address(this), address(uniswapV2Router), tokenAmount);

      // make the swap
      uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
          tokenAmount,
          0, // accept any amount of ETH
          path,
          _operationsAddress,
          block.timestamp
      );
  }

  /**
  @dev Set pancake address
   */
  function setRouterAddress(address newRouter) public authorized {
      IUniswapV2Router02 _newPancakeRouter = IUniswapV2Router02(newRouter);
      uniswapV2Pair = IUniswapV2Factory(_newPancakeRouter.factory()).createPair(address(this), _newPancakeRouter.WETH());
      uniswapV2Router = _newPancakeRouter;
  }
  
  /**
  @dev Set operation address
   */
  function setOperationAddress(address _address) public authorized {
    _operationsAddress = _address;
  }
  
  /**
  @dev Set staking fee address
   */
  function setStakingFeeAddress(address _address) public authorized {
    _stakingFeeAddress = _address;
  }
  
  /**
  @dev Set distributor address
   */
  function setDistributorAddress(address _address) public authorized {
    distributor = IHolderRewarderDistributor(_address);
  }
  
  /**
  @dev Set maxTxAmount, amount / 100
   */
  function setMaxTokensSellToAddliquidity(uint256 maxTokensSellToAddToLiquidity) public authorized {
      _maxTokensSellToAddToLiquidity = maxTokensSellToAddToLiquidity;
  }
  
  /**
  @dev Set maxPercSellAmount, divisor 10**5
   */
  function setMaxSellPercentage(uint256 maxSellPercentage) public authorized {
      require(maxSellPercentage >= 100, "Max sell percentage must be greater than 0.1% of circulating supply");
      _maxSellPercentage = maxSellPercentage;
  }

  /**
  @dev Set tax matrix for tax fee code
   */
  function setTaxFee(string memory taxFeeCode, uint256 _longTermFee, uint256 _midTermFee, uint256 _shortTermFee, uint256 _operationFee, uint256 _stakingFee, uint256 _liquidityFee)
    public authorized
    {
      require(_longTermFee + _midTermFee + _operationFee + _shortTermFee + _stakingFee + _liquidityFee <= 2000,  "Fee cannot be more than 20%");

      _taxMatrix[taxFeeCode] = (TaxFees(_longTermFee, _midTermFee, _shortTermFee, _operationFee, _stakingFee, _liquidityFee));
    }
}