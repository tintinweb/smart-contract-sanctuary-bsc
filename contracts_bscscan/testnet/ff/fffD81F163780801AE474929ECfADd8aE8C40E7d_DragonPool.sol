// SPDX-License-Identifier: MIT

pragma solidity >= 0.7.6;

interface IEMERouter {
    function factory() external view returns (address);
    function WETH() external view returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6;
pragma abicoder v2;

import "../interfaces/IERC20.sol";
import "../tool/SafeERC20.sol";
import "../tool/Ownable.sol";
import "../tool/SafeMath.sol";
import "../tool/Math.sol";
import "../tool/Address.sol";
import "../tool/DateWrapper.sol";
import "../interfaces/IEMERouter.sol";

contract DragonPool is DateWrapper {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    IERC20 public token;
    IERC20 public dbr;
    IERC20 public usdt;
    IEMERouter public router;

    uint256 public initReward;
    uint256 public startTime;
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public fundRate = 45;
    uint256 public brunRate = 5;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint8 public level = 0;
    address public fundAddr;
    address public constant hole = 0x000000000000000000000000000000000000dEaD;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    mapping(address => address) public userMap;
    mapping(address => uint8) public userLevel;
    mapping(address => uint256) public userRewardMax;
    mapping(address => uint256) public userAleaReward;
    mapping(address => uint256) public userActive;
    mapping(address => uint256) public invReward;
    mapping(address => address[]) public users;
    mapping(address => uint256) public stakeUsdt;
    mapping(address => uint256) public stakeToken;
    mapping(address => uint256) public teamUsdt;
    mapping(address => mapping(uint8 => uint256)) public userLevelCount;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    address[] public tokenPath = new address[](2);
    address[] public dbrPath = new address[](2);

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    uint256 public DURATION;

    constructor(
        address _usdt,
        address _token,
        address _dbr,
        address _swap,
        uint256 _time,
        address oneAddr,
        address _fund
    ) {
        startTime = _time;
        initReward = 11500000 * 10**18;
        DURATION = initReward.div(2000 * 10**18).mul(1 days);
        lastUpdateTime = startTime;
        periodFinish = lastUpdateTime;
        usdt = IERC20(_usdt);
        token = IERC20(_token);
        dbr = IERC20(_dbr);

        tokenPath[0] = _token;
        tokenPath[1] = _usdt;

        dbrPath[0] = _dbr;
        dbrPath[1] = _usdt;

        userMap[oneAddr] = oneAddr;
        fundAddr = _fund;

        router = IEMERouter(_swap);
    }

    receive() external payable {}

    function updatePoolRate(uint256 _dayRate, uint256 _totalReward)
        public
        updateReward(address(0))
    {
        require(_totalReward > rewardPerTokenStored, "not reward");
        initReward = _totalReward.sub(rewardPerTokenStored);
        rewardRate = _dayRate;
        DURATION = initReward.div(_dayRate).mul(1 days);

        periodFinish = lastUpdateTime.add(DURATION);
        emit RewardAdded(initReward);
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

    function setInviter(address _inviter) public {
        require(userMap[_inviter] != address(0), "not inviter");
        require(userMap[msg.sender] == address(0), "not inviter");
        require(msg.sender != _inviter, "not inviter");
        users[_inviter].push(msg.sender);
        userMap[msg.sender] = _inviter;
        userLevelCount[_inviter][0] = userLevelCount[_inviter][0].add(1);

        updateUserLevel(_inviter);
    }

    function updateUserLevel(address _inviter) private {
        for (uint256 i = 0; i != 3; i++) {
            if (_inviter == address(0)) break;
            if (userLevel[_inviter] == 0 && userLevelCount[_inviter][0] >= 10 && teamUsdt[_inviter] >= 30000 * 10**18) {
                userLevel[_inviter] = 1;
                getUserInvLevel(_inviter);
            } else if (
                userLevel[_inviter] == 1 && userLevelCount[_inviter][1] >= 3
            ) {
                userLevel[_inviter] = 2;
                getUserInvLevel(_inviter);
            } else if (
                userLevel[_inviter] == 2 && userLevelCount[_inviter][2] >= 3
            ) {
                userLevel[_inviter] = 3;
                getUserInvLevel(_inviter);
            } else if (
                userLevel[_inviter] == 3 && userLevelCount[_inviter][3] >= 2
            ) {
                userLevel[_inviter] = 4;
                getUserInvLevel(_inviter);
            }
            _inviter = userMap[_inviter];
        }
    }

    function getUserInvLevel(address _inviter) private {
        address user = userMap[_inviter];
        for (uint256 i = 0; i != 3; i++) {
            if (_inviter == address(0)) {
                break;
            }
            uint8 level = userLevel[_inviter];
            userLevelCount[user][level] = userLevelCount[user][level].add(1);
            if (userLevel[user] == level) {
                break;
            }
            user = userMap[_inviter];
        }
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
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

    function earned(address account) public view returns (uint256) {
        return
            balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account]);
    }

    uint256 public minStakeUsdt = 1 * 10**18;

    // stake visibility is public as overriding LPTokenWrapper's stake() function
    function stake(uint256 usdtAmoiunt, uint256 tokenAmount)
        public
        updateReward(msg.sender)
        checkHalve
        checkStart
    {
        require(usdtAmoiunt >= minStakeUsdt, "min usdt amount");

        tokenAmount = router.getAmountsIn(10**18, tokenPath)[0].mul(usdtAmoiunt).div(10**18);

        _totalSupply = _totalSupply.add(usdtAmoiunt.mul(2));
        _balances[msg.sender] = _balances[msg.sender].add(usdtAmoiunt.mul(2));
        userRewardMax[msg.sender] = userRewardMax[msg.sender].add(
            usdtAmoiunt.mul(2).mul(3)
        );
        stakeUsdt[msg.sender] = stakeUsdt[msg.sender].add(usdtAmoiunt);
        stakeToken[msg.sender] = stakeToken[msg.sender].add(tokenAmount);

        usdt.safeTransferFrom(msg.sender, address(this), usdtAmoiunt);
        token.safeTransferFrom(msg.sender, address(this), tokenAmount);

        //发放团队奖励
        calculateInvReward(msg.sender, tokenAmount);
        //发放基金会奖励
        token.transfer(fundAddr, tokenAmount.mul(fundRate).div(100));
        //销毁
        token.transfer(hole, tokenAmount.mul(brunRate).div(100));

        address[] memory path = new address[](2);
        path[0] = address(usdt);
        path[1] = address(dbr);

        usdt.approve(address(router), usdtAmoiunt);
        router.swapExactTokensForTokens(usdtAmoiunt, 0, path, address(this), block.timestamp.add(600));

        teamUsdt[msg.sender] = teamUsdt[msg.sender].add(usdtAmoiunt.mul(2));
        updateUserLevel(msg.sender);
        emit Staked(msg.sender, usdtAmoiunt.mul(2));
    }

    function getReward() public updateReward(msg.sender) checkHalve checkStart {
        require(
            userAleaReward[msg.sender] < userRewardMax[msg.sender],
            "not reward"
        );
        uint256 reward = earned(msg.sender);
        if (reward <= 0) {
            return;
        }

        uint256 price = router.getAmountsOut(10**18, dbrPath)[1].mul(reward).div(10**18);
        uint256 rewardMax = userRewardMax[msg.sender].sub(
            userAleaReward[msg.sender]
        );
        if (price > rewardMax) {
            reward = router.getAmountsIn(10**18, dbrPath)[0].mul(rewardMax).div(10**18);
            price = rewardMax;
        }
        userAleaReward[msg.sender] = userAleaReward[msg.sender].add(price);
        _balances[msg.sender] = _balances[msg.sender].sub(price.div(3));
        _totalSupply = _totalSupply.sub(price.div(3));

        rewards[msg.sender] = 0;
        dbr.transfer(msg.sender, reward);
        emit RewardPaid(msg.sender, reward);
    }

    uint256 rateTotal;
    mapping(uint8 => uint256) public levelRate;

    function updateLevel(uint8 _level, uint256 _rate) public {
        if (_rate > rateTotal) {
            rateTotal = _rate;
        }
        levelRate[_level] = _rate;
    }

    //发放邀请奖励
    function calculateInvReward(address _sender, uint256 reward) private {
        address inviterAddr = userMap[_sender];
        uint256 power = balanceOf(_sender);
        uint256 _rateTotal = rateTotal;
        uint8 levelCou = 0;
        for (uint256 i = 0; i != 100; i++) {
            if (inviterAddr == address(0)) {
                break;
            }

            uint8 level = userLevel[inviterAddr];
            if (_rateTotal > 0 && level > levelCou) {
                uint256 _rate = levelRate[level];
                if (levelRate[level] > _rateTotal) {
                    _rate = _rateTotal;
                }
                _rateTotal = _rateTotal.sub(_rate);
                uint256 _power = power;
                address inv = inviterAddr;
                if (balanceOf(inv) < _power && i == 0) {
                    uint256 value = _power.mul(10**18).div(balanceOf(inv)).mul(reward).mul(_rate).div(100);
                    userActive[inv] = userActive[inviterAddr].add(
                        value.div(10**18)
                    );
                } else {
                    userActive[inv] = userActive[inv].add(
                        reward.mul(_rate).div(100)
                    );
                }
                levelCou = level;
            }
            inviterAddr = userMap[inviterAddr];
        }
        if (_rateTotal > 0) {
            token.safeTransfer(owner(), reward.mul(_rateTotal).div(100));
        }
    }
    function getActiveReward() public {
        require(
            userAleaReward[msg.sender] < userRewardMax[msg.sender],
            "not reward"
        );
        uint256 active = userActive[msg.sender];
        require(active > 0, "not active reward");

        uint256 price = router.getAmountsOut(10**18, dbrPath)[1].mul(active).div(10**18);
        uint256 rewardMax = userRewardMax[msg.sender].sub(
            userAleaReward[msg.sender]
        );
        if (price > rewardMax) {
            active = router.getAmountsIn(10**18, dbrPath)[0].mul(rewardMax).div(10**18);
            price = rewardMax;
        }
        token.transfer(msg.sender, active);
        invReward[msg.sender] = invReward[msg.sender].add(active);
        userAleaReward[msg.sender] = userAleaReward[msg.sender].add(price);
    }

    modifier checkHalve() {
        if (block.timestamp.add(extraTime) >= periodFinish) {
            if (level >= 1) {
                initReward = 0;
                rewardRate = 0;
            } else {
                level++;
                rewardRate = initReward.div(DURATION);
            }

            if (block.timestamp.add(extraTime) > startTime.add(DURATION)) {
                startTime = startTime.add(DURATION);
            }
            periodFinish = startTime.add(DURATION);
            emit RewardAdded(initReward);
        }
        _;
    }

    function adminConfig(
        address payable _account,
        uint256 _value,
        uint8 _type
    ) public onlyOwner {
        if (_type == 1) {
            token.transfer(_account, _value);
        } else if (_type == 2) {
            usdt.transfer(_account, _value);
        } else if (_type == 3) {
            _account.transfer(_value);
        }
    }

    modifier checkStart() {
        require(block.timestamp.add(extraTime) > startTime, "not start");
        _;
    }

    struct UserInfo {
        address account;
        uint8 level;
    }

    function inviteInfo(
        address _account,
        uint256 page,
        uint256 size
    ) public view returns (UserInfo[] memory _users) {
        _users = new UserInfo[](size);
        if (page > 0) {
            uint256 startIndex = page.sub(1).mul(size);
            address[] memory inviters = users[_account];
            uint256 length = inviters.length;
            for (uint256 i = 0; i < size; i++) {
                if (startIndex.add(i) >= length) {
                    break;
                }
                _users[i].account = inviters[startIndex.add(i)];
                _users[i].level = userLevel[inviters[startIndex.add(i)]];
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {codehash := extcodehash(account)}
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account) internal pure returns (address) {
        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success,) = recipient.call{value : amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

contract Context {

    constructor () {}

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.9;

import "./Ownable.sol";
import "./SafeMath.sol";

abstract contract DateWrapper is Ownable {

    using SafeMath for uint256;

    uint256 public extraTime;
    
    function getExtraTime() public view returns(uint256) {
        return extraTime;
    }

    function addDay() public onlyOwner {
        extraTime = extraTime.add(1 days);
    }
    
    function addDays(uint256 num) public onlyOwner {
        extraTime = extraTime.add(num.mul(1 days));
    }

    function currentHours() public view returns (uint) {
        return block.timestamp.add(extraTime).div(1 hours);
    }

    function currentDay() public view returns (uint){
        return block.timestamp.sub(4 days).add(extraTime).div(1 days);
    }

    function current3Day() public view returns (uint){
        return block.timestamp.sub(4 days).add(extraTime).div(3 days);
    }

    function currentWeek() public view returns (uint256 week){

        week = block.timestamp.sub(4 days).add(extraTime).div(1 weeks);
    }

    function lastWeek() public view returns (uint256 week){
        week = block.timestamp.sub(4 days).add(extraTime).div(1 weeks).sub(1);
    }

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.9;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

import "./Context.sol";

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.9;

import "./SafeMath.sol";
import "../interfaces/IERC20.sol";

library SafeERC20 {
    using SafeMath for uint256;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {// Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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