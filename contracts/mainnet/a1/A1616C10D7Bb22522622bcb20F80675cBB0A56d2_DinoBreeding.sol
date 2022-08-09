// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import "../../core/interface/IDinolandNFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../evolve_lab/IEvolveLab.sol";
import "../breed_stone/IBreedStone.sol";
import "./IDinoGenesScience.sol";
import "../heaven_stone/IHeavenStone.sol";

contract DinoBreeding is OwnableUpgradeable {
    function initialize() public initializer {
        __Ownable_init();
        blockTime = 3;
        maxBreedCount = 5;
        breedCountToBreedPrice[0] = 800 * 1e18;
        breedCountToBreedPrice[1] = 1250 * 1e18;
        breedCountToBreedPrice[2] = 2500 * 1e18;
        breedCountToBreedPrice[3] = 3750 * 1e18;
        breedCountToBreedPrice[4] = 6250 * 1e18;

        minLifeDurationToBreed = 30 days;
    }

    event BabyDinoBorned(address indexed owner, uint256 indexed dinoId);

    IDinolandNFT public nftContract;
    IEvolveLab public evolveLabContract;
    IBreedStone public breedStoneContract;
    IDinoGenesScience public dinoGenesScienceContract;
    IERC20 public tokenContract;
    uint256 public blockTime;
    uint256 public maxBreedCount;
    uint256 public minLifeDurationToBreed;
    mapping(uint256 => uint256) public breedCountToBreedPrice;

    uint256 constant NOVIS_CLASS = 0;
    uint256 constant AQUIS_CLASS = 1;
    uint256 constant TERROS_CLASS = 2;
    uint256 constant DARK_CLASS = 3;

    mapping(uint256 => uint256) public dinoIdToBreedCount;
    mapping(uint256 => uint256) public dinoIdToFatherId;
    mapping(uint256 => uint256) public dinoIdToMotherId;
    mapping(uint256 => uint256[]) public dinoIdToChildrenIds;

    IHeavenStone public heavenStoneContract;
    uint256 constant LIGHT_CLASS = 4;

    function setHeavenStoneContract(IHeavenStone _heavenStoneContract)
        public
        onlyOwner
    {
        heavenStoneContract = _heavenStoneContract;
    }

    function getChildrenIdsByDinoId(uint256 _dinoId)
        external
        view
        returns (uint256[] memory)
    {
        return dinoIdToChildrenIds[_dinoId];
    }

    function setBreedCountToBreedPrice(uint256 _breedCount, uint256 _price)
        external
        onlyOwner
    {
        require(_breedCount <= maxBreedCount, "Breed count is out of range");
        breedCountToBreedPrice[_breedCount] = _price;
    }

    function setMaxBreedCount(uint256 _maxBreedCount) external onlyOwner {
        maxBreedCount = _maxBreedCount;
    }

    function setMinLifeTimeToBreed(uint256 _minLifeDurationToBreed)
        external
        onlyOwner
    {
        minLifeDurationToBreed = _minLifeDurationToBreed;
    }

    function setBlockTime(uint256 _blockTime) external onlyOwner {
        blockTime = _blockTime;
    }

    function setTokenContract(address _tokenContract) external onlyOwner {
        tokenContract = IERC20(_tokenContract);
    }

    function setDinoGenesScienceContract(
        IDinoGenesScience _dinoGenesScienceContract
    ) external onlyOwner {
        dinoGenesScienceContract = _dinoGenesScienceContract;
    }

    function setNftContract(IDinolandNFT _nftContract) external onlyOwner {
        nftContract = _nftContract;
    }

    function setEvolveLabContract(IEvolveLab _evolveLabContract)
        external
        onlyOwner
    {
        evolveLabContract = _evolveLabContract;
    }

    function setBreedStoneContract(IBreedStone _breedStoneContract)
        external
        onlyOwner
    {
        breedStoneContract = _breedStoneContract;
    }

    function withdrawToken(uint256 _amount, address _to) external onlyOwner {
        tokenContract.transfer(_to, _amount);
    }

    struct Dino {
        uint256 id;
        uint256 genes;
        uint256 bornAt;
        uint256 cooldownEndAt;
        uint128 gender;
        uint128 generation;
    }

    function getBreedingFee(uint256 _sireId, uint256 _matronId)
        public
        view
        returns (uint256)
    {
        return
            breedCountToBreedPrice[dinoIdToBreedCount[_sireId]] +
            breedCountToBreedPrice[dinoIdToBreedCount[_matronId]];
    }

    function breed(
        uint256 _sireId,
        uint256 _matronId,
        uint256 _breedStoneId
    ) external {
        /// @dev Get the Breeding Fee
        uint256 breedingFee = getBreedingFee(_sireId, _matronId);
        tokenContract.transferFrom(msg.sender, address(this), breedingFee);

        Dino memory sireDino;
        Dino memory matronDino;
        (
            sireDino.genes,
            sireDino.bornAt,
            ,
            sireDino.gender,
            sireDino.generation
        ) = nftContract.getDino(_sireId);
        (
            matronDino.genes,
            matronDino.bornAt,
            ,
            matronDino.gender,
            matronDino.generation
        ) = nftContract.getDino(_matronId);
        sireDino.id = _sireId;
        matronDino.id = _matronId;

        /// @dev Validate the max breed count
        require(
            dinoIdToBreedCount[_sireId] <
                dinoGenesScienceContract.getMaxBreedCountByGenes(
                    sireDino.genes
                ),
            "DinoBreeding: Sire is already at max breed count"
        );
        require(
            dinoIdToBreedCount[_matronId] <
                dinoGenesScienceContract.getMaxBreedCountByGenes(
                    matronDino.genes
                ),
            "DinoBreeding: Matron is already at max breed count"
        );

        /// @dev Increase breed count
        dinoIdToBreedCount[_sireId] += 1;
        dinoIdToBreedCount[_matronId] += 1;

        /// @dev Make sure two dino is old enough to breed
        require(
            sireDino.bornAt + minLifeDurationToBreed < block.timestamp,
            "DinoBreeding: Sire is not old enough to breed"
        );
        require(
            matronDino.bornAt + minLifeDurationToBreed < block.timestamp,
            "DinoBreeding: Matron is not old enough to breed"
        );
        /// @dev Validate the premission of the sender
        require(
            nftContract.ownerOf(sireDino.id) == msg.sender,
            "DinoBreeding: You are not the owner of the sire dino"
        );
        require(
            nftContract.ownerOf(matronDino.id) == msg.sender,
            "DinoBreeding: You are not the owner of the matron dino"
        );
        require(
            sireDino.id != matronDino.id,
            "DinoBreeding: Sire and matron need to be different"
        );
        /// @dev Make sure the sire and matron are already evolved
        require(
            evolveLabContract.isEvolved(sireDino.id) ||
                !evolveLabContract.isOldGenes(sireDino.id),
            "DinoBreeding: Sire is not evolved"
        );
        require(
            evolveLabContract.isEvolved(matronDino.id) ||
                !evolveLabContract.isOldGenes(matronDino.id),
            "DinoBreeding: Matron is not evolved"
        );
        /// @dev Make sure the sire and matron are not the same gender
        require(sireDino.gender == 1, "DinoBreeding: Sire gender is not valid");
        require(
            matronDino.gender == 2,
            "DinoBreeding: Matron gender is not valid"
        );
        /// @dev Dino can not breed with siblings and parent
        if (sireDino.generation > 1 || matronDino.generation > 1) {
            if (
                dinoIdToFatherId[sireDino.id] > 0 &&
                dinoIdToFatherId[matronDino.id] > 0
            ) {
                require(
                    dinoIdToFatherId[sireDino.id] !=
                        dinoIdToFatherId[matronDino.id] &&
                        dinoIdToMotherId[sireDino.id] !=
                        dinoIdToMotherId[matronDino.id],
                    "DinoBreeding: Sire and matron can not be siblings"
                );
            }
            require(
                dinoIdToFatherId[matronDino.id] != sireDino.id,
                "DinoBreeding: Sire can not be matron's parent"
            );
            require(
                dinoIdToMotherId[sireDino.id] != matronDino.id,
                "DinoBreeding: Matron can not be sire's parent"
            );
        }
        /// @dev Get class of the parents and validate the Breed Stone type
        uint256 sireClass = dinoGenesScienceContract.expressingClassDino(
            sireDino.genes
        );
        uint256 matronClass = dinoGenesScienceContract.expressingClassDino(
            matronDino.genes
        );
        (StoneType stoneType, ) = breedStoneContract.getBreedStoneDetail(
            _breedStoneId
        );
        
        if(matronClass == LIGHT_CLASS) {
            require(sireClass != DARK_CLASS, "DinoBreeding: Can not breed dark and light");
        }
        if(sireClass == LIGHT_CLASS) {
            require(matronClass != DARK_CLASS, "DinoBreeding: Can not breed dark and light");
        }

        if (matronClass == LIGHT_CLASS || sireClass == LIGHT_CLASS) {
            require(
                heavenStoneContract.ownerOf(_breedStoneId) == msg.sender,
                "DinoBreeding: You are not the owner of the breed stone"
            );
            heavenStoneContract.burn(_breedStoneId);
        } else {
            require(
                breedStoneContract.ownerOf(_breedStoneId) == msg.sender,
                "DinoBreeding: You are not the owner of the breed stone"
            );
            if (matronClass == sireClass) {
                if (matronClass == DARK_CLASS) {
                    require(
                        stoneType == StoneType.Moon,
                        "DinoBreeding: Need Moon Stone"
                    );
                } else {
                    if (stoneType == StoneType.Rainbow) {} else if (
                        matronClass == NOVIS_CLASS
                    ) {
                        require(
                            stoneType == StoneType.Fire,
                            "DinoBreeding: Need Fire Stone"
                        );
                    } else if (matronClass == AQUIS_CLASS) {
                        require(
                            stoneType == StoneType.Water,
                            "DinoBreeding: Need Water Stone"
                        );
                    } else if (matronClass == TERROS_CLASS) {
                        require(
                            stoneType == StoneType.Leaf,
                            "DinoBreeding: Need Leaf Stone"
                        );
                    }
                }
            } else {
                if (matronClass == DARK_CLASS || sireClass == DARK_CLASS) {
                    require(
                        stoneType == StoneType.Moon,
                        "DinoBreeding: Need Moon Stone"
                    );
                } else {
                    require(
                        stoneType == StoneType.Rainbow,
                        "DinoBreeding: Need Rainbow Stone"
                    );
                }
            }
            /// @dev Burn the stone
            breedStoneContract.burn(_breedStoneId);
        }

        /// @dev Create a new baby dino
        uint256 targetBlock = ((sireDino.bornAt + matronDino.bornAt) / 2) /
            blockTime;
        uint256 babyGenes = dinoGenesScienceContract.mixGenesDinos(
            sireDino.genes,
            matronDino.genes,
            targetBlock
        );
        uint256 babyGender = (uint256(
            keccak256(
                abi.encodePacked(
                    sireDino.genes,
                    matronDino.genes,
                    block.timestamp
                )
            )
        ) % 2) + 1;
        uint256 babyGeneration = sireDino.generation > matronDino.generation
            ? sireDino.generation + 1
            : matronDino.generation + 1;
        uint256 babyId = nftContract.createDino(
            babyGenes,
            msg.sender,
            uint128(babyGender),
            uint128(babyGeneration)
        );
        dinoIdToFatherId[babyId] = sireDino.id;
        dinoIdToMotherId[babyId] = matronDino.id;
        dinoIdToChildrenIds[sireDino.id].push(babyId);
        dinoIdToChildrenIds[matronDino.id].push(babyId);
        evolveLabContract.setEvolved(babyId, true);
        emit BabyDinoBorned(msg.sender, babyId);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
interface IDinolandNFT is IERC721 {
    function createDino(
        uint256 _dinoGenes,
        address _ownerAddress,
        uint128 _gender,
        uint128 _generation
    ) external returns (uint256);

    function getDinosByOwner(address _owner)
        external
        returns (uint256[] memory);

    function getDino(uint256 _dinoId)
        external
        view
        returns (
            uint256 genes,
            uint256 bornAt,
            uint256 cooldownEndAt,
            uint128 gender,
            uint128 generation
        );

    function evolveDino(uint256 _dinoId, uint256 _newGenes) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IHeavenStone is IERC721 {
    function burn(uint256 _tokenId) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IEvolveLab {
    function isEvolved(uint256 _dinoId) external returns (bool);

    function isOldGenes(uint256 _dinoId) external returns (bool);

    function setEvolved(uint256 _id, bool _isEvolved) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IDinoGenesScience {
    function decodeDino(uint256 _genes) external pure returns (uint8[] memory);

    function expressingTraitsDino(uint256 _genes)
        external
        pure
        returns (uint8[7] memory);

    function expressingClassDino(uint256 _genes) external pure returns (uint8);

    function getMaxBreedCountByGenes(uint256 _genes) external view returns(uint256 maxBreedCount);

    function mixGenesDinos(
        uint256 _genes1,
        uint256 _genes2,
        uint256 _targetBlock
    ) external returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
enum StoneType {
    Fire,
    Water,
    Leaf,
    Rainbow,
    Moon
}

interface IBreedStone is IERC721 {
    function burn(uint256 _tokenId) external;

    function getBreedStoneDetail(uint256 _stoneId)
        external
        view
        returns (StoneType stoneType, uint256 createdAt);
}

// SPDX-License-Identifier: MIT

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

pragma solidity ^0.8.0;

/*
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

pragma solidity ^0.8.0;

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

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
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
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

pragma solidity ^0.8.0;

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
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}

// SPDX-License-Identifier: MIT

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
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}