/**
 *Submitted for verification at BscScan.com on 2022-10-13
*/

pragma solidity 0.6.12;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
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
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

library Math {
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
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

contract Ownable {
    address public owner;

    constructor () public{
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}

contract LPPool is Ownable {
    IERC20 private constant c_erc20_usdt_pair = IERC20(0x30bd8cB52a5BE2ebfbb45F722cc9C39C526e07f1);
    IERC20 private constant c_erc20 = IERC20(0xeFa42568A6Cb3E0e5Bc6476Ee57aA21b5e18A277);

    uint256 private constant DURATION = 1825 days;
    uint256 public immutable starttime = block.timestamp;
    uint256 public immutable periodFinish = block.timestamp + DURATION;

    uint256 public immutable rewardRate = 38051750380517503;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    using SafeMath for uint256;

    struct User {
        uint256 id;
        address upline;
        uint256 reward;
        uint256 downlineAmount;
        uint256 withdrawn;
    }
    mapping(address => User) public users;
    mapping(uint256 => address) public id2Address;
    uint256 public nextUserId = 2;

    struct RefInfo {
        uint256 minAmount;
        uint256 refRewardRate;
    }
    mapping (uint256 => RefInfo) public refRewardRates;
    
    constructor(address first) public {
        users[first].id = 1;
        id2Address[1] = first;

        refRewardRates[0] = RefInfo(1000*10**18, 50);
        refRewardRates[1] = RefInfo(2000*10**18, 50);
        refRewardRates[2] = RefInfo(3000*10**18, 50);
        refRewardRates[3] = RefInfo(4000*10**18, 50);
        refRewardRates[4] = RefInfo(5000*10**18, 50);
        refRewardRates[5] = RefInfo(6000*10**18, 50);
        refRewardRates[6] = RefInfo(7000*10**18, 50);
        refRewardRates[7] = RefInfo(8000*10**18, 50);
        refRewardRates[8] = RefInfo(9000*10**18, 50);
        refRewardRates[9] = RefInfo(10000*10**18, 50);
        refRewardRates[10] = RefInfo(11000*10**18, 50);
        refRewardRates[11] = RefInfo(12000*10**18, 50);
        refRewardRates[12] = RefInfo(13000*10**18, 50);
        refRewardRates[13] = RefInfo(14000*10**18, 50);
        refRewardRates[14] = RefInfo(15000*10**18, 50);
        refRewardRates[15] = RefInfo(16000*10**18, 50);
        refRewardRates[16] = RefInfo(17000*10**18, 50);
        refRewardRates[17] = RefInfo(18000*10**18, 50);
        refRewardRates[18] = RefInfo(19000*10**18, 50);
        refRewardRates[19] = RefInfo(20000*10**18, 50);
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        
        rewards[account] = _balances[account].mul(rewardPerTokenStored.sub(userRewardPerTokenPaid[account])).div(1e18).add(rewards[account]);
        userRewardPerTokenPaid[account] = rewardPerTokenStored;
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return rewardPerTokenStored.add( lastTimeRewardApplicable().sub(lastUpdateTime).mul(rewardRate).mul(1e18).div(_totalSupply) );
    }

    function register(address referrer) public {
        require(!isUserExists(msg.sender), "user already register");
        require(isUserExists(referrer), "referrer not exists");
        uint256 id = nextUserId++;
        users[msg.sender].id = id;
        users[msg.sender].upline = referrer;
        id2Address[id] = msg.sender;
    }

    function stake(address referrer, uint256 amount) external updateReward(msg.sender) {
        require(amount > 0, 'LPPool: Cannot stake 0');
        c_erc20_usdt_pair.transferFrom(msg.sender, address(this), amount);
        if (!isUserExists(msg.sender)) {
            register(referrer);
        }
        _mint(msg.sender, amount);
    }

    function isUserExists(address addr) public view returns (bool) {
        return (users[addr].id != 0);
    }

    function _mint(address account, uint256 amount) internal {
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        _addGen(account, amount);
    }

    function _addGen(address addr, uint256 amount) private {
        address up = users[addr].upline;
        for(; up != address(0);) {
            users[up].downlineAmount += amount;
            up = users[up].upline;
        }
    }

    function withdraw(uint256 amount) public updateReward(msg.sender) {
        if (amount > 0) {
            _burn(msg.sender, amount);
            c_erc20_usdt_pair.transfer(msg.sender, amount);
        }
    }

    function _burn(address account, uint256 amount) internal {
        _balances[account] = _balances[account].sub(amount, "burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        _removeGen(account, amount);
    }

    function _removeGen(address addr, uint256 amount) private {
        address up = users[addr].upline;
        for(; up != address(0);) {
            users[up].downlineAmount -= amount;
            up = users[up].upline;
        }
    }

    function exit() external {
        withdraw(_balances[msg.sender]);
        getReward();
    }

    function getReward() public updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            _refPayout(msg.sender, reward);
            rewards[msg.sender] = 0;
        }

        reward += users[msg.sender].reward;
        users[msg.sender].reward = 0;

        if (reward > 0) {
            c_erc20.transfer(msg.sender, reward);
            users[msg.sender].withdrawn += reward;
        }
    }

    function _refPayout(address addr, uint256 amount) private {
        address up = users[addr].upline;
        for(uint256 i = 0; i < 20; i++) {
            if(up == address(0)) break;
            if (_balances[up] >= refRewardRates[i].minAmount){
                users[up].reward += amount * refRewardRates[i].refRewardRate / 1000;
            }
            up = users[up].upline;
        }
    }

    function setRate(uint256 i, uint256 m, uint256 newR) external onlyOwner {
        refRewardRates[i].minAmount = m;
        refRewardRates[i].refRewardRate = newR;
    }

    function contractInfo() external view returns(uint256, uint256, uint256) {
        return (_totalSupply, c_erc20.balanceOf(address(this)), nextUserId);
    }

    function userInfo(address account) public view returns(uint256, address, uint256, uint256, uint256, uint256, uint256) {
        User storage o = users[account];
        uint256 earned = getAddressReward(account);
        return (o.id, o.upline, _balances[account], earned, o.reward, o.downlineAmount, o.withdrawn);
    }

    function getAddressReward(address account) public view returns(uint256) {
        return _balances[account].mul(rewardPerToken().sub(userRewardPerTokenPaid[account])).div(1e18).add(rewards[account]);
    }

    function userInfoById(uint256 id) external view returns(uint256, address, uint256, uint256, uint256, uint256, uint256) {
        address account = id2Address[id];
        return userInfo(account);
    }
}