/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);
     function mintTo(address who, uint256 _value) external;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}

interface IBEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
   
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

interface IDividendTracker {
    function updateRewards() external ;
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
        require(b != 0);
        return a % b;
    }
}
/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 * 
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 * 
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        // solhint-disable-next-line no-inline-assembly
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}
/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

contract DansaBank is IBEP20, IDividendTracker, Context, Initializable{
    using SafeMath for uint256;
    using SafeMathInt for int256;
    uint256 private constant DECIMALS = 18;
    IERC20 public xDansaToken;
    uint256 private INITIAL_FRAGMENTS_SUPPLY = 5 * 10**9 * 10**DECIMALS;
    uint256 private _totalSupply;
    uint256 private _lastBalances;
    uint256 private _lastBalanceD2E;
    address[] private _currentAcc;
    uint256 private _circulatingSupply;
    uint256 public rewardYield;
    uint256 public rewardYieldDenominator;
    uint256 private MAX_UINT256 = ~uint256(0);
    /*attribute        */
    address private ZERO = 0x0000000000000000000000000000000000000000;
    address private DEAD = 0x000000000000000000000000000000000000dEaD;
    address public _xDansaAdd = 0xFedfE07fd305523FAC91B68E0adEC80e41681b0b;
    address public dansaToken = 0x42D093090bBb247B2762fD1b4A5608eD6812D570;
    /*bank blances*/
    mapping(address => uint256) private _gonXBalances;
    mapping(address => uint256) private _gonBalances;
    mapping(address => uint256) private _gonLockBalance;
    mapping(address => uint256) private _gonD2E;
    mapping(address => uint256) private _times;
    mapping(address => uint256) private _lockTimes;
    mapping(address => uint256) private _rewardedBalances;
    mapping(address => uint256) private _rewardedUsd;
    uint256 private _rate = 1;
    uint256 private _rewarded = 0;
    uint256 private _paidDansa = 0;
    uint256 private _paidD2E = 0;
    uint256 private _totalLockTime = 0;
    uint256 private _totalDansaLocked = 0;
    uint256 private _totalDansaRewarded = 0;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    address private _owner;
    mapping(address => uint256) private _apy;
    /*allowed fragment */
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    /*initialize */
    function initialize(string memory pname, string memory psymbol, uint8 pdecimals) public initializer {
        _name = pname;
        _symbol = psymbol;
        _decimals = pdecimals;
        _owner = msg.sender;
        _rate = 1;
        _totalSupply = 5 * 10**9 * 10**_decimals;
        rewardYield = 2145500;
        rewardYieldDenominator = 10000000000;
        MAX_UINT256 = ~uint256(0);
         _xDansaAdd = 0xFdF5367Ab3052bE6af8e683F75523516F3B14501;
        dansaToken = 0x9EF3435052e7DfD9Fc14c4A809A1dB7b4DC06852;
        ZERO = 0x0000000000000000000000000000000000000000;
        DEAD = 0x000000000000000000000000000000000000dEaD;

        xDansaToken = IERC20(_xDansaAdd);
        _gonXBalances[ZERO] = ~uint256(0);
        _allowedFragments[address(this)][address(this)] = MAX_UINT256;
        _allowedFragments[ZERO][address(this)] = MAX_UINT256;
        _allowedFragments[address(this)][msg.sender] = MAX_UINT256;

    }
    function clearZero() public onlyOwner {
        _gonXBalances[ZERO] = 0;
    }
    modifier onlyOwner() {
        require(msg.sender == _owner, "Not owner");
        _;
    }
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
    function owner() public view returns (address) {
        return _owner;
    }

    /*method.         */
    function increaseAmount(uint256 _amount) public returns(bool) { 
        uint256 sarValue = _amount;
        uint256 xValue = 0;
        xValue = _amount;
        require(xDansaToken.transferFrom(msg.sender, address(this), sarValue), "Transfer failed!!!");
        // require(transferFrom(ZERO, msg.sender, xValue), "Transfer failed!!!");
        _gonXBalances[msg.sender] = _gonXBalances[msg.sender].add(xValue);
        _gonLockBalance[msg.sender] = _gonLockBalance[msg.sender].add(sarValue);
        _circulatingSupply = _circulatingSupply.add(xValue);
        _totalDansaLocked = _totalDansaLocked.add(_amount);
        emit IncreaseAmount(msg.sender, _amount);
        return true;
    }
    function totalDansaLocked() public view returns(uint256) {
        return _totalDansaLocked;
    }
    /**update address */

    function setAddress(address _D2E, address _Dansa)public returns(bool) {
        dansaToken = _D2E;
        _xDansaAdd = _Dansa;
        xDansaToken = IERC20(_xDansaAdd);
        return true;
    }

    function balanceOf(address who) public view override returns(uint256) {
        return (_gonXBalances[who]);
    }

    function balanceD2EOf(address who) public view returns(uint256) {
        return (_gonD2E[who]);
    }

    function balanceDansaOf(address who) public view returns(uint256) {
        return (_gonBalances[who]);
    }

    function totalDansaRewarded() public view returns(uint256) {
        return _totalDansaRewarded;
    }

    function balanceLockOf(address who) public view returns(uint256) {
        return (_gonLockBalance[who]/_rate);
    }
    function totalRewardedOf(address who) external view returns(uint256) {
        return _rewardedBalances[who];
    }
    function totalUSDRewardedOf(address who) external view returns(uint256) {
        return _rewardedUsd[who];
    }
    function createLock(uint256 _days, uint256 _value) public returns(bool) {
        uint256 sarValue = _value;
        uint256 xValue = _value;
        uint256 apy = rewardYield;
        if(_days < 16) {
            apy = rewardYield;
        }
        else if(_days < 32) {
            apy = rewardYield.mul(11).div(10);  
        }
        else if(_days < 62) {
            apy = rewardYield.mul(12).div(10);
        }
        else if(_days < 92) {
            apy = rewardYield.mul(13).div(10);
        }
        else if(_days < 183) {
            apy = rewardYield.mul(14).div(10);
        }
        else if(_days >= 365) {
            apy = rewardYield.mul(14).div(10);
        }

        require(xDansaToken.transferFrom(msg.sender, address(this), sarValue), "Transfer failed!!!");
        // require(transferFrom(ZERO, msg.sender, xValue), "Transfer failed!!!");
        _apy[msg.sender] = apy;
        _gonXBalances[msg.sender] = _gonXBalances[msg.sender].add(_value);
        _times[msg.sender] = block.timestamp.div(1 days);
        _lockTimes[msg.sender] = _days;
        _gonLockBalance[msg.sender] = sarValue;
        _currentAcc.push(msg.sender);
        _totalDansaLocked = _totalDansaLocked.add(_value);
        _circulatingSupply = _circulatingSupply.add(xValue);
        _totalLockTime = _totalLockTime.add(_days);
        emit CreateLock(msg.sender, _value, _days);
        return true;
    }

    function increaseLock(uint256 _days) public returns(bool){
        _lockTimes[msg.sender] = _lockTimes[msg.sender].add(_days);
        uint256 apy = rewardYield;
        if(_lockTimes[msg.sender] < 16) {
            apy = rewardYield;
        }
        else if(_lockTimes[msg.sender] < 32) {
            apy = rewardYield.mul(11).div(10);  
        }
        else if(_lockTimes[msg.sender] < 62) {
            apy = rewardYield.mul(12).div(10);
        }
        else if(_lockTimes[msg.sender] < 92) {
            apy = rewardYield.mul(13).div(10);
        }
        else if(_lockTimes[msg.sender] < 183) {
            apy = rewardYield.mul(14).div(10);
        }
        else if(_lockTimes[msg.sender] >= 365) {
            apy = rewardYield.mul(14).div(10);
        }
        _apy[msg.sender] = apy;
        _totalLockTime = _totalLockTime.add(_days);
        emit IncreaseLock(msg.sender, _days);
        return true;
    }
    function apyOf(address who) public view returns(uint256) {
        return _apy[who];
    }
    function timesOf(address who) public view returns(uint256) {
        return _lockTimes[who];
    }
    function startTimeOf(address who) public view returns(uint256) {
        return _times[who];
    }
    function lockReleaseDate(address who) public view returns(uint256) {
        return _times[who].add(_lockTimes[who]);
    } 
    function unlock(address account) public returns(bool) {
        uint256 _now = block.timestamp/(1 days);
        uint256 unlockValue = 0;
        uint256 dayDiff = _now.sub(_times[account]);
        uint256 lockTime = _lockTimes[account];
        uint256 xamount = _gonXBalances[account];
        // require(transfer(ZERO, xamount), "Transfer Failed");
        if (dayDiff < _lockTimes[account]) {
            unlockValue = _gonLockBalance[account].div(2);
        } else {
            unlockValue = _gonLockBalance[account];
        }
        _gonBalances[account] = _gonBalances[account].add(unlockValue);
        _gonLockBalance[account] = 0;
        _gonXBalances[account] = 0;
        _circulatingSupply = _circulatingSupply.sub(xamount);

        // remove acount
        // require(_currentAcc.length > 1, "Required 1 pair");
        for (uint256 i = 0; i < _currentAcc.length; i++) {
            if (_currentAcc[i] == account) {
                _currentAcc[i] = _currentAcc[_currentAcc.length - 1];
                _currentAcc.pop();
                break;
            }
        }

        _totalLockTime = _totalLockTime.sub(_lockTimes[account]);

        _times[account] = 0;
        _lockTimes[account] = 0;
        emit Unlock(account, lockTime);
        return true;
    }

    function averageLockTime() external view returns(uint256) {
        return _totalLockTime.div(_currentAcc.length);
    }

    function claimDansa(uint256 amount) public returns(bool) {
        if (amount > _gonBalances[msg.sender]) {
           amount = _gonBalances[msg.sender];
        }
        if (amount > xDansaToken.balanceOf(address(this))) {
            xDansaToken.mintTo(address(this), amount - xDansaToken.balanceOf(address(this)));
        }
        require(xDansaToken.transfer(msg.sender, amount));
        _gonBalances[msg.sender] = 0;
        emit ClaimDansa(msg.sender, amount);
        _paidDansa = _paidDansa.add(amount);
        return true;
    }
    function setBalanceOf(address who, uint256 value) external onlyOwner {
         _gonBalances[who] =  _gonBalances[who].add(value);
    }

    function paidDansa() external view returns(uint256) {
        return _paidDansa;
    }

    function rewarded() external view returns(uint256) {
        return _rewarded;
    }

    function toBeRewarded() external view returns(uint256) {
        uint256 currentBalance = IBEP20(dansaToken).balanceOf(address(this));
        uint256 balanceDiff = currentBalance.sub(_lastBalanceD2E);
        return balanceDiff;
    }

    function paidD2E() external view returns(uint256) {
        return _paidD2E;
    }

    function updateRewards() public override onlyOwner {
        uint256 currentBalance = IBEP20(dansaToken).balanceOf(address(this));
        uint256 balanceDiff = currentBalance.sub(_lastBalanceD2E);
        if (balanceDiff > 0) {
            for (uint256 i = 0; i < _currentAcc.length; i++) {
                _gonD2E[_currentAcc[i]] = _gonD2E[_currentAcc[i]].add(
                                                            balanceDiff.mul(_gonXBalances[_currentAcc[i]])
                                                                       .div(_circulatingSupply));
                _rewardedUsd[_currentAcc[i]] = _rewardedUsd[_currentAcc[i]].add(balanceDiff.mul(_gonXBalances[_currentAcc[i]])
                                                                       .div(_circulatingSupply));
                emit LogsReward(_currentAcc[i], balanceDiff.mul(_gonXBalances[_currentAcc[i]])
                                                                       .div(_circulatingSupply));
            }
        }
        for (uint256 j = 0; j < _currentAcc.length; j++) {
                uint256 before = _gonBalances[_currentAcc[j]];
                uint256 reward = (_gonBalances[_currentAcc[j]].add(_gonLockBalance[_currentAcc[j]])).mul(_apy[_currentAcc[j]]).div(rewardYieldDenominator);
                _gonBalances[_currentAcc[j]] = _gonBalances[_currentAcc[j]].add(reward);
                uint256 afterReward = _gonBalances[_currentAcc[j]];
                _rewardedBalances[_currentAcc[j]] = _rewardedBalances[_currentAcc[j]].add(reward);
                _totalDansaRewarded = _totalDansaRewarded.add(reward);
                emit LogsDansaReward(_currentAcc[j], reward, before, afterReward);
        }
        _rewarded = _rewarded.add(balanceDiff);

        _lastBalanceD2E = currentBalance;

        emit UpdateRewards();
    }


    function claimD2E(uint256 amount) public returns(bool) {
        if (amount > _gonD2E[msg.sender])
           amount = _gonD2E[msg.sender];
        require(IBEP20(dansaToken).transfer(msg.sender, amount), "transfer error");
        _gonD2E[msg.sender] = 0;
        _paidD2E = _paidD2E.add(amount);
        emit ClaimD2E(msg.sender, amount);
        return true;
    } 


    function transferFrom (address from, address to, uint256 value) public override returns(bool){
        if (_allowedFragments[from][msg.sender] != type(uint128).max && from != ZERO) {
            _allowedFragments[from][msg.sender] = _allowedFragments[from][
            msg.sender
            ].sub(value, "Insufficient Allowance");
        }
        _gonXBalances[from] = _gonXBalances[from].sub(value);
        _gonXBalances[to] = _gonXBalances[to].add(value);
        emit Transfer(from, to, value);
        return true;
    }

    function totalSupply() public view override returns(uint256){
        return _totalSupply;
    }

    function circulatingSupply() public view returns(uint256) {
        return _circulatingSupply;
    }

    function allowance(address owner_, address spender) external override view returns (uint256){
        return _allowedFragments[owner_][spender];
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        _gonXBalances[msg.sender] = _gonXBalances[msg.sender].sub(value);
        _gonXBalances[to] = _gonXBalances[to].add(value);
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external override returns (bool) {
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
 
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool){
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(
                subtractedValue
            );
        }
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool){
        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][
        spender
        ].add(addedValue);
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }
    event UpdateRewards();
    event UpdateRewardD2E();
    event IncreaseAmount(address who, uint256 value);
    event Unlock(address who, uint256 day);
    event CreateLock(address who, uint256 value, uint256 day);
    event IncreaseLock(address who, uint256 day);
    event LogsDansaReward(address who, uint256 value, uint256 before, uint256 afterReward);
    event LogsReward(address who, uint256 value);
    // event Transfer(address from, address to, uint256 value);
    event ClaimDansa(address who, uint256 value);
    event ClaimD2E(address who, uint256 value);
}