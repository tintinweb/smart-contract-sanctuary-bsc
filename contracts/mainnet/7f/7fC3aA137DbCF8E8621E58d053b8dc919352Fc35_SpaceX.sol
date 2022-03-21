/**
 *Submitted for verification at BscScan.com on 2022-03-21
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

/**
 * Standard SafeMath, stripped down to just add/sub/mul/div
 */
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

/**
 * BEP20 standard interface.
 */
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

/**
 * Allows for contract ownership along with multi-address authorization
 */
abstract contract Auth {
    address internal owner;
    mapping(address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED");
        _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IPair {
    function sync() external;
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

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;

    function setShare(address shareholder, uint256 amount) external;

    function deposit(uint256 amount) external payable;

    function process(uint256 gas) external;
}

contract SpaceX is IBEP20, Auth {
    using SafeMath for uint256;

    address public DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address public USDT;

    string constant _name = "SpaceX Token";
    string constant _symbol = "SpaceX";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 210000 * (10 ** _decimals);

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    mapping(address => bool) isFeeExempt;
    mapping(address => uint256) public userLastTime;

    uint256 nodeFee = 15;
    uint256 marketingFee = 15;
    uint256 totalFee = 30;
    uint256 feeDenominator = 1000;

    address public nodeReceiver;
    address public marketingFeeReceiver;

    IDEXRouter public router;
    address public pair;

    IDividendDistributor public distributor;
    uint256 distributorGas = 500000;

    constructor (address _distributor) Auth(msg.sender) {
        //mainnet
               router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
               USDT = 0x55d398326f99059fF775485246999027B3197955;
        //testnet
        // router = IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        // USDT = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;

        pair = IDEXFactory(router.factory()).createPair(address(this), USDT);
        _allowances[address(this)][address(router)] = type(uint256).max;

        distributor = IDividendDistributor(_distributor);

        address _presaler = msg.sender;
        isFeeExempt[_presaler] = true;
        isFeeExempt[_distributor] = true;

        marketingFeeReceiver = pair;
        nodeReceiver = _distributor;

        _balances[_presaler] = _totalSupply;
        emit Transfer(address(0), _presaler, _totalSupply);
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

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }


    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        userLastTime[sender] = block.timestamp;
        if (!shouldTakeFee(recipient)) {return _basicTransfer(sender, recipient, amount);}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        try distributor.process(distributorGas) {} catch {}

        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function getTotalFee(bool buying) public view returns (uint256) {
        if (buying) {
            return 0;
        }
        return totalFee;
    }


    function takeFee(address sender, address receiver, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(getTotalFee(sender == pair)).div(feeDenominator);
        if (feeAmount > 0) {
            uint256 nodeFeeAmount = amount.mul(nodeFee).div(feeDenominator);
            if (nodeFeeAmount > 0) {
                _balances[nodeReceiver] = _balances[nodeReceiver].add(nodeFeeAmount);
                emit Transfer(sender, nodeReceiver, nodeFeeAmount);
                try distributor.deposit(nodeFeeAmount) {} catch {}
            }
            uint256 marketFeeAmount = feeAmount.sub(nodeFeeAmount);
            if (marketFeeAmount > 0) {
                _balances[marketingFeeReceiver] = _balances[marketingFeeReceiver].add(marketFeeAmount);
                emit Transfer(sender, marketingFeeReceiver, marketFeeAmount);
                if (marketingFeeReceiver == pair) {
                    IPair(pair).sync();
                }
            }
        }
        return amount.sub(feeAmount);
    }


    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setFeeReceivers(address _nodeReceiver, address _marketingFeeReceiver) external authorized {
        nodeReceiver = _nodeReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
    }

    function updateDistributor(address _distributor) external authorized {
        distributor = IDividendDistributor(_distributor);
        isFeeExempt[_distributor] = true;
        nodeReceiver = _distributor;
    }

    function manualSend() external authorized {
        uint256 contractETHBalance = address(this).balance;
        payable(msg.sender).transfer(contractETHBalance);
    }


    function rescueToken(address token, address to) external authorized {
        IBEP20(token).transfer(to, IBEP20(token).balanceOf(address(this)));
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }
}