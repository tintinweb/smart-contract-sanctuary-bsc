/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

pragma solidity 0.8.13;

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

interface IHolderRewarderDistributorV2 {
    function addShare(address shareholder, uint256 amount) external;
    function removeShare(address shareholder, uint256 amount) external returns (uint256, uint256, uint256);
    function getTotalShares(address shareholder) external view returns (uint256);
    function getTotalSharesCount(address shareholder) external view returns (uint256);
    function totalSharesCount() external view returns (uint256);
    function snapshotTotalShares() external returns (bool);
    function getSnapshotTotalShares() external view returns (uint256, uint256);
    function process(uint256 gas) external returns(uint256, uint256);
    function manualClaim(address shareholderAddress) external;
    function addSupply(uint256 tSupply, uint256 mSupply) external;
    function resetSupply() external;
}

pragma solidity 0.8.13;

struct Share {
    uint256 amount;
    uint256 txDateTime;
    uint256 rewardDateTime;
}

interface IHolderRewardStack {
    function addShare(address shareholder, uint256 amount) external;
    function getShare(address shareholder, uint256 tIndex) external view returns (Share memory);
    function addManualShareholder(address shareholder) external;
    function addManualShare(address shareholder, uint256 amount, uint256 timestamp, uint256 rewardTimestamp) external;
    function getShareCount(address shareholder) external view returns (uint256);
    function updateShare(address shareholder, uint256 tIndex, uint256 newAmount) external;
    function removeShare(address shareholder, uint256 tIndex) external;
    function removeShareHolder(address shareholder) external;
    function getShareholderCount() external view returns (uint256);
    function getShareholderAddress(uint256 index) external view returns (address);
    function updateRewardDateTime(address shareholder, uint256 tIndex, uint256 timestamp) external;
    function totalSharesCount() external view returns (uint256);
    function getShares(address shareholder) external view returns (Share[] memory);
}

interface IHolderRewarderDistributorV1 {
    function addShare(address shareholder, uint256 amount) external;
    function removeShare(address shareholder, uint256 amount) external returns (uint256, uint256, uint256);
    function getTotalShares(address shareholder) external view returns (uint256);
    function getTotalSharesCount(address shareholder) external view returns (uint256);
    function totalSharesCount() external view returns (uint256);
    function snapshotTotalShares() external returns (bool);
    function getSnapshotTotalShares() external view returns (uint256, uint256);
    function process(uint256 gas) external returns(uint256, uint256);
    function manualClaim(address shareholderAddress) external;
    function addSupply(uint256 tSupply, uint256 mSupply) external;
    function resetSupply() external;
    function getShareholderAddresses() external view returns (address[] memory);
    function getManualShares(address shareholderAddress) external view returns (Share[] memory);
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

contract HolderRewardStack is IHolderRewardStack, Authorization {
    using SafeMath for uint256;

  address[] shareholders;
  mapping (address => Share[]) private _shareHoldersTxShares;

  constructor() Authorization(msg.sender) {
  }

  /**
  * @dev if share holder not in list, add to list
  then create share witihn txHolders
  */
  function addShare(address shareholder, uint256 amount) external authorized
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
  /**
  * @dev add shareholder
  */
  function addManualShareholder(address shareholder) external authorized {
      if (_shareHoldersTxShares[shareholder].length == 0) {
        addShareholder(shareholder);
      }
  }

  /**
  /**
  * @dev add shareholder
  */
  function addManualShare(address shareholder, uint256 amount, uint256 timestamp, uint256 rewardTimestamp) external authorized {
      _shareHoldersTxShares[shareholder].push(Share(amount, timestamp, rewardTimestamp));
  }

  /**
  /**
  * @dev add shareholder
  */
  function addShareholder(address shareholder) internal {
      shareholders.push(shareholder);
  }

  function getShare(address shareholder, uint256 tIndex) external view authorized returns (Share memory) {
    Share memory share = _shareHoldersTxShares[shareholder][tIndex];
    return share;
  }

  function getShares(address shareholder) public view returns (Share[] memory) {
    return _shareHoldersTxShares[shareholder];
  }

  function getShareCount(address shareholder) external view authorized returns (uint256) {
    return _shareHoldersTxShares[shareholder].length;
  }

  function updateShare(address shareholder, uint256 tIndex, uint256 newAmount) external authorized {
    Share storage share = _shareHoldersTxShares[shareholder][tIndex];
    share.amount = newAmount;
  }

  function removeShare(address shareholder, uint256 tIndex) external authorized {
    if (tIndex == _shareHoldersTxShares[shareholder].length.sub(1)){
      popTopOfStack(shareholder);
    }
  }

  function removeShareHolder(address shareholder) external authorized {
    uint i = 0;
    while (shareholders[i] != shareholder) {
        i++;
    }
    shareholders[i] = shareholders[shareholders.length - 1];
    shareholders.pop();
  }

  function getShareholderCount() external view authorized returns (uint256) {
    return shareholders.length;
  }


  function getShareholderAddress(uint256 index) external view authorized returns (address) {
    return shareholders[index];
  }

  function updateRewardDateTime(address shareholder, uint256 tIndex, uint256 timestamp) external authorized {
    Share storage share = _shareHoldersTxShares[shareholder][tIndex];
    share.rewardDateTime = timestamp;
  }

  function popTopOfStack(address shareholder) internal {
      _shareHoldersTxShares[shareholder].pop();
  }

  function getTotalShares(address shareholder) public view returns (uint256) {
    uint256 amount = 0;
    for (uint256 i = 0; i < _shareHoldersTxShares[shareholder].length; i++) {
      Share memory share = _shareHoldersTxShares[shareholder][i];
      amount = amount.add(share.amount);
    }
    return amount;
  }

  function getTotalSharesCount(address shareholder) public view returns (uint256){
    return _shareHoldersTxShares[shareholder].length;
  }

  function totalSharesCount() public view returns (uint256) {
    return shareholders.length;
  }

  function getBlockTimestamp() internal view returns (uint256) {
    return block.timestamp;
  }

  /**
   * @dev Returns the current block timestamp.
   */
  function blockTimestamp() public view returns (uint256) {
    return block.timestamp;
  }

  //to recieve BNB from contract
  receive() external payable {}
}

struct RemoveRewardDto {
  uint256 longTerm;
  uint256 midTerm;
  uint256 standardTerm;
}

contract HolderRewarderDistributorV2 is IHolderRewarderDistributorV2, Authorization {
    using SafeMath for uint256;

  IBEP20 private BUSD;
  address private WBNB;
  address private _token;

  event SnapshotRewards(uint256 index, uint256 shareHoldersToProcess);
  event MigrationRewards(uint256 index);
  event Event(uint256 index);

  uint256 public _tSupply;
  uint256 public _mSupply;
  uint256 private _snapshotBUSD;
  uint256 private _snapshotLongTotalShares;
  uint256 private _snapshotMidTotalShares;
  bool private _tSupplyTaken;
  bool private _mSupplyTaken;
  bool private _rewardResetTaken;
  bool private _useInternalGasDistributor;
  bool public _inSnapshot;
  bool public _inRewards;
  uint256 private _snapshotProcessLongTotalShares;
  uint256 private _snapshotProcessMidTotalShares;

  uint256 private _midTermDuration = (7 days);
  uint256 private _longTermDuration = (90 days);
  uint256 private _rewardTermDuration = (166 hours);
  uint256 private _snapshotTermDuration = (7 days);

  uint256 public nextRewardTriggerTimestamp;
  uint256 public snapshotCurrentIndex;
  uint256 public currentIndex;
  uint256 public currentMigrationIndex;
  bool public migrationEnabled;
  bool public removeShareHolderEnabled;
  uint256 private gasRewardDistributor = 500000;
  uint256 private gasSnapshotDistributor = 500000;
  uint256 private gasMigration = 1000000;

  IUniswapV2Router02 public router;
  IHolderRewarderDistributorV1 public distributorV1;
  IHolderRewardStack public rewardStack;

  constructor() Authorization(msg.sender) {
      distributorV1 = IHolderRewarderDistributorV1(0x089D7AC6e02fF22063ff9a05672792a7Eb2cf31b);
      router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
      BUSD = IBEP20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
      WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
      rewardStack = new HolderRewardStack();
      _token = 0x09f78A9DebD74cDeEe3B8e6F02FA96E2E76846be;
      _tSupply = 0;
      _mSupply = 0;
      currentIndex = 0;
      snapshotCurrentIndex = 0;
      _tSupplyTaken = false;
      _mSupplyTaken = false;
      _rewardResetTaken = true;
      removeShareHolderEnabled = true;
      migrationEnabled = true;
      _useInternalGasDistributor = false;
      _inSnapshot = false;
      _inRewards = false;
      nextRewardTriggerTimestamp = block.timestamp.add(_snapshotTermDuration);
      authorize(_token);
      authorize(address(this));
  }

  /**
  * @dev if share holder not in list, add to list
  then create share within txHolders
  */
  function addShare(address shareholder, uint256 amount) external authorized
  {
    rewardStack.addShare(shareholder, amount);
    migrate(gasMigration);
    processSnapshotTotalShares(gasSnapshotDistributor);
    processRewards(gasRewardDistributor);
  }

  function termShareCalc(uint256 termAmount, RemoveRewardDto memory removeRwardDto, uint256 amount, uint256 shareAmount, address shareholder, uint256 tIndex) private returns(uint256, bool) {
      termAmount = termAmount.add(shareAmount);
      uint256 termAmountTotal = removeRwardDto.longTerm.add(removeRwardDto.midTerm).add(removeRwardDto.standardTerm).add(termAmount);
      if (amount <= termAmountTotal)
      {
          termAmount = obsolesceShare(termAmountTotal, amount, termAmount, shareholder, tIndex);
          return (termAmount, true);
      }
      else {
        rewardStack.removeShare(shareholder, tIndex);
        return (termAmount, false);
      }
  }

  function termShareFacCheck(address shareholder, uint256 amount) private returns(RemoveRewardDto memory) {
      RemoveRewardDto memory removeRwardDto = RemoveRewardDto(0, 0, 0);
      uint256 _shareHoldersTxSharesLength = rewardStack.getShareCount(shareholder);
      for (uint256 i = 0; i < _shareHoldersTxSharesLength; i++)
      {
        uint256 tIndex = rewardStack.getShareCount(shareholder).sub(1);
        Share memory share = rewardStack.getShare(shareholder, tIndex);
        uint256 blockTimestampLast = getBlockTimestamp();
        if (share.txDateTime.add(_midTermDuration) < blockTimestampLast)
        {
          if (share.txDateTime.add(_longTermDuration) < blockTimestampLast)
          {
              bool end = false;
              (removeRwardDto.longTerm, end) = termShareCalc(removeRwardDto.longTerm, removeRwardDto, amount, share.amount, shareholder, tIndex);
              if (end){
                break;
              }
          }
          else
          {
            bool end = false;
            (removeRwardDto.midTerm, end) = termShareCalc(removeRwardDto.midTerm, removeRwardDto, amount, share.amount, shareholder, tIndex);
            if (end){
              break;
            }
          }
        }
        else{
          bool end = false;
          (removeRwardDto.standardTerm, end) = termShareCalc(removeRwardDto.standardTerm, removeRwardDto, amount, share.amount, shareholder, tIndex);
          if (end){
            break;
          }
        }
        if (rewardStack.getShareCount(shareholder) == 0) {
            break;
        }
      }
      return removeRwardDto;
  }

  /**
  * @dev remove shares with amount until 0, then return removed amounts within each term (standard, mid and long)
  */
  function removeShare(address shareholder, uint256 amount) external authorized returns (uint256, uint256, uint256) {
    if (gasleft() > 70000000) {
        revert("Gas limit reached");
    }
    uint256 _shareHoldersTxSharesLength = rewardStack.getShareCount(shareholder);
    if(_shareHoldersTxSharesLength == 0)
    {
      return (0, 0, 0);
    }
    RemoveRewardDto memory removeRwardDto = termShareFacCheck(shareholder, amount);
    if (rewardStack.getShareCount(shareholder) == 0 && removeShareHolderEnabled) {
      rewardStack.removeShareHolder(shareholder);
    }
    migrate(gasMigration);
    processSnapshotTotalShares(gasSnapshotDistributor);
    processRewards(gasRewardDistributor);
    return (removeRwardDto.longTerm, removeRwardDto.midTerm, removeRwardDto.standardTerm);
  }

  function obsolesceShare(uint256 currentTotal, uint256 amount, uint256 termAmount, address shareholder, uint256 tIndex) private returns(uint256) {
    uint256 newTermAmount = termAmount;
    if (currentTotal == amount) {
      rewardStack.removeShare(shareholder, tIndex);
    }
    else {
      uint256 remainer = currentTotal.sub(amount);
      rewardStack.updateShare(shareholder, tIndex, remainer);
      newTermAmount = termAmount.sub(remainer);
    }
    return newTermAmount;
  }

  /**
  * @dev calculate total share for share holder
  */
  function calculateShareOfShareHolder(address shareholderAddress) private returns (uint256, uint256) {
    uint256 longTermHolds = 0;
    uint256 midTermHolds = 0;

    uint256 blockTimestampLast = getBlockTimestamp();
    uint256 shareHoldersTxSharesLength = rewardStack.getShareCount(shareholderAddress);
    for (uint256 i = 0; i < shareHoldersTxSharesLength; i++) {
      Share memory share = rewardStack.getShare(shareholderAddress, i);
      uint256 txDateTime = share.txDateTime;
      uint256 rewardDateTime = share.rewardDateTime;
      if (txDateTime.add(_midTermDuration) < blockTimestampLast) {
        if (txDateTime.add(_longTermDuration) < blockTimestampLast && rewardDateTime.add(_rewardTermDuration) < blockTimestampLast)
        {
          longTermHolds = longTermHolds.add(share.amount);
          midTermHolds = midTermHolds.add(share.amount);
          rewardStack.updateRewardDateTime(shareholderAddress, i, blockTimestampLast);

        }
        else if (rewardDateTime.add(_rewardTermDuration) < blockTimestampLast)
        {
          midTermHolds = midTermHolds.add(share.amount);
          rewardStack.updateRewardDateTime(shareholderAddress, i, blockTimestampLast);
        }
      }
    }
    return (longTermHolds, midTermHolds);
  }

  /**
  * @dev get total share for share holder
  */
  function getTotalShareOfShareHolder(address shareholderAddress) private view returns (uint256, uint256) {
    uint256 longTermHolds = 0;
    uint256 midTermHolds = 0;

    uint256 blockTimestampLast = getBlockTimestamp();
    uint256 shareHoldersTxSharesLength = rewardStack.getShareCount(shareholderAddress);
    for (uint256 i = 0; i < shareHoldersTxSharesLength; i++) {
      Share memory share = rewardStack.getShare(shareholderAddress, i);
      uint256 txDateTime = share.txDateTime;
      if (txDateTime.add(_midTermDuration) < blockTimestampLast) {
        if (txDateTime.add(_longTermDuration) < blockTimestampLast)
        {
          longTermHolds = longTermHolds.add(share.amount);
          midTermHolds = midTermHolds.add(share.amount);
        }
        else
        {
          midTermHolds = midTermHolds.add(share.amount);
        }
      }
    }
    return (longTermHolds, midTermHolds);
  }

  function checkRewardTimestamp() internal returns (bool) {
    if (block.timestamp > nextRewardTriggerTimestamp){
      _inSnapshot = true;
      return true;
    }
    return false;
  }

  /**
  * @dev snapshots the total shares for all share holders
  */
  function snapshotTotalShares() external authorized returns (bool) {
    if (!_inSnapshot) {
      _inSnapshot = true;
    }
    bool completed = processSnapshotTotalShares(gasSnapshotDistributor);
    if (completed) {
      _inSnapshot = false;
    }
    return completed;
  }

  function processSnapshotTotalShares(uint256 gas) internal returns (bool) {
    if (!_inSnapshot) {
      if (!checkRewardTimestamp()){
        emit Event(274);
        return false;
      }
    }
    uint256 shareHolderCount = rewardStack.getShareholderCount();
    if(snapshotCurrentIndex >= (shareHolderCount)) {
        snapshotCurrentIndex = 0;
    }

    uint256 longTermHolds = 0;
    uint256 midTermHolds = 0;
    uint256 gasUsed = 0;
    uint256 gasLeft = gasleft();
    while(gasUsed < gas && snapshotCurrentIndex < shareHolderCount)
    {
        address shareholderAddress = rewardStack.getShareholderAddress(snapshotCurrentIndex);
        (uint256 shareHolderLongTermHold, uint256 shareHolderMidTermHold) = getTotalShareOfShareHolder(shareholderAddress);
        longTermHolds = longTermHolds.add(shareHolderLongTermHold);
        midTermHolds = midTermHolds.add(shareHolderMidTermHold);
        gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
        gasLeft = gasleft();
        snapshotCurrentIndex++;
    }
    _snapshotProcessLongTotalShares = _snapshotProcessLongTotalShares.add(longTermHolds);
    _snapshotProcessMidTotalShares = _snapshotProcessMidTotalShares.add(midTermHolds);
    emit SnapshotRewards(snapshotCurrentIndex, (shareHolderCount.sub(snapshotCurrentIndex)));
    bool completed = false;
    if (shareHolderCount.sub(snapshotCurrentIndex) == 0) {
      _snapshotLongTotalShares = _snapshotProcessLongTotalShares;
      _snapshotMidTotalShares = _snapshotProcessMidTotalShares;
      _snapshotProcessLongTotalShares = 0;
      _snapshotProcessMidTotalShares = 0;
      _snapshotBUSD = BUSD.balanceOf(address(this));
      completed = true;
      _inRewards = true;
      _inSnapshot = false;
    }
    return completed;
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
  function manualClaim(address shareholderAddress) external authorized {
    processShareHolder(shareholderAddress);
    _snapshotBUSD = BUSD.balanceOf(address(this));
  }

  /**
  * @dev processes rewards for share holders
  */
  function process(uint256 gas) external authorized returns (uint256, uint256) {
    if (!_inSnapshot) {
      _inSnapshot = true;
    }
    (uint256 index, uint256 remaining) = processRewards(gas);
    if (_inSnapshot){
      _inSnapshot = false;
    }
    return (index, remaining);
  }


  /**
  * @dev processes rewards for share holders
  */
  function processRewards(uint256 gas) internal returns (uint256, uint256) {
    if (!_inRewards) return (0, 0);
    if (_useInternalGasDistributor) { gas = gasRewardDistributor; }

    uint256 shareHolderCount = rewardStack.getShareholderCount();
    if(shareHolderCount == 0) { return (0, 0); }
    if(currentIndex >= (shareHolderCount)) {
        currentIndex = 0;
    }

    uint256 gasUsed = 0;
    uint256 gasLeft = gasleft();
    while(gasUsed < gas && currentIndex < shareHolderCount)
    {
        address shareholderAddress = rewardStack.getShareholderAddress(currentIndex);
        processShareHolder(shareholderAddress);
        gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
        gasLeft = gasleft();
        currentIndex++;
    }

    if ((shareHolderCount.sub(currentIndex)) == 0) {
      _inRewards = false;
      nextRewardTriggerTimestamp = nextRewardTriggerTimestamp.add(_snapshotTermDuration);
    }

    return (currentIndex, (shareHolderCount.sub(currentIndex)));
  }

  /**
  * @dev processes snap shares for share holder
  */
  function processShareHolder(address shareholderAddress) internal {
      (uint256 shareHolderLongTermHold, uint256 shareHolderMidTermHold) = calculateShareOfShareHolder(shareholderAddress);
      distributeLongDividend(shareholderAddress, shareHolderLongTermHold);
      distributeMidDividend(shareholderAddress, shareHolderMidTermHold);
  }

  /**
  * @dev Get balance of contract, multiply it by long term rate, then BUSD transfer to share holder.
  */
  function distributeLongDividend(address shareholder, uint256 longTermHolds) internal
  {
      if (longTermHolds > 0 && _snapshotLongTotalShares > 0 && _tSupply > 0 && _snapshotBUSD > 0) {
        uint256 busdSnapshot = _snapshotBUSD.div(getLRate()).mul(10**9);
        uint256 busdAmount = busdSnapshot.div((_snapshotLongTotalShares).mul(10**9).div(longTermHolds)).mul(10**9);
        try BUSD.transfer(shareholder, busdAmount) {} catch {}
        _tSupplyTaken = true;
      }
  }

  /**
  * @dev Get balance of contract, multiply it by mid term rate, then BUSD transfer to share holder.
  */
  function distributeMidDividend(address shareholder, uint256 midTermHolds) internal {
      if (midTermHolds > 0 && _snapshotMidTotalShares > 0 && _mSupply > 0 && _snapshotBUSD > 0) {
        uint256 busdSnapshot = _snapshotBUSD.div(getMRate()).mul(10**9);
        uint256 busdAmount = busdSnapshot.div((_snapshotMidTotalShares).mul(10**9).div(midTermHolds)).mul(10**9);
        try BUSD.transfer(shareholder, busdAmount) {} catch { emit Event(391); }
        _mSupplyTaken = true;
    }
    emit Event(394);
  }

  /**
  * @dev get total shares without date stamp with claim reward
  */
  function getTotalShares(address shareholder) external view returns (uint256) {
    uint256 amount = 0;
    uint256 shareHoldersTxSharesLength = rewardStack.getShareCount(shareholder);
    if(shareHoldersTxSharesLength == 0)
    {
      return amount;
    }
    (uint256 shareHolderLongTermHold, uint256 shareHolderMidTermHold) = getTotalShareOfShareHolder(shareholder);
    amount = shareHolderLongTermHold.add(shareHolderMidTermHold);
    return amount;
  }

  /**
  * @dev get total shares count for address
  */
  function getTotalSharesCount(address shareholder) public view returns (uint256){
    return rewardStack.getShareCount(shareholder);
  }

  /**
  * @dev get total shares count
  */
  function totalSharesCount() public view returns (uint256) {
    return rewardStack.totalSharesCount();
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
  function getMRate() internal view returns (uint256) {
    return (_tSupply.add(_mSupply)).mul(10**9).div(_mSupply);
  }

  /**
   * @dev Returns long term rate.
   */
  function getLRate() internal view returns (uint256) {
    return (_tSupply.add(_mSupply)).mul(10**9).div(_tSupply);
  }

  /**
   * @dev Update reward term supply and swaps BNB into BUSD for distribution.
  */
  function addSupply(uint256 tSupply, uint256 mSupply) external authorized {
    address[] memory path = new address[](2);
    path[0] = WBNB;
    path[1] = address(BUSD);
    router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: address(this).balance}(
            0,
            path,
            address(this),
            block.timestamp
    );
    _tSupply = _tSupply.add(tSupply);
    _mSupply = _mSupply.add(mSupply);
  }

  /**
   * @dev Reset reward term supply after weekly rewards.
  */
  function resetSupply() external authorized {
    if (_tSupplyTaken){
        _tSupply = 0;
        _tSupplyTaken = false;
    }
    if (_mSupplyTaken){
        _mSupply = 0;
        _mSupplyTaken = false;
    }
    currentIndex = 0;
  }

  /**
   * @dev Manual set reward term supply for weekly rewards.
  */
  function manualSetSupply(uint256 tSupply, uint256 mSupply) public authorized {
    _tSupply = tSupply;
    _mSupply = mSupply;
  }

  /**
   * @dev Manual set indexs
  */
  function manualSetIndex(uint256 index, uint256 snapShotIndex, uint256 migrationindex) public authorized {
    currentIndex = index;
    snapshotCurrentIndex = snapShotIndex;
    currentMigrationIndex = migrationindex;
  }

  /**
  * @dev BUSD transfer to account.
  */
  function depositOutBUSD(address account,uint256 amount) public authorized {
        if (BUSD.balanceOf(address(this)) >= amount) {
            BUSD.transfer(account, amount);
        }
  }

  function updateGasRewardProcess(uint256 gas) public authorized {
    gasRewardDistributor = gas;
  }

  function updateGasMigrationProcess(uint256 gas) public authorized {
    gasMigration = gas;
  }

  function updateGasSnapShotProcess(uint256 gas) public authorized {
    gasSnapshotDistributor = gas;
  }

  function setRemoveShareHolderEnabled(bool enabled) public authorized {
    removeShareHolderEnabled = enabled;
  }

  function setnextRewardTriggerTimestamp(uint256 timestamp) public authorized {
    nextRewardTriggerTimestamp = timestamp;
  }

  function setMigrationEnabled(bool enabled) public authorized {
    migrationEnabled = enabled;
  }

  function manualMigrate(uint256 gas) public {
    migrate(gas);
  }

  function migrate(uint256 gas) internal {
    if (migrationEnabled == false) return;
    if (gasleft() > gas) return;
    uint256 totalShareHolderCount = distributorV1.totalSharesCount();
    uint256 gasUsed = 0;
    uint256 gasLeft = gasleft();
    address[] memory shareHolders = distributorV1.getShareholderAddresses();
    while(gasUsed < gas && currentMigrationIndex < totalShareHolderCount)
    {
        emit MigrationRewards(currentIndex);
        processShareHolderMigration(shareHolders[currentMigrationIndex]);
        gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
        gasLeft = gasleft();
        currentMigrationIndex++;
    }
    if (currentMigrationIndex >= totalShareHolderCount){
      migrationEnabled = false;
    }
  }

  function processShareHolderMigration(address shareHolder) internal{
      Share[] memory shares = distributorV1.getManualShares(shareHolder);
      if (shares.length == 0) return;
      rewardStack.addManualShareholder(shareHolder);
      for (uint256 i = 0; i < shares.length; i++) {
        rewardStack.addManualShare(shareHolder, shares[i].amount, shares[i].txDateTime, shares[i].rewardDateTime);
      }
  }

  /**
   * @dev Returns the current block timestamp.
   */
  function blockTimestamp() public view returns (uint256) {
    return block.timestamp;
  }

  //to recieve BNB from contract
  receive() external payable {}
}