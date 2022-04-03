/**
 *Submitted for verification at BscScan.com on 2022-04-03
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
    IERC20 private constant c_erc20_usdt_pair = IERC20(0xdBadE197Ff0f366Dcb1CA5232A0eF5ea91b05bb4);
    IERC20 private constant c_erc20 = IERC20(0x4e041E2B45b6F33E22Ae2f1e7be0Ac503f452436);

    uint256 private constant DURATION = 3000 days;
    uint256 public immutable starttime = block.timestamp;
    uint256 public immutable periodFinish = block.timestamp + DURATION;

    uint256 public immutable rewardRate = 26620370370370370;
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
    }
    mapping(address => User) public users;
    address private immutable firstAddress;
    mapping(uint256 => address) public id2Address;
    uint256 public nextUserId = 2;

    mapping (uint256 => uint256) public refRewardRates;

    constructor(address first) public {
        firstAddress = first;
        id2Address[1] = first;
        refRewardRates[0] = 0;
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
        return (addr == firstAddress || users[addr].upline != address(0));
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
        }
    }

    function _refPayout(address addr, uint256 amount) private {
        address up = users[addr].upline;
        for(uint8 i = 0; i < 1; i++) {
            if(up == address(0)) break;
            users[up].reward += amount * refRewardRates[i] / 1000;
            up = users[up].upline;
        }
    }

    function setRate(uint256 newR) external onlyOwner {
        refRewardRates[0] = newR;
    }

    function contractInfo() external view returns(uint256, uint256, uint256) {
        return (_totalSupply, c_erc20.balanceOf(address(this)), nextUserId);
    }

    function userInfo(address account) public view returns(uint256, uint256, uint256, uint256, address, uint256) {
        uint256 earned = _balances[account].mul(rewardPerToken().sub(userRewardPerTokenPaid[account])).div(1e18).add(rewards[account]);
        return (users[account].downlineAmount, _balances[account], earned, users[account].reward, users[account].upline, users[account].id);
    }

    function userInfoById(uint256 id) external view returns(uint256, uint256, uint256, uint256, address, uint256) {
        address account = id2Address[id];
        return userInfo(account);
    }
}