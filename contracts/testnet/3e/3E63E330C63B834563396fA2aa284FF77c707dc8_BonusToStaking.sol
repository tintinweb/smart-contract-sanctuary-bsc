/**
 *Submitted for verification at BscScan.com on 2022-08-31
*/

// SPDX-License-Identifier: MIT
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



pragma solidity ^0.8.16;





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
    mapping(uint => uint256) roundCount;
    uint256 currentRoundPrice;

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

        roundCount[0] = 4E25;
        roundCount[1] = 4E25;
        roundCount[2] = 2E25;
        roundCount[3] = 5E24;

        currentRoundPrice = 50000000000000000;

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
        _startSales = false;
    }

    function activeSales() public onlyLegalCaller{
        _startSales = true;
        _startPrivateRound = false;
    }

    function stopSales() public onlyLegalCaller{
        _startSales = false;
        _startPrivateRound = false;
    }

    function getSales() public view returns(int sales){
        sales = 0;
        if(_startPrivateRound){
            sales = 1;
        }else if(_startSales){
            sales = 2;
        }
    }

    function setRoot(address _root) public onlyLegalCaller {
        root = _root;
    }

    function mintOwner(address user, uint256 amount) public onlyLegalCaller isStartSales {
        _mint(user, amount);
    }

    function mint(address user, uint256 amount) public onlyLegalCaller isStartSales {
        if(_supplyPrivateRound + (10 ** decimals() * amount / currentRoundPrice) >= _maxSupplyPrivateRound && !_startSales){
            activeSales();
        }
        if(_startPrivateRound){
            if(_supplyPrivateRound + (10 ** decimals() * amount / currentRoundPrice) <= _maxSupplyPrivateRound){
                if(amount <= _maxMintPerUser - (currentRoundPrice * frozenAmountPrivateRound[user].amount / 10 ** decimals())){
                    uint256 migrationTimestamp = block.timestamp;
                    if(_supplyPrivateRound + (10 ** decimals() * amount / currentRoundPrice) <= 4E25){
                        amount = 10 ** decimals() * amount / roundPrice[0];
                    }else if(_supplyPrivateRound + (10 ** decimals() * amount / currentRoundPrice) <= 8E25){
                        currentRoundPrice = roundPrice[0];
                        if(_supplyPrivateRound < 4E25){
                            amount = (10 ** decimals() * (4E25 - _supplyPrivateRound) / roundPrice[0]) + (10 ** decimals() * (amount - (4E25 - _supplyPrivateRound)) / roundPrice[1]);
                        }else{
                            amount = 10 ** decimals() * amount / roundPrice[1];
                        }
                    }else if(_supplyPrivateRound + (10 ** decimals() * amount / currentRoundPrice) <= 1E26){
                        currentRoundPrice = roundPrice[1];
                        if(_supplyPrivateRound < 8E25){
                            amount = (10 ** decimals() * (8E25 - _supplyPrivateRound) / roundPrice[1]) + (10 ** decimals() * (amount - (8E25 - _supplyPrivateRound)) / roundPrice[2]);
                        }else{
                            amount = 10 ** decimals() * amount / roundPrice[2];
                        }
                    }else if(_supplyPrivateRound + (10 ** decimals() * amount / currentRoundPrice) <= 105E24){
                        currentRoundPrice = roundPrice[2];
                        if(_supplyPrivateRound < 1E26){
                            amount = (10 ** decimals() * (1E26 - _supplyPrivateRound) / roundPrice[2]) + (10 ** decimals() * (amount - (1E26 - _supplyPrivateRound)) / roundPrice[3]);
                        }else{
                            amount = 10 ** decimals() * amount / roundPrice[3];
                        }
                    }
                    _mint(user, amount);
                    _supplyPrivateRound += amount;
                    frozenAmountPrivateRound[user] = UserPR(frozenAmountPrivateRound[user].amount + amount, migrationTimestamp, frozenAmountPrivateRound[user].amount + amount);
                    emit MintFrozenAmountPrivateRound(user, amount);
                }
            }
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

    function getDate(address user) public view returns(uint256 months){
        months = 0;
        uint256 newTS = block.timestamp - frozenAmount[user].timestamp;
        while(newTS >= _months){
            newTS -= _months;
            months++;
        }
    }

    function getDatePrivateRound(address user) public view returns(uint256 months){
        months = 0;
        uint256 newTS = block.timestamp - frozenAmountPrivateRound[user].timestamp;
        while(newTS >= _months){
            newTS -= _months;
            months++;
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

        uint256 fAmount = frozenAmount[from].amount;
        uint256 fAmountPR = frozenAmountPrivateRound[from].amount;

        if(frozenAmount[from].timestamp != 0){
            uint256 monthsCount = getDate(from);
            if(monthsCount <= 36){
                if(monthsCount != 0){
                    uint256 nPercents = 0;
                    uint i = 1;
                    while(i <= monthsCount){
                        if(i <= 12){
                            nPercents += _firstYear;
                        }else if(i > 12 && i <= 24){
                            nPercents += _secondYear;
                        }else{
                            nPercents += _thirdYear;
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
                fAmount = 0;
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
                            nPercentsPrivateRound += _firstYearPrivateRound;
                        }else{
                            nPercentsPrivateRound += _secondYearPrivateRound;
                        }
                        i++;
                    }
                    if(fAmountPR >= fAmountPR * nPercentsPrivateRound / 10000){
                        fAmountPR -= fAmountPR * nPercentsPrivateRound / 10000;
                    }else{
                        fAmountPR = 0;
                    }
                }
            }else{
                fAmountPR = 0;
                frozenAmountPrivateRound[from] = UserPR(0, 0, 0);
            }
        }

        require(balanceOf(from) - amount >= fAmount + fAmountPR, "The amount exceeds the allowed amount for withdrawal");
        
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
// File: contracts/stackingFenom2.sol



pragma solidity ^0.8.14;


contract StakingPhenom{

    FrozenToken _depositToken;
    uint256 public _priceUSDT;
    address public _owner;
    mapping(address => bool) public _b2s;
    address public _migrationCaller;
    address public _marketingContract;
    StakingPhenom public _oldStakingContract;

    bool public _emergency;

    //uint256 _days = 1 days;
    uint256 _days = 5 minutes;

    struct Staking{
        uint256 amount;
        uint8 staking;
        uint256 StakingMonths;
        uint256 StakingPeriod;
        uint256 stakingTimestamp;
        uint256 daysRemains;
        bool frozen;
    }

    mapping(uint256 => uint256) public StakingPeriods;

    mapping(address => Staking[]) public holders;
    mapping(address => uint256) public holderStakingCount;

    modifier onlyOwner() {
        require(msg.sender == _owner, "caller is not Owner");
        _;
    }

    modifier onlyB2S() {
        require(_b2s[msg.sender] || msg.sender == _owner, "caller is not b2s");
        _;
    }

    modifier onlyMigrationCaller() {
        require(msg.sender == _migrationCaller, "caller is not Migration Caller");
        _;
    }

    event AddedToStakingNotActivated(address indexed user, uint256 amount);
    event AddedToStaking(address indexed user, uint256 amount, uint8 token, uint256 period);
    event WithdrawalPercents(address indexed user, uint256 amount, uint8 token);
    event WithdrawalBodyDeposit(address indexed user, uint256 amount, uint8 token);
    event ReinvestedPercents(address indexed user, uint256 amount, uint8 token);
    event AddedToTokenStaking(address indexed user, uint256 amount, uint8 token);

    constructor(address owner, address migrationCaller){
        _owner = owner;
        _migrationCaller = migrationCaller;
        StakingPeriods[6] = 17; //6 months - 5% (0,17 in day)
        StakingPeriods[9] = 23; //9 months - 7% (0,23 in day)
        StakingPeriods[12] = 30; //12 months - 9% (0,3 in day)
        StakingPeriods[24] = 40; //24 months - 12% (0,4 in day)
    }

    function newOwner(address _newOwner) public onlyOwner{
        _owner = _newOwner;
    }

    function setEmergency(bool emergency) public onlyOwner{
        _emergency = emergency;
    }

    function setOldStakingContract(address oldStakingContract) public onlyOwner{
        _oldStakingContract = StakingPhenom(oldStakingContract);
    }
    
    function setDepositToken(FrozenToken depositToken) public onlyOwner{
        _depositToken = depositToken;
    }

    function setMarketingContract(address marketingContract) public onlyOwner{
        _marketingContract = marketingContract;
    }

    function setB2S(address[] memory b2s) public onlyOwner{
        for(uint256 b2 = 0; b2 < b2s.length; b2++){
            _b2s[b2s[b2]] = true;
        }
    }

    function setMigrationCaller(address migrationCaller) public onlyOwner{
        _migrationCaller = migrationCaller;
    }

    function setPriceUSDT(uint256 priceUSDT) public onlyOwner{
        _priceUSDT = priceUSDT;
    }

    function getPeriods(uint256 period) public view returns(uint256){
        return StakingPeriods[period];
    }

    function setPeriod(uint256 period, uint256 percent) public onlyOwner{
        StakingPeriods[period] = percent;
    }

    function getStaking(address user) public view returns (Staking[] memory) {
        return holders[user];
    }

    function transferFromTheOld(address[] memory users) public onlyOwner{
        for(uint256 i = 0; i < users.length; i++){
            Staking[] memory st = _oldStakingContract.getStaking(users[i]);
            for(uint256 s = 0; s < st.length; s++){
                holders[users[i]].push(st[s]);
                holderStakingCount[users[i]]++;
            }
        }
    }

    function transferTokenToStaking(uint256 amount, uint256 period) public {
        require(msg.sender != address(0), "User with zero address");
        require(amount > 0, "The amount cannot be zero");
        require(StakingPeriods[period] != 0, "There is no such staking period");
        uint256 periodDays = period * 30;
        _depositToken.transferFrom(msg.sender, address(this), amount);
        holders[msg.sender].push(Staking(amount, 1, period, StakingPeriods[period], block.timestamp, periodDays, false));
        holderStakingCount[msg.sender]++;
        emit AddedToStaking(msg.sender, amount, 1, period);
    }

    function transferFrozenToStaking(uint256 period, uint8 token) public {
        require(msg.sender != address(0), "User with zero address");
        require(StakingPeriods[period] != 0, "There is no such staking period");
        uint256 timestamp = block.timestamp;
        uint256 periodDays = period * 30;
        bool fr = false;
        for(uint i = 0; i < holders[msg.sender].length; i++){
            if(holders[msg.sender][i].frozen && holders[msg.sender][i].staking == token){
                fr = true;
                holders[msg.sender][i].StakingPeriod = StakingPeriods[period];
                holders[msg.sender][i].stakingTimestamp = timestamp;
                holders[msg.sender][i].StakingMonths = period;
                holders[msg.sender][i].daysRemains = periodDays;
                holders[msg.sender][i].frozen = false;
                emit AddedToStaking(msg.sender, holders[msg.sender][i].amount, 0, period);
            }
        }
        require(fr, "No pending Tokens");
    }

    function transferAdminTokenToStaking(address user, uint8 token, uint256 amount, uint256 period) public onlyB2S{
        require(user != address(0), "User with zero address");
        require(amount > 0, "The amount cannot be zero");
        require(StakingPeriods[period] != 0, "There is no such staking period");
        uint256 periodDays = period * 30;
        if(token == 1){
            _depositToken.transferFrom(msg.sender, address(this), amount);
        }
        holders[user].push(Staking(amount, token, period, StakingPeriods[period], block.timestamp, periodDays, false));
        holderStakingCount[user]++;
        emit AddedToStaking(user, amount, token, period);
    }

    function getSales() public view returns(int){
        return _depositToken.getSales();
    }

    function migrationMint(address user, uint256 amount, bool add) public onlyMigrationCaller{
        _depositToken.migrationMint(user, amount, add);
    }

    function delivery(
		address user,
		uint8 token,
		uint256 amount
	) external onlyB2S {
        if(_emergency){
            holders[user].push(Staking(amount, token, 0, 0, 0, 0, true));
            holderStakingCount[user]++;
            emit AddedToStakingNotActivated(user, amount);
        } else if(getSales() == 1 && !_emergency){
            _depositToken.mint(user, amount);
        }else if(getSales() == 2 && !_emergency){
            holders[user].push(Staking(amount, token, 0, 0, 0, 0, true));
            holderStakingCount[user]++;
            emit AddedToStakingNotActivated(user, amount);
        }
	}

    function withdrawPercents(uint8 token) public{
        for(uint i = 0; i < holders[msg.sender].length; i++){
            if(holders[msg.sender][i].staking == token){
                withdrawOneStakingPercents(i);
            }
        }
    }

    function withdrawPercentsForPeriod(uint8 token, uint256 period) public{
        for(uint i = 0; i < holders[msg.sender].length; i++){
            if(holders[msg.sender][i].staking == token && holders[msg.sender][i].StakingMonths == period){
                withdrawOneStakingPercents(i);
            }
        }
    }

    function withdrawOneStakingPercents(uint256 stakingNum) public{
        require(msg.sender != address(0), "Withdraw user the zero address");
        require(stakingNum < holders[msg.sender].length, "Staking does not exist");
        require(!holders[msg.sender][stakingNum].frozen, "Stacking is not activated yet");
        uint256 amount = 0;
        uint256 amountUSDT = 0;
        uint256 bAmount = 0;
        uint256 bAmountUSDT = 0;
        uint256 timestamp = block.timestamp;
        
        if(holders[msg.sender][stakingNum].stakingTimestamp != 0){
            (uint256 days_, uint256 remains) = getDate(msg.sender, stakingNum);
            require(days_ > 0, "The time for interest payments has not yet come");
            holders[msg.sender][stakingNum].stakingTimestamp = timestamp - remains;
            if(holders[msg.sender][stakingNum].daysRemains > days_){
                holders[msg.sender][stakingNum].daysRemains -= days_;
                if(holders[msg.sender][stakingNum].staking == 1){
                    amount = (holders[msg.sender][stakingNum].amount * holders[msg.sender][stakingNum].StakingPeriod / 100) / 100 * days_;
                }else if(holders[msg.sender][stakingNum].staking == 0){
                    amountUSDT = (holders[msg.sender][stakingNum].amount * holders[msg.sender][stakingNum].StakingPeriod / 100) / 100 * days_;
                }
            }else{
                if(holders[msg.sender][stakingNum].staking == 1){
                    amount = (holders[msg.sender][stakingNum].amount * holders[msg.sender][stakingNum].StakingPeriod / 100) / 100 * holders[msg.sender][stakingNum].daysRemains;
                    bAmount = holders[msg.sender][stakingNum].amount;
                }else if(holders[msg.sender][stakingNum].staking == 0){
                    amountUSDT = (holders[msg.sender][stakingNum].amount * holders[msg.sender][stakingNum].StakingPeriod / 100) / 100 * holders[msg.sender][stakingNum].daysRemains;
                    bAmountUSDT = holders[msg.sender][stakingNum].amount;
                }
            }
        }

        uint256 allStakingAmount = 0;
        uint256 nAmount = 0;
        
        if(amount > 0){
            if(_emergency){
                _depositToken.transfer(msg.sender, amount * 75 / 100);
                _depositToken.transfer(_marketingContract, amount * 25 / 100);
            }else{
                _depositToken.mint(msg.sender, amount * 75 / 100);
                _depositToken.mint(_marketingContract, amount * 25 / 100);
            }
            if(holders[msg.sender][stakingNum].StakingPeriod == 12){
                allStakingAmount = holders[msg.sender][stakingNum].amount;
            }
            nAmount += amount * 25 / 100;
            emit WithdrawalPercents(msg.sender, amount, 1);
        }
        if(bAmount > 0){
            _depositToken.transfer(msg.sender, bAmount);
            if(holders[msg.sender].length > 1){
                holders[msg.sender][stakingNum] = holders[msg.sender][holders[msg.sender].length - 1];
            }
            holders[msg.sender].pop();
            holderStakingCount[msg.sender]--;
            emit WithdrawalBodyDeposit(msg.sender, bAmount, 1);
        }
        if(amountUSDT > 0){
            amountUSDT = 10 ** _depositToken.decimals() * amountUSDT / _priceUSDT;
            if(_emergency){
                _depositToken.transfer(msg.sender, amountUSDT * 75 / 100);
                _depositToken.transfer(_marketingContract, amountUSDT * 25 / 100);
            }else{
                _depositToken.mint(msg.sender, amountUSDT * 75 / 100);
                _depositToken.mint(_marketingContract, amountUSDT * 25 / 100);
            }
            if(holders[msg.sender][stakingNum].StakingPeriod == 12){
                allStakingAmount = holders[msg.sender][stakingNum].amount;
            }
            nAmount += amountUSDT * 25 / 100;
            emit WithdrawalPercents(msg.sender, amountUSDT, 0);
        }
        if(bAmountUSDT > 0){
            bAmountUSDT = 10 ** _depositToken.decimals() * bAmountUSDT / _priceUSDT;
            if(_emergency){
                _depositToken.transfer(msg.sender, bAmountUSDT);
            }else{
                _depositToken.mint(msg.sender, bAmountUSDT);
            }
            if(holders[msg.sender].length > 1){
                holders[msg.sender][stakingNum] = holders[msg.sender][holders[msg.sender].length - 1];
            }
            holders[msg.sender].pop();
            holderStakingCount[msg.sender]--;
            emit WithdrawalBodyDeposit(msg.sender, bAmountUSDT, 0);
        }
        
        (bool success,) = _marketingContract
        .call(abi.encodeWithSignature("depositPools(address,uint256,uint256)",
        msg.sender,nAmount,allStakingAmount));
        require(success,"depositPools call FAIL");
    }

    function addToStaking(uint256 amount, uint256 stakingNum) public{
        require(msg.sender != address(0), "Reinvest user the zero address");
        require(stakingNum < holders[msg.sender].length, "Staking does not exist");
        require(holders[msg.sender][stakingNum].staking == 1, "Staking is not in the project tokens!");
        require(amount > 0, "The amount cannot be zero");
        _depositToken.transferFrom(msg.sender, address(this), amount);
        (uint256 m, ) = getDate(msg.sender, stakingNum);
        if(m > 0){
            reinvestOneStakingPercents(stakingNum);
        }
        holders[msg.sender][stakingNum].amount += amount;
        emit AddedToTokenStaking(msg.sender, amount, 1);
    }

    function reinvestStakingPercents(uint8 token) public{
        for(uint i = 0; i < holders[msg.sender].length; i++){
            if(holders[msg.sender][i].staking == token){
                reinvestOneStakingPercents(i);
            }
        }
    }

    function reinvestStakingPercentsForPeriod(uint8 token, uint256 period) public{
        for(uint i = 0; i < holders[msg.sender].length; i++){
            if(holders[msg.sender][i].staking == token && holders[msg.sender][i].StakingMonths == period){
                reinvestOneStakingPercents(i);
            }
        }
    }

    function reinvestOneStakingPercents(uint256 stakingNum) public{
        require(msg.sender != address(0), "Reinvest user the zero address");
        require(stakingNum < holders[msg.sender].length, "Staking does not exist");
        require(!holders[msg.sender][stakingNum].frozen, "Stacking is not activated yet");
        uint256 amount = 0;
        uint256 amountUSDT = 0;
        uint256 timestamp = block.timestamp;
        
        if(holders[msg.sender][stakingNum].stakingTimestamp != 0){
            (uint256 days_, uint256 remains) = getDate(msg.sender, stakingNum);
            require(holders[msg.sender][stakingNum].daysRemains > days_, "The staking period is over");
            require(days_ > 0, "The time for interest payments has not yet come");
            holders[msg.sender][stakingNum].stakingTimestamp = timestamp - remains;
            if(holders[msg.sender][stakingNum].daysRemains > days_){
                holders[msg.sender][stakingNum].daysRemains -= days_;
                if(holders[msg.sender][stakingNum].staking == 1){
                    amount += (holders[msg.sender][stakingNum].amount * holders[msg.sender][stakingNum].StakingPeriod / 100) / 100 * days_;
                }else if(holders[msg.sender][stakingNum].staking == 0){
                    amountUSDT += (holders[msg.sender][stakingNum].amount * holders[msg.sender][stakingNum].StakingPeriod / 100) / 100 * days_;
                }
            }
        }

        uint256 allStakingAmount = 0;
        uint256 nAmount = 0;
        
        if(amount > 0){
            if(_emergency){
                _depositToken.transfer(_marketingContract, amount * 25 / 100);
            }else{
                _depositToken.mint(_marketingContract, amount * 25 / 100);
            }
            if(holders[msg.sender][stakingNum].StakingPeriod == 12){
                allStakingAmount += holders[msg.sender][stakingNum].amount;
            }
            holders[msg.sender][stakingNum].amount += amount * 75 / 100;
            if(!_emergency){
                _depositToken.mint(address(this), amount * 75 / 100);
            }
            nAmount += amount * 25 / 100;
            (bool success,) = _marketingContract
            .call(abi.encodeWithSignature("depositPools(address,uint256,uint256)",
            msg.sender,nAmount,allStakingAmount));
            require(success,"depositPools call FAIL");
            emit ReinvestedPercents(msg.sender, amount, 1);
        }
        if(amountUSDT > 0){
            holders[msg.sender][stakingNum].amount += amountUSDT;
            emit ReinvestedPercents(msg.sender, amountUSDT, 0);
        }
    }

    function getDate(address user, uint cell) public view returns(uint256 days_, uint256 remains){
        days_ = 0;
        remains = block.timestamp - holders[user][cell].stakingTimestamp;
        while(remains >= _days){
            remains -= _days;
            days_++;
        }
    }

    function withdrawTokens(uint256 amount) public onlyOwner{
        _depositToken.transfer(_owner, amount);
    }
}
// File: contracts/bonusToStaking.sol



pragma solidity ^0.8.14;


contract BonusToStaking{
    address public _owner;
    address public _bonusContract;
    StakingPhenom public _stakingPhenom;
    uint8 public _token;

    modifier onlyOwner() {
        require(msg.sender == _owner, "caller is not Owner");
        _;
    }

    modifier onlyLegalCaller() {
        require(msg.sender == _bonusContract || msg.sender == _owner, "caller is not Legal Caller");
        _;
    }

    constructor(address owner, address bonusContract, address stakingPhenom, uint8 token){
        _owner = owner;
        _bonusContract = bonusContract;
        _stakingPhenom = StakingPhenom(stakingPhenom);
        _token = token;
    }

    function newOwner(address _newOwner) public onlyOwner{
        _owner = _newOwner;
    }

    function setBonusContract(address bonusContract) public onlyOwner{
        _bonusContract = bonusContract;
    }

    function setStakingPhenom(address stakingPhenom) public onlyOwner{
        _stakingPhenom = StakingPhenom(stakingPhenom);
    }

    function delivery(
		address user,
		uint256 packetType,
		uint256 quantity,
		uint256 packageId,
		uint256 amount
	) external onlyLegalCaller {
        _stakingPhenom.delivery(user, _token, amount);
	}

    function withdrawTokens(uint256 amount, address payToken) public onlyOwner{
        FrozenToken(payToken).transfer(_owner, amount);
    }
}