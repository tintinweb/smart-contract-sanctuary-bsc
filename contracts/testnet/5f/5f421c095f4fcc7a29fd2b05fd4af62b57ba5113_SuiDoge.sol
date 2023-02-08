/**
 *Submitted for verification at BscScan.com on 2023-02-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


abstract contract ReentrancyGuard {

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
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata, ReentrancyGuard {

    uint public CAP = 990 * 1000 * 1000 * 1000 * ( 10 ** decimals()); // 990 BI

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

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);

        require(_totalSupply <= CAP, "SuiDoge: Maximum minted excedeed." );
    }


    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }


    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {
        
    }
}

contract SuiDoge is ERC20("SuiDogeCoin","SUIDG") {

    uint public RATE = 30 * 1000 * 1000; 

    uint public TIME_LAPSE = 14400; 

    address public owner;

    bool public PURCHASE_LOCKED;

    uint public AIRDROP_AMOUNT = 4 * 1000 * 1000 * (10 ** decimals()); 

    mapping( address => uint ) public lockedUntil;

    uint public raised;

    uint public users;

    event Gain(address holder, uint amount, uint time);

    constructor(){
        owner = msg.sender;
    }

    // Each SuiDoge on the BSC Blockchain is equivalent to one SuiDoge on the Sui Blockchain.

    function airdrop(uint _amount) public payable nonReentrant() {

        require(!PURCHASE_LOCKED, "SuiDoge: Purchase is locked." );

        require(lockedUntil[msg.sender] < block.timestamp, "SuiDoge: Still locked to you." );

        if(lockedUntil[msg.sender] == 0){
            users = users + 1;
        }

        if(_amount <= AIRDROP_AMOUNT){
            
            _mint(msg.sender, _amount);

            emit Gain(msg.sender, _amount, block.timestamp);

        } else {

            uint purchased = _amount - AIRDROP_AMOUNT;  // Airdrop amount is decreased because is free.

            uint payment = purchased / RATE;

            require(msg.value >= payment, "SuiDoge: Insufficient payment.");

            raised = raised + payment;

            _mint(msg.sender, _amount);

            emit Gain(msg.sender, _amount, block.timestamp);

        }

        lockedUntil[msg.sender] = block.timestamp + TIME_LAPSE;

    }

    function price(uint _amount) public view returns(uint){

            if(_amount <= AIRDROP_AMOUNT){

                return 0;

            } else {

                uint purchased = _amount - AIRDROP_AMOUNT; 

                return purchased / RATE;

            }
    }


    modifier onlyOwner() {
        require(msg.sender == owner, "SuiDoge: Not allowed." );
        _;
    }

    function updateOwner(address _owner) public onlyOwner() {
        owner = _owner;
    }

    function updateTimeLapse(uint _timeLapse) public onlyOwner(){
        TIME_LAPSE = _timeLapse;
    }

    function updateRate(uint _rate) public onlyOwner(){
        RATE = _rate;
    }

    function updatePurchaseLock(bool _locked) public onlyOwner(){
        PURCHASE_LOCKED = _locked;
    }

    function redeemLiquidityToSuiPair(address _destinatary, uint _value) public payable onlyOwner() {
        (bool sent,) = _destinatary.call{value: _value != 0 ? _value : address(this).balance }("");
        require(sent, "SuiDoge: Failed to send BNB." );
    }

}