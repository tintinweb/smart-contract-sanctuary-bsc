// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    constructor () internal {
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;


 

interface IERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns(bool);
}




/// @title ERC-721 Non-Fungible Token Standard
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x80ac58cd.
interface IERC721 /* is ERC165 */ {
    /// @dev This emits when ownership of any NFT changes by any mechanism.
    ///  This event emits when NFTs are created (`from` == 0) and destroyed
    ///  (`to` == 0). Exception: during contract creation, any number of NFTs
    ///  may be created and assigned without emitting Transfer. At the time of
    ///  any transfer, the approved address for that NFT (if any) is reset to none.
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    /// @dev This emits when the approved address for an NFT is changed or
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    /// @dev This emits when an operator is enabled or disabled for an owner.
    ///  The operator can manage all NFTs of the owner.
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// @param _owner An address for whom to query the balance
    /// @return The number of NFTs owned by `_owner`, possibly zero
    function balanceOf(address _owner) external view returns(uint256);

    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT
    function ownerOf(uint256 _tokenId) external view returns(address);

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) external payable;

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to "".
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Change or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _approved, uint256 _tokenId) external payable;

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) external;

    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT.
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId) external view returns(address);

    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) external view returns(bool);
}



/// @title ERC-721 Non-Fungible Token Standard, optional metadata extension
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x5b5e139f.
interface IERC721Metadata /* is ERC721 */ {
    /// @notice A descriptive name for a collection of NFTs in this contract
    function name() external view returns (string memory);

    /// @notice An abbreviated name for NFTs in this contract
    function symbol() external view returns (string memory);

    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    /// @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC
    ///  3986. The URI may point to a JSON file that conforms to the "ERC721
    ///  Metadata JSON Schema".
    /// {"name":"","description":"","image":""}
    function tokenURI(uint256 _tokenId) external view returns (string memory);
}


/// @dev Note: the ERC-165 identifier for this interface is 0x150b7a02.
interface IERC721TokenReceiver {
    /// @notice Handle the receipt of an NFT
    /// @dev The ERC721 smart contract calls this function on the recipient
    ///  after a `transfer`. This function MAY throw to revert and reject the
    ///  transfer. Return of other than the magic value MUST result in the
    ///  transaction being reverted.
    ///  Note: the contract address is always the message sender.
    /// @param _operator The address which called `safeTransferFrom` function
    /// @param _from The address which previously owned the token
    /// @param _tokenId The NFT identifier which is being transferred
    /// @param _data Additional data with no specified format
    /// @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    ///  unless throwing
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes memory _data) external returns(bytes4);
}


interface IERC721TokenReceiverEx is IERC721TokenReceiver {
    // bytes4(keccak256("onERC721ExReceived(address,address,uint256[],bytes)")) = 0x0f7b88e3
    function onERC721ExReceived(address operator, address from,
        uint256[] memory tokenIds, bytes memory data)
    external returns(bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

 

library Util {
    bytes4 internal constant ERC721_RECEIVER_RETURN = 0x150b7a02;
    bytes4 internal constant ERC721_RECEIVER_EX_RETURN = 0x0f7b88e3;

    uint256 public constant UDENO = 10 ** 10;
    int256 public constant SDENO = 10 ** 10;

    uint256 public constant RARITY_GRAY = 0;
    uint256 public constant RARITY_WHITE = 1;
    uint256 public constant RARITY_GREEN = 2;
    uint256 public constant RARITY_BLUE = 3;
    uint256 public constant RARITY_PURPLE = 4;
    uint256 public constant RARITY_ORANGE = 5;
    uint256 public constant RARITY_GOLD = 6;
    uint256 public constant RARITY_COLOR = 7;


    function randomUint(bytes memory seed, uint256 min, uint256 max)
    internal pure returns (uint256) {

        if (min >= max) {
            return min;
        }

        uint256 number = uint256(keccak256(seed));
        return number % (max - min + 1) + min;
    }

    function randomInt(bytes memory seed, int256 min, int256 max)
    internal pure returns (int256) {

        if (min >= max) {
            return min;
        }

        int256 number = int256(keccak256(seed));
        return number % (max - min + 1) + min;
    }

    function randomWeightCard(bytes memory seed, uint256[] memory weights,
        uint256 totalWeight) internal pure returns (uint256) {

        uint256 number = Util.randomUint(seed, 1, totalWeight);

        uint256 cou = 0;
        for(uint i = 0; i < 120; i++) {
            if(weights[i] == 0) {
                continue;
            }
            if (cou >= (number - 1)) {
                return weights[i];
            }
            cou = cou + 1;
        }
        return weights[number - 1];
    }

    function randomWeight(bytes memory seed, uint256[] memory weights,
        uint256 totalWeight) internal pure returns (uint256) {

        uint256 number = Util.randomUint(seed, 1, totalWeight);

        for (uint256 i = weights.length - 1; i != 0; --i) {
            if (number <= weights[i]) {
                return i;
            }

            number -= weights[i];
        }

        return 0;
    }

    function randomProb(bytes memory seed, uint256 nume, uint256 deno)
    internal pure returns (bool) {

        uint256 rand = Util.randomUint(seed, 1, deno);
        return rand <= nume;
    }

}


/**
 * Utility library of inline functions on addresses
 */
library Address {

    /**
     * Returns whether the target address is a contract
     * @dev This function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param account address of the account to check
     * @return whether the target address is a contract
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solium-disable-next-line security/no-inline-assembly
        assembly {size := extcodesize(account)}
        return size > 0;
    }
}


library String {
    function equals(string memory a, string memory b)
    internal pure returns (bool) {

        bytes memory ba = bytes(a);
        bytes memory bb = bytes(b);

        uint256 la = ba.length;
        uint256 lb = bb.length;

        for (uint256 i = 0; i != la && i != lb; ++i) {
            if (ba[i] != bb[i]) {
                return false;
            }
        }

        return la == lb;
    }

    function concat(string memory a, string memory b)
    internal pure returns (string memory) {

        bytes memory ba = bytes(a);
        bytes memory bb = bytes(b);
        bytes memory bc = new bytes(ba.length + bb.length);

        uint256 bal = ba.length;
        uint256 bbl = bb.length;
        uint256 k = 0;

        for (uint256 i = 0; i != bal; ++i) {
            bc[k++] = ba[i];
        }
        for (uint256 i = 0; i != bbl; ++i) {
            bc[k++] = bb[i];
        }

        return string(bc);
    }
}

library UInteger {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "add error");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(a >= b, "sub error");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "mul error");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function toString(uint256 a, uint256 radix)
    internal pure returns (string memory) {

        if (a == 0) {
            return "0";
        }

        uint256 length = 0;
        for (uint256 n = a; n != 0; n /= radix) {
            length++;
        }

        bytes memory bs = new bytes(length);

        for (uint256 i = length - 1; a != 0; --i) {
            uint256 b = a % radix;
            a /= radix;

            if (b < 10) {
                bs[i] = bytes1(uint8(b + 48));
            } else {
                bs[i] = bytes1(uint8(b + 87));
            }
        }

        return string(bs);
    }

    function toString(uint256 a) internal pure returns (string memory) {
        return UInteger.toString(a, 10);
    }

}


/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant alphabet = "0123456789abcdef";

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
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}

library Base64 {

    bytes constant private base64stdchars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    bytes constant private base64urlchars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";

    function encode(string memory _str) internal pure returns (string memory) {

        bytes memory _bs = bytes(_str);
        uint256 rem = _bs.length % 3;

        uint256 res_length = (_bs.length + 2) / 3 * 4 - ((3 - rem) % 3);
        bytes memory res = new bytes(res_length);

        uint256 i = 0;
        uint256 j = 0;

        for (; i + 3 <= _bs.length; i += 3) {
            (res[j], res[j + 1], res[j + 2], res[j + 3]) = encode3(
                uint8(_bs[i]),
                uint8(_bs[i + 1]),
                uint8(_bs[i + 2])
            );

            j += 4;
        }

        if (rem != 0) {
            uint8 la0 = uint8(_bs[_bs.length - rem]);
            uint8 la1 = 0;

            if (rem == 2) {
                la1 = uint8(_bs[_bs.length - 1]);
            }

            (byte b0, byte b1, byte b2,) = encode3(la0, la1, 0);
            res[j] = b0;
            res[j + 1] = b1;
            if (rem == 2) {
                res[j + 2] = b2;
            }
        }

        return string(res);
    }

    function encode3(uint256 a0, uint256 a1, uint256 a2)
    private
    pure
    returns (byte b0, byte b1, byte b2, byte b3)
    {

        uint256 n = (a0 << 16) | (a1 << 8) | a2;

        uint256 c0 = (n >> 18) & 63;
        uint256 c1 = (n >> 12) & 63;
        uint256 c2 = (n >> 6) & 63;
        uint256 c3 = (n) & 63;

        b0 = base64urlchars[c0];
        b1 = base64urlchars[c1];
        b2 = base64urlchars[c2];
        b3 = base64urlchars[c3];
    }

}

library Integer {
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;

        if (a < 0 && b < 0) {
            require(c < 0, "add error");
        } else if (a > 0 && b > 0) {
            require(c > 0, "add error");
        }

        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;

        if (a < 0 && b > 0) {
            require(c < 0, "sub error");
        } else if (a >= 0 && b < 0) {
            require(c > 0, "sub error");
        }

        return c;
    }

    function mul(int256 a, int256 b) internal pure returns (int256) {
        if (a == 0) {
            return 0;
        }

        int256 c = a * b;
        require(c / a == b, "mul error");
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(a != (int256(1) << 255) || b != - 1, "div error");
        return a / b;
    }

    function toString(int256 a, uint256 radix)
    internal pure returns (string memory) {

        if (a == 0) {
            return "0";
        }

        uint256 m = a < 0 ? uint256(- a) : uint256(a);

        uint256 length = 0;
        for (uint256 n = m; n != 0; n /= radix) {
            ++length;
        }

        bytes memory bs;
        if (a < 0) {
            bs = new bytes(++length);
            bs[0] = bytes1(uint8(45));
        } else {
            bs = new bytes(length);
        }

        for (uint256 i = length - 1; m != 0; --i) {
            uint256 b = m % radix;
            m /= radix;

            if (b < 10) {
                bs[i] = bytes1(uint8(b + 48));
            } else {
                bs[i] = bytes1(uint8(b + 87));
            }
        }

        return string(bs);
    }

    function toString(int256 a) internal pure returns (string memory) {
        return Integer.toString(a, 10);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

import "./ERC721.sol";
import "../lib/Util.sol";

contract ASDICCard is ERC721 {
    using Address for address;
    using Strings for uint256;

    mapping(address => bool) public packages;
    mapping(uint256 => uint16) public _cardType;

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {
        packages[msg.sender] = true;
    }

    string public uriPrefix = "https://ipfs.org/ipfs/";

    uint256 public total;

    function setMaxHoldCard(uint256 num) external onlyOwner {
        maxHoldCard = num;
    }

    function mint(address to, uint16 cardType) public returns (uint256) {
        require(packages[msg.sender], "Card: Card only");
        total++;
        uint256 tokenId = total;
        _cardType[tokenId] = cardType;
        _addTokenTo(to, tokenId);
        return tokenId;
    }

    function batchByAmountMint(
        address to,
        uint16 _type,
        uint256 _num
    ) external returns (uint256[] memory) {
        require(packages[msg.sender], "package only");

        uint256[] memory tokenIds = new uint256[](_num);
        for (uint256 i = 0; i != _num; ++i) {
            tokenIds[i] = mint(to, _type);
        }
        return tokenIds;
    }

    function batchMint(address to, uint16[] memory cardTypes)
        external
        returns (uint256[] memory)
    {
        require(packages[msg.sender], "package only");

        uint256 length = cardTypes.length;
        uint256[] memory tokenIds = new uint256[](length);
        for (uint256 i = 0; i != length; ++i) {
            tokenIds[i] = mint(to, cardTypes[i]);
        }
        return tokenIds;
    }

    function safeBatchTransferFrom(address from, address to,
        uint256[] memory tokenIds) external {

        safeBatchTransferFrom(from, to, tokenIds, "");
    }

    function safeBatchTransferFrom(address from, address to,
        uint256[] memory tokenIds, bytes memory data) public {

        batchTransferFrom(from, to, tokenIds);

        if (to.isContract()) {
            require(IERC721TokenReceiverEx(to)
            .onERC721ExReceived(msg.sender, from, tokenIds, data)
                == Util.ERC721_RECEIVER_EX_RETURN,
                "onERC721ExReceived() return invalid");
        }
    }

    function batchTransferFrom(address from, address to,
        uint256[] memory tokenIds) public {
        require(!_isExcludedFrom[from], "sender is excluded");
        require(from != address(0), "from is zero address");
        require(to != address(0), "to is zero address");

        uint256 length = tokenIds.length;
        address sender = msg.sender;

        bool approval = from == sender || approvalForAlls[from][sender];

        for (uint256 i = 0; i != length; ++i) {
            uint256 tokenId = tokenIds[i];

            require(from == tokenOwners[tokenId], "from must be owner");
            require(approval || sender == tokenApprovals[tokenId],
                "sender must be owner or approvaled");

            if (tokenApprovals[tokenId] != address(0)) {
                delete tokenApprovals[tokenId];
            }

            _removeTokenFrom(from, tokenId);
            _addTokenTo(to, tokenId);

            emit Transfer(from, to, tokenId);
        }
    }

    function batchBurn(uint256[] memory tokenIds) external {
        for (uint256 i = 0; i != tokenIds.length; i++) {
            _removeTokenFrom(msg.sender, tokenIds[i]);
        }
    }

    function setPackage(address package, bool enable) external onlyOwner {
        packages[package] = enable;
    }

    function _baseURI() internal view returns (string memory) {
        return uriPrefix;
    }

    function tokenURI(uint256 tokenId)
        view
        override
        public
        returns (string memory)
    {
        require(_cardType[tokenId] > 0, "not card");
        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(
                    abi.encodePacked(
                        baseURI,
                        Base64.encode(
                            uint256(_cardType[tokenId]).toString()
                        )
                    )
                )
                : "";
    }

    function setUriPrefix(string memory prefix) external onlyOwner {
        uriPrefix = prefix;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

import "../interfaces/IERC721.sol";

import "../lib/Util.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract ERC721 is Ownable, IERC165, IERC721, IERC721Metadata {
    using Address for address;

    bytes4 private constant INTERFACE_ID_ERC165 = 0x01ffc9a7;

    bytes4 private constant INTERFACE_ID_ERC721 = 0x80ac58cd;

    bytes4 private constant INTERFACE_ID_ERC721Metadata = 0x5b5e139f;

    string public override name;
    string public override symbol;
    uint256 internal maxHoldCard = 10;

    mapping(address => uint256[]) internal ownerTokens;
    mapping(uint256 => uint256) internal tokenIndexs;
    mapping(uint256 => address) internal tokenOwners;

    mapping(uint256 => address) internal tokenApprovals;
    mapping(address => mapping(address => bool)) internal approvalForAlls;
    mapping(address => bool) public _isExcludedFrom;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function excludeFrom(address account) external onlyOwner {
        _isExcludedFrom[account] = true;
    }

    function includeInFrom(address account) external onlyOwner {
        _isExcludedFrom[account] = false;
    }

    function balanceOf(address owner) external view override returns (uint256) {
        require(owner != address(0), "owner is zero address");
        return ownerTokens[owner].length;
    }

    // [startIndex, endIndex)
    function tokensOf(
        address owner,
        uint256 startIndex,
        uint256 endIndex
    ) external view returns (uint256[] memory) {
        require(owner != address(0), "owner is zero address");

        uint256[] storage tokens = ownerTokens[owner];
        if (endIndex == 0 || endIndex > tokens.length) {
            return tokens;
        }

        require(startIndex < endIndex, "invalid index");

        uint256[] memory result = new uint256[](endIndex - startIndex);
        for (uint256 i = startIndex; i != endIndex; ++i) {
            result[i] = tokens[i];
        }

        return result;
    }

    function ownerOf(uint256 tokenId) external view override returns (address) {
        address owner = tokenOwners[tokenId];
        require(owner != address(0), "nobody own the token");
        return owner;
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external payable override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public payable override {
        _transferFrom(from, to, tokenId);

        if (to.isContract()) {
            require(
                IERC721TokenReceiver(to).onERC721Received(
                    msg.sender,
                    from,
                    tokenId,
                    data
                ) == Util.ERC721_RECEIVER_RETURN,
                "onERC721Received() return invalid"
            );
        }
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external payable override {
        _transferFrom(from, to, tokenId);
    }

    function _transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) internal {
        require(!_isExcludedFrom[from], "sender is excluded");
        require(from != address(0), "from is zero address");
        require(to != address(0), "to is zero address");

        require(from == tokenOwners[tokenId], "from must be owner");

        require(
            msg.sender == from ||
                msg.sender == tokenApprovals[tokenId] ||
                approvalForAlls[from][msg.sender],
            "sender must be owner or approvaled"
        );

        if (tokenApprovals[tokenId] != address(0)) {
            delete tokenApprovals[tokenId];
        }

        _removeTokenFrom(from, tokenId);
        _addTokenTo(to, tokenId);

        emit Transfer(from, to, tokenId);
    }

    // ensure everything is ok before call it
    function _removeTokenFrom(address from, uint256 tokenId) internal {
        uint256 index = tokenIndexs[tokenId];

        uint256[] storage tokens = ownerTokens[from];
        uint256 indexLast = tokens.length - 1;

        // save gas
        // if (index != indexLast) {
        uint256 tokenIdLast = tokens[indexLast];
        tokens[index] = tokenIdLast;
        tokenIndexs[tokenIdLast] = index;
        // }

        tokens.pop();

        // delete tokenIndexs[tokenId]; // save gas
        delete tokenOwners[tokenId];
    }

    // ensure everything is ok before call it
    function _addTokenTo(address to, uint256 tokenId) internal {
        uint256[] storage tokens = ownerTokens[to];
        tokenIndexs[tokenId] = tokens.length;
        tokens.push(tokenId);

        tokenOwners[tokenId] = to;
    }

    function approve(address to, uint256 tokenId) external payable override {
        address owner = tokenOwners[tokenId];

        require(
            msg.sender == owner || approvalForAlls[owner][msg.sender],
            "sender must be owner or approved for all"
        );

        tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function setApprovalForAll(address to, bool approved) external override {
        approvalForAlls[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    function getApproved(uint256 tokenId)
        external
        view
        override
        returns (address)
    {
        require(tokenOwners[tokenId] != address(0), "nobody own then token");

        return tokenApprovals[tokenId];
    }

    function isApprovedForAll(address owner, address operator)
        external
        view
        override
        returns (bool)
    {
        return approvalForAlls[owner][operator];
    }

    function supportsInterface(bytes4 interfaceID)
        external
        pure
        override
        returns (bool)
    {
        return
            interfaceID == INTERFACE_ID_ERC165 ||
            interfaceID == INTERFACE_ID_ERC721 ||
            interfaceID == INTERFACE_ID_ERC721Metadata;
    }
}