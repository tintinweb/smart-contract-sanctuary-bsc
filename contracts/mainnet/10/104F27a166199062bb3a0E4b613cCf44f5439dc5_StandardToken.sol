/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    mapping(address => bool) private _administratorList;

    event LogOwnerChanged(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
        _administratorList[_msgSender()] = true;
    }

    modifier onlyOwner() {
        require(Owner() == _msgSender(), "!owner");
        _;
    }

    modifier onlyAdmin() {
        require(isAdministrator(), "!administrator");
        _;
    }

    function isAdministrator() public view virtual returns (bool) {
        return _administratorList[_msgSender()];
    }

    function setAdministrator(address newAdmin, bool _status)
        public
        virtual
        onlyOwner
    {
        _administratorList[newAdmin] = _status;
    }

    function Owner() public view virtual returns (address) {
        return _owner;
    }

    function isOwner() public view virtual returns (bool) {
        return Owner() == _msgSender();
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "!address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit LogOwnerChanged(oldOwner, newOwner);
    }
}

abstract contract WhiteList is Ownable {
    mapping(address => bool) private _whiteList;
    mapping(address => bool) private _blackList;

    constructor() {}

    event LogWhiteListChanged(address indexed _user, bool _status);
    event LogBlackListChanged(address indexed _user, bool _status);

    modifier onlyWhiteList() {
        require(_whiteList[_msgSender()], "White list");
        _;
    }

    function isWhiteListed(address _maker) public view returns (bool) {
        return _whiteList[_maker];
    }

    function setWhiteList(address _evilUser, bool _status)
        public
        virtual
        onlyAdmin
        returns (bool)
    {
        _whiteList[_evilUser] = _status;
        emit LogWhiteListChanged(_evilUser, _status);
        return _whiteList[_evilUser];
    }

    function isBlackListed(address _maker) public view returns (bool) {
        return _blackList[_maker];
    }

    function setBlackList(address _evilUser, bool _status)
        public
        virtual
        onlyAdmin
        returns (bool)
    {
        _blackList[_evilUser] = _status;
        emit LogBlackListChanged(_evilUser, _status);
        return _blackList[_evilUser];
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
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

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: transfer amount exceeds allowance"
            );
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "!from");
        require(recipient != address(0), "!to");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
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
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _destroy(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: destroy from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(
            accountBalance >= amount,
            "ERC20: destroy amount exceeds balance"
        );
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _balances[address(0)] += amount;

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

interface SupportAssist {
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) external returns (uint256);

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 fromtype,
        uint256 amount,
        uint256 actual,
        uint256 fee
    ) external returns (uint256);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
}

contract StandardToken is ERC20, WhiteList {
    address public immutable uniswapV2Pair;
    IUniswapV2Router02 public immutable uniswapV2Router;

    uint64[4] public feeRatio = [30, 0, 30, 0];
    uint256 public startTradeTime = 0;
    uint256 public maxTradeAmount = 9999;

    SupportAssist public assist;

    mapping(address => bool) private _isUniswapV2Pair;
    mapping(address => bool) private _isExcludedFromFees;

    constructor(
        address _owners,
        uint256 _amount,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol, 18) {
        _mint(_owners, _amount * 10**decimals());

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        address swapPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(
                address(this),
                address(0x55d398326f99059fF775485246999027B3197955)
            );
        uniswapV2Pair = swapPair;
        uniswapV2Router = _uniswapV2Router;
        setUniswapV2Pair(swapPair, true);

        excludeFromFees(_owners, true);
        assist = SupportAssist(address(this));
        startTradeTime = block.timestamp;
    }

    receive() external payable {}

    function setStartTime(uint256 _start) external onlyAdmin {
        require(startTradeTime != _start, "Token: Repeat Setting");
        startTradeTime = _start;
    }

    function setAssist(address _assist) external onlyAdmin {
        require(address(assist) != _assist, "Token: Repeat Setting");
        assist = SupportAssist(_assist);
        excludeFromFees(_assist, true);
    }

    function excludeFromFees(address account, bool excluded) public onlyAdmin {
        require(
            _isExcludedFromFees[account] != excluded,
            "TOKEN: Account is already the value of 'excluded'"
        );
        _isExcludedFromFees[account] = excluded;
    }

    function isExcludeFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function setUniswapV2Pair(address account, bool pair) public onlyAdmin {
        require(
            _isUniswapV2Pair[account] != pair,
            "TOKEN: Account is already the value of 'pair'"
        );
        _isUniswapV2Pair[account] = pair;
    }

    function isUniswapV2Pair(address account) public view returns (bool) {
        return _isUniswapV2Pair[account];
    }

    function burn(uint256 amount) public {
        super._burn(_msgSender(), amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        require(
            _balances[sender] >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        uint256 actualAmount = amount;

        require(
            !isBlackListed(sender),
            "ERC20: transfer from the blacklist address"
        );

        if (address(assist) != address(this)) {
            assist._beforeTokenTransfer(sender, recipient, amount);
        }

        uint256 _fromtype = 0;
        uint256 _fee = 0;
        uint256 _ratio = 0;
        uint256 _bratio = 0;
        if (isUniswapV2Pair(sender)) {
            _fromtype = 1;
            _ratio = feeRatio[0];
            _bratio = feeRatio[1];
        } else if (isUniswapV2Pair(recipient)) {
            _fromtype = 2;
            _ratio = feeRatio[2];
            _bratio = feeRatio[3];
        }

        if (
            _isExcludedFromFees[sender] || _isExcludedFromFees[recipient]
        ) {} else {
            if (_fromtype > 0) {
                require(
                    startTradeTime > 0 && block.timestamp >= startTradeTime,
                    "!Time"
                );

                if (
                    (_balances[sender] * maxTradeAmount) / 10000 < actualAmount
                ) {
                    actualAmount = (_balances[sender] * maxTradeAmount) / 10000;
                }

                if (_ratio > 0) {
                    _fee = (amount * _ratio) / 1000;
                    super._transfer(sender, address(assist), _fee);
                    actualAmount -= _fee;
                }

                if (_bratio > 0) {
                    uint256 _bfee = (amount * _bratio) / 1000;
                    super._burn(sender, _bfee);
                    actualAmount -= _bfee;
                }
            }
        }
        super._transfer(sender, recipient, actualAmount);

        if (address(assist) != address(this)) {
            assist._afterTokenTransfer(
                sender,
                recipient,
                _fromtype,
                amount,
                actualAmount,
                _fee
            );
        }
    }

    function withdraw(
        address _token,
        address _to,
        uint256 _amount
    ) external onlyAdmin returns (uint256) {
        require(_to != address(0), "ERC20: transfer from the zero address");

        uint256 val = Math.min(
            _amount,
            IERC20(_token).balanceOf(address(this))
        );
        if (val > 0) {
            IERC20(_token).transfer(_to, val);
        }
        return val;
    }

    function withdrawBNB(address _to, uint256 _amount)
        external
        onlyAdmin
        returns (uint256)
    {
        require(_to != address(0), "ERC20: transfer from the zero address");

        uint256 val = Math.min(_amount, address(this).balance);
        if (val > 0) {
            payable(_to).transfer(val);
        }
        return val;
    }
}