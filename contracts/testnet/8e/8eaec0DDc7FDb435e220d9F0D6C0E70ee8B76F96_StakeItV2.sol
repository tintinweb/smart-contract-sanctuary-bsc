/**
 *Submitted for verification at BscScan.com on 2023-01-05
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IBEP20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function approve(address sender, uint256 value) external returns (bool);

    function allowance(address sender, address spender)
        external
        view
        returns (uint256);

    function transfer(address recepient, uint256 value) external returns (bool);

    function transferFrom(
        address sender,
        address recepient,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed sender,
        address indexed spender,
        uint256 value
    );
}

contract Context {
    constructor() {}

    function _msgsender() internal view returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address internal _Owner;

    event transferOwnerShip(
        address indexed _previousOwner,
        address indexed _newOwner
    );

    constructor() {
        address msgsender = _msgsender();
        _Owner = msgsender;
        emit transferOwnerShip(address(0), msgsender);
    }

    function checkOwner() public view returns (address) {
        return _Owner;
    }

    modifier OnlyOwner() {
        require(_Owner == _msgsender(), "Only owner can change the Ownership");
        _;
    }

    function transferOwnership(address _newOwner) public OnlyOwner {
        _transferOwnership(_newOwner);
    }

    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0), "Owner should not be 0 address");
        emit transferOwnerShip(_Owner, _newOwner);
        _Owner = _newOwner;
    }
}

contract StakeItV2 is Ownable {
    address public signerAddress;
    address public operatorAddress;

    IBEP20 public STC_Addr;
    IBEP20 public BUSD;

    uint256 diviser = 100e18;
    uint256 public maxMintStcPerDay = 41e18;
    uint256 public updateRewardPershareLimit = 1 days;
    uint256 public lastRewardPerShareUpdate;
    uint256 public totalStakedAmount;
    uint256 public rewardPerShare;

    bool public rewardClaiming;

    mapping (Pack => bool) public packageStatus;
    mapping(Pack => Packages) public packages;
    mapping(address => userDetails) public UserDetails;
    mapping(uint256 => uint256) public rewards; //EG := LEVEL => REWARD
    mapping(uint256 => uint256) public levels;
    mapping(bytes32 => bool) public hashStatus;

    enum Pack {
        TRIAL,
        STARTER,
        GROWTH
    }

    struct Packages {
        uint256 lifeSpan;
        uint256 busdPrice;
        uint256 busdCapacity;
        uint256 poolSTCamount;
    }

    struct userDetails {
        address reffererAddr;
        uint256 uplineLength;
        uint256 level;
        address[] directRefferals;
        mapping(uint256 => uint256) affiliateRewardForLevel;
        mapping(uint256 => address[]) levelRefferredUsers;
        mapping(address => uint256) reffererAddedLevel;
        mapping(Pack => UserPack) packages;
    }

    struct UserPack {
        uint256 stakedAmount;
        uint256 unClaimedAmt;
        uint256 rewardDept;
        uint256 totalRewardClaimed;
        uint256 packageBoughtTime;
        uint256 stakedTime;
        uint256 lastRewardClaimedTime;
        bool isActive;
    }

    event packageBought(Pack pack, uint256 busdAmount);
    event LevelBought(
        address indexed reffererAddr,
        address indexed refferingAddr,
        Pack indexed pack,
        uint256 level
    );
    event ClaimedAffiliate(
        address indexed userAddress,
        uint256 claimedRewardAmount,
        uint256 level
    );
    event Staked(
        Pack indexed pack,
        address indexed userAddress,
        uint256 stcAmountToStake
    );
    event ClaimedRewardAmount(
        Pack indexed pack,
        address indexed userAddress,
        uint256 indexed rewardAmount
    );
    event updatedPackage(
        Pack indexed pack,
        uint256 span,
        uint256 price,
        uint256 capacity
    );
    event SwapBusdToStc(address addr, uint256 busdAmount, uint256 busdPrice);
    event ClaimedCapital(
        address indexed user,
        Pack indexed pack,
        uint256 amount
    );
    event RewardUpdated(uint256 indexed level, uint256 percentage);
    event LevelRefCountUpdated(uint256 indexed level, uint256 refCounts);

    constructor(
        address signer,
        address stc_addr,
        address busd,
        address _operatorAddress,
        uint256 _deployTime
    ) {
        assembly {
            sstore(signerAddress.slot, signer)
            sstore(STC_Addr.slot, stc_addr)
            sstore(BUSD.slot, busd)
            sstore(operatorAddress.slot, _operatorAddress)
        }
        lastRewardPerShareUpdate = _deployTime;
        initPackages();
        initLevelRewards();
        initLevelsRefferalCount();
        initAdminActiveInAllPacks();
    }

    modifier onlyOperator() {
        require(msg.sender == operatorAddress, "Operator: u?");
        _;
    }

    modifier isDisabled() {
        require(!rewardClaiming, "Reward claiming is disabled!");
        _;
    }

    modifier ensure(uint256 expiry) {
        require(expiry > block.timestamp, "StakeIt: Expired!");
        _;
    }

    modifier ensurePackageStatus(Pack pack) {
        require(!packageStatus[pack], "StakeIt: This pack is disabled!");
        _;
    }

    function buyPackage(Pack pack) public ensurePackageStatus(pack) {
        require(pack <= Pack(2), "StakeIt: Invalid pack!");
        userDetails storage userdetails = UserDetails[msg.sender];
        Packages memory package = packages[pack];

        address reffererAddress = userdetails.reffererAddr;
        require(reffererAddress != address(0), "StakeIt: 0 ref");
        require(
            !userdetails.packages[pack].isActive ||
                userdetails.packages[pack].stakedAmount == 0,
            "STakeIt: User not found in this pack"
        );
        require(
            !validateUserPack(msg.sender),
            "User already existed, claim capital or pack not expired"
        );

        userDetails storage userReffererDetails = UserDetails[reffererAddress];
        require(
            userReffererDetails.uplineLength != 0,
            "StakeIt: Invalid upline!"
        );

        addAffiliateRewardAmountToTheReffs(userdetails, package);
        userdetails.packages[pack].packageBoughtTime = userdetails
            .packages[pack]
            .lastRewardClaimedTime = block.timestamp;
        if (userdetails.level == 0) userdetails.level = 1;
        if (!userdetails.packages[pack].isActive)
            userdetails.packages[pack].isActive = true;
        require(
            BUSD.transferFrom(msg.sender, address(this), package.busdPrice),
            "StakeIt: Tx failed"
        );
        emit packageBought(pack, package.busdPrice);
    }

    function buyLevel(
        Pack pack,
        address reffererAddress,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public ensure(expiry) ensurePackageStatus(pack) {
        require(pack <= Pack(2), "StakeIt: Invalid pack!");
        require(
            validateBuyLevelHash(
                reffererAddress,
                msg.sender,
                pack,
                expiry,
                v,
                r,
                s
            ),
            "Invalid sig"
        );
        Packages memory package = packages[pack];
        reffererAddress = reffererAddress == address(0)
            ? _Owner
            : reffererAddress;
        userDetails storage userRefferralDetails = UserDetails[msg.sender];
        userDetails storage userReffererDetails = UserDetails[reffererAddress];
        require(
            userRefferralDetails.reffererAddr == address(0),
            "StakeIt: User already reffered!"
        );
        require(
            !userRefferralDetails.packages[pack].isActive,
            "StakeIt: User already exist!"
        );
        require(userRefferralDetails.level == 0, "StakeIt: User exist!");
        require(
            reffererAddress == _Owner || checkRefBoughtAnyPack(reffererAddress),
            "StakeIt: Refferer not bought any pack yet!"
        );
        uint8 reffererPack = viewUserActivePack(reffererAddress, pack);
        require(reffererPack != uint8(3), "Invalid reffererPack!");

        userReffererDetails.directRefferals.push(msg.sender);

        if (reffererAddress != _Owner) {
            userRefferralDetails.uplineLength =
                userReffererDetails.uplineLength +
                1;
        } else {
            userRefferralDetails.uplineLength = 1;
        }

        userRefferralDetails.level = 1;
        userRefferralDetails.reffererAddr = reffererAddress;
        userRefferralDetails.packages[pack].packageBoughtTime = block.timestamp;
        userRefferralDetails.packages[pack].isActive = true;

        if (
            reffererAddress != _Owner &&
            userReffererDetails.directRefferals.length ==
            levels[userReffererDetails.level]
        ) {
            userReffererDetails.level <= 12
                ? userReffererDetails.level++
                : userReffererDetails.level;
        }
        userReffererDetails.reffererAddedLevel[msg.sender] = userReffererDetails
            .level;
        userReffererDetails
            .levelRefferredUsers[userReffererDetails.level]
            .push(msg.sender);
        addAffiliateRewardAmountToTheReffs(userRefferralDetails, package);
        require(
            BUSD.transferFrom(msg.sender, address(this), package.busdPrice),
            "Tx failed"
        );

        setHashCompleted(
            prepareBuyLevelHash(reffererAddress, msg.sender, pack, expiry),
            true
        );
        emit LevelBought(reffererAddress, msg.sender, pack, 1);
    }

    function stake(
        Pack pack,
        uint256 stcAmountToStake,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public ensure(expiry) {
        require(stcAmountToStake > 0, "StakeIt: Invalid STC amount");
        require(
            validateHash(msg.sender, stcAmountToStake, pack, expiry, v, r, s),
            "Invalid signature"
        );
        userDetails storage userdetails = UserDetails[msg.sender];
        Packages storage package = packages[pack];
        require(userdetails.reffererAddr != address(0), "StakeIt: zero ref!");
        require(
            userdetails.packages[pack].isActive,
            "StakeIt: User not found in this package! stake"
        );
        require(
            (userdetails.packages[pack].packageBoughtTime + package.lifeSpan) >
                block.timestamp,
            "StakeIt: User pack expired, claim capital!"
        );

        userdetails.packages[pack].unClaimedAmt += pendingReward(
            pack,
            msg.sender
        );
        userdetails.packages[pack].stakedTime = block.timestamp;
        userdetails.packages[pack].stakedAmount += stcAmountToStake;
        userdetails.packages[pack].rewardDept = (rewardPerShare *
            userdetails.packages[pack].stakedAmount);
        totalStakedAmount += stcAmountToStake;
        package.poolSTCamount += stcAmountToStake;
        require(
            STC_Addr.transferFrom(msg.sender, address(this), stcAmountToStake),
            "StakeIt: Tx failed!"
        );
        
        setHashCompleted(
            prepareHash(msg.sender, stcAmountToStake, pack, expiry),
            true
        );
        emit Staked(pack, msg.sender, stcAmountToStake);
    }

    function claimRewardAmount(
        Pack pack,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public ensure(expiry) isDisabled {
        require(pack <= Pack(2), "StakeIt: Invalid pack!");
        require(
            validateClaimHash(pack, msg.sender, expiry, v, r, s),
            "Invalid sig4 claim!"
        );
        userDetails storage userdetails = UserDetails[msg.sender];
        require(
            userdetails.packages[pack].isActive,
            "StakeIt: User not found!"
        );
        require(
            userdetails.packages[pack].stakedAmount > 0,
            "StakeIt: User not staked yet!"
        );
        userdetails.packages[pack].lastRewardClaimedTime = block.timestamp;
        uint256 rewardAmount = _pendingReward(pack, msg.sender);
        rewardAmount += userdetails.packages[pack].unClaimedAmt;
        userdetails.packages[pack].unClaimedAmt = 0;
        userdetails.packages[pack].totalRewardClaimed += rewardAmount;
        userdetails.packages[pack].rewardDept = (rewardPerShare *
            userdetails.packages[pack].stakedAmount);
        require(rewardAmount > 0, "StakeIt: No reward to claim!");
        require(STC_Addr.transfer(msg.sender, rewardAmount), "Tx failed!");
        setHashCompleted(prepareClaimHash(pack, msg.sender, expiry), true);
        emit ClaimedRewardAmount(pack, msg.sender, rewardAmount);
    }

    function pendingReward(Pack pack, address userAddress)
        public
        view
        returns (uint256)
    {
        return (_pendingReward(pack, userAddress) +
            UserDetails[userAddress].packages[pack].unClaimedAmt);
    }

    function _pendingReward(Pack pack, address userAddress)
        private
        view
        returns (uint256)
    {
        if (UserDetails[userAddress].packages[pack].stakedAmount == 0) {
            return 0;
        }

        return
            ((rewardPerShare *
                UserDetails[userAddress].packages[pack].stakedAmount) -
                UserDetails[userAddress].packages[pack].rewardDept) / 1e18;
    }

    function addAffiliateRewardAmountToTheReffs(
        userDetails storage userRefferralDetails,
        Packages memory package
    ) private {
        address[] memory reffererAddresses = new address[](13);
        reffererAddresses[0] = address(0);
        uint256 startingLevel = 1;
        reffererAddresses[1] = userRefferralDetails.reffererAddr;
        for (uint8 i = 1; i <= userRefferralDetails.uplineLength; i++) {
            userDetails storage userRefferralDetailsForAddingR = UserDetails[
                reffererAddresses[i]
            ];
            if (startingLevel == 1) {
                uint256 rewardAmount = calculateAffiliateRewardAmount(
                    package.busdPrice,
                    i
                );

                if (isPackNotExpired(reffererAddresses[i]))
                    userRefferralDetailsForAddingR.affiliateRewardForLevel[
                        startingLevel
                    ] += rewardAmount;

                if (i + 1 <= 12) {
                    reffererAddresses[i + 1] = userRefferralDetailsForAddingR
                        .reffererAddr;
                } else {
                    break;
                }
                startingLevel <= 12 ? startingLevel++ : startingLevel;
            } else {
                uint256 rewardAmount = calculateAffiliateRewardAmount(
                    package.busdPrice,
                    i
                );

                if (isPackNotExpired(reffererAddresses[i]))
                    userRefferralDetailsForAddingR.affiliateRewardForLevel[
                        startingLevel
                    ] += rewardAmount;

                if (i + 1 <= 12) {
                    reffererAddresses[i + 1] = userRefferralDetailsForAddingR
                        .reffererAddr;
                } else {
                    break;
                }
                startingLevel <= 12 ? startingLevel++ : startingLevel;
            }
        }
    }

    function claimAffiliateReward(uint256 level) public isDisabled {
        require(level != 0 && level <= 12, "StakeIt: Invalid level!");
        userDetails storage userdetails = UserDetails[msg.sender];
        uint256 afReward = userdetails.affiliateRewardForLevel[level];
        require(afReward > 0, "StakeIt: No rewards in this level!");
        require(
            level != 0 && level <= userdetails.level,
            "StakeIt: User can't claim coz not qualified for this level!"
        );
        require(userdetails.level >= level, "StakeIt: User is not eligible!");
        userdetails.affiliateRewardForLevel[level] = 0;
        require(BUSD.transfer(msg.sender, afReward), "Tx failed!");
        emit ClaimedAffiliate(msg.sender, afReward, level);
    }

    function claimCapital(Pack pack) public {
        userDetails storage userdetails = UserDetails[msg.sender];
        Packages storage package = packages[pack];
        require(
            block.timestamp >
                userdetails.packages[pack].packageBoughtTime + package.lifeSpan,
            "Pack not yet expired!"
        );
        require(
            pendingReward(pack, msg.sender) == 0,
            "StakeIt: Claim the pending rewards before capital!"
        );
        require(userdetails.packages[pack].isActive, "User not found");
        uint256 stkAmnt = userdetails.packages[pack].stakedAmount;
        userdetails.packages[pack].stakedAmount = 0;
        userdetails.packages[pack].isActive = false;
        userdetails.packages[pack].packageBoughtTime = 0;
        require(STC_Addr.transfer(msg.sender, stkAmnt), "Tx failed!");
        package.poolSTCamount -= stkAmnt;
        emit ClaimedCapital(msg.sender, pack, stkAmnt);
    }

    function swapBusdToStc(
        uint256 busdAmount,
        uint256 busdPrice,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        require(busdAmount > 0 && busdPrice > 0, "0 busd");
        require(
            validateSwapHash(
                msg.sender,
                busdAmount,
                busdPrice,
                expiry,
                v,
                r,
                s
            ),
            "Invalid sig"
        );
        require(
            BUSD.transferFrom(msg.sender, address(this), busdAmount),
            "Tx_failed"
        );
        uint256 stcAmount = (busdAmount * busdPrice) / 1e18;
        require(STC_Addr.transfer(msg.sender, stcAmount), "Tx_2 failed");
        emit SwapBusdToStc(msg.sender, busdAmount, busdPrice);
    }

    function setRewardClaiming(bool isOpen) public OnlyOwner { //Eg := True = enable, False = Disable
        rewardClaiming = isOpen;
    }

    function setPackageStatus(Pack pack, bool status) public OnlyOwner { //Eg := True = enable, False = Disable
        packageStatus[pack] = status;
    }

    function updateRewardPerShare() public onlyOperator {
        require(
            lastRewardPerShareUpdate + updateRewardPershareLimit <
                block.timestamp,
            "StakeIt: Only once a day"
        );
        rewardPerShare += (maxMintStcPerDay * 1e18) / totalStakedAmount;
        lastRewardPerShareUpdate = block.timestamp;
    }

    function updateReward(uint256 level, uint256 rewardPercent)
        public
        OnlyOwner
    {
        require(level != 0 && level <= 12, "Invalid level!");
        rewards[level] = rewardPercent;
        emit RewardUpdated(level, rewardPercent);
    }

    function updateLevelReferals(uint256 level, uint256 refCount)
        public
        OnlyOwner
    {
        require(level != 0 && level <= 12, "Invalid level");
        levels[level] = refCount;
        emit LevelRefCountUpdated(level, refCount);
    }

    function updateToken(address tokenAddress, uint256 flag) public OnlyOwner {
        require(tokenAddress != address(0) && flag != 0, "0");
        if (flag == 1) {
            BUSD = IBEP20(tokenAddress);
        } else if (flag == 2) {
            STC_Addr = IBEP20(tokenAddress);
        } else {
            revert("Invalid flag");
        }
    }

    function updatePackage(
        Pack pack,
        uint256 span,
        uint256 price,
        uint256 capacity
    ) public OnlyOwner {
        require(span != 0 && price != 0 && capacity != 0, "0 pack");
        require(pack <= Pack.GROWTH, "Invalid pack");
        packages[pack] = Packages({
            lifeSpan: span,
            busdPrice: price,
            busdCapacity: capacity,
            poolSTCamount: 0
        });
        emit updatedPackage(pack, span, price, capacity);
    }

    function updateMaxMintStcPerDay(uint256 maxMintStcPerDay_)
        public
        OnlyOwner
    {
        require(maxMintStcPerDay_ != 0, "Invalid maxMintStcPerDay_");
        maxMintStcPerDay = maxMintStcPerDay_;
    }

    function updateSigner(address signer) public OnlyOwner {
        require(signer != address(0), "Signer: wut?");
        signerAddress = signer;
    }

    function updateOperator(address opAddr) public OnlyOwner {
        require(opAddr != address(0), "Operator: How?");
        operatorAddress = opAddr;
    }

    function calculateAffiliateRewardAmount(
        uint256 busdPriceForPackage,
        uint256 level
    ) public view returns (uint256 rewardAmount) {
        rewardAmount = ((busdPriceForPackage * rewards[level]) / diviser);
    }

    function validateUserPack(address user) public view returns (bool r) {
        for (uint8 i = 0; i <= 2; i++) {
            if (
                UserDetails[user].packages[Pack(i)].packageBoughtTime +
                    packages[Pack(i)].lifeSpan >
                block.timestamp ||
                UserDetails[user].packages[Pack(i)].stakedAmount != 0
            ) {
                return true;
            }
        }
        return false;
    }

    function viewRefAddedLevel(
        address userAddress,
        address refAddr,
        uint256 level
    ) public view returns (uint256) {
        require(level <= 12, "Invalid level");
        userDetails storage userdetails = UserDetails[userAddress];
        return userdetails.reffererAddedLevel[refAddr];
    }

    function viewUserLevelDetails(address userAddress, uint256 level)
        public
        view
        returns (
            uint256 affiliateRewardForTheLevel,
            address[] memory levelRefferedUsers
        )
    {
        require(level <= 12, "Invalid level");
        userDetails storage userdetails = UserDetails[userAddress];
        affiliateRewardForTheLevel = userdetails.affiliateRewardForLevel[level];
        levelRefferedUsers = userdetails.levelRefferredUsers[level];
    }

    function viewUserDetails(Pack pack, address userAddress)
        public
        view
        returns (
            address reffererAddress,
            uint256 uplineLength,
            uint256 level,
            address[] memory directRefs,
            uint256 stakedAMount,
            uint256 rewardDept,
            uint256 unClaimedAmt,
            uint256 totalRewardsClaimed,
            uint256 packageBoughtTime,
            uint256 stakedTime,
            bool isActive
        )
    {
        userDetails storage userdetails = UserDetails[userAddress];
        reffererAddress = userdetails.reffererAddr;
        uplineLength = userdetails.uplineLength;
        level = userdetails.level;
        directRefs = userdetails.directRefferals;
        stakedAMount = userdetails.packages[pack].stakedAmount;
        rewardDept = userdetails.packages[pack].rewardDept;
        unClaimedAmt = userdetails.packages[pack].unClaimedAmt;
        totalRewardsClaimed = userdetails.packages[pack].totalRewardClaimed;
        packageBoughtTime = userdetails.packages[pack].packageBoughtTime;
        stakedTime = userdetails.packages[pack].stakedTime;
        isActive = userdetails.packages[pack].isActive;
    }

    function viewUserAffiliateRewardForLevels(address userAddress)
        public
        view
        returns (uint256[12] memory level)
    {
        for (uint256 i = 1; i <= 12; i++) {
            level[i - 1] = UserDetails[userAddress].affiliateRewardForLevel[i];
        }
    }

    function viewUserActivePack(address userAddress, Pack pack)
        public
        view
        returns (uint8)
    {
        if (UserDetails[userAddress].packages[pack].isActive) {
            return uint8(pack);
        } else {
            for (uint8 i = 0; i <= 2; i++) {
                if (UserDetails[userAddress].packages[Pack(i)].isActive) {
                    return i;
                }
            }
        }
        return 3;
    }

    function checkRefBoughtAnyPack(address userAddress)
        public
        view
        returns (bool)
    {
        for (uint256 i = 0; i <= 2; i++) {
            if (UserDetails[userAddress].packages[Pack(i)].isActive) {
                return true;
            }
        }
        return false;
    }

    function viewUserActivePacks(address userAddress) public view returns(uint8[3] memory packs, bool[3] memory isActive) {
        for (uint8 i = 0; i <= 2; i++) {
            if (UserDetails[userAddress].packages[Pack(i)].isActive) {
                packs[i] = i;
                isActive[i] = true;
            } else {
                packs[i] = i;
                isActive[i] = false;
            }
        }
    }

    function isPackNotExpired(address userAddress) public view returns (bool) {
        for (uint256 i = 0; i <= 2; i++) {
            if (UserDetails[userAddress].packages[Pack(i)].isActive) {
                if (
                    (UserDetails[userAddress].packages[Pack(i)].packageBoughtTime + packages[Pack(i)].lifeSpan) >
                    block.timestamp
                ) {
                    return true;
                }
            }
        }
        return false;
    }

    function validateHash(
        address to,
        uint256 stcAmountToStake,
        Pack pack,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public view returns (bool result) {
        bytes32 hash = prepareHash(to, stcAmountToStake, pack, expiry);
        require(!hashStatus[hash], "Hash already exist!");
        bytes32 fullMessage = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
        );
        address signatoryAddress = ecrecover(fullMessage, v, r, s);
        result = signatoryAddress == signerAddress;
    }

    function prepareHash(
        address to,
        uint256 stcAmountToStake,
        Pack pack,
        uint256 blockExpiry
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(to, stcAmountToStake, pack, blockExpiry)
            );
    }

    function validateBuyLevelHash(
        address refferAddr,
        address referrerdAddr,
        Pack pack,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view returns (bool result) {
        bytes32 hash = prepareBuyLevelHash(
            refferAddr,
            referrerdAddr,
            pack,
            expiry
        );
        require(!hashStatus[hash], "Hash already exist!");
        bytes32 fullMessage = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
        );
        address referrerAddr = ecrecover(fullMessage, v, r, s);
        result = referrerAddr == referrerdAddr;
    }

    function validateClaimHash(
        Pack pack,
        address to,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view returns (bool result) {
        bytes32 hash = prepareClaimHash(pack, to, expiry);
        require(!hashStatus[hash], "Hash already exist!");
        bytes32 fullMessage = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
        );
        address signatoryAddress = ecrecover(fullMessage, v, r, s);
        result = signatoryAddress == signerAddress;
    }

    function prepareBuyLevelHash(
        address refferrer,
        address referringAddr,
        Pack pack,
        uint256 expiry
    ) public pure returns (bytes32) {
        return
            keccak256(abi.encodePacked(refferrer, referringAddr, pack, expiry));
    }

    function prepareClaimHash(
        Pack pack,
        address to,
        uint256 blockExpiry
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(pack, to, blockExpiry));
    }

    function validateSwapHash(
        address to,
        uint256 busdAmount,
        uint256 busdPrice,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view returns (bool result) {
        bytes32 hash = prepareSwapHash(to, busdAmount, busdPrice, expiry);
        require(!hashStatus[hash], "Hash already exist!");
        bytes32 fullMessage = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
        );
        address signatoryAddress = ecrecover(fullMessage, v, r, s);
        result = signatoryAddress == signerAddress;
    }

    function prepareSwapHash(
        address to,
        uint256 busdAmount,
        uint256 busdPrice,
        uint256 blockExpiry
    ) public pure returns (bytes32) {
        return
            keccak256(abi.encodePacked(to, busdAmount, busdPrice, blockExpiry));
    }

    function setHashCompleted(bytes32 hash, bool status) private {
        hashStatus[hash] = status;
    }

    function initPackages() private OnlyOwner {
        uint256 span = 60 days;
        uint256 price = 100e18;
        uint256 capacity = 200e18;
        for (uint8 i = 0; i < 3; i++) {
            packages[Pack(i)] = Packages({
                lifeSpan: span,
                busdPrice: price,
                busdCapacity: capacity,
                poolSTCamount: 0
            });
            i == 0 ? span += 305 days : 0;
            i == 0 || i > 0
                ? (i == 1 ? (price = price * 5) : (price = price * 5))
                : price;
            i == 0 || i > 0
                ? (i == 1 ? (capacity = 5000e18) : (capacity = 1000e18))
                : capacity;
        }
    }

    function initAdminActiveInAllPacks() private OnlyOwner {
        userDetails storage userdetails = UserDetails[msg.sender];
        userdetails.uplineLength = 1;
        userdetails.level = 1;
        userdetails.reffererAddr = msg.sender;
        for (uint256 i = 0; i <= 2; i++) {
            if (i <= 2) {
                userdetails.packages[Pack(i)].isActive = true;
            }
        }
    }

    function initLevelRewards() private {
        // downline
        rewards[1] = 20e18;
        rewards[2] = 10e18;
        rewards[3] = 5e18;
        rewards[4] = 4e18;
        rewards[5] = 4e18;
        rewards[6] = 4e18;
        rewards[7] = 4e18;
        rewards[8] = 4e18;
        rewards[9] = 2.5e18;
        rewards[10] = 2.5e18;
        rewards[11] = 2.5e18;
        rewards[12] = 2.5e18;
    }

    function initLevelsRefferalCount() private {
        levels[1] = 3;
        levels[2] = 5;
        levels[3] = 7;
        levels[4] = 9;
        levels[5] = 11;
        levels[6] = 13;
        levels[7] = 15;
        levels[8] = 17;
        levels[9] = 19;
        levels[10] = 21;
        levels[11] = 23;
        levels[12] = 24;
    }

    function withdraw(
        address tokenAddress,
        address _toUser,
        uint256 amount
    ) public OnlyOwner returns (bool status) {
        require(_toUser != address(0), "Invalid Address");
        if (tokenAddress == address(0)) {
            require(address(this).balance >= amount, "Insufficient balance");
            require(payable(_toUser).send(amount), "Transaction failed");
            return true;
        } else {
            require(IBEP20(tokenAddress).balanceOf(address(this)) >= amount);
            IBEP20(tokenAddress).transfer(_toUser, amount);
            return true;
        }
    }
}