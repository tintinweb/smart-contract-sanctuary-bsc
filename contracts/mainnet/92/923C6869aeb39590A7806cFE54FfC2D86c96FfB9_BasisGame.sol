/**
 *Submitted for verification at BscScan.com on 2022-06-24
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

contract LPTokenWrapper
{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public TokenBGS ; //Token

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
	
	constructor (IERC20 ierc20) internal {
	    TokenBGS = ierc20;
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
        TokenBGS.safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) public {
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        TokenBGS.safeTransfer(msg.sender, amount);
    }
}

contract BasisGame  is LPTokenWrapper
{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public TokenBGM = IERC20(0); 

    struct RewardRateTable
    {
        uint256 TimePoint;
        uint256 totalBonus;
        uint256 totalStake;
    }

    struct UserStateTable
    {
        uint32  Index;
        uint256 Balance;
        uint256 Timestamp;
        uint256 TotalRewards;
    }

    address payable public owner;
    uint256 public  StartTime = 0;
    uint256 private Time = 0;
    uint256 private totalBonus = 0;

    uint32 public Index = 0;
    mapping(uint32 => RewardRateTable) private RateTable;
    mapping(address => UserStateTable) private StateTable;

    event Staked(address indexed user, uint256 amount);
    event Shareout(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event EarningWithdrawn(address indexed user, uint256 reward);

	constructor(address _TokenBGS,address _TokenBGM) LPTokenWrapper(IERC20(_TokenBGS)) public
    {
        owner = msg.sender;
	    TokenBGM = IERC20(_TokenBGM);
        StartTime = block.timestamp; 
        Index = 0;
        Time = 4 * 3600;           //(4 + 8)
        RateTable[0].totalBonus = 0;
        RateTable[0].totalStake = 0;
        RateTable[0].TimePoint = NextTimePoint();
	}

    function NextTimePoint() public view returns (uint256 _TimePoint)
    {
        uint256 TimePoint;
        uint256 Seconds = block.timestamp % 86400;    //1 day
        uint256 Days = block.timestamp / 86400;    //1 day
        if (Seconds < Time)
        {
            TimePoint = Days * 86400 + Time;
        }
        else
        {
            TimePoint = (Days + 1) * 86400 + Time;
        }

        return TimePoint;
    }

    function _RateTable(uint32 _Index) public view returns (uint256 TimePoint, uint256 _totalBonus, uint256 _totalStake)
    {
        return (RateTable[_Index].TimePoint, RateTable[_Index].totalBonus, RateTable[_Index].totalStake);
    }

    function _StateTable(address account) public view returns (uint32 _Index, uint256 balance, uint256 Timestamp)
    {
        return (StateTable[account].Index, StateTable[account].Balance, StateTable[account].Timestamp);
    }

    function RealtimeEarning(address account) public view returns (uint256)
    {
        uint256 TotalRewards = 0;
        uint32 i = 0;

        TotalRewards = StateTable[account].TotalRewards;

        for(i = StateTable[account].Index; i <= Index; i++)
        {   
            if (block.timestamp < RateTable[i].TimePoint)
            {
                break;
            }

            if (StateTable[account].Timestamp > RateTable[i].TimePoint)
            {
                continue;
            }

            if (StateTable[account].Balance > 0 && RateTable[i].totalStake > 0)
            {
                TotalRewards += RateTable[i].totalBonus * (StateTable[account].Balance / 10000000000) / RateTable[i].totalStake * 10000000000;
            }
        }

        return TotalRewards;
    }
    
    function stake(uint256 amount) public
    { 
        require(amount > 0, "Cannot stake 0");
        super.stake(amount);

        uint256 TimePoint = NextTimePoint();
        
        if (TimePoint == RateTable[Index].TimePoint)
        {
            RateTable[Index].totalStake = totalSupply();
        }
        else
        {   
            Index++;
            RateTable[Index].totalBonus = 0;
            RateTable[Index].totalStake = totalSupply();
            RateTable[Index].TimePoint = TimePoint;
        }

        StateTable[msg.sender].TotalRewards = RealtimeEarning(msg.sender);
        StateTable[msg.sender].Balance += balanceOf(msg.sender);
        StateTable[msg.sender].Index = Index;
        StateTable[msg.sender].Timestamp = block.timestamp;

        emit Staked(msg.sender, amount);
    }

    function shareout(uint256 amount) public
    {
        require(amount > 0, "Cannot stake 0");
        TokenBGM.safeTransferFrom(msg.sender, address(this), amount);

        uint256 TimePoint = NextTimePoint();
        
        if (TimePoint == RateTable[Index].TimePoint)
        {
            RateTable[Index].totalBonus += amount;
        }
        else
        {   
            Index++;
            RateTable[Index].totalBonus = amount;
            RateTable[Index].totalStake = totalSupply();
            RateTable[Index].TimePoint = TimePoint;
        }

        emit Shareout(msg.sender, amount);
    }

    function withdraw(uint256 amount) public
    {
        require(amount <= StateTable[msg.sender].Balance, "Balance is not enough.");
        super.withdraw(amount);

        uint256 TimePoint = NextTimePoint();
        
        if (TimePoint == RateTable[Index].TimePoint)
        {
            RateTable[Index].totalStake = totalSupply();
        }

        StateTable[msg.sender].TotalRewards = RealtimeEarning(msg.sender);
        StateTable[msg.sender].Balance -= amount;
        StateTable[msg.sender].Index = Index;
        StateTable[msg.sender].Timestamp = block.timestamp;

        emit Withdrawn(msg.sender, amount);
    }

    function withdrawEarning() public
    {
        uint256 Earning = RealtimeEarning(msg.sender);
        require(Earning > 0, "Your earning is 0");

        TokenBGM.safeTransfer(msg.sender, Earning);
        StateTable[msg.sender].TotalRewards = 0;
        StateTable[msg.sender].Index = Index;
        StateTable[msg.sender].Timestamp = block.timestamp;

        emit EarningWithdrawn(msg.sender, Earning);
    }
}