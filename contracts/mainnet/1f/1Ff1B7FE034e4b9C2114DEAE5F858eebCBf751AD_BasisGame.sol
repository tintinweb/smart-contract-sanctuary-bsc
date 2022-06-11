/**
 *Submitted for verification at BscScan.com on 2022-06-11
*/

pragma solidity ^0.5.9 < 0.7.0;

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

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
    
 
}

library Address {
  
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
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
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract LPTokenWrapper {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public LPToken ; //Token

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
	
	constructor (IERC20 ierc20) internal {
	    LPToken = ierc20;
	}
	
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function stake(uint256 amount) public {
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        LPToken.safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) public {
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        LPToken.safeTransfer(msg.sender, amount);
    }
}

contract BasisGame is LPTokenWrapper {
    IERC20 public TokenBGS = IERC20(0); 

    struct RewardRateTable{
        uint256 timestamp;
        uint256 endTime;
        uint256 totalSupply;
        uint256 rewardRate;
    }

    struct UserStateTable{
        uint32  Index;
        uint256 Balance;
        uint256 Timestamp;
        uint256 TotalRewards;
    }

    uint256 public StartTime = 0;
    uint256 public StartWithdrawBGSTime = 0;
    uint256 private InitRewards = 0;
    uint256 public Interval = 0;
    uint32 public Index = 0;
    mapping(uint32 => RewardRateTable) private RateTable;
    mapping(address => UserStateTable) private StateTable;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event EarningWithdrawn(address indexed user, uint256 reward);

	constructor(address _lptoken, address _TokenBGS, uint256 _Interval) LPTokenWrapper(IERC20(_lptoken)) public{
	    TokenBGS = IERC20(_TokenBGS);

        InitRewards = 24000000000000000;   //0.024BGS
        Interval = _Interval;   //45 days，3888000 seconds

        Index = 0;
        //StartTime = 1655295300; /*2022-06-15 20:15:00*/
        //StartWithdrawBGSTime = 1655305200; /*2022-06-15 23:00:00*/
        StartTime = 1655036100; /*2022-06-12 20:15:00*/
        StartWithdrawBGSTime = 1655046000; /*2022-06-12 23:00:00*/

        RateTable[0].totalSupply = 0;
        RateTable[0].timestamp = StartTime;
        RateTable[0].endTime = StartTime + Interval;
        RateTable[0].rewardRate = InitRewards;
	}
	
    function SaveRateTable() private
    {        
        while(true)
        {
            Index++;

            if (block.timestamp < RateTable[Index - 1].endTime)
            {
                RateTable[Index].timestamp = block.timestamp;
                RateTable[Index].endTime = RateTable[Index - 1].endTime;
                RateTable[Index].totalSupply = totalSupply();
                RateTable[Index].rewardRate = RateTable[Index - 1].rewardRate;
                break;
            }
            else
            {
                RateTable[Index].timestamp = RateTable[Index - 1].endTime;
                RateTable[Index].endTime = RateTable[Index - 1].endTime + Interval;
                RateTable[Index].totalSupply = RateTable[Index - 1].totalSupply;
                RateTable[Index].rewardRate = RateTable[Index - 1].rewardRate * 4 / 5;
            }
        }
    }

    function _RateTable(uint32 _Index) public view returns (uint256 timestamp, uint256 endTime, uint256 totalSupply, uint256 rewardRate)
    {
        return (RateTable[_Index].timestamp, RateTable[_Index].endTime, RateTable[_Index].totalSupply, RateTable[_Index].rewardRate);
    }

    function _StateTable(address account) public view returns (uint32 _Index, uint256 balance, uint256 Timestamp, uint256 Rewards)
    {
        return (StateTable[account].Index, StateTable[account].Balance, StateTable[account].Timestamp, StateTable[account].TotalRewards);
    }

    function RealtimeEarning(address account) public view returns (uint256)
    {
        uint256 endTime;
        uint256 startTime;
        uint256 rewardRate;
        uint256 Rewards = 0;
        uint32 i = 0;

        if (StateTable[account].Index == 0 || StateTable[account].Balance == 0)
        {
            return StateTable[account].TotalRewards;
        }

        Rewards = StateTable[account].TotalRewards;
        startTime = StateTable[account].Timestamp;

        for(i = StateTable[account].Index; i < Index; i++)
        {
            if (startTime >= RateTable[i].timestamp && RateTable[i].totalSupply > 0)
            {
                Rewards += (RateTable[i + 1].timestamp - startTime) * RateTable[i].rewardRate * (StateTable[account].Balance / 10000000000) / RateTable[i].totalSupply * 10000000000;
                startTime = RateTable[i + 1].timestamp;
            }
        }

        if (RateTable[Index].totalSupply == 0)
        {
            return Rewards;
        }

        startTime = RateTable[Index].timestamp;
        endTime = RateTable[Index].endTime;
        rewardRate = RateTable[Index].rewardRate;

        while(true)
        {
            if (block.timestamp < endTime)
            {
                require(block.timestamp >= startTime, "Internal error");
                if (startTime < StateTable[account].Timestamp)
                {
                    startTime = StateTable[account].Timestamp;
                }
                Rewards += (block.timestamp - startTime) * rewardRate * (StateTable[account].Balance / 10000000000) / RateTable[Index].totalSupply * 10000000000;
                break;
            }
            
            require(endTime >= startTime, "Internal error");
            if (startTime < StateTable[account].Timestamp && endTime > StateTable[account].Timestamp)
            {
                Rewards += (endTime - StateTable[account].Timestamp) * rewardRate * (StateTable[account].Balance / 10000000000) / RateTable[Index].totalSupply * 10000000000;    
            }
            else if (startTime > StateTable[account].Timestamp)
            {
                Rewards += (endTime - startTime) * rewardRate * (StateTable[account].Balance / 10000000000) / RateTable[Index].totalSupply * 10000000000;
            }
            
            startTime = endTime;
            endTime += Interval;
            rewardRate = rewardRate * 4 / 5;
        }

        return Rewards;
    }

    // stake visibility is public as overriding LPTokenWrapper's stake() function
    function stake(uint256 amount) public
    { 
        require(amount > 0, "Cannot stake 0");
        require(block.timestamp >= StartTime, "This activity hasn't started yet.");
        super.stake(amount);

        SaveRateTable();
        
        StateTable[msg.sender].TotalRewards = RealtimeEarning(msg.sender);
        StateTable[msg.sender].Index = Index;
        StateTable[msg.sender].Timestamp = block.timestamp;
        StateTable[msg.sender].Balance = balanceOf(msg.sender);

        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) public
    {
        require(amount > 0, "Cannot withdraw 0");
        super.withdraw(amount);
        
        SaveRateTable();
        
        StateTable[msg.sender].TotalRewards = RealtimeEarning(msg.sender);
        StateTable[msg.sender].Index = Index;
        StateTable[msg.sender].Timestamp = block.timestamp;
        StateTable[msg.sender].Balance = balanceOf(msg.sender);

        emit Withdrawn(msg.sender, amount);
    }

    function withdrawEarning() public
    {
        uint256 Reward = RealtimeEarning(msg.sender);
        require(Reward > 0, "Your rewards is 0");
        require(block.timestamp > StartWithdrawBGSTime, "It's not started to withdraw now");
        
        TokenBGS.safeTransfer(msg.sender, Reward);

        StateTable[msg.sender].TotalRewards = 0;
        StateTable[msg.sender].Index = Index;
        StateTable[msg.sender].Timestamp = block.timestamp;

        emit EarningWithdrawn(msg.sender, Reward);
    }
    
    function PoolBGS() public view returns (uint256 _AmountBGS)
    {
        return TokenBGS.balanceOf(address(this));
    }
}