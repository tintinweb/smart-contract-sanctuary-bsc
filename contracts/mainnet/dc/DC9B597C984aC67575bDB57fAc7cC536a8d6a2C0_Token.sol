/**
 *Submitted for verification at BscScan.com on 2023-02-12
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

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

contract Owner {
    address private _owner;

    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == _owner, "Caller is not owner");
        _;
    }

    constructor() {
        _owner = msg.sender;
        emit OwnerSet(address(0), _owner);
    }

    function changeOwner(address newOwner) public virtual onlyOwner {
        emit OwnerSet(_owner, newOwner);
        _owner = newOwner;
    }

    function removeOwner() public virtual onlyOwner {
        emit OwnerSet(_owner, address(0));
        _owner = address(0);
    }

    function getOwner() external view returns (address) {
        return _owner;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

abstract contract ERC20 is IERC20 {
    using SafeMath for uint256;

    string private _name;

    string private _symbol;

    uint8 private _decimals;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        uint8 tokenDecimals
    ) {
        _name = tokenName;
        _symbol = tokenSymbol;
        _decimals = tokenDecimals;
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

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(amount)
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(subtractedValue)
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);

        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        if (value > 0) {
            _totalSupply = _totalSupply.sub(value);
            _balances[account] = _balances[account].sub(value);
            emit Transfer(account, address(0), value);
        }
    }

    function _approve(
        address owner,
        address spender,
        uint256 value
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(
            account,
            msg.sender,
            _allowances[account][msg.sender].sub(amount)
        );
    }
}

contract Token is ERC20, Owner {
    using SafeMath for uint256;

    uint256 private _interestFee = 218;
    uint256 private _deflationFee = 1500;

    address private _backflowAddress =
        0x58cbc1032963eAd2AC174DCFb09B7934243470E0;
    address private _bonusAddress = 0xA29899666c253DbD28C2eA7F5395fc09E0112998;
    address private _appointAddress =
        0x843A7F4875fBc8d6f0b1E80C381095B60167a9e3;
    address private _fundAddress = 0xA7237cC3150c802D8812Fa8A83d71c374CC32c60;
    address private _nftAddress = 0xBA84608d1CAF94d8b6642C4EA11b2DEC899299e8;
    address private _deflationAddress =
        0x3A5445a73C260bA0C95C2a3Ef40CD09422B0c39a;

    mapping(address => bool) private _whiteList;
    mapping(address => bool) private _blackList;

    mapping(address => bool) private _registerList;
    mapping(address => address) private _teamList;

    constructor() ERC20("SFTeam001", "SFT001", 18) {
        uint256 _totalSupply_ = 30000000 * (10**uint256(decimals()));

        address recipient = 0x7ea015E886f52fF8b6f5A38675BD922ed266A623;

        _mint(recipient, _totalSupply_);

        _registerList[recipient] = true;
        _registerList[_backflowAddress] = true;
        _registerList[_bonusAddress] = true;
        _registerList[_appointAddress] = true;
        _registerList[_fundAddress] = true;
        _registerList[_nftAddress] = true;
        _registerList[_deflationAddress] = true;

        _whiteList[recipient] = true;
        _whiteList[0x9eFE9Ed215E290f98d1eAcE47C7FE35254fb2739] = true;
        _whiteList[0xE5f5231E9C504cF563831626816eA27886Ac7E0E] = true;
        _whiteList[0x6925DcB4888cA8F63B2aF535f83049005A911705] = true;
        _whiteList[0xc9bA1ca66608e8E54aFE843149a41a343Ab81313] = true;
        _whiteList[0xb6d087d90cd28942Dc1dfD32b7b0CD05018297e3] = true;
        _whiteList[0x728a021C262aB4C74bCcF90Ca6F661AeAC539ec5] = true;
        _whiteList[0xBc960B65b8Fb7c30106cdEDBfBa5a5B1995e1508] = true;
        _whiteList[0xb73a2F9ebc00Dc91a84FF49Ee911d8dDC23d0deE] = true;
        _whiteList[0xC2a0D1F373f734Edb06b503548546371856Ab308] = true;
        _whiteList[0x07E78b6A754A11240D1C82B28EC61787A8A7170c] = true;
    }

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function getInterestFee() public view returns (uint256) {
        return _interestFee;
    }

    function getDeflationFee() public view returns (uint256) {
        return _deflationFee;
    }

    function getWhiteList(address account) public view returns (bool) {
        return _whiteList[account];
    }

    function getBlackList(address account) public view returns (bool) {
        return _blackList[account];
    }

    function getRegisterList(address account) public view returns (bool) {
        return _registerList[account];
    }

    function getTeamList(address account) public view returns (address) {
        return _teamList[account];
    }

    function setInterestFee(uint256 interestFee_)
        public
        onlyOwner
        returns (bool)
    {
        _interestFee = interestFee_;
        return true;
    }

    function setDeflationFee(uint256 deflationFee_)
        public
        onlyOwner
        returns (bool)
    {
        _deflationFee = deflationFee_;
        return true;
    }

    function setWhiteList(address account, bool yesOrNo)
        public
        onlyOwner
        returns (bool)
    {
        _whiteList[account] = yesOrNo;
        return true;
    }

    function setBlackList(address account, bool yesOrNo)
        public
        onlyOwner
        returns (bool)
    {
        _blackList[account] = yesOrNo;
        return true;
    }

    function setRegisterList(address account, bool yesOrNo)
        public
        onlyOwner
        returns (bool)
    {
        _registerList[account] = yesOrNo;
        return true;
    }

    function setTeam(address sender, address recipient)
        public
        onlyOwner
        returns (bool)
    {
        _setTeam(sender, recipient);
        return true;
    }

    function _setTeam(address sender, address recipient) internal {
        _registerList[recipient] = true;
        _teamList[recipient] = sender;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        super._transfer(sender, recipient, amount);

        if (
            _registerList[sender] == true &&
            _registerList[recipient] == false &&
            _blackList[sender] == false &&
            _blackList[recipient] == false &&
            isContract(recipient) == false
        ) {
            _setTeam(sender, recipient);
        }
    }
}