/**
 *Submitted for verification at BscScan.com on 2022-03-31
*/

pragma solidity ^0.6.12;

// SPDX-License-Identifier: Unlicensed
interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Context {
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract BPContract {
    function protect(
        address sender,
        address receiver,
        uint256 amount
    ) external virtual;
}

contract MetaBat is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;
    

    /**
     * @dev Enable or Disable tax system
     */
    bool private _taxEnabled;
    /**
     * @dev To either store or burn tax
     */
    bool private _taxStoreEnabled;

    /**
     * @dev tax percentage to be deducted from taxed transaction
     */
    uint256 private _BUY_TAX = 1; // %
    uint256 private _SELL_TAX = 1; // %

    /**
     * @dev address to store tax collected
     */
    address private _taxStoreAddr;

    /**
     * @dev Store addresses included in tax collection
     * @dev Sending to addresses included in tax collection will remove tax using the percentage in _BUY_TAX and _SELL_TAX
     */
    mapping (address => bool) private _isIncluded;
    address[] private _included;
    

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;

    BPContract public BP;
    bool public bpEnabled;
    bool public BPDisabledForever = false;

    constructor() public {
        _name = "MetaBat";
        _symbol = "MTB";
        _decimals = 18;
        _totalSupply = 100000000000000000000000000;
        _taxStoreAddr = msg.sender;
        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function setBPAddrss(address _bp) external onlyOwner {
        require(address(BP) == address(0), "Can only be initialized once");
        BP = BPContract(_bp);
    }

    function setBpEnabled(bool _enabled) external onlyOwner {
        bpEnabled = _enabled;
    }

    function setBotProtectionDisableForever() external onlyOwner {
        require(BPDisabledForever == false);
        BPDisabledForever = true;
    }
    
    function updateBuyTax(uint256 _percentage) external onlyOwner{
        _BUY_TAX = _percentage;
    }
    
    function updateSellTax(uint256 _percentage) external onlyOwner{
        _SELL_TAX = _percentage;
    }

    function setTaxEnabled(bool _enabled) external onlyOwner {
        _taxEnabled = _enabled;
    }

    function setTaxStoreEnabled(bool _enabled) external onlyOwner {
        _taxStoreEnabled = _enabled;
    }

    function setTaxStoreAddr(address _addr) external onlyOwner {
        _taxStoreAddr = _addr;
    }

    function getOwner() external view override returns (address) {
        return owner();
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    // Checks if account is included in tax collection
    function isIncluded(address account) external view returns (bool) {
        return _isIncluded[account];
    }

    function getBuyTaxPercentage() external view returns (uint256) {
        return _BUY_TAX;
    }

    function getSellTaxPercentage() external view returns (uint256) {
        return _SELL_TAX;
    }

    function getTaxEnabled() external view returns (bool) {
        return _taxEnabled;
    }

    function getTaxStoreEnabled() external view returns (bool) {
        return _taxStoreEnabled;
    }

    function getTaxStoreAddr() external view returns (address) {
        return _taxStoreAddr;
    }
    
    /**
     * @dev Include account in tax collection by adding it to included accounts
     */
    function includeAccount(address account) external onlyOwner() {
        require(!_isIncluded[account], "DPD: Account is already included");
        _isIncluded[account] = true;
        _included.push(account);
    }
    
    /**
     * @dev Exclude account from tax collection by removing it from included accounts
     */
    function excludeAccount(address account) external onlyOwner() {
        require(_isIncluded[account], "DPD: Account is already excluded");
        for (uint256 i = 0; i < _included.length; i++) {
            if (_included[i] == account) {
                _included[i] = _included[_included.length - 1];
                _isIncluded[account] = false;
                _included.pop();
                break;
            }
        }
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "BEP20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "BEP20: decreased allowance below zero"
            )
        );
        return true;
    }

    function burn(uint256 amount) public onlyOwner returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        if (bpEnabled && !BPDisabledForever) {
            BP.protect(sender, recipient, amount);
        }

        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        if (_taxEnabled) {
            if (_isIncluded[sender] || _isIncluded[recipient]) { // if Sender or Recipient is included in tax collection then implement tax
                _transferWithTax(sender, recipient, amount);
            } else {
                _transferWithoutTax(sender, recipient, amount);
            }
        } else {
            _transferWithoutTax(sender, recipient, amount);
        }

    }

    function _transferWithTax(address sender, address recipient, uint256 amount) private {

        uint256 tTax;

        if (_isIncluded[sender]) { // if Sender is included
            tTax =  _BUY_TAX.mul(amount).div(100);
        }
        if (_isIncluded[recipient]) { // if Recipient is included
            tTax =  _SELL_TAX.mul(amount).div(100);
        }

        uint256 taxedAmount =  amount.sub(tTax);

        _balances[sender] = _balances[sender].sub(
            amount,
            "BEP20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(taxedAmount);

        if (_taxStoreEnabled) { // store tax collected in tax storage address
            _balances[_taxStoreAddr] = _balances[_taxStoreAddr].add(tTax);
        }else{
            _totalSupply = _totalSupply.sub(tTax);
        }
        
        emit Transfer(sender, recipient, taxedAmount);
    }

    function _transferWithoutTax(address sender, address recipient, uint256 amount) private {
        _balances[sender] = _balances[sender].sub(
            amount,
            "BEP20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _balances[account] = _balances[account].sub(
            amount,
            "BEP20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(
            account,
            _msgSender(),
            _allowances[account][_msgSender()].sub(
                amount,
                "BEP20: burn amount exceeds allowance"
            )
        );
    }
}