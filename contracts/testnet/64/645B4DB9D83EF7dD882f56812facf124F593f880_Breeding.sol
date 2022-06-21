// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/INftMinter.sol";
import "./interfaces/ILandNFT.sol";
import "./interfaces/ICowNFT.sol";
import "./interfaces/IBullNFT.sol";


contract Breeding is ReentrancyGuard, Ownable {
    address MILK_TOKEN_ADDRESS;
    address public minterAddr; // NftMinter contract address

    // Structure of BreedingVault
    struct BreedingVault {
        uint cowTokenId; // Staked Cow tokenId
        uint rarity;
        uint cowBreed;
        uint bullTokenId; // Staked Bull tokenId
        uint bullBreed;
        uint unlockTime; // Breeding time
        address owner; // Owner of the couple
    }
    BreedingVault[] public breedingVaults; // Array of BreedingVault

    uint public maxRecoveryTime;
    uint[5] public baseRecoveryTime;
    uint public breedingPrice;
    uint256 rarityProbability;
    uint256 breedProbability;
    uint256 cowProbability;
    mapping(address => uint256[]) public userCows;
    mapping(address => uint256[]) public userBulls;
    bool private initialized;
    event Breed(uint _cowTokenId, uint _bullTokenId, address _owner);
    event ClaimedNewCattle(address _owner, uint _cowTokenId, uint _bullTokenId);
    event StakeCow(address owner, uint256 tokenId);
    event StakeBull(address owner, uint256 tokenId);
    // Initialize the contract. This is for Proxy functionality.
    function initialize(address _minterAddr) public {
        require(_minterAddr != address(0), "Minter contract must be non-zero address");
        require(!initialized, "already initialized");
        minterAddr = _minterAddr;
        maxRecoveryTime = 200 days;
        breedingPrice = 90*10**18;
        rarityProbability = 50;
        breedProbability = 80;
        cowProbability = 90;
        MILK_TOKEN_ADDRESS = 0x3eFA66aB2b1690e9BE8e82784EDfF2cF2dc150e0;

        baseRecoveryTime[0] = 50 minutes;
        baseRecoveryTime[1] = 40 minutes;
        baseRecoveryTime[2] = 30 minutes;
        baseRecoveryTime[3] = 20 minutes;
        baseRecoveryTime[4] = 10 minutes;
        // baseRecoveryTime[0] = 180 hours;
        // baseRecoveryTime[1] = 90 hours;
        // baseRecoveryTime[2] = 48 hours;
        // baseRecoveryTime[3] = 24 hours;
        // baseRecoveryTime[4] = 12 hours;
    }
    function stakeCow(uint256 tokenId) external {
        address _owner = msg.sender;
        INftMinter minter = INftMinter(address(minterAddr));
        ICowNFT cowNfts = ICowNFT(address(minter.cowNftColl()));
        cowNfts.transferFrom(_owner, address(this), tokenId);
        userCows[_owner].push(tokenId);
        emit StakeCow(_owner, tokenId);
    }
    function stakeBull(uint256 tokenId) external {
        address _owner = msg.sender;
        INftMinter minter = INftMinter(address(minterAddr));
        IBullNFT bullNfts = IBullNFT(address(minter.bullNftColl()));
        bullNfts.transferFrom(_owner, address(this), tokenId);
        userBulls[_owner].push(tokenId);
        emit StakeBull(_owner, tokenId);
    }

    function unStakeCow(uint256 tokenId) external {
        INftMinter minter = INftMinter(address(minterAddr));
        ICowNFT cowNfts = ICowNFT(address(minter.cowNftColl()));
        uint256[] storage stakedCows = userCows[msg.sender];
        for(uint256 i = 0; i < stakedCows.length; i++) {
            if(stakedCows[i] == tokenId) {
                stakedCows[i] = stakedCows[stakedCows.length - 1];
                stakedCows.pop();
                cowNfts.transferFrom(address(this), msg.sender, tokenId);
            }
        }
    }
    function unStakeBull(uint256 tokenId) external {
        INftMinter minter = INftMinter(address(minterAddr));
        IBullNFT bullNfts = IBullNFT(address(minter.bullNftColl()));
        uint256[] storage stakedBulls = userBulls[msg.sender];
        for(uint256 i = 0; i < stakedBulls.length; i++) {
            if(stakedBulls[i] == tokenId) {
                stakedBulls[i] = stakedBulls[stakedBulls.length - 1];
                stakedBulls.pop();
                bullNfts.transferFrom(address(this), msg.sender, tokenId);
            }
        }
    }
    // Deposit(Stake) a couple of Cow and Bull NFT for breeding.
    function breed(uint _cowTokenId, uint _bullTokenId) public {
        uint256[] storage cows = userCows[msg.sender];
        uint256[] storage bulls = userBulls[msg.sender];
        bool isStakedCow = false;
        bool isStakedBull = false;
        for(uint256 i = 0 ; i < cows.length; i++) {
            if(cows[i] == _cowTokenId) {
                cows[i] = cows[cows.length - 1];
                cows.pop();
                isStakedCow =true;
            }
        }
        for(uint256 j = 0 ; j <bulls.length; j++) {
            if(bulls[j] == _bullTokenId) {
                bulls[j] = bulls[bulls.length - 1];
                bulls.pop();
                isStakedBull = true;
            }
        }
        require(isStakedCow, "unstaked cow token");
        require(isStakedBull, "unStaked bull token");
        INftMinter minter = INftMinter(address(minterAddr));
        ICowNFT cowNfts = ICowNFT(address(minter.cowNftColl()));
        IBullNFT bullNfts = IBullNFT(address(minter.bullNftColl()));
        // require(cowNfts.ownerOf(_cowTokenId) == msg.sender, "Not owner");
        // require(bullNfts.ownerOf(_bullTokenId) == msg.sender, "Not owner");
        ICowNFT.CattleAttr memory cowAttr = cowNfts.attrOf(_cowTokenId);
        IBullNFT.CattleAttr memory bullAttr = bullNfts.attrOf(_bullTokenId);
        uint256 _old = block.timestamp - bullAttr.birth;

        require(cowAttr.rarity == bullAttr.rarity, "Breeding is impossible between different rarity");
        require(maxRecoveryTime > _old, "Bull is too old");
        IERC20(address(MILK_TOKEN_ADDRESS)).transferFrom(msg.sender, address(this), breedingPrice);

        BreedingVault memory newBreeding;
        newBreeding.cowTokenId = _cowTokenId;
        newBreeding.bullTokenId = _bullTokenId;
        newBreeding.cowBreed = cowAttr.breed;
        newBreeding.rarity = cowAttr.rarity;
        newBreeding.bullBreed = bullAttr.breed;
        newBreeding.owner = msg.sender;

        uint256 weight =1e8 - ((maxRecoveryTime - _old) * 1e8) / maxRecoveryTime;
        newBreeding.unlockTime = block.timestamp + baseRecoveryTime[bullAttr.rarity] + (baseRecoveryTime[bullAttr.rarity] * weight) /1e8;
        breedingVaults.push(newBreeding);
        emit Breed(_cowTokenId, _bullTokenId, msg.sender);
    }

    // Claim newly breeded cattle(Cow or Bull NFT).
    // Rarity : 80%(Parents rarity), 20%(Parents' rarity + 1)
    // Breed : 50%(Cow's breed), 50%(Bull's breed)
    // Cow or Bull : 95%(Cow), 5%(Bull)
    function claimCattle(uint _bullTokenId) public {
        uint breedingIdx = _indexOfBreedingByBull(_bullTokenId);
        address _owner = breedingVaults[breedingIdx].owner;
        uint256 _cowTokenId = breedingVaults[breedingIdx].cowTokenId;
        // uint256 _bullTokenId = breedingVaults[breedingIdx].bullTokenId;
        require(_owner == msg.sender, "Not owner");
        require(block.timestamp > breedingVaults[breedingIdx].unlockTime, "Wait until Recovery");

        INftMinter minter = INftMinter(address(minterAddr));
        ICowNFT cowNfts = ICowNFT(address(minter.cowNftColl()));
        ICowNFT.CattleAttr memory cowAttr = cowNfts.attrOf(_cowTokenId);

        IBullNFT bullNfts = IBullNFT(address(minter.bullNftColl()));
        IBullNFT.CattleAttr memory bullAttr = bullNfts.attrOf(_bullTokenId);
        
        uint8 rarityOfNew = 0;
        uint8 breedOfNew = bullAttr.breed;

        uint randProbability = _rand(100);
        if(randProbability < rarityProbability || bullAttr.rarity == 4) {
            rarityOfNew = bullAttr.rarity;
        } else {
            rarityOfNew = bullAttr.rarity + 1;
        }

        if(randProbability < breedProbability) {
            breedOfNew = cowAttr.breed;
        }

        if(randProbability < cowProbability) {
            minter.mintCow(_owner, rarityOfNew, breedOfNew);
        } else {
            minter.mintBull(_owner, rarityOfNew, breedOfNew);
        }

        // cowNfts.transferFrom(address(this), breedingVaults[breedingIdx].owner, breedingVaults[breedingIdx].cowTokenId);
        // bullNfts.transferFrom(address(this), breedingVaults[breedingIdx].owner, breedingVaults[breedingIdx].bullTokenId);
        userCows[_owner].push(_cowTokenId);
        userBulls[_owner].push(_bullTokenId);

        emit ClaimedNewCattle(_owner, _cowTokenId, _bullTokenId);

        breedingVaults[breedingIdx] = breedingVaults[breedingVaults.length - 1];
        breedingVaults.pop();
    }

    // Set breeding price
    function setBreedingPrice(uint _price) public onlyOwner {
        breedingPrice = _price;
    }

    // Withdraw MILK tokens.
    function withdrawMilk() public onlyOwner{
        IERC20 payToken = IERC20(address(MILK_TOKEN_ADDRESS));
        uint amountOf = payToken.balanceOf(address(this));
        payToken.transfer(msg.sender, amountOf);
    }

    function _indexOfBreedingByBull(uint _bullTokenId) private view returns (uint) {
        uint idx = 0;
        for(idx = 0;idx < breedingVaults.length;idx ++){
            if(breedingVaults[idx].bullTokenId == _bullTokenId) {
                return idx;
            }
        }
        return idx;
    }

    function _rand(uint _modulus) internal view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % _modulus;
    }

    function getBreedingItems(address userAddress) public view 
    returns(
        uint256[] memory ,
        uint256[] memory ,
        uint256[] memory ,
        uint256[] memory ,
        uint256[] memory ,
        uint256[] memory 
    ) {
        uint k = 0;
        uint ownedCount = 0;
        for(uint j = 0 ; j< breedingVaults.length ; j ++ ) {
            if(breedingVaults[j].owner == userAddress) {
                ownedCount +=1;
            }
        }
        uint256[] memory cowTokenIds = new uint256[](ownedCount);
        uint256[] memory raritis = new uint256[](ownedCount);
        uint256[] memory cowBreeds = new uint256[](ownedCount);
        uint256[] memory bullTokenIds = new uint256[](ownedCount);
        uint256[] memory bullBreeds = new uint256[](ownedCount);
        uint256[] memory unLockTimes = new uint256[](ownedCount);
        for(uint i = 0 ; i < breedingVaults.length; i++) {
            if(breedingVaults[i].owner == userAddress) {
                cowTokenIds[k] = breedingVaults[i].cowTokenId;
                raritis[k] = breedingVaults[i].rarity;
                cowBreeds[k] = breedingVaults[i].cowBreed;
                bullTokenIds[k] = breedingVaults[i].bullTokenId;
                bullBreeds[k] = breedingVaults[i].bullBreed;
                unLockTimes[k] = breedingVaults[i].unlockTime;
                k +=1;
            }
        }
        return (cowTokenIds, raritis,cowBreeds,bullTokenIds,bullBreeds,unLockTimes);
    }
    function setProbabilities(uint256 _rarityP, uint256 _breedP, uint256 _cowP) public onlyOwner {
        rarityProbability = _rarityP;
        breedProbability = _breedP;
        cowProbability = _cowP;
    }
    function cancelBreeding(uint256 _breedingIdx) public {
        BreedingVault memory _breedingData = breedingVaults[_breedingIdx];
        uint256 itemCount = breedingVaults.length;
        INftMinter minter = INftMinter(address(minterAddr));
        ICowNFT cowNfts = ICowNFT(address(minter.cowNftColl()));
        IBullNFT bullNfts = IBullNFT(address(minter.bullNftColl()));

        require(_breedingData.owner == msg.sender, "not owner");
        cowNfts.transferFrom(address(this), breedingVaults[_breedingIdx].owner, breedingVaults[_breedingIdx].cowTokenId);
        bullNfts.transferFrom(address(this), breedingVaults[_breedingIdx].owner, breedingVaults[_breedingIdx].bullTokenId);
        breedingVaults[_breedingIdx] = breedingVaults[itemCount -1];
        breedingVaults.pop();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

interface INftMinter{

  function initialize(address _landCollAddr, address _cowCollAddr, address _bullCollAddr) external;

  function mintLand(address _owner, uint8 _rarity, uint8 _type) external;
  function mintCow(address _owner, uint8 _rarity, uint8 _breed) external;
  function mintBull(address _owner, uint8 _rarity, uint8 _breed) external;

  function landNftColl() external view returns (address);
  function setLandNftColl(address) external;
  function cowNftColl() external view returns (address);
  function setCowNftColl(address) external;
  function bullNftColl() external view returns (address);
  function setBullNftColl(address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ILandNFT is IERC721 {
  struct LandAttr{
    uint8 rarity;
    uint8 landType;
  }
  function mint(uint8 _rarity, uint8 _landType, address) external;
  function setBaseTokenURI(string memory _baseUri) external;
  function attrOf(uint _tokenId) external view returns (LandAttr memory);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ICowNFT is IERC721 {
  struct CattleAttr{
    uint8 rarity;
    uint8 breed;
    uint256 birth;
  }
  function mint(uint8 _rarity, uint8 _breed, address _owner) external;
  function burn(uint _tokenId) external;
  function setBaseTokenURI(string memory _baseUri) external;
  function attrOf(uint _tokenId) external view returns (CattleAttr memory);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IBullNFT is IERC721 {
  struct CattleAttr{
    uint8 rarity;
    uint8 breed;
    uint256 birth;
  }
  function mint(uint8 _rarity, uint8 _breed, address _owner) external;
  function burn(uint _tokenId) external;
  function setBaseTokenURI(string memory _baseUri) external;
  function attrOf(uint _tokenId) external view returns (CattleAttr memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
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