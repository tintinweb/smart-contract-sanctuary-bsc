// contracts/sale/SaleManager.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "../interfaces/IDependencyManager.sol";
import "../interfaces/IBitmonSpawner.sol";
import "../interfaces/ISuperchargerNFT.sol";

contract SaleManager is ReentrancyGuard, Ownable {
    enum SaleStage {
        Closed,
        Presale,
        Sale1,
        Sale2
    }

    struct WhitelistWalletData {
        uint8 bitmonQty;
        uint8 superchargerQty;
    }

    mapping(address => WhitelistWalletData) private whitelistWalletData;

    SaleStage public saleStage;
    uint256 public presaleEndBlock;
    uint256 public sale1EndBlock;

    // TODO: Check access, because of Solidity reverse notation:
    // https://docs.soliditylang.org/en/v0.8.13/types.html#arrays
    uint256[][] public bitmonStagePrice = [
        [
            250000000000000000,
            600000000000000000,
            1500000000000000000,
            2500000000000000000,
            3200000000000000000,
            4000000000000000000
        ],
        [
            287500000000000000,
            690000000000000000,
            1725000000000000000,
            2875000000000000000,
            3680000000000000000,
            4600000000000000000
        ],
        [
            312500000000000000,
            750000000000000000,
            1875000000000000000,
            3125000000000000000,
            4000000000000000000,
            5000000000000000000
        ]
    ];

    uint256[] public superchargerToSale = [500, 400, 300, 200, 100];

    uint256[][] public superchargerStagePrice = [
        [1200000000000000000, 3000000000000000000, 6000000000000000000, 8800000000000000000, 1200000000000000000],
        [4600000000000000000, 4600000000000000000, 4600000000000000000, 4600000000000000000, 4600000000000000000],
        [5000000000000000000, 5000000000000000000, 5000000000000000000, 5000000000000000000, 5000000000000000000]
    ];

    bytes32 private merkleRootHash;
    IDependencyManager public dependency;
    address public treasury;
    uint8 public constant MAX_PRESALE_BITMON_AMOUNT = 4;
    uint8 public constant MAX_PRESALE_SUPERCHARGER_AMOUNT = 1;
    // TODO: To delete
    bool public bitmonAncientsSold;

    // Define events
    event BitmonEggSold(uint256 _type, uint256 _rarity, uint256 _qty);
    event SuperchargerSold(uint256 _rarity, uint256 _qty);

    /**
     * @dev Sale Manager
     */
    constructor(address _treasury, address _dependency) {
        require(_treasury != address(0), "zero address");
        require(_dependency != address(0), "zero address");

        treasury = _treasury;
        dependency = IDependencyManager(_dependency);
    }

    modifier onlyTreasury() {
        require(msg.sender == treasury, "not allowed");
        _;
    }

    /**
     * @dev Set Treasury
     */
    function setTreasury(address _treasury) external onlyOwner {
        require(_treasury != address(0), "zero address");
        treasury = _treasury;
    }

    /**
     * @dev Set Dependency
     */
    function setDependency(address _dependency) external onlyOwner {
        require(_dependency != address(0), "zero address");
        dependency = IDependencyManager(_dependency);
    }

    /**
     * @dev Set Merkle Root Hash
     */
    function setMerkleRootHash(bytes32 _rootHash) public onlyOwner {
        merkleRootHash = _rootHash;
    }

    /**
     * @dev Set Presale End Block
     */
    function setPresaleEndBlock(uint256 _presaleEndBlock) external onlyOwner {
        require(_presaleEndBlock > 0, "zero block");
        presaleEndBlock = _presaleEndBlock;
    }

    /**
     * @dev Set Sale1 End Block
     */
    function setSale1EndBlock(uint256 _sale1EndBlock) external onlyOwner {
        require(_sale1EndBlock > 0, "zero block");
        sale1EndBlock = _sale1EndBlock;
    }

    /**
     * @dev Set Bitmon Stage Price
     * Set Bitmon price (per rarity) for the stage
     */
    function setBitmonStagePrice(uint256 _stage, uint256[] calldata _newPrice) external onlyOwner {
        require(_stage > 0 && _stage <= bitmonStagePrice.length, "stage not valid");
        require(_newPrice.length == bitmonStagePrice[0].length, "price data not valid");
        bitmonStagePrice[_stage - 1] = _newPrice;
    }

    /**
     * @dev Set Superchargers To Sale
     * When all Superchargers are sold, new qtys can be placed to sale
     */
    function setSuperchargerToSale(uint256[] calldata _newQuantity) external onlyOwner {
        require(_newQuantity.length == superchargerToSale.length, "qty data not valid");
        if (saleStage == SaleStage.Closed) {
            // used for testing
            superchargerToSale = _newQuantity;
        } else {
            unchecked {
                superchargerToSale[0] += _newQuantity[0];
                superchargerToSale[1] += _newQuantity[1];
                superchargerToSale[2] += _newQuantity[2];
                superchargerToSale[3] += _newQuantity[3];
                superchargerToSale[4] += _newQuantity[4];
            }
        }
    }

    /**
     * @dev Set Supercharger Stage Price
     * Set Supercharger price (per rarity) for the stage
     */
    function setSuperchargerStagePrice(uint256 _stage, uint256[] calldata _newPrice) external onlyOwner {
        require(_stage > 0 && _stage <= superchargerStagePrice.length, "stage not valid");
        require(_newPrice.length == superchargerStagePrice[0].length, "price data not valid");
        superchargerStagePrice[_stage - 1] = _newPrice;
    }

    /**
     * @dev Start Presale
     */
    function startPresale() external onlyOwner {
        unchecked {
            presaleEndBlock = block.number + (48 hours / 3);
            sale1EndBlock = presaleEndBlock + (48 hours / 3);
        }
        saleStage = SaleStage.Presale;
    }

    /**
     * @dev Close Sale
     */
    function closeSale() external onlyOwner {
        saleStage = SaleStage.Closed;
    }

    /**
     * @dev Get Current Stage Bitmon Price
     * Get Bitmon price (per rarity) for the current stage
     * While on Stage "Closed" will return presale prices
     */
    function getCurrentStageBitmonPrice() public view returns (uint256[] memory) {
        uint256 stage = uint256(saleStage);
        if (stage > 0) {
            if (block.number >= sale1EndBlock) {
                stage = 3;
            } else if (block.number >= presaleEndBlock) {
                stage = 2;
            }
            unchecked {
                return bitmonStagePrice[stage - 1];
            }
        }
        return bitmonStagePrice[0];
    }

    /**
     * @dev Get Current Stage Supercharger Price
     * Get Supercharger price (per rarity) for the current stage
     * While on Stage "Closed" will return presale prices
     */
    function getCurrentStageSuperchargerPrice() public view returns (uint256[] memory) {
        uint256 stage = uint256(saleStage);
        if (stage > 0) {
            if (block.number >= sale1EndBlock) {
                stage = 3;
            } else if (block.number >= presaleEndBlock) {
                stage = 2;
            }
            unchecked {
                return superchargerStagePrice[stage - 1];
            }
        }
        return superchargerStagePrice[0];
    }

    /**
     * @dev Get Whitelist Wallet Sales
     * Get the number of Bitmon and Supercharger sold to the wallet on PreSale
     */
    function getWhitelistWalletSales(address _wallet) public view returns (uint256, uint256) {
        return (whitelistWalletData[_wallet].bitmonQty, whitelistWalletData[_wallet].superchargerQty);
    }

    /**
     * @dev Modifier onlyWhitelist
     * Ensures that the sender wallet is on the whitelist and saves PreSale data
     */
    modifier onlyWhitelist(
        uint8 _bitmonQty,
        uint8 _superchargerQty,
        bytes32[] calldata _merkleProof
    ) {
        if (saleStage == SaleStage.Presale) {
            bytes32 leafHash = keccak256(abi.encodePacked(msg.sender));
            require(MerkleProof.verify(_merkleProof, merkleRootHash, leafHash), "wallet not in presale list");
            // Save sale qty
            WhitelistWalletData storage data = whitelistWalletData[msg.sender];
            if (_bitmonQty > 0) {
                unchecked {
                    data.bitmonQty += _bitmonQty;
                }
                require(data.bitmonQty <= MAX_PRESALE_BITMON_AMOUNT, "max whitelist qty sold");
            } else {
                unchecked {
                    data.superchargerQty += _superchargerQty;
                }
                require(data.superchargerQty <= MAX_PRESALE_SUPERCHARGER_AMOUNT, "max whitelist qty sold");
            }
        }
        _;
    }

    /**
     * @dev Modifier verifyStage
     * This modifier checks if the stage should be advanced
     */
    modifier verifyStage() {
        if (saleStage == SaleStage.Presale) {
            if (block.number >= presaleEndBlock) {
                saleStage = SaleStage.Sale1;
            }
        }
        if (saleStage == SaleStage.Sale1) {
            if (block.number >= sale1EndBlock) {
                saleStage = SaleStage.Sale2;
            }
        }
        _;
    }

    /**
     * @dev Buy Egg
     */
    function buyEgg(
        uint8 _qty,
        uint256 _type,
        uint256 _rarity,
        bytes32[] calldata _merkleProof
    ) external payable nonReentrant verifyStage onlyWhitelist(_qty, 0, _merkleProof) {
        require(saleStage > SaleStage.Closed, "sale closed");
        require(_qty > 0, "no qty");
        require(_type > 0, "no type");
        require(_rarity > 0 && _rarity < 7, "invalid rarity");
        if (_rarity == 6) {
            require(_type > 6 && _type < 9, "invalid arcane");
        } else {
            require(_type < 7, "invalid type");
        }

        unchecked {
            // Check BNB amount
            uint256 amount = bitmonStagePrice[uint256(saleStage) - 1][_rarity - 1] * _qty;
            require(amount == msg.value, "invalid sent amount");
        }

        emit BitmonEggSold(_type, _rarity, _qty);
        IBitmonSpawner(dependency.getBitmonSpawner()).spawnBitmonEgg(msg.sender, _qty, _type, _rarity);
    }

    /**
     * @dev Buy Supercharger
     */
    function buySupercharger(
        uint8 _qty,
        uint256 _rarity,
        bytes32[] calldata _merkleProof
    ) external payable nonReentrant verifyStage onlyWhitelist(0, _qty, _merkleProof) {
        require(saleStage > SaleStage.Closed, "sale closed");
        require(_qty > 0, "no qty");
        require(_rarity > 0 && _rarity < 6, "invalid rarity");

        // Check BNB amount
        unchecked {
            uint256 amount = superchargerStagePrice[uint256(saleStage) - 1][_rarity - 1] * _qty;
            require(amount == msg.value, "invalid sent amount");
        }
        // This will underflow if try to sell more than available
        superchargerToSale[_rarity - 1] -= _qty;

        emit SuperchargerSold(_rarity, _qty);
        ISuperchargerNFT(dependency.getSuperchargerNFT()).mint(msg.sender, _qty, _rarity);
    }

    /**
     * @dev Allows `treasury` wallet to collect NFT minting fees in BNB.
     */
    function collectBNB() external nonReentrant onlyTreasury {
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "not payable");
    }
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
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Trees proofs.
 *
 * The proofs can be generated using the JavaScript library
 * https://github.com/miguelmota/merkletreejs[merkletreejs].
 * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.
 *
 * See `test/utils/cryptography/MerkleProof.test.js` for some examples.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merklee tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash;
    }
}

// contracts/interfaces/IDependencyManager.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IDependencyManager {
    function getBitmonNFT() external view returns (address);

    function getSuperchargerNFT() external view returns (address);

    function getBitmonSpawner() external view returns (address);

    function getBitmonGeneScientist() external view returns (address);

    function getMarketManager() external view returns (address);

    function getRandomProvider() external view returns (address);

    function getSaleManager() external view returns (address);
}

// contracts/interfaces/IBitmonSpawner.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IBitmonSpawner {
    function spawnBitmonEgg(
        address _recipient,
        uint256 _tokensToMint,
        uint256 _type,
        uint256 _rarity
    ) external;
}

// contracts/interfaces/ISuperchargerNFT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface ISuperchargerNFT {
    function mint(
        address _recipient,
        uint256 _tokensToMint,
        uint256 _rarity
    ) external returns (uint256);

    function getSuperchargerData(uint256 _tokenId) external view returns (uint256);
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