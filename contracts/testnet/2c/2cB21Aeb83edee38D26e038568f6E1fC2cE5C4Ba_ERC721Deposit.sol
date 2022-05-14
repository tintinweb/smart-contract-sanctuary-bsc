// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import "./IERC721Deposit.sol";
import "./library/Whitelist.sol";
import "./library/LogReporting.sol";

contract ERC721Deposit is Context, AccessControl, IERC721Deposit {
    bytes32 public constant GOVERNOR_ROLE = keccak256("GOVERNOR_ROLE");

    using ECDSA for bytes32;
    using Whitelist for sWhitelist;
    using LogReporting for sLogReporting;

    sWhitelist private whitelist;
    sLogReporting private logger;

    uint64 unlockPeriod;
    uint64 fastWithdrawDelay;
    address fastWithdrawAuthority;

    mapping(address => UserDepositState[]) tokensDepositedByUser;
    mapping(address => mapping(uint256 => DepositState)) tokensDepositedByContract;

    constructor(address _governor) {
        _setupRole(GOVERNOR_ROLE, _governor);
        logger = sLogReporting("ERC721Deposit");
        whitelist.init(logger);
        unlockPeriod = 2 weeks;
        fastWithdrawDelay = 1 hours;
    }

    modifier _onlyGovernor() {
        require(
            hasRole(GOVERNOR_ROLE, _msgSender()),
            logger.reportError("You are not allowed to perform this operation")
        );
        _;
    }

    modifier _allContractWhitelisted(DepositRequest[] memory tokens) {
        bool allWhitelisted = true;
        for (uint256 i = 0; i > tokens.length; i++) {
            require(
                whitelist.isWhitelisted(tokens[i].contractAddr) == true,
                logger.reportError(
                    "Contract address not whitelisted",
                    Strings.toHexString(uint160(tokens[i].contractAddr), 20)
                )
            );
        }
        _;
    }

    function getUnlockPeriod() public view returns (uint64) {
        return unlockPeriod;
    }

    //Update of unlock period doesn't affect already deposited token
    function updateUnlockPeriod(uint64 period) public _onlyGovernor {
        require(period > 0, logger.reportError("Unlock period couldn't be negative"));
        require(
            period < 3 * 4 weeks,
            logger.reportError("Unlock period is should be lesser than 3 months")
        );
        unlockPeriod = period;
    }

    function getFastWithdrawDelay() public view returns (uint64) {
        return fastWithdrawDelay;
    }

    function updateFastWithdrawDelay(uint64 delay) public _onlyGovernor {
        require(delay > 0, logger.reportError("Delay should be greater than 0"));
        require(delay < 1 days, logger.reportError("Delay should be lesser than 1 day"));
        fastWithdrawDelay = delay;
    }

    function getFastWithdrawAuthority() public view _onlyGovernor returns (address) {
        return fastWithdrawAuthority;
    }

    function updateFastWithdrawAuthority(address authority) public _onlyGovernor {
        require(authority != address(0), logger.reportError("Authority can't be address 0x"));
        fastWithdrawAuthority = authority;
    }

    function getWhitelisted() public view _onlyGovernor returns (address[] memory) {
        return whitelist.contracts;
    }

    function isWhitelisted(address contractAddr) public view _onlyGovernor returns (bool) {
        return whitelist.isWhitelisted(contractAddr);
    }

    function getTokenDepositedByUser(address userAddr)
        public
        view
        returns (UserDepositState[] memory)
    {
        return tokensDepositedByUser[userAddr];
    }

    function getDepositState(address contractAddr, uint256 tokenId)
        public
        view
        returns (DepositState memory)
    {
        return tokensDepositedByContract[contractAddr][tokenId];
    }

    function addContract(address contractAddr) public _onlyGovernor {
        whitelist.add(contractAddr);
    }

    function removeContract(address contractAddr) public _onlyGovernor {
        whitelist.remove(contractAddr);
    }

    function depositTokens(DepositRequest[] memory tokens) public _allContractWhitelisted(tokens) {
        for (uint256 i = 0; i < tokens.length; i++) {
            IERC721 tokenInstance = IERC721(tokens[i].contractAddr);
            DepositState storage ds = tokensDepositedByContract[tokens[i].contractAddr][
                tokens[i].tokenId
            ];
            require(
                ds.owner == address(0),
                logger.reportError("Token already deposited | ", depositRequestToString(tokens[i]))
            );
            tokenInstance.transferFrom(_msgSender(), address(this), tokens[i].tokenId);
            ds.owner = _msgSender();
            ds.lockedUntil = 0;
            ds.unlockPeriod = unlockPeriod;
            tokensDepositedByUser[_msgSender()].push(
                UserDepositState(tokens[i].tokenId, tokens[i].contractAddr, ds)
            );
        }
        emit TokenDeposited(_msgSender(), tokens);
    }

    function requestWithdraws(DepositRequest[] memory tokens) public {
        UserDepositState[] memory tokenRequested = new UserDepositState[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            DepositState storage ds = tokensDepositedByContract[tokens[i].contractAddr][
                tokens[i].tokenId
            ];
            require(
                ds.owner == _msgSender(),
                logger.reportError("Token not deposited | ", depositRequestToString(tokens[i]))
            );
            require(
                ds.lockedUntil == 0,
                logger.reportError("Token already requested | ", depositRequestToString(tokens[i]))
            );
            ds.lockedUntil = uint64(block.timestamp + ds.unlockPeriod);
            for (uint256 j = 0; j < tokensDepositedByUser[_msgSender()].length; j++) {
                if (tokensDepositedByUser[_msgSender()][j].tokenId == tokens[i].tokenId) {
                    tokensDepositedByUser[_msgSender()][j].ds = ds;
                    break;
                }
            }
            tokenRequested[i] = UserDepositState(tokens[i].tokenId, tokens[i].contractAddr, ds);
        }
        emit TokenWithdrawalRequest(_msgSender(), tokenRequested);
    }

    function withdraws(DepositRequest[] memory tokens) public {
        for (uint256 i = 0; i < tokens.length; i++) {
            DepositState storage ds = tokensDepositedByContract[tokens[i].contractAddr][
                tokens[i].tokenId
            ];
            require(
                ds.owner == _msgSender(),
                logger.reportError("Token not deposited | ", depositRequestToString(tokens[i]))
            );
            require(
                ds.lockedUntil != 0,
                logger.reportError(
                    "Token not request for withdraw | ",
                    depositRequestToString(tokens[i])
                )
            );
            require(
                uint64(block.timestamp) > ds.lockedUntil,
                logger.reportError(
                    "Token is still locked in time | ",
                    depositRequestToString(tokens[i])
                )
            );
            IERC721 tokenInstance = IERC721(tokens[i].contractAddr);
            tokenInstance.transferFrom(address(this), _msgSender(), tokens[i].tokenId);
            ds.owner = address(0);
            ds.lockedUntil = 0;
            ds.unlockPeriod = 0;
            ds.lastWithdraw = uint64(block.timestamp);
            removeTokenFromStorage(tokens[i].tokenId);
        }
        emit TokenWithdrawal(_msgSender(), tokens);
    }

    function fastWithdraws(
        DepositRequest[] memory tokens,
        uint64 timestamp,
        bytes32 message,
        bytes memory signature
    ) public {
        require(
            fastWithdrawAuthority != address(0),
            logger.reportError("Unknow fast withdraw authority")
        );
        require(
            message.toEthSignedMessageHash().recover(signature) == fastWithdrawAuthority,
            logger.reportError("Bad signer for message")
        );
        verifyFastWithdrawsHash(tokens, timestamp, message);
        for (uint256 i = 0; i < tokens.length; i++) {
            DepositState storage ds = tokensDepositedByContract[tokens[i].contractAddr][
                tokens[i].tokenId
            ];
            require(
                ds.owner == _msgSender(),
                logger.reportError("Token not deposited | ", depositRequestToString(tokens[i]))
            );
            require(
                ds.lastWithdraw + fastWithdrawDelay < timestamp,
                logger.reportError(
                    "Need to wait before fast withdraw again | ",
                    string(
                        abi.encodePacked(depositRequestToString(tokens[i]), " ", ds.lastWithdraw)
                    )
                )
            );
            IERC721 tokenInstance = IERC721(tokens[i].contractAddr);
            tokenInstance.transferFrom(address(this), _msgSender(), tokens[i].tokenId);
            ds.owner = address(0);
            ds.lockedUntil = 0;
            ds.unlockPeriod = 0;
            ds.lastWithdraw = timestamp;
            removeTokenFromStorage(tokens[i].tokenId);
        }
        emit TokenWithdrawal(_msgSender(), tokens);
    }

    function verifyFastWithdrawsHash(
        DepositRequest[] memory tokens,
        uint64 timestamp,
        bytes32 message
    ) internal view {
        bytes32[] memory tokensHash = new bytes32[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            tokensHash[i] = keccak256(abi.encodePacked(tokens[i].tokenId, tokens[i].contractAddr));
        }
        require(
            keccak256(abi.encodePacked(tokensHash, timestamp)) == message,
            logger.reportError("Message malformed")
        );
    }

    function depositRequestToString(DepositRequest memory token)
        internal
        pure
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    Strings.toString(token.tokenId),
                    " ",
                    Strings.toHexString(uint160(token.contractAddr), 20)
                )
            );
    }

    function removeTokenFromStorage(uint256 tokenId) internal {
        for (uint256 i = 0; i < tokensDepositedByUser[_msgSender()].length; i++) {
            if (tokensDepositedByUser[_msgSender()][i].tokenId == tokenId) {
                tokensDepositedByUser[_msgSender()][i] = tokensDepositedByUser[_msgSender()][
                    tokensDepositedByUser[_msgSender()].length - 1
                ];
                tokensDepositedByUser[_msgSender()].pop();
                break;
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

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
abstract contract AccessControl is Context, IAccessControl, ERC165 {
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
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
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
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

/**
 * @dev Interface of the deposit contract for Chromia bridge standard
 *
 * This contract is use to deposit assets from EVM compatible chain to CHR
 * You could deposit any token that are whitelisted
 * You could withdraw any token even if the contract was remove from whitelist
 * You could request for a witdhraw, token will be locked for (`unlockPeriod`).
 *
 */
interface IERC721Deposit {
    /**
     * @dev DepositState is a storage for a tokenId where we could keep in memory
     *
     * - `address owner`: owner of the token
     * - `uint64 lockedUntil`: period of lock after request withdraw
     * - `uint64 unlockPeriod`: period of lock when deposit
     * - `uint64 lastWithdraw`: period of lastWithdraw to prevent fastWithdraw abuse
     *
     */
    struct DepositState {
        address owner;
        uint64 lockedUntil;
        uint64 unlockPeriod;
        uint64 lastWithdraw;
    }

    /**
     * @dev DepositRequest is a struct use to call {depositToken}, {requestWithdraws}, {withdraws} & {fastWithdraws}
     *
     * - `uint256 tokenId`: tokenId of an ERC721
     * - `address contractAddr`: Adress of the contract for the tokenId should be whitelisted for deposit only !
     *
     */
    struct DepositRequest {
        uint256 tokenId;
        address contractAddr;
    }

    /**
     * @dev UserDepositState is a struct use to keep track in a mapping of all tokens deposited by a user
     *
     * - `uint256 tokenId`: tokenId of an ERC721
     * - `address contractAddr`: Address of the ERC721 Contract
     * - `DepositState ds`: Deposit state of a given token
     *
     */
    struct UserDepositState {
        uint256 tokenId;
        address contractAddr;
        DepositState ds;
    }

    /**
     * @dev Emitted when (`from`) make an NFT deposit as an array of {DepositRequest} (`tokens`)
     */
    event TokenDeposited(address indexed from, DepositRequest[] tokens);

    /**
     * @dev Emitted when (`from`) make an NFT withdrawal request as an array of {UserDepositState} (`tokens`)
     * Will have info for each token about `unlockPeriod` and `lockedUntil`
     */
    event TokenWithdrawalRequest(address indexed from, UserDepositState[] tokens);

    /**
     * @dev Emitted when (`from`) make an NFT withdrawal as an array of {DepositRequest} (`tokens`)
     */
    event TokenWithdrawal(address indexed from, DepositRequest[] tokens);

    /**
     * @dev return standard unlock period stored in contract
     *
     */
    function getUnlockPeriod() external view returns (uint64);

    /**
     * @dev Use to update unlockPeriod, (`unlockPeriod`) need to be greater than 0 and lesser than 3 months
     *
     * Requirements:
     *
     * - Caller should be `GOVERNOR_ROLE`
     *
     */
    function updateUnlockPeriod(uint64 unlockPeriod) external;

    /**
     * @dev return fast withdraw delay
     */
    function getFastWithdrawDelay() external view returns (uint64);

    /**
     * @dev Use to update fastWithdrawDelay, (`delay`) need to be greater than 0 and lesser than 1 day
     *
     * Requirements:
     *
     * - Caller should be `GOVERNOR_ROLE`
     *
     */
    function updateFastWithdrawDelay(uint64 delay) external;

    /**
     * @dev return fast withdraw authority is the address that should sign message for fast withdraw
     *
     * Requirements:
     *
     * - Caller should be `GOVERNOR_ROLE`
     *
     */
    function getFastWithdrawAuthority() external view returns (address);

    /**
     * @dev Use to update fastWithdrawAuthority, (`authority`) should be different than address(0)
     *
     * Requirements:
     *
     * - Caller should be `GOVERNOR_ROLE`
     *
     */
    function updateFastWithdrawAuthority(address authority) external;

    /**
     * @dev return list of contract addresses that are whitelisted
     *
     * Requirements:
     *
     * - Caller should be `GOVERNOR_ROLE`
     *
     */
    function getWhitelisted() external view returns (address[] memory);

    /**
     * @dev return true or false if contract is whitelisted
     *
     * Requirements:
     *
     * - Caller should be `GOVERNOR_ROLE`
     *
     */
    function isWhitelisted(address contractAddr) external view returns (bool);

    /**
     * @dev return list of all tokens deposited by user address (`userAddr`) as {UserDepositState}
     */
    function getTokenDepositedByUser(address userAddr)
        external
        view
        returns (UserDepositState[] memory);

    /**
     * @dev return {DepositState} for a given (`contractAddr`) and (`tokenId`)
     */
    function getDepositState(address contractAddr, uint256 tokenId)
        external
        view
        returns (DepositState memory);

    /**
     * @dev Use to add address of a contract in the whitelist to allow deposit
     * address (`contractAddr`)
     *
     * Requirements:
     *
     * - Caller should be `GOVERNOR_ROLE`
     *
     */
    function addContract(address contractAddr) external;

    /**
     * @dev Use to remove address of a contract in the whitelist, token could still be withdrawns
     * address (`contractAddr`)
     *
     * Requirements:
     *
     * - Caller should be `GOVERNOR_ROLE`
     *
     */
    function removeContract(address contractAddr) external;

    /**
     * @dev Deposit an array of tokens and contract (`tokens`) in the deposit state
     *
     * ex: [[0, "0x..."], [1, "0x..."]]
     *
     * Emits a {TokenDeposited} event.
     *
     * Requirements:
     *
     * - All contracts should be whitelisted
     * - {DepositState} shouldn't exist or owner should be address(0) it's set after a withdrawal
     *
     */
    function depositTokens(DepositRequest[] memory tokens) external;

    /**
     * @dev Request the withdraw of a tokens and contract array (`tokens`)
     *
     * ex: [[0, "0x..."], [1, "0x..."]]
     *
     * Emits a {TokenWithdrawalRequest} event.
     *
     * Requirements:
     *
     * - {DepositState} owner should be the message sender
     * - {DepositState} lockedUntil should be 0 else token is already requested for withdraw
     *
     */
    function requestWithdraws(DepositRequest[] memory tokens) external;

    /**
     * @dev Withdraw an array of tokens and contract (`tokens`) if they are unlockable
     * it will update `lastWithdraw` to prevent a {fastWithdraws} call
     *
     *  ex: [[0, "0x..."], [1, "0x..."]]
     *
     * Emits a {TokenWithdrawal} event.
     *
     * Requirements:
     *
     * - {DepositState} owner should be the message sender
     * - {DepositState} lockedUntil should be != 0 else token is not requested for withdraw (lockedUntil is always greater or equal 0)
     * - {DepositeState} lockedUntil should be greater than `block.timestamp`
     *
     */
    function withdraws(DepositRequest[] memory tokens) external;

    /**
     * @dev Withdraw an array of tokens and contract (`tokens`)
     * regarding a `message` hashed with a `timestamp` and a `signature`
     *
     * It will use keccak256() to verify parameter and hash it on solidity side
     * It use ECDSA to get back signer of signature
     * It will update lastWithdraw regarding the passed timestamp
     *
     *  ex: [[0, "0x..."], [1, "0x..."]]
     *
     * Emits a {TokenWithdrawal} event.
     *
     * Requirements:
     *
     * - {DepositState} owner should be the message sender
     * - `signature` should be signed by fastWithdrawAuthority. check {updateFastWithdrawAuthority} & {getFastWithrawAuthority}
     * - {DepositState} lastWithdraw + fastWithdrawDelay should be greater than timestamp
     *
     * We could use timestamp safely here because message hash it's checked with timestamp and should come from the approved authority
     *
     */
    function fastWithdraws(
        DepositRequest[] memory tokens,
        uint64 timestamp,
        bytes32 message,
        bytes memory signature
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./LogReporting.sol";

struct sWhitelist {
    sLogReporting logger;
    address[] contracts;
}

library Whitelist {
    using LogReporting for sLogReporting;

    function init(sWhitelist storage self, sLogReporting memory logger) public {
        self.logger = logger;
    }

    function add(sWhitelist storage self, address contractAddr) public {
        require(
            contractAddr != address(0),
            self.logger.reportError("Contract address can't be 0x")
        );
        require(
            isWhitelisted(self, contractAddr) == false,
            self.logger.reportError("Contract address already whitelisted")
        );
        self.contracts.push(contractAddr);
    }

    function remove(sWhitelist storage self, address contractAddr) public {
        require(
            contractAddr != address(0),
            self.logger.reportError("Contract address can't be 0x")
        );
        require(
            isWhitelisted(self, contractAddr) != false,
            self.logger.reportError("Contract address not whitelisted")
        );
        for (uint64 i = 0; i < self.contracts.length; i++) {
            if (self.contracts[i] == contractAddr) {
                self.contracts[i] = self.contracts[self.contracts.length - 1];
                self.contracts.pop();
                break;
            }
        }
    }

    function isWhitelisted(sWhitelist storage self, address contractAddr)
        public
        view
        returns (bool)
    {
        for (uint64 i = 0; i < self.contracts.length; i++) {
            if (self.contracts[i] == contractAddr) {
                return true;
            }
        }
        return false;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

struct sLogReporting {
    string contractName;
}

library LogReporting {
    function reportError(sLogReporting storage self, string memory error)
        public
        view
        returns (string memory)
    {
        return string(abi.encodePacked(self.contractName, " - [ERROR]: ", error));
    }

    function reportError(
        sLogReporting storage self,
        string memory error1,
        string memory error2
    ) public view returns (string memory) {
        return string(abi.encodePacked(self.contractName, " - [ERROR]: ", error1, error2));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

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
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
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