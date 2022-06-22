/**
 *Submitted for verification at BscScan.com on 2022-06-22
*/

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: contracts/FrozenToken.sol



pragma solidity ^0.8.14;





contract FrozenToken is Context, IERC20, IERC20Metadata, Ownable {

    address public root;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    //uint256 _months = 30 days;
    uint256 _months = 5 minutes;

    uint256 _firstYear;
    uint256 _secondYear;
    uint256 _thirdYear;

    uint256 _firstYearPrivateRound;
    uint256 _secondYearPrivateRound;

    bool public _startPrivateRound = false;
    bool public _startSales = false;

    struct User{
        uint256 amount;
        uint256 timestamp;
    }

    struct UserPR{
        uint256 amount;
        uint256 timestamp;
        uint256 maxAmount;
    }

    mapping(address => User) public frozenAmount;
    mapping(address => UserPR) public frozenAmountPrivateRound;

    uint256 private _maxSupplyPrivateRound;
    uint256 _supplyPrivateRound;

    mapping(uint => uint256) roundPrice; //price

    uint256 private _maxMintPerUser;

    modifier onlyLegalCaller() {
        require(msg.sender == owner() || msg.sender == root, "caller is not Legal Caller");
        _;
    }

    modifier isStartSales() {
        require(_startSales || _startPrivateRound, "Sales is not activated");
        _;
    }

    event MintFrozenAmountMigration(address indexed user, uint256 value);
    event MintFrozenAmountPrivateRound(address indexed user, uint256 value);

    constructor(
        string memory name_,
        string memory symbol_,
        address owner
    ) {
        _name = name_;
        _symbol = symbol_;
        
        _firstYear = 100; // 1%
        _secondYear = 200; // 2%
        _thirdYear = 534; // 5,34%

        _firstYearPrivateRound = 400; //4%
        _secondYearPrivateRound = 434; //4.34%

        _totalSupply = 1E27;

        _maxSupplyPrivateRound = 105E24;
        _supplyPrivateRound = 0;

        roundPrice[0] = 50000000000000000;
        roundPrice[1] = 60000000000000000;
        roundPrice[2] = 70000000000000000;
        roundPrice[3] = 80000000000000000;

        _maxMintPerUser = 1E21;

        _transferOwnership(owner);
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

    function activePrivateRound() public onlyLegalCaller{
        _startPrivateRound = true;
    }

    function activeSales() public onlyLegalCaller{
        _startSales = true;
        _startPrivateRound = false;
    }

    function stopSales() public onlyLegalCaller{
        _startSales = false;
        _startPrivateRound = false;
    }

    function setRoot(address _root) public onlyLegalCaller {
        root = _root;
    }

    function mint(address user, uint256 amount) public onlyLegalCaller isStartSales {
        if(_supplyPrivateRound + amount > _maxSupplyPrivateRound){
            activeSales();
        }
        if(_startPrivateRound){
            require(_supplyPrivateRound + amount <= _maxSupplyPrivateRound, "The amount is greater than the allowed amount");
            require(amount <= _maxMintPerUser - frozenAmountPrivateRound[user].amount, "The amount is more than the allowed amount for the user");
            uint256 migrationTimestamp = block.timestamp;
            if(_supplyPrivateRound + amount <= 4E25){
                amount = 10 ** decimals() * amount / roundPrice[0];
            }else if(_supplyPrivateRound + amount <= 8E25){
                if(_supplyPrivateRound < 4E25){
                    amount = (10 ** decimals() * (4E25 - _supplyPrivateRound) / roundPrice[0]) + (10 ** decimals() * (amount - (4E25 - _supplyPrivateRound)) / roundPrice[1]);
                }else{
                    amount = 10 ** decimals() * amount / roundPrice[1];
                }
            }else if(_supplyPrivateRound + amount <= 1E26){
                if(_supplyPrivateRound < 8E25){
                    amount = (10 ** decimals() * (8E25 - _supplyPrivateRound) / roundPrice[1]) + (10 ** decimals() * (amount - (8E25 - _supplyPrivateRound)) / roundPrice[2]);
                }else{
                    amount = 10 ** decimals() * amount / roundPrice[2];
                }
            }else if(_supplyPrivateRound + amount <= 105E24){
                if(_supplyPrivateRound < 1E26){
                    amount = (10 ** decimals() * (1E26 - _supplyPrivateRound) / roundPrice[2]) + (10 ** decimals() * (amount - (1E26 - _supplyPrivateRound)) / roundPrice[3]);
                }else{
                    amount = 10 ** decimals() * amount / roundPrice[3];
                }
            }
            _mint(user, amount);
            _supplyPrivateRound += amount;
            frozenAmountPrivateRound[user] = UserPR(amount, migrationTimestamp, frozenAmountPrivateRound[user].amount + amount);
            emit MintFrozenAmountPrivateRound(user, amount);
        }else{
            _mint(user, amount);
        }
    }

    function migrationMint(address user, uint256 amount, bool add) public onlyLegalCaller {
        uint256 migrationTimestamp = block.timestamp;
        _mint(user, amount);
        if(add){
            frozenAmount[user] = User(frozenAmount[user].amount + amount, migrationTimestamp);
        }else{
            frozenAmount[user] = User(amount, migrationTimestamp);
        }
        emit MintFrozenAmountMigration(user, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        require(_totalSupply > 0, "The maximum number of minted tokens has been reached");
        require(_totalSupply >= amount, "The amount is greater than the maximum number of minted tokens");
        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply -= amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function getDate(address user) private view returns(uint256 months){
        months = 0;
        uint256 newTS = block.timestamp - frozenAmount[user].timestamp;
        uint i = 0;
        while(newTS >= _months){
            newTS -= _months;
            months++;
            i++;
        }
    }

    function getDatePrivateRound(address user) private view returns(uint256 months){
        months = 0;
        uint256 newTS = block.timestamp - frozenAmountPrivateRound[user].timestamp;
        uint i = 0;
        while(newTS >= _months){
            newTS -= _months;
            months++;
            i++;
        }
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

        uint256 fAmount = frozenAmount[from].amount + frozenAmountPrivateRound[from].amount;

        if(frozenAmount[from].timestamp != 0){
            uint256 monthsCount = getDate(from);
            if(monthsCount <= 36){
                if(monthsCount != 0){
                    uint256 nPercents = 0;
                    uint i = 1;
                    while(i <= monthsCount){
                        if(i <= 12){
                            nPercents += i * _firstYear;
                        }else if(i > 12 && i <= 24){
                            nPercents += i * _secondYear;
                        }else{
                            nPercents += i * _thirdYear;
                        }
                        i++;
                    }
                    if(fAmount >= fAmount * nPercents / 10000){
                        fAmount -= fAmount * nPercents / 10000;
                    }else{
                        fAmount = 0;
                    }
                }
            }else{
                frozenAmount[from] = User(0, 0);
            }
        }
        if(frozenAmountPrivateRound[from].timestamp != 0){
            uint256 monthsCountPrivateRound = getDatePrivateRound(from);
            if(monthsCountPrivateRound <= 24){
                if(monthsCountPrivateRound != 0){
                    uint256 nPercentsPrivateRound = 0;
                    uint i = 1;
                    while(i <= monthsCountPrivateRound){
                        if(i <= 12){
                            nPercentsPrivateRound += i * _firstYearPrivateRound;
                        }else{
                            nPercentsPrivateRound += i * _secondYearPrivateRound;
                        }
                        i++;
                    }
                    if(fAmount >= fAmount * nPercentsPrivateRound / 10000){
                        fAmount -= fAmount * nPercentsPrivateRound / 10000;
                    }else{
                        fAmount = 0;
                    }
                }
            }else{
                frozenAmountPrivateRound[from] = UserPR(0, 0, 0);
            }
        }

        require(balanceOf(from) - amount >= fAmount, "The amount exceeds the allowed amount for withdrawal");
        
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

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
// File: contracts/stackingPhenom.sol



pragma solidity ^0.8.14;


contract StackingPhenom{

    FrozenToken _depositToken;
    uint256 public _priceUSDT;
    address public _owner;
    address public _bonusContract;
    address public _marketingContract;

    //uint256 _months = 30 days;
    uint256 _months = 5 minutes;

    enum StackingType{
        USDT,
        TOKEN
    }

    struct Stacking{
        uint256 amount;
        StackingType stacking;
        uint8 StackingPeriod;
        uint256 stackingTimestamp;
        uint256 monthsRemains;
        bool frozen;
    }

    mapping(uint8 => uint8) public StackingPeriods;

    mapping(address => Stacking[]) public holders;

    modifier onlyOwner() {
        require(msg.sender == _owner, "caller is not Owner");
        _;
    }

    modifier onlyLegalCaller() {
        require(msg.sender == _bonusContract, "caller is not Legal Caller");
        _;
    }

    constructor(address owner, address bonusContract){
        _owner = owner;
        _bonusContract = bonusContract;
        StackingPeriods[6] = 5; //6 months - 5%
        StackingPeriods[9] = 7; //9 months - 7%
        StackingPeriods[12] = 9; //12 months - 9%
        StackingPeriods[24] = 12; //24 months - 12%
    }
    
    function setDepositToken(FrozenToken depositToken) public onlyOwner{
        _depositToken = depositToken;
    }

    function setMarketingContract(address marketingContract) public onlyOwner{
        _marketingContract = marketingContract;
    }

    function setPriceUSDT(uint256 priceUSDT) public onlyOwner{
        _priceUSDT = priceUSDT;
    }

    function transferTokenToStaking(uint256 amount, uint8 period) public {
        require(msg.sender != address(0), "User with zero address");
        require(amount > 0, "The amount cannot be zero");
        require(period == 6 || period == 9 || period == 12 || period == 24, "There is no such stacking period");
        _depositToken.transferFrom(msg.sender, address(this), amount);
        holders[msg.sender].push(Stacking(amount, StackingType.TOKEN, StackingPeriods[period], block.timestamp, period, false));
    }

    function transferFrozenToStaking(uint8 period) public {
        require(msg.sender != address(0), "User with zero address");
        require(period == 6 || period == 9 || period == 12 || period == 24, "There is no such stacking period");
        uint256 timestamp = block.timestamp;
        for(uint i = 0; i < holders[msg.sender].length; i++){
            if(holders[msg.sender][i].frozen){
                holders[msg.sender][i].StackingPeriod = StackingPeriods[period];
                holders[msg.sender][i].stackingTimestamp = timestamp;
                holders[msg.sender][i].monthsRemains = period;
                holders[msg.sender][i].frozen = false;
            }
        }
    }

    function delivery(
		address user,
		uint256 packetType,
		uint256 quantity,
		uint256 packageId,
		uint256 amount
	) external onlyLegalCaller {
        if(_depositToken._startPrivateRound()){
            _depositToken.mint(user, amount);
        }else if(_depositToken._startSales()){
            holders[user].push(Stacking(amount, StackingType.USDT, 0, 0, 0, true));
        }
	}

    function withdrawPercents(address user) public{
        require(user != address(0), "Withdraw user the zero address");
        uint256 amount = 0;
        uint256 amountUSDT = 0;
        uint256 bAmount = 0;
        uint256 bAmountUSDT = 0;
        uint256 timestamp = block.timestamp;
        for(uint i = 0; i < holders[user].length; i++){
            if(!holders[user][i].frozen){
                if(holders[user][i].stackingTimestamp != 0){
                    (uint256 months, uint256 remains) = getDate(user, i);
                    if(months > 0){
                        holders[user][i].stackingTimestamp = timestamp - remains;
                        if(holders[user][i].monthsRemains > months){
                            holders[user][i].monthsRemains -= months;
                            if(holders[user][i].stacking == StackingType.TOKEN){
                                amount += holders[user][i].amount * holders[user][i].StackingPeriod / 100 * months;
                            }else if(holders[user][i].stacking == StackingType.USDT){
                                amountUSDT += holders[user][i].amount * holders[user][i].StackingPeriod / 100 * months;
                            }
                        }else{
                            if(holders[user][i].stacking == StackingType.TOKEN){
                                amount += holders[user][i].amount * holders[user][i].StackingPeriod / 100 * holders[user][i].monthsRemains;
                                bAmount += holders[user][i].amount;
                            }else if(holders[user][i].stacking == StackingType.USDT){
                                amountUSDT += holders[user][i].amount * holders[user][i].StackingPeriod / 100 * holders[user][i].monthsRemains;
                                bAmountUSDT += holders[user][i].amount;
                            }
                            holders[user][i] = holders[user][holders[user].length - 1];
                            holders[user].pop();
                        }
                    }
                }
            }
        }

        uint256 allStackingAmount = 0;
        uint256 nAmount = 0;
        
        if(amount > 0){
            _depositToken.mint(user, amount * 75 / 100);
            _depositToken.mint(_marketingContract, amount * 25 / 100);
            for(uint256 i = 0; i < holders[user].length; i++){
                if(holders[user][i].StackingPeriod == 12){
                    allStackingAmount += holders[user][i].amount;
                }
            }
            nAmount += amount * 25 / 100;
        }
        if(bAmount > 0){
            _depositToken.transfer(user, bAmount);
        }
        if(amountUSDT > 0){
            amountUSDT = 10 ** _depositToken.decimals() * amountUSDT / _priceUSDT;
            _depositToken.mint(user, amountUSDT * 75 / 100);
            _depositToken.mint(_marketingContract, amountUSDT * 25 / 100);
            for(uint256 i = 0; i < holders[user].length; i++){
                if(holders[user][i].StackingPeriod == 12){
                    allStackingAmount += holders[user][i].amount;
                }
            }
            nAmount += amountUSDT * 25 / 100;
        }
        if(bAmountUSDT > 0){
            bAmountUSDT = 10 ** _depositToken.decimals() * bAmountUSDT / _priceUSDT;
            _depositToken.mint(user, bAmountUSDT);
        }
        
        (bool success,) = _marketingContract
        .call(abi.encodeWithSignature("depositPools(address,uint256,uint256)",
        user,nAmount,allStackingAmount));
        require(success,"depositPools call FAIL");
    }

    function getDate(address user, uint cell) public view returns(uint256 months, uint256 remains){
        months = 0;
        remains = block.timestamp - holders[user][cell].stackingTimestamp;
        uint i = 0;
        while(remains >= _months){
            remains -= _months;
            months++;
            i++;
        }
    }
}