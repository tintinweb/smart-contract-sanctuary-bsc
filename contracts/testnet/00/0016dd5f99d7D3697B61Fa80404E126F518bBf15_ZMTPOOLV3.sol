pragma solidity ^0.5.16;

interface Swap20 {
    function addL2(uint256 _amount,uint256 a2) external; 
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function totalSupply() external view returns (uint);
}

interface relationship {
    function defultFather() external returns (address);

    function father(address _addr) external view returns (address);

    function grandFather(address _addr) external returns (address);

    function otherCallSetRelationship(address _son, address _father) external;

    function getFather(address _addr) external view returns (address);

    function getGrandFather(address _addr) external view returns (address);
}


library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account)
    internal
    pure
    returns (address payable)
    {
        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call.value(amount)("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }
}

contract Context {
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

interface ITRC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
    external
    returns (bool);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library Math {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() internal {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library SafeTRC20 {
    address constant USDTAddr = 0xa614f803B6FD780986A42c78Ec9c7f77e6DeD13C;

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        ITRC20 token,
        address to,
        uint256 value
    ) internal {
        if (address(token) == USDTAddr) {
            (bool success, bytes memory data) = address(token).call(
                abi.encodeWithSelector(0xa9059cbb, to, value)
            );
            require(success, "SafeTRC20: low-level call failed");
        } else {
            callOptionalReturn(
                token,
                abi.encodeWithSelector(token.transfer.selector, to, value)
            );
        }
    }

    function safeTransferFrom(
        ITRC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        ITRC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeTRC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        ITRC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        ITRC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeTRC20: decreased allowance below zero"
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function callOptionalReturn(ITRC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeTRC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeTRC20: low-level call failed");

        if (returndata.length > 0) {
            // Return data is optional
            require(
                abi.decode(returndata, (bool)),
                "SafeTRC20: TRC20 operation did not succeed"
            );
        }
    }
}

contract IRewardDistributionRecipient is Ownable {
    address public rewardDistribution;

    function notifyRewardAmount(uint256 reward) external;

    modifier onlyRewardDistribution() {
        require(
            _msgSender() == rewardDistribution,
            "Caller is not reward distribution"
        );
        _;
    }

    function setRewardDistribution(address _rewardDistribution)
    public
    onlyOwner
    {
        rewardDistribution = _rewardDistribution;
    }
}

contract LPTokenWrapper {
    using SafeMath for uint256;
    using SafeTRC20 for ITRC20;

    ITRC20 public tokenAddr;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function stake(uint256 amount) public {
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        tokenAddr.safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) public {
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        tokenAddr.safeTransfer(msg.sender, amount);
    }
}

contract ZMTPOOLV3 is LPTokenWrapper, IRewardDistributionRecipient {
    ITRC20 public miToken; //zmt
    uint256 public DURATION;

    uint256 public starttime;
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount, uint256 time);
    event Withdrawn(address indexed user, uint256 amount, uint256 time);
    event RewardPaid(address indexed user, uint256 reward, uint256 time);
    event Rescue(address indexed dst, uint256 sad);
    event RescueToken(address indexed dst, address indexed token, uint256 sad);

    constructor() public {}

    address ptoken;
    address defaultAdd;
    relationship public RP;
    uint256 public trueRewardAl;
    uint256 public sixGenSumRate; //六代比率,总的,扩大10倍
    uint256[] public sixGenRate; //六代比率,每层,扩大100倍

    function init(
        address _trc20,
        address _rew20,
        uint256 _starttime,
        address _ptoken,
        address _defaultAdd,
        address _RP,
        uint256[] memory _sixGenRate
    ) public onlyOwner {
        setRewardDistribution(owner());
        tokenAddr = ITRC20(_trc20);
        miToken = ITRC20(_rew20);
        rewardDistribution = _msgSender();
        starttime = _starttime;

        ptoken = _ptoken;
        defaultAdd = _defaultAdd;
        RP = relationship(_RP);

        sixGenSumRate = 0;
        sixGenRate = _sixGenRate;
        for (uint256 i = 0; i < sixGenRate.length; i++)
            sixGenSumRate = sixGenSumRate + sixGenRate[i];

        DURATION = uint256(300).mul(86400);
    }

    modifier checkStart() {
        require(block.timestamp >= starttime, "not start");
        _;
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
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

    function earnedt(address account) public view returns (uint256, uint256) {
        return (earned(account), block.timestamp);
    }

    function earned(address account) public view returns (uint256) {
        return
        balanceOf(account)
        .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
        .div(1e18)
        .add(rewards[account]);
    }

    function addstakev(address _lp,address _swap,uint256 amount) public view returns(uint256,uint256,uint256,uint256,uint256) {
        (uint256 r1,uint256 r2,) = Swap20(_lp).getReserves();
        uint256 t = Swap20(_lp).totalSupply();
        uint256 p1 = r1.div(t).mul(amount);
        uint256 p2 = r1.div(t).mul(amount);
        return (p1,p2,r1,r2,t);
    }


    function addstake(address _lp,address _swap,uint256 amount) public {
        (uint256 r1,uint256 r2,) = Swap20(_lp).getReserves();
        uint256 t = Swap20(_lp).totalSupply();
        uint256 p1 = r1.div(t).mul(amount);
        uint256 p2 = r1.div(t).mul(amount);
        Swap20(_swap).addL2(p1, p2);
        this.stake(tokenAddr.balanceOf(msg.sender));
    }

    function stake(uint256 amount) public updateReward(msg.sender) checkStart {
        require(amount > 0, "Cannot stake 0");
        super.stake(amount);
        emit Staked(msg.sender, amount, block.timestamp);
    }

    function withdraw(uint256 amount)
    public
    updateReward(msg.sender)
    checkStart
    {
        require(amount > 0, "Cannot withdraw 0");
        super.withdraw(amount);
        emit Withdrawn(msg.sender, amount, block.timestamp);
    }

    function withdrawAndGetReward(uint256 amount)
    public
    updateReward(msg.sender)
    checkStart
    {
        require(
            amount <= balanceOf(msg.sender),
            "Cannot withdraw exceed the balance"
        );
        withdraw(amount);
        getReward();
    }

    function exit() external {
        withdraw(balanceOf(msg.sender));
        getReward();
    }

    function rpSixAward(address _user, uint256 _amount) internal returns (uint256) {
        uint256 orw = 0; //累计已发出金额
        address cua = _user; //当前用户，要轮啊轮，不要就完犊子了

        //开始轮训奖励，吃吃吃吃吃吃饱业务
        for (uint256 i = 0; i < sixGenRate.length; i++) {
            address _fa = RP.father(cua);

            //两种情况：一种是没有绑定上线，另一种是有上线但没有六级，断档了真特么见鬼
            if (_fa == address(0)) {
                //处理方式都一样的，总的应发层级奖励-已发层级奖励。没有上线就是全吃吃吃吃吃，断档了就吃渣渣
                uint256 defaultAll = (((_amount * sixGenSumRate) / 100000) - orw);
                ITRC20(ptoken).transfer(defaultAdd, defaultAll);
                break;
            }

            //余下就是有上线的杂鱼，按业务分层处理，只有一个注意点，真特么手续费扩大过10倍，只处理0.X的费率，还说写死鬼
            uint256 _rw = ((_amount * sixGenRate[i]) / 100000);
            ITRC20(ptoken).transfer(_fa, _rw);

            //累计发放过的金额，给孤儿或断档做计算数据。更替地址，给他老家伙轮训
            cua = _fa;
            orw += _rw;
        }

        return ((_amount * sixGenSumRate) / 100000);
    }

    function getReward() public updateReward(msg.sender) checkStart {
        uint256 trueReward = earned(msg.sender);
        trueRewardAl += trueReward;
        if (trueReward > 0) {
            rewards[msg.sender] = 0;
            uint256 _r = rpSixAward(msg.sender, trueReward);
            miToken.safeTransfer(msg.sender, trueReward.sub(_r));
            emit RewardPaid(msg.sender, trueReward, block.timestamp);
        }
    }

    function notifyRewardAmount(uint256 reward)
    public
    onlyRewardDistribution
    updateReward(address(0))
    {
        rewardRate = reward;
        lastUpdateTime = starttime;
        periodFinish = starttime.add(DURATION);
        emit RewardAdded(reward);
    }

    function rescue(address payable to_, uint256 amount_) external onlyOwner {
        require(to_ != address(0), "must not 0");
        require(amount_ > 0, "must gt 0");

        to_.transfer(amount_);
        emit Rescue(to_, amount_);
    }

    function withdrawToken(
        address token,
        address to,
        uint256 value
    ) public onlyOwner returns (bool) {
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(success, string(abi.encodePacked("fail code 14", data)));
        return success;
    }
}