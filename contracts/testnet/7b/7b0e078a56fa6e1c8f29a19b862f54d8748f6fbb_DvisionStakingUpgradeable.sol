// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155ReceiverUpgradeable.sol";

import "./interfaces/IDvisionMysteryBox.sol";

// @title  Main contract for Dvision Staking.
// @author sotatek.eth
// @notice User will stake NFT Land in Dvision Networks to earn Random Box NFT. There are 7
//         kinds of NFT Land: from 1x1, 1x1 Premium... to 3x3. About Random Box, the rewards
//         will be splited into Random Box (7 types) and Random Building Box (2 types).
// @notice There are 7 types of staking tokens:
//         [1] Land 1x1
//         [2] Land 1x1 Premium
//         [3] Land 2x1
//         [4] Land 2x1 Premium
//         [5] Land 2x2
//         [6] Land 2x2 Premium
//         [7] Land 3x3
// @notice There are 2 kinds of rewards:
//         I. Random Box Types [7 types]
//          [1] Random Box A 1x1
//          [2] Random Box B 1x1 Premium
//          [3] Random Box C 2x1
//          [4] Random Box D 2x1 Premium
//          [5] Random Box E 2x2
//          [6] Random Box F 2x2 Premium
//          [7] Random Box G 3x3
//         II. Random Building Box Types [2 types]
//          [8] Building Box A: 2~4 Level
//          [9] Building Box B: 3~6 Level

contract DvisionStakingUpgradeable is
    Initializable,
    AccessControlUpgradeable,
    IERC721ReceiverUpgradeable,
    IERC1155ReceiverUpgradeable,
    ReentrancyGuardUpgradeable
{
    // @notice OpenZeppelin's Math library is used for all compare operations.
    using MathUpgradeable for uint256;

    /* ********** */
    /* DATA TYPES */
    /* ********** */

    // @notice The main Campaign struct. The struct fits in six 256-bits words due
    //         to Solidity's rules for struct packing.
    struct Campaign {
        // The amount of time (measured in seconds) that can elapse before the
        // staking reward calculator start working. When campaign launched, user can not
        // stake more.
        uint256 duration;
        // The block.timestamp when the campaign began (measured in seconds).
        uint256 campaignStartTime;
        // The block.timestamp when the campaign finished (measured in seconds).
        uint256 campaignEndTime;
    }

    // @notice The main CampaignReward struct. The struct fits in six 256-bits words due to
    //         Solidity's rules for struct packing.
    struct CampaignReward {
        // The Random Box Types.
        uint256 boxType;
        // The amount of Random Box Types reward.
        uint256 boxAmount;
        // The Random Building Box Types.
        uint256 buildingBoxType;
        // The amount of Random Building Box Types reward.
        uint256 buildingBoxAmount;
    }

    // @notice The main Deposit/Withdraw Params struct. The struct fits in six 256-bits
    //         words due to Solidity's rules for struct packing.
    struct Params {
        uint256[] erc721TokenIds;
        uint256[] erc1155TokenIds;
        uint256[] erc1155Amounts;
    }

    /* ****** */
    /* EVENTS */
    /* ****** */

    /// @notice This event is fired whenever an user deposit a NFT Land by calling
    ///         deposit(). The amount of events depend on total token ID of ERC721 and
    ///         ERC1155 Land were deposited.
    /// @param  user - The address of staker.
    /// @param  campaignId - A unique identifier for this particular campaign. There are 3
    ///         campaign represent for 3 kinds of duration: 30, 60 and 90 days.
    /// @param  stakingToken - The NFT Land address
    /// @param  tokenId - The ID within the NFTLandContract for NFT being used as item to
    ///         stake. The NFT is stored within this contract during the duration of the
    ///         campaign.
    /// @param  amount - The amount of a particular NFT Land TokenID was deposited into this
    ///         contract.
    event Deposited(
        address indexed user,
        uint8 indexed campaignId,
        address indexed stakingToken,
        uint256 tokenId,
        uint256 amount
    );

    /// @notice This event is fired whenever an user withdraw a NFT Land by calling
    ///         withdraw(). The amount of events depend on total token IDs of ERC721 and
    ///         ERC1155 Land were withdrawn.
    /// @param  user - The address of staker.
    /// @param  campaignId - A unique identifier for this particular campaign. There
    ///         are 3 campaign represent for 3 kinds of duration: 30, 60 and 90 days.
    /// @param  stakingToken - The NFT Land address
    /// @param  tokenId - The ID within the NFTLandContract for NFT being used as item
    ///         to stake. The NFT is stored within this contract during the duration of
    ///         the campaign.
    /// @param  amount - The amount of a particular NFT Land TokenID was withdrawn from this
    ///         contract.
    event Withdrawn(
        address indexed user,
        uint8 indexed campaignId,
        address indexed stakingToken,
        uint256 tokenId,
        uint256 amount
    );

    /// @notice This event is fired whenever an user claim their reward by calling
    ///         claimReward(). User uses the data and signature signed by Admin and call
    ///         function through a Proxy contract to verify the signature.
    /// @param  user - The address of staker.
    /// @param  campaignId - An unique identifier for this particular campaign. There are 3
    ///         campaign represent for 3 kinds of duration: 30, 60 and 90 days.
    /// @param  boxTypes - The list of random box types.
    /// @param  boxAmounts - The list of random box amounts.
    event ClaimedReward(
        address indexed user,
        uint8 indexed campaignId,
        uint256[] boxTypes,
        uint256[] boxAmounts
    );

    /// @notice This event is fired whenever campaign was setup to begin.
    /// @param  campaignId - An unique identifier for this particular campaign. There are 3
    ///         campaign represent for 3 kinds of duration: 30, 60 and 90 days.
    /// @param  campaignStartTime - The timestamp that the campaign duration will be
    ///         started.
    /// @param  duration - The total time that the user's NFT Land will be locked (measured
    ///         in seconds).
    event CampaignLaunched(
        uint8 indexed campaignId,
        uint256 campaignStartTime,
        uint256 duration
    );

    /// @notice This event is fired whenever all campaign allows user withdraw in duration
    ///         flag turn on/off.
    /// @param  allow - Allow or not.
    event AllowedWithdraw(bool allow);

    /// @notice This event is fired whenever a proxy address being set.
    /// @param  newProxy - The proxy address.
    event SetNewProxy(address newProxy);

    /* ******* */
    /* STORAGE */
    /* ******* */

    /// @notice
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    /// @notice
    IERC721Upgradeable public ERC721_STAKING_TOKEN;

    /// @notice
    IERC1155Upgradeable public ERC1155_STAKING_TOKEN;

    /// @notice
    IDvisionMysteryBox public REWARD_BOX;

    /// @notice
    address PROXY;

    /// @notice Info of each campaign.
    mapping(uint8 => Campaign) public campaignInfo;

    /// @notice User staking amount by Token ID. With ERC721, it's always 1.
    ///         (campaignId + userAddress + stakingToken + tokenId)
    mapping(uint8 => mapping(address => mapping(address => mapping(uint256 => uint256))))
        public userBalanceByTokenId;

    /// @notice EMERGENCY CASE: Permission to withdraw while the campaign is in
    ///         progress
    bool public isAllowWithdraw;

    /* *********** */
    /* INITIALIZER */
    /* *********** */

    /**
     * @dev   This function is called by the deployer when they deploy this contract.
     * @param _erc721Token - The ERC721 NFT Land address
     * @param _erc1155Token - The ERC1155 NFT Land address
     * @param _rewardBox - The NFT Random Box address
     */
    function initialize(
        address _erc721Token,
        address _erc1155Token,
        address _rewardBox
    ) external initializer {
        __AccessControl_init_unchained();
        __ReentrancyGuard_init_unchained();
        // Set admin role
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MANAGER_ROLE, msg.sender);

        ERC721_STAKING_TOKEN = IERC721Upgradeable(_erc721Token);
        ERC1155_STAKING_TOKEN = IERC1155Upgradeable(_erc1155Token);
        REWARD_BOX = IDvisionMysteryBox(_rewardBox);

        campaignInfo[1].duration = 30 days;
        campaignInfo[2].duration = 60 days;
        campaignInfo[3].duration = 90 days;
    }

    /* ********* */
    /* MODIFIERS */
    /* ********* */

    modifier notProcessing(uint8 campaignId) {
        require(
            block.timestamp < campaignInfo[campaignId].campaignStartTime ||
                block.timestamp >= campaignInfo[campaignId].campaignEndTime,
            "campaign is running"
        );
        _;
    }

    modifier allowWithdraw(uint8 campaignId) {
        require(
            isAllowWithdraw ||
                block.timestamp < campaignInfo[campaignId].campaignStartTime ||
                block.timestamp >= campaignInfo[campaignId].campaignEndTime,
            "cannot withdraw"
        );
        _;
    }

    modifier onlyProxy() {
        require(msg.sender == PROXY, "only proxy");
        _;
    }

    /* ********* */
    /* FUNCTIONS */
    /* ********* */

    /**
     * @dev   This function is called by the user when thay want to deposit their NFT Lands
     *        into this contract to earn rewards.
     * @param campaignId - An unique identifier for this particular campaign. There are 3
     *        campaign represent for 3 kinds of duration: 30, 60 and 90 days.
     * @param params aa
     */
    function deposit(uint8 campaignId, Params calldata params)
        external
        nonReentrant
        notProcessing(campaignId)
    {
        require(
            params.erc1155TokenIds.length == params.erc1155Amounts.length,
            "length not match"
        );
        uint256 len = MathUpgradeable.max(
            params.erc721TokenIds.length,
            params.erc1155TokenIds.length
        );
        require(len > 0, "length equals 0");
        address erc721 = address(ERC721_STAKING_TOKEN);
        address erc1155 = address(ERC1155_STAKING_TOKEN);
        for (uint256 i; i < len; i++) {
            if (i < params.erc721TokenIds.length) {
                _deposit(
                    campaignId,
                    msg.sender,
                    erc721,
                    params.erc721TokenIds[i],
                    1
                );
            }
            if (i < params.erc1155TokenIds.length) {
                _deposit(
                    campaignId,
                    msg.sender,
                    erc1155,
                    params.erc1155TokenIds[i],
                    params.erc1155Amounts[i]
                );
            }
        }
        _erc721Transfer(msg.sender, address(this), params.erc721TokenIds);
        _erc1155Transfer(
            msg.sender,
            address(this),
            params.erc1155TokenIds,
            params.erc1155Amounts
        );
    }

    /**
     * @dev   This function is called by the user when thay want to withdraw their staked
     *        NFT Lands from this contract.
     * @param campaignId - An unique identifier for this particular campaign. There are 3
     *        campaign represent for 3 kinds of duration: 30, 60 and 90 days.
     * @param params aa
     */
    function withdraw(uint8 campaignId, Params calldata params)
        external
        nonReentrant
        allowWithdraw(campaignId)
    {
        require(
            params.erc1155TokenIds.length == params.erc1155Amounts.length,
            "length not match"
        );
        uint256 len = MathUpgradeable.max(
            params.erc721TokenIds.length,
            params.erc1155TokenIds.length
        );
        require(len > 0, "length equals 0");
        address erc721 = address(ERC721_STAKING_TOKEN);
        address erc1155 = address(ERC1155_STAKING_TOKEN);
        for (uint256 i; i < len; i++) {
            if (i < params.erc721TokenIds.length) {
                _withdraw(
                    campaignId,
                    msg.sender,
                    erc721,
                    params.erc721TokenIds[i],
                    1
                );
            }
            if (i < params.erc1155TokenIds.length) {
                _withdraw(
                    campaignId,
                    msg.sender,
                    erc1155,
                    params.erc1155TokenIds[i],
                    params.erc1155Amounts[i]
                );
            }
        }
        _erc721Transfer(address(this), msg.sender, params.erc721TokenIds);
        _erc1155Transfer(
            address(this),
            msg.sender,
            params.erc1155TokenIds,
            params.erc1155Amounts
        );
    }

    /**
     * @dev   This function is called by the user when they claim their reward. User uses
     *        the data and signature signed by Admin and call function through a Proxy
     *        contract to verify the signature.
     * @param campaignId - An unique identifier for this particular campaign. There are 3
     *        campaign represent for 3 kinds of duration: 30, 60 and 90 days.
     * @param to - The user address
     * @param boxTypes aa
     * @param boxAmounts aa
     */
    function claimReward(
        uint8 campaignId,
        address to,
        uint256[] calldata boxTypes,
        uint256[] calldata boxAmounts
    ) external nonReentrant onlyProxy {
        REWARD_BOX.batchMint(to, boxTypes, boxAmounts);
        emit ClaimedReward(to, campaignId, boxTypes, boxAmounts);
    }

    /**
     * @dev   This function is called by the Manager when they want to start campaigns in
     *        particular time.
     * @param campaignIds - An list unique identifier for this particular campaign. There
     *        are 3 campaign represent for 3 kinds of duration: 30, 60 and 90 days.
     * @param campaignStartTimes - The list of timestamps that the campaigns's duration will
     *        be started.
     */
    function startCampaigns(
        uint8[] calldata campaignIds,
        uint256[] calldata campaignStartTimes
    ) external onlyRole(MANAGER_ROLE) {
        require(
            campaignIds.length == campaignStartTimes.length,
            "length not match"
        );
        require(campaignIds.length > 0, "length equals 0");
        for (uint256 i = 0; i < campaignIds.length; i++) {
            uint256 startTime = campaignStartTimes[i];
            require(startTime >= block.timestamp, "timestamp passed");
            Campaign memory campaign = campaignInfo[campaignIds[i]];
            campaign.campaignStartTime = startTime;
            campaign.campaignEndTime = startTime + campaign.duration;

            emit CampaignLaunched(campaignIds[i], startTime, campaign.duration);
            campaignInfo[campaignIds[i]] = campaign;
        }
    }

    /**
     * @dev   This function is called by the Admin when they want to change the duration
     *        time of each campaign.
     * @param campaignIds - An list unique identifier for this particular campaign. There
     *        are 3 campaign represent for 3 kinds of duration: 30, 60 and 90 days.
     * @param durations - The list of total time that the user's NFT Land will be locked
     *        (measured in seconds).
     */
    function setCampaigns(
        uint8[] calldata campaignIds,
        uint256[] calldata durations
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(campaignIds.length == durations.length, "length not match");
        require(campaignIds.length > 0, "length equals 0");

        for (uint256 i = 0; i < campaignIds.length; i++) {
            campaignInfo[campaignIds[i]].duration = durations[i];
        }
    }

    /**
     * @dev   This function is called by the Admin when they want to enable the ERMERGENCY
     *        CASE. In this case, all of users are able to withdraw their Land even the
     *        campaign is running.
     * @param allow - True/false are allown or not respectively.
     */
    function setAllowWithdraw(bool allow)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        isAllowWithdraw = allow;
        emit AllowedWithdraw(allow);
    }

    /**
     * @dev aa
     * @param newProxy aa
     */
    function setProxy(address newProxy) external onlyRole(DEFAULT_ADMIN_ROLE) {
        PROXY = newProxy;
        emit SetNewProxy(newProxy);
    }

    /* ****************** */
    /* INTERNAL FUNCTIONS */
    /* ****************** */

    function _deposit(
        uint8 _campaignId,
        address _beneficiary,
        address _token,
        uint256 _tokenId,
        uint256 _amount
    ) internal {
        if (_token == address(ERC721_STAKING_TOKEN)) {
            require(
                userBalanceByTokenId[_campaignId][_beneficiary][_token][
                    _tokenId
                ] == 0,
                "already staked"
            );
            userBalanceByTokenId[_campaignId][_beneficiary][_token][
                _tokenId
            ] += _amount;
        } else {
            userBalanceByTokenId[_campaignId][_beneficiary][_token][
                _tokenId
            ] += _amount;
        }
        emit Deposited(
            msg.sender,
            _campaignId,
            _token,
            _tokenId,
            _amount
        );
    }

    function _withdraw(
        uint8 _campaignId,
        address _beneficiary,
        address _token,
        uint256 _tokenId,
        uint256 _amount
    ) internal {
        if (_token == address(ERC721_STAKING_TOKEN)) {
            require(
                userBalanceByTokenId[_campaignId][_beneficiary][_token][
                    _tokenId
                ] == 1,
                "invalid amount"
            );
            userBalanceByTokenId[_campaignId][_beneficiary][_token][
                _tokenId
            ] -= _amount;
        } else {
            userBalanceByTokenId[_campaignId][_beneficiary][_token][
                _tokenId
            ] -= _amount;
        }
        emit Withdrawn(
            msg.sender,
            _campaignId,
            _token,
            _tokenId,
            _amount
        );
    }

    function _erc721Transfer(
        address from,
        address to,
        uint256[] calldata ids
    ) internal {
        if (ids.length == 0) return;
        // ERC721
        for (uint256 i = 0; i < ids.length; i++) {
            // bytes4(keccak256('safeTransferFrom(address,address,uint256)')) == 0x42842e0e
            (bool success, bytes memory data) = address(ERC721_STAKING_TOKEN)
                .call(abi.encodeWithSelector(0x42842e0e, from, to, ids[i]));
            require(
                success && (data.length == 0 || abi.decode(data, (bool))),
                "batch transferFrom failed"
            );
        }
    }

    function _erc1155Transfer(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts
    ) internal {
        if (ids.length == 0) return;
        // ERC1155
        // bytes4(keccak256('safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)')) == 0x2eb2c2d6
        (bool success, bytes memory data) = address(ERC1155_STAKING_TOKEN).call(
            abi.encodeWithSelector(0x2eb2c2d6, from, to, ids, amounts, "")
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "batch transferFrom failed"
        );
    }

    function onERC721Received(
        address, /* operator */
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return IERC721ReceiverUpgradeable.onERC721Received.selector;
    }

    function onERC1155Received(
        address, /* operator */
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return IERC1155ReceiverUpgradeable.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address, /* operator */
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes memory
    ) public virtual override returns (bytes4) {
        return IERC1155ReceiverUpgradeable.onERC1155BatchReceived.selector;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControlUpgradeable.sol";
import "../utils/ContextUpgradeable.sol";
import "../utils/StringsUpgradeable.sol";
import "../utils/introspection/ERC165Upgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {
    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

interface IDvisionMysteryBox {
    /**
     * VIEW FUNCTIONS
     */
    function MANAGER_ROLE() external view returns (bytes32);
    function boxType(uint256) external view returns (string memory);

    /**
     * SETTING BEFORE MINTING
     */
    function grantRole(bytes32 role, address account) external;
    function setBoxType(uint256 _index, string calldata _boxType) external;

    /**
     * MINTING
     */
    function mint(address _to, uint256 _boxType, uint256 _amount) external;
    function mintBase(
        address _operator,
        address _to,
        uint256 _id,
        uint256 _boxType,
        uint256 _amount
    ) external;
    function batchMint(
        address _to,
        uint256[] memory _boxTypes,
        uint256[] memory _amounts
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
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
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
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
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
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