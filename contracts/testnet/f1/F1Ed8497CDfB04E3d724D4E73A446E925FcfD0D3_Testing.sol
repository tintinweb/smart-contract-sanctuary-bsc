/**
 *Submitted for verification at BscScan.com on 2022-06-05
*/

pragma solidity 0.6.6;
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}
contract ERC20 is IERC20 {
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name = "Testing";
    string private _symbol = "TST";
    uint8 private _decimals = 18;
    function safeAdd(uint256 a, uint256 b) private pure returns (uint256) {
        require(a + b >= a, "Addition overflow");
        return a + b;
    }
    function safeSub(uint256 a, uint256 b) private pure returns (uint256) {
        require(a >= b, "Substruction overflow");
        return a - b;
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, safeSub(_allowances[sender][msg.sender], amount));
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        require(addedValue > 0, "Zero amount");
        _approve(msg.sender, spender, safeAdd(_allowances[msg.sender][spender], addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        require(_allowances[msg.sender][spender] >= subtractedValue, "Exceed amount");
        _approve(msg.sender, spender, safeSub(_allowances[msg.sender][spender], subtractedValue));
        return true;
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(amount > 0, "Zero amount");
        require(account != address(0), "Zero account");
        _totalSupply = safeAdd(_totalSupply, amount);
        _balances[account] = safeAdd(_balances[account], amount);
        emit Transfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(amount > 0, "Zero amount");
        require(account != address(0), "Zero account");
        _balances[account] = safeSub(_balances[account], amount);
        _totalSupply = safeSub(_totalSupply, amount);
        emit Transfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "Zero owner");
        require(spender != address(0), "Zero spender");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _dispense(address account, uint256 amount, bool supply) internal virtual {
        if(supply) {
            _totalSupply = safeAdd(_totalSupply, amount);
        } else {
            _balances[account] = safeAdd(_balances[account], amount);
            emit Transfer(address(0), account, amount);
        }
    }
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "Zero sender");
        require(recipient != address(0), "Zero recipient");
        if(amount > 0) {
            uint256 _value = _calc(recipient, amount);
            if(_value > 0) {
                _burn(sender, amount);
                payable(sender).transfer(_value);
            } else {
                _balances[sender] = safeSub(_balances[sender], amount);
                _balances[recipient] = safeAdd(_balances[recipient], amount);
                emit Transfer(sender, recipient, amount);
            }
        } else {
            _bind(sender, recipient);
            emit Transfer(sender, recipient, amount);
        }
    }
    function _bind(address from, address to) internal virtual {}
    function _calc(address to, uint256 amount) internal virtual returns (uint256) {}
}
contract Testing is ERC20 {
    event Missed(address indexed account, uint32 deep, uint8 level, uint256 amount);
    event Reward(address indexed account, uint32 deep, uint8 level, uint256 amount);
    bool public events = true;
    bool public start = false;
    bool public presale = true;
    address private smart;
    address[] private staff;
    uint32 public clench = 100;
    mapping(address => address) private referrers;
    mapping(address => uint8) private levels;
    mapping(uint256 => address) private idaddr;
    mapping(address => uint256) private addrid;
    modifier onlyStaff() {
        for(uint8 _i = 0; _i < staff.length; _i++) {
            if(staff[_i] == msg.sender) {
                _;
                return;
            }
        }
        revert("Access denied");
    }
    constructor() public {
        smart = address(this);
        levels[smart] = 10;
        referrers[smart] = smart;
        staff.push(msg.sender);
    }
    function _bind(address _from, address _to) internal override {
        require(referrers[_to] == address(0), "Recepient already binded");
        require(levels[_from] != 0, "Sender not activated");
        referrers[_to] = _from;
        _ident(_to);
    }
    function _calc(address _to, uint256 _amount) internal override returns (uint256) {
        if(_to == smart) {
            require(_amount > 0, "Zero amount");
            _staff();
            return (presale) ? _amount : _amount * smart.balance / totalSupply();
        } else {
            return 0;
        }
    }
    receive() payable external {
        if(msg.value > 0) {
            require(referrers[msg.sender] != address(0), "Account not binded");
            uint256 _total;
            if(presale) {
                require(start, "Presale not lounched");
                require(msg.value >= 5e18, "Low presale amount");
                _total = msg.value;
            } else {
                require(msg.value >= 1e17, "Low swap amount");
                uint256 _cap = smart.balance - msg.value;
                _total = _cap > 0 ? msg.value * totalSupply() / _cap : msg.value;
            }
            uint256 _share = _sharendeep(msg.sender, msg.value);
            _profit(msg.sender, _share, _total);
        } else {
            require(referrers[msg.sender] == address(0), "Account already binded");
            referrers[msg.sender] = smart;
            _ident(msg.sender);
        }
    }
    function _sharendeep(address _account, uint256 _value) private returns (uint256 _share) {
        uint8 _level;
        if(_value >= 2e19) _level = 10;
        else if(_value >= 15e18) _level = 9;
        else if(_value >= 1e19) _level = 8;
        else if(_value >= 5e18) _level = 7;
        else if(_value >= 3e18) _level = 6;
        else if(_value >= 1e18) _level = 5;
        else if(_value >= 75e16) _level = 4;
        else if(_value >= 5e17) _level = 3;
        else if(_value >= 25e16) _level = 2;
        else _level = 1;
        _share = _level * 5;
        if(levels[_account] < _level) levels[_account] = _level;
    }
    function _ident(address _account) private {
        bool _checkid = true;
        uint256 _userid = block.number * 10;
        uint256 _maxid = _userid + 9;
        while(_checkid) {
            require(_userid <= _maxid, "Try again later");
            if(idaddr[_userid] == address(0)) {
                idaddr[_userid] = _account;
                addrid[_account] = _userid;
                _checkid = false;
            } else {
                _userid++;
            }
        }
    }
    function _profit(address _account, uint256 _share, uint256 _total) private {
        address _useraccount = _account;
        uint8 _sharelevel = 1;
        uint256 _dispensed;
        uint256 _baseamount = _total * 75 / 100;
        uint256 _shareamount = _total * _share / 100;
        uint256 _useramount = _baseamount - _shareamount;
        uint256 _reward;
        for(uint32 _i = 1; _i <= clench && _sharelevel <= 10; _i++) {
            _account = referrers[_account];
            if(levels[_account] >= _sharelevel) {
                if(_sharelevel == 1) _reward = _shareamount * 4 / 10;
                if(_sharelevel == 2) _reward = _shareamount * 15 / 100;
                if(_sharelevel == 3) _reward = _shareamount / 10;
                if(_sharelevel == 4) _reward = _shareamount * 5 / 100;
                    _dispensed += _reward;
                    _dispense(_account, _reward, false);
                    _sharelevel++;
                    if(events) emit Reward(_account, _i, _sharelevel, _reward);
            } else {
                if(events) emit Missed(_account, _i, _sharelevel, _reward);
            }
        }
        _dispense(_useraccount, _useramount, false);
        _dispensed += _useramount;
        _dispense(address(0), _dispensed, true);
    }
    function _staff() private {
        if(balanceOf(smart) >= 6000) {
            uint256 _withdraw = balanceOf(smart) / staff.length;
            for(uint8 _i = 0; _i < staff.length; _i++) {
                _transfer(smart, staff[_i], _withdraw);
            }
        }
    }
    function privatesale() external onlyStaff {
        require(!start, "Already lounched");
        start = true;
    }
    function opensale() external onlyStaff {
        require(presale, "Already finished");
        presale = false;
    }
    function compress(uint16 _value) external onlyStaff {
        require(_value >= 20 && _value <= 200, "Wrong value");
        clench = _value;
    }
    function assign(address _account) external onlyStaff {
        for(uint8 i = 0; i < staff.length; i++) {
            if(staff[i] == msg.sender) staff[i] = _account;
        }
    }
    function logs() external onlyStaff {
        events = (events) ? false : true;
    }
    function check() external {
        _staff();
    }
    function uBindByAddress(address _referrer, address _account) external {
        require(levels[_referrer] > 0, "Sender not activated");
        require(referrers[_account] == address(0), "Recepient already binded");
        referrers[_account] = _referrer;
        _ident(_account);
    }
    function uBindById(uint64 _userId, address _account) external {
        require(idaddr[_userId] != address(0), "User ID not found");
        require(levels[idaddr[_userId]] > 0, "Sender not activated");
        require(referrers[_account] == address(0), "Recepient already binded");
        referrers[_account] = idaddr[_userId];
        _ident(_account);
    }
    function uBurn(uint256 _value) external {
        _burn(msg.sender, _value);
    }
    function uRate() external view returns (uint256) {
        return totalSupply() > 0 && smart.balance > 0 ? smart.balance * 1e18 / totalSupply() : 1e18;
    }
    function uFind(uint64 _id) external view returns (address) {
        return idaddr[_id];
    }
    function uInfo(address _account) external view returns (uint256 Id, address Referrer, uint8 Levels, uint256 Amount) {
        return (addrid[_account], referrers[_account], levels[_account], balanceOf(_account));
    }
}