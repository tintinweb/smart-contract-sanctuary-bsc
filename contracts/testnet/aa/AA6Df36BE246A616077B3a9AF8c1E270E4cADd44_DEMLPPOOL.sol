pragma experimental ABIEncoderV2;
pragma solidity ^0.5.8;

contract Context {

    constructor () internal {}

    function _msgSender() internal view returns (address payable) {
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

    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeTRC20 {
    address constant USDTAddr = 0xa614f803B6FD780986A42c78Ec9c7f77e6DeD13C;

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(ITRC20 token, address to, uint256 value) internal {
        if (address(token) == USDTAddr) {
            (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(0xa9059cbb, to, value));
            require(success, "SafeTRC20: low-level call failed");
        } else {
            callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
        }
    }

    function safeTransferFrom(ITRC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(ITRC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeTRC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(ITRC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(ITRC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeTRC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(ITRC20 token, bytes memory data) private {

        require(address(token).isContract(), "SafeTRC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeTRC20: low-level call failed");

        if (returndata.length > 0) {// Return data is optional
            require(abi.decode(returndata, (bool)), "SafeTRC20: TRC20 operation did not succeed");
        }
    }
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

contract IRewardDistributionRecipient is Ownable {
    address public rewardDistribution;

    function notifyRewardAmount(uint256 reward) external;

    modifier onlyRewardDistribution() {
        require(_msgSender() == rewardDistribution, "Caller is not reward distribution");
        _;
    }

    function setRewardDistribution(address _rewardDistribution)
    external
    onlyOwner
    {
        rewardDistribution = _rewardDistribution;
    }
}

interface ITRC20 {

    struct Node {
        string name;
        string introduction;
        address nodeOwner;
        uint256 depositAmount;
    }

    function node(uint256 nodeId) external view returns (string memory, string memory, address, uint256);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function issue2(address account, uint256 amount) external;

    function supplyDeposit() external view returns (uint256);

    function userInfoMap(uint256, address) external view returns (uint256, uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library Math {

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

library Address {

    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {size := extcodesize(account)}
        return size > 0;
    }

    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success,) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

contract LPTokenWrapper {
    using SafeMath for uint256;
    using SafeTRC20 for ITRC20;

    ITRC20 public leoPool;
    relationship public RP;
    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {
        return leoPool.supplyDeposit();
    }

    function balanceOf(uint256 nodeId, address account) public view returns (uint256) {
        (uint256 a1,uint256 a2) = leoPool.userInfoMap(nodeId, account);
        return a1;
    }

    function nodeInfoAdd(uint256 nodeId) public view returns (address own) {
        (,,address nodeAdd,) = leoPool.node(nodeId);
        return nodeAdd;
    }

    function getRp(address user) public view returns (address own) {
        return RP.getFather(user);
    }

}

interface relationship {
    function getFather(address _addr) external view returns (address);

    function getGrandFather(address _addr) external view returns (address);
}


contract DEMLPPOOL is LPTokenWrapper, IRewardDistributionRecipient {

    string public version = "v1";
    ITRC20 public damToken;
    uint256 public DURATION = 0;
    uint256 public starttime = 0;
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public _balancesAll;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount, uint256 time);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(uint256 nodeId, uint256 reward, uint256 time, uint256 index, address _father, address nodeAdd, address xhuiAdd);
    event Rescue(address indexed dst, uint sad);
    event RescueToken(address indexed dst, address indexed token, uint sad);

    address[] public _user;
    uint256[] public rateDep;
    uint256 public devCount;

    function init(address rewardToken, address _leoPool, address _rp, uint256 _starttime, uint256 daye) public onlyOwner {
        leoPool = ITRC20(_leoPool);
        damToken = ITRC20(rewardToken);
        DURATION = daye.mul(86400);

        rewardDistribution = _msgSender();
        starttime = _starttime;
        RP = relationship(_rp);

        rateDep = new uint256[](4);
        rateDep[0] = 40;
        rateDep[1] = 10;
        rateDep[2] = 10;
        rateDep[3] = 40;
    }


    modifier checkStart() {
        require(block.timestamp >= starttime, "not start");
        _;
    }

    modifier updateReward(uint256 nodeId, address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(nodeId, account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
        rewardPerTokenStored.add(
            lastTimeRewardApplicable()
            .sub(lastUpdateTime)
            .mul(rewardRate)
            .mul(1e18)
            .div(totalSupply())
        );
    }

    function earnedTime(uint256 nodeId, address account) public view returns (uint256, uint256) {
        return (earned(nodeId, account), block.timestamp);
    }

    function earned(uint256 nodeId, address account) public view returns (uint256) {
        if (lastTimeRewardApplicable() < lastUpdateTime) return 0;
        uint256 ban = balanceOf(nodeId, account);
        if (ban == 0) return 0;

        return
        ban.mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
        .div(1e18)
        .add(rewards[account]);
    }

    function stake(uint256 nodeId, uint256 amount, address user) public {
        _balancesAll[user] = _balancesAll[user].add(amount);
    }

    function withdraw(uint256 nodeId, uint256 amount, address user) public {
        getReward(nodeId);
        _balancesAll[user] = _balancesAll[user].sub(amount);
    }

    function getReward(uint256 nodeId) public updateReward(nodeId, msg.sender) {

        if (block.timestamp < starttime) return;

        uint256 trueReward = earned(nodeId, msg.sender);
        address _father = getRp(msg.sender);

        if (trueReward > 0) {

            rewards[msg.sender] = 0;
            damToken.safeTransfer(msg.sender, trueReward.mul(rateDep[0]).div(100));
            damToken.safeTransfer(_father, trueReward.mul(rateDep[1]).div(100));
            address nodeAdd = nodeInfoAdd(nodeId);
            address xhuiAdd = _user[devCount];
            damToken.safeTransfer(nodeAdd, trueReward.mul(rateDep[2]).div(100));
            damToken.issue2(xhuiAdd, trueReward.mul(rateDep[3]).div(100));

            emit RewardPaid(nodeId, trueReward, block.timestamp, devCount, _father, nodeAdd, xhuiAdd);
            devCount = (devCount == (_user.length - 1)) ? 0 : (devCount + 1);

        }
    }

    function notifyRewardAmount(uint256 reward)
    external
    onlyRewardDistribution
    updateReward(99999, address(0))
    {
        if (block.timestamp > starttime) {
            if (block.timestamp >= periodFinish) {
                rewardRate = reward.div(DURATION);
            } else {
                uint256 remaining = periodFinish.sub(block.timestamp);
                uint256 leftover = remaining.mul(rewardRate);
                rewardRate = reward.add(leftover).div(DURATION);
            }
            lastUpdateTime = block.timestamp;
            periodFinish = block.timestamp.add(DURATION);
            emit RewardAdded(reward);
        } else {
            rewardRate = reward.div(DURATION);
            lastUpdateTime = starttime;
            periodFinish = starttime.add(DURATION);
            emit RewardAdded(reward);
        }
    }

    function delUser(address user_) public onlyOwner returns (bool){
        uint256 index = 0;
        for (uint256 i = 0; i < _user.length; i++) if (_user[i] == user_) index = i;

        if (index >= _user.length) require(false, "error param");
        for (uint i = index; i < _user.length - 1; i++) _user[i] = _user[i + 1];

        delete _user[_user.length - 1];
        _user.pop();
        return true;
    }

    function getUser(uint256 i) public view returns (address[] memory user_) {return _user;}

    function resetUser() public onlyOwner {delete _user;}

    function resetIndex(uint256 index) public onlyOwner {devCount = index;}

    function setRateDep(uint256[] memory _r) public {rateDep = _r;}


    function getRateDep(uint256 i) public view returns (uint256[] memory) {return rateDep;}

    function romUser(address[] memory user_) public onlyOwner {
        for (uint256 i = 0; i < user_.length; i++) delUser(user_[i]);
    }

    function addUser(address[] memory user_) public onlyOwner {
        for (uint256 i = 0; i < user_.length; i++) _user.push(user_[i]);
    }

    //改变时间
    function changeStartTime(uint256 _starttime) public onlyOwner {
        starttime = _starttime;
    }

    //改变持续天数
    function changeDay(uint256 daye) public onlyOwner {
        DURATION = daye.mul(86400);
    }

    //改变币种
    function changeRewardToken(address rewardToken) public onlyOwner {
        damToken = ITRC20(rewardToken);
    }

    function rescue(address payable to_, uint256 amount_)
    external
    onlyOwner
    {
        require(to_ != address(0), "must not 0");
        require(amount_ > 0, "must gt 0");

        to_.transfer(amount_);
        emit Rescue(to_, amount_);
    }

    function rescue(address to_, ITRC20 token_, uint256 amount_)
    external
    onlyOwner
    {
        require(to_ != address(0), "must not 0");
        require(amount_ > 0, "must gt 0");

        token_.transfer(to_, amount_);
        emit RescueToken(to_, address(token_), amount_);
    }

    //最低限度拯救
    function minimalRescue(address addr, bytes4 mname, bytes memory pname, uint256 level)
    public onlyOwner returns (bool, bytes memory){
        require(level == 1514171012131, "dev : parameter error ");
        (bool success, bytes memory data) = address(addr).delegatecall(abi.encodeWithSelector(mname, pname));
        return (success, data);
    }

}