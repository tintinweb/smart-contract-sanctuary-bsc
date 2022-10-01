/**
 *Submitted for verification at BscScan.com on 2022-10-01
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

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

contract Pausable is Context {
    
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () {
        _paused = false;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

contract staking is Ownable, Pausable, ReentrancyGuard{

    IBEP20 public Mabrook;
    uint256 public APYpercentage;

    struct User{
        address user;
        uint256 amount;
        uint256 depositTime;
        uint256 lastClaimTime;
        uint256 rewardEndTime;
        uint256 stakeID;
        uint256 APY;
        bool unstake;
    }

    mapping(address => mapping(uint256 => User)) public userInfo;
    mapping(address => uint256 ) public stakingCount;

    event Deposit(address indexed Depositor, uint256 StakeID, uint256 DepoistAmount, uint256 DepoistTime );
    event Withdraw(address indexed Depositor, uint256 StakeID, uint256 WithdrawAmount, uint256 WithdrawTime);
    event ClaimReward(address indexed Depositor, uint256 StakeID, uint256 ClaimAmount, uint256 ClaimTime);

    constructor(address _token, uint256 _APYpercent) {
        Mabrook = IBEP20(_token);
        APYpercentage = _APYpercent; // 100 value mean 10%
    }

    function setToken(address _token) external onlyOwner {
        Mabrook = IBEP20(_token);
    }

    function setAPY(uint256 _percentage) external onlyOwner {
        APYpercentage = _percentage; // 100 value mean 10%
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unPause() external onlyOwner {
        _unpause();
    }

    function pendingReward(address _user, uint256 _stakeID) public view returns(uint256 rewardAmount){
        User storage user = userInfo[_user][_stakeID];
        uint256 stakeTime = block.timestamp - user.lastClaimTime;
        if(user.rewardEndTime < block.timestamp){
            stakeTime = user.rewardEndTime - user.lastClaimTime;
        }
        uint256 perDay = user.APY * 1e16 / 365;
        rewardAmount = stakeTime * user.amount * perDay / 1e3 / 1e16 / 86400;
    }

    function deposit(uint256 _tokenAmount) external whenNotPaused nonReentrant {
        stakingCount[_msgSender()]++;
        User storage user = userInfo[_msgSender()][stakingCount[_msgSender()]];

        user.user = _msgSender();
        user.amount = _tokenAmount;
        user.depositTime = block.timestamp;
        user.lastClaimTime = block.timestamp;
        user.rewardEndTime = block.timestamp + (365 * 86400);
        user.stakeID = stakingCount[_msgSender()];
        user.APY = APYpercentage;

        Mabrook.transferFrom(_msgSender(), address(this), _tokenAmount);
        emit Deposit(_msgSender(), user.stakeID, _tokenAmount, block.timestamp);
    }

    function claim(uint256 _stakeID) public whenNotPaused nonReentrant {
        User storage user = userInfo[_msgSender()][_stakeID];
        require(!user.unstake,"user already unstaked");
        require(user.depositTime > 0 , "stake ID not founc");
        uint rewardAmount = pendingReward(_msgSender(), _stakeID);
        user.lastClaimTime = block.timestamp;
        
        Mabrook.transfer(_msgSender(), rewardAmount);

        emit ClaimReward(_msgSender(), _stakeID, rewardAmount, block.timestamp);
    }

    function withdraw(uint256 _stakeID) external whenNotPaused nonReentrant{
        User storage user = userInfo[_msgSender()][_stakeID];
        require(!user.unstake,"user already unstaked");
        require(user.depositTime > 0 , "stake ID not founc");
        claim(_stakeID);
        user.unstake = true;
        Mabrook.transfer(_msgSender(), user.amount);

        emit Withdraw(_msgSender(), _stakeID, user.amount, block.timestamp);
    }

    function recover(address _tokenAddress, address _to, uint256 _tokenAmount) external onlyOwner{
        IBEP20(_tokenAddress).transfer(_to, _tokenAmount);
    }

}