/**
 *Submitted for verification at BscScan.com on 2022-04-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * -------
 * Context
 * -------
 */
abstract contract Context {

    // Get msg.sender
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    // Get msg.data
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * ------
 * IBEP20
 * ------
 */
interface IBEP20 {
    
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * -------
 * Ownable
 * -------
 */
contract Ownable is Context {

    address public _owner;

    // On deploy, transfers ownership to msg.sender
    constructor() {
        _transferOwnership(_msgSender());
    }

    // Get owner
    function owner() public view virtual returns (address) {
        return _owner;
    }

    // Only owner modifier
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    // renounce ownership
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    // Transfer ownership to new owner
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    // Transfer ownership to new owner (internal)
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    // Ownership transferred event
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}

/**
 * ----------------
 * Reentrancy Guard
 * ----------------
 */
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor () {_status = _NOT_ENTERED;}

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

    modifier isHuman() {
        require(tx.origin == msg.sender, "sorry humans only");
        _;
    }
}

/**
 * ------------------
 * Regy swap contract
 * ------------------
 */
contract RegySwap is Ownable, ReentrancyGuard {
    
    // Address who can withdraw values from contract
    address payable private withdrawOwner;

    // Balance
    uint256 public balance;

    // RegyToken
    IBEP20 private regyToken;

    // Virtual tokens
    mapping(string => uint256) private tokensFactor;

    constructor(address _regyToken) {
        regyToken = IBEP20(_regyToken);
    }

    /**
     * -------
     * Receive
     * -------
     */
    receive() external payable {
        balance += msg.value;
    }

    /**
     * ---------------------
     * Transfer ERC20 tokens
     * ---------------------
     */
    function transferERC20(IBEP20 token, address to, uint256 amount) public onlyOwner nonReentrant {
        uint256 erc20balance = token.balanceOf(address(this));
        require(amount <= erc20balance, "balance is low");
        token.transfer(to, amount);
    }

    function withdrawERC20(uint amount, address payable to) public onlyOwner nonReentrant {
        require(amount <= balance, "Insufficient funds");
        balance -= amount;
        to.transfer(amount);
    }

    /**
     * ---------------------
     * Set RegyToken address
     * ---------------------
     */
    function setRegyTokenAddress(
        address _newAddress
    ) public onlyOwner returns (address) {
        regyToken = IBEP20(_newAddress);
        return _newAddress;
    }

    /**
     * ---------------------
     * Get RegyToken address
     * ---------------------
     */
    function getRegyTokenAddress() public view returns (address) {
        return address(regyToken);
    }

    /**
     * ------------------
     * Withdraw RegyCoins
     * ------------------
     */
    function withdraw
    (
        address wallet, 
        uint256 amount
    ) public onlyOwner returns (uint256) {
        require(amount > 0, "Invalid amount");
        regyToken.transfer(wallet, amount);
        return amount;
    }

    /**
     * ------------------
     * Return BNB balance
     * ------------------
     */
    function totalBalance() external view returns(uint256) {
        return payable(address(this)).balance;
    }

    /**
     * ------------
     * Withdraw BNB
     * ------------
     */
    function withdrawBNB() public onlyOwner(){
        require(withdrawOwner != address(0), "To make the withdrawal, you need to register a valid address.");
        require(this.totalBalance() > 0, "You do not have enough balance for this withdrawal");
        withdrawOwner.transfer(this.totalBalance());
    }
  
    /**
     * ---------------
     * Withdraw tokens
     * ---------------
     */
    function withdrawToken(address _contractAdd) public onlyOwner(){
        require(withdrawOwner != address(0), "To make the withdrawal, you need to register a valid address.");
        IBEP20 ContractAdd = IBEP20(_contractAdd);
        uint256 dexBalance = ContractAdd.balanceOf(address(this));
        require(dexBalance > 0, "You do not have enough balance for this withdrawal");
        ContractAdd.transfer(withdrawOwner, dexBalance);
    }
}