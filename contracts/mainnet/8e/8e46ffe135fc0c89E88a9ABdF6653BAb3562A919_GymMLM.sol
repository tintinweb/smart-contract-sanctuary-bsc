// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IPendingCommissions.sol";
import "./interfaces/IGymMLMQualifications.sol";
import "./interfaces/IGymSinglePool.sol";
import "./interfaces/IGymFarming.sol";
import "./interfaces/IAccountant.sol";
import "./interfaces/IGymVault.sol";
import "./interfaces/ICommissionActivation.sol";

contract GymMLM is OwnableUpgradeable {
    event NewReferral(address indexed user, address indexed referral);

    uint256 public currentId;
    uint256[25] public directReferralBonuses;

    mapping(address => uint256) public addressToId;
    mapping(uint256 => address) public idToAddress;
    mapping(address => bool) public hasInvestment;
    mapping(address => bool) public isDeactivated;
    mapping(address => address) public userToReferrer;
    mapping(address => uint256) public userMLMDepth;
    mapping(address => bool) public termsOfConditions;

    address public bankAddress;
    address public farmingAddress;
    address public singlePoolAddress;
    address public accountantAddress;
    address public mlmQualificationsAddress;
    address public managementAddress;
    address public whiteListAddress;
    address public gymStreetAddress;

    // 1 - VaultBank, 2 - Farming, 3 - SinglePool
    mapping(uint256 => address) public commissionsAddresses;

    event ReferralRewardReceived(
        address indexed user,
        address indexed referral,
        uint256 level,
        uint256 amount,
        address wantAddress
    );

    event MLMCommissionUpdated(uint256 indexed _level, uint256 _newValue);
    event WhitelistWallet(address indexed _wallet);

    event SetGymVaultsBankAddress(address indexed _address);
    event SetGymFarmingAddress(address indexed _address);
    event SetGymSinglePoolAddress(address indexed _address);
    event SetGymAccountantAddress(address indexed _address);
    event SetGymMLMQualificationsAddress(address indexed _address);
    event SetManagementAddress(address indexed _address);
    event SetGymStreetAddress(address indexed _address);
    event SetPendingCommissionsAddress(address indexed _address, uint256 _type);

    function initialize(
        address _bankAddress,
        address _farmingAddress,
        address _singlePoolAddress,
        address _accountantAddress,
        address _mlmQualificationsAddress,
        address _managementAddress,
        address _gymStreetAddress
    ) external initializer {
        bankAddress = _bankAddress;
        farmingAddress = _farmingAddress;
        singlePoolAddress = _singlePoolAddress;
        accountantAddress = _accountantAddress;
        mlmQualificationsAddress = _mlmQualificationsAddress;
        managementAddress = _managementAddress;
        gymStreetAddress = _gymStreetAddress;

        directReferralBonuses = [
            1000,
            500,
            500,
            300,
            300,
            200,
            200,
            100,
            100,
            100,
            50,
            50,
            50,
            50,
            50,
            50,
            50,
            50,
            50,
            25,
            25,
            25,
            25,
            25,
            25
        ];
        addressToId[0x49A6DaD36768c23eeb75BD253aBBf26AB38BE4EB] = 1;
        idToAddress[1] = 0x49A6DaD36768c23eeb75BD253aBBf26AB38BE4EB;
        userToReferrer[
            0x49A6DaD36768c23eeb75BD253aBBf26AB38BE4EB
        ] = 0x49A6DaD36768c23eeb75BD253aBBf26AB38BE4EB;
        userMLMDepth[0x49A6DaD36768c23eeb75BD253aBBf26AB38BE4EB] = 0;
        termsOfConditions[0x49A6DaD36768c23eeb75BD253aBBf26AB38BE4EB] = true;
        currentId = 2;

        __Ownable_init();
    }

    modifier onlyRelatedContracts() {
        require(
            msg.sender == bankAddress ||
                msg.sender == farmingAddress ||
                msg.sender == singlePoolAddress,
            "GymMLM:: Only related contracts"
        );
        _;
    }

    modifier onlyBank() {
        require(msg.sender == bankAddress, "GymMLM:: Only bank");
        _;
    }

    modifier onlyWhiteList() {
        require(msg.sender == whiteListAddress, "GymMLM:: Only white list address");
        _;
    }

    modifier onlyGymStreet() {
        require(msg.sender == gymStreetAddress, "GymMLM:: Only gym street");
        _;
    }

    receive() external payable {}

    fallback() external payable {}

    function setBankAddress(address _address) external onlyOwner {
        bankAddress = _address;

        emit SetGymVaultsBankAddress(_address);
    }

    function setSinglePoolAddress(address _address) external onlyOwner {
        singlePoolAddress = _address;

        emit SetGymSinglePoolAddress(_address);
    }

    function setFarmingAddress(address _address) external onlyOwner {
        farmingAddress = _address;

        emit SetGymFarmingAddress(_address);
    }

    function setAccountantAddress(address _address) external onlyOwner {
        accountantAddress = _address;

        emit SetGymAccountantAddress(_address);
    }

    function setMLMQualificationsAddress(address _address) external onlyOwner {
        mlmQualificationsAddress = _address;

        emit SetGymMLMQualificationsAddress(_address);
    }

    function setManagementAddress(address _address) external onlyOwner {
        managementAddress = _address;

        emit SetManagementAddress(_address);
    }

    function setWhiteListAddress(address _address) external onlyOwner {
        whiteListAddress = _address;

        emit WhitelistWallet(_address);
    }

    function setGymStreetAddress(address _address) external onlyOwner {
        gymStreetAddress = _address;

        emit SetGymStreetAddress(_address);
    }

    function setCommissionsAddress(address _address, uint256 _type) external onlyOwner {
        commissionsAddresses[_type] = _address;

        emit SetPendingCommissionsAddress(_address, _type);
    }

    /**
     * @notice  Function to update MLM commission
     * @param _level commission level for change
     * @param _commission new commission
     */
    function updateMLMCommission(uint256 _level, uint256 _commission) external onlyOwner {
        directReferralBonuses[_level] = _commission;

        emit MLMCommissionUpdated(_level, _commission);
    }

    /**
     * @notice  Function to add GymMLM from related contracts
     * @param _user Address of user
     * @param _referrerId id of referrer
     */
    function addGymMLM(address _user, uint256 _referrerId) external onlyBank {
        address _referrer = _getReferrer(_user, _referrerId);
        if (addressToId[_user] == 0) {
            require(
                termsOfConditions[_referrer],
                "GymMLM:: your sponsor not activate Affiliate program"
            );
        }
        _addMLM(_user, _referrer);
    }

    /**
     * @notice  Function to add GymMLM from NFT part
     * @param _user Address of user
     * @param _referrerId id of referrer
     */
    function addGymMLMNFT(address _user, uint256 _referrerId) external onlyGymStreet {
        _addMLM(_user, _getReferrer(_user, _referrerId));
    }

    function agreeTermsOfConditions(address[] calldata _directPartners) external {
        if (termsOfConditions[msg.sender] == false) {
            termsOfConditions[msg.sender] = true;
            IGymVault(bankAddress).updateTermsOfConditionsTimestamp(msg.sender);
        }
        _addDirectPartners(msg.sender, _directPartners);
    }

    /**
     * @notice Function to distribute rewards to referrers
     * @param _amount Amount of assets that will be distributed
     * @param _pid Pool id
     * @param _type: type of pending rewards (
                1 - VaultBank,
                2 - Farming,
                3 - SinglePool
       )
     * @param _isDeposit is deposit
     * @param _user Address of user
     */
    function distributeCommissions(
        uint256 _amount,
        uint256 _pid,
        uint256 _type,
        bool _isDeposit,
        address _user
    ) external onlyRelatedContracts {
        uint256 index;
        IPendingCommissions(commissionsAddresses[_type]).claimInternally(
            _pid,
            _user
        );

        IPendingCommissions.DistributionInfo[]
            memory _distributionInfo = new IPendingCommissions.DistributionInfo[](
                _userDepth(_user)
            );
        while (index < directReferralBonuses.length && addressToId[_user] != 1) {
            address _referrer = userToReferrer[_user];
            uint256 _shares = (_amount * directReferralBonuses[index]) / 10000;
            _distributionInfo[index] = IPendingCommissions.DistributionInfo({
                user: _referrer,
                amount: _shares
            });
            _user = userToReferrer[_user];
            index++;
        }

        
        IPendingCommissions(commissionsAddresses[_type]).updateRewards(
            _pid,
            _isDeposit,
            _amount,
            _distributionInfo
        );
        
        return;
    }

    /**
     * @notice Function to distribute rewards to referrers
     * @param _wantAmt Amount of assets that will be distributed
     * @param _wantAddr Address of want token contract
     * @param _user Address of user
     * @param _type: type of pending rewards (
                1 - VaultBank,
                2 - Farming,
                3 - SinglePool
       )
     */
    function distributeRewards(
        uint256 _wantAmt,
        address _wantAddr,
        address _user,
        uint32 _type
    ) public onlyRelatedContracts {
        uint256 index;
        bool _activateCommission;

        IERC20 token = IERC20(_wantAddr);

        while (index < directReferralBonuses.length && addressToId[userToReferrer[_user]] != 1) {
            address referrer = userToReferrer[_user];
            uint32 _level = IGymMLMQualifications(mlmQualificationsAddress).getUserCurrentLevel(
                referrer
            );
            uint256 userDepositDollarValue = IGymVault(bankAddress).getUserDepositDollarValue(
                _user
            );
            if (index <= _level && userDepositDollarValue > 0) {
                uint256 reward = (_wantAmt * directReferralBonuses[index]) / 10000;
                uint256 rewardToTransfer = reward;
                // update accountant information
                uint256 _borrowedAmount = IAccountant(accountantAddress).getUserBorrowedAmount(
                    referrer,
                    _type
                );
                if (_borrowedAmount > 0) {
                    if (reward >= _borrowedAmount) {
                        token.transfer(accountantAddress, _borrowedAmount);
                        IAccountant(accountantAddress).updateBorrowedAmount(
                            referrer,
                            _borrowedAmount,
                            _type,
                            false
                        );
                        rewardToTransfer = reward - _borrowedAmount;
                    } else {
                        token.transfer(accountantAddress, reward);
                        IAccountant(accountantAddress).updateBorrowedAmount(
                            referrer,
                            reward,
                            _type,
                            false
                        );
                        rewardToTransfer = 0;
                    }
                }
                
                _activateCommission = ICommissionActivation(
                    0x3E1240E879b4613C7Ae6eE1772292FC80B9c259e
                ).getCommissionActivation(referrer, _type);
                if (!_activateCommission || block.number < 21722617) {
                    // ====
                    require(token.transfer(referrer, rewardToTransfer), "GymMLM:: Transfer failed");
                } else {
                    require(
                        token.transfer(commissionsAddresses[_type], rewardToTransfer),
                        "GymMLM:: Transfer failed"
                    );
                }
                emit ReferralRewardReceived(referrer, _user, index, reward, _wantAddr);
            }
            _user = userToReferrer[_user];
            index++;
        }

        if (token.balanceOf(address(this)) > 0) {
            require(
                token.transfer(managementAddress, token.balanceOf(address(this))),
                "GymMLM:: Transfer failed"
            );
        }

        return;
    }

    /*
     * @notice Function to seed users
     * @param mlmAddress: MLM address
     */
    function seedUsers(address[] memory _users, address[] memory _referrers) external onlyOwner {
        require(_users.length == _referrers.length, "Length mismatch");
        for (uint256 i; i < _users.length; i++) {
            _addUser(_users[i], _referrers[i]);

            emit NewReferral(_referrers[i], _users[i]);
        }
    }

    /**
     * @notice Function to update investment
     * @param _user: user address
     * @param _hasInvestment: boolean flag
     */
    function updateInvestment(address _user, bool _hasInvestment) external onlyBank {
        hasInvestment[_user] = _hasInvestment;
    }

    /**
     * @notice Function to get all referrals
     * @param _userAddress: User address
     * @param _level: user level
     * @return users address array
     */
    function getReferrals(address _userAddress, uint256 _level)
        external
        view
        returns (address[] memory)
    {
        address[] memory referrals = new address[](_level);
        for (uint256 i = 0; i < _level; i++) {
            _userAddress = userToReferrer[_userAddress];
            referrals[i] = _userAddress;
        }

        return referrals;
    }

    /**
     * @notice Function to get referrer by io
     * @param _user Address of user
     * @param _referrerId id of referrer
     */
    function _getReferrer(address _user, uint256 _referrerId) private view returns (address) {
        address _referrer = userToReferrer[_user];

        if (_referrer == address(0)) {
            _referrer = idToAddress[_referrerId];
        }

        return _referrer;
    }

    /**
     * @notice  Function to add User to MLM tree
     * @param _user: Address of user
     * @param _referrer: Address of referrer user
     */
    function _addMLM(address _user, address _referrer) private {
        require(_user != address(0), "GymMLM::user is zero address");
        require(
            userToReferrer[_user] == address(0) || userToReferrer[_user] == _referrer,
            "GymMLM::referrer is zero address"
        );

        // If user didn't exist before
        if (addressToId[_user] == 0) {
            _addUser(_user, _referrer);
        }
    }

    /**
     * @notice  Function to add User to MLM tree
     * @param _user: Address of user
     * @param _referrer: Address of referrer user
     */
    function _addUser(address _user, address _referrer) private {
        addressToId[_user] = currentId;
        idToAddress[currentId] = _user;
        userToReferrer[_user] = _referrer;
        IGymMLMQualifications(mlmQualificationsAddress).addDirectPartner(_referrer, _user);
        currentId++;
        emit NewReferral(_referrer, _user);
    }

    /**
     * @notice Private function to get pending rewards to referrers
     * @param _userAddress: User address
     * @param _type: type of pending rewards (
                1 - VaultBank,
                2 - Farming,
                3 - SinglePool
       )
     * @return Pending Rewards
     */
    function _getPendingRewardBalance(address _userAddress, uint32 _type)
        private
        view
        returns (uint256)
    {
        uint256 convertBalance;
        if (_type == 1) {
            convertBalance = IGymVault(bankAddress).pendingRewardTotal(_userAddress);
        } else if (_type == 2) {
            convertBalance = IGymFarming(farmingAddress).pendingRewardTotal(_userAddress);
        } else if (_type == 3) {
            convertBalance = IGymSinglePool(singlePoolAddress).pendingRewardTotal(_userAddress);
        }
        return convertBalance;
    }

    /**
     * @notice Private function to get pending rewards to referrers
     * @param _userAddress: User address
     * @param _type: type of pending rewards (
                1 - VaultBank,
                2 - Farming,
                3 - SinglePool
       )
     * @param _level: User level (default = 0)
     * @param _depth: depth of direct partners (default = 0)
     * @return Pending Rewards
     */
    function _getPendingRewards(
        address _userAddress,
        uint32 _type,
        uint32 _level,
        uint32 _depth
    ) private view returns (uint256) {
        if (_depth > _level + 1) {
            return 0;
        }
        uint256 _rewardsPendingTotal;
        uint256 convertBalance;
        address[] memory _directChilds = IGymMLMQualifications(mlmQualificationsAddress)
            .getDirectPartners(_userAddress);

        if (_depth != 0) {
            convertBalance = _getPendingRewardBalance(_userAddress, _type);
            _rewardsPendingTotal = _calculatePercentOfAmount(
                convertBalance,
                directReferralBonuses[_depth - 1]
            );
        } else {
            _rewardsPendingTotal = 0;
        }

        for (uint32 i = 0; i < _directChilds.length; i++) {
            _rewardsPendingTotal += _getPendingRewards(_directChilds[i], _type, _level, _depth + 1);
        }

        return _rewardsPendingTotal;
    }

    /**
     * @notice Pure Function to calculate percent of amount
     * @param _amount: Amount
     * @param _percent: User address
     */
    function _calculatePercentOfAmount(uint256 _amount, uint256 _percent)
        private
        pure
        returns (uint256)
    {
        return (_amount * _percent) / 10000;
    }

    function _addDirectPartners(address _referrer, address[] memory _directPartners) private {
        for (uint32 i = 0; i < _directPartners.length; i++) {
            if (
                userToReferrer[_directPartners[i]] == _referrer &&
                isUniqueDirectPartner(_referrer, _directPartners[i])
            ) {
                IGymMLMQualifications(mlmQualificationsAddress).addDirectPartner(
                    _referrer,
                    _directPartners[i]
                );
            }
        }
    }

    function isUniqueDirectPartner(address _userAddress, address _referrAddress)
        private
        view
        returns (bool)
    {
        address[] memory _directPartners = IGymMLMQualifications(mlmQualificationsAddress)
            .getDirectPartners(_userAddress);
        if (_directPartners.length == 0) {
            return true;
        }
        for (uint32 i = 0; i < _directPartners.length; i++) {
            if (_referrAddress == _directPartners[i]) {
                return false;
            }
        }
        return true;
    }

    function _userDepth(address _user) private view returns (uint256) {
        uint256 depth = 1;
        while (addressToId[userToReferrer[_user]] != 1 && depth < directReferralBonuses.length) {
            _user = userToReferrer[_user];
            depth++;
        }
        return depth;
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

pragma solidity 0.8.15;

interface IPendingCommissions {
    struct DistributionInfo {
        address user;
        uint256 amount;
    }

    function updateRewards(
        uint256,
        bool,
        uint256,
        DistributionInfo[] memory
    ) external;

    function claimInternally(
        uint256,
        address
    ) external;

}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IGymMLMQualifications {
    struct RockstarLevel {
        uint64 qualificationLevel;
        uint64 usdAmountVault;
        uint64 usdAmountFarm;
        uint64 usdAmountPool;
    }

    function addDirectPartner(address, address) external;

    function getUserCurrentLevel(address) external view returns (uint32);

    function directPartners(address) external view returns (address[] memory);

    function getRockstarAmount(uint32 _rank) external view returns (RockstarLevel memory);

    function updateRockstarRank(
        address,
        uint8,
        bool
    ) external;

    function getDirectPartners(address) external view returns (address[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IGymSinglePool {
    struct UserInfo {
        uint256 totalDepositTokens;
        uint256 totalDepositDollarValue;
        uint256 totalGGYMNET;
        uint256 level;
        uint256 depositId;
        uint256 totalClaimt;
    }

    function getUserInfo(address) external view returns (UserInfo memory);

    function pendingRewardTotal(address) external view returns (uint256);

    function getUserLevelInSinglePool(address) external view returns (uint32);

    function totalGGymnetInPoolLocked() external view returns (uint256);

    function depositFromOtherContract(
        uint256,
        uint8,
        bool,
        address
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IGymFarming {
    struct UserInfo {
        uint256 totalDepositTokens;
        uint256 totalDepositDollarValue;
        uint256 lpTokensAmount;
        uint256 rewardDebt;
    }

    struct PoolInfo {
        address lpToken;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accRewardPerShare;
    }

    function getUserInfo(uint256, address) external view returns (UserInfo memory);

    function getUserUsdDepositAllPools(address) external view returns (uint256);

    function depositFromOtherContract(
        uint256,
        uint256,
        address
    ) external;

    function pendingRewardTotal(address) external view returns (uint256 total);

    function isSpecialOfferParticipant(address _user) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IAccountant {
    function updateBorrowedAmount(
        address _userAddress,
        uint256 _amount,
        uint256 _type,
        bool _increase
    ) external;

    function getUserBorrowedAmount(address _userAddress, uint256 _type)
        external
        view
        returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IGymVault {
    /// @dev Return the total ERC20 entitled to the token holders. Be careful of unaccrued interests.
    function totalToken() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    /// @dev Add more ERC20 to the bank. Hope to get some good returns.
    function deposit(uint256 amountToken) external payable;

    /// @dev Withdraw ERC20 from the bank by burning the share tokens.
    function withdraw(uint256 share) external;

    /// @dev Request funds from user through Vault
    function requestFunds(address targetedToken, uint256 amount) external;

    function token() external view returns (address);

    function pendingRewardTotal(address _user) external view returns (uint256);

    function getUserInvestment(address _user) external view returns (bool);

    function getUserDepositDollarValue(address _user) external view returns (uint256);

    function updateTermsOfConditionsTimestamp(address _user) external;

    function termsOfConditionsTimeStamp(address _user) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface ICommissionActivation {
    function activateCommissions(uint256, address) external;

    function getCommissionActivation(address, uint256) external view returns (bool);
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