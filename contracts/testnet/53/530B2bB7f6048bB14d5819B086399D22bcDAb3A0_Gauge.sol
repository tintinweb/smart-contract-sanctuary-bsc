/**
 * @title Gauge
 * @dev Gauge.sol contract
 *
 * @author - <USDFI TRUST>
 * for the USDFI Trust
 *
 * SPDX-License-Identifier: Business Source License 1.1
 *
 **/

pragma solidity =0.8.11;

import "./SafeERC20.sol";
import "./Math.sol";
import "./ReentrancyGuard.sol";
import "./IBasePair.sol";
import "./IBaseFactory.sol";
import "./IBribe.sol";
import "./IGaugeFactory.sol";
import "./IReferrals.sol";

contract Gauge is ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public STABLE;
    IERC20 public veSTABLE;

    IERC20 public immutable TOKEN;
    address private token;
    address public immutable DISTRIBUTION;
    uint256 public constant DURATION = 7 days;

    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    uint256 public fees0;
    uint256 public fees1;

    address public gaugeFactory;
    address public referralContract;
    address public zapContract;

    mapping(address => mapping(address => bool)) public whitelisted;
    mapping(address => uint256) public earnedRefs;

    /**
     * @dev Outputs the fee variables.
     */
    uint256 public referralFee;
    uint256[] public refLevelPercent = [6000, 3000, 1000];

    modifier onlyDistribution() {
        require(
            msg.sender == DISTRIBUTION,
            "Caller is not RewardsDistribution contract"
        );
        _;
    }

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    uint256 private _totalSupply;
    uint256 public derivedSupply;
    mapping(address => uint256) private _balances;
    mapping(address => uint256) public derivedBalances;
    mapping(address => uint256) private _base;

    constructor(
        address _stable,
        address _veStable,
        address _token,
        address _gaugeFactory
    ) public {
        STABLE = IERC20(_stable);
        veSTABLE = IERC20(_veStable);
        TOKEN = IERC20(_token);
        token = _token;
        gaugeFactory = _gaugeFactory;
        DISTRIBUTION = msg.sender;
        referralContract = IGaugeFactory(gaugeFactory).baseReferralsContract();
        referralFee = IGaugeFactory(gaugeFactory).baseReferralFee();
    }

    function claimVotingFees()
        external
        nonReentrant
        returns (uint256 claimed0, uint256 claimed1)
    {
        return _claimVotingFees();
    }

    function _claimVotingFees()
        internal
        returns (uint256 claimed0, uint256 claimed1)
    {
        (claimed0, claimed1) = IBaseV1Pair(address(TOKEN)).claimFees();
        address bribe = IGaugeFactory(gaugeFactory).bribes(address(this));
        if (claimed0 > 0 || claimed1 > 0) {
            uint256 _fees0 = fees0 + claimed0;
            uint256 _fees1 = fees1 + claimed1;
            (address _token0, address _token1) = IBaseV1Pair(address(TOKEN))
                .tokens();
            if (_fees0 > IBribe(bribe).left(_token0) && _fees0 / DURATION > 0) {
                fees0 = 0;
                IERC20(_token0).safeApprove(bribe, _fees0);
                IBribe(bribe).notifyRewardAmount(_token0, _fees0);
            } else {
                fees0 = _fees0;
            }
            if (_fees1 > IBribe(bribe).left(_token1) && _fees1 / DURATION > 0) {
                fees1 = 0;
                IERC20(_token1).safeApprove(bribe, _fees1);
                IBribe(bribe).notifyRewardAmount(_token1, _fees1);
            } else {
                fees1 = _fees1;
            }

            emit ClaimVotingFees(msg.sender, claimed0, claimed1);
        }
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (derivedSupply == 0) {
            return 0;
        }

        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored +
            (((lastTimeRewardApplicable() - lastUpdateTime) *
                rewardRate *
                1e18) / derivedSupply);
    }

    function derivedBalance(address account) public view returns (uint256) {
        if (IGaugeFactory(gaugeFactory).weights(token) == 0) return 0;
        uint256 _balance = _balances[account];
        uint256 _derived = (_balance * 40) / 100;
        uint256 _adjusted = ((((_totalSupply *
            IGaugeFactory(gaugeFactory).votes(account, token)) /
            IGaugeFactory(gaugeFactory).weights(token)) * 60) / 100);
        // uint256 _adjusted = (_totalSupply * veSTABLE.balanceOf(account) / veSTABLE.totalSupply()) * 60 / 100;
        return Math.min(_derived + _adjusted, _balance);
    }

    function kick(address account) public {
        uint256 _derivedBalance = derivedBalances[account];
        derivedSupply = derivedSupply - _derivedBalance;
        _derivedBalance = derivedBalance(account);
        derivedBalances[account] = _derivedBalance;
        derivedSupply = derivedSupply + _derivedBalance;
    }

    function earned(address account) public view returns (uint256) {
        return
            ((derivedBalances[account] *
                (rewardPerToken() - userRewardPerTokenPaid[account])) / 1e18) +
            rewards[account];
    }

    function getRewardForDuration() external view returns (uint256) {
        return rewardRate * DURATION;
    }

    function deposit(uint256 amount) external {
        _deposit(amount, msg.sender);
    }

    function depositWithNewRef(uint256 amount, address _sponsor) external {
        _deposit(amount, msg.sender);
        _newRef(_sponsor);
    }

    function depositFor(uint256 amount, address account) external {
        _deposit(amount, account);
    }

    function _deposit(uint256 amount, address account)
        internal
        nonReentrant
        updateReward(account)
    {
        require(amount > 0, "deposit(Gauge): cannot stake 0");

        uint256 userAmount = amount;

        _balances[account] = _balances[account] + userAmount;
        _totalSupply = _totalSupply + userAmount;

        TOKEN.safeTransferFrom(account, address(this), amount);

        emit Staked(account, userAmount);
    }

    function _newRef(address _sponsor) internal {
        if (
            IReferrals(referralContract).isMember(msg.sender) == false &&
            IReferrals(referralContract).isMember(_sponsor) == true
        ) {
            IReferrals(referralContract).addMember(msg.sender, _sponsor);
        }
    }

    function withdraw(uint256 amount) external {
        _withdraw(amount);
    }

    function _withdraw(uint256 amount)
        internal
        nonReentrant
        updateReward(msg.sender)
    {
        require(amount > 0, "Cannot withdraw 0");
        _totalSupply = _totalSupply - amount;
        _balances[msg.sender] = _balances[msg.sender] - amount;
        TOKEN.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    function withdrawToZap(uint256 amount) external {
        _withdrawToZap(amount);
    }

    function _withdrawToZap(uint256 amount)
        internal
        nonReentrant
        updateReward(tx.origin)
    {
        require(amount > 0, "Cannot withdraw 0");
        _totalSupply = _totalSupply - amount;
        _balances[tx.origin] = _balances[tx.origin] - amount;
        TOKEN.safeTransfer(zapContract, amount);
        emit Withdrawn(tx.origin, amount);
    }

    function getReward() external {
        getRewardForOwnerToOtherOwner(msg.sender, msg.sender);
    }

    function getRewardForOwner(address _owner) external {
        getRewardForOwnerToOtherOwner(_owner, _owner);
    }

    function getRewardForOwnerToOtherOwner(address _owner, address _receiver)
        public
        nonReentrant
        updateReward(_owner)
    {
        uint256 reward = rewards[_owner];
        if (reward > 0) {
            if (_owner != _receiver) {
                require(
                    _owner == msg.sender ||
                        whitelisted[_owner][_receiver] == true,
                    "not owner or whitelisted"
                );
            }

            rewards[_owner] = 0;

            uint256 refReward = (reward * referralFee) / 10000;
            uint256 remainingRefReward = refReward;

            STABLE.safeTransfer(_receiver, reward - refReward);
            emit RewardPaid(_owner, _receiver, reward - refReward);

            address ref = IReferrals(referralContract).getSponsor(_owner);

            uint256 i = 0;
            while (i < refLevelPercent.length && refLevelPercent[i] > 0) {
                if (ref != IReferrals(referralContract).membersList(0)) {
                    uint256 refFeeAmount = (refReward * refLevelPercent[i]) /
                        10000;
                    remainingRefReward = remainingRefReward - refFeeAmount;
                    STABLE.safeTransfer(ref, refFeeAmount);
                    earnedRefs[ref] = earnedRefs[ref] + refFeeAmount;
                    emit RefRewardPaid(ref, reward);
                    ref = IReferrals(referralContract).getSponsor(ref);
                    i++;
                } else {
                    i += 30051999;
                }
            }
            if (remainingRefReward > 0) {
                STABLE.safeTransfer(
                    IGaugeFactory(gaugeFactory).mainRefFeeReceiver(),
                    remainingRefReward
                );
            }
        }
    }

    function notifyRewardAmount(uint256 reward)
        external
        onlyDistribution
        updateReward(address(0))
    {
        STABLE.safeTransferFrom(DISTRIBUTION, address(this), reward);
        if (block.timestamp >= periodFinish) {
            rewardRate = reward / DURATION;
        } else {
            uint256 remaining = periodFinish - block.timestamp;
            uint256 leftover = remaining * rewardRate;
            rewardRate = (reward + leftover) / DURATION;
        }

        // Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of rewardRate in the earned and rewardsPerToken functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        uint256 balance = STABLE.balanceOf(address(this));
        require(rewardRate <= balance / DURATION, "Provided reward too high");

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp + DURATION;
        emit RewardAdded(reward);
    }

    modifier updateReward(address account) {
        if (block.timestamp > IGaugeFactory(gaugeFactory).nextPoke(account)) {
            IGaugeFactory(gaugeFactory).poke(account);
        }
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
        if (account != address(0)) {
            kick(account);
        }
    }

    // update the referral Variables
    function updateReferral(
        address _referralsContract,
        uint256 _referralFee,
        uint256[] memory _refLevelPercent
    ) public {
        require((msg.sender == gaugeFactory), "!gaugeFactory");
        referralContract = _referralsContract;
        referralFee = _referralFee;
        refLevelPercent = _refLevelPercent;
    }

    // update the zap contract
    function updateZapContract(address _zapContract) public {
        require((msg.sender == gaugeFactory), "!gaugeFactory");
        zapContract = _zapContract;
    }

    // set whitelist for other receiver
    function setWhitelisted(address _receiver, bool _whitelist) public {
        whitelisted[msg.sender][_receiver] = _whitelist;
    }

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(
        address indexed user,
        address indexed receiver,
        uint256 reward
    );
    event RefRewardPaid(address indexed user, uint256 reward);
    event ClaimVotingFees(
        address indexed from,
        uint256 claimed0,
        uint256 claimed1
    );
}