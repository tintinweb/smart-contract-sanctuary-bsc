// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0 <0.8.0;
pragma abicoder v2;

import "../Library/Context.sol";
import "../Library/Ownable.sol";
import "../Library/SafeMath.sol";
import "../Library/IERC1155.sol";
import "../Library/IERC721.sol";
import "../Library/IERC1155Receiver.sol";
import "./MowaCore.sol";
import "./MowaItemsCore.sol";

contract MowaNFTPetUpgradeLevelV3 is Ownable {
    using SafeMath for uint256;
    MowaCore public mowaCoreV1;
    IERC721 public mowaNFTV1;
    MowaCore public mowaCoreV2;
    IERC721 public mowaNFTV2;
    MowaItemsCore public mowaItemsCore;
    IERC1155 public mowaItemsNFT;

    address public addressBurn = 0x309d4172B8A0B3883263EC9622651d88aA1B0972;
    mapping(address => bool) public blackList;
    mapping(uint256 => bool) public TokenIdblackList;

    struct UserUpgrade {
        uint256 tokenId;
        uint256 levelOld;
        uint256 levelNew;
    }
    mapping(address => UserUpgrade) public userUpgrade;

    mapping(uint256 => uint256) public pointPet;

    struct PointGems {
        uint256 characterId;
        uint256 point;
    }
    mapping(uint256 => PointGems) public pointGems;

    constructor(
        MowaCore _mowaCoreV1,
        IERC721 _mowaNFTV1,
        MowaCore _mowaCoreV2,
        IERC721 _mowaNFTV2,
        MowaItemsCore _mowaItemsCore,
        IERC1155 _mowaItemsNFT
    ) {
        mowaCoreV1 = MowaCore(_mowaCoreV1);
        mowaNFTV1 = _mowaNFTV1;
        mowaNFTV2 = _mowaNFTV2;
        mowaCoreV2 = MowaCore(_mowaCoreV2);
        mowaItemsCore = MowaItemsCore(_mowaItemsCore);
        mowaItemsNFT = _mowaItemsNFT;
        pointPet[2] = 8;
        pointPet[3] = 20;
        pointPet[4] = 48;
        pointPet[5] = 112;
        pointPet[6] = 256;
        pointPet[7] = 576;
        pointPet[8] = 1280;
        pointPet[9] = 2816;
        pointGems[1] = PointGems(24 ,1);
        pointGems[2] = PointGems(25 ,2);
        pointGems[3] = PointGems(26 ,4);
        pointGems[4] = PointGems(27 ,8);
        pointGems[5] = PointGems(28 ,16);
        pointGems[6] = PointGems(29 ,32);
        pointGems[7] = PointGems(30 ,64);
        pointGems[8] = PointGems(31 ,128);
        pointGems[9] = PointGems(32 ,256);
    }

    function setBlackList(address[] memory _user, bool _block) onlyOwner public {
        for (uint256 index; index < _user.length; index++) {
            blackList[_user[index]] = _block;
        }
    }
    function setTokenIdblackList(uint256[] memory _tokenId, bool _block) onlyOwner public {
        for (uint256 index; index < _tokenId.length; index++) {
            TokenIdblackList[_tokenId[index]] = _block;
        }
    }
    function changePointPet(uint256 level, uint256 point) onlyOwner public {
        pointPet[level] = point;
    }
    function changePointGems(uint256 level, uint256 point) onlyOwner public {
        pointGems[level].point = point;
    }

    function petUpgradeLevel(
        uint256[] memory qtyGems,
        uint256 _tokenIdPet
    ) public {
        require(blackList[_msgSender()] == false, "owner has been locked");
        require(TokenIdblackList[_tokenIdPet] == false, "TokenId in black list");
        require(_tokenIdPet > 0, "TokenId Pet not zero");
        userUpgrade[_msgSender()].tokenId = _tokenIdPet;

        uint256 level = mowaCoreV2.getNFT(_tokenIdPet).level;
        uint256 version = 2;
        if (level == 0) {
            level = mowaCoreV1.getNFT(_tokenIdPet).level;
            version = 1;
            require(_msgSender() == mowaNFTV1.ownerOf(_tokenIdPet), "Not the owner of this nft");
        } else {
            require(_msgSender() == mowaNFTV2.ownerOf(_tokenIdPet), "Not the owner of this nft");
        }
        userUpgrade[_msgSender()].levelOld = level;

        uint256 _pointGems = calculatePoint(qtyGems);
        require(_pointGems > 0, "Qty Gems not zero");

        uint256 levelNew = getLevelPet(_pointGems, level);
        if(levelNew <= level){
            revert("Gems points are not enough to upgrade to a new level");
        }
        calculateFeeUpgrade(levelNew, level);
        userUpgrade[_msgSender()].levelNew = levelNew;
        if (version == 1) {
            mowaCoreV2.safeMintNFT(_msgSender(), _tokenIdPet);
            Mowa memory mowa = mowaCoreV1.getNFT(_tokenIdPet);
            mowa.level = levelNew;
            mowaCoreV2.setNFTFactory(mowa, _tokenIdPet);
            mowaNFTV1.transferFrom(_msgSender(), addressBurn, _tokenIdPet);
        } else {
            mowaCoreV2.changeLevel(_tokenIdPet, levelNew);
        }
    }

    function calculateFeeUpgrade(uint256 _levelNew, uint256 level) internal {
        for(_levelNew; _levelNew > level; _levelNew--){
            burnNFTItems(_levelNew, 1);
        }
    }

    function calculatePoint(uint256[] memory qtyGems) internal returns (uint256 point) {
        require(qtyGems.length == 9, "requires the quantity list to be from 1 to 9");
        point = 0;
        for(uint256 i = 0; i < qtyGems.length; i++){
            if(qtyGems[i] > 0){
                uint256 _levelGems = i + 1;
                point += pointGems[_levelGems].point * qtyGems[i];
                burnNFTItems(_levelGems, qtyGems[i]);
            }
        }
        return point;
    }

    function burnNFTItems(uint256 gemLevel, uint256 qty) internal {
        uint256 tokenId = mowaItemsCore.getTokenWithCharacter(pointGems[gemLevel].characterId);
        require(mowaItemsNFT.balanceOf(_msgSender(), tokenId) >= qty, "not enough gems to upgrade");
        mowaItemsCore.burnNFT(_msgSender(), tokenId, qty);
    }

    function getLevelPet(uint256 point, uint256 _level) public view returns (uint256 level) {
        uint256 pointRequest;
        _level += 1;
        for(_level; _level <= 9; _level++){
            pointRequest += pointPet[_level];
            if(pointRequest == point || ( _level == 9 && pointRequest < point)){
                return _level;
            } else if(pointRequest > point) {
                return _level - 1;
            }
        }
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.7.6;
pragma abicoder v2;

struct MowaItems {
    uint256 character;
    uint256 class;
    uint256 level;
    uint256 star;
    uint256 characterPet;
    uint256 attr1;
    uint256 attr2;
    uint256 attr3;
}

interface MowaItemsCore {
    function getNFT(uint256 _tokenId) external view returns (MowaItems memory);
    function setNFTFactory(MowaItems memory _mowa, uint256 _tokenId) external;
    function safeMintNFT(address _addr, uint256 tokenId, uint256 amount) external;
    function safeBatchMintNFT(address _addr, uint256[] memory tokenId, uint256[] memory amount) external;
    function burnNFT(address _addr, uint256 tokenId, uint256 amount) external;
    function burnBatchNFT(address _addr, uint256[] memory ids, uint256[] memory amounts) external;
    function getAllNFT(uint256 _fromTokenId, uint256 _toTokenId) external view returns (MowaItems[] memory);
    function getNextNFTId() external view returns (uint256);
    function getTokenWithCharacter(uint256 _character) external view returns (uint256);
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.7.6;
pragma abicoder v2;

struct Mowa {
    uint256 tokenId;
    uint256 level;
    uint256 skill;
    uint256 star;
    uint256 character;
    uint256 class;
    uint256 bornTime;
}

interface MowaCore {
    function changeLevel(
        uint256 _tokenId,
        uint256 _level
    ) external;

    function changeClass(
        uint256 _tokenId,
        uint256 _class
    ) external;

    function changeSkill(
        uint256 _tokenId,
        uint256 _skill
    ) external;

    function changeCharacter(
        uint256 _tokenId,
        uint256 _character
    ) external;

    function changeStar(
        uint256 _tokenId,
        uint256 _star
    ) external;

    function getNFT(uint256 _tokenId) external view returns (Mowa memory);
    function setNFTFactory(Mowa memory _mowa, uint256 _tokenId) external;
    function safeMintNFT(address _addr, uint256 tokenId) external;
    function getAllNFT(uint256 _fromTokenId, uint256 _toTokenId) external view returns (Mowa[] memory);
    function getNextNFTId() external view returns (uint256);
    function safeBurnNFT(uint256 tokenId) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "./Context.sol";
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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }    
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC165.sol";

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
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

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
    function transferFrom(address from, address to, uint256 tokenId) external;

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
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity ^0.7.0;

import "./IERC165.sol";

/**
 * _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {

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
    )
        external
        returns(bytes4);

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
    )
        external
        returns(bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "./IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event Burn(address indexed account, uint256 id, uint256 value);
    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);
    event BurnBatch(address indexed account, uint256[] ids, uint256[] values);

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
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

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
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

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
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

    function ownerOf(uint256 tokenId) external view returns (address[] memory);
    function _exists(address account, uint256 tokenId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}