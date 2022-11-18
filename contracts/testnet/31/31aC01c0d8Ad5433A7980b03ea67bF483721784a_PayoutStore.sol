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

import {IPayoutStore, IProjects, IConfigStore, PayoutMod} from "./interfaces/IPayoutStore.sol";

/**
  @notice
  Stores mods for each project.
  @dev
  Mods can be used to distribute a percentage of payments or tickets to preconfigured beneficiaries.

  @notice
  the fundingCycleID is unique, then there is no need to store ProjectId in SmartContract. 
*/
contract PayoutStore is IPayoutStore {
  /*╔═════════════════════════════╗
    ║  Private Stored Properties  ║
    ╚═════════════════════════════╝*/
  // All payout mods for each fundingCycleID => payModsOf
  mapping(uint256 => PayoutMod[]) private _payoutModsOf;

  /*╔═════════════════════════════╗
    ║  Public Stored Properties   ║
    ╚═════════════════════════════╝*/
  // The contract storing project information.
  IProjects public immutable override projects;

  // Config store utils to store the global configration
  IConfigStore public immutable override configStore;

  /*╔══════════════════╗
    ║   Public VIEW    ║
    ╚══════════════════╝*/
  /**
   * @notice
   * Get all payout mods for the specified project ID.
   *
   * @param _fundingCycleId The ID of the fundingCycle to get mods for.
   * @return An array of all mods for the project.
   */
  function payoutModsOf(uint256 _fundingCycleId)
    external
    view
    override
    returns (PayoutMod[] memory)
  {
    return _payoutModsOf[_fundingCycleId];
  }

  /*╔═════════════════════════╗
    ║   External Transactions ║
    ╚═════════════════════════╝*/
  /**
   * @param _projects The contract storing project information
   */
  constructor(IProjects _projects, IConfigStore _configStore) {
    projects = _projects;
    configStore = _configStore;
  }

  /**
   * @notice
   * Adds a mod to the payout mods list.
   * @dev
   * Only the owner or operator of a project can make this call, or the current terminal of the project.
   * @param _projectId The project to add a mod to.
   * @param _mods The payout mods to set.
   */
  function setPayoutMods(
    uint256 _projectId,
    uint256 _fundingCycleId,
    PayoutMod[] calldata _mods
  ) external override {
    if (!configStore.terminalRoles(msg.sender)) revert UnAuthorized();

    // There must be something to do.
    if (_mods.length <= 0) {
      revert NoOp();
    }

    // Delete from storage so mods can be repopulated.
    delete _payoutModsOf[_fundingCycleId];

    // Add up all the percents to make sure they cumulative are under 100%.
    uint256 _payoutModPercentTotal;

    for (uint256 _i; _i < _mods.length; ) {
      // The percent should be greater than 0.
      if (_mods[_i].percent <= 0) revert BadPercentage();

      // Add to the total percents.
      _payoutModPercentTotal += _mods[_i].percent;

      // The allocator and the beneficiary shouldn't both be the zero address.
      if (_mods[_i].beneficiary == address(0)) revert BadAddress();

      // Push the new mod into the project's list of mods.
      _payoutModsOf[_fundingCycleId].push(_mods[_i]);

      emit SetPayoutMod(_projectId, _fundingCycleId, _mods[_i], msg.sender);

      unchecked {
        _i++;
      }
    }

    // The total percent should be less than 10000.
    if (_payoutModPercentTotal > 10000) revert BadTotalPercentage();
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

import {IProjects} from "./IProjects.sol";
import {IConfigStore} from "./IConfigStore.sol";

struct PayoutMod {
  uint16 percent;
  address payable beneficiary;
}

interface IPayoutStore {
  error BadPercentage();
  error BadTotalPercentage();
  error BadAddress();
  error NoOp();
  error UnAuthorized();

  event SetPayoutMod(
    uint256 indexed projectId,
    uint256 indexed fundingCycleId,
    PayoutMod mod,
    address caller
  );

  function projects() external view returns (IProjects);

  function configStore() external view returns (IConfigStore);

  function payoutModsOf(uint256 _fundingCycleId) external returns (PayoutMod[] memory);

  function setPayoutMods(
    uint256 _projectId,
    uint256 _fundingCycleId,
    PayoutMod[] memory _mods
  ) external;
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