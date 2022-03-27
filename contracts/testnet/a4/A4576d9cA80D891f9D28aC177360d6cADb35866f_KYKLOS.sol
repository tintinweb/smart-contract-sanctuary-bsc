/**
 *Submitted for verification at BscScan.com on 2022-03-26
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.5;

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
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable {
    address internal owner;
    address private _previousOwner;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

/**
 * Pancakeswap standard Factory interface.
 */
interface PCSFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

/**
 * Pancakeswap standard Router interface.
 */
interface PCSv2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
}

contract KYKLOS is IBEP20, Ownable {

    address WBNB     = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address DEAD     = 0x000000000000000000000000000000000000dEaD;
    address ZERO     = 0x0000000000000000000000000000000000000000;
    
    address   public treasury       = 0x7bf44672FC94f4C089f37025e6B97d3305F17B02;

    string constant _name           = "Kyklos";
    string constant _symbol         = "KYK";
    string constant public ContractCreator = "@FrankFourier";
    uint8  constant _decimals       = 2;
    uint8   private  factor         = 2;
    uint256 _totalSupply            =  1 * 10**9 * 10**_decimals;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isIDORouter;
    mapping (address => bool) isSniper;


    uint256 public Fee                = 3;
    uint256 public feeDenominator     = 100;

    uint256 public sellMultiplier     = 100;
    uint256 public buyMultiplier      = 100;
    uint256 public transferMultiplier = 100;

    uint256 public swapThreshold            = _totalSupply / 1000;
    uint256 public swapTransactionThreshold = _totalSupply / 10000;

    uint256 public deadBlocks = 5;
    uint256 public launchedAt = 0;

    PCSv2Router public router;
    address public pair;

    bool    public launched;
    bool    public gasLimitActive = false;
    bool    public projectWalletsFounded;
    uint256 public gasPriceLimit = 20 gwei;

    constructor () Ownable(msg.sender) {
        router = PCSv2Router(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        pair   = PCSFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        isFeeExempt[msg.sender] = true;
        //isFeeExempt[address(this)] = true;
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
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - (amount);
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(sender != owner && recipient != owner && isIDORouter[sender] && isIDORouter[recipient]){
            require(launched,"Trading not open yet");
            
            if(gasLimitActive) {
                require(tx.gasprice <= gasPriceLimit,"Gas price exceeds limit");
            }
        }

        // Actual transfer
        _balances[sender] = _balances[sender] - amount;
        uint256 amountReceived = (isFeeExempt[sender] || isFeeExempt[recipient]) ? amount : takeFee(sender, amount, recipient);
        _balances[recipient] = _balances[recipient] + amountReceived;

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
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

        uint256 feeAmount = amount * Fee * multiplier / (feeDenominator * 100);

        if(sender == pair && (launchedAt + deadBlocks) >= block.number){
            feeAmount = amount / 100 * 99;
            isSniper[recipient] = true;
        } else if (isSniper[recipient] && isSniper[sender]){
        	    revert("Sniper detected!");
        	}

        _balances[address(this)] = _balances[address(this)] + feeAmount;
        emit Transfer(sender, address(this), feeAmount);
        return amount - feeAmount;
    }   

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer(amountBNB * amountPercentage / 100);
    }

    // launch
    function launch(uint256 _deadBlocks) public onlyOwner {
        require(launched == false);
        launched = true;
        launchedAt = block.number;
        deadBlocks = _deadBlocks;
    }

    function swapBack(uint256 amount) internal {
        uint256 amountToSwap = amount;

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

        uint256 amountBNB = address(this).balance - balanceBefore;
        (bool tmpSuccess,) = payable(treasury).call{value: amountBNB, gas: 30000}("");        
        tmpSuccess = false;
    }

    function _swapTokensForFees(uint256 amount) external onlyOwner{
        amount = getwithdecimals(amount);
        uint256 contractTokenBalance = balanceOf(address(this));
        require(contractTokenBalance >= amount);
        swapBack(amount);
    }

    function setMultipliers(uint256 _buy, uint256 _sell, uint256 _trans) external onlyOwner {
        require(_buy <= 300, "Fees too high");
        require(_sell <= 300, "Fees too high");
        require(_trans <= 300, "Fees too high");
        sellMultiplier = _sell;
        buyMultiplier = _buy;
        transferMultiplier = _trans;
    }

    function setGasPriceLimit(uint256 gas) external onlyOwner {
        require(gas >= 20 gwei);
        gasPriceLimit = gas * 1 gwei;
    }

    function setgasLimitActive(bool antiGas) external onlyOwner {
        gasLimitActive = antiGas;
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function setisIDORouter(address IDOrouter, bool exempt) external onlyOwner {
        isIDORouter[IDOrouter] = exempt;
        isFeeExempt[IDOrouter] = exempt;
    }

    function setFee(uint256 _Fee) external onlyOwner {
        Fee = _Fee;
        require(Fee <= 10, "Fees cannot be more than 30%");
    }

    function setFeeReceiver(address _treasury) external onlyOwner {
        treasury = _treasury;
    }

    function setSwapBackSettings(uint256 _amount, uint256 _transaction) external onlyOwner {
        _amount = getwithdecimals(_amount);
        require(_amount <= _totalSupply);
        swapThreshold = _amount;
        swapTransactionThreshold = _transaction;
    }

    function is_ExcludedFromFee(address account) public view returns(bool) {
        return isFeeExempt[account];
    }
    
    function is_IDORouter(address IDOrouter) public view returns(bool) {
        return isIDORouter[IDOrouter];
    }

    function rescueToken(address token, address to) external onlyOwner {
        require(address(this) != token);
        IBEP20(token).transfer(to, IBEP20(token).balanceOf(address(this))); 
    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply - balanceOf(DEAD) - balanceOf(ZERO);
    }

    function getwithdecimals(uint256 input) public view returns(uint256) {
        return factor * input;
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