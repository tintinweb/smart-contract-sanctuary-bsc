/**
 *Submitted for verification at BscScan.com on 2022-03-18
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
*/// File: @openzeppelin/contracts/math/SafeMath.sol

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

// File: @openzeppelin/contracts/introspection/IERC165.sol



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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol



pragma solidity >=0.6.2 <0.8.0;


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

// File: @openzeppelin/contracts/token/ERC721/IERC721Enumerable.sol



pragma solidity >=0.6.2 <0.8.0;


/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {

    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// File: contracts/library/Governance.sol

pragma solidity ^0.6.0;

contract Governance {

    address public _governance;

    constructor() public {
        _governance = tx.origin;
    }

    event GovernanceTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyGovernance {
        require(msg.sender == _governance, "not governance");
        _;
    }

    function setGovernance(address governance)  public  onlyGovernance
    {
        require(governance != address(0), "new governance the zero address");
        emit GovernanceTransferred(_governance, governance);
        _governance = governance;
    }


}

// File: contracts/interface/ISecondLiveFactoryV2.sol

pragma solidity ^0.6.6;

interface ISecondLiveFactory{
    function getSecondLive(uint256 tokenId)
        external view
        returns (
            uint256 rule,
            uint256 apartment,
            uint256 spaceType,
            uint256 initLevel
        );

    function getUserSpace(address user, uint256 roomType)
        external view
        returns (uint256);

    function getUserSpaceByIndex(address user, uint256 roomType, uint256 index)
        external view
        returns (uint256);
}

// File: contracts/interface/ISecondLive.sol

pragma solidity ^0.6.6;

pragma experimental ABIEncoderV2;


interface ISecondLive is IERC721 {
    
    struct Attribute {
        uint256 rule; // 1 room
        uint256 quality; // type -> (Pink | Blue | island)
        uint256 format; // space -> (Person Space | island)
        uint256 extra; // level
    }

    function mint(
        address to, 
        uint256 tokenId, 
        Attribute calldata attribute) external;

    function getAttribute(uint256 id) 
        external 
        view 
        returns (Attribute memory attribute);

}

// File: @openzeppelin/contracts/token/ERC1155/IERC1155.sol



pragma solidity >=0.6.2 <0.8.0;


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

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

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
}

// File: contracts/interface/ISecondLiveNFT.sol

pragma solidity ^0.6.6;




interface ISecondLiveNFT is IERC1155 {
    
    struct Attribute {
        uint256 rule; // 1
        uint256 quality; // power 
        uint256 format; // proj
        uint256 extra; // tokenId
    }

    function mint(
        address account, 
        uint256 id, 
        uint256 amount,
        bytes calldata data,
        Attribute calldata attribute) external;
        
    function mintBatch(
        address to, 
        uint256[] calldata ids, 
        uint256[] calldata amounts, 
        bytes calldata data,
        Attribute[] calldata _attributes) external;

    function getAttribute(uint256 id) 
        external 
        view 
        returns (Attribute memory attribute);

}

// File: contracts/Dao/SecondLiveVotePowerV2.sol

pragma solidity ^0.6.0;









// levle[index](1,2,3,4,5) -> D C B A S

contract SecondLiveVotePower is Governance {
    using SafeMath for uint256;
    
    ISecondLiveFactory public secondLiveFactory = ISecondLiveFactory(0x260e69ab6665B9ef67b60674E265b5D21c88CB45);
    address public secondLive = address(0x17316Bb0B16A57177272DD88617841037Bcec3d3);
    ISecondLiveNFT public secondLiveNFT = ISecondLiveNFT(0xAC1f9Fadc33cC0799Cf7e3051E5f6b28C98966EE);

    uint256[] private petIds = [61,62,63,64,65];
    uint256[] private badgeIds;
    
    uint256 public weightOfApartMent = 800 * 1e18;
    uint256 public weightOfIsland = 1600 * 1e18;
    uint256 public weightOfBadge = 30 * 1e18;
    uint256 public weightOfPed = 80 * 1e18;
    
    // levelRatio
    uint256 baseRate = 10000;
    // D C B A S
    uint256[] public levelRate = [8000, 9000, 10000, 11000, 13000];
    
    event eveInit(address indexed owner);
    
    event UpdateWeight(
        uint256 weightOfApartMent,
        uint256 weightOfIsland,
        uint256 weightOfBadge,
        uint256 weightOfPed
    );

    event SetBadgeIds(
        uint256 indexed fromId,
        uint256 indexed toId
    );
    
    event ReSetBadgeIds(bool set);

    event UpdateLevelRateWeight(
        uint256 _baseRate,
        uint256[] _levelRate
    );

    function apartMentPowerOfLevelsByUser(address user, uint256[] memory levels) public view returns (uint256) {
       // attribute.format = 1;
        uint256[] memory balances = apartMentBalanceOfLevelsByUser(user, levels);
        uint256 power = 0;
        for (uint256 i = 0; i < levels.length; i++) {
            uint256 level = levels[i];
            uint256 levelRate_ = levelRate[level.sub(1)];
            power = power.add(
               balances[i]
               .mul(weightOfApartMent)
               .mul(levelRate_)
               .div(baseRate));
        }
        return power;
    }

    function islandPowerOfLevelsByUser(address user, uint256[] memory levels) public view returns (uint256) {
        // attribute.format = 2;
        uint256[] memory balances = islandBalanceOfLevelsByUser(user, levels);
        uint256 power = 0;
        for (uint256 i = 0; i < levels.length; i++) {
            uint256 level = levels[i];
            uint256 levelRate_ = levelRate[level.sub(1)];
            power = power.add(
               balances[i]
               .mul(weightOfIsland)
               .mul(levelRate_)
               .div(baseRate));
        }
        return power;
    }

    function apartMentBalanceOfLevelsByUser(address user, uint256[] memory levels) public view returns (uint256[] memory) {
       // attribute.format = 1;
       uint256[] memory inWalletBalance = inWalletSpace(user, 1, levels);
        uint256[] memory balances = new uint256[](levels.length);
        uint256 inSpaceBalance = secondLiveFactory.getUserSpace(user, 1);
        for (uint256 i = 0; i < levels.length; i++) {
            uint256 level = levels[i];
            uint256 InSpaceBalanceCurrLevel = 0;
            for (uint256 j = 0; j < inSpaceBalance; j++) {
                uint256 spaceId = secondLiveFactory.getUserSpaceByIndex(user, 1, j);
                uint256 level_;
                (,,,level_) = secondLiveFactory.getSecondLive(spaceId);
                if (level == level_) {
                    InSpaceBalanceCurrLevel++;
                }
            }
            uint256 blance = inWalletBalance[i];
            balances[i] = blance.add(InSpaceBalanceCurrLevel);
        }
        return balances;
    }

    function islandBalanceOfLevelsByUser(address user, uint256[] memory levels) public view returns (uint256[] memory) {
        // attribute.format = 2;
        uint256[] memory inWalletBalance = inWalletSpace(user, 2, levels);
        uint256[] memory balances = new uint256[](levels.length);
        uint256 inSpaceBalance = secondLiveFactory.getUserSpace(user, 2);
        for (uint256 i = 0; i < levels.length; i++) {
            uint256 level = levels[i];
            uint256 InSpaceBalanceCurrLevel = 0;
            for (uint256 j = 0; j < inSpaceBalance; j++) {
                uint256 spaceId = secondLiveFactory.getUserSpaceByIndex(user, 2, j);
                uint256 level_;
                (,,,level_) = secondLiveFactory.getSecondLive(spaceId);
                if (level == level_) {
                    InSpaceBalanceCurrLevel++;
                }
            }
            uint256 blance = inWalletBalance[i];
            balances[i] = blance.add(InSpaceBalanceCurrLevel);
        }
        return balances;
    }

    function inWalletSpace(address user, uint256 format, uint256[] memory levels) private view returns (uint256[] memory) {
        uint256 allSpace = ISecondLive(secondLive).balanceOf(user);
        uint256[] memory balances = new uint256[](levels.length);
        for (uint256 i = 0; i < levels.length; i++) {
           uint256 level = levels[i];
           uint256 balance = 0;
           for (uint256 j = 0; j < allSpace; j++) {
                uint256 tokenId = IERC721Enumerable(secondLive).tokenOfOwnerByIndex(user, j);
                uint256 format_;
                uint256 level_;
                (,,format_,level_) = secondLiveFactory.getSecondLive(tokenId);
                if (format_ == format && level == level_) {
                    balance++;
                }
            }
            balances[i] = balance;
        }
        return balances;
    }

    function badgePowerOf(address user) public view returns (uint256) {
        return badgeBalanceOf(user).mul(weightOfBadge);
    }

    function pedPowerOfLevelsByUser(address user, uint256[] memory levels) public view returns (uint256) {
        uint256[] memory balances = pedBalanceOfLevelsByUser(user, levels);
        uint256 power = 0;
        for (uint256 i = 0; i < levels.length; i++) {
            uint256 level = levels[i];
            uint256 levelRate_ = levelRate[level.sub(1)];
            power = power.add(
               balances[i]
               .mul(weightOfPed)
               .mul(levelRate_)
               .div(baseRate));
        }
        return power;
    }
    
    function badgeBalanceOf(address user) public view returns (uint256) {
        address[] memory accounts = new address[](badgeIds.length);
        for (uint256 index = 0; index < badgeIds.length; index++) {
            accounts[index] = user;
        }
        uint256[] memory balanceArray = secondLiveNFT.balanceOfBatch(accounts, badgeIds);
        uint256 balance = 0;
        for (uint256 index = 0; index < balanceArray.length; index++) {
            balance = balance.add(balanceArray[index]);
        }
        return balance;
    }

    function pedBalanceOfLevelsByUser(address user, uint256[] memory levels) public view returns (uint256[] memory) {
        uint256[] memory tempArray = new uint256[](levels.length);
        for (uint256 i = 0; i < levels.length; i++) {
            uint256 level = levels[i];
            uint256 idIndex = level.sub(1);
            tempArray[i] = petIds[idIndex];
        }
        return inWalletNFT(user, tempArray);
    }

    function inWalletNFT(address user, uint256[] memory tokenIds) private view returns (uint256[] memory) {
        address[] memory accounts = new address[](tokenIds.length);
        for (uint256 index = 0; index < tokenIds.length; index++) {
            accounts[index] = user;
        }
        return secondLiveNFT.balanceOfBatch(accounts, tokenIds);
    }

    function balanceOf(address user) external view returns (uint256) {
        uint256[] memory levels = new uint256[](5);
        for (uint256 index = 1; index <= 5; index++) {
            levels[index.sub(1)] = index;
        }
        return
            apartMentPowerOfLevelsByUser(user,levels).
            add(islandPowerOfLevelsByUser(user,levels)).
            add(badgePowerOf(user)).
            add(pedPowerOfLevelsByUser(user,levels));
    }

    function decimals() external pure returns (uint256) {
        return uint256(18);
    }
    
    function name() external pure returns (string memory) {
        return "vote.power";
    }
    
    function symbol() external pure returns (string memory) {
        return "VP";
    }

    function totalSupply() external pure returns (uint256) {
        return 0;
    }
    
    function setBadgeIds(uint256 fromId, uint256 toId) external onlyGovernance {
        for (uint256 i = fromId; i <= toId; i++) {
            badgeIds.push(i);
        }
        emit SetBadgeIds(fromId, toId);
    }

    function reSetBadgeIds(uint256[] calldata arr) external onlyGovernance {
        badgeIds = arr;
        emit ReSetBadgeIds(true);
    }

    function updateWeight(
        uint256 _weightOfApartMent,
        uint256 _weightOfIsland,
        uint256 _weightOfBadge,
        uint256 _weightOfPed
        ) external onlyGovernance {
        weightOfApartMent = _weightOfApartMent;
        weightOfIsland = _weightOfIsland;
        weightOfBadge = _weightOfBadge;
        weightOfPed = _weightOfPed;
        
        emit UpdateWeight(
            weightOfApartMent,
            weightOfIsland,
            weightOfBadge,
            weightOfPed
        );
    }
    function updateLevelRateWeight(
        uint256 _baseRate,
        uint256[] calldata _levelRate
        ) external onlyGovernance {
            baseRate = _baseRate;
            levelRate = _levelRate;

            emit UpdateLevelRateWeight(
                _baseRate, _levelRate
            );
    }
}