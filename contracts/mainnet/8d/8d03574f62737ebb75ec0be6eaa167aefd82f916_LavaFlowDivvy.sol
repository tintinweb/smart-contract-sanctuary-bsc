/**
 *Submitted for verification at BscScan.com on 2022-04-09
*/

// Original Build by FEGROX

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.7.6;



abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

// ----------------------------------------------------------------------------
// SafeMath library
// ----------------------------------------------------------------------------


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
    
    function ceil(uint a, uint m) internal pure returns (uint r) {
        return (a + m - 1) / m * m;
    }
}

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address payable public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {
        require(_newOwner != address(0), "ERC20: sending to the zero address");
        owner = _newOwner;
        emit OwnershipTransferred(msg.sender, _newOwner);
    }
}

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// ----------------------------------------------------------------------------
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address tokenOwner) external view returns (uint256 balance);
    function allowance(address tokenOwner, address spender) external view returns (uint256 remaining);
    function transfer(address to, uint256 tokens) external returns (bool success);
    function approve(address spender, uint256 tokens) external returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) external returns (bool success);
    function burnTokens(uint256 _amount) external;
    
    function calculateFeesBeforeSend(
        address sender,
        address recipient,
        uint256 amount
    ) external view returns (uint256, uint256);
    
    
    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}

// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------

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

contract LavaFlowDivvy is Owned, ReentrancyGuard {
    using SafeMath for uint256;
    
    bool private _paused;
    address private _activeTokenAddress;
    mapping (address => bool) private _claimer;
    mapping (address => uint256) private _locked;

    mapping (address => uint256) public transData;

    constructor() {
        _claimer[msg.sender] = true;
        _paused = true;
    }

    modifier onlyClaimers() {
        require(_claimer[msg.sender], "Claimer: caller is not the allowed list of claimer");
        _;
    }

    function setTokenAddress(address tokenAddress) public onlyClaimers{
        _activeTokenAddress = tokenAddress;
    }

    function isContract(address account) internal view returns (bool) {
       uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function resetFloor() external onlyClaimers{
        _locked[_activeTokenAddress] = IERC20(_activeTokenAddress).balanceOf(address(this));
    }
    
    function availableReflections() external view returns(uint256){
        return IERC20(_activeTokenAddress).balanceOf(address(this)) - _locked[_activeTokenAddress];
    }

    function lockedSupply(address tokenAddress) view external returns(uint256){
        return _locked[tokenAddress];
    }

    function pause() external onlyClaimers{
        _paused = true;
    }
    
    function unpause() external onlyClaimers{
        _paused = false;
    }

    function currentActiveToken() external view returns(address){
        return _activeTokenAddress;
    }

    function isClaimer(address toCheck) external view returns(bool){
        return _claimer[toCheck];
    }

    function addClaimer(address toAdd) external onlyClaimers{
        _claimer[toAdd] = true;
    }

    function removeClaimer(address toRemove) external onlyClaimers{
        _claimer[toRemove] = false;
    }
    
    modifier noContract() {
        require(isContract(msg.sender) == false, 'Unapproved contracts are not allowed to interact with the swap');
        _;
    }
    
    function GetFaucetRewards() external nonReentrant noContract { 
        require(_paused == false, "Claiming is paused");
        uint256 timeNow = block.timestamp;
        if(timeNow < transData[msg.sender] + 1440 minutes){
            revert("FOR VALUE PROTECTION, YOU CAN ONLY CLAIM ONCE EVERY 24 HOURS");
        }
        uint256 transferToAmount = IERC20(_activeTokenAddress).balanceOf(address(this)) - _locked[_activeTokenAddress];
        require(IERC20(_activeTokenAddress).transfer(address(msg.sender), transferToAmount), "Error in un-staking tokens");
        saveTransData(msg.sender, block.timestamp);
    }

    function saveTransData(address sender, uint256 _timestamp) internal {
        require(sender != address(0), "Error: sending from 0 address");        
        transData[sender] = _timestamp;
    }

}