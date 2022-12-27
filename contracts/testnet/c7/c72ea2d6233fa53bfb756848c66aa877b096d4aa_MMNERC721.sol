/**
 *Submitted for verification at BscScan.com on 2022-12-26
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <= 0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) external view returns (uint256);
}

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

abstract contract ERC165 is IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

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

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

library EnumerableSet {

    struct Set {
        bytes32[] _values;
        mapping (bytes32 => uint256) _indexes;
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
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;
            bytes32 lastvalue = set._values[lastIndex];
            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based
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
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

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
}

library EnumerableMap {
    struct MapEntry {
        bytes32 _key;
        bytes32 _value;
    }

    struct Map {
        MapEntry[] _entries;
        mapping (bytes32 => uint256) _indexes;
    }

    function _set(Map storage map, bytes32 key, bytes32 value) private returns (bool) {
        uint256 keyIndex = map._indexes[key];

        if (keyIndex == 0) { // Equivalent to !contains(map, key)
            map._entries.push(MapEntry({ _key: key, _value: value }));
            map._indexes[key] = map._entries.length;
            return true;
        } else {
            map._entries[keyIndex - 1]._value = value;
            return false;
        }
    }

    function _remove(Map storage map, bytes32 key) private returns (bool) {
        uint256 keyIndex = map._indexes[key];

        if (keyIndex != 0) { // Equivalent to contains(map, key)

            uint256 toDeleteIndex = keyIndex - 1;
            uint256 lastIndex = map._entries.length - 1;
            MapEntry storage lastEntry = map._entries[lastIndex];
            map._entries[toDeleteIndex] = lastEntry;
            map._indexes[lastEntry._key] = toDeleteIndex + 1; // All indexes are 1-based
            map._entries.pop();
            delete map._indexes[key];
            return true;
        } else {
            return false;
        }
    }

    function _contains(Map storage map, bytes32 key) private view returns (bool) {
        return map._indexes[key] != 0;
    }

    function _length(Map storage map) private view returns (uint256) {
        return map._entries.length;
    }

    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {
        require(map._entries.length > index, "EnumerableMap: index out of bounds");

        MapEntry storage entry = map._entries[index];
        return (entry._key, entry._value);
    }

    function _tryGet(Map storage map, bytes32 key) private view returns (bool, bytes32) {
        uint256 keyIndex = map._indexes[key];
        if (keyIndex == 0) return (false, 0); // Equivalent to contains(map, key)
        return (true, map._entries[keyIndex - 1]._value); // All indexes are 1-based
    }

    function _get(Map storage map, bytes32 key) private view returns (bytes32) {
        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, "EnumerableMap: nonexistent key"); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }

    function _get(Map storage map, bytes32 key, string memory errorMessage) private view returns (bytes32) {
        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, errorMessage); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }

    // UintToAddressMap

    struct UintToAddressMap {
        Map _inner;
    }

    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {
        return _set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
    }

    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {
        return _remove(map._inner, bytes32(key));
    }

    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {
        return _contains(map._inner, bytes32(key));
    }

    function length(UintToAddressMap storage map) internal view returns (uint256) {
        return _length(map._inner);
    }

    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {
        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), address(uint160(uint256(value))));
    }

    function tryGet(UintToAddressMap storage map, uint256 key) internal view returns (bool, address) {
        (bool success, bytes32 value) = _tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(value))));
    }

    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {
        return address(uint160(uint256(_get(map._inner, bytes32(key)))));
    }

    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {
        return address(uint160(uint256(_get(map._inner, bytes32(key), errorMessage))));
    }
}


library Strings {

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
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}

contract ERC721 is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for uint256;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping (address => EnumerableSet.UintSet) private _holderTokens;

    EnumerableMap.UintToAddressMap private _tokenOwners;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    string private _name;

    string private _symbol;

    mapping (uint256 => string) private _tokenURIs;

    string private _baseURI;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _holderTokens[owner].length();
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = baseURI();
        if (bytes(base).length == 0) {
            return _tokenURI;
        }

        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return string(abi.encodePacked(base, tokenId.toString()));
    }

    function baseURI() public view virtual returns (string memory) {
        return _baseURI;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        return _holderTokens[owner].at(index);
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _tokenOwners.length();
    }

    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }

    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || ERC721.isApprovedForAll(owner, _msgSender()),
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

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _tokenOwners.contains(tokenId);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || ERC721.isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId); // internal owner

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

        _holderTokens[owner].remove(tokenId);

        _tokenOwners.remove(tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own"); // internal owner
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(from, to, tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _setBaseURI(string memory baseURI_) internal virtual {
        _baseURI = baseURI_;
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            _msgSender(),
            from,
            tokenId,
            _data
        ), "ERC721: transfer to non ERC721Receiver implementer");
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId); // internal owner
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }
}

interface MMNURI{
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity >=0.6.0 <= 0.8.17;

contract MMNERC721 is Context, ERC721{
    using Address for address;
    using SafeMath for uint256;
    using Strings for uint256;
    address _owner;
    uint256 public MMNERC721ID;
    uint256 public MintPrice = 1e17;
    uint256 public ActiveTime;
    uint256 public EndTime;
    uint public maxAddressNFT;
    uint public maxPerMint;
    uint256 public NFTmaxSupply;
    bool public saleIsActive = true;

    mapping (address => uint256) public mintAmounts;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(string memory name, string memory symbol, uint256 _maxSupply, uint256 _startTime, uint256 _endTime, uint256 _MMNID, uint _MaxPurchase, address _sOwnerAddr) ERC721(name, symbol) {
        NFTmaxSupply = _maxSupply;
        ActiveTime = _startTime;
		EndTime = _endTime;
		MMNERC721ID = _MMNID;
		maxAddressNFT = _MaxPurchase;
		maxPerMint = _MaxPurchase;
		_owner = _sOwnerAddr;
        emit OwnershipTransferred(address(0), _owner);
    }

    function withdraw() external onlyOwner {
		(bool success, ) = owner().call{value: address(this).balance}("");
		require(success, "Transfer failed.");
    }

    function tokensToOwner(address tokenAddr) external onlyOwner{
        uint _ERC20Balance = MMNURI(tokenAddr).balanceOf(address(this));
        require(MMNURI(tokenAddr).transfer(msg.sender, _ERC20Balance));
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }
	
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function flipSaleState() public onlyOwner {
        saleIsActive = !saleIsActive;
    }

    function setMintPrice(uint _MintPrice) public onlyOwner {
        MintPrice = _MintPrice;
    }

    function sMintPrice() public view returns (uint256) {
        return MintPrice;
    }

    function setmaxNFTperAddress(uint _maxTokens) public onlyOwner {
        maxAddressNFT = _maxTokens;
    }

    function setMaxPerMint(uint _maxperMint) public onlyOwner {
        maxPerMint = _maxperMint;
    }

    //Mints NFTs
    function mint(uint numberOfTokens) public payable {
        require(saleIsActive && IsTimeActive(), "Sale must be active to mint NFT");
        require(numberOfTokens <= maxPerMint, "Can only mint maxPerMint tokens at a time");
        require(totalSupply().add(numberOfTokens) <= NFTmaxSupply, "Purchase would exceed max supply of NFTs");
        require(mintAmounts[msg.sender].add(numberOfTokens) <= maxAddressNFT, "Purchase would exceed max supply of NFTs");
        uint256 totalCost = MintPrice.mul(numberOfTokens);
		require(totalCost <= msg.value, "Ether value sent is not correct");
        

        for(uint i = 0; i < numberOfTokens; i++) {
            uint mintIndex = totalSupply();
            if (mintIndex < NFTmaxSupply) {
                _safeMint(msg.sender, mintIndex);
            }
			mintAmounts[msg.sender] += 1;
        }
		refundIfOver(totalCost);
    }

    //Mint team NFTs for free.
    function teamNFT(uint _NFTokens) public onlyOwner {
        require(totalSupply().add(_NFTokens) <= NFTmaxSupply, "Purchase would exceed max supply of NFTs");
        uint supply = totalSupply();
        for (uint i = 0; i < _NFTokens; i++) {
            _safeMint(msg.sender, supply + i);
        }
    }

    function refundIfOver(uint256 price) private {
        if (msg.value > price) {
            (bool success, ) = (msg.sender).call{value: (msg.value - price)}("");
            require(success, "Transfer failed.");
        }
    }

    function MintAmountsOf(address tokenAddr) public view returns (uint256) {
        return mintAmounts[tokenAddr];
    }
	
    function CheckAllID(address tokenAddr) public view returns (uint[] memory) {
        uint _balanceOf = balanceOf(tokenAddr);
		uint[] memory IDAll = new uint[](_balanceOf);
        for (uint i = 0; i < _balanceOf; i++){
		    IDAll[i] = tokenOfOwnerByIndex(tokenAddr, i);
        }
        return IDAll;
    }

    function IsTimeActive() public view returns (bool) {
        bool _IsActive = false;
        if(block.timestamp >= ActiveTime && block.timestamp <= EndTime){
			_IsActive = true;
		}
        return _IsActive;
    }
	
    //Metadata setting
    string private _baseTokenURI;
    string private URISubfile = ".json";
  
    function _baseURI() internal view virtual returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function _SubfileURI() internal view virtual returns (string memory) {
        return URISubfile;
    }

    function setSubfileURI(string calldata sSubfileURI) external onlyOwner {
        URISubfile = sSubfileURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory _preBaseURI = _baseURI();
        return
            bytes(_preBaseURI).length > 0
                ? string(abi.encodePacked(_preBaseURI, tokenId.toString(), _SubfileURI()))
                : "";
    }
}

interface iMMN{
    function transferOwnership(address newOwner) external;
	function balanceOf(address owner) external view returns (uint256 balance);
	function ownerOf(uint256 tokenId) external view returns (address owner);
}

contract MyMasterNFTERC721 {
    using Address for address;
	
    address public MMNOwner;
    address public MMNPFPAddr;
    uint256 public MMNSupply;
	uint256 public ReferrerID;
    uint256 public MMNPrice = 1 ether;
    uint256 public ReferrerRate = 20;
    uint256 public ReturnRate = 10;
    uint256 public MMNPFPRate = 20;
	
    bool public MMNIsActive = true;
	
    constructor() public{
        MMNOwner = msg.sender;
    }
	
    struct MMNERC721data {
        address NFTAddr;
        address NFTOwner;
        uint CreatTime;
        uint MaxNftSupply;
    }
	
    mapping(uint256 => MMNERC721data) public MMNData;
	
    mapping(address => uint256) public MMNNFTAmonts;
	
    mapping(address => mapping (uint256 => uint256)) public MMNSortID;

    mapping(address => mapping (uint256 => address)) public MMNNFTAddr;

    mapping(address => uint256) public MMNPass;

    mapping(uint256 => uint256) public ReferrerCode;
	
    mapping(uint256 => address) public ReferrerAddr;

    event NFTCreatorResult(address indexed _XContract);

    function owner() public view virtual returns (address) {
        return MMNOwner;
    }
	
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function withdraw() external onlyOwner {
		(bool success, ) = owner().call{value: address(this).balance}("");
		require(success, "Transfer failed.");
    }

    function tokensToOwner(address tokenAddr) external onlyOwner{
        uint _ERC20Balance = MMNURI(tokenAddr).balanceOf(address(this));
        require(MMNURI(tokenAddr).transfer(msg.sender, _ERC20Balance));
    }

    function setMMNPrice(uint _MMNPrice) external onlyOwner {
        MMNPrice = _MMNPrice;
    }
	
    function sMMNPrice() public view returns (uint256) {
        return MMNPrice;
    }

    function setReferrerRate(uint _Rate) external onlyOwner {
        require((_Rate + MMNPFPRate + ReturnRate) <= 80, "MMN: Referrer rate error.");
        ReferrerRate = _Rate;
    }
	
    function sReferrerRate() public view returns (uint256) {
        return ReferrerRate;
    }

    function setMMNPFPRate(uint _Rate) external onlyOwner {
        require((_Rate + ReferrerRate + ReturnRate) <= 80, "MMN: Referrer rate error.");
        MMNPFPRate = _Rate;
    }

    function sMMNPFPRate() public view returns (uint256) {
        return MMNPFPRate;
    }

    function setReturnRate(uint _Rate) external onlyOwner {
        require((_Rate + MMNPFPRate + ReferrerRate) <= 80, "MMN: Referrer rate error.");
        ReturnRate = _Rate;
    }

    function sReturnRate() public view returns (uint256) {
        return ReturnRate;
    }

    function setMMNPFPAddr(address _PFPAddr) external onlyOwner {
        MMNPFPAddr = _PFPAddr;
    }

    function setMMNPass(address _addr, uint _amounts) external onlyOwner {
        MMNPass[_addr] = _amounts;
    }

    function IsMyMasterNFTActive() public view returns (bool) {
        return MMNIsActive;
    }

    function SetMyMasterNFTActive() external onlyOwner {
        MMNIsActive = !MMNIsActive;
    }

    function MMNtotalSupply() public view returns (uint256) {
        return MMNSupply;
    }
	
    function transferMMNOwner(uint _NFTID, address newOwner) external {
        require(msg.sender == MMNData[_NFTID].NFTOwner, "Ownable: sender is not owner.");

		iMMN(MMNData[_NFTID].NFTAddr).transferOwnership(newOwner);
		removeNFTAddr(CheckNFTIDSort(_NFTID, msg.sender), msg.sender);
		MMNData[_NFTID].NFTOwner = newOwner;

		MMNSortID[newOwner][MMNNFTAmonts[newOwner]] = _NFTID;
		MMNNFTAddr[newOwner][MMNNFTAmonts[newOwner]] = MMNData[_NFTID].NFTAddr;
		MMNNFTAmonts[msg.sender] -= 1;
		MMNNFTAmonts[newOwner] += 1;
    }
	
    function IsMMNPFPOwner(address _URIAddr) public view returns (bool) {
        return iMMN(MMNPFPAddr).balanceOf(_URIAddr) > 0;
    }

    function IsMMNPass(address _URIAddr) public view returns (bool) {
        return MMNPass[_URIAddr] > 0;
    }

    function IsNFTOwner(address _Addr) public view returns (bool) {
        return MMNNFTAmonts[_Addr] > 0;
    }

    function IsPassActive(uint _Type) public view returns (bool) {
        if (_Type == 0) {
            return MMNPass[msg.sender] > 0;
        } else if (_Type == 1) {
            return iMMN(MMNPFPAddr).balanceOf(msg.sender) > 0;
        } else {
            return MMNPass[msg.sender] > 0;
        }
    }

    function CheckNFTAmounts(address _Addr) public view returns (uint256) {
        return MMNNFTAmonts[_Addr];
    }

    function CheckAllNFTID(address _Addr) public view returns (uint[] memory) {
        uint _balanceOf = MMNNFTAmonts[_Addr];
		uint[] memory IDReturn = new uint[](_balanceOf);
        for (uint i = 0; i < _balanceOf; i++){
		    IDReturn[i] = MMNSortID[_Addr][i];
        }
        return IDReturn;
    }

    function CheckAllNFTAddr(address _Addr) public view returns (address[] memory) {
        uint _balanceOf = MMNNFTAmonts[_Addr];
		address[] memory AddrReturn = new address[](_balanceOf);
        for (uint i = 0; i < _balanceOf; i++){
		    AddrReturn[i] = MMNNFTAddr[_Addr][i];
        }
        return AddrReturn;
    }

    function CheckNFTIDSort(uint _NFTID, address _Addr) public view returns (uint256) {
        require(_Addr == MMNData[_NFTID].NFTOwner, "Ownable: sender is not owner.");
        uint IDSort = 1000000;
        for(uint i = 0; i < CheckNFTAmounts(_Addr); i++) {
            if (_NFTID == MMNSortID[_Addr][i]) {
                IDSort = i;
                return IDSort;
            }
        }
        return IDSort;
    }
	
    function removeNFTAddr(uint index, address _Addr) internal returns (bool) {
        uint _NFTLength = CheckNFTAmounts(_Addr);
        require(index < _NFTLength, "Gaia : Length error.");
        for (uint i = index; i< _NFTLength - 1; i++){
            MMNSortID[_Addr][i] = MMNSortID[_Addr][i+1];
            MMNNFTAddr[_Addr][i] = MMNNFTAddr[_Addr][i+1];
        }
        return true;
    }

    function refundIfOver(uint256 price) private {
        if (msg.value > price) {
            (bool success, ) = (msg.sender).call{value: (msg.value - price)}("");
            require(success, "Transfer failed.");
        }
    }

    //----------------↓↓↓---Referrer---↓↓↓-------------------------
	
	function setReferrerCode(uint _ReferrerCode, address _addr) external onlyOwner{
        ReferrerCode[ReferrerID] = _ReferrerCode;
        ReferrerAddr[ReferrerID] = _addr;
        ReferrerID += 1;
    }

    function isReferrerCode(uint _ReferrerCode) public view returns (bool) {
		bool isCode = false;
	    for (uint i = 0; i < ReferrerID; i++) {
            if(ReferrerCode[i] == _ReferrerCode){
				isCode = true;
				return isCode;
            }
        }
        return isCode;
    }
	
    function isReferrerAddr(address _Addr) public view returns (bool) {
		bool isAddr = false;
	    for (uint i = 0; i < ReferrerID; i++) {
            if(ReferrerAddr[i] == _Addr){
				isAddr = true;
				return isAddr;
            }
        }
        return isAddr;
    }
	
    function getReferrerSort(uint _ReferrerCode) public view returns (uint256) {
	    require(isReferrerCode(_ReferrerCode), "MMN: Referrer code does not exist.");
		uint ReferrerSort = 1000000;
	
	    for (uint i = 0; i < ReferrerID; i++) {
            if(ReferrerCode[i] == _ReferrerCode){
				ReferrerSort = i;
				return ReferrerSort;
            }
        }
        return ReferrerSort;
    }
	
    function getReferrer(uint _ReferrerCode) public view returns (address) {
	    require(isReferrerCode(_ReferrerCode), "MMN: Referrer Code does not exist.");
		uint ReferrerSort = getReferrerSort(_ReferrerCode);
        return ReferrerAddr[ReferrerSort];
    }

    function getReferrerCode(address _Addr) public view returns (uint256) {
	    require(isReferrerAddr(_Addr), "MMN: Referrer Code does not exist.");
		
	    for (uint i = 0; i < ReferrerID; i++) {
            if(ReferrerAddr[i] == _Addr){
				return ReferrerCode[i];
            }
        }
    }

    function getReferrerAddr(uint index) public view returns (uint256 _ReferrerCode, address _Addr) {
	    require(index < ReferrerID, "MMN: Referrer index does not exist.");
        return (ReferrerCode[index], ReferrerAddr[index]);
    }
	
    //----------------↑↑↑---Referrer---↑↑↑-------------------------

    function MMNCreateERC721(
        uint8 tokenType,
        string memory name, 
        string memory symbol, 
        uint256 maxNftSupply, 
        uint256 saleStart, 
        uint256 saleEnd, 
        uint256 _MaxPurchase, 
		uint256 _ReferrerCode
	)
       external payable returns (bool)
    {
        require(IsMyMasterNFTActive(), "MMN must be active to deploy NFT contract.");
        address _Sender = msg.sender;
        require(MMNNFTAmonts[_Sender] < 20, "MMN: Create too many NFT contracts.");
        require(saleEnd >= saleStart, "MMN: Mint time rrror.");
		address _RAddr = address(this);
		uint256 totalCost = MMNPrice;
		
        if (tokenType == 0) {
            require(IsMMNPass(_Sender), "MMNPass: MMNPass error T0.");
        } else {
            require(MMNPrice <= msg.value, "MMN price is not correct");
			uint _sTotalRate = 0;
			if(isReferrerCode(_ReferrerCode)) {
				_sTotalRate += ReturnRate;
				_RAddr = getReferrer(_ReferrerCode);
			}
			if(IsMMNPFPOwner(_Sender)) {
				_sTotalRate += MMNPFPRate;
			}
			totalCost = MMNPrice * (100 - _sTotalRate) / 100;
        }

		uint _mintStart = saleStart;
		uint _mintEnd = saleEnd;
        if (saleStart == 0) {
            _mintStart = block.timestamp;
        }
		
        if (saleEnd == 0) {
            _mintEnd = block.timestamp + 3153600000;
        }

        address _NFTAddress = address(createMMNERC721(name, symbol, maxNftSupply, _mintStart, _mintEnd, MMNSupply, _MaxPurchase, msg.sender));
        emit NFTCreatorResult(_NFTAddress);

		MMNData[MMNSupply].NFTAddr = _NFTAddress;
		MMNData[MMNSupply].NFTOwner = _Sender;
		MMNData[MMNSupply].CreatTime = block.timestamp;
		MMNData[MMNSupply].MaxNftSupply = maxNftSupply;

        if (tokenType == 0) {
            MMNPass[_Sender] -= 1;
        }

		MMNSortID[_Sender][MMNNFTAmonts[_Sender]] = MMNSupply;
		MMNNFTAddr[_Sender][MMNNFTAmonts[_Sender]] = _NFTAddress;
		MMNNFTAmonts[_Sender] += 1;

		MMNSupply += 1;
		refundIfOver(totalCost);
		(bool success, ) = (_RAddr).call{value: (MMNPrice * ReferrerRate / 100)}("");
		require(success, "Transfer failed.");
        return true;
    }

    function createMMNERC721(
        string memory name, 
        string memory symbol, 
        uint256 maxNftSupply, 
        uint256 saleStart, 
        uint256 saleEnd, 
        uint256 _NFTID, 
        uint _MaxPurchase, 
        address _sOwnerAddr
	)
       private
       returns (MMNERC721 NFTAddress)
    {
        return new MMNERC721(name, symbol, maxNftSupply, saleStart, saleEnd, _NFTID, _MaxPurchase, _sOwnerAddr);
    }
}