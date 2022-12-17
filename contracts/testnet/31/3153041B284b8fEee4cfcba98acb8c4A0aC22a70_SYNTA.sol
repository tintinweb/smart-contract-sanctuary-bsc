pragma solidity 0.8.17;

// ----------------------------------------------------------------------------
// SYNTA token main contract (2022)
//
// Symbol       : SYNTA
// Name         : SYNTA
// Total supply : 300.000.000 (burnable)
// Decimals     : 18
// ----------------------------------------------------------------------------
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function getOwner() external view returns (address);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Ownable {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed from, address indexed to);

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), owner);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Ownable: Caller is not the owner");
        _;
    }

    function transferOwnership(address transferOwner) external onlyOwner {
        require(transferOwner != newOwner);
        newOwner = transferOwner;
    }

    function acceptOwnership() virtual public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenPaused() {
        require(paused);
        _;
    }

    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Pause();
    }

    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }
}

contract SYNTA is IERC20, Ownable, Pausable {
    mapping (address => mapping (address => uint)) private _allowances;
    
    mapping (address => uint) private _unfrozenBalances;

    mapping (address => uint) private _vestingNonces;
    mapping (address => mapping (uint => uint)) private _vestingAmounts;
    mapping (address => mapping (uint => uint)) private _unvestedAmounts;
    mapping (address => mapping (uint => uint)) private _vestingTypes; //0 - multivest, 1 - single vest, > 2 give by vester id
    mapping (address => mapping (uint => uint)) private _vestingReleaseStartDates;
    mapping (address => mapping (uint => uint)) private _vestingSecondPeriods;

    uint private _totalSupply = 300_000_000e18;
    string private constant _name = "SYNTA";
    string private constant _symbol = "SYNTA";
    uint8 private constant _decimals = 18;
    uint public  issuedSupply = 100_000_000e18;

    uint public constant vestingSaleSecondPeriod = 6 minutes;

    uint public giveAmount;
    mapping (address => bool) public vesters;

    bytes32 public immutable DOMAIN_SEPARATOR;
    bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    mapping (address => uint) public nonces;

    event Unvest(address indexed user, uint amount);

    constructor () {
        _unfrozenBalances[owner] = issuedSupply;

        emit Transfer(address(0), owner, _unfrozenBalances[owner]);

        uint chainId = block.chainid;

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,uint256 chainId,address verifyingContract)'),
                keccak256(bytes(_name)),
                chainId,
                address(this)
            )
        );
        giveAmount = _totalSupply / 10;
    }

    receive() payable external {
        revert();
    }

    function getOwner() public override view returns (address) {
        return owner;
    }

    /**
     * @dev Sets amount as the allowance of spender over the caller's tokens.
     * Returns a boolean value indicating whether the operation succeeded.
     * @param spender address of token spender
     * @param amount the number of tokens that are allowed to spend
     * Emits an {Approval} event
     */
    function approve(address spender, uint amount) external override whenNotPaused returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev Moves amount tokens from the caller's account to recipient.
     * Returns a boolean value indicating whether the operation succeeded.
     * Emits a {Transfer} event.
     * @param recipient address of user
     * @param amount amount of token that you want to send
     */
    function transfer(address recipient, uint amount) external override whenNotPaused returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev Moves amount tokens from src to dst using the
     * allowance mechanism
     * amount is then deducted from the caller's allowance.
     * Returns a boolean value indicating whether the operation succeeded.
     * Emits a {Transfer} event.
     * @param sender address from
     * @param recipient address of user
     * @param amount amount of token that you want to send
     */
    function transferFrom(address sender, address recipient, uint amount) external override whenNotPaused returns (bool) {
        _transfer(sender, recipient, amount);
        
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "SYNTA::transferFrom: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance - amount);

        return true;
    }
    /**
     * @dev Issue tokens to receiver address
     * @param receiver address receiver
     * @param amount issue amount
     */
    function issue(address receiver, uint amount) public onlyOwner {
        require(issuedSupply + amount <= _totalSupply, "SYNTA::issue: issuedSupply cant be more than totalSupply");
        require(_unfrozenBalances[receiver] + amount > _unfrozenBalances[receiver], "SYNTA::issue: exceeds available amount");

        _unfrozenBalances[receiver] += amount;
        issuedSupply += amount;
        emit Transfer(address(0), receiver, amount);
    }

    /**
     * @notice This method can be used to change an account's ERC20 allowance by
     * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
     * need to send a transaction, and thus is not required to hold Ether at all. 
     * @dev Sets value as the allowance of spender over owner's tokens,
     * given owner's signed approval
     * @param owner address of token owner
     * @param spender address of token spender
     * @param amount the number of tokens that are allowed to spend
     * @param deadline the expiration date of the permit
     * @param v the recovery id
     * @param r outputs of an ECDSA signature
     * @param s outputs of an ECDSA signature
     */
    function permit(address owner, address spender, uint amount, uint deadline, uint8 v, bytes32 r, bytes32 s) external whenNotPaused {
        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, amount, nonces[owner]++, deadline));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "SYNTA::permit: invalid signature");
        require(signatory == owner, "SYNTA::permit: unauthorized");
        require(block.timestamp <= deadline, "SYNTA::permit: signature expired");

        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Atomically increases the allowance granted to spender by the caller.
     * @param spender address of user
     * @param addedValue value of tokens 
     * Emits an {Approval} event indicating the updated allowance.
     */
    function increaseAllowance(address spender, uint addedValue) external returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to spender by the caller.
     * @param spender address of user
     * @param subtractedValue value of tokens 
     * Emits an {Approval} event indicating the updated allowance.
     */
    function decreaseAllowance(address spender, uint subtractedValue) external returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "SYNTA::decreaseAllowance: decreased allowance below zero");
        _approve(msg.sender, spender, currentAllowance - subtractedValue);

        return true;
    }
    
    /**
     * @dev This method is used to withdraw tokens from vesting
     * Emits a {Unvest} event.
     */
    function unvest() external whenNotPaused returns (uint unvested) {
        require (_vestingNonces[msg.sender] > 0, "SYNTA::unvest:No vested amount");
        for (uint i = 1; i <= _vestingNonces[msg.sender]; i++) {
            if (_vestingAmounts[msg.sender][i] == _unvestedAmounts[msg.sender][i]) continue;
            if (_vestingReleaseStartDates[msg.sender][i] > block.timestamp) break;
            uint toUnvest = (block.timestamp - _vestingReleaseStartDates[msg.sender][i]) * _vestingAmounts[msg.sender][i] / (_vestingSecondPeriods[msg.sender][i] - _vestingReleaseStartDates[msg.sender][i]);
            if (toUnvest > _vestingAmounts[msg.sender][i]) {
                toUnvest = _vestingAmounts[msg.sender][i];
            } 
            uint totalUnvestedForNonce = toUnvest;
            toUnvest -= _unvestedAmounts[msg.sender][i];
            unvested += toUnvest;
            _unvestedAmounts[msg.sender][i] = totalUnvestedForNonce;
        }
        _unfrozenBalances[msg.sender] += unvested;
        emit Unvest(msg.sender, unvested);
    }

    /**
     * @dev Sends tokens to vesting
     * @param user address of user
     * @param amount SYNTA amount 
     * @param vesterId vester Id
     */
    function give(address user, uint amount, uint vesterId) external {
        require (giveAmount > amount, "SYNTA::give: give finished");
        require (vesters[msg.sender], "SYNTA::give: not vester");
        giveAmount -= amount;
        _vest(user, amount, vesterId, block.timestamp + vestingSaleSecondPeriod, block.timestamp + vestingSaleSecondPeriod + 1);
    }

    /**
     * @dev Transfer frozen funds to user
     * @param user address of user
     * @param amount SYNTA amount 
     * Emits a {Transfer} event.
     */
    function vest(address user, uint amount) external {
        require (vesters[msg.sender], "SYNTA::vest: not vester");
        _vest(user, amount, 1, block.timestamp + vestingSaleSecondPeriod, block.timestamp + vestingSaleSecondPeriod + 1);
    }

    /**
     * @dev Transfer frozen funds to user
     * @param user address of user
     * @param amount SYNTA amount 
     * Emits a {Transfer} event.
     */
    function vestPurchase(address user, uint amount) external {
        require (vesters[msg.sender], "SYNTA::vestPurchase: not vester");
        _transfer(msg.sender, owner, amount);
        _vest(user, amount, 1, block.timestamp + vestingSaleSecondPeriod, block.timestamp + vestingSaleSecondPeriod + 1);
    }

    /**
     * @dev Destroys the number of tokens from the owner account, reducing the total supply.
     * can be called only from the owner account
     * @param amount the number of tokens that will be burned
     * Emits a {Transfer} event.
     */
    function burnTokens(uint amount) external onlyOwner returns (bool success) {
        require(amount <= _unfrozenBalances[owner], "SYNTA::burnTokens: exceeds available amount");

        uint256 ownerBalance = _unfrozenBalances[owner];
        require(ownerBalance >= amount, "SYNTA::burnTokens: burn amount exceeds owner balance");

        _unfrozenBalances[owner] = ownerBalance - amount;
        _totalSupply -= amount;
        emit Transfer(owner, address(0), amount);
        return true;
    }

    /**
     * @dev Returns the remaining number of tokens that spender will be
     * allowed to spend on behalf of owner through {transferFrom}. 
     * This is zero by default.
     * This value changes when {approve} or {transferFrom} are called
     * @param owner address of token owner
     * @param spender address of token spender
     */
    function allowance(address owner, address spender) external view override returns (uint) {
        return _allowances[owner][spender];
    }

    function decimals() external override pure returns (uint8) {
        return _decimals;
    }

    function name() external pure returns (string memory) {
        return _name;
    }

    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function totalSupply() external view override returns (uint) {
        return _totalSupply;
    }

    /**
     * @dev View method that returns the number of tokens owned by account
     * and vesting balance
     * @param account address of user
     */
    function balanceOf(address account) external view override returns (uint) {
        uint amount = _unfrozenBalances[account];
        if (_vestingNonces[account] == 0) return amount;
        for (uint i = 1; i <= _vestingNonces[account]; i++) {
            amount = amount + _vestingAmounts[account][i] - _unvestedAmounts[account][i];
        }
        return amount;
    }

    /**
     * @notice View method to get available for unvesting volume
     * @param user address of user
     */
    function availableForUnvesting(address user) external view returns (uint unvestAmount) {
        if (_vestingNonces[user] == 0) return 0;
        for (uint i = 1; i <= _vestingNonces[user]; i++) {
            if (_vestingAmounts[user][i] == _unvestedAmounts[user][i]) continue;
            if (_vestingReleaseStartDates[user][i] > block.timestamp) break;
            uint toUnvest = (block.timestamp - _vestingReleaseStartDates[user][i]) * _vestingAmounts[user][i] / (_vestingSecondPeriods[user][i] - _vestingReleaseStartDates[user][i]);
            if (toUnvest > _vestingAmounts[user][i]) {
                toUnvest = _vestingAmounts[user][i];
            } 
            toUnvest -= _unvestedAmounts[user][i];
            unvestAmount += toUnvest;
        }
    }

    /**
     * @notice View method to get available for transfer amount
     * @param account address of user
     */
    function availableForTransfer(address account) external view returns (uint) {
        return _unfrozenBalances[account];
    }

    /**
     * @notice View method to get vesting Information
     * @param user address of user
     * @param nonce nonce of current lock
     */
    function vestingInfo(address user, uint nonce) external view returns (uint vestingAmount, uint unvestedAmount, uint vestingReleaseStartDate, uint vestingSecondPeriod, uint vestType) {
        vestingAmount = _vestingAmounts[user][nonce];
        unvestedAmount = _unvestedAmounts[user][nonce];
        vestingReleaseStartDate = _vestingReleaseStartDates[user][nonce];
        vestingSecondPeriod = _vestingSecondPeriods[user][nonce];
        vestType = _vestingTypes[user][nonce];
    }

    /**
     * @notice View method to get last vesting nonce for user 
     * @param user address of user
     */
    function vestingNonces(address user) external view returns (uint lastNonce) {
        return _vestingNonces[user];
    }

    function _approve(address owner, address spender, uint amount) private {
        require(owner != address(0), "SYNTA::_approve: approve from the zero address");
        require(spender != address(0), "SYNTA::_approve: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint amount) private {
        require(sender != address(0), "SYNTA::_transfer: transfer from the zero address");
        require(recipient != address(0), "SYNTA::_transfer: transfer to the zero address");

        uint256 senderAvailableBalance = _unfrozenBalances[sender];
        require(senderAvailableBalance >= amount, "SYNTA::_transfer: amount exceeds available for transfer balance");
        _unfrozenBalances[sender] = senderAvailableBalance - amount;
        _unfrozenBalances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _vest(address user, uint amount, uint vestType, uint vestingReleaseStart, uint vestingReleaseSecondPeriod) private {
        require(user != address(0), "SYNTA::_vest: vest to the zero address");
        require(vestingReleaseStart >= 0, "SYNTA::_vest: vesting release start date should be more then 0");
        require(vestingReleaseSecondPeriod >= vestingReleaseStart, "SYNTA::_vest: vesting release end date should be more then start date");
        uint nonce = ++_vestingNonces[user];
        _vestingAmounts[user][nonce] = amount;
        _vestingReleaseStartDates[user][nonce] = vestingReleaseStart;
        _vestingSecondPeriods[user][nonce] = vestingReleaseSecondPeriod;
        _unfrozenBalances[owner] -= amount;
        _vestingTypes[user][nonce] = vestType;
        emit Transfer(owner, user, amount);
    }

    /**
     * @dev This method is used to add new vesters
     * can be called only from the owner account
     * @param vester new vester 
     * @param isActive boolean condition
     */
    function updateVesters(address vester, bool isActive) external onlyOwner { 
        vesters[vester] = isActive;
    }

    /**
     * @dev This method is update give amount
     * can be called only from the owner account
     * @param amount new amount 
     */
    function updateGiveAmount(uint amount) external onlyOwner { 
        require (_unfrozenBalances[owner] > amount, "SYNTA::updateGiveAmount: exceed owner balance");
        giveAmount = amount;
    }
    
    /**
     * @dev This method is used to withdraw any ERC20 tokens from the contract
     * can be called only from the owner account
     * @param tokenAddress token address
     * @param tokens token amount
     */
    function transferAnyERC20Token(address tokenAddress, uint tokens) external onlyOwner returns (bool success) {
        return IERC20(tokenAddress).transfer(owner, tokens);
    }

    function acceptOwnership() public override {
        uint amount = _unfrozenBalances[owner];
        _unfrozenBalances[newOwner] = amount;
        _unfrozenBalances[owner] = 0;
        emit Transfer(owner, newOwner, amount);
        super.acceptOwnership();
    }
}