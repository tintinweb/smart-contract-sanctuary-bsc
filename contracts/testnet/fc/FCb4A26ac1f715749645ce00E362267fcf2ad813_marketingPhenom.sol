/**
 *Submitted for verification at BscScan.com on 2022-08-06
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

    function getDate(address user) private view returns(uint256 months){
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

        uint256 fAmount = frozenAmount[from].amount + frozenAmountPrivateRound[from].amount;

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
                    if(fAmount >= fAmount * nPercentsPrivateRound / 10000){
                        fAmount -= fAmount * nPercentsPrivateRound / 10000;
                    }else{
                        fAmount = 0;
                    }
                }
            }else{
                fAmount = 0;
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
// File: contracts/marketingPhenom2.sol



pragma solidity ^0.8.14;


/*
нет квалификации - 0

Senior Agent -1
Group Agent - 2
Manager Senior - 3
Manager - 4
Group Manager - 5
Regional Manager - 6
Director - 7
Senior Director - 8
Group Director - 9
Regional Director - 10
National Director - 11
International Director - 12
World Director - 13
Ambassador - 14
Senior Ambassador - 15
Group Ambassador - 16
Regional Ambassador - 17
National Ambassador - 18
International Ambassador - 19
*/

contract marketingPhenom{
    address public caller;
    address public stackingContract;
    FrozenToken public _depositToken;
    address public _owner;
    
    address public extraFund;
    uint256 public extraFundAmount;

    uint256 public pool1;
    uint256 public pool2;
    uint256 public pool3;
    uint256 public pool4;

    struct LinePool{
        mapping(uint256 => uint256) linePoolAmount;
    }

    uint256[9] public percentsToLine = [24, 16, 8, 6, 6, 4, 4, 2, 2];

    mapping(address => uint256) public userStackingAmount; // Колличество застекированных токенов

    mapping(address => uint256) public usersAmount; // Суммы для выплат пользователям

    mapping(address => mapping(uint256 => uint256)) public UserLinePool; // сумма на линейный бонус пользователю

    mapping(address => address) public userReferrers;

    modifier onlyOwner() {
        require(msg.sender == _owner, "caller is not Owner");
        _;
    }

    modifier onlyLegalCaller() {
        require(msg.sender == caller, "caller is not Legal Caller");
        _;
    }

    modifier onlyStackingContract() {
        require(msg.sender == stackingContract, "caller is not Legal Caller");
        _;
    }

    constructor(address owner, address _caller, address _stackingContract, address _extraFund){
        _owner = owner;
        caller = _caller;
        stackingContract = _stackingContract;
        extraFund = _extraFund;
    }

    function setDepositToken(FrozenToken depositToken) public onlyOwner{
        _depositToken = depositToken;
    }

    function depositPools(address user, uint256 amount, uint256 allStackingAmount) public onlyStackingContract{

        pool1 += amount * 12 / 100;
        pool2 += amount * 8 / 100;
        pool3 += amount * 4 / 100;
        pool4 += amount * 4 / 100;

        address ref = user;
        for(uint256 i = 0; i < percentsToLine.length; i++){
            ref = userReferrers[ref];
            UserLinePool[ref][i] += amount * percentsToLine[i] / 100;
        }
        
        userStackingAmount[user] = allStackingAmount;

        extraFundAmount += amount;
    }

    function addReferal(address user, address referrer) public onlyLegalCaller{
        userReferrers[user] = referrer;
    }

    function addReferals(address[] memory users, address[] memory referrers) public onlyLegalCaller{
        for(uint256 i = 0; i< users.length; i++){
            userReferrers[users[i]] = referrers[i];
        }
    }

    function updatePools(address[] memory users, uint8[] memory qualifications, uint256[] memory amounts) public onlyLegalCaller {
        uint256 q1 = 0;
        uint256 q2 = 0;
        uint256 q3 = 0;
        uint256 q4 = 0;
        for(uint256 q = 0; q < users.length; q++){
            if(qualifications[q] >= 8){
                q1++;
            }
            if(qualifications[q] >= 10){
                q2++;
            }
            if(qualifications[q] >= 11){
                q3++;
            }
            if(qualifications[q] >= 14){
                q4++;
            }
        }
        
        for(uint256 i = 0; i < users.length; i++){
            if(qualifications[i] >= 14 && amounts[i] >= 40000000000000000000000){
                for(uint256 a = 0; a < 9; a++){
                    usersAmount[users[i]] += UserLinePool[users[i]][a];
                }
                usersAmount[users[i]] += pool1 / q1;
                usersAmount[users[i]] += pool2 / q2;
                usersAmount[users[i]] += pool3 / q3;
                usersAmount[users[i]] += pool4 / q4;
            }else if(qualifications[i] >= 13 && amounts[i] >= 25000000000000000000000){
                for(uint256 a = 0; a < 9; a++){
                    usersAmount[users[i]] += UserLinePool[users[i]][a];
                }
                usersAmount[users[i]] += pool1 / q1;
                usersAmount[users[i]] += pool2 / q2;
                usersAmount[users[i]] += pool3 / q3;
            }else if(qualifications[i] >= 12 && amounts[i] >= 15000000000000000000000){
                for(uint256 a = 0; a < 8; a++){
                    usersAmount[users[i]] += UserLinePool[users[i]][a];
                }
                usersAmount[users[i]] += pool1 / q1;
                usersAmount[users[i]] += pool2 / q2;
                usersAmount[users[i]] += pool3 / q3;
            }else if(qualifications[i] >= 11 && amounts[i] >= 10000000000000000000000){
                for(uint256 a = 0; a < 8; a++){
                    usersAmount[users[i]] += UserLinePool[users[i]][a];
                }
                usersAmount[users[i]] += pool1 / q1;
                usersAmount[users[i]] += pool2 / q2;
            }else if(qualifications[i] >= 10 && amounts[i] >= 8000000000000000000000){
                for(uint256 a = 0; a < 7; a++){
                    usersAmount[users[i]] += UserLinePool[users[i]][a];
                }
                usersAmount[users[i]] += pool1 / q1;
                usersAmount[users[i]] += pool2 / q2;
            }else if(qualifications[i] >= 9 && amounts[i] >= 6000000000000000000000){
                for(uint256 a = 0; a < 7; a++){
                    usersAmount[users[i]] += UserLinePool[users[i]][a];
                }
                usersAmount[users[i]] += pool1 / q1;
            }else if(qualifications[i] >= 8 && amounts[i] >= 4000000000000000000000){
                for(uint256 a = 0; a < 6; a++){
                    usersAmount[users[i]] += UserLinePool[users[i]][a];
                }
                usersAmount[users[i]] += pool1 / q1;
            }else if(qualifications[i] >= 7 && amounts[i] >= 2000000000000000000000){
                for(uint256 a = 0; a < 6; a++){
                    usersAmount[users[i]] += UserLinePool[users[i]][a];
                }
            }else if(qualifications[i] >= 6 && amounts[i] >= 1000000000000000000000){
                for(uint256 a = 0; a < 6; a++){
                    usersAmount[users[i]] += UserLinePool[users[i]][a];
                }
            }else if(qualifications[i] >= 5 && amounts[i] >= 750000000000000000000){
                for(uint256 a = 0; a < 5; a++){
                    usersAmount[users[i]] += UserLinePool[users[i]][a];
                }
            }else if(qualifications[i] >= 4 && amounts[i] >= 500000000000000000000){
                for(uint256 a = 0; a < 4; a++){
                    usersAmount[users[i]] += UserLinePool[users[i]][a];
                }
            }else if(qualifications[i] >= 3 && amounts[i] >= 250000000000000000000){
                for(uint256 a = 0; a < 3; a++){
                    usersAmount[users[i]] += UserLinePool[users[i]][a];
                }
            }else if(qualifications[i] >= 2 && amounts[i] >= 250000000000000000000){
                for(uint256 a = 0; a < 2; a++){
                    usersAmount[users[i]] += UserLinePool[users[i]][a];
                }
            }else if(qualifications[i] >= 1 && amounts[i] >= 100000000000000000000){
                for(uint256 a = 0; a < 1; a++){
                    usersAmount[users[i]] += UserLinePool[users[i]][a];
                }
            }

            UserLinePool[users[i]][0] = 0;
            UserLinePool[users[i]][1] = 0;
            UserLinePool[users[i]][2] = 0;
            UserLinePool[users[i]][3] = 0;
            UserLinePool[users[i]][4] = 0;
            UserLinePool[users[i]][5] = 0;
            UserLinePool[users[i]][6] = 0;
            UserLinePool[users[i]][7] = 0;
            UserLinePool[users[i]][8] = 0;
        }
        pool1 = 0;
        pool2 = 0;
        pool3 = 0;
        pool4 = 0;
    }

    function widthdrawBonus(address user) public{
        require(usersAmount[user] > 0, "The amount cannot be zero");
        extraFundAmount -= usersAmount[user];
        _depositToken.transfer(user, usersAmount[user]);
    }

    function widthdrawFunds(uint256 amount) public onlyOwner{
        _depositToken.transfer(extraFund, amount);
    }
}