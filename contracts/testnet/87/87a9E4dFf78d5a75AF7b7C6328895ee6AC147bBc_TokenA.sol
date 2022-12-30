/**
 *Submitted for verification at BscScan.com on 2022-12-29
*/

//SPDX-License-Identifier:Unlicensed
pragma solidity ^0.8.13;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
    
}

interface IERC20 {

    function name() external view returns(string memory);
    function symbol() external view returns(string memory);
    function decimals() external view returns(uint256);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}

abstract contract Context {

    function _msgSender() internal view returns(address){
        return(msg.sender);
    }

    function _msgData() internal pure returns(bytes memory){
        return(msg.data);
    }

}

abstract contract Pausable is Context {

    event Paused(address indexed account);
    event Unpaused(address indexed account);

    bool private _paused;

    constructor () {
        _paused = false;
    }

    function paused() public view returns(bool){
        return _paused;
    }

    modifier whenNotPaused{
        require(!paused(),"Pasuable : Paused");
        _;
    }

    modifier whenPaused(){
        require(paused(),"Pasuable : Not Paused");
        _;
    }

    function _pause() internal whenNotPaused{
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal whenPaused{
        _paused = false;
        emit Unpaused(_msgSender());
    }

}

abstract contract Ownable is Context{

    address private _owner;

    event TransferOwnerShip(address oldOwner, address newOwner);

    constructor () {
        _owner = _msgSender();
        emit TransferOwnerShip(address(0), _owner);
    }

    function owner() public view returns(address){
        return _owner;
    }

    modifier onlyOwner {
        require(_owner == _msgSender(),"Only allowed to Owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0),"ZEROADDRESS");
        require(newOwner != _owner, "Entering OLD_OWNER_ADDRESS");
        emit TransferOwnerShip(_owner, newOwner);
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal onlyOwner {
        _owner = newOwner;
    }

    function renonceOwnerShip() public onlyOwner {
        _owner = address(0);
    }

}

contract TokenA is Ownable, IERC20, Pausable{

    using SafeMath for uint256;

    string private name_ = "TokenA";
    string private symbol_ = "tknA";
    uint256 private decimals_ = 18;
    uint256 private totalSupply_ = 300000000000*10**18;

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    constructor() {
        balances[owner()] = totalSupply_ ;
        emit Transfer(address(0), owner(), totalSupply_);
    }

    function name() external view returns(string memory){
        return name_;
    }

    function symbol() external view returns(string memory){
        return symbol_;
    }

    function decimals() external view returns(uint256){
        return decimals_;
    }

    function totalSupply() external view returns (uint256){
        return totalSupply_;
    }

    function transfer(address receiver, uint256 numTokens) external whenNotPaused returns (bool) {
        require(numTokens <= balances[_msgSender()],"INSUFFICIENT_BALANCE");
        require(numTokens > 0, "INVALID_AMOUNT");
        require(receiver != address(0),"TRANSFERING_TO_ZEROADDRESS");

        balances[_msgSender()] = balances[_msgSender()].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(_msgSender(), receiver, numTokens);
        return true;
    }

    function balanceOf(address account) external view returns (uint256){
        return balances[account];
    }

    function approve(address delegate, uint256 numTokens) external returns (bool) {
        require(delegate != address(0),"APPROVING_TO_ZEROADDRESS");
        require(numTokens > 0, "INVALID_AMOUNT");

        allowed[_msgSender()][delegate] = numTokens;
        emit Approval(_msgSender(), delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) external view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) external whenNotPaused returns (bool) {
        require(numTokens <= balances[owner],"INSUFFICIENT_BALANCE");
        require(numTokens <= allowed[owner][_msgSender()],"INSUFFICIENT_APPROVAL");
        require(buyer != address(0),"TRANSFERING_TO_ZEROADDRESS");

        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][_msgSender()] = allowed[owner][_msgSender()].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }

    function increaseAllowance(address _spender, uint256 _numTokens) external returns(bool){
        require(_spender != address(0), "INCREASING ALLOWANCE TO ZEROADDRESS");
        require(_numTokens > 0 , "INVALID NUMTOKENS");

        allowed[_msgSender()][_spender] = allowed[_msgSender()][_spender].add(_numTokens);
        return true;
    }

    function decreaseAllowance(address _spender, uint256 _numTokens) external returns(bool){
        require(_spender != address(0), "INCREASING ALLOWANCE TO ZEROADDRESS");
        require(_numTokens > 0 , "INVALID NUMTOKENS");

        allowed[_msgSender()][_spender] = allowed[_msgSender()][_spender].sub(_numTokens);
        return true;
    }

    function mint(address account, uint256 amount) external onlyOwner whenNotPaused {
        require(account != address(0), "MINT_TO_ZEROADDRESS");
        require(amount > 0, "INVALID_AMOUNT");

        totalSupply_ = totalSupply_.add(amount);
        balances[account] = balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function burn(address account, uint256 amount) external onlyOwner whenNotPaused {
        require(account == _msgSender(), "ONLY_ALLOWED_TO_BURN_OWN_TOKENS");
        require(account != address(0), "BURN_FROM_ZEROADDRESS");
        require(amount > 0, "INVALID_AMOUNT");

        balances[account] = balances[account].sub(amount);
        totalSupply_ = totalSupply_.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

}