/**
 *Submitted for verification at BscScan.com on 2022-12-28
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


interface IBEP20{
    function name() external view returns(string memory);

    function symbol() external view returns(string memory);

    function totalSupply() external view returns (uint );

    function decimals() external view returns(uint);

    function balanceOf(address account) external view returns(uint);

    function approve(address sender , uint value)external returns(bool);

    function allowance(address sender, address spender) external view returns (uint256);

    function transfer(address recepient , uint value) external returns(bool);

    function transferFrom(address sender,address recepient, uint value) external returns(bool);

    event Transfer(address indexed from , address indexed to , uint value);

    event Approval(address indexed sender , address indexed  spender , uint value);
}


contract Context{
    constructor () {}
   function _msgsender() internal view returns (address) {
    return msg.sender;
  }
}

contract Ownable is Context{
    address internal  _Owner;

    event transferOwnerShip(address indexed _previousOwner , address indexed _newOwner);

    constructor(){
        address msgsender = _msgsender();
        _Owner = msgsender;
        emit transferOwnerShip(address(0),msgsender);
    }

    function checkOwner() public view returns(address){
        return _Owner;
    }

    modifier OnlyOwner(){
       require(_Owner == _msgsender(),"Only owner can change the Ownership");
       _; 
    }
   
    function transferOwnership(address _newOwner) public OnlyOwner {
      _transferOwnership(_newOwner);
    }

    function _transferOwnership(address _newOwner) internal {
      require(_newOwner != address(0),"Owner should not be 0 address");
      emit transferOwnerShip(_Owner,_newOwner);
      _Owner = _newOwner;
    }
}

contract Stake_It_Platform is Ownable {
    address public signerAddress;

    IBEP20 public STC_Addr;
    IBEP20 public BUSD;

    uint public rewardClaimingTime = 1 days; 
    uint public rewardUpdatePerHour = 1 hours; 
    uint diviser = 100e18;
    uint public claimTimes = 24; 
    uint public affiliateRewardPercentage = 2e18;
    uint public maxRefferelCountPerUser = 24;
    uint public maxMintStcPerDay = 41e18;
    uint public adminAffiliateRewardPercent = 65e18;
    uint public rewardRefresh = 1 days;
    uint currentTimeStamp;

    bool public rewardClaiming;

    mapping (Pack => Packages) public packages;
    mapping (address => userDetails) public UserDetails;
    mapping (uint => uint) public rewards; //EG := LEVEL => REWARD
    mapping (uint => uint) public levels;
    mapping (bytes32 => bool) public hashStatus;
    mapping (uint => uint) public stakedAmountPerDay;

    enum Pack{
        TRIAL,
        STARTER,
        GROWTH
    }

    struct Packages {
        uint lifeSpan;
        uint busdPrice;
        uint busdCapacity;
        uint poolSTCamount;
        uint poolStcStakedPerDay;
    }

    struct userDetails{
        address reffererAddr;
        uint uplineLength;
        uint level;
        address[] directRefferals; 
        uint[] totalDirectRefferels;
        mapping (uint => uint) affiliateRewardForLevel;
        mapping (uint => bool) isLevelReachedForClaimingAffiliateReward;
        mapping (uint => address[]) levelRefferredUsers;
        mapping (address => uint) reffererAddedLevel;      
        mapping (Pack => UserPack) packages;
    }

    struct UserPack {
        uint stakedAmount;
        uint totalRewardClaimed;
        uint packageBoughtTime;
        uint stakedTimestamp;
        uint lastRewardClaimedTime;
        bool isActive;
        mapping (uint => uint) dayTimeStampStakedAmount;
        mapping (address => mapping(uint => uint[])) userStakedTimestamps;
    }

    event packageBought(Pack pack, uint busdAmount);
    event LevelBought(address indexed reffererAddr, address indexed refferingAddr , Pack pack, uint level);
    event ClaimedAffiliate(address indexed userAddress, uint claimedRewardAmount, uint level);
    event Staked(address indexed userAddress, uint indexed dayTimeStamp, uint stcStakedAmount);

    constructor(address signer, address stc_addr, address busd, uint dayTimestamp) {
        assembly{
            sstore(signerAddress.slot, signer)
            sstore(STC_Addr.slot,stc_addr)
            sstore(BUSD.slot,busd)
        }
        initPackages();
        initLevelRewards();
        initLevelsRefferalCount();
        initAdminActiveInAllPacks();
        currentTimeStamp = dayTimestamp;
        stakedAmountPerDay[dayTimestamp] = 0;
    }

    modifier isDisabled() {
        require(!rewardClaiming, "Reward claiming is disabled!");
        _;
    }

    modifier ensure(uint expiry) {
        require(expiry > block.timestamp, "StakeIt: Expired!");
        _;
    }

    function buyPackage(Pack pack) public {
        require(pack <= Pack(2), "StakeIt: Invalid pack!");
        userDetails storage userdetails = UserDetails[msg.sender];
        Packages memory package = packages[pack];

        address reffererAddress = userdetails.reffererAddr;
        require(reffererAddress != address(0), "StakeIt: 0 ref");
        require(!userdetails.packages[pack].isActive, "STakeIt: User already active in this pack");
        require(!validateUserPack(msg.sender), "User already existed, claim capital or pack not expired");
        
        userDetails storage userReffererDetails = UserDetails[reffererAddress];
        require(userReffererDetails.uplineLength != 0, "StakeIt: Invalid upline!");

        addAffiliateRewardAmountToTheReffs(userdetails, package);
        userdetails.packages[pack].packageBoughtTime = userdetails.packages[pack].lastRewardClaimedTime  = block.timestamp;
        if (userdetails.level == 0) userdetails.level = 1;
        if (!userdetails.packages[pack].isActive) userdetails.packages[pack].isActive = true;
        require(BUSD.transferFrom(msg.sender, address(this), package.busdPrice), "StakeIt: Tx failed");
        emit packageBought(pack, package.busdPrice);
    }

    function buyLevel(Pack pack, address reffererAddress, uint expiry, uint8 v, bytes32 r, bytes32 s) public ensure(expiry) {
        require(pack <= Pack(2), "StakeIt: Invalid pack!");
        require(validateBuyLevelHash(reffererAddress, msg.sender, pack, expiry,v,r,s),"Invalid sig");
        Packages memory package = packages[pack];
        reffererAddress = reffererAddress == address(0) ? _Owner : reffererAddress;
        userDetails storage userRefferralDetails = UserDetails[msg.sender];
        userDetails storage userReffererDetails = UserDetails[reffererAddress];
        require(userRefferralDetails.reffererAddr == address(0), "StakeIt: User already reffered!");
        require(!userRefferralDetails.packages[pack].isActive, "StakeIt: User already exist!");
        require(userRefferralDetails.level == 0, "StakeIt: User exist!");
        require(reffererAddress == _Owner || checkRefBoughtAnyPack(reffererAddress), "StakeIt: Refferer not bought any pack yet!");
        Pack reffererPack = viewUserActivePack(reffererAddress, pack);
        require(reffererPack != Pack(uint8(3)), "Invalid reffererPack!");
        
        if (reffererAddress != _Owner) {
            userReffererDetails.directRefferals.push(msg.sender);
            userReffererDetails.reffererAddedLevel[msg.sender] = userReffererDetails.level;
            userReffererDetails.levelRefferredUsers[userRefferralDetails.level].push(msg.sender);

            userRefferralDetails.uplineLength = userReffererDetails.uplineLength + 1;
        } else {
            userReffererDetails.directRefferals.push(msg.sender);
            userReffererDetails.levelRefferredUsers[userRefferralDetails.level].push(msg.sender);
            userRefferralDetails.uplineLength = 1;
        }
        
        userRefferralDetails.level = 1;
        userRefferralDetails.reffererAddr = reffererAddress;
        userRefferralDetails.packages[pack].packageBoughtTime = block.timestamp;
        userRefferralDetails.packages[pack].isActive = true;

        if (reffererAddress != _Owner && userReffererDetails.directRefferals.length == levels[userReffererDetails.level]) {
            userReffererDetails.level++;
            addAffiliateRewardAmountToTheReffs(userRefferralDetails, package);
            require(BUSD.transferFrom(msg.sender, address(this), package.busdPrice), "Tx failed");
        } else {
            addAffiliateRewardAmountToTheReffs(userRefferralDetails, package);
            require(BUSD.transferFrom(msg.sender, address(this), package.busdPrice), "Tx failed");
        }

        setHashCompleted(prepareBuyLevelHash(reffererAddress, msg.sender, pack, expiry), true);
        emit LevelBought(reffererAddress,msg.sender, pack, 1);
    }

    function addAffiliateRewardAmountToTheReffs(userDetails storage userRefferralDetails, Packages memory package) private {
        address[] memory reffererAddresses = new address[](13);
        reffererAddresses[0] = address(0);
        uint startingLevel = 1;
        for (uint8 i = 1; i <= userRefferralDetails.uplineLength; i++) {
            reffererAddresses[i] = userRefferralDetails.reffererAddr;
            userDetails storage userRefferralDetailsForAddingR = UserDetails[reffererAddresses[i]];
            if (startingLevel == 1) {
                uint rewardAmount = calculateAffiliateRewardAmount(package.busdPrice, i);
                if (!userRefferralDetailsForAddingR.isLevelReachedForClaimingAffiliateReward[startingLevel]) userRefferralDetailsForAddingR.isLevelReachedForClaimingAffiliateReward[startingLevel] = true;
                userRefferralDetailsForAddingR.affiliateRewardForLevel[startingLevel] += rewardAmount;
                reffererAddresses[i + 1] = userRefferralDetailsForAddingR.reffererAddr;
                startingLevel <= 12 ? startingLevel++ : startingLevel;
            } else {
                uint rewardAmount = calculateAffiliateRewardAmount(package.busdPrice, i);
                if (userRefferralDetailsForAddingR.directRefferals.length >= levels[startingLevel]) userRefferralDetailsForAddingR.isLevelReachedForClaimingAffiliateReward[startingLevel] = true;
                userRefferralDetailsForAddingR.affiliateRewardForLevel[startingLevel] += rewardAmount;
                reffererAddresses[i + 1] = userRefferralDetailsForAddingR.reffererAddr;
                startingLevel <= 12 ? startingLevel++ : startingLevel;
            }
        }
    }

    function claimAffiliateReward(uint level) public {
        require(level != 0 && level <= 12, "StakeIt: Invalid level!");
        userDetails storage userdetails = UserDetails[msg.sender];
        require(userdetails.affiliateRewardForLevel[level] > 0, "StakeIt: No rewards in this level!");
        require(userdetails.isLevelReachedForClaimingAffiliateReward[level], "StakeIt: User can't claim coz not qualified for this level!");
        require(userdetails.level >= level, "StakeIt: User is not eligible!");
        userdetails.affiliateRewardForLevel[level] = 0;
        require(BUSD.transfer( msg.sender, userdetails.affiliateRewardForLevel[level]), "Tx failed!");
        emit ClaimedAffiliate(msg.sender, userdetails.affiliateRewardForLevel[level], level);
    }

     function stake(Pack pack, uint stcAmountToStake, uint expiry, uint8 v, bytes32 r, bytes32 s) public ensure(expiry) {
        userDetails storage userdetails = UserDetails[msg.sender];
        Packages memory package = packages[pack];
        currentTimeStamp = (((currentTimeStamp + rewardClaimingTime) > block.timestamp) ? currentTimeStamp : (currentTimeStamp + rewardClaimingTime));
        require(userdetails.packages[pack].isActive, "StakeIt: User not found in this pack!");
        require(stcAmountToStake > 0, "StakeIt: 0 STC!");
        require(validateHash(msg.sender, stcAmountToStake, pack, expiry,v,r,s),"Invalid signature");
        userdetails.packages[pack].stakedAmount += stcAmountToStake;
        userdetails.packages[pack].stakedTimestamp = currentTimeStamp;
        require(package.lifeSpan + userdetails.packages[pack].packageBoughtTime > block.timestamp, "StakeIt: pack expired, claim capital and redeem!");
        stakedAmountPerDay[currentTimeStamp] += stcAmountToStake;
        userdetails.packages[pack].dayTimeStampStakedAmount[currentTimeStamp] += stcAmountToStake;
        userdetails.packages[pack].userStakedTimestamps[msg.sender][currentTimeStamp].push(currentTimeStamp);
        require(STC_Addr.transferFrom(msg.sender, address(this), stcAmountToStake), "Tx failed!");
        emit Staked(msg.sender, currentTimeStamp, stcAmountToStake);
    }

    function claimRewardAmount(Pack pack) public {
        require(pack <= Pack(2), "StakeIt: Invalid pack!");
        userDetails storage userdetails = UserDetails[msg.sender];
        require(userdetails.packages[pack].isActive, "StakeIt: User not found in this pack!");
        require(userdetails.packages[pack].dayTimeStampStakedAmount[userdetails.packages[pack].stakedTimestamp] > 0, "StakeIt: User does'nt stake or already claimed!");
        require(stakedAmountPerDay[userdetails.packages[pack].stakedTimestamp] > 0, "StakeIt: No staked amount in this day!");
        uint _lrClaimedTime = ((userdetails.packages[pack].lastRewardClaimedTime == 0) ? userdetails.packages[pack].stakedTimestamp : userdetails.packages[pack].lastRewardClaimedTime);
        require(_lrClaimedTime < (userdetails.packages[pack].packageBoughtTime + packages[pack].lifeSpan),"No available claims");
        require(_lrClaimedTime + rewardClaimingTime > block.timestamp, "StakeIt: 1ce 24hrs");
        uint totalPoolStakedAmount = stakedAmountPerDay[userdetails.packages[pack].stakedTimestamp];
        uint userTotalStakedAmountIntheTimeStamp = userdetails.packages[pack].dayTimeStampStakedAmount[userdetails.packages[pack].stakedTimestamp];
        uint rewardAmountToTheUser;
        for (uint i = 0; i <  userdetails.packages[pack].userStakedTimestamps[msg.sender][userdetails.packages[pack].stakedTimestamp].length; i++) {
            rewardAmountToTheUser += calculateRewards(totalPoolStakedAmount, userTotalStakedAmountIntheTimeStamp);
        }
        userdetails.packages[pack].dayTimeStampStakedAmount[userdetails.packages[pack].stakedTimestamp] = 0;
        require(STC_Addr.transfer(msg.sender, rewardAmountToTheUser), "Tx failed!");
    }

    function viewStakedAmountInTheTimeStamp(Pack pack, address userAddress, uint dayTimestamp) public view returns(uint) {
        require(dayTimestamp > 0, "StakeIt: Invalid timestamp!");
        userDetails storage userdetails = UserDetails[userAddress];
        require(userdetails.packages[pack].isActive, "StakeIt: User not found in this pack!");
        require(userdetails.packages[pack].dayTimeStampStakedAmount[dayTimestamp] > 0, "StakeIt: User does'nt stake or already claimed!");
        return userdetails.packages[pack].dayTimeStampStakedAmount[dayTimestamp];
    }

    function calculateRewards(uint poolStakedAmount, uint userStakedAmountInThatTimsetamp) public view returns(uint rewardForUser) {
        uint rewardInTheTotalPoolStaked = ( maxMintStcPerDay / poolStakedAmount );
        rewardForUser = rewardInTheTotalPoolStaked * userStakedAmountInThatTimsetamp;
    }
 
    function viewTotalPoolStakedAmount(uint dayTimestamp) public view returns(uint) {
        return stakedAmountPerDay[dayTimestamp];
    }

    function updateToken(address tokenAddress, uint flag) public OnlyOwner {
        require(tokenAddress != address(0) && flag != 0, "0");
        if (flag == 1) {
            BUSD = IBEP20(tokenAddress);
        } else if(flag == 2) {
            STC_Addr = IBEP20(tokenAddress);
        }else {
            revert("Invalid flag");
        }
    }

    function calculateAffiliateRewardAmount(uint busdPriceForPackage, uint level) public view returns(uint rewardAmount) {
        rewardAmount = ((busdPriceForPackage * rewards[level]) / diviser);
    }

    function validateUserPack(address user) public view returns (bool r) {
        for(uint8 i = 0; i <= 2; i++) {
            if(UserDetails[user].packages[Pack(i)].packageBoughtTime + packages[Pack(i)].lifeSpan > block.timestamp || UserDetails[user].packages[Pack(i)].stakedAmount != 0) {
                return true;
            }
        }
        return false;
    }

    function viewUserAffiliateRewardForLevels(address userAddress) public view returns(uint l1, uint l2, uint l3, uint l4, uint l5, uint l6, uint l7, uint l8, uint l9, uint l10, uint l11, uint l12) {
        l1 = UserDetails[userAddress].affiliateRewardForLevel[1];
        l2 = UserDetails[userAddress].affiliateRewardForLevel[2];
        l3 = UserDetails[userAddress].affiliateRewardForLevel[3];
        l4 = UserDetails[userAddress].affiliateRewardForLevel[4];
        l5 = UserDetails[userAddress].affiliateRewardForLevel[5];
        l6 = UserDetails[userAddress].affiliateRewardForLevel[6];
        l7 = UserDetails[userAddress].affiliateRewardForLevel[7];
        l8 = UserDetails[userAddress].affiliateRewardForLevel[8];
        l9 = UserDetails[userAddress].affiliateRewardForLevel[9];
        l10 = UserDetails[userAddress].affiliateRewardForLevel[10];
        l11 = UserDetails[userAddress].affiliateRewardForLevel[11];
        l12 = UserDetails[userAddress].affiliateRewardForLevel[12];
    } 

    function viewUserActivePack(address userAddress, Pack pack) public view returns(Pack) {
        if (UserDetails[userAddress].packages[pack].isActive) {
            return pack;
        } else {
            for (uint8 i = 0; i <= 2; i++) {
                if (UserDetails[userAddress].packages[Pack(i)].isActive) {
                    return Pack(i);
                }
            }
        }
        return Pack(uint8(3));
    }

    function checkRefBoughtAnyPack(address userAddress) public view returns(bool) {
        for (uint i = 0; i <= 2; i++) {
            if (UserDetails[userAddress].packages[Pack(i)].isActive) {
                return true;
            }
        }
        return false;
    }

    function validateHash(address to, uint stcAmountToStake, Pack pack, uint expiry, uint8 v, bytes32 r, bytes32 s)internal view returns(bool result){
        bytes32 hash = prepareHash(to, stcAmountToStake, pack, expiry);
        require(!hashStatus[hash], "Hash already exist!");
        bytes32 fullMessage = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
        );
        address signatoryAddress = ecrecover(fullMessage,v,r,s);
        result = signatoryAddress == signerAddress;
    }

    function prepareHash(address to, uint stcAmountToStake,Pack pack, uint blockExpiry)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(to, stcAmountToStake, pack, blockExpiry));
    }

    function validateBuyLevelHash(address refferAddr, address referrerdAddr ,Pack pack,uint expiry ,uint8 v, bytes32 r, bytes32 s) internal view returns(bool result) {
        bytes32 hash = prepareBuyLevelHash(refferAddr, referrerdAddr, pack, expiry);
        require(!hashStatus[hash], "Hash already exist!");
        bytes32 fullMessage = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
        );
        address referrerAddr = ecrecover(fullMessage,v,r,s);
        result = referrerAddr == referrerdAddr;
    }

    function prepareBuyLevelHash(address refferrer,address referringAddr, Pack pack, uint expiry)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(refferrer,referringAddr,pack, expiry));
    }

    function setHashCompleted(bytes32 hash, bool status) private {
        hashStatus[hash] = status;
    }

    function initPackages() private OnlyOwner {
        uint span = 60 days;
        uint price = 100e18;
        uint capacity = 200e18;
        for (uint8 i = 0; i < 3; i++){
            packages[Pack(i)] = Packages({
                lifeSpan : span,
                busdPrice : price,
                busdCapacity : capacity,
                poolSTCamount : 0,
                poolStcStakedPerDay : 0
            });
            i == 0 ? span += 305 days : 0;
            i == 0 || i > 0 ? (i == 1 ? (price = price * 5) : (price = price * 5)) : price;
            i == 0 || i > 0 ?  (i == 1 ? (capacity = 5000e18) : (capacity = 1000e18)) : capacity;
        }
    }

    function initAdminActiveInAllPacks() private OnlyOwner {
        for (uint i = 0; i <= 12; i++) {
            userDetails storage userdetails = UserDetails[msg.sender];
            if (i <= 2) {
                userdetails.packages[Pack(i)].isActive = true;
            }
            userdetails.uplineLength = 1;
            userdetails.level = 1;
            userdetails.isLevelReachedForClaimingAffiliateReward[i] = true;
            userdetails.reffererAddr= msg.sender;
        }
    }

    function initLevelRewards() private { // downline
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

    function withdraw(address tokenAddress,address _toUser,uint amount)public OnlyOwner returns(bool status){
        require(_toUser != address(0), "Invalid Address");
        if (tokenAddress == address(0)) {
            require(address(this).balance >= amount, "Insufficient balance");
            require(payable(_toUser).send(amount), "Transaction failed");
            return true;
        }
        else {
            require(IBEP20(tokenAddress).balanceOf(address(this)) >= amount);
            IBEP20(tokenAddress).transfer(_toUser,amount);
            return true;
        }
    }
}