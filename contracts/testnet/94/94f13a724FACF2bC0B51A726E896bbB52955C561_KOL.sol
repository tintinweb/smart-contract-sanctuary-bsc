// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./Strings.sol";
import "./IERC165.sol";
import "./IERC721.sol";
import "./IERC721TokenReceiver.sol";
import "./IERC721Metadata.sol";

contract ERC721 is IERC165, IERC721 {

    using Strings for uint256;

    string public name;
    string public symbol;
    mapping(uint => address) public ownerOf;
    mapping(uint => address) public getApproved;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165) returns (bool) {
        return interfaceId == type(IERC165).interfaceId || interfaceId == type(IERC721).interfaceId || interfaceId == type(IERC721TokenReceiver).interfaceId || interfaceId == type(IERC721Metadata).interfaceId;
    }

    function setApprovalForAll(address operator, bool approved) external {
        isApprovedForAll[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function approve(address spender, uint id) external {
        address owner = ownerOf[id];
        require(msg.sender == owner || isApprovedForAll[owner][msg.sender], "not authorized");

        getApproved[id] = spender;
        emit Approval(owner, spender, id);
    }

    function _isApprovedOrOwner(address owner, address spender, uint id) internal view returns (bool) {
        return spender == owner || isApprovedForAll[owner][spender] || spender == getApproved[id];
    }

    function transferFrom(address from, address to, uint id) public {
        require(from == ownerOf[id], "from != owner");
        require(to != address(0), "transfer to zero address");
        require(_isApprovedOrOwner(from, msg.sender, id), "not authorized");

        balanceOf[from]--;
        balanceOf[to]++;
        ownerOf[id] = to;
        delete getApproved[id];
        emit Transfer(from, to, id);
    }

    function safeTransferFrom(address from, address to, uint id) external {
        transferFrom(from, to, id);

        require(to.code.length == 0 || IERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, "") == IERC721TokenReceiver.onERC721Received.selector,
            "unsafe recipient"
        );
    }

    function safeTransferFrom(address from, address to, uint id, bytes calldata data) external {
        transferFrom(from, to, id);

        require(to.code.length == 0 || IERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, data) == IERC721TokenReceiver.onERC721Received.selector,
            "unsafe recipient"
        );
    }

    function _mint(address to, uint id) internal {
        require(to != address(0), "mint to zero address");
        require(ownerOf[id] == address(0), "already minted");

        balanceOf[to]++;
        ownerOf[id] = to;

        emit Transfer(address(0), to, id);
    }

    function _burn(uint id) internal {
        address owner = ownerOf[id];
        require(owner != address(0), "not minted");

        balanceOf[owner] -= 1;

        delete ownerOf[id];
        delete getApproved[id];

        emit Transfer(owner, address(0), id);
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return ownerOf[tokenId] != address(0);
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IERC721 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 _tokenId) external;
    function approve(address approved, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
    function getApproved(uint256 tokenId) external view returns (address);
    function isApprovedForAll(address owner, address operator) external view returns (bool);

}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IERC721Metadata {

    function name() external view returns (string memory name);
    function symbol() external view returns (string memory symbol);
    function tokenURI(uint256 tokenId) external view returns (string memory);

}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IERC721TokenReceiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) external returns (bytes4);

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./ERC721.sol";
import "./Ownable.sol";

contract KOL is ERC721, Ownable {

    string baseTokenURI;

    constructor(string memory _initBaseURI) ERC721("blockchain YT KOL", "KOL") {
        setBaseURI(_initBaseURI);
    }

    function mint(address to, uint id) external {
        _mint(to, id);
    }

    function burn(uint id) external {
        require(msg.sender == ownerOf[id], "not owner");
        _burn(id);
    }

    function setBaseURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

contract Ownable {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    address private _owner;

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    constructor() {
        _transferOwnership(msg.sender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {
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