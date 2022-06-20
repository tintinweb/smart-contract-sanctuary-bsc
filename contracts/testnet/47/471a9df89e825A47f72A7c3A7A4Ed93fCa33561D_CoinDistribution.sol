/**
 *Submitted for verification at BscScan.com on 2022-06-19
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

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}

interface ICoinVIP {
    //会员系统返回上级
    function parentInviter(address child) external view returns (address);
    function memberInfoList(address user) external view returns (uint256[5] memory);
    //增加个人投资额
    function investmentAdd(address user,uint256 amount) external;
    //增加团队有效会员个数，大于50U的购买额度
    function teamEffectiveCountAdd(address user,address child) external;
    //增加团队总投资额，当前会员总算力，在认购代币的时候累加
    function teamInvestmentAdd(address user,uint256 amount) external;
}

contract CoinDistribution is Context, Ownable {
    using SafeMath for uint256;
    using Address for address;

    //代币合约地址
    address public coin;
    //USDT合约地址
    address public USDT = address(0x55d398326f99059fF775485246999027B3197955);
    //CoinVIP 合约地址
    address public CoinVIP = address(0x55d398326f99059fF775485246999027B3197955);

    //1USDT = ncoin
    uint256 public swapRate;
    //最小购买USDT数量 = 1U
    uint256 public minBuy = 1e18;
    //最大购买USDT数量 = 2U
    uint256 public maxBuy = 2*1e18;
    //地址已买USDT数量，每次购买会累加
    mapping (address => uint256) public boughtOf;

    //地址总购买代币数量
    mapping (address => uint256) public profitOf;
    //地址代币已领取数量
    mapping (address => uint256) public profitReleasedOf;
    //累计总释放coin数量
    uint256 public totalProfit;
    //累计已提取coin数量
    uint256 public totalProfitReleased;

    //初始锁仓时间 固定时间（T）
    uint256 public firstReleaseStartTime;


    //地址可领取USDT数量
    mapping (address => uint256) public profitUSDTOf;
    //累计总释放USDT数量
    uint256 public totalProfitUSDT;
    //累计已提取USDT数量
    uint256 public totalProfitUSDTReleased;


    //事件通知========================================
    event SetSwapRate(uint256 oldValue,uint256 newValue);
    event SetMinBuy(uint256 oldValue,uint256 newValue);
    event SetMaxBuy(uint256 oldValue,uint256 newValue);
    event SetFirstReleaseStartTime(uint256 oldValue,uint256 newValue);
    event SetCoinVIPContractAddress(address oldValue,address newValue);


    event Buy(address user,uint256 payAmount);
    //事件通知========================================

    constructor (address _coin,address _USDT,uint256 _swapRate,uint256 _minBuy,uint256 _maxBuy,
        uint256 _firstReleaseStartTime) public {
        require(_coin!=address(0),"coin error");
        coin = _coin;//代币地址
        USDT= _USDT;
        swapRate = _swapRate;
        minBuy = _minBuy;
        maxBuy = _maxBuy;
        firstReleaseStartTime = _firstReleaseStartTime;


        _owner = msg.sender;
    }

    //购买
    function buy(uint256 buyUSDT) external {
        require(buyUSDT>=minBuy,"buy error: pay amount less than minBuy");
        require(boughtOf[msg.sender].add(buyUSDT)<=maxBuy,"buy error: pay amount more than maxBuy");
        uint256 outAmount = buyUSDT.mul(swapRate).div(1e18);
        require(outAmount>0,"buy: outAmount error");
        //更新已购买USDT数量
        TransferHelper.safeTransferFrom(USDT, msg.sender, address(this), buyUSDT);
        boughtOf[msg.sender] = boughtOf[msg.sender].add(buyUSDT);
        //结算用户获取代币 START
        profitOf[msg.sender] = profitOf[msg.sender].add(outAmount);
        totalProfit = totalProfit.add(outAmount);
        //结算上级直推收益 = 查询到购买用户的直接上级，然后将5%的M3直接分配给上级。
        address firstToplevel = ICoinVIP(CoinVIP).parentInviter(msg.sender);
        if(firstToplevel!=address(0)){ 
            uint256 one = buyUSDT.mul(500).div(10000);//5%
            profitUSDTOf[firstToplevel] = profitUSDTOf[firstToplevel].add(one);
            totalProfitUSDT = totalProfitUSDT.add(one);
        }
        //结算用户获取代币 级差收益 START
        uint256[5] memory member = 
            ICoinVIP(CoinVIP).memberInfoList(msg.sender);
        //更新本身的投资额
        ICoinVIP(CoinVIP).investmentAdd(msg.sender,buyUSDT);
        address lastParent = firstToplevel;
        uint256 lastLevel = member[0];
        for(uint i=0;i<200;i++){
            if(lastParent==address(0)){
                break;
            }
            //增加团队有效会员个数，大于50U的购买额度
            if(boughtOf[msg.sender]>50*1e18){
                ICoinVIP(CoinVIP).teamEffectiveCountAdd(lastParent,msg.sender);
            }
            ICoinVIP(CoinVIP).teamInvestmentAdd(lastParent,buyUSDT);
            if(lastLevel==5){
                lastParent = ICoinVIP(CoinVIP).parentInviter(lastParent);
                continue;
            }
            uint256[5] memory member1 = ICoinVIP(CoinVIP).memberInfoList(lastParent);
            if(member1[0]<=lastLevel){
                lastParent = ICoinVIP(CoinVIP).parentInviter(lastParent);
                continue;
            }
            uint256 two = member1[0].sub(lastLevel).mul(buyUSDT).mul(500).div(10000);//5%
            profitUSDTOf[lastParent] = profitUSDTOf[lastParent].add(two);
            totalProfitUSDT = totalProfitUSDT.add(two);

            lastLevel = member1[0];
            lastParent = ICoinVIP(CoinVIP).parentInviter(lastParent);
        }
        //结算邀请关系收益 级差收益 END
        emit Buy(msg.sender,buyUSDT);
    }

    //查询用户可领取收益
    function calculateUserProfit(address user)public view returns(uint256 profit){
        uint256 userCanRelease = profitOf[user];//若时间大于7个月+固定时间 ，则表示应全部释放
        if(block.timestamp < (firstReleaseStartTime+7*30*86400)){
            userCanRelease = profitOf[user].mul(20).div(100);//20%的A3直接发放给用户
            if(block.timestamp>=firstReleaseStartTime){
                userCanRelease = userCanRelease.add(profitOf[user].mul(10).div(100));//到固定时间（T）释放。合约向该用户释放10%的A3
            }else if(block.timestamp>=(firstReleaseStartTime*30*86400)){
                uint256 monthCount = block.timestamp.sub(firstReleaseStartTime)%(30*86400);
                userCanRelease = userCanRelease.add(profitOf[user].mul(10*monthCount).div(100));
            }
        }
        //未领取= 可领取-已领取
        profit = userCanRelease.sub(profitReleasedOf[user]);
    }

    //查询用户锁定数量
    function queryLockCoin(address user)public view returns(uint256 lockAmount){
        lockAmount = 0;
        if(profitOf[user]>=profitReleasedOf[user]){
            lockAmount = profitOf[user].sub(profitReleasedOf[user]);
        }
    }

    //用户提取代币
    function userWithdrawCoin(uint256 _amount) external {
        require(_amount > 0, "userWithdrawCoin: _amount error 0");
        uint256 userCanRelease = calculateUserProfit(msg.sender);
        require(userCanRelease > _amount, "userWithdrawCoin: _amount error 0");
        safeErc20Transfer(coin, msg.sender, _amount);
        profitReleasedOf[msg.sender] = profitReleasedOf[msg.sender].add(_amount);
        totalProfitReleased = totalProfitReleased.add(_amount);
    }

    //用户提取U 已完成
    function userWithdrawUSDT(uint256 _amount) external {
        require(_amount > 0, "userWithdrawUSDT: _amount error 0");
        require(profitUSDTOf[msg.sender] >= _amount, "userWithdrawUSDT: _amount error");
        profitUSDTOf[msg.sender] = profitUSDTOf[msg.sender].sub(_amount);
        safeErc20Transfer(USDT, msg.sender, _amount);
        totalProfitUSDTReleased = totalProfitUSDTReleased.add(_amount);
    }


    //管理员相关方法====================================================================
    receive() external payable {
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

    //设置兑换比例  做 1e18 精度位处理 即 1USDT = 100代币 _swapRate = 100*18
    function setSwapRate(uint256 _swapRate) public onlyOwner {
        require(_swapRate > 0 && swapRate!= _swapRate, "setSwapRate: _swapRate error");
        uint256 _old = swapRate;
        swapRate = _swapRate;
        emit SetSwapRate(_old,_swapRate);
    }

    //设置最小购买N USDT 需考虑USDT精度位
    function setMinBuy(uint256 _minBuy) public onlyOwner {
        require(_minBuy > 0 && minBuy!= _minBuy, "setMinBuy: _minBuy error");
        uint256 _old = minBuy;
        minBuy = _minBuy;
        emit SetMinBuy(_old,minBuy);
    }
    //设置最大购买M USDT 需考虑USDT精度位
    function setMaxBuy(uint256 _maxBuy) public onlyOwner {
        require(_maxBuy > 0 && maxBuy!= _maxBuy, "setMaxBuy: _maxBuy error");
        uint256 _old = maxBuy;
        maxBuy = _maxBuy;
        emit SetMaxBuy(_old,maxBuy);
    }
    //设置会员智能合约地址
    function setCoinVIPContractAddress(address _coinVip) public onlyOwner {
        require(_coinVip!=address(0) && CoinVIP!= _coinVip, "setCoinVIPContractAddress: _coinVip error");
        address _old = CoinVIP;
        CoinVIP = _coinVip;
        emit SetCoinVIPContractAddress(_old,CoinVIP);
    }
    //设置固定时间T
    function setFirstReleaseStartTime(uint256 _firstReleaseStartTime) public onlyOwner {
        require(_firstReleaseStartTime > block.timestamp && firstReleaseStartTime!= _firstReleaseStartTime, "setFirstReleaseStartTime: _firstReleaseStartTime error");
        uint256 _old = firstReleaseStartTime;
        firstReleaseStartTime = _firstReleaseStartTime;
        emit SetFirstReleaseStartTime(_old,firstReleaseStartTime);
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
}