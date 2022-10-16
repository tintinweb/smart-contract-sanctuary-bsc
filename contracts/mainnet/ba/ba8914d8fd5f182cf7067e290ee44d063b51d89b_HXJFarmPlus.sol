/**
 *Submitted for verification at BscScan.com on 2022-10-16
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'e0');
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'e0');
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, 'e0');
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'e0');
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}


interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}


library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'e0');
        (bool success,) = recipient.call{value : amount}('');
        require(success, 'e1');
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, 'e0');
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, 'e0');
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, 'e0');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'e0');
        (bool success, bytes memory returndata) = target.call{value : weiValue}(data);
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

contract Context {
    constructor() internal {}
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), 'e0');
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'e0');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface Token {
    function mint(address _to, uint256 _amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
}

interface IPair is IERC20 {
    function token0() external view returns (address);

    function token1() external view returns (address);
}

contract HXJFarmPlus is Ownable {
    using SafeMath for uint256;
    using SafeBEP20 for IERC20;
    using Address for address;
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    struct timeLineItem {
        uint256 startTime;
        uint256 endTime;
    }

    struct statusListItem {
        bool pool_status;
        bool limitGetReward;
        bool limitWithdraw;
    }

    struct fixedItem {
        bool useFixedMode;
        uint256 rewardPerBlockPerToken;
        uint256 maxAmount;
    }

    struct PoolInfo {
        IERC20 lpToken;
        uint256 rewardRate;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accCakePerShare;
        uint256 staking_stock_length;
        uint256 stakingFee;
        uint256 withdrawFee;
        uint256 getRewardFee;
        uint256 allAmount;
        statusListItem statusList;
        timeLineItem timeLine;
        fixedItem fixedList;
    }

    Token public cake;
    address deadAddress = 0x000000000000000000000000000000000000dEaD;
    address public devAddress;
    uint256 public cakePerBlock;
    uint256 public BONUS_MULTIPLIER = 1;
    uint256 public poolLength = 0;
    mapping(uint256 => PoolInfo) public  poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint = 0;

    event Deposit(address user, uint256 pid, uint256 amount, uint256 time, address rerferer);
    event Withdraw(address user, uint256 pid, uint256 amount, uint256 time, address rerferer);
    event GetReward(address user, uint256 pid, uint256 amount, uint256 time, address rerferer);
    event EmergencyWithdraw(address user, uint256 pid, uint256 amount, uint256 time, address rerferer);

    mapping(uint256 => mapping(address => uint256)) public first_staking_time;
    mapping(uint256 => mapping(address => uint256)) public last_staking_time;
    mapping(uint256 => mapping(address => uint256)) public pending_list;

    mapping(address => address) public refererAddressList;
    mapping(address => uint256) public refererTimeList;
    mapping(uint256=>uint256) public allGetRewardFeeList;

    mapping(address => bool) public white_list;
    bool public useMintMode = false;
    bool public useMintStrictMode = false;
    bool public canClaim = false;

    constructor (address _devaddr) public {
        devAddress = _devaddr;
        white_list[msg.sender] = true;
        white_list[_devaddr] = true;
        totalAllocPoint = 0;
        refererAddressList[deadAddress] = msg.sender;
        refererAddressList[msg.sender] = msg.sender;
        refererTimeList[msg.sender] = block.timestamp;
    }

    function setCanClaim(bool _canClaim) external onlyOwner {
        canClaim = _canClaim;
    }

    function setDevAddress(address _devAddress) external onlyOwner {
        devAddress = _devAddress;
    }

    function setMintMode(bool _useMintMode, bool _useMintStrictMode) external onlyOwner {
        useMintMode = _useMintMode;
        useMintStrictMode = _useMintStrictMode;
    }

    function setWhiteList(address[] memory _address_list) public onlyOwner {
        for (uint256 i = 0; i < _address_list.length; i++) {
            white_list[_address_list[i]] = true;
        }
    }

    function removeWhiteList(address[] memory _address_list) public onlyOwner {
        for (uint256 i = 0; i < _address_list.length; i++) {
            white_list[_address_list[i]] = false;
        }
    }

    function setCakePerBlockAndCake(bool _withUpdate, uint256 _cakePerBlock, Token _cake) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        cake = _cake;
        cakePerBlock = _cakePerBlock;
    }

    function updateMultiplier(uint256 multiplierNumber) public onlyOwner {
        BONUS_MULTIPLIER = multiplierNumber;
    }

    function addPool(
        uint256 _allocPoint,
        IERC20 _lpToken,
        bool _withUpdate,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _staking_stock_length,
        uint256[] memory _stakingFee_withdrawFee_getRewardFee_rewardRate,
        bool _limitGetReward,
        bool _limitWithdraw,
        bool _fixedList_useFixedMode,
        uint256 _fixedList_rewardPerBlockPerToken,
        uint256 _fixedList_maxAmount
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        if (!_fixedList_useFixedMode) {
            totalAllocPoint = totalAllocPoint.add(_allocPoint);
        }
        PoolInfo memory x = new PoolInfo[](1)[0];
        x.lpToken = _lpToken;
        x.allocPoint = _allocPoint;
        x.timeLine.startTime = _startTime;
        x.timeLine.endTime = _endTime;
        x.lastRewardBlock = block.timestamp > _startTime ? block.timestamp : _startTime;
        x.accCakePerShare = 0;
        x.staking_stock_length = _staking_stock_length;
        x.stakingFee = _stakingFee_withdrawFee_getRewardFee_rewardRate[0];
        x.withdrawFee = _stakingFee_withdrawFee_getRewardFee_rewardRate[1];
        x.getRewardFee = _stakingFee_withdrawFee_getRewardFee_rewardRate[2];
        x.rewardRate =  _stakingFee_withdrawFee_getRewardFee_rewardRate[3];
        x.allAmount = 0;
        x.statusList.pool_status = true;
        x.statusList.limitGetReward = _limitGetReward;
        x.statusList.limitWithdraw = _limitWithdraw;
        x.fixedList.useFixedMode = _fixedList_useFixedMode;
        x.fixedList.rewardPerBlockPerToken = _fixedList_rewardPerBlockPerToken;
        x.fixedList.maxAmount = _fixedList_maxAmount;
        poolInfo[poolLength] = x;
        poolLength = poolLength.add(1);
    }

    function setFixedList(uint256 _pid, bool _useFixedMode, uint256 _rewardPerBlockPerToken, uint256 _maxAmount) external {
        massUpdatePools();
        if (poolInfo[_pid].fixedList.useFixedMode && _useFixedMode == false) {
            totalAllocPoint = totalAllocPoint.add(poolInfo[_pid].allocPoint);
        }
        if (!poolInfo[_pid].fixedList.useFixedMode && _useFixedMode) {
            totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint);
        }
        poolInfo[_pid].fixedList.useFixedMode = _useFixedMode;
        poolInfo[_pid].fixedList.rewardPerBlockPerToken = _rewardPerBlockPerToken;
        poolInfo[_pid].fixedList.maxAmount = _maxAmount;
    }

    function setPoolTimeLine(uint256 _pid, uint256 _startTime, uint256 _endTime) public onlyOwner {
        updatePool(_pid);
        poolInfo[_pid].timeLine.startTime = _startTime;
        poolInfo[_pid].timeLine.endTime = _endTime;
    }

    function setPoolFees(uint256 _pid, uint256 _stakingFee, uint256 _withdrawFee,uint256 _getRewardFee,uint256 _rewardRate) external onlyOwner {
        poolInfo[_pid].stakingFee = _stakingFee;
        poolInfo[_pid].withdrawFee = _withdrawFee;
        poolInfo[_pid].getRewardFee = _getRewardFee;
        poolInfo[_pid].rewardRate = _rewardRate;
    }

    function takeWrongToken(IERC20 _token, uint256 _amount) external onlyOwner {
        _token.transfer(msg.sender, _amount);
    }

    function setPoolAllocPoint(uint256 _pid, uint256 _allocPoint) external onlyOwner {
        massUpdatePools();
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function setPoolLimitWithdraw(uint256 _pid, bool _limitGetReward, bool _limitWithdraw) external onlyOwner {
        updatePool(_pid);
        poolInfo[_pid].statusList.limitGetReward = _limitGetReward;
        poolInfo[_pid].statusList.limitWithdraw = _limitWithdraw;
    }

    function setPoolLockTime(uint256 _pid, uint256 _staking_stock_length) external onlyOwner {
        updatePool(_pid);
        poolInfo[_pid].staking_stock_length = _staking_stock_length;
    }

    function setPoolStatus(uint256 _pid, bool _status) public onlyOwner {
        updatePool(_pid);
        poolInfo[_pid].statusList.pool_status = _status;
    }

    function getMultiplier(uint256 _pid, uint256 _from, uint256 _to) public view returns (uint256) {
        if (!poolInfo[_pid].statusList.pool_status) {
            return 0;
        } else {
            if (_to <= poolInfo[_pid].timeLine.endTime) {
                return _to.sub(_from);
            } else if (_from >= poolInfo[_pid].timeLine.endTime) {
                return 0;
            } else {
                return poolInfo[_pid].timeLine.endTime.sub(_from);
            }
        }
    }

    function pendingCake(uint256 _pid, address _user) public view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accCakePerShare = pool.accCakePerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.timestamp > pool.lastRewardBlock && lpSupply != 0) {
            uint256 cakeReward;
            uint256 multiplier = getMultiplier(_pid, pool.lastRewardBlock, block.timestamp);
            if (pool.fixedList.useFixedMode) {
                uint256 rewardAmount = (pool.fixedList.rewardPerBlockPerToken).mul(lpSupply).div(1e18);
                cakeReward = multiplier.mul(rewardAmount);
            } else {
                cakeReward = multiplier.mul(cakePerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            }
            accCakePerShare = accCakePerShare.add(cakeReward.mul(1e12).div(lpSupply));
        }
        return ((user.amount.mul(accCakePerShare).div(1e12).sub(user.rewardDebt)).add(pending_list[_pid][_user]));
    }

    function massUpdatePools() public {
        for (uint256 pid = 0; pid < poolLength; ++pid) {
            updatePool(pid);
        }
    }

    // function updatePool(uint256 _pid) public {
    //     PoolInfo storage pool = poolInfo[_pid];
    //     if (block.timestamp <= pool.lastRewardBlock) {
    //         return;
    //     }
    //     uint256 lpSupply = pool.allAmount;
    //     if (lpSupply == 0) {
    //         pool.lastRewardBlock = block.timestamp;
    //         return;
    //     }
    //     uint256 multiplier = getMultiplier(_pid, pool.lastRewardBlock, block.timestamp);
    //     uint256 cakeReward = multiplier.mul(cakePerBlock).mul(pool.allocPoint).div(totalAllocPoint);
    //     if (useMintMode) {
    //         if (useMintStrictMode) {
    //             cake.mint(address(this), cakeReward);
    //         }
    //         else {
    //             try cake.mint(address(this), cakeReward){} catch {}
    //         }
    //     }
    //     pool.accCakePerShare = pool.accCakePerShare.add(cakeReward.mul(1e12).div(lpSupply));
    //     pool.lastRewardBlock = block.timestamp;
    // }

    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.timestamp <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.allAmount;
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.timestamp;
            return;
        }
        uint256 multiplier = getMultiplier(_pid, pool.lastRewardBlock, block.timestamp);
        // uint256 rewardAmount = cakePerBlock.mul(lpSupply).div(1e18);
        // uint256 cakeReward = multiplier.mul(rewardAmount).mul(pool.allocPoint).div(totalAllocPoint);
        uint256 cakeReward;
        if (pool.fixedList.useFixedMode) {
            uint256 rewardAmount = (pool.fixedList.rewardPerBlockPerToken).mul(lpSupply).div(1e18);
            cakeReward = multiplier.mul(rewardAmount);
        } else {
            cakeReward = multiplier.mul(cakePerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        }

        if (useMintMode) {
            if (useMintStrictMode) {
                cake.mint(address(this), cakeReward);
            }
            else {
                try cake.mint(address(this), cakeReward){} catch {}
            }
        }
        pool.accCakePerShare = pool.accCakePerShare.add(cakeReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.timestamp;
    }


    function blindReferer(address _referer) external {
        _blindReferer(msg.sender, _referer);
    }

    function _blindReferer(address _user, address _referer) internal {
        require(!_referer.isContract(), "k001");
        require(_referer != address(0), "k002");
        require(refererAddressList[_referer] != address(0), "ke003");
        require(refererAddressList[_user] == address(0), "k004");
        refererAddressList[_user] = _referer;
        refererTimeList[_user] = block.timestamp;
    }

    function deposit(uint256 _pid, uint256 _amount, address _referer) external {
        if (refererAddressList[msg.sender] == address(0)) {
            _blindReferer(msg.sender, _referer);
        }
        PoolInfo storage pool = poolInfo[_pid];
        if (pool.fixedList.useFixedMode) {
            require(poolInfo[_pid].allAmount.add(_amount) <= pool.fixedList.maxAmount, "e001");
        }
        require(block.timestamp >= pool.timeLine.startTime, "e001");
        require(poolInfo[_pid].statusList.pool_status == true, "e002");
        if (first_staking_time[_pid][msg.sender] == 0) {
            first_staking_time[_pid][msg.sender] = block.timestamp;
        }
        last_staking_time[_pid][msg.sender] = block.timestamp;
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accCakePerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                pending_list[_pid][msg.sender] = pending_list[_pid][msg.sender].add(pending);
            }
        }
        if (_amount > 0) {
            uint256 fee = white_list[msg.sender] ? 0 : _amount.mul(pool.stakingFee).div(100);
            uint256 left = _amount.sub(fee);
            if (fee > 0) {
                pool.lpToken.safeTransferFrom(address(msg.sender), devAddress, fee);
            }
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), left);
            user.amount = user.amount.add(left);
            poolInfo[_pid].allAmount = poolInfo[_pid].allAmount.add(left);
        }
        user.rewardDebt = user.amount.mul(pool.accCakePerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount, block.timestamp, refererAddressList[msg.sender]);
    }

    function getReward(uint256 _pid) external {
        require(canClaim,"e000");
        PoolInfo storage pool = poolInfo[_pid];
        if (!white_list[msg.sender] && pool.statusList.limitGetReward) {
            require(block.timestamp > last_staking_time[_pid][msg.sender] + pool.staking_stock_length || block.timestamp >= pool.timeLine.endTime, "e001");
        }
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accCakePerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                pending_list[_pid][msg.sender] = pending_list[_pid][msg.sender].add(pending);
            }
        }
        user.rewardDebt = user.amount.mul(pool.accCakePerShare).div(1e12);
        require(pending_list[_pid][msg.sender] > 0, "e002");
        uint256 allAmount = pending_list[_pid][msg.sender];
        emit GetReward(msg.sender, _pid, allAmount, block.timestamp, refererAddressList[msg.sender]);
        uint256 rewardAmout = allAmount.mul(pool.rewardRate).div(100);
        uint256 letAmount = allAmount.sub(rewardAmout);
        address _referer = refererAddressList[msg.sender];
        if (rewardAmout > 0) {
            if (_referer == address(0) || _referer == deadAddress) {
                safeCakeTransfer(devAddress, rewardAmout);
            } else {
                safeCakeTransfer(_referer, rewardAmout);
            }
        }
        safeCakeTransfer(msg.sender, letAmount);
        pending_list[_pid][msg.sender] = 0;
        if (poolInfo[_pid].getRewardFee>0) {
            uint256 getRewardFee = (userInfo[_pid][msg.sender].amount).mul(poolInfo[_pid].getRewardFee).div(100);
            userInfo[_pid][msg.sender].amount = (userInfo[_pid][msg.sender].amount).sub(getRewardFee);
            poolInfo[_pid].allAmount = poolInfo[_pid].allAmount.sub(getRewardFee);
            allGetRewardFeeList[_pid] = allGetRewardFeeList[_pid].add(getRewardFee);
            poolInfo[_pid].lpToken.transfer(devAddress,getRewardFee);
        }
    }

    function withdraw(uint256 _pid, uint256 _amount) external {
        PoolInfo storage pool = poolInfo[_pid];
        if (!white_list[msg.sender] && pool.statusList.limitWithdraw) {
            require(block.timestamp > last_staking_time[_pid][msg.sender] + pool.staking_stock_length || block.timestamp >= pool.timeLine.endTime, "e001");
        }
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "e002");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accCakePerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            pending_list[_pid][msg.sender] = pending_list[_pid][msg.sender].add(pending);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            uint256 fee = _amount.mul(pool.withdrawFee).div(100);
            uint256 left = _amount.sub(fee);
            if (fee > 0) {
                pool.lpToken.safeTransfer(devAddress, fee);
            }
            pool.lpToken.safeTransfer(address(msg.sender), left);
        }
        poolInfo[_pid].allAmount = poolInfo[_pid].allAmount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accCakePerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount, block.timestamp, refererAddressList[msg.sender]);
    }

    function emergencyWithdraw(uint256 _pid) external {
        PoolInfo storage pool = poolInfo[_pid];
        if (!white_list[msg.sender] && pool.statusList.limitWithdraw) {
            require(block.timestamp > last_staking_time[_pid][msg.sender] + pool.staking_stock_length || block.timestamp >= pool.timeLine.endTime, "e001");
        }
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 fee = user.amount.mul(pool.withdrawFee).div(100);
        uint256 left = user.amount.sub(fee);
        if (fee > 0) {
            pool.lpToken.safeTransfer(devAddress, fee);
        }
        pool.lpToken.safeTransfer(address(msg.sender), left);
        poolInfo[_pid].allAmount = poolInfo[_pid].allAmount.sub(user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, left, block.timestamp, refererAddressList[msg.sender]);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    function safeCakeTransfer(address _to, uint256 _amount) internal {
        uint256 cakeBal = cake.balanceOf(address(this));
        if (_amount > cakeBal) {
            cake.transfer(_to, cakeBal);
        } else {
            cake.transfer(_to, _amount);
        }
    }

    struct returnStruct {
        PoolInfo PoolInfo_;
        UserInfo UserInfo_;
        uint256 first_staking_time;
        uint256 last_staking_time;
        uint256 pending_list;
        uint256 pending_cake;
        bool isInWhiteList;
        TokenItem TokenItem_;
        address referer;
        uint256 refererTime;
        bool canClaim;
        uint256 allGetRewardFee;
    }

    function getUserInfo(uint256 _pid, address _user) public view returns (returnStruct memory userInfo_) {
        userInfo_.PoolInfo_ = poolInfo[_pid];
        userInfo_.UserInfo_ = userInfo[_pid][_user];
        userInfo_.TokenItem_ = getLpInfo(poolInfo[_pid].lpToken, _user);
        userInfo_.first_staking_time = first_staking_time[_pid][_user];
        userInfo_.last_staking_time = last_staking_time[_pid][_user];
        userInfo_.pending_list = pending_list[_pid][_user];
        userInfo_.pending_cake = pendingCake(_pid, _user);
        userInfo_.isInWhiteList = white_list[_user];
        userInfo_.referer = refererAddressList[_user];
        userInfo_.refererTime = refererTimeList[_user];
        userInfo_.canClaim = canClaim;
        userInfo_.allGetRewardFee = allGetRewardFeeList[_pid];
    }

    function massGetUserInfo(address _user) external view returns (returnStruct[] memory userInfoList_) {
        userInfoList_ = new returnStruct[](poolLength);
        for (uint256 i = 0; i < poolLength; i++) {
            userInfoList_[i] = getUserInfo(i, _user);
        }
    }

    struct TokenItem {
        uint256 balanceOf;
        uint256 decimals;
        uint256 totalSupply;
        string name;
        string symbol;
        address[] tokenList;
        string[] nameList;
        string[] symbolList;
        uint256[] decimalsList;
    }

    function getLpInfo(IERC20 _token, address _user) public view returns (TokenItem memory lpInfo) {
        uint256 balanceOf = _token.balanceOf(_user);
        address[] memory tokenList = new address[](2);
        string[] memory nameList = new string[](2);
        string[] memory symbolList = new string[](2);
        uint256[] memory decimalsList = new uint256[](2);
        try IPair(address(_token)).token0() returns (address token){
            address token0 = token;
            address token1 = IPair(address(_token)).token1();
            tokenList[0] = token0;
            tokenList[1] = token1;
            nameList[0] = IERC20(token0).name();
            nameList[1] = IERC20(token1).name();
            symbolList[0] = IERC20(token0).symbol();
            symbolList[1] = IERC20(token1).symbol();
            decimalsList[0] = IERC20(token0).decimals();
            decimalsList[1] = IERC20(token1).decimals();
        } catch {
        }
        lpInfo = TokenItem(balanceOf, _token.decimals(), _token.totalSupply(), _token.name(), _token.symbol(), tokenList, nameList, symbolList, decimalsList);
    }
}