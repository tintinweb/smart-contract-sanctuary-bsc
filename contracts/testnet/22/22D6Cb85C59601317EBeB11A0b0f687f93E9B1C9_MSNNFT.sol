// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./VRFCoordinatorV2Interface.sol";
import "./VRFConsumerBaseV2.sol";

interface BOXNFT {
   function name() external view returns (string memory);
   function symbol() external view returns (string memory);
   function totalSupply() external view returns (uint256);
   function balanceOf(address _owner) external view returns (uint balance);
   function ownerOf(uint256 _tokenId) external view returns (address owner);
   function approve(address _to, uint256 _tokenId) external ;
   function transfer(address _to, uint256 _tokenId) external ;
   function transferFrom(address _from,address _to, uint256 _tokenId) external ;
   function safeTransferFrom(address from, address to, uint256 tokenId) external;
   event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
   event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
}
interface ERC20 {
 function transfer(address _to, uint _value) external returns (bool success);
 function transferFrom(address _from, address _to, uint _value) external returns (bool success);
}
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
    constructor () {
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
        assembly { size := extcodesize(account) }
        return size > 0;
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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
library EnumerableSet {
    struct Set {
        bytes32[] _values;
        mapping (bytes32 => uint256) _indexes;
    }
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
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
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
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
    constructor (string memory name_, string memory symbol_) {
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
        return _tokenURI;
    }
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        return _holderTokens[owner].at(index);
    }
    function totalSupply() public view virtual override returns (uint256) {
        // _tokenOwners are indexed by tokenIds, so .length() returns the number of tokenIds
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
        //solhint-disable-next-line max-line-length
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
        // Clear approvals
        _approve(address(0), tokenId);
        // Clear metadata (if any)
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
        // Clear approvals from the previous owner
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
abstract contract Ownable is Context {
    address private _owner;
    mapping(address=>uint8) private managers;
    address[] private _owners;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        _owners.push(msgSender);
        managers[msgSender] = 1;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    modifier isManager{
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
}
abstract contract VRFv2Consumer is VRFConsumerBaseV2 {
}
contract MSNNFT is ERC721, Ownable,VRFv2Consumer {
    struct ShareRecord{
        uint256 now;
        address agent_address;
        uint256 number;
        string coin_name;
    }
    struct Rewards{
        uint256 now;
        uint256 amount;
    }
    struct nft_ability{
        uint256 pac;
        uint256 sho;
        uint256 pa;
        uint256 dr;
        uint256 def;
        uint256 phy;
    }
    struct nft{ 
        uint256 added;                  // new nft mark
        nft_ability ability;
        uint256 probability;
        uint256 synthesis;      // Synthesis Chance
        uint256 cooling_time;   // Synthesis Cooldown
        uint256 synthesis_consume_msp; // Msp Amount of synthesis consumed
        uint256 synthesis_consume_msg; // Msg Amount of synthesis consumed  
        uint256 sign_consume_msp; // Msp Amount of sign consumed
        uint256 sign_consume_msg; // Msg Amount of sign consumed
		string image_url;//nft info url
        string name;//nft name
    }
    struct nft_struct{
        uint256 level;
		uint256 kind;
        uint256 generation_time;
        uint256 create_time;
        uint256 sign_number;
    }
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    VRFCoordinatorV2Interface COORDINATOR;
    address[] public mapping_address;
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;
    address public jobaddress = 0x2dF854084D943b973eFe0e2B2C22c2E3Fd94105a;
    address public bscusdaddress = 0x1Ab1C70D67287B6EBBe4820c6BDADc341803a32C;
    address public Msg_contract = 0x557c86c9C9E003CD74AFf798f3F540DdC546Ab9B ;
    address public Msp_contract = 0x2FeF2D8aCe3836D88b2A32656922EEe842603d81;
    address public Bscusd_contract = 0x55d398326f99059fF775485246999027B3197955;
    address public vrfCoordinator = 0xc587d9053cd1118f25F645F9E08BB98c9712A4EE;
    bytes32 public keyHash = 0x17cd473250a9a479dc7f234c64332ed4bc8af9e8ded7556aa6e66d83da49f470;
    uint32 private callbackGasLimit = 2500000;
    uint16 private requestConfirmations = 3;
    uint32 private numWords =  2;
    uint64 public level_type_step = 100;
    uint256 private s_requestId;
    uint256[] public s_randomWords;
    uint64 public s_subscriptionId =  578;
    uint256 public pricePerMNFT = 10000 * 10 ** 6;
    uint256 public pricePerMNFT_bscusd= 100 * 10 ** 18;
    uint256 public maxMNFT = 1000;
    uint256 public sign_wait_time = 35 * 86400000;
    uint256 public latest_level = 0;
    uint256 public sign_msp_consume_add_step = 80000000;
    uint256 public agentRate = 10;
    uint256 public burnRate = 90;
    uint256 public signBurnRate = 90;
    uint256 public all_nft = 0;
    bool public isSaleActive = false;
    bool public isSaleActive_bscusd = false;
    bool public isOpenActive = false;
    bool public isSignActive = false;
    mapping (address => EnumerableSet.UintSet) private _boxTokens;
    mapping (address => EnumerableSet.UintSet) private _nftTokens;
    mapping (address=> address)public agent;
    mapping(address=>ShareRecord[]) public sharerecord;
    mapping(address=>Rewards[]) public rewards;   
    mapping(address => bool)private Minters;
    mapping(address => bool)private Signers;
    mapping(uint256 => bool) public is_open;
    mapping(uint256 => uint256) public token_value;
    mapping(uint256 => nft) public nfts;
    mapping(uint256 => nft_struct) public token_nft;
    mapping(uint256 => uint256) public level_type;
    constructor() VRFConsumerBaseV2(vrfCoordinator) ERC721("Meta Sports NFT", "MSN")
    {    
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    }
    function addMinters(address _address)external isManager{
        Minters[_address] = true;
    }
    function removeMinters(address _address)external isManager{
        Minters[_address] = false;
    }
    function addSigners(address _address)external isManager{
        Signers[_address] = true;
    }
    function removeSigners(address _address)external isManager{
        Signers[_address] = false;
    }
    function set_times(uint256 _tokenId,uint256 _generation_time,uint256 _create_time)external isManager{
            token_nft[_tokenId].generation_time = _generation_time;
            token_nft[_tokenId].create_time = _create_time;
    }
    function set_sign_number(uint256 _tokenId,uint256 sign_number)external isManager{
            token_nft[_tokenId].sign_number = sign_number;
    }
    function Mint(uint256 _level,uint256 _kind,address _address,uint256 is_nft,uint256 times,uint256 create_time,uint256 sign_number) public {
        require(Minters[msg.sender]);
        require(_level <= latest_level);
        uint256 _tokenId = totalSupply(); 
        if(is_nft == 1){
            is_open[_tokenId] = true;
            _nftTokens[_address].add(_tokenId);
            token_nft[_tokenId].generation_time = times;
            token_nft[_tokenId].create_time = create_time;
            token_nft[_tokenId].level = _level; 
            token_nft[_tokenId].kind = _kind;
            token_nft[_tokenId].sign_number = sign_number;
        }else{
            _boxTokens[_address].add(_tokenId);
        }
        _safeMint(_address,_tokenId); 
        if(is_nft == 1){
            _setTokenURI(_tokenId,nfts[_level * level_type_step + _kind].image_url);
        }
    }
    function setChlink(address _vrfCoordinator,bytes32 _keyHash) external isManager {
        vrfCoordinator = _vrfCoordinator;
        keyHash = _keyHash;
    }
    function set_subscriptionId(uint64 _id)external isManager{
        s_subscriptionId = _id;
    }
    function requestRandomWords() external isManager {
    // Will revert if subscription is not set and funded.
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }
    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        s_randomWords = randomWords;
    }
    function rand(address _to,uint256 tokenId) private view returns(uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp,_to,tokenId,block.number)));
        return random%1000;
    }
    function getAllNftToken(address owner) public view  returns (uint256[] memory) {
        uint256[] memory tokens = new uint256[](_nftTokens[owner].length());
        if(_nftTokens[owner].length() > 0){
            for(uint i=0;i<_nftTokens[owner].length();i++){
                tokens[i] = _nftTokens[owner].at(i);
            }
        }
        return tokens;
    }
    function getSignAmount(uint256 tokenid)public view returns(uint256,uint256){
        require(is_open[tokenid], "nft is not open");
        uint256 msp_consume;
        uint256 nft_index = token_nft[tokenid].level * level_type_step + token_nft[tokenid].kind;
        if(token_nft[tokenid].sign_number > 3)
            msp_consume = nfts[nft_index].sign_consume_msp + 3 * sign_msp_consume_add_step;
        else
            msp_consume = nfts[nft_index].sign_consume_msp + token_nft[tokenid].sign_number * sign_msp_consume_add_step;
        return (nfts[nft_index].sign_consume_msg,msp_consume);
    }
    function getAll_length(address _owner)public view returns(uint256,uint256){
        uint256 nft_length = _nftTokens[_owner].length();
        uint256 box_length = _boxTokens[_owner].length();
        return (box_length,nft_length);
    }
    function setSignRule(uint256 amount) public isManager{
        sign_msp_consume_add_step = amount;
    }
    function set_address(address _msg_address,address _msp_address) public isManager {
        require(_msg_address != address(0x0));
        require(_msp_address != address(0x0));
        Msg_contract = _msg_address;
        Msp_contract = _msp_address;
    }
    function set_bscusd_address(address _bscusd_address) public isManager{
        require(_bscusd_address != address(0x0));
        Bscusd_contract = _bscusd_address;
    }
    function open_nft_range(uint256 start_tokenId,uint256 end_tokenId)public isManager{
        require(end_tokenId - start_tokenId  >= 0);
        require(s_randomWords[0] != 0,"error");
        uint256 size = end_tokenId - start_tokenId + 1;
        uint256[] memory result = new uint256[](size); 
        result =  shuffle(size,s_randomWords[0]);
        uint j = 0;
        for(uint i = start_tokenId; i <= end_tokenId; i++){    
            token_value[i] = result[j++];
        }
    }
    function owner_transfer(uint256 start_tokenId,uint256 end_tokenId,address _to_address)public isManager{
        require(end_tokenId != 0 );
        for(uint i = start_tokenId; i <= end_tokenId; i++){
            ERC721.transferFrom(msg.sender,_to_address,i);
        }
    }
    function owner_open_nft(uint256 start_tokenId,uint256 end_tokenId)public isManager{
        for(uint i = start_tokenId;i<=end_tokenId;i++){
            CreateNft(i);
        }
    }
    function set_SaleActive(bool mstate,bool ustate) public isManager{
        isSaleActive = mstate;
        isSaleActive_bscusd = ustate;
    }
    function set_SignActive(bool state) public isManager{
        isSignActive = state;
    }
    function set_OpenActive(bool state) public isManager{
        isOpenActive = state;
    }
    function setMaxNft(uint256 _MaxNft) public isManager{
        maxMNFT = _MaxNft;
    }
    function setPrice(uint256 _price,uint256 _price_bscusd) public isManager{
        pricePerMNFT = _price;
        pricePerMNFT_bscusd =  _price_bscusd;
    }

    function setPayAdd(address _msg_job,address _bscusd_address) public isManager{
        jobaddress = _msg_job;
        bscusdaddress = _bscusd_address;
    }
    function setBurnAgentRate(uint256  burn_rate,uint256  agent_rate,uint256 sign_burn_rate) public isManager{
        require(burn_rate <= 100 && agent_rate <= 100 && sign_burn_rate <= 100);
        burnRate = burn_rate;
        agentRate = agent_rate;
        signBurnRate = sign_burn_rate;
    }
    function setSignWaitTime(uint256 time) public isManager{
        sign_wait_time =  time;
    }
    function setNftProbability(uint256 level,uint256 kind,uint256 probability) public isManager{
        uint256 index = level*level_type_step + kind;
        require(nfts[index].added == 1);
        nfts[index].probability = probability;
    }
    function setNftName(string memory name,uint256 level,uint256 kind) public isManager{
        uint256 index = level*level_type_step + kind;
        require(nfts[index].added == 1);
        nfts[index].name = name;
    }
    function setNftUrl(string memory url,uint256 level,uint256 kind) public isManager{
        uint256 index = level*level_type_step + kind;
        require(nfts[index].added == 1);
        nfts[index].image_url = url;
    }
    function setNftBasicAttribute(uint256 pac,uint256 sho,uint256 pa,uint256 dr,uint256 def,uint256 phy,uint256 _synthesis,uint256 _cooling_time,string memory _image_url,uint256 level,uint256 kind) public isManager{
        uint256 index = level*level_type_step + kind;
        require(nfts[index].added == 1);
        nfts[index].ability.pac = pac;
        nfts[index].ability.sho = sho;
        nfts[index].ability.pa = pa;     
        nfts[index].ability.dr = dr;
        nfts[index].ability.def = def;
        nfts[index].ability.phy = phy;
        nfts[index].synthesis = _synthesis;     
        nfts[index].cooling_time = _cooling_time;
        nfts[index].image_url = _image_url;
    }
    function SetNftConsumeAttribute(uint256 synthesis_consume_msp,uint256 synthesis_consume_msg,uint256 sign_consume_msp,uint256 sign_consume_msg,uint256 level,uint256 kind) public isManager{
        uint256 index = level*level_type_step + kind;
        require(nfts[index].added == 1);
        nfts[index].synthesis_consume_msp = synthesis_consume_msp;
        nfts[index].synthesis_consume_msg = synthesis_consume_msg;     
        nfts[index].sign_consume_msp = sign_consume_msp;
        nfts[index].sign_consume_msg = sign_consume_msg;
    }
    function AddNft(uint256 level,uint256 probability,string memory name,uint256 synthesis_consume_msp,uint256 synthesis_consume_msg,uint256 sign_consume_msp,uint256 sign_consume_msg) public isManager{
        if(level_type[0] == 0)
            require(level == 0,"level error");
        require(level <= latest_level+1,"level error");
        uint256 kind = level_type[level] + 1;
        uint256 index = level*level_type_step + kind;
        if(nfts[index].added == 0){     
          nfts[index].added = 1;  
          all_nft = all_nft+1;
          if(level >  latest_level)
            latest_level = level;
          level_type[level] = kind;
          nfts[index].probability = probability;
          nfts[index].name = name;
          nfts[index].synthesis_consume_msp = synthesis_consume_msp;
          nfts[index].synthesis_consume_msg = synthesis_consume_msg;     
          nfts[index].sign_consume_msp = sign_consume_msp;
          nfts[index].sign_consume_msg = sign_consume_msg;
        }
    }
    function CreateNft(uint256 _tokenId) internal {
        require(tx.origin == msg.sender);
        require(level_type[0] > 0);
        require(ERC721.ownerOf(_tokenId) == msg.sender || msg.sender == owner() ,"is not owner");
        require(!is_open[_tokenId]);   
        uint256 level = 0;
        uint256 kind = 1;
        (level,kind) = _randomProbability(_tokenId,level_type_step);
        token_nft[_tokenId].level = level;
        token_nft[_tokenId].kind = kind;
        token_nft[_tokenId].generation_time = block.timestamp;
        is_open[_tokenId] = true;     
        _setTokenURI(_tokenId,nfts[level*level_type_step+kind].image_url);
        _nftTokens[msg.sender].add(_tokenId);
        _boxTokens[msg.sender].remove(_tokenId);
        emit Transfer(msg.sender, msg.sender, _tokenId);  
    }
    function rand2(address _to,uint256 tokenId,uint256 _step) private view returns(uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp,_to,tokenId,block.number)));
        uint256 randomMax ;
        for(uint i=0;i<=latest_level;i++){
            for(uint j=1;j<=level_type[i];j++){
                uint _nfts_index=i*_step+j;
                if(randomMax<nfts[_nfts_index].probability){
                    randomMax = nfts[_nfts_index].probability;
                }
            }
        }
        return (random%randomMax)+1;
    }
    function _randomProbability(uint256  _tokenIds_m,uint256 _step)  private view returns(uint256 ,uint256){
        uint256 number;
        if(token_value[_tokenIds_m] == 0){
            number = rand2(msg.sender,_tokenIds_m,_step);
        }else{
            number = token_value[_tokenIds_m];
        }
        uint256 _levelReal = 0;
        uint256 _typeReal = 1;
        for(uint i=0;i<=latest_level;i++){
            for(uint j=1;j<=level_type[i];j++){
                uint _nfts_index=i*_step+j;
                if(number<=nfts[_nfts_index].probability){
                    _levelReal=i;
                    _typeReal=j;
                }
           }
        }
        return (_levelReal,_typeReal);
    }
    function openAll(uint256[] memory tokenIds) public {
        require(isOpenActive, "function is off");
        require(tokenIds.length > 0);
        require(tx.origin == msg.sender);
        require(level_type[0] > 0);
        for(uint m;m<tokenIds.length;m++){   
            require(!is_open[tokenIds[m]]);
            uint256 level = 0;
            uint256 kind = 1;
            (level,kind) = _randomProbability(tokenIds[m],level_type_step);
            if(ERC721.ownerOf(tokenIds[m]) == msg.sender ){
                _setTokenURI(tokenIds[m],nfts[level*level_type_step+kind].image_url);
                token_nft[tokenIds[m]].level = level;
                token_nft[tokenIds[m]].kind = kind;
                token_nft[tokenIds[m]].generation_time = block.timestamp;
                is_open[tokenIds[m]] = true;     
                _nftTokens[msg.sender].add(tokenIds[m]);
                _boxTokens[msg.sender].remove(tokenIds[m]);
                emit Transfer(msg.sender, msg.sender, tokenIds[m]);
            }
        }
    }
    function Sign(uint256 tokenid,uint256 time,uint256 sign_number) public {
        require(Signers[msg.sender]);
        token_nft[tokenid].sign_number = sign_number; 
        token_nft[tokenid].generation_time = time;
    }
    function check_member(address _address)public view returns(bool){
        if(mapping_address.length > 0){
            for(uint i;i<mapping_address.length;i++){
                if(mapping_address[i] == _address){
                    return false;
                }
            }
        }
        return true;
    }
    function getSharerecordNumber(address owner) public view  returns (uint256) {
        return sharerecord[owner].length;
    }
    function getCommissionAmount(address owner) public view  returns (uint256,uint256) {
        uint256 msg_amount = 0;
        uint256 usdt_amount = 0;
        for (uint256 i = 0; i < sharerecord[owner].length; i++) {
            if(keccak256(abi.encodePacked(sharerecord[owner][i].coin_name)) == keccak256(abi.encodePacked("MSG")))
                msg_amount += sharerecord[owner][i].number;
            else   
                usdt_amount += sharerecord[owner][i].number;
        }
        return (msg_amount,usdt_amount);
    }
    function getShareRecordPage(address owner,uint256 _limit, uint256 _pageNumber) public view  returns (ShareRecord[] memory) {
        uint256 pageEnd = _limit * (_pageNumber + 1);
        uint256 RecordSize = sharerecord[owner].length >= pageEnd ? _limit : sharerecord[owner].length.sub(_limit * _pageNumber);  
        ShareRecord[] memory record = new ShareRecord[](RecordSize);
        if(sharerecord[owner].length > 0){
            uint256 counter = 0;
            uint256 Iterator = 0;
            for (uint256 i = 0; i < sharerecord[owner].length && counter < pageEnd; i++) {
     
                if(counter >= pageEnd - _limit) {
                    record[Iterator] = sharerecord[owner][i];
                    Iterator++;
                }
                counter++; 
            }
        }
        return record;
    }
    function getBoxPageToken(address owner,uint256 _limit, uint256 _pageNumber) public view  returns (uint256[] memory) {
        uint256 pageEnd = _limit * (_pageNumber + 1);
        uint256 tokensSize = _boxTokens[owner].length() >= pageEnd ? _limit : _boxTokens[owner].length().sub(_limit * _pageNumber);  
        uint256[] memory tokens = new uint256[](tokensSize);
        if(_boxTokens[owner].length() > 0){
            uint256 counter = 0;
            uint256 tokenIterator = 0;
            for (uint256 i = 0; i < _boxTokens[owner].length() && counter < pageEnd; i++) {
                if(counter >= pageEnd - _limit) {
                    tokens[tokenIterator] = _boxTokens[owner].at(i);
                    tokenIterator++;
                }
                counter++; 
            }
        }
        return tokens;
    }
    function getNftPageToken(address owner,uint256 _limit, uint256 _pageNumber) public view  returns (uint256[] memory) {
        uint256 pageEnd = _limit * (_pageNumber + 1);
        uint256 tokensSize = _nftTokens[owner].length() >= pageEnd ? _limit : _nftTokens[owner].length().sub(_limit * _pageNumber);  
        uint256[] memory tokens = new uint256[](tokensSize);
        if(_nftTokens[owner].length() > 0){
            uint256 counter = 0;
            uint8 tokenIterator = 0;
            for (uint256 i = 0; i < _nftTokens[owner].length() && counter < pageEnd; i++) {
                if(counter >= pageEnd - _limit) {
                    tokens[tokenIterator] = _nftTokens[owner].at(i);
                    tokenIterator++;
                }
                counter++;
            }
        }
        return tokens;
    }
    function BuyBox(uint256 numberOfTokens,address agent_address,uint8 coin_type) public {
        if(coin_type == 1)
            require(isSaleActive, "Sale is not active");
        else
            require(isSaleActive_bscusd,"Sale is not active");
        require(totalSupply().add(numberOfTokens) <= maxMNFT, "Purchase would exceed max supply of KILLAz");
        uint256 price = numberOfTokens*pricePerMNFT;
        uint256 price_bscusd = numberOfTokens*pricePerMNFT_bscusd;
		if(coin_type == 1){
            if(price*burnRate != 0 )
                erc20tranFrom(Msg_contract,msg.sender,deadAddress,price*burnRate/100);
        }
        if(agent[msg.sender] == address(0x0) && agent_address != address(0x0) && agent_address != msg.sender){
            agent[msg.sender] = agent_address;
        }
        agent_address = agent[msg.sender];
        if(agent_address != address(0x0)){
            if(coin_type == 1){
                if(price*agentRate != 0 ){
                    erc20tranFrom(Msg_contract,msg.sender,agent_address,price*agentRate/100);
                    sharerecord[agent_address].push(ShareRecord(block.timestamp,msg.sender,price*agentRate/100,"MSG"));
                }
                if(price*(100-burnRate-agentRate) !=  0)
                    erc20tranFrom(Msg_contract,msg.sender,jobaddress,price*(100-burnRate-agentRate)/100);
            }
            else{
                if(price_bscusd*agentRate != 0){
                    erc20tranFrom(Bscusd_contract,msg.sender,agent_address,price_bscusd*agentRate/100);
                    sharerecord[agent_address].push(ShareRecord(block.timestamp,msg.sender,price_bscusd*agentRate/100,"USDT"));
                }
                if(price_bscusd*(100-agentRate) != 0)
                    erc20tranFrom(Bscusd_contract,msg.sender,bscusdaddress,price_bscusd*(100-agentRate)/100);
            }
        }
        else{
            if(coin_type == 1){
                if(price*(100-burnRate) != 0)
                    erc20tranFrom(Msg_contract,msg.sender,jobaddress,price*(100-burnRate)/100);
            }
            else{
                if(price_bscusd != 0)
                    erc20tranFrom(Bscusd_contract,msg.sender,bscusdaddress,price_bscusd);
            }
        }
        if(check_member(msg.sender)){
            mapping_address.push(msg.sender);
        }
        for (uint256 i = 0; i < numberOfTokens; i++) {
            uint256 mintIndex = totalSupply();
            if (totalSupply() < maxMNFT) {
                _boxTokens[msg.sender].add(mintIndex);
                _safeMint(msg.sender, mintIndex);
            }
        }
    }
    function Admin_BuyBox(uint256 numberOfTokens) public isManager{
        require(totalSupply().add(numberOfTokens) <= maxMNFT, "Purchase would exceed max supply of KILLAz");
        if(check_member(msg.sender)){
            mapping_address.push(msg.sender);
        }
        for (uint256 i = 0; i < numberOfTokens; i++) {
            uint256 mintIndex = totalSupply();
            if (totalSupply() < maxMNFT) {
                _boxTokens[msg.sender].add(mintIndex);
                _safeMint(msg.sender, mintIndex);
            }
        }
    }
    function claimTokenRewards(uint256 amount) public {
        rewards[msg.sender].push(Rewards(block.timestamp,amount));
    }
    function msgtranFrom(address _addr1,address _addr2,uint256 _amount)  internal virtual{
        ERC20(Msg_contract).transferFrom(_addr1,_addr2,_amount);
    }
    function erc20tranFrom(address contract_addr,address _addr1,address _addr2,uint256 _amount)  internal virtual{
        ERC20(contract_addr).transferFrom(_addr1,_addr2,_amount);
    }
   function shuffle(uint256 size, uint256 entropy) public pure returns (uint256[] memory) {
        uint256[] memory result = new uint[](size); 
        // Initialize array.
        for (uint256 i = 0; i < size; i++) {
           result[i] = i + 1;
        }
        // Set the initial randomness based on the provided entropy.
        bytes32 random = keccak256(abi.encodePacked(entropy));
        // Set the last item of the array which will be swapped.
        uint256 last_item = size - 1;
        // We need to do `size - 1` iterations to completely shuffle the array.
        for (uint256 i = 1; i < size - 1; i++) {
            // Select a number based on the randomness.
            uint256 selected_item = uint256(random) % last_item;
            // Swap items `selected_item <> last_item`.
            uint256 aux = result[last_item];
            result[last_item] = result[selected_item];
            result[selected_item] = aux%1000;
            // Decrease the size of the possible shuffle
            // to preserve the already shuffled items.
            // The already shuffled items are at the end of the array.
            last_item--;
            // Generate new randomness.
            random = keccak256(abi.encodePacked(random));
        }
        return result;
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        if(is_open[tokenId]){
            _nftTokens[to].add(tokenId);
            _nftTokens[from].remove(tokenId);
        }else{
            _boxTokens[to].add(tokenId);
            _boxTokens[from].remove(tokenId);
        }
    }
}