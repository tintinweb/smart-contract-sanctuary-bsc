/**
 *Submitted for verification at BscScan.com on 2023-01-28
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.8.7;

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

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "e003");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "e004");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "e005");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "e006");
        uint256 c = a / b;
        return c;
    }
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success,) = recipient.call{value : amount}("");
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

        (bool success, bytes memory returndata) = target.call{value : value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
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

library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, 'e0');
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), 'e1');
        }
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

interface IERC721 {
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function balanceOf(address owner) external view returns (uint256 balance);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
}

contract nftStaking is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeBEP20 for IERC20;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    struct poolInfo0 {
        IERC20 rewardToken;
        IERC721 nftToken;
    }

    struct poolInfo1 {
        bool limitWithdrawTime;
        bool pool_status;
        bool updatePool;
    }

    struct poolInfo2 {
        uint256 lastRewardBlock;
        uint256 accCakePerShare;
        uint256 stakingPeriod;
        uint256 startBlock;
        uint256 bonusEndBlock;
        uint256 rewardPerBlockPerToken;
    }

    struct PoolInfoItem {
        uint256 pid;
        poolInfo0 tokensList;
        poolInfo1 statusList;
        poolInfo2 poolConfigList;
    }

    address public devaddr;
    uint256 public BONUS_MULTIPLIER = 1;
    uint256 public poolLength = 0;
    mapping(uint256 => PoolInfoItem) public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    bool public limitGetRewardTime = false;
    bool public useWhiteList = false;

    mapping(uint256 => mapping(address => uint256)) public staking_time;
    mapping(uint256 => mapping(address => uint256)) public unlock_time;
    mapping(uint256 => mapping(address => uint256)) public getReward_time;
    mapping(uint256 => uint256) public stakingNumForPool;
    mapping(uint256 => mapping(address => uint256)) public pending_list;
    mapping(uint256 => mapping(address => uint256)) public allrewardList;
    mapping(address => bool) public white_list;
    mapping(uint256 => mapping(address => EnumerableSet.UintSet)) private userStakingTokenForPoolIdListSet;
    mapping(address => EnumerableSet.UintSet) private userStakingTokenIdListSet;
    mapping(address => bool) public depositProxyList;
    //EnumerableSet.AddressSet private stakingAddress;

    //event depositEvent(uint256 _time, address _user, uint256 _pid, uint256 _depositAmount, uint256[] _tokenIdList);
    //event withdrawEvent(uint256 _time, address _user, uint256 _pid, uint256 _withdrawAmount, uint256[] _tokenIdList);
    //event getRewardEvent(uint256 _time, address _user, uint256 _pid, uint256 _rewardAmount);

    event AllEvent(uint256 _time, address _user, uint256 _pid, string _type, uint256 _amount, uint256[] _tokenIdList);
    event safeCakeTransferEvent(IERC20 _rewardToken, address _to, uint256 _amount, uint256 cakeBalance);

    constructor()  {
        devaddr = msg.sender;
    }

    function setDepositProxyList(address[] memory _addressList, bool _status) external onlyOwner {
        for (uint256 i = 0; i < _addressList.length; i++) {
            depositProxyList[_addressList[i]] = _status;
        }
    }

    function setLimitGetRewardTime(bool _limitGetRewardTime) external onlyOwner {
        limitGetRewardTime = _limitGetRewardTime;
    }

    function setUseWhiteList(bool _useWhiteList) external onlyOwner {
        useWhiteList = _useWhiteList;
    }

    function setWhiteList(address[] memory _address_list) external onlyOwner {
        for (uint256 i = 0; i < _address_list.length; i++) {
            white_list[_address_list[i]] = true;
        }
    }

    function removeWhiteList(address[] memory _address_list) external onlyOwner {
        for (uint256 i = 0; i < _address_list.length; i++) {
            white_list[_address_list[i]] = false;
        }
    }

    function updateMultiplier(uint256 multiplierNumber) external onlyOwner {
        BONUS_MULTIPLIER = multiplierNumber;
    }

    function addPool(
        IERC721 _nftToken,
        bool _limitWithdrawTime,
        uint256 _stakingPeriod,
        uint256 _startBlock,
        uint256 _bonusEndBlock,
        IERC20 _rewardToken,
        bool _updatePool,
        uint256 _rewardPerBlockPerToken
    ) external onlyOwner {
        if (_updatePool) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.timestamp > _startBlock ? block.timestamp : _startBlock;
        PoolInfoItem memory poolItem = (new PoolInfoItem[](1))[0];
        poolItem.pid = poolLength;
        poolItem.tokensList = poolInfo0({
        rewardToken : _rewardToken,
        nftToken : _nftToken
        });
        poolItem.statusList = poolInfo1({
        limitWithdrawTime : _limitWithdrawTime,
        pool_status : true,
        updatePool : _updatePool
        });
        poolItem.poolConfigList = poolInfo2({
        lastRewardBlock : lastRewardBlock,
        accCakePerShare : 0,
        stakingPeriod : _stakingPeriod,
        startBlock : _startBlock,
        bonusEndBlock : _bonusEndBlock,
        rewardPerBlockPerToken : _rewardPerBlockPerToken
        });
        poolInfo[poolLength] = poolItem;
        poolLength = poolLength.add(1);
    }

    function setPoolLock(uint256 _pid, bool _limitWithdrawTime, uint256 _stakingPeriod) external onlyOwner {
        updatePool(_pid);
        poolInfo[_pid].statusList.limitWithdrawTime = _limitWithdrawTime;
        poolInfo[_pid].poolConfigList.stakingPeriod = _stakingPeriod;
    }

    function setPoolTimeLine(uint256 _pid, uint256 _startBlock, uint256 _bonusEndBlock) external onlyOwner {
        updatePool(_pid);
        poolInfo[_pid].poolConfigList.startBlock = _startBlock;
        poolInfo[_pid].poolConfigList.bonusEndBlock = _bonusEndBlock;
    }

    function setFixedList(uint256 _pid, uint256 _rewardPerBlockPerToken) external onlyOwner {
        massUpdatePools();
        poolInfo[_pid].poolConfigList.rewardPerBlockPerToken = _rewardPerBlockPerToken;
    }

    function enablePool(uint256 _pid) external onlyOwner {
        updatePool(_pid);
        poolInfo[_pid].statusList.pool_status = true;
    }

    function disablePool(uint256 _pid) external onlyOwner {
        updatePool(_pid);
        poolInfo[_pid].statusList.pool_status = false;
    }

    function getMultiplier(uint256 _pid, uint256 _from, uint256 _to) public view returns (uint256) {
        uint256 bonusEndBlock = poolInfo[_pid].poolConfigList.bonusEndBlock;
        uint256 fromBlock = poolInfo[_pid].poolConfigList.startBlock;
        if (!poolInfo[_pid].statusList.pool_status || block.timestamp < fromBlock) {
            return 0;
        }
        if (_to <= bonusEndBlock) {
            return _to - _from;
        } else if (_from >= bonusEndBlock) {
            return 0;
        } else {
            return bonusEndBlock - _from;
        }
    }

    function pendingCake(uint256 _pid, address _user) public view returns (uint256) {
        PoolInfoItem storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accCakePerShare = pool.poolConfigList.accCakePerShare;
        uint256 lpSupply = stakingNumForPool[_pid];
        if (block.timestamp > pool.poolConfigList.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(_pid, pool.poolConfigList.lastRewardBlock, block.timestamp);
            uint256 cakeReward;
            uint256 rewardAmount = (pool.poolConfigList.rewardPerBlockPerToken).mul(lpSupply);
            cakeReward = multiplier.mul(rewardAmount);
            accCakePerShare = accCakePerShare.add(cakeReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accCakePerShare).div(1e12).sub(user.rewardDebt);
    }

    function updatePool(uint256 _pid) public {
        PoolInfoItem storage pool = poolInfo[_pid];
        if (block.timestamp <= pool.poolConfigList.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = stakingNumForPool[_pid];
        if (lpSupply == 0) {
            pool.poolConfigList.lastRewardBlock = block.timestamp;
            return;
        }
        uint256 multiplier = getMultiplier(_pid, pool.poolConfigList.lastRewardBlock, block.timestamp);
        uint256 cakeReward;
        uint256 rewardAmount = (pool.poolConfigList.rewardPerBlockPerToken).mul(lpSupply);
        cakeReward = multiplier.mul(rewardAmount);
        pool.poolConfigList.accCakePerShare = pool.poolConfigList.accCakePerShare.add(cakeReward.mul(1e12).div(lpSupply));
        pool.poolConfigList.lastRewardBlock = block.timestamp;
    }

    function massUpdatePools() public {
        for (uint256 pid = 0; pid < poolLength; pid++) {
            updatePool(pid);
        }
    }

    function isContract(address _address) public view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_address)
        }
        return size > 0;
    }

    function deposit(uint256 _pid, uint256[] memory _tokenIdList) external {
        address _proxy = address(0);
        depositByUser(_proxy, msg.sender, _pid, _tokenIdList);
    }

    function depositAll(uint256 _pid) external {
        address _proxy = address(0);
        uint256 balance = poolInfo[_pid].tokensList.nftToken.balanceOf(msg.sender);
        uint256[] memory tokenIdList = new uint256[](balance);
        for (uint256 i = 0; i < balance; i++) {
            tokenIdList[i] = poolInfo[_pid].tokensList.nftToken.tokenOfOwnerByIndex(msg.sender, i);
        }
        depositByUser(_proxy, msg.sender, _pid, tokenIdList);
    }

    modifier onlyProxyList() {
        require(depositProxyList[_msgSender()], "e001");
        _;
    }

    function depositByProxy(address _user, uint256 _pid, uint256[] memory _tokenIdList) external onlyProxyList {
        address _proxy = msg.sender;
        depositByUser(_proxy, _user, _pid, _tokenIdList);
    }

    function depositByUser(address _proxy, address _user, uint256 _pid, uint256[] memory _tokenIdList) internal {
        updatePool(_pid);
        require(poolInfo[_pid].statusList.pool_status, "e4");
        PoolInfoItem storage pool = poolInfo[_pid];
        require(block.timestamp >= pool.poolConfigList.startBlock || block.timestamp <= pool.poolConfigList.bonusEndBlock, "e5");
        UserInfo storage user = userInfo[_pid][_user];
        address fromAddress;
        if (_proxy == address(0)) {
            fromAddress = _user;
        } else {
            fromAddress = _proxy;
        }

        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.poolConfigList.accCakePerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                pending_list[_pid][_user] = pending_list[_pid][_user].add(pending);
            }
        }
        uint256 _depositAmount = _tokenIdList.length;
        if (_depositAmount > 0) {
            for (uint256 i = 0; i < _depositAmount; i++) {
                uint256 _tokenId = _tokenIdList[i];
                pool.tokensList.nftToken.transferFrom(fromAddress, address(this), _tokenId);
                userStakingTokenForPoolIdListSet[_pid][_user].add(_tokenId);
            }
            stakingNumForPool[_pid] = stakingNumForPool[_pid].add(_depositAmount);
            user.amount = user.amount.add(_depositAmount);
            unlock_time[_pid][_user] = pool.poolConfigList.bonusEndBlock;
            staking_time[_pid][_user] = block.timestamp;
        }
        user.rewardDebt = user.amount.mul(pool.poolConfigList.accCakePerShare).div(1e12);
        if (getReward_time[_pid][_user] == 0) {
            getReward_time[_pid][_user] = block.timestamp;
        }
        //emit depositEvent(block.timestamp, _user, _pid, _tokenIdList.length, _tokenIdList);
        emit AllEvent(block.timestamp, _user, _pid, "_deposit", _tokenIdList.length, _tokenIdList);
    }

    function withdraw(uint256 _pid, uint256[] memory _tokenIdList, address _to) public {
        address _user = msg.sender;
        updatePool(_pid);
        if (poolInfo[_pid].statusList.limitWithdrawTime) {
            if (!useWhiteList) {
                require(block.timestamp >= unlock_time[_pid][msg.sender] || block.timestamp >= poolInfo[_pid].poolConfigList.bonusEndBlock || !poolInfo[_pid].statusList.pool_status, "e10");
            } else {
                if (!white_list[msg.sender]) {
                    require(block.timestamp >= unlock_time[_pid][msg.sender] || block.timestamp >= poolInfo[_pid].poolConfigList.bonusEndBlock, "e11");
                }
            }
        }
        PoolInfoItem storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 pending = user.amount.mul(pool.poolConfigList.accCakePerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            pending_list[_pid][_user] = pending_list[_pid][_user].add(pending);
        }
        uint256 _withdrawAmount = _tokenIdList.length;
        for (uint256 i = 0; i < _withdrawAmount; i++) {
            uint256 _tokenId = _tokenIdList[i];
            pool.tokensList.nftToken.transferFrom(address(this), _to, _tokenId);
            require(userStakingTokenForPoolIdListSet[_pid][_user].contains(_tokenId));
            userStakingTokenForPoolIdListSet[_pid][_user].remove(_tokenId);
        }
        user.amount = user.amount.sub(_withdrawAmount);
        stakingNumForPool[_pid] = stakingNumForPool[_pid].sub(_withdrawAmount);
        user.rewardDebt = user.amount.mul(pool.poolConfigList.accCakePerShare).div(1e12);
        //emit withdrawEvent(block.timestamp, _user, _pid, _tokenIdList.length, _tokenIdList);
        emit AllEvent(block.timestamp, _user, _pid, "_withdraw", _tokenIdList.length, _tokenIdList);
    }

    function withdrawAll(uint256 _pid, address _to) external nonReentrant {
        uint256[] memory _tokenIdList = userStakingTokenForPoolIdListSet[_pid][msg.sender].values();
        withdraw(_pid, _tokenIdList, _to);
    }

    function _getReward(uint256 _pid, address _user) private {
        updatePool(_pid);
        PoolInfoItem storage pool = poolInfo[_pid];
        if (limitGetRewardTime) {
            if (!useWhiteList) {
                require(block.timestamp > unlock_time[_pid][_user] || block.timestamp >= poolInfo[_pid].poolConfigList.bonusEndBlock || !poolInfo[_pid].statusList.pool_status, "e7");
            } else {
                if (!white_list[_user]) {
                    require(block.timestamp > unlock_time[_pid][_user] || block.timestamp >= poolInfo[_pid].poolConfigList.bonusEndBlock || !poolInfo[_pid].statusList.pool_status, "e8");
                }
            }
        }
        UserInfo storage user = userInfo[_pid][_user];
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.poolConfigList.accCakePerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                pending_list[_pid][_user] = pending_list[_pid][_user].add(pending);
            }
        }
        user.rewardDebt = user.amount.mul(pool.poolConfigList.accCakePerShare).div(1e12);
        if (pending_list[_pid][_user] > 0) {
            uint256 allAmount = pending_list[_pid][_user];
            allrewardList[_pid][_user] = allrewardList[_pid][_user].add(allAmount);
            //emit getRewardEvent(block.timestamp, _user, _pid, allAmount);
            emit AllEvent(block.timestamp, _user, _pid, "_getReward", allAmount, new uint256[](0));
            safeTokenTransfer(pool.tokensList.rewardToken, _user, allAmount);
            pending_list[_pid][_user] = 0;
        }
        getReward_time[_pid][_user] = block.timestamp;
    }

    function getReward(uint256 _pid) external nonReentrant {
        _getReward(_pid, msg.sender);
    }

    function massGetReward() external nonReentrant {
        address _user = msg.sender;
        for (uint256 _pid = 0; _pid < poolLength; _pid++) {
            if (userInfo[_pid][_user].amount > 0 || pending_list[_pid][_user] > 0) {
                _getReward(_pid, msg.sender);
            }
        }
    }

    function safeTokenTransfer(IERC20 _rewardToekn, address _to, uint256 _amount) internal {
        uint256 cakeBalance = _rewardToekn.balanceOf(address(this));
        if (_amount > cakeBalance) {
            _rewardToekn.transfer(_to, cakeBalance);
        } else {
            _rewardToekn.transfer(_to, _amount);
        }
        emit safeCakeTransferEvent(_rewardToekn, _to, _amount, cakeBalance);
    }

    function setdev(address _devaddr) external {
        require(msg.sender == devaddr || msg.sender == owner(), "e18");
        devaddr = _devaddr;
    }

    struct getInfoForUserItem {
        PoolInfoItem poolinfo;
        UserInfo userinfo;
        uint256 unlockTime;
        uint256 stakingTime;
        uint256 pendingAmount;
        uint256 pendingCake;
        uint256 allPendingReward;
        uint256 stakingNumAll;
        uint256 allreward;
        uint256 nftBalance;
        uint256[] tokenIdList;
        uint256[] tokenIdListForPool;
        uint256 rewardTokenPerBlock;
        bool limitGetRewardTime;
        bool limitWithdrawTime;
        bool useWhiteList;
        bool isInWhiteList;
    }

    function getInfoForUser(uint256 _pid, address _user) public view returns (getInfoForUserItem memory getInfoForUserInfo) {
        getInfoForUserInfo.poolinfo = poolInfo[_pid];
        getInfoForUserInfo.userinfo = userInfo[_pid][_user];
        getInfoForUserInfo.unlockTime = unlock_time[_pid][_user];
        getInfoForUserInfo.stakingTime = staking_time[_pid][_user];
        getInfoForUserInfo.pendingAmount = pending_list[_pid][_user];
        uint256 pending = pendingCake(_pid, _user);
        getInfoForUserInfo.pendingCake = pending;
        getInfoForUserInfo.allPendingReward = pending_list[_pid][_user].add(pending);
        getInfoForUserInfo.stakingNumAll = stakingNumForPool[_pid];
        getInfoForUserInfo.allreward = allrewardList[_pid][_user];
        uint256 balance = poolInfo[_pid].tokensList.nftToken.balanceOf(_user);
        getInfoForUserInfo.nftBalance = balance;
        uint256[] memory tokenIdList = new uint256[](balance);
        for (uint256 i = 0; i < balance; i++) {
            tokenIdList[i] = poolInfo[_pid].tokensList.nftToken.tokenOfOwnerByIndex(_user, i);
        }
        getInfoForUserInfo.tokenIdList = tokenIdList;
        getInfoForUserInfo.tokenIdListForPool = userStakingTokenForPoolIdListSet[_pid][_user].values();
        getInfoForUserInfo.limitGetRewardTime = limitGetRewardTime;
        getInfoForUserInfo.limitWithdrawTime = poolInfo[_pid].statusList.limitWithdrawTime;
        getInfoForUserInfo.useWhiteList = useWhiteList;
        getInfoForUserInfo.isInWhiteList = white_list[_user];
    }

    function MassGetInfoForUser(address _user) external view returns (getInfoForUserItem[] memory getInfoForUserInfoList) {
        getInfoForUserInfoList = new getInfoForUserItem[](poolLength);
        for (uint256 i = 0; i < poolLength; i++) {
            getInfoForUserInfoList[i] = getInfoForUser(i, _user);
        }
    }

    function getErc20Token(IERC20 _token, uint256 _amount) external onlyOwner {
        safeTokenTransfer(_token, msg.sender, _amount);
    }
}