// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../../breeding/evolve_lab/IEvolveLab.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../../core/interface/IDinolandNFT.sol";
import "../../breeding/dino_breeding/IDinoGenesScience.sol";
import "../creation_stone/ICreationStone.sol";
import "./IFusionScience.sol";

contract FusionLab is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    IERC20 public tokenContract;
    IEvolveLab public evolveLabContract;
    IDinolandNFT public nftContract;
    IDinoGenesScience public dinoGenesScienceContract;
    ICreationStone public creationStoneContract;
    IFusionScience public fusionScienceContract;

    uint256 public constant RATE_DENOMINATOR = 10000;
    mapping(uint256 => uint256) public dinoRarityToCreationStoneNeeded;
    mapping(uint256 => uint256) public dinoRarityToSuccessRate;
    mapping(uint256 => uint256) public dinoRarityToFusionFee;
    mapping(uint256 => uint256[]) public oldGenesToNewGenes;
    uint256[] public scoreByIndex = [1, 1, 1, 2, 2, 2, 3, 3, 4, 5];
    uint256 public blockTime = 3;

    constructor(address[] memory _addrs) {
        tokenContract = IERC20(_addrs[0]);
        nftContract = IDinolandNFT(_addrs[1]);
        evolveLabContract = IEvolveLab(_addrs[2]);
        dinoGenesScienceContract = IDinoGenesScience(_addrs[3]);
        creationStoneContract = ICreationStone(_addrs[4]);
        fusionScienceContract = IFusionScience(_addrs[5]);

        dinoRarityToFusionFee[1] = 2500 ether;
        dinoRarityToFusionFee[2] = 3750 ether;
        dinoRarityToFusionFee[3] = 7000 ether;
        dinoRarityToFusionFee[4] = 12500 ether;

        dinoRarityToCreationStoneNeeded[1] = 1;
        dinoRarityToCreationStoneNeeded[2] = 3;
        dinoRarityToCreationStoneNeeded[3] = 6;
        dinoRarityToCreationStoneNeeded[4] = 10;
    }

    modifier noContract() {
        uint32 size;
        address _addr = msg.sender;
        assembly {
            size := extcodesize(_addr)
        }
        require(size == 0);
        require(msg.sender == tx.origin);
        _;
    }

    struct Dino {
        uint256 id;
        uint256 genes;
        uint256 bornAt;
        uint256 cooldownEndAt;
        uint128 gender;
        uint128 generation;
    }

    event FusionSucceed(
        uint256 indexed dino1,
        uint256 indexed dino2,
        uint256 newDinoId,
        uint256 newDinoGenes
    );
    event FusionFailed(uint256 indexed dino1, uint256 indexed dino2);

    function setTokenContract(IERC20 _tokenContract) external onlyOwner {
        tokenContract = _tokenContract;
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

    function setDinoGenesScienceContract(
        IDinoGenesScience _dinoGenesScienceContract
    ) external onlyOwner {
        dinoGenesScienceContract = _dinoGenesScienceContract;
    }

    function setFusionScienceContract(IFusionScience _fusionScienceContract)
        external
        onlyOwner
    {
        fusionScienceContract = _fusionScienceContract;
    }

    function setCreationStoneContract(ICreationStone _creationStoneContract)
        external
        onlyOwner
    {
        creationStoneContract = _creationStoneContract;
    }

    function setDinoRarityToFusionFee(uint256 _dinoRarity, uint256 _fusionFee)
        external
        onlyOwner
    {
        dinoRarityToFusionFee[_dinoRarity] = _fusionFee;
    }

    function setOldGenesToNewGenes(
        uint256 _oldGenes,
        uint256[] memory _newGenes
    ) external onlyOwner {
        oldGenesToNewGenes[_oldGenes] = _newGenes;
    }

    function setDinoRarityToCreationStoneNeeded(
        uint256 _dinoRarity,
        uint256 _creationStoneNeeded
    ) external onlyOwner {
        dinoRarityToCreationStoneNeeded[_dinoRarity] = _creationStoneNeeded;
    }

    function setBlockTime(uint256 _blockTime) external onlyOwner {
        blockTime = _blockTime;
    }

    function getDinoRarity(uint256 _dinoGenes)
        public
        view
        returns (uint256 dinoRarity)
    {
        if (evolveLabContract.isOldGenes(_dinoGenes)) {
            return (_dinoGenes % 1000) % 10;
        }
        uint8[7] memory expressingTraits = dinoGenesScienceContract
            .expressingTraitsDino(_dinoGenes);
        uint256 totalScore;
        for (uint256 i = 0; i < 7; i++) {
            if (i == 1 || i == 2 || i == 3 || i == 6) {
                totalScore += scoreByIndex[expressingTraits[i]];
            }
        }
        if (totalScore <= 8) {
            return 1;
        } else if (totalScore <= 13) {
            return 2;
        } else if (totalScore <= 16) {
            return 3;
        } else if (totalScore <= 18) {
            return 4;
        } else {
            return 5;
        }
    }

    function fusion(
        uint256 _dino1,
        uint256 _dino2,
        uint256[] memory _creationStones
    ) external noContract nonReentrant {
        Dino memory dino1;
        Dino memory dino2;
        (
            dino1.genes,
            dino1.bornAt,
            ,
            dino1.gender,
            dino1.generation
        ) = nftContract.getDino(_dino1);
        (
            dino2.genes,
            dino2.bornAt,
            ,
            dino2.gender,
            dino2.generation
        ) = nftContract.getDino(_dino2);
        require(
            nftContract.ownerOf(_dino1) == msg.sender,
            "FusionLab: You are not owner of first dino"
        );
        require(
            nftContract.ownerOf(_dino2) == msg.sender,
            "FusionLab: You are not owner of second dino"
        );
        require(
            evolveLabContract.isEvolved(_dino1),
            "FusionLab: First dino is not evolved"
        );
        require(
            evolveLabContract.isEvolved(_dino2),
            "FusionLab: Second dino is not evolved"
        );

        uint256 dino1Rarity = getDinoRarity(dino1.genes);
        uint256 dino2Rarity = getDinoRarity(dino2.genes);
        require(
            dino1Rarity == dino2Rarity,
            "FusionLab: You can only fusion dino with same rarity"
        );

        require(
            _creationStones.length ==
                dinoRarityToCreationStoneNeeded[dino1Rarity],
            "FusionLab: Not enough creation stones"
        );
        for (uint256 i = 0; i < _creationStones.length; i++) {
            require(
                creationStoneContract.ownerOf(_creationStones[i]) == msg.sender,
                "FusionLab: You are not owner of creation stone"
            );
        }
        creationStoneContract.burnBatch(_creationStones);

        tokenContract.transferFrom(
            msg.sender,
            address(this),
            dinoRarityToFusionFee[dino1Rarity]
        );

        (bool isSuccess, uint256 dinoGenes) = fusionScienceContract
            .calculateFusionGenes(
                dino1Rarity,
                _dino1,
                dino1.bornAt,
                _dino2,
                dino2.bornAt
            );

        if (isSuccess) {
            nftContract.retireDino(_dino1, true);
            nftContract.retireDino(_dino2, true);
            uint256 createdAtBlock = (dino1.bornAt + dino2.bornAt) /
                (2 * blockTime);
            uint256 newGenesArrLength = oldGenesToNewGenes[dinoGenes].length;
            require(
                newGenesArrLength > 0,
                "FusionLab: No new genes for this dino"
            );
            uint256 genesIndex = (
                uint256(
                    keccak256(
                        abi.encodePacked(
                            blockhash(createdAtBlock),
                            block.number
                        )
                    )
                )
            ) % newGenesArrLength;
            uint128 gender = uint128(
                (uint256(keccak256(abi.encodePacked(block.timestamp))) % 2) + 1
            );
            uint256 dinoEvolvedGenes = oldGenesToNewGenes[dinoGenes][
                genesIndex
            ];
            uint256 newDinoId = nftContract.createDino(
                dinoEvolvedGenes,
                msg.sender,
                gender,
                1
            );
            evolveLabContract.setEvolved(newDinoId, true);
            emit FusionSucceed(dino1.id, dino2.id, newDinoId, dinoEvolvedGenes);
        } else {
            emit FusionFailed(_dino1, _dino2);
        }
    }

    function withdrawERC20(address _tokenAddress, uint256 _amount)
        external
        onlyOwner
    {
        IERC20(_tokenAddress).transfer(msg.sender, _amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IFusionScience {
    function calculateFusionGenes(
        uint256 _dinoRarity,
        uint256 _dino1Id,
        uint256 _dino1BornAt,
        uint256 _dino2Id,
        uint256 _dino2BornAt
    ) external view returns(
        bool _isSuccess,
        uint256 _dinoGenes
    );
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ICreationStone is IERC721 {
  function burn(uint256 _tokenId) external;
  function burnBatch(uint256[] memory _tokenIds) external;
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
    function retireDino(uint256 _dinoId, bool _rip) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IEvolveLab {
    function isEvolved(uint256 _dinoId) external returns (bool);

    function isOldGenes(uint256 _dinoId) external view returns (bool);

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

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
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
     * by making the `nonReentrant` function external, and make it call a
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