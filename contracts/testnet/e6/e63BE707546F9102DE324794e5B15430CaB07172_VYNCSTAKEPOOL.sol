// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface BusdPrice {
    function price() external view returns (uint256); //price in 18 decimals
}

interface GetDataInterface {
    function returnData()
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function returnAprData()
        external
        view
        returns (
            uint256,
            uint256,
            bool
        );

    function returnMaxStakeUnstake()
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );
}

interface TreasuryInterface {
    function send(address, uint256) external;
}

interface VyncMigrate {
    struct userInfoData {
        uint256 stakeBalanceWithReward;
        uint256 stakeBalance;
        uint256 lastClaimedReward;
        uint256 lastStakeUnstakeTimestamp;
        uint256 lastClaimTimestamp;
        bool isStaker;
        uint256 totalClaimedReward;
        uint256 autoClaimWithStakeUnstake;
        uint256 pendingRewardAfterFullyUnstake;
        bool isClaimAferUnstake;
        uint256 nextCompoundDuringStakeUnstake;
        uint256 nextCompoundDuringClaim;
        uint256 lastCompoundedRewardWithStakeUnstakeClaim;
    }
    function userInfo(address)
        external
        view
        returns (userInfoData memory);
    function compoundedReward(address user)
        external
        view
        returns (uint256);
}

contract VYNCSTAKEPOOL is ReentrancyGuard, Ownable {
    using SafeMath for uint256;

    address public dataAddress = 0xD296c93744574443bF1a8c67A5f1471490a3e231; //new one
    // address public dataAddress = 0x95BAa846abB64F9314eec91CD33Ec47B3EEFEf93; 
    GetDataInterface data = GetDataInterface(dataAddress);
    address public busdPriceAddress =
        0xbA9fFDe1CE983a5eD91Ba7b2298c812F6C633542;
    BusdPrice busdPrice = BusdPrice(busdPriceAddress);
    address public TreasuryAddress = 0xA4FE6E8150770132c32e4204C2C1Ff59783eDfA0;
    TreasuryInterface treasury = TreasuryInterface(TreasuryAddress);
    address public migrateAddress = 0x1324cA2AA7Ffde79e972E8C199886C40648a328f;
    VyncMigrate migrate = VyncMigrate(migrateAddress);

    struct stakeInfoData {
        uint256 compoundStart;
        bool isCompoundStartSet;
    }

    struct userInfoData {
        uint256 stakeBalanceWithReward;
        uint256 stakeBalance;
        uint256 lastClaimedReward;
        uint256 lastStakeUnstakeTimestamp;
        uint256 lastClaimTimestamp;
        bool isStaker;
        uint256 totalClaimedReward;
        uint256 autoClaimWithStakeUnstake;
        uint256 pendingRewardAfterFullyUnstake;
        bool isClaimAferUnstake;
        uint256 nextCompoundDuringStakeUnstake;
        uint256 nextCompoundDuringClaim;
        uint256 lastCompoundedRewardWithStakeUnstakeClaim;
    }

    IERC20 public vync = IERC20(0x71BE9BA58e0271b967a980eD8e59C07fF2108C85);

    uint256 decimal4 = 1e4;
    uint256 decimal18 = 1e18;
    mapping(address => userInfoData) public userInfo;
    stakeInfoData public stakeInfo;
    uint256 s; // total staking amount
    uint256 u; //total unstaking amount
    uint256 s_v; //total stake in vync
    uint256 u_v; // total unstake in vync
    bool public isClaim = true;
    bool public fixUnstakeAmount;
    uint256 public stake_fee = 5 * decimal18; // in usd 18 decimal
    uint256 public unstake_fee = 5 * decimal18; // in usd 18 decimal
    bool public isMigrate = true;

    mapping(address => uint256) public dCompoundAmount;
    mapping(address => uint256) public iCompoundAmount;
    mapping(address => bool) isBlock;
    mapping(address => bool) stopMigrate;

    event rewardClaim(address indexed user, uint256 rewards);
    event Stake(address account, uint256 stakeAmount);
    event UnStake(address account, uint256 unStakeAmount);
    event DataAddressSet(address newDataAddress);
    event TreasuryAddressSet(address newTreasuryAddresss);
    event SetCompoundStart(uint256 _blocktime);

    constructor() {
        stakeInfo.compoundStart = block.timestamp;
    }

    function set_compoundStart(uint256 _blocktime) public onlyOwner {
        require(stakeInfo.isCompoundStartSet == false, "already set once");
        stakeInfo.compoundStart = _blocktime;
        stakeInfo.isCompoundStartSet = true;
        emit SetCompoundStart(_blocktime);
    }

    function set_data(address _data) public onlyOwner {
        require(
            _data != address(0),
            "can not set zero address for data address"
        );
        dataAddress = _data;
        data = GetDataInterface(_data);
        emit DataAddressSet(_data);
    }

    function set_busdPriceAddress(address _address) public onlyOwner {
        require(
            _address != address(0),
            "can not set zero address for data address"
        );
        busdPriceAddress = _address;
        busdPrice = BusdPrice(_address);
    }

    function set_treasuryAddress(address _treasury) public onlyOwner {
        require(
            _treasury != address(0),
            "can not set zero address for treasury address"
        );
        TreasuryAddress = _treasury;
        treasury = TreasuryInterface(_treasury);
        emit TreasuryAddressSet(_treasury);
    }

    function set_fee(uint256 _stakeFee, uint256 _unstakeFee) public onlyOwner {
        stake_fee = _stakeFee;
        unstake_fee = _unstakeFee;
    }

    function set_isClaim(bool _isClaim) public onlyOwner {
        isClaim = _isClaim;
    }

    function set_fixUnstakeAmount(bool _fix) public onlyOwner {
        fixUnstakeAmount = _fix;
    }

    function d_compoundAmount(address _address, uint256 _amount)
        public
        onlyOwner
    {
        dCompoundAmount[_address] = _amount;
    }

    function i_compoundAmount(address _address, uint256 _amount)
        public
        onlyOwner
    {
        iCompoundAmount[_address] = _amount;
    }

    function _block(address _address, bool is_Block) public onlyOwner {
        isBlock[_address] = is_Block;
    }

    function nextCompound() public view returns (uint256 _nextCompound) {
        (, uint256 compoundRate, ) = data.returnData();
        uint256 interval = block.timestamp - stakeInfo.compoundStart;
        interval = interval / compoundRate;
        _nextCompound =
            stakeInfo.compoundStart +
            compoundRate +
            interval *
            compoundRate;
    }

    function stake(uint256 amount) external nonReentrant {
        require(isBlock[msg.sender] == false, "blocked");
        uint256 _price = busdPrice.price();
        uint256 usdAmount = amount * _price;
        usdAmount = usdAmount / decimal4;
        (uint256 maxStakePerTx, , uint256 totalStakePerUser) = data
            .returnMaxStakeUnstake();
        require(usdAmount <= maxStakePerTx, "exceed max stake limit for a tx");
        require(
            (userInfo[msg.sender].stakeBalance + usdAmount) <=
                totalStakePerUser,
            "exceed total stake limit"
        );

        uint256 fee = (stake_fee * decimal4) / _price;
        require(amount > fee, "amount less then stake_fee");
        amount = amount - fee;
        usdAmount = usdAmount - stake_fee;
        vync.transferFrom(msg.sender, address(this), amount);
        vync.transferFrom(msg.sender, TreasuryAddress, fee);

        userInfo[msg.sender]
            .lastCompoundedRewardWithStakeUnstakeClaim = lastCompoundedReward(
            msg.sender
        );

        if (userInfo[msg.sender].isStaker == true) {
            uint256 _pendingReward = compoundedReward(msg.sender);
            uint256 cpending = cPendingReward(msg.sender);
            userInfo[msg.sender].stakeBalanceWithReward =
                userInfo[msg.sender].stakeBalanceWithReward +
                _pendingReward;
            userInfo[msg.sender].autoClaimWithStakeUnstake = _pendingReward;
            userInfo[msg.sender].totalClaimedReward = 0;
            if (
                block.timestamp <
                userInfo[msg.sender].nextCompoundDuringStakeUnstake
            ) {
                userInfo[msg.sender].stakeBalanceWithReward =
                    userInfo[msg.sender].stakeBalanceWithReward +
                    cpending;
                userInfo[msg.sender].autoClaimWithStakeUnstake =
                    userInfo[msg.sender].autoClaimWithStakeUnstake +
                    cpending;
            }
        }

        userInfo[msg.sender].stakeBalanceWithReward =
            userInfo[msg.sender].stakeBalanceWithReward +
            usdAmount;
        userInfo[msg.sender].stakeBalance =
            userInfo[msg.sender].stakeBalance +
            usdAmount;
        userInfo[msg.sender].lastStakeUnstakeTimestamp = block.timestamp;
        userInfo[msg.sender].nextCompoundDuringStakeUnstake = nextCompound();
        userInfo[msg.sender].isStaker = true;
        iCompoundAmount[msg.sender] = 0;
        dCompoundAmount[msg.sender] = 0;
        s = s + usdAmount;
        s_v = s_v + amount;
        emit Stake(msg.sender, usdAmount);
    }

    function unStake(uint256 amount) external nonReentrant {
        require(isBlock[msg.sender] == false, "blocked");
        require(
            amount <= userInfo[msg.sender].stakeBalance,
            "invalid staked amount"
        );

        (, uint256 maxUnstakePerTx, ) = data.returnMaxStakeUnstake();
        require(amount <= maxUnstakePerTx, "exceed unstake limit per tx");
        require(amount > unstake_fee, "amount less then unstake_fee");

        uint256 pending = compoundedReward(msg.sender);
        uint256 stakeBalance = userInfo[msg.sender].stakeBalance;
        uint256 _price = busdPrice.price();
        uint256 vyncAmount = (amount * decimal4) / _price;
        uint256 fee = (unstake_fee * decimal4) / _price;
        vyncAmount = vyncAmount - fee;
        vync.transfer(msg.sender, vyncAmount);
        vync.transfer(TreasuryAddress, fee);
        amount = amount - unstake_fee;
        emit UnStake(msg.sender, amount);

        // reward update
        if (amount < stakeBalance) {
            uint256 _pendingReward = compoundedReward(msg.sender);

            userInfo[msg.sender]
                .lastCompoundedRewardWithStakeUnstakeClaim = lastCompoundedReward(
                msg.sender
            );

            userInfo[msg.sender].autoClaimWithStakeUnstake = _pendingReward;

            // update state

            userInfo[msg.sender].lastStakeUnstakeTimestamp = block.timestamp;
            userInfo[msg.sender]
                .nextCompoundDuringStakeUnstake = nextCompound();
            userInfo[msg.sender].totalClaimedReward = 0;

            userInfo[msg.sender].stakeBalanceWithReward =
                userInfo[msg.sender].stakeBalanceWithReward -
                amount +
                unstake_fee;
            userInfo[msg.sender].stakeBalance =
                userInfo[msg.sender].stakeBalance -
                amount +
                unstake_fee;
            u = u + amount + unstake_fee;
            u_v = u_v + vyncAmount + fee;
        }

        if (amount >= stakeBalance) {
            u = u + stakeBalance;
            u_v = u_v + vyncAmount + fee;
            userInfo[msg.sender].pendingRewardAfterFullyUnstake = pending;
            userInfo[msg.sender].isClaimAferUnstake = true;
            userInfo[msg.sender].stakeBalanceWithReward = 0;
            userInfo[msg.sender].stakeBalance = 0;
            userInfo[msg.sender].isStaker = false;
            userInfo[msg.sender].totalClaimedReward = 0;
            userInfo[msg.sender].autoClaimWithStakeUnstake = 0;
            userInfo[msg.sender].lastCompoundedRewardWithStakeUnstakeClaim = 0;
        }

        if (userInfo[msg.sender].pendingRewardAfterFullyUnstake == 0) {
            userInfo[msg.sender].isClaimAferUnstake = false;
        }

        iCompoundAmount[msg.sender] = 0;
        dCompoundAmount[msg.sender] = 0;
    }

    function cPendingReward(address user)
        internal
        view
        returns (uint256 _compoundedReward)
    {
        uint256 reward;
        if (
            userInfo[user].lastClaimTimestamp <
            userInfo[user].nextCompoundDuringStakeUnstake &&
            userInfo[user].lastStakeUnstakeTimestamp <
            userInfo[user].nextCompoundDuringStakeUnstake
        ) {
            (uint256 a, uint256 compoundRate, ) = data.returnData();
            a = a / compoundRate;
            uint256 tsec = userInfo[user].nextCompoundDuringStakeUnstake -
                userInfo[user].lastStakeUnstakeTimestamp;
            uint256 stakeSec = block.timestamp -
                userInfo[user].lastStakeUnstakeTimestamp;
            uint256 sec = tsec > stakeSec ? stakeSec : tsec;
            uint256 balance = userInfo[user].stakeBalanceWithReward;
            reward = (balance.mul(a)).div(100);
            reward = reward / decimal18;
            _compoundedReward = reward * sec;
        }
    }

    function compoundedReward(address user)
        public
        view
        returns (uint256 _compoundedReward)
    {
        address _user = user;
        uint256 nextcompound = userInfo[user].nextCompoundDuringStakeUnstake;
        (, uint256 compoundRate, ) = data.returnData();
        uint256 compoundTime = block.timestamp > nextcompound
            ? block.timestamp - nextcompound
            : 0;
        uint256 loopRound = compoundTime / compoundRate;
        uint256 reward = 0;
        if (userInfo[user].isStaker == false) {
            loopRound = 0;
        }
        (uint256 a, , ) = data.returnData();
        _compoundedReward = 0;
        uint256 cpending = cPendingReward(user);
        uint256 balance = userInfo[user].stakeBalanceWithReward + cpending;

        for (uint256 i = 1; i <= loopRound; i++) {
            uint256 amount = balance.add(reward);
            reward = (amount.mul(a)).div(100);
            reward = reward / decimal18;
            _compoundedReward = _compoundedReward.add(reward);
            balance = amount;
        }

        if (_compoundedReward != 0) {
            uint256 sum = _compoundedReward +
                userInfo[user].autoClaimWithStakeUnstake;
            _compoundedReward = sum > userInfo[user].totalClaimedReward
                ? sum - userInfo[user].totalClaimedReward
                : 0;
            _compoundedReward = _compoundedReward + cPendingReward(user);
        }

        if (_compoundedReward == 0) {
            _compoundedReward = userInfo[user].autoClaimWithStakeUnstake;

            if (
                block.timestamp > userInfo[user].nextCompoundDuringStakeUnstake
            ) {
                _compoundedReward = _compoundedReward + cPendingReward(user);
            }
        }

        if (userInfo[user].isClaimAferUnstake == true) {
            _compoundedReward =
                _compoundedReward +
                userInfo[user].pendingRewardAfterFullyUnstake;
        }

        (
            uint256 aprChangeTimestamp,
            uint256 aprChangePercentage,
            bool isAprIncrease
        ) = data.returnAprData();

        if (userInfo[_user].lastStakeUnstakeTimestamp < aprChangeTimestamp) {
            if (isAprIncrease == false) {
                _compoundedReward =
                    _compoundedReward -
                    ((userInfo[_user].autoClaimWithStakeUnstake *
                        aprChangePercentage) / 100);
            }

            if (isAprIncrease == true) {
                _compoundedReward =
                    _compoundedReward +
                    ((userInfo[_user].autoClaimWithStakeUnstake *
                        aprChangePercentage) / 100);
            }
        }

        if (iCompoundAmount[_user] > 0 || dCompoundAmount[_user] > 0) {
            _compoundedReward = _compoundedReward + iCompoundAmount[_user];
            _compoundedReward = _compoundedReward - dCompoundAmount[_user];
        }
    }

    function compoundedRewardInVync(address user)
        public
        view
        returns (uint256 _compoundedVyncReward)
    {
        uint256 reward;
        reward = compoundedReward(user);
        uint256 _price = busdPrice.price();
        _compoundedVyncReward = (reward * decimal4) / _price;
    }

    function pendingReward(address user)
        public
        view
        returns (uint256 _pendingReward)
    {
        uint256 nextcompound = userInfo[user].nextCompoundDuringStakeUnstake;
        (, uint256 compoundRate, ) = data.returnData();
        uint256 compoundTime = block.timestamp > nextcompound
            ? block.timestamp - nextcompound
            : 0;
        uint256 loopRound = compoundTime / compoundRate;
        uint256 reward = 0;
        (uint256 a, , ) = data.returnData();
        if (userInfo[user].isStaker == false) {
            loopRound = 0;
        }
        _pendingReward = 0;
        uint256 cpending = cPendingReward(user);
        uint256 balance = userInfo[user].stakeBalanceWithReward + cpending;

        for (uint256 i = 1; i <= loopRound + 1; i++) {
            uint256 amount = balance.add(reward);
            reward = (amount.mul(a)).div(100);
            reward = reward / decimal18;
            _pendingReward = _pendingReward.add(reward);
            balance = amount;
        }

        if (_pendingReward != 0) {
            _pendingReward =
                _pendingReward -
                userInfo[user].totalClaimedReward +
                userInfo[user].autoClaimWithStakeUnstake +
                cPendingReward(user);

            if (
                block.timestamp < userInfo[user].nextCompoundDuringStakeUnstake
            ) {
                _pendingReward =
                    userInfo[user].autoClaimWithStakeUnstake +
                    cPendingReward(user);
            }
        }

        if (userInfo[user].isClaimAferUnstake == true) {
            _pendingReward =
                _pendingReward +
                userInfo[user].pendingRewardAfterFullyUnstake;
        }

        _pendingReward = _pendingReward - compoundedReward(user);
    }

    function pendingRewardInVync(address user)
        public
        view
        returns (uint256 _pendingVyncReward)
    {
        uint256 reward;
        reward = pendingReward(user);
        uint256 _price = busdPrice.price();
        _pendingVyncReward = (reward * decimal4) / _price;
    }

    function lastCompoundedReward(address user)
        public
        view
        returns (uint256 _compoundedReward)
    {
        uint256 nextcompound = userInfo[user].nextCompoundDuringStakeUnstake;
        (, uint256 compoundRate, ) = data.returnData();
        uint256 compoundTime = block.timestamp > nextcompound
            ? block.timestamp - nextcompound
            : 0;
        compoundTime = compoundTime > compoundRate
            ? compoundTime - compoundRate
            : 0;
        uint256 loopRound = compoundTime / compoundRate;
        uint256 reward = 0;
        if (userInfo[user].isStaker == false) {
            loopRound = 0;
        }
        (uint256 a, , ) = data.returnData();
        _compoundedReward = 0;
        uint256 cpending = cPendingReward(user);
        uint256 balance = userInfo[user].stakeBalanceWithReward + cpending;

        for (uint256 i = 1; i <= loopRound; i++) {
            uint256 amount = balance.add(reward);
            reward = (amount.mul(a)).div(100);
            reward = reward / decimal18;
            _compoundedReward = _compoundedReward.add(reward);
            balance = amount;
        }

        if (_compoundedReward != 0) {
            uint256 sum = _compoundedReward +
                userInfo[user].autoClaimWithStakeUnstake;
            _compoundedReward = sum > userInfo[user].totalClaimedReward
                ? sum - userInfo[user].totalClaimedReward
                : 0;
            _compoundedReward = _compoundedReward + cPendingReward(user);
        }

        if (_compoundedReward == 0) {
            _compoundedReward = userInfo[user].autoClaimWithStakeUnstake;

            if (
                block.timestamp >
                userInfo[user].nextCompoundDuringStakeUnstake + compoundRate
            ) {
                _compoundedReward = _compoundedReward + cPendingReward(user);
            }
        }

        if (userInfo[user].isClaimAferUnstake == true) {
            _compoundedReward =
                _compoundedReward +
                userInfo[user].pendingRewardAfterFullyUnstake;
        }

        uint256 result = compoundedReward(user) - _compoundedReward;

        if (
            block.timestamp < userInfo[user].nextCompoundDuringStakeUnstake ||
            block.timestamp < userInfo[user].nextCompoundDuringClaim
        ) {
            result =
                result +
                userInfo[user].lastCompoundedRewardWithStakeUnstakeClaim;
        }

        _compoundedReward = result;
    }

    function rewardCalculation(address user) internal {
        (, uint256 compoundRate, ) = data.returnData();
        address _user = user;
        uint256 nextcompound = userInfo[user].nextCompoundDuringStakeUnstake;
        uint256 compoundTime = block.timestamp > nextcompound
            ? block.timestamp - nextcompound
            : 0;
        uint256 loopRound = compoundTime / compoundRate;
        (uint256 a, , ) = data.returnData();
        uint256 reward;
        if (userInfo[user].isStaker == false) {
            loopRound = 0;
        }
        uint256 totalReward;
        uint256 cpending = cPendingReward(user);
        uint256 balance = userInfo[user].stakeBalanceWithReward + cpending;

        for (uint256 i = 1; i <= loopRound; i++) {
            uint256 amount = balance.add(reward);
            reward = (amount.mul(a)).div(100);
            reward = reward / decimal18;
            totalReward = totalReward.add(reward);
            balance = amount;
        }

        if (userInfo[user].isClaimAferUnstake == true) {
            totalReward =
                totalReward +
                userInfo[user].pendingRewardAfterFullyUnstake;
        }
        totalReward = totalReward + cPendingReward(user);
        userInfo[user].lastClaimedReward =
            totalReward -
            userInfo[user].totalClaimedReward;
        userInfo[user].totalClaimedReward =
            userInfo[user].totalClaimedReward +
            userInfo[user].lastClaimedReward -
            cPendingReward(user);

        (
            uint256 aprChangeTimestamp,
            uint256 aprChangePercentage,
            bool isAprIncrease
        ) = data.returnAprData();

        if (userInfo[_user].lastStakeUnstakeTimestamp < aprChangeTimestamp) {
            if (isAprIncrease == false) {
                userInfo[_user].autoClaimWithStakeUnstake =
                    userInfo[_user].autoClaimWithStakeUnstake -
                    ((userInfo[_user].autoClaimWithStakeUnstake *
                        aprChangePercentage) / 100);
            }

            if (isAprIncrease == true) {
                userInfo[_user].autoClaimWithStakeUnstake =
                    userInfo[_user].autoClaimWithStakeUnstake +
                    (((userInfo[_user].autoClaimWithStakeUnstake) *
                        aprChangePercentage) / 100);
            }
        }
    }

    function claim() public nonReentrant {
        require(isClaim == true, "claim stopped");
        require(isBlock[msg.sender] == false, "blocked");
        require(
            userInfo[msg.sender].isStaker == true ||
                userInfo[msg.sender].isClaimAferUnstake == true,
            "user not staked"
        );
        userInfo[msg.sender]
            .lastCompoundedRewardWithStakeUnstakeClaim = lastCompoundedReward(
            msg.sender
        );

        rewardCalculation(msg.sender);
        uint256 reward = userInfo[msg.sender].lastClaimedReward +
            userInfo[msg.sender].autoClaimWithStakeUnstake;
        require(reward > 0, "can't reap zero reward");
        if (
            iCompoundAmount[msg.sender] > 0 || dCompoundAmount[msg.sender] > 0
        ) {
            reward = reward + iCompoundAmount[msg.sender];
            reward = reward - dCompoundAmount[msg.sender];
        }
        uint256 _price = busdPrice.price();
        uint256 rewardAmount = (reward * decimal4) / _price;

        treasury.send(msg.sender, rewardAmount);
        emit rewardClaim(msg.sender, rewardAmount);
        userInfo[msg.sender].autoClaimWithStakeUnstake = 0;
        userInfo[msg.sender].lastClaimTimestamp = block.timestamp;
        userInfo[msg.sender].nextCompoundDuringClaim = nextCompound();

        if (
            userInfo[msg.sender].isClaimAferUnstake == true &&
            userInfo[msg.sender].isStaker == false
        ) {
            userInfo[msg.sender].lastStakeUnstakeTimestamp = 0;
            userInfo[msg.sender].lastClaimedReward = 0;
            userInfo[msg.sender].totalClaimedReward = 0;
        }

        if (
            userInfo[msg.sender].isClaimAferUnstake == true &&
            userInfo[msg.sender].isStaker == true
        ) {
            userInfo[msg.sender].totalClaimedReward =
                userInfo[msg.sender].totalClaimedReward -
                userInfo[msg.sender].pendingRewardAfterFullyUnstake;
        }
        bool c = userInfo[msg.sender].isClaimAferUnstake;
        if (c == true) {
            userInfo[msg.sender].pendingRewardAfterFullyUnstake = 0;
            userInfo[msg.sender].isClaimAferUnstake = false;
        }

        dCompoundAmount[msg.sender] = 0;
        iCompoundAmount[msg.sender] = 0;
    }

    function totalStake() external view returns (uint256 stakingAmount) {
        stakingAmount = s;
    }

    function totalUnstake() external view returns (uint256 unstakingAmount) {
        unstakingAmount = u;
    }

    function totalStakeInVync() external view returns (uint256 stakingAmount) {
        stakingAmount = s_v;
    }

    function totalUnstakeInVync()
        external
        view
        returns (uint256 unstakingAmount)
    {
        unstakingAmount = u_v;
    }

    function transferAnyERC20Token(
        address _tokenAddress,
        address _to,
        uint256 _amount
    ) public onlyOwner {
        IERC20(_tokenAddress).transfer(_to, _amount);
    }

    function vyncPrice() public view returns (uint256 _price) {
        _price = busdPrice.price();
    }

    function set_migrate(bool _isMigrate) public onlyOwner {
        isMigrate = _isMigrate;
    }

    function _stopMigrate(address _address) public onlyOwner {
        stopMigrate[_address] = true;
    }

    function setMigratePoolAddress(address _address) public onlyOwner {
        migrateAddress = _address;
    }

    function migrateStaking() public {
        address staker = msg.sender;
        require(isMigrate == true, "migration off");
        require(stopMigrate[staker] == false, "can't migrate");

        VyncMigrate.userInfoData memory user= migrate.userInfo(staker);
        userInfo[staker].stakeBalanceWithReward = user.stakeBalance;
        userInfo[staker].stakeBalance = user.stakeBalance;
        userInfo[staker].lastClaimedReward=0;
        userInfo[staker].lastStakeUnstakeTimestamp = user.lastStakeUnstakeTimestamp;
        userInfo[staker].lastClaimTimestamp = user.lastClaimTimestamp;
        userInfo[staker].isStaker = true;
        userInfo[staker].totalClaimedReward = 0;
        userInfo[staker].autoClaimWithStakeUnstake= migrate.compoundedReward(staker);
        userInfo[staker].pendingRewardAfterFullyUnstake = user.autoClaimWithStakeUnstake;
        userInfo[staker].isClaimAferUnstake = user.isClaimAferUnstake;
        userInfo[staker].nextCompoundDuringStakeUnstake = nextCompound();
        userInfo[staker].nextCompoundDuringClaim;
        userInfo[staker].lastCompoundedRewardWithStakeUnstakeClaim;
        s= s+user.stakeBalance;

        stopMigrate[staker] = true;
    }

    function migrateStakingByOwner(address _staker) public onlyOwner {
        address staker = _staker;
        require(stopMigrate[staker] = false, "can't migrate");

        VyncMigrate.userInfoData memory user= migrate.userInfo(staker);
        userInfo[staker].stakeBalanceWithReward = user.stakeBalance;
        userInfo[staker].stakeBalance = user.stakeBalance;
        userInfo[staker].lastClaimedReward=0;
        userInfo[staker].lastStakeUnstakeTimestamp = user.lastStakeUnstakeTimestamp;
        userInfo[staker].lastClaimTimestamp = user.lastClaimTimestamp;
        userInfo[staker].isStaker = true;
        userInfo[staker].totalClaimedReward = 0;
        userInfo[staker].autoClaimWithStakeUnstake = migrate.compoundedReward(staker);
        userInfo[staker].pendingRewardAfterFullyUnstake = user.autoClaimWithStakeUnstake;
        userInfo[staker].isClaimAferUnstake = user.isClaimAferUnstake;
        userInfo[staker].nextCompoundDuringStakeUnstake = nextCompound();
        userInfo[staker].nextCompoundDuringClaim;
        userInfo[staker].lastCompoundedRewardWithStakeUnstakeClaim;
        s=s+user.stakeBalance;

        stopMigrate[staker] = true;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
library SafeMath {
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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
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