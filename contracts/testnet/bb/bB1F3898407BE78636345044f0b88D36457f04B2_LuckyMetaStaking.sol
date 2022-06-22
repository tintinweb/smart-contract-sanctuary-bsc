/**
 *Submitted for verification at BscScan.com on 2022-06-21
*/

// SPDX-License-Identifier: MIT

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

contract LuckyMetaStaking is Ownable, ReentrancyGuard {
    using SafeBEP20 for IBEP20;
    using Address for address;

    struct UserInfo {
        uint256 amount;  
        uint256 lastDepositTime;
    }

    struct PoolInfo{
        uint256 APR;  
        uint256 startEpoch;
        uint256 lockPeriod;
        uint256 depositFee;
        uint256 withdrawFee;
        uint256 emergencyWithdrawFee;
        bool isOpen;
    }

    IBEP20 LuckyMeta;

    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    uint256 public minAmount = 100_000 * (10 ** 9);
    uint256 public maxAmount = 900_000_000 * (10 ** 9);

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event DepositFee(address indexed user, uint256 amount);
    event WithdrawFee(address indexed user, uint256 amount);
    event EmergencyWithdrawFee(address indexed user, uint256 amount);

    constructor(IBEP20 _LuckyMeta) {
        LuckyMeta = _LuckyMeta;
    }

    function addPool(PoolInfo memory pool) external onlyOwner{
        poolInfo.push(pool);
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function pendingReward(uint256 _pid,address _user) public view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        
        uint256 lockedTime = block.timestamp > user.lastDepositTime + pool.lockPeriod ? pool.lockPeriod : block.timestamp - user.lastDepositTime;
        uint256 reward = (((user.amount * pool.APR) / 10_000) * lockedTime) / pool.lockPeriod;
        return reward;
    }

    function deposit(uint256 _pid,uint256 _amount) public nonReentrant{
        require (_amount > 0, 'amount 0');
        UserInfo storage user = userInfo[_pid][msg.sender];
        PoolInfo storage pool = poolInfo[_pid];
        require(pool.isOpen,'pool is closed');
        require(pool.startEpoch < block.timestamp,'pool has not started yet');
        require(user.amount == 0,"cannot restake");
        require(_amount >= minAmount && _amount <= maxAmount,'amount out of limits');
        
        LuckyMeta.safeTransferFrom(address(msg.sender), address(this), _amount);

        if(pool.depositFee>0){
            emit DepositFee(address(msg.sender),(_amount * pool.depositFee) / 10_000);
            _amount -= (_amount * pool.depositFee) / 10_000;
            
        }
        user.amount = user.amount + _amount;
        user.lastDepositTime = block.timestamp;

        emit Deposit(msg.sender, _amount);
    }

    function canWithdraw(uint256 _pid, address _user) public view returns (bool) {
        return (withdrawCountdown(_pid,_user)==0);
    }

    function withdrawCountdown(uint256 _pid, address _user) public view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        
        if ((block.timestamp < user.lastDepositTime + pool.lockPeriod)){
            return user.lastDepositTime + pool.lockPeriod -  block.timestamp;
        }else{
            return 0;
        }
    }

    function withdraw(uint256 _pid) public nonReentrant{
        require(canWithdraw(_pid,msg.sender),'cannot withdraw yet');
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256  _amount = user.amount;
        require (_amount > 0, 'amount 0');

        if(pool.withdrawFee>0){
            emit WithdrawFee(address(msg.sender), (_amount * pool.withdrawFee) / 10_000);
            _amount -= (_amount * pool.withdrawFee) / 10_000;
        }

        _amount += pendingReward(_pid, msg.sender);
        user.amount=0;
        LuckyMeta.safeTransfer(address(msg.sender), _amount);

        emit Withdraw(msg.sender, _amount);
    }

    function emergencyWithdraw(uint256 _pid) public nonReentrant{
        require(!canWithdraw(_pid,msg.sender),'Use normal withdraw instead');
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount > 0,'amount 0');

        uint256 _amount=user.amount;
        user.amount = 0;
        if(pool.emergencyWithdrawFee>0){
            emit  EmergencyWithdrawFee(address(msg.sender), (_amount * pool.emergencyWithdrawFee) / 10_000);  
            _amount -= (_amount * pool.emergencyWithdrawFee) / 10_000; 
        }
        LuckyMeta.safeTransfer(address(msg.sender), _amount);
        emit EmergencyWithdraw(msg.sender, _amount);
    }

    function setFees(uint256 _pid,uint depFee,uint emFee,uint wFee) external onlyOwner {
        PoolInfo storage pool = poolInfo[_pid];
        require(depFee <= 500, "DeposiFee should be < 5");
        require(wFee <= 500, "WithdrawFee should be < 5");
        require(emFee <= 3000, "EmergencyWithdrawFee should be <= 30");
        pool.depositFee = depFee;
        pool.withdrawFee = wFee;
        pool.emergencyWithdrawFee = emFee;
    }

    function poolStatus(uint256 _pid,bool _isOpen) external onlyOwner{
        PoolInfo storage pool = poolInfo[_pid];
        pool.isOpen = _isOpen;
    }

    function setMinAndMaxStakeAmounts(uint256 _min, uint256 _max) external onlyOwner {
        minAmount = _min;
        maxAmount = _max;
    }

    function recoverTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        IBEP20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount); 
    }
}