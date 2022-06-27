// contracts/bitmon/BitmonGeneScientist.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IDependencyManager.sol";
import "../interfaces/IBitmonNFT.sol";
import "../interfaces/IRandomProvider.sol";

contract BitmonGeneScientist is Ownable {
    IDependencyManager public dependency;
    uint8 private counter;
    uint256 public incubationTime;

    /**
     * @dev Bitmon Gene Scientist
     */
    constructor(address _dependency, uint256 _incubationTime) {
        require(_dependency != address(0), "zero address");
        require(_incubationTime > 0, "zero incubationTime");
        dependency = IDependencyManager(_dependency);
        incubationTime = _incubationTime;
    }

    modifier onlyBitmonSpawner() {
        require(msg.sender == dependency.getBitmonSpawner(), "not BitmonSpawner");
        _;
    }

    /**
     * @dev Set Dependency
     */
    function setDependency(address _dependency) external onlyOwner {
        require(_dependency != address(0), "zero address");
        dependency = IDependencyManager(_dependency);
    }

    /**
     * @dev Set Incubation Time (in seconds)
     */
    function setIncubationTime(uint256 _incubationTime) external onlyOwner {
        require(_incubationTime > 0, "zero incubationTime");
        incubationTime = _incubationTime;
    }

    /**
     * @dev Get New Egg Genes
     * This function returns the Egg genes
     * TODO: only used from BitmonSpawner, consider moving there to avoid external call
     */
    function getNewEggGenes(
        uint256 _type,
        uint256 _rarity,
        uint256 _parent1Id,
        uint256 _parent2Id
    ) external view returns (uint256) {
        // +---------+---------+---------+-----------------------------
        // |0000 0000|0000 0000|0000 0000|0000 0000 0000 0000 0000 ...
        // +---------+---------+---------+-----------------------------
        //  State     Type      Rarity    empty
        //
        // State: 0 000 0000
        //        - --- ----
        //        |  |   |
        //        |  |   +--> Version of data structure
        //        |  +------> Reserved
        //        +---------> Genome type: 0-Egg, 1-Bitmon
        //                                 When it's a 0, the contained data comes from user selection when
        //                                 the egg was purchased. When it's a 1, there is actual genes data.
        //
        // See docs for a complete reference of data structure
        //
        uint256 genes = (uint256(1) << 248) |
            (_type << 240) |
            (_rarity << 232) |
            (_parent1Id << 96) |
            (_parent2Id << 64) |
            // solhint-disable-next-line not-rely-on-time
            (block.timestamp << 32);

        return genes;
    }

    /**
     * @dev Reveal Egg Genes
     * Function called on egg hatching to reveal the data of the Bitmon
     */
    function revealEggGenes(uint256 _tokenId) external onlyBitmonSpawner returns (uint256) {
        IBitmonNFT bitmon = IBitmonNFT(dependency.getBitmonNFT());
        uint256 currentGenes = bitmon.getGenes(_tokenId);
        uint256 newGenes;

        uint256 state = uint256(currentGenes >> 248);
        require(state < 0x80, "genes already revealed");

        uint256 birthTime = uint256((currentGenes >> 32) & 0xffffffff);
        // solhint-disable-next-line not-rely-on-time
        require(incubationTime < (block.timestamp - birthTime), "too early");

        // Don't need to check version from state, it's allways 1 right now.
        // Read egg rarity
        uint256 rarity = uint256((currentGenes >> 232) & 0xff);

        // prepare mask to transfer data from current to new genes
        // Set new state with revealed bit = 1
        newGenes =
            (currentGenes & 0xffff0000000000000000000000000000ffffffffffffffff0000000000000000) |
            (uint256(1) << 255);

        // Add eclosion time
        // solhint-disable-next-line not-rely-on-time
        newGenes = newGenes | block.timestamp;

        uint256 random = getRandom(_tokenId);

        // Calculate SVs for egg rarity
        newGenes = newGenes | getRaritySvValues(random, rarity);

        // family
        uint256 r = (random >> 128) & 0xf;
        uint256 value;
        if (rarity < 6) {
            // Not Arcane, family 1 to 3
            unchecked {
                value = (r % 3) + 1;
            }
        } else {
            // Arcane, family 1 to 2
            unchecked {
                value = (r % 2) + 1;
            }
        }
        newGenes = newGenes | (value << 176);

        // brilliant
        r = (random >> 132) & 0xfffff;
        bool brilliant = r < 105;
        if (brilliant) {
            value = uint256(1);
        } else {
            value = uint256(0);
        }
        newGenes = newGenes | (uint8(value) << 184);

        // update genes on NFT
        IBitmonNFT(dependency.getBitmonNFT()).setGenes(_tokenId, newGenes);

        return newGenes;
    }

    /**
     * @dev Get Rarity SV Values
     * This function calculates random SVs for each rarity. Used on hatching or spawning Bitmons by rarity
     */
    function getRaritySvValues(uint256 _random, uint256 _rarity) public pure returns (uint256) {
        uint256 r;
        uint256 value;
        uint256 result;
        uint256 divisor;
        uint256 offset;
        uint256 mask;
        uint256 shift;
        uint256 position;

        // calculate parameters for rarity ranks
        if (_rarity == 1) {
            // Common
            // SV values will go from 0 to 3
            divisor = 4;
            offset = 0;
            mask = 0x7;
            shift = 3;
        } else if (_rarity == 2) {
            // Rare
            // SV values will go from 4 to 7
            divisor = 4;
            offset = 4;
            mask = 0x7;
            shift = 3;
        } else if (_rarity == 3) {
            // Special
            // SV values will go from 8 to 11
            divisor = 4;
            offset = 8;
            mask = 0x7;
            shift = 3;
        } else if (_rarity == 4) {
            // Legendary
            // SV values will go from 12 to 16
            divisor = 5;
            offset = 12;
            mask = 0x7F;
            shift = 7;
            // TODO one random up to 20
        } else if (_rarity == 5) {
            // Mythical
            // SV values will go from 17 to 19
            divisor = 3;
            offset = 17;
            mask = 0xF;
            shift = 4;
            // TODO two random up to 20
        } else if (_rarity == 6) {
            // Arcane
            // SV values will go from 17 to 20
            divisor = 4;
            offset = 17;
            mask = 0x7;
            shift = 3;
        }

        unchecked {
            // HP SV
            r = _random & mask;
            value = (r % divisor) + offset;
            result = value << 232;
            position = position + shift;
            // ATK SV
            r = (_random >> position) & mask;
            value = (r % divisor) + offset;
            result = result | (value << 224);
            position = position + shift;
            // DEF SV
            r = (_random >> position) & mask;
            value = (r % divisor) + offset;
            result = result | (value << 216);
            position = position + shift;
            // SA SV
            r = (_random >> position) & mask;
            value = (r % divisor) + offset;
            result = result | (value << 208);
            position = position + shift;
            // SD SV
            r = (_random >> position) & mask;
            value = (r % divisor) + offset;
            result = result | (value << 200);
            position = position + shift;
            // SPE SV
            r = (_random >> position) & mask;
            value = (r % divisor) + offset;
            result = result | (value << 192);
            position = position + shift;

            if (_rarity == 4) {
                // one random up to 20
                r = (_random >> position) & 0x7f;
                uint256 wich = r % 6;
                position = position + 7;
                // get new value
                r = (_random >> position) & 0x3f;
                value = (r % 9) + offset;
                position = position + 6;
                // reset previous value
                mask = 0xff << (192 + wich * 8);
                result = result & ~ mask;
                // set new value
                result = result | (value << (192 + wich * 8));
            }
            
            if (_rarity == 5) {
                // first random up to 20
                r = (_random >> position) & 0x7f;
                uint256 wich = r % 6;
                position = position + 7;
                // get new value
                r = (_random >> position) & 0x7;
                value = (r % 4) + offset;
                position = position + 3;
                // reset previous value
                mask = 0xff << (192 + wich * 8);
                result = result & ~ mask;
                // set new value
                result = result | (value << (192 + wich * 8));

                // second random up to 20
                r = (_random >> position) & 0x7f;
                wich = r % 6;
                position = position + 7;
                // get new value
                r = (_random >> position) & 0x7;
                value = (r % 4) + offset;
                position = position + 3;
                // reset previous value
                mask = 0xff << (192 + wich * 8);
                result = result & ~ mask;
                // set new value
                result = result | (value << (192 + wich * 8));
            }
        }
        return result;
    }

    /**
     * @dev Get Random Bitmon Genes
     * This function calculates random genes values. Used when spawning random Bitmons.
     */
    function getNewBitmonGenes(
        uint256 _type,
        uint256 _rarity,
        uint256 _parent1Id,
        uint256 _parent2Id
    ) external onlyBitmonSpawner returns (uint256) {
        uint256 newGenes = (uint256(0x81) << 248) |
            (_type << 240) |
            (_parent1Id << 96) |
            (_parent2Id << 64) |
            // solhint-disable-next-line not-rely-on-time
            (block.timestamp << 32) |
            // solhint-disable-next-line not-rely-on-time
            block.timestamp;

        // We don't have tokenId here, but it's safe to provide a 0 to get random data
        uint256 random = getRandom(0);

        // If rarity is provided, calculate SVs for that rarity, if not, go full random
        if (_rarity > 0) {
            uint256 svValues = getRaritySvValues(random, _rarity);
            newGenes = newGenes | svValues;
        } else {
            uint256 svValues = getRandomSvValues(random);
            newGenes = newGenes | svValues;
        }

        // family
        uint256 r = (random >> 128) & 0xf;
        uint256 value;
        if (_rarity < 6) {
            // Not Arcane, family 1 to 3
            unchecked {
                value = (r % 3) + 1;
            }
        } else {
            // Arcane, family 1 to 2
            unchecked {
                value = (r % 2) + 1;
            }
        }
        newGenes = newGenes | (value << 176);

        // brilliant
        r = (random >> 132) & 0xfffff;
        bool brilliant = r < 105;
        if (brilliant) {
            value = uint256(1);
        } else {
            value = uint256(0);
        }
        newGenes = newGenes | (uint8(value) << 184);

        return newGenes;
    }

    function getRandomSvValues(uint256 _random) public pure returns (uint256) {
        uint256 r;
        uint256 value;
        uint256 result;

        // HP SV (0 to 20)
        r = _random & 0x1f;
        value = r % 21; // mod bias is our friend here
        result = value << 232;
        // ATK SV (0 to 20)
        r = (_random >> 5) & 0x1f;
        value = r % 21; // mod bias is our friend here
        result = result | (value << 224);
        // DEF SV (0 to 20)
        r = (_random >> 10) & 0x1f;
        value = r % 21; // mod bias is our friend here
        result = result | (value << 216);
        // SA SV (0 to 20)
        r = (_random >> 15) & 0x1f;
        value = r % 21; // mod bias is our friend here
        result = result | (value << 208);
        // SD SV (0 to 20)
        r = (_random >> 20) & 0x1f;
        value = r % 21; // mod bias is our friend here
        result = result | (value << 200);
        // SPE SV (0 to 20)
        r = (_random >> 25) & 0x1f;
        value = r % 21; // mod bias is our friend here
        result = result | (value << 192);

        return result;
    }

    /**
     * @dev Generate a pseudo-random number for the given Bitmon ID
     * We don't need a high secure random number, but we try to reduce the possibilities of forging a good one.
     * Take a look on the approach and let us know your concerns.
     */
    function getRandom(uint256 _tokenId) internal returns (uint256) {
        unchecked {
            // this will overflow intentionally
            counter++;
        }
        // The seed number will depend on the NFT we are working and a local counter
        return IRandomProvider(dependency.getRandomProvider()).getRandom(_tokenId + counter);
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

// contracts/interfaces/IBitmonNFT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IBitmonNFT {
    function mint(
        address _recipient,
        uint256 _tokensToMint,
        uint256 _geneData
    ) external returns (uint256);

    function getGenes(uint256 _tokenId) external view returns (uint256);

    function setGenes(uint256 _tokenId, uint256 _geneData) external;
}

// contracts/interfaces/IRandomProvider.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IRandomProvider {
    function getRandom(uint256 _seed) external view returns (uint256);
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