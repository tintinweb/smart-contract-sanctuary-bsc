/**
 *Submitted for verification at BscScan.com on 2022-08-03
*/

//SPDX-License-Identifier:MIT
pragma solidity ^ 0.8.12;


library SafeMath {
    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}
contract Context {
    constructor() {}

    function _msgSender() internal view returns(address) {
        return msg.sender;
    }

    function _msgData() internal view returns(bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

contract MinterRole is Context,Ownable {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender));
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyOwner {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



contract veFroyo is MinterRole {

    using SafeMath for uint256;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    mapping(address => uint256) private _balances;
    uint256 private _totalSupply;
    IERC20 Froyo = IERC20(0xC3d06270ac4b7Fc491ec885eFc7AB811b7606Fb8);
    mapping(uint => uint) public lockduration;
    mapping(address => uint) public acounttotallock;
    mapping(address => uint) public accountlockcounter;
    mapping(address => mapping(uint => uint)) public accountlockduration;
    mapping(address => mapping(uint => uint)) public accountlockamount;
    mapping(address => mapping(uint => bool)) public accountlockclaimed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event LockFroyo(address indexed owner, uint256 id, uint256 amount, uint256 releasetime);
    event ReleaseFroyo(address indexed owner, uint256 amount);

    //constructor
    constructor() {
        _owner = msg.sender;
        _name = "veFroyo";
        _symbol = "veFroyo";
        _decimals = 18;

        lockduration[1] = 7776000; //3 Months
        lockduration[2] = 31536000; //12 Months
        lockduration[3] = 63072000; // 24 Months
        lockduration[4] = 94608000; // 36 Months
    }

    function lock(uint _selection, uint _amount) public{
        require(_selection <= 4 && _selection >= 1, "Invalid selection");
        
        uint veamount = veFroyoAmount(_selection, _amount);
        
        uint transferamount = froyoAmount(_selection, veamount);

        //Receive Froyo
        Froyo.transferFrom(msg.sender, address(this), transferamount);

        //Transfer veFroyo
        mint(msg.sender, veamount);

        //Set Release Timestamp
        uint locktime = lockduration[_selection].add(block.timestamp);
        accountlockcounter[msg.sender] += 1;
        accountlockduration[msg.sender][accountlockcounter[msg.sender]] = locktime;
        accountlockamount[msg.sender][accountlockcounter[msg.sender]] = transferamount;
        acounttotallock[msg.sender] += transferamount;

        emit LockFroyo(msg.sender, accountlockcounter[msg.sender], transferamount, locktime);
    }

    function veFroyoAmount(uint _selection, uint _amount) internal pure returns(uint veamount){
        if(_selection == 1){
            veamount = _amount.mul(1e6).div(40 * 1e6);
        }
        else if(_selection == 2){
            veamount = _amount.mul(1e6).div(4 * 1e6);
        }
        else if(_selection == 3){
            veamount = _amount.mul(1e6).div(2 * 1e6);
        }
        else if(_selection == 4){
            veamount = _amount;
        }
        require(veamount > 0, "Amount too small");
    }

    function froyoAmount(uint _selection, uint veamount) internal pure returns(uint transferamount){
        if(_selection == 1){
            transferamount = veamount.mul(40);
        }
        else if(_selection == 2){
            transferamount = veamount.mul(4);
        }
        else if(_selection == 3){
            transferamount = veamount.mul(2);
        }
        else if(_selection == 4){
            transferamount = veamount;
        }
    }

    function testSetUnlockTime(address _user, uint _counter, uint _time) external onlyOwner(){
        accountlockduration[_user][_counter] = _time;
    }

    function unlock(uint _counter) public {
        require(block.timestamp > accountlockduration[msg.sender][_counter], "Not ready to unlock");
        require(accountlockclaimed[msg.sender][_counter] == false, "Claimed");

        //Receive Froyo
        Froyo.transfer(address(this), accountlockamount[msg.sender][_counter]);
        accountlockclaimed[msg.sender][_counter] == true;

        burn(accountlockamount[msg.sender][_counter]);

        emit ReleaseFroyo(msg.sender, accountlockamount[msg.sender][_counter]);
    }

    function setFroyo(address _froyo) external onlyOwner{
        Froyo = IERC20(_froyo);
    }

    function mint(address account, uint256 amount) public onlyMinter returns(bool) {
        require(amount>0);
        _mint(account, amount);
        return true;
    }
    
    function burn(uint256 amount) public onlyMinter returns(bool) {
        _burn(msg.sender, amount);
        return true;
    }

    function name() public view returns(string memory) {
        return _name;
    }

    function symbol() public view returns(string memory) {
        return _symbol;
    }

    function decimals() public view returns(uint8) {
        return _decimals;
    }

    function totalSupply() public view returns(uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns(uint256) {
        return _balances[account];
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

}