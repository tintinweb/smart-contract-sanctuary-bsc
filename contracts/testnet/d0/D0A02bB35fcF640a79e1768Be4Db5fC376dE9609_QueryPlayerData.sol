// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../interface/ICOW721.sol";
import "../interface/Iprofile_photo.sol";

contract QueryPlayerData {
    ICOW public bovineHero;
    IProfilePhoto public avatar;

    constructor(){
        bovineHero = ICOW(0x3c16efCd766764F1bdd67dDe2F0b4D24AC30aa0A);
        avatar = IProfilePhoto(0x545a576e20dFAe72CD3880E829D99103944AA66c);

    }

    // query profile data
    function queryProfileData(address addr_) public view returns (string[] memory)  {
        string []memory profilePhotos = getUserProfilePhoto(addr_);

        return profilePhotos;
    }

    function getUserProfilePhoto(address addr_) public view returns(string[] memory) {
        uint l;
        uint index;
        // 1.bovine hero
        uint []memory bovineHeroPhoto = bovineHero.checkUserCowListType(addr_, true);
        l += bovineHeroPhoto.length;

        // 2.profile photo
        uint []memory profilePhoto = avatar.getUserPhotos(addr_);
        l += profilePhoto.length;

        string[] memory profileIcons = new string[](l);
        for (uint i = 0;i < bovineHeroPhoto.length; i++) {
            profileIcons[index] = (string(abi.encodePacked("Bovine Hero-",bovineHeroPhoto[i])));
            index++;
        }
        for (uint i = 0;i < profilePhoto.length; i++) {
            profileIcons[index] = (string(abi.encodePacked(profilePhoto[i])));
            index++;
        }


        return profileIcons;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IProfilePhoto {
    function mintBabyBull(address addr_) external;

    function mintAdultBull(address addr_) external;

    function mintBabyCow(address addr_) external;

    function mintAdultCow(address addr_) external;

    function mintMysteryBox(address addr_) external;

    function getUserPhotos(address addr_) external view returns(uint[]memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICOW {
    function getGender(uint tokenId_) external view returns (uint);

    function getEnergy(uint tokenId_) external view returns (uint);

    function getAuldt(uint tokenId_) external view returns (bool);

    function getAttack(uint tokenId_) external view returns (uint);

    function getStamina(uint tokenId_) external view returns (uint);

    function getDefense(uint tokenId_) external view returns (uint);

    function getPower(uint tokenId_) external view returns (uint);

    function getLife(uint tokenId_) external view returns (uint);

    function getBronTime(uint tokenId_) external view returns (uint);

    function getGrowth(uint tokenId_) external view returns (uint);

    function getMilk(uint tokenId_) external view returns (uint);

    function getMilkRate(uint tokenId_) external view returns (uint);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function mintNormall(address player, uint[2] memory parents) external;

    function mint(address player) external;

    function setApprovalForAll(address operator, bool approved) external;

    function growUp(uint tokenId_) external;

    function isCreation(uint tokenId_) external view returns (bool);

    function burn(uint tokenId_) external returns (bool);

    function deadTime(uint tokenId_) external view returns (uint);

    function addDeadTime(uint tokenId, uint time_) external;

    function checkUserCowListType(address player,bool creation_) external view returns (uint[] memory);
}

interface IBOX {
    function mint(address player, uint[2] memory parents_) external;

    function burn(uint tokenId_) external returns (bool);

    function checkParents(uint tokenId_) external view returns (uint[2] memory);

    function checkGrow(uint tokenId_) external view returns (uint[2] memory);

    function checkLife(uint tokenId_) external view returns (uint[2] memory);
    
    function checkEnergy(uint tokenId_) external view returns (uint[2] memory);
}

interface IStable {
    function isStable(uint tokenId) external view returns (bool);

    function isUsing(uint tokenId) external view returns (bool);

    function changeUsing(uint tokenId, bool com_) external;

    function CattleOwner(uint tokenId) external view returns (address);

    function getStableLevel(address addr_) external view returns (uint);

    function energy(uint tokenId) external view returns (uint);

    function grow(uint tokenId) external view returns (uint);

    function costEnergy(uint tokenId, uint amount) external;
    
    function addStableExp(address addr, uint amount) external;

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