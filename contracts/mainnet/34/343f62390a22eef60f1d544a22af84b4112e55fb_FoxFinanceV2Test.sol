/**
 *Submitted for verification at BscScan.com on 2022-03-30
*/

// SPDX-License-Identifier: NONE
pragma solidity 0.8.13;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {_setOwner(_msgSender());}
    function owner() public view virtual returns (address) {return _owner;}
    modifier onlyOwner() {require(owner() == _msgSender(), "Ownable: caller is not the owner");_;}
    function transferOwnership(address newOwner) public virtual onlyOwner {_setOwner(newOwner);}
    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IFactory{
        function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IRouter {
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;
}

contract FoxFinanceV2Test is Context, IERC20, Ownable {

    string private constant _name = "FoxFinanceV2_Test";
    string private constant _symbol = "FOXV2test";
    uint8 private constant _decimals = 9;
    uint256 private constant MAX = type(uint256).max;

    uint256 private _tTotal = 10**9 * 10**_decimals;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 public _maxTxAmount = _tTotal / 100;        // 1% max tx

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;

    address[] private _excluded;

    bool public tradingEnabled;
    bool public swapEnabled;
    bool private swapping;

    IRouter public router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public pair;

    uint256 public swapThreshold = _tTotal / 10000;   //10'000 token
    uint256 public maxSwapAmount = _tTotal / 200;     //500'000 token
    
    address public burnAddress = 0x0000000000000000000000000000000000000001;
    address public marketingAddress = 0x20dAC28ED4c51F3dFBCFbB989dB91e16fe8EDD58;
    address public devAddress = 0xe6497e1F2C5418978D5fC2cD32AA23315E7a41Fb;
    address public charityAddress = 0x6BA9882203F896335A1f1A8ac509d6839Ca57B62;
    address public stakingAddress;
    address public reserveAddress;
    address public teamAddress = 0xef948Fbf3Ef54BB4b4061AEd2928a5cA94628053;
    address public deployerAddress = 0x6A4D3Fe038eaB7F3EEf5a3db51A931bcf8aff152;

    struct Taxes {
      uint256 rfi;
      uint256 tokenTax;
      uint256 bnbTax;
    }

    struct bnbDistribution {
      uint256 liquidityPercentage;
      uint256 marketingPercentage;
      uint256 teamPercentage;
      uint256 devPercentage;
      uint256 charityPercentage;
      uint256 stakingPercentage;
      uint256 reservePercentage;
    }

    struct tokenDistribution {
      uint256 burnPercentage;
      uint256 marketingPercentage;
      uint256 teamPercentage;
      uint256 devPercentage;
      uint256 charityPercentage;
      uint256 stakingPercentage;
      uint256 reservePercentage;
    }

    bnbDistribution public howAreTheBnbsFromTaxesDistributed = bnbDistribution(40,20,20,0,20,0,0);
    tokenDistribution public howAreTheTokensFromTaxesDistributed = tokenDistribution(100,0,0,0,0,0,0);

    Taxes public transferTaxes = Taxes(0,0,0);
    Taxes public buyTaxes = Taxes(4,0,5);
    Taxes public sellTaxes = Taxes(4,0,5);

    struct TotFeesPaidStruct{
        uint256 rfi;
        uint256 tokenTax;
        uint256 bnbTax;
    }
    TotFeesPaidStruct public totFeesPaid;

    struct valuesFromGetValues{
      uint256 rAmount;
      uint256 rTransferAmount;
      uint256 rRfi;
      uint256 rTokenTax;
      uint256 rBnbTax;
      uint256 tTransferAmount;
      uint256 tRfi;
      uint256 tTokenTax;
      uint256 tBnbTax;
    }

    event FeesChanged();
    event UpdatedRouter(address oldRouter, address newRouter);

    modifier lockTheSwap {
        swapping = true;
        _;
        swapping = false;
    }


    address public foxV1 = 0xFAd8E46123D7b4e77496491769C167FF894d2ACB;
    address public migratorContractAddress = 0x287616AF136E00Ea328321031Ef31e4D746d3c85;

    mapping (address => uint256) public oldToken;
    mapping (address => uint256) public newToken;

    uint256 public totalTokenAvailableForMigration;
    uint256 public totalTokenMigrated;
    uint256 public totalWalletsMigrated;
        

    event MigrationSuccessful(uint256 oldTokenMigrated, uint256 newTokensSentOut);
    
    constructor () {
        IRouter _router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _pair = IFactory(_router.factory())
            .createPair(address(this), _router.WETH());

        router = _router;
        pair = _pair;
        
        excludeFromReward(pair);
        excludeFromReward(marketingAddress);
        excludeFromReward(burnAddress);
        excludeFromReward(charityAddress);
        excludeFromReward(teamAddress);
        excludeFromReward(migratorContractAddress);



        _rOwned[owner()] = _rTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[burnAddress] = true;
        _isExcludedFromFee[marketingAddress] = true;
        _isExcludedFromFee[devAddress] = true;
        _isExcludedFromFee[charityAddress] = true;
        _isExcludedFromFee[teamAddress] = true;
        _isExcludedFromFee[migratorContractAddress] = true;

        emit Transfer(address(0), owner(), _tTotal);
    }

    receive() external payable{}


////////////////////////////////////////////////////////////////////// Basic token functions
    function name() public pure returns (string memory) { return _name; }
    function symbol() public pure returns (string memory) { return _symbol; }
    function decimals() public pure returns (uint8) { return _decimals; }
    function totalSupply() public view override returns (uint256) { return _tTotal; }
    function allowance(address owner, address spender) public view override returns (uint256) { return _allowances[owner][spender]; }
    
    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
////////////////////////////////////////////////////////////////////// Basic token functions end


////////////////////////////////////////////////////////////////////// Reflection token functions
    function isExcludedFromReward(address account) public view returns (bool) { return _isExcluded[account]; }
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferRfi, Taxes memory temp) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferRfi) {
            valuesFromGetValues memory s = _getValues(tAmount, true, temp);
            return s.rAmount;
        } else {
            valuesFromGetValues memory s = _getValues(tAmount, true, temp);
            return s.rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount/currentRate;
    }

    function _reflectRfi(uint256 rRfi, uint256 tRfi) private {
        _rTotal -=rRfi;
        totFeesPaid.rfi +=tRfi;
    }

    function _getValues(uint256 tAmount, bool takeFee, Taxes memory temp) private view returns (valuesFromGetValues memory to_return) {
        to_return = _getTValues(tAmount, takeFee, temp);
        (to_return.rAmount, to_return.rTransferAmount, to_return.rRfi, to_return.rTokenTax, to_return.rBnbTax) = _getRValues(to_return, tAmount, takeFee, _getRate());
        return to_return;
    }

    function _getTValues(uint256 tAmount, bool takeFee, Taxes memory temp) private pure returns (valuesFromGetValues memory s) {
        if(!takeFee) {
          s.tTransferAmount = tAmount;
          return s;
        }
        s.tRfi = tAmount*temp.rfi/100;
        s.tTokenTax = tAmount*temp.tokenTax/100;
        s.tBnbTax = tAmount*temp.bnbTax/100;
        s.tTransferAmount = tAmount-s.tRfi-s.tTokenTax-s.tBnbTax;
        return s;
    }

    function _getRValues(valuesFromGetValues memory s, uint256 tAmount, bool takeFee, uint256 currentRate) private pure returns (uint256 rAmount, uint256 rTransferAmount, uint256 rRfi,uint256 rTokenTax, uint256 rBnbTax) {
        rAmount = tAmount*currentRate;
        if(!takeFee) {
          return(rAmount, rAmount, 0,0,0);
        }
        rRfi = s.tRfi*currentRate;
        rTokenTax = s.tTokenTax*currentRate;
        rBnbTax = s.tBnbTax*currentRate;
        rTransferAmount =  rAmount-rRfi-rTokenTax-rBnbTax;
        return (rAmount, rTransferAmount, rRfi,rTokenTax,rBnbTax);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply/tSupply;
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply-_rOwned[_excluded[i]];
            tSupply = tSupply-_tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal/_tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
////////////////////////////////////////////////////////////////////// Reflection token functions end

////////////////////////////////////////////////////////////////////// Taking and distributing taxes
    function _takeBnbTax(uint256 rBnbTax, uint256 tBnbTax) private {
        totFeesPaid.bnbTax +=tBnbTax;
        _tOwned[address(this)]+=tBnbTax;
        _rOwned[address(this)] +=rBnbTax;
    }

    function _takeTokenTax(uint256 rTokenTax, uint256 tTokenTax, address sender) private {
        totFeesPaid.tokenTax +=tTokenTax;

        if(howAreTheTokensFromTaxesDistributed.burnPercentage > 0) {
            _tOwned[burnAddress]+= tTokenTax * howAreTheTokensFromTaxesDistributed.burnPercentage / 100;
            _rOwned[burnAddress] += rTokenTax * howAreTheTokensFromTaxesDistributed.burnPercentage / 100;
            emit Transfer(sender,burnAddress, tTokenTax * howAreTheTokensFromTaxesDistributed.burnPercentage / 100);
        }

        if(howAreTheTokensFromTaxesDistributed.marketingPercentage > 0) {
            _tOwned[marketingAddress]+= tTokenTax * howAreTheTokensFromTaxesDistributed.marketingPercentage / 100;
            _rOwned[marketingAddress] += rTokenTax * howAreTheTokensFromTaxesDistributed.marketingPercentage / 100;
            emit Transfer(sender,marketingAddress, tTokenTax * howAreTheTokensFromTaxesDistributed.marketingPercentage / 100);
        }

        if(howAreTheTokensFromTaxesDistributed.teamPercentage > 0) {
            _tOwned[teamAddress]+= tTokenTax * howAreTheTokensFromTaxesDistributed.teamPercentage / 100;
            _rOwned[teamAddress] += rTokenTax * howAreTheTokensFromTaxesDistributed.teamPercentage / 100;
            emit Transfer(sender,teamAddress, tTokenTax * howAreTheTokensFromTaxesDistributed.teamPercentage / 100);
        }

        if(howAreTheTokensFromTaxesDistributed.devPercentage > 0) {
            _tOwned[devAddress]+= tTokenTax * howAreTheTokensFromTaxesDistributed.devPercentage / 100;
            _rOwned[devAddress] += rTokenTax * howAreTheTokensFromTaxesDistributed.devPercentage / 100;
            emit Transfer(sender,devAddress, tTokenTax * howAreTheTokensFromTaxesDistributed.devPercentage / 100);
        }

        if(howAreTheTokensFromTaxesDistributed.charityPercentage > 0) {
            _tOwned[charityAddress]+= tTokenTax * howAreTheTokensFromTaxesDistributed.charityPercentage / 100;
            _rOwned[charityAddress] += rTokenTax * howAreTheTokensFromTaxesDistributed.charityPercentage / 100;
            emit Transfer(sender,charityAddress, tTokenTax * howAreTheTokensFromTaxesDistributed.charityPercentage / 100);
        }

        if(howAreTheTokensFromTaxesDistributed.stakingPercentage > 0) {
            _tOwned[stakingAddress]+= tTokenTax * howAreTheTokensFromTaxesDistributed.stakingPercentage / 100;
            _rOwned[stakingAddress] += rTokenTax * howAreTheTokensFromTaxesDistributed.stakingPercentage / 100;
            emit Transfer(sender,stakingAddress, tTokenTax * howAreTheTokensFromTaxesDistributed.stakingPercentage / 100);
        }

        if(howAreTheTokensFromTaxesDistributed.reservePercentage > 0) {
            if(_isExcluded[reserveAddress]) {
                _tOwned[reserveAddress]+= tTokenTax * howAreTheTokensFromTaxesDistributed.reservePercentage / 100;
            }
            _rOwned[reserveAddress] += rTokenTax * howAreTheTokensFromTaxesDistributed.reservePercentage / 100;        
            emit Transfer(sender,reserveAddress, tTokenTax * howAreTheTokensFromTaxesDistributed.reservePercentage / 100);
        }
    }

    function swapAndLiquify() private lockTheSwap{
        uint256 contractBalance = balanceOf(address(this));
        if(contractBalance > maxSwapAmount){
            contractBalance = maxSwapAmount;
        }
    
        uint256 tokensToLiquidity = contractBalance * howAreTheBnbsFromTaxesDistributed.liquidityPercentage / 200;

        uint256 tokensToSwapToBnb = contractBalance - tokensToLiquidity;

        swapTokensForBNB(tokensToSwapToBnb);

        if(tokensToLiquidity > 0 && address(this).balance > 0){
            addLiquidity(tokensToLiquidity, address(this).balance);
        }

        uint256 onePercentOfBNBTaxes = address(this).balance / (100 - howAreTheBnbsFromTaxesDistributed.liquidityPercentage);

        payable(marketingAddress).transfer(onePercentOfBNBTaxes * howAreTheBnbsFromTaxesDistributed.marketingPercentage);
        payable(devAddress).transfer(onePercentOfBNBTaxes * howAreTheBnbsFromTaxesDistributed.devPercentage);
        payable(charityAddress).transfer(onePercentOfBNBTaxes * howAreTheBnbsFromTaxesDistributed.charityPercentage);
        payable(stakingAddress).transfer(onePercentOfBNBTaxes * howAreTheBnbsFromTaxesDistributed.stakingPercentage);
        payable(reserveAddress).transfer(onePercentOfBNBTaxes * howAreTheBnbsFromTaxesDistributed.reservePercentage);
        payable(teamAddress).transfer(address(this).balance);
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(router), type(uint256).max);

        // add the liquidity
        router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            deployerAddress,
            block.timestamp
        );
    }

    function swapTokensForBNB(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), type(uint256).max);

        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }
////////////////////////////////////////////////////////////////////// Taking and distributing taxes end


////////////////////////////////////////////////////////////////////// Transfer functions
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(amount <= balanceOf(from),"You are trying to transfer more than your balance");
        
        if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to]){
            require(tradingEnabled, "Trading not active");
        }

       
        bool canSwap = balanceOf(address(this)) >= swapThreshold;
        if(!swapping && swapEnabled && canSwap && from != pair && !_isExcludedFromFee[from] && !_isExcludedFromFee[to]){
            swapAndLiquify();
        }
        Taxes memory temp; 

        if(from == pair) temp = buyTaxes;
        else if(to == pair) temp = sellTaxes;
        else temp = transferTaxes;

        _tokenTransfer(from, to, amount, !(_isExcludedFromFee[from] || _isExcludedFromFee[to]), temp);
    }


    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool takeFee, Taxes memory temp) private {

        valuesFromGetValues memory s = _getValues(tAmount, takeFee, temp);

        if (_isExcluded[sender] ) {  //from excluded
                _tOwned[sender] = _tOwned[sender]-tAmount;
        }
        if (_isExcluded[recipient]) { //to excluded
                _tOwned[recipient] = _tOwned[recipient]+s.tTransferAmount;
        }

        _rOwned[sender] = _rOwned[sender]-s.rAmount;
        _rOwned[recipient] = _rOwned[recipient]+s.rTransferAmount;
        
        if(s.rRfi > 0 || s.tRfi > 0) _reflectRfi(s.rRfi, s.tRfi);

        if(s.rBnbTax > 0 || s.tBnbTax > 0) {
            _takeBnbTax(s.rBnbTax,s.tBnbTax);
            emit Transfer(sender, address(this), s.tBnbTax);
        }
        if(s.rTokenTax > 0 || s.tTokenTax > 0){
            _takeTokenTax(s.rTokenTax, s.tTokenTax, sender);


        }
        emit Transfer(sender, recipient, s.tTransferAmount);
        
    }
////////////////////////////////////////////////////////////////////// Transfer functions end


////////////////////////////////////////////////////////////////////// Admin functions
    function updateTokenTaxWallets(
        address newBurnAddress, 
        address newMarketingAddress, 
        address newCharityAddress, 
        address newStakingAddress, 
        address newReserveAddress, 
        address newTeamAddress
        ) 
        external onlyOwner {
        burnAddress = newBurnAddress;
        marketingAddress = newMarketingAddress;
        charityAddress = newCharityAddress;
        stakingAddress = newStakingAddress;
        reserveAddress = newReserveAddress;
        teamAddress = newTeamAddress;

        excludeFromReward(marketingAddress);
        excludeFromReward(burnAddress);
        excludeFromReward(charityAddress);
        excludeFromReward(teamAddress);
        excludeFromReward(stakingAddress);

        _isExcludedFromFee[burnAddress] = true;
        _isExcludedFromFee[marketingAddress] = true;
        _isExcludedFromFee[devAddress] = true;
        _isExcludedFromFee[charityAddress] = true;
        _isExcludedFromFee[teamAddress] = true;
        _isExcludedFromFee[stakingAddress] = true;
        _isExcludedFromFee[reserveAddress] = true;
    }

    function setSwapSettings(bool set, uint256 minimumSwap, uint256 maximumSwap) external onlyOwner {
		swapEnabled = set;
        maxSwapAmount = _tTotal / 10**9 * maximumSwap;
        swapThreshold = _tTotal / 10**9 * minimumSwap;
	}

    function updateTransferTaxes(uint256 _rfi, uint256 _tokenTax, uint256 _bnbTax) external onlyOwner {
        transferTaxes = Taxes(_rfi, _tokenTax, _bnbTax);
    }

    function updateBuyTaxes(uint256 _rfi, uint256 _tokenTax, uint256 _bnbTax) external onlyOwner {
        sellTaxes = Taxes(_rfi, _tokenTax, _bnbTax);
    }

    function updateSellTaxes(uint256 _rfi, uint256 _tokenTax, uint256 _bnbTax) external onlyOwner {
        buyTaxes = Taxes(_rfi, _tokenTax, _bnbTax);
    }

    function updateRouterAndPair(address newRouter, address newPair) external onlyOwner {
        router = IRouter(newRouter);
        pair = newPair;
    }
    
    function openTrading() external onlyOwner{
        tradingEnabled = true;
    }


    function setTransferTaxes(uint256 _rfi, uint256 _tokenTax, uint256 _bnbTax) public onlyOwner {
        transferTaxes.rfi = _rfi;
        transferTaxes.tokenTax = _tokenTax;
        transferTaxes.bnbTax = _bnbTax;
        emit FeesChanged();
    }

    function setBuyTaxes(uint256 _rfi, uint256 _tokenTax, uint256 _bnbTax) public onlyOwner {
        buyTaxes.rfi = _rfi;
        buyTaxes.tokenTax = _tokenTax;
        buyTaxes.bnbTax = _bnbTax;
        emit FeesChanged();
    }

    function setSellTaxes(uint256 _rfi, uint256 _tokenTax, uint256 _bnbTax) public onlyOwner {
        sellTaxes.rfi = _rfi;
        sellTaxes.tokenTax = _tokenTax;
        sellTaxes.bnbTax = _bnbTax;
        emit FeesChanged();
    }

    function setBNBDistribution(uint256 newLiquidity, uint256 newMarketing, uint256 newTeam, uint256 newDev, uint256 newCharity, uint256 newStaking, uint256 newReserve) public onlyOwner {
        howAreTheBnbsFromTaxesDistributed = bnbDistribution(newLiquidity, newMarketing, newTeam, newDev, newCharity, newStaking, newReserve);
    }
    function setTokenDistribution(uint256 newBurn, uint256 newMarketing, uint256 newTeam, uint256 newDev, uint256 newCharity, uint256 newStaking, uint256 newReserve) public onlyOwner {
        howAreTheTokensFromTaxesDistributed = tokenDistribution(newBurn, newMarketing, newTeam, newDev, newCharity, newStaking, newReserve);
    }

///////////////////////////////// Include and exclude wallets from taxes
    function excludeFromReward(address account) public onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is not excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }



     //////////////////////////////////////////////////////////////////EmergencyFunctions
    function rescueBNB() external onlyOwner{
        payable(owner()).transfer(address(this).balance);
    }
    

    function rescueAnyBEP20Tokens(address _tokenAddr) public onlyOwner {
        IERC20(_tokenAddr).transfer(owner(), IERC20(_tokenAddr).balanceOf(address(this)));
    }
////////////////////////////////////////////////////////////////////// Admin functions end

//////////////////////////////////////////////////////////////////////// Migration from FoxV1
    function migrationPreview() public view returns(uint256, uint256) {
        uint256 oldTokenPreview = IERC20(foxV1).balanceOf(msg.sender);
        uint256 newTokenPreview = oldTokenPreview / 1000000;
        return (oldTokenPreview, newTokenPreview);
    }
    function migrationPreviewForOtherWallet(address account) public view returns(uint256, uint256) {
        uint256 oldTokenPreview = IERC20(foxV1).balanceOf(account);
        uint256 newTokenPreview = oldTokenPreview / 1000000;
        return (oldTokenPreview, newTokenPreview);
    }

    function migrateToken() external {
        oldToken[msg.sender] = IERC20(foxV1).balanceOf(msg.sender);
        newToken[msg.sender] = oldToken[msg.sender] / 1000000;
        require(_tOwned[migratorContractAddress] > newToken[msg.sender], "MigratorContract is out of tokens, please ask the team to refill it");

        IERC20(foxV1).transferFrom(msg.sender, deployerAddress, oldToken[msg.sender]);
        

        if(_isExcluded[msg.sender]) {
                _tOwned[msg.sender] += newToken[msg.sender];
            }
        _rOwned[msg.sender] += newToken[msg.sender];
  
        _tOwned[migratorContractAddress] -= newToken[msg.sender];
        _rOwned[migratorContractAddress] -= newToken[msg.sender];

        emit Transfer(migratorContractAddress ,msg.sender, newToken[msg.sender]);

        totalTokenAvailableForMigration = balanceOf(migratorContractAddress);
        totalTokenMigrated += oldToken[msg.sender];
        totalWalletsMigrated++;

        emit MigrationSuccessful(oldToken[msg.sender], newToken[msg.sender]);
    }

    function rescueV2TokensFromMigratorContract() external onlyOwner{
        uint256 migratorTokensToRescue = balanceOf(migratorContractAddress);

        if(_isExcluded[msg.sender]) {
                _tOwned[msg.sender] += migratorTokensToRescue;
        }
        _rOwned[msg.sender] += migratorTokensToRescue;

        _tOwned[migratorContractAddress] -= migratorTokensToRescue;
        _rOwned[migratorContractAddress] -= migratorTokensToRescue;

        emit Transfer(migratorContractAddress ,msg.sender, migratorTokensToRescue);
    }
//////////////////////////////////////////////////////////////////////// Migration from FoxV1 end
}