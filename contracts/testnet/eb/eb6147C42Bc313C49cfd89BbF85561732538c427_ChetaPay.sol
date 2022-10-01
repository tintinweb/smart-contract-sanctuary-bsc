/*
    BSC Token developed by Kraitor <TG: kraitordev>
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../BasicLibraries/IBEP20.sol";
import "../BasicLibraries/SafeMath.sol";
import "../BasicLibraries/MultiSignAuth.sol";
import "../BasicLibraries/IDEXFactory.sol";
import "../BasicLibraries/IDEXRouter.sol";

contract ChetaPay is IBEP20, MultiSignAuth {
    using SafeMath for uint256;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    string constant _name = "ChetaPay";
    string constant _symbol = "CHTP";
    uint8 constant _decimals = 18;

    uint256 public _totalSupply = 10_000_000_000 * (10 ** _decimals);
    uint256 public _maxWalletSize = (_totalSupply * 35) / 1000;  //3.5% max wallet

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isWalletLimitExempt;

    //Open/close trade
    bool public isTradeOpened = false;

    //Total fee
    uint256 public buySellFee = 250;
    uint256 public feeDenominator = 10000;

    //Fees, all of them over buySellFee (250)
    uint256 public liquidityFee = 100;
    uint256 public marketingFee = 50;
    uint256 public rewardsFee = 50;
    uint256 public devFee = 50;

    //Fees receivers, can be set only one time
    address public liquidityFeeReceiver;
    address public marketingFeeReceiver;
    address public rewardsFeeReceiver;
    address public devFeeReceiver;

    //Wallet to manage project supply, unique wallet that allows burns
    address public supplyWallet;

    //Liq. pair and router
    IDEXRouter private router;
    address public pair;

    //Swapback settings
    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply / 1000 * 3; // 0.3%
    uint256 public pcThresholdMaxSell = 100; //Applied over swapThreshold

    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor (address _WBNB, address _PANCAKE_ROUTER) MultiSignAuth(msg.sender) {
        if(_PANCAKE_ROUTER != address(0)){ PANCAKE_ROUTER = _PANCAKE_ROUTER; }
        if(_WBNB != address(0)){ WBNB = _WBNB; }

        router = IDEXRouter(PANCAKE_ROUTER);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        address _owner = getOwners()[0];
        isWalletLimitExempt[pair] = true;
        isWalletLimitExempt[address(this)] = true;

        _balances[_owner] = _totalSupply;
        emit Transfer(address(0), _owner, _totalSupply);
    }

    error test(uint256);//Remove
    receive() external payable { }

    function getCirculatingSupply() public view returns (uint256) { return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO)); }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return getOwners()[0]; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }    

    function approve(address spender, uint256 amount) external override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        _allowances[msg.sender][spender] = type(uint256).max;
        emit Approval(msg.sender, spender, type(uint256).max);
        return true;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }
        
        if (recipient != pair && recipient != DEAD) {
            require(isWalletLimitExempt[recipient] || isOwner[recipient] || _balances[recipient] + amount <= _maxWalletSize, "Transfer amount exceeds the bag size.");
        }
        
        if(shouldSwapBack()){ swapBack(); }

        require(isTradeOpened || isOwner[sender], "Trade still not opened");

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        uint256 amountReceived = (shouldTakeFee(sender) && shouldTakeFee(recipient)) ? takeFee(sender, amount) : amount;        
        _balances[recipient] = _balances[recipient].add(amountReceived);

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function shouldTakeFee(address sender) internal view returns (bool) { return !isOwner[sender] && !isFeeExempt[sender]; }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {        
        uint256 feeAmount = amount.mul(buySellFee).div(feeDenominator);        
        _balances[address(this)] = _balances[address(this)].add(feeAmount);        
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function swapBack() internal swapping {
        uint256 contractTokenBalance = balanceOf(address(this));
        if(contractTokenBalance > swapThreshold.mul(pcThresholdMaxSell).div(100)){
            contractTokenBalance = swapThreshold.mul(pcThresholdMaxSell).div(100);
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        try router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            contractTokenBalance,
            0,
            path,
            address(this),
            block.timestamp
        ){}catch{}

        sendFees();
    }

    function sendFees() internal {
        uint256 amountBNB = address(this).balance;
        if(amountBNB > 0){
            uint256 amountBNBLiquidity = amountBNB.mul(liquidityFee).div(buySellFee);
            uint256 amountBNBDev = amountBNB.mul(devFee).div(buySellFee);
            uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(buySellFee);
            uint256 amountBNBRewards = amountBNB.mul(rewardsFee).div(buySellFee);

            if(marketingFeeReceiver != address(0)){
                payable(marketingFeeReceiver).transfer(amountBNBMarketing);
            }
            if(devFeeReceiver != address(0)){
                payable(devFeeReceiver).transfer(amountBNBDev);
            }
            if(rewardsFeeReceiver != address(0)){
                payable(rewardsFeeReceiver).transfer(amountBNBRewards);
            }
            if(liquidityFeeReceiver != address(0)){
                payable(liquidityFeeReceiver).transfer(amountBNBLiquidity);
            }
        }
    }

    /* 
     * Functions that only can be triggered by owners, after the necessary confirmations
     */
    function openTrade(bool _open) external multiSignReq { 
        if(multiSign()){ 
            isTradeOpened = _open; 
        }
    }

    function burn(uint256 amount) external override multiSignReq {
        require(_balances[supplyWallet] >= amount, 'Not enough tokens to burn');

        if(multiSign()){ 
            _transferFrom(supplyWallet, DEAD, amount);
        }
    }

    /* 
     * Functions that only can be triggered by owners
     */
    function setIsFeeExempt(address holder, bool exempt) external onlyOwners { 
        isFeeExempt[holder] = exempt; 
    }

    function setIsWalletLimitExempt(address holder, bool exempt) external onlyOwners {
        isWalletLimitExempt[holder] = exempt;
    }

    function setFeesReceivers(address _marketingFeeReceiver, address _devFeeReceiver, address _rewardsFeeReceiver, address _liqFeeReceiver) external onlyOwners {
        require(_marketingFeeReceiver != address(0) && _devFeeReceiver != address(0) && _rewardsFeeReceiver != address(0) && _liqFeeReceiver != address(0), "Zero address not allowed");
        require(marketingFeeReceiver == address(0) && devFeeReceiver == address(0) && rewardsFeeReceiver == address(0) && liquidityFeeReceiver == address(0), "Fees receivers only can be set one time");                    

        marketingFeeReceiver = _marketingFeeReceiver;        
        devFeeReceiver = _devFeeReceiver;
        rewardsFeeReceiver = _rewardsFeeReceiver;
        liquidityFeeReceiver = _liqFeeReceiver;

        isFeeExempt[marketingFeeReceiver] = true;               
        isFeeExempt[devFeeReceiver] = true;        
        isFeeExempt[rewardsFeeReceiver] = true;        
        isFeeExempt[liquidityFeeReceiver] = true;

        isWalletLimitExempt[marketingFeeReceiver] = true; 
        isWalletLimitExempt[devFeeReceiver] = true;   
        isWalletLimitExempt[rewardsFeeReceiver] = true;   
        isWalletLimitExempt[liquidityFeeReceiver] = true;   
    }

    function setSupplyWallet(address _supplyWallet) external onlyOwners { 
        require(_supplyWallet != address(0), "Zero address not allowed");
        require(supplyWallet == address(0), "Supply wallet only can be set one time");

        supplyWallet = _supplyWallet; 

        isFeeExempt[supplyWallet] = true;        
        isWalletLimitExempt[supplyWallet] = true;
    }

    function setSwapBackSettings(bool _enabled, uint256 _threshold, uint256 _pcThresholdMaxSell) external onlyOwners {
        require(pcThresholdMaxSell >= 100, "The _pcThresholdMaxSell has to be 100 or higher");

        swapEnabled = _enabled;
        swapThreshold = _threshold;
        pcThresholdMaxSell = _pcThresholdMaxSell;
    }

    function forceSwapBack() external onlyOwners { 
        swapBack(); 
    }

    function forceSendFees() external onlyOwners { 
        sendFees(); 
    }

    function transferForeignToken(address _token) public onlyOwners {
        require(_token != address(this), "Can't let you take native tokens");

        uint256 _contractBalance = IBEP20(_token).balanceOf(address(this));
        IBEP20(_token).transfer(msg.sender, _contractBalance);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

/*
    MultiSign token class, developed by Kraitor <TG: kraitordev>
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

abstract contract MultiSignAuth {
    /*
     *  Constants
     */
    uint constant public MAX_OWNER_COUNT = 50;

    /*
     *  Storage
     */    
    mapping (uint => Transaction) public transactions;
    mapping (uint => mapping (address => bool)) public confirmations;
    mapping (address => bool) internal isOwner;    
    mapping (bytes => uint) public transactionsIds;
    address[] internal owners;
    uint public required;
    uint public transactionCount;

    struct Transaction {
        address destination;
        uint value;
        bytes data;
        bool executed;
    }

    constructor(address _owner) {
        isOwner[_owner] = true;
        owners.push(_owner);
        required = 1;
    }

    /*
     *  Events
     */
    event Confirmation(address indexed sender, uint indexed transactionId);
    event Revocation(address indexed sender, uint indexed transactionId);
    event Submission(uint indexed transactionId);

    /*
     *  Modifiers
     */
    modifier ownerDoesNotExist(address owner) {
        require(!isOwner[owner]);
        _;
    }

    modifier ownerExists(address owner) {
        require(isOwner[owner]);
        _;
    }

    modifier transactionExists(uint transactionId) {
        require(transactions[transactionId].destination != address(0));
        _;
    }

    modifier confirmed(uint transactionId, address owner) {
        require(confirmations[transactionId][owner]);
        _;
    }

    modifier notConfirmed(uint transactionId, address owner) {
        require(!confirmations[transactionId][owner]);
        _;
    }

    modifier notExecuted(uint transactionId) {
        require(!transactions[transactionId].executed);
        _;
    }

    modifier notNull(address _address) {
        require(_address != address(0));
        _;
    }

    modifier validRequirement(uint ownerCount, uint _required) {
        require(ownerCount <= MAX_OWNER_COUNT
            && _required <= ownerCount
            && _required != 0
            && ownerCount != 0);
        _;
    }

    modifier onlyOwners() {
        require(isOwner[msg.sender], "!OWNER"); _;
    }

    bool multiSignAuthRan;
    modifier multiSignReq() { 
        require(isOwner[msg.sender], "!OWNER");
        multiSignAuthRan = false; 
        _;
        require(multiSignAuthRan, "This transaction requires multisign"); 
        multiSignAuthRan = false;
    }

    /*
     * Public functions
     */
    /// @dev Sets initial owners and required number of confirmations.
    /// @param _owners List of owners.
    /// @param _required Number of required confirmations.
    function MultiSignOwners(address[] memory _owners, uint _required)
        public
        multiSignReq
        validRequirement(_owners.length, _required)
    {        
        if(multiSign()){
            for (uint i=0; i<owners.length; i++) {
                isOwner[owners[i]] = false;
            }
            for (uint i=0; i<_owners.length; i++) {
                require(_owners[i] != address(0));
                isOwner[_owners[i]] = true;
            }
            owners = _owners;
            required = _required;
        }
    }

    /// @dev Allows an owner to revoke a confirmation for a transaction.
    /// @param transactionId Transaction ID.
    function revokeConfirmation(uint transactionId)
        public
        ownerExists(msg.sender)
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId)
    {
        confirmations[transactionId][msg.sender] = false;
        emit Revocation(msg.sender, transactionId);
    }

    /*
     * Internal functions
     */
    /// @dev Adds a new transaction to the transaction mapping, if transaction does not exist yet.
    /// @return Returns transaction ID.
    function addTransaction()
        internal
        returns (uint)
    {
        uint transactionId = transactionCount;
        if(!transactions[transactionsIds[msg.data]].executed && transactions[transactionsIds[msg.data]].destination != address(0))
        {
            transactionId = transactionsIds[msg.data];
        }
        else
        {
            transactions[transactionId] = Transaction({
                destination: address(this),
                value: msg.value,
                data: msg.data,
                executed: false
            });
            transactionsIds[msg.data] = transactionId;
            transactionCount += 1;            
            emit Submission(transactionId);
        }        
        return transactionId;
    }

    /// @dev Allows an owner to confirm a transaction.
    /// @param transactionId Transaction ID.
    function confirmTransaction(uint transactionId)
        internal
        ownerExists(msg.sender)
        transactionExists(transactionId)
        notConfirmed(transactionId, msg.sender)
    {
        confirmations[transactionId][msg.sender] = true;        
        emit Confirmation(msg.sender, transactionId);
    }

    /// @dev Allows an owner to submit and confirm a transaction.
    /// @return Returns transaction ID.
    function submitTransaction()
        internal
        returns (uint)
    {
        uint transactionId = addTransaction();        
        require(!transactions[transactionId].executed, "Transaction already executed");        
        confirmTransaction(transactionId);
        return transactionId;
    }

    /// @dev Allows an owner to submit and confirm a transaction.
    /// @return Returns the transaction status
    function multiSign()
        internal
        returns (bool)
    {
        multiSignAuthRan = true;
        uint _transactionId = submitTransaction();
        bool _execute = isConfirmed(_transactionId);
        transactions[_transactionId].executed = _execute;
        return _execute;
    }

    /*
     * Web3 call functions
     */
    /// @dev Returns number of confirmations of a transaction.
    /// @param transactionId Transaction ID.
    /// @return Number of confirmations.
    function getConfirmationCount(uint transactionId) 
        public view 
        returns (uint)
    {
        uint count;
        for (uint i=0; i<owners.length; i++)
            if (confirmations[transactionId][owners[i]])
                count += 1;
        return count;
    }

    /// @dev Returns total number of transactions after filers are applied.
    /// @param pending Include pending transactions.
    /// @param executed Include executed transactions.
    /// @return Total number of transactions after filters are applied.
    function getTransactionCount(bool pending, bool executed)
        public view
        returns (uint)
    {
        uint count;
        for (uint i=0; i<transactionCount; i++)
            if (   pending && !transactions[i].executed
                || executed && transactions[i].executed)
                count += 1;
        return count;
    }

    /// @dev Returns the confirmation status of a transaction.
    /// @param transactionId Transaction ID.
    /// @return Confirmation status.
    function isConfirmed(uint transactionId)
        public view
        returns (bool)
    {
        uint count = 0;
        for (uint i=0; i<owners.length; i++) {
            if (confirmations[transactionId][owners[i]])
                count += 1;
            if (count == required)
                return true;
        }
        return false;
    }

    /// @dev Returns list of owners.
    /// @return List of owner addresses.
    function getOwners()
        public view
        returns (address[] memory)
    {
        return owners;
    }

    /// @dev Returns array with owner addresses, which confirmed transaction.
    /// @param transactionId Transaction ID.
    /// @return Returns array of owner addresses.
    function getConfirmations(uint transactionId)
        public view
        returns (address[] memory)
    {
        address[] memory confirmationsTemp = new address[](owners.length);
        uint count = 0;
        uint i;
        for (i=0; i<owners.length; i++)
            if (confirmations[transactionId][owners[i]]) {
                confirmationsTemp[count] = owners[i];
                count += 1;
            }
        address[] memory _confirmations = new address[](count);
        for (i=0; i<count; i++)
            _confirmations[i] = confirmationsTemp[i];

        return _confirmations;
    }

    /// @dev Returns list of transaction IDs in defined range.
    /// @param from Index start position of transaction array.
    /// @param to Index end position of transaction array.
    /// @param pending Include pending transactions.
    /// @param executed Include executed transactions.
    /// @return Returns array of transaction IDs.
    function getTransactionIds(uint from, uint to, bool pending, bool executed)
        public view
        returns (uint[] memory)
    {
        uint[] memory transactionIdsTemp = new uint[](transactionCount);
        uint count = 0;
        uint i;
        for (i=0; i<transactionCount; i++)
            if (   pending && !transactions[i].executed
                || executed && transactions[i].executed)
            {
                transactionIdsTemp[count] = i;
                count += 1;
            }
        uint[] memory _transactionIds = new uint[](to - from);
        for (i=from; i<to; i++)
            _transactionIds[i - from] = transactionIdsTemp[i];

        return _transactionIds;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * BEP20 standard interface.
 */
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function burn(uint256 amount) external;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);    
}