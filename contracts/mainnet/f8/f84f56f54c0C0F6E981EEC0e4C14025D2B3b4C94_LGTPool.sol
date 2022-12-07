/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

pragma solidity 0.6.12;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a,uint256 b,string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    function mod(uint256 a,uint256 b,string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
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

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {
    address private _owner;

    constructor() internal {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, 'Ownable: caller is not the owner');
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
}

contract LGTPool is Ownable {
    using SafeMath for uint256;
    
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 downlineAmount;
        uint256 withdrawn;
        uint256 reward;
        uint256 refReward;
        uint256 validDirectNum;
    }

    struct User {
        uint256 id;
        address upline;
    }
    mapping(address => User) public users;
    mapping(uint256 => address) public id2Address;
    uint256 public nextUserId = 2;

    struct PoolInfo {
        IERC20 lpToken;
        uint256 allocPoint;  
        uint256 lastRewardBlock;
        uint256 acclgtPerShare;
    }

    IERC20 public lgt;
    uint256 public lgtPerBlock;
    uint256 public lgtStakeAmount;

    PoolInfo[] public poolInfo;
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;

    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;
    uint256 public totalLP;
    uint256 public constant validLPamount = 500*10**18;

    struct RefInfo {
        uint256 minAmount;
        uint256 refRewardRate;
    }
    mapping (uint256 => RefInfo) public refRewardRates;

    constructor(IERC20 _lgt, uint256 _lgtPerBlock, uint256 _startBlock, address _first) public {
        lgt = _lgt;
        lgtPerBlock = _lgtPerBlock;
        startBlock = _startBlock;

        poolInfo.push(PoolInfo({
            lpToken: _lgt,
            allocPoint: 0,
            lastRewardBlock: startBlock,
            acclgtPerShare: 0
        }));

        id2Address[1] = _first;
        users[_first].id = 1;

        refRewardRates[0] = RefInfo(1, 50);
        refRewardRates[1] = RefInfo(1, 50);
        refRewardRates[2] = RefInfo(2, 50);
        refRewardRates[3] = RefInfo(2, 50);
        refRewardRates[4] = RefInfo(3, 50);
        refRewardRates[5] = RefInfo(3, 50);
        refRewardRates[6] = RefInfo(4, 50);
        refRewardRates[7] = RefInfo(4, 50);
        refRewardRates[8] = RefInfo(5, 50);
        refRewardRates[9] = RefInfo(5, 50);
        refRewardRates[10] = RefInfo(6, 50);
        refRewardRates[11] = RefInfo(6, 50);
        refRewardRates[12] = RefInfo(7, 50);
        refRewardRates[13] = RefInfo(7, 50);
        refRewardRates[14] = RefInfo(8, 50);
        refRewardRates[15] = RefInfo(8, 50);
        refRewardRates[16] = RefInfo(9, 50);
        refRewardRates[17] = RefInfo(9, 50);
        refRewardRates[18] = RefInfo(10, 50);
        refRewardRates[19] = RefInfo(10, 50);
    }

    function register(address up) external {
        require(isUserExists(up), "up not exist");
        require(!isUserExists(msg.sender), "user exist");
        
        uint256 id = nextUserId++;
        users[msg.sender].id = id;
        users[msg.sender].upline = up;
        id2Address[id] = msg.sender;
    }

    function add(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate) external onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            acclgtPerShare: 0
        }));
    }

    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) external onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function setRate(uint256 i, uint256 m, uint256 newR) external onlyOwner {
        refRewardRates[i].minAmount = m;
        refRewardRates[i].refRewardRate = newR;
    }

    function setPer(uint256 p) external onlyOwner {
        massUpdatePools();
        lgtPerBlock = p;
    }

    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if(_pid == 0) {
            lpSupply = lgtStakeAmount;
        }
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 blockNum = block.number.sub(pool.lastRewardBlock);
        uint256 lgtReward = blockNum.mul(lgtPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        pool.acclgtPerShare = pool.acclgtPerShare.add( lgtReward.mul(1e12).div(lpSupply) );
        pool.lastRewardBlock = block.number;
    }

    function deposit(uint256 _pid, uint256 _amount) external {
        require(isUserExists(msg.sender), "user not exist");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        _addGen(msg.sender, _pid, _amount);
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.acclgtPerShare).div(1e12).sub(user.rewardDebt);
            user.reward = user.reward.add(pending);
        }
        if (_amount > 0) {
            uint256 before = user.amount;
            pool.lpToken.transferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
            if(_pid == 0) {
                lgtStakeAmount = lgtStakeAmount.add(_amount);
            }
            totalLP = totalLP.add(_amount);
            uint256 afterAmount = user.amount;
            if ( before < validLPamount && afterAmount >= validLPamount ) {
                address up = users[msg.sender].upline;
                if ( up != address(0) ) {
                    userInfo[_pid][up].validDirectNum++;
                }
            }
        }
        user.rewardDebt = user.amount.mul(pool.acclgtPerShare).div(1e12);
    }

    function _addGen(address addr, uint256 pid, uint256 amount) private {
        address up = users[addr].upline;
        for(; up != address(0);) {
            userInfo[pid][up].downlineAmount = userInfo[pid][up].downlineAmount.add(amount);
            up = users[up].upline;
        }
    }

    function withdraw(uint256 _pid, uint256 _amount) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");

        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.acclgtPerShare).div(1e12).sub(user.rewardDebt);
        pending = pending.add(user.reward);
        _refPayout(_pid, msg.sender, pending);
        pending = pending.add(user.refReward);
        lgt.transfer(msg.sender, pending);
        user.reward = 0;
        user.refReward = 0;
        user.withdrawn = user.withdrawn.add(pending);

        if(_amount > 0) {
            uint256 before = user.amount;
            user.amount = user.amount.sub(_amount);
            pool.lpToken.transfer(msg.sender, _amount);
            if(_pid == 0) {
                lgtStakeAmount = lgtStakeAmount.sub(_amount);
            }
            _removeGen(msg.sender, _pid, _amount);
            totalLP = totalLP.sub(_amount);
            uint256 afterAmount = user.amount;
            if ( before >= validLPamount && afterAmount < validLPamount ) {
                address up = users[msg.sender].upline;
                if ( up != address(0) ) {
                    userInfo[_pid][up].validDirectNum = userInfo[_pid][up].validDirectNum.sub(1);
                }
            }
        }
        user.rewardDebt = user.amount.mul(pool.acclgtPerShare).div(1e12);
    }

    function _removeGen(address addr, uint256 pid, uint256 amount) private {
        address up = users[addr].upline;
        for(; up != address(0);) {
            userInfo[pid][up].downlineAmount = userInfo[pid][up].downlineAmount.sub(amount);
            up = users[up].upline;
        }
    }

    function _refPayout(uint256 pid, address addr, uint256 amount) private {
        uint256 v = validLPamount;
        address up = users[addr].upline;
        for(uint256 i = 0; i < 20; i++) {
            if(up == address(0)) break;
            if (userInfo[pid][up].amount >= v && userInfo[pid][up].validDirectNum >= refRewardRates[i].minAmount){
                userInfo[pid][up].refReward = userInfo[pid][up].refReward.add( amount.mul(refRewardRates[i].refRewardRate).div(1000) );
            }
            up = users[up].upline;
        }
    }

    function emergencyWithdraw(uint256 _pid) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.transfer(msg.sender, user.amount);
        _removeGen(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
        user.reward = 0;
        user.refReward = 0;
    }

    function isUserExists(address addr) public view returns (bool) {
        return users[addr].id != 0;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function pendinglgt(uint256 _pid, address _user) public view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 acclgtPerShare = pool.acclgtPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if(_pid == 0) {
            lpSupply = lgtStakeAmount;
        }
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 blockNum = block.number.sub(pool.lastRewardBlock);
            uint256 lgtReward = blockNum.mul(lgtPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            acclgtPerShare = acclgtPerShare.add(lgtReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(acclgtPerShare).div(1e12).sub(user.rewardDebt);
    }

    function userInfoById(uint256 userid, uint256 pid) external view returns (address, address, uint256, uint256, uint256, uint256, uint256, uint256) {
        address addr = id2Address[userid];
        return userInfoByAddr(addr, pid);
    }

    function userInfoByAddr(address addr, uint256 pid) public view returns (address, address, uint256, uint256, uint256, uint256, uint256, uint256) {
        UserInfo storage o = userInfo[pid][addr];
        uint256 pending = pendinglgt(pid, addr).add(o.reward);
        return (addr, users[addr].upline, o.amount, o.downlineAmount, o.withdrawn, pending, o.refReward, o.validDirectNum);
    }

    function getRate(uint256 pid) external view returns(uint256) {
        PoolInfo storage pool = poolInfo[pid];
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        uint256 rate = pool.allocPoint.mul(52560000000000000000000).mul(pool.lpToken.totalSupply()).mul(lgtPerBlock).div(totalAllocPoint).div(lpSupply).div(lgt.balanceOf(address(pool.lpToken)));
        return rate;
    }
}