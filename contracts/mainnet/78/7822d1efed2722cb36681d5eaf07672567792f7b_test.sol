/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

/**

 Test

**/
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

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

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
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

/**
 * Allows for contract ownership without with multi-address authorization
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
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Transfer ownership to new address. Caller must be owner. 
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract test is IBEP20, Auth {
    using SafeMath for uint256;

    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "TEST";
    string constant _symbol = "TEST";
    uint8 constant _decimals = 9;

    uint256 _totalSupply = 50000000000000000;

    //max wallet holding of 5% supply
    uint256 public _maxWalletToken = (_totalSupply * 5) / 100;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    // diff pairs which will be taxed
    mapping(address => bool) pairs;
    mapping(address => bool) isFeeExempt;
    //whitelist presale ca to hold more than 3% 
    mapping(address => bool) isMaxWalletExempt;

    bool public feesOn = true;

    //buying fee
    uint256 public totalFee = 5;
    // selling fee
    uint256 public totalSellFee = 5;
    uint256 public totalTransferFee = 1;
    uint256 feeDenominator = 100;

    address public MarketingAndEventsFeeReceiver;
    address public NFTsPoolFeeReceiver;

    IDEXRouter public router;
    address public pair;

    uint256 public launchedAt;

    bool public swapEnabled = true;
    uint256 public swapThreshold = 125000000000000; 
    //burn is always less than swap threshold.
    uint256 public taxBurnAmount = 25000000000000; 

    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Auth(msg.sender) {
        launchedAt = block.timestamp;

        //Testnet: 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        //Mainet: 0x10ED43C718714eb63d5aA57B78B54704E256024E
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        MarketingAndEventsFeeReceiver = 0x75B6A84d9E943180e881D9Ce7d6519E50dc57046;
        NFTsPoolFeeReceiver = 0xD5a14b7585B3c286A6aB13378c64174537E44FD6;

        // exempted from tax
        isFeeExempt[msg.sender] = true;
        isFeeExempt[DEAD] = true;
        isFeeExempt[address(this)] = true;

        // exempted for max wallet
        isMaxWalletExempt[msg.sender] = true;
        isMaxWalletExempt[DEAD] = true;
        isMaxWalletExempt[address(this)] = true;
        isMaxWalletExempt[pair] = true;

        // add to pairs for taxes.
        pairs[pair] = true;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address holder, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 amount)
        public
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
        return _transferFrom(msg.sender, recipient, amount);
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
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        // max wallet code
        if (!isMaxWalletExempt[recipient]) {
            uint256 heldTokens = balanceOf(recipient);
            require(
                (heldTokens + amount) <= _maxWalletToken,
                "Max wallet reached."
            );
        }

        if (shouldSwapBack()) {
            swapBack();
            //burn extra tax
            uint256 taxUnsold = balanceOf(address(this));
            if (taxUnsold > taxBurnAmount) {
                _basicTransfer(address(this), DEAD, taxBurnAmount);
            }
        }

        //Exchange tokens
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );

        uint256 amountReceived = !isFeeExempt[sender] && feesOn
            ? takeFee(sender, amount, recipient)
            : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);

        emit Transfer(sender, recipient, amountReceived);
        return true;
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

    function takeFee(
        address sender,
        uint256 amount,
        address recipient
    ) internal returns (uint256) {
        uint256 feeAmount;
        //buying
        if (pairs[sender]) {
            feeAmount = amount.mul(totalFee).div(feeDenominator);
        }
        //selling
        else if (pairs[recipient]) {
            feeAmount = amount.mul(totalSellFee).div(feeDenominator);
        }
        // transfer 1% tax
        else {
            feeAmount = amount.mul(totalTransferFee).div(feeDenominator);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    /**
     * Only swaps back if these conditions are met, during sells and when the
     * threshold is reached or when the time has reached for the swap.
     */
    function shouldSwapBack() internal view returns (bool) {
        return
            msg.sender != pair &&
            !inSwap &&
            swapEnabled &&
            _balances[address(this)] >= swapThreshold.mul(2);
    }

    /**
     * Swaps the tax collected for fees sent to MarketingAndEvents and NFTsPool. The swap only swaps the threshold amount.
     */
    function swapBack() internal swapping {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            swapThreshold,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amountBNB = address(this).balance;
        (bool tmpSuccess, ) = payable(MarketingAndEventsFeeReceiver).call{
            value: amountBNB.div(2)
        }("");
        (bool tmpSuccess2, ) = payable(NFTsPoolFeeReceiver).call{
            value: address(this).balance
        }("");
        require(tmpSuccess, "MarketingAndEvents not sent.");
        require(tmpSuccess2, "NFTsPool not sent.");
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function setIsMaxWalletExempt(address holder, bool exempt)
        external
        onlyOwner
    {
        isMaxWalletExempt[holder] = exempt;
    }

    /**
     * Sets the amount of tokens collected from taxes to be swapped for BNB and the amount of overflowing collected amount to be burned  
     */
    function setSwapBackSettings(
        bool _enabled,
        uint256 _amount,
        uint256 _taxBurnAmount
    ) external onlyOwner {
        require(
            _amount > _taxBurnAmount,
            "Swap threshold must be more than amount burned"
        );
        swapEnabled = _enabled;
        swapThreshold = _amount * 10**9;
        taxBurnAmount = _taxBurnAmount * 10**9;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function setMaxWalletPercent(uint256 percent) external onlyOwner {
        //Hardcoded safety measures
        require(percent > 1, "Max wallet can only be more than 1%");
        _maxWalletToken = _totalSupply.mul(percent).div(100);
    }

    function setFeesOn(bool _feesOn) external onlyOwner {
        feesOn = _feesOn;
    }

    function setFeeReceivers(address MarketingAndEventsTax, address NFTsPoolTax) external onlyOwner {
        MarketingAndEventsFeeReceiver = MarketingAndEventsTax;
        NFTsPoolFeeReceiver = NFTsPoolTax;
    }

    function setFees(
        uint256 _totalFee,
        uint256 _totalSellFee,
        uint256 _totalTransferFee
    ) external onlyOwner {
        require(_totalFee <= 5 && _totalSellFee <= 5 && _totalTransferFee <= 1);
        totalFee = _totalFee;
        totalSellFee = _totalSellFee;
        totalTransferFee = _totalTransferFee;
    }

    
}