/**
 *Submitted for verification at BscScan.com on 2022-09-05
*/

// SPDX-License-Identifier: MIT

// Address.sol file
pragma solidity ^0.8.0;
library Address {
  function isContract(address account) internal view returns (bool) {
    uint256 size;
    assembly {
      size := extcodesize(account)
    }
    return size > 0;
  }
  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, "Address: insufficient balance");

    (bool success, ) = recipient.call{value: amount}("");
    require(success, "Address: unable to send value, recipient may have reverted");
  }
  function functionCall(address target, bytes memory data) internal returns (bytes memory) {
    return functionCall(target, data, "Address: low-level call failed");
  }
  function functionCall(address target,bytes memory data,string memory errorMessage) internal returns (bytes memory) {
    return functionCallWithValue(target, data, 0, errorMessage);
  }
  function functionCallWithValue(address target,bytes memory data,uint256 value) internal returns (bytes memory) {
    return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
  }
  function functionCallWithValue(address target,bytes memory data,uint256 value,string memory errorMessage) internal returns (bytes memory) {
    require(address(this).balance >= value, "Address: insufficient balance for call");
    require(isContract(target), "Address: call to non-contract");

    (bool success, bytes memory returndata) = target.call{value: value}(data);
    return verifyCallResult(success, returndata, errorMessage);
  }
  function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
    return functionStaticCall(target, data, "Address: low-level static call failed");
  }
  function functionStaticCall(address target,bytes memory data,string memory errorMessage) internal view returns (bytes memory) {
    require(isContract(target), "Address: static call to non-contract");

    (bool success, bytes memory returndata) = target.staticcall(data);
    return verifyCallResult(success, returndata, errorMessage);
  }
  function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
    return functionDelegateCall(target, data, "Address: low-level delegate call failed");
  }
  function functionDelegateCall(address target,bytes memory data,string memory errorMessage) internal returns (bytes memory) {
    require(isContract(target), "Address: delegate call to non-contract");
    (bool success, bytes memory returndata) = target.delegatecall(data);
    return verifyCallResult(success, returndata, errorMessage);
  }
  function verifyCallResult(bool success,bytes memory returndata,string memory errorMessage) internal pure returns (bytes memory) {
    if (success) {
      return returndata;
    } else {
      if (returndata.length > 0) {
        assembly {
          let returndata_size := mload(returndata)
          revert(add(32, returndata), returndata_size)
        }
      } else {
        revert(errorMessage);
      }
    }
  }
}

// Strings.sol file
pragma solidity ^0.8.0;
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

// Context.sol file
pragma solidity ^0.8.0;
abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }
  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }
}
// Ownable.sol file
pragma solidity ^0.8.0;
abstract contract Ownable is Context {
  address private _owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor() {
    _setOwner(_msgSender());
  }
  function owner() public view virtual returns (address) {
    return _owner;
  }
  modifier onlyOwner() {
    require(owner() == _msgSender(), "Ownable: caller is not the owner");
    _;
  }
  function renounceOwnership() public virtual onlyOwner {
    _setOwner(address(0));
  }
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

// IERC165.sol file
pragma solidity ^0.8.0;
interface IERC165 {
  function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// IERC721.sol file
pragma solidity ^0.8.0;
interface IERC721 is IERC165 {
  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
  event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
  event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

  function balanceOf(address owner) external view returns (uint256 balance);
  function ownerOf(uint256 tokenId) external view returns (address owner);
  function safeTransferFrom(address from,address to,uint256 tokenId) external;
  function transferFrom(address from,address to,uint256 tokenId) external;
  function approve(address to, uint256 tokenId) external;
  function getApproved(uint256 tokenId) external view returns (address operator);
  function setApprovalForAll(address operator, bool _approved) external;
  function isApprovedForAll(address owner, address operator) external view returns (bool);
  function safeTransferFrom(address from,address to,uint256 tokenId,bytes calldata data) external;
}

// IERC721Receiver.sol file
pragma solidity ^0.8.0;
interface IERC721Receiver {
  function onERC721Received(address operator,address from,uint256 tokenId,bytes calldata data) external returns (bytes4);
}

// IERC721Metadata.sol file
pragma solidity ^0.8.0;
interface IERC721Metadata is IERC721 {
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function tokenURI(uint256 tokenId) external view returns (string memory);
}

// ERC165.sol file
pragma solidity ^0.8.0;
abstract contract ERC165 is IERC165 {
  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return interfaceId == type(IERC165).interfaceId;
  }
}
// ERC721.sol file
pragma solidity ^0.8.0;
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
  using Address for address;
  using Strings for uint256;
  string private _name;
  string private _symbol;
  // Mapping from token ID to owner address
  mapping(uint256 => address) private _owners;
  // Mapping owner address to token count
  mapping(address => uint256) private _balances;
  // Mapping from token ID to approved address
  mapping(uint256 => address) private _tokenApprovals;
  // Mapping from owner to operator approvals
  mapping(address => mapping(address => bool)) private _operatorApprovals;
  constructor(string memory name_, string memory symbol_) {
    _name = name_;
    _symbol = symbol_;
  }
  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
    return
      interfaceId == type(IERC721).interfaceId ||
      interfaceId == type(IERC721Metadata).interfaceId ||
      super.supportsInterface(interfaceId);
  }
  function balanceOf(address owner) public view virtual override returns (uint256) {
    require(owner != address(0), "ERC721: balance query for the zero address");
    return _balances[owner];
  }
  function ownerOf(uint256 tokenId) public view virtual override returns (address) {
    address owner = _owners[tokenId];
    require(owner != address(0), "ERC721: owner query for nonexistent token");
    return owner;
  }
  function name() public view virtual override returns (string memory) {
    return _name;
  }
  function symbol() public view virtual override returns (string memory) {
    return _symbol;
  }
  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
    string memory baseURI = _baseURI();
    return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
  }
  function _baseURI() internal view virtual returns (string memory) {
    return "";
  }
  function approve(address to, uint256 tokenId) public virtual override {
    address owner = ERC721.ownerOf(tokenId);
    require(to != owner, "ERC721: approval to current owner");
    require(
      _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
      "ERC721: approve caller is not owner nor approved for all"
    );
    _approve(to, tokenId);
  }
  function getApproved(uint256 tokenId) public view virtual override returns (address) {
    require(_exists(tokenId), "ERC721: approved query for nonexistent token");
    return _tokenApprovals[tokenId];
  }
  function setApprovalForAll(address operator, bool approved) public virtual override {
    require(operator != _msgSender(), "ERC721: approve to caller");
    _operatorApprovals[_msgSender()][operator] = approved;
    emit ApprovalForAll(_msgSender(), operator, approved);
  }
  function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
    return _operatorApprovals[owner][operator];
  }
  function transferFrom(address from,address to,uint256 tokenId) public virtual override {
    require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
    _transfer(from, to, tokenId);
  }
  function safeTransferFrom(address from,address to,uint256 tokenId) public virtual override {
    safeTransferFrom(from, to, tokenId, "");
  }
  function safeTransferFrom(address from,address to,uint256 tokenId,bytes memory _data) public virtual override {
    require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
    _safeTransfer(from, to, tokenId, _data);
  }
  function _safeTransfer(address from,address to,uint256 tokenId,bytes memory _data) internal virtual {
    _transfer(from, to, tokenId);
    require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
  }
  function _exists(uint256 tokenId) internal view virtual returns (bool) {
    return _owners[tokenId] != address(0);
  }
  function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
    require(_exists(tokenId), "ERC721: operator query for nonexistent token");
    address owner = ERC721.ownerOf(tokenId);
    return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
  }
  function _safeMint(address to, uint256 tokenId) internal virtual {
    _safeMint(to, tokenId, "");
  }
  function _safeMint(address to,uint256 tokenId,bytes memory _data) internal virtual {
    _mint(to, tokenId);
    require(
        _checkOnERC721Received(address(0), to, tokenId, _data),
        "ERC721: transfer to non ERC721Receiver implementer"
    );
  }
  function _mint(address to, uint256 tokenId) internal virtual {
    require(to != address(0), "ERC721: mint to the zero address");
    require(!_exists(tokenId), "ERC721: token already minted");

    _beforeTokenTransfer(address(0), to, tokenId);

    _balances[to] += 1;
    _owners[tokenId] = to;

    emit Transfer(address(0), to, tokenId);
  }
  function _burn(uint256 tokenId) internal virtual {
    address owner = ERC721.ownerOf(tokenId);

    _beforeTokenTransfer(owner, address(0), tokenId);

    // Clear approvals
    _approve(address(0), tokenId);

    _balances[owner] -= 1;
    delete _owners[tokenId];

    emit Transfer(owner, address(0), tokenId);
  }
  function _transfer(address from,address to,uint256 tokenId) internal virtual {
    require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
    require(to != address(0), "ERC721: transfer to the zero address");

    _beforeTokenTransfer(from, to, tokenId);

    // Clear approvals from the previous owner
    _approve(address(0), tokenId);

    _balances[from] -= 1;
    _balances[to] += 1;
    _owners[tokenId] = to;

    emit Transfer(from, to, tokenId);
  }
  function _approve(address to, uint256 tokenId) internal virtual {
    _tokenApprovals[tokenId] = to;
    emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
  }
  function _checkOnERC721Received(address from,address to,uint256 tokenId,bytes memory _data) private returns (bool) {
    if (to.isContract()) {
      try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
        return retval == IERC721Receiver.onERC721Received.selector;
      } catch (bytes memory reason) {
        if (reason.length == 0) {
          revert("ERC721: transfer to non ERC721Receiver implementer");
        } else {
          assembly {
            revert(add(32, reason), mload(reason))
          }
        }
      }
    } else {
      return true;
    }
  }
  function _beforeTokenTransfer(address from,address to,uint256 tokenId) internal virtual {}
}


// IERC721Enumerable.sol file
pragma solidity ^0.8.0;
interface IERC721Enumerable is IERC721 {
  function totalSupply() external view returns (uint256);
  function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
  function tokenByIndex(uint256 index) external view returns (uint256);
}

// ERC721Enumerable.sol file
pragma solidity ^0.8.0;
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
  // Mapping from owner to list of owned token IDs
  mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

  // Mapping from token ID to index of the owner tokens list
  mapping(uint256 => uint256) private _ownedTokensIndex;

  // Array with all token ids, used for enumeration
  uint256[] private _allTokens;

  // Mapping from token id to position in the allTokens array
  mapping(uint256 => uint256) private _allTokensIndex;

  function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
    return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
  }
  function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
    require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
    return _ownedTokens[owner][index];
  }
  function totalSupply() public view virtual override returns (uint256) {
    return _allTokens.length;
  }
  function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
    require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
    return _allTokens[index];
  }
  function _beforeTokenTransfer(address from,address to,uint256 tokenId) internal virtual override {
    super._beforeTokenTransfer(from, to, tokenId);

    if (from == address(0)) {
        _addTokenToAllTokensEnumeration(tokenId);
    } else if (from != to) {
        _removeTokenFromOwnerEnumeration(from, tokenId);
    }
    if (to == address(0)) {
        _removeTokenFromAllTokensEnumeration(tokenId);
    } else if (to != from) {
        _addTokenToOwnerEnumeration(to, tokenId);
    }
  }
  function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
    uint256 length = ERC721.balanceOf(to);
    _ownedTokens[to][length] = tokenId;
    _ownedTokensIndex[tokenId] = length;
  }
  function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
    _allTokensIndex[tokenId] = _allTokens.length;
    _allTokens.push(tokenId);
  }
  function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
    // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
    // then delete the last slot (swap and pop).

    uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
    uint256 tokenIndex = _ownedTokensIndex[tokenId];

    // When the token to delete is the last token, the swap operation is unnecessary
    if (tokenIndex != lastTokenIndex) {
        uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

        _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
    }

    // This also deletes the contents at the last position of the array
    delete _ownedTokensIndex[tokenId];
    delete _ownedTokens[from][lastTokenIndex];
  }
  function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
    uint256 lastTokenIndex = _allTokens.length - 1;
    uint256 tokenIndex = _allTokensIndex[tokenId];
    uint256 lastTokenId = _allTokens[lastTokenIndex];
    _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
    _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
    // This also deletes the contents at the last position of the array
    delete _allTokensIndex[tokenId];
    _allTokens.pop();
  }
}


// IERC20.sol file
pragma solidity ^0.8.0;
interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// ReentrancyGuard.sol file
pragma solidity ^0.8.0;
abstract contract ReentrancyGuard {
  uint256 private constant _NOT_ENTERED = 1;
  uint256 private constant _ENTERED = 2;

  uint256 private _status;

  constructor() {
    _status = _NOT_ENTERED;
  }
  modifier nonReentrant() {
    require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
    _status = _ENTERED;
    _;
    _status = _NOT_ENTERED;
  }
}

// NoContractGuard.sol file
pragma solidity ^0.8.0;
abstract contract NoContractGuard  {
  modifier notContract() {
    require(!_isContract(msg.sender), "Contract not allowed");
    require(msg.sender == tx.origin, "Proxy contract not allowed");
    _;
  }
  function _isContract(address _addr) internal view returns (bool) {
    uint256 size;
    assembly {
      size := extcodesize(_addr)
    }
    return size > 0;
  }    
}

// EnumerableSet.sol file
pragma solidity ^0.8.0;
library EnumerableSet {
    struct Set {
      // Storage of set values
      bytes32[] _values;
      // Position of the value in the `values` array, plus 1 because index 0
      // means a value is not in the set.
      mapping(bytes32 => uint256) _indexes;
    }
    function _add(Set storage set, bytes32 value) private returns (bool) {
      if (!_contains(set, value)) {
        set._values.push(value);
        // The value is stored at length-1, but we add 1 to all indexes
        // and use 0 as a sentinel value
        set._indexes[value] = set._values.length;
        return true;
      } else {
        return false;
      }
    }
    function _remove(Set storage set, bytes32 value) private returns (bool) {
      // We read and store the value's index to prevent multiple reads from the same storage slot
      uint256 valueIndex = set._indexes[value];

      if (valueIndex != 0) {
        // Equivalent to contains(set, value)
        // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
        // the array, and then remove the last element (sometimes called as 'swap and pop').
        // This modifies the order of the array, as noted in {at}.

        uint256 toDeleteIndex = valueIndex - 1;
        uint256 lastIndex = set._values.length - 1;

      if (lastIndex != toDeleteIndex) {
        bytes32 lastvalue = set._values[lastIndex];

        // Move the last value to the index where the value to delete is
        set._values[toDeleteIndex] = lastvalue;
        // Update the index for the moved value
        set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
      }
      set._values.pop();
      delete set._indexes[value];

      return true;
    } else {
      return false;
    }
  }
  function _contains(Set storage set, bytes32 value) private view returns (bool) {
    return set._indexes[value] != 0;
  }
  function _length(Set storage set) private view returns (uint256) {
    return set._values.length;
  }
  function _at(Set storage set, uint256 index) private view returns (bytes32) {
    return set._values[index];
  }
  function _values(Set storage set) private view returns (bytes32[] memory) {
    return set._values;
  }
  // Bytes32Set
  struct Bytes32Set {
    Set _inner;
  }
  function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
    return _add(set._inner, value);
  }
  function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
    return _remove(set._inner, value);
  }
  function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
    return _contains(set._inner, value);
  }
  function length(Bytes32Set storage set) internal view returns (uint256) {
    return _length(set._inner);
  }
  function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
    return _at(set._inner, index);
  }
  function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
    return _values(set._inner);
  }
  // AddressSet
  struct AddressSet {
    Set _inner;
  }
  function add(AddressSet storage set, address value) internal returns (bool) {
    return _add(set._inner, bytes32(uint256(uint160(value))));
  }
  function remove(AddressSet storage set, address value) internal returns (bool) {
    return _remove(set._inner, bytes32(uint256(uint160(value))));
  }
  function contains(AddressSet storage set, address value) internal view returns (bool) {
    return _contains(set._inner, bytes32(uint256(uint160(value))));
  }
  function length(AddressSet storage set) internal view returns (uint256) {
    return _length(set._inner);
  }
  function at(AddressSet storage set, uint256 index) internal view returns (address) {
    return address(uint160(uint256(_at(set._inner, index))));
  }
  function values(AddressSet storage set) internal view returns (address[] memory) {
    bytes32[] memory store = _values(set._inner);
    address[] memory result;

    assembly {
      result := store
    }

    return result;
  }
  // UintSet
  struct UintSet {
    Set _inner;
  }
  function add(UintSet storage set, uint256 value) internal returns (bool) {
    return _add(set._inner, bytes32(value));
  }
  function remove(UintSet storage set, uint256 value) internal returns (bool) {
    return _remove(set._inner, bytes32(value));
  }
  function contains(UintSet storage set, uint256 value) internal view returns (bool) {
    return _contains(set._inner, bytes32(value));
  }
  function length(UintSet storage set) internal view returns (uint256) {
    return _length(set._inner);
  }
  function at(UintSet storage set, uint256 index) internal view returns (uint256) {
    return uint256(_at(set._inner, index));
  }
  function values(UintSet storage set) internal view returns (uint256[] memory) {
    bytes32[] memory store = _values(set._inner);
    uint256[] memory result;

    assembly {
      result := store
    }

    return result;
  }
}

// NFT.sol file
contract KCCNFT is NoContractGuard, ReentrancyGuard, ERC721Enumerable, Ownable {
  using EnumerableSet for EnumerableSet.UintSet;

  // Events
  event TokenMinted(address indexed user,uint256 tokenId,uint256 tokenLevel);
  event AddTokenOnSale(address owner,uint256 _tokenId,uint256 _price);
  event RemoveTokenOnSale(address owner,uint256 _tokenId);
  event TokenTranscation(address from,address to,uint256 tokenId,uint256 price);
  event TokenMinted(address indexed user,uint256[] tokenIds);
  event TokenComposed(address indexed user,uint256 tokenId);

  string public tokenURIPrefix = "https://d-d.design/KCCNFT2/?NFTCode=";

  uint256[] public mintTotalSupplyByLevel = [500000,50000,5000,500];
  uint256[] public mintCostByLevel = [1 ether,12 ether,160 ether,1200 ether];
  uint256[] public mintTotalMintedByLevel = [0,0,0,0];
  uint8 public constant COMP_SIZE = 10;

  uint256 tokenMinted; //current mintedTotal
  struct NFTDetail {
    bool isSale;
    uint256 salePrice;
    uint8 level;  // 1-5
  }
  mapping(uint256 => NFTDetail) tokenTraits;

  address public paidToken;
  address public barn; //msg.sender == address(this) no need approve
  address public receiveAddress;

  EnumerableSet.UintSet private tokensOnSale;

  constructor() ERC721("KCCNFT", 'KCCNFT') { 
    paidToken = 0x3Fb24E86aFDfa44B1C7FB16fC6AF064Fd421C230;
    receiveAddress = 0xF202E15577E522df795446056590Cf46fedfE448;
  }

  // Admin functions
  function setURIPrefix(string memory _tokenURIPrefix) external onlyOwner {
    tokenURIPrefix = _tokenURIPrefix;
  }
  function setMintInfo(uint256[] calldata _mintTotalSupplyByLevel,uint256[] calldata _mintCostByLevel) external onlyOwner {
    require(_mintTotalSupplyByLevel.length == _mintCostByLevel.length && _mintCostByLevel.length == 4,"KCC: invalid mint info args");
    for(uint24 i = 0;i < _mintTotalSupplyByLevel.length;i++) {
      mintTotalSupplyByLevel[i] = _mintTotalSupplyByLevel[i];
      mintCostByLevel[i] = _mintCostByLevel[i];
    }
  }
  function setPaidToken(address _paidToken) external onlyOwner {
    paidToken = _paidToken;
  }
  function setReceiveAddress(address _receiveAddress) external onlyOwner {
    receiveAddress = _receiveAddress;
  }
  function safeWithdraw(address _token, uint256 _amount) public onlyOwner {
    IERC20(_token).transfer( msg.sender, _amount);
  }
  function setBarn(address _barn) external onlyOwner {
    barn = _barn;
  }

  // base read functions
  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");
    return string(abi.encodePacked(tokenURIPrefix, uint2str(_tokenId) ,"&level=", uint2str(uint256(tokenTraits[_tokenId].level)) ) );
  }
  function uint2str( uint256 _i ) public pure returns (string memory str) {
    if (_i == 0) {
      return "0";
    }
    uint256 j = _i;
    uint256 length;
    while (j != 0) {
      length++;
      j /= 10;
    }
    bytes memory bstr = new bytes(length);
    uint256 k = length;
    j = _i;
    while (j != 0){
      bstr[--k] = bytes1(uint8(48 + j % 10));
      j /= 10;
    }
    str = string(bstr);
  }
  function getTokensByAddress(address _owner,uint256 level) public view returns (uint256[] memory listOfOffers) {
    //get nfts by each level, level 5 means all
    uint256[] memory _tokens = new uint256[](balanceOf(_owner));
    uint256 currentLevelTotal = 0;
    for(uint256 i = 0; i < balanceOf(_owner); i++){
      uint256 tokenId = tokenOfOwnerByIndex(_owner, i);
      if(tokenTraits[tokenId].level == level) {
        currentLevelTotal++;
      }
      _tokens[i] = tokenId; 
    }
    if(level == 5) {
      return _tokens;
    }else {
      uint256[] memory _targetLevelTokens = new uint256[](currentLevelTotal);
      uint256 len = 0;
      for(uint256 i = 0;i < _tokens.length;i++) {
        if(tokenTraits[_tokens[i]].level == level) {
          _targetLevelTokens[len] = _tokens[i];
          len++;
        }
      }
      return _targetLevelTokens;
    }
  }
  function getTokenTraits(uint256 tokenId) external view returns (NFTDetail memory) {
    return tokenTraits[tokenId];
  }
  function getTokenLevel(uint256 tokenId) external view returns (uint256) {
    return tokenTraits[tokenId].level;
  }

  //nft mint,compose function
  // Hardcode the Barn's approval so that users don't have to waste gas approving
  function transferFrom(address from,address to,uint256 tokenId) public virtual override(ERC721,IERC721) {
    if (_msgSender() != address(barn)) {
      require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
    }
    _transfer(from, to, tokenId);
  }

  function mint(uint256 amount,uint8 level) external nonReentrant notContract {
    require(mintTotalMintedByLevel[level] + amount <= mintTotalSupplyByLevel[level], "KCC: Current type All tokens minted");
    require(amount > 0 && amount <= 10, "KCC: Invalid mint amount");

    uint256 totalPaidTokenCost = 0;
    uint256[] memory ids = new uint256[](amount);

    for (uint i = 0; i < amount; i++) {
      tokenMinted++;
      mintTotalMintedByLevel[level]++;
      _safeMint(_msgSender(), tokenMinted);
      tokenTraits[tokenMinted].salePrice = 0;
      tokenTraits[tokenMinted].isSale = false;
      tokenTraits[tokenMinted].level = level;
      ids[i] = tokenMinted;
      totalPaidTokenCost += mintCostByLevel[level];
    }
    IERC20(paidToken).transferFrom(_msgSender(), receiveAddress, totalPaidTokenCost);  
    emit TokenMinted(_msgSender(), ids );
  }

  function compose(uint24[COMP_SIZE] calldata tokenIds,uint8 level) external nonReentrant notContract {
    //mint 1 level+1 nft to sender
    tokenMinted++;
    _safeMint(_msgSender(), tokenMinted);
    tokenTraits[tokenMinted].salePrice = 0;
    tokenTraits[tokenMinted].isSale = false;
    tokenTraits[tokenMinted].level = level+1;
    uint256 tokenId = tokenMinted;

    for (uint i = 0; i < COMP_SIZE; i++) {
      require(ownerOf(tokenIds[i]) == _msgSender(), "KCC: AINT YO TOKEN");
      require(level <= 3,"KCC: Current level can not composed");
      require(tokenTraits[tokenIds[i]].level == level && tokenTraits[tokenIds[i]].level <= 3, "KCC: Not same level");
      _transfer(_msgSender(), address(this), tokenIds[i]);
    } 
    emit TokenComposed(_msgSender(), tokenId);
  }  

  //market functions
  function setAvalibleForSale(uint256 _tokenId,uint256 _price) public {
    require(ERC721.ownerOf(_tokenId) == msg.sender, "ERC721: set of token that is not own");
    require(_price > 0,'sale price need to more than zero.');
    tokenTraits[_tokenId].salePrice = _price;
    tokenTraits[_tokenId].isSale = true;
    tokensOnSale.add(_tokenId);
    emit AddTokenOnSale(msg.sender,_tokenId,_price);
  }
  function setDisableForSale(uint256 _tokenId) public {
    require(ERC721.ownerOf(_tokenId) == msg.sender, "ERC721: set of token that is not own");
    tokenTraits[_tokenId].salePrice = 0;
    tokenTraits[_tokenId].isSale = false;
    tokensOnSale.remove(_tokenId);
    emit RemoveTokenOnSale(msg.sender, _tokenId);
  }
  // when transfer token across user,reset sale state
  function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override { 
    super._beforeTokenTransfer(from, to, tokenId);
    tokenTraits[tokenId].salePrice = 0;
    tokenTraits[tokenId].isSale = false;
    tokensOnSale.remove(tokenId);
  }

  function getAllTokensOnSale(uint256 level) public view returns (uint256[] memory listOfOffers) {
    //get all tokens by level   level 5 means all
    uint256 _len = tokensOnSale.length();
    uint256[] memory _tokens = new uint256[](_len);
    uint256 currentLevelTotal = 0;
    for (uint256 index = 0; index < _len; index++) {
      uint256 tokenId = tokensOnSale.at(index);
      if(tokenTraits[tokenId].level == level) {
        currentLevelTotal++;
      }
      _tokens[index] = tokenId;
    }
    if(level == 5) {
      return _tokens;
    }else {
      uint256[] memory _targetLevelTokens = new uint256[](currentLevelTotal);
      uint256 len = 0;
      for(uint256 i = 0;i < _tokens.length;i++) {
        if(tokenTraits[_tokens[i]].level == level) {
          _targetLevelTokens[len] = _tokens[i];
          len++;
        }
      }
      return _targetLevelTokens;
    }
  }
  function getTokensOnSaleByOwner(address _owner,uint256 level) public view returns (uint256[] memory listOfOffers) {
    uint256 _len = 0;
    uint256 _id;

    for(uint256 i = 0;i < balanceOf(_owner);i++){
      _id = tokenOfOwnerByIndex(_owner, i);  
      if(tokenTraits[_id].isSale) {
        _len++;
      }
    }

    if (_len == 0) {
      return new uint256[](0);//returns empty array
    } else {
      uint256[] memory _tokens = new uint256[](_len);
      _len = 0;//reset index of new array
      uint256 currentLevelTotal = 0;
      for(uint256 i = 0; i < balanceOf(_owner); i++){
        _id = tokenOfOwnerByIndex(_owner, i);  
        if (tokenTraits[_id].isSale) {
          _tokens[_len] = _id;
          _len++;
          if(tokenTraits[_id].level == level) {
            currentLevelTotal++;
          }
        }
      }
      if(level == 5) {
        return _tokens;
      }else {
        uint256[] memory _targetLevelTokens = new uint256[](currentLevelTotal);
        uint256 len = 0;
        for(uint256 i = 0;i < _tokens.length;i++) {
          if(tokenTraits[_tokens[i]].level == level) {
            _targetLevelTokens[len] = _tokens[i];
            len++;
          }
        }
        return _targetLevelTokens;
      }
    }   
  }

  function buyNFT(uint256 _tokenId) public {
    address nowOwner = ERC721.ownerOf(_tokenId);
    require(tokenTraits[_tokenId].isSale,'KCC: target NFT is not for sale');
    require(nowOwner != msg.sender,'KCC: Cannot transfer target NFT to yourself!');

    IERC20(paidToken).transferFrom(msg.sender, nowOwner, tokenTraits[_tokenId].salePrice);       
    _safeTransfer(nowOwner, msg.sender, _tokenId, '');
    emit TokenTranscation(nowOwner, msg.sender, _tokenId,tokenTraits[_tokenId].salePrice);
  }
}