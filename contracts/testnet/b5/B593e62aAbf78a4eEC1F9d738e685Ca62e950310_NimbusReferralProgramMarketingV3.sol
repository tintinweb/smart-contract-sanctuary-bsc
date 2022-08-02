// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "./NimbusReferralProgramMarketingStorage.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract NimbusReferralProgramMarketingV3 is Initializable, NimbusReferralProgramMarketingStorage {
    address public target;

    function initialize(address _paymentToken, address _rpUsers, address _smartStaker) public initializer {
        __Ownable_init();
        require(AddressUpgradeable.isContract(_paymentToken), "_paymentToken is not a contract");
        require(AddressUpgradeable.isContract(_rpUsers), "_rpUsers is not a contract");
        require(AddressUpgradeable.isContract(_smartStaker), "_smartStaker is not a contract");

        paymentToken = IERC20Upgradeable(_paymentToken);
        rpUsers = INimbusReferralProgramUsers(_rpUsers);
        nftSmartStaker = IStakingMain(_smartStaker);
        airdropProgramCap = 75_000_000e18;
        levelLockPeriod = 1 days;
    }

    modifier onlyAllowedContract() {
        require(isAllowedContract[msg.sender], "Provided address is not an allowed contract");
        _;
    }

    modifier onlyRegistrators() {
        require(registrators[msg.sender], "Provided address is not a registrator");
        _;
    }

    modifier onlyAllowedUpdaters() {
        require(allowedUpdaters[msg.sender], "Provided address is not a allowed updater");
        _;
    }

    modifier onlyAllowedVerifiers() {
        require(allowedVerifiers[msg.sender], "Provided address is not a allowed verifier");
        _;
    }

    function register(uint sponsorId) external returns (uint userId) {
        return _register(msg.sender, sponsorId);
    }

    function registerUser(address user, uint sponsorId) external onlyRegistrators returns (uint userId) {
        return _register(user, sponsorId);
    }

    function registerBySponsorAddress(address sponsor) external returns (uint userId) {
        uint sponsorId = rpUsers.userIdByAddress(sponsor);
        return _register(msg.sender, sponsorId);
    }

    function registerUserBySponsorAddress(address user, address sponsor) external onlyRegistrators returns (uint userId) {
        uint sponsorId = rpUsers.userIdByAddress(sponsor);
        return _register(user, sponsorId);
    }

    function registerUserBySponsorId(address user, uint sponsorId, uint category) external onlyRegistrators returns (uint userId) {
        return _register(user, sponsorId);
    }

    function updateReferralProfitAmount(address user, uint amount) external onlyAllowedContract {
        require(rpUsers.userIdByAddress(user) != 0, "User is not a part of referral program");

        _updateReferralProfitAmount(user, amount, 0, false);
    }

    function upgradeLevelsLeft(address user, uint potentialLevel) public view returns (uint) {
        uint qualificationLevel = userQualificationLevel[user];
        if (userUpgradeAllowedToLevel[user] >= potentialLevel)
        return potentialLevel;
        else if (userUpgradeAllowedToLevel[user] > qualificationLevel && potentialLevel > userUpgradeAllowedToLevel[user])
        return userUpgradeAllowedToLevel[user];

        uint upgradedLevelsForPeriod;
        if (upgradeNonces[user] > 0)
            {
                for (uint i = upgradeNonces[user]; i > 0; i--) {
                    if (upgradeInfos[user][i].date + levelLockPeriod <= block.timestamp) break;
                    upgradedLevelsForPeriod += upgradeInfos[user][i].nextLevel - upgradeInfos[user][i].prevLevel;
                }
            }
        
        
        uint maxUpdateLevel = qualifications[qualificationLevel].MaxUpdateLevel;

        if (upgradedLevelsForPeriod < maxUpdateLevel) {
            uint toUpgrade = maxUpdateLevel - upgradedLevelsForPeriod;
            if (potentialLevel >= toUpgrade) return qualificationLevel + toUpgrade;
            return potentialLevel;
        }
        return 0;
    }

    function purchaseStakerNFT(address user, uint256 upgradeNonce, uint256 userFixedAirdropAmount) internal returns(uint256 nftTokenId) {
            if(IERC20Upgradeable(paymentToken).allowance(address(this), address(nftSmartStaker)) < userFixedAirdropAmount) {
                IERC20Upgradeable(paymentToken).approve(address(nftSmartStaker), type(uint256).max);
            }
            nftSmartStaker.buySmartStaker(SMART_STAKER_SET, userFixedAirdropAmount);
            nftTokenId = nftSmartStaker.tokenCount();
            nftSmartStaker.safeTransferFrom(address(this), user, nftTokenId);

            upgradeInfos[user][upgradeNonce].nftFixedReward = address(nftSmartStaker);
            upgradeInfos[user][upgradeNonce].fixedRewardTokenId = nftTokenId;
            upgradeInfos[user][upgradeNonce].fixedRewardAmount = userFixedAirdropAmount;
    }

    function getUserLatestUpgrade(address user) external view returns(UpgradeInfo memory userUpgradeInfo) {
        userUpgradeInfo = upgradeInfos[user][upgradeNonces[user]];
    }

    function _processFixedAirdrop(address user, uint256 potentialLevel, uint256 upgradeNonce, uint256 userFixedAirdropAmount) internal {
        if (userFixedAirdropAmount > 0) {
            totalFixedAirdropped += userFixedAirdropAmount;
            uint256 nftTokenId = purchaseStakerNFT(user, upgradeNonce, userFixedAirdropAmount);
            upgradeInfos[user][upgradeNonce].fixedRewardAmount = userFixedAirdropAmount;
            upgradeInfos[user][upgradeNonce].fixedRewardTokenId = nftTokenId;
            upgradeInfos[user][upgradeNonce].nftFixedReward = address(nftSmartStaker);
            emit AirdropFixedReward(user, address(nftSmartStaker), nftTokenId, userFixedAirdropAmount, potentialLevel);
        }
    }

    function _processVariableAirdrop(address user, uint256 potentialLevel, uint256 upgradeNonce, uint256 userVariableAirdropAmount, uint256 systemFee, bool dryRun) internal {
        if (userVariableAirdropAmount > 0) {
            totalVariableAirdropped += userVariableAirdropAmount;
            require(dryRun || userVariableAirdropAmount > systemFee, "No rewards or fee more then rewards");
            TransferHelper.safeTransfer(address(paymentToken), user, userVariableAirdropAmount - systemFee);
            emit AirdropVariableReward(user, userVariableAirdropAmount, potentialLevel);
            upgradeInfos[user][upgradeNonce].variableRewardAmount = userVariableAirdropAmount;
        }
    }

    function _createUpgradeNonce(address user, uint potentialLevel, string memory hash) internal returns(uint256 upgradeNonce) {
        upgradeNonce = ++upgradeNonces[user];
        upgradeInfos[user][upgradeNonce].date = block.timestamp;
        upgradeInfos[user][upgradeNonce].prevLevel = userQualificationLevel[user];
        upgradeInfos[user][upgradeNonce].nextLevel = potentialLevel;
        upgradeInfos[user][upgradeNonce].hash = hash;
    }

    function claimRewards(address user, uint256 userLevel, uint256 structureTurnover, string memory hash, uint256 userVariableAirdropAmount, uint256 systemFee) external onlyAllowedUpdaters {
        bool dryRun = systemFee == 0 || userQualificationLevel[user] == 0;
        bool isPartialReward = userLevel == userQualificationLevel[user];
        (uint userFixedAirdropAmount, uint potentialLevel, bool isMaxLevel) = getUserRewards(user, structureTurnover, dryRun || isPartialReward);

        if(isMaxLevel) {
            // require(userLevel >= userMaxLevelPaymentNonce[user] + qualificationsCount, "Wrong Max Level");
            userMaxLevelPaymentNonce[user] = userLevel - qualificationsCount;
        }

        require(dryRun || isMaxLevel || isPartialReward || potentialLevel > userQualificationLevel[user], "Upgrade not allowed yet");

        uint upgradeNonce = _createUpgradeNonce(user, potentialLevel, hash);

        if (dryRun) {
            potentialLevel = userLevel;
            userFixedAirdropAmount = 0;
            userVariableAirdropAmount = 0;
        }

        if (!isPartialReward) {
            _processFixedAirdrop(user, potentialLevel, upgradeNonce, userFixedAirdropAmount);
        }
        _processVariableAirdrop(user, potentialLevel, upgradeNonce, userVariableAirdropAmount, systemFee, dryRun);

        emit QualificationUpdated(user, userQualificationLevel[user], potentialLevel, systemFee);
        userQualificationLevel[user] = potentialLevel;
        if (isMaxLevel) {
            userMaxLevelPayment[user] += userVariableAirdropAmount;
        }
    }

    function manualClaimRewards(address user, uint256 potentialLevel, string memory hash, uint256 userFixedAirdropAmount, uint256 userVariableAirdropAmount, address nbuToken, uint256 userNbuAirdropAmount) external onlyOwner {
        uint upgradeNonce = _createUpgradeNonce(user, potentialLevel, hash);

        _processFixedAirdrop(user, potentialLevel, upgradeNonce, userFixedAirdropAmount);

        _processVariableAirdrop(user, potentialLevel, upgradeNonce, userVariableAirdropAmount, 0, true);

        if (userNbuAirdropAmount > 0 && nbuToken != address(0)) {
            TransferHelper.safeTransferFrom(nbuToken, msg.sender, user, userNbuAirdropAmount);
            emit AirdropManualReward(user, nbuToken, userNbuAirdropAmount, potentialLevel);
        }

        emit QualificationUpdated(user, userQualificationLevel[user], potentialLevel, 0);
        userQualificationLevel[user] = potentialLevel;
    }

    function totalAirdropped() public view returns(uint) {
        return totalFixedAirdropped + totalVariableAirdropped;
    }

    function totalTurnover() public view returns(uint total) {
        for (uint i = 0; i < regionalManagers.length; i++) {
            total += regionalManagerTurnover[regionalManagers[i]];
        }
    }

    function getRegionalManagers() public view returns(address[] memory) {
        return regionalManagers;
    }

    function getHeadOfLocations() public view returns(address[] memory) {
        return headOfLocations;
    }

    function calculateStructureLine(address[] memory referralAddresses, uint256[] memory referalTurnovers) internal pure returns (uint256 structureTurnover) {
        for (uint i = 0; i < referralAddresses.length; i++) structureTurnover += referalTurnovers[i];
    }

    function getUserPotentialQualificationLevel(address user, uint256 structureTurnover) public view returns (uint) {
        uint qualificationLevel = userQualificationLevel[user];
        return _getUserPotentialQualificationLevel(qualificationLevel, structureTurnover);
    }

    function getUserRewards(address user, uint256 structureTurnover, bool noChecks) public view returns (uint userFixed, uint potentialLevel, bool isMaxLevel) {
        require(rpUsers.userIdByAddress(user) > 0, "User not registered");

        uint qualificationLevel = userQualificationLevel[user];
        isMaxLevel = qualificationLevel >= (qualificationsCount - 1);
        
        if (!isMaxLevel) {
            potentialLevel = _getUserPotentialQualificationLevel(qualificationLevel, structureTurnover);
            require(noChecks || potentialLevel > qualificationLevel, "User level not changed");
        } else {
            potentialLevel = qualificationsCount - 1;
        }
        require(noChecks || upgradeLevelsLeft(user, potentialLevel) >= potentialLevel, "No upgrade levels left");

        if (structureTurnover == 0) return (0, potentialLevel, isMaxLevel);
        
        userFixed = _getFixedRewardToBePaidForQualification(structureTurnover, qualificationLevel, potentialLevel);
    }

    function getUserTokens(address user) external view returns (uint[] memory) {
        return nftSmartStaker.getUserTokens(user); 
    }

    function withdrawReward(uint256 _id) external {
        nftSmartStaker.withdrawReward(_id); // withdraw Smart Staker reward
    }

    function _register(address user, uint sponsorId) private returns (uint userId) {
        require(rpUsers.userIdByAddress(user) == 0, "User already registered");
        address sponsor = rpUsers.userAddressById(sponsorId);
        require(sponsor != address(0), "User sponsor address is equal to 0");

        address sponsorAddress = rpUsers.userAddressById(sponsorId);
        if (isHeadOfLocation[sponsorAddress]) {
            userHeadOfLocations[user] = sponsorAddress;
        } else {
            address head = userHeadOfLocations[sponsor];
            if (head != address(0)){
                userHeadOfLocations[user] = head;
            } else {
                emit UserRegisteredWithoutHeadOfLocation(user, sponsorId);
            }
        }
        
        emit UserRegistered(user, sponsorId);   
        return rpUsers.registerUserBySponsorId(user, sponsorId, MARKETING_CATEGORY);
    }

    function _updateReferralProfitAmount(address user, uint amount, uint line, bool isRegionalAmountUpdated) internal {
        if (line == 0) {
            userPersonalTurnover[user] += amount;
            emit UpdateReferralProfitAmount(user, amount, line);
            if (isHeadOfLocation[user]) {
                headOfLocationTurnover[user] += amount;
                address regionalManager = headOfLocationRegionManagers[user];
                regionalManagerTurnover[regionalManager] += amount;
                isRegionalAmountUpdated = true;
            } else if (isRegionManager[user]) {
                regionalManagerTurnover[user] += amount;
                return;
            } else {
                address userSponsor = rpUsers.userSponsorAddressByAddress(user);
                _updateReferralProfitAmount(userSponsor, amount, 1, isRegionalAmountUpdated);
            }
        } else {
            emit UpdateReferralProfitAmount(user, amount, line);
            if (isHeadOfLocation[user]) {
                headOfLocationTurnover[user] += amount;
                address regionalManager = headOfLocationRegionManagers[user];
                if (!isRegionalAmountUpdated) {
                    regionalManagerTurnover[regionalManager] += amount;
                    isRegionalAmountUpdated = true;
                }
            } else if (isRegionManager[user]) {
                if (!isRegionalAmountUpdated) regionalManagerTurnover[user] += amount;
                return;
            }

            if (line >= REFERRAL_LINES) {
                if (!isRegionalAmountUpdated) _updateReferralHeadOfLocationAndRegionalTurnover(user, amount);
                return;
            }

            address userSponsor = rpUsers.userSponsorAddressByAddress(user);
            if (userSponsor == address(0)) {
                if (!isRegionalAmountUpdated) _updateReferralHeadOfLocationAndRegionalTurnover(user, amount);
                return;
            }

            _updateReferralProfitAmount(userSponsor, amount, ++line, isRegionalAmountUpdated);
        }
    }

    function _updateReferralHeadOfLocationAndRegionalTurnover(address user, uint amount) internal {
        address headOfLocation = userHeadOfLocations[user];
        if (headOfLocation == address(0)) return;
        headOfLocationTurnover[headOfLocation] += amount;
        address regionalManager = headOfLocationRegionManagers[user];
        emit UpdateHeadOfLocationTurnover(headOfLocation, amount);
        if (regionalManager == address(0)) return;
        regionalManagerTurnover[regionalManager] += amount;
        emit UpdateRegionalManagerTurnover(regionalManager, amount);
    }

    function _getUserPotentialQualificationLevel(uint qualificationLevel, uint256 turnover) internal view returns (uint) {
        if (qualificationLevel >= qualificationsCount) return qualificationsCount - 1;
        
        for (uint i = qualificationLevel; i < qualificationsCount; i++) {
            if (qualifications[i+1].TotalTurnover > turnover) {
                return i;
            }
        }
        return qualificationsCount - 1; //user gained max qualification
    }

    function _getFixedRewardToBePaidForQualification(uint structureTurnover, uint qualificationLevel, uint potentialLevel) internal view returns (uint userFixed) { 
        if (structureTurnover == 0) return 0;

        for (uint i = qualificationLevel + 1; i <= potentialLevel; i++) {
            uint fixedRewardAmount = qualifications[i].FixedReward;
            if (fixedRewardAmount > 0) {
                userFixed += fixedRewardAmount;
            }
        }
    }

    function updateRegistrator(address registrator, bool isActive) external onlyOwner {
        require(registrator != address(0), "Registrator address is equal to 0");
        registrators[registrator] = isActive;
    }

    function updateAllowedUpdater(address updater, bool isActive) external onlyOwner {
        require(updater != address(0), "Updater address is equal to 0");
        allowedUpdaters[updater] = isActive;
    }

    function updateAllowedVerifier(address verifier, bool isActive) external onlyOwner {
        require(verifier != address(0), "Verifier address is equal to 0");
        allowedVerifiers[verifier] = isActive;
    }

    function updateAllowedContract(address _contract, bool _isAllowed) external onlyOwner {
        require(AddressUpgradeable.isContract(_contract), "Provided address is not a contract");
        isAllowedContract[_contract] = _isAllowed;
    }

    function updateQualifications(uint[] memory totalTurnoverAmounts, uint[] memory percentages, uint[] memory fixedRewards, uint[] memory maxUpdateLevels) external onlyOwner {
        require(totalTurnoverAmounts.length == percentages.length && totalTurnoverAmounts.length == fixedRewards.length && totalTurnoverAmounts.length == maxUpdateLevels.length, "Arrays length are not equal");
        qualificationsCount = 0;

        for (uint i; i < totalTurnoverAmounts.length; i++) {
            _updateQualification(i, totalTurnoverAmounts[i], percentages[i], fixedRewards[i], maxUpdateLevels[i]);
        }
        qualificationsCount = totalTurnoverAmounts.length;
    }

    function updateAirdropProgramCap(uint newAirdropProgramCap) external onlyOwner {
        require(newAirdropProgramCap > 0, "Airdrop cap must be grater then 0");
        airdropProgramCap = newAirdropProgramCap;
        emit UpdateAirdropProgramCap(newAirdropProgramCap);
    }

    function setUserQualification(address user, uint qualification, bool updateTurnover) external onlyOwner {
        _upgradeUserQualification(user, qualification, updateTurnover);
    }

    function setUserQualifications(address[] memory users, uint[] memory newQualifications, bool updateTurnover) external onlyOwner {
        require(users.length == newQualifications.length, "Arrays length are not equal");
        for (uint i; i < users.length; i++) {
            _upgradeUserQualification(users[i], newQualifications[i], updateTurnover);
        }
    }

    function addHeadOfLocation(address headOfLocation, address regionalManager) external onlyOwner {
        _addHeadOfLocation(headOfLocation, regionalManager);
    }

    function addHeadOfLocations(address[] memory headOfLocation, address[] memory managers) external onlyOwner {
        require(headOfLocation.length == managers.length, "Arrays length are not equal");
        for (uint i; i < headOfLocation.length; i++) {
            _addHeadOfLocation(headOfLocation[i], managers[i]);
        }
    }

    function removeHeadOfLocation(uint index) external onlyOwner {
        require (headOfLocations.length > index, "Incorrect index");
        address headOfLocation = headOfLocations[index];
        headOfLocations[index] = headOfLocations[headOfLocations.length - 1];
        headOfLocations.pop(); 
        isHeadOfLocation[headOfLocation] = false;
        emit RemoveHeadOfLocation(headOfLocation);
    }

    function updateLevelLockPeriod(uint newLevelLockPeriod) external onlyOwner {
        levelLockPeriod = newLevelLockPeriod;
        emit LevelLockPeriodSet(newLevelLockPeriod);
    }

    function addRegionalManager(address regionalManager) external onlyOwner {
        _addRegionalManager(regionalManager);
    }

    function addRegionalManagers(address[] memory managers) external onlyOwner {
        for (uint i; i < managers.length; i++) {
            _addRegionalManager(managers[i]);
        }
    }

    function removeRegionalManager(uint index) external onlyOwner {
        require (regionalManagers.length > index, "Incorrect index");
        address regionalManager = regionalManagers[index];
        regionalManagers[index] = regionalManagers[regionalManagers.length - 1];
        regionalManagers.pop(); 
        isRegionManager[regionalManager] = false;
        emit RemoveRegionalManager(regionalManager);
    }

    function importUserHeadOfLocation(address user, address headOfLocation, bool isSilent) external onlyOwner {
        _importUserHeadOfLocation(user, headOfLocation, isSilent);
    }

    function importUserHeadOfLocations(address[] memory users, address[] memory headOfLocationsLocal, bool isSilent) external onlyOwner {
        require(users.length == headOfLocationsLocal.length, "Array length missmatch");
        for(uint i = 0; i < users.length; i++) {
            _importUserHeadOfLocation(users[i], headOfLocationsLocal[i], isSilent);
        }
    }

    function importBatchUserHeadOfLocations(address[] memory users, address headOfLocationsLocal, bool isSilent) external onlyOwner {
        for(uint i = 0; i < users.length; i++) {
            _importUserHeadOfLocation(users[i], headOfLocationsLocal, isSilent);
        }
    }
    
    function importUserTurnover(address user, uint personalTurnoverSystem, uint personalTurnoverPayment, string memory hash, uint levelHint, bool addToCurrentTurnover, bool updateLevel, bool isSilent) external onlyOwner {
        _importUserTurnover(user, personalTurnoverSystem, personalTurnoverPayment, hash, levelHint, addToCurrentTurnover, updateLevel, isSilent);
    }

    function importUserTurnovers(address[] memory users, uint[] memory personalTurnoversSystem, uint[] memory personalTurnoversPayment, string[] memory hash, uint[] memory levelsHints, bool addToCurrentTurnover, bool updateLevel, bool isSilent) external onlyOwner {
        require(users.length == personalTurnoversSystem.length && users.length == personalTurnoversPayment.length && 
            users.length == levelsHints.length, "Array length missmatch");

        for(uint i = 0; i < users.length; i++) {
            _importUserTurnover(users[i], personalTurnoversSystem[i], personalTurnoversPayment[i], hash[i], levelsHints[i], addToCurrentTurnover, updateLevel, isSilent);
        }
    }

    function importHeadOfLocationTurnover(address headOfLocation, uint turnover, uint levelHint, bool addToCurrentTurnover, bool updateLevel) external onlyOwner {
        _importHeadOfLocationTurnover(headOfLocation, turnover, levelHint, addToCurrentTurnover, updateLevel);
    }

    function importHeadOfLocationTurnovers(address[] memory heads, uint[] memory turnovers, uint[] memory levelsHints, bool addToCurrentTurnover, bool updateLevel) external onlyOwner {
        require(heads.length == turnovers.length, "Array length missmatch");

        for(uint i = 0; i < heads.length; i++) {
            _importHeadOfLocationTurnover(heads[i], turnovers[i], levelsHints[i], addToCurrentTurnover, updateLevel);
        }
    }

    function importRegionalManagerTurnover(address headOfLocation, uint turnover, uint levelHint, bool addToCurrentTurnover, bool updateLevel) external onlyOwner {
        _importRegionalManagerTurnover(headOfLocation, turnover, levelHint, addToCurrentTurnover, updateLevel);
    }

    function importRegionalManagerTurnovers(address[] memory managers, uint[] memory turnovers, uint[] memory levelsHints, bool addToCurrentTurnover, bool updateLevel) external onlyOwner {
        require(managers.length == turnovers.length && managers.length == levelsHints.length, "Array length missmatch");

        for(uint i = 0; i < managers.length; i++) {
            _importRegionalManagerTurnover(managers[i], turnovers[i], levelsHints[i], addToCurrentTurnover, updateLevel);
        }
    }

    function allowLevelUpgradeForUser(address user, uint level) external onlyAllowedVerifiers {
        _allowLevelUpgradeForUser(user, level);
    }

    function _allowLevelUpgradeForUser(address user, uint level) internal {
        require(userQualificationLevel[user] <= level, "Level below current");
        userUpgradeAllowedToLevel[user] = level;
        emit AllowLevelUpgradeForUser(user, userQualificationLevel[user], level);
    }

    function importUserMaxLevelPayment(address user, uint maxLevelPayment, bool addToCurrentPayment) external onlyOwner { 
        _importUserMaxLevelPayment(user, maxLevelPayment, addToCurrentPayment);
    }

    function importUserMaxLevelPayments(address[] memory users, uint[] memory maxLevelPayments, bool addToCurrentPayment) external onlyOwner { 
        require(users.length == maxLevelPayments.length, "Array length missmatch");

        for(uint i = 0; i < users.length; i++) {
            _importUserMaxLevelPayment(users[i], maxLevelPayments[i], addToCurrentPayment);
        }
    }

    


    function _addHeadOfLocation(address headOfLocation, address regionalManager) internal {
        // require(isRegionManager[regionalManager], "Regional manager not exists");
        // require(rpUsers.userIdByAddress(headOfLocation) > 1000000001, "HOL not in referral system or first user");
        headOfLocations.push(headOfLocation);
        isHeadOfLocation[headOfLocation] = true;
        headOfLocationRegionManagers[headOfLocation] = regionalManager;
        emit AddHeadOfLocation(headOfLocation, regionalManager);
    }

    function _addRegionalManager(address regionalManager) internal {
        // require(!isRegionManager[regionalManager], "Regional manager exist");
        // require(rpUsers.userIdByAddress(regionalManager) > 1000000001, "Regional manager not in referral system or first user");
        regionalManagers.push(regionalManager);
        isRegionManager[regionalManager] = true;
        emit AddRegionalManager(regionalManager);
    }

    function _upgradeUserQualification(address user, uint qualification, bool updateTurnover) internal {
        require(qualification < qualificationsCount, "Incorrect qualification index");
        require(userQualificationLevel[user] < qualification, "Can't donwgrade user qualification");
        uint newTurnover;
        if (updateTurnover) newTurnover = qualifications[qualification].TotalTurnover;
        emit UpgradeUserQualification(user, userQualificationLevel[user], qualification, newTurnover);
        userQualificationLevel[user] = qualification;
        userQualificationOrigin[user] = 2;
    }

    function _importUserHeadOfLocation(address user, address headOfLocation, bool isSilent) internal onlyOwner {
        // require(isHeadOfLocation[headOfLocation], "Not HOL");
        userHeadOfLocations[user] = headOfLocation;
        if (!isSilent) emit ImportUserHeadOfLocation(user, headOfLocation);
    }

    function _updateQualification(uint index, uint totalTurnoverAmount, uint percentage, uint fixedReward, uint maxUpdateLevel) internal {
        //Total turnover amount can be zero for the first qualification (zero qualification), so check and require is not needed
        qualifications[index] = Qualification(index, totalTurnoverAmount, percentage, fixedReward, maxUpdateLevel);
        emit UpdateQualification(index, totalTurnoverAmount, percentage, fixedReward, maxUpdateLevel);
    }

    function _importUserTurnover(address user, uint personalTurnoverSystemToken, uint personalTurnoverPaymentToken, string memory hash, uint levelHint, bool addToCurrentTurnover, bool updateLevel, bool isSilent) private {
        // require(rpUsers.userIdByAddress(user) != 0, "User is not registered");

        if (addToCurrentTurnover) {
            uint previousPersonalTurnover = userPersonalTurnover[user];
            uint newPersonalTurnover = previousPersonalTurnover + personalTurnoverPaymentToken;
            if (!isSilent) emit ImportUserTurnoverUpdate(user, newPersonalTurnover, previousPersonalTurnover);
            userPersonalTurnover[user] = newPersonalTurnover;
        } else {
            userPersonalTurnover[user] = personalTurnoverPaymentToken;
            if (!isSilent) emit ImportUserTurnoverSet(user, personalTurnoverSystemToken, personalTurnoverPaymentToken);
        }

        uint upgradeNonce = ++upgradeNonces[user];
        upgradeInfos[user][upgradeNonce].date = block.timestamp;
        upgradeInfos[user][upgradeNonce].prevLevel = userQualificationLevel[user];
        if (updateLevel) {
            uint potentialLevel = levelHint;
            if (potentialLevel > 0) {
                userQualificationLevel[user] = potentialLevel;
                // if (!isSilent) emit QualificationUpdated(user, 0, potentialLevel, 0);
            }
        }
        userQualificationOrigin[user] = 1;
        upgradeInfos[user][upgradeNonce].nextLevel = userQualificationLevel[user];
        upgradeInfos[user][upgradeNonce].hash = hash;
    }

    function _importHeadOfLocationTurnover(address headOfLocation, uint turnover, uint levelHint, bool addToCurrentTurnover, bool updateLevel) private {
        require(isHeadOfLocation[headOfLocation], "User is not HOL");

        uint actualTurnover;
        if (addToCurrentTurnover) {
            uint previousTurnover = headOfLocationTurnover[headOfLocation];

            actualTurnover = previousTurnover + turnover;
            emit ImportHeadOfLocationTurnoverUpdate(headOfLocation, previousTurnover, actualTurnover);
            headOfLocationTurnover[headOfLocation] = actualTurnover;
        } else {
            headOfLocationTurnover[headOfLocation] = turnover;
            emit ImportHeadOfLocationTurnoverSet(headOfLocation, turnover);
            actualTurnover = turnover;
        }

        if (updateLevel) {
            uint potentialLevel = levelHint;
            if (potentialLevel > 0) {
                userQualificationLevel[headOfLocation] = potentialLevel;
                emit QualificationUpdated(headOfLocation, 0, potentialLevel, 0);
            }
        }
        userQualificationOrigin[headOfLocation] = 1;
    }

    function _importRegionalManagerTurnover(address regionalManager, uint turnover, uint levelHint, bool addToCurrentTurnover, bool updateLevel) private {
        require(isRegionManager[regionalManager], "User is not HOL");
        require(levelHint < qualificationsCount, "Incorrect level hint");

        uint actualTurnover;
        if (addToCurrentTurnover) {
            uint previousTurnover = regionalManagerTurnover[regionalManager];

            actualTurnover = previousTurnover + turnover;
            emit ImportRegionalManagerTurnoverUpdate(regionalManager, previousTurnover, actualTurnover);
            regionalManagerTurnover[regionalManager] = actualTurnover;
        } else {
            regionalManagerTurnover[regionalManager] = turnover;
            emit ImportRegionalManagerTurnoverSet(regionalManager, turnover);
            actualTurnover = turnover;
        }

        if (updateLevel) {
            uint potentialLevel = levelHint;
            if (potentialLevel > 0) {
                userQualificationLevel[regionalManager] = potentialLevel;
                emit QualificationUpdated(regionalManager, 0, potentialLevel, 0);
            }
        }
        userQualificationOrigin[regionalManager] = 1;
    }

    function _importUserMaxLevelPayment(address user, uint maxLevelPayment, bool addToCurrentPayment) internal {
        require(userQualificationLevel[user] >= qualificationsCount - 1, "Not max level user");
        if (addToCurrentPayment) {
            userMaxLevelPayment[user] += maxLevelPayment;
        } else {
            userMaxLevelPayment[user] = maxLevelPayment;
        }
        emit ImportUserMaxLevelPayment(user, maxLevelPayment, addToCurrentPayment);
    }

    function updateNFTSmartStakerContract(address nftSmartStakerAddress) external onlyOwner {
        require(AddressUpgradeable.isContract(nftSmartStakerAddress), "NFTSmartStakerContractAddress is not a contract");
        nftSmartStaker = IStakingMain(nftSmartStakerAddress);
        emit UpdateNFTSmartStakerContract(nftSmartStakerAddress);
    }

    //Admin functions
    function rescue(address payable to, uint256 amount) external onlyOwner {
        require(to != address(0), "Can't be zero address");
        require(amount > 0, "Should be greater than 0");
        TransferHelper.safeTransferBNB(to, amount);
        emit Rescue(to, amount);
    }

    function rescue(address to, address token, uint256 amount) external onlyOwner {
        require(to != address(0), "Can't be zero address");
        require(amount > 0, "Should be greater than 0");
        TransferHelper.safeTransfer(token, to, amount);
        emit RescueToken(token, to, amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferBNB(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: BNB_TRANSFER_FAILED');
    }
}

interface INimbusReferralProgramUsers {
    function userSponsor(uint user) external view returns (uint);
    function registerUser(address user, uint category) external returns (uint);
    function registerUserBySponsorAddress(address user, address sponsorAddress, uint category) external returns (uint);
    function registerUserBySponsorId(address user, uint sponsorId, uint category) external returns (uint);
    function userIdByAddress(address user) external view returns (uint);
    function userAddressById(uint id) external view returns (address);
    function userSponsorAddressByAddress(address user) external view returns (address);
    function getUserReferrals(address user) external view returns (uint[] memory);
}

interface INimbusVesting {
    struct VestingInfo {
        uint vestingAmount;
        uint unvestedAmount;
        uint vestingType;
        uint vestingStart;
        uint vestingReleaseStartDate;
        uint vestingEnd;
        uint vestingSecondPeriod;
    }
    function vestingInfos(address user, uint nonce) external view returns (VestingInfo memory);
    function vestingNonces(address user) external view returns (uint);
}

interface IBEP165 {
  function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

abstract contract ERC165 is IBEP165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IBEP165).interfaceId;
    }
}

interface IBEP721 is IBEP165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

interface IStakingMain is IBEP721 {
    function buySmartStaker(uint256 _setNum, uint _amount) external payable;
    function withdrawReward(uint256 _id) external;
    function tokenCount() external view returns(uint);
    function getUserTokens(address user) external view returns (uint[] memory);
}

contract NimbusReferralProgramMarketingStorage is OwnableUpgradeable {  
        struct Qualification {
            uint Number;
            uint TotalTurnover; 
            uint Percentage; 
            uint FixedReward;
            uint MaxUpdateLevel;
        }

        struct UpgradeInfo {
            uint date;
            uint prevLevel;
            uint nextLevel;
            string hash;
            address nftFixedReward;
            uint fixedRewardTokenId;
            uint fixedRewardAmount;
            uint variableRewardAmount;
        }

        mapping (address => uint) public upgradeNonces;
        mapping (address => mapping (uint => UpgradeInfo)) public upgradeInfos;

        IERC20Upgradeable public paymentToken;
        INimbusReferralProgramUsers rpUsers;
        IStakingMain public nftSmartStaker;

        uint constant SMART_STAKER_SET = 0;

        uint public totalFixedAirdropped;
        uint public totalVariableAirdropped;
        uint public airdropProgramCap;

        uint constant PERCENTAGE_PRECISION = 1e5;
        uint constant MARKETING_CATEGORY = 3;
        uint constant REFERRAL_LINES = 1;

        mapping(address => bool) public isRegionManager;
        mapping(address => bool) public isHeadOfLocation;
        mapping(address => address) public userHeadOfLocations;
        mapping(address => address) public headOfLocationRegionManagers;
        address[] public regionalManagers;
        address[] public headOfLocations;

        mapping(address => uint) public headOfLocationTurnover; //contains the whole structure turnover (more than 6 lines), including userStructureTurnover (only 6 lines turnover)
        mapping(address => uint) public regionalManagerTurnover;
        mapping(address => uint) public userPersonalTurnover;
        mapping(address => uint) public userQualificationLevel;
        mapping(address => uint) public userQualificationOrigin; //0 - organic, 1 - imported, 2 - set
        mapping(address => uint) public userMaxLevelPayment;
        mapping(address => uint) public userUpgradeAllowedToLevel;

        mapping(address => uint) public userMaxLevelPaymentNonce;

        uint public qualificationsCount;
        mapping(uint => Qualification) public qualifications;

        mapping(address => bool) public isAllowedContract;
        mapping(address => bool) public registrators;
        mapping(address => bool) public allowedUpdaters;
        mapping(address => bool) public allowedVerifiers;

        uint public levelLockPeriod;

        event Rescue(address indexed to, uint amount);
        event RescueToken(address indexed token, address indexed to, uint amount);

        event AirdropFixedReward(address indexed user, address nftContract, uint nftTokenId, uint fixedAirdropped, uint indexed qualification);
        event AirdropVariableReward(address indexed user, uint variableAirdropped, uint indexed qualification);
        event QualificationUpdated(address indexed user, uint indexed previousQualificationLevel, uint indexed qualificationLevel, uint systemFee);

        event UserRegistered(address user, uint indexed sponsorId);
        event UserRegisteredWithoutHeadOfLocation(address user, uint indexed sponsorId);

        event LevelLockPeriodSet(uint levelLockPeriod);
        event PendingQualificationUpdate(address indexed user, uint indexed previousQualificationLevel, uint indexed qualificationLevel);

        event UpdateReferralProfitAmount(address indexed user, uint amount, uint indexed line);
        event UpdateHeadOfLocationTurnover(address indexed headOfLocation, uint amount);
        event UpdateRegionalManagerTurnover(address indexed regionalManager, uint amount);
        event UpdateAirdropProgramCap(uint indexed newAirdropProgramCap);
        event UpdateQualification(uint indexed index, uint indexed totalTurnoverAmount, uint indexed percentage, uint fixedReward, uint maxUpdateLevel);
        event AddHeadOfLocation(address indexed headOfLocation, address indexed regionalManager);
        event RemoveHeadOfLocation(address indexed headOfLocation);
        event AddRegionalManager(address indexed regionalManager);
        event RemoveRegionalManager(address indexed regionalManager);
        event UpdateRegionalManager(address indexed user, bool indexed isManager);
        event ImportUserTurnoverSet(address indexed user, uint personalTurnoverSystemToken, uint personalTurnoverPaymentToken);
        event ImportUserMaxLevelPayment(address indexed user, uint maxLevelPayment, bool indexed addToCurrentPayment);
        event AllowLevelUpgradeForUser(address indexed user, uint currentLevel, uint allowedLevel);
        event ImportUserTurnoverUpdate(address indexed user, uint newPersonalTurnoverAmount, uint previousPersonalTurnoverAmount);
        event ImportHeadOfLocationTurnoverUpdate(address indexed headOfLocation, uint previousTurnover, uint newTurnover);
        event ImportHeadOfLocationTurnoverSet(address indexed headOfLocation, uint turnover);
        event ImportRegionalManagerTurnoverUpdate(address indexed headOfLocation, uint previousTurnover, uint newTurnover);
        event ImportRegionalManagerTurnoverSet(address indexed headOfLocation, uint turnover);
        event ImportUserHeadOfLocation(address indexed user, address indexed headOfLocation);
        event UpgradeUserQualification(address indexed user, uint indexed previousQualification, uint indexed newQualification, uint newStructureTurnover);

        event UpdateNFTSmartStakerContract(address indexed nftSmartStakerAddress);

        event AirdropManualReward(address indexed user, address token, uint amount, uint indexed qualification);
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
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
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}