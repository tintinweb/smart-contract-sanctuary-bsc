/**
 *Submitted for verification at BscScan.com on 2022-02-10
*/

//					$$\ $$\ $$\    $$\                    $$\   $$\     
//					\__|\__|$$ |   $$ |                   $$ |  $$ |    
//					$$\ $$\ $$ |   $$ |$$$$$$\  $$\   $$\ $$ |$$$$$$\   
//					$$ |$$ |\$$\  $$  |\____$$\ $$ |  $$ |$$ |\_$$  _|  
//					$$ |$$ | \$$\$$  / $$$$$$$ |$$ |  $$ |$$ |  $$ |    
//					$$ |$$ |  \$$$  / $$  __$$ |$$ |  $$ |$$ |  $$ |$$\ 
//					$$ |$$ |   \$  /  \$$$$$$$ |\$$$$$$  |$$ |  \$$$$  |
//					\__|\__|    \_/    \_______| \______/ \__|   \____/ 

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

// -------------------------------------- Context -------------------------------------------
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// -------------------------------------- Ownable -------------------------------------------
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// -------------------------------------- Address -------------------------------------------
library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
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
// -------------------------------------- IERC20 -------------------------------------------
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
// -------------------------------------- SafeMath -------------------------------------------
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}
// -------------------------------------- ERC20 -------------------------------------------
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return _decimals;
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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}
// ------------------------------------- SafeERC20 -------------------------------------------
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// ------------------------------------- ReentrancyGuard -------------------------------------------
abstract contract ReentrancyGuard {
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
// ------------------------------------- Pausable -------------------------------------------
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}
// ------------------------------------- IStrategy -------------------------------------------
interface IStrategy {
    function vault() external view returns (address);
    function want() external view returns (IERC20);
	function chef() external view returns (address);
	function poolId() external view returns (uint256);
    function beforeDeposit() external;
    function deposit() external;
    function withdraw(uint256) external;
    function balanceOf() external view returns (uint256);
    function balanceOfWant() external view returns (uint256);
    function balanceOfPool() external view returns (uint256);
	function rewardsAvailable() external view returns (uint256);
	function callReward() external view returns (uint256);
	function lastHarvest() external view returns (uint256);	
    function harvest() external;
    function retireStrat() external;
    function panic() external;
    function pause() external;
    function unpause() external;
    function paused() external view returns (bool);
    function unirouter() external view returns (address);
	function outputToWbnb() external view returns (address[] memory);
	function outputToLp0() external view returns (address[] memory);
	function outputToLp1() external view returns (address[] memory);	
	function withdrawalFee() external view returns (uint256);
	function profitFee() external view returns (uint256);
	function strategistFee() external view returns (uint256);
	function callFee() external view returns (uint256);
	function feeDelimiter() external view returns (uint256);		
}

// ------------------------------------------------------------------------------------------
// -------------------------------------- iiVault -------------------------------------------
// ------------------------------------------------------------------------------------------
contract iiVaultV3 is ERC20, Ownable, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
	// ---------------------------- STRUCTS ----------------------------------	
    struct StrategyCandidate {
        address implementation;
        uint proposedTime;
    }
	struct LastDepositUserData {
        uint256 timestamp;
        uint256 balance;
		uint256 pricePerFullShare;
		uint256 totalSupply;
		uint256 balanceWant;
		uint256 depositAmount;
    }
	struct VaultUserData {
        uint256 balance;
        uint256 allowance;
    }
    struct VaultData {
        bool productionMode;
	    bool paused;
        bool whiteListOnly;
        uint256 balance;
        uint256 available;
        uint256 pricePerFullShare;
		address tokenToHold;
	    uint256 minTokenToHold;
    }
    struct StrategyData {
		bool paused; 
        address strategy;
		address want;    
		address chef; 		
		uint256 poolId;   
        uint256 balanceOf;
        uint256 balanceOfWant;
        uint256 balanceOfPool;  
		uint256 lastHarvest;  		  
		uint256 rewardsAvailable; 
		address unirouter;
		uint256 withdrawalFee;
		uint256 profitFee;
		uint256 strategistFee;
		uint256 callFee;
		uint256 feeDelimiter;	
		address[] outputToWbnb;
		address[] outputToLp0;
		address[] outputToLp1;
    }

	// ---------------------------- VARS ----------------------------------	
	IStrategy public strategy;
    StrategyCandidate public strategyCandidate;    
    // The minimum time it has to pass before a strat candidate can be approved.
    uint256 public immutable approvalDelay;

    bool public whiteListOnly;
	bool public productionMode;
	mapping (address => bool) public operators; 
	mapping (address => bool) public whiteList; 
	mapping (address => LastDepositUserData) public lastDepositUserData;		
	address public tokenToHold;
	uint256 public minTokenToHold;

	// ---------------------------- CONSTRUCT ----------------------------------	    
    constructor () ERC20("iiVault-CAKE Token", "iiVault-CAKE") {
        strategy = IStrategy(address(0));
        approvalDelay = 6 hours;
        operators[owner()] = true;
		operators[0xbe4B76587aF273D2f78477B080BB5E22Ff0e560B] = true;
		whiteListOnly = false;
	}

	// ---------------------------- VIEWS ----------------------------------	
	// ------------------------------------------------
	function getData() public view returns (            
        VaultData memory vaultData,
        StrategyData memory strategyData
        ) {                        
        vaultData.productionMode = productionMode;
        vaultData.paused = paused();
        vaultData.whiteListOnly = whiteListOnly;        
		vaultData.tokenToHold = tokenToHold;
        vaultData.minTokenToHold = minTokenToHold; 

		if (address(strategy) != address(0) && strategy.vault() == address(this)) {
			vaultData.balance = balance();
        	vaultData.available = available();      
        	vaultData.pricePerFullShare = getPricePerFullShare(); 

			strategyData.strategy = address(strategy);
			strategyData.want = address(strategy.want());
			strategyData.chef = strategy.chef();
			strategyData.poolId = strategy.poolId();
			strategyData.unirouter = strategy.unirouter(); 

			strategyData.paused = strategy.paused();        
			strategyData.balanceOf = strategy.balanceOf();
			strategyData.balanceOfWant = strategy.balanceOfWant();
			strategyData.balanceOfPool = strategy.balanceOfPool();    
			strategyData.lastHarvest = strategy.lastHarvest(); 			 
			strategyData.rewardsAvailable = strategy.rewardsAvailable(); 
			
			strategyData.withdrawalFee = strategy.withdrawalFee(); 
			strategyData.profitFee = strategy.profitFee(); 
			strategyData.strategistFee = strategy.strategistFee(); 
			strategyData.callFee = strategy.callFee(); 
			strategyData.feeDelimiter = strategy.feeDelimiter();

			strategyData.outputToWbnb = strategy.outputToWbnb();
			strategyData.outputToLp0 = strategy.outputToLp0();
			strategyData.outputToLp1 = strategy.outputToLp1();
		} 
    }
	// ------------------------------------------------
    function getUserData(address account) public view returns (            
        VaultUserData memory vaultUserData,
		LastDepositUserData memory lastDepositData
        ) {
        vaultUserData.balance = balanceOf(account);
        vaultUserData.allowance = allowance(address(this), account); 
		lastDepositData = lastDepositUserData[account];    
    }
	// ------------------------------------------------
	function want() public view returns (IERC20) {
        return IERC20(strategy.want());
    }
	// ------------------------------------------------
	function balance() public view returns (uint) {
        return want().balanceOf(address(this)).add(IStrategy(strategy).balanceOf());
    }
	// ------------------------------------------------
    function available() public view returns (uint256) {
        return want().balanceOf(address(this));
    }
	// ------------------------------------------------
    // Function for various UIs to display the current value of one of our yield tokens.
    // Returns an uint256 with 18 decimals of how much underlying asset one vault share represents.
    function getPricePerFullShare() public view returns (uint256) {
        return totalSupply() == 0 ? 1e18 : balance().mul(1e18).div(totalSupply());
    }

    // ---------------------------- ADMIN ----------------------------------
	// ------------------------------------------------
	modifier onlyStrategySet() {
        require(address(strategy) != address(0), "No strategy");
		require(strategy.vault() == address(this), "No strategy");
        _;
    }
	// ------------------------------------------------
	function setOperator(address _operator) public onlyOwner {
        operators[_operator] = !operators[_operator];
    }
	// ------------------------------------------------
	modifier onlyOperator() {
        require(operators[_msgSender()] || owner() == _msgSender(), "Not allowed to call");
        _;
    }
	// ------------------------------------------------
	function setTokenHold(address token, uint256 amount) public onlyOwner {
        tokenToHold = token;
		minTokenToHold = amount;
    }
	// ------------------------------------------------
	modifier onlyTokenHold() {
		if (tokenToHold != address(0)) {
			require(IERC20(tokenToHold).balanceOf(_msgSender()) >= minTokenToHold, "You must hold minimun required tokens");
		}         
        _;
    }
	// ------------------------------------------------
	function setProductionMode() public onlyOperator {
		require(!productionMode, "Production mode already enabled");
        productionMode = true;
		whiteListOnly = false;
    }
	// ------------------------------------------------
	function setWhiteListOnly(bool state) public onlyOperator {
		require(!productionMode, "Not allowed in production mode");
        whiteListOnly = state;
    }
	// ------------------------------------------------
	function whiteListAccount(address account, bool state) public onlyOperator {
		whiteList[account] = state;	
    }
	// ------------------------------------------------
	function whiteListAccounts(address[] memory accounts, bool[] memory states) public onlyOperator {
		for (uint256 i = 0; i < accounts.length; i++) {
			whiteList[accounts[i]] = states[i];			
		}
    }
	// ------------------------------------------------
	modifier onlyWhiteList() {
		if (whiteListOnly && !productionMode) {			
			require(whiteList[_msgSender()] || operators[_msgSender()], "White list only");
		}        
        _;
    }	
	// ------------------------------------------------
	function migrateAccounts(address[] memory accounts, uint256[] memory balances) public onlyOperator { // whenPaused
		require(!productionMode, "!productionMode");
		for (uint256 i = 0; i < accounts.length; i++) {
			require(accounts[i] != address(0), "Mint to 0 address!");
			require(balances[i] != 0, "Mint 0!");
			_mint(accounts[i], balances[i]);			
		}
    }
	// ------------------------------------------------
	function migrateWant(address newVault) public onlyOperator {// whenPaused
		require(!productionMode, "!productionMode");
		want().safeTransfer(newVault, available());
    }
	// ------------------------------------------------
	function setStrategy(address _strategy) public onlyOwner {  
		require(!productionMode, "!productionMode");
		require(IStrategy(_strategy).vault() == address(this), "!strategy vault");
		
        if (address(strategy) != address(0)) {
            strategy.retireStrat();
        }
        
        strategy = IStrategy(_strategy);
		earn();                      
    }
    // ------------------------------------------------
    function proposeStrat(address _implementation) public onlyOperator {
        require(address(this) == IStrategy(_implementation).vault(), "Proposal not valid for this Vault");
        strategyCandidate = StrategyCandidate({
           	implementation: _implementation,
           	proposedTime: block.timestamp
        });
        emit NewStrategyCandidate(_implementation);
    }
    // ------------------------------------------------
    function upgradeStrat() public onlyOperator {
        require(strategyCandidate.implementation != address(0), "There is no candidate");
        require(strategyCandidate.proposedTime.add(approvalDelay) < block.timestamp, "Delay has not passed");

        emit UpgradeStrat(strategyCandidate.implementation);

        strategy.retireStrat();
        strategy = IStrategy(strategyCandidate.implementation);
        
		strategyCandidate.implementation = address(0);
        strategyCandidate.proposedTime = 5000 days;

        earn();
    }
    // ------------------------------------------------
    function recover(address _token) external onlyOperator {		
		if (productionMode) {
			require(_token != address(want()), "!token");
		}
        uint256 amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(msg.sender, amount);
    }

    // ---------------------------- MUTATIVE ----------------------------------
    // ------------------------------------------------
    function deposit(uint _amount) public nonReentrant onlyWhiteList onlyTokenHold {
        strategy.beforeDeposit();
        
        LastDepositUserData storage ld = lastDepositUserData[tx.origin];		
		ld.timestamp = block.timestamp;
		ld.balance = balanceOf(tx.origin);
		
		ld.pricePerFullShare = getPricePerFullShare();
		ld.totalSupply = totalSupply();
				
		uint256 _pool = balance();
		ld.balanceWant = _pool;

        want().safeTransferFrom(msg.sender, address(this), _amount);
        		
		earn();
        uint256 _after = balance();
        _amount = _after.sub(_pool); // Additional check for deflationary tokens
        uint256 shares = 0;
        if (totalSupply() == 0) {
            shares = _amount;
        } else {
            shares = (_amount.mul(totalSupply())).div(_pool);
        }
		ld.depositAmount = shares;
        _mint(msg.sender, shares);
    }
	// ------------------------------------------------	
    function depositAll() external {
        deposit(want().balanceOf(msg.sender));
    }
    // ------------------------------------------------
    function withdraw(uint256 _shares) public {
        uint256 r = (balance().mul(_shares)).div(totalSupply());
        _burn(msg.sender, _shares);

        uint256 b = want().balanceOf(address(this));
        if (b < r) {
            uint256 _withdraw = r.sub(b);
            strategy.withdraw(_withdraw);
            uint256 _after = want().balanceOf(address(this));
            uint256 _diff = _after.sub(b);
            if (_diff < _withdraw) {
                r = b.add(_diff);
            }
        }

        want().safeTransfer(msg.sender, r);
    }
	// ------------------------------------------------
	function withdrawAll() external {
        withdraw(balanceOf(msg.sender));
    }
	// ------------------------------------------------
	function earn() public onlyWhiteList {
        uint256 bal = available();
		if (bal != 0) {
			want().safeTransfer(address(strategy), bal);
        	strategy.deposit();
		}        
    }

    // ------------------------ EVENTS ----------------------------
	event NewStrategyCandidate(address implementation);
    event UpgradeStrat(address implementation);
}