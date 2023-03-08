/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
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
}

// File: test 1.sol


pragma solidity ^0.8.18;


// Context contract
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// IBEP20 interface
interface IBEP20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// IBEP20 Metadata
interface IBEP20Metadata is IBEP20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

// BEP20
contract BEP20 is Context, IBEP20, IBEP20Metadata {
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

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
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

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
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

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

contract Stepain is BEP20,ReentrancyGuard {

    uint256 private initialSupply;
    uint256 private _maxTransferAmount;
    address private _owner;

    address private constant MARKETING_FEE_ADDRESS = 0x6eF969580Bb4eA293878a713197B895BfDD82bbe;
    address private constant CHARITY_FEE_ADDRESS = 0xc2ACF98406BE652AfB7b1274ab1eFCb3fd15f115;
    address private constant LIQUIDITY_FEE_ADDRESS = 0x9d48e287D30e509dbd1347C1e0a21e793Fa3c638;
    address private constant TAX_FEE_ADDRESS = 0xfa1281d974fE922437F03817947246070eE898B1;
    address private constant UNSTAKE_FEE_ADDRESS = 0xFb72e8d18a46144ae2D59fb1134F0128D99F153F;

    uint256 private _marketingFee;
    uint256 private _charityFee;
    uint256 private _liquidityFee;
    uint256 private _taxFee;
    uint256 private _unstakeFee;
    uint256  private constant CLAIM_PERIOD = 15 days;

    // Anti-bot checker
    uint256 private constant MIN_TIME_DELAY = 120;

    // Auto-burn
    uint256 private constant MAX_BURN_PERCENTAGE = 25;
    uint256 private constant AUTOBURN_INTERVAL = 4 * 30 days; // 4 months
    uint256 private lastAutoburnTimestamp;

    mapping(address=>uint256) public stakingBalance;
    mapping(address=>uint256) public depositBalance;
    mapping(address => uint256) lastTransactionTimestamp;
    mapping(address => uint256) public lastClaimedTime;

    event Stake(address indexed user, uint256 amount);
    event Unstake(address indexed user, uint256 amount);
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event PayMarketingFee(address indexed user, uint256 amount);
    event PayCharityFee(address indexed user, uint256 amount);
    event PayLiquidityFee(address indexed user, uint256 amount);
    event PayTaxFee(address indexed user, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only the contract owner can perform this action.");
        _;
    }

    constructor() BEP20("STEPAIN", "MRC") {
        initialSupply = 400000000 * (10 ** decimals());
        _maxTransferAmount = 4000000 * (10 ** decimals());

        _marketingFee = 1;
        _charityFee = 1;
        _liquidityFee = 1;
        _taxFee = 1;
        _unstakeFee = 15;

        _owner = msg.sender;
        _mint(msg.sender, initialSupply);
    }
    
    function getTaxFee() public view returns (uint256) {
        return _taxFee;
    }

    function getCharityFee() public view returns (uint256) {
        return _charityFee;
    }

    function getLiquidityFee() public view returns (uint256) {
        return _liquidityFee;
    }

    function getMarketingFee() public view returns (uint256) {
        return _marketingFee;
    }

    // Transfer
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        require(block.timestamp - lastTransactionTimestamp[msg.sender] >= MIN_TIME_DELAY, "You must wait before making another transaction");
        require(to != msg.sender, "Self transfer is not supported");
        require(balanceOf(msg.sender) >= amount, "Transfer amount exceeds balance");
        // Anti-whale
        require(_maxTransferAmount >= amount,"Amount exceeds maximum transfer limit");

        uint256 _finalTransferAmount = _payFees(msg.sender,amount);
        _transfer(msg.sender, to, _finalTransferAmount);

        lastTransactionTimestamp[msg.sender] = block.timestamp;
        return true;
    }

    // Transfer fees
    function _payFees(address _user,uint256 _amount) internal returns(uint256) {
        // Marketing fee
        uint256 marketingfee = (_amount * getMarketingFee()) / 100;
        _transfer(_user,MARKETING_FEE_ADDRESS,marketingfee);
        emit PayMarketingFee(_user,marketingfee);

        // Charity fee
        uint256 charityfee = (_amount * getCharityFee()) / 100;
        _transfer(_user,CHARITY_FEE_ADDRESS,charityfee);
        emit PayCharityFee(_user,charityfee);

        // Liquidity fee
        uint256 liquidityfee = (_amount * getLiquidityFee()) / 100;
        _transfer(_user,LIQUIDITY_FEE_ADDRESS,liquidityfee);
        emit PayLiquidityFee(_user,liquidityfee);

        // Tax Fee
        uint256 taxfee = (_amount * getTaxFee()) / 100;
        _transfer(_user,TAX_FEE_ADDRESS,taxfee);
        emit PayTaxFee(_user,taxfee);

        uint256 finalTransferAmount = _amount - (marketingfee + charityfee + liquidityfee + taxfee);
        return finalTransferAmount;
    }

    // Claim
    function claim() external nonReentrant{
        require(block.timestamp >= lastClaimedTime[msg.sender] + CLAIM_PERIOD, "Cannot claim yet");
        require(stakingBalance[msg.sender] > 0, "No staked balance");

        uint256 reward = (stakingBalance[msg.sender] * 3) / 100;
        uint256 _finalClaimAmount = _payFees(msg.sender, reward);
        _mint(msg.sender, _finalClaimAmount);

        lastClaimedTime[msg.sender] = block.timestamp;
    }
    
    // Stake
    function stakeTokens(uint256 amount) external {
        require(block.timestamp - lastTransactionTimestamp[msg.sender] >= MIN_TIME_DELAY, "You must wait before making another transaction");
        require(balanceOf(msg.sender) >= amount, "Staking amount is more than balance");
        require(amount > 0, "Staking amount must be more than 0");

        _burn(msg.sender, amount);
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + amount;
        emit Stake(msg.sender,amount);

        lastTransactionTimestamp[msg.sender] = block.timestamp;
    }

    // Unstake
    function unstakeTokens(uint256 amount) external nonReentrant{
        require(block.timestamp - lastTransactionTimestamp[msg.sender] >= MIN_TIME_DELAY, "You must wait before making another transaction");
        require(stakingBalance[msg.sender] > 0,"Your staking balance is 0");
        require(stakingBalance[msg.sender] >= amount,"Staking balance must be more than unstaking amount");
        require(amount > 0,"Unstaking amount must be greater than 0 tokens");

        uint256 unstakeFee = (amount * _unstakeFee) / 100;
        _mint(UNSTAKE_FEE_ADDRESS, unstakeFee);
        uint256 _unstakeAmount = amount - unstakeFee;
        _mint(msg.sender, _unstakeAmount);
        stakingBalance[msg.sender] = stakingBalance[msg.sender] - amount;
        emit Unstake(msg.sender, amount);

        lastTransactionTimestamp[msg.sender] = block.timestamp;
    }

    // Deposit
    function deposit() external payable {
        require(block.timestamp - lastTransactionTimestamp[msg.sender] >= MIN_TIME_DELAY, "You must wait before making another transaction");
        //require(msg.value >= 0.005 ether, "You must deposit a minimum of 0.005 ETH"); // consider a minimum amount to deposit
        require(msg.value > 0, "Deposit amount must be greater than 0");

        lastTransactionTimestamp[msg.sender] = block.timestamp;

        depositBalance[msg.sender] = depositBalance[msg.sender] + msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // Withdraw
    function withdraw(uint256 amount) external nonReentrant {
        require(block.timestamp - lastTransactionTimestamp[msg.sender] >= MIN_TIME_DELAY, "You must wait before making another transaction");
        require(depositBalance[msg.sender] >= amount, "Insufficient balance");

        lastTransactionTimestamp[msg.sender] = block.timestamp;
        depositBalance[msg.sender] -= amount;
        emit Withdraw(msg.sender, amount);
        
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Withdrawal failed");
    }

    // Autoburn
    function autoburn() external onlyOwner {
        require(block.timestamp >= lastAutoburnTimestamp + AUTOBURN_INTERVAL, "Autoburn interval not yet reached");
        
        uint256 burnAmount = (totalSupply() * 5) / 1000; // 0.5% of total supply
        
        if (burnAmount > (totalSupply() * MAX_BURN_PERCENTAGE) / 100) {
            burnAmount = (totalSupply() * MAX_BURN_PERCENTAGE) / 100; // limit to maximum autoburn percentage
        }
        
        _burn(msg.sender, burnAmount);
        
        lastAutoburnTimestamp = block.timestamp;
    }

}