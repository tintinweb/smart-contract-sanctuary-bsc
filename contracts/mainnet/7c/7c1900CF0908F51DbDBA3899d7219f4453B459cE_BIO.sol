/**
 *Submitted for verification at BscScan.com on 2022-09-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
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

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
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

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

interface IPancakeFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IPancakeRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function waiveOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract BIO is Context, IERC20, IERC20Metadata, Ownable {
    using SafeMath for uint256;
    string private _name;
    string private _symbol;
    uint256 private _totalSupply;
    address public _pair;
    uint256 public finalSupply = 10**8 * 10**18;
    uint256 public startTime = 1666781526;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public isExcludedFromFee;

    address public immutable _dead = 0x000000000000000000000000000000000000dEaD;
    address public _routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public _usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public _admin;
    IPancakeRouter private _router;

    constructor() {
        _name = "BIO";
        _symbol = "BIO";
        _mint(owner(), 100 * 10**8 * 10**18);
        _router = IPancakeRouter(_routerAddress);
        _pair = IPancakeFactory(_router.factory()).createPair(
            address(_usdt),
            address(this)
        );

        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[address(this)] = true;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return (100 * 10**8 * 10**18);
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }

    function _mint(address account, uint256 amount) internal virtual {
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(uint256 amount) internal virtual returns (uint256) {
        if (_totalSupply < finalSupply) {
            return amount;
        }
        if (_totalSupply.sub(amount) <= finalSupply) {
            uint256 burnAmount = _totalSupply.sub(finalSupply);
            _totalSupply = _totalSupply.sub(burnAmount);
            _balances[_dead] = _balances[_dead].add(burnAmount);
            emit Transfer(address(0), _dead, burnAmount);
            return amount.sub(burnAmount);
        } else {
            _totalSupply = _totalSupply.sub(amount);
            _balances[_dead] = _balances[_dead].add(amount);
            emit Transfer(address(0), _dead, amount);
            return 0;
        }
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        if (isExcludedFromFee[sender] || isExcludedFromFee[recipient]) {
            _basicTransfer(sender, recipient, amount);
        } else {
            if (sender == _pair) {
                require(block.timestamp > startTime, "Not yet open");
                _basicTransfer(sender, recipient, amount);
            } else if (recipient == _pair) {
                uint256 senderBalance = _balances[sender];
                require(
                    senderBalance >= amount,
                    "ERC20: transfer amount exceeds balance1"
                );
                unchecked {
                    _balances[sender] = senderBalance.sub(amount);
                }
                uint256 share = amount.div(100);
                uint256 burnAmount = share.mul(8);
                uint256 noBurn = _burn(burnAmount);
                if (noBurn > 0) {
                    _balances[recipient] = _balances[recipient].add(
                        share.mul(92).add(noBurn)
                    );
                    emit Transfer(sender, recipient, share.mul(92).add(noBurn));
                } else {
                    _balances[recipient] = _balances[recipient].add(
                        share.mul(92)
                    );
                    emit Transfer(sender, recipient, share.mul(92));
                }
            } else {
                _basicTransfer(sender, recipient, amount);
            }
        }
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    modifier onlyAdmin() {
        require(
            msg.sender == _admin || msg.sender == owner(),
            "only called by admin"
        );
        _;
    }

    function setAdmin(address admin) public onlyOwner {
        _admin = admin;
    }

    function addIsExcludedFromFee(address[] memory users) public onlyOwner {
        for (uint8 i = 0; i < users.length; i++) {
            isExcludedFromFee[users[i]] = true;
        }
    }

    function delIsExcludedFromFee(address[] memory users) public onlyOwner {
        for (uint8 i = 0; i < users.length; i++) {
            isExcludedFromFee[users[i]] = false;
        }
    }

    function setStartTime(uint256 _startTime) public onlyOwner {
        startTime = _startTime;
    }

    function setPair(address pair) public onlyAdmin {
        _pair = pair;
    }

    function withdraw(
        address token,
        uint256 amount,
        address to
    ) public onlyAdmin {
        if (token == address(0)) {
            require(amount <= address(this).balance, "insufficient balance");
            payable(to).transfer(amount);
        } else {
            require(
                amount <= IERC20(token).balanceOf(address(this)),
                "insufficient balance"
            );
            IERC20(token).transfer(to, amount);
        }
    }
}