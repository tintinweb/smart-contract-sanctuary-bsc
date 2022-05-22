/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
interface IBEP721 is IERC165 {
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
interface IBEP721Metadata is IBEP721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
interface IBEP721Enumerable is IBEP721 {
    function totalSupply() external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
    function tokenByIndex(uint256 index) external view returns (uint256);
}
interface IBEP721Receiver {
    function onBEP721Received(address operator, address from, uint256 tokenId, bytes calldata data)
    external returns (bytes4);
}
contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;
    mapping(bytes4 => bool) private _supportedInterfaces;
    constructor (){
        _registerInterface(_INTERFACE_ID_ERC165);
    }
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor (){
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
library Math {
    using SafeMath for uint256;
    function getPartial(uint256 target,uint256 numerator,uint256 denominator) internal pure returns (uint256) {
        return target.mul(numerator).div(denominator);
    }
    function getPartialRoundUp(uint256 target,uint256 numerator,uint256 denominator) internal pure returns (uint256) {
        if (target == 0 || numerator == 0) {
            // SafeMath will check for zero denominator
            return SafeMath.div(0, denominator);
        }
        return target.mul(numerator).sub(1).div(denominator).add(1);
    }
    function to128(uint256 number) internal pure returns (uint128) {
        uint128 result = uint128(number);
        require(result == number, "Math: Unsafe cast to uint128");
        return result;
    }
    function to96(uint256 number) internal pure returns (uint96) {
        uint96 result = uint96(number);
        require(result == number, "Math: Unsafe cast to uint96");
        return result;
    }
    function to32(uint256 number) internal pure returns (uint32) {
        uint32 result = uint32(number);
        require(result == number, "Math: Unsafe cast to uint32");
        return result;
    }
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}
contract BaseBEP20 is IBEP20, Ownable {
    using SafeMath for uint256;
    string internal _name;
    string internal _symbol;
    uint256 internal _supply;
    uint8 internal _decimals;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    constructor(string memory name_,string memory symbol_,uint8 decimals_){
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }
    function totalSupply() public view override returns (uint256) {
        return _supply;
    }
    function balanceOf(address who) public view override returns (uint256) {
        return _balances[who];
    }
    function allowance(address owner, address spender) public view override returns (uint256){
        return _allowances[owner][spender];
    }
    function _mint(address to, uint256 value) internal {
        require(to != address(0), "Cannot mint to zero address");
        _balances[to] = _balances[to].add(value);
        _supply = _supply.add(value);
        emit Transfer(address(0), to, value);
    }
    function _burn(address from, uint256 value) internal {
        require(from != address(0), "Cannot burn to zero");
        _balances[from] = _balances[from].sub(value);
        _supply = _supply.sub(value);
        emit Transfer(from, address(0), value);
    }
    function transfer(address to, uint256 value)public virtual override returns (bool){
        if (_balances[msg.sender] >= value) {
            _balances[msg.sender] = _balances[msg.sender].sub(value);
            _balances[to] = _balances[to].add(value);
            emit Transfer(msg.sender, to, value);
            return true;
        } else {
            return false;
        }
    }
    function transferFrom(address from, address to, uint256 value) public virtual override returns (bool) {
        if (_balances[from] >= value && _allowances[from][msg.sender] >= value) {
            _balances[to] = _balances[to].add(value);
            _balances[from] = _balances[from].sub(value);
            _allowances[from][msg.sender] = _allowances[from][msg.sender].sub(value);
            emit Transfer(from, to, value);
            return true;
        } else {
            return false;
        }
    }
    function approve(address spender, uint256 value)public override returns (bool){
        return _approve(msg.sender, spender, value);
    }
    function _approve(address owner,address spender,uint256 value) internal returns (bool) {
        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
        return true;
    }
    function mint(address to, uint256 value) public onlyOwner {
        _mint(to, value);
    }
}
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
contract BEP721 is Context,ERC165,IBEP721,IBEP721Metadata,IBEP721Enumerable{
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for uint256;
    // Equals to `bytes4(keccak256("onBEP721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IBEP721Receiver(0).onBEP721Received.selector`
    bytes4 private constant _BEP721_RECEIVED = 0x150b7a02;
    // Mapping from holder address to their (enumerable) set of owned tokens
    mapping(address => EnumerableSet.UintSet) private _holderTokens;
    // Enumerable mapping from token ids to their owners
    EnumerableMap.UintToAddressMap private _tokenOwners;
    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;
    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    // Token name
    string private _name;
    // Token symbol
    string private _symbol;
    // Optional mapping for token URIs
    mapping(uint256 => string) internal _tokenURIs;
    // Base URI
    string internal _baseURI;
    bytes4 private constant _INTERFACE_ID_BEP721 = 0x80ac58cd;
    bytes4 private constant _INTERFACE_ID_BEP721_ENUMERABLE = 0x780e9d63;
    constructor(string memory name_, string memory symbol_){
        _name = name_;
        _symbol = symbol_;
        // register the supported interfaces to conform to BEP721 via ERC165
        _registerInterface(_INTERFACE_ID_BEP721);
        _registerInterface(_INTERFACE_ID_BEP721_ENUMERABLE);
    }
    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0),"BEP721: balance query for the zero address");
        return _holderTokens[owner].length();
    }
    function ownerOf(uint256 tokenId) public view override returns (address) {
        return _tokenOwners.get(tokenId,"BEP721: owner query for nonexistent token");
    }
    function name() public view override returns (string memory) {
        return _name;
    }
    function symbol() public view override returns (string memory) {
        return _symbol;
    }
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory){
        require(_exists(tokenId),"BEP721Metadata: URI query for nonexistent token");
        string memory _tokenURI = _tokenURIs[tokenId];
        // If there is no base URI, return the token URI.
        if (bytes(_baseURI).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(_baseURI, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return string(abi.encodePacked(_baseURI, tokenId.toString()));
    }
    function baseURI() public view returns (string memory) {
        return _baseURI;
    }
    function tokenOfOwnerByIndex(address owner, uint256 index)public view override returns (uint256){
        return _holderTokens[owner].at(index);
    }
    function totalSupply() public view override returns (uint256) {
        // _tokenOwners are indexed by tokenIds, so .length() returns the number of tokenIds
        return _tokenOwners.length();
    }
    function tokenByIndex(uint256 index)public view override returns (uint256){
        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId);
        require(to != owner, "BEP721: approval to current owner");
        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),"BEP721: approve caller is not owner nor approved for all");
        _approve(to, tokenId);
    }
    function getApproved(uint256 tokenId) public view override returns (address){
        require(_exists(tokenId),"BEP721: approved query for nonexistent token");
        return _tokenApprovals[tokenId];
    }
    function setApprovalForAll(address operator, bool approved) public virtual override{
        require(operator != _msgSender(), "BEP721: approve to caller");
        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }
    function isApprovedForAll(address owner, address operator) public view override returns (bool){
        return _operatorApprovals[owner][operator];
    }
    function transferFrom(address from,address to,uint256 tokenId) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId),"BEP721: transfer caller is not owner nor approved");
        _transfer(from, to, tokenId);
    }
    function safeTransferFrom(address from,address to,uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }
    function safeTransferFrom(address from,address to,uint256 tokenId,bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId),"BEP721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }
    function _safeTransfer(address from,address to,uint256 tokenId,bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnBEP721Received(from, to, tokenId, _data),"BEP721: transfer to non BEP721Receiver implementer");
    }
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _tokenOwners.contains(tokenId);
    }
    function _isApprovedOrOwner(address spender, uint256 tokenId)internal view returns (bool){
        require(_exists(tokenId),"BEP721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender));
    }
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }
    function _safeMint(address to,uint256 tokenId, bytes memory _data) internal virtual {
        _mint(to, tokenId);
        require(_checkOnBEP721Received(address(0), to, tokenId, _data),"BEP721: transfer to non BEP721Receiver implementer");
    }
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "BEP721: mint to the zero address");
        require(!_exists(tokenId), "BEP721: token already minted");
        _beforeTokenTransfer(address(0), to, tokenId);
        _holderTokens[to].add(tokenId);
        _tokenOwners.set(tokenId, to);
        emit Transfer(address(0), to, tokenId);
    }
    function _burn(uint256 tokenId) internal virtual {
        address owner = ownerOf(tokenId);
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
    function _transfer(address from,address to,uint256 tokenId) internal virtual {
        require(ownerOf(tokenId) == from,"BEP721: transfer of token that is not own");
        require(to != address(0), "BEP721: transfer to the zero address");
        _beforeTokenTransfer(from, to, tokenId);
        // Clear approvals from the previous owner
        _approve(address(0), tokenId);
        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);
        _tokenOwners.set(tokenId, to);
        emit Transfer(from, to, tokenId);
    }
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual{
        require(_exists(tokenId),"BEP721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }
    function _setBaseURI(string memory baseURI_) internal virtual {
        _baseURI = baseURI_;
    }
    function _checkOnBEP721Received(address from,address to,uint256 tokenId,bytes memory _data) private returns (bool) {
        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata =to.functionCall(abi.encodeWithSelector(IBEP721Receiver(to).onBEP721Received.selector,_msgSender(),from,tokenId,
            _data),"BEP721: transfer to non BEP721Receiver implementer");
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _BEP721_RECEIVED);
    }
    function _approve(address to, uint256 tokenId) internal {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }
    function _beforeTokenTransfer(address from,address to,uint256 tokenId) internal virtual {}
}
abstract contract BEP721Burnable is Context, BEP721 {
    function burn(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId),"BEP721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }
}
library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }
    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                // solhint-disable-next-line no-inline-assembly
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
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
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
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];
        if (valueIndex != 0) { 
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;
            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.
            bytes32 lastvalue = set._values[lastIndex];
            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based
            // Delete the slot where the moved value was stored
            set._values.pop();
            // Delete the index for the deleted slot
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
        // Storage of map keys and values
        MapEntry[] _entries;
        // Position of the entry defined by a key in the `entries` array, plus 1
        // because index 0 means a key is not in the map.
        mapping (bytes32 => uint256) _indexes;
    }
    function _set(Map storage map, bytes32 key, bytes32 value) private returns (bool) {
        // We read and store the key's index to prevent multiple reads from the same storage slot
        uint256 keyIndex = map._indexes[key];
        if (keyIndex == 0) { // Equivalent to !contains(map, key)
            map._entries.push(MapEntry({ _key: key, _value: value }));
            // The entry is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            map._indexes[key] = map._entries.length;
            return true;
        } else {
            map._entries[keyIndex - 1]._value = value;
            return false;
        }
    }
    function _remove(Map storage map, bytes32 key) private returns (bool) {
        // We read and store the key's index to prevent multiple reads from the same storage slot
        uint256 keyIndex = map._indexes[key];
        if (keyIndex != 0) { // Equivalent to contains(map, key)
            uint256 toDeleteIndex = keyIndex - 1;
            uint256 lastIndex = map._entries.length - 1;
            // When the entry to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.
            MapEntry storage lastEntry = map._entries[lastIndex];
            // Move the last entry to the index where the entry to delete is
            map._entries[toDeleteIndex] = lastEntry;
            // Update the index for the moved entry
            map._indexes[lastEntry._key] = toDeleteIndex + 1; // All indexes are 1-based
            // Delete the slot where the moved entry was stored
            map._entries.pop();
            // Delete the index for the deleted slot
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
    function _get(Map storage map, bytes32 key) private view returns (bytes32) {
        return _get(map, key, "EnumerableMap: nonexistent key");
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
    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {
        return address(uint160(uint256(_get(map._inner, bytes32(key)))));
    }
    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {
        return address(uint160(uint256(_get(map._inner, bytes32(key), errorMessage))));
    }
}
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;
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
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}
interface IMedia {
    struct EIP712Signature {
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }
    struct MediaData {
        // A valid URI of the content represented by this token
        string tokenURI;
        // A valid URI of the metadata associated with this token
        string metadataURI;
        // A SHA256 hash of the content pointed to by tokenURI
        bytes32 contentHash;
        // A SHA256 hash of the content pointed to by metadataURI
        bytes32 metadataHash;
    }
    event TokenURIUpdated(uint256 indexed _tokenId, address owner, string _uri);
    event TokenMetadataURIUpdated(uint256 indexed _tokenId,address owner,string _uri);
    function tokenMetadataURI(uint256 tokenId)external view returns (string memory);
    function mint(MediaData calldata data, IMarket.BidShares calldata bidShares)external;
    function mintWithSig(address creator,MediaData calldata data,IMarket.BidShares calldata bidShares,EIP712Signature calldata sig) external;
    function auctionTransfer(uint256 tokenId, address recipient) external;
    function setAsk(uint256 tokenId, IMarket.Ask calldata ask) external;
    function removeAsk(uint256 tokenId) external;
    function setBid(uint256 tokenId, IMarket.Bid calldata bid) external;
    function removeBid(uint256 tokenId) external;
    function acceptBid(uint256 tokenId, IMarket.Bid calldata bid) external;
    function revokeApproval(uint256 tokenId) external;
    function updateTokenURI(uint256 tokenId, string calldata tokenURI) external;
    function updateTokenMetadataURI(uint256 tokenId,string calldata metadataURI) external;
    function permit(address spender, uint256 tokenId, EIP712Signature calldata sig) external;
}
contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor (){
        _status = _NOT_ENTERED;
    }
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
contract Media is IMedia, BEP721Burnable, ReentrancyGuard {
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    // Address for the market
    address public marketContract;
    // Mapping from token to previous owner of the token
    mapping(uint256 => address) public previousTokenOwners;
    // Mapping from token id to creator address
    mapping(uint256 => address) public tokenCreators;
    // Mapping from creator address to their (enumerable) set of created tokens
    mapping(address => EnumerableSet.UintSet) private _creatorTokens;
    // Mapping from token id to sha256 hash of content
    mapping(uint256 => bytes32) public tokenContentHashes;
    // Mapping from token id to sha256 hash of metadata
    mapping(uint256 => bytes32) public tokenMetadataHashes;
    // Mapping from token id to metadataURI
    mapping(uint256 => string) private _tokenMetadataURIs;
    // Mapping from contentHash to bool
    mapping(bytes32 => bool) private _contentHashes;
    //keccak256("Permit(address spender,uint256 tokenId,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH = 0x49ecf333e5b8c95c40fdafc95c1ad136e8914a8fb55e9dc8bb01eaa83a2df9ad;
    //keccak256("MintWithSig(bytes32 contentHash,bytes32 metadataHash,uint256 creatorShare,uint256 nonce,uint256 deadline)");
    bytes32 public constant MINT_WITH_SIG_TYPEHASH = 0x2952e482b8e2b192305f87374d7af45dc2eafafe4f50d26a0c02e90f2fdbe14b;
    // Mapping from address to token id to permit nonce
    mapping(address => mapping(uint256 => uint256)) public permitNonces;
    // Mapping from address to mint with sig nonce
    mapping(address => uint256) public mintWithSigNonces;
    bytes4 private constant _INTERFACE_ID_BEP721_METADATA = 0x4e222e66;
    Counters.Counter private _tokenIdTracker;
    modifier onlyExistingToken(uint256 tokenId) {
        require(_exists(tokenId), "Media: nonexistent token");
        _;
    }
    modifier onlyTokenWithContentHash(uint256 tokenId) {
        require(tokenContentHashes[tokenId] != 0,"Media: token does not have hash of created content");
        _;
    }
    modifier onlyTokenWithMetadataHash(uint256 tokenId) {
        require(tokenMetadataHashes[tokenId] != 0, "Media: token does not have hash of its metadata");
        _;
    }
    modifier onlyApprovedOrOwner(address spender, uint256 tokenId) {
        require(_isApprovedOrOwner(spender, tokenId), "Media: Only approved or owner");
        _;
    }
    modifier onlyTokenCreated(uint256 tokenId) {
        require( _tokenIdTracker.current() > tokenId,"Media: token with that id does not exist");
        _;
    }
    modifier onlyValidURI(string memory uri) {
        require(bytes(uri).length != 0,"Media: specified uri must be non-empty");
        _;
    }
    constructor(address marketContractAddr)BEP721("SSS", "SSS") {
        marketContract = marketContractAddr;
        _registerInterface(_INTERFACE_ID_BEP721_METADATA);
    }
    function tokenURI(uint256 tokenId)public view override onlyTokenCreated(tokenId) returns (string memory){
        string memory _tokenURI = _tokenURIs[tokenId];
        return _tokenURI;
    }
    function tokenMetadataURI(uint256 tokenId)external view override onlyTokenCreated(tokenId) returns (string memory){
        return _tokenMetadataURIs[tokenId];
    }
    function mint(MediaData memory data, IMarket.BidShares memory bidShares)public override nonReentrant{
        _mintForCreator(msg.sender, data, bidShares);
    }
    function mintWithSig(address creator,MediaData memory data,IMarket.BidShares memory bidShares,EIP712Signature memory sig) public override nonReentrant {
        require(sig.deadline == 0 || sig.deadline >= block.timestamp,"Media: mintWithSig expired");
        bytes32 domainSeparator = _calculateDomainSeparator();
        bytes32 digest =keccak256(abi.encodePacked("\x19\x01",domainSeparator,keccak256(abi.encode(MINT_WITH_SIG_TYPEHASH,data.contentHash,data.metadataHash,
            bidShares.creator.value,mintWithSigNonces[creator]++,sig.deadline))));
        address recoveredAddress = ecrecover(digest, sig.v, sig.r, sig.s);
        require(recoveredAddress != address(0) && creator == recoveredAddress,"Media: Signature invalid");
        _mintForCreator(recoveredAddress, data, bidShares);
    }
    function auctionTransfer(uint256 tokenId, address recipient)external override{
        require(msg.sender == marketContract, "Media: only market contract");
        previousTokenOwners[tokenId] = ownerOf(tokenId);
        _safeTransfer(ownerOf(tokenId), recipient, tokenId, "");
    }
    function setAsk(uint256 tokenId, IMarket.Ask memory ask)public override nonReentrant onlyApprovedOrOwner(msg.sender, tokenId){
        IMarket(marketContract).setAsk(tokenId, ask);
    }
    function removeAsk(uint256 tokenId)external override nonReentrant onlyApprovedOrOwner(msg.sender, tokenId){
        IMarket(marketContract).removeAsk(tokenId);
    }
    function setBid(uint256 tokenId, IMarket.Bid memory bid)public override nonReentrant onlyExistingToken(tokenId){
        require(msg.sender == bid.bidder, "Market: Bidder must be msg sender");
        IMarket(marketContract).setBid(tokenId, bid, msg.sender);
    }
    function removeBid(uint256 tokenId)external override nonReentrant onlyTokenCreated(tokenId){
        IMarket(marketContract).removeBid(tokenId, msg.sender);
    }
    function acceptBid(uint256 tokenId, IMarket.Bid memory bid)public override nonReentrant onlyApprovedOrOwner(msg.sender, tokenId){
        IMarket(marketContract).acceptBid(tokenId, bid);
    }
    function burn(uint256 tokenId)public override nonReentrant onlyExistingToken(tokenId) onlyApprovedOrOwner(msg.sender, tokenId){
        address owner = ownerOf(tokenId);
        require(tokenCreators[tokenId] == owner,"Media: owner is not creator of media");
        _burn(tokenId);
    }
    function revokeApproval(uint256 tokenId) external override nonReentrant {
        require(msg.sender == getApproved(tokenId),"Media: caller not approved address");
        _approve(address(0), tokenId);
    }
    function updateTokenURI(uint256 tokenId, string calldata tokenURI)external override nonReentrant onlyApprovedOrOwner(msg.sender, tokenId) onlyTokenWithContentHash(tokenId) onlyValidURI(tokenURI){
        _setTokenURI(tokenId, tokenURI);
        emit TokenURIUpdated(tokenId, msg.sender, tokenURI);
    }
    function updateTokenMetadataURI(uint256 tokenId,string calldata metadataURI) external override nonReentrant onlyApprovedOrOwner(msg.sender, tokenId) 
        onlyTokenWithMetadataHash(tokenId) onlyValidURI(metadataURI){
        _setTokenMetadataURI(tokenId, metadataURI);
        emit TokenMetadataURIUpdated(tokenId, msg.sender, metadataURI);
    }
    function permit(address spender,uint256 tokenId,EIP712Signature memory sig) public override nonReentrant onlyExistingToken(tokenId) {
        require(sig.deadline == 0 || sig.deadline >= block.timestamp,"Media: Permit expired");
        require(spender != address(0), "Media: spender cannot be 0x0");
        bytes32 domainSeparator = _calculateDomainSeparator();
        bytes32 digest =keccak256(abi.encodePacked("\x19\x01",domainSeparator,keccak256(abi.encode(PERMIT_TYPEHASH,spender,tokenId,permitNonces[ownerOf(tokenId)][tokenId]++,sig.deadline))));
        address recoveredAddress = ecrecover(digest, sig.v, sig.r, sig.s);
        require(recoveredAddress != address(0) && ownerOf(tokenId) == recoveredAddress,"Media: Signature invalid");
        _approve(spender, tokenId);
    }    
    function _mintForCreator(address creator,MediaData memory data,IMarket.BidShares memory bidShares) internal onlyValidURI(data.tokenURI) onlyValidURI(data.metadataURI) {
        require(data.contentHash != 0, "Media: content hash must be non-zero");
        require(_contentHashes[data.contentHash] == false,"Media: a token has already been created with this content hash");
        require(data.metadataHash != 0,"Media: metadata hash must be non-zero");
        uint256 tokenId = _tokenIdTracker.current();
        _safeMint(creator, tokenId);
        _tokenIdTracker.increment();
        _setTokenContentHash(tokenId, data.contentHash);
        _setTokenMetadataHash(tokenId, data.metadataHash);
        _setTokenMetadataURI(tokenId, data.metadataURI);
        _setTokenURI(tokenId, data.tokenURI);
      //  _creatorTokens[creator].add(tokenId);
        _contentHashes[data.contentHash] = true;
        tokenCreators[tokenId] = creator;
        previousTokenOwners[tokenId] = creator;
        IMarket(marketContract).setBidShares(tokenId, bidShares);
    }
    function _setTokenContentHash(uint256 tokenId, bytes32 contentHash)internal virtual onlyExistingToken(tokenId){
        tokenContentHashes[tokenId] = contentHash;
    }
    function _setTokenMetadataHash(uint256 tokenId, bytes32 metadataHash)internal virtual onlyExistingToken(tokenId){
        tokenMetadataHashes[tokenId] = metadataHash;
    }

    function _setTokenMetadataURI(uint256 tokenId, string memory metadataURI)internal virtual onlyExistingToken(tokenId){
        _tokenMetadataURIs[tokenId] = metadataURI;
    }
    function _burn(uint256 tokenId) internal override {
        string memory tokenURI = _tokenURIs[tokenId];
        super._burn(tokenId);
        if (bytes(tokenURI).length != 0) {
            _tokenURIs[tokenId] = tokenURI;
        }
        delete previousTokenOwners[tokenId];
    }
    function _transfer(address from,address to,uint256 tokenId) internal override {
        IMarket(marketContract).removeAsk(tokenId);
        super._transfer(from, to, tokenId);
    }
    function _calculateDomainSeparator() internal view returns (bytes32) {
        uint256 chainID;
        /* solium-disable-next-line */
        assembly {
            chainID := chainid()
        }
        return
            keccak256(abi.encode(keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes("SSS")),keccak256(bytes("1")),chainID,address(this)));
    }
}
library Counters {
    using SafeMath for uint256;
    struct Counter {
        uint256 _value; // default: 0
    }
    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }
    function increment(Counter storage counter) internal {
        // The {SafeMath} overflow check can be skipped here, see the comment at the top
        counter._value += 1;
    }
    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}
library Decimal {
    using SafeMath for uint256;
    uint256 constant BASE_POW = 18;
    uint256 constant BASE = 10**BASE_POW;
    struct D256 {
        uint256 value;
    }
    function one() internal pure returns (D256 memory) {
        return D256({value: BASE});
    }
    function onePlus(D256 memory d) internal pure returns (D256 memory) {
        return D256({value: d.value.add(BASE)});
    }
    function mul(uint256 target, D256 memory d)internal pure returns (uint256){
        return Math.getPartial(target, d.value, BASE);
    }
    function div(uint256 target, D256 memory d)internal pure returns (uint256){
        return Math.getPartial(target, BASE, d.value);
    }
}
interface IMarket {
    struct Bid {
        // Amount of the currency being bid
        uint256 amount;
        // Address to the BEP20 token being used to bid
        address currency;
        // Address of the bidder
        address bidder;
        // Address of the recipient
        address recipient;
        // % of the next sale to award the current owner
        Decimal.D256 sellOnShare;
    }
    struct Ask {
        // Amount of the currency being asked
        uint256 amount;
        // Address to the BEP20 token being asked
        address currency;
    }
    struct BidShares {
        // % of sale value that goes to the _previous_ owner of the nft
        Decimal.D256 prevOwner;
        // % of sale value that goes to the original creator of the nft
        Decimal.D256 creator;
        // % of sale value that goes to the seller (current owner) of the nft
        Decimal.D256 owner;
    }
    event BidCreated(uint256 indexed tokenId, Bid bid);
    event BidRemoved(uint256 indexed tokenId, Bid bid);
    event BidFinalized(uint256 indexed tokenId, Bid bid);
    event AskCreated(uint256 indexed tokenId, Ask ask);
    event AskRemoved(uint256 indexed tokenId, Ask ask);
    event BidShareUpdated(uint256 indexed tokenId, BidShares bidShares);
    function bidForTokenBidder(uint256 tokenId, address bidder) external view returns (Bid memory);
    function currentAskForToken(uint256 tokenId)external view returns (Ask memory);
    function bidSharesForToken(uint256 tokenId)external view returns (BidShares memory);
    function isValidBid(uint256 tokenId, uint256 bidAmount)external view  returns (bool);
    function isValidBidShares(BidShares calldata bidShares)external pure returns (bool);
    function splitShare(Decimal.D256 calldata sharePercentage, uint256 amount)external pure returns (uint256);
    function configure(address mediaContractAddress) external;
    function setBidShares(uint256 tokenId, BidShares calldata bidShares)external;
    function setAsk(uint256 tokenId, Ask calldata ask) external;
    function removeAsk(uint256 tokenId) external;
    function setBid(uint256 tokenId,Bid calldata bid,address spender) external;
    function removeBid(uint256 tokenId, address bidder) external;
    function acceptBid(uint256 tokenId, Bid calldata expectedBid) external;
}
contract Market is IMarket {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;
    // Address of the media contract that can call this market
    address public mediaContract;
    // Deployment Address
    address private _owner;
    // Mapping from token to mapping from bidder to bid
    mapping(uint256 => mapping(address => Bid)) private _tokenBidders;
    // Mapping from token to the bid shares for the token
    mapping(uint256 => BidShares) private _bidShares;
    // Mapping from token to the current ask for the token
    mapping(uint256 => Ask) private _tokenAsks;
    modifier onlyMediaCaller() {
        require(mediaContract == msg.sender, "Market: Only media contract");
        _;
    }
    function bidForTokenBidder(uint256 tokenId, address bidder)external view override returns (Bid memory){
        return _tokenBidders[tokenId][bidder];
    }
    function currentAskForToken(uint256 tokenId)external view override returns (Ask memory){
        return _tokenAsks[tokenId];
    }
    function bidSharesForToken(uint256 tokenId)public view override returns (BidShares memory){
        return _bidShares[tokenId];
    }
    function isValidBid(uint256 tokenId, uint256 bidAmount)public view override returns (bool){
        BidShares memory bidShares = bidSharesForToken(tokenId);
        require(isValidBidShares(bidShares), "Market: Invalid bid shares for token");
        return  bidAmount != 0 && (bidAmount == splitShare(bidShares.creator, bidAmount).add(splitShare(bidShares.prevOwner, bidAmount))
                    .add(splitShare(bidShares.owner, bidAmount)));
    }
    function isValidBidShares(BidShares memory bidShares) public pure override returns (bool){
        return bidShares.creator.value.add(bidShares.owner.value).add(bidShares.prevOwner.value) == uint256(100).mul(Decimal.BASE);
    }
    function splitShare(Decimal.D256 memory sharePercentage, uint256 amount) public pure override returns (uint256){
        return Decimal.mul(amount, sharePercentage).div(100);
    }
    constructor() public {
        _owner = msg.sender;
    }
    function configure(address mediaContractAddress) external override {
        require(msg.sender == _owner, "Market: Only owner");
        require(mediaContract == address(0), "Market: Already configured");
        require(mediaContractAddress != address(0),"Market: cannot set media contract as zero address");
        mediaContract = mediaContractAddress;
    }
    function setBidShares(uint256 tokenId, BidShares memory bidShares)public override onlyMediaCaller{
        require(isValidBidShares(bidShares), "Market: Invalid bid shares, must sum to 100");
        _bidShares[tokenId] = bidShares;
        emit BidShareUpdated(tokenId, bidShares);
    }
    function setAsk(uint256 tokenId, Ask memory ask) public override onlyMediaCaller{
        require(isValidBid(tokenId, ask.amount), "Market: Ask invalid for share splitting");
        _tokenAsks[tokenId] = ask;
        emit AskCreated(tokenId, ask);
    }
    function removeAsk(uint256 tokenId) external override onlyMediaCaller {
        emit AskRemoved(tokenId, _tokenAsks[tokenId]);
        delete _tokenAsks[tokenId];
    }
    function setBid(uint256 tokenId,Bid memory bid,address spender) public override onlyMediaCaller {
        BidShares memory bidShares = _bidShares[tokenId];
        require(bidShares.creator.value.add(bid.sellOnShare.value) <= uint256(100).mul(Decimal.BASE),"Market: Sell on fee invalid for share splitting");
        require(bid.bidder != address(0), "Market: bidder cannot be 0 address");
        require(bid.amount != 0, "Market: cannot bid amount of 0");
        require(bid.currency != address(0),"Market: bid currency cannot be 0 address");
        require(bid.recipient != address(0),"Market: bid recipient cannot be 0 address");
        Bid storage existingBid = _tokenBidders[tokenId][bid.bidder];
        // If there is an existing bid, refund it before continuing
        if (existingBid.amount > 0) {
            removeBid(tokenId, bid.bidder);
        }
        IBEP20 token = IBEP20(bid.currency);
        uint256 beforeBalance = token.balanceOf(address(this));
        token.safeTransferFrom(spender, address(this), bid.amount);
        uint256 afterBalance = token.balanceOf(address(this));
        _tokenBidders[tokenId][bid.bidder] = Bid(afterBalance.sub(beforeBalance),bid.currency,bid.bidder,bid.recipient,bid.sellOnShare);
        emit BidCreated(tokenId, bid);
        // If a bid meets the criteria for an ask, automatically accept the bid.
        // If no ask is set or the bid does not meet the requirements, ignore.
        if (_tokenAsks[tokenId].currency != address(0) && bid.currency == _tokenAsks[tokenId].currency && bid.amount >= _tokenAsks[tokenId].amount) {
            // Finalize exchange
            _finalizeNFTTransfer(tokenId, bid.bidder);
        }
    }
    function removeBid(uint256 tokenId, address bidder)public override onlyMediaCaller{
        Bid storage bid = _tokenBidders[tokenId][bidder];
        uint256 bidAmount = bid.amount;
        address bidCurrency = bid.currency;
        require(bid.amount > 0, "Market: cannot remove bid amount of 0");
        IBEP20 token = IBEP20(bidCurrency);
        emit BidRemoved(tokenId, bid);
        delete _tokenBidders[tokenId][bidder];
        token.safeTransfer(bidder, bidAmount);
    }
    function acceptBid(uint256 tokenId, Bid calldata expectedBid)external override onlyMediaCaller{
        Bid memory bid = _tokenBidders[tokenId][expectedBid.bidder];
        require(bid.amount > 0, "Market: cannot accept bid of 0");
        require(bid.amount == expectedBid.amount && bid.currency == expectedBid.currency && bid.sellOnShare.value == expectedBid.sellOnShare.value &&
                bid.recipient == expectedBid.recipient,"Market: Unexpected bid found.");
        require(isValidBid(tokenId, bid.amount),"Market: Bid invalid for share splitting");
        _finalizeNFTTransfer(tokenId, bid.bidder);
    }
    function _finalizeNFTTransfer(uint256 tokenId, address bidder) private {
        Bid memory bid = _tokenBidders[tokenId][bidder];
        BidShares storage bidShares = _bidShares[tokenId];
        IBEP20 token = IBEP20(bid.currency);
        // Transfer bid share to owner of media
        token.safeTransfer(IBEP721(mediaContract).ownerOf(tokenId),splitShare(bidShares.owner, bid.amount));
        // Transfer bid share to creator of media
        token.safeTransfer(Media(mediaContract).tokenCreators(tokenId),splitShare(bidShares.creator, bid.amount));
        // Transfer bid share to previous owner of media (if applicable)
        token.safeTransfer(Media(mediaContract).previousTokenOwners(tokenId),splitShare(bidShares.prevOwner, bid.amount));
        // Transfer media to bid recipient
        Media(mediaContract).auctionTransfer(tokenId, bid.recipient);
        // Calculate the bid share for the new owner,
        // equal to 100 - creatorShare - sellOnShare
        bidShares.owner = Decimal.D256(uint256(100).mul(Decimal.BASE).sub(_bidShares[tokenId].creator.value).sub(bid.sellOnShare.value));
        // Set the previous owner share to the accepted bid's sell-on fee
        bidShares.prevOwner = bid.sellOnShare;
        // Remove the accepted bid
        delete _tokenBidders[tokenId][bidder];
        emit BidShareUpdated(tokenId, bidShares);
        emit BidFinalized(tokenId, bid);
    }
}
library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;
    function safeTransfer(IBEP20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(IBEP20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(IBEP20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function safeIncreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeBEP20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}