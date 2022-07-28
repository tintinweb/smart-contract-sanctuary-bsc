// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./IChimERC1155Upgradeable.sol";

contract ChimStakingUpgradeableV1 is Initializable, ContextUpgradeable, OwnableUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable, ERC1155HolderUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using CountersUpgradeable for CountersUpgradeable.Counter;

    // chim erc1155 contract address
    address private _chimErc1155Address;

    // plan parameters
    struct PlanData {
        string name;
        uint256 nftCount;
        uint256 nftClosed;
        uint256 nftLimit;
        uint256 periodSec;
        uint256 minNftStack;
        uint256[] nftIdList;
        mapping(uint256 => bool) nftIdMapping;
        address rewardErc20Address;
        uint256 rewardErc20AmountPerNft;
        bool paused;
    }
    CountersUpgradeable.Counter private _planIdTracker;
    mapping(uint256 => PlanData) private _plans;

    // stake parameters
    struct StakeData {
        address account;
        uint256 planId;
        uint256 startSec;
        uint256 endSec;
        uint256 nftCount;
        uint256[] nftIdList;
        uint256[] nftAmountList;
        bool closed;
    }
    CountersUpgradeable.Counter private _stakeIdTracker;
    mapping(uint256 => StakeData) private _stakes;

    // mapping plan to stake count
    mapping(uint256 => uint256) private _planStakeCounts;
    // mapping from plan to list of stake IDs
    mapping(uint256 => mapping(uint256 => uint256)) private _planStakes;

    // mapping account to stake count
    mapping(address => uint256) private _accountStakeCounts;
    // mapping from account to list of stake IDs
    mapping(address => mapping(uint256 => uint256)) private _accountStakes;

    // Mapping for staking admin list
    mapping(address => bool) private _stakingAdminList;

    // Emitted when plan created
    event PlanCreated(
        uint256 indexed planId,
        string name,
        uint256 nftLimit,
        uint256 periodSec,
        uint256 minNftStack,
        uint256[] nftIdList,
        address rewardErc20Address,
        uint256 rewardErc20AmountPerNft,
        bool paused
    );
    // Emitted when plan paused
    event PlanPaused(uint256 indexed planId);
    // Emitted when plan unpaused
    event PlanUnpaused(uint256 indexed planId);

    // Emitted when stake created
    event StakeCreated(
        uint256 indexed stakeId,
        address indexed account,
        uint256 indexed planId,
        uint256 nftCount,
        uint256[] nftIdList,
        uint256[] nftAmountList
    );
    // Emitted when stake closed
    event StakeClosed(
        uint256 indexed stakeId,
        address indexed account,
        uint256 indexed planId,
        uint256 nftCount,
        uint256[] nftIdList,
        uint256[] nftAmountList,
        address rewardErc20Address,
        uint256 rewardErc20Amount
    );

    // Emitted when `account` added to staking admin list.
    event AddToStakingAdminList(address account);
    // Emitted when `account` removed from staking admin list.
    event RemoveFromStakingAdminList(address account);

    modifier onlyStakingAdmin() {
        require(_stakingAdminList[_msgSender()], "ChimStaking: caller is not admin");
        _;
    }

    function initialize(address chimErc1155Address_) public virtual initializer {
        __ChimStakingV1_init(chimErc1155Address_);
    }

    function __ChimStakingV1_init(address chimErc1155Address_) internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
        __Pausable_init_unchained();
        __ReentrancyGuard_init_unchained();
        __ERC165_init_unchained();
        __ERC1155Receiver_init_unchained();
        __ERC1155Holder_init_unchained();
        __ChimStakingV1_init_unchained(chimErc1155Address_);
    }

    function __ChimStakingV1_init_unchained(address chimErc1155Address_) internal initializer {
        require(chimErc1155Address_ != address(0), "ChimStaking: invalid address");
        _chimErc1155Address = chimErc1155Address_;
    }

    function getChimErc1155Address() external view virtual returns (address chimErc1155Address) {
        return _chimErc1155Address;
    }

    function getAllPlanCount() public view virtual returns (uint256 plansCount) {
        return _planIdTracker.current();
    }

    function getPlanCount(bool active_) public view virtual returns (uint256 plansCount) {
        for (uint256 i = 1; i <= getAllPlanCount(); ++i) {
            PlanData storage planData = _plans[i];
            if ((!planData.paused && planData.nftCount < planData.nftLimit) == active_) {
                plansCount++;
            }
        }
        return plansCount;
    }

    function getPlanIds(bool active_) external view virtual returns (uint256[] memory planIds_) {
        uint256 index;
        planIds_ = new uint256[](getPlanCount(active_));
        for (uint256 i = 1; i <= getAllPlanCount(); ++i) {
            PlanData storage planData = _plans[i];
            if ((!planData.paused && planData.nftCount < planData.nftLimit) == active_) {
                planIds_[index] = i;
                index++;
            }
        }
        return planIds_;
    }

    function getPlan(uint256 planId_)
        external
        view
        virtual
        returns (
            string memory name,
            uint256 nftCount,
            uint256 nftClosed,
            uint256 nftLimit,
            uint256 periodSec,
            uint256 minNftStack,
            uint256[] memory nftIdList,
            address rewardErc20Address,
            string memory rewardErc20Symbol,
            uint8 rewardErc20Decimals,
            uint256 rewardErc20AmountPerNft,
            bool paused
        )
    {
        PlanData storage planData = _plans[planId_];
        return (
            planData.name,
            planData.nftCount,
            planData.nftClosed,
            planData.nftLimit,
            planData.periodSec,
            planData.minNftStack,
            planData.nftIdList,
            planData.rewardErc20Address,
            getErc20Symbol(planData.rewardErc20Address),
            getErc20Decimals(planData.rewardErc20Address),
            planData.rewardErc20AmountPerNft,
            planData.paused
        );
    }

    function getPlanBatch(uint256[] memory planIds_)
        external
        view
        virtual
        returns (
            string[] memory nameList,
            uint256[] memory nftCountList,
            uint256[] memory nftClosedList,
            uint256[] memory nftLimitList,
            uint256[] memory periodSecList,
            uint256[] memory minNftStackList,
            uint256[][] memory nftIdsList,
            address[] memory rewardErc20AddressList,
            string[] memory rewardErc20SymbolList,
            uint8[] memory rewardErc20DecimalsList,
            uint256[] memory rewardErc20AmountPerNftList,
            bool[] memory pausedList
        )
    {
        nameList = new string[](planIds_.length);
        nftCountList = new uint256[](planIds_.length);
        nftClosedList = new uint256[](planIds_.length);
        nftLimitList = new uint256[](planIds_.length);
        periodSecList = new uint256[](planIds_.length);
        minNftStackList = new uint256[](planIds_.length);
        nftIdsList = new uint256[][](planIds_.length);
        rewardErc20AddressList = new address[](planIds_.length);
        rewardErc20SymbolList = new string[](planIds_.length);
        rewardErc20DecimalsList = new uint8[](planIds_.length);
        rewardErc20AmountPerNftList = new uint256[](planIds_.length);
        pausedList = new bool[](planIds_.length);
        for (uint256 i = 0; i < planIds_.length; ++i) {
            uint256 planId = planIds_[i];
            PlanData storage planData = _plans[planId];
            nameList[i] = planData.name;
            nftCountList[i] = planData.nftCount;
            nftClosedList[i] = planData.nftClosed;
            nftLimitList[i] = planData.nftLimit;
            periodSecList[i] = planData.periodSec;
            minNftStackList[i] = planData.minNftStack;
            nftIdsList[i] = planData.nftIdList;
            rewardErc20AddressList[i] = planData.rewardErc20Address;
            rewardErc20SymbolList[i] = getErc20Symbol(planData.rewardErc20Address);
            rewardErc20DecimalsList[i] = getErc20Decimals(planData.rewardErc20Address);
            rewardErc20AmountPerNftList[i] = planData.rewardErc20AmountPerNft;
            pausedList[i] = planData.paused;
        }
        return (
            nameList,
            nftCountList,
            nftClosedList,
            nftLimitList,
            periodSecList,
            minNftStackList,
            nftIdsList,
            rewardErc20AddressList,
            rewardErc20SymbolList,
            rewardErc20DecimalsList,
            rewardErc20AmountPerNftList,
            pausedList
        );
    }

    function getStakesCount() public view virtual returns (uint256 stakesCount) {
        return _stakeIdTracker.current();
    }

    function getPlanStakesCount(uint256 planId_) public view virtual returns (uint256 planStakesCount) {
        return _planStakeCounts[planId_];
    }

    function getAddressStakesCount(address account_) public view virtual returns (uint256 addressStakesCount) {
        return _accountStakeCounts[account_];
    }

    function getPlanStakeIdByIndex(uint256 planId_, uint256 index_) public view virtual returns (uint256 stakeId) {
        require(index_ < getPlanStakesCount(planId_), "ChimStaking: index out of bounds");
        return _planStakes[planId_][index_];
    }

    function getPlanStakeIdByIndexBatch(uint256 planId_, uint256[] memory indexList_) external view virtual returns (uint256[] memory stakeIdList) {
        stakeIdList = new uint256[](indexList_.length);
        for (uint256 i = 0; i < indexList_.length; ++i) {
            stakeIdList[i] = getPlanStakeIdByIndex(planId_, indexList_[i]);
        }
        return stakeIdList;
    }

    function getAddressStakeIdByIndex(address account_, uint256 index_) public view virtual returns (uint256 stakeId) {
        require(index_ < getAddressStakesCount(account_), "ChimStaking: index out of bounds");
        return _accountStakes[account_][index_];
    }

    function getAddressStakeIdByIndexBatch(address account_, uint256[] memory indexList_) external view virtual returns (uint256[] memory stakeIdList) {
        stakeIdList = new uint256[](indexList_.length);
        for (uint256 i = 0; i < indexList_.length; ++i) {
            stakeIdList[i] = getAddressStakeIdByIndex(account_, indexList_[i]);
        }
        return stakeIdList;
    }

    function getStake(uint256 stakeId_)
        external
        view
        virtual
        returns (
            address account,
            uint256 planId,
            string memory planName,
            string memory planRewardErc20Symbol,
            uint8 planRewardErc20Decimals,
            uint256 startSec,
            uint256 endSec,
            uint256 stakeReward,
            uint256[] memory nftIdList,
            uint256[] memory nftAmountList,
            bool closed
        )
    {
        StakeData storage stakeData = _stakes[stakeId_];
        PlanData storage planData = _plans[stakeData.planId];
        return (
            stakeData.account,
            stakeData.planId,
            planData.name,
            getErc20Symbol(planData.rewardErc20Address),
            getErc20Decimals(planData.rewardErc20Address),
            stakeData.startSec,
            stakeData.endSec,
            calculateReward(stakeData.nftCount, planData.rewardErc20AmountPerNft),
            stakeData.nftIdList,
            stakeData.nftAmountList,
            stakeData.closed
        );
    }

    function getStakeBatch(uint256[] memory stakeIds_)
        external
        view
        virtual
        returns (
            address[] memory accountList,
            uint256[] memory planIdList,
            string[] memory planNameList,
            string[] memory planRewardErc20SymbolList,
            uint8[] memory planRewardErc20DecimalsList,
            uint256[] memory startSecList,
            uint256[] memory endSecList,
            uint256[] memory stakeRewardList,
            uint256[][] memory nftIdsList,
            uint256[][] memory nftAmountsList,
            bool[] memory closedList
        )
    {
        accountList = new address[](stakeIds_.length);
        planIdList = new uint256[](stakeIds_.length);
        planNameList = new string[](stakeIds_.length);
        planRewardErc20SymbolList = new string[](stakeIds_.length);
        planRewardErc20DecimalsList = new uint8[](stakeIds_.length);
        startSecList = new uint256[](stakeIds_.length);
        endSecList = new uint256[](stakeIds_.length);
        stakeRewardList = new uint256[](stakeIds_.length);
        nftIdsList = new uint256[][](stakeIds_.length);
        nftAmountsList = new uint256[][](stakeIds_.length);
        closedList = new bool[](stakeIds_.length);
        for (uint256 i = 0; i < stakeIds_.length; ++i) {
            uint256 stakeId = stakeIds_[i];
            StakeData storage stakeData = _stakes[stakeId];
            PlanData storage planData = _plans[stakeData.planId];
            accountList[i] = stakeData.account;
            planIdList[i] = stakeData.planId;
            planNameList[i] = planData.name;
            planRewardErc20SymbolList[i] = getErc20Symbol(planData.rewardErc20Address);
            planRewardErc20DecimalsList[i] = getErc20Decimals(planData.rewardErc20Address);
            startSecList[i] = stakeData.startSec;
            endSecList[i] = stakeData.endSec;
            stakeRewardList[i] = calculateReward(stakeData.nftCount, planData.rewardErc20AmountPerNft);
            nftIdsList[i] = stakeData.nftIdList;
            nftAmountsList[i] = stakeData.nftAmountList;
            closedList[i] = stakeData.closed;
        }
        return (
            accountList,
            planIdList,
            planNameList,
            planRewardErc20SymbolList,
            planRewardErc20DecimalsList,
            startSecList,
            endSecList,
            stakeRewardList,
            nftIdsList,
            nftAmountsList,
            closedList
        );
    }

    function isStakingAdmin(address account_) external view virtual returns (bool) {
        return _stakingAdminList[account_];
    }

    function checkBeforeStake(
        address account_,
        uint256 planId_,
        uint256 nftCount_,
        uint256[] memory nftIdList_,
        uint256[] memory nftAmountList_
    ) public view virtual returns (bool) {
        require(
            account_ != address(0)
            && planId_ != 0
            && planId_ <= getAllPlanCount()
            && nftIdList_.length != 0
            && nftIdList_.length == nftAmountList_.length
        , "ChimStaking: invalid stake params");
        require(!paused(), "ChimStaking: paused");
        require(!IChimERC1155Upgradeable(_chimErc1155Address).paused(), "ChimStaking: chimErc1155 is paused");
        require(IChimERC1155Upgradeable(_chimErc1155Address).isApprovedForAll(account_, address(this)), "ChimStaking: chimErc1155 transfer not approved");
        PlanData storage planData = _plans[planId_];
        require(!planData.paused, "ChimStaking: plan is paused");
        uint256 nftCountCheck;
        for (uint256 i = 0; i < nftIdList_.length; ++i) {
            require(planData.nftIdMapping[nftIdList_[i]], "ChimStaking: invalid nftId list");
            nftCountCheck += nftAmountList_[i];
        }
        require(nftCount_ >= planData.minNftStack && nftCount_ == nftCountCheck, "ChimStaking: invalid nft count");
        require((planData.nftCount + nftCount_) <= planData.nftLimit, "ChimStaking: plan nft limit reached");
        return true;
    }

    function stake(
        uint256 planId_,
        uint256 nftCount_,
        uint256[] memory nftIdList_,
        uint256[] memory nftAmountList_
    ) external virtual nonReentrant whenNotPaused {
        require(checkBeforeStake(_msgSender(), planId_, nftCount_, nftIdList_, nftAmountList_), "");

        PlanData storage planData = _plans[planId_];
        planData.nftCount += nftCount_;
        require(planData.nftCount <= planData.nftLimit, "ChimStaking: plan nft limit reached");

        IChimERC1155Upgradeable(_chimErc1155Address).safeBatchTransferFrom(_msgSender(), address(this), nftIdList_, nftAmountList_, "");

        _stakeIdTracker.increment();
        uint256 stakeId = _stakeIdTracker.current();
        StakeData storage stakeData = _stakes[stakeId];
        stakeData.account = _msgSender();
        stakeData.planId = planId_;
        stakeData.startSec = block.timestamp;
        stakeData.endSec = block.timestamp + planData.periodSec;
        stakeData.nftCount = nftCount_;
        stakeData.nftIdList = nftIdList_;
        stakeData.nftAmountList = nftAmountList_;

        _planStakes[planId_][_planStakeCounts[planId_]] = stakeId;
        _planStakeCounts[planId_] += 1;

        _accountStakes[_msgSender()][_accountStakeCounts[_msgSender()]] = stakeId;
        _accountStakeCounts[_msgSender()] += 1;

        emit StakeCreated(
            stakeId,
            _msgSender(),
            planId_,
            nftCount_,
            nftIdList_,
            nftAmountList_
        );
    }

    function checkBeforeWithdraw(
        address account_,
        uint256 stakeId_
    ) public view virtual returns (bool) {
        require(
            account_ != address(0)
            && stakeId_ != 0
            && stakeId_ <= getStakesCount()
        , "ChimStaking: invalid withdraw params");
        require(!paused(), "ChimStaking: paused");
        require(!IChimERC1155Upgradeable(_chimErc1155Address).paused(), "ChimStaking: chimErc1155 is paused");
        StakeData storage stakeData = _stakes[stakeId_];
        require(stakeData.account == account_, "ChimStaking: wrong stake owner");
        require(!stakeData.closed, "ChimStaking: stake already closed");
        require(stakeData.endSec <= block.timestamp, "ChimStaking: withdrawal time has not yet come");
        PlanData storage planData = _plans[stakeData.planId];
        require(IERC20Upgradeable(planData.rewardErc20Address).balanceOf(address(this)) >= calculateReward(stakeData.nftCount, planData.rewardErc20AmountPerNft), "ChimStaking: reward erc20 balance too low");
        return true;
    }

    function withdraw(uint256 stakeId_) external virtual nonReentrant whenNotPaused {
        require(checkBeforeWithdraw(_msgSender(), stakeId_), "");

        StakeData storage stakeData = _stakes[stakeId_];
        stakeData.closed = true;

        PlanData storage planData = _plans[stakeData.planId];
        planData.nftClosed += stakeData.nftCount;

        uint256 rewardErc20Amount = calculateReward(stakeData.nftCount, planData.rewardErc20AmountPerNft);

        IERC20Upgradeable(planData.rewardErc20Address).transfer(_msgSender(), rewardErc20Amount);
        IChimERC1155Upgradeable(_chimErc1155Address).safeBatchTransferFrom(address(this), _msgSender(), stakeData.nftIdList, stakeData.nftAmountList, "");

        emit StakeClosed(
            stakeId_,
            _msgSender(),
            stakeData.planId,
            stakeData.nftCount,
            stakeData.nftIdList,
            stakeData.nftAmountList,
            planData.rewardErc20Address,
            rewardErc20Amount
        );
    }

    function createPlan(
        string memory name_,
        uint256 nftLimit_,
        uint256 periodSec_,
        uint256 minNftStack_,
        uint256[] memory nftIdList_,
        address rewardErc20Address_,
        uint256 rewardErc20AmountPerNft_,
        bool paused
    ) external virtual onlyStakingAdmin {
        require(
            bytes(name_).length != 0
            && nftLimit_ != 0
            && periodSec_ != 0
            && minNftStack_ != 0
            && nftIdList_.length != 0
            && rewardErc20Address_ != address(0)
            && rewardErc20AmountPerNft_ != 0
        , "ChimStaking: invalid plan params");

        _planIdTracker.increment();
        uint256 planId = _planIdTracker.current();
        PlanData storage planData = _plans[planId];
        planData.name = name_;
        planData.nftLimit = nftLimit_;
        planData.periodSec = periodSec_;
        planData.minNftStack = minNftStack_;
        planData.nftIdList = nftIdList_;
        planData.rewardErc20Address = rewardErc20Address_;
        planData.rewardErc20AmountPerNft = rewardErc20AmountPerNft_;
        planData.paused = paused;
        for (uint256 i = 0; i < nftIdList_.length; ++i) {
            planData.nftIdMapping[nftIdList_[i]] = true;
        }

        emit PlanCreated(
            planId,
            name_,
            nftLimit_,
            periodSec_,
            minNftStack_,
            nftIdList_,
            rewardErc20Address_,
            rewardErc20AmountPerNft_,
            paused
        );
    }

    function pausePlan(uint256 planId_) external virtual onlyStakingAdmin {
        require(planId_ != 0 && planId_ <= getAllPlanCount(), "ChimStaking: invalid plan id");
        PlanData storage planData = _plans[planId_];
        planData.paused = true;
        emit PlanPaused(planId_);
    }

    function unpausePlan(uint256 planId_) external virtual onlyStakingAdmin {
        require(planId_ != 0 && planId_ <= getAllPlanCount(), "ChimStaking: invalid plan id");
        PlanData storage planData = _plans[planId_];
        planData.paused = false;
        emit PlanUnpaused(planId_);
    }

    function pause() external virtual onlyOwner {
        _pause();
    }

    function unpause() external virtual onlyOwner {
        _unpause();
    }

    function addToStakingAdminList(address account_) external virtual onlyOwner {
        _stakingAdminList[account_] = true;
        emit AddToStakingAdminList(account_);
    }

    function removeFromStakingAdminList(address account_) external virtual onlyOwner {
        _stakingAdminList[account_] = false;
        emit RemoveFromStakingAdminList(account_);
    }

    function withdrawAnyErc20(
        address erc20Address_,
        address recipient_,
        uint256 amount_
    ) external virtual onlyOwner {
        IERC20Upgradeable(erc20Address_).safeTransfer(recipient_, amount_);
    }

    function getErc20Symbol(address erc20Address_) internal view virtual returns (string memory) {
        return erc20Address_ != address(0) ? IERC20MetadataUpgradeable(erc20Address_).symbol() : "";
    }

    function getErc20Decimals(address erc20Address_) internal view virtual returns (uint8) {
        return erc20Address_ != address(0) ? IERC20MetadataUpgradeable(erc20Address_).decimals() : 0;
    }

    function calculateReward(uint256 nftCount, uint256 rewardPerNft) internal view virtual returns (uint256 reward) {
        return nftCount * rewardPerNft;
    }
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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library CountersUpgradeable {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;

import "./ERC1155ReceiverUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155HolderUpgradeable is Initializable, ERC1155ReceiverUpgradeable {
    function __ERC1155Holder_init() internal onlyInitializing {
    }

    function __ERC1155Holder_init_unchained() internal onlyInitializing {
    }
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
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

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";

interface IChimERC1155Upgradeable is IERC1155Upgradeable {
    // public read methods
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function owner() external view returns (address);
    function getOwner() external view returns (address);
    function paused() external view returns (bool);
    function royaltyParams() external view returns (address royaltyAddress, uint256 royaltyPercent);
    function royaltyInfo(uint256 tokenId, uint256 salePrice) external view returns (address receiver, uint256 royaltyAmount);
    function exists(uint256 tokenId) external view returns (bool);
    function uri(uint256 tokenId) external view returns (string memory);
    function totalSupply(uint256 tokenId) external view returns (uint256);
    function tokenInfo(uint256 tokenId) external view returns (uint256 tokenSupply, string memory tokenURI);
    function tokenInfoBatch(uint256[] memory tokenIds) external view returns (uint256[] memory batchTokenSupplies, string[] memory batchTokenURIs);
    function getBaseUri() external view returns (string memory);
    function isApprovedMinter(address minterAddress) external view returns (bool);

    // public write methods
    function burn(address account, uint256 tokenId, uint256 value) external;
    function burnBatch(address account, uint256[] memory tokenIds, uint256[] memory values) external;

    // minter write methods
    function setTokenURI(uint256 tokenId, string memory tokenURI) external;
    function mint(address to, uint256 tokenId, uint256 amount, bytes memory data) external;
    function mintBatch(address to, uint256[] memory tokenIds, uint256[] memory amounts, bytes memory data) external;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../IERC1155ReceiverUpgradeable.sol";
import "../../../utils/introspection/ERC165Upgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155ReceiverUpgradeable is Initializable, ERC165Upgradeable, IERC1155ReceiverUpgradeable {
    function __ERC1155Receiver_init() internal onlyInitializing {
    }

    function __ERC1155Receiver_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return interfaceId == type(IERC1155ReceiverUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}