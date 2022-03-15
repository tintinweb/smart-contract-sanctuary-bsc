/**
 *Submitted for verification at BscScan.com on 2022-03-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-21
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.1;

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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

/**
 * @notice Biswap NFT interface
 */
interface IEggNFT {
    function stakingMint(address to, uint level, string memory name) external;
}


contract EggFarm {
    string public name = "Egg Farm";
    address public owner;
    uint256 profileId;
    uint256 packageId;
    uint256 public totalStaking;
    uint256 public totalClaimedStaking;
    uint256 public totalProfit;
    uint256 public totalClaimedProfit;
    IEggNFT eggNFT;
    bool public isEnableRandom;
    bool public isEnalbeMintNFT;
    uint nonce;

    IERC20 public stakeToken;

    struct Package {
        uint256 totalPercentProfit; // 5 = 5%
        uint256 vestingTime; // 1 = 1 month
        bool isActive; 
        uint256 minAmount;
    }

    struct UserInfo {
        uint256 id;
        address user;
        uint256 amount; // How many tokens the user has provided.
        uint256 profitClaimed; // default false
        uint256 stakeClaimed; // default false
        uint256 vestingStart;
        uint256 vestingEnd;
        uint256 totalProfit;
        uint256 packageId;
        uint256 eggLevel;
        string eggName;
        bool isNFTMinted;
    }

    mapping(address => uint) public totalProfile;
    mapping(uint256 => uint256[]) public lockups;
    mapping(uint256 => uint256[]) public randomPercents; // Arrange buy level: 1, 2, 3
    
    string[] public eggNames;
    UserInfo[] public userInfo;

    mapping(uint => Package ) public packages;

    event Deposit(address by, uint256 amount);
    event ClaimProfit(address by, uint256 amount);
    event ClaimStaking(address by, uint256 amount);

    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner of the token farm can call this function");
        _;
    }

    constructor(IERC20 _stakeToken, IEggNFT _eggNFT) {
        // In order to use them in other functions
        eggNFT = _eggNFT;
        stakeToken = _stakeToken;
        owner = msg.sender;

        // Init packages
        packages[1] = Package(6, 3, true, 10 ether);
        lockups[1] =  [5, 10, 15, 25, 35, 45, 60, 80, 100];
        randomPercents[1] = [8000, 9800, 10000]; // 80%, (98 - 80) 18%, (100 - 98) 2%

        packages[2] = Package(24, 6, true, 50 ether);
        lockups[2] =  [5, 10, 25, 40, 65, 100];
        randomPercents[2] = [2000, 8000, 10000]; // 20%, (80 - 20) 60%, (100 - 80) 20%

        packages[3] = Package(60, 12, true, 250 ether);
        lockups[3] =  [100];
        randomPercents[3] = [200, 2000, 10000]; // 2%, (20 - 2) 18%, (100 - 18) 82%

        // Init package
        packageId = 4;

        // Init contract info
        isEnableRandom = true;
        isEnalbeMintNFT = false;
        eggNames = ['mouse', 'buffalo', 'lion', 'dinosaur'];
    }

    // Add status package
    function addPackage(
        uint256 _totalPercentProfit, 
        uint256 _vestingTime, 
        uint256[] memory _lockups,
        uint256[] memory _randomPercents,
        uint256 _minAmount
        ) public onlyOwner {
        require(_totalPercentProfit > 0, "Profit can not be 0");
        require(_vestingTime > 0, "Vesting time can not be 0");
        packages[packageId] = Package(_totalPercentProfit, _vestingTime, true, _minAmount);
        lockups[packageId] = _lockups;
        randomPercents[packageId] = _randomPercents;
        packageId++;
    }

    // Add package info
    function updatePackageInfo(
        uint256 _packageId,
        uint256 _totalPercentProfit, 
        uint256 _vestingTime, 
        uint256 _minAmount
        ) public onlyOwner {
        require(packages[_packageId].totalPercentProfit > 0, "Invalid package id");
        require(_totalPercentProfit > 0, "Profit can not be 0");
        require(_vestingTime > 0, "Vesting time can not be 0");
        packages[packageId] = Package(_totalPercentProfit, _vestingTime, true, _minAmount);
    }

    // Add lockups package
    function updateLockupsPackage(
        uint256 _packageId,
        uint256[] memory _lockups
        ) public onlyOwner {
        require(packages[_packageId].totalPercentProfit > 0, "Invalid package id");
        lockups[packageId] = _lockups;
    }

    // Add levels package
    function updateRamdomPercentsPackage(
        uint256 _packageId,
        uint256[] memory _randomPercents
        ) public onlyOwner {
        require(packages[_packageId].totalPercentProfit > 0, "Invalid package id");
        randomPercents[packageId] = _randomPercents;
    }

    // Update status package
    function setActivePackage(uint256 _packageId, bool _isActive) public onlyOwner {
        require(packages[_packageId].totalPercentProfit > 0, "Invalid package id");
        packages[_packageId].isActive = _isActive;
    }

    function setStakeToken(IERC20 _stakeToken) public onlyOwner {
        stakeToken = _stakeToken;
    }

    function setEggMint(IEggNFT _eggNFT) public onlyOwner {
        eggNFT = _eggNFT;
    }

    function setEnableRandom(bool _active) public onlyOwner {
        isEnableRandom = _active;
    }

    function setEnableMintNFT(bool _active) public onlyOwner {
        isEnalbeMintNFT = _active;
    }

    function setEggNames(string[] memory _names) public onlyOwner {
        require(_names.length > 0, "Please input array items.");
        eggNames = _names;
    }

    function getLockups(uint256 _packageId) public view returns(uint256[] memory) {
        return lockups[_packageId];
    }

    function getProfilesByAddress(address user) public view returns(UserInfo[] memory) {
        uint256 total = 0;
        for(uint i = 0; i < userInfo.length; i++){
            if (userInfo[i].user == user) {
               total++;
            }
        }

        require(total > 0, "Invalid profile address");

        UserInfo[] memory profiles = new UserInfo[](total);
        uint256 j;

        for(uint i = 0; i < userInfo.length; i++){
            if (userInfo[i].user == user) {
                profiles[j] = userInfo[i];  // step 3 - fill the array
                j++;
            }
        }

        return profiles;
    }

    function getProfilesLength() public view returns(uint256) {
        return userInfo.length;
    }

    /**
     * @notice Generate random between min and max brackets value. Then find RB value
     */
    function getRandomLevel(uint256 _packageId) private returns(uint) {
        uint min = 100;
        uint max = 10000;
        uint random = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % max + min;
        nonce++;
        uint level = 1;

        for (uint256 index = 0; index < randomPercents[_packageId].length; index++) {
            if (random <= randomPercents[_packageId][index]) {
                level = index + 1;
                return level;
            }
        }

        return level;
    }

    function getRandomName() private  returns(string memory) {
        uint min = 0;
        uint max = eggNames.length - 1;
        uint random = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % max + min;
        nonce++;

        if (random < min || random > max) {
            return eggNames[0];
        }

        return eggNames[random];
    }
    
    function stake(uint _amount, uint256 _packageId) public returns(uint level, string memory eggName) {
        // Validate amount
        require(_amount > 0, "Amount cannot be 0");
        require(packages[_packageId].totalPercentProfit > 0, "Invalid package id");
        require(packages[_packageId].isActive == true, "This package is not available");
        require(packages[_packageId].minAmount <= _amount, "Amount is lower than the minimum amount");

        // Transfer token
        stakeToken.transferFrom(msg.sender, address(this), _amount);

        uint256 profit = _amount * packages[_packageId].totalPercentProfit / 100;

        UserInfo memory profile;
        profile.id = profileId;
        profile.packageId = _packageId;
        profile.user = msg.sender;
        profile.amount = _amount;
        profile.profitClaimed = 0;
        profile.stakeClaimed = 0;
        profile.vestingStart = block.timestamp;
        profile.vestingEnd = block.timestamp + packages[_packageId].vestingTime * 10 minutes;
        profile.totalProfit = profit;

        if (isEnableRandom) {
            level = getRandomLevel(_packageId);
            profile.eggLevel = level;
            
            eggName = getRandomName();
            profile.eggName = eggName;

            // Mint nft if enable flag
            if (isEnalbeMintNFT) {
                eggNFT.stakingMint(msg.sender, level, name);
                profile.isNFTMinted = true;
            } else {
                profile.isNFTMinted = false;
            }

        } else {
            level = 0;
            eggName = "";
            profile.eggLevel = level;
            profile.eggName = eggName;
            profile.isNFTMinted = false;
        }

        userInfo.push(profile);

        // Update profile id
        profileId++;

        // Update total staking
        totalStaking += _amount;

        // Update total profit
        totalProfit += profit;

        emit Deposit(msg.sender, _amount);

        return (level, eggName);
    }

    function getCurrentProfit(uint256 _profileId) public view returns(uint256) {
        require(userInfo[_profileId].packageId != 0, 'Invalid profile');

        UserInfo memory info = userInfo[_profileId];

        if ( block.timestamp > info.vestingEnd) {
            return info.totalProfit;
        }

        uint256 profit = (( block.timestamp - info.vestingStart) * info.totalProfit) / (info.vestingEnd - info.vestingStart);
        return profit;
    }

    function claimProfit(uint256 _profileId) public {
        require(userInfo[_profileId].user == msg.sender, 'You are not onwer');
        UserInfo storage info = userInfo[_profileId];

        uint256 profit = getCurrentProfit(_profileId);
        uint256 remainProfit = profit - info.profitClaimed;

        require(remainProfit > 0, "No profit");

        stakeToken.transfer(msg.sender, remainProfit);
        info.profitClaimed += remainProfit;

        // Update total profit claimed
        totalClaimedProfit += profit;

        emit ClaimProfit(msg.sender, remainProfit);
    }

    function getCurrentStakeUnlock(uint256 _profileId) public view returns(uint256) {
        require(userInfo[_profileId].packageId != 0, 'Invalid profile');

        UserInfo memory info = userInfo[_profileId];

        uint256[] memory pkgLockups = getLockups(info.packageId);

        if (block.timestamp < info.vestingEnd) {
            return 0;
        }

        // Not lockup, can withdraw 100% after vesting time
        if (pkgLockups.length == 1 && pkgLockups[0] == 100) {
            return info.amount;
        }

        uint256 length = pkgLockups.length;
        for(uint i = length - 1; i >= 0; i--){
            uint256 limitWithdrawTime = info.vestingEnd + (i + 1) * 10 minutes;
            if (block.timestamp > limitWithdrawTime) {
               return pkgLockups[i] * info.amount / 100;
            }
        }

        return 0;
    }

    function claimStaking(uint256 _profileId) public {
        require(userInfo[_profileId].user == msg.sender, 'You are not onwer');
        require(userInfo[_profileId].vestingEnd < block.timestamp, 'Can not claim before vesting end');

        UserInfo storage info = userInfo[_profileId];
        uint256 amountUnlock = getCurrentStakeUnlock(_profileId);

        uint256 remainAmount = amountUnlock - info.stakeClaimed;

        require(remainAmount > 0, "No staking");
        
        stakeToken.transfer(msg.sender, remainAmount);
        info.stakeClaimed += remainAmount;

        // Update total staking
        totalClaimedStaking += remainAmount;

        emit ClaimStaking(msg.sender, remainAmount);
    }

    // Withdraw staking token from smart contract
    function withdraw(uint256 _amount) public onlyOwner {
        stakeToken.transfer(msg.sender, _amount);
    }
}