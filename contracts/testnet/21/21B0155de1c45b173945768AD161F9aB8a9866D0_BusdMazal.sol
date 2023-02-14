/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

/**
*/

/*
──────────────────────────────────────────────────────────────────
─██████████████───██████──██████─██████████████─████████████──────
─██░░░░░░░░░░██───██░░██──██░░██─██░░░░░░░░░░██─██░░░░░░░░████────
─██░░██████░░██───██░░██──██░░██─██░░██████████─██░░████░░░░██────
─██░░██──██░░██───██░░██──██░░██─██░░██─────────██░░██──██░░██────
─██░░██████░░████─██░░██──██░░██─██░░██████████─██░░██──██░░██────
─██░░░░░░░░░░░░██─██░░██──██░░██─██░░░░░░░░░░██─██░░██──██░░██────
─██░░████████░░██─██░░██──██░░██─██████████░░██─██░░██──██░░██────
─██░░██────██░░██─██░░██──██░░██─────────██░░██─██░░██──██░░██────
─██░░████████░░██─██░░██████░░██─██████████░░██─██░░████░░░░██────
─██░░░░░░░░░░░░██─██░░░░░░░░░░██─██░░░░░░░░░░██─██░░░░░░░░████────
─████████████████─██████████████─██████████████─████████████──────
──────────────────────────────────────────────────────────────────
────────────────────────────────────────────────────────────────────────────────────────
─██████──────────██████─██████████████─██████████████████─██████████████─██████─────────
─██░░██████████████░░██─██░░░░░░░░░░██─██░░░░░░░░░░░░░░██─██░░░░░░░░░░██─██░░██─────────
─██░░░░░░░░░░░░░░░░░░██─██░░██████░░██─████████████░░░░██─██░░██████░░██─██░░██─────────
─██░░██████░░██████░░██─██░░██──██░░██─────────████░░████─██░░██──██░░██─██░░██─────────
─██░░██──██░░██──██░░██─██░░██████░░██───────████░░████───██░░██████░░██─██░░██─────────
─██░░██──██░░██──██░░██─██░░░░░░░░░░██─────████░░████─────██░░░░░░░░░░██─██░░██─────────
─██░░██──██████──██░░██─██░░██████░░██───████░░████───────██░░██████░░██─██░░██─────────
─██░░██──────────██░░██─██░░██──██░░██─████░░████─────────██░░██──██░░██─██░░██─────────
─██░░██──────────██░░██─██░░██──██░░██─██░░░░████████████─██░░██──██░░██─██░░██████████─
─██░░██──────────██░░██─██░░██──██░░██─██░░░░░░░░░░░░░░██─██░░██──██░░██─██░░░░░░░░░░██─
─██████──────────██████─██████──██████─██████████████████─██████──██████─██████████████─
────────────────────────────────────────────────────────────────────────────────────────
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IBEP20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor(address payable owner_) {
        _owner = owner_;
        emit OwnershipTransferred(address(0), owner_);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract BusdMazal is Ownable {
    address public dev1FeeWallet;
    address public dev2FeeWallet;
    address public marketingFeeWallet;
    address public marketingManagerFeeWallet;
    address public ceoFeeWallet;
    address public communityLeaderFeeWallet;
    address public modsChiefFeeWallet;
    IBEP20 public busd = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); // Main

    uint256 public totalDeposits;
    uint256 public totalCompound;
    uint256 public totalWithdrawan;
    uint256 public totalRefRewards;
    uint256 public uniqueStakers;
    uint256 public currentWeek;
    uint256 public launchTime;
    bool public launched;

    uint256 public depositFeePercent = 4_00;
    uint256 public withdrawFeePercent = 4_00;

    uint256 public referrerPercent = 1_50;
    uint256 public referralPercent = 1_50;
    uint256 public marketingFeePercent = 75_00;
    uint256 public dev1FeePercent = 18_75;
    uint256 public dev2FeePercent = 18_75;
    uint256 public ceoFeePercent = 11_25;
    uint256 public marketingManagerFeePercent = 10_00;
    uint256 public communityLeaderFeePercent = 8_75;
    uint256 public modsChiefFeePercent = 7_50;
    uint256 public percentDivider = 100_00;

    uint256 public minDeposit = 20e18;
    uint256 public maxDeposit = 50_000e18;
    uint256 public maxWithdrawl = 10_000e18;
    uint256 public dailyRewardPercent = 8_00;
    uint256 public maxRewardPercent = 300_00;
    uint256 public timeStep = 1 days;
    uint256 public withdrawDuration = 7 days;
    uint256 public accumulationDuration = 10 days;

    struct User {
        bool isExists;
        uint256 depositAmount;
        uint256 currentAmount;
        address referrer;
        uint256 referrals;
        uint256 referralRewards;
        uint256 refRewardsWithdrawn;
        uint256 checkpoint;
        uint256 totalDeposits;
        uint256 totalCompound;
        uint256 totalWithdrawan;
        uint256 pendingRewards;
    }

    mapping(address => User) users;
    mapping(uint256 => address[]) public currentWeekUsers;
    mapping(uint256 => mapping(address => bool)) public isInvested;

    event INVEST(address user, uint256 amount);
    event REINVEST(address user, uint256 amount);
    event WITHDRAW(address user, uint256 amount);

    constructor(address payable _owner) Ownable(_owner) {}

    function launch() external onlyOwner {
        require(!launched, "Already launched");
        launched = true;
        launchTime = block.timestamp;
    }

    function calculateWeek() public view returns (uint256) {
        return (block.timestamp - launchTime) / (7 * timeStep);
    }

    function updateWeekly() public {
        if (currentWeek != calculateWeek()) {
            currentWeek = calculateWeek();
        }
    }

    function invest(address _referrer, uint256 _amount) public {
        require(launched, "Wait for the launch");
        updateWeekly();
        User storage user = users[msg.sender];
        require(_amount >= minDeposit, "Below minimum limit");
        require(
            user.depositAmount + _amount <= maxDeposit,
            "Exceeds maximum limit"
        );

        if (!user.isExists) {
            user.isExists = true;
            uniqueStakers++;
        }
        busd.transferFrom(msg.sender, address(this), _amount);

        uint256 feeAmount = (_amount * depositFeePercent) / percentDivider;
        takeDepositFee(feeAmount);

        uint256 pendingRewards;
        pendingRewards = calculateReward(msg.sender);
        user.pendingRewards += pendingRewards;
        setDepositData(msg.sender, _amount, 0);
        setReferrer(msg.sender, _referrer, _amount);

        if (!isInvested[currentWeek][msg.sender]) {
            isInvested[currentWeek][msg.sender] = true;
            currentWeekUsers[currentWeek].push(msg.sender);
        }

        emit INVEST(msg.sender, _amount);
    }

    function withdraw(uint256 _claimPercent) public {
        require(launched, "Wait for the launch");
        require(_claimPercent <= percentDivider,"Invalid percent");
        updateWeekly();
        User storage user = users[msg.sender];
        require(user.isExists, "No deposit found");
        require(
            block.timestamp > user.checkpoint + withdrawDuration,
            "Wait for next withdraw time"
        );
        uint256 pendingRewards = user.pendingRewards;
        user.pendingRewards = 0;
        pendingRewards += calculateReward(msg.sender);
        user.totalWithdrawan += pendingRewards;
        totalWithdrawan += pendingRewards;
        pendingRewards += user.referralRewards;
        user.refRewardsWithdrawn += user.referralRewards;
        user.referralRewards = 0;
        require(pendingRewards > 0, "no reward yet");
        if (pendingRewards > maxWithdrawl) {
            user.pendingRewards += (pendingRewards - maxWithdrawl);
            pendingRewards = maxWithdrawl;
        }

        uint256 forClaim = (pendingRewards * _claimPercent) / percentDivider;
        if(forClaim > 0){
            busd.transfer(msg.sender, forClaim);
        }

        uint256 feeAmount = (forClaim * withdrawFeePercent) / percentDivider;
        if(feeAmount > 0){
            takeWithdrawFee(feeAmount);
        }

        uint256 forCompound = pendingRewards - forClaim;
        if (forCompound > 0) {
            setDepositData(msg.sender, 0, forCompound);
            emit REINVEST(msg.sender, forCompound);
        } else {
            user.checkpoint = block.timestamp;
        }

        emit WITHDRAW(msg.sender, forClaim);
    }

    function setDepositData(
        address _user,
        uint256 _amount,
        uint256 _reward
    ) private {
        User storage user = users[_user];
        user.depositAmount += _amount;
        user.currentAmount += (_amount + _reward);
        user.checkpoint = block.timestamp;
        user.totalCompound += _reward;
        totalCompound += _reward;
        user.totalDeposits += _amount;
        totalDeposits += _amount;
    }

    function setReferrer(
        address _user,
        address _referrer,
        uint256 _amount
    ) private {
        User storage user = users[_user];

        if (user.referrer == address(0) && _user != owner()) {
            if (_referrer != _user) {
                user.referrer = _referrer;
            }
        }

        if (user.referrer != address(0)) {
            users[user.referrer].referrals++;
            uint256 userRewards = (_amount * referralPercent) / percentDivider;
            uint256 refRewards = (_amount * referrerPercent) / percentDivider;
            user.referralRewards += userRewards;
            users[user.referrer].referralRewards += refRewards;
            totalRefRewards += (userRewards + refRewards);
        }
    }

    function takeDepositFee(uint256 _feeAmount) private {

        uint256 dev1FeeAmount = (_feeAmount * dev1FeePercent) / percentDivider;
        busd.transfer(dev1FeeWallet, dev1FeeAmount);

        uint256 dev2FeeAmount = (_feeAmount * dev2FeePercent) / percentDivider;
        busd.transfer(dev2FeeWallet, dev2FeeAmount);

        uint256 ceoFeeAmount = (_feeAmount * ceoFeePercent) / percentDivider;
        busd.transfer(ceoFeeWallet, ceoFeeAmount);

        uint256 marketingManagerFeeAmount = (_feeAmount *
            marketingManagerFeePercent) / percentDivider;
        busd.transfer(marketingManagerFeeWallet, marketingManagerFeeAmount);

        uint256 communityFeeAmount = (_feeAmount * communityLeaderFeePercent) /
            percentDivider;
        busd.transfer(communityLeaderFeeWallet, communityFeeAmount);

        uint256 modsChiefFeeAmount = (_feeAmount * modsChiefFeePercent) /
            percentDivider;
        busd.transfer(modsChiefFeeWallet, modsChiefFeeAmount);
    }

    function takeWithdrawFee(uint256 _feeAmount) private {
        uint256 marketingFeeAmount = (_feeAmount * marketingFeePercent) /
            percentDivider;
        busd.transfer(marketingFeeWallet, marketingFeeAmount);

        uint256 dev1FeeAmount = (_feeAmount * dev1FeePercent) / percentDivider;
        busd.transfer(dev1FeeWallet, dev1FeeAmount);

        uint256 dev2FeeAmount = (_feeAmount * dev2FeePercent) / percentDivider;
        busd.transfer(dev2FeeWallet, dev2FeeAmount);

        uint256 ceoFeeAmount = (_feeAmount * ceoFeePercent) / percentDivider;
        busd.transfer(ceoFeeWallet, ceoFeeAmount);

        uint256 marketingManagerFeeAmount = (_feeAmount *
            marketingManagerFeePercent) / percentDivider;
        busd.transfer(marketingManagerFeeWallet, marketingManagerFeeAmount);

        uint256 communityFeeAmount = (_feeAmount * communityLeaderFeePercent) /
            percentDivider;
        busd.transfer(communityLeaderFeeWallet, communityFeeAmount);

        uint256 modsChiefFeeAmount = (_feeAmount * modsChiefFeePercent) /
            percentDivider;
        busd.transfer(modsChiefFeeWallet, modsChiefFeeAmount);
    }

    function calculateReward(address _user) public view returns (uint256) {
        User storage user = users[_user];
        uint256 rewardDuration = block.timestamp - user.checkpoint;
        if (rewardDuration > accumulationDuration) {
            rewardDuration = accumulationDuration;
        }
        uint256 reward = (user.currentAmount *
            rewardDuration *
            dailyRewardPercent) / (percentDivider * timeStep);
        uint256 maxClaimable = (user.currentAmount * maxRewardPercent) /
            percentDivider;
        uint256 remaining = maxClaimable - (user.totalWithdrawan + user.pendingRewards);
        if (reward > remaining) {
            reward = remaining;
        }
        return reward;
    }

    function getContractBalance() public view returns (uint256) {
        return busd.balanceOf(address(this));
    }

    function random(
        uint256 from,
        uint256 to,
        uint256 salty
    ) public view returns (uint256) {
        uint256 seed = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp +
                        block.difficulty +
                        ((
                            uint256(keccak256(abi.encodePacked(block.coinbase)))
                        ) / (block.timestamp)) +
                        block.gaslimit +
                        ((uint256(keccak256(abi.encodePacked(msg.sender)))) /
                            (block.timestamp)) +
                        block.number +
                        salty
                )
            )
        );
        return seed % (to - from);
    }

    function getUserInfo(address _user)
        public
        view
        returns (
            bool _isExists,
            uint256 _depositAmount,
            uint256 _currentAmount,
            uint256 _checkpoint,
            uint256 _totalDeposits,
            uint256 _totalCompound,
            uint256 _totalWithdrawan,
            uint256 _pendingRewards
        )
    {
        User storage user = users[_user];
        _isExists = user.isExists;
        _depositAmount = user.depositAmount;
        _currentAmount = user.currentAmount;
        _checkpoint = user.checkpoint;
        _totalDeposits = user.totalDeposits;
        _totalCompound = user.totalCompound;
        _totalWithdrawan = user.totalWithdrawan;
        _pendingRewards = user.pendingRewards;
    }

    function getUserRefInfo(address _user)
        public
        view
        returns (
            address _referrer,
            uint256 _referrals,
            uint256 _referralRewards,
            uint256 _refRewardsWithdrawn
        )
    {
        User storage user = users[_user];
        _referrer = user.referrer;
        _referrals = user.referrals;
        _referralRewards = user.referralRewards;
        _refRewardsWithdrawn = user.refRewardsWithdrawn;
    }

    function SetFeeWallets(
        address _wallet1,
        address _wallet2,
        address _wallet3,
        address _wallet4,
        address _wallet5,
        address _wallet6,
        address _wallet7
    ) external onlyOwner {
        dev1FeeWallet = _wallet1;
        dev2FeeWallet = _wallet2;
        marketingFeeWallet = _wallet3;
        ceoFeeWallet = _wallet4;
        marketingManagerFeeWallet = _wallet5;
        communityLeaderFeeWallet = _wallet6;
        modsChiefFeeWallet = _wallet7;
    }

    function SetLimits(uint256 _min, uint256 _max) external onlyOwner {
        minDeposit = _min;
        maxDeposit = _max;
    }
}