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

contract BasisGame
{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public TokenBGM = IERC20(0); 

    struct RewardRateTable
    {
        uint256 timestamp;
        uint256 totalSupply;
    }

    struct UserStateTable
    {
        uint32  Index;
        uint256 Balance;
        uint256 Timestamp;
        uint256 TotalRewards;
    }

    uint256 public totalSupply = 0;
    uint256 public StartTime = 0;
    uint256 public StartWithdrawBGMTime = 0;
    uint256 public EndTime = 0;
    uint256 private RewardsPS = 0;

    uint32 public Index = 0;
    mapping(uint32 => RewardRateTable) private RateTable;
    mapping(address => UserStateTable) private StateTable;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event EarningWithdrawn(address indexed user, uint256 reward);

	constructor(address _TokenBGM) public payable
    {
	    TokenBGM = IERC20(_TokenBGM);
        //StartTime = 1655208000;     /*2022-06-14 20:00:00*/
        StartTime = 1655006400;     /*2022-06-12 12:00:00*/
        StartWithdrawBGMTime = 1655046000; /*2022-06-12 23:00:00*/
        EndTime = StartTime + 259200;   //3 days
        RewardsPS = 6944444444444444;   //1800000000000000000000 / 259200
        Index = 0;
        RateTable[Index].timestamp = StartTime;
        RateTable[Index].totalSupply = 0;
	}

    function () payable external
    {
        require(msg.value > 0, "msg.value is 0");
        require(block.timestamp >= StartTime, "This activity hasn't started yet.");
        require(block.timestamp <= EndTime, "This activity has ended");

        if (block.timestamp >= EndTime)
        {
            msg.sender.transfer(msg.value);
            return;
        }

        Index += 1;
        RateTable[Index].timestamp = block.timestamp;
        totalSupply += msg.value;
        RateTable[Index].totalSupply = totalSupply;

        if (0 == StateTable[msg.sender].Index)
        {
            StateTable[msg.sender].TotalRewards = 0;
            StateTable[msg.sender].Balance = msg.value;
        }
        else
        {
            StateTable[msg.sender].TotalRewards = RealtimeEarning(msg.sender);
            StateTable[msg.sender].Balance += msg.value;
        }

        StateTable[msg.sender].Index = Index;
        StateTable[msg.sender].Timestamp = block.timestamp;
        
        emit Staked(msg.sender, msg.value);
    }

    function _RateTable(uint32 _Index) public view returns (uint256 timestamp, uint256 _totalSupply)
    {
        return (RateTable[_Index].timestamp, RateTable[_Index].totalSupply);
    }

    function _StateTable(address account) public view returns (uint32 _Index, uint256 balance, uint256 TotalRewards, uint256 Timestamp)
    {
        return (StateTable[account].Index, StateTable[account].Balance, StateTable[account].TotalRewards, StateTable[account].Timestamp);
    }

    function balanceOf(address account) public view returns (uint256 balance)
    {
        return StateTable[account].Balance;
    }

    function RealtimeEarning(address account) public view returns (uint256 _TotalRewards)
    {
        uint256 TotalRewards = 0;
        uint32 i = 0;
        uint256 timestamp;

        timestamp = block.timestamp;
        if (timestamp > EndTime)
        {
            timestamp = EndTime;
        }

        TotalRewards = StateTable[account].TotalRewards;

        for(i = StateTable[account].Index; i < Index; i++)
        {
            if (StateTable[account].Balance == 0 || RateTable[i].totalSupply == 0)
            {
                continue;
            }

            if (RateTable[i].timestamp <= StateTable[account].Timestamp
                && StateTable[account].Timestamp < RateTable[i + 1].timestamp)
            {
                TotalRewards += (RateTable[i + 1].timestamp - StateTable[account].Timestamp) * RewardsPS * (StateTable[account].Balance / 10000000000) / RateTable[i].totalSupply * 10000000000;
            }
            else if (StateTable[account].Timestamp <= RateTable[i].timestamp
                && StateTable[account].Timestamp < RateTable[i + 1].timestamp)
            {
                TotalRewards += (RateTable[i + 1].timestamp - RateTable[i].timestamp) * RewardsPS * (StateTable[account].Balance / 10000000000) / RateTable[i].totalSupply * 10000000000;
            }
        }

        if (i == Index && RateTable[i].timestamp < EndTime && RateTable[i].totalSupply > 0)
        {
            if (RateTable[i].timestamp < StateTable[account].Timestamp)
            {
                TotalRewards += (timestamp - StateTable[account].Timestamp) * RewardsPS * (StateTable[account].Balance / 10000000000) / RateTable[i].totalSupply * 10000000000;
            }
            else
            {
                TotalRewards += (timestamp - RateTable[i].timestamp) * RewardsPS * (StateTable[account].Balance / 10000000000) / RateTable[i].totalSupply * 10000000000;
            }
        }

        return TotalRewards;
    }

    function withdraw(uint256 amount) public payable
    {
        uint256 timestamp;

        require(amount <= StateTable[msg.sender].Balance, "Balance is not enough.");

        timestamp = block.timestamp;
        if (timestamp <= EndTime)
        {
            Index += 1;
            totalSupply -= amount;
            RateTable[Index].totalSupply = totalSupply;
            RateTable[Index].timestamp = block.timestamp;
        }
        else
        {
            timestamp = EndTime;
        }

        StateTable[msg.sender].TotalRewards = RealtimeEarning(msg.sender);
        StateTable[msg.sender].Balance -= amount;
        StateTable[msg.sender].Index = Index;
        StateTable[msg.sender].Timestamp = timestamp;

        msg.sender.transfer(amount);

        emit Withdrawn(msg.sender, amount);
    }

    function withdrawEarning() public
    {
        uint256 TotalRewards = RealtimeEarning(msg.sender);
        require(TotalRewards > 0, "Your rewards is 0");
        require(block.timestamp > StartWithdrawBGMTime, "It's not started to withdraw now");

        TokenBGM.safeTransfer(msg.sender, TotalRewards);
        StateTable[msg.sender].TotalRewards = 0;
        StateTable[msg.sender].Index = Index;
        StateTable[msg.sender].Timestamp = block.timestamp;

        emit EarningWithdrawn(msg.sender, TotalRewards);
    }
    
    function PoolBGM() public view returns (uint256 _AmountBGM)
    {
        return TokenBGM.balanceOf(address(this));
    }
}