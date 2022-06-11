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
    IERC20 public TokenBGMC = IERC20(0); 

    struct UserStateTable
    {
        uint256 Balance;
        uint256 Timestamp;
        uint256 TotalBGM;
        uint256 TotalBGMC;
        bool    Shareholder;
    }

    address payable public owner;
    uint256 public totalSupply = 0;
    uint256 public StartTime = 0;
    uint256 public EndTime = 0;
    uint256 public MinBNB = 0;
    uint256 public MaxBNB = 0;
    bool    public CanWithdrawBGM = false;
    bool    public CanWithdrawBGMC = false;

    mapping(address => UserStateTable) private StateTable;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event WithdrawnBGM(address indexed user, uint256 TotalBGM);
    event WithdrawnBGMC(address indexed user, uint256 TotalBGMC);

	constructor(address _TokenBGM, address _TokenBGMC ) public payable
    {
        owner = msg.sender;
	    TokenBGM    = IERC20(_TokenBGM);
        TokenBGMC   = IERC20(_TokenBGMC);
        //StartTime   = 1655272800; /*2022-06-15 14:00:00*/ 
        StartTime   = 1655013600; /*2022-06-12 14:00:00*/
        EndTime     = StartTime + 259200;   //3 days
        MinBNB      = 500000000000000;       //0.0005 BNB
        MaxBNB      = 2000000000000000000;   //2 BNB
        CanWithdrawBGM = false;
        CanWithdrawBGMC = false;
	}

    function () payable external
    {
        require(msg.value >= MinBNB, "msg.value is less than 0.0005 BNB");
        require(msg.value <= MaxBNB, "msg.value is greater than 2 BNB");
        require(block.timestamp >= StartTime, "This activity hasn't started yet.");
        require(block.timestamp <= EndTime, "This activity has ended");
        require(true == StateTable[msg.sender].Shareholder, "address is not registered.");
        
        if (true != StateTable[msg.sender].Shareholder || block.timestamp >= EndTime)
        {
            msg.sender.transfer(msg.value);
            return;
        }

        StateTable[msg.sender].Balance += msg.value;
        totalSupply += msg.value;
        StateTable[msg.sender].Timestamp = block.timestamp;

        if (StateTable[msg.sender].Balance > MaxBNB)
        {
            msg.sender.transfer(StateTable[msg.sender].Balance - MaxBNB);
            totalSupply -= (StateTable[msg.sender].Balance - MaxBNB);
            StateTable[msg.sender].Balance = MaxBNB;
        }

        StateTable[msg.sender].TotalBGM  = StateTable[msg.sender].Balance / 500000000000000 * 100000000000000000;
        StateTable[msg.sender].TotalBGMC = StateTable[msg.sender].Balance / 500000000000000 * 1000000000000000000;
        
        emit Staked(msg.sender, msg.value);
    }

    function RegisterAddress(address account) public
    {
        require(msg.sender == owner, "Unauthorized.");
        require(true != StateTable[account].Shareholder, "address has registered.");

        StateTable[account].Shareholder = true;
    }

    function SetCanWithdrawBGM(bool _CanWithdrawBGM) public
    {
        require(CanWithdrawBGM != _CanWithdrawBGM, "The result has not changed.");

        CanWithdrawBGM = _CanWithdrawBGM;
    }

    function SetCanWithdrawBGMC(bool _CanWithdrawBGMC) public
    {
        require(CanWithdrawBGMC != _CanWithdrawBGMC, "The result has not changed.");

        CanWithdrawBGMC = _CanWithdrawBGMC;
    }

    function _StateTable(address account) public view returns (uint256 balance, uint256 Timestamp, uint256 _TotalBGM, uint256 _TotalBGMC, bool Shareholder)
    {
        return (StateTable[account].Balance, StateTable[account].Timestamp, StateTable[account].TotalBGM, StateTable[account].TotalBGMC, StateTable[account].Shareholder);
    }

    function RealtimeEarning(address account) public view returns (uint256 _TotalBGM, uint256 _TotalBGMC)
    {
        return (StateTable[account].TotalBGM, StateTable[account].TotalBGMC);
    }

    function TotalBGM() public view returns (uint256 _TotalBGM)
    {
        return TokenBGM.balanceOf(address(this));
    }
    
    function TotalBGMC() public view returns (uint256 _TotalBGMC)
    {
        return TokenBGMC.balanceOf(address(this));
    }

    function withdraw(address payable to, uint256 amount) public payable
    {
        require(msg.sender == owner, "Only owner can withdrow.");
        require(totalSupply >= amount, "amount is invalid.");

        to.transfer(amount);
        totalSupply -= amount;

        emit Withdrawn(msg.sender, amount);
    }

    function withdrawEarningBGM() public
    {   
        uint256 AmountBGM =  StateTable[msg.sender].TotalBGM;

        require(true == CanWithdrawBGM, "Can not withdraw now.");
        require(TokenBGM.balanceOf(msg.sender) > 0 || TokenBGMC.balanceOf(msg.sender) > 0, "You has no any earning.");
        require(TokenBGM.balanceOf(address(this)) >= AmountBGM, "The amount of BGM is not enough.");

        if (AmountBGM > 0)
        {
            TokenBGM.safeTransfer(msg.sender, AmountBGM);
            StateTable[msg.sender].TotalBGM = 0;
        }
        
        StateTable[msg.sender].Timestamp = block.timestamp;

        emit WithdrawnBGM(msg.sender, AmountBGM);
    }

    function withdrawEarningBGMC() public
    {   
        uint256 AmountBGMC =  StateTable[msg.sender].TotalBGMC;

        require(true == CanWithdrawBGMC, "Can not withdraw now.");
        require(TokenBGM.balanceOf(msg.sender) > 0 || TokenBGMC.balanceOf(msg.sender) > 0, "You has no any earning.");
        require(TokenBGMC.balanceOf(address(this)) >= AmountBGMC, "The amount of BGMC is not enough.");
        
        if (AmountBGMC > 0)
        {
            TokenBGMC.safeTransfer(msg.sender, AmountBGMC);
            StateTable[msg.sender].TotalBGMC = 0;
        }
        
        StateTable[msg.sender].Timestamp = block.timestamp;

        emit WithdrawnBGMC(msg.sender, AmountBGMC);
    }
}