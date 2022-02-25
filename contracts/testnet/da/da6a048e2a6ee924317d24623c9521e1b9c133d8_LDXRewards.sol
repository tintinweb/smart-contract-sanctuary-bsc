/**
 *Submitted for verification at BscScan.com on 2022-02-25
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ~0.8.9;

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
}

/**
 * BEP20 standard interface.
 */
interface IBEP20 {
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Auth {
  address internal owner;
  mapping(address => bool) internal authorizations;

  constructor(address _owner) {
    owner = _owner;
    authorizations[_owner] = true;
  }

  modifier onlyOwner() {
    require(isOwner(msg.sender), "!OWNER");
    _;
  }

  modifier authorized() {
    require(isAuthorized(msg.sender), "!AUTHORIZED");
    _;
  }

  function authorize(address adr) public onlyOwner {
    authorizations[adr] = true;
  }

  function unauthorize(address adr) public onlyOwner {
    authorizations[adr] = false;
  }

  function isOwner(address account) public view returns (bool) {
    return account == owner;
  }

  function isAuthorized(address adr) public view returns (bool) {
    return authorizations[adr];
  }

  function transferOwnership(address payable adr) public onlyOwner {
    owner = adr;
    authorizations[adr] = true;
    emit OwnershipTransferred(adr);
  }

  event OwnershipTransferred(address owner);
}

interface IDEXFactory {
  function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

interface IDEXRouter {
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

contract LDXRewards is Auth {
  using SafeMath for uint256;

  address ldxToken = 0x517a1b989d2dC9042f02aA873E26601f7f36aD99;
  address rewardToken = 0x8BaBbB98678facC7342735486C851ABD7A0d17Ca;
  IDEXRouter router = IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);

  address[] excludedShareholders;

  struct ShareHolder {
    uint256 shares;
    uint256 rewardsPaid;
    uint256 rewardsPending;
    bool isExcluded;
  }

  // mapping(address => uint256) rewardBalances;

  mapping(address => ShareHolder) public mHolders;
  address[] public aHolders;

  uint256 public shareHoldersCount;
  uint256 public totalSharesForRewards;
  uint256 public minAmtForRewards = 0.01 ether;
  uint256 public lastProcessedIndex;
  uint256 public rewardTokensForRewards;
  uint256 public bnbForRewards;

  constructor() Auth(msg.sender) {}

  function changeRewardToken(address _rewardToken) external onlyOwner {
    rewardToken = _rewardToken;
  }

  function resetShareholders() external onlyOwner {
    _resetShareholders();
  }

  function _resetShareholders() internal {
    delete aHolders;
    shareHoldersCount = 0;
    totalSharesForRewards = 0;
    lastProcessedIndex = 0;
  }

  function setShareHolders(
    address[] calldata _holders,
    uint256[] calldata _holdings
  ) external onlyOwner {
    require(_holders.length == _holdings.length, "Array mismatch");
    for (uint256 i; i < _holders.length; ++i) {
      aHolders[i] = _holders[i];
      mHolders[_holders[i]].shares = _holdings[i];
      totalSharesForRewards = totalSharesForRewards.add(_holdings[i]);
    }
    shareHoldersCount = aHolders.length;
  }

  function removeExcludedShareHoldersFromRewards() internal {
    uint256 excludedShares;
    for (uint256 i; i < excludedShareholders.length; ++i) {
      excludedShares = excludedShares.add(
        mHolders[excludedShareholders[i]].shares
      );
      mHolders[excludedShareholders[i]].isExcluded = true;
    }
    totalSharesForRewards = totalSharesForRewards.sub(excludedShares);
  }

  function calculateRewards() public onlyOwner {
    bnbForRewards = address(this).balance;

    for (uint256 i; i < aHolders.length; ++i) {
      if (!mHolders[aHolders[i]].isExcluded) {
        mHolders[aHolders[i]].rewardsPending = mHolders[aHolders[i]]
          .rewardsPending
          .add(
            mHolders[aHolders[i]].shares.mul(bnbForRewards).div(
              totalSharesForRewards
            )
          );
      }
    }
  }

  function swapForRewardToken() internal returns (uint256) {
    uint256 rewardBalanceBefore = IBEP20(rewardToken).balanceOf(address(this));

    address[] memory path = new address[](2);
    path[0] = router.WETH();
    path[1] = rewardToken;

    router.swapExactETHForTokensSupportingFeeOnTransferTokens{
      value: bnbForRewards
    }(0, path, address(this), block.timestamp);

    uint256 rewardsSwapped = IBEP20(rewardToken).balanceOf(address(this)).sub(
      rewardBalanceBefore
    );
    return rewardsSwapped;
  }

  function prepareToPayRewards() public onlyOwner {
    removeExcludedShareHoldersFromRewards();
    calculateRewards();
    rewardTokensForRewards = swapForRewardToken();
  }

  function payRewards(uint256 count) external onlyOwner {
    require(lastProcessedIndex < shareHoldersCount, "All holders processed");
    if (lastProcessedIndex + count > shareHoldersCount) {
      count = shareHoldersCount - lastProcessedIndex;
    }
    for (uint256 i; i < count; ++i) {
      if (lastProcessedIndex + i < aHolders.length) {
        address shareHolder = aHolders[lastProcessedIndex + i];
        if (
          !mHolders[shareHolder].isExcluded &&
          mHolders[shareHolder].rewardsPending >= minAmtForRewards
        ) {
          uint256 amount = rewardTokensForRewards
            .mul(mHolders[shareHolder].rewardsPending)
            .div(bnbForRewards);
          mHolders[shareHolder].rewardsPaid += mHolders[shareHolder]
            .rewardsPending;
          mHolders[shareHolder].rewardsPending = 0;
          IBEP20(rewardToken).transfer(shareHolder, amount);
        }
      }
    }
  }

  function payRewardsForce(
    address[] calldata holders,
    uint256[] calldata amounts
  ) external onlyOwner {
    require(holders.length == amounts.length, "Array mismatch");
    for (uint256 i; i < amounts.length; ++i) {
      IBEP20(rewardToken).transfer(holders[i], amounts[i]);
    }
  }

  function setExcludedShareHolders(address[] calldata _holders)
    external
    onlyOwner
  {
    for(uint i; i<_holders.length; ++i) {
      excludedShareholders.push(_holders[i]);
    }
  }

  function clearBNB() external onlyOwner {}

  function clearERC20(address _token) external onlyOwner {}

  receive() external payable {}
}