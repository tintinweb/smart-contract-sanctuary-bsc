/**
 *Submitted for verification at BscScan.com on 2022-07-06
*/

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

pragma solidity ^0.8.0;

interface IERC20 {
 
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.8.0;

library SafeERC20 {
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

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity ^0.8.0;

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
interface IXPHP{
    function stake(address sender,uint256 amount) external ;
    function UnStake(address sender,uint256 amount) external ;
}

pragma solidity ^0.8.0;

contract phpMine is Ownable {
    using SafeERC20 for IERC20;
    struct PoolUser {
        uint256 amount;
        uint256 rewardDebt;
        uint256 remainingReward;
        uint256 startTime;
    }

    struct Pool {
        IERC20 token;
        uint256 amount;
        uint256 accUnits;
        uint256 lastRewardTime;
        uint256 allocPoint;
        uint256 feePoint;
        uint256 duration;
    }

    IERC20 immutable public retoken;

    uint256 public retokenPeS;

    Pool[] public pools;

    mapping(uint256 => mapping(address => PoolUser)) public poolUsers;

    uint256 public totalAllocPoint = 0;

    uint256 immutable public startTime;

    uint256 public endTime;

    address public feeAddress;

    IXPHP public xphp = IXPHP(0x6eb58E044B9Bc01eba3Fb5D9C129C6e01cCc4C94);
    mapping (uint256 => uint256) public maxMultiple;
    mapping (uint256 => uint256) public needXphp;
    mapping (address => mapping (uint256 => uint256)) public userXphp;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor() {
        retoken = IERC20(0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c);
        retokenPeS = 1000000000;
        startTime = block.timestamp;
        endTime = block.timestamp + 360 days;
        feeAddress = msg.sender;
    }
    function stakeXphp(uint256 _pid,uint256 amount)public{
        deposit(_pid,0);
        xphp.stake(msg.sender,amount);
        userXphp[msg.sender][_pid] = userXphp[msg.sender][_pid] + amount;
    }
    function unStakeXphp(uint256 _pid,uint256 amount)public{
        deposit(_pid,0);
        xphp.UnStake(msg.sender,amount);
        userXphp[msg.sender][_pid] = userXphp[msg.sender][_pid] - amount;
    }

    function getUserMultiple(uint256 _pid,address _user)public view returns(uint256 mt){
        PoolUser storage user = poolUsers[_pid][_user];
        if(user.amount > 0 && needXphp[_pid]  > 0 && userXphp[_user][_pid] > 0){
            uint256 bs = ((userXphp[_user][_pid] * (10 ** 18)) * 10000) / (user.amount * needXphp[_pid] );
            uint256 mx = maxMultiple[_pid] * 10000;
            mt = bs > mx ? mx : bs;
        }
        mt += 10000;
    }

    function needToMaxXphp(uint256 _pid,address _user)public view returns(uint256 mt){
        PoolUser storage user = poolUsers[_pid][_user];
        mt = (user.amount * needXphp[_pid] * maxMultiple[_pid] ) / (10 ** 18) ;
    }

    function changeNeedXphp(uint256 _pid,uint256 _nx) external onlyOwner{
        needXphp[_pid] = _nx;
    }

    function changeMaxMultiple(uint256 _pid,uint256 _maxM) external onlyOwner{
        maxMultiple[_pid] = _maxM;
    }

    function changeXphp(address _adr) external onlyOwner{
        xphp = IXPHP(_adr);
    }
    function setEndTime(uint256 _endTime) external onlyOwner{
        endTime = _endTime;
    } 
    function getTime()public view returns(uint256){
        return block.timestamp;
    }

    function addEndTime(uint256 _seconds) external onlyOwner {
        endTime += _seconds;
    }

    function setRetokenPeS(uint256 _retokenPeS, bool _withUpdate) external onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        retokenPeS = _retokenPeS;
    }

    function getPools() external view returns (Pool[] memory) {
        return pools;
    }

    function addPool(uint256 _allocPoint, IERC20 _token, uint256 _feePoint, uint256 _duration,bool _withUpdate) external onlyOwner {
        require(_feePoint <= 10000, "addPool: Out of basis fee points");
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardTime = block.timestamp > startTime ? block.timestamp : startTime;
        totalAllocPoint += _allocPoint;
        pools.push(Pool({token : _token, amount : 0, accUnits : 0, lastRewardTime : uint256(lastRewardTime), allocPoint : _allocPoint, feePoint : _feePoint,duration : _duration}));
    }

    function setPool(uint256 _pid, uint256 _allocPoint, uint256 _feePoint, uint256 _duration , bool _withUpdate) external onlyOwner {
        require(_feePoint <= 10000, "setPool: Out of basis fee points");
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint - pools[_pid].allocPoint + _allocPoint;
        pools[_pid].allocPoint = _allocPoint;
        pools[_pid].feePoint = _feePoint;
        pools[_pid].duration = _duration;
    }

    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256){
        _from = _from > startTime ? _from : startTime;
        if (_from > endTime || _to < startTime) {
            return 0;
        }
        if (_to > endTime) {
            return endTime - _from;
        }
        return _to - _from;
    }

    function pendingReward(uint256 _pid, address _user) external view returns (uint256){
        Pool storage pool = pools[_pid];
        PoolUser storage user = poolUsers[_pid][_user];
        uint256 accUnits = pool.accUnits;

        if (block.timestamp > pool.lastRewardTime && pool.amount != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardTime, block.timestamp);
            uint256 rewardAmount = multiplier * retokenPeS * pool.allocPoint / totalAllocPoint;
            accUnits += rewardAmount * 1e12 / pool.amount;
        }
        uint256 reward = user.amount * accUnits / 1e12 - user.rewardDebt + user.remainingReward;
        reward = reward * getUserMultiple(_pid,_user) / 10000 ;
        return reward;
    }

    function massUpdatePools() public {
        uint256 length = pools.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {
        Pool storage pool = pools[_pid];
        if (block.timestamp <= pool.lastRewardTime) {
            return;
        }
        if (pool.amount == 0) {
            pool.lastRewardTime = block.timestamp;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardTime, block.timestamp);
        uint256 rewardAmount = multiplier * retokenPeS * pool.allocPoint / totalAllocPoint;
        pool.accUnits += rewardAmount * 1e12 / pool.amount;
        pool.lastRewardTime = block.timestamp;
    }

    function deposit(uint256 _pid, uint256 _amount) public {
        Pool storage pool = pools[_pid];
        PoolUser storage user = poolUsers[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 reward = user.amount * pool.accUnits / 1e12 - user.rewardDebt + user.remainingReward;
            reward = reward * getUserMultiple(_pid,msg.sender) / 10000 ;
            user.remainingReward = safeRewardTransfer(msg.sender, reward);
            if(user.remainingReward > 0){
                user.remainingReward = user.remainingReward * 10000 / getUserMultiple(_pid,msg.sender) ;
            }
        }
        if(_amount != 0) {
            pool.token.safeTransferFrom(msg.sender, address(this), _amount);
            user.startTime = block.timestamp;
        }        
        if (pool.feePoint > 0) {
            uint256 fee = _amount * pool.feePoint / 10000;
            pool.token.safeTransfer(feeAddress, fee);
            user.amount = user.amount + _amount - fee;
            pool.amount = pool.amount + _amount - fee;
        } else {
            user.amount += _amount;
            pool.amount += _amount;
        }
        user.rewardDebt = user.amount * pool.accUnits / 1e12;
        emit Deposit(msg.sender, _pid, _amount);
    }
    function getCountdown(uint256 _pid,address _user)public view returns(uint256) {
        Pool storage pool = pools[_pid];
        PoolUser storage user = poolUsers[_pid][_user];
        if(block.timestamp - user.startTime >= pool.duration){return 0;}
        return pool.duration - (block.timestamp - user.startTime);
    }

    function withdraw(uint256 _pid, uint256 _amount) public {
        Pool storage pool = pools[_pid];
        PoolUser storage user = poolUsers[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: Insufficient Stake Balance");
        if(_amount > 0){
            require(block.timestamp - user.startTime >= pool.duration,"time is not enough");
        }
        updatePool(_pid);
        uint256 reward = user.amount * pool.accUnits / 1e12 - user.rewardDebt + user.remainingReward;

        reward = reward * getUserMultiple(_pid,msg.sender) / 10000 ;
        user.remainingReward = safeRewardTransfer(msg.sender, reward);
        if(user.remainingReward > 0){
            user.remainingReward = user.remainingReward * 10000 / getUserMultiple(_pid,msg.sender) ;
        }
        
        user.amount -= _amount;
        pool.amount -= _amount;
        pool.token.safeTransfer(msg.sender, _amount);
        user.rewardDebt = user.amount * pool.accUnits / 1e12;
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function emergencyWithdraw(uint256 _pid) public {
        Pool storage pool = pools[_pid];
        PoolUser storage user = poolUsers[_pid][msg.sender];
        require(block.timestamp - user.startTime >= pool.duration,"time is not enough");
        uint256 userAmount = user.amount;
        pool.amount -= userAmount;
        delete poolUsers[_pid][msg.sender];
        pool.token.safeTransfer(msg.sender, userAmount);
        emit EmergencyWithdraw(msg.sender, _pid, userAmount);
    }

    function safeRewardTransfer(address _to, uint256 _amount) internal returns (uint256) {
        uint256 retokenBalance = retoken.balanceOf(address(this));
        if (retokenBalance == 0) {
            return _amount;
        }
        if (_amount > retokenBalance) {
            retoken.safeTransfer(_to, retokenBalance);
            return _amount - retokenBalance;
        }
        retoken.safeTransfer(_to, _amount);
        return 0;
    }

    function setFeeAddress(address _feeAddress) public {
        require(msg.sender == feeAddress, "setFeeAddress: FORBIDDEN");
        feeAddress = _feeAddress;
    }
    function withdrawETH(address to,uint256 _amount)public onlyOwner{
        payable(to).transfer(_amount);
    }

    function withdrawRewards(address to, uint256 _amount) public onlyOwner {
        require(IERC20(retoken).balanceOf(address(this)) >= _amount);
        IERC20(retoken).transfer(to, _amount);
    }
}