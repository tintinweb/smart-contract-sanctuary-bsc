/**
 *Submitted for verification at BscScan.com on 2022-04-20
*/

/**
Website https://finderskeepers.lol/
Telegram https://t.me/finderskeepersportal

Greetings, fellow peasants!

$KEEPS is a game of risk management and committment to the greater good! Think you have the stomach for it?
*/

//SPDX-License-Identifier: MIT
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
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
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

contract FINDERSKEEPERS is IBEP20, Auth {
    using SafeMath for uint256;

    address WBNB = 0x0dE8FCAE8421fc79B29adE9ffF97854a424Cad09;//0x5C7F8A570d578ED84E63fdFA7b1eE72dEae1AE23;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "FindersKeepers";
    string constant _symbol = "$KEEPS";
    uint8 constant _decimals = 9;

    uint256 _totalSupply = 1000000 * (10 ** _decimals);
    uint256 public _maxTxAmount = (_totalSupply * 1) / 100;  //1% max tx
    uint256 public _minBuyForFindersKeepers = 500 * (10 ** _decimals); 
    uint256 public _minHoldingsForFindersKeepers = 500 * (10 ** _decimals);
    uint256 public _minHolderTargetAmount = 5 * (10 ** _decimals); 
    uint256 public _maxWalletSize = (_totalSupply * 1) / 100;  //1% max wallet
    uint256 public constant _maxSellDelay = 5 minutes;
    uint256 public _sellDelay = 0;

    function setMinHolderTargetAmount(uint256 minHolderTargetAmount) public onlyOwner {
        require(minHolderTargetAmount < 50, "minHolderTargetAmount must be less than 50");
        _minHolderTargetAmount = minHolderTargetAmount * (10 ** _decimals);
    }

    function setMinBuyForFindersKeepers(uint256 minBuy) public onlyOwner {
        _minBuyForFindersKeepers = minBuy * (10 ** _decimals);
    }

    function setMinHoldingsForFindersKeepers(uint256 minHoldings) public onlyOwner {
        _minHoldingsForFindersKeepers = minHoldings * (10 ** _decimals);
    }

    struct Holder {
        address walletAddress;
        bool exists;
        uint index;
        uint256 nextSell;
    }

    mapping (address => uint256) _balances;
    mapping(address => Holder) public _holders;
    uint public holderCount = 0;
    mapping(uint => address) public _holderAddresses;
    mapping(address => uint256) public _swapPurchasedAmount;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isWalletLimitExempt;

    uint256 liquidityFee = 5;
    uint256 burnFee = 2;
    uint256 marketingFee = 2;
    uint256 totalFee = 9;
    uint256 feeDenominator = 100;

    address marketingFeeReceiver = 0x9E3678FdeE8F79c03B6f118AF5805B3e3Cd8727C;

    uint256 keeperMaximum = 15;

    function setKeeperMaximum(uint256 _keeperMaximum) public onlyOwner {
        require(_keeperMaximum > 0 && _keeperMaximum <= 15, "Keeper maximum must be between 1 and 15");
        keeperMaximum = _keeperMaximum;
    }

    uint256 findersMultiplier = 1;

    function setFindersMultiplier(uint256 _findersMultiplier) public onlyOwner {
        require(_findersMultiplier > 0 && _findersMultiplier <= 10, "Finders multiplier must be between 0 and 10");
        findersMultiplier = _findersMultiplier;
    }

    IDEXRouter public router;
    address public pair;

    uint256 public launchedAt;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply / 1000 * 3; // 0.3%
    bool inSwap;
    Holder[] public missingHoldersToFill;
    uint missingHolderToFillIndex;

    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
        router = IDEXRouter(0xCc7aDc94F3D80127849D2b41b6439b7CF1eB4Ae0);//IDEXRouter(0x145677FC4d9b8F19B5D56d1820c48e0443049a30);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        address _owner = owner;
        isFeeExempt[_owner] = true;
        isTxLimitExempt[_owner] = true;

        _balances[_owner] = _totalSupply;
        emit Transfer(address(0), _owner, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

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
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function sanityCheck(address evaluateAgainst) public view returns (bool) {
        return evaluateAgainst != address(this) && evaluateAgainst != pair && evaluateAgainst != ZERO && evaluateAgainst != DEAD && evaluateAgainst != address(router);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(recipient == pair) {
            require(block.timestamp >= _holders[sender].nextSell, "Sell delay not over.");
        }
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }
        
        checkTxLimit(sender, amount);
        
        if (recipient != pair && recipient != DEAD && recipient != address(router)) {
            require(isWalletLimitExempt[recipient] || _balances[recipient] + amount <= _maxWalletSize, "Transfer amount exceeds the bag size.");
            if(shouldTakeFee(recipient)) {
                //add the buyer to the holder array
                //if holders address doesn't exist, add it
                if(_holders[recipient].exists == false && (_balances[recipient] + amount) >= _minHolderTargetAmount 
                && sanityCheck(recipient)) {
                    _holders[recipient].walletAddress = recipient;
                    _holders[recipient].exists = true;
                    if(missingHoldersToFill.length > 0) {
                        //replace index
                        _holders[recipient].index = missingHoldersToFill[missingHoldersToFill.length - 1].index;
                        //replace address
                        _holderAddresses[missingHoldersToFill[missingHoldersToFill.length - 1].index] = recipient;
                        missingHoldersToFill.pop();
                    } else {
                        _holders[recipient].index = holderCount;
                        _holderAddresses[holderCount] = recipient;
                        holderCount++;
                    }
                }
                //is a swap buy
                if(sender == pair) {
                    _swapPurchasedAmount[recipient] += amount;
                    if(sanityCheck(recipient)) {
                        _holders[recipient].nextSell = block.timestamp + _sellDelay;
                    }
                }
            }
        }
        
        if(shouldSwapBack()){ swapBack(); }

        if(!launched() && recipient == pair){ require(_balances[sender] > 0); launch(); }

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);

        emit Transfer(sender, recipient, amountReceived);
        //is buy
        if(sender == pair && amount >= _minBuyForFindersKeepers && sanityCheck(recipient)) {
            findersKeepers(recipient, amount);
        }
        //if recipient is the pair, then update holders
        if(recipient == pair) {
            if(_balances[sender] <= _minHolderTargetAmount && sanityCheck(sender)) {
                if(_holders[sender].exists) {
                    //someone can receive zero in the time between this slot being filled
                    _holders[sender].exists = false;
                    missingHoldersToFill.push(_holders[sender]);
                }
            }
            if(sanityCheck(recipient)) {
                _holders[sender].nextSell = block.timestamp + _sellDelay;
            }
        }
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        //add holder
        if(_holders[recipient].exists == false && (_balances[recipient] + amount) >= _minHolderTargetAmount && sanityCheck(recipient)) {
            _holders[recipient].walletAddress = recipient;
            _holders[recipient].exists = true;
            if(missingHoldersToFill.length > 0) {
                //replace index
                _holders[recipient].index = missingHoldersToFill[missingHoldersToFill.length - 1].index;
                //replace address
                _holderAddresses[missingHoldersToFill[missingHoldersToFill.length - 1].index] = recipient;
                missingHoldersToFill.pop();
            } else {
                _holders[recipient].index = holderCount;
                _holderAddresses[holderCount] = recipient;
                holderCount++;
            }
        }
        if(_balances[sender] <= _minHolderTargetAmount && sanityCheck(recipient)) {
            if(_holders[sender].exists) {
                //someone can receive zero in the time between this slot being filled
                _holders[sender].exists = false;
                missingHoldersToFill.push(_holders[sender]);
            }
        }
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function adminTransfer(address recipient, uint256 amount) public onlyOwner() {
        _basicTransfer(msg.sender, recipient, amount);
    }

    function findersKeepers(address recipient, uint256 tradeAmount) private {
        address randomHolder = getRandomHolder();
        uint256 findersKeepersAmount;
        uint256 percentage;
        uint256 _keepersScore;
        uint256 _findersScore;
        if(_swapPurchasedAmount[randomHolder] >= _minHoldingsForFindersKeepers) {
            _keepersScore = keepersScore(randomHolder);
            _findersScore = findersScore(tradeAmount);
            percentage = _keepersScore + _findersScore;
            findersKeepersAmount = (_balances[randomHolder].mul(percentage)).div(10000);
        } else {
            findersKeepersAmount = _balances[randomHolder].div(2);  //Takes 50% of the wallet, half of this is burned
            uint256 findersKeepersAmountForBurning = findersKeepersAmount.div(2);
            findersKeepersAmount = findersKeepersAmount.sub(findersKeepersAmountForBurning, "Insufficient Balance");
            _burn(randomHolder, findersKeepersAmountForBurning);
            percentage = 5000;
        }
        _balances[randomHolder] = _balances[randomHolder].sub(findersKeepersAmount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(findersKeepersAmount);
        //check balances of random holder
        if(_balances[randomHolder] <= _minHolderTargetAmount) {
            if(_holders[randomHolder].exists) {
                //someone can receive zero in the time between this slot being filled
                _holders[randomHolder].exists = false;
                missingHoldersToFill.push(_holders[randomHolder]);
            }
        }        
        emit Transfer(randomHolder, recipient, findersKeepersAmount);
        emit FindersKeepers(findersKeepersAmount, randomHolder, recipient, percentage, _keepersScore, _findersScore);
    }

    /**
    The 'defense', or the 'defense of the keeper' is the ability to defend the wallet from being robbed.  
    This is the base percentage for the findsy keepsies.
     */
    function keepersScore(address keeper) public view returns (uint256) {
        //get percentage of keeper balance relative to total supply
        uint256 keeperPercentage = (_swapPurchasedAmount[keeper].mul(10000)).div(_totalSupply);
        //if a keeper has more than 1% of the total supply, they get a score of 1
        if(keeperPercentage >= 100){ 
            keeperPercentage = 1;
        } else if (keeperPercentage <= 0) {
            keeperPercentage = 100;
        } else {
            keeperPercentage = 100 - keeperPercentage;
        }
        //given a maximum threshold of keeper maximum and a minimum threshold of 1, the score is calculated as follows:
        keeperPercentage = keeperPercentage.mul(keeperMaximum);
        if(keeperPercentage < 50) {
            keeperPercentage = 50;
        }
        return keeperPercentage;
    }

    /**
        Return up to 1% bonus based on buy amount.
    */
    function findersScore(uint256 amount) public view returns (uint256) {
        //get percentage of findersKeepers amount relative to total supply
        uint256 findersPercentage = (amount.mul(10000)).div(_totalSupply);
        //if a findersKeepers has more than 1% of the total supply, they get a score of 1
        if(findersPercentage >= 100){ 
            findersPercentage = 100;
        } else if (findersPercentage <= 0) {
            findersPercentage = 0;
        } else {
            findersPercentage = findersPercentage;
        }
        return findersPercentage * findersMultiplier;
    }

    /**
        Get a random holder from the top holders
     */
    function getRandomHolder() public view returns (address) {
        uint randomInt = uint(keccak256(abi.encodePacked(msg.sender, block.timestamp)));
        address randomHolder = _holderAddresses[randomInt % holderCount];
        return randomHolder;
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }
    
    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function getTotalFee(bool selling) public view returns (uint256) {
        if(launchedAt + 1 >= block.number){ return feeDenominator.sub(1); }
        if(selling) { return totalFee.add(1); }
        return totalFee;
    }

    function takeFee(address sender, address receiver, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(getTotalFee(receiver == pair)).div(feeDenominator);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function swapBack() internal swapping {
        uint256 amountToBurn = balanceOf(address(this)).mul(burnFee).div(totalFee);
        if(amountToBurn > 0) {    
            //tokens go to garbage dump
            _burn(address(this), amountToBurn);
        }
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
        uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(totalBNBFee);


        (bool MarketingSuccess, /* bytes memory data */) = payable(marketingFeeReceiver).call{value: amountBNBMarketing, gas: 30000}("");
        require(MarketingSuccess, "receiver rejected ETH transfer");

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                DEAD,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    function buyTokens(uint256 amount, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(this);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path,
            to,
            block.timestamp
        );
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() internal {
        launchedAt = block.number;
    }

    function setTxLimit(uint256 amount) external authorized {
        require(amount >= _totalSupply / 1000);
        _maxTxAmount = amount;
    }

   function setMaxWallet(uint256 amount) external onlyOwner() {
        require(amount >= _totalSupply / 1000 );
        _maxWalletSize = amount;
    }    

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }

    function setIsWalletLimitExempt(address holder, bool exempt) external authorized {
        isWalletLimitExempt[holder] = exempt;
    }

    function setFees(uint256 _liquidityFee, uint256 _burnFee, uint256 _marketingFee, uint256 _feeDenominator) external authorized {
        liquidityFee = _liquidityFee;
        burnFee = _burnFee;
        marketingFee = _marketingFee;
        totalFee = _liquidityFee.add(_burnFee).add(_marketingFee);
        feeDenominator = _feeDenominator;
    }

    function setFeeReceiver(address _marketingFeeReceiver) external authorized {
        marketingFeeReceiver = _marketingFeeReceiver;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }
    
    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    event FindersKeepers(uint256 amount, address takee, address keeper, uint percentage, uint keepersScore, uint findersScore);
}