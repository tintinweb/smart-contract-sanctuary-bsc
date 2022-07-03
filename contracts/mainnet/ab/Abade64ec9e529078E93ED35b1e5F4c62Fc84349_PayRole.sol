pragma solidity ^0.8.15;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';


contract PayRole{

address owner;
IERC20 BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
mapping(address => bool) allowed;
mapping(address => uint) allowance;
mapping(address => uint) moment;
mapping(address => uint) rest;

event devAdded(address);
event allowanceAdded(address, uint);
event allowanceChanged(address, uint);
event deposited(address, uint);
event claimed(address, uint);
event ownershipTransfered(address);
event ownerClaimned(uint);


constructor () public {
owner = msg.sender;
}

modifier onlyOwner() {
require(
    msg.sender == owner, "This function is restricted to the contract's owner");
_;
}

function transferOwnership(address _address) external onlyOwner {
    owner = _address;
}

function getStatus(address _address) view external onlyOwner returns(bool){
    return allowed[_address];
}

function addDev(address _address, uint _allowance) external onlyOwner {
    allowed[_address] = true;
    moment[_address] = block.timestamp;
    allowance[_address] = _allowance;
    emit devAdded(_address);
    emit allowanceAdded(_address, _allowance);
}

function setAllowance(address _address, uint _amount) external onlyOwner{
    allowance[_address] = _amount;
    emit allowanceChanged(_address, _amount);
}
/*
function deposit(uint256 _amount) external {
    require(_amount > 0, 'You need to send some tokens!');
    BUSD.transfer(address(this), _amount);
    emit deposited(msg.sender, _amount);
}
*/

function getReward() external view returns(uint){
    require(allowed[msg.sender] == true, 'This address is not allowed to check allowance');
    uint _moment = moment[msg.sender];
    uint _allowance = allowance[msg.sender];
    uint result = (((block.timestamp - _moment) / 1 hours) * _allowance) + rest[msg.sender];
    return result;
}

function claim() external {
    uint _moment = moment[msg.sender];
    uint _allowance = allowance[msg.sender];
    uint amount = (((block.timestamp - _moment) / 1 hours) * _allowance) + rest[msg.sender];
    require(allowed[msg.sender] == true, 'This address is not allowed to perform withdrawns');
    require(amount > 0 ,'No value to be claimned');
    if(BUSD.balanceOf(address(this)) < amount){
        uint _rest = amount - BUSD.balanceOf(address(this));
        BUSD.transfer(msg.sender, BUSD.balanceOf(address(this)));
        moment[msg.sender] = block.timestamp;
        rest[msg.sender] += _rest;
        emit claimed(msg.sender, amount);        
    }else{
        BUSD.transfer(msg.sender, amount);
        moment[msg.sender] = block.timestamp;
        emit claimed(msg.sender, amount);
        rest[msg.sender] = 0;
    }
}

function ownerClaim(uint _amount) external onlyOwner {
    BUSD.transfer(msg.sender, _amount);
    emit ownerClaimned(_amount);
}

function ownerCheckReward(address _address) view external returns(uint){
    uint _moment = moment[_address];
    uint _allowance = allowance[_address];
     uint result = (((block.timestamp - _moment) / 1 hours) * _allowance) + rest[_address];
    return result;
}

function getBalance() view external returns(uint){
    uint balance = BUSD.balanceOf(address(this));
    return balance;
}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}