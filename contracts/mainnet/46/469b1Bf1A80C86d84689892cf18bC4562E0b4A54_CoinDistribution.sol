/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;
interface IERC20 {

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

contract Ownable is Context {
    address public _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


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

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = now + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(now > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}


contract CoinDistribution is Context, Ownable {
    using SafeMath for uint256;
    using Address for address;

    //预设置代币总量
    uint256 public totalCoinAmount;
    
    //已绑定的邀请关系,下级->上级
    mapping(address => address) public parentInviter;
    //上级->下级
    mapping(address => address[]) public childInviter;
    mapping (address => bool) public claimed;
    //空投数量
    uint256 public airdropAmount;
    //代币合约地址
    address public coin;
    //地址可领取代币数量
    mapping (address => uint256) public profitOf;
    //累计总释放coin数量
    uint256 public totalProfit;
    //累计已提取coin数量
    uint256 public totalProfitReleased;
    //地址可领取BNB数量
    mapping (address => uint256) public profitBNBOf;
    //累计总释放BNB数量
    uint256 public totalProfitBNB;
    //累计已提取BNB数量
    uint256 public totalProfitBNBReleased;

    //1BNB = ncoin
    uint256 public swapRate;

    uint256 public minBuy = 1e17;//最小购买BNB数量
    uint256 public maxBuy = 5*1e18;//最大购买BNB数量
    //地址已买BNB数量，每次购买会累加
    mapping (address => uint256) public boughtOf;
    //代币可领取开始时间
    uint256 public withdrawStartTime;


    event SetAirdropAmount(uint256 oldAmount,uint256 newAmount);
    event SetTotalCoinAmount(uint256 oldAmount,uint256 newAmount);
    event SetSwapRate(uint256 oldSwapRate,uint256 newSwapRate);
    event SetWithdrawStartTime(uint256 oldWithdrawStartTime,uint256 newWithdrawStartTime);
    event ClaimAirdrop(address inviter,address inviterPa,uint256 airdropAmount);
    event Buy(address user,address inviter,uint256 payAmount,uint256 outAmount);

    constructor (address _coin,uint256 _airdropAmount,uint256 _swapRate,uint256 _withdrawStartTime,uint256 _totalCoinAmount) public {
        require(_swapRate>0,"_swapRate error");
        swapRate = _swapRate;//举例： 1BNB = 100Coin 则 _swapRate = 100 * 1e18
        require(_withdrawStartTime>block.timestamp,"_withdrawStartTime error");
        withdrawStartTime = _withdrawStartTime;
        require(_coin!=address(0),"coin error");
        coin = _coin;//代币地址
        require(_totalCoinAmount>0,"_totalCoinAmount error");
        totalCoinAmount = _totalCoinAmount;//总的分发代币数，需要转入等量的代币
        require(_airdropAmount>0,"_airdropAmount error");
        airdropAmount = _airdropAmount;//领取的代币数量，与代币精度位有关

        _owner = msg.sender;
    }

    //管理员提取平台币
    function withdrawETH(uint256 _amount) public onlyOwner {
        require(_amount > 0, "withdrawETH: amount not good");
        safeTransferETH(msg.sender, _amount);
    }

    //管理员提取代币
    function withdrawERC20(address _erc20, uint256 _amount) public onlyOwner {
        require(_amount > 0, "withdrawERC20: amount not good");
        safeErc20Transfer(_erc20, msg.sender, _amount);
    }

    function safeErc20Transfer(address _erc20 ,address _to, uint256 _amount) internal {
        uint256 bal = IERC20(_erc20).balanceOf(address(this));
        require(bal >= _amount,"safeErc20Transfer: _amount error");
        IERC20(_erc20).transfer(_to, _amount);
    }
    function safeTransferETH(address to, uint256 value) internal {
        require(address(this).balance >= value,"safeTransferETH: _amount error");
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }

    //查询合约中剩余代币数量
    function getBalance() public view returns (uint256 coinBalance,uint256 bnbBalance,uint256 leftCoinAmount)
    {
        coinBalance = IERC20(coin).balanceOf(address(this));
        bnbBalance = address(this).balance;
        leftCoinAmount = totalCoinAmount.sub(totalProfit);
    }
    
    //设置总释放代币数。需要转入相应的代币
    function setTotalCoinAmount(uint256 _amount) public onlyOwner {
        require(_amount > 0 && totalCoinAmount!= _amount, "setTotalCoinAmount: _amount error");
        uint256 _old = totalCoinAmount;
        totalCoinAmount = _amount;
        emit SetTotalCoinAmount(_old,_amount);
    }

    //设置领取代币的数量
    function setAirdropAmount(uint256 _amount) public onlyOwner {
        require(_amount > 0 && airdropAmount!= _amount, "setAirdropAmount: _amount error");
        uint256 _old = airdropAmount;
        airdropAmount = _amount;
        emit SetAirdropAmount(_old,_amount);
    }
    //设置兑换比例
    function setSwapRate(uint256 _swapRate) public onlyOwner {
        require(_swapRate > 0 && swapRate!= _swapRate, "setAirdropAmount: _swapRate error");
        uint256 _old = swapRate;
        swapRate = _swapRate;
        emit SetSwapRate(_old,_swapRate);
    }
    
    //设置领取开始时间
    function setWithdrawStartTime(uint256 _withdrawStartTime) public onlyOwner {
        require(_withdrawStartTime > 0 && withdrawStartTime!= _withdrawStartTime, "setWithdrawStartTime: _withdrawStartTime error");
        uint256 _old = withdrawStartTime;
        withdrawStartTime = _withdrawStartTime;
        emit SetWithdrawStartTime(_old,_withdrawStartTime);
    }
    

    //领取代币
    function claimAirdrop(address _inviter) external {
        require(_inviter!=address(0),"claimAirdrop: _inviter error");
        require(_inviter!=msg.sender && msg.sender!=parentInviter[msg.sender] && msg.sender!=parentInviter[parentInviter[msg.sender]],"claimAirdrop: _inviter error 1");
        require(claimed[msg.sender]==false,"claimAirdrop: claimed");
        if(parentInviter[msg.sender]==address(0)){
            parentInviter[msg.sender] = _inviter;
            childInviter[_inviter].push(msg.sender);
        }
        require(parentInviter[msg.sender] == _inviter,"buy: _inviter error 2");
        profitOf[msg.sender] = profitOf[msg.sender].add(airdropAmount);
        uint256 one = airdropAmount.mul(1000).div(10000);//10%
        uint256 two = airdropAmount.mul(500).div(10000);//5%
        if(parentInviter[msg.sender]!=address(0) && one>0){
            profitOf[parentInviter[msg.sender]] = profitOf[parentInviter[msg.sender]].add(one);
            totalProfit = totalProfit.add(one);
        }
        if(parentInviter[parentInviter[msg.sender]]!=address(0) && two>0){
            profitOf[parentInviter[parentInviter[msg.sender]]] = profitOf[parentInviter[parentInviter[msg.sender]]].add(two);
            totalProfit = totalProfit.add(two);
        }
        claimed[msg.sender]=true;
        emit ClaimAirdrop(parentInviter[msg.sender],parentInviter[parentInviter[msg.sender]],airdropAmount);
    }

    //购买
    function buy(address _inviter) external payable{
        require(_inviter!=address(0),"buy: _inviter error");
        require(_inviter!=msg.sender && msg.sender!=parentInviter[msg.sender] && msg.sender!=parentInviter[parentInviter[msg.sender]],"claimAirdrop: _inviter error 1");
        require(msg.value>0,"buy: pay amount less than 0");
        require(msg.value>=minBuy,"buy: pay amount less than minBuy");
        require(boughtOf[msg.sender].add(msg.value)<=maxBuy,"buy: pay amount more than maxBuy");
        if(parentInviter[msg.sender]==address(0)){
            parentInviter[msg.sender] = _inviter;
            childInviter[_inviter].push(msg.sender);
        }
        require(parentInviter[msg.sender] == _inviter,"buy: _inviter error 2");
        uint256 outAmount = msg.value.mul(swapRate).div(1e18);
        require(outAmount>0,"buy: outAmount error");
        profitOf[msg.sender] = profitOf[msg.sender].add(outAmount);
        totalProfit = totalProfit.add(outAmount);

        address lastPa = msg.sender;
        uint8 count = 0;
        for(uint256 i=0;i<20;i++){//循环20代
            if(count>=2){
                break;
            }
            if(parentInviter[lastPa]==address(0)){
                break;
            }
            if(boughtOf[parentInviter[lastPa]]>=5*1e17 && count==0){//大于0.5个BNB
                uint256 one = msg.value.mul(1000).div(10000);//10%
                profitBNBOf[parentInviter[lastPa]] = profitBNBOf[parentInviter[lastPa]].add(one);
                totalProfitBNB = totalProfitBNB.add(one);
                count++;
            }else if(boughtOf[parentInviter[lastPa]]>=5*1e17 && count==1){
                uint256 two = msg.value.mul(500).div(10000);//5%
                profitBNBOf[parentInviter[lastPa]] = profitBNBOf[parentInviter[lastPa]].add(two);
                totalProfitBNB = totalProfitBNB.add(two);
                count++;
            }
            lastPa = parentInviter[lastPa];
        }

        //更新已购买BNB数量
        boughtOf[msg.sender] = boughtOf[msg.sender].add(msg.value);
        emit Buy(msg.sender,_inviter,msg.value,outAmount);
    }

    //用户提取平台币
    function userWithdrawETH(uint256 _amount) external {
        require(_amount > 0, "userWithdrawETH: _amount error 0");
        require(profitBNBOf[msg.sender] >= _amount, "userWithdrawETH: _amount error");
        profitBNBOf[msg.sender] = profitBNBOf[msg.sender].sub(_amount);
        totalProfitBNBReleased = totalProfitBNBReleased.add(_amount);
        safeTransferETH(msg.sender, _amount);
    }

    //用户提取代币
    function userWithdrawERC20(uint256 _amount) external {
        require(_amount > 0, "userWithdrawETH: _amount error 0");
        require(profitOf[msg.sender] >= _amount, "userWithdrawERC20: _amount error");
        require(block.timestamp>=withdrawStartTime,"userWithdrawERC20: paused");
        profitOf[msg.sender] = profitOf[msg.sender].sub(_amount);
        safeErc20Transfer(coin, msg.sender, _amount);
        totalProfitReleased = totalProfitReleased.add(_amount);
    }

    function viewInviteeByAddress(
        address inviter,
        uint256 cursor,
        uint256 size
    )
        external
        view
        returns (
            address[] memory generation,
            uint256
        )
    {
        uint256 length = size;

        if (length > childInviter[inviter].length - cursor) {
            length = childInviter[inviter].length - cursor;
        }

        generation = new address[](length);

        for (uint256 i = 0; i < length; i++) {
            generation[i] = childInviter[inviter][i];
        }

        return (generation, cursor + length);
    }

    receive() external payable {
    }
}