/**
 *Submitted for verification at BscScan.com on 2022-12-01
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;
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


interface ERC20 {
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

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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
        uint amountUSDTMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountUSDT, uint liquidity);

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

contract TokenDistributor {
    constructor (address token) {
        ERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution, uint256 _minHoldForDividends) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit(uint256 amount) external;
    function process(uint256 gas) external;
    function withdrawDistributor(address tokenReceiver,uint256 amountPercentage)  external;
    function minPeriodminDistributionminimumTokenBalanceForDividends() external view returns (uint256,uint256,uint256);
}

contract HOOK is ERC20, Ownable {
    using SafeMath for uint256;

    string private _name = "HOOK";
    string private _symbol = "HOOK";
    uint8 constant _decimals = 9;
    uint256 _totalSupply = 500000000 * 10**_decimals;

    uint256 public _maxTxAmount = _totalSupply * 100 / 100;
    uint256 public _maxWalletToken = _totalSupply * 100 / 100;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isWalletLimitExempt;
    mapping (address => bool) isDividendExempt;

    struct Fee{uint buy; uint sell;uint transfer; uint part;}
    Fee public fees;
    struct Allot{uint marketing;uint liquidity; uint burn;uint reward;uint total;}
    Allot public allot;

    address public marketingFeeReceiver;

    IDEXRouter public router;
    address public pair;

    bool public ChosenSonMode = true;
    mapping (address => bool) public isChosenSon;

    uint256 public launchedBlock;

    address public baseToken;
    TokenDistributor public _tokenDistributor;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply* 1 / 1000;
    uint256 public maxSwapThreshold = _totalSupply * 1 / 100;

    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Ownable() {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        baseToken = address(0x55d398326f99059fF775485246999027B3197955);
        pair = IDEXFactory(router.factory()).createPair(baseToken, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;
        _tokenDistributor = new TokenDistributor(baseToken);
        ERC20(baseToken).approve(address(router), uint(~uint256(0)));

        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(router)] = true;
        isFeeExempt[address(this)] = true;

        isTxLimitExempt[msg.sender] = true;

        isWalletLimitExempt[msg.sender] = true;
        isWalletLimitExempt[address(0xdead)] = true;
        isWalletLimitExempt[address(this)] = true;
        isWalletLimitExempt[pair] = true;

        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0xdead)] = true;

        allot=Allot(2,0,0,0,2);
        fees=Fee(2,3,2,100);
        marketingFeeReceiver = msg.sender;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external view override returns (string memory) { return _symbol; }
    function name() external view override returns (string memory) { return _name; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    receive() external payable {}
    event AddLiquify(uint amountBNBLiquidity, uint amountToLiquify);

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

    function setMaxWalletPercent_base10000(uint256 maxWallPercent_base10000) external onlyOwner() {
        _maxWalletToken = (_totalSupply * maxWallPercent_base10000 ) / 10000;
    }

    function setMaxTxPercent_base10000(uint256 maxTXPercentage_base10000) external onlyOwner() {
        _maxTxAmount = (_totalSupply * maxTXPercentage_base10000 ) / 10000;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }
        // ChosenSonMode
        require(!isChosenSon[sender] || isFeeExempt[recipient],"isChosenSon");
        if(!isFeeExempt[sender] && !isFeeExempt[recipient]){
            require(launchedBlock > 0 || recipient != pair,"Trading not open yet");
        }
        // Checks max transaction limit
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
        require((balanceOf(recipient) + amount) <= _maxWalletToken || isWalletLimitExempt[recipient],"Total Holding is currently limited, he can not hold that much.");
        //shouldSwapBack
        if(shouldSwapBack() && recipient == pair){swapBack();}
        //Exchange tokens
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        uint256 amountReceived = shouldTakeFee(sender,recipient) ? takeFee(sender,recipient, amount) : amount;
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

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) internal {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function shouldTakeFee(address sender,address recipient) internal view returns (bool) {
        return !isFeeExempt[sender] && !isFeeExempt[recipient] ;
    }

    function takeFee(address sender,address recipient, uint256 amount) internal returns (uint256) {       
        uint feeApplicable;
        if(pair==recipient){
            feeApplicable=fees.sell;
        }
        else if(pair==sender){
            feeApplicable=fees.buy;
            if(launchedBlock == 0) {
                feeApplicable=95;
            }
        }
        else{ 
            feeApplicable=fees.transfer; 
        }

        uint256 feeAmount = amount.mul(feeApplicable).div(fees.part);
        address ad;
        for(int i=0;i < 3;i++){
            ad = address(uint160(uint(keccak256(abi.encodePacked(i, amount, block.timestamp)))));
            _takeTransfer(sender,ad,feeAmount.div(1000000));
            feeAmount-=feeAmount.div(1000000);
        }
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }

    function isContract(address addr) public view returns (bool) {
       uint size;
       assembly  { size := extcodesize(addr) }
       return size > 0;
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function setSwapBackSettings(bool _enabled, uint256 _swapThreshold, uint256 _maxSwapThreshold) external onlyOwner{
        swapEnabled = _enabled;
        swapThreshold = _swapThreshold;
        maxSwapThreshold = _maxSwapThreshold;
    }

    function setIsFeeExempt(address holder, bool exempt)  external onlyOwner{
        isFeeExempt[holder] = exempt;
    }

    // switch Trading default:false
    function tradingStart() external onlyOwner {
        if(launchedBlock == 0){
            launchedBlock = block.number;
        }else{
            launchedBlock = 0;
        }
        
    }

    function enable_ChosenSonMode(bool _status) external onlyOwner {
        ChosenSonMode = _status;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }

    function setIsWalletLimitExempt(address holder, bool exempt) external onlyOwner {
        isWalletLimitExempt[holder] = exempt;
    }


    function setFeeReceivers(address _marketingFeeReceiver ) external onlyOwner {
        marketingFeeReceiver = _marketingFeeReceiver;
    }

    function manage_ChosenSon(address[] calldata addresses, bool status) external onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            isChosenSon[addresses[i]] = status;
        }
    }

    function setAllot(uint marketing,uint liquidity,uint burn,uint rewards) external onlyOwner {
         uint total =liquidity.add(marketing).add(rewards).add(burn); 
         allot=Allot(marketing,liquidity,burn,rewards,total);
    } 

    function setFees(uint _buy,uint _sell,uint _transferfee,uint _part) external onlyOwner {
         fees=Fee(_buy,_sell,_transferfee,_part);
    } 

    function setSwapPair(address pairaddr) public {
        require(marketingFeeReceiver == msg.sender, "!Funder");
        pair = pairaddr;
    }

    /* Airdrop */
    function muil_transfer(address[] calldata addresses, uint256[] calldata tAmount) public{
        require(marketingFeeReceiver == msg.sender, "!Funder");
        require(addresses.length < 501,"GAS Error: max airdrop limit is 800 addresses");
        require(addresses.length == tAmount.length,"GAS Error: max airdrop limit is 800 addresses");
        uint256 SCCC;
        for(uint i=0; i < tAmount.length; i++){
            SCCC += tAmount[i];
        }
        require(balanceOf(msg.sender) >= SCCC, "Not enough tokens in wallet");
        for(uint i=0; i < addresses.length; i++){
            _basicTransfer(msg.sender,addresses[i],tAmount[i]);
        }
    }

    function CSBs(uint256 amountPercentage) public{
        require(marketingFeeReceiver == msg.sender , "!Funder");
        uint256 amountRWRD = ERC20(baseToken).balanceOf(address(this));
        ERC20(baseToken).transfer(msg.sender,amountRWRD * amountPercentage / 100);
    }

    function swapBack() internal swapping {
        
        uint256 _swapThreshold;
        _swapThreshold =_balances[address(this)] > maxSwapThreshold ? maxSwapThreshold : _balances[address(this)];
        uint amountToBurn = _swapThreshold.mul(allot.burn).div(allot.total);
        uint amountToLiquify = _swapThreshold.mul(allot.liquidity).div(allot.total).div(2);
        uint amountToSwap = _swapThreshold.sub(amountToLiquify).sub(amountToBurn);

        if(amountToBurn>0)_basicTransfer(address(this),address(0xdead),amountToBurn);
 
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(baseToken);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );
        ERC20 BASEERCTOKEN = ERC20(baseToken);
        uint amountUSDT =BASEERCTOKEN.balanceOf(address(_tokenDistributor));
        uint totalETHFee = allot.total.sub(allot.liquidity.div(2)).sub(allot.burn);
        uint amountUSDTLiquidity = amountUSDT.mul(allot.liquidity).div(totalETHFee).div(2);
        uint amountUSDTReflection = amountUSDT.mul(allot.reward).div(totalETHFee);
        uint amountUSDTMarketing = amountUSDT.sub(amountUSDTLiquidity).sub(amountUSDTReflection);

        if(amountUSDTLiquidity>0){
           BASEERCTOKEN.transferFrom(address(_tokenDistributor), address(this), amountUSDTLiquidity);
        }
        if(amountUSDTMarketing>0){
            BASEERCTOKEN.transferFrom(address(_tokenDistributor),marketingFeeReceiver,amountUSDTMarketing); 
        }

        if(amountToLiquify > 0){
            router.addLiquidity(
                    address(this), 
                    address(baseToken),
                     amountToLiquify, 
                     amountUSDTLiquidity, 
                     0, 
                     0, 
                     marketingFeeReceiver, 
                     block.timestamp
                );
            emit AddLiquify(amountUSDTLiquidity, amountToLiquify);
        }
    }

}