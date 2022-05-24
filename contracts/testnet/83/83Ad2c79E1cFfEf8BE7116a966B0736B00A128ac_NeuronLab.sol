// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IECIONFTCore {
    function tokenInfo(uint256 _tokenId)
        external
        view
        returns (string memory, uint256);

    function ownerOf(uint256 _tokenId) external view returns (address);

    function burn(uint256 _tokenId) external;

    function safeMint(address _to, string memory partCode) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

interface IRandomWorker {
    function startRandom() external returns (uint256);
}

interface ISuccessRate {
    function getSuccessRate(
        uint16 starNum,
        uint16 cardNum,
        uint16 _number
    ) external view returns (uint16);
}

interface IGnenomRarity {
    function getGenomRarity(string memory genomPart) external view returns (uint16);
}

contract NeuronLab is Ownable, ReentrancyGuard {
    //Part Code Index
    uint256 constant PC_NFT_TYPE = 12;
    uint256 constant PC_KINGDOM = 11;
    uint256 constant PC_CAMP = 10;
    uint256 constant PC_GEAR = 9;
    uint256 constant PC_DRONE = 8;
    uint256 constant PC_SUITE = 7;
    uint256 constant PC_BOT = 6;
    uint256 constant PC_GENOME = 5;
    uint256 constant PC_WEAPON = 4;
    uint256 constant PC_STAR = 3;
    uint256 constant PC_EQUIPMENT = 2;
    uint256 constant PC_RESERVED1 = 1;
    uint256 constant PC_RESERVED2 = 0;

    //Genom Rarity Code
    uint16 constant GENOME_COMMON = 1;
    uint16 constant GENOME_RARE = 2;
    uint16 constant GENOME_EPIC = 3;
    uint16 constant GENOME_LIMITED = 4;
    uint16 constant GENOME_LEGENDARY = 5;

    //Stars tier string
    string constant ONE_STAR = "00";
    string constant TWO_STAR = "01";
    string constant THREE_STAR = "02";
    string constant FOUR_STAR = "03";
    string constant FIVE_STAR = "04";

    //Star
    uint16 private constant ONE_STAR_UINT = 1;
    uint16 private constant TWO_STAR_UINT = 2;
    uint16 private constant THREE_STAR_UINT = 3;
    uint16 private constant FOUR_STAR_UINT = 4;

    //FAILED OR SUCCESS
    uint16 private constant SUCCEEDED = 0;
    uint16 private constant FAILED = 1;

    uint16 public constant ECIO_FEE_TYPE = 1;
    uint16 public constant LAKRIMA_FEE_TYPE = 2;

    //rate being charged to upgrade stars
    mapping(uint16 => mapping(uint16 => uint256)) public FEE_PER_MATERIAL;

    IECIONFTCore public ECIO_NFT_CORE;
    IERC20 public ECIO_TOKEN;
    IERC20 public LAKRIMA_TOKEN;
    ISuccessRate public SUCCESS_RATE;
    IRandomWorker public RANDOM_WORKER;
    IGnenomRarity public GENOM_RARITY;

    // Initial fee
    function initialFee() public onlyOwner {
        FEE_PER_MATERIAL[ECIO_FEE_TYPE][ONE_STAR_UINT] = 5000000000000000000000; // 5000 ecio
        FEE_PER_MATERIAL[ECIO_FEE_TYPE][TWO_STAR_UINT] = 15000000000000000000000; // 15000 ecio
        FEE_PER_MATERIAL[ECIO_FEE_TYPE][THREE_STAR_UINT] = 40000000000000000000000; // 40000 ecio
        FEE_PER_MATERIAL[ECIO_FEE_TYPE][FOUR_STAR_UINT] = 50000000000000000000000; // 50000 ecio

        FEE_PER_MATERIAL[LAKRIMA_FEE_TYPE][ONE_STAR_UINT] = 5000000000000000000000; // 5000 lakrima
        FEE_PER_MATERIAL[LAKRIMA_FEE_TYPE][TWO_STAR_UINT] = 10000000000000000000000; // 10000 lakrima
        FEE_PER_MATERIAL[LAKRIMA_FEE_TYPE][THREE_STAR_UINT] = 15000000000000000000000; // 15000 lakrima
        FEE_PER_MATERIAL[LAKRIMA_FEE_TYPE][FOUR_STAR_UINT] = 20000000000000000000000; // 20000 lakrima
    }

    // Setup ECIO token Address
    function setupEcioToken(address ecioTokenAddress) public onlyOwner {
        ECIO_TOKEN = IERC20(ecioTokenAddress);
    }

    // Setup lakrima token Address
    function setupLakrimaToken(address lakrimaTokenAddress) public onlyOwner {
        LAKRIMA_TOKEN = IERC20(lakrimaTokenAddress);
    }

    // Setup ECIONFTcore address
    function setupECIONFTCore(IECIONFTCore ecioNFTCoreAddress) public onlyOwner {
        ECIO_NFT_CORE = ecioNFTCoreAddress;
    }

    // Setup success rate address
    function setupSuccessRate(ISuccessRate successRateAddress) public onlyOwner {
        SUCCESS_RATE = successRateAddress;
    }

    // Setup random worker address
    function setupRandomWorker(IRandomWorker randomWorkerAddress) public onlyOwner {
        RANDOM_WORKER = randomWorkerAddress;
    }

    // Setup success rate address
    function setupGenomRarity(IGnenomRarity genomRarityAddress) public onlyOwner {
        GENOM_RARITY = genomRarityAddress;
    }

    // Setup fee
    function setupFee(uint16 tokenType, uint16[] memory starUnit, uint256[] memory newRate) public onlyOwner {
        require(starUnit.length == newRate.length, "Array data of star and rate is invalid");
        for (uint8 i = 0; i < starUnit.length; i++) {
            FEE_PER_MATERIAL[tokenType][starUnit[i]] = newRate[i];
        }
    }

    // Compare 2 strings
    function compareStrings(string memory a, string memory b)
        public
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }

    // Get user Partcode and then split the code to check Genomic numbers
    function splitGenom(string memory partCode)
        public
        pure
        returns (string memory)
    {
        string[] memory splittedPartCodes = splitPartCode(partCode);
        string memory genType = splittedPartCodes[PC_GENOME];

        return (genType);
    }

    // Get user Partcode and then split the code to check stars numbers
    function splitPartcodeStar(string memory partCode)
        public
        pure
        returns (string memory)
    {
        string[] memory splittedPartCodes = splitPartCode(partCode);
        string memory starCode = splittedPartCodes[PC_STAR];

        return starCode;
    }

    // Convert from string to uint16
    function convertStarToUint(string memory starPart)
        public
        pure
        returns (uint16 stars)
    {
        if (compareStrings(starPart, ONE_STAR) == true) {
            return ONE_STAR_UINT;
        } else if (compareStrings(starPart, TWO_STAR) == true) {
            return TWO_STAR_UINT;
        } else if (compareStrings(starPart, THREE_STAR) == true) {
            return THREE_STAR_UINT;
        } else if (compareStrings(starPart, FOUR_STAR) == true) {
            return FOUR_STAR_UINT;
        } 

        return ONE_STAR_UINT;
    }

    // Split partcode for each part
    function splitPartCode(string memory partCode)
        public
        pure
        returns (string[] memory)
    {
        string[] memory result = new string[](bytes(partCode).length / 2);
        for (uint256 index = 0; index < bytes(partCode).length / 2; index++) {
            result[index] = string(
                abi.encodePacked(
                    bytes(partCode)[index * 2],
                    bytes(partCode)[(index * 2) + 1]
                )
            );
        }
        return result;
    }

    // Combine partcode
    function createPartCode(
        string memory equipmentCode,
        string memory starCode,
        string memory weapCode,
        string memory humanGENCode,
        string memory battleBotCode,
        string memory battleSuiteCode,
        string memory battleDROCode,
        string memory battleGearCode,
        string memory trainingCode,
        string memory kingdomCode,
        string memory nftTypeCode
    ) public pure returns (string memory) {
        string memory code = concateCode("", "00");
        code = concateCode(code, "00");
        code = concateCode(code, equipmentCode);
        code = concateCode(code, starCode);
        code = concateCode(code, weapCode);
        code = concateCode(code, humanGENCode);
        code = concateCode(code, battleBotCode);
        code = concateCode(code, battleSuiteCode);
        code = concateCode(code, battleDROCode);
        code = concateCode(code, battleGearCode);
        code = concateCode(code, trainingCode); //Reserved
        code = concateCode(code, kingdomCode); //Reserved
        code = concateCode(code, nftTypeCode); //Reserved
        return code;
    }

    // Concate code
    function concateCode(string memory concatedCode, string memory newCode)
        public
        pure
        returns (string memory)
    {
        concatedCode = string(abi.encodePacked(concatedCode, newCode));

        return concatedCode;
    }

    // Get number and mod
    function getNumberAndMod(
        uint256 _ranNum,
        uint16 digit,
        uint16 mod
    ) public view virtual returns (uint16) {
        if (digit == 1) {
            return uint16((_ranNum % 10000) % mod);
        } else if (digit == 2) {
            return uint16(((_ranNum % 100000000) / 10000) % mod);
        } else if (digit == 3) {
            return uint16(((_ranNum % 1000000000000) / 100000000) % mod);
        }

        return 0;
    }

    // Get card id and then burn them and mint a new one
    function gatherMaterials(uint256[] memory tokenIds, uint256 mainCardTokenId)
        external payable nonReentrant
    {
        string memory mainCardPartCode;
        (mainCardPartCode, ) = ECIO_NFT_CORE.tokenInfo(mainCardTokenId);

        // get main card genom rarity
        string memory mainCardGenom = splitGenom(mainCardPartCode);
        uint16 mainCardRarity = GENOM_RARITY.getGenomRarity(mainCardGenom);

        //get main part code star
        string memory mainCardStar = splitPartcodeStar(mainCardPartCode);
        uint16 starConverted = convertStarToUint(mainCardStar);

        // send fee to contract
        (bool sent, )= address(this).call{value: 0.0004 ether}("");
        require(sent, "Failed to send Ether");

        require(
            ECIO_TOKEN.balanceOf(msg.sender) >= FEE_PER_MATERIAL[ECIO_FEE_TYPE][starConverted]*tokenIds.length,
            "Token: your token is not enough"
        );

        require(
            LAKRIMA_TOKEN.balanceOf(msg.sender) >= FEE_PER_MATERIAL[LAKRIMA_FEE_TYPE][starConverted]*tokenIds.length,
            "Token: your token is not enough"
        );

        // get random number
        uint256 _randomNumber = RANDOM_WORKER.startRandom();
        uint16 _modRandomNumber = getNumberAndMod(_randomNumber, 3, 1000);

        // get success rate
        uint16 randomResult = SUCCESS_RATE.getSuccessRate(
            starConverted,
            uint16(tokenIds.length),
            _modRandomNumber
        );

        if (randomResult == SUCCEEDED) {
            burnAndCheckToken(starConverted, mainCardRarity, tokenIds, mainCardTokenId);
            upgradeSW(starConverted, mainCardPartCode);

            ECIO_NFT_CORE.transferFrom(
                msg.sender,
                address(this),
                mainCardTokenId
            );

        } else if (randomResult == FAILED) {
            burnAndCheckToken(starConverted, mainCardRarity, tokenIds, mainCardTokenId);
        }

        ECIO_TOKEN.transferFrom(
            msg.sender, 
            address(this), 
            FEE_PER_MATERIAL[ECIO_FEE_TYPE][starConverted]*tokenIds.length);

        LAKRIMA_TOKEN.transferFrom(
            msg.sender, 
            address(this), 
            FEE_PER_MATERIAL[LAKRIMA_FEE_TYPE][starConverted]*tokenIds.length);
    }

    // Burn and check token
    function burnAndCheckToken(uint16 mainCardStar,uint16 mainCardRarity, uint256[] memory tokenIds, uint256 mainTokenId)
        internal
    {
        for (uint32 i = 0; i < tokenIds.length; i++) {
            string memory tokenIdPart;
            (tokenIdPart, ) = ECIO_NFT_CORE.tokenInfo(tokenIds[i]);

            string memory tokenIdsGenom = splitGenom(tokenIdPart);
            uint16 tokenIdsRarity = GENOM_RARITY.getGenomRarity(tokenIdsGenom);

            string memory cardStar = splitPartcodeStar(tokenIdPart);
            uint16 tokenIdStar = convertStarToUint(cardStar);

            require(
                ECIO_NFT_CORE.ownerOf(tokenIds[i]) == msg.sender,
                "Ownership: you are not the owner"
            );

            require(
                tokenIds[i] != mainTokenId,
                "Your meterial token must not duplicate main token"
            );

            require(
                tokenIdStar == mainCardStar,
                "Star: your meterial must be equal main card"
            );

            if (mainCardRarity == GENOME_COMMON || mainCardRarity == GENOME_RARE) {
                require(
                    tokenIdsRarity == GENOME_COMMON,
                    "Rarity: your meterial must be common"
                );
            }else if (mainCardRarity == GENOME_LIMITED || mainCardRarity == GENOME_EPIC) {
                require(
                    tokenIdsRarity == GENOME_RARE,
                    "Rarity: your meterial must be rare"
                );
            }else if (mainCardRarity == GENOME_LEGENDARY) {
                require(
                    tokenIdsRarity == GENOME_EPIC,
                    "Rarity: your meterial must be epic"
                );
            }

            ECIO_NFT_CORE.burn(tokenIds[i]);
        }
    }

    // Upgrade space warrior
    function upgradeSW(uint16 mainCardStar, string memory mainCardPart)
        internal
    {
        if (mainCardStar <= FOUR_STAR_UINT) {
            // split part code
            string[] memory splittedPartCode = splitPartCode(mainCardPart);
            // update partcode
            string memory partCode = createPartCode(
                splittedPartCode[PC_EQUIPMENT], //equipmentTypeId
                upgradedStar(splittedPartCode[PC_STAR]), //upgrade combatStarCode
                splittedPartCode[PC_WEAPON], //WEAPCode
                splittedPartCode[PC_GENOME], //humanGENCode
                splittedPartCode[PC_BOT], //battleBotCode
                splittedPartCode[PC_SUITE], //battleSuiteCode
                splittedPartCode[PC_DRONE], //battleDROCode
                splittedPartCode[PC_GEAR], //battleGearCode
                splittedPartCode[PC_CAMP], //trainingCode
                splittedPartCode[PC_KINGDOM], //kingdomCode
                splittedPartCode[PC_NFT_TYPE] // nft Type
            );
            
            ECIO_NFT_CORE.safeMint(msg.sender, partCode);
        }
    }

    function upgradedStar(string memory currentStar) internal pure returns (string memory) {
        if (compareStrings(currentStar, ONE_STAR) == true) {
            return TWO_STAR;
        } else if (compareStrings(currentStar, TWO_STAR) == true) {
            return THREE_STAR;
        } else if (compareStrings(currentStar, THREE_STAR) == true) {
            return FOUR_STAR;
        } else if (compareStrings(currentStar, FOUR_STAR) == true) {
            return FIVE_STAR;
        }

        return currentStar; 
    }

    //*************************** transfer fee ***************************//

    // transfer fee
    function transferFee(address payable _to, uint256 _amount)
        public
        onlyOwner
    {
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Failed to send Ether");
    }

    // transfer reward
    function transferReward(
        address _contractAddress,
        address _to,
        uint256 _amount
    ) public onlyOwner {
        IERC20 _token = IERC20(_contractAddress);
        _token.transfer(_to, _amount);
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
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/IERC721.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}