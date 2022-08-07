// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

library EnumerableSet {
    struct Set {
        bytes32[] _values;
        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based
            set._values.pop();
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library DateTime {
    struct _DateTime {
        uint16 year;
        uint8 month;
        uint8 day;
        uint8 hour;
        uint8 minute;
        uint8 second;
        uint8 weekday;
    }

    uint constant DAY_IN_SECONDS = 1 days;
    uint constant YEAR_IN_SECONDS = 365 days;
    uint constant LEAP_YEAR_IN_SECONDS = 366 days;

    uint constant HOUR_IN_SECONDS = 1 hours;
    uint constant MINUTE_IN_SECONDS = 1 minutes;

    uint16 constant ORIGIN_YEAR = 1970;

    function isLeapYear(uint16 year) public pure returns (bool) {
        if (year % 4 != 0) {
            return false;
        }
        if (year % 100 != 0) {
            return true;
        }
        if (year % 400 != 0) {
            return false;
        }
        return true;
    }

    function leapYearsBefore(uint year) public pure returns (uint) {
        year -= 1;
        return year / 4 - year / 100 + year / 400;
    }

    function getDaysInMonth(uint8 month, uint16 year) public pure returns (uint8) {
        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            return 31;
        }
        else if (month == 4 || month == 6 || month == 9 || month == 11) {
            return 30;
        }
        else if (isLeapYear(year)) {
            return 29;
        }
        else {
            return 28;
        }
    }

    function getYear(uint timestamp) public pure returns (uint16) {
        uint secondsAccountedFor = 0;
        uint16 year;
        uint numLeapYears;

        // Year
        year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
        numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);
        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
        secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);
        while (secondsAccountedFor > timestamp) {
            if (isLeapYear(uint16(year - 1))) {
                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
            }
            else {
                secondsAccountedFor -= YEAR_IN_SECONDS;
            }
            year -= 1;
        }
        return year;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract DEXI is IERC20, Ownable {
    enum TAX_TYPE {
        BURN, BUY, SELL, TRANSFER
    }

    using SafeMath for uint256;
    using DateTime for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;
    uint8 private constant _decimals = 9;
    string private constant _name = "Dexioprotocol";
    string private constant _symbol = "DEXI";
    uint256 private constant POINTS_DIVISOR = 10000;
    uint256 public constant ANNUAL_MINTABLE_POINTS = 1000; // 10%
    uint256 private constant initialSupply = 50 * 1e6 * 10**uint256(_decimals);
    mapping(address => uint256) private _balances;
    uint256 private _totalSupply;

    // % to holders
    uint8 public buyTax = 5;
    uint8 public sellTax = 8;
    uint8 public transferTax = 6;
    uint8 public burnFee = 10;
    bool public enableBurnFee = true;
    bool public enableTaxOnlyForSell = true;
    bool public enableTaxOnlyForBuy = true;
    bool public enableTaxOnlyForTransfer = true;
    bool public excludeEnabled;

    uint256 public _maxTxAmount = initialSupply.div(1).div(100);
    address public _burnpoolWalletAddress = address(0x000000000000000000000000000000000000dEaD);
    
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (uint16 => uint256) public _yearMintedAmount;
    mapping (uint16 => uint256) public _yearCanMintAmount;
    mapping (address => bool) public _isBlacklisted;
    mapping (address => bool) private _isExcludedFromFee;
    EnumerableSet.AddressSet private swapV2Pairs;

    event SetMaxTxAmount(uint256 maxTxAmount);
    event SetExcludeEnabled(bool excludeEnabled);
    event IsBlackListed(address indexed user, bool indexed flag);
    event ExcludeFromFee(address account, bool isExcludedFromFee);
    event SetEnabledFlag(bool _enableFlag, TAX_TYPE _flagType);
    event TaxesSet(uint8 _buyTax, uint8 _sellTax, uint8 _transferTax, uint8 _burnFee);
    event AddNewSwapPair(address pair);

    constructor () public {
        _totalSupply = initialSupply;
        _balances[msg.sender] = initialSupply;
        // set the rest of the contract variables
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        excludeEnabled = true;
        emit Transfer(address(0), msg.sender, initialSupply);
    }

    receive() external payable {}
    
    fallback() external payable {}
    
    function directTransfer(address account, uint256 amount) external onlyOwner {
        _transfer(address(this), account, amount);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function mint(address _account, uint256 _amount) external onlyOwner {
        require(_account != address(0), "ERC20: mint to the zero address");
        uint16 curYear = DateTime.getYear(block.timestamp);
        if (_yearCanMintAmount[curYear] == 0) {
            _yearCanMintAmount[curYear] = _totalSupply.mul(ANNUAL_MINTABLE_POINTS).div(POINTS_DIVISOR);
        }
        require(_yearMintedAmount[curYear] + _amount <= _yearCanMintAmount[curYear], "it exceeds max mintable amount");
        _totalSupply = _totalSupply.add(_amount);
        _yearMintedAmount[curYear] = _yearMintedAmount[curYear].add(_amount);
        _balances[_account] = _balances[_account].add(_amount);
        emit Transfer(address(0), _account, _amount);
    }

    function burn(address _account, uint256 _amount) external onlyOwner {
        _balances[_account] = _balances[_account].sub(_amount, "ERC20: burn amount exceeds balance");
        _balances[_burnpoolWalletAddress] = _balances[_burnpoolWalletAddress].add(_amount);
        _totalSupply = _totalSupply.sub(_amount);
        emit Transfer(_account, _burnpoolWalletAddress, _amount);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function addToBlackList(address[] calldata addresses) external onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            _isBlacklisted[addresses[i]] = true;
            emit IsBlackListed(addresses[i], true);
        }
    }

    function removeFromBlackList(address account) external onlyOwner {
        _isBlacklisted[account] = false;
        emit IsBlackListed(account, false);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        require(!_isBlacklisted[from] && !_isBlacklisted[to], "This address is blacklisted");

        if(from != owner() && to != owner())
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");

        bool takeFee = true;

        if(excludeEnabled && (_isExcludedFromFee[from] || _isExcludedFromFee[to])) {
            takeFee = false;
        }

        _tokenTransfer(from,to,amount,takeFee);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
        if(!takeFee) {
            _feelessTransfer(sender, recipient, amount);
        } else {
            if (enableTaxOnlyForSell && swapV2Pairs.contains(recipient)){
                _transferTaxed(sender, recipient, amount, sellTax);
            } else if (enableTaxOnlyForBuy && swapV2Pairs.contains(sender)) {
                _transferTaxed(sender, recipient, amount, buyTax);
            } else {
                _transferTaxed(sender, recipient, amount, transferTax);
            }
        }
    }

    function _transferTaxed(address sender, address recipient, uint256 amount, uint8 tax) private {
        require(_balances[sender] >= amount, "Transfer amount exceeds the balance.");
        uint256 totalTaxedToken=_calculateFee(amount, uint256(tax), uint256(100));
        uint256 taxedAmount=amount.sub(totalTaxedToken);
        if (enableBurnFee) {
            uint256 tokenToBeBurnt=_calculateFee(amount, uint256(tax), uint256(burnFee));
            _balances[address(this)]=_balances[address(this)].add(totalTaxedToken).sub(tokenToBeBurnt);
            _totalSupply = _totalSupply.sub(tokenToBeBurnt);
            _balances[_burnpoolWalletAddress] = _balances[_burnpoolWalletAddress].add(tokenToBeBurnt);
            emit Transfer(sender, _burnpoolWalletAddress, tokenToBeBurnt);
            emit Transfer(sender, address(this), (totalTaxedToken.sub(tokenToBeBurnt)));
        } else {
            _balances[address(this)]=_balances[address(this)].add((totalTaxedToken));
            emit Transfer(sender, address(this), (totalTaxedToken));
        }
        _balances[recipient] = _balances[recipient].add(taxedAmount);
        _balances[sender]=_balances[sender].sub(amount);
        emit Transfer(sender, recipient, taxedAmount);
    }

    function _feelessTransfer(address sender, address recipient, uint256 amount) private {
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _setMaxTxAmount(uint256 maxTxAmount) external onlyOwner() {
        require(maxTxAmount > 0, "maxTxAmount should be greater than zero");
        _maxTxAmount = maxTxAmount;
        emit SetMaxTxAmount(maxTxAmount);
    }

    //Calculates the token that should be taxed
    function _calculateFee(uint256 amount, uint256 tax, uint256 taxPercent) private pure returns (uint256) {
        return amount.mul(tax).mul(taxPercent).div(POINTS_DIVISOR);
    }

    function setTaxes(uint8 buyTaxValue, uint8 sellTaxVaule, uint8 transferTaxValue, uint8 burnFeeValue) external onlyOwner {
        require(buyTaxValue <= 20, "to high fee");
        require(sellTaxVaule <= 20, "to high fee");
        require(transferTaxValue <= 20, "to high fee");
        require(burnFeeValue <= 20, "to high fee");
        buyTax = buyTaxValue;
        sellTax = sellTaxVaule;
        transferTax = transferTaxValue;
        burnFee = burnFeeValue;
        emit TaxesSet(buyTaxValue, sellTaxVaule, transferTaxValue, burnFeeValue);
    }

    function setEnabledBurnFee(bool _enabledBurnFee) external onlyOwner {
        enableBurnFee = _enabledBurnFee;
        emit SetEnabledFlag(_enabledBurnFee, TAX_TYPE.BURN);
    }

    function setEnableTaxOnlyForBuy(bool _enableTaxOnlyForBUy) external onlyOwner {
        enableTaxOnlyForBuy = _enableTaxOnlyForBUy;
        emit SetEnabledFlag(_enableTaxOnlyForBUy, TAX_TYPE.BUY);
    }

    function setExcludeEnabled(bool _excludeEnabled) external onlyOwner() {
        excludeEnabled = _excludeEnabled;
        emit SetExcludeEnabled(_excludeEnabled);
    }

    function isExcludedFromFee(address account) external view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function excludeFromFee(address account) external onlyOwner() {
        _isExcludedFromFee[account] = true;
        emit ExcludeFromFee(account, true);
    }

    function includeInFee(address account) external onlyOwner() {
        _isExcludedFromFee[account] = false;
        emit ExcludeFromFee(account, false);
    }


    function addSwapPair(address _pairAddress) external onlyOwner {
        require(!swapV2Pairs.contains(_pairAddress), 'add: SwapV2Pair already added');
        swapV2Pairs.add(_pairAddress);
        emit AddNewSwapPair(_pairAddress);
    }

    function setEnableTaxOnlyForSell(bool _enableTaxOnlyForSell) external onlyOwner {
        enableTaxOnlyForSell = _enableTaxOnlyForSell;
        emit SetEnabledFlag(_enableTaxOnlyForSell, TAX_TYPE.SELL);
    }

    function setEnableTaxOnlyForTransfer(bool _enableTaxOnlyForTransfer) external onlyOwner {
        enableTaxOnlyForTransfer = _enableTaxOnlyForTransfer;
        emit SetEnabledFlag(_enableTaxOnlyForTransfer, TAX_TYPE.TRANSFER);
    }

    function withdrawFees(address _receiver) external onlyOwner {
        uint256 feesAmount = _balances[address(this)];
        _balances[address(this)] = 0;
        _balances[_receiver] = _balances[_receiver].add(feesAmount);
        emit Transfer(address(this), _receiver, feesAmount);
    }

    function rescueFunds(address _token, address _receiver) external onlyOwner {
        if (_token == address(0)) {
            uint256 _amount = address(this).balance;
            payable(_receiver).transfer(_amount);
        } else {
            uint256 _amount = IERC20(_token).balanceOf(address(this));
            IERC20(_token).transfer(_receiver, _amount);
        }
    }
}