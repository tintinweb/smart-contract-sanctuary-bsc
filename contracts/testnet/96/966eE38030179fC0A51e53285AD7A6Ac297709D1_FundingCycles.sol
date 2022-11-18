// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
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

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
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
interface IERC165 {
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
pragma solidity ^0.8.4;

import {IProjects} from "./interfaces/IProjects.sol";
import {AuctionedPass, IFundingCycles, FundingCycleState, FundingCycleParameter, FundingCycleProperties, IConfigStore} from "./interfaces/IFundingCycles.sol";

contract FundingCycles is IFundingCycles {
  /*╔═════════════════════════════╗
    ║   Private Stored Constants  ║
    ╚═════════════════════════════╝*/

  // The number of seconds in a day.
  uint256 private constant SECONDS_IN_DAY = 3600; // TODO 1 hour

  // mapping fundingCycleId with auctionPass
  mapping(uint256 => mapping(uint256 => AuctionedPass)) private _fundingCycleIdAuctionedPass;

  /*╔═════════════════════════════╗
    ║  Public Stored Properties   ║
    ╚═════════════════════════════╝*/

  // The total number of funding cycles created, which is used for issuing funding cycle IDs.
  // Funding cycles have IDs > 0.
  uint256 public override count;

  // mapping projectId with latest funding cycle properties id
  mapping(uint256 => uint256) public override latestIdFundingProject;

  // mapping id with funding cycle properties
  mapping(uint256 => FundingCycleProperties) public fundingCycleProperties;

  /*╔═════════════════════════════╗
    ║    Public Stored Constants  ║
    ╚═════════════════════════════╝*/
  // Config store utils to store the global configuration
  IConfigStore public immutable override configStore;

  /*╔══════════════════╗
    ║   External VIEW  ║
    ╚══════════════════╝*/

  /**
   * @notice
   * Get the funding cycle with the given ID
   *
   * @param _fundingCycleId The ID of the funding cycle to get
   */
  function getFundingCycle(uint256 _fundingCycleId)
    public
    view
    override
    returns (FundingCycleProperties memory)
  {
    return fundingCycleProperties[_fundingCycleId];
  }

  /**
   * @notice
   * Current active funding cycle of this dao project
   *
   * @param _projectId The ID of project
   */
  function currentOf(uint256 _projectId)
    external
    view
    override
    returns (FundingCycleProperties memory)
  {
    return fundingCycleProperties[latestIdFundingProject[_projectId]];
  }

  /**
   * @notice
   * Return the state of giving funding cycle
   *
   * @param _fundingCycleId The ID of funding cycle to get state
   */
  function getFundingCycleState(uint256 _fundingCycleId)
    external
    view
    override
    returns (FundingCycleState)
  {
    FundingCycleProperties memory _fundingCycle = fundingCycleProperties[_fundingCycleId];

    if (block.timestamp < _fundingCycle.start) return FundingCycleState.WarmUp;
    if (block.timestamp >= _fundingCycle.end) return FundingCycleState.Expired;

    return FundingCycleState.Active;
  }

  function getAutionedPass(uint256 _fundingCycleId, uint256 _tierId)
    external
    view
    override
    returns (AuctionedPass memory)
  {
    return _fundingCycleIdAuctionedPass[_fundingCycleId][_tierId];
  }

  /*╔═════════════════════════╗
    ║   External Transaction  ║
    ╚═════════════════════════╝*/
  constructor(IConfigStore _configStore) {
    configStore = _configStore;
  }

  /**
   * @notice
   * configure funding cycle
   * return a new funding cycle by call init if there is no funding cycle exist in the project
   * return existing funding cycle if the funding cycle still active in the project
   * return new funding cycle if there is no active funding cycle
   *
   * @param _projectId Dao Id
   * @param _params The parameters for Funding Cycle
   * @param _auctionedPass auction pass information
   */
  function configure(
    uint256 _projectId,
    FundingCycleParameter calldata _params,
    AuctionedPass[] calldata _auctionedPass
  ) external override returns (FundingCycleProperties memory) {
    if (!configStore.terminalRoles(msg.sender)) revert UnAuthorized();
    if (_params.duration >= type(uint16).max) revert BadDuration();

    // Check if the latestIdFunding project still running
    uint256 _latestId = latestIdFundingProject[_projectId];
    if (_latestId != 0 && block.timestamp <= fundingCycleProperties[_latestId].end)
      revert FundingCycleExist(_latestId);

    count += 1;
    for (uint256 i; i < _auctionedPass.length; i++) {
      _fundingCycleIdAuctionedPass[count][_auctionedPass[i].id] = _auctionedPass[i];

      emit InitAuctionedPass(count, _auctionedPass[i]);
    }

    FundingCycleProperties memory _newFundingCycle = FundingCycleProperties({
      id: count,
      launchMode: _params.launchMode,
      previousId: _latestId,
      projectId: _projectId,
      start: block.timestamp + 300, // TODO update 300 to 1 day
      duration: _params.duration,
      end: block.timestamp + 300 + _params.duration * SECONDS_IN_DAY, // TODO update 300 to 1 day
      isPaused: false
    });
    latestIdFundingProject[_projectId] = count;
    fundingCycleProperties[count] = _newFundingCycle;

    emit Init(
      count,
      _projectId,
      _latestId,
      _newFundingCycle.start,
      _newFundingCycle.end,
      _newFundingCycle.duration,
      _newFundingCycle.launchMode
    );

    return _newFundingCycle;
  }

  /**
   * @notice
   * Update the contribute status of giving project
   *
   * @param _projectId The project ID to update
   * @param _paused Paused or not
   */
  function setPauseFundingCycle(uint256 _projectId, bool _paused) external override {
    if (!configStore.terminalRoles(msg.sender)) revert UnAuthorized();

    uint256 _latestId = latestIdFundingProject[_projectId];
    if (_latestId == 0) revert FundingCycleNotExist();

    FundingCycleProperties storage latestFundingCycleProperties = fundingCycleProperties[_latestId];
    latestFundingCycleProperties.isPaused = _paused;

    emit PauseStateChanged(_latestId, _paused);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IConfigStore {
  event SetBaseProjectURI(string uri);

  event SetBaseMembershipPassURI(string uri);

  event SetBaseContractURI(string uri);

  event SetSigner(address signer);

  event SetSuperAdmin(address admin);

  event SetDevTreasury(address devTreasury);

  event SetTapFee(uint256 fee);

  event SetContributeFee(uint256 fee);

  event SetClaimFee(uint256 fee);

  event SetMinLockRate(uint256 minLockRate);

  event RoyaltyFeeSenderChanged(address royaltyFeeSender, bool isAdd);

  event TerminalRoleChanged(address terminal, bool grant);

  event MintRoleChanged(address account, bool grant);

  error BadTapFee();

  error ZeroAddress();

  function baseProjectURI() external view returns (string memory);

  function baseMembershipPassURI() external view returns (string memory);

  function baseContractURI() external view returns (string memory);

  function signerAddress() external view returns (address);

  function superAdmin() external view returns (address);

  function devTreasury() external view returns (address);

  function tapFee() external view returns (uint256);

  function contributeFee() external view returns (uint256);

  function claimFee() external view returns (uint256);

  function minLockRate() external view returns (uint256);

  function royaltyFeeSenderWhiteList(address _sender) external view returns (bool);

  function terminalRoles(address) external view returns (bool);

  function mintRoles(address) external view returns (bool);

  function setBaseProjectURI(string calldata _uri) external;

  function setBaseMembershipPassURI(string calldata _uri) external;

  function setBaseContractURI(string calldata _uri) external;

  function setSigner(address _admin) external;

  function setSuperAdmin(address _signer) external;

  function setDevTreasury(address _devTreasury) external;

  function setTapFee(uint256 _fee) external;

  function setContributeFee(uint256 _fee) external;

  function setClaimFee(uint256 _fee) external;

  function setMinLockRate(uint256 _lockRate) external;

  function addRoyaltyFeeSender(address _sender) external;

  function removeRoyaltyFeeSender(address _sender) external;

  function grantTerminalRole(address _terminal) external;

  function revokeTerminalRole(address _terminal) external;

  function grantMintRole(address _terminal) external;

  function revokeMintRole(address _terminal) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IConfigStore} from "./IConfigStore.sol";

enum FundingCycleState {
  WarmUp,
  Active,
  Expired
}

enum FundingCycleMod {
  Airdrop,
  Auction,
  FreeMint,
  FundRaising
}

struct AuctionedPass {
  // tier id, indexed from 0
  uint256 id;
  // the amount of tickets allocated to current round
  uint256 allocateAmount;
  // the amount of tickets reserved to next round
  uint256 reservedAmount;
}

struct FundingCycleProperties {
  uint256 id;
  FundingCycleMod launchMode;
  uint256 previousId;
  uint256 projectId;
  uint256 start;
  uint16 duration;
  uint256 end;
  bool isPaused;
}

struct FundingCycleParameter {
  FundingCycleMod launchMode;
  uint16 duration;
}

interface IFundingCycles {
  event Init(
    uint256 indexed fundingCycleId,
    uint256 indexed projectId,
    uint256 previous,
    uint256 start,
    uint256 end,
    uint256 duration,
    FundingCycleMod launchMode
  );

  event InitAuctionedPass(uint256 indexed fundingCycleId, AuctionedPass autionPass);

  event PauseStateChanged(uint256 indexed fundingCycleId, bool isPause);

  error BadDuration();
  error UnAuthorized();
  error FundingCycleNotExist();
  error FundingCycleExist(uint256 fundingCycleId);

  function count() external view returns (uint256);

  function configStore() external view returns (IConfigStore);

  function latestIdFundingProject(uint256 _projectId) external view returns (uint256);

  function getFundingCycle(uint256 _fundingCycleId)
    external
    view
    returns (FundingCycleProperties memory);

  function currentOf(uint256 _projectId) external view returns (FundingCycleProperties memory);

  function getFundingCycleState(uint256 _fundingCycleId) external view returns (FundingCycleState);

  function getAutionedPass(uint256 _fundingCycleId, uint256 _tierId)
    external
    view
    returns (AuctionedPass memory);

  function configure(
    uint256 _projectId,
    FundingCycleParameter calldata _params,
    AuctionedPass[] calldata _auctionedPass
  ) external returns (FundingCycleProperties memory);

  function setPauseFundingCycle(uint256 _projectId, bool _paused) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import {IConfigStore} from "./IConfigStore.sol";

interface IProjects is IERC721 {
  error EmptyHandle();
  error TakenedHandle();
  error UnAuthorized();

  event Create(uint256 indexed projectId, address indexed owner, bytes32 handle, address caller);

  function count() external view returns (uint256);

  function configStore() external view returns (IConfigStore);

  function handleOf(uint256 _projectId) external returns (bytes32 handle);

  function projectFor(bytes32 _handle) external returns (uint256 projectId);

  function exists(uint256 _projectId) external view returns (bool);

  function create(address _owner, bytes32 _handle) external returns (uint256 id);
}