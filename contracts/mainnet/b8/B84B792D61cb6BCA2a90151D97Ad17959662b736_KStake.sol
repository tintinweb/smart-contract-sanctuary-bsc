/**
 *Submitted for verification at BscScan.com on 2022-09-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    // function renounceOwnership() public virtual onlyOwner {
    //     emit OwnershipTransferred(_owner, address(0));
    //     _owner = address(0);
    // }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IStorage {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function stakeFor(address _from, address _to,uint _value) external returns (uint);
    function withdraw(address account, uint _index) external;
}

contract KStake is Ownable {
    using SafeMath for uint256;

    struct Boardseat {
        uint256 lastSnapshotIndex;
        uint256 rewardEarned;
    }

    struct BoardSnapshot {
        uint256 time;
        uint256 rewardReceived;
        uint256 rewardPerShare;
    }

    IERC20 public kToken;
    IStorage public store;
    uint256 public rewardDuration = 1 hours;
    uint256 public refundTotal;
    uint256 public rewardTotal;

    mapping(address => Boardseat) private directors;
    BoardSnapshot[] private boardHistory;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardAdded(address indexed user, uint256 reward);

    constructor(address _kToken, address _store) {
        kToken = IERC20(_kToken);
        store = IStorage(_store);
        BoardSnapshot memory genesisSnapshot = BoardSnapshot({
            time: block.timestamp,
            rewardReceived: 0,
            rewardPerShare: 0
            });
        boardHistory.push(genesisSnapshot);
    }

    modifier updateReward(address director) {
        (, uint256 amount) = getTotalIncome().trySub(rewardTotal);
        if(amount>0 && getLatestSnapshot().time.add(rewardDuration)<block.timestamp) {
            allocate(amount);
        }
        if (director != address(0)) {
            Boardseat memory seat = directors[director];
            seat.rewardEarned = earned(director);
            seat.lastSnapshotIndex = latestSnapshotIndex();
            directors[director] = seat;
        }
        _;
    }

    function latestSnapshotIndex() public view returns (uint256) {
        return boardHistory.length.sub(1);
    }

    function getLatestSnapshot() public view returns (BoardSnapshot memory) {
        return boardHistory[latestSnapshotIndex()];
    }

    function getLastSnapshotIndexOf(address director) public view returns (uint256){
        return directors[director].lastSnapshotIndex;
    }

    function getLastSnapshotOf(address director)internal view returns (BoardSnapshot memory) {
        return boardHistory[getLastSnapshotIndexOf(director)];
    }

    function rewardPerShare() public view returns (uint256) {
        return getLatestSnapshot().rewardPerShare;
    }

    function earned(address director) public view returns (uint256) {
        uint256 latestRPS = getLatestSnapshot().rewardPerShare;
        uint256 storedRPS = getLastSnapshotOf(director).rewardPerShare;

        uint256 rewardEarned = store.balanceOf(director)
        .mul(latestRPS.sub(storedRPS)).div(1e18)
        .add(directors[director].rewardEarned);
        return rewardEarned;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */
    function stakeFor(address _to, uint _value) public  updateReward(_to) returns (uint){
        require(_value > 0, 'Cannot stake 0');
        store.stakeFor(msg.sender, _to, _value);
        return _value;
    }

    function stake(uint _value) public returns (uint){
        return stakeFor(msg.sender, _value);
    }

    function withdraw(uint _index) public updateReward(msg.sender) {
        store.withdraw(msg.sender, _index);
    }

    function getReward() public updateReward(msg.sender) {
        uint256 reward = directors[msg.sender].rewardEarned;
        if (reward > 0) {
            directors[msg.sender].rewardEarned = 0;
            kToken.transfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
            refundTotal = refundTotal.add(reward);
        }
    }

    function getTotalIncome() public view returns (uint){
        uint total = kToken.balanceOf(address(this));
        return total.add(refundTotal);
    }

    function addNewSnapshot(uint256 amount) private{
        // Create & add new snapshot
        uint256 prevRPS = getLatestSnapshot().rewardPerShare;
        uint256 nextRPS = prevRPS.add(amount.mul(1e18).div(store.totalSupply()));

        BoardSnapshot memory newSnapshot = BoardSnapshot({
            time: block.timestamp,
            rewardReceived: amount,
            rewardPerShare: nextRPS
            });
        boardHistory.push(newSnapshot);
        rewardTotal = rewardTotal.add(amount);
    }

    function allocate(uint256 amount) private{
        if(store.totalSupply() > 0){
            addNewSnapshot(amount);
            emit RewardAdded(msg.sender, amount);
        }
    }

    function changeDuration(uint256 _rewardDuration) public onlyOwner{
        rewardDuration = _rewardDuration;
    }

    function withdrawForeignTokens(address token, address to, uint256 amount) onlyOwner public returns (bool) {
        require(token!=address(kToken), 'Wrong token!');
        return IERC20(token).transfer(to, amount);
    }
}