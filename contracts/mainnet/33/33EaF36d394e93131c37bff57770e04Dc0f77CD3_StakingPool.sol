/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


library SafeMathUpgradeable {
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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

library AddressUpgradeable {
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
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
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

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
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

interface IERC20Upgradeable {
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




contract StakingPool {

    using SafeMathUpgradeable for uint;
    using AddressUpgradeable for address;

    address payable public admin;

    IERC20Upgradeable public EGN;

    IERC20Upgradeable public USDT;

    //双币剩余质押量
    uint public restStakingNumberUSDT;
    uint public restStakingNumberEGN;

    //单笔剩余质押量
    uint public restStakingSingle;
    //egn质押最小额
    uint public minStakingEGN;

    //激活条件(代币余额最小值）
    uint public minEnabledAmount;
    //绑定关系，奖励上级代币数量
    uint public referAwardAmount;

    //推荐奖励开关
    bool referSwitch;

    //激活推荐发放奖励总量
    uint public referAwardTotal;
    //奖励记录
    mapping(address=>uint) referAwards;
    //推荐关系
    mapping(address => address) public relations;




    bool initialized;



    event WithdrawFDRW(address, uint);
    event AddStakingDouble(address, uint,uint);
    event AddStakingSingle(address, uint);


    event BindParent(address,address);


    modifier onlyAdmin {
        require(msg.sender == admin,"You Are not admin");
        _;
    }

    //上级必须有上级
    modifier checkParent(address _parentAddr){
        require(relations[_parentAddr]!=address(0),"superior must have superior");
        _;
    }


    function initialize(address payable _admin,
        address _egnAddr,
        address _usdtAddr,
        uint _restStakingNumberEGN,
        uint _restStakingNumberUSDT,
        uint _restStakingSingle
    ) external {
        require(!initialized,"initialized");
        admin = _admin;

        EGN = IERC20Upgradeable(_egnAddr);
        USDT = IERC20Upgradeable(_usdtAddr);

        restStakingNumberEGN=_restStakingNumberEGN;
        restStakingNumberUSDT=_restStakingNumberUSDT;

        restStakingSingle=_restStakingSingle;

        //0.01
        minEnabledAmount=1*10**4 wei;
        //1
        referAwardAmount=1*10**6 wei;
        //0.0001
        minStakingEGN=1*10**2 wei;

        referSwitch=true;

        initialized = true;
    }

    //设置管理员
    function setAdmin(address payable _admin) external onlyAdmin {
        admin = _admin;
    }

    /*
    * 设置推荐奖励参数
    * _referSwitch ：开 true  关:false
    * _referAwardAmount 绑定上级奖励数量
    */
    function setRefer(bool _referSwitch,uint _referAwardAmount) external onlyAdmin {
        referSwitch = _referSwitch;
        referAwardAmount=_referAwardAmount;
    }



    //设置双币剩余质押量
    function setRestStakingNumber(uint _restStakingNumberEGN,uint _restStakingNumberUSDT) external onlyAdmin{
        restStakingNumberEGN=_restStakingNumberEGN;
        restStakingNumberUSDT=_restStakingNumberUSDT;
    }

    //绑定上级
    function bindParent(address _parentAddr,uint _egnAmount) external checkParent(_parentAddr){
        //未绑定
        require(relations[msg.sender]==address(0),"binding already exists!");
        //不能绑定自己
        require(msg.sender!=_parentAddr,"Can't set myself");
        //持有达标
        require(EGN.balanceOf(msg.sender)>=minEnabledAmount,"Your egn holdings are insufficient! ");
        //上级持有达标
        require(EGN.balanceOf(_parentAddr)>=minEnabledAmount,"(_parentAddr) egn holdings are insufficient! ");
        //给上级转账数量符合
        require(_egnAmount>=minEnabledAmount,"The transfer amount must be more then 0.01");


        EGN.transferFrom(msg.sender,_parentAddr,_egnAmount);

        if(referSwitch){
            EGN.transfer(_parentAddr,referAwardAmount);
            referAwardTotal+=referAwardAmount;
            referAwards[_parentAddr]+=referAwardAmount;
        }

        relations[msg.sender]=_parentAddr;

        emit BindParent(msg.sender,_parentAddr);
    }


    //修改上级
    function editParent(address _childAddr,address _parentAddr) external onlyAdmin{

        relations[_childAddr]=_parentAddr;

        emit BindParent(_childAddr,_parentAddr);
    }



    //双币质押
    function addStakingDouble(uint _usdtAmount,uint _egnAmount) external checkParent(msg.sender){
        require(EGN.balanceOf(msg.sender)>=minEnabledAmount,"Please activate your address");

        require(_egnAmount>=minStakingEGN,"Insufficient pledges");

        require(restStakingNumberEGN>=_egnAmount,"Insufficient remaining pledge amount");

        require(restStakingNumberUSDT>=_usdtAmount,"Insufficient remaining pledge amount");


        USDT.transferFrom(msg.sender, address(this), _usdtAmount);

        EGN.transferFrom(msg.sender, address(0x000000000000000000000000000000000000dEaD),_egnAmount);

        restStakingNumberEGN-=_egnAmount;
        restStakingNumberUSDT-=_usdtAmount;

        emit AddStakingDouble(msg.sender, _usdtAmount,_egnAmount);
    }

    //设置单币质押剩余
    function setRestStakingSingle(uint _restStakingSingle) external onlyAdmin{
        restStakingSingle=_restStakingSingle;
    }


    //单币质押
    function addStakingSingle(uint _egnAmount) external checkParent(msg.sender){

        require(EGN.balanceOf(msg.sender)>=minEnabledAmount,"Please activate your address");

        require(_egnAmount>=minStakingEGN,"Insufficient pledges");

        require(restStakingSingle>=_egnAmount,"Insufficient remaining pledge amount");

        restStakingSingle-=_egnAmount;
        EGN.transferFrom(msg.sender, address(this),_egnAmount);
        emit AddStakingSingle(msg.sender,_egnAmount);
    }





    function batchAdminWithdrawEGN(address[] memory _userList, uint[] memory _amount) external onlyAdmin {
        for (uint i = 0; i < _userList.length; i++) {
            EGN.transfer(address(_userList[i]), uint(_amount[i]));
        }
    }


    function withdrawEGN(address _addr, uint _amount) external onlyAdmin {
        require(_addr!=address(0),"Can not withdraw to Blackhole");
        EGN.transfer(_addr, _amount);
    }

    function withdrawUSDT(address _addr, uint _amount) external onlyAdmin {
        require(_addr!=address(0),"Can not withdraw to Blackhole");
        USDT.transfer(_addr, _amount);
    }

    function getBalanceEGN() view external returns(uint){
        return EGN.balanceOf(address(this));
    }

    function getBalanceUSDT() view external returns(uint){
        return USDT.balanceOf(address(this));
    }



    receive () external payable {}


}