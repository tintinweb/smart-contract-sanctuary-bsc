/**
 *Submitted for verification at BscScan.com on 2022-03-06
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.0 <0.9.0;

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
        require(b > 0, errorMessage);
        uint256 c = a / b;
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

interface NFTRarity {
    function walletOfOwner(address _owner) external view returns (uint256[] memory);
    function isRarity1(uint256 tokenid) external view returns (bool);
    function isRarity2(uint256 tokenid) external view returns (bool);
    function isRarity3(uint256 tokenid) external view returns (bool);
}


abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        require(adr != owner,"Cant remove owner");
        authorizations[adr] = false;
    }

    function isOwner(address account) internal view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface PCSFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface PCSv2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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

contract METAWHALES  is IBEP20, Auth {
    using SafeMath for uint256;

    address WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address NFT;

    string constant _name = "Metawhales";
    string constant _symbol = "MWHALE";
    string constant ContractCreator = "@FrankFourier";
    uint8 constant _decimals = 9;

    uint256 _totalSupply =  100 * 10**6 * 10**_decimals;

    uint256 public _maxTxAmount = _totalSupply / 100;
    uint256 public _maxWalletToken = _totalSupply / 50;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    bool public AntisniperMode = true;
    mapping (address => bool) public isSniper;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isMaxWalletExempt;

    uint256 public marketingFee     = 6;
    uint256 public teamFee          = 2;
    uint256 public devFee           = 1;
    uint256 public totalFee         = devFee + marketingFee + teamFee;
    uint256 public feeDenominator   = 100;

    uint256 public sellMultiplier = 200;
    uint256 public buyMultiplier = 100;
    uint256 public transferMultiplier = 100;

    uint256 public deadBlocks = 4;
    uint256 public launchedAt = 0;

    address public marketingFeeReceiver;
    address public teamFeeReceiver;
    address public devFeeReceiver;

    PCSv2Router public router;
    address public pair;

    bool public tradingOpen;
    bool public gasLimitActive = false;
    uint256 public gasPriceLimit = 75;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply / 1000;
    uint256 public swapTransactionThreshold = _totalSupply * 5 / 10000;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
        router = PCSv2Router(0x482eC5Bac2e048014187D245b2C8aaa49A6284a8);
        pair = PCSFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        marketingFeeReceiver = 0x5451998B2eaF9c7Bb3F36aBd6DE657100aECd38B;
        teamFeeReceiver = 0x5451998B2eaF9c7Bb3F36aBd6DE657100aECd38B;
        devFeeReceiver = 0x5451998B2eaF9c7Bb3F36aBd6DE657100aECd38B; 

        isFeeExempt[msg.sender] = true;

        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[DEAD] = true;
        isTxLimitExempt[ZERO] = true;

        isMaxWalletExempt[msg.sender] = true;
        isMaxWalletExempt[address(this)] = true;
        isMaxWalletExempt[DEAD] = true;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
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
        uint256 usrAllowance = _allowances[sender][msg.sender];
        if(usrAllowance != type(uint256).max ){
            usrAllowance = usrAllowance.sub(amount,"Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }

    function setMaxWallet(uint256 amount) external authorized {
        _maxWalletToken = amount;
    }

    function setMaxTx(uint256 amount) external authorized {
        _maxTxAmount = amount;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(!authorizations[sender] && !authorizations[recipient]){
            require(tradingOpen,"Trading not open yet");
            
            if(gasLimitActive) {
                require(tx.gasprice <= gasPriceLimit,"Gas price exceeds limit");
            }

            // Blacklist sniper
            if(AntisniperMode){
                require(!isSniper[sender] && !isSniper[recipient],"Blacklisted");    
            }
        }

        if (!authorizations[sender] && recipient != owner  && recipient != address(this) && sender != address(this) && recipient != address(DEAD) ){
            require(amount <= _maxTxAmount || isTxLimitExempt[sender],"TX Limit Exceeded");
            if(recipient != pair)
            require((amount + balanceOf(recipient)) <= _maxWalletToken || isMaxWalletExempt[recipient],"Max wallet holding reached");
        }

        // Swap
        if(sender != pair
            && !inSwap
            && swapEnabled
            && amount > swapTransactionThreshold
            && _balances[address(this)] >= swapThreshold) {
            swapBack();
        }

        // Actual transfer
        _balances[sender] = _balances[sender].sub(amount,"Insufficient Balance");
        
        uint256 amountReceived = (isFeeExempt[sender] || isFeeExempt[recipient]) ? amount : takeFee(sender, amount, recipient);
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

    function takeFee(address sender, uint256 amount, address recipient) internal returns (uint256) {

        uint256 multiplier = transferMultiplier;
        if(recipient == pair){
            multiplier = sellMultiplier;
        } else if(sender == pair){
            multiplier = buyMultiplier;
        }

        uint256 feeAmount = amount.mul(totalFee).mul(multiplier).div(feeDenominator * 100);


        if(sender == pair && (launchedAt + deadBlocks) > block.number){
            feeAmount = amount.div(100).mul(99);
        }

        if(totalFee == 10){
            uint256[] memory inventory = NFTRarity(NFT).walletOfOwner(msg.sender);
            for (uint256 i; i < inventory.length; ++i) {
               if (NFTRarity(NFT).isRarity1(inventory[i]) == true) {
                    feeAmount = amount.mul(6).mul(multiplier).div(feeDenominator * 100);
                } else if (NFTRarity(NFT).isRarity1(inventory[i]) == true) {
                    feeAmount = amount.mul(8).mul(multiplier).div(feeDenominator * 100);
                    }
            }
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }

    function clearStuckBalance(uint256 amountPercentage) external authorized {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer(amountBNB * amountPercentage / 100);
    }

    function set_sell_multiplier(uint256 Multiplier) external onlyOwner{
        sellMultiplier = Multiplier;        
    }

    // switch Trading
    function tradingStatus(bool _status, uint256 _deadBlocks) public onlyOwner {
        tradingOpen = _status;
        if(tradingOpen && launchedAt == 0){
            launchedAt = block.number;
            deadBlocks = _deadBlocks;
        }
    }

    function isContract(address _target) internal view returns (bool) {
        if (_target == address(0)) {
            return false;
        }

        uint256 size;
        assembly { size := extcodesize(_target) }
        return size > 0;
    }

    function swapBack() internal swapping {
        uint256 amountToSwap = swapThreshold;

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
        uint256 totalBNBFee = totalFee;
        
        uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(totalBNBFee);
        uint256 amountBNBdevFee = amountBNB.mul(devFee).div(totalBNBFee);
        uint256 amountBNBteam = amountBNB.mul(teamFee).div(totalBNBFee);

        (bool tmpSuccess,) = payable(marketingFeeReceiver).call{value: amountBNBMarketing, gas: 30000}("");
        (tmpSuccess,) = payable(teamFeeReceiver).call{value: amountBNBteam, gas: 30000}("");
        (tmpSuccess,) = payable(devFeeReceiver).call{value: amountBNBdevFee, gas: 30000}("");
        
        tmpSuccess = false;
    }

    function _swapTokensForFees(uint256 amount) external onlyOwner{
        uint256 contractTokenBalance = balanceOf(address(this));
        require(amount <= swapThreshold);
        require(contractTokenBalance >= amount);
        swapBack();
    }

    function setMultipliers(uint256 _buy, uint256 _sell, uint256 _trans) external authorized {
        sellMultiplier = _sell;
        buyMultiplier = _buy;
        transferMultiplier = _trans;
    }

    function enable_AntisniperMode(bool _status) public onlyOwner {
        AntisniperMode = _status;
    }

    function manage_snipers(address[] calldata addresses, bool status) public onlyOwner {
        require(addresses.length < 501,"GAS Error: max limit is 500 addresses");
        for (uint256 i; i < addresses.length; ++i) {
            isSniper[addresses[i]] = status;
        }
    }

    function setGasPriceLimit(uint256 gas) external onlyOwner {
        require(gas >= 75);
        gasPriceLimit = gas * 1 gwei;
    }

    function setgasLimitActive(bool antiGas) external onlyOwner {
        gasLimitActive = antiGas;
    }

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }

    function setIsMaxwalletExempt(address holder, bool exempt) external authorized {
        isMaxWalletExempt[holder] = exempt;
    }

    function setFees(uint256 _devFee, uint256 _marketingFee, uint256 _teamFee, uint256 _feeDenominator) external onlyOwner {
        devFee = _devFee;
        marketingFee = _marketingFee;
        teamFee = _teamFee;
        require(_devFee.add(_marketingFee).add(_teamFee) <= 30, "Fees cannot be more than 30%");
        totalFee = _devFee.add(_marketingFee).add(_teamFee);
        feeDenominator = _feeDenominator;
    }

    function setFeeReceivers(address _marketingFeeReceiver, address _teamFeeReceiver, address _devFeeReceiver) external onlyOwner {
        marketingFeeReceiver = _marketingFeeReceiver;
        teamFeeReceiver = _teamFeeReceiver;
        devFeeReceiver = _devFeeReceiver;
    }

    function setNFT(address _NFT) external onlyOwner {
        NFT = _NFT;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount, uint256 _transaction) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount;
        swapTransactionThreshold = _transaction;
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return isFeeExempt[account];
    }

    function isExcludedFromTxLimit(address account) public view returns(bool) {
        return isTxLimitExempt[account];
    }

    function isExcludedFromMaxWallet(address account) public view returns(bool) {
        return isMaxWalletExempt[account];
    }

    function rescueToken(address token, address to) external onlyOwner {
        require(address(this) != token);
        IBEP20(token).transfer(to, IBEP20(token).balanceOf(address(this))); 
    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function setRouterAddress(address newRouter) public onlyOwner() {
        router = PCSv2Router(newRouter);
        pair = PCSFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(newRouter)] = type(uint256).max;
    }

    /* Airdrop Begins */
    function multiTransfer(address from, address[] calldata addresses, uint256[] calldata tokens) external onlyOwner {

        require(addresses.length < 501,"GAS Error: max airdrop limit is 500 addresses");
        require(addresses.length == tokens.length,"Mismatch between Address and token count");

        uint256 SCCC = 0;

        for(uint i=0; i < addresses.length; i++){
            SCCC = SCCC + tokens[i];
        }

        require(balanceOf(from) >= SCCC, "Not enough tokens in wallet");

        for(uint i=0; i < addresses.length; i++){
            _basicTransfer(from,addresses[i],tokens[i]);
        }
    }
}