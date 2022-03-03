/**
 *Submitted for verification at BscScan.com on 2022-03-03
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
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
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
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

    function transferFrom( address sender, address recipient, uint256 amount) external returns (bool);
   
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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
        require(address(this).balance >= amount, 'Address: insufficient balance');

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
        if (returndata.length > 0) { 
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

contract Context {
    
    constructor()  {}

    function _msgSender() internal view returns (address ) {
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

    constructor()  {
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

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Pausable is Ownable {
    event Paused();
    event Unpaused();

    bool private _paused = false;

    function paused() public view returns(bool) {
       return _paused;
    }

    modifier whenNotPaused() {
       require(!_paused);
       _;
    }

    modifier whenPaused() {
       require(_paused);
       _;
    }

    function pause() public onlyOwner  whenNotPaused {
       _paused = true;
       emit Paused();
    }

    function unpause() public onlyOwner  whenPaused {
       _paused = false;
       emit Unpaused();
    }
}

contract BISLaunchPad is Pausable{
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;
    
    address public feeWallet;
    uint256 public launchFee = 1e17;
    IBEP20 public BISToken;
    uint256 public currentPool;
    
    struct TireDetails{
        string tireName;    
        uint256 requireAmount;
        uint256 tireID;
        uint256 tireWeight;
        bool tireStatus;
    }
    
    struct PoolDetails{
        address poolOwner;
        uint256 startTime;
        uint256 endTime;
        address RewardToken;
        uint256 avgAmount;
        uint256 totalAmount;
        bool poolOpen;
        bool draw;
    }
    
    struct Poollevel{
        uint256 amount;
        uint256 members;
    }
    
    struct UserDetails{
        string tire;
        uint256 depositAmount;
        uint256 poolID;
        uint256 depositTime;
        uint256 HoldAmount;
        uint256 tireLevel;
        bool whiteList;
        bool claim;
    }
    
    TireDetails[] public tireInfo;
    
    mapping(uint256 => PoolDetails) public poolInfo;
    mapping(uint256 => mapping(uint256 => Poollevel)) public levelInfo;
    mapping(address => mapping(uint256 => UserDetails)) private stake;
    mapping(uint256 => uint256) public rewardTokens;
    
    event LaunchPool(uint256 PoolID, uint256 startTime, uint256 endTime);
    event UpdateTire(uint256 TireID, uint256 requireAmount, uint256 TireWeight);
    event ExtendTime(address owner, uint256 endTime);
    event HoldTokens(address holder, uint256 amount, uint256 level, uint256 poolID, bool whiteList);
    event AddWhiteList(address Owner, address account, uint256 tireID);
    event RemoveWhiteList(address Owner, address account, uint256 tireID);
    event Deposit(address depositor, uint256 amount, uint256 tireID);
    event ClaimReward(address depositor, uint256 rewardAmount, bool claimStatus, address rewardToken);
    event DrawPool(uint256 poolID, bool poolStaus);
    event WithdrawBISToken(address holder, uint256 holdingAmount);
    event EmergencySafe(address owner, address receiver, address token, uint256 amount);
    event AdminDeposit(address Admin, address token, uint256 amount);

    constructor( address _BISToken, address _feeWallet) {
        BISToken = IBEP20(_BISToken);
        feeWallet =  _feeWallet;
    }
    
    modifier isWhiteList(address account, uint256 poolID){
        require(stake[account][poolID].whiteList,"user not in whiteList");
        _;
    }

    modifier isCreator(address account,uint256 _poolID){
        require(poolInfo[_poolID].poolOwner == account,"Invalid pool creator");
        _;
    }

    function updateFee(uint256 _Fee) external onlyOwner{
        launchFee = _Fee;
    }

    function addTire(TireDetails[] memory _tires)external onlyOwner{
        require(tireInfo.length == 0,"AddTire :: tire already initialized");
        for(uint256 i = 0; i < _tires.length; i++){
        tireInfo.push(TireDetails( _tires[i].tireName,
            _tires[i].requireAmount,
            _tires[i].tireID,
            _tires[i].tireWeight,
            _tires[i].tireStatus
        ));
        }
    }

    function launchPool(address _rewardToken, uint256 _startTime, uint256 _endTime)external payable {
        require(_rewardToken != address(0) , "launchPool :: Invalid reward token address" );
        require(_startTime >= block.timestamp && _startTime < _endTime ,"launchPool :: Invalid timing params");
        require(tireInfo.length != 0,"launchPool :: Tire not initialized");
        require(launchFee <= msg.value,"launchPool :: Invalid Launch Fee");
        require(payable(feeWallet).send(msg.value),"transaction failed");
        currentPool++;
        
        poolInfo[currentPool] = PoolDetails({
            poolOwner: msg.sender,
            startTime: _startTime,
            endTime: _endTime,
            RewardToken: _rewardToken,
            avgAmount: 0,
            totalAmount: 0,
            poolOpen: true,
            draw: false
        });
        
        emit LaunchPool(currentPool , _startTime, _endTime);
    }
    
    function userDetails(address _account, uint256 _poolID)external view returns(bool){
        return stake[_account][_poolID].whiteList;
    }
    
    function updateTire(uint256 _tireID,uint256 _requireAmount, uint256 _tireWeight)external onlyOwner{
        require(tireInfo.length > _tireID,"UpdateTire :: tire not found" );
        TireDetails storage tire = tireInfo[_tireID];
        tire.requireAmount = _requireAmount;
        tire.tireWeight = _tireWeight;

        emit UpdateTire(_tireID, _requireAmount, _tireWeight);
    }
    
    function extendDepositTime(uint256 _poolID,uint256 _endTime)external onlyOwner{
        PoolDetails storage pool = poolInfo[_poolID];
        require(!pool.draw,"Launch Pad :: Pool fund is released");
        require(_endTime > pool.endTime,"Launch Pad :: new end time greater than old");
        
        pool.endTime = _endTime;
        emit ExtendTime(msg.sender, _endTime);
    }
    
    function holdTokens(uint256 _amount, uint256 _poolID)external whenNotPaused returns(bool success){
        require(poolInfo[_poolID].poolOpen,"HoldTokens :: Pool closed");
        UserDetails storage user = stake[msg.sender][_poolID];
        require(!user.whiteList,"already have a tier or withdraw the previous pool");
        
        require(_amount > 0, "Hold :: Holding amount must greater than zero");
        user.HoldAmount = _amount;
        (uint256 level, string memory name) = tireLevels(_amount);
        user.tireLevel = level;
        user.tire = name;
        user.poolID = _poolID;
        user.whiteList = true;
        BISToken.safeTransferFrom(msg.sender, address(this), _amount);
        
        emit HoldTokens(msg.sender,_amount, level, currentPool, true);
        
        return true;
    }
    
    function tireLevels(uint256 _amount) public view returns(uint256 tire, string memory name){
        for(uint256 i = 0; i < tireInfo.length; i++){
            if(_amount == tireInfo[i].requireAmount){
                return (i, tireInfo[i].tireName);
            }
        }
        revert("Undefined amount");
    }
    
    function addWhiteList(address _account, uint256 _tireID, uint256 _poolID)external isCreator(msg.sender, _poolID){
        UserDetails storage user = stake[_account][_poolID];
        require(!user.whiteList,"whiteList :: already in whiteList");
        require(tireInfo.length > _tireID,"whiteList :: TireID not found");
        user.tireLevel = _tireID;
        user.tire = tireInfo[_tireID].tireName;
        user.whiteList = true;
        
        emit AddWhiteList(msg.sender, _account, _tireID);
    }
    
    function removeWhiteList(address _account, uint256 _tireID, uint256 _poolID)external isCreator(msg.sender, _poolID){
        UserDetails storage user = stake[_account][_poolID];
        require(user.whiteList,"whiteList :: already in blacklist");
        require(user.depositAmount == 0,"whiteList :: user not eligible to add blacklist");
        delete stake[_account][currentPool];
        
        emit RemoveWhiteList(msg.sender, _account, _tireID);
    }
    
    function deposit(uint256 _poolID)external payable whenNotPaused isWhiteList(msg.sender, _poolID){
        require(_poolID <= currentPool,"Invalid PoolID");
        require(rewardTokens[_poolID] > 0,"reward amount not deposited");
        require(msg.value > 0, "Deposit :: amount greater than zero");
        UserDetails storage user = stake[msg.sender][_poolID];
        Poollevel storage level = levelInfo[_poolID][user.tireLevel];
        PoolDetails storage pool = poolInfo[_poolID];
        pool.totalAmount += msg.value;
        user.depositAmount += msg.value;
        level.amount += msg.value;
        level.members++;
        
        emit Deposit(msg.sender, msg.value, user.tireLevel);
    }
    
    function claimReward(uint256 _poolID)external whenNotPaused isWhiteList(msg.sender, _poolID){
        UserDetails storage user = stake[msg.sender][_poolID];
        require(poolInfo[_poolID].draw,"ClaimReward :: Reward fund not released");
        require(!user.claim,"ClaimReward :: user already claimed");
        require(user.depositAmount > 0,"Withdraw :: User not deposited" );
        uint256 transferReward = calculateReward(msg.sender, _poolID);
        user.claim = true;
        IBEP20(poolInfo[_poolID].RewardToken).safeTransfer( msg.sender, transferReward);

        BISToken.safeTransfer(msg.sender, user.HoldAmount);
        
        emit WithdrawBISToken(msg.sender, user.HoldAmount);
        
        emit ClaimReward(msg.sender, transferReward, user.claim, poolInfo[_poolID].RewardToken);
    }
    
    function drawPool(uint256 _poolID)external isCreator(msg.sender, _poolID){
        PoolDetails storage pool = poolInfo[_poolID];
        require(!pool.draw,"DrawPool :: pool has already drawn");
        require(pool.endTime < block.timestamp,"DrawPool :: pool not reached the end time");
        require(rewardTokens[_poolID] > 0,"DrawPool :: reward token NOT DEPOSITED");
        
        pool.draw = true;
        pool.poolOpen = false;
        getPoolAVG(_poolID);
        payable(msg.sender).transfer(pool.totalAmount);
        emit DrawPool(_poolID, poolInfo[_poolID].draw);
    }
    
    function getPoolAVG(uint256 _poolID)internal{
        uint256 totalAmount;
        for(uint256 i = 0; i < tireInfo.length; i++){
            totalAmount += levelInfo[_poolID][i].members.mul(tireInfo[i].tireWeight);
        }
        poolInfo[_poolID].avgAmount = rewardTokens[_poolID].div(totalAmount);
    }
    
    function calculateReward(address _account,uint256 _poolID)internal view  returns(uint256 reward){
        UserDetails storage user = stake[_account][_poolID];
        uint256 totalReward =  getReward(_poolID,user.tireLevel);
        uint256 percentage = (user.depositAmount.mul(100)).div(levelInfo[_poolID][user.tireLevel].amount);
        return reward = percentage.mul(totalReward).div(100);
    }
    
    function getReward(uint256 _poolID, uint256 _tireLevel)internal view returns(uint256 reward){
        reward = levelInfo[_poolID][_tireLevel].members.mul(poolInfo[_poolID].avgAmount).mul(tireInfo[_tireLevel].tireWeight);
    }
    
    function depositRewardTokens(uint256 _poolID,address _token, uint256 _amount)external onlyOwner{
        require(poolInfo[_poolID].RewardToken == _token,"DrawPool :: Pool id and reward tokens are mismatched");
        rewardTokens[_poolID] += _amount;
        IBEP20(_token).safeTransferFrom(msg.sender,address(this),_amount);
        emit AdminDeposit(msg.sender, _token, _amount);
    }
    
    function emergencySafe(address _token,address _to, uint256 _amount)external onlyOwner{
        if(_token != address(0)){
            IBEP20(_token).safeTransfer( _to, _amount);
        }else {
            require(payable(_to).send(_amount),"Safe :: transaction Failed");
        }
        emit EmergencySafe(msg.sender, _to, _token, _amount);
    }
}