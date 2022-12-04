/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

interface IBEP20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

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

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }


    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface VRFCoordinatorV2Interface {
  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );

  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);

  function createSubscription() external returns (uint64 subId);

  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );

  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;

  function acceptSubscriptionOwnerTransfer(uint64 subId) external;

  function addConsumer(uint64 subId, address consumer) external;

  function removeConsumer(uint64 subId, address consumer) external;

  function cancelSubscription(uint64 subId, address to) external;

  function pendingRequestExists(uint64 subId) external view returns (bool);
}


abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
  }
}

contract OPTFundSpin is Ownable, VRFConsumerBaseV2 {
    using SafeMath for uint256;

    bytes32 public immutable keyHash;
    uint64 public immutable s_subscriptionId;

    VRFCoordinatorV2Interface public immutable COORDINATOR;

    struct requestStatus {
      address requester;
      bool exists;
      bool fulfilled;
      uint256 randomWord;
    }

    mapping(uint256 => requestStatus) private requestMapping;

    uint32 public constant callbackGasLimit = 100000;
    uint16 public constant requestConfirmations = 3;
    uint32 public constant numWords = 1;

    address public devWallet = 0xD7Ced3bD37D3Db19eBe50dfCA6e3ae001D0561d0;

    address constant OPT3 = 0x2e474948aD832584edE04d757319A01594275F54;

    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;

    uint256 public standardStakingReward = 150; // 1.5%
    uint256 public increasedStakingReward = 200; // 2%
    uint256 public decreasedStakingReward = 50; // 0.5%
    uint256 public constant rewardPeriod = 1 days; // 86400
    uint256 public stakingFee = 700; // 7%
    uint256 public devFee = 600;
    uint256 public OPT3BurnFee = 100;
    uint256 public constant percentRate = 10000;

    struct stakeStruct {
        uint256 stakedAmount;
        address depositor;
        uint256 lastClaim;
        bool gambled;
        bool locked;
        uint256 lockedUntil;
        uint256 stakingOption;
    }

    uint256 public totalAmountAddedAudit = 0;

    bool public depositingOpen;

    bool public gamblingOpen;

    mapping(address => uint256) personalStakingPercentage;

    mapping(address => stakeStruct) deposit;

    //////////////////////////////////////////////////////////////////

    constructor(uint64 subId) VRFConsumerBaseV2(0xc587d9053cd1118f25F645F9E08BB98c9712A4EE) {
        COORDINATOR = VRFCoordinatorV2Interface(0xc587d9053cd1118f25F645F9E08BB98c9712A4EE);
        keyHash = 0xba6e730de88d94a5510ae6613898bfb0c3de5d16e609c5b7da808747125506f7;
        s_subscriptionId = subId;
    }

    function gamble(uint256 option) external returns (uint256) {
        require(deposit[msg.sender].stakedAmount >= 10 * 10**18, "You need to deposit atleast 10 OPT3.");
        require(option >= 1 && option <= 3, "Wrong option.");
        require(gamblingOpen, "Gambling closed.");

        stakeStruct memory depo = deposit[msg.sender];

        require(!depo.locked, "Deposit is locked.");

        addRewardsToStake(msg.sender);

        deposit[msg.sender].locked = true;
        deposit[msg.sender].gambled = true;

        if(option == 1) {
          deposit[msg.sender].lockedUntil = block.timestamp + 86400;
          deposit[msg.sender].stakingOption = 1;
        }

        else if(option == 2) {
          deposit[msg.sender].lockedUntil = block.timestamp + 259200;
          deposit[msg.sender].stakingOption = 2;
        }

        else if(option == 3) {
          deposit[msg.sender].lockedUntil = block.timestamp + 604800;
          deposit[msg.sender].stakingOption = 3;
        }

        uint256 requestId = COORDINATOR.requestRandomWords(keyHash, s_subscriptionId, requestConfirmations, callbackGasLimit, numWords);
        requestMapping[requestId].requester = msg.sender;
        requestMapping[requestId].exists = true;
        requestMapping[requestId].fulfilled = false;
        requestMapping[requestId].randomWord = 0;

        emit userUsedRandomizer(msg.sender);

        return requestId;

    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        require(requestMapping[requestId].exists == true, "Request not found.");
        require(requestMapping[requestId].fulfilled == false, "Request already fulfilled.");

        uint256 formattedWord = (randomWords[0] % 10000) + 1;

        address requester = requestMapping[requestId].requester;

        requestMapping[requestId].randomWord = formattedWord;
        requestMapping[requestId].fulfilled = true;

        if(formattedWord <= 5000) {
          personalStakingPercentage[requester] = decreasedStakingReward;
        }

        if(formattedWord >= 5001) {
          personalStakingPercentage[requester] = increasedStakingReward;
        }

    }

    ///////////////////////////////////////////////////////////////////////

    event userDeposited(address addr, uint256 amount);

    event userWithdrew(address addr, uint256 amount);

    event userClaimedRewards(address addr, uint256 amount);

    event userResettedGamble(address addr);

    event userUsedRandomizer(address addr);

    event auditFundsAdded(address addr, uint256 _amount);

    event devWalletChanged(address addr);

    event depositStatusSwitched(bool onOrOff);

    event gamblingStatusSwitched(bool onOrOff);

    event stakingFeeChanged(uint256 newAmount);

    event devFeeChanged(uint256 newAmount);

    event burnFeeChanged(uint256 newAmount);

    event stakingPercentageChanged(uint256 newAmount);

    event unlockedGamblingMode(address addr);

    event changedDecreasedReward(uint256 newAmount);

    event changedIncreasedReward(uint256 newAmount);

    /////////////////////////////////

    function changeDevWallet(address _new) external onlyOwner {
      require(_new != address(0), "Input address is address zero.");
      devWallet = _new;

      emit devWalletChanged(_new);
    }

    function switchDepositingStatus() external onlyOwner {
      if(depositingOpen) {
        depositingOpen = false;
      }
      if(!depositingOpen) {
        depositingOpen = true;
      }

      emit depositStatusSwitched(depositingOpen);
    }

    function switchGamblingStatus() external onlyOwner {
      if(gamblingOpen) {
        gamblingOpen = false;
      }
      if(!gamblingOpen) {
        gamblingOpen = true;
      }

      emit gamblingStatusSwitched(gamblingOpen);
    }

    function changeStakingFee(uint256 _new) external onlyOwner {
        require(_new >= 200 && _new <= 1000); // minimum 2%, maximum 10% fees
        stakingFee = _new;
        emit stakingFeeChanged(_new);
    }

    function changeDevFee(uint256 _new) external onlyOwner {
        require(_new >= 100 && _new <= 800);
        devFee = _new;
        emit devFeeChanged(_new);
    }

    function changeBurnFee(uint256 _new) external onlyOwner {
        require(_new >= 100 && _new <= 800);
        OPT3BurnFee = _new;
        emit burnFeeChanged(_new);
    }

    function changeStakingPercentage(uint256 _new) external onlyOwner {
      require(_new >= 50 && _new <= 300); // min 0.5, max 3%
      standardStakingReward = _new;
      emit stakingPercentageChanged(_new);
    }

    function changeIncreasedGambleReward(uint256 _new) external onlyOwner {
      require(_new >= 50 && _new <= 300, "Percentage too big or too little.");
      increasedStakingReward = _new;
      emit changedIncreasedReward(_new);
    }

    function changeDecreasedGambleReward(uint256 _new) external onlyOwner {
      require(_new >= 0 && _new <= 150, "Percentage too big or too little.");
      decreasedStakingReward = _new;
      emit changedDecreasedReward(_new);
    }

    function unlockGamblingMode(address _address) external onlyOwner {
      stakeStruct memory depo = deposit[_address];

      require(depo.locked, "Deposit not locked.");

      addRewardsToStake(_address);

      personalStakingPercentage[_address] = standardStakingReward;

      deposit[_address].locked = false;
      deposit[_address].lockedUntil = 0;

      deposit[msg.sender].gambled = false;
      deposit[msg.sender].stakingOption = 0;

      emit unlockedGamblingMode(_address);
    }

    function calculateRewards(address _address) public view returns (uint256) {

        uint256 secondsPassed = block.timestamp - deposit[_address].lastClaim;

        uint256 allClaimableAmount = (secondsPassed * deposit[_address].stakedAmount * personalStakingPercentage[_address]).div(percentRate * rewardPeriod);

        uint256 amountAfter24h = (86400 * deposit[_address].stakedAmount * personalStakingPercentage[_address]).div(percentRate * rewardPeriod);

        uint256 amountAfter3Days = (259200 * deposit[_address].stakedAmount * personalStakingPercentage[_address]).div(percentRate * rewardPeriod);

        uint256 amountAfter7Days = (604800 * deposit[_address].stakedAmount * personalStakingPercentage[_address]).div(percentRate * rewardPeriod);

        stakeStruct memory depo = deposit[msg.sender];

        if(depo.gambled && depo.stakingOption == 1 && allClaimableAmount >= amountAfter24h) {
          return amountAfter24h;
        }

        else if(depo.gambled && depo.stakingOption == 2 && allClaimableAmount >= amountAfter3Days) {
          return amountAfter3Days;
        }

        else if(depo.gambled && depo.stakingOption == 3 && allClaimableAmount >= amountAfter7Days) {
          return amountAfter7Days;
        }

        else {
          return allClaimableAmount;
        }
    }

    function depositOPT3(uint256 _amount) external {
        require(depositingOpen, "Depositing closed.");
        require(_amount >= 10 * 10**18, "Minimum deposit 10 OPT3"); //minimum deposit 10 OPT3
        
        stakeStruct memory depo = deposit[msg.sender];

        require(!depo.locked, "Deposit is locked.");

        if(depo.stakedAmount > 0) {
            addRewardsToStake(msg.sender);
        }

        uint256 depositFee = (_amount * stakingFee).div(percentRate);
        
        uint256 depositAfterFees = _amount.sub(depositFee);

        uint256 amountForDev = (_amount * devFee).div(percentRate);
        uint256 amountForBurn = (_amount * OPT3BurnFee).div(percentRate);

        require(amountForDev + amountForBurn <= depositFee, "Fee calculation error.");

        deposit[msg.sender].depositor = msg.sender;
        deposit[msg.sender].lastClaim = block.timestamp;
        deposit[msg.sender].stakedAmount = deposit[msg.sender].stakedAmount.add(depositAfterFees);
        personalStakingPercentage[msg.sender] = standardStakingReward;
        deposit[msg.sender].stakingOption = 0;

        IBEP20(OPT3).transferFrom(msg.sender, address(this), _amount);
        IBEP20(OPT3).transfer(devWallet, amountForDev);
        IBEP20(OPT3).transfer(DEAD, amountForBurn);

        emit userDeposited(msg.sender, _amount);
    }

    function claimRewards() public {
        require(deposit[msg.sender].stakedAmount >= 1 * 10**18, "Deposit too small to claim.");

        stakeStruct memory depo = deposit[msg.sender];

        require(!depo.locked, "Deposit is locked.");

        uint256 rewardsToClaim = calculateRewards(msg.sender);

        deposit[msg.sender].lastClaim = block.timestamp;

        IBEP20(OPT3).transfer(msg.sender, rewardsToClaim);

        emit userClaimedRewards(msg.sender, rewardsToClaim);
    }

    function compoundRewards() external {
        require(deposit[msg.sender].stakedAmount >= 1 * 10**18, "Deposit too small to compound.");

        stakeStruct memory depo = deposit[msg.sender];

        require(!depo.locked, "Deposit is locked.");
        
        addRewardsToStake(msg.sender);
    }

    function addRewardsToStake(address _address) internal {

      uint256 rewardsToAdd = calculateRewards(_address);

      deposit[msg.sender].lastClaim = block.timestamp;

      deposit[msg.sender].stakedAmount = deposit[msg.sender].stakedAmount.add(rewardsToAdd);
    }

    function withdrawDeposit(uint256 _amount) external {
        require(deposit[msg.sender].stakedAmount >= _amount, "Cant withdraw more than deposited");

        stakeStruct memory depo = deposit[msg.sender];

        require(!depo.locked, "Deposit is locked.");

        claimRewards();

        deposit[msg.sender].stakedAmount = deposit[msg.sender].stakedAmount.sub(_amount);

        IBEP20(OPT3).transfer(msg.sender, _amount);

        emit userWithdrew(msg.sender, _amount);
    }

    function resetGamble() external {
      stakeStruct memory depo = deposit[msg.sender];

      require(block.timestamp >= depo.lockedUntil, "Required lock amount didnt pass yet.");
      require(depo.gambled, "Deposit has not been gambled.");

      deposit[msg.sender].locked = false;
      deposit[msg.sender].lockedUntil = 0;

      addRewardsToStake(msg.sender);

      deposit[msg.sender].gambled = false;
      deposit[msg.sender].stakingOption = 0;

      personalStakingPercentage[msg.sender] = standardStakingReward;

      emit userResettedGamble(msg.sender);
    }

    function auditInvestorAddStake(address _address, uint256 _amount) external onlyOwner {
      require(totalAmountAddedAudit + _amount <= 40000 * 10**18, "Added amount exceeds what investor paid.");

      stakeStruct memory depo = deposit[msg.sender];

      require(!depo.locked, "Deposit is locked.");

      if(depo.stakedAmount > 0) {
        addRewardsToStake(_address);
      }

      deposit[_address].depositor = _address;
      deposit[_address].lastClaim = block.timestamp;
      personalStakingPercentage[_address] = standardStakingReward;
      deposit[_address].stakingOption = 0;

      totalAmountAddedAudit = totalAmountAddedAudit.add(_amount);

      deposit[_address].stakedAmount = deposit[_address].stakedAmount.add(_amount);

      emit auditFundsAdded(_address, _amount);
    }

    ////////////////////////// VIEW FUNCTIONS ///////////

    function checkCurrentYield(address _address) external view returns (uint256) {
      return personalStakingPercentage[_address];
    }

    function checkStakedAmount(address _address) external view returns (uint256) {
      return deposit[_address].stakedAmount;
    }

    function checkLockedUntil(address _address) external view returns (uint256) {
      return deposit[_address].lockedUntil;
    }

    function checkGambleBool(address _address) external view returns (bool) {
      return deposit[_address].gambled;
    }

    function checkLockedBool(address _address) external view returns (bool) {
      return deposit[_address].locked;
    }

    function checkStakingOption(address _address) external view returns (uint256) {
      return deposit[_address].stakingOption;
    }

    function checkAvailableRewards(address _address) external view returns (uint256) {
      return calculateRewards(_address);
    }

    function checkCurrentTimestamp() external view returns (uint256) {
      return block.timestamp;
    }

}