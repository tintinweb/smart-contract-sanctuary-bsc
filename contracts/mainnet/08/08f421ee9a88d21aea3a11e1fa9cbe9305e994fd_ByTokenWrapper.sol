/**
 *Submitted for verification at BscScan.com on 2022-12-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

pragma solidity ^0.8.0;


library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
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

// File: @openzeppelin/contracts/ownership/Ownable.sol

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


// File: @openzeppelin/contracts/utils/Address.sol

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
   
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

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
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

pragma solidity ^0.8.0;

contract ByTokenWrapper is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct Account {
        address inviter;
        address[] invitees;
        uint tokenBonus;
        uint tokenHoder;
    }
    mapping(address => address) public oneInviter;
    mapping(address => Account) public myInviter;
    uint256 public startTradeBlock = 1703054250;//私募结束时间

    address public rewardToken = address(0x5933Fa8C95f0d5a42570c22A265cb25323223cB5);
    address public tokenAddress = address(0x24261112F8e68065B26D2737079A835972D6F971);//代币地址

    address public inUAddress = address(0x54d24923d6BAB331a12c6B1B355160260ac2dd5e);//收U地址
    address public outTokenAddress = address(0xEE70ea2176333feCF41521dBD4a5c6B0D297179C);//转币地址
    address public _destroyAddress = address(0x000000000000000000000000000000000000dEaD);
    event Bind(address indexed inviter, address indexed invitee);

    mapping(address => uint256) private _nftHouder; //NFT地址
    uint256 public nftTotal = 30;
    uint256 private _totalSupply;//总私募U
    mapping(address => uint256) private _balances;//个人私募U
    mapping(address => uint256) private _balancesToken;//代释放的币
    mapping(address => uint256) private _withdrawBalancesToken;//已经领取的币
    mapping(address => uint256) private _releaseRatio;//比例
    mapping(address => uint256) private _reardBalancesToken;//抽奖获得的币
    mapping(address => uint256) private _reardWink;//抽奖奖品

    address[] private allMiners;//所有私募地址

    uint256 chuTimes = 1703001600;//初始时间
    mapping(address => uint256) private _claimTime;//上次领取时间
    

    function bind(address inviter) public {
        require(inviter != address(0), "not zero account");
        require(inviter != msg.sender, "can not be yourself");
        require(oneInviter[msg.sender] == address(0), "already bind");
        require(myInviter[msg.sender].inviter == address(0), "already bind");

        oneInviter[msg.sender] = inviter;
        myInviter[msg.sender].inviter = inviter;
        myInviter[inviter].invitees.push(msg.sender);
        emit Bind(inviter, msg.sender);
    }

    function getInviter(address account) view public returns(address){
        return myInviter[account].inviter;
    }
    function getInvitees(address account) view public returns(address[] memory invitees){
        return myInviter[account].invitees;
    }
    function getBonus(address account) view public returns(uint tokenBonus){
        return myInviter[account].tokenBonus;
    }
    function getHoder(address account) view public returns(uint tokenHoder){
        return myInviter[account].tokenHoder;
    }
    function getInvitation(address account) public view returns (address inviter,uint tokenBonus, uint tokenHoder,address[] memory invitees) {
        Account memory info = myInviter[account];
        return (info.inviter, info.tokenBonus,info.tokenHoder, info.invitees);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    function balanceOfToken(address account) public view returns (uint256) {
        return _balancesToken[account];
    }
    function withdrawBalanceOfToken(address account) public view returns (uint256) {
        return _withdrawBalancesToken[account];
    }
    function releaseRatio(address account) public view returns (uint256) {
        return _releaseRatio[account];
    }
    function reardBalanceOfToken(address account) public view returns (uint256) {
        return _reardBalancesToken[account];
    }
    function reardWink(address account) public view returns (uint256) {
        return _reardWink[account];
    }
    function nftHouder(address account) public view returns (uint256) {
        return _nftHouder[account];
    }
    function claimTime(address account) public view returns (uint256) {
        return _claimTime[account];
    }
    function getAllMiners() external view returns (address[] memory) {
        return allMiners;
    }
    function getAllMinersAmount() external view returns (uint256[] memory) {
        uint256[] memory balanceAll = new uint256[](allMiners.length);
         for (uint256 i = 0; i < allMiners.length; i++) {
           balanceAll[i] = _balances[allMiners[i]];
        }
        return balanceAll;
    }


    function buyToken() public returns(bool){
        uint256 amount = 100 * 10**18;
        require(block.timestamp < startTradeBlock, "Buy Tower BNB max2");
        require(_balances[msg.sender] <= 500 * 10**18, "Buy Tower BNB max3");
        uint256 initialCAKEBalance = IERC20(rewardToken).balanceOf(msg.sender);
		require(initialCAKEBalance >= amount, "Buy Tower BNB max4");

        address oneParentAddress = oneInviter[msg.sender];
        require(oneParentAddress != address(0), "Buy11111111");
        address twoParentAddress = oneInviter[oneParentAddress];

        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        allMiners.push(msg.sender);

        myInviter[oneParentAddress].tokenHoder += 1;
        myInviter[oneParentAddress].tokenBonus += 100;

        if(myInviter[oneParentAddress].tokenHoder >= 30 && myInviter[oneParentAddress].tokenBonus >= 10000 && nftTotal > 0)
        {
            if(_nftHouder[msg.sender] == 0){
                _nftHouder[msg.sender] += 100;
                nftTotal -= 1;
            }
        }

        if(_nftHouder[msg.sender] == 100)
        {
            if(twoParentAddress == address(0)){
                IERC20(rewardToken).safeTransferFrom(msg.sender, inUAddress, 80 * 10**18);
                IERC20(rewardToken).safeTransferFrom(msg.sender, oneParentAddress, 20 * 10**18);
            }else{
                IERC20(rewardToken).safeTransferFrom(msg.sender, inUAddress, 70 * 10**18);
                IERC20(rewardToken).safeTransferFrom(msg.sender, oneParentAddress, 20 * 10**18);
                IERC20(rewardToken).safeTransferFrom(msg.sender, twoParentAddress, 10 * 10**18);
            }
        }
        else
        {
            IERC20(rewardToken).safeTransferFrom(msg.sender, inUAddress, 90 * 10**18);
            IERC20(rewardToken).safeTransferFrom(msg.sender, oneParentAddress, 10 * 10**18);
            if(_totalSupply < 100000 * 10**18){
                IERC20(tokenAddress).safeTransferFrom(msg.sender, oneParentAddress, 6000 * 10**18);
            }else if(_totalSupply >= 100000 * 10**18 && _totalSupply < 200000 * 10**18){
                IERC20(tokenAddress).safeTransferFrom(msg.sender, oneParentAddress, 5500 * 10**18);
            }else{
                IERC20(tokenAddress).safeTransferFrom(msg.sender, oneParentAddress, 5000 * 10**18);
            }
        }
        if(_totalSupply < 100000 * 10**18)
        {
            _balancesToken[msg.sender] = _balancesToken[msg.sender].add(9600 * 10**18);
            IERC20(tokenAddress).safeTransferFrom(outTokenAddress, msg.sender, 2400 * 10**18);
        }
        else if(_totalSupply >= 100000 * 10**18 && _totalSupply < 200000 * 10**18)
        {
            _balancesToken[msg.sender] = _balancesToken[msg.sender].add(8800 * 10**18);
            IERC20(tokenAddress).safeTransferFrom(outTokenAddress, msg.sender, 2200 * 10**18);
        }
        else
        {
            _balancesToken[msg.sender] = _balancesToken[msg.sender].add(8000 * 10**18);
            IERC20(tokenAddress).safeTransferFrom(outTokenAddress, msg.sender, 2000 * 10**18);
        }
        
        return true;
    }

    function dayZero() public view returns(uint256){
        return block.timestamp-(block.timestamp%(24*3600))-(8*3600);
    }
    function getVTime() public view returns(uint256){
        uint256 time = _claimTime[msg.sender];
        if(time == 0){
            time = chuTimes;
        }
        uint256 day = dayZero().sub(time);
        require(day >= 86400, "Buy Tower BNB max2");

        uint256 getVTimes = day/86400;
        return getVTimes;
    }

    function withdraw() public returns(bool){
        require(_balancesToken[msg.sender] > 0, "Buy Tower BNB max1");
        uint256 ratio = _releaseRatio[msg.sender];
        if(ratio == 0){
            ratio = 1;
        }
        uint256 time = _claimTime[msg.sender];
        if(time == 0){
            time = chuTimes;
        }
        uint256 day = dayZero().sub(time);
        require(day >= 86400, "Buy Tower BNB max2");

        uint256 getVTimes = day/86400;
        uint256 releaseAmount = _balancesToken[msg.sender].mul(ratio).mul(getVTimes).div(1000);

        IERC20(tokenAddress).safeTransferFrom(outTokenAddress, msg.sender, releaseAmount);
        _balancesToken[msg.sender] = _balancesToken[msg.sender].sub(releaseAmount);
        require(_balancesToken[msg.sender] > 0, "Buy Tower BNB max1");
        _claimTime[msg.sender] = dayZero();
        _withdrawBalancesToken[msg.sender] += releaseAmount;
        return true;
    }

    function GetIsInvite(address account) public view returns(uint256){
        if(oneInviter[account] != address(0)){
            return 1;
        }else{
            return 0;
        }
    }
    function settokenAddress(address account) public onlyOwner {
        tokenAddress = account;
    }
    function startTrade(uint256 time) external onlyOwner {
        startTradeBlock = time;
    }

    //转盘
     function turntable() public returns(uint256){
        require(block.timestamp < startTradeBlock.add(86400000), "Buy Tower BNB max2");
        uint256 initialCAKEBalance = IERC20(tokenAddress).balanceOf(msg.sender);
		require(initialCAKEBalance >= 10000 * 10**18, "Buy Tower BNB max4");
        IERC20(tokenAddress).safeTransferFrom(msg.sender, _destroyAddress, 10000 * 10**18);

        if(_releaseRatio[msg.sender] == 0){
            _releaseRatio[msg.sender] = 11;
        }else if(_releaseRatio[msg.sender] > 0 && _releaseRatio[msg.sender] < 45 ){
            _releaseRatio[msg.sender] += 10;
        }
        
        uint w = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, dayZero())));
        uint fh= w % 10000000;
        uint r = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, fh)));
        uint index= r % 10000;

        uint256 fun = 0;
        if(index>=0 && index<100){//10
            _balancesToken[msg.sender] += 100000 * 10**18;
            _reardBalancesToken[msg.sender] += 100000 * 10**18;
            fun = 1;
            _reardWink[msg.sender] = 1;
        }else if(index>=100 && index<300){//5
            _balancesToken[msg.sender] += 50000 * 10**18;
            _reardBalancesToken[msg.sender] += 50000 * 10**18;
            fun = 2;
            _reardWink[msg.sender] = 2;
        }else if(index>=300 && index<800){//3
            _balancesToken[msg.sender] += 30000 * 10**18;
            _reardBalancesToken[msg.sender] += 30000 * 10**18;
            fun = 3;
            _reardWink[msg.sender] = 3;
        }else if(index>=800 && index<1800){//1.5
            _balancesToken[msg.sender] += 15000 * 10**18;
            _reardBalancesToken[msg.sender] += 15000 * 10**18;
            fun = 4;
            _reardWink[msg.sender] = 4;
        }else if(index>=1800 && index<3800){//1.3
            _balancesToken[msg.sender] += 13000 * 10**18;
            _reardBalancesToken[msg.sender] += 13000 * 10**18;
            fun = 5;
            _reardWink[msg.sender] = 5;
        }else{//1.1
            _balancesToken[msg.sender] += 11000 * 10**18;
            _reardBalancesToken[msg.sender] += 11000 * 10**18;
            fun = 6;
            _reardWink[msg.sender] = 6;
        }

		return fun;
    }
}