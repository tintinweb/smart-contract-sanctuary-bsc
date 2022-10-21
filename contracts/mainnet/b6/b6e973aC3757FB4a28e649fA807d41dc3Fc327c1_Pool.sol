/**
 *Submitted for verification at BscScan.com on 2022-10-21
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
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

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
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

pragma solidity ^0.8.0;

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
    constructor() {
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

pragma solidity ^0.8.0;

abstract contract isOpenCCOINConvert is Context {

    event OpenedCC(address account);
    event ClosedCC(address account);
    bool private _isOpenCC;

    constructor() {
        _isOpenCC = true;
    }

    function isOpenCC() public view virtual returns (bool) {
        return _isOpenCC;
    }

    modifier whenOpenCC() {
        require(isOpenCC(), "CCOIN Convert is Closed");
        _;
    }

    modifier whenCloseCC() {
        require(!isOpenCC(), "CCOIN Convert is Opened");
        _;
    }

    function openCC() external virtual whenCloseCC {
        _isOpenCC = true;
        emit OpenedCC(_msgSender());
    }

    function closeCC() external virtual whenOpenCC {
        _isOpenCC = false;
        emit ClosedCC(_msgSender());
    }
}

pragma solidity ^0.8.0;

abstract contract DITransfer is Context {

    event DirectTransfer(address account);
    event IndirectTransfer(address account);
    bool private _isDirect;

    constructor() {
        _isDirect = false;
    }

    function Direct() public view virtual returns (bool) {
        return _isDirect;
    }

    modifier isDirect() {
        require(Direct(), "Exchange mode is Indirect");
        _;
    }

    modifier isIndirect() {
        require(!Direct(), "Exchange mode is Direct");
        _;
    }

    function setDirect() external virtual isIndirect {
        _isDirect = true;
        emit DirectTransfer(_msgSender());
    }

    function setIndirect() external virtual isDirect {
        _isDirect = false;
        emit IndirectTransfer(_msgSender());
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
     * by making the `nonReentrant` function external, and make it call a
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

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */
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
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
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
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeERC20 {
    using SafeMath for uint;

    function safeTransfer(IERC20 token, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(isContract(address(token)), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}

pragma solidity ^0.8.0;

 /**
 * @title Contract that will work with ERC223 tokens.
 */
 
abstract contract IERC223Recipient {


 struct ERC223TransferInfo
    {
        address token_contract;
        address sender;
        uint256 value;
        bytes   data;
    }
    
    ERC223TransferInfo private tkn;
    
/**
 * @dev Standard ERC223 function that will handle incoming token transfers.
 *
 * @param _from  Token sender address.
 * @param _value Amount of tokens.
 * @param _data  Transaction metadata.
 */
    function tokenReceived(address _from, uint _value, bytes memory _data) public virtual
    {
        /**
         * @dev Note that inside of the token transaction handler the actual sender of token transfer is accessible via the tkn.sender variable
         * (analogue of msg.sender for Ether transfers)
         * 
         * tkn.value - is the amount of transferred tokens
         * tkn.data  - is the "metadata" of token transfer
         * tkn.token_contract is most likely equal to msg.sender because the token contract typically invokes this function
        */
        tkn.token_contract = msg.sender;
        tkn.sender         = _from;
        tkn.value          = _value;
        tkn.data           = _data;
        
        // ACTUAL CODE
    }
}

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
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
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

pragma solidity ^0.8.0;

contract Pool is Ownable, Pausable, ReentrancyGuard, isOpenCCOINConvert, DITransfer {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    IERC20 public BUSDtoken;
    IERC20 public USDTtoken;
    IERC20 public CCOINtoken;
    IERC20 public CCXStoken;


    address public adminAddress;
    address public operatorAddress;
    address private tokensAddress;
    uint256 public _ccoinPrice = 35;


    event NewAdminAddress(address admin);
    event NewOperatorAddress(address operator);
    event TokenRecovery(address indexed token, uint256 amount);
    event Transfer(IERC20 indexed token, address to, uint256 amount);
    event NewPackage(uint8 indexed number, uint256 available, uint256 payoutAmount, uint256 expire, bool isActive );
    event CCoinExchangeRate(uint256 newrate,address by);

    struct PackageDetails {
        uint256 AvailableNum;
        uint256 PayoutAmount;
        uint256 expireTime;
        bool isActive;
    } 
  
    mapping(uint8 => PackageDetails ) public Packages;


    constructor(address _CCOINtoken, address _BUSDtoken, address _USDTtoken, address _CCXStoken){
       //require(isContract(_BUSDtoken) && isContract(_USDTtoken) && isContract(_CCOINtoken) && isContract(_CCXStoken));
       
        CCOINtoken = IERC20(_CCOINtoken);
        BUSDtoken = IERC20(_BUSDtoken);
        USDTtoken = IERC20(_USDTtoken);
        CCXStoken = IERC20(_CCXStoken);
        
        adminAddress = msg.sender;

    }
    
    function _AddPackage(uint8 _num,uint256 _avaliableNum, uint256 _payoutAmount, uint256 _endTime, bool _isActive) private {
        Packages[_num] = PackageDetails(_avaliableNum,_payoutAmount,_endTime,_isActive);
        emit NewPackage(_num,_avaliableNum,_payoutAmount,_endTime,_isActive);
    }

    function AddMultiPackage(uint8[] calldata _num, uint256[] calldata _avaliableNum, uint256[] calldata _payoutAmount, uint256[] calldata _endTime,bool[] calldata _isActive) external onlyAdminOrOperator {
        require((_num.length == _avaliableNum.length) && (_num.length == _payoutAmount.length) && (_num.length == _endTime.length) && (_num.length == _isActive.length), "Invalid parameters Input length");
        for(uint8 i = 0; i < _num.length ; i++ ){
             _AddPackage(_num[i],_avaliableNum[i], _payoutAmount[i],_endTime[i],_isActive[i]);
        }   
    }

    function getBlockTimeStamp() public view returns (uint256){
        return block.timestamp;
    }

    function _subPackage(uint8 _package) private {
        Packages[_package].AvailableNum -= 1;
    }

    // Indirect transfer for Package
    function packageSold(address _token, address _buyer, uint8 _package) external onlyAdminOrOperator nonReentrant isIndirect whenNotPaused{
        require(Packages[_package].isActive, "Package: Not Active");
        require(Packages[_package].AvailableNum > 0 , "Package: Sold Out!");
        require(Packages[_package].expireTime > getBlockTimeStamp(), "Package: Expired");

        _subPackage(_package);

        IERC20(_token).transfer(address(_buyer), Packages[_package].PayoutAmount);
        emit Transfer(IERC20(_token), _buyer ,Packages[_package].PayoutAmount);
    }

    // Indirect transfer able to pay with USDT and BUSD
    function usdxExchange(address _buyer ,uint256 _amount) external onlyAdminOrOperator isIndirect whenNotPaused{
        uint256 _ccoinAmount = _amount.mul(_ccoinPrice);
        CCOINtoken.safeTransfer(_buyer,_ccoinAmount);
        emit Transfer(CCOINtoken, _buyer ,_ccoinAmount);
    }

    function exchangeCCoin(address _to , uint256 _amount) public onlyAdminOrOperator nonReentrant whenNotPaused isIndirect whenOpenCC{
        IERC20(CCOINtoken).transfer(address(_to), _amount);
        emit Transfer(IERC20(CCOINtoken), _to ,_amount);
    }

    // ^^^ Indirect ^^^

    // Direct transfer USDT
    function usdtExchange(uint256 _amount) public whenNotPaused isDirect{
        require(_amount <= USDTtoken.allowance(msg.sender, address(this)));
        uint256 _ccoinAmount = _amount.mul(_ccoinPrice);
        USDTtoken.safeTransferFrom(msg.sender, address(this), _amount);
        CCOINtoken.safeTransfer(msg.sender,_ccoinAmount);
    }


    function busdExchange(uint256 _amount) public whenNotPaused isDirect{
        require(_amount <= BUSDtoken.allowance(msg.sender, address(this)));
        uint256 _ccoinAmount = _amount.mul(_ccoinPrice);
        BUSDtoken.safeTransferFrom(msg.sender, address(this), _amount);
        CCOINtoken.safeTransfer(msg.sender,_ccoinAmount);
    } 


    function ccoinExchange(uint256 _amount) public whenNotPaused isDirect whenOpenCC(){
        require(_amount <= CCXStoken.allowance(msg.sender, address(this)));
        CCXStoken.safeTransferFrom(msg.sender, address(this), _amount);
        CCOINtoken.safeTransfer(msg.sender,_amount);
    }
    // ^^^ Direct ^^^

    function stopMarket() external onlyAdminOrOperator whenNotPaused {
        _pause();
    }

    function resumeMarket() external onlyAdminOrOperator whenPaused {
        _unpause();
    }

    function ccoinRateChange(uint256 _newRate) external onlyAdminOrOperator {
        _ccoinPrice = _newRate;
        emit CCoinExchangeRate(_newRate, msg.sender);

    }

    function activePackage(uint8 _package) external onlyAdminOrOperator {
        require(!Packages[_package].isActive , "Package: Already Active");
        Packages[_package].isActive = true;
    }

    function deactivePackahe(uint8 _package) external onlyAdminOrOperator {
        require(Packages[_package].isActive , "Package: Already Deactive");
        Packages[_package].isActive = false;
    }
 

    // Reciver Token to Owner address
    function recoverToken(address _token, uint256 _amount) external onlyAdminOrOperator nonReentrant {
        IERC20(_token).transfer(address(owner()), _amount);
        emit TokenRecovery(_token, _amount);
    }


    function transferToken(address _token, address _to , uint256 _amount) public onlyAdmin nonReentrant whenNotPaused {
        IERC20(_token).transfer(address(_to), _amount);
        emit Transfer(IERC20(_token), _to ,_amount);
    }


    
    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "Not admin");
        _;
    }

    modifier onlyOperator() {
        require(msg.sender == operatorAddress, "Not operator");
        _;
    }
    
    modifier onlyAdminOrOperator() {
        require(msg.sender == adminAddress || msg.sender == operatorAddress, "Not operator/admin");
        _;
    }

       /**
     * @notice Set operator address
     * @dev Callable by admin
     */
    function setOperator(address _operatorAddress) external onlyAdmin {
        require(_operatorAddress != address(0), "Cannot be zero address");
        operatorAddress = _operatorAddress;

        emit NewOperatorAddress(_operatorAddress);
    }

     /**
     * @notice Set admin address
     * @dev Callable by owner
     */
    function setAdmin(address _adminAddress) external onlyOwner {
        require(_adminAddress != address(0), "Cannot be zero address");
        adminAddress = _adminAddress;

        emit NewAdminAddress(_adminAddress);
    }

    

    

}