/**
 *Submitted for verification at BscScan.com on 2022-06-10
*/

// SPDX-License-Identifier: MIT
// Developed by ContractChecker Ⓒ
pragma solidity 0.8.14;

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
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, 'Address: low-level call failed');
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
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
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
interface IBEP20 {

    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
library SafeBEP20 {
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeBEP20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) - value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
        }
    }
}
contract Context {
    constructor() {}

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
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
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}
contract StandartStaking is Ownable, ReentrancyGuard {
    using SafeBEP20 for IBEP20;

    struct UserInfo {
        uint256 amount;  
        uint256 rewardDebt;  
        uint256 lastDepositTime;
    }

    struct PoolInfo {
        uint256 lastRewardBlock;  
        uint256 accRewardPerShare; 
        uint256 rewardPerBlock;
        uint256  startBlock;
        uint256  bonusEndBlock;
        uint256 lockPeriod;
        IBEP20  rewardToken;
        IBEP20  stakedToken;
        uint256 withdrawFee;
        uint256 depositFee;
        uint256 emergencyWithdrawFee;
        uint256 balance;
    }
    
    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event Harvest(address indexed user, uint256 amount);
    event DepositFee(address indexed user, uint256 amount);
    event WithdrawFee(address indexed user, uint256 amount);
    event EmergencyWithdrawFee(address indexed user, uint256 amount);
    constructor() {}

    function addPool(PoolInfo memory pool) public onlyOwner {
        pool.lastRewardBlock = block.number > pool.startBlock ? block.number : pool.startBlock;
        poolInfo.push(pool);
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function getMultiplier(uint256 _pid,uint256 _from, uint256 _to) internal view returns (uint256) {

        if (_to <= poolInfo[_pid].bonusEndBlock) {
            return _to - _from;
        } else if (_from >= poolInfo[_pid].bonusEndBlock) {
            return 0;
        } else {
            return poolInfo[_pid].bonusEndBlock - _from;
        }
    }

    function pendingReward(uint256 _pid,address _user) public view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accRewardPerShare = pool.accRewardPerShare;
        uint256 stakedSupply = pool.balance;
        if (block.number > pool.lastRewardBlock && stakedSupply != 0) {
            uint256 multiplier = getMultiplier(_pid,pool.lastRewardBlock, block.number);
            uint256 tokenReward = multiplier * pool.rewardPerBlock;
            accRewardPerShare = accRewardPerShare + ((tokenReward * 1e12) / stakedSupply);
        }
        return ((user.amount * accRewardPerShare) / 1e12) - user.rewardDebt ;
    }

    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 poolSupply = pool.balance;
        if (poolSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(_pid, pool.lastRewardBlock, block.number);
        uint256 tokenReward = multiplier * pool.rewardPerBlock;

        pool.accRewardPerShare = pool.accRewardPerShare + ((tokenReward * 1e12) / poolSupply);
        pool.lastRewardBlock = block.number;
    }

    function _harvest(address harvester, uint256 _pid) internal nonReentrant{
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][harvester];
        updatePool(_pid);
        uint256 rewardPending = pendingReward(_pid,harvester);
        require(rewardPending > 0,"reward : 0");

        user.rewardDebt = (user.amount *  pool.accRewardPerShare) / 1e12;
        if(rewardPending>0){
            pool.rewardToken.safeTransferFrom(address(this),address(harvester), rewardPending);
        }
        emit Harvest(harvester, rewardPending);
    }

    function harvest(uint256 _pid) public {
        _harvest(msg.sender,_pid);
    }

    function deposit(uint256 _pid,uint256 _amount) public {
        _deposit(msg.sender,_pid, _amount);
    }
    
    function _deposit(address userAddress,uint256 _pid,uint256 _amount)internal nonReentrant{
        require (_amount > 0, 'amount 0');
        UserInfo storage user = userInfo[_pid][userAddress];
        PoolInfo storage pool = poolInfo[_pid];
        require(user.amount == 0,"cannot restake");

        updatePool(_pid);
        pool.stakedToken.safeTransferFrom(address(userAddress), address(this), _amount);

        if(pool.depositFee>0){
            emit DepositFee(address(userAddress),(_amount * pool.depositFee) / 10_000);
            _amount -= (_amount * pool.depositFee) / 10_000;
            
        }
        user.amount = user.amount + _amount;
        pool.balance += _amount;
        user.rewardDebt = (user.amount *  pool.accRewardPerShare) / 1e12;
        user.lastDepositTime = block.timestamp;
        emit Deposit(userAddress, _amount);
    }

    function canWithdraw(uint256 _pid, address _user) public view returns (bool) {
        return (canWithdrawTime(_pid,_user)==0);
    }

    function canWithdrawTime(uint256 _pid, address _user) public view returns (uint256) {
        UserInfo storage user = userInfo[_pid][_user];
        PoolInfo storage pool = poolInfo[_pid];
        
        if ((block.timestamp < user.lastDepositTime + pool.lockPeriod) && (block.number < pool.bonusEndBlock)){
            return user.lastDepositTime + pool.lockPeriod -  block.timestamp;
        }else{
            return 0;
        }
    }

    function withdraw(uint256 _pid,uint256 _amount) public nonReentrant{
        require (_amount > 0, 'amount 0');
        require(canWithdraw(_pid,msg.sender),'cannot withdraw yet');
        UserInfo storage user = userInfo[_pid][msg.sender];
        PoolInfo storage pool = poolInfo[_pid];
        require(user.amount >= _amount, "withdraw: not enough");
        _harvest(msg.sender,_pid);

        pool.balance -= _amount;
        user.amount = user.amount - _amount;
        if(pool.withdrawFee>0){
            emit WithdrawFee(address(msg.sender), (_amount * pool.withdrawFee) / 10_000);
            _amount -= (_amount * pool.withdrawFee) / 10_000;
        }
        pool.stakedToken.safeTransfer(address(msg.sender), _amount);
        
        user.rewardDebt = (user.amount * pool.accRewardPerShare) / 1e12;

        emit Withdraw(msg.sender, _amount);
    }

    function emergencyWithdraw(uint256 _pid) public nonReentrant{
        require(!canWithdraw(_pid,msg.sender),'Use normal withdraw instead');
        UserInfo storage user = userInfo[_pid][msg.sender];
        PoolInfo storage pool = poolInfo[_pid];
        require(user.amount > 0,'amount 0');

        uint256 _amount=user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        pool.balance -= _amount;
        if(pool.emergencyWithdrawFee>0){
            emit  EmergencyWithdrawFee(address(msg.sender), (_amount * pool.emergencyWithdrawFee) / 10_000);  
            _amount -= (_amount * pool.emergencyWithdrawFee) / 10_000; 
        }
        pool.stakedToken.safeTransfer(address(msg.sender), _amount);
        emit EmergencyWithdraw(msg.sender, _amount);
    }

    function setDepositFee(uint256 _pid,uint depFee) external onlyOwner {
        PoolInfo storage pool = poolInfo[_pid]; 
        require(depFee < 500 && depFee % 4 ==0 , "DeposiFee should be < 5 and %4 ==0 because 1/4 may send own of referralCode");
        pool.depositFee = depFee;
    }

    function setEmergencyFee(uint256 _pid,uint emFee) external onlyOwner {
        PoolInfo storage pool = poolInfo[_pid];
        require(emFee <= 3000, "EmergencyWithdrawFee should be <= 30");
        pool.emergencyWithdrawFee = emFee;
    }    

    function setWithdrawFee(uint256 _pid,uint wFee) external onlyOwner {
        PoolInfo storage pool = poolInfo[_pid]; 
        require(wFee < 500, "WithdrawFee should be < 5");
        pool.withdrawFee = wFee;
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    struct FixedUserInfo {
        uint256 amount;  
        uint256 lastDepositTime;
    }

    struct FixedPoolInfo{
        uint256 APR;  
        uint256 startEpoch;
        uint256 lockPeriod;
        IBEP20  stakedToken;
        uint256 withdrawFee;
        uint256 depositFee;
        uint256 emergencyWithdrawFee;
        bool isOpen;
    }

    FixedPoolInfo[] public fixedPoolInfo;
    mapping(uint256 => mapping(address => FixedUserInfo)) public fixedUserInfo;

    function FixedAddPool(FixedPoolInfo memory pool) external onlyOwner{
        fixedPoolInfo.push(pool);
    }

    function fixedPoolLength() external view returns (uint256) {
        return fixedPoolInfo.length;
    }

    function fixedPendingReward(uint256 _pid,address _user) public view returns (uint256) {
        FixedPoolInfo storage pool = fixedPoolInfo[_pid];
        FixedUserInfo storage user = fixedUserInfo[_pid][_user];
        
        uint256 lockedTime = block.timestamp > user.lastDepositTime + pool.lockPeriod ? pool.lockPeriod : block.timestamp - user.lastDepositTime;
        uint256 reward = (((user.amount * pool.APR) / 10_000) * lockedTime) / pool.lockPeriod;
        return reward;
    }

    function fixedDeposit(uint256 _pid,uint256 _amount) public nonReentrant{
        require (_amount > 0, 'amount 0');
        FixedUserInfo storage user = fixedUserInfo[_pid][msg.sender];
        FixedPoolInfo storage pool = fixedPoolInfo[_pid];
        require(pool.isOpen,' pool is closed');
        require(pool.startEpoch < block.timestamp,'pool has not started yet');
        require(user.amount == 0,"cannot restake");
        pool.stakedToken.safeTransferFrom(address(msg.sender), address(this), _amount);

        if(pool.depositFee>0){
            emit DepositFee(address(msg.sender),(_amount * pool.depositFee) / 10_000);
            _amount -= (_amount * pool.depositFee) / 10_000;
            
        }
        user.amount = user.amount + _amount;
        user.lastDepositTime = block.timestamp;

        emit Deposit(msg.sender, _amount);
    }

    function fixedCanWithdraw(uint256 _pid, address _user) public view returns (bool) {
        return (fixedCanWithdrawTime(_pid,_user)==0);
    }

    function fixedCanWithdrawTime(uint256 _pid, address _user) public view returns (uint256) {
        FixedPoolInfo storage pool = fixedPoolInfo[_pid];
        FixedUserInfo storage user = fixedUserInfo[_pid][_user];
        
        if ((block.timestamp < user.lastDepositTime + pool.lockPeriod)){
            return user.lastDepositTime + pool.lockPeriod -  block.timestamp;
        }else{
            return 0;
        }
    }

    function fixedWithdraw(uint256 _pid) public nonReentrant{
        require(fixedCanWithdraw(_pid,msg.sender),'cannot withdraw yet');
        FixedPoolInfo storage pool = fixedPoolInfo[_pid];
        FixedUserInfo storage user = fixedUserInfo[_pid][msg.sender];
        uint256  _amount = user.amount;
        require (_amount > 0, 'amount 0');

        if(pool.withdrawFee>0){
            emit WithdrawFee(address(msg.sender), (_amount * pool.withdrawFee) / 10_000);
            _amount -= (_amount * pool.withdrawFee) / 10_000;
        }

        _amount += fixedPendingReward(_pid, msg.sender);
        user.amount=0;
        pool.stakedToken.safeTransfer(address(msg.sender), _amount);

        emit Withdraw(msg.sender, _amount);
    }

    function fixedEmergencyWithdraw(uint256 _pid) public nonReentrant{
        require(!fixedCanWithdraw(_pid,msg.sender),'Use normal withdraw instead');
        FixedPoolInfo storage pool = fixedPoolInfo[_pid];
        FixedUserInfo storage user = fixedUserInfo[_pid][msg.sender];
        require(user.amount > 0,'amount 0');

        uint256 _amount=user.amount;
        user.amount = 0;
        if(pool.emergencyWithdrawFee>0){
            emit  EmergencyWithdrawFee(address(msg.sender), (_amount * pool.emergencyWithdrawFee) / 10_000);  
            _amount -= (_amount * pool.emergencyWithdrawFee) / 10_000; 
        }
        pool.stakedToken.safeTransfer(address(msg.sender), _amount);
        emit EmergencyWithdraw(msg.sender, _amount);
    }

    function fixedSetFees(uint256 _pid,uint depFee,uint emFee,uint wFee) external onlyOwner {
        FixedPoolInfo storage pool = fixedPoolInfo[_pid];
        require(depFee <= 500, "DeposiFee should be < 5");
        require(wFee <= 500, "WithdrawFee should be < 5");
        require(emFee <= 3000, "EmergencyWithdrawFee should be <= 30");
        pool.depositFee = depFee;
        pool.withdrawFee = wFee;
        pool.emergencyWithdrawFee = emFee;
    }

    function fixedPoolStatus(uint256 _pid,bool _isOpen) external onlyOwner{
        FixedPoolInfo storage pool = fixedPoolInfo[_pid];
        pool.isOpen = _isOpen;
    }

    function transferPoolNativeToOther(uint256 _pid,uint256 _newPid) external nonReentrant{
        FixedPoolInfo storage pool = fixedPoolInfo[_pid];
        PoolInfo storage newPool = poolInfo[_newPid];
        FixedUserInfo storage user = fixedUserInfo[_pid][msg.sender];
        require(user.amount > 0,"must stake");
        require(pool.lockPeriod < newPool.lockPeriod,"You can't do that!");
 
        uint256 pending = fixedPendingReward(_pid, msg.sender);
        uint256 _amount = user.amount + pending;
         user.amount = 0;
        _deposit(msg.sender, _newPid, _amount);
       
    }
    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        IBEP20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount); 
    }

    function recoverBNB(uint256 amount) public onlyOwner {
            payable(msg.sender).transfer(amount);
    }
}