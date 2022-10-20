/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

/***
 * 
 * ███████╗███████╗ ██████╗ ██████╗ ███╗   ██╗██████╗ ██╗     ██╗██╗   ██╗███████╗
 * ██╔════╝██╔════╝██╔════╝██╔═══██╗████╗  ██║██╔══██╗██║     ██║██║   ██║██╔════╝
 * ███████╗█████╗  ██║     ██║   ██║██╔██╗ ██║██║  ██║██║     ██║██║   ██║█████╗  
 * ╚════██║██╔══╝  ██║     ██║   ██║██║╚██╗██║██║  ██║██║     ██║╚██╗ ██╔╝██╔══╝  
 * ███████║███████╗╚██████╗╚██████╔╝██║ ╚████║██████╔╝███████╗██║ ╚████╔╝ ███████╗
 * ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═════╝ ╚══════╝╚═╝  ╚═══╝  ╚══════╝
 *    
 * https://secondlive.world
                               
* MIT License
* ===========
*
* Copyright (c) 2022 secondlive
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*/// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/utils/Strings.sol


// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


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

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


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

// File: @openzeppelin/contracts/utils/cryptography/MerkleProof.sol


// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/MerkleProof.sol)

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
                computedHash = _efficientHash(computedHash, proofElement);
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = _efficientHash(proofElement, computedHash);
            }
        }
        return computedHash;
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}

// File: contracts/interface/ISecondLiveIMO.sol

pragma solidity ^0.8.0;


pragma experimental ABIEncoderV2;

interface ISecondLiveIMO{
    
    struct Attribute {
        uint256 rule; 
        uint256 quality;
        uint256 format;
        uint256 extra;
    }

    function mint(
        address to, 
        Attribute calldata attribute) external returns(uint256);
    
    function getAttribute(uint256 id) 
        external 
        view 
        returns (Attribute memory attribute);

    function setTokenRoyalty(
        uint256 tokenId,
        address receiver,
        uint96 feeNumerator) external;

}

// File: contracts/interface/ISecondLiveCreatorFactory.sol

pragma solidity ^0.8.0;


interface ISecondLiveCreatorFactory {
    function existingAttr(
        uint rule,
        uint quality,
        uint format,
        uint extra) external returns(bool);
}

// File: contracts/creatorimo/SecondLiveCreatorIMO.sol

pragma solidity ^ 0.8.0;








contract SecondLiveCreatorIMO is Ownable, ReentrancyGuard {
    using Strings for uint256;
    using SafeMath for uint256;

    bool private initialized;
    
    struct IMOPool {
        uint256 poolIndex;
        address creator;
        bytes32 whitelistRoot;// whitelist "0" is open
        ISecondLiveIMO.Attribute attribute;
        uint256 unitPrice;
        uint256 totalAmount;
        uint256 maxAmount;
        address asset; // avatar space
        uint96 royalty;
        // uint256 sellType; // single mysterybox suit
    }

    ISecondLiveCreatorFactory private creatorFactory;
    mapping (address => bool) public governance;
    mapping (uint256 => mapping(address => uint256)) public userBoughtAmount;
    mapping (uint256 => uint256) public poolSoldAmount;
    mapping (uint256 => bool) public haveMint;
    
    IMOPool[] public allImo;
    
    address payable public devAddress;

    // r q f e
    mapping(uint =>
        mapping(uint =>
            mapping(uint =>
                mapping(uint=>bool)))) public existingAttr;
    
    event CreateImo(
        uint256 poolIndex, 
        address creator,
        uint256 unitPrice,
        uint256 amount,
        address asset,
        ISecondLiveIMO.Attribute attribute
        );

    event Claim(
            address sender,
            uint256 poolIndex,
            uint256 amount
        );

    event UpdateImo(
            uint256 poolIndex,
            address creator,
            uint256 unitPrice,
            address asset,
            uint256 totalAmount,
            ISecondLiveIMO.Attribute attribute
        );

    event SetGovernance(
            address gov,
            bool tag
        );
    
    event CreatorMint(
            address creator,
            uint256 poolIndex,
            address asset
        );

    event TransferCreator(
        address sender,
        uint256 poolIndex,
        address newCreator
    );

    function initialize(
        address _owner,
        address payable _devAddress,
        ISecondLiveCreatorFactory _creatorFactory) external {
        require(!initialized, "initialize: Already initialized!");
        _transferOwnership(_owner);
        creatorFactory = _creatorFactory;
        devAddress = _devAddress;
        initialized = true;
    }

    function creatPool(
        address creator,
        bytes32 whitelistRoot,
        ISecondLiveIMO.Attribute memory attribute,
        uint256 unitPrice,
        uint256 totalAmount,
        uint256 maxAmount,
        address asset,
        uint96 royalty
    ) external nonReentrant {
        require(governance[msg.sender],"can not call");
        require(royalty <= 2000, "The maximum royalty can only be 20%!!!");

        uint256 rule = attribute.rule;
        uint256 quality = attribute.quality;
        uint256 format = attribute.format;
        uint256 extra = attribute.extra;

        // factory
        require(creatorFactory.existingAttr(rule,quality,format,extra) == false,
            string(abi.encodePacked(
                            "attribute has been used in factory!!! ",
                            "rule:",rule.toString(),
                            " quality:",quality.toString(),
                            " format:",format.toString(),
                            " extra:",extra.toString())
                            ));

        require(existingAttr[rule][quality][format][extra] == false,
            string(abi.encodePacked(
                            "attribute has been used!!! ",
                            "rule:",rule.toString(),
                            " quality:",quality.toString(),
                            " format:",format.toString(),
                            " extra:",extra.toString())
                            ));

        existingAttr[rule][quality][format][extra] = true;
        
        ISecondLiveIMO.Attribute memory _attribute = attribute;

        IMOPool memory imo;
        imo.poolIndex = allImo.length;
        imo.creator = creator;
        imo.whitelistRoot = whitelistRoot;
        imo.attribute = _attribute;
        imo.unitPrice = unitPrice;
        imo.totalAmount = totalAmount;
        imo.maxAmount = maxAmount;
        imo.asset = asset;
        imo.royalty = royalty;
        allImo.push(imo);
        
        emit CreateImo(
            imo.poolIndex,
            creator,
            unitPrice,
            totalAmount,
            asset,
            _attribute
        );
    }

    function claim( 
        uint256 poolIndex,
        uint256 amount, 
        uint256 addressId, 
        bytes32[] memory merkleProof) external payable nonReentrant {
        
        IMOPool memory imo = allImo[poolIndex];
        bytes32 merkleRoot = imo.whitelistRoot;
        if (merkleRoot != bytes32(0)) {
            bytes32 node = keccak256(abi.encodePacked(addressId, msg.sender));
            require(MerkleProof.verify(merkleProof, merkleRoot, node), "SecondLive: sender can not claim");
        }

        uint256 boughtAmount = userBoughtAmount[poolIndex][msg.sender];
        uint256 maxAmount = imo.maxAmount;
        require(maxAmount.sub(boughtAmount) >= amount, "excessive amount");
        uint256 soldAmount = poolSoldAmount[poolIndex];
        require(imo.totalAmount.sub(soldAmount) >= amount, "sold out");
        
        if (imo.unitPrice > 0) {
            uint256 total = amount.mul(imo.unitPrice);
            require(msg.value >= total,"value error");
            uint256 returnBack = msg.value.sub(total);
            if(returnBack > 0) {
                payable(msg.sender).transfer(returnBack);
            }
            // payable(0x37593E4c28Ef8a7ab9F5A7be1bF7f89347172dC6).transfer(total.mul(20).div(100));
            payable(devAddress).transfer(total.mul(20).div(100));
            payable(imo.creator).transfer(total.mul(80).div(100));
            
        }else{
            require(msg.value == 0,"value error");
        }

        for (uint256 i = 0; i < amount; i++) {
            uint256 tokenId = ISecondLiveIMO(imo.asset).mint(msg.sender, imo.attribute);
            if (imo.royalty > 0) {
                ISecondLiveIMO(imo.asset).setTokenRoyalty(tokenId, imo.creator, imo.royalty);
            }
        }
        
        userBoughtAmount[poolIndex][msg.sender] = userBoughtAmount[poolIndex][msg.sender].add(amount);
        poolSoldAmount[poolIndex] = poolSoldAmount[poolIndex].add(amount);

        emit Claim(
            msg.sender,
            poolIndex,
            amount
        );
    }

    function fixImo(uint256 poolIndex, IMOPool memory _imo) external {
        require(governance[msg.sender],"can not call");
        IMOPool storage imo = allImo[poolIndex];
        
        imo.poolIndex = _imo.poolIndex;
        imo.creator = _imo.creator;
        imo.whitelistRoot = _imo.whitelistRoot;
        imo.attribute = _imo.attribute;
        imo.unitPrice = _imo.unitPrice;
        imo.totalAmount = _imo.totalAmount;
        imo.maxAmount = _imo.maxAmount;
        imo.asset = _imo.asset;
        imo.royalty = _imo.royalty;
        
        emit UpdateImo(
            _imo.poolIndex,
            _imo.creator,
            _imo.unitPrice,
            _imo.asset,
            _imo.totalAmount,
            _imo.attribute
        );
    }

    function setGovernance(address gov, bool tag) external onlyOwner {
        governance[gov] = tag;
        
        emit SetGovernance(
            gov,
            tag
        );
    }

    function creatorMint(uint256 poolIndex) external {
        // only once
        require(!haveMint[poolIndex],"have mint!!!");
        IMOPool memory imo = allImo[poolIndex];
        address creator = imo.creator;
        ISecondLiveIMO.Attribute memory attr = imo.attribute;
        address asset = imo.asset;
        uint96 royalty = imo.royalty;
        require(creator == msg.sender, "are not the creator of this IMO");
        uint256 tokenId1 = ISecondLiveIMO(asset).mint(creator, attr);
        ISecondLiveIMO(asset).setTokenRoyalty(tokenId1, creator, royalty);
        
        uint256 tokenId2 = ISecondLiveIMO(asset).mint(creator, attr);
        ISecondLiveIMO(asset).setTokenRoyalty(tokenId2, creator, royalty);
        
        haveMint[poolIndex] = true;
        emit CreatorMint(
            msg.sender,
            poolIndex,
            asset
        );
    }


    function transferCreator(uint256 poolIndex, address newCreator) external {
        IMOPool storage imo = allImo[poolIndex];
        address creator = imo.creator;
        require(creator == msg.sender, "are not the creator of this IMO");
        imo.creator = newCreator;
        
        emit TransferCreator(
            msg.sender,
            poolIndex,
            newCreator
        );
    }

    function updateExistingAttr(uint256[][] memory attrs) external onlyOwner {
        for (uint256 index = 0; index < attrs.length; index++) {
            uint256[] memory attr = attrs[index];
            existingAttr[attr[0]][attr[1]][attr[2]][attr[3]] = true;
        }
    }
    
    function imoOf(uint256 index) external view returns (IMOPool memory imo){
        imo = allImo[index];
    }

    function allIMOLength() external view returns (uint256) {
        return allImo.length;
    }
    
    receive() payable external {}
}