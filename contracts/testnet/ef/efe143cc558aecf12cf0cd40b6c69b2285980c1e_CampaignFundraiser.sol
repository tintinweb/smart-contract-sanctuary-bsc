/**
 *Submitted for verification at BscScan.com on 2022-08-09
*/

/*
   ______                                         _
  / ____/  ____ _   ____ ___     ____   ____ _   (_)   ____ _   ____
 / /      / __ `/  / __ `__ \   / __ \ / __ `/  / /   / __ `/  / __ \
/ /___   / /_/ /  / / / / / /  / /_/ // /_/ /  / /   / /_/ /  / / / /
\____/   \__,_/  /_/ /_/ /_/  / .___/ \__,_/  /_/    \__, /  /_/ /_/
                             /_/                    /____/
    ______                       __                    _
   / ____/  __  __   ____   ____/ /   _____  ____ _   (_)   _____  ___    _____
  / /_     / / / /  / __ \ / __  /   / ___/ / __ `/  / /   / ___/ / _ \  / ___/
 / __/    / /_/ /  / / / // /_/ /   / /    / /_/ /  / /   (__  ) /  __/ / /
/_/       \__,_/  /_/ /_/ \__,_/   /_/     \__,_/  /_/   /____/  \___/ /_/

                            A contract by
                    Distributed Consensus Technologies

*/
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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

contract CampaignFundraiser is Ownable {

    address payable public feeReceiver;
    uint256 public campaignCost = 0;
    uint256 public collectionRoundCost = 0;

    uint256 public campaignFeesCollected = 0;
    uint256 public collectionFeesCollected = 0;

    uint256 nextCampaignID = 1;
    uint256 nextCollectionRoundID = 1;

    // address => campaignID => is admin
    mapping(address => mapping(uint256 => bool)) isAdmin;

    // address => campaignID => is owner
    mapping(address => mapping(uint256 => bool)) isOwner;

    // campaignID => item
    mapping(uint256 => address payable) public campaignReceiverWallet;
    mapping(uint256 => uint256) public campaignHardcap;
    mapping(uint256 => uint256) public campaignMaxContributionPerWallet;
    mapping(uint256 => bool) public campaignEnabled;
    mapping(uint256 => bool) public campaignFinalized;
    mapping(uint256 => address) public campaignToken;

    // campaignID => name
    mapping(uint256 => string) campaignName;

    // collectionRoundID => name
    mapping(uint256 => string) collectionRoundName;

    // owner => list of campaigns
    mapping(address => uint256[]) public ownerMapping;

    // campaignID => rounds
    mapping(uint256 => uint256[]) public campaignCollectionRounds;

    // collectionRoundID => campaignID
    mapping(uint256 => uint256) public campaignIDFromCollectionRoundID;

    // collectionRoundID => item
    mapping(uint256 => bool) public collectionRoundEnabled;
    mapping(uint256 => uint256) public collectionRoundDeadline;
    mapping(uint256 => uint256) public collectionRoundPeriod;
    mapping(uint256 => bool) public collectionRoundFinalized;
    mapping(uint256 => bool) public collectionRoundPrivate;

    // campaignID => address => whitelisted
    // This means that the will be automatically whitelisted in to any private collection rounds
    mapping(uint256 => mapping(address => bool)) public campaignWhitelist;

    // campaignID => address => blacklisted
    // This means that the will excluded from all collection rounds
    mapping(uint256 => mapping(address => bool)) public campaignBlacklist;

    // campaignID => address => exempt
    // This means that the will be exempt from campaign limits
    mapping(uint256 => mapping(address => bool)) public campaignLimitExempt;

    // campaignID => address => exempt
    // This means that the will be exempt from all collection round limits
    mapping(uint256 => mapping(address => bool)) public campaignCollectionRoundLimitExempt;

    // collectionRoundID => address => whitelisted
    mapping(uint256 => mapping(address => bool)) public collectionRoundWhitelist;

    // collectionRoundID => address => exempt
    mapping(uint256 => mapping(address => bool)) public collectionRoundLimitExempt;

    mapping(uint256 => uint256) public collectionRoundHardcap;
    mapping(uint256 => uint256) public collectionRoundMaxContributionPerWallet;
    mapping(uint256 => uint256) public collectionRoundMinContributionPerWallet;

    // collectionRoundID => value
    mapping(uint256 => uint256) public totalRaisedByCollectionRound;
    mapping(uint256 => uint256) public uniqueContributorsByCollectionRound;

    // campaignID => value
    mapping(uint256 => uint256) public totalRaisedByCampaign;
    mapping(uint256 => uint256) public uniqueContributorsByCampaignID;

    // Wallet => campaignID => value
    mapping(address => mapping(uint256 => uint256)) public totalContributedToCampaignByUser;

    // Wallet => collectionRoundID => value
    mapping(address => mapping(uint256 => uint256)) public totalContributedToCollectionRoundByUser;

    event CampaignCreated(uint256 indexed campaignID, address indexed creator, string name);
    event CampaignAdminAdded(uint256 indexed campaignID, address indexed newAdmin);
    event CampaignAdminRemoved(uint256 indexed campaignID, address indexed removedAdmin);

    event CampaignDisabled(uint256 indexed campaignID);
    event CampaignEnabled(uint256 indexed campaignID);
    event CampaignFinalized(uint256 indexed campaignID);

    event CollectionRoundCreated(uint256 indexed campaignID, uint256 indexed collectionRoundID, string name, bool isPrivate);
    event CollectionRoundEnabled(uint256 indexed campaignID, uint256 indexed collectionRoundID);
    event CollectionRoundDisabled(uint256 indexed campaignID, uint256 indexed collectionRoundID);
    event CollectionRoundFinalized(uint256 indexed campaignID, uint256 indexed collectionRoundID);
    event CollectionRoundPrivacySet(uint256 indexed campaignID, uint256 indexed collectionRoundID, bool isPrivate);
    event CollectionRoundHardcapSet(uint256 indexed campaignID, uint256 indexed collectionRoundID, uint256 hardcap);
    event CollectionRoundContributionLimitsPerWalletSet(uint256 indexed campaignID, uint256 indexed collectionRoundID, uint256 minContributionPerWallet, uint256 maxContributionPerWallet);

    event CampaignReceiverSet(uint256 indexed campaignID, address receiver);
    event CampaignHardcapSet(uint256 indexed campaignID, uint256 hardcap);
    event CampaignMaxContributionPerWalletSet(uint256 indexed campaignID, uint256 hardcap);

    event FundsCollected(uint256 indexed campaignID, uint256 indexed collectionRoundID, address contributor, uint256 amount);

    modifier isCampaignAdmin(uint256 campaignID) {
        require(isAdmin[msg.sender][campaignID], "Not authorized");
        _;
    }

    modifier isCampaignOwner(uint256 campaignID) {
        require(isOwner[msg.sender][campaignID], "Not authorized");
        _;
    }

    modifier isCollectionRoundAdmin(uint256 collectionRoundID) {
        uint256 campaignID = campaignIDFromCollectionRoundID[collectionRoundID];
        require(isAdmin[msg.sender][campaignID], "Not authorized");
        _;
    }

    modifier checkCampaignMutable(uint256 campaignID) {
        _checkCanModifyCampaign(campaignID);
        _;
    }

    modifier checkCollectionRoundMutable(uint256 collectionRoundID) {
        _checkCanModifyCollectionRound(collectionRoundID);
        _;
    }

    modifier checkCollectionRoundEnabled(uint256 collectionRoundID) {
        _checkCollectionRoundEnabled(collectionRoundID);
        _;
    }

    constructor (
        address _feeReceiver
    ) {
        feeReceiver = payable(_feeReceiver);
    }

    function setCampaignCost(uint256 _campaignCost) external onlyOwner {
        campaignCost = _campaignCost;
    }

    function setCollectionRoundCost(uint256 _collectionRoundCost) external onlyOwner {
        collectionRoundCost = _collectionRoundCost;
    }

    function setFeeReceiver(address _feeReceiver) external onlyOwner {
        feeReceiver = payable(_feeReceiver);
    }

    function createCampaign(
        string memory name,
        address receiverWallet,
        uint256 hardcap,
        uint256 maxContributionPerWallet,
        address token   // Set to zero address or WETH address for collections in native tokens
    )
        external
        payable
        returns (uint256 campaignID)
    {
        _checkAndCollectCampaignFee();

        campaignID = _getNextCampaignID();

        isAdmin[msg.sender][campaignID] = true;
        isOwner[msg.sender][campaignID] = true;

        campaignReceiverWallet[campaignID] = payable(receiverWallet);
        campaignMaxContributionPerWallet[campaignID] = maxContributionPerWallet;
        campaignHardcap[campaignID] = hardcap;
        campaignToken[campaignID] = token;

        campaignEnabled[campaignID] = true;
        campaignName[campaignID] = name;

        emit CampaignCreated(campaignID, msg.sender, name);

        emit CampaignHardcapSet(campaignID, hardcap);
        emit CampaignMaxContributionPerWalletSet(campaignID, maxContributionPerWallet);
        emit CampaignAdminAdded(campaignID, msg.sender);

        return campaignID;
    }

    function createCollectionRound(
        uint256 campaignID,
        uint256 deadline,                 // max timestamp to receive
        uint256 period,                   // length of time to set collection
        uint256 hardcap,                  // max for collection
        uint256 maxContributionPerWallet, // max contribution per wallet
        uint256 minContributionPerWallet, // min contribution per wallet
        bool startEnabled,                // whether the round is immediately open
        bool isPrivate,                   // whether it is a private round
        string memory name                // the name of this round
    )
        external
        payable
        isCampaignAdmin(campaignID)
        checkCampaignMutable(campaignID)
        returns (uint256 collectionRoundID)
    {
        // Check validity and auth
        require(campaignID < nextCampaignID, "Invalid campaignID");
        require(!campaignFinalized[campaignID], "Campaign already Finalized");

        // check
        require((deadline == 0 && period == 0) || (deadline != 0 && period == 0) || (deadline == 0 && period != 0), "Deadline and Period cannot both be specified");
        require(maxContributionPerWallet <= campaignMaxContributionPerWallet[campaignID], "Collection Round Max Contribution higher than Campaign Max Contribution");

        _checkAndCollectCollectionRoundFee();

        collectionRoundID = _getNextCollectionRoundID();

        campaignCollectionRounds[campaignID].push(collectionRoundID);
        campaignIDFromCollectionRoundID[collectionRoundID] = campaignID;

        collectionRoundHardcap[collectionRoundID] = hardcap;
        collectionRoundMaxContributionPerWallet[collectionRoundID] = maxContributionPerWallet;
        collectionRoundMinContributionPerWallet[collectionRoundID] = minContributionPerWallet;
        collectionRoundDeadline[collectionRoundID] = deadline;
        collectionRoundPeriod[collectionRoundID] = period;
        collectionRoundPrivate[collectionRoundID] = isPrivate;

        collectionRoundName[collectionRoundID] = name;

        emit CollectionRoundCreated(campaignID, collectionRoundID, name, isPrivate);

        if (startEnabled) {
            collectionRoundEnabled[collectionRoundID] = true;

            if (deadline == 0 && period != 0) {
                collectionRoundDeadline[collectionRoundID] = block.timestamp + period;
            }
            emit CollectionRoundEnabled(campaignID, collectionRoundID);
        }
    }

    function enableCollectionRound(
        uint256 collectionRoundID
    )
        external
        isCollectionRoundAdmin(collectionRoundID)
        checkCollectionRoundMutable(collectionRoundID)
    {
        require(!collectionRoundEnabled[collectionRoundID], "Collection Round already enabled");
        uint256 campaignID = campaignIDFromCollectionRoundID[collectionRoundID];

        collectionRoundEnabled[collectionRoundID] = true;

        if (collectionRoundDeadline[collectionRoundID] == 0 && collectionRoundPeriod[collectionRoundID] != 0) {
            collectionRoundDeadline[collectionRoundID] = block.timestamp + collectionRoundPeriod[collectionRoundID];
        }
        emit CollectionRoundEnabled(campaignID, collectionRoundID);
    }

    function disableCollectionRound(
        uint256 collectionRoundID
    )
        external
        isCollectionRoundAdmin(collectionRoundID)
        checkCollectionRoundMutable(collectionRoundID)
    {
        uint256 campaignID = campaignIDFromCollectionRoundID[collectionRoundID];
        require(collectionRoundEnabled[collectionRoundID], "Collection Round already disabled");

        collectionRoundEnabled[collectionRoundID] = false;

        emit CollectionRoundDisabled(campaignID, collectionRoundID);
    }

    function setCollectionRoundPrivacy(
        uint256 collectionRoundID,
        bool isPrivate
    )
        external
        isCollectionRoundAdmin(collectionRoundID)
        checkCollectionRoundMutable(collectionRoundID)
    {
        require(isPrivate = !collectionRoundPrivate[collectionRoundID], "Collection Round already conforms to privacy setting");

        uint256 campaignID = campaignIDFromCollectionRoundID[collectionRoundID];
        collectionRoundPrivate[collectionRoundID] = isPrivate;
        emit CollectionRoundPrivacySet(campaignID, collectionRoundID, isPrivate);
    }

    function addToWhitelistForCollectionRound(
        uint256 collectionRoundID,
        address[] calldata addressesToAdd
    )
        external
        isCollectionRoundAdmin(collectionRoundID)
        checkCollectionRoundMutable(collectionRoundID)
    {
        for (uint16 i = 0; i < addressesToAdd.length; i++) {
            collectionRoundWhitelist[collectionRoundID][addressesToAdd[i]] = true;
        }
    }

    function removeFromWhitelistForCollectionRound(
        uint256 collectionRoundID,
        address[] calldata addressesToRemove
    )
        external
        isCollectionRoundAdmin(collectionRoundID)
        checkCollectionRoundMutable(collectionRoundID)
    {
        for (uint i = 0; i < addressesToRemove.length; i++) {
            collectionRoundWhitelist[collectionRoundID][addressesToRemove[i]] = false;
        }
    }

    function addToLimitExemptForCollectionRound(
        uint256 collectionRoundID,
        address[] calldata addressesToAdd
    )
        external
        isCollectionRoundAdmin(collectionRoundID)
        checkCollectionRoundMutable(collectionRoundID)
    {
        for (uint16 i = 0; i < addressesToAdd.length; i++) {
            collectionRoundLimitExempt[collectionRoundID][addressesToAdd[i]] = true;
        }
    }

    function removeFromLimitExemptCollectionRound(
        uint256 collectionRoundID,
        address[] calldata addressesToRemove
    )
        external
        isCollectionRoundAdmin(collectionRoundID)
        checkCollectionRoundMutable(collectionRoundID)
    {
        for (uint i = 0; i < addressesToRemove.length; i++) {
            collectionRoundLimitExempt[collectionRoundID][addressesToRemove[i]] = false;
        }
    }

    function addToCampaignLimitExempt(
        uint256 campaignID,
        address[] calldata addressesToAdd
    )
        external
        isCampaignAdmin(campaignID)
        checkCampaignMutable(campaignID)
    {
        for (uint16 i = 0; i < addressesToAdd.length; i++) {
            campaignLimitExempt[campaignID][addressesToAdd[i]] = true;
        }
    }

    function removeFromCampaignLimitExempt(
        uint256 campaignID,
        address[] calldata addressesToRemove
    )
        external
        isCampaignAdmin(campaignID)
        checkCampaignMutable(campaignID)
    {
        for (uint i = 0; i < addressesToRemove.length; i++) {
            campaignLimitExempt[campaignID][addressesToRemove[i]] = false;
        }
    }

    function addToCampaignBlacklist(
        uint256 campaignID,
        address[] calldata addressesToAdd
    )
        external
        isCampaignAdmin(campaignID)
        checkCampaignMutable(campaignID)
    {
        for (uint16 i = 0; i < addressesToAdd.length; i++) {
            campaignBlacklist[campaignID][addressesToAdd[i]] = true;
        }
    }

    function removeFromCampaignBlacklist(
        uint256 campaignID,
        address[] calldata addressesToRemove
    )
        external
        isCampaignAdmin(campaignID)
        checkCampaignMutable(campaignID)
    {
        for (uint i = 0; i < addressesToRemove.length; i++) {
            campaignBlacklist[campaignID][addressesToRemove[i]] = false;
        }
    }

    function addToCampaignCollectionROundLimitExempt(
        uint256 campaignID,
        address[] calldata addressesToAdd
    )
        external
        isCampaignAdmin(campaignID)
        checkCampaignMutable(campaignID)
    {
        for (uint16 i = 0; i < addressesToAdd.length; i++) {
            campaignCollectionRoundLimitExempt[campaignID][addressesToAdd[i]] = true;
        }
    }

    function removeFromCampaignCollectionRoundLimitExempt(
        uint256 campaignID,
        address[] calldata addressesToRemove
    )
        external
        isCampaignAdmin(campaignID)
        checkCampaignMutable(campaignID)
    {
        for (uint i = 0; i < addressesToRemove.length; i++) {
            campaignCollectionRoundLimitExempt[campaignID][addressesToRemove[i]] = false;
        }
    }

    function addToWhitelistForCampaign(
        uint256 campaignID,
        address[] calldata addressesToAdd
    )
        external
        isCampaignAdmin(campaignID)
        checkCampaignMutable(campaignID)
    {
        for (uint16 i = 0; i < addressesToAdd.length; i++) {
            campaignWhitelist[campaignID][addressesToAdd[i]] = true;
        }
    }

    function removeFromWhitelistForCampaign(
        uint256 campaignID,
        address[] calldata addressesToRemove
    )
        external
        isCampaignAdmin(campaignID)
        checkCampaignMutable(campaignID)
    {
        for (uint i = 0; i < addressesToRemove.length; i++) {
            campaignWhitelist[campaignID][addressesToRemove[i]] = false;
        }
    }

    function disableCampaign(
        uint256 campaignID
    )
        external
        isCampaignAdmin(campaignID)
        checkCampaignMutable(campaignID)
    {
        require(campaignEnabled[campaignID], "Campaign already disabled");
        campaignEnabled[campaignID] = false;
        emit CampaignDisabled(campaignID);
    }

    function enableCampaign(
        uint256 campaignID
    )
        external
        isCampaignAdmin(campaignID)
        checkCampaignMutable(campaignID)
    {
        require(!campaignEnabled[campaignID], "Campaign already enabled");
        campaignEnabled[campaignID] = false;
        emit CampaignEnabled(campaignID);
    }

    function finalizeCollectionRound(
        uint256 collectionRoundID
    )
        external
        isCollectionRoundAdmin(collectionRoundID)
    {
        uint256 campaignID = campaignIDFromCollectionRoundID[collectionRoundID];
        require(!collectionRoundFinalized[collectionRoundID], "Colelction Round already finalized");

        collectionRoundFinalized[collectionRoundID] = true;

        emit CollectionRoundFinalized(campaignID, collectionRoundID);
    }

    function finalizeCampaign(
        uint256 campaignID
    )
        external
        isCampaignOwner(campaignID)
    {
        require(!campaignFinalized[campaignID], "Campaign already Finalized");

        if (campaignEnabled[campaignID]) {
            campaignEnabled[campaignID] = false;
            emit CampaignDisabled(campaignID);
        }

        campaignFinalized[campaignID] = true;

        uint256[] memory collectionRounds = campaignCollectionRounds[campaignID];

        uint256 collectionRoundID;

        for (uint16 i=0; i <= collectionRounds.length; i++) {
            collectionRoundID = collectionRounds[i];
            if (collectionRoundEnabled[collectionRoundID]) {
                collectionRoundEnabled[collectionRoundID] = false;
                emit CollectionRoundDisabled(campaignID, collectionRoundID);
            }

            if (!collectionRoundFinalized[collectionRoundID]) {
                collectionRoundFinalized[collectionRoundID] = true;
                emit CollectionRoundFinalized(campaignID, collectionRoundID);
            }
        }

        emit CampaignFinalized(campaignID);
    }

    function setCampaignReceiver(
        uint256 campaignID,
        address receiver
    )
        external
        isCampaignAdmin(campaignID)
        checkCampaignMutable(campaignID)
    {
        campaignReceiverWallet[campaignID] = payable(receiver);
        emit CampaignReceiverSet(campaignID, receiver);
    }

    function setCampaignHardcap(
        uint256 campaignID,
        uint256 hardcap
    )
        external
        isCampaignAdmin(campaignID)
        checkCampaignMutable(campaignID)
    {
        require(hardcap > campaignHardcap[campaignID], "Cannot reduce campaign hardcap");
        campaignHardcap[campaignID] = hardcap;
        emit CampaignHardcapSet(campaignID, hardcap);
    }

    function setCollectionRoundHardcap(
        uint256 collectionRoundID,
        uint256 hardcap
    )
        external
        isCollectionRoundAdmin(collectionRoundID)
        checkCollectionRoundMutable(collectionRoundID)
    {
        require(hardcap > collectionRoundHardcap[collectionRoundID], "Cannot reduce collection round hardcap");

        uint256 campaignID = campaignIDFromCollectionRoundID[collectionRoundID];
        collectionRoundHardcap[collectionRoundID] = hardcap;
        emit CollectionRoundHardcapSet(campaignID, collectionRoundID, hardcap);
    }

    function setCampaignMaxContributionPerWallet(
        uint256 campaignID,
        uint256 maxContributionPerWallet
    )
        external
        isCampaignAdmin(campaignID)
        checkCampaignMutable(campaignID)
    {
        require(maxContributionPerWallet > campaignMaxContributionPerWallet[campaignID], "Cannot reduce campaign max contribution per wallet");
        campaignMaxContributionPerWallet[campaignID] = maxContributionPerWallet;
        emit CampaignMaxContributionPerWalletSet(campaignID, maxContributionPerWallet);
    }

    function setCollectionRoundMinMaxContributionPerWallet(
        uint256 collectionRoundID,
        uint256 minContributionPerWallet,
        uint256 maxContributionPerWallet
    )
        external
        isCollectionRoundAdmin(collectionRoundID)
        checkCollectionRoundMutable(collectionRoundID)
    {
        require(maxContributionPerWallet > collectionRoundMaxContributionPerWallet[collectionRoundID], "Cannot reduce max contribution per wallet");
        require(minContributionPerWallet < collectionRoundMinContributionPerWallet[collectionRoundID], "Cannot increase min contribution per wallet");

        uint256 campaignID = campaignIDFromCollectionRoundID[collectionRoundID];
        collectionRoundMaxContributionPerWallet[collectionRoundID] = maxContributionPerWallet;
        collectionRoundMinContributionPerWallet[collectionRoundID] = minContributionPerWallet;
        emit CollectionRoundContributionLimitsPerWalletSet(campaignID, collectionRoundID, minContributionPerWallet, maxContributionPerWallet);
    }

    function addCampaignAdmin(
        uint256 campaignID,
        address admin
    )
        external
        isCampaignOwner(campaignID)
        checkCampaignMutable(campaignID)
    {
        isAdmin[admin][campaignID] = true;
        emit CampaignAdminAdded(campaignID, admin);
    }

    function removeCampaignAdmin(
        uint256 campaignID,
        address admin
    )
        external
        isCampaignOwner(campaignID)
        checkCampaignMutable(campaignID)
    {
        isAdmin[admin][campaignID] = false;
        emit CampaignAdminRemoved(campaignID, admin);
    }

    function contributeETHToCollectionRound(
        uint256 collectionRoundID
    )
        external
        payable
        checkCollectionRoundMutable(collectionRoundID)
        checkCollectionRoundEnabled(collectionRoundID)
    {
        uint256 campaignID = campaignIDFromCollectionRoundID[collectionRoundID];

        require(
            campaignToken[campaignID] == address(0),
            "If campaign token is not the native token, call contributeTokensToCollectionRound"
        );

        _contributeTokensToCollectionRound(
            collectionRoundID,
            msg.value
        );

        (bool success, ) = payable(campaignReceiverWallet[campaignID]).call{value: msg.value}("");
        require(success, "Transfer to campaign receiver wallet failed");

        emit FundsCollected(campaignID, collectionRoundID, msg.sender, msg.value);
    }

    function contributeTokensToCollectionRound(
        uint256 collectionRoundID,
        uint256 amount
    )
        external
        checkCollectionRoundMutable(collectionRoundID)
        checkCollectionRoundEnabled(collectionRoundID)
    {
        uint256 campaignID = campaignIDFromCollectionRoundID[collectionRoundID];

        _contributeTokensToCollectionRound(
            collectionRoundID,
            amount
        );

        IERC20(campaignToken[campaignID]).transferFrom(
            msg.sender,
            campaignReceiverWallet[campaignID],
            amount
        );

        emit FundsCollected(campaignID, collectionRoundID, msg.sender, amount);

    }

    function _contributeTokensToCollectionRound(
        uint256 collectionRoundID,
        uint256 amount
    ) internal {
        require(amount > 0, "Must send value when calling contributeToCollectionRound");

        uint256 campaignID = campaignIDFromCollectionRoundID[collectionRoundID];

        require(!campaignBlacklist[campaignID][msg.sender], "Cannot contribute to this campaign");
        uint256 totalRaised = totalRaisedByCampaign[campaignID];
        uint256 totalCollectionRaised = totalRaisedByCollectionRound[collectionRoundID];

        uint256 campaignUserTotal = totalContributedToCampaignByUser[msg.sender][campaignID];
        uint256 collectionRoundUserTotal = totalContributedToCollectionRoundByUser[msg.sender][collectionRoundID];

        if (collectionRoundPrivate[collectionRoundID]) {
            require(collectionRoundWhitelist[collectionRoundID][msg.sender], "Contributor not in whitelist");
        }

        if (
            !collectionRoundLimitExempt[collectionRoundID][msg.sender]
            && !campaignCollectionRoundLimitExempt[campaignID][msg.sender]
        ) {
            if (collectionRoundDeadline[collectionRoundID] != 0) {
                require(block.timestamp <= collectionRoundDeadline[collectionRoundID], "Collection Round is over");
            }
            // Check collection round hardcap and max wallet contributions
            require(totalCollectionRaised + amount <= collectionRoundHardcap[collectionRoundID], "Contribution exceeds collection round hardcap");
            require(collectionRoundUserTotal + amount <= collectionRoundMaxContributionPerWallet[collectionRoundID], "Contribution exceeds collection round max contribution per wallet");
            require(collectionRoundUserTotal + amount >= collectionRoundMinContributionPerWallet[collectionRoundID], "Contribution does not exceed collection round min contribution per wallet");
        }

        if (!campaignLimitExempt[campaignID][msg.sender]) {
            // Check campaign hardcap and max wallet contributions
            require(totalRaised + amount <= campaignHardcap[campaignID], "Contribution exceeds campaign hardcap");
            require(campaignUserTotal + amount <= campaignMaxContributionPerWallet[campaignID], "Contribution exceeds campaign max contribution per wallet");
        }

        if (totalContributedToCampaignByUser[msg.sender][campaignID] == 0) {
            uniqueContributorsByCampaignID[campaignID] += 1;
        }

        if (totalContributedToCollectionRoundByUser[msg.sender][collectionRoundID] == 0) {
            uniqueContributorsByCollectionRound[collectionRoundID] += 1;
        }

        totalContributedToCampaignByUser[msg.sender][campaignID] += amount;
        totalContributedToCollectionRoundByUser[msg.sender][collectionRoundID] += amount;
        totalRaisedByCampaign[campaignID] += amount;
        totalRaisedByCollectionRound[collectionRoundID] += amount;
    }

    function campaignInfo(uint256 campaignID) external view returns (
        string memory name,
        uint256 hardcap,
        uint256 maxContributionPerWallet,
        uint256[] memory collectionRoundIDs,
        address receiverWallet,
        bool isEnabled,
        bool isFinalized,
        uint256 totalRaised,
        uint256 uniqueContributors
    ) {
        name = campaignName[campaignID];
        collectionRoundIDs = campaignCollectionRounds[campaignID];
        hardcap = campaignHardcap[campaignID];
        maxContributionPerWallet = campaignMaxContributionPerWallet[campaignID];
        receiverWallet = campaignReceiverWallet[campaignID];
        isEnabled = campaignEnabled[campaignID];
        isFinalized = campaignFinalized[campaignID];
        totalRaised = totalRaisedByCampaign[campaignID];
        uniqueContributors = uniqueContributorsByCampaignID[campaignID];
    }

    function collectionRoundInfo(uint256 collectionRoundID) external view returns (
        uint256 campaignID,
        string memory name,
        uint256 hardcap,
        uint256 maxContributionPerWallet,
        bool isPrivate,
        bool isEnabled,
        bool isFinalized,
        uint256 totalRaised,
        uint256 uniqueContributors
    ) {
        campaignID = campaignIDFromCollectionRoundID[collectionRoundID];
        name = collectionRoundName[collectionRoundID];
        hardcap = collectionRoundHardcap[collectionRoundID];
        maxContributionPerWallet = collectionRoundMaxContributionPerWallet[collectionRoundID];
        isPrivate = collectionRoundPrivate[collectionRoundID];
        isEnabled = collectionRoundEnabled[collectionRoundID];
        isFinalized = collectionRoundFinalized[collectionRoundID];
        totalRaised = totalRaisedByCollectionRound[collectionRoundID];
        uniqueContributors = uniqueContributorsByCollectionRound[collectionRoundID];
    }

    function campaignCountByOwner(address owner) external view returns (uint256) {
        return ownerMapping[owner].length;
    }

    function campaignIDsByOwner(address owner, uint256 index, uint256 count) external view returns (uint256[] memory) {
        uint256[] memory campaignIDs = ownerMapping[owner];
        require(count > 0, "count must be greater than 0");
        require(index+count <= campaignIDs.length, "Requested more campaign IDs than exist");

        uint256[] memory result = new uint256[](count);

        for (uint256 i=index; i < index + count; i++) {
            result[i-index] = campaignIDs[i];
        }
        return result;
    }

    function collectionRoundCountByCampaignID(uint256 campaignID) external view returns (uint256) {
        return campaignCollectionRounds[campaignID].length;
    }

    function collectionRoundIDsByCampaignID(uint256 campaignID, uint256 index, uint256 count) external view returns (uint256[] memory) {
        uint256[] memory collectionRounds = campaignCollectionRounds[campaignID];
        require(count > 0, "count must be greater than 0");
        require(index+count <= collectionRounds.length, "Requested more campaign IDs than exist");

        uint256[] memory result = new uint256[](count);

        for (uint256 i=index; i < index + count; i++) {
            result[i-index] = collectionRounds[i];
        }
        return result;
    }

    function withdrawBalance() external onlyOwner {
        (bool success, ) = feeReceiver.call{value: address(this).balance}("");
        require(success);
    }

    function withdrawTokenBalance(address tokenAddress) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        token.transfer(feeReceiver, token.balanceOf(address(this)));
    }

    function _checkAndCollectCampaignFee() internal {
        if (campaignCost == 0) {
            return;
        }

        require(msg.value >= campaignCost, "Campaign fee not paid");
        campaignFeesCollected += campaignCost;

        if (msg.value > campaignCost) {
            // Refund creator
            (bool success, ) = msg.sender.call{value: msg.value - campaignCost}("");
            require(success);
        }
    }

    function _checkAndCollectCollectionRoundFee() internal {
        if (collectionRoundCost == 0) {
            return;
        }

        require(msg.value >= collectionRoundCost, "Collection round fee not paid");
        collectionFeesCollected += collectionRoundCost;

        if (msg.value > collectionRoundCost) {
            // Refund creator
            (bool success, ) = msg.sender.call{value: msg.value - collectionRoundCost}("");
            require(success);
        }
    }

    function _getNextCampaignID() internal returns (uint256 campaignID) {
        campaignID = nextCampaignID;
        nextCampaignID += 1;
    }

    function _getNextCollectionRoundID() internal returns (uint256 collectionRoundID) {
        collectionRoundID = nextCollectionRoundID;
        nextCollectionRoundID += 1;
    }

    function _checkCanModifyCollectionRound(uint256 collectionRoundID) internal view {
        uint256 campaignID = campaignIDFromCollectionRoundID[collectionRoundID];
        require(!campaignFinalized[campaignID], "Campaign already finalized");
        require(!collectionRoundFinalized[collectionRoundID], "Collection round already finalized");
    }

    function _checkCanModifyCampaign(uint256 campaignID) internal view {
        require(!campaignFinalized[campaignID], "Campaign already finalized");
    }

    function _checkCollectionRoundEnabled(uint256 collectionRoundID) internal view {
        uint256 campaignID = campaignIDFromCollectionRoundID[collectionRoundID];
        require(campaignEnabled[campaignID], "Campaign disabled");
        require(collectionRoundEnabled[collectionRoundID], "Collection round disabled");
    }

}