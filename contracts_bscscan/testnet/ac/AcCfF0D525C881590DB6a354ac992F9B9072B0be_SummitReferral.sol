pragma solidity =0.6.6;
pragma experimental ABIEncoderV2;

import "./libraries/SafeMath2.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/ISummitswapRouter02.sol";

import "./shared/Ownable.sol";

// TODO: Explain scheme - and maybe simplify a little bit
// TODO: Ask - promotions only work for noninfluencers
// TODO: Add functions to simply set 1 field in feeInfo
struct FeeInfo {
  address tokenR;
  uint256 refFee;
  uint256 devFee;
  uint256 promRefFee;
  uint256 promStart;
  uint256 promEnd;
}

struct InfInfo {
  address lead;
  uint256 leadFee;
  uint256 refFee;
  bool isActive;
  bool isLead;
}

// We don't consider refferee first time fees in totalReward to notify project owner
contract SummitReferral is Ownable {
  using SafeMath for uint256;

  uint256 public feeDenominator = 1000000000;

  address public summitswapRouter;
  address public pancakeswapRouter;
  address public devAddr;
  address public kapex;
  address public busd;
  address public wbnb;

  mapping(address => mapping(address => bool)) public isManager; // output token => manager => is manager

  mapping(address => FeeInfo) public feeInfo; // output token => fee info
  mapping(address => uint256) public firstBuyRefereeFee; // output token => first buy referee fee
  mapping(address => mapping(address => bool)) public isFirstBuy; // output token => referee => is first buy

  mapping(address => mapping(address => InfInfo)) public influencers; // output token token => influencer => influencer info
  mapping(address => mapping(address => address)) public subInfluencerAcceptedLead; // output token token => sub influencer => lead influencer
  mapping(address => mapping(address => address)) public referrers; // output token => referee => referrer

  mapping(address => mapping(address => uint256)) public balances; // reward token => user => amount
  mapping(address => address[]) public hasBalance; // user => list of reward tokens he has balance on
  mapping(address => mapping(address => uint256)) public hasBalanceIndex; // reward token => user => array index in hasBalance
  mapping(address => mapping(address => bool)) public isBalanceIndex; // reward token => user => has array index in hasBalance or not

  mapping(address => uint256) public totalReward; // reward token => total reward

  mapping(address => uint256) public claimingFee; // claim token => claiming fee

  // Removed maps
  // mapping(address => uint256) public referralsCount; // referrer address => referrals count
  // mapping(address => bool) private rewardEnabled;
  // address[] private rewardTokens;

  // TODO: Add ReferralRecorded into unit tests
  event ReferralRecorded(address indexed referee, address indexed referrer, address indexed outputToken);

  // TODO: Add ReferralReward into unit tests
  event ReferralReward(
    address indexed referrer,
    address indexed lead,
    uint256 timestamp,
    address inputToken,
    address outputToken,
    uint256 inputTokenAmount,
    uint256 outputTokenAmount,
    uint256 referrerReward,
    uint256 leadReward,
    uint256 devReward
  );

  modifier onlySummitswapRouter() {
    require(msg.sender == summitswapRouter, "Caller is not the router");
    _;
  }

  modifier onlyManager(address _outputToken) {
    require(
      msg.sender == owner() || isManager[_outputToken][msg.sender] == true,
      "Caller is not the manager of specified token"
    );
    _;
  }

  modifier onlyLeadInfluencer(address _outputToken, address _user) {
    require(influencers[_outputToken][msg.sender].isActive == true, "You aren't lead influencer on this output token");
    require(influencers[_outputToken][msg.sender].isLead == true, "You aren't lead influencer on this output token");
    require(
      subInfluencerAcceptedLead[_outputToken][_user] == msg.sender,
      "This user didn't accept you as a lead influencer"
    );
    _;
  }

  constructor(
    address _devAddr,
    address _summitswapRouter,
    address _pancakeswapRouter,
    address _kapex,
    address _busd
  ) public {
    devAddr = _devAddr;
    summitswapRouter = _summitswapRouter;
    pancakeswapRouter = _pancakeswapRouter;
    kapex = _kapex;
    busd = _busd;
    wbnb = ISummitswapRouter02(_summitswapRouter).WETH();
  }

  receive() external payable {}

  function setDevAddress(address _devAddr) external onlyOwner {
    devAddr = _devAddr;
  }

  function setSummitswapRouter(address _summitswapRouter) external onlyOwner {
    summitswapRouter = _summitswapRouter;
  }

  function setPancakeswapRouter(address _pancakeswapRouter) external onlyOwner {
    pancakeswapRouter = _pancakeswapRouter;
  }

  function setKapex(address _kapex) external onlyOwner {
    kapex = _kapex;
  }

  function getBalancesLength(address _user) external view returns (uint256) {
    return hasBalance[_user].length;
  }

  function setClaimingFee(address _claimToken, uint256 _fee) external onlyOwner {
    claimingFee[_claimToken] = _fee;
  }

  function setFirstBuyFee(address _outputToken, uint256 _fee) external onlyManager(_outputToken) {
    require(_fee <= feeDenominator, "Wrong Fee");
    firstBuyRefereeFee[_outputToken] = _fee;
  }

  function setManager(
    address _outputToken,
    address _manager,
    bool _isManager
  ) external onlyOwner {
    isManager[_outputToken][_manager] = _isManager;
  }

  // Don't use WBNB as a outputToken
  function setFeeInfo(
    address _outputToken,
    address _rewardToken,
    uint256 _refFee,
    uint256 _devFee,
    uint256 _promRefFee,
    uint256 _promStart,
    uint256 _promEnd
  ) external onlyManager(_outputToken) {
    require(_refFee + _devFee <= feeDenominator, "Wrong Fee");

    feeInfo[_outputToken].tokenR = _rewardToken;
    feeInfo[_outputToken].refFee = _refFee;
    feeInfo[_outputToken].devFee = _devFee;
    feeInfo[_outputToken].promRefFee = _promRefFee;
    feeInfo[_outputToken].promStart = _promStart;
    feeInfo[_outputToken].promEnd = _promEnd;
  }

  // Improvement: Revert if some conditions are not met
  function recordReferral(address _outputToken, address _referrer) external {
    require(_referrer != msg.sender, "You can't refer yourself");
    require(_referrer != address(0), "You can't use burn address as a refferer");
    require(referrers[_outputToken][msg.sender] == address(0), "You are already referred on this token");

    referrers[_outputToken][msg.sender] = _referrer;
    // referralsCount[_referrer] += 1;
    emit ReferralRecorded(msg.sender, _referrer, _outputToken);
  }

  // Improvement: In the previous version it was impossible to provote subInfluencer to be leadInfluencer
  function setLeadInfluencer(
    address _outputToken,
    address _user,
    uint256 _leadFee
  ) external onlyManager(_outputToken) {
    require(_leadFee <= feeDenominator, "Wrong Fee");

    influencers[_outputToken][_user].lead = address(0);
    influencers[_outputToken][_user].leadFee = _leadFee;
    influencers[_outputToken][_user].refFee = 0;
    influencers[_outputToken][_user].isActive = true;
    influencers[_outputToken][_user].isLead = true;
  }

  // Improvement: In the previous version we did not even check in swap function if leadInfluencer was active or not
  function removeLeadInfluencer(address _outputToken, address _lead) external onlyManager(_outputToken) {
    influencers[_outputToken][_lead].isLead = false;
    influencers[_outputToken][_lead].isActive = false;
  }

  function acceptLeadInfluencer(address _outputToken, address _leadInfluencer) external {
    subInfluencerAcceptedLead[_outputToken][msg.sender] = _leadInfluencer;
  }

  // Improvement: In the previous version sub influencer wasn't able to change lead influencer
  function setSubInfluencer(
    address _outputToken,
    address _user,
    uint256 _leadFee,
    uint256 _infFee
  ) external onlyLeadInfluencer(_outputToken, _user) {
    require(influencers[_outputToken][_user].isLead == false, "User is already lead influencer on this output token");
    require(_leadFee + _infFee == feeDenominator, "Wrong Fee");

    influencers[_outputToken][_user].isActive = true;
    influencers[_outputToken][_user].lead = msg.sender;
    influencers[_outputToken][_user].refFee = _infFee;
    influencers[_outputToken][_user].leadFee = _leadFee;
  }

  // Improvement: In the previous version we weren't able to remove subInfluencers
  function removeSubInfluencer(address _outputToken, address _user) external {
    require(
      influencers[_outputToken][_user].lead == msg.sender,
      "This user is added by another lead on this output token"
    );

    influencers[_outputToken][_user].isActive = false;
  }

  function claimRewardIn(address _outputToken, address _claimToken) public {
    require(
      _claimToken == _outputToken ||
        _claimToken == busd ||
        _claimToken == wbnb ||
        _claimToken == kapex ||
        _claimToken == feeInfo[_outputToken].tokenR,
      "You can't claim in that token"
    );

    uint256 balance = balances[_outputToken][msg.sender];

    require(balance > 0, "Insufficient balance");

    balances[_outputToken][msg.sender] = 0;
    isBalanceIndex[_outputToken][msg.sender] = false;
    uint256 rewardTokenIndex = hasBalanceIndex[_outputToken][msg.sender];
    address lastToken = hasBalance[msg.sender][hasBalance[msg.sender].length - 1];
    hasBalanceIndex[lastToken][msg.sender] = rewardTokenIndex;
    hasBalance[msg.sender][rewardTokenIndex] = lastToken;
    hasBalance[msg.sender].pop();
    totalReward[_outputToken] -= balance;

    // TODO: Test claiming fee

    uint256 rewardInClaimingTokenAmount = convertOutputToReward(_outputToken, balance, _claimToken);
    uint256 claimFee = rewardInClaimingTokenAmount.mul(claimingFee[_claimToken]).div(feeDenominator);
    uint256 totalClaimableAmount = rewardInClaimingTokenAmount - claimFee;

    if (_claimToken == ISummitswapRouter02(summitswapRouter).WETH()) {
      payable(msg.sender).transfer(totalClaimableAmount);

      if (claimFee != 0) {
        payable(devAddr).transfer(claimFee);
      }
    } else {
      IERC20(_claimToken).transfer(msg.sender, totalClaimableAmount);

      if (claimFee != 0) {
        IERC20(_claimToken).transfer(devAddr, claimFee);
      }
    }
  }

  function claimAllRewardsIn(address _claimToken) external {
    uint256 hasBalanceLength = hasBalance[msg.sender].length;
    for (uint256 i = 0; i < hasBalanceLength; i++) {
      claimRewardIn(hasBalance[msg.sender][0], _claimToken);
    }
  }

  function claimAllRewardsInOutput() external {
    uint256 hasBalanceLength = hasBalance[msg.sender].length;
    for (uint256 i = 0; i < hasBalanceLength; i++) {
      claimRewardIn(hasBalance[msg.sender][0], hasBalance[msg.sender][0]);
    }
  }

  function swap(
    address _outputToken,
    uint256 _outputTokenAmount,
    uint256 amountOut,
    address router,
    address[] memory path
  ) internal {
    IERC20(_outputToken).approve(router, _outputTokenAmount);

    if (path[path.length - 1] == wbnb) {
      ISummitswapRouter02(router).swapExactTokensForETH(
        _outputTokenAmount,
        amountOut,
        path,
        address(this),
        block.timestamp
      );
    } else {
      ISummitswapRouter02(router).swapExactTokensForTokens(
        _outputTokenAmount,
        amountOut,
        path,
        address(this),
        block.timestamp
      );
    }
  }

  function convertOutputToReward(
    address _outputToken,
    uint256 _outputTokenAmount,
    address _claimToken
  ) internal returns (uint256) {
    if (_outputToken == _claimToken) {
      return _outputTokenAmount;
    }

    if (_claimToken == wbnb) {
      address[] memory summitPath = new address[](2);
      summitPath[0] = _outputToken;
      summitPath[1] = wbnb;
      uint256 summitAmountsOut = ISummitswapRouter02(summitswapRouter).getAmountsOut(_outputTokenAmount, summitPath)[1];

      if (pancakeswapRouter == address(0)) {
        swap(_outputToken, _outputTokenAmount, summitAmountsOut, summitswapRouter, summitPath);
        return summitAmountsOut;
      }

      address[] memory pancakePath = new address[](2);
      pancakePath[0] = _outputToken;
      pancakePath[1] = wbnb;
      uint256 pancakeAmountsOut;
      try ISummitswapRouter02(pancakeswapRouter).getAmountsOut(_outputTokenAmount, pancakePath) returns (
        uint256[] memory amounts
      ) {
        pancakeAmountsOut = amounts[1];
      } catch {}

      if (summitAmountsOut >= pancakeAmountsOut) {
        swap(_outputToken, _outputTokenAmount, summitAmountsOut, summitswapRouter, summitPath);
        return summitAmountsOut;
      } else {
        swap(_outputToken, _outputTokenAmount, pancakeAmountsOut, pancakeswapRouter, pancakePath);
        return pancakeAmountsOut;
      }
    }

    address[] memory summitPath = new address[](3);
    summitPath[0] = _outputToken;
    summitPath[1] = wbnb;
    summitPath[2] = _claimToken;
    uint256 summitAmountsOut = ISummitswapRouter02(summitswapRouter).getAmountsOut(_outputTokenAmount, summitPath)[2];

    if (pancakeswapRouter == address(0)) {
      swap(_outputToken, _outputTokenAmount, summitAmountsOut, summitswapRouter, summitPath);
      return summitAmountsOut;
    }

    address[] memory pancakePath = new address[](3);
    pancakePath[0] = _outputToken;
    pancakePath[1] = wbnb;
    pancakePath[2] = _claimToken;
    uint256 pancakeAmountsOut;
    try ISummitswapRouter02(pancakeswapRouter).getAmountsOut(_outputTokenAmount, pancakePath) returns (
      uint256[] memory amounts
    ) {
      pancakeAmountsOut = amounts[2];
    } catch {}

    if (summitAmountsOut >= pancakeAmountsOut) {
      swap(_outputToken, _outputTokenAmount, summitAmountsOut, summitswapRouter, summitPath);
      return summitAmountsOut;
    } else {
      swap(_outputToken, _outputTokenAmount, pancakeAmountsOut, pancakeswapRouter, pancakePath);
      return pancakeAmountsOut;
    }
  }

  function increaseBalance(
    address _user,
    address _rewardToken,
    uint256 _amount
  ) internal {
    if (_amount == 0) {
      return;
    }

    if (isBalanceIndex[_rewardToken][_user] == false) {
      hasBalanceIndex[_rewardToken][_user] = hasBalance[_user].length;
      isBalanceIndex[_rewardToken][_user] = true;
      hasBalance[_user].push(_rewardToken);
    }
    balances[_rewardToken][_user] += _amount;
  }

  function swap(
    address _user,
    address _inputToken,
    address _outputToken,
    uint256 _inputTokenAmount,
    uint256 _outputTokenAmount
  ) external onlySummitswapRouter {
    address referrer = referrers[_outputToken][_user];

    if (referrer == address(0)) {
      return;
    }

    // if (rewardEnabled[rewardToken] == false) {
    //   rewardEnabled[rewardToken] = true;
    //   rewardTokens.push(rewardToken);
    // }

    uint256 amountR;
    uint256 amountL;

    address leadInfluencer = influencers[_outputToken][referrer].lead;

    if (block.timestamp >= feeInfo[_outputToken].promStart && block.timestamp <= feeInfo[_outputToken].promEnd) {
      amountR = _outputTokenAmount.mul(feeInfo[_outputToken].promRefFee).div(feeDenominator);
    } else {
      amountR = _outputTokenAmount.mul(feeInfo[_outputToken].refFee).div(feeDenominator);
    }

    if (influencers[_outputToken][referrer].isActive && influencers[_outputToken][referrer].isLead) {
      amountR += _outputTokenAmount.mul(influencers[_outputToken][referrer].leadFee).div(feeDenominator);
    } else if (influencers[_outputToken][leadInfluencer].isActive && influencers[_outputToken][leadInfluencer].isLead) {
      uint256 amountI = _outputTokenAmount.mul(influencers[_outputToken][leadInfluencer].leadFee).div(feeDenominator);

      amountL = amountI.mul(influencers[_outputToken][referrer].leadFee).div(feeDenominator);
      amountR += amountI.mul(influencers[_outputToken][referrer].refFee).div(feeDenominator);

      increaseBalance(leadInfluencer, _outputToken, amountL);
    }

    if (isFirstBuy[_outputToken][_user] == false) {
      isFirstBuy[_outputToken][_user] = true;
      uint256 amountU = _outputTokenAmount.mul(firstBuyRefereeFee[_outputToken]).div(feeDenominator);
      IERC20(_outputToken).transfer(_user, amountU);
    }

    increaseBalance(referrer, _outputToken, amountR);

    uint256 amountD = _outputTokenAmount.mul(feeInfo[_outputToken].devFee).div(feeDenominator);
    increaseBalance(devAddr, _outputToken, amountD);

    totalReward[_outputToken] += amountL + amountR + amountD;

    emit ReferralReward(
      referrer,
      leadInfluencer,
      block.timestamp,
      _inputToken,
      _outputToken,
      _inputTokenAmount,
      _outputTokenAmount,
      amountR,
      amountL,
      amountD
    );
  }
}

pragma solidity =0.6.6;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

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
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }
}

pragma solidity >=0.5.0;

interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity >=0.6.2;

import "./ISummitswapRouter01.sol";

interface ISummitswapRouter02 is ISummitswapRouter01 {
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

  // Supporting Fee cause We are sending fee
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

pragma solidity =0.6.6;

contract Ownable {
  address private _owner;

  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  function isOwner(address account) public view returns (bool) {
    return account == _owner;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  modifier onlyOwner() {
    require(isOwner(msg.sender), "Ownable: caller is not the owner");
    _;
  }

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}

pragma solidity >=0.6.2;

interface ISummitswapRouter01 {
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