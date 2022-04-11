/**
 *Submitted for verification at BscScan.com on 2022-04-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-31
*/

/**
 * Anji is about building an ecosystem of altruistic defi applications to enable a decentralised digital economy that leaves the earth in a better way than we found it.
 *
 * Web: https://anji.eco
 * Telegram: https://t.me/anjieco
 * Twitter: https://twitter.com/anji_eco
 *
 *                 _ _   ______                        _
 *     /\         (_|_) |  ____|                      | |
 *    /  \   _ __  _ _  | |__   ___ ___  ___ _   _ ___| |_ ___ _ __ ___
 *   / /\ \ | '_ \| | | |  __| / __/ _ \/ __| | | / __| __/ _ \ '_ ` _ \
 *  / ____ \| | | | | | | |___| (_| (_) \__ \ |_| \__ \ ||  __/ | | | | |
 * /_/    \_\_| |_| |_| |______\___\___/|___/\__, |___/\__\___|_| |_| |_|
 *               _/ |                         __/ |
 *              |__/                         |___/
 */

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() external virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

interface BambooStaking {
    function rewardDeposited(uint256 amount) external;
}

contract Bamboo is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "Bamboo";
    string constant _symbol = "BMBO";
    uint8 constant _decimals = 9;

    uint256 constant _totalSupply = 1000000 * 10**9 * 10**9; // 1 Quadrillion

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isRestricted;

    uint256 burnFee = 200;
    uint256 charityFee = 200;
    uint256 liquidityFee = 200;
    uint256 marketingFee = 200;
    uint256 stakingFee = 200;

    uint256 constant feeDenominator = 10000;

    address public autoLiquidityReceiver;
    address public charityFeeReceiver;
    address public marketingFeeReceiver;
    address public stakingFeeReceiver;

    IDEXRouter public router;
    address pancakeV2BNBPair;
    address[] public pairs;

    bool public autoLiquifyEnabled = false;
    bool public autoStakeContract = false;
    bool public feesOnNormalTransfers = true;

    bool inSwap;
    modifier swapping { inSwap = true; _; inSwap = false; }
    uint256 public autoLiquifyThreshold = 100 * 10 ** _decimals;

    event AutoLiquify(uint256 amountBNB, uint256 amountToken);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event FeesUpdated(uint256 indexed newBurnFee, uint256 indexed newCharityFee, uint256 newLiquidityFee, uint256 newMarketingFee, uint256 newStakingFee);
    event RecoveredExcess(uint256 amount);
    event UpdateCharityAddress(address indexed newAddr, address indexed oldAddr);
    event UpdateLiquidityAddress(address indexed newAddr, address indexed oldAddr);
    event UpdateAutoLiquifyEnabled(bool enabled);
    event UpdateFeesOnNormalTransfer(bool enabled);
    event UpdateMarketingAddress(address indexed newAddr, address indexed oldAddr);
    event UpdateStakingAddress(address indexed newAddr, address indexed oldAddr, bool stakingContract);

    constructor() {
        address ownerAddr = msg.sender;

        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pancakeV2BNBPair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
        _allowances[address(this)][address(router)] = ~uint256(0);

        pairs.push(pancakeV2BNBPair);

        isFeeExempt[ownerAddr] = true;
        isFeeExempt[address(this)] = true;

        charityFeeReceiver = ownerAddr;
        marketingFeeReceiver = ownerAddr;
        autoLiquidityReceiver = ownerAddr;
        stakingFeeReceiver = ownerAddr;

        _balances[ownerAddr] = _totalSupply;
        emit Transfer(address(0), ownerAddr, _totalSupply);
    }

    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function name() external pure override returns (string memory) { return _name; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function totalSupply() external pure override returns (uint256) { return _totalSupply; }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, ~uint256(0));
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != ~uint256(0)){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(!isRestricted[recipient], "Address is restricted");

        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(shouldAutoLiquify()) { autoLiquify(); }

        require(_balances[sender].sub(amount) >= 0, "Insufficient Balance");
        _balances[sender] = _balances[sender].sub(amount);

        if (shouldTakeFee(sender, recipient)) {
            uint256 burnAmount = amount.mul(burnFee).div(feeDenominator);
            uint256 charityAmount = amount.mul(charityFee).div(feeDenominator);
            uint256 liquidityAmount = amount.mul(liquidityFee).div(feeDenominator);
            uint256 marketingAmount = amount.mul(marketingFee).div(feeDenominator);
            uint256 stakingAmount = amount.mul(stakingFee).div(feeDenominator);

            uint256 totalStoreAmount = charityAmount + liquidityAmount + marketingAmount; // Total token fee
            uint256 totalTaxAmount = burnAmount + stakingAmount + totalStoreAmount; // Total amount of tax

            _balances[address(this)] = _balances[address(this)] + totalStoreAmount; // Store tax fees within itself
            emit Transfer(sender, address(this), totalStoreAmount);

            _balances[DEAD] = _balances[DEAD].add(burnAmount); // Send the Burn fee to the DEAD wallet
            emit Transfer(sender, DEAD, burnAmount);

            _balances[stakingFeeReceiver] = _balances[stakingFeeReceiver].add(stakingAmount); // Send the Stake fee to Stake contract
            if (autoStakeContract) {
                BambooStaking(stakingFeeReceiver).rewardDeposited(stakingAmount);
            }
            emit Transfer(sender, stakingFeeReceiver, stakingAmount);

            uint256 amountReceived = amount - totalTaxAmount;
            _balances[recipient] = _balances[recipient].add(amountReceived);
            emit Transfer(sender, recipient, amountReceived);
        } else {
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }

        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(balanceOf(sender).sub(amount) >= 0, "Insufficient Balance");
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        if (isFeeExempt[sender] || isFeeExempt[recipient]) return false;

        address[] memory liqPairs = pairs;

        for (uint256 i = 0; i < liqPairs.length; i++) {
            if (sender == liqPairs[i] || recipient == liqPairs[i]) return true;
        }

        return feesOnNormalTransfers;
    }

    function shouldAutoLiquify() internal view returns (bool) {
        return msg.sender != pancakeV2BNBPair
        && !inSwap
        && autoLiquifyEnabled
        && _balances[address(this)] >= autoLiquifyThreshold;
    }

    function liquify() external onlyOwner {
        autoLiquify();
    }

    function autoLiquify() internal swapping {
        uint256 balanceBefore = address(this).balance;

        uint256 totalAmount = _balances[address(this)];
        uint256 denom = charityFee + liquidityFee + marketingFee;

        uint256 charitySwap = totalAmount.mul(charityFee).div(denom);
        uint256 liquiditySwap = totalAmount.mul(liquidityFee).div(denom);
        uint256 marketingSwap = totalAmount.mul(marketingFee).div(denom);

        uint256 amountToLiquify = liquiditySwap.div(2);

        uint256 amountToSwap = charitySwap + amountToLiquify + marketingSwap;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), amountToSwap);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 swapedBNBAmount = address(this).balance.sub(balanceBefore);

        if (swapedBNBAmount > 0) {
            uint256 bnbDenom =  charityFee + marketingFee + liquidityFee.div(2);

            uint256 bnbSwapMarketingAmount = swapedBNBAmount.mul(marketingFee).div(bnbDenom); // BNB for Marketing
            uint256 bnbSwapCharityAmount = swapedBNBAmount.mul(charityFee).div(bnbDenom); // BNB for Charity
            uint256 bnbLiquidify = swapedBNBAmount.mul(liquidityFee.div(2)).div(bnbDenom); // BNB for Liqudity

            if (bnbSwapMarketingAmount > 0) {
                // Send BNB for Marketing
                payable(marketingFeeReceiver).transfer(bnbSwapMarketingAmount);
            }

            if (bnbSwapCharityAmount > 0) {
                // Send BNB for Charity
                payable(charityFeeReceiver).transfer(bnbSwapCharityAmount);
            }

            if (bnbLiquidify > 0){
                _approve(address(this), address(router), amountToLiquify);
                router.addLiquidityETH{ value: bnbLiquidify }(
                    address(this),
                    amountToLiquify,
                    0,
                    0,
                    autoLiquidityReceiver,
                    block.timestamp
                );
            }
        }
    }

    function BNBbalance() external view returns (uint256) {
        return address(this).balance;
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;

        emit ExcludeFromFees(holder, exempt);
    }

    function setFees(
        uint256 _burnFee,
        uint256 _charityFee,
        uint256 _liquidityFee,
        uint256 _marketingFee,
        uint256 _stakingFee
    ) external onlyOwner {
        burnFee = _burnFee;
        charityFee = _charityFee;
        liquidityFee = _liquidityFee;
        marketingFee = _marketingFee;
        stakingFee = _stakingFee;

        emit FeesUpdated(burnFee, charityFee, liquidityFee, marketingFee, stakingFee);
    }

    function setAutoLiquifyThreshold(uint256 threshold) external onlyOwner {
        autoLiquifyThreshold = threshold;
    }

    function setAutoLiquifyEnabled(bool _enabled) external onlyOwner {
        autoLiquifyEnabled = _enabled;
        emit UpdateAutoLiquifyEnabled(_enabled);
    }

    function setCharityFeeReceiver(address _receiver) external onlyOwner {
        address oldAddr = charityFeeReceiver;
        charityFeeReceiver = _receiver;

        isFeeExempt[_receiver] = true;

        emit UpdateCharityAddress(oldAddr, _receiver);
    }

    function setLiquidityFeeReceiver(address _receiver) external onlyOwner {
        address oldAddr = autoLiquidityReceiver;
        autoLiquidityReceiver = _receiver;

        isFeeExempt[_receiver] = true;

        emit UpdateLiquidityAddress(oldAddr, _receiver);
    }

    function setMarketingFeeReceiver(address _receiver) external onlyOwner {
        address oldAddr = marketingFeeReceiver;
        marketingFeeReceiver = _receiver;

        isFeeExempt[_receiver] = true;

        emit UpdateMarketingAddress(oldAddr, _receiver);
    }

    function setStakingFeeReceiver(address _receiver, bool _autoStakeContract) external onlyOwner {
        address oldAddr = stakingFeeReceiver;
        stakingFeeReceiver = _receiver;

        isFeeExempt[_receiver] = true;

        emit UpdateStakingAddress(oldAddr, _receiver, _autoStakeContract);
    }

    function getCirculatingSupply() external view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function addPair(address pair) external onlyOwner {
        pairs.push(pair);
    }

    function removeLastPair() external onlyOwner {
        pairs.pop();
    }

    function setFeesOnNormalTransfers(bool _enabled) external onlyOwner {
        feesOnNormalTransfers = _enabled;

        emit UpdateFeesOnNormalTransfer(_enabled);
    }

    function setisRestricted(address adr, bool restricted) external onlyOwner {
        isRestricted[adr] = restricted;
    }

    function totalFees() external view returns (uint256) {
        return burnFee.add(charityFee).add(liquidityFee).add(marketingFee).add(stakingFee).div(100);
    }

    function walletisRestricted(address adr) external view returns (bool) {
        return isRestricted[adr];
    }

    function walletIsTaxExempt(address adr) external view returns (bool) {
        return isFeeExempt[adr];
    }

    // only for recovering excess BNB in the contract, in times of miscalculation. Can only be sent to marketing wallet - ALWAYS CONFIRM BEFORE USE
    function recoverExcess(uint256 amount) external onlyOwner {
        require(amount < address(this).balance, "BMBO: Can not send more than contract balance");
        payable(marketingFeeReceiver).transfer(amount);
        emit RecoveredExcess(amount);
    }

    // only for recovering tokens that are NOT BMBO tokens sent in error by wallets
    function withdrawTokens(address tokenaddr) external onlyOwner {
        require(tokenaddr != address(this), 'This is for tokens sent to the contract by mistake');
        uint256 tokenBal = IBEP20(tokenaddr).balanceOf(address(this));
        if (tokenBal > 0) {
            IBEP20(tokenaddr).transfer(marketingFeeReceiver, tokenBal);
        }
    }

    // for one-time airdrop feature after contract launch
    function airdropToWallets(address[] memory airdropWallets, uint256[] memory amount) external onlyOwner() {
        require(airdropWallets.length == amount.length, "BMBO: airdropToWallets:: Arrays must be the same length");

        for(uint256 i = 0; i < airdropWallets.length; i++){
            address wallet = airdropWallets[i];
            uint256 airdropAmount = amount[i];
            _transferFrom(msg.sender, wallet, airdropAmount);
        }
    }

    receive() external payable { }
}