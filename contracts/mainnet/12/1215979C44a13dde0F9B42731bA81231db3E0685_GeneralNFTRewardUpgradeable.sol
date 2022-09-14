// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <=0.8.4;

import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

import "./library/GovernanceUpgradeable.sol";
import "./interface/IERC20WithDecimals.sol";
import "./interface/IPool.sol";
import "./interface/ISpynNFTFactoryUpgradeable.sol";
import "./interface/ISpynNFTUpgradeable.sol";
import "./interface/ISpynReferral.sol";
import "./interface/ISpynLeaderboard.sol";
import "./interface/IMigratable.sol";

contract GeneralNFTRewardUpgradeable is IPool,GovernanceUpgradeable,IMigratable {
    using SafeERC20Upgradeable for IERC20WithDecimals;
    using SafeMathUpgradeable for uint256;

    IERC20WithDecimals public _rewardERC20;
    ISpynNFTFactoryUpgradeable public _gegoFactory;
    ISpynNFTUpgradeable public _gegoToken;

    address public _rewardPool;
    address public _treasury;
    address public _migrateToContract;
    address public _migrateFromContract;
    address private constant _deadWallet = address(0x000000000000000000000000000000000000dEaD);

    uint256 public constant DURATION = 7 days;
    uint256 public _startTime;
    uint256 public _periodFinish;
    uint256 public _rewardRate;
    uint256 public _lastUpdateTime;
    uint256 public _rewardPerTokenStored;
    uint256 public _harvestInterval;
    uint256 public totalLockedUpRewards;

    uint256 public _depositFeeRate;
    uint256 public _burnFeeRate;
    uint256 public _spynFeeRate;
    uint256 public _harvestFeeRate;
    uint256 public _baseRate;
    ISpynReferral public _spynReferral;
    ISpynLeaderboard public _spynLeaderboard;
    // Referral commission rate in basis points.
    uint16[] public _harvestReferralCommissionRates;
    uint16[] public _depositReferralCommissionRates;
    // The precision factor
    uint256 public REWARDS_PRECISION_FACTOR;

    mapping(address => uint256) public _userRewardPerTokenPaid;
    mapping(address => uint256) public _rewards;
    mapping(address => uint256) public _lastStakedTime;
    mapping(address => uint256) public _nextHarvestUntil;
    mapping(address => uint256) public _rewardLockedUp;

    uint256 public _fixRateBase;

    uint256 public _totalWeight;
    mapping(address => uint256) public _weightBalances;
    mapping(uint256 => uint256) public _stakeWeightes;
    mapping(uint256 => uint256) public _stakeBalances;

    uint256 public _totalBalance;
    mapping(address => uint256) public _degoBalances;
    uint256 public _maxStakedDego;

    mapping(address => uint256[]) public _playerGego;
    mapping(uint256 => uint256) public _gegoMapIndex;
    uint256 public _extraHarvestInterval;



    event RewardAdded(uint256 reward);
    event StakedGEGO(address indexed user, uint256 amount);
    event WithdrawnGego(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardLockedUp(address indexed user, uint256 reward);
    event NFTReceived(address operator, address from, uint256 tokenId, bytes data);
    event HarvestReferralCommissionPaid(address indexed user, address indexed referrer, uint256 level, uint256 commissionAmount);
    event HarvestReferralCommissionMissed(address indexed user, address indexed referrer, uint256 level, uint256 commissionAmount);
    event DepositReferralCommissionPaid(address indexed user, address indexed referrer, uint256 level, uint256 commissionAmount);
    event DepositReferralCommissionMissed(address indexed user, address indexed referrer, uint256 level, uint256 commissionAmount);

    function initialize(
        address spynNftToken,
        address gegoFactory,
        address rewardAddress,
        address treasury,
        uint256 startTime,
        address spynReferral,
        address spynLeaderboard
    ) public initializer {
        __GovernanceUpgradeable_init_unchained();
        __GeneralNFTRewardUpgradeable_init_unchained(spynNftToken, gegoFactory, rewardAddress, treasury, startTime, spynReferral, spynLeaderboard);
    }

    function __GeneralNFTRewardUpgradeable_init_unchained(
        address spynNftToken,
        address gegoFactory,
        address rewardAddress,
        address treasury,
        uint256 startTime,
        address spynReferral,
        address spynLeaderboard
    ) internal initializer {
        _treasury = treasury;
        _rewardERC20 = IERC20WithDecimals(rewardAddress);
        _gegoToken = ISpynNFTUpgradeable(spynNftToken);
        _gegoFactory = ISpynNFTFactoryUpgradeable(gegoFactory);

        uint256 decimalsRewardToken = uint256(IERC20WithDecimals(rewardAddress).decimals());
        require(decimalsRewardToken < 18, "Must be inferior to 18");

        REWARDS_PRECISION_FACTOR = uint256(10**(uint256(18).sub(decimalsRewardToken)));

        _startTime = startTime;
        _lastUpdateTime = _startTime;

        _rewardPool = address(0x0);
        _periodFinish = 0;
        _rewardRate = 0;
        _harvestInterval = 12 hours;
        _extraHarvestInterval = 0 hours;

        _depositFeeRate = 500;
        _burnFeeRate = 2000;
        _spynFeeRate = 1000;
        _depositReferralCommissionRates.push(500);
        _depositReferralCommissionRates.push(400);
        _depositReferralCommissionRates.push(300);
        _depositReferralCommissionRates.push(200);
        _depositReferralCommissionRates.push(100);

        _harvestFeeRate = 500;
        _harvestReferralCommissionRates.push(100);
        _harvestReferralCommissionRates.push(100);
        _harvestReferralCommissionRates.push(100);
        _harvestReferralCommissionRates.push(100);
        _harvestReferralCommissionRates.push(100);
        _baseRate = 10000;
        _spynReferral = ISpynReferral(spynReferral);
        _spynLeaderboard = ISpynLeaderboard(spynLeaderboard);

        _fixRateBase = 100000;
        _maxStakedDego = 200;
    }

    modifier updateReward(address account) {
        _rewardPerTokenStored = rewardPerToken();
        _lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            _rewards[account] = earnedInternal(account);
            _userRewardPerTokenPaid[account] = _rewardPerTokenStored;
        }
        _;
    }

    function setMaxStakedDego(uint256 amount) external onlyGovernance{
        _maxStakedDego = amount;
    }

    /* Fee collection for any other token */
    function seize(IERC20WithDecimals token, uint256 amount) external  {
        require(token != _rewardERC20, "reward");
        token.transfer(_governance, amount);
    }

    /* Fee collection for any other token */
    function seizeErc721(IERC721Upgradeable token, uint256 tokenId) external
    {
        require(token != _gegoToken, "gego stake");
        token.safeTransferFrom(address(this), _governance, tokenId);
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return MathUpgradeable.min(block.timestamp, _periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return _rewardPerTokenStored;
        }
        return
            _rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(_lastUpdateTime)
                    .mul(_rewardRate)
                    .mul(1e18)
                    .div(totalSupply())
            );
    }

    function rewardLockedupForUser(address account) public view returns (uint256) {
        return _rewardLockedUp[account].div(REWARDS_PRECISION_FACTOR);
    }

    function earned(address account) public view returns (uint256) {
        return earnedInternal(account).div(REWARDS_PRECISION_FACTOR);
    }

    function earnedInternal(address account) private view returns (uint256) {
        return
            balanceOf(account)
                .mul(rewardPerToken().sub(_userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(_rewards[account]);
    }

    function extraHarvestIntervalFor(address account) public view returns (uint256) {
        if (_extraHarvestInterval == 0) {
            return 0;
        }
        uint256 res = uint256(keccak256(abi.encodePacked(account, _lastStakedTime[account]))) % _extraHarvestInterval;
        return res;
    }

    function canHarvest(address account) public view returns (bool) {
        return block.timestamp >= _nextHarvestUntil[account] + extraHarvestIntervalFor(account);
    }

    //the grade is a number between 1-6
    //the quality is a number between 1-10000
    /*
    1   quality	1.1+ 0.1*quality/5000
    2	quality	1.2+ 0.1*(quality-5000)/3000
    3	quality	1.3+ 0.1*(quality-8000/1000
    4	quality	1.4+ 0.2*(quality-9000)/800
    5	quality	1.6+ 0.2*(quality-9800)/180
    6	quality	1.8+ 0.2*(quality-9980)/20
    */

    function getFixRate(uint256 grade,uint256 quality) public pure returns (uint256){

        require(grade > 0 && grade < 7, "the gego not dego");

        uint256 unfold = 0;

        if( grade == 1 ){
            unfold = quality*10000/5000;
            return unfold.add(110000);
        }else if( grade == 2){
            unfold = quality.sub(5000)*10000/3000;
            return unfold.add(120000);
        }else if( grade == 3){
            unfold = quality.sub(8000)*10000/1000;
           return unfold.add(130000);
        }else if( grade == 4){
            unfold = quality.sub(9000)*20000/800;
           return unfold.add(140000);
        }else if( grade == 5){
            unfold = quality.sub(9800)*20000/180;
            return unfold.add(160000);
        }else{
            unfold = quality.sub(9980)*20000/20;
            return unfold.add(180000);
        }
    }

    function getStakeInfo( uint256 gegoId ) public view returns ( uint256 stakeRate, uint256 degoAmount){

        uint256 grade;
        uint256 quality;

        (grade, quality, degoAmount,, , , ,, ,,,) = _gegoFactory.getGego(gegoId);

        require(degoAmount > 0,"the gego not dego");

        stakeRate = getFixRate(grade,quality);
    }

    function stakeMulti(uint256[] calldata gegoIds, address referrer) external {
        uint256 length = gegoIds.length;
        for (uint256 i = 0; i < length; i ++) {
            stake(gegoIds[i], referrer);
        }
    }

    // stake NFT
    function stake(uint256 gegoId, address referrer)
        public
        updateReward(msg.sender)
        checkStart
    {
        if (
            address(_spynReferral) != address(0) &&
            referrer != address(0) &&
            referrer != msg.sender
        ) {
            _spynReferral.recordReferral(msg.sender, referrer);
        }

        uint256[] storage gegoIds = _playerGego[msg.sender];
        if (gegoIds.length == 0) {
            gegoIds.push(0);
            _gegoMapIndex[0] = 0;
        }
        gegoIds.push(gegoId);
        _gegoMapIndex[gegoId] = gegoIds.length - 1;

        uint256 stakeRate;
        uint256 degoAmount;
        (stakeRate, degoAmount) = getStakeInfo(gegoId);

        takeDepositFee(gegoId, degoAmount);

        uint256 stakedDegoAmount = _degoBalances[msg.sender];
        uint256 stakingDegoAmount = stakedDegoAmount.add(degoAmount) <= _maxStakedDego?degoAmount:_maxStakedDego.sub(stakedDegoAmount);


        if(stakingDegoAmount > 0){
            uint256 stakeWeight = stakeRate.mul(stakingDegoAmount).div(_fixRateBase);
            _degoBalances[msg.sender] = _degoBalances[msg.sender].add(stakingDegoAmount);

            _weightBalances[msg.sender] = _weightBalances[msg.sender].add(stakeWeight);

            _stakeBalances[gegoId] = stakingDegoAmount;
            _stakeWeightes[gegoId] = stakeWeight;

            _totalBalance = _totalBalance.add(stakingDegoAmount);
            _totalWeight = _totalWeight.add(stakeWeight);
        }

        if (address(_spynLeaderboard) != address(0)) {
            _spynLeaderboard.recordStaking(msg.sender, address(_gegoToken), 1);
        }
        _gegoToken.safeTransferFrom(msg.sender, address(this), gegoId);

        if(_nextHarvestUntil[msg.sender] == 0){
            _nextHarvestUntil[msg.sender] = block.timestamp.add(
                    _harvestInterval
                );
        }
        _lastStakedTime[msg.sender] = block.timestamp;

        emit StakedGEGO(msg.sender, gegoId);

    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public returns (bytes4) {
        emit NFTReceived(operator, from, tokenId, data);
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

    function unstake(uint256 gegoId)
        public
        updateReward(msg.sender)
        checkStart
    {
        require(gegoId > 0, "the gegoId error");

        uint256[] memory gegoIds = _playerGego[msg.sender];
        uint256 gegoIndex = _gegoMapIndex[gegoId];

        require(gegoIds[gegoIndex] == gegoId, "not gegoId owner");

        uint256 gegoArrayLength = gegoIds.length-1;
        uint256 tailId = gegoIds[gegoArrayLength];

        _playerGego[msg.sender][gegoIndex] = tailId;
        _playerGego[msg.sender][gegoArrayLength] = 0;

        // _playerGego[msg.sender].length--;  // remove in new version

        _playerGego[msg.sender].pop();

        _gegoMapIndex[tailId] = gegoIndex;
        _gegoMapIndex[gegoId] = 0;

        uint256 stakeWeight = _stakeWeightes[gegoId];
        _weightBalances[msg.sender] = _weightBalances[msg.sender].sub(stakeWeight);
        _totalWeight = _totalWeight.sub(stakeWeight);

        uint256 stakeBalance = _stakeBalances[gegoId];
        _degoBalances[msg.sender] = _degoBalances[msg.sender].sub(stakeBalance);
        _totalBalance = _totalBalance.sub(stakeBalance);

        _stakeBalances[gegoId] = 0;
        _stakeWeightes[gegoId] = 0;

        _gegoFactory.reflectFee(gegoId);

        if (address(_spynLeaderboard) != address(0)) {
            _spynLeaderboard.recordUnstaking(msg.sender, address(_gegoToken), 1);
        }
        _gegoToken.safeTransferFrom(address(this), msg.sender, gegoId);
        emit WithdrawnGego(msg.sender, gegoId);
    }

    function withdraw()
        public
        checkStart
    {

        uint256[] memory gegoId = _playerGego[msg.sender];
        for (uint8 index = 1; index < gegoId.length; index++) {
            if (gegoId[index] > 0) {
                unstake(gegoId[index]);
            }
        }
    }

    function getPlayerIds( address account ) public view override returns( uint256[] memory gegoId )
    {
        gegoId = _playerGego[account];
    }

    function exit() external {
        withdraw();
        harvest();
    }

    function migrateFrom() external override {
        uint256[] memory gegoIds = IMigratable(_migrateFromContract).getPlayerIds(msg.sender);
        for (uint256 i = 0; i < gegoIds.length; i ++) {
            if (gegoIds[i] > 0) {
                migrateGegoFrom(gegoIds[i]);
            }
        }
    }

    function migrateGegoFrom(uint256 gegoId)
        public override
        updateReward(msg.sender)
        checkStart
    {

        uint256[] storage gegoIds = _playerGego[msg.sender];
        if (gegoIds.length == 0) {
            gegoIds.push(0);
            _gegoMapIndex[0] = 0;
        }
        gegoIds.push(gegoId);
        _gegoMapIndex[gegoId] = gegoIds.length - 1;

        uint256 stakeRate;
        uint256 degoAmount;
        (stakeRate, degoAmount) = getStakeInfo(gegoId);

        uint256 stakedDegoAmount = _degoBalances[msg.sender];
        uint256 stakingDegoAmount = stakedDegoAmount.add(degoAmount) <= _maxStakedDego?degoAmount:_maxStakedDego.sub(stakedDegoAmount);


        if(stakingDegoAmount > 0){
            uint256 stakeWeight = stakeRate.mul(stakingDegoAmount).div(_fixRateBase);
            _degoBalances[msg.sender] = _degoBalances[msg.sender].add(stakingDegoAmount);

            _weightBalances[msg.sender] = _weightBalances[msg.sender].add(stakeWeight);

            _stakeBalances[gegoId] = stakingDegoAmount;
            _stakeWeightes[gegoId] = stakeWeight;

            _totalBalance = _totalBalance.add(stakingDegoAmount);
            _totalWeight = _totalWeight.add(stakeWeight);
        }

        if (address(_spynLeaderboard) != address(0)) {
            _spynLeaderboard.recordStaking(msg.sender, address(_gegoToken), 1);
        }

        IMigratable(_migrateFromContract).migrateGegoTo(msg.sender, gegoId);

        if(_nextHarvestUntil[msg.sender] == 0){
            _nextHarvestUntil[msg.sender] = block.timestamp.add(
                    _harvestInterval
                );
        }
        _lastStakedTime[msg.sender] = block.timestamp;

        emit MigratedGegoFrom(msg.sender, _migrateFromContract, gegoId);
    }

    function migrateGegoTo(address account, uint256 gegoId)
        public override
        updateReward(account)
        checkStart
    {
        require(gegoId > 0, "the gegoId error");
        require(msg.sender == _migrateToContract, "Invalid migration caller");

        uint256[] memory gegoIds = _playerGego[account];
        uint256 gegoIndex = _gegoMapIndex[gegoId];

        require(gegoIds[gegoIndex] == gegoId, "not gegoId owner");

        uint256 gegoArrayLength = gegoIds.length-1;
        uint256 tailId = gegoIds[gegoArrayLength];

        _playerGego[account][gegoIndex] = tailId;
        _playerGego[account][gegoArrayLength] = 0;

        // _playerGego[msg.sender].length--;  // remove in new version

        _playerGego[account].pop();

        _gegoMapIndex[tailId] = gegoIndex;
        _gegoMapIndex[gegoId] = 0;

        uint256 stakeWeight = _stakeWeightes[gegoId];
        _weightBalances[account] = _weightBalances[account].sub(stakeWeight);
        _totalWeight = _totalWeight.sub(stakeWeight);

        uint256 stakeBalance = _stakeBalances[gegoId];
        _degoBalances[account] = _degoBalances[account].sub(stakeBalance);
        _totalBalance = _totalBalance.sub(stakeBalance);

        _stakeBalances[gegoId] = 0;
        _stakeWeightes[gegoId] = 0;
        _gegoToken.safeTransferFrom(address(this), msg.sender, gegoId);
        if (address(_spynLeaderboard) != address(0)) {
            _spynLeaderboard.recordUnstaking(msg.sender, address(_gegoToken), 1);
        }
        emit MigratedGegoTo(account, msg.sender, gegoId);
    }

    function harvest() public updateReward(msg.sender) checkStart {
        uint256 reward = earnedInternal(msg.sender);
        if(canHarvest(msg.sender)){
            if (reward > 0 || _rewardLockedUp[msg.sender] > 0) {
                _rewards[msg.sender] = 0;
                reward = reward.add(_rewardLockedUp[msg.sender]);
                // reset lockup
                totalLockedUpRewards = totalLockedUpRewards.sub(_rewardLockedUp[msg.sender]);
                _rewardLockedUp[msg.sender] = 0;
                _nextHarvestUntil[msg.sender] = block.timestamp.add(
                    _harvestInterval
                );

                // pay referral commision
                (uint256 referralFeeTaken, uint256 referralFeeMissing) = payHarvestReferralCommission(msg.sender, reward);

                // take harvest fee
                uint256 harvestFee = reward.mul(_harvestFeeRate).div(_baseRate);
                harvestFee = harvestFee.add(referralFeeMissing);

                uint256 harvestFeeWithDecimal = harvestFee.div(REWARDS_PRECISION_FACTOR);
                if(harvestFeeWithDecimal > 0 && _rewardPool != address(0)){
                    _rewardERC20.safeTransfer(_rewardPool, harvestFeeWithDecimal);
                }

                // send remaining reward to user
                reward = reward.sub(harvestFee).sub(referralFeeTaken);

                uint256 rewardWithDecimal = reward.div(REWARDS_PRECISION_FACTOR);
                if(rewardWithDecimal>0){
                    _rewardERC20.safeTransfer(msg.sender, rewardWithDecimal);
                }
                emit RewardPaid(msg.sender, rewardWithDecimal);
            }
        } else if(reward > 0){
            _rewards[msg.sender] = 0;
            _rewardLockedUp[msg.sender] = _rewardLockedUp[msg.sender].add(reward);
            totalLockedUpRewards = totalLockedUpRewards.add(reward);

            uint256 rewardWithDecimal = reward.div(REWARDS_PRECISION_FACTOR);
            emit RewardLockedUp(msg.sender, rewardWithDecimal);
        }
    }

    function payHarvestReferralCommission(
        address _user,
        uint256 _pending
    ) internal returns (
        uint256 feeTaken,
        uint256 feeMissing
    ) {
        if (address(_spynReferral) != address(0)) {
            address[] memory referrersByLevel = _spynReferral.getReferrersByLevel(_user, _harvestReferralCommissionRates.length);

            uint256 commissionAmount;
            for (uint256 i = 0; i < _harvestReferralCommissionRates.length; i ++) {
                commissionAmount = _pending.mul(_harvestReferralCommissionRates[i]).div(_baseRate);
                uint256 commissionAmountWithDecimal = commissionAmount.div(REWARDS_PRECISION_FACTOR);
                if (commissionAmountWithDecimal > 0 && referrersByLevel[i] != address(0)) {
                    feeTaken = feeTaken.add(commissionAmount);
                    if (address(_spynLeaderboard) != address(0) && _spynLeaderboard.hasStaking(referrersByLevel[i])) {
                        _rewardERC20.safeTransfer(referrersByLevel[i], commissionAmountWithDecimal);
                        _spynReferral.recordReferralCommission(referrersByLevel[i], _user, commissionAmountWithDecimal, address(_rewardERC20), 0, i);
                        emit HarvestReferralCommissionPaid(_user, referrersByLevel[i], i + 1, commissionAmountWithDecimal);
                    } else {
                        _rewardERC20.safeTransfer(_treasury, commissionAmountWithDecimal);
                        _spynReferral.recordReferralCommissionMissing(referrersByLevel[i], _user, commissionAmountWithDecimal, address(_rewardERC20), 0, i);
                        emit HarvestReferralCommissionMissed(_user, referrersByLevel[i], i + 1, commissionAmountWithDecimal);
                    }
                } else {
                    feeMissing = feeMissing.add(commissionAmount);
                }
            }
        } else {
            uint256 commissionAmount;
            for (uint256 i = 0; i < _harvestReferralCommissionRates.length; i ++) {
                commissionAmount = _pending.mul(_harvestReferralCommissionRates[i]).div(10000);
                feeMissing = feeMissing.add(commissionAmount);
            }
        }
    }

    function payDepositReferralCommission(
        address _user,
        uint256 _depositedAmount,
        uint256 _gegoId
    ) internal returns (
        uint256 feeTaken,
        uint256 feeMissing
    ) {
        if (address(_spynReferral) != address(0)) {
            address[] memory referrersByLevel = _spynReferral.getReferrersByLevel(_user, _depositReferralCommissionRates.length);

            uint256 commissionAmount;
            for (uint256 i = 0; i < _depositReferralCommissionRates.length; i ++) {
                commissionAmount = _depositedAmount.mul(_depositReferralCommissionRates[i]).div(_baseRate);
                if (commissionAmount > 0 && referrersByLevel[i] != address(0)) {
                    feeTaken = feeTaken.add(commissionAmount);
                    if (address(_spynLeaderboard) != address(0) && _spynLeaderboard.hasStaking(referrersByLevel[i])) {
                        address token = _gegoFactory.takeFee(_gegoId, commissionAmount, referrersByLevel[i], false);
                        _spynReferral.recordReferralCommission(referrersByLevel[i], _user, commissionAmount, token, 1, i);
                        emit DepositReferralCommissionPaid(_user, referrersByLevel[i], i + 1, commissionAmount);
                    } else {
                        address token = _gegoFactory.takeFee(_gegoId, commissionAmount, _treasury, false);
                        _spynReferral.recordReferralCommissionMissing(referrersByLevel[i], _user, commissionAmount, token, 1, i);
                        emit DepositReferralCommissionMissed(_user, referrersByLevel[i], i + 1, commissionAmount);
                    }
                } else {
                    feeMissing = feeMissing.add(commissionAmount);
                }
            }
        } else {
            uint256 commissionAmount;
            for (uint256 i = 0; i < _depositReferralCommissionRates.length; i ++) {
                commissionAmount = _depositedAmount.mul(_depositReferralCommissionRates[i]).div(10000);
                feeMissing = feeMissing.add(commissionAmount);
            }
        }
    }


    function takeDepositFee(uint256 gegoId, uint256 degoAmount) internal returns (uint256 feeTaken) {

        // Deposit Fee 5%
        uint256 depositFee = degoAmount.mul(_depositFeeRate).div(_baseRate);
        // Referral Fee: 5, 4, 3, 2, 1%
        (uint256 referralFeeTaken, uint256 referralFeeMissing) = payDepositReferralCommission(msg.sender, degoAmount, gegoId);
        // Burn 20%
        uint256 burnFee = degoAmount.mul(_burnFeeRate).div(_baseRate);
        _gegoFactory.takeFee(gegoId, burnFee, _deadWallet, false);
        // SPYN 10%
        uint256 spynFee = degoAmount.mul(_spynFeeRate).div(_baseRate);
        depositFee = depositFee.add(spynFee).add(referralFeeMissing);
        if (depositFee > 0) {
            _gegoFactory.takeFee(gegoId, depositFee, _rewardPool, false);
        }

        feeTaken = depositFee.add(referralFeeTaken).add(burnFee);
    }

    modifier checkStart() {
        require(block.timestamp > _startTime, "not start");
        _;
    }

    //for extra reward
    function notifyReward(uint256 reward)
        external
        onlyGovernance
        updateReward(address(0))
    {

        uint256 balanceBefore = _rewardERC20.balanceOf(address(this));
        IERC20WithDecimals(_rewardERC20).transferFrom(msg.sender, address(this), reward);
        uint256 balanceEnd = _rewardERC20.balanceOf(address(this));

        uint256 realReward = balanceEnd.sub(balanceBefore).mul(REWARDS_PRECISION_FACTOR);

        if (block.timestamp >= _periodFinish) {
            _rewardRate = realReward.div(DURATION);
        } else {
            uint256 remaining = _periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(_rewardRate);
            _rewardRate = realReward.add(leftover).div(DURATION);
        }
        _lastUpdateTime = block.timestamp;
        _periodFinish = block.timestamp.add(DURATION);

        emit RewardAdded(realReward);
    }

    function setMigrateToContract(address migrateToContract) external onlyGovernance {
        _migrateToContract = migrateToContract;
    }

    function setMigrateFromContract(address migrateFromContract) external onlyGovernance {
        _migrateFromContract = migrateFromContract;
    }

    function setDepositFeeRate( uint256 depositFeeRate ) public onlyGovernance {
        _depositFeeRate = depositFeeRate;
    }

    function setBurnFeeRate( uint256 burnFeeRate ) public onlyGovernance {
        _burnFeeRate = burnFeeRate;
    }

    function setSpynFeeRate( uint256 spynFeeRate ) public onlyGovernance {
        _spynFeeRate = spynFeeRate;
    }

    function setHarvestFeeRate( uint256 harvestFeeRate ) public onlyGovernance {
        _harvestFeeRate = harvestFeeRate;
    }
    
    function setHarvestInterval( uint256  harvestInterval ) public onlyGovernance{
        _harvestInterval = harvestInterval;
    }
    
    function setExtraHarvestInterval( uint256  extraHarvestInterval ) public onlyGovernance{
        _extraHarvestInterval = extraHarvestInterval;
    }

    function setRewardPool( address  rewardPool ) public onlyGovernance{
        _rewardPool = rewardPool;
    }

    function totalSupply()  public view override returns (uint256) {
        return _totalWeight;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _weightBalances[account];
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <=0.8.4;

import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract GovernanceUpgradeable is Initializable, ContextUpgradeable {

    address public _governance;

    function __GovernanceUpgradeable_init() internal onlyInitializing {
        __GovernanceUpgradeable_init_unchained();
    }

    function __GovernanceUpgradeable_init_unchained() internal onlyInitializing {
        _governance = msg.sender;
    }

    event GovernanceTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyGovernance {
        require(msg.sender == _governance, "not governance");
        _;
    }

    function setGovernance(address governance)  public  onlyGovernance
    {
        require(governance != address(0), "new governance the zero address");
        emit GovernanceTransferred(_governance, governance);
        _governance = governance;
    }


}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <=0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";


import "./ISpynNFTUpgradeable.sol";

interface IERC20WithDecimals is IERC20Upgradeable{

    function decimals() external returns (uint8);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <=0.8.4;


interface IPool {
    function totalSupply( ) external view returns (uint256);
    function balanceOf( address player ) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <=0.8.4;

pragma experimental ABIEncoderV2;


import "./ISpynNFTUpgradeable.sol";

interface ISpynNFTFactoryUpgradeable {


    function getGego(uint256 tokenId)
        external view
        returns (
            uint256 grade,
            uint256 quality,
            uint256 amount,
            uint256 realAmount,
            uint256 resBaseId,
            uint256 ruleId,
            uint256 nftType,
            address author,
            address erc20,
            uint256 createdTime,
            uint256 blockNum,
            uint256 lockedDays
        );


    function getGegoStruct(uint256 tokenId)
        external view
        returns (ISpynNFTUpgradeable.Gego memory gego);

    function burn(uint256 tokenId) external returns ( bool );

    function reflectFee(uint256 tokenId) external;

    function takeFee(uint256 tokenId, uint256 feeAmount, address receipt, bool reflectAmount) external returns (address);
   
    function isRulerProxyContract(address proxy) external view returns ( bool );
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <=0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";


interface ISpynNFTUpgradeable is IERC721Upgradeable {

    struct Gego {
        uint256 id;
        uint256 grade;
        uint256 quality;
        uint256 amount;
        uint256 realAmount;
        uint256 resBaseId;
        uint256 ruleId;
        uint256 nftType;
        address author;
        address erc20;
        uint256 createdTime;
        uint256 blockNum;
        uint256 lockedDays;
    }
    
    function mint(address to, uint256 tokenId) external returns (bool) ;
    function burn(uint256 tokenId) external;
}

pragma solidity ^0.8.0;

interface ISpynReferral {
    /**
     * @dev Record referral.
     */
    function recordReferral(address user, address referrer) external;

    /**
     * @dev Record referral commission.
     */
    function recordReferralCommission(
        address _referrer,
        address _referee,
        uint256 _commission,
        address _token,
        uint256 _type,
        uint256 _level
    ) external;

    function recordReferralCommissionMissing(
        address _referrer,
        address _referee,
        uint256 _commission,
        address _token,
        uint256 _type,
        uint256 _level
    ) external;

    /**
     * @dev Get the referrer address that referred the user.
     */
    function getReferrer(address user) external view returns (address);

    /**
     * @dev Get the referrer addresses that referred the user by level.
     */
    function getReferrersByLevel(
        address _user,
        uint256 count
    ) external view returns (
        address[] memory referrersByLevel
    );

    function updateOperator(address _operator, bool _status) external;
}

pragma solidity ^0.8.0;

interface ISpynLeaderboard {
    function recordStaking(
        address _user,
        address _token,
        uint256 _amount
    ) external;

    function recordUnstaking(
        address _user,
        address _token,
        uint256 _amount
    ) external;

    function hasStaking(address _user) external view returns(bool);
    
    function updateOperator(address _operator, bool _status) external;
}

pragma solidity ^0.8.0;

interface IMigratable {

    event MigratedGegoFrom(address indexed owner, address fromContract, uint256 gegoId);
    event MigratedGegoTo(address indexed owner, address toContract, uint256 gegoId);

    function getPlayerIds(address owner) external view returns( uint256[] memory gegoId );
    function migrateFrom() external;
    function migrateGegoFrom(uint256 gegoId) external;
    function migrateGegoTo(address owner, uint256 gegoId) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}