/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
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

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _setOwner(_msgSender());
    }
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
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

library Address {
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

abstract contract Pausable is Context {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

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

interface IMasterChef {
    function stake(uint256 _amount) external;
    function getReward() external;
    function withdraw(uint256 _amount) external;
    function exit() external;
    function earned(address) external view returns(uint256);
    function balanceOf(address) external view returns(uint256);
}



contract MasterchefScalper is ERC20("ScalpLP ", "Slp-"), Ownable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IERC20 public immutable baseAsset;
    IERC20 public immutable rewardAsset;
    IERC20 public stableAsset;
    IERC20 public immutable lp0;
    IERC20 public immutable lp1;
    IMasterChef public immutable masterChef;
    uint256 public immutable stakingPid;
    uint256 public totalshares;
    address[] public addresses;
    address[] public rewardToStable;
    address[] public rewardToLp0;
    address[] public rewardToLp1;
    mapping (address => uint256) public share;
    mapping (address => address) public referrar;
    mapping(address => bool) public whitelist;
    uint256 public performanceFee = 200;
    uint256 public governanceDivident = 100;

    event Deposit(address indexed sender, uint256 amount, uint256 lastDepositedTime);
    event Withdraw(address indexed sender, uint256 currentAmount, uint256 amount);
    event Compounded(address, uint256);
    event SetAddresses(address indexed unirouter, address indexed treasury, address indexed governanceTreasury);
    event SetPerformanceFee(uint256 performanceFee);
    event SetGovernanceDividentFee(uint256 governanceDivident);
    event EmergencyWithdraw();
    event UserEmergencyWithdraw(address, uint256);

    constructor(
        IERC20 _baseAsset,
        IERC20 _rewardAsset,
        IERC20 _stableAsset,
        IERC20 _lp0,
        IERC20 _lp1,
        IMasterChef _masterChef,
        uint256 _stakingPid,
        address[] memory _addresses,
        address[] memory _rewardToLp0,
        address[] memory _rewardToLp1,
        address[] memory _rewardToStable
    ) {

        baseAsset = _baseAsset;
        rewardAsset = _rewardAsset;
        stableAsset = _stableAsset;
        masterChef = _masterChef;
        stakingPid = _stakingPid;
        addresses = _addresses;
        rewardToLp0 = _rewardToLp0;
        rewardToLp1 = _rewardToLp1;
    	lp0 = _lp0;
        lp1 = _lp1;
        rewardToStable = _rewardToStable;

        IERC20(_baseAsset).safeApprove(address(_masterChef), type(uint256).max);
        IERC20(_rewardAsset).safeApprove(addresses[0], type(uint256).max);
        if(_rewardAsset != _lp0){
        IERC20(_lp0).safeApprove(addresses[0], type(uint256).max);
        }
        if(_rewardAsset != _lp1){
        IERC20(_lp1).safeApprove(addresses[0], type(uint256).max);
        }
    }

     function depositAll(address _referrar) external {
         require(tx.origin==msg.sender || whitelist[msg.sender], "Contract cannot stake");
        deposit(IERC20(baseAsset).balanceOf(msg.sender),_referrar);
    }
   
    function deposit(uint256 _amount,address _referrar) public whenNotPaused nonReentrant {
        require(_amount > 0, "Nothing to deposit");
        require(tx.origin==msg.sender || whitelist[msg.sender], "Contract cannot stake");
        //Checkpoint:1 - Check if farm can auto harvest on deposit or withdrawal, remove if auto harvests
        _harvest();
        if(share[msg.sender]==0){
        if(_referrar!=address(0)){
            referrar[msg.sender] = _referrar;
        }
        }
        IERC20(baseAsset).safeTransferFrom(msg.sender, address(this), _amount);
        _earn();
        _compound();
        uint256 value = baseAssetBalanceOf().sub(_amount);
        if(totalshares == 0){
        share[msg.sender] = _amount;
        totalshares = share[msg.sender];
                }
        else {
            uint256 c = _amount.mul(totalshares).div(value);
            share[msg.sender] = share[msg.sender].add(c); 
            totalshares = totalshares.add(c);
        }
        _mint(msg.sender, _amount);
        emit Deposit(msg.sender, _amount, block.timestamp);  
    }
        function withdrawAll() external {
        require(tx.origin==msg.sender || whitelist[msg.sender], "Contract cannot withdraw");
        withdraw(balanceOf(msg.sender));
    }
    function withdraw(uint256 _amount) public nonReentrant {
        require(_amount <= balanceOf(msg.sender), "Withdraw amount exceeds balance");
         require(tx.origin==msg.sender || whitelist[msg.sender], "Contract cannot withdraw");
        uint256 bal = available();
        if (bal < _amount) {
            uint256 balWithdraw = _amount - bal;
            //Checkpoint:4 - Check for function name for withdraw in farm/pool
           // IMasterChef(masterChef).withdrawAndHarvest(stakingPid, balWithdraw, address(this));
            IMasterChef(masterChef).withdraw(balWithdraw);
            //Checkpoint:3 - Check if farm can auto harvest on deposit or withdrawal, remove if auto harvests
            _harvest();
            //IMasterChef(masterChef).leaveStaking(balWithdraw);
            uint256 balAfter = available();
            uint256 diff = balAfter - bal;
            if (diff < balWithdraw) {
            _amount = balAfter;
            }
        }
        if(_amount==0){
        _harvest();
        }
        _compound();
        uint256 calc = share[msg.sender].mul(getPricePerFullShare()).div(1e18);
        uint256 interest = calc.sub(balanceOf(msg.sender));
        uint256 referrarshare = interest.div(100);
        uint256 tempshare = totalshares-share[msg.sender];
        uint256 tempsupply = baseAssetBalanceOf().sub(calc);
        if(tempshare==0){
        share[msg.sender] = balanceOf(msg.sender).sub(_amount);
        }
        else{
        share[msg.sender] = (balanceOf(msg.sender).sub(_amount)).mul(tempshare).div(tempsupply); 
        }
        totalshares = tempshare.add(share[msg.sender]); 
        if(referrar[msg.sender]!=address(0))
        {
        IERC20(baseAsset).safeTransfer(msg.sender, calc.sub(referrarshare));
        IERC20(baseAsset).safeTransfer(referrar[msg.sender], referrarshare);
        }
        else{
        IERC20(baseAsset).safeTransfer(msg.sender, calc);
        }
        _burn(msg.sender, _amount);    
        emit Withdraw(msg.sender, _amount , interest);
    }

   //View function

    function baseAssetBalanceOf() public view returns (uint256) {
         return IERC20(baseAsset).balanceOf(address(this)).add(IMasterChef(masterChef).balanceOf(address(this)));
    }
    
    function rewardAssetBalance() public view returns (uint256) {
        return IERC20(rewardAsset).balanceOf(address(this));
   
    }
//UI
    function balance() external view returns (uint) {   //Changed from public to external
          return IERC20(baseAsset).balanceOf(address(this)).add(IERC20(baseAsset).balanceOf(address(masterChef)));
    }
//UI  
    function pendingRewards() external view returns (uint256) {
      //Checkpoint :7 
          return IMasterChef(masterChef).earned(address(this));
//UI
    }
     function shareRatio() external view returns (uint256) {
        return share[msg.sender].div(totalshares);
    }
    function available() public view returns (uint256) {
        return IERC20(baseAsset).balanceOf(address(this));
    }
//UI
    function getPricePerFullShare() public view returns (uint256) {
        return totalSupply() == 0 ? 1e18 : baseAssetBalanceOf().mul(1e18).div(totalshares);
    }


//Internal executions

    function _compound() internal {
        uint256 balrewardAsset = rewardAssetBalance();
        uint256 half = balrewardAsset.mul(485).div(1000); 
        if(half > 0){
        if(rewardAsset != lp0){
        IUniswapRouterETH(addresses[0]).swapExactTokensForTokens(half, 0, rewardToLp0, address(this), block.timestamp);
        }
        if(rewardAsset != lp1){
        IUniswapRouterETH(addresses[0]).swapExactTokensForTokens(half, 0, rewardToLp1, address(this), block.timestamp);
        }
        IUniswapRouterETH(addresses[0]).swapExactTokensForTokens(rewardAssetBalance(), 0, rewardToStable, address(this), block.timestamp);
        IUniswapRouterETH(addresses[0]).addLiquidity(address(lp0),address(lp1),lp0.balanceOf(address(this)),lp1.balanceOf(address(this)),1,1,address(this), block.timestamp);
        _earn();
        IERC20(stableAsset).safeTransfer(addresses[1], stableAsset.balanceOf(address(this)).div(3));
        IERC20(stableAsset).safeTransfer(addresses[2], stableAsset.balanceOf(address(this)));
        emit Compounded(msg.sender, balrewardAsset);
        }
    }
     
    function _earn() internal {
        uint256 bal = available();
        if (bal > 0) {
          //Checkpoint:2 - Check proper function name for deposit in farm/pool
           // IMasterChef(masterChef).deposit(stakingPid, bal, address(this));
             IMasterChef(masterChef).stake(bal);
        }
    }

    function harvest() external whenNotPaused nonReentrant {
        _harvest();   
    }

    function _harvest() internal{
      //Checkpoint-5: Check for proper function name for harvest in Farm/pool
         //IMasterChef(masterChef).claim(stakingPid);
         IMasterChef(masterChef).getReward();
    }
//Configurations

    function setPerformanceFee(uint256 _performanceFee) external onlyOwner {
        require(_performanceFee <= 500, "performanceFee cannot be more than MAX_PERFORMANCE_FEE(500)");
        performanceFee = _performanceFee;
        emit SetPerformanceFee(_performanceFee);
    }

    function setGovernanceDivident(uint256 _governanceDivident) external onlyOwner {
        require(_governanceDivident <= 500, "governanceDivident cannot be more than MAX_GOVERNANCE_DIVIDEND(500)");
        governanceDivident = _governanceDivident;
        emit SetGovernanceDividentFee(_governanceDivident);
    }
/*
    function emergencyWithdraw() external onlyOwner {
        IMasterChef(masterChef).emergencyWithdraw(stakingPid);
        _pause();
        emit EmergencyWithdraw();
    }
*/
    function pause() external onlyOwner {
        _pause();
    }
     
     function setWhitelist (address _whitelist) external onlyOwner{
        whitelist[_whitelist]=true;
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function setStableRoute(address[] memory _rewardToStable) external onlyOwner {
        rewardToStable = _rewardToStable;
     }
    
    function setAddresses(address _unirouter, address _treasury,address _governanceTreasury ) external onlyOwner {
        require(_unirouter != address(0), "Cannot be zero address");
        addresses=[_unirouter,_treasury,_governanceTreasury];

        IERC20(rewardAsset).safeApprove(addresses[0], type(uint256).max);
        IERC20(lp0).safeApprove(addresses[0], type(uint256).max);
        IERC20(lp1).safeApprove(addresses[0], type(uint256).max);
    }
    function inCaseTokensGetStuck(address _token) external onlyOwner {
        require(_token != address(baseAsset), "Not Allowed to withdraw staked token");
        require(_token != address(rewardAsset), "Not Allowed to withdraw reward token");
        require(_token != address(stableAsset), "Not Allowed to withdraw stable token");
        uint256 amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(msg.sender, amount);
    }
/*
    function userEmergencyWithdraw() external {
        require(balanceOf(msg.sender)>0, "No balance");
        require(tx.origin==msg.sender || whitelist[msg.sender], "Contract cannot withdraw");
        uint256 _amount = balanceOf(msg.sender);
        uint256 bal = available();
        if (bal < _amount) {
            uint256 balWithdraw = _amount - bal;
            //Checkpoint - 8
            IMasterChef(masterChef).withdrawAndHarvest(stakingPid, balWithdraw, address(this));
            //IMasterChef(masterChef).leaveStaking(balWithdraw);
            uint256 balAfter = available();
            uint256 diff = balAfter - bal;
            if (diff < balWithdraw) {
                _amount = balAfter;
            }
        }
        totalshares = totalshares.sub(share[msg.sender]);
        share[msg.sender] = 0;
        _burn(msg.sender, _amount);    
        IERC20(baseAsset).safeTransfer(msg.sender, _amount);
        emit UserEmergencyWithdraw(msg.sender, _amount);
}
*/
}


pragma solidity ^0.8.10;

interface IUniswapRouterETH {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn, 
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}