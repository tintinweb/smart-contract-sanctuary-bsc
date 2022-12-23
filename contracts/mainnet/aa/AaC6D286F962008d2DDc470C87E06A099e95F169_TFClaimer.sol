pragma solidity >=0.7.0 <0.9.0;

import "./ERC20Upgradeable.sol";
import "./SafeERC20Upgradeable.sol";
import "./SafeMathUpgradeable.sol";
import "./OwnableUpgradeable.sol";
import "./EnumerableSetUpgradeable.sol";
import "./ReentrancyGuardUpgradeable.sol";

interface ITFToken is IERC20Upgradeable {
    function mint(uint value) external;
}

contract TFClaimer is OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using SafeMathUpgradeable for uint;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    uint[] public timePoints;
    uint[] public poolIds;

    mapping(uint => mapping(uint => uint)) public claimPercents;    // poolid timeid percents  1e6 = 100%
    mapping(uint => uint) public totalAllocation; // poolid total
    mapping(uint => uint) public totalClaimed; // poolid totalClaimed
    mapping(uint => bool) public isPaused; // poolid is pause
    mapping(uint => mapping(address => uint)) public allocation;    // user poolid total
    mapping(uint => mapping(address => mapping(uint => uint))) public userClaimedPerPoint;  // user poolid timeid amount

    address public token;

    uint256[50] private __gap;

    event Deposit(address indexed user, uint indexed pid, uint amount);
    event Withdraw(address indexed user, uint indexed pid, uint amount);
    event Claim(address indexed user, uint indexed pid, uint amount);

    function initialize(address _token) external initializer {
        __Ownable_init();
        token = _token;
    }

    function addTimePoints(uint[] memory _timePoints) external onlyOwner {
        for(uint i = 0; i < _timePoints.length; i ++) {
            for(uint j = 0; j < timePoints.length; j ++) {
                require(timePoints[j] != _timePoints[i], '!has');
            }
            timePoints.push(_timePoints[i]);
        }
    }

    function addPools(uint[] memory _pidcode) external onlyOwner {
        for(uint i = 0; i < _pidcode.length; i ++) {
            poolIds.push(_pidcode[i]);
        }
    }

    function showTimePoints() external view returns (uint[] memory) {
        return timePoints;
    }

    function setClaimPercents(uint _id, uint[] memory _timeIds, uint[] memory _percents) public onlyOwner {
        require(_timeIds.length == _percents.length, "!length");
        require(_id < poolIds.length, '!_id');

        for (uint i = 0; i < _timeIds.length; i++) {
            require(timePoints[_timeIds[i]] > block.timestamp, '!timestamp');
            claimPercents[_id][_timeIds[i]] = _percents[i];
        }

        uint totalPercent = 0;
        for (uint i = 0; i < _timeIds.length; i++) {
            totalPercent = totalPercent.add(claimPercents[_id][_timeIds[i]]);
        }
        require(totalPercent == 1e6, "!totalPercent");
    }

    function setAllocation(uint _id, address _account, uint _newAllocation) public onlyOwner {
        require(_id < poolIds.length, '!_id');
        totalAllocation[_id] = totalAllocation[_id].sub(allocation[_id][_account]).add(_newAllocation);
        allocation[_id][_account] = _newAllocation;
    }

    function batchAddAllocation(uint _id, address[] memory addresses, uint[] memory allocations) external onlyOwner {
        require(addresses.length == allocations.length, "!length");
        require(_id < poolIds.length, '!_id');

        for (uint i = 0; i < addresses.length; i++) {
            setAllocation(_id, addresses[i], allocations[i]);
        }
    }

    function setUserClaimedPerPoint(uint _id, address _user, uint[] memory _timeIds, uint[] memory _values) public onlyOwner {
        require(_timeIds.length == _values.length, "!length");
        require(allocation[_id][_user] > 0, "!_user");
        require(_id < poolIds.length, '!_id');
        for (uint tindex = 0; tindex < _timeIds.length; tindex++) {
            uint tid = _timeIds[tindex];
            userClaimedPerPoint[_id][_user][tid] = _values[tindex];
        }  
    }

    function pendingLength(address _user) public view returns (uint length) {
        for (uint tid = 0; tid < timePoints.length; tid++) {
            for(uint pid = 0; pid < poolIds.length; pid++) {
                if(allocation[pid][_user] == 0) {
                    continue;
                }
                if(claimPercents[pid][tid] == 0) {
                    continue;
                }
                length = length.add(1);
                break;
            }
        }
    }

    function pendingTimePoint(uint _tid, address _user) public view returns (uint timeamount, uint timeclaim) {
        for(uint pid = 0; pid < poolIds.length; pid++) {
            if(allocation[pid][_user] == 0) {
                continue;
            }
            if(claimPercents[pid][_tid] == 0) {
                continue;
            }
            uint poolamount = allocation[pid][_user].mul(claimPercents[pid][_tid]).div(1e6);
            timeamount = timeamount.add(poolamount);
            timeclaim = timeclaim.add(userClaimedPerPoint[pid][_user][_tid]);
        }
    }

    function pending(address _user, uint length) public view returns (uint[] memory times, uint[] memory amount, uint[] memory claimable) {
        times = new uint[](length);
        amount = new uint[](length);
        claimable = new uint[](length);
        uint saveIndex = 0;
        for (uint tid = 0; tid < timePoints.length; tid++) {
            (uint timeamount, uint timeclaim) = pendingTimePoint(tid, _user);
            if(timeamount > 0) {
                require(saveIndex < length, '!length');
                times[saveIndex] = timePoints[tid];
                amount[saveIndex] = timeamount;
                claimable[saveIndex] = timeclaim;
                saveIndex = saveIndex.add(1);
            }
        }
    }

    function claimTimePoint(uint _tid, address _user) internal returns (uint timeamount) {
        for(uint pid = 0; pid < poolIds.length; pid++) {
            if(allocation[pid][_user] == 0) {
                continue;
            }
            if(claimPercents[pid][_tid] == 0) {
                continue;
            }
            if(isPaused[pid]) {
                continue;
            }
            uint poolamount = allocation[pid][_user].mul(claimPercents[pid][_tid]).div(1e6);
            uint claimamount = userClaimedPerPoint[pid][_user][_tid];
            if(claimamount < poolamount) {
                timeamount = timeamount.add(poolamount).sub(claimamount);
                totalClaimed[pid] = totalClaimed[pid].add(poolamount).sub(claimamount);
                userClaimedPerPoint[pid][_user][_tid] = poolamount;
            }
        }
    }

    function claim() external nonReentrant returns (uint value)  {
        value = 0;
        for (uint tid = 0; tid < timePoints.length; tid++) {
            if(timePoints[tid] > block.timestamp) {
                continue;
            }
            uint timeamount = claimTimePoint(tid, msg.sender);
            if(timeamount > 0) {
                value = value.add(timeamount);
                emit Claim(msg.sender, tid, timeamount);
            }
        }

        if(value > 0) {
            ITFToken(token).mint(value);
            ITFToken(token).transfer(msg.sender, value);
        }
    }

    function withdrawAll() external onlyOwner {
        uint balance = address(this).balance;
        if (balance > 0) {
            payable(owner()).transfer(balance);
        }
        
        balance = IERC20Upgradeable(token).balanceOf(address(this));
        IERC20Upgradeable(token).transfer(owner(), balance);
    }

    function withdrawToken(address _token, uint amount) external onlyOwner {
        IERC20Upgradeable(_token).transfer(owner(), amount);
    }
}