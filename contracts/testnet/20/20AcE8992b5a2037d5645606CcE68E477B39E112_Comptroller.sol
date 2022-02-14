/**
 *Submitted for verification at BscScan.com on 2022-02-14
*/

// File: contracts/utils/Access.sol

pragma solidity ^0.8.0;

contract Access {
    bool private _contractCallable = false;
    bool private _pause = false;
    address private _owner;
    address private _pendingOwner;

    event NewOwner(address indexed owner);
    event NewPendingOwner(address indexed pendingOwner);
    event SetContractCallable(bool indexed able,address indexed owner);

    constructor(){
        _owner = msg.sender;
    }

    // ownership
    modifier onlyOwner() {
        require(owner() == msg.sender, "Access: caller is not the owner");
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }
    function setPendingOwner(address account) public onlyOwner {
        require(account != address(0),"Access: zero address");
        require(_pendingOwner == address(0), "Access: pendingOwner already exist");
        _pendingOwner = account;
        emit NewPendingOwner(_pendingOwner);
    }
    function becomeOwner() external {
        require(msg.sender == _pendingOwner,"Access: not pending owner");
        _owner = _pendingOwner;
        _pendingOwner = address(0);
        emit NewOwner(_owner);
    }

    // pause
    modifier checkPaused() {
        require(!paused(), "Access: paused");
        _;
    }
    function paused() public view virtual returns (bool) {
        return _pause;
    }
    function setPaused(bool p) external onlyOwner{
        _pause = p;
    }


    // contract call
    modifier checkContractCall() {
        require(contractCallable() || msg.sender == tx.origin, "Access: non contract");
        _;
    }
    function contractCallable() public view virtual returns (bool) {
        return _contractCallable;
    }
    function setContractCallable(bool able) external onlyOwner {
        _contractCallable = able;
        emit SetContractCallable(able,_owner);
    }

}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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

// File: contracts/Comptroller.sol

pragma solidity ^0.8.0;



interface IStake {
    function dividend(uint amount) external;
}

contract Comptroller is Access {

    IERC20 public Token;
    IStake public Stake;
    struct Account {
        address inviter;
        address[] invitees;
        uint bonus;
    }
    mapping(address=>Account) public accounts;
    address public fundA = address(0xA);
    address public fundB = address(0xB);
    address public fundC = address(0xC);

    event Bind(address indexed inviter, address indexed invitee);
    event Bonus(address indexed inviter, address indexed invitee, uint bonus);

    constructor(address token, address stake, address root){
        accounts[root].inviter = root;
        accounts[address(1)].inviter = root;
        accounts[fundA].inviter = root;
        accounts[fundB].inviter = root;
        accounts[fundC].inviter = root;
        accounts[address(this)].inviter = root;
        accounts[stake].inviter = root;


        Token = IERC20(token);
        Stake = IStake(stake);
        setPendingOwner(0x449F8492FA10bcB4d1017FD306da649EB81D1c99);
    }

    function bind(address inviter) external checkContractCall checkPaused {

        require(inviter != address(0), "not zero account");
        require(inviter != msg.sender, "can not be yourself");
        require(accounts[msg.sender].inviter == address(0), "already bind");
        accounts[msg.sender].inviter = inviter;
        accounts[inviter].invitees.push(msg.sender);
        emit Bind(inviter, msg.sender);
    }

    function dividend(address account) external {
        uint bal = Token.balanceOf(address(this));
        require(bal > 0,"Comptroller: balance not enough");

        if (account == address(0)) {
            Token.transfer(fundA, bal / 3);
            Token.transfer(address(1), bal * 2 / 3);
        }else{
            Token.transfer(fundB, bal / 11);
            Token.transfer(address(1), bal / 11);
            Token.transfer(fundC, bal * 3 / 11);

            address inviter = accounts[account].inviter;
            uint bs = bal * 15 / 110;
            emit Bonus(inviter, account, bs);
            Token.transfer(inviter, bs);
            accounts[inviter].bonus += bs;

            bs = bal / 11;
            emit Bonus(accounts[inviter].inviter, inviter, bs);
            inviter = accounts[inviter].inviter;
            Token.transfer(inviter, bs);
            accounts[inviter].bonus += bs;

            bs = bal * 8 / 110;
            emit Bonus(accounts[inviter].inviter, inviter, bs);
            inviter = accounts[inviter].inviter;
            Token.transfer(inviter, bs);
            accounts[inviter].bonus += bs;

            bs = bal * 5  / 110;
            emit Bonus(accounts[inviter].inviter, inviter, bs);
            inviter = accounts[inviter].inviter;
            Token.transfer(inviter, bs);
            accounts[inviter].bonus += bs;

            bs = bal * 2 / 110;
            emit Bonus(accounts[inviter].inviter, inviter, bs);
            inviter = accounts[inviter].inviter;
            Token.transfer(inviter, bs);
            accounts[inviter].bonus += bs;

            bs = bal * 2 / 11;
            Token.transfer(address(Stake), bs);
            Stake.dividend(bs);
        }
    }


    function getInvitation(address account) external view returns (address inviter, address[] memory invitees) {
        Account memory info = accounts[account];
        return (info.inviter, info.invitees);
    }

    function getInviter(address account) view external returns(address){
        return accounts[account].inviter;
    }

    function recipientAble(address account) external view returns(bool) {
        return (accounts[account].inviter != address(0));
    }

    function setFundA(address a) external onlyOwner{
        require(accounts[a].inviter != address(0));
        fundA = a;
    }
    function setFundB(address b) external onlyOwner{
        require(accounts[b].inviter != address(0));
        fundB = b;
    }
    function setFundC(address c) external onlyOwner{
        require(accounts[c].inviter != address(0));
        fundC = c;
    }

}