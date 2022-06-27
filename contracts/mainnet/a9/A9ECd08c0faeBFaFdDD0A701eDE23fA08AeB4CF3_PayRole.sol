pragma solidity ^0.8.7;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';


contract PayRole{

address owner;
uint i;
IERC20 BUSD = IERC20(0x4Fabb145d64652a948d72533023f6E7A623C7C53);
mapping(address => bool) allowed;
mapping(address => uint) allowance;
mapping(address => uint) moment;

event devAdded(address);
event allowanceAdded(address, uint);
event allowanceRemoved(address, uint);
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

function addDev(address _address, uint _allowance) external onlyOwner {
    allowed[_address] = true;
    moment[_address] = block.timestamp;
    allowance[_address] = _allowance;
    emit devAdded(_address);
    emit allowanceAdded(_address, _allowance);
}

function addAllowance(address _address, uint _amount) external onlyOwner {
    allowance[_address] += _amount;
    emit allowanceAdded(_address, _amount);
}

function removeAllowance(address _address, uint _amount) external onlyOwner {
    allowance[_address] -= _amount;
    emit allowanceRemoved(_address, _amount);
}

function setAllowance(address _address, uint _amount) external onlyOwner{
    allowance[_address] = _amount;
    emit allowanceChanged(_address, _amount);
}

function deposit(uint256 _amount) external {
    require(_amount > 0, 'You need to send some tokens!');
    BUSD.transferFrom(msg.sender, address(this), _amount);
    emit deposited(msg.sender, _amount);
}

function getReward() public returns(uint){
    require(allowed[msg.sender] = true, 'This address is not allowed to check allowance');
    return block.timestamp - moment[msg.sender] * allowance[msg.sender];
}

function claim() external {
    require(allowed[msg.sender] = true, 'This address is not allowed to perform withdrawns');
    require(BUSD.balanceOf(address(this)) > block.timestamp - moment[msg.sender] * allowance[msg.sender], 'Not enough balance');
    uint amount = moment[msg.sender] * allowance[msg.sender];
    BUSD.transferFrom(address(this), msg.sender, amount);
    allowance[msg.sender] = 0;
    emit claimed(msg.sender, amount);
}

function ownerClaim(uint _amount) external onlyOwner {
    BUSD.transferFrom(address(this), msg.sender, _amount);
    emit ownerClaimned(_amount);
}

function ownerCheckReward(address _address) external onlyOwner returns(uint){
    return block.timestamp - moment[_address] * allowance[_address];
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