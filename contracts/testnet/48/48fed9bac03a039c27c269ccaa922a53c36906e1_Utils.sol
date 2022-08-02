/**
 *Submitted for verification at BscScan.com on 2022-08-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
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
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
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
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
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
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
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

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
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

interface IERC20 {
    
    function balanceOf(address account) external view returns (uint256);
}

interface LP {

    function totalSupply() external view returns (uint256);

    function token0() external view returns (IERC20);

    function token1() external view returns (IERC20);

    function balanceOf(address account) external view returns (uint256);
}

interface Router {
    function getAmountsOut(uint amountIn, address[] memory path) external
        view
        returns (uint[] memory amounts);
}

interface IMasterChef {

    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function enterStaking(uint256 _amount) external;

    function leaveStaking(uint256 _amount) external;

    function emergencyWithdraw(uint256 _pid) external;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

}

    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. DRGs to distribute per block.
        uint256 lastRewardBlock; // Last block number that DRGs distribution occurs.
        uint256 accDRGPerShare; // Accumulated DRGs per share, times 1e12. See below.
        IMasterChef poolMasterChef;
        IERC20 rewardToken;
    }

        struct PoolNFTInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. Powers to distribute per block.
        uint256 lastRewardBlock; // Last block number that Powers distribution occurs.
        uint256 accPowerPerShare; // Accumulated Powers per share, times 1e12. See below.
    }

interface MetaMasterChef {
    function poolInfo(uint256 pid) external view returns(PoolInfo memory);

    function totalAllocPoint() external view returns(uint256);

    function DDT() external view returns(address);

    function poolBalance(uint256 pid) external view returns(uint256);

    function DRGPerBlock() external view returns(uint256);

    function poolLength() external view returns(uint256);
}

interface NFTMasterChef {
    function poolInfo(uint256 pid) external view returns(PoolNFTInfo memory);

    function totalAllocPoint() external view returns(uint256);

    function DRG() external view returns(address);

    function poolBalance(uint256 pid) external view returns(uint256);

    function PowerPerBlock() external view returns(uint256);

    function poolLength() external view returns(uint256);
}

contract Utils is Ownable{
    using SafeMath for uint256;
    //WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    //BUSD = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    address public WBNB;
    address public BUSD;
    uint256 amount = 1000000000000000000;
    Router public routerAddress;

    uint256 BLOCKS_PER_YEAR = 10512000;

     constructor(Router _routerAddress, address _WBNB, address _BUSD) {
         routerAddress = _routerAddress;
         WBNB = _WBNB;
         BUSD = _BUSD;
    }

    function setRouter(Router _routerAddress) public onlyOwner{
        routerAddress = _routerAddress;
    }

    //Pass Test
    function Tokenprice(address token) public view returns(uint256){
        address[] memory path = new address[](3);
        path[0] = token;
        path[1] = WBNB;
        path[2] = BUSD;
        return routerAddress.getAmountsOut(amount,path)[2];
    }

    //Pass Test
    function WBNBPrice(address token) public view returns(uint256){
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = BUSD;
        return routerAddress.getAmountsOut(amount,path)[1];
    }

    //Pass Test
    function CalcLpPrice(LP lpAddress) public view returns(uint256){
        uint256 phase1;
        uint256 phase2;
        if(address(WBNB) == address(lpAddress.token0())){
            phase1 = (lpAddress.token0().balanceOf(address(lpAddress)).mul(WBNBPrice(address(lpAddress.token0()))));
        }else{
            phase1 = (lpAddress.token0().balanceOf(address(lpAddress)).mul(Tokenprice(address(lpAddress.token0()))));
        }

        if(address(WBNB) == address(lpAddress.token1())){
            phase2 = (lpAddress.token1().balanceOf(address(lpAddress)).mul(WBNBPrice(address(lpAddress.token1()))));
        }else{
            phase2 = (lpAddress.token1().balanceOf(address(lpAddress)).mul(Tokenprice(address(lpAddress.token1()))));
        }
        
        return ((phase1.add(phase2)).div(lpAddress.totalSupply()));
    }
    //Pass Test
    function calcPoolTVLInUSD(uint256 pid, LP lpAddress, uint256 isLp, MetaMasterChef MasterChef) public view returns(uint256){
        uint256 Balance = MasterChef.poolBalance(pid);
        uint256 price;
        if(isLp == 1){
            price = CalcLpPrice(lpAddress);
        }else if(isLp == 0){
            if(address(WBNB) == address(lpAddress)){
                price = WBNBPrice(address(lpAddress));
            }else{
                price = Tokenprice(address(lpAddress));
            }
        }

        return (Balance * price).div(amount);
    }

    function calcPoolTVLInUSDNFTFarm(LP lpAddress, uint256 isLp, MetaMasterChef MasterChef) public view returns(uint256){
        uint256 Balance = lpAddress.balanceOf(address(MasterChef));
        uint256 price;
        if(isLp == 1){
            price = CalcLpPrice(lpAddress);
        }else if(isLp == 0){
            if(address(WBNB) == address(lpAddress)){
                price = WBNBPrice(address(lpAddress));
            }else{
                price = Tokenprice(address(lpAddress));
            }
        }

        return (Balance * price).div(amount);
    }

    function CalcApy(uint256 pid, LP lpAddress,uint256 isLp, MetaMasterChef MasterChef) external view returns(uint256){
        PoolInfo memory pool = MasterChef.poolInfo(pid);
        uint256 poolWeight = ((pool.allocPoint).mul(amount)).div(MasterChef.totalAllocPoint());
        uint256 rewardTokenPrice = Tokenprice(MasterChef.DDT());
        uint256 DRG_PER_YEAR = BLOCKS_PER_YEAR.mul(MasterChef.DRGPerBlock());
        uint256 yearlyDRGRewardAllocation = (DRG_PER_YEAR.mul(poolWeight)).div(amount);
        uint256 poolLiquidityUsd = calcPoolTVLInUSD(pid, lpAddress, isLp, MasterChef);
        if(poolLiquidityUsd == 0){
            return 0;
        }else{
            return(((yearlyDRGRewardAllocation.mul(rewardTokenPrice))).div(poolLiquidityUsd)).mul(100);
        }
    }

    function CalcApyNFTFarm(uint256 pid, NFTMasterChef MasterChef) external view returns(uint256){
        PoolNFTInfo memory pool = MasterChef.poolInfo(pid);
        uint256 allocPoint = pool.allocPoint;
        uint256 totalAllocPoint = MasterChef.totalAllocPoint();
        uint256 PowerPerBlock = MasterChef.PowerPerBlock();
        uint256 Power_PER_DAY = (BLOCKS_PER_YEAR.mul(PowerPerBlock)).div(365);

        return (Power_PER_DAY.mul(allocPoint)).div(totalAllocPoint);
    }

    function isLpAddress(LP lpAddress) public view returns(uint256){
        try lpAddress.token0() {
            return 1;
        }catch{
            return 0;
        }
    }

    function CalcTotalTVL(MetaMasterChef MasterChef,LP[] memory lpAddress) external view returns(uint256){
        uint256 TVL = 0;
        for(uint256 i=0; i< lpAddress.length; i++){
            if(isLpAddress(lpAddress[i]) == 1){
                TVL += calcPoolTVLInUSD(i, lpAddress[i], 1, MasterChef);
            }else{
                TVL += calcPoolTVLInUSD(i, lpAddress[i], 0, MasterChef);
            }
        }

        return TVL;
    }

    function CalcTotalTVLNFTFarm(MetaMasterChef MasterChef,LP[] memory lpAddress) external view returns(uint256){
        uint256 TVL = 0;
        for(uint256 i=0; i< lpAddress.length; i++){
            if(isLpAddress(lpAddress[i]) == 1){
                TVL += calcPoolTVLInUSDNFTFarm(lpAddress[i], 1, MasterChef);
            }else{
                TVL += calcPoolTVLInUSDNFTFarm(lpAddress[i], 0, MasterChef);
            }
        }

        return TVL;
    }
}