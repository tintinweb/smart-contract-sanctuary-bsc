/**
 *Submitted for verification at BscScan.com on 2022-11-27
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

pragma solidity ^0.8.0;
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

pragma solidity ^0.8.0;
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.8.0;
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

pragma solidity ^0.8.0;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity ^0.8.4;
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
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
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, 'Address: low-level call failed');
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeBEP20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            'SafeBEP20: decreased allowance below zero'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IBEP20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
        }
    }
}

abstract contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;

        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity ^0.8.12;
contract StakeMan is Ownable {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    struct UserReference {
        address wallet;
        address parent;
        bool isExist;
    }

    struct UserStakeInfo {
        uint256 amount;
        uint256 _amount;
        uint256 withdraw;

        uint256 payback_remain;
        uint256 w_payback_remain;
        uint256 last_payback;

        uint256 start_block;
        uint256 end_block;
        uint256 last_claim;
        uint256 max_interest; //amount x5
        uint256 childs_comission;
        uint status; //0=inactive,1=active,2=500% interest
    }

    address private poolAddress;
    address private tokenAddress = 0x2efDff1e566202f82e774bB7aDD18c56CbB9427D;
    uint256 private decimal = 18;
    uint256 private totalStake = 0;
    uint256 private minStake = 0;
    bool private rewardComission = false;

    uint256 private blockStake = 1 days; //release
    uint256 private blockPayback = 30 * blockStake; //1month
    uint private stakeLifeTime = 6 * blockPayback;
    uint private daylyInterestPercent = 10; //1%
    uint private paybackPercent = 50; //5%
    uint private _percentRate = 1000;

    // Info of each user that stakes LP tokens.
    mapping (address => UserStakeInfo) private userStake;
    mapping(uint256 => UserReference) private accounts;
    mapping(uint256 => uint256) private InterestLevelPercent;
    address[] private g20;
    uint private _g20Percent = 100; //10%
    uint private _g20_round_robin;
    //
    bool private isLockStake = false;
    //
    using Counters for Counters.Counter;
    Counters.Counter private _accIndex;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    event EventResponse(address indexed user, uint256 errCode, string errorMessage);
    event Claim(address indexed user, uint256 errCode, string errorMessage, uint256 totalEarn);
    event Unstake(address indexed user, uint256 errCode, string errorMessage, uint256 totalEarn);

    constructor() {
        poolAddress = address(this);
        InterestLevelPercent[1] = 300; //30%
        InterestLevelPercent[2] = 200;
        InterestLevelPercent[3] = 100;
        InterestLevelPercent[4] = 50;
        InterestLevelPercent[5] = 50;
        InterestLevelPercent[6] = 30;
        InterestLevelPercent[7] = 30;
        InterestLevelPercent[8] = 30;
        InterestLevelPercent[9] = 30;
        InterestLevelPercent[10] = 30; //3%
        InterestLevelPercent[11] = 15; //1.5%
        InterestLevelPercent[12] = 15;
        InterestLevelPercent[13] = 15;
        InterestLevelPercent[14] = 15;
        InterestLevelPercent[15] = 15;
        InterestLevelPercent[16] = 15;
        InterestLevelPercent[17] = 15;
        InterestLevelPercent[18] = 15;
        InterestLevelPercent[19] = 15;
        InterestLevelPercent[20] = 15;
    }

    function g20Percent() public view returns(uint) {
        return _g20Percent;
    }

    function getG20() public view returns(address[] memory)  {
        return g20;
    }

    function updateG20Percent(uint _percent) public onlyOwner {
        _g20Percent = _percent;
    }

    function updateG20(uint index,address _address) public onlyOwner {
        uint _index = getAccountIndex(_address);
        if( _index > 0 ) {
            g20[index] = _address;
            UserReference memory userInfo = accounts[_index];
            userInfo.wallet = _address;
            accounts[_index] = userInfo;
        }
    }

    function addG20(address _address) public onlyOwner {
        require( _address != address(0) , "Null address" );
        //reg root
        uint _index = getAccountIndex(_address);
        if( _index == 0 ) {
            g20.push(_address);
            UserReference memory userInfo = UserReference( _address,address(0),true);
            _accIndex.increment();
            accounts[_accIndex.current()] = userInfo;
        }
    }

    function isG20(address _address) private returns(bool flag) {
        flag = false;
        for(uint i = 0; i < g20.length; i++) {
            if( g20[i] != address(0) && g20[i] == _address ) {
                flag = true;
                i = g20.length;
            }
        }   
        return flag;
    }

    function getMinStake() public view returns(uint256) {
        return minStake;
    }

    function updateMinStake(uint256 _minStake) public onlyOwner {
        minStake = _minStake;
    }

    function onRewardComission() public onlyOwner {
        rewardComission = true;
    }

    function offRewardComission() public onlyOwner {
        rewardComission = false;
    }

    function lockStake() public onlyOwner {
        isLockStake = true;
    }

    function unLockStake() public onlyOwner {
        isLockStake = false;
    }

    function updatePackageReward(uint256 index,uint256 percent) public onlyOwner {
        InterestLevelPercent[index] = percent;
    }

    function getPackageRewardInfo(uint256 index) public view onlyOwner returns(uint256) {
        return InterestLevelPercent[index];
    }

    function changePoolAddress(address _poolAdress) public onlyOwner {
        poolAddress = _poolAdress;
    }

    function changeTokenAddress(address _tokenAddress) public onlyOwner {
        tokenAddress = _tokenAddress;
    }

    function getUserInfos() public view returns(UserReference[] memory) {
        UserReference[] memory userInfos = new UserReference[](_accIndex.current());
        for (uint i = 0; i < _accIndex.current(); i++) {
            if (accounts[i + 1].isExist ) {
                userInfos[i] = accounts[i + 1];
            }
        }
        return userInfos;
    }

    function getUserInfo(address _wallet) public returns(UserReference memory userInfo) {
        uint accIndex = getAccountIndex(_wallet);
        if( accIndex > 0) {
            userInfo = accounts[accIndex];
        }
    }

    function getAccountIndex(address _wallet) private returns(uint) {
        uint totalItemCount = _accIndex.current();
        uint currentIndex = 0;
        for (uint i = 0; i < totalItemCount; i++) {
            if (accounts[i + 1].isExist && accounts[i + 1].wallet == _wallet) {
                currentIndex = i + 1;
                i = totalItemCount;
            }
        }
        return currentIndex;
    }

    function checkHaveParent(address _wallet) public view returns(bool) {
        bool flag = false;
        uint totalItemCount = _accIndex.current();
        for (uint i = 0; i < totalItemCount; i++) {
            if (accounts[i + 1].isExist && accounts[i + 1].wallet == _wallet && accounts[i + 1].parent != address(0)) {
                flag = true;
                i = totalItemCount;
            }
        }
        return flag;
    }

    function register(address _user, address inviter) private {
        require( _user != address(0),"User address is invalid" );
        require( _user != inviter,"Can not inviter your self" );
        uint _acc_index = getAccountIndex( _user );
        if( _acc_index == 0 ) {
            bool flag = checkHaveParent( _user );
            if(!flag) {
                UserReference memory userInfo = UserReference( _user,inviter,true);
                _accIndex.increment();
                accounts[_accIndex.current()] = userInfo;
            }
        }
    }

    function getRoot(address _parent,address _root) public returns(address) {
        UserReference memory userRef = getUserInfo(_parent);
        if( userRef.isExist ) {
            if( isG20(_parent) ) {
                //ah g20
                _root = _parent;
            } else if( userRef.parent != address(0) ) {
                _root = getRoot(userRef.parent,_root);
            }
        }
        return _root;
    }

    function _4g20(uint256 _amount, address inviter) private {
        uint256 _add = _amount * _g20Percent / _percentRate;
        if( _add > 0 && inviter != address(0) ) {
            address root = address(0);
            root = getRoot(inviter,root);
            if( root != address(0) ) {
                poolReward(_add,root);    
            }
        }
    }

    function stake(uint256 amount, address inviter) public {
        uint256 errCode = 0;
        string memory errorMessage = "You have successfully staked";
        require(amount > minStake,"Deposit amount must be greater than the minimum amount");
        if(!isLockStake) {
            register(_msgSender(),inviter);
            UserStakeInfo memory stakeInfo = userStake[_msgSender()];
            if( stakeInfo.status == 0 || stakeInfo.status == 2 ) {
                uint256 _amount = amount * 10 ** decimal;
                uint256 userBalance = IERC20(tokenAddress).balanceOf(_msgSender());
                if( userBalance >= _amount ) {
                    IERC20(tokenAddress).transferFrom(_msgSender(), poolAddress, _amount);
                    //update user stake
                    stakeInfo.status = 1; //active
                    stakeInfo.withdraw = 0;
                    stakeInfo.payback_remain = _amount;
                    stakeInfo.amount = _amount;
                    stakeInfo._amount = amount;
                    stakeInfo.max_interest = _amount * 5;
                    stakeInfo.childs_comission = 0;
                    stakeInfo.start_block = block.timestamp;
                    stakeInfo.last_claim = block.timestamp;
                    stakeInfo.last_payback = block.timestamp;
                    stakeInfo.end_block = block.timestamp + stakeLifeTime;
                    userStake[_msgSender()] = stakeInfo;
                    totalStake += amount;
                    _4g20(_amount,inviter);
                } else {
                    errCode = 2;
                    errorMessage = "Balance is not enough";
                }
            } else {
                errCode = 1;
                errorMessage = "You have already staking";
            }
        } else {
            errCode = 3;
            errorMessage = "Stake is locked";
        }
        emit EventResponse(_msgSender(),errCode,errorMessage);
    }

    function claim() public {
        uint256 errCode = 0;
        string memory errorMessage = "OK";
        UserStakeInfo memory stakeInfo = userStake[_msgSender()];
        uint _acc_index = getAccountIndex( _msgSender() );
        require(_acc_index > 0, "user not found");
        UserReference memory userInfo = accounts[_acc_index];
        require(userInfo.isExist, "user is not exists");
        uint256 _real_earn = 0;
        if( stakeInfo.status == 1 || stakeInfo.status == 2 ) {
            bool _reach_x5 = false;
            uint256 _check = stakeInfo.withdraw;
            uint256 _interest = dailyInterest(_msgSender(),0);
            if( _check + _interest <= stakeInfo.max_interest ) {
                _real_earn = _interest;
                _check += _interest;
            } else {
                _real_earn = _interest - (_check + _interest - stakeInfo.max_interest);
                if( _real_earn <= 0 ) {
                    _reach_x5 = true;
                }
            }
            if( !_reach_x5 ) {
                //try check child_comission
                uint256 _child_comission = stakeInfo.childs_comission;
                if( _check + _child_comission <= stakeInfo.max_interest ) {
                    _real_earn += _child_comission;
                    _check += _child_comission;
                    stakeInfo.childs_comission = 0; //reset childs comission
                } else {
                    _real_earn += _child_comission - (_check + _child_comission - stakeInfo.max_interest);
                    if( _real_earn <= 0 ) {
                        _reach_x5 = true;
                    }
                }
                // if( !_reach_x5 ) {
                //     uint acc_level = accountLevel(_msgSender());
                //     //try check child comission calcu
                //     uint256 _comission = 0;
                //     _comission = childsInterestCalcu(_msgSender(),1,acc_level,stakeInfo.last_claim,_comission,address(0));
                //     if( _comission > 0 ) {
                //         if( _check + _comission <= stakeInfo.max_interest ) {
                //             _real_earn += _comission;
                //             _check += _comission;
                //         } else {
                //             _real_earn += _comission - (_check + _comission - stakeInfo.max_interest);
                //             if( _real_earn <= 0 ) {
                //                 _reach_x5 = true;
                //             }
                //         }
                //     }
                // }
            }
            if( _reach_x5 ) {
                if( stakeInfo.status == 1 ) {
                    stakeInfo.status = 2; //reach 500% funds
                    stakeInfo.w_payback_remain += stakeInfo.payback_remain;
                    stakeInfo.payback_remain = 0;    
                }
            }
            comission20Lv(userInfo.parent,_real_earn,1);
            //payback
            (uint256 _payback,uint256 _amount_remain, uint256 _w_amount_remain) = _payback30d(stakeInfo);
            if( _payback > 0 ) {
                if( stakeInfo.status == 1 ) {
                    stakeInfo.payback_remain = _amount_remain;    
                }
                if( stakeInfo.status == 2 ) {
                    stakeInfo.w_payback_remain = _w_amount_remain;    
                }
                stakeInfo.last_payback = absLastLog(stakeInfo.start_block, blockPayback);
                _real_earn += _payback;
            }
            //
            stakeInfo.withdraw += _real_earn;
            stakeInfo.last_claim = absLastLog(stakeInfo.start_block, blockStake);
            userStake[_msgSender()] = stakeInfo;
            poolReward(_real_earn,_msgSender());
            
        } else {
            errCode = 1;
            errorMessage = "You have no staking";
        }
        emit Claim(_msgSender(),errCode,errorMessage,_real_earn);
    }

    function absLastLog(uint256 _start_time, uint256 _div_block) private returns(uint256) {
        uint256 result = block.timestamp;
        if( result - _start_time > 0 ) {
            result -= (result - _start_time) % _div_block; 
        }
        return result;
    }

    function unstake() public {
        uint256 errCode = 0;
        uint256 _real_earn = 0;
        string memory errorMessage = "OK";
        UserStakeInfo memory stakeInfo = userStake[_msgSender()];
        if(stakeInfo.status == 1 || stakeInfo.status == 2) {
            totalStake -= (stakeInfo.amount / (10 ** decimal));
            _real_earn = stakeInfo.payback_remain;
            if( _real_earn > 0 ) {
                poolReward(_real_earn,_msgSender());
            } else {
                _real_earn = stakeInfo.w_payback_remain;
                if( _real_earn > 0 ) {
                    poolReward(_real_earn,_msgSender());
                }
            }
            stakeInfo.status = 0; 
            userStake[_msgSender()] = stakeInfo;
        } else {
            errCode = 1;
            errorMessage = "You have no staking";
        }
        emit Unstake(_msgSender(),errCode,errorMessage,_real_earn);
    }

    function poolReward(uint256 amount,address receiver) private {
        if( amount > 0 ){
            uint256 _poolBalance = IERC20(tokenAddress).balanceOf(address(this));
            if( _poolBalance < amount ) {
                amount = _poolBalance;
            }
            IERC20(tokenAddress).transfer(receiver,amount);
        }
    }

    function getTotalStake() public view returns(uint256) {
        return totalStake;
    }
 
    function stakeInfos() public view returns(UserStakeInfo memory) {
        return userStake[_msgSender()];
    }

    function stakeInfo(address _sender) public view returns(
        uint256 last_payback, 
        uint256 last_claim,
        uint256 childs_comission,
        uint256 daily_interest,
        uint acc_level,
        uint256 _payback30d,
        uint256 _payback_remain,
        uint256 _w_payback_remain,
        uint256 now,
        uint256 dblock,
        uint256 mblock) {
        UserStakeInfo memory info = userStake[_sender];
        if( info.status == 1 || info.status == 2 ) {
            last_payback = info.last_payback;
            last_claim = info.last_claim;
            childs_comission = info.childs_comission;
            //
            daily_interest = dailyInterest(_sender,0);
            acc_level = accountLevel(_sender);
            (_payback30d,_payback_remain,_w_payback_remain) = payback30d(_sender);
            now = block.timestamp;
            dblock = blockStake;
            mblock = blockPayback;
        }
    }

    function comission20Lv(address _parent,uint256 _interest,uint level) private {
        if( level >= 1 && _interest > 0 ) {
            UserReference memory userRef = getUserInfo(_parent);
            if( userRef.isExist ) {
                //update parent stake-info
                UserStakeInfo memory stakeInfo = userStake[_parent];
                uint parent_stake_level = accountLevel(_parent);
                if( stakeInfo.status == 1 && parent_stake_level >= level ) {
                    uint256 percent = InterestLevelPercent[level];
                    uint256 comission = _interest * percent / _percentRate;
                    uint256 _check5x = check5x(_parent,comission);
                    if( _check5x > 0 ) {
                        stakeInfo.childs_comission += _check5x;
                        userStake[_parent] = stakeInfo;
                    }
                }
                if( userRef.parent != address(0) ) {
                    level += 1;
                    comission20Lv(userRef.parent,_interest,level);
                }
            }
        }
    }

    function check5x( address _sender, uint256 _addon ) public view returns(uint256) {
        uint256 _to_earn = 0;
        UserStakeInfo memory stakeInfo = userStake[_sender];
        if( stakeInfo.status == 1 ) {
            uint256 _earn = stakeInfo.withdraw;
            _earn += stakeInfo.childs_comission;
            uint256 _interest = dailyInterest(_sender,0);
            _earn += _interest;
            if( _earn < stakeInfo.max_interest ) {
                if( _earn + _addon < stakeInfo.max_interest ) {
                    _to_earn = _addon;
                } else {
                    _to_earn = _addon - (_earn + _addon - stakeInfo.max_interest);
                }
            }
        }
        return _to_earn;
    }

    function getAllChild(address _sender) public view returns(UserReference[] memory) {
        uint totalItemCount = _accIndex.current();
        uint itemCount = 0;
        for (uint i = 0; i < totalItemCount; i++) {
            if (accounts[i + 1].parent == _sender) {
                itemCount += 1;
            }
        }
        UserReference[] memory items = new UserReference[](itemCount);
        uint arIndex = 0;
        for (uint i = 0; i < totalItemCount; i++) {
            if (accounts[i + 1].parent == _sender) {
                UserReference storage currentItem = accounts[i + 1];
                items[arIndex] = currentItem;
                arIndex++;
            }
        }
        return items;
    }

    function accountLevel(address _sender) public view returns(uint) {
        uint level = 0;
        UserStakeInfo memory stakeInfo = userStake[_sender];
        if( stakeInfo.status == 1 || stakeInfo.status == 2 ) {
            //by F1
            UserReference[] memory childs = getAllChild(_sender);
            uint f1_level = childs.length;
            //by funds amount
            uint funds_level = 0; 
            if( stakeInfo._amount >= 3000 && stakeInfo._amount < 5000 ) {
                funds_level = 1;
            } else if( stakeInfo._amount >= 5000 && stakeInfo._amount < 13000 ) {
                funds_level = 2;
            } else if( stakeInfo._amount >= 13000 && stakeInfo._amount < 30000 ) {
                funds_level = 5;
            } else if( stakeInfo._amount >= 30000 && stakeInfo._amount < 60000 ) {
                funds_level = 10;
            } else if( stakeInfo._amount >= 60000 && stakeInfo._amount < 150000 ) {
                funds_level = 15;
            } else if( stakeInfo._amount >= 150000 ) {
                funds_level = 20;
            }
            level = f1_level;
            if( level < funds_level ) {
                level = funds_level;
            }
        }
        return level;
    }

    function dailyInterest(address _sender, uint256 _time_check) public view returns(uint256) {
        uint256 _interest = 0;
        UserStakeInfo memory stakeInfo = userStake[_sender];
        if( stakeInfo.status == 1 ) {
            uint256 now = block.timestamp;
            if( now > stakeInfo.end_block ) {
                now = stakeInfo.end_block;
            }
            if( _time_check == 0 || _time_check < stakeInfo.last_claim ) {
                _time_check = stakeInfo.last_claim;
            }
            uint256 _duration = now - _time_check;
            uint _block = _duration / blockStake;
            if( _block > 0 ) {
                uint _interest_percent = _block * daylyInterestPercent;
                _interest = _interest_percent * stakeInfo.amount / _percentRate;    
            }
        }
        return _interest;
    }

    function payback30d(address _sender) public view returns(uint256 _payback,uint256 _amount,uint256 _w_amount) {
        UserStakeInfo memory stakeInfo = userStake[_sender];
        if( stakeInfo.status == 1 || stakeInfo.status == 2 ) {
            uint256 now = block.timestamp;
            if( now > stakeInfo.end_block ) {
                now = stakeInfo.end_block;
            }
            uint256 _duration = now - stakeInfo.last_payback;
            uint _block = _duration / blockPayback;
            _amount = stakeInfo.payback_remain;
            if( _amount > 0 ) {
                for(uint i=0;i<_block;i++) {
                    uint256 _l_ = _amount * paybackPercent / _percentRate;
                    _payback = _payback + _l_;
                    _amount = _amount - _l_;
                }
            }
            _w_amount = stakeInfo.w_payback_remain;
            if( _w_amount > 0 ) {
                for(uint i=0;i<_block;i++) {
                    uint256 _l_ = _w_amount * paybackPercent / _percentRate;
                    _payback = _payback + _l_;
                    _w_amount = _w_amount - _l_;
                }
            }
        }
    }

    function _payback30d(UserStakeInfo memory stakeInfo) private view returns(uint256 _payback,uint256 _amount,uint256 _w_amount) {
        if( stakeInfo.status == 1 || stakeInfo.status == 2 ) {
            uint256 now = block.timestamp;
            if( now > stakeInfo.end_block ) {
                now = stakeInfo.end_block;
            }
            uint256 _duration = now - stakeInfo.last_payback;
            uint _block = _duration / blockPayback;
            _amount = stakeInfo.payback_remain;
            if( _amount > 0 ) {
                for(uint i=0;i<_block;i++) {
                    uint256 _l_ = _amount * paybackPercent / _percentRate;
                    _payback = _payback + _l_;
                    _amount = _amount - _l_;
                }
            }
            _w_amount = stakeInfo.w_payback_remain;
            if( _w_amount > 0 ) {
                for(uint i=0;i<_block;i++) {
                    uint256 _l_ = _w_amount * paybackPercent / _percentRate;
                    _payback = _payback + _l_;
                    _w_amount = _w_amount - _l_;
                }
            }
        }
    }

    function childsInterestCalcu(address _sender,uint level,uint max_level,uint256 _time_check,uint256 _comission,address ignor) public view returns(uint256) {
        if( _time_check == 0 ) {
            UserStakeInfo memory stakeInfo = userStake[_sender];
            _time_check = stakeInfo.last_claim;
        }
        if( _time_check > 0 ) {
            UserReference[] memory childs = getAllChild(_sender);
            if( childs.length > 0 ) {
                uint256 percent = InterestLevelPercent[level];
                for(uint i=0; i < childs.length; i++) {
                    UserReference memory _item = childs[i];
                    if(_item.isExist && _item.wallet != ignor) {
                        uint256 _child_interest = dailyInterest(_item.wallet,_time_check);
                        if( _child_interest > 0 ) {
                            uint256 __comission = _child_interest * percent / _percentRate;
                            _comission = _comission + __comission;
                        }
                        if( level + 1 <= max_level ) {
                            _comission = childsInterestCalcu(_item.wallet,level + 1,max_level,_time_check,_comission,ignor);
                        }
                    }
                }
            }
        }
        return _comission;
    }
}