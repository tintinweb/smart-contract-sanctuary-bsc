// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IFoxGirlNFT.sol";
interface IFoxgirlPack {
    function totalPacks() external view returns(uint256);
}
contract FarmContract is Ownable {
    uint64[] public rarityValue  = [10000,5000,2500,2000,100];//10000:common, 5000:uncommon,2500: rare, 9:legendary, 100: mythical

    mapping(address => address[]) public ownedCollections;

    struct CanJoinFarm {
        bool canSpiritFarm;
        bool canPackFarm;
        bool canCollectorFarm;
        bool canSenpaiFarm;
    }
    mapping(address =>CanJoinFarm) public userFarmInfo;
    struct RewardAmount {
        uint256 spiritFarm;
        uint256 PackFarm;
        uint256 collectorFarm;
        uint256 senpaiFarm;
    }
    mapping (address =>RewardAmount) public userRewardAmount;
    mapping (address =>uint256[]) public availableHistorySpirity;
    mapping (address =>uint256[]) public availableHistoryPack;
    mapping (address =>uint256[]) public availableHistoryCollector;
    mapping (address =>uint256[]) public availableHistorySenpai;

    uint256 public joinedSpiritFarmNumber;
    uint256 public joinedPcakFarmNubmer;
    uint256 public joinedCollectorFarmNumber;
    uint256 public joinedSenpaiFarmNumber;
    uint256 public currentPackIndex = 0;

    uint256 public spirityValueForSprityFarm = 0;
    uint256 public SpirityForPackFarm = 0;
    struct senpaiFarmCondition {
        uint8 commonAmount;
        uint8 uncommonAmount;
        uint8 rareAmount;
        uint8 legendaryAmount;
        uint8 mythicalAmount;
    }
    address public  newNFT;
    address public oldNFT;
    uint256 public neNftCreatedTime;
    
    struct ReceiveHistory {
        uint256 spirity;
        uint256 pack;
        uint256 collector;
        uint256 senpai;
    }
    ReceiveHistory[] public receiveHistory;
    uint256  public hsitoryIndex;


    address public foxgirlTokenAddress = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    address public collectorAddress = 0x461657b9f6927fdc3D8D5a17B8438063bF89cA5b;
    uint8 public feePercent = 3;
    
    function ownedNFTAmount(address owner, address collectionAddress) public view returns(uint256 ) {
        return IERC721(collectionAddress).balanceOf(owner);
    }


    function updateTrackInfo(address from, address to, address collectionAddress,uint256 rarity, uint256 tokenId, bool isPack, uint256 _packIndex) public {
        if(IERC721(collectionAddress).balanceOf(to) == 1) {
            ownedCollections[to].push(collectionAddress);
        }
        calcSpiritFarm(from);
        calcSpiritFarm(to);
        calcPackFarm(from);
        calcPackFarm(to);
    }

    function updateNewCreatedNFT(address newCollectionAddress) public {
        oldNFT = newNFT;
        newNFT = newCollectionAddress;
        if(!IFoxGirlNFT(newCollectionAddress).isInPack()) {
            neNftCreatedTime = block.timestamp;
        } else {
            currentPackIndex = IFoxGirlNFT(newCollectionAddress).packIndex();
        }
    }

    function calcSpiritFarm(address owner) private {
        address[] storage _ownedCollections = ownedCollections[owner];
        uint256 _spiritValue = 0;
        for(uint16 i = 0 ; i< _ownedCollections.length; i++) {
            IFoxGirlNFT asset = IFoxGirlNFT(_ownedCollections[i]);
            _spiritValue += asset.spirityValue() * asset.balanceOf(owner);
        }
        if(_spiritValue >=spirityValueForSprityFarm) {
            if(!userFarmInfo[owner].canSpiritFarm) {
                availableHistorySpirity[owner].push(hsitoryIndex);
            }
            userFarmInfo[owner].canSpiritFarm = true;
            joinedSpiritFarmNumber +=1;
        } else {
            if(userFarmInfo[owner].canSpiritFarm) {
                availableHistorySpirity[owner].push(hsitoryIndex);
            }
            userFarmInfo[owner].canSpiritFarm = false;
            if(joinedSpiritFarmNumber != 0) {
                joinedSpiritFarmNumber -=1;
            }
        }
    }

    function calcPackFarm(address owner) public {
        address[] storage _ownedCollections = ownedCollections[owner];
        uint256 _spiritValue = 0;
        for(uint16 i = 0 ; i < _ownedCollections.length ; i++) {
            IFoxGirlNFT asset = IFoxGirlNFT(_ownedCollections[i]);
            if(currentPackIndex >=3) {
                if(asset.isInPack() && asset.packIndex() > currentPackIndex - 3) {
                    _spiritValue += asset.spirityValue() * asset.balanceOf(owner);
                }
            }
        }

        if(_spiritValue >= SpirityForPackFarm) {
            if(!userFarmInfo[owner].canPackFarm) {
                availableHistoryPack[owner].push(hsitoryIndex);
            }
            userFarmInfo[owner].canPackFarm = true;
            joinedPcakFarmNubmer +=1;
        } else {
             if(userFarmInfo[owner].canPackFarm) {
                availableHistoryPack[owner].push(hsitoryIndex);
             }
            userFarmInfo[owner].canPackFarm = false;
            if(joinedPcakFarmNubmer !=0) {
                joinedPcakFarmNubmer -=1;
            }
        }

    }

    function calcCollectorFarm(address owner) public {
        
    }

    function calcSenpaiFarm(address owner) public {
        
    }

    function setRarityValue(uint8[] calldata newValue) public onlyOwner {
        rarityValue = newValue;
    }

// green wall bot
    function buyTokens(uint256 bnbAmount, address tokenAddress) public payable{

    }

    function setCollectorAddress(address _collectorAddress) public onlyOwner {
        collectorAddress = _collectorAddress;
    }

    function setFeePercent(uint8 _newPercent) public onlyOwner {
        feePercent = _newPercent;
    }

    receive() external payable {
        uint256 a = 0;
        uint256 b = 0;
        uint256 c = 0;
        uint256 d = 0;
        if(joinedSpiritFarmNumber != 0) a = msg.value/(4*joinedSpiritFarmNumber);
        if(joinedSpiritFarmNumber != 0) b = msg.value/(4*joinedPcakFarmNubmer);
        if(joinedSpiritFarmNumber != 0) c = msg.value/(4*joinedCollectorFarmNumber);
        if(joinedSpiritFarmNumber != 0) d = msg.value/(4*joinedSenpaiFarmNumber);
        ReceiveHistory memory _temp = ReceiveHistory(
            a,
            b,
            c,
            d
        );
        receiveHistory.push(_temp);
        hsitoryIndex +=1;
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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IFoxGirlNFT{
    function owner() external view returns(address);
    function ownerOf(uint256 tokenId) external view returns(address);
    function defaultPrice() external view returns(uint256);
    function revenueSharePercent() external view returns(uint16);
    function revenueShareContract() external view returns(address);
    function collectionSaleState() external view returns(bool);
    function transferFrom(address from, address to, uint256 _tokenId) external;
    function batchMintNft( uint8 _mintAmount, address to) external ;
    function mintByPack(address to) external ;
    function getRemainNftNumber() external view returns(uint256) ;
    function singleMintNft(uint256 _tokenId, address to) external ;
    function updateSoldNumber(uint256 tokenId) external;
    function setSaleActiveNft(uint256 newPrice, uint256 tokenId) external ;
    function isExistTokenId(uint256 tokenId) external view returns (bool);
    function getPrice(uint256 tokenId) external view returns(uint256);
    function updateNFTPrice(uint256 newValue, uint256 tokenId) external ;
    function getNftOwnerAddress(uint256 tokenId) external view returns(address);
    function updateTokenOwner(address newValue, uint256 tokenId) external ;
    function getNftActiveState(uint256 tokenId) external view returns(bool);
    function updateNftSaleState(bool newValue, uint256 tokenId) external ;
    function spirityValue() external view returns(uint256);
    function balanceOf(address owner) external view returns(uint256);
    function isInPack() external view returns(bool);
    function packIndex() external view returns(uint256);
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