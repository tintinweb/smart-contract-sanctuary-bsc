/**
 *Submitted for verification at BscScan.com on 2022-10-11
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.8.7;

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
        return _values(set._inner);
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


interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "e5");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "e6");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "e7");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "e8");
        uint256 c = a / b;
        return c;
    }
}


library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "e0");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "e1");
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
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "k002");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "k003");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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
        require(_status != _ENTERED, "k004");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
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
        require(address(this).balance >= amount, "k005");

        (bool success,) = recipient.call{value : amount}("");
        require(success, "k006");
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
        require(address(this).balance >= value, "k007");
        require(isContract(target), "k008");

        (bool success, bytes memory returndata) = target.call{value : value}(data);
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
        require(isContract(target), "k009");

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
        require(isContract(target), "k010");

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

contract shareTokenV2 is Ownable, ReentrancyGuard {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;
    address public erc20Token;
    uint256 public distributionAmount;
    uint256 public minDistributionAmount = 1000000 * (10 ** 18);
    uint256 public claimedAmount;
    uint256 public indexes = 0;
    mapping(uint256 => mapping(address => bool)) public ClaimStatusList;
    mapping(uint256 => distributionItem) public distributionList;
    mapping(address => bool) public callerList;
    mapping(address => uint256) public userClaimedAmountList;
    EnumerableSet.AddressSet private vipSet;
    uint256 public vipNum;
    mapping(uint256 => address) public vipList;
    mapping(address => uint256) public vipIndexList;


    struct dataItem {
        uint256 balance;
        uint256 distributionAmount;
        uint256 claimedAmount;
        uint256 vipNum;
    }

    struct distributionItem {
        uint256 index;
        uint256 maxTokenId;
        uint256 pershare;
        uint256 totalShare;
    }

    constructor () {
        callerList[msg.sender] = true;
    }

    modifier onlyCaller() {
        require(callerList[msg.sender], "only caller");
        _;
    }

    event claimEvent(address _account, uint256 _tokenID, uint256 _index, uint256 _claimedAmount);
    event doShareEvent(address _account, uint256 _index, uint256 _maxTokenId, uint256 _perShare, uint256 _totalShare);


    function setCallList(address _user, bool _status) external onlyOwner {
        callerList[_user] = _status;
    }

    function addVip(address[] memory _addressList) external onlyOwner {
        for (uint256 i = 0; i < _addressList.length; i++) {
            if (!vipSet.contains(_addressList[i])) {
                vipSet.add(_addressList[i]);
                vipList[vipNum] = _addressList[i];
                vipIndexList[_addressList[i]] = vipNum;
                vipNum = vipNum.add(1);
            }
        }

    }

    function getVipList() external view returns (address[] memory) {
        return vipSet.values();
    }

    function getVipListLength() external view returns (uint256) {
        return vipSet.length();
    }

    function getVipListItem(uint256 _index) external view returns (address) {
        return vipSet.at(_index);
    }

    function setErc20Token(address _erc20Token) external onlyOwner {
        erc20Token = _erc20Token;
    }

    function setMinDistributionAmount(uint256 _minDistributionAmount) external onlyOwner {
        minDistributionAmount = _minDistributionAmount;
    }

    function doShare() external nonReentrant onlyCaller {
        uint256 balance = erc20Token == address(0) ? address(this).balance : IERC20(erc20Token).balanceOf(address(this));
        if (balance < minDistributionAmount.add(distributionAmount.sub(claimedAmount))) {
            return;
        }
        uint256 toShareAmount = balance.sub(distributionAmount.sub(claimedAmount));
        uint256 perShare = toShareAmount.div(vipNum);
        uint256 totalShare = perShare.mul(vipNum);
        emit doShareEvent(msg.sender, indexes, vipNum, perShare, totalShare);
        distributionList[indexes] = distributionItem(indexes, vipNum, perShare, totalShare);
        indexes = indexes.add(1);
        distributionAmount = distributionAmount.add(totalShare);
    }


    function claim(uint256 _distributionIndex) external {
        require(vipIndexList[msg.sender] < distributionList[_distributionIndex].maxTokenId, "e001");
        require(!ClaimStatusList[_distributionIndex][msg.sender], "e002");
        IERC20(erc20Token).safeTransfer(msg.sender, distributionList[_distributionIndex].pershare);
        ClaimStatusList[_distributionIndex][msg.sender] = true;
        claimedAmount = claimedAmount.add(distributionList[_distributionIndex].pershare);
        userClaimedAmountList[msg.sender] = userClaimedAmountList[msg.sender].add(distributionList[_distributionIndex].pershare);
    }

    function takeToken(uint256 _amount, address _token, address _account) internal {
        uint256 takeAmount;
        if (_amount == 0) {
            takeAmount = _token == address(0) ? address(this).balance : IERC20(_token).balanceOf(address(this));
        } else {
            takeAmount = _amount;
        }
        require(takeAmount > 0, "takeAmount should above zero");
        if (_token == address(0)) {
            payable(_account).transfer(takeAmount);
        } else {
            IERC20(_token).safeTransfer(_account, takeAmount);
        }
    }

    function takeErc20Token(uint256 _amount) external onlyOwner {
        takeToken(_amount, erc20Token, msg.sender);
    }

    function takeAnyToken(uint256 _amount, address _token) external onlyOwner {
        takeToken(_amount, _token, msg.sender);
    }

    function getDistributionItemList(uint256[] memory _indexList) external view returns (distributionItem[] memory distributionList_) {
        distributionList_ = new distributionItem[](_indexList.length);
        for (uint256 i = 0; i < _indexList.length; i++) {
            distributionList_[i] = distributionList[_indexList[i]];
        }
    }

    function getAllDistributionItemList() public view returns (distributionItem[] memory distributionList_) {
        distributionList_ = new distributionItem[](indexes);
        for (uint256 i = 0; i < indexes; i++) {
            distributionList_[i] = distributionList[i];
        }
    }

    function getUserInfo(address _user) public view returns (uint256 userClaimedAmount, bool isVip, uint256 index, bool[] memory if_claimed, bool[] memory can_claim) {
        userClaimedAmount = userClaimedAmountList[_user];
        isVip = vipSet.contains(_user);
        index = vipIndexList[_user];
        if_claimed = new bool[](indexes);
        can_claim = new bool[](indexes);
        for (uint256 i = 0; i < indexes; i++) {
            if (isVip) {
                if_claimed[i] = ClaimStatusList[i][_user];
                can_claim[i] = index < distributionList[i].maxTokenId;
            } else {
                if_claimed[i] = false;
                can_claim[i] = false;
            }
        }
    }

    function getAlldata(address _user) external view returns (dataItem memory baseInfo,uint256 userClaimedAmount, bool isVip, uint256 index, bool[] memory if_claimed, bool[] memory can_claim, distributionItem[] memory distributionList_) {
        (userClaimedAmount, isVip, index, if_claimed, can_claim) = getUserInfo(_user);
        distributionList_ = getAllDistributionItemList();
        baseInfo.balance = erc20Token == address(0) ? address(this).balance : IERC20(erc20Token).balanceOf(address(this));
        baseInfo.distributionAmount = distributionAmount;
        baseInfo.claimedAmount = claimedAmount;
        baseInfo.vipNum = vipNum;
    }

    receive() payable external {}
}