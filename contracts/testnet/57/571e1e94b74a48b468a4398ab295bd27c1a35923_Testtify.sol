/**
 *Submitted for verification at BscScan.com on 2022-06-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

library Address {
    
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }


    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }


    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

   
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
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
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {

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

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function mintFromContract(uint256 _amount , address recipient) external returns (bool);

    function burn(uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Testtify is Context , Ownable{
    
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address private _company_address = 0xF22029b2905dd61B0930bd5d83a6A8d3e22CA3a8;
    address private _usdt_address = 0x08FC180975c1e3f021ae4fa6ba22d4F40885eC22;
    address private _iusdt_address = 0x6D65196ef92C7e7126E437A2A2673d714Cf9Ce4F;

    uint256 public _total_usdt_swap;
    uint256 public _current_iusdt_pair;
    uint256 public _pending_usdt_withdraw;
    uint256 public flexi_stake_pool;
    uint256 public _min_amount = 1000000000000000000000;

    uint256 public _iusdt_withdraw_vest = 7200;
    uint256 public _flexi_unstake_vest = 7200;
    uint256 public _locked_unstake_vest = 7200;
    uint256 private one_day = 3600;

    uint256 private _locked_performance_fee = 50; //50 = 5%

    uint256[] public _peformace_days;


    struct User {
        address upline;
        bool status;
    }

    struct iUSDTWithdraw{
        uint256 amount;
        bool status;
        uint256 end_time;
    }

    struct FlexiStake {
        uint256 amount;
        uint256 init_time;
        bool status;
        bool vest_status;
        uint256 end_time;
        uint256 _return_amount;
        uint256 _platform_fee;
    }
    
    struct LockedStake {
        uint16 day;
        uint256 amount;
        uint256 expiry_time;
        bool status;
        bool vest_status;
        uint256 end_time;
        uint256 _return_amount;
        uint256 _platform_fee;
    }

    struct LockedPool {
        uint256 _total_locked;
        uint256 _total_vested;
        bool status;
    }

    struct PerformanceFee {
        uint256 fee;
        bool status;
    }

    mapping(address => User) public users;
    mapping(address => iUSDTWithdraw) public iusdtvest;
    mapping(address => FlexiStake) public flexistake;
    mapping(uint16  => LockedPool) public lockedPool;
    mapping(address => LockedStake) public lockedstake;
    mapping(uint256 => PerformanceFee) public flexiPerformanceFee;
    mapping(address => bool) private skipVest;
 
    constructor() {
        skipVest[_company_address] = true;
    }
    
    function regUser(address _addr) external {
        require((users[_addr].status == true || _addr == owner()),"Invalid Referral");
        require(users[_msgSender()].status == false,"Address Register Already");
        
        users[_msgSender()].status = true;
        users[_msgSender()].upline = _addr;
    }

    function swapToiUSDT(uint256 _amount) external {
        //require(users[_msgSender()].status == true,"Not Allowed");
        
        IERC20 _usdt = IERC20(_usdt_address);
        require(_usdt.allowance(_msgSender(),address(this)) >= _amount,"Allowance Required");
        require(_usdt.balanceOf(_msgSender()) >= _amount,"No Balance");
        
        uint256 _pre_balance = _usdt.balanceOf(address(this));
        _usdt.safeTransferFrom(_msgSender(),address(this),_amount);

        require(_usdt.balanceOf(address(this)).sub(_pre_balance) == _amount ,"Amount Not Tally");

        IERC20 _iusdt = IERC20(_iusdt_address);
        _iusdt.mintFromContract(_amount,_msgSender());

        _total_usdt_swap = _total_usdt_swap.add(_amount);
        _current_iusdt_pair = _current_iusdt_pair.add(_amount);
        
    }

    function swapToUSDT(uint256 _amount) external {
        //require(users[_msgSender()].status == true,"Not Allowed");
        require(iusdtvest[_msgSender()].status == false,"Active Withdrawal On Progress");

        IERC20 _iusdt = IERC20(_iusdt_address);
        require(_iusdt.allowance(_msgSender(),address(this)) >= _amount,"Allowance Required");
        require(_iusdt.balanceOf(_msgSender()) >= _amount,"No Balance");

         uint256 _pre_balance = _iusdt.balanceOf(address(this));
        _iusdt.safeTransferFrom(_msgSender(),address(this),_amount);

        require(_iusdt.balanceOf(address(this)).sub(_pre_balance) == _amount ,"Amount Not Tally");
        
        uint256 _time;

        if(skipVest[_msgSender()] == true)
            _time = block.timestamp;
        else
            _time = block.timestamp.add(_iusdt_withdraw_vest);

        iusdtvest[_msgSender()].amount = _amount;
        iusdtvest[_msgSender()].status = true;
        iusdtvest[_msgSender()].end_time = _time;
        
        
        _pending_usdt_withdraw = _pending_usdt_withdraw.add(_amount);

        emit iUSDTVesting(_msgSender(),_amount,_time);

    }

    function claimUSDTWithdraw() external{
        //require(users[_msgSender()].status == true,"Not Allowed");
        require(iusdtvest[_msgSender()].status == true,"Active Withdrawal Required");
        require(iusdtvest[_msgSender()].end_time <= block.timestamp,"Vest Time not reached");

        uint256 _amount = iusdtvest[_msgSender()].amount;

        IERC20 _usdt = IERC20(_usdt_address);
        IERC20 _iusdt = IERC20(_iusdt_address);

        _usdt.safeTransfer(_msgSender(),_amount);
        _iusdt.burn(_amount);
        _current_iusdt_pair = _current_iusdt_pair.sub(_amount);
        _pending_usdt_withdraw = _pending_usdt_withdraw.sub(_amount); 
        
        delete iusdtvest[_msgSender()];
        
        emit iUSDTClaim(_msgSender(),_amount);
    }

    function stakeOnFlexi(uint256 _amount) external {
        //require(users[_msgSender()].status == true,"Not Allowed");
        require(flexistake[_msgSender()].vest_status == false,"Stake Failed");
        require(_amount >= _min_amount,"Minimu Amount");
        
        IERC20 _iusdt = IERC20(_iusdt_address);
        require(_iusdt.allowance(_msgSender(),address(this)) >= _amount,"Allowance Required");
        require(_iusdt.balanceOf(_msgSender()) >= _amount,"Not Allowed");

        uint256 _pre_balance = _iusdt.balanceOf(address(this));
        _iusdt.safeTransferFrom(_msgSender(),address(this),_amount);

        require(_iusdt.balanceOf(address(this)).sub(_pre_balance) == _amount ,"Amount Not Tally");

        flexistake[_msgSender()].amount = flexistake[_msgSender()].amount.add(_amount);
        flexistake[_msgSender()].init_time = block.timestamp;
        flexistake[_msgSender()].status = true;

        flexi_stake_pool = flexi_stake_pool.add(_amount);
        
        emit flexiStaking(_msgSender(),flexistake[_msgSender()].amount);
    }

    function unStakeOnFlexi() external {
        //require(users[_msgSender()].status == true,"Not Allowed");
        require(flexistake[_msgSender()].vest_status == false,"UnStake Failed");
        require(flexistake[_msgSender()].status == true,"Unstake Blocked");
        
        uint256 time_reach = block.timestamp.sub(flexistake[_msgSender()].init_time);
        uint256 _sfee = 0;
        for(uint8 i=0; i<_peformace_days.length;i++){

            if(time_reach <= _peformace_days[i])
            {
                _sfee = flexiPerformanceFee[_peformace_days[i]].fee;
                break;
            }
        }

        uint256 _peformance = flexistake[_msgSender()].amount.div(1000).mul(_sfee);

        flexistake[_msgSender()].status = true;
        flexistake[_msgSender()].vest_status = true;
        flexistake[_msgSender()].end_time = block.timestamp.add(_flexi_unstake_vest);
        flexistake[_msgSender()]._return_amount = flexistake[_msgSender()].amount.sub(_peformance);
        flexistake[_msgSender()]._platform_fee = _peformance;

        IERC20 _iusdt = IERC20(_iusdt_address);
        _iusdt.safeTransfer(_company_address,_peformance);

        emit unStaking(_msgSender(),flexistake[_msgSender()]._return_amount,_peformance,block.timestamp.add(_flexi_unstake_vest),0);
    }

    function claimFlexiVest() external {
        require(flexistake[_msgSender()].vest_status == true,"UnStake Requested");
        require(block.timestamp >= flexistake[_msgSender()].end_time,"Vest Not Completed");

        IERC20 _iusdt = IERC20(_iusdt_address);
        _iusdt.safeTransfer(_msgSender(),flexistake[_msgSender()]._return_amount);
        
        flexi_stake_pool = flexi_stake_pool.sub(flexistake[_msgSender()].amount);

        emit VestCalim(_msgSender(),flexistake[_msgSender()]._return_amount,0);

        delete flexistake[_msgSender()];
    }

    function updateLockedPool(uint16 _day,bool _status) external onlyOwner{
        lockedPool[_day].status = _status;
    }

    function stakeOnL(uint16 _day , uint256 _amount) external {
        //require(users[_msgSender()].status == true,"Not Allowed");
        require(_amount >= _min_amount,"Minimu Amount");
        require(lockedPool[_day].status == true,"Pool Days Not Available");
        require(lockedstake[_msgSender()].status == false,"Running Locked Staking");
        require(lockedstake[_msgSender()].vest_status == false,"VEST on Progress");
        
        IERC20 _iusdt = IERC20(_iusdt_address);
        require(_iusdt.allowance(_msgSender(),address(this)) >= _amount,"Allowance Required");
        require(_iusdt.balanceOf(_msgSender()) >= _amount,"Not Allowed");

        uint256 _pre_balance = _iusdt.balanceOf(address(this));
        _iusdt.safeTransferFrom(_msgSender(),address(this),_amount);

        require(_iusdt.balanceOf(address(this)).sub(_pre_balance) == _amount ,"Amount Not Tally");

        lockedstake[_msgSender()].day = _day;
        lockedstake[_msgSender()].amount = _amount;
        lockedstake[_msgSender()].expiry_time = block.timestamp.add(uint256(_day).mul(one_day));
        lockedstake[_msgSender()].status = true;

        lockedPool[_day]._total_locked = lockedPool[_day]._total_locked.add(_amount);

        emit lockedStaking(_msgSender(),_day,_amount,lockedstake[_msgSender()].expiry_time);

    }

    function stakeOnLwithUpdate(uint16 _day,uint256 _amount) external {
        //require(users[_msgSender()].status == true,"Not Allowed");
        require(lockedPool[_day].status == true,"Pool Days Not Available");
        require(lockedstake[_msgSender()].status == true,"Running Locked Running");
        require(lockedstake[_msgSender()].vest_status == false,"Running Locked Running");
        require(_day >= lockedstake[_msgSender()].day,"Locked Days Must Greater than current");
        uint256 _old_stake  = lockedstake[_msgSender()].amount;
        if(_amount >0)
        {
            IERC20 _iusdt = IERC20(_iusdt_address);
            require(_iusdt.allowance(_msgSender(),address(this)) >= _amount,"Allowance Required");
            require(_iusdt.balanceOf(_msgSender()) >= _amount,"Not Allowed");
        }
        //Remove Old Stake From Pool
        lockedPool[lockedstake[_msgSender()].day]._total_locked = lockedPool[lockedstake[_msgSender()].day]._total_locked.sub(_old_stake);
        
        uint256 _new_stake = _old_stake.add(_amount);

        lockedstake[_msgSender()].day = _day;
        lockedstake[_msgSender()].amount = _new_stake;
        lockedstake[_msgSender()].expiry_time = block.timestamp.add(uint256(_day).mul(one_day));
        lockedstake[_msgSender()].status = true;

        lockedPool[_day]._total_locked = lockedPool[_day]._total_locked.add(_new_stake);

        emit lockedStaking(_msgSender(),_day,_new_stake,lockedstake[_msgSender()].expiry_time);

    }

    function unStakeOnLS() external {
        //require(users[_msgSender()].status == true,"Not Allowed");
        require(lockedstake[_msgSender()].status == true,"Running Locked Running");
        require(lockedstake[_msgSender()].vest_status == false,"Running Locked Running");
        require(block.timestamp >= lockedstake[_msgSender()].expiry_time ,"End Time Didnt Reach");

        uint256 _peformance = lockedstake[_msgSender()].amount.div(1000).mul(_locked_performance_fee);

        lockedstake[_msgSender()].vest_status = true;
        lockedstake[_msgSender()].end_time = block.timestamp.add(_locked_unstake_vest);
        lockedstake[_msgSender()]._return_amount = lockedstake[_msgSender()].amount.sub(_peformance);
        lockedstake[_msgSender()]._platform_fee = _peformance;
        IERC20 _iusdt = IERC20(_iusdt_address);
        _iusdt.safeTransfer(_company_address,_peformance);

        lockedPool[lockedstake[_msgSender()].day]._total_vested = lockedPool[lockedstake[_msgSender()].day]._total_vested.add(lockedstake[_msgSender()]._return_amount);
        lockedPool[lockedstake[_msgSender()].day]._total_locked = lockedPool[lockedstake[_msgSender()].day]._total_locked.sub(lockedstake[_msgSender()].amount);
        
        emit unStaking(_msgSender(),lockedstake[_msgSender()]._return_amount,_peformance,lockedstake[_msgSender()].end_time,1);
    }
    
    function claimLVest() external {
        require(lockedstake[_msgSender()].vest_status == true,"UnStake Requested");
        require(block.timestamp >= lockedstake[_msgSender()].end_time,"Vest Not Completed");

        IERC20 _iusdt = IERC20(_iusdt_address);
        _iusdt.safeTransfer(_msgSender(),lockedstake[_msgSender()]._return_amount);

        lockedPool[lockedstake[_msgSender()].day]._total_vested = lockedPool[lockedstake[_msgSender()].day]._total_vested.sub(lockedstake[_msgSender()]._return_amount);

        emit VestCalim(_msgSender(),lockedstake[_msgSender()]._return_amount,1);

        delete lockedstake[_msgSender()];
    }

    function addPerformanceFee(uint256 _day ,uint256 _fee) external onlyOwner {
        uint256 _new_day = _day.mul(one_day);
        if(flexiPerformanceFee[_new_day].status == true)
        {
            flexiPerformanceFee[_new_day].fee = _fee;
        }
        else
        {
            flexiPerformanceFee[_new_day].status = true;
            flexiPerformanceFee[_new_day].fee = _fee;
            _peformace_days.push(_new_day);
            sortAsc();
        }
    }

    function updateLockedPlatformFee(uint256 _fee) external onlyOwner {
        require(_fee >= 0 && _fee < 1000, "Require min & max");
        _locked_performance_fee = _fee;
    }

    function updateiUSDTVestDays(uint256 _time) external onlyOwner {
        require(_time > 0,"Required Valid Time");
        _iusdt_withdraw_vest = _time;
    }

    function updateFlexiVestDays(uint256 _time) external onlyOwner {
        require(_time > 0,"Required Valid Time");
        _flexi_unstake_vest = _time;
    }

    function updateLockedVestDays(uint256 _time) external onlyOwner {
        require(_time > 0,"Required Valid Time");
        _locked_unstake_vest = _time;
    }
    
    function changeMinStake(uint256 _amount) external onlyOwner {
        require(_amount >0 ,"Valid Amount");
        _min_amount = _amount;
    }

    function sortAsc() internal {
        uint256 temp;
        for(uint8 i=0; i<_peformace_days.length;i++){
            
            for(uint8 j=i+1;j<_peformace_days.length;j++)
            {
                if(_peformace_days[i] > _peformace_days[j] )
                {
                    temp = _peformace_days[i];
                    
                    _peformace_days[i] = _peformace_days[j];
                    _peformace_days[j] = temp;
                }
            }
        }
    }

    function withdrawToken(address _token,uint256 _amount) external onlyOwner {
        IERC20 token = IERC20(_token);
        uint256 _bal = token.balanceOf(address(this));
        
        require(_amount <= _bal,"Over Balance");

        token.safeTransfer(_company_address,_amount);
    }

    event flexiStaking(address indexed _addr,uint256 _total_amount);
    event lockedStaking(address indexed _addr,uint256 _day,uint256 _amount,uint256 end_day);
    event unStaking(address indexed _addr,uint256 _return_amount,uint256 _platform_fee,uint256 end_time,uint8 types);
    event VestCalim(address indexed _addr,uint256 _total_amount,uint8 types);
    event iUSDTVesting(address indexed _addr,uint256 _amount,uint256 end_day);
    event iUSDTClaim(address indexed _addr,uint256 _amount);
}