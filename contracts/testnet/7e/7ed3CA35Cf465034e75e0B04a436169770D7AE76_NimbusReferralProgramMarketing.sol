/**
 *Submitted for verification at BscScan.com on 2022-03-24
*/

pragma solidity =0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function getOwner() external view returns (address);
    function vest(address user, uint amount) external;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

contract Ownable {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed from, address indexed to);

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), owner);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Ownable: Caller is not the owner");
        _;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function transferOwnership(address transferOwner) external onlyOwner {
        require(transferOwner != newOwner);
        newOwner = transferOwner;
    }

    function acceptOwnership() virtual external {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

contract NimbusReferralProgramMarketingStorage is Ownable {  
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
        }

        mapping (address => uint) public upgradeNonces;
        mapping (address => mapping (uint => UpgradeInfo)) public upgradeInfos;
        mapping (address => mapping (uint => mapping(address => uint))) public prevTurnovers;

        IBEP20 public NBU;
        INimbusReferralProgramUsers rpUsers;

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

        uint public qualificationsCount;
        mapping(uint => Qualification) public qualifications;

        mapping(address => bool) public isAllowedContract;
        mapping(address => bool) public registrators;
        mapping(address => bool) public allowedUpdaters;
        mapping(address => bool) public allowedVerifiers;

        uint public levelLockPeriod;

        event Rescue(address indexed to, uint amount);
        event RescueToken(address indexed token, address indexed to, uint amount);

        event AirdropFixedReward(address indexed user, uint fixedAirdropped, uint indexed qualification);
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
        event ImportUserTurnoverSet(address indexed user, uint personalTurnover);
        event ImportUserMaxLevelPayment(address indexed user, uint maxLevelPayment, bool indexed addToCurrentPayment);
        event AllowLevelUpgradeForUser(address indexed user, uint currentLevel, uint allowedLevel);
        event ImportUserTurnoverUpdate(address indexed user, uint newPersonalTurnoverAmount, uint previousPersonalTurnoverAmount);
        event ImportHeadOfLocationTurnoverUpdate(address indexed headOfLocation, uint previousTurnover, uint newTurnover);
        event ImportHeadOfLocationTurnoverSet(address indexed headOfLocation, uint turnover);
        event ImportRegionalManagerTurnoverUpdate(address indexed headOfLocation, uint previousTurnover, uint newTurnover);
        event ImportRegionalManagerTurnoverSet(address indexed headOfLocation, uint turnover);
        event ImportUserHeadOfLocation(address indexed user, address indexed headOfLocation);
        event UpgradeUserQualification(address indexed user, uint indexed previousQualification, uint indexed newQualification, uint newStructureTurnover);
    }

contract NimbusReferralProgramMarketing is NimbusReferralProgramMarketingStorage {
    address public target;

    function initialize(address _nbu, address _rpUsers) external onlyOwner {
        require(Address.isContract(_nbu), "_nbu is not a contract");
        require(Address.isContract(_rpUsers), "_rpUsers is not a contract");

        NBU = IBEP20(_nbu);
        rpUsers = INimbusReferralProgramUsers(_rpUsers);
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

    function claimRewards(address user, uint256 personalTurnover, address[] memory referralAddresses, uint256[] memory referalTurnovers, uint256 systemFee) external onlyAllowedUpdaters {
        (uint userFixedAirdropAmount, uint userVariableAirdropAmount, uint potentialLevel, bool isMaxLevel) = getUserRewards(user, personalTurnover, referralAddresses, referalTurnovers);

        require(potentialLevel > userQualificationLevel[user], "Upgrade not allowed yet");

        uint upgradeNonce = ++upgradeNonces[user];
        upgradeInfos[user][upgradeNonce].date = block.timestamp;
        upgradeInfos[user][upgradeNonce].prevLevel = userQualificationLevel[user];
        upgradeInfos[user][upgradeNonce].nextLevel = potentialLevel;
        for (uint i = 0; i < referralAddresses.length; i++) {
            require(rpUsers.userSponsorAddressByAddress(referralAddresses[i]) == user, "Wrong referal address");
            prevTurnovers[user][upgradeNonce][referralAddresses[i]] = referalTurnovers[i];
        }

        uint toPayout;
        if (userFixedAirdropAmount > 0) {
            totalFixedAirdropped += userFixedAirdropAmount;
            toPayout += userFixedAirdropAmount;
            emit AirdropFixedReward(user, userFixedAirdropAmount, potentialLevel);
        }

        if (userVariableAirdropAmount > 0) {
            totalVariableAirdropped += userVariableAirdropAmount;
            toPayout += userVariableAirdropAmount;
            emit AirdropVariableReward(user, userVariableAirdropAmount, potentialLevel);
        }

        require(toPayout > systemFee, "No rewards or fee more then rewards");
        TransferHelper.safeTransfer(address(NBU), user, toPayout - systemFee);
        
        require(totalAirdropped() <= airdropProgramCap, "Airdrop program reached its cap");
        emit QualificationUpdated(user, userQualificationLevel[user], potentialLevel, systemFee);
        userQualificationLevel[user] = potentialLevel;
        if (isMaxLevel) {
            userMaxLevelPayment[user] += userVariableAirdropAmount;
        }
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



    function canQualificationBeUpgraded(address user, uint256 structureTurnover) external view returns (bool) {
        uint qualificationLevel = userQualificationLevel[user];
        return _getUserPotentialQualificationLevel(qualificationLevel, structureTurnover) > qualificationLevel;
    }

    function calculateStructureLine(address[] memory referralAddresses, uint256[] memory referalTurnovers) internal pure returns (uint256 structureTurnover) {
        for (uint i = 0; i < referralAddresses.length; i++) structureTurnover += referalTurnovers[i];
    }

    function canQualificationBeUpgradedOrCanClaimMaxLevelReward(address user, uint256 personalTurnover, address[] memory referralAddresses, uint256[] memory referalTurnovers) external view 
        returns (bool canQualBeUpgraded, bool canClaimMaxLevelReward) 
    {
        uint256 structureTurnover = calculateStructureLine(referralAddresses, referalTurnovers);
        uint qualificationLevel = userQualificationLevel[user];
        canQualBeUpgraded = _getUserPotentialQualificationLevel(qualificationLevel, structureTurnover) > qualificationLevel;
        if (qualificationLevel >= qualificationsCount - 1) {
            (, uint userVariable, ,)  = getUserRewards(user, personalTurnover, referralAddresses, referalTurnovers);
            canClaimMaxLevelReward = userVariable > 0;
        }
    }

    function getUserPotentialQualificationLevel(address user, uint256 structureTurnover) public view returns (uint) {
        uint qualificationLevel = userQualificationLevel[user];
        return _getUserPotentialQualificationLevel(qualificationLevel, structureTurnover);
    }

    function userFullStructureTurnover(address user) public view returns (uint) {
        return _userFullStructureTurnover(rpUsers.getUserReferrals(user));
    }

    function _userFullStructureTurnover(uint[] memory userReferrals) internal view returns (uint256 structureTurnover) {
        if (userReferrals.length == 0) return structureTurnover;

        for (uint i = 0; i < userReferrals.length; i++) {
            address referralAddress = rpUsers.userAddressById(userReferrals[i]);
            structureTurnover += userPersonalTurnover[referralAddress] + 
            _userFullStructureTurnover(rpUsers.getUserReferrals(referralAddress));
        }
        return structureTurnover;
    }

    function getUserRewards(address user, uint256 personalTurnover, address[] memory referralAddresses, uint256[] memory referalTurnovers) public view returns (uint userFixed, uint userVariable, uint potentialLevel, bool isMaxLevel) {
        require(rpUsers.userIdByAddress(user) > 0, "User not registered");
        require(referralAddresses.length == referalTurnovers.length, "Not equal arrays");
        require(personalTurnover <= userPersonalTurnover[user], "Wrong personal turnover");

        uint qualificationLevel = userQualificationLevel[user];

        uint structureLine = calculateStructureLine(referralAddresses, referalTurnovers);
        uint turnover = personalTurnover + structureLine;
        isMaxLevel = qualificationLevel >= (qualificationsCount - 1);
        
        if (!isMaxLevel) {
            potentialLevel = _getUserPotentialQualificationLevel(qualificationLevel, turnover);
            require(potentialLevel > qualificationLevel, "User level hasn't changed");
        } else {
            potentialLevel = qualificationsCount - 1;
        }
        require(upgradeLevelsLeft(user, potentialLevel) >= potentialLevel, "No upgrade levels left");

        if (referralAddresses.length == 0) return (0, 0, potentialLevel, isMaxLevel);
        
        userFixed = _getFixedRewardToBePaidForQualification(structureLine, qualificationLevel, potentialLevel);
        userVariable = _getVariableRewardToBePaidForQualification(user, referralAddresses, referalTurnovers, potentialLevel);
        if (isMaxLevel) {
            if (userVariable > userMaxLevelPayment[user]) userVariable -= userMaxLevelPayment[user];
        }
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

    function _getVariableRewardToBePaidForQualification(address user, address[] memory referralAddresses, uint256[] memory referralTurnovers, uint qualification) internal view returns (uint userVariable) {
        uint userQualificationPercentage = qualifications[qualification].Percentage;
        for (uint i; i < referralAddresses.length; i++) {
            uint referralTurnover = referralTurnovers[i];
            uint referralQualification = getUserPotentialQualificationLevel(referralAddresses[i], referralTurnover);
            uint referralPercentage = qualifications[referralQualification].Percentage;
            if (referralPercentage >= userQualificationPercentage) continue;
            if (upgradeNonces[user] > 0) referralTurnover -= prevTurnovers[user][upgradeNonces[user]][referralAddresses[i]];
            userVariable += (userQualificationPercentage - referralPercentage) * referralTurnover / PERCENTAGE_PRECISION;
        }
    }

    function _getVariableRewardToBePaidForQualificationByLines(address user, address[] memory referralAddresses, uint256[] memory referralTurnovers, uint qualification) internal view returns (uint[] memory linePercentages, uint[] memory lineVariables) {
        uint userQualificationPercentage = qualifications[qualification].Percentage;
        linePercentages = new uint[](referralAddresses.length);
        lineVariables = new uint[](referralAddresses.length);
        for (uint i; i < referralAddresses.length; i++) {
            uint referralTurnover = referralTurnovers[i];
            uint referralQualification = getUserPotentialQualificationLevel(referralAddresses[i], referralTurnover);
            uint referralPercentage = qualifications[referralQualification].Percentage;
            if (referralPercentage >= userQualificationPercentage) continue;
            if (upgradeNonces[user] > 0) referralTurnover -= prevTurnovers[user][upgradeNonces[user]][referralAddresses[i]];
            uint linePercentage = userQualificationPercentage - referralPercentage;
            linePercentages[i] = linePercentage;
            lineVariables[i] = linePercentage * referralTurnover / PERCENTAGE_PRECISION;
        }
    }

    function getPreviousUpgradeReferalTurnovers(address user, address[] memory referralAddresses) external view returns(uint[] memory turnovers) {
        for (uint i = 0; i < referralAddresses.length; i++) turnovers[i] = prevTurnovers[user][upgradeNonces[user]][referralAddresses[i]];
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
        require(Address.isContract(_contract), "Provided address is not a contract");
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
    
    function importUserTurnover(address user, uint personalTurnover, uint levelHint, bool addToCurrentTurnover, bool updateLevel, bool isSilent) external onlyOwner {
        _importUserTurnover(user, personalTurnover, levelHint, addToCurrentTurnover, updateLevel, isSilent);
    }

    function importUserTurnovers(address[] memory users, uint[] memory personalTurnovers, uint[] memory levelsHints, bool addToCurrentTurnover, bool updateLevel, bool isSilent) external onlyOwner {
        require(users.length == personalTurnovers.length && 
            users.length == levelsHints.length, "Array length missmatch");

        for(uint i = 0; i < users.length; i++) {
            _importUserTurnover(users[i], personalTurnovers[i], levelsHints[i], addToCurrentTurnover, updateLevel, isSilent);
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
        require(!isHeadOfLocation[headOfLocation], "Head of location already added");
        require(isRegionManager[regionalManager], "Regional manager not exists");
        require(rpUsers.userIdByAddress(headOfLocation) > 1000000001, "Head of location not in referral system or first user");
        headOfLocations.push(headOfLocation);
        isHeadOfLocation[headOfLocation] = true;
        headOfLocationRegionManagers[headOfLocation] = regionalManager;
        emit AddHeadOfLocation(headOfLocation, regionalManager);
    }

    function _addRegionalManager(address regionalManager) internal {
        require(!isRegionManager[regionalManager], "Regional manager exist");
        require(rpUsers.userIdByAddress(regionalManager) > 1000000001, "Regional manager not in referral system or first user");
        regionalManagers.push(regionalManager);
        isRegionManager[regionalManager] = true;
        emit AddRegionalManager(regionalManager);
    }

    function _upgradeUserQualification(address user, uint qualification, bool updateTurnover) internal {
        require(qualification < qualificationsCount, "Incorrect qualification index");
        require(userQualificationLevel[user] < qualification, "Can't donwgrade user qualification");
        uint newTurnover;
        if (updateTurnover) {
            newTurnover = qualifications[qualification].TotalTurnover;
            // userStructureTurnover[user] = newTurnover;
        }
        emit UpgradeUserQualification(user, userQualificationLevel[user], qualification, newTurnover);
        userQualificationLevel[user] = qualification;
        userQualificationOrigin[user] = 2;
    }

    function _importUserHeadOfLocation(address user, address headOfLocation, bool isSilent) internal onlyOwner {
        require(isHeadOfLocation[headOfLocation], "Not head of location");
        userHeadOfLocations[user] = headOfLocation;
        if (!isSilent) emit ImportUserHeadOfLocation(user, headOfLocation);
    }

    function _updateQualification(uint index, uint totalTurnoverAmount, uint percentage, uint fixedReward, uint maxUpdateLevel) internal {
        //Total turnover amount can be zero for the first qualification (zero qualification), so check and require is not needed
        qualifications[index] = Qualification(index, totalTurnoverAmount, percentage, fixedReward, maxUpdateLevel);
        emit UpdateQualification(index, totalTurnoverAmount, percentage, fixedReward, maxUpdateLevel);
    }

    function _importUserTurnover(address user, uint personalTurnover, uint levelHint, bool addToCurrentTurnover, bool updateLevel, bool isSilent) private {
        require(rpUsers.userIdByAddress(user) != 0, "User is not registered");

        if (addToCurrentTurnover) {
            uint previousPersonalTurnover = userPersonalTurnover[user];
            uint newPersonalTurnover = previousPersonalTurnover + personalTurnover;
            if (!isSilent) emit ImportUserTurnoverUpdate(user, newPersonalTurnover, previousPersonalTurnover);
            userPersonalTurnover[user] = newPersonalTurnover;
        } else {
            userPersonalTurnover[user] = personalTurnover;
            if (!isSilent) emit ImportUserTurnoverSet(user, personalTurnover);
        }

        if (updateLevel) {
            uint potentialLevel = levelHint;
            if (potentialLevel > 0) {
                userQualificationLevel[user] = potentialLevel;
                if (!isSilent) emit QualificationUpdated(user, 0, potentialLevel, 0);
            }
        }
        userQualificationOrigin[user] = 1;
    }

    function _importHeadOfLocationTurnover(address headOfLocation, uint turnover, uint levelHint, bool addToCurrentTurnover, bool updateLevel) private {
        require(isHeadOfLocation[headOfLocation], "User is not head of location");

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
        require(isRegionManager[regionalManager], "User is not head of location");
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

    function availableAirdropSupply() external view returns (uint) {
        return NBU.balanceOf(address(this));
    }
}