/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

library Math {
    enum Rounding {Down, Up, Zero
    }
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a & b) + (a ^ b) / 2;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function verifyCallResultFromTarget(address target, bool success, bytes memory returndata, string memory errorMessage) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }
    function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }
    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool _approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract ERC721Holder is IERC721Receiver {
  function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
    return this.onERC721Received.selector;
  }
}

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

library EnumerableSet {
    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
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
        if (valueIndex != 0) {
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;
            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];
                set._values[toDeleteIndex] = lastValue;
                set._indexes[lastValue] = valueIndex;
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
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;
        assembly {
            result := store
        }
        return result;
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
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;
        assembly {
            result := store
        }
        return result;
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
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;
        assembly {
            result := store
        }
        return result;
    }
}

library EnumerableMap {
    struct MapEntry {
        uint256 _key;
        uint256 _value;
    }
    struct Map {
        MapEntry[] _entries;
        mapping(uint256 => uint256) _indexes;
    }
    function _set(Map storage map, uint256 key, uint256 value) private returns (bool) {
        uint256 keyIndex = map._indexes[key];
        if (keyIndex == 0) {
            map._entries.push(MapEntry({_key: key, _value: value}));
            map._indexes[key] = map._entries.length;
            return true;
        } else {
            map._entries[keyIndex - 1]._value = value;
            return false;
        }
    }
    function _remove(Map storage map, uint256 key) private returns (bool) {
        uint256 keyIndex = map._indexes[key];
        if (keyIndex != 0) {
            uint256 toDeleteIndex = keyIndex - 1;
            uint256 lastIndex = map._entries.length - 1;
            MapEntry storage lastEntry = map._entries[lastIndex];
            map._entries[toDeleteIndex] = lastEntry;
            map._indexes[lastEntry._key] = toDeleteIndex + 1;
            map._entries.pop();
            delete map._indexes[key];
            return true;
        } else {
            return false;
        }
    }
    function _contains(Map storage map, uint256 key) private view returns (bool) {
        return map._indexes[key] != 0;
    }
    function _length(Map storage map) private view returns (uint256) {
        return map._entries.length;
    }
    function _at(Map storage map, uint256 index) private view returns (uint256, uint256) {
        require(map._entries.length > index, "EnumerableMap: index out of bounds");
        MapEntry storage entry = map._entries[index];
        return (entry._key, entry._value);
    }
    function _get(Map storage map, uint256 key) private view returns (uint256) {
        return _get(map, key, "EnumerableMap: nonexistent key");
    }
    function _get(Map storage map, uint256 key, string memory errorMessage) private view returns (uint256) {
        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, errorMessage);
        return map._entries[keyIndex - 1]._value;
    }
    struct UintToUintMap {
        Map _inner;
    }
    function set(UintToUintMap storage map, uint256 key, uint256 value) internal returns (bool) {
        return _set(map._inner, key, value);
    }
    function remove(UintToUintMap storage map, uint256 key) internal returns (bool) {
        return _remove(map._inner, key);
    }
    function contains(UintToUintMap storage map, uint256 key) internal view returns (bool) {
        return _contains(map._inner, key);
    }
    function length(UintToUintMap storage map) internal view returns (uint256) {
        return _length(map._inner);
    }
    function at(UintToUintMap storage map, uint256 index) internal view returns (uint256, uint256) {
        return _at(map._inner, index);
    }
    function get(UintToUintMap storage map, uint256 key) internal view returns (uint256) {
        return _get(map._inner, key);
    }
    function get(UintToUintMap storage map, uint256 key, string memory errorMessage) internal view returns (uint256) {
        return _get(map._inner, key, errorMessage);
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(from, to, amount);
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }
        emit Transfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

library TransferHelper {
    function safeApprove(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: APPROVE_FAILED");
    }
    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FAILED");
    }
    function safeTransferFrom(address token, address from, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FROM_FAILED");
    }
    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
    }
}

abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

library ExchangeNFTsHelper {
    address public constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    function burnToken(address _token, address _from, uint256 _amount) internal {
        if (_from == address(this)) {
            ERC20Burnable(_token).burn(_amount);
        } else {
            ERC20Burnable(_token).burnFrom(_from, _amount);
        }
    }
    function transferToken(address _token, address _from, address _to, uint256 _amount) internal {
        if (_amount == 0) {
            return;
        }
        if (_token == ExchangeNFTsHelper.ETH_ADDRESS) {
            if (_from == address(this)) {
                TransferHelper.safeTransferETH(_to, _amount);
            } else {
                require(_from == msg.sender && _to == address(this), "error eth");
            }
        } else {
            if (_from == address(this)) {
                TransferHelper.safeTransfer(_token, _to, _amount);
            } else {
                TransferHelper.safeTransferFrom(_token, _from, _to, _amount);
            }
        }
    }
}

interface IExchangeNFTs {
    event Ask(address indexed nftToken, address seller, uint256 indexed tokenId, address indexed quoteToken, uint256 price);
    event Trade(address indexed nftToken, address indexed quoteToken, address seller, address buyer, uint256 indexed tokenId, uint256 originPrice, uint256 price, uint256 fee);
    event CancelSellToken(address indexed nftToken, address indexed quoteToken, address seller, uint256 indexed tokenId, uint256 price);
    event Bid(address indexed nftToken, address bidder, uint256 indexed tokenId, address indexed quoteToken, uint256 price);
    event CancelBidToken(address indexed nftToken, address indexed quoteToken, address bidder, uint256 indexed tokenId, uint256 price);
    function getNftQuotes(address _nftToken) external view returns (address[] memory);
    function batchReadyToSellToken(address[] memory _nftTokens, uint256[] memory _tokenIds, address[] memory _quoteTokens, uint256[] memory _prices, uint256[] memory _selleStatus) external;
    function batchReadyToSellTokenTo(address[] memory _nftTokens, uint256[] memory _tokenIds, address[] memory _quoteTokens, uint256[] memory _prices, uint256[] memory _selleStatus, address _to) external;
    function readyToSellToken(address _nftToken, uint256 _tokenId, address _quoteToken, uint256 _price, uint256 _selleStatus) external;
    function readyToSellToken(address _nftToken, uint256 _tokenId, address _quoteToken, uint256 _price) external;
    function readyToSellTokenTo(address _nftToken, uint256 _tokenId, address _quoteToken, uint256 _price, address _to, uint256 _selleStatus) external;
    function batchSetCurrentPrice(address[] memory _nftTokens, uint256[] memory _tokenIds, address[] memory _quoteTokens, uint256[] memory _prices) external;
    function setCurrentPrice(address _nftToken, uint256 _tokenId, address _quoteToken, uint256 _price) external;
    function batchBuyToken(address[] memory _nftTokens, uint256[] memory _tokenIds, address[] memory _quoteTokens, uint256[] memory _prices) external;
    function batchBuyTokenTo(address[] memory _nftTokens, uint256[] memory _tokenIds, address[] memory _quoteTokens, uint256[] memory _prices, address _to) external;
    function buyToken(address _nftToken, uint256 _tokenId, address _quoteToken, uint256 _price) external payable;
    function buyTokenTo(address _nftToken, uint256 _tokenId, address _quoteToken, uint256 _price, address _to) external payable;
    function batchCancelSellToken(address[] memory _nftTokens, uint256[] memory _tokenIds) external;
    function cancelSellToken(address _nftToken, uint256 _tokenId) external;
    function batchBidToken(address[] memory _nftTokens, uint256[] memory _tokenIds, address[] memory _quoteTokens, uint256[] memory _prices) external;
    function batchBidTokenTo(address[] memory _nftTokens, uint256[] memory _tokenIds, address[] memory _quoteTokens, uint256[] memory _prices, address _to) external;
    function bidToken(address _nftToken, uint256 _tokenId, address _quoteToken, uint256 _price) external payable;
    function bidTokenTo(address _nftToken, uint256 _tokenId, address _quoteToken, uint256 _price, address _to) external payable;
    function batchUpdateBidPrice(address[] memory _nftTokens, uint256[] memory _tokenIds, address[] memory _quoteTokens, uint256[] memory _prices) external;
    function updateBidPrice(address _nftToken, uint256 _tokenId, address _quoteToken, uint256 _price) external payable;
    function sellTokenTo(address _nftToken, uint256 _tokenId, address _quoteToken, uint256 _price, address _to) external;
    function batchCancelBidToken(address[] memory _nftTokens, address[] memory _quoteTokens, uint256[] memory _tokenIds) external;
    function cancelBidToken(address _nftToken, address _quoteToken, uint256 _tokenId) external;
}

interface IExchangeNFTConfiguration {
    event FeeAddressTransferred(address indexed nftToken, address indexed quoteToken, address previousOwner, address newOwner);
    event SetFee(address indexed nftToken, address indexed quoteToken, address seller, uint256 oldFee, uint256 newFee);
    event SetFeeBurnAble(address indexed nftToken, address indexed quoteToken, address seller, bool oldFeeBurnable, bool newFeeBurnable);
    event SetRoyaltiesProvider(address indexed nftToken, address indexed quoteToken, address seller, address oldRoyaltiesProvider, address newRoyaltiesProvider);
    event SetRoyaltiesBurnable(address indexed nftToken, address indexed quoteToken, address seller, bool oldRoyaltiesBurnable, bool newFeeRoyaltiesBurnable);
    event UpdateSettings(uint256 indexed setting, uint256 proviousValue, uint256 value);
    struct NftSettings {bool enable; bool nftQuoteEnable; address feeAddress; bool feeBurnAble; uint256 feeValue; address royaltiesProvider; bool royaltiesBurnable;}
    function settings(uint256 _key) external view returns (uint256 value);
    function nftEnables(address _nftToken) external view returns (bool enable);
    function nftQuoteEnables(address _nftToken, address _quoteToken) external view returns (bool enable);
    function feeBurnables(address _nftToken, address _quoteToken) external view returns (bool enable);
    function feeAddresses(address _nftToken, address _quoteToken) external view returns (address feeAddress);
    function feeValues(address _nftToken, address _quoteToken) external view returns (uint256 feeValue);
    function royaltiesProviders(address _nftToken, address _quoteToken) external view returns (address royaltiesProvider);
    function royaltiesBurnables(address _nftToken, address _quoteToken) external view returns (bool enable);
    function checkEnableTrade(address _nftToken, address _quoteToken) external view;
    function whenSettings(uint256 key, uint256 value) external view;
    function setSettings(uint256[] memory keys, uint256[] memory values) external;
    function nftSettings(address _nftToken, address _quoteToken) external view returns (NftSettings memory);
    function setNftEnables(address _nftToken, bool _enable) external;
    function setNftQuoteEnables(address _nftToken, address[] memory _quotes, bool _enable) external;
    function getNftQuotes(address _nftToken) external view returns (address[] memory quotes);
    function transferFeeAddress(address _nftToken, address _quoteToken, address _feeAddress) external;
    function batchTransferFeeAddress(address _nftToken, address[] memory _quoteTokens, address[] memory _feeAddresses) external;
    function setFee(address _nftToken, address _quoteToken, uint256 _feeValue) external;
    function batchSetFee(address _nftToken, address[] memory _quoteTokens, uint256[] memory _feeValues) external;
    function setFeeBurnAble(address _nftToken, address _quoteToken, bool _feeBurnable) external;
    function batchSetFeeBurnAble(address _nftToken, address[] memory _quoteTokens, bool[] memory _feeBurnables) external;
    function setRoyaltiesProvider(address _nftToken, address _quoteToken, address _royaltiesProvider) external;
    function batchSetRoyaltiesProviders(address _nftToken, address[] memory _quoteTokens, address[] memory _royaltiesProviders) external;
    function setRoyaltiesBurnable(address _nftToken, address _quoteToken, bool _royaltiesBurnable) external;
    function batchSetRoyaltiesBurnable(address _nftToken, address[] memory _quoteTokens, bool[] memory _royaltiesBurnables) external;
    function addNft(address _nftToken, bool _enable, address[] memory _quotes, address[] memory _feeAddresses, uint256[] memory _feeValues, bool[] memory _feeBurnAbles, address[] memory _royaltiesProviders, bool[] memory _royaltiesBurnables) external;
}

library LibPart {
    bytes32 public constant TYPE_HASH = keccak256("Part(address account,uint96 value)");
    struct Part {
        address payable account;
        uint96 value;
    }
    function hash(Part memory part) internal pure returns (bytes32) {
        return keccak256(abi.encode(TYPE_HASH, part.account, part.value));
    }
}

interface IRoyaltiesProvider {
    function getRoyalties(address token, uint256 tokenId) external returns (LibPart.Part[] memory);
}

contract NFT_Trade_Contract is IExchangeNFTs, ERC721Holder, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using EnumerableMap for EnumerableMap.UintToUintMap;
    using EnumerableSet for EnumerableSet.UintSet;
    struct SettleTrade {
        address nftToken;
        address quoteToken;
        address buyer;
        address seller;
        uint256 tokenId;
        uint256 originPrice;
        uint256 price;
        bool isMaker;
    }
    struct AskEntry {
        uint256 tokenId;
        uint256 price;
    }
    struct BidEntry {
        address bidder;
        uint256 price;
    }
    struct UserBidEntry {
        uint256 tokenId;
        uint256 price;
    }

    IExchangeNFTConfiguration public config;
    mapping(address => mapping(uint256 => address)) public tokenSellers;
    mapping(address => mapping(uint256 => address)) public tokenSelleOn;
    mapping(address => mapping(address => EnumerableMap.UintToUintMap)) private _asksMaps;
    mapping(address => mapping(address => mapping(address => EnumerableSet.UintSet))) private _userSellingTokens;
    mapping(address => mapping(address => mapping(uint256 => BidEntry[]))) public tokenBids;
    mapping(address => mapping(address => mapping(address => EnumerableMap.UintToUintMap))) private _userBids;
    mapping(address => mapping(uint256 => uint256)) tokenSelleStatus;
    function setConfig(address _config) public onlyOwner {
        require(address(config) != _config, "forbidden");
        config = IExchangeNFTConfiguration(_config);
    }
    function getNftQuotes(address _nftToken) public view override returns (address[] memory) {
        return config.getNftQuotes(_nftToken);
    }
    function batchReadyToSellToken(address[] memory _nftTokens, uint256[] memory _tokenIds, address[] memory _quoteTokens, uint256[] memory _prices, uint256[] memory _selleStatus) external override {
        batchReadyToSellTokenTo(_nftTokens, _tokenIds, _quoteTokens, _prices, _selleStatus, _msgSender());
    }
    function batchReadyToSellTokenTo(address[] memory _nftTokens, uint256[] memory _tokenIds, address[] memory _quoteTokens, uint256[] memory _prices, uint256[] memory _selleStatus, address _to) public override {
        require(_nftTokens.length == _tokenIds.length && _tokenIds.length == _quoteTokens.length && _quoteTokens.length == _prices.length, "length err");
        for (uint256 i = 0; i < _nftTokens.length; i++) {
            readyToSellTokenTo(_nftTokens[i], _tokenIds[i], _quoteTokens[i], _prices[i], _to, _selleStatus[i]);
        }
    }
    function readyToSellToken(address _nftToken, uint256 _tokenId, address _quoteToken, uint256 _price, uint256 _selleStatus) external override {
        readyToSellTokenTo(_nftToken, _tokenId, _quoteToken, _price, _msgSender(), _selleStatus);
    }
    function readyToSellToken(address _nftToken, uint256 _tokenId, address _quoteToken, uint256 _price) external override {
        readyToSellTokenTo(_nftToken, _tokenId, _quoteToken, _price, _msgSender(), 0);
    }
    function readyToSellTokenTo(address _nftToken, uint256 _tokenId, address _quoteToken, uint256 _price, address _to, uint256 _selleStatus) public override nonReentrant {
        config.whenSettings(0, 0);
        config.checkEnableTrade(_nftToken, _quoteToken);
        require(_msgSender() == IERC721(_nftToken).ownerOf(_tokenId), "Only Token Owner can sell token");
        require(_price != 0, "Price must be granter than zero");
        IERC721(_nftToken).safeTransferFrom(_msgSender(), address(this), _tokenId);
        _asksMaps[_nftToken][_quoteToken].set(_tokenId, _price);
        tokenSellers[_nftToken][_tokenId] = _to;
        tokenSelleOn[_nftToken][_tokenId] = _quoteToken;
        _userSellingTokens[_nftToken][_quoteToken][_to].add(_tokenId);
        tokenSelleStatus[_nftToken][_tokenId] = _selleStatus;
        emit Ask(_nftToken, _msgSender(), _tokenId, _quoteToken, _price);
    }
    function batchSetCurrentPrice(address[] memory _nftTokens, uint256[] memory _tokenIds, address[] memory _quoteTokens, uint256[] memory _prices) external override {
        require(_nftTokens.length == _tokenIds.length && _tokenIds.length == _quoteTokens.length && _quoteTokens.length == _prices.length, "length err");
        for (uint256 i = 0; i < _nftTokens.length; i++) {
            setCurrentPrice(_nftTokens[i], _tokenIds[i], _quoteTokens[i], _prices[i]);
        }
    }
    function setCurrentPrice(address _nftToken, uint256 _tokenId, address _quoteToken, uint256 _price) public override nonReentrant {
        config.whenSettings(1, 0);
        config.checkEnableTrade(_nftToken, _quoteToken);
        require(_userSellingTokens[_nftToken][_quoteToken][_msgSender()].contains(_tokenId), "Only Seller can update price");
        require(_price != 0, "Price must be granter than zero");
        _asksMaps[_nftToken][_quoteToken].set(_tokenId, _price);
        emit Ask(_nftToken, _msgSender(), _tokenId, _quoteToken, _price);
    }
    function batchBuyToken(address[] memory _nftTokens, uint256[] memory _tokenIds, address[] memory _quoteTokens, uint256[] memory _prices) external override {
        batchBuyTokenTo(_nftTokens, _tokenIds, _quoteTokens, _prices, _msgSender());
    }
    function batchBuyTokenTo(address[] memory _nftTokens, uint256[] memory _tokenIds, address[] memory _quoteTokens, uint256[] memory _prices, address _to) public override {
        require(_nftTokens.length == _tokenIds.length && _tokenIds.length == _quoteTokens.length && _quoteTokens.length == _prices.length, "length err");
        for (uint256 i = 0; i < _nftTokens.length; i++) {
            buyTokenTo(_nftTokens[i], _tokenIds[i], _quoteTokens[i], _prices[i], _to);
        }
    }
    function buyToken(address _nftToken, uint256 _tokenId, address _quoteToken, uint256 _price) external payable override {
        buyTokenTo(_nftToken, _tokenId, _quoteToken, _price, _msgSender());
    }
    function _settleTrade(SettleTrade memory settleTrade) internal {
        IExchangeNFTConfiguration.NftSettings memory nftSettings = config.nftSettings(settleTrade.nftToken, settleTrade.quoteToken);
        uint256 feeAmount = settleTrade.price.mul(nftSettings.feeValue).div(10000);
        address transferTokenFrom = settleTrade.isMaker ? address(this) : _msgSender();
        if (feeAmount != 0) {
            if (nftSettings.feeBurnAble) {
                ExchangeNFTsHelper.burnToken(settleTrade.quoteToken, transferTokenFrom, feeAmount);
            } else {
                ExchangeNFTsHelper.transferToken(settleTrade.quoteToken, transferTokenFrom, nftSettings.feeAddress,feeAmount);
            }
        }
        uint256 restValue = settleTrade.price.sub(feeAmount);
        if (nftSettings.royaltiesProvider != address(0)) {
            LibPart.Part[] memory fees = IRoyaltiesProvider(nftSettings.royaltiesProvider).getRoyalties(settleTrade.nftToken, settleTrade.tokenId);
            for (uint256 i = 0; i < fees.length; i++) {
                uint256 feeValue = settleTrade.price.mul(fees[i].value).div(10000);
                if (restValue > feeValue) {
                    restValue = restValue.sub(feeValue);
                } else {
                    feeValue = restValue;
                    restValue = 0;
                }
                if (feeValue != 0) {
                    feeAmount = feeAmount.add(feeValue);
                    if (nftSettings.royaltiesBurnable) {
                        ExchangeNFTsHelper.burnToken(settleTrade.quoteToken, transferTokenFrom, feeValue);
                    } else {
                        ExchangeNFTsHelper.transferToken(settleTrade.quoteToken, transferTokenFrom, fees[i].account, feeValue);
                    }
                }
            }
        }
        ExchangeNFTsHelper.transferToken(settleTrade.quoteToken, transferTokenFrom, settleTrade.seller, restValue);
        _asksMaps[settleTrade.nftToken][settleTrade.quoteToken].remove(settleTrade.tokenId);
        _userSellingTokens[settleTrade.nftToken][settleTrade.quoteToken][settleTrade.seller].remove(settleTrade.tokenId);
        IERC721(settleTrade.nftToken).safeTransferFrom(address(this), settleTrade.buyer, settleTrade.tokenId);
        emit Trade(settleTrade.nftToken, settleTrade.quoteToken, settleTrade.seller, settleTrade.buyer, settleTrade.tokenId, settleTrade.originPrice, settleTrade.price, feeAmount);
        delete tokenSellers[settleTrade.nftToken][settleTrade.tokenId];
        delete tokenSelleOn[settleTrade.nftToken][settleTrade.tokenId];
        delete tokenSelleStatus[settleTrade.nftToken][settleTrade.tokenId];
    }
    function buyTokenTo(address _nftToken, uint256 _tokenId, address _quoteToken, uint256 _price, address _to) public payable override nonReentrant {
        config.whenSettings(2, 0);
        config.checkEnableTrade(_nftToken, _quoteToken);
        require(tokenSelleOn[_nftToken][_tokenId] == _quoteToken, "quote token err");
        require(_asksMaps[_nftToken][_quoteToken].contains(_tokenId), "Token not in sell book");
        require(!_userBids[_nftToken][_quoteToken][_msgSender()].contains(_tokenId), "You must cancel your bid first");
        uint256 price = _asksMaps[_nftToken][_quoteToken].get(_tokenId);
        require(_price == price, "Wrong price");
        require((msg.value == 0 && _quoteToken != ExchangeNFTsHelper.ETH_ADDRESS) || (_quoteToken == ExchangeNFTsHelper.ETH_ADDRESS && msg.value == _price), "error msg value");
        require(tokenSelleStatus[_nftToken][_tokenId] == 0, "only bid");
        _settleTrade(
            SettleTrade({
                nftToken: _nftToken,
                quoteToken: _quoteToken,
                buyer: _to,
                seller: tokenSellers[_nftToken][_tokenId],
                tokenId: _tokenId,
                originPrice: price,
                price: _price,
                isMaker: false
            })
        );
    }
    function batchCancelSellToken(address[] memory _nftTokens, uint256[] memory _tokenIds) external override {
        require(_nftTokens.length == _tokenIds.length);
        for (uint256 i = 0; i < _nftTokens.length; i++) {
            cancelSellToken(_nftTokens[i], _tokenIds[i]);
        }
    }
    function cancelSellToken(address _nftToken, uint256 _tokenId) public override nonReentrant {
        config.whenSettings(3, 0);
        require(tokenSellers[_nftToken][_tokenId] == _msgSender(), "Only Seller can cancel sell token");
        IERC721(_nftToken).safeTransferFrom(address(this), _msgSender(), _tokenId);
        _userSellingTokens[_nftToken][tokenSelleOn[_nftToken][_tokenId]][_msgSender()].remove(_tokenId);
        emit CancelSellToken(_nftToken, tokenSelleOn[_nftToken][_tokenId], _msgSender(), _tokenId, _asksMaps[_nftToken][tokenSelleOn[_nftToken][_tokenId]].get(_tokenId));
        _asksMaps[_nftToken][tokenSelleOn[_nftToken][_tokenId]].remove(_tokenId);
        delete tokenSellers[_nftToken][_tokenId];
        delete tokenSelleOn[_nftToken][_tokenId];
        delete tokenSelleStatus[_nftToken][_tokenId];
    }
    function getAskLength(address _nftToken, address _quoteToken) public view returns (uint256) {
        return _asksMaps[_nftToken][_quoteToken].length();
    }
    function getAsks(address _nftToken, address _quoteToken) public view returns (AskEntry[] memory) {
        AskEntry[] memory asks = new AskEntry[](_asksMaps[_nftToken][_quoteToken].length());
        for (uint256 i = 0; i < _asksMaps[_nftToken][_quoteToken].length(); ++i) {
            (uint256 tokenId, uint256 price) = _asksMaps[_nftToken][_quoteToken].at(i);
            asks[i] = AskEntry({tokenId: tokenId, price: price});
        }
        return asks;
    }
    function getAsksByNFT(address _nftToken) external view returns (
            address[] memory quotes, uint256[] memory lengths, AskEntry[] memory asks
        ) {
        quotes = getNftQuotes(_nftToken);
        lengths = new uint256[](quotes.length);
        uint256 total = 0;
        for (uint256 i = 0; i < quotes.length; ++i) {
            lengths[i] = getAskLength(_nftToken, quotes[i]);
            total = total + lengths[i];
        }
        asks = new AskEntry[](total);
        uint256 index = 0;
        for (uint256 i = 0; i < quotes.length; ++i) {
            AskEntry[] memory tempAsks = getAsks(_nftToken, quotes[i]);
            for (uint256 j = 0; j < tempAsks.length; ++j) {
                asks[index] = tempAsks[j];
                ++index;
            }
        }
    }
    function getAsksByPage(address _nftToken, address _quoteToken, uint256 _page, uint256 _size) external view returns (AskEntry[] memory) {
        if (_asksMaps[_nftToken][_quoteToken].length() > 0) {
            uint256 from = _page == 0 ? 0 : (_page - 1) * _size;
            uint256 to = Math.min((_page == 0 ? 1 : _page) * _size, _asksMaps[_nftToken][_quoteToken].length());
            AskEntry[] memory asks = new AskEntry[]((to - from));
            for (uint256 i = 0; from < to; ++i) {
                (uint256 tokenId, uint256 price) = _asksMaps[_nftToken][_quoteToken].at(from);
                asks[i] = AskEntry({tokenId: tokenId, price: price});
                ++from;
            }
            return asks;
        } else {
            return new AskEntry[](0);
        }
    }
    function getUserAsks(address _nftToken, address _quoteToken, address _user) public view returns (AskEntry[] memory) {
        AskEntry[] memory asks = new AskEntry[](_userSellingTokens[_nftToken][_quoteToken][_user].length());
        for (uint256 i = 0; i < _userSellingTokens[_nftToken][_quoteToken][_user].length(); ++i) {
            uint256 tokenId = _userSellingTokens[_nftToken][_quoteToken][_user].at(i);
            uint256 price = _asksMaps[_nftToken][_quoteToken].get(tokenId);
            asks[i] = AskEntry({tokenId: tokenId, price: price});
        }
        return asks;
    }
    function getUserAsksByNFT(address _nftToken, address _user) external view returns (
            address[] memory quotes, uint256[] memory lengths, AskEntry[] memory asks
        ) {
        quotes = getNftQuotes(_nftToken);
        lengths = new uint256[](quotes.length);
        uint256 total = 0;
        for (uint256 i = 0; i < quotes.length; ++i) {
            lengths[i] = _userSellingTokens[_nftToken][quotes[i]][_user].length();
            total = total + lengths[i];
        }
        asks = new AskEntry[](total);
        uint256 index = 0;
        for (uint256 i = 0; i < quotes.length; ++i) {
            AskEntry[] memory tempAsks = getUserAsks(_nftToken, quotes[i], _user);
            for (uint256 j = 0; j < tempAsks.length; ++j) {
                asks[index] = tempAsks[j];
                ++index;
            }
        }
    }
    function batchBidToken(address[] memory _nftTokens, uint256[] memory _tokenIds, address[] memory _quoteTokens, uint256[] memory _prices) external override {
        batchBidTokenTo(_nftTokens, _tokenIds, _quoteTokens, _prices, _msgSender());
    }
    function batchBidTokenTo(address[] memory _nftTokens, uint256[] memory _tokenIds, address[] memory _quoteTokens, uint256[] memory _prices, address _to) public override {
        require(_nftTokens.length == _tokenIds.length && _tokenIds.length == _quoteTokens.length && _quoteTokens.length == _prices.length, "length err");
        for (uint256 i = 0; i < _nftTokens.length; i++) {
            bidTokenTo(_nftTokens[i], _tokenIds[i], _quoteTokens[i], _prices[i], _to);
        }
    }
    function bidToken(address _nftToken, uint256 _tokenId, address _quoteToken, uint256 _price) external payable override {
        bidTokenTo(_nftToken, _tokenId, _quoteToken, _price, _msgSender());
    }
    function bidTokenTo(address _nftToken, uint256 _tokenId, address _quoteToken, uint256 _price, address _to) public payable override nonReentrant {
        config.whenSettings(4, 0);
        config.checkEnableTrade(_nftToken, _quoteToken);
        require(_price != 0, "Price must be granter than zero");
        require(_asksMaps[_nftToken][_quoteToken].contains(_tokenId), "Token not in sell book");
        require(tokenSellers[_nftToken][_tokenId] != _to, "Owner cannot bid");
        require(!_userBids[_nftToken][_quoteToken][_to].contains(_tokenId), "Bidder already exists");
        require((msg.value == 0 && _quoteToken != ExchangeNFTsHelper.ETH_ADDRESS) || (_quoteToken == ExchangeNFTsHelper.ETH_ADDRESS && msg.value == _price), "error msg value");
        if (_quoteToken != ExchangeNFTsHelper.ETH_ADDRESS) {
            TransferHelper.safeTransferFrom(_quoteToken, _msgSender(), address(this), _price);
        }
        _userBids[_nftToken][_quoteToken][_to].set(_tokenId, _price);
        tokenBids[_nftToken][_quoteToken][_tokenId].push(BidEntry({bidder: _to, price: _price}));
        emit Bid(_nftToken, _to, _tokenId, _quoteToken, _price);
    }
    function batchUpdateBidPrice(address[] memory _nftTokens, uint256[] memory _tokenIds, address[] memory _quoteTokens, uint256[] memory _prices) external override {
        require(_nftTokens.length == _tokenIds.length && _tokenIds.length == _quoteTokens.length && _quoteTokens.length == _prices.length, "length err");
        for (uint256 i = 0; i < _nftTokens.length; i++) {
            updateBidPrice(_nftTokens[i], _tokenIds[i], _quoteTokens[i], _prices[i]);
        }
    }
    function updateBidPrice(address _nftToken, uint256 _tokenId, address _quoteToken, uint256 _price) public payable override nonReentrant {
        config.whenSettings(5, 0);
        config.checkEnableTrade(_nftToken, _quoteToken);
        require(_userBids[_nftToken][_quoteToken][_msgSender()].contains(_tokenId), "Only Bidder can update the bid price");
        require(_price != 0, "Price must be granter than zero");
        address _to = _msgSender();
        (BidEntry memory bidEntry, uint256 _index) = getBidByTokenIdAndAddress(_nftToken, _quoteToken, _tokenId, _to);
        require(bidEntry.price != 0, "Bidder does not exist");
        require(bidEntry.price != _price, "The bid price cannot be the same");
        require((_quoteToken != ExchangeNFTsHelper.ETH_ADDRESS && msg.value == 0) || _quoteToken == ExchangeNFTsHelper.ETH_ADDRESS, "error msg value");
        if (_price > bidEntry.price) {
            require(_quoteToken != ExchangeNFTsHelper.ETH_ADDRESS || msg.value == _price.sub(bidEntry.price), "error msg value.");
            ExchangeNFTsHelper.transferToken(_quoteToken, _msgSender(), address(this), _price.sub(bidEntry.price));
        } else {
            ExchangeNFTsHelper.transferToken(_quoteToken, address(this), _msgSender(), bidEntry.price.sub(_price));
        }
        _userBids[_nftToken][_quoteToken][_to].set(_tokenId, _price);
        tokenBids[_nftToken][_quoteToken][_tokenId][_index] = BidEntry({bidder: _to, price: _price});
        emit Bid(_nftToken, _to, _tokenId, _quoteToken, _price);
    }
    function getBidByTokenIdAndAddress(address _nftToken, address _quoteToken, uint256 _tokenId, address _address) internal view virtual returns (BidEntry memory, uint256) {
        BidEntry[] memory bidEntries = tokenBids[_nftToken][_quoteToken][_tokenId];
        uint256 len = bidEntries.length;
        uint256 _index;
        BidEntry memory bidEntry;
        for (uint256 i = 0; i < len; i++) {
            if (_address == bidEntries[i].bidder) {
                _index = i;
                bidEntry = BidEntry({bidder: bidEntries[i].bidder, price: bidEntries[i].price});
                break;
            }
        }
        return (bidEntry, _index);
    }
    function delBidByTokenIdAndIndex(address _nftToken, address _quoteToken, uint256 _tokenId, uint256 _index) internal virtual {
        _userBids[_nftToken][_quoteToken][tokenBids[_nftToken][_quoteToken][_tokenId][_index].bidder].remove(_tokenId);
        uint256 len = tokenBids[_nftToken][_quoteToken][_tokenId].length;
        for (uint256 i = _index; i < len - 1; i++) {
            tokenBids[_nftToken][_quoteToken][_tokenId][i] = tokenBids[_nftToken][_quoteToken][_tokenId][i + 1];
        }
        tokenBids[_nftToken][_quoteToken][_tokenId].pop();
    }
    function sellTokenTo(address _nftToken, uint256 _tokenId, address _quoteToken, uint256 _price, address _to) public override nonReentrant {
        config.whenSettings(6, 0);
        config.checkEnableTrade(_nftToken, _quoteToken);
        require(_asksMaps[_nftToken][_quoteToken].contains(_tokenId), "Token not in sell book");
        require(tokenSellers[_nftToken][_tokenId] == _msgSender(), "Only owner can sell token");
        (BidEntry memory bidEntry, uint256 _index) = getBidByTokenIdAndAddress(_nftToken, _quoteToken, _tokenId, _to);
        require(bidEntry.price != 0, "Bidder does not exist");
        require(_price == bidEntry.price, "Wrong price");
        uint256 originPrice = _asksMaps[_nftToken][_quoteToken].get(_tokenId);
        _settleTrade(
            SettleTrade({
                nftToken: _nftToken,
                quoteToken: _quoteToken,
                buyer: _to,
                seller: tokenSellers[_nftToken][_tokenId],
                tokenId: _tokenId,
                originPrice: originPrice,
                price: bidEntry.price,
                isMaker: true
            })
        );
        delBidByTokenIdAndIndex(_nftToken, _quoteToken, _tokenId, _index);
    }
    function batchCancelBidToken(address[] memory _nftTokens, address[] memory _quoteTokens, uint256[] memory _tokenIds) external override {
        require(_nftTokens.length == _quoteTokens.length && _quoteTokens.length == _tokenIds.length, "length err");
        for (uint256 i = 0; i < _nftTokens.length; i++) {
            cancelBidToken(_nftTokens[i], _quoteTokens[i], _tokenIds[i]);
        }
    }
    function cancelBidToken(address _nftToken, address _quoteToken, uint256 _tokenId) public override nonReentrant {
        config.whenSettings(7, 0);
        require(_userBids[_nftToken][_quoteToken][_msgSender()].contains(_tokenId), "Only Bidder can cancel the bid");
        (BidEntry memory bidEntry, uint256 _index) = getBidByTokenIdAndAddress(_nftToken, _quoteToken, _tokenId, _msgSender());
        require(bidEntry.price != 0, "Bidder does not exist");
        ExchangeNFTsHelper.transferToken(_quoteToken, address(this), _msgSender(), bidEntry.price);
        emit CancelBidToken(_nftToken, _quoteToken, _msgSender(), _tokenId, bidEntry.price);
        delBidByTokenIdAndIndex(_nftToken, _quoteToken, _tokenId, _index);
    }
    function getBidsLength(address _nftToken, address _quoteToken, uint256 _tokenId) external view returns (uint256) {
        return tokenBids[_nftToken][_quoteToken][_tokenId].length;
    }
    function getBids(address _nftToken, address _quoteToken, uint256 _tokenId) external view returns (BidEntry[] memory) {
        return tokenBids[_nftToken][_quoteToken][_tokenId];
    }
    function getUserBids(address _nftToken, address _quoteToken, address _user) public view returns (UserBidEntry[] memory) {
        uint256 length = _userBids[_nftToken][_quoteToken][_user].length();
        UserBidEntry[] memory bids = new UserBidEntry[](length);
        for (uint256 i = 0; i < length; i++) {
            (uint256 tokenId, uint256 price) = _userBids[_nftToken][_quoteToken][_user].at(i);
            bids[i] = UserBidEntry({tokenId: tokenId, price: price});
        }
        return bids;
    }
    function getUserBidsByNFT(address _nftToken, address _user) external view returns (address[] memory quotes, uint256[] memory lengths, UserBidEntry[] memory bids
        ) {
        quotes = getNftQuotes(_nftToken);
        lengths = new uint256[](quotes.length);
        uint256 total = 0;
        for (uint256 i = 0; i < quotes.length; ++i) {
            lengths[i] = _userBids[_nftToken][quotes[i]][_user].length();
            total = total + lengths[i];
        }
        bids = new UserBidEntry[](total);
        uint256 index = 0;
        for (uint256 i = 0; i < quotes.length; ++i) {
            UserBidEntry[] memory tempBids = getUserBids(_nftToken, quotes[i], _user);
            for (uint256 j = 0; j < tempBids.length; ++j) {
                bids[index] = tempBids[j];
                ++index;
            }
        }
    }
}