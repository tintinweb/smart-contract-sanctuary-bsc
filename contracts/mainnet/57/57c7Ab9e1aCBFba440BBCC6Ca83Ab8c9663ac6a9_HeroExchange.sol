// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./lib/openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./lib/openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./lib/Signature.sol";
import "./Configable.sol";

contract HeroExchange is ReentrancyGuard, Configable {
    enum Quality { Blue, Purple, Orange }
    address immutable b_treasury;
    address immutable b_nft0;
    address immutable b_nft1;
    address public s_signer;
    mapping(Quality => uint16[]) private s_quality2tokenIds;
    mapping(Quality => uint16) private s_quality2index;

    event Exchange(address caller, uint tokenId0, uint tokenId1);

    constructor(address treasury, address nft0, address nft1, address signer) {
        require(treasury != address (0) && nft0 != address(0) && nft1 != address(0) && signer != address(0), "invalid params");
        b_treasury = treasury;
        b_nft0 = nft0;
        b_nft1 = nft1;
        s_signer = signer;
        owner = msg.sender;
    }

    function setTokenIds(Quality quality, uint16[] memory tokenIds) external onlyOwner {
        uint length = 700;
        if (quality == Quality.Purple) {
            length = 200;
        } else if (quality == Quality.Orange) {
            length = 100;
        }
        require(tokenIds.length == length, "wrong tokenIds length");
        s_quality2tokenIds[quality] = tokenIds;
    }

    function setSigner(address signer) external onlyOwner {
        require(s_signer != signer && signer != address(0), "invalid signer");
        s_signer = signer;
    }

    function exchange(uint tokenId0, Quality quality, bytes memory signature) external nonReentrant {
        require(_verifySingle(tokenId0 , quality, signature), "invalid signatures");
        _exchange(tokenId0, quality);
    }

    function batchExchange(uint[] memory tokenIds0, Quality[] memory qualities, bytes memory signature) external nonReentrant {
        require(tokenIds0.length == qualities.length, "invalid params length");
        require(_verifyBatch(tokenIds0, qualities, signature), "invalid signatures");
        for (uint i = 0; i < tokenIds0.length; i++) {
            _exchange(tokenIds0[i], qualities[i]);
        }
    }

    function qualityIndex(Quality quality) external view returns(uint16) {
        return s_quality2index[quality];
    }

    function _exchange(uint tokenId0, Quality quality) internal {
        uint tokenId1 = s_quality2tokenIds[quality][s_quality2index[quality]];
        IERC721(b_nft0).transferFrom(msg.sender, address(this), tokenId0);
        IERC721(b_nft1).transferFrom(b_treasury, msg.sender, tokenId1);
        s_quality2index[quality] = s_quality2index[quality] + 1;
        emit Exchange(msg.sender, tokenId0, tokenId1);
    }

    function _verifySingle(
        uint tokenId0,
        Quality quality,
        bytes memory signature
    ) public view returns (bool) {
        bytes32 message = keccak256(abi.encodePacked(tokenId0, quality, address(this)));
        bytes32 hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", message));
        address[] memory signList = Signature.recoverAddresses(hash, signature);
        return signList[0] == s_signer;
    }

    function _verifyBatch(
        uint[] memory tokenIds0,
        Quality[] memory qualities,
        bytes memory signature
    ) public view returns (bool) {
        bytes32 message = keccak256(abi.encodePacked(tokenIds0, qualities, address(this)));
        bytes32 hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", message));
        address[] memory signList = Signature.recoverAddresses(hash, signature);
        return signList[0] == s_signer;
    }

    function _verifyBatch2(
        uint[] memory tokenIds0,
        uint[] memory qualities,
        bytes memory signature
    ) public view returns (bool) {
        bytes32 message = keccak256(abi.encodePacked(tokenIds0, qualities, address(this)));
        bytes32 hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", message));
        address[] memory signList = Signature.recoverAddresses(hash, signature);
        return signList[0] == s_signer;
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
abstract contract ReentrancyGuard {
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

    constructor() {
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
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

library Signature {
    function recoverAddresses(bytes32 _hash, bytes memory _signatures) internal pure returns (address[] memory addresses) {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint count = _countSignatures(_signatures);
        addresses = new address[](count);
        for (uint i = 0; i < count; i++) {
            (v, r, s) = _parseSignature(_signatures, i);
            addresses[i] = ecrecover(_hash, v, r, s);
        }
    }
    
    function _parseSignature(bytes memory _signatures, uint _pos) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        uint offset = _pos * 65;
        assembly {
            r := mload(add(_signatures, add(32, offset)))
            s := mload(add(_signatures, add(64, offset)))
            v := and(mload(add(_signatures, add(65, offset))), 0xff)
        }

        if (v < 27) v += 27;

        require(v == 27 || v == 28);
    }
    
    function _countSignatures(bytes memory _signatures) internal pure returns (uint) {
        return _signatures.length % 65 == 0 ? _signatures.length / 65 : 0;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IConfig {
    function dev() external view returns (address);
    function admin() external view returns (address);
}

contract Configable {
    address public config;
    address public owner;

    event ConfigChanged(address indexed _user, address indexed _old, address indexed _new);
    event OwnerChanged(address indexed _user, address indexed _old, address indexed _new);
 
    function setupConfig(address _config) external onlyOwner {
        emit ConfigChanged(msg.sender, config, _config);
        config = _config;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'OWNER FORBIDDEN');
        _;
    }

    function admin() public view returns(address) {
        if(config != address(0)) {
            return IConfig(config).admin();
        }
        return owner;
    }

    function dev() public view returns(address) {
        if(config != address(0)) {
            return IConfig(config).dev();
        }
        return owner;
    }

    function changeOwner(address _user) external onlyOwner {
        require(owner != _user, 'Owner: NO CHANGE');
        emit OwnerChanged(msg.sender, owner, _user);
        owner = _user;
    }
    
    modifier onlyDev() {
        require(msg.sender == dev() || msg.sender == owner, 'dev FORBIDDEN');
        _;
    }
    
    modifier onlyAdmin() {
        require(msg.sender == admin() || msg.sender == owner, 'admin FORBIDDEN');
        _;
    }
  
    modifier onlyManager() {
        require(msg.sender == dev() || msg.sender == admin() || msg.sender == owner, 'manager FORBIDDEN');
        _;
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