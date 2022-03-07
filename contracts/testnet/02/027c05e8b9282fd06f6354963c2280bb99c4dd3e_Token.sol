/**
 *Submitted for verification at BscScan.com on 2022-03-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
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

contract ERC20 is Context, IERC20, IERC20Metadata {
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

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
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

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
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
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
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
        require(b != 0);
        return a % b;
    }
}

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Token is ERC20, Ownable {
    using SafeMath for uint256;

    address public pair;

    uint256 private constant INITIAL_SUPPLY = 100000000 ether;

    mapping(address => uint256) private _timestamps;

    //корректировка времени в соответсвии с ТЗ
    uint256 public timeDelay = 10 seconds;

    uint256 public percentages = 10;

    // 5%
    uint256 private TAX_FEE = 5000;

    uint256 public pool;

    //добавлена переменная для отсчёта времени с который стартует данный контракт
    uint256 public poolStartTime;

    uint256 public timeDelayPool = 10 seconds;

    constructor() ERC20("Dollar", "DLLR") {
        _mint(address(this), INITIAL_SUPPLY);

        poolStartTime = block.timestamp;
    }

    function transfer(address to, uint256 amount)
        public
        override
        returns (bool)
    {
        address owner = _msgSender();

        uint256 amountFee = (amount * TAX_FEE) / 100000;

        //Исключаем направление комиссии в пул при транзакции
        //pool = pool.add(amountFee);

        //данная строка кода остаётся. Отвечает за сжигание 5% от транзакции
        _burn(owner, amountFee);

        _timestamps[owner] = block.timestamp;
        _timestamps[to] = block.timestamp;

        _transfer(owner, to, amount - amountFee);
        return true;
    }

    function tokenTransferOwner(address to, uint256 amount)
        public
        onlyOwner
        returns (bool)
    {
        _transfer(address(this), to, amount);

        _timestamps[to] = block.timestamp;

        return true;
    }

    function claim() external returns (bool) {
        require(block.timestamp - _timestamps[msg.sender] >= timeDelay);

        // расчёт переменной для начисления кол-ва процентов в пул
        uint256 poolAdd = (block.timestamp.sub(poolStartTime)).div(
            timeDelayPool
        );
        // обновляем переменную для, того что-бы отсчитывать время с новой точки (для исключения дублирования начисления средств в пул)
        poolStartTime = block.timestamp;

        uint256 rewardCount = (block.timestamp.sub(_timestamps[msg.sender]))
            .div(timeDelay);

        // добавлена функция добавления в пул
        for (uint256 i = 1; i <= poolAdd; i++) {
            uint256 amount = getAmountPool();
            pool = pool.add(amount);
        }
        // функция require перенесена для возможности первоначального выполнения функции claim()
        require(pool > 0, "pool balance is 0 now");

        for (uint256 i = 1; i <= rewardCount; i++) {
            uint256 amount = getAmount(msg.sender);
            pool = pool.sub(amount);

            _mint(msg.sender, amount);
        }

        _timestamps[msg.sender] = block.timestamp;

        return true;
    }

    function getAmount(address _user) private view returns (uint256) {
        uint256 balance = balanceOf(_user);

        uint256 amount = (balance.mul(percentages)).div(100000);

        return amount;
    }

    // добавлена функция расчёта 0,01% от размера эмиссии токена
    function getAmountPool() private view returns (uint256) {
        uint256 totalSupply = totalSupply();

        uint256 amount = (totalSupply.mul(percentages)).div(100000);

        return amount;
    }

    function mint(address _to, uint256 _amount) public {
        _mint(_to, _amount);
    }

    function burn(address _from, uint256 _amount) public {
        _burn(_from, _amount);
    }

    function withdraw() external virtual onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
}

contract IDO is Token {
    //1 000 000 DLLR (токен) = 1 BNB
    uint256 public dllrForBnb = 1000000;
    //в сети BSC используем 18 decimals
    uint256 public bnb = 1 ether;
    uint256 public idoStatus;
    //определяем курс DLLR
    uint256 public jagerForDllr = bnb / dllrForBnb; //1000000000000
    //console.log(jagerForDllr);
    uint256 public idoPool;
    uint256 private startTime;

    Token public token;

    event HashTeg(string hashTeg);

    constructor(address payable _token) {
        token = Token(_token);
        uint256 totalSupply = totalSupply();
        //10% от totalSupply создаём на этом адресе
        idoPool = (totalSupply * 10) / 100;
        token.mint(address(this), idoPool);
        token.burn(_token, idoPool);
        startTime = block.timestamp;
    }

    modifier idoStatusModifier() {
        require(idoStatus == 1, "IDO isn't active");
        _;
    }

    function startIDO() public {
        require(idoStatus == 0, "IDO started or is over");
        idoStatus = 1;
    }

    function buy(uint256 _amount)
        public
        payable
        idoStatusModifier
        returns (string memory)
    {
        uint256 requireBnb = _amount * jagerForDllr;

        address buyer = msg.sender;
        //проверка наличия баланса более чем запрашивая сумма токенов в эквиваленте bnb
        require(buyer.balance > requireBnb, "balance is not enought");
        //проверка на предмет, того что покупатель вводит верный баланс
        require(requireBnb <= msg.value, "Type right amount of BNB");
        //проверка наличия средств в пуле необходимом кол-ве
        require(_amount < idoPool, "tokens in the pool isn't enough");
        token.transfer(buyer, _amount);
        idoPool -= _amount;
        emit HashTeg("#from_ido");

        return "#from_ido";
    }

    function withdraw() external override onlyOwner {
        require(
            (block.timestamp - startTime) > 24 hours,
            "you can withdraw only after 24 hour"
        );
        payable(msg.sender).transfer(address(this).balance);
        startTime = block.timestamp;
    }

    function endIDO() public {
        require(idoStatus == 1, "IDO isn't started or it's over");
        idoStatus = 2;
        token.burn(address(this), idoPool);
    }
}