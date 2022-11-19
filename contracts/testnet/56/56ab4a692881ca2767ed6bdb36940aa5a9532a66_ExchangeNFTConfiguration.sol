/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

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

contract ExchangeNFTConfiguration is IExchangeNFTConfiguration, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    mapping(uint256 => uint256) public override settings;
    mapping(address => bool) public override nftEnables;
    mapping(address => mapping(address => bool)) public override nftQuoteEnables;
    mapping(address => mapping(address => bool)) public override feeBurnables;
    mapping(address => mapping(address => address)) public override feeAddresses;
    mapping(address => mapping(address => uint256)) public override feeValues;
    mapping(address => mapping(address => address)) public override royaltiesProviders;
    mapping(address => mapping(address => bool)) public override royaltiesBurnables;
    mapping(address => EnumerableSet.AddressSet) private nftQuotes;
    function nftSettings(address _nftToken, address _quoteToken) external view override returns (NftSettings memory) {
        return NftSettings({enable: nftEnables[_nftToken], nftQuoteEnable: nftQuoteEnables[_nftToken][_quoteToken], feeAddress: feeAddresses[_nftToken][_quoteToken], feeBurnAble: feeBurnables[_nftToken][_quoteToken], feeValue: feeValues[_nftToken][_quoteToken], royaltiesProvider: royaltiesProviders[_nftToken][_quoteToken], royaltiesBurnable: royaltiesBurnables[_nftToken][_quoteToken]});
    }
    function checkEnableTrade(address _nftToken, address _quoteToken) external view override {
        require(nftEnables[_nftToken], "nft disable");
        require(nftQuoteEnables[_nftToken][_quoteToken], "quote disable");
    }
    function whenSettings(uint256 key, uint256 value) external view override {
        require(settings[key] == value, "settings err");
    }
    function setSettings(uint256[] memory keys, uint256[] memory values) external override onlyOwner {
        require(keys.length == values.length, "Invalid Length");
        for (uint256 i; i < keys.length; ++i) {
            emit UpdateSettings(keys[i], settings[keys[i]], values[i]);
            settings[keys[i]] = values[i];
        }
    }
    function setNftEnables(address _nftToken, bool _enable) public override onlyOwner {
        nftEnables[_nftToken] = _enable;
    }
    function setNftQuoteEnables(address _nftToken, address[] memory _quotes, bool _enable) public override onlyOwner {
        EnumerableSet.AddressSet storage quotes = nftQuotes[_nftToken];
        for (uint256 i; i < _quotes.length; i++) {
            nftQuoteEnables[_nftToken][_quotes[i]] = _enable;
            if (!quotes.contains(_quotes[i])) {
                quotes.add(_quotes[i]);
            }
        }
    }
    function getNftQuotes(address _nftToken) external view override returns (address[] memory quotes) {
        quotes = new address[](nftQuotes[_nftToken].length());
        for (uint256 i = 0; i < nftQuotes[_nftToken].length(); ++i) {
            quotes[i] = nftQuotes[_nftToken].at(i);
        }
    }
    function transferFeeAddress(address _nftToken, address _quoteToken, address _feeAddress) public override {
        require(_msgSender() == feeAddresses[_nftToken][_quoteToken] || owner() == _msgSender(), "forbidden");
        emit FeeAddressTransferred(_nftToken, _quoteToken, feeAddresses[_nftToken][_quoteToken], _feeAddress);
        feeAddresses[_nftToken][_quoteToken] = _feeAddress;
    }
    function batchTransferFeeAddress(address _nftToken, address[] memory _quoteTokens, address[] memory _feeAddresses) public override {
        require(_quoteTokens.length == _feeAddresses.length, "Invalid Length");
        for (uint256 i; i < _quoteTokens.length; ++i) {
            transferFeeAddress(_nftToken, _quoteTokens[i], _feeAddresses[i]);
        }
    }
    function setFee(address _nftToken, address _quoteToken, uint256 _feeValue) public override onlyOwner {
        emit SetFee(_nftToken, _quoteToken, _msgSender(), feeValues[_nftToken][_quoteToken], _feeValue);
        feeValues[_nftToken][_quoteToken] = _feeValue;
    }
    function batchSetFee(address _nftToken, address[] memory _quoteTokens, uint256[] memory _feeValues) public override onlyOwner {
        require(_quoteTokens.length == _feeValues.length, "Invalid Length");
        for (uint256 i; i < _quoteTokens.length; ++i) {
            setFee(_nftToken, _quoteTokens[i], _feeValues[i]);
        }
    }
    function setFeeBurnAble(address _nftToken, address _quoteToken, bool _feeBurnable) public override onlyOwner {
        emit SetFeeBurnAble(_nftToken, _quoteToken, _msgSender(), feeBurnables[_nftToken][_quoteToken], _feeBurnable);
        feeBurnables[_nftToken][_quoteToken] = _feeBurnable;
    }
    function batchSetFeeBurnAble(address _nftToken, address[] memory _quoteTokens, bool[] memory _feeBurnables) public override onlyOwner {
        require(_quoteTokens.length == _feeBurnables.length, "Invalid Length");
        for (uint256 i; i < _quoteTokens.length; ++i) {
            setFeeBurnAble(_nftToken, _quoteTokens[i], _feeBurnables[i]);
        }
    }
    function setRoyaltiesProvider(address _nftToken, address _quoteToken, address _royaltiesProvider) public override onlyOwner {
        emit SetRoyaltiesProvider(_nftToken, _quoteToken, _msgSender(), royaltiesProviders[_nftToken][_quoteToken], _royaltiesProvider);
        royaltiesProviders[_nftToken][_quoteToken] = _royaltiesProvider;
    }
    function batchSetRoyaltiesProviders(address _nftToken, address[] memory _quoteTokens, address[] memory _royaltiesProviders) public override onlyOwner {
        require(_quoteTokens.length == _royaltiesProviders.length, "Invalid Length");
        for (uint256 i; i < _quoteTokens.length; ++i) {
            setRoyaltiesProvider(_nftToken, _quoteTokens[i], _royaltiesProviders[i]);
        }
    }
    function setRoyaltiesBurnable(address _nftToken, address _quoteToken, bool _royaltiesBurnable) public override onlyOwner {
        emit SetRoyaltiesBurnable(_nftToken, _quoteToken, _msgSender(), royaltiesBurnables[_nftToken][_quoteToken], _royaltiesBurnable);
        royaltiesBurnables[_nftToken][_quoteToken] = _royaltiesBurnable;
    }
    function batchSetRoyaltiesBurnable(address _nftToken, address[] memory _quoteTokens, bool[] memory _royaltiesBurnables) public override onlyOwner {
        require(_quoteTokens.length == _royaltiesBurnables.length, "Invalid Length");
        for (uint256 i; i < _quoteTokens.length; ++i) {
            setRoyaltiesBurnable(_nftToken, _quoteTokens[i], _royaltiesBurnables[i]);
        }
    }
    function addNft(address _nftToken, bool _enable, address[] memory _quotes, address[] memory _feeAddresses, uint256[] memory _feeValues, bool[] memory _feeBurnAbles, address[] memory _royaltiesProviders, bool[] memory _royaltiesBurnables) external override onlyOwner {
        require(_quotes.length == _feeAddresses.length && _feeAddresses.length == _feeValues.length && _feeValues.length == _feeBurnAbles.length && _feeBurnAbles.length == _royaltiesProviders.length && _royaltiesProviders.length == _royaltiesBurnables.length, "Invalid Length");
        setNftEnables(_nftToken, _enable);
        setNftQuoteEnables(_nftToken, _quotes, true);
        batchTransferFeeAddress(_nftToken, _quotes, _feeAddresses);
        batchSetFee(_nftToken, _quotes, _feeValues);
        batchSetFeeBurnAble(_nftToken, _quotes, _feeBurnAbles);
        batchSetRoyaltiesProviders(_nftToken, _quotes, _royaltiesProviders);
        batchSetRoyaltiesBurnable(_nftToken, _quotes, _royaltiesBurnables);
    }
}