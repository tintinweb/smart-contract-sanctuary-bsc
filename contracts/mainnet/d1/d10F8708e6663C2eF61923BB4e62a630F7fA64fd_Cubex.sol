/**
 *Submitted for verification at BscScan.com on 2022-10-08
*/

/*
    cubeprotocol.io Cubex
*/  

// Code written by MrGreenCrypto
// SPDX-License-Identifier: None
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
        this;
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

contract Cubex is Context, IERC20, Ownable {

    string private constant _name = "Cubex Protocol";
    string private constant _symbol = "Cubex";
    uint8 private constant _decimals = 9;
    uint256 private constant MAX = type(uint256).max;

    uint256 private _tTotal = 1_000_000_000 * 10**_decimals;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;

    address[] private _excluded;
    address[] public pairs;
    
    bool public tradingEnabled = false;
    bool public swapEnabled = false;
    bool private swapping;

    IRouter public router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public pair;
    

    uint256 public swapThreshold = 200_000 * 10**_decimals;
    uint256 public maxSwapAmount = 300_000 * 10**_decimals;
    
    address public burnAddress = 0x0000000000000000000000000000000000000001;
    address public marketingAddress = 0x83F3E9fb978F52ce8D07fE71F7033F19F992debc;
    address public devAddress = 0x83F3E9fb978F52ce8D07fE71F7033F19F992debc;
    address public bountyAddress = 0x83F3E9fb978F52ce8D07fE71F7033F19F992debc;
    address public stakingAddress;
    address public reserveAddress;
    address public teamAddress = 0x83F3E9fb978F52ce8D07fE71F7033F19F992debc;
    address public deployerAddress = 0x55f7e2bC6139a52104101A14567fA8302E84A46c;

    struct Taxes {
      uint256 rfi;
      uint256 tokenTax;
      uint256 bnbTax;
    }

    Taxes public transferTaxes = Taxes(0,0,0);
    Taxes public buyTaxes = Taxes(4,0,5);
    Taxes public sellTaxes = Taxes(4,0,5);

    struct bnbDistribution {
      uint256 liquidityPercentage;
      uint256 marketingPercentage;
      uint256 teamPercentage;
      uint256 devPercentage;
      uint256 bountyPercentage;
      uint256 stakingPercentage;
      uint256 reservePercentage;
    }
    
    bnbDistribution public howAreTheBnbsFromTaxesDistributed = bnbDistribution(40,20,20,0,20,0,0);
    
    struct tokenDistribution {
      uint256 burnPercentage;
      uint256 marketingPercentage;
      uint256 teamPercentage;
      uint256 devPercentage;
      uint256 bountyPercentage;
      uint256 stakingPercentage;
      uint256 reservePercentage;
    }

    tokenDistribution public howAreTheTokensFromTaxesDistributed = tokenDistribution(20,20,20,20,20,0,0);

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

    event FeesChanged(
        Taxes transferTaxes,
        Taxes buyTaxes,
        Taxes sellTaxes,
        bnbDistribution howAreTheBnbsFromTaxesDistributed,
        tokenDistribution howAreTheTokensFromTaxesDistributed
    );


    modifier lockTheSwap {
        swapping = true;
        _;
        swapping = false;
    }

    constructor () {
        //set up the addresses for PancakeSwap
        IRouter _router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _pair = IFactory(_router.factory()).createPair(address(this), _router.WETH());
        router = _router;
        pair = _pair;
        pairs.push(pair);
        excludeFromReward(pair);

        excludeFromEverything(marketingAddress);
        excludeFromEverything(bountyAddress);
        excludeFromEverything(teamAddress);

        _isExcludedFromFee[address(this)] = true;

        _rOwned[owner()] = _rTotal;
        emit Transfer(address(0), owner(), _tTotal);
    }

    receive() external payable{}

////////////////////////////////////////////////////////////////////// Basic token functions
    function name() public pure returns (string memory) { return _name; }
    function symbol() public pure returns (string memory) { return _symbol; }
    function decimals() public pure returns (uint8) { return _decimals; }
    function allowance(address owner, address spender) public view override returns (uint256) { return _allowances[owner][spender]; }
    function totalSupply() public view override returns (uint256) { return _tTotal; }

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

    function approveMax(address spender) external returns (bool) {
        _approve(_msgSender(), spender, MAX);
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

////////////////////////////////////////////////////////////////////// Reflection functions
    function isExcludedFromReward(address account) public view returns (bool) {return _isExcluded[account];}
    function isExcludedFromFee(address account) public view returns(bool) {return _isExcludedFromFee[account];}

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
////////////////////////////////////////////////////////////////////// Reflection functions end

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

        if(isPair(from)) temp = buyTaxes;
        else if(isPair(to)) temp = sellTaxes;
        else temp = transferTaxes;

        _tokenTransfer(from, to, amount, !(_isExcludedFromFee[from] || _isExcludedFromFee[to]), temp);
    }

    function isPair(address addressToCheckIfPair) internal view returns (bool) {
        address[] memory liqPairs = pairs;
        for (uint256 i = 0; i < liqPairs.length; i++) {
            if (addressToCheckIfPair == liqPairs[i] ) {
            return true;
		    }
        }
        return false;     
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
        
        if(s.rRfi > 0 || s.tRfi > 0) {
            _reflectRfi(s.rRfi, s.tRfi);
        }

        if(s.rBnbTax > 0 || s.tBnbTax > 0) {
            _takeBnbTax(s.rBnbTax,s.tBnbTax);
            emit Transfer(sender, address(this), s.tBnbTax);
        }

        if(s.rTokenTax > 0 || s.tTokenTax > 0){
            _takeTokenTax(sender, s.rTokenTax, s.tTokenTax);
        }

        emit Transfer(sender, recipient, s.tTransferAmount);
        
    }
////////////////////////////////////////////////////////////////////// Transfer functions end

////////////////////////////////////////////////////////////////////// Taking and distributing taxes
    function _takeBnbTax(uint256 rBnbTax, uint256 tBnbTax) private {
        totFeesPaid.bnbTax +=tBnbTax;
        _tOwned[address(this)]+=tBnbTax;
        _rOwned[address(this)] +=rBnbTax;
    }

    function _takeTokenTax(address sender, uint256 rTokenTax, uint256 tTokenTax) private {
        totFeesPaid.tokenTax +=tTokenTax;

        transferTokenTax(sender, burnAddress, rTokenTax, tTokenTax, howAreTheTokensFromTaxesDistributed.burnPercentage);
        transferTokenTax(sender, marketingAddress, rTokenTax, tTokenTax, howAreTheTokensFromTaxesDistributed.marketingPercentage);
        transferTokenTax(sender, teamAddress, rTokenTax, tTokenTax, howAreTheTokensFromTaxesDistributed.teamPercentage);
        transferTokenTax(sender, devAddress, rTokenTax, tTokenTax, howAreTheTokensFromTaxesDistributed.devPercentage);
        transferTokenTax(sender, bountyAddress, rTokenTax, tTokenTax, howAreTheTokensFromTaxesDistributed.bountyPercentage);
        transferTokenTax(sender, stakingAddress, rTokenTax, tTokenTax, howAreTheTokensFromTaxesDistributed.stakingPercentage);
        transferTokenTax(sender, reserveAddress, rTokenTax, tTokenTax, howAreTheTokensFromTaxesDistributed.reservePercentage);
    }

    function transferTokenTax(address sender, address receiver, uint256 rAmount, uint256 tAmount, uint256 percent) internal {
        if(percent == 0 || rAmount == 0 || tAmount == 0) return;
        if(_isExcluded[receiver]) _tOwned[receiver] += tAmount * percent / 100;
        _rOwned[receiver] += rAmount * percent / 100;
        emit Transfer(sender,receiver, rAmount * percent / 100);
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

        transferBNBPercent(marketingAddress, onePercentOfBNBTaxes, howAreTheBnbsFromTaxesDistributed.marketingPercentage);
        transferBNBPercent(devAddress, onePercentOfBNBTaxes, howAreTheBnbsFromTaxesDistributed.devPercentage);
        transferBNBPercent(bountyAddress, onePercentOfBNBTaxes, howAreTheBnbsFromTaxesDistributed.bountyPercentage);
        transferBNBPercent(stakingAddress, onePercentOfBNBTaxes, howAreTheBnbsFromTaxesDistributed.stakingPercentage);
        transferBNBPercent(reserveAddress, onePercentOfBNBTaxes, howAreTheBnbsFromTaxesDistributed.reservePercentage);
        
        //Send rest to teamWallet, to ensure no failed tx because of miscalculations 
        //(normally the amount sent here is the teamPercentage, in case of miscalculations, the amount might be slightly more or less)
        payable(teamAddress).transfer(address(this).balance);
    }

    function transferBNBPercent(address receiver, uint256 onePercent, uint256 howManyPercent) internal {
        payable(receiver).transfer(onePercent * howManyPercent);
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        _approve(address(this), address(router), MAX);

        router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            deployerAddress,
            block.timestamp
        );
    }

    function swapTokensForBNB(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), MAX);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
////////////////////////////////////////////////////////////////////// Taking and distributing taxes end

////////////////////////////////////////////////////////////////////// Admin functions
    function setTaxes(
        uint256 selectTaxToChange,
        uint256 _rfi,
        uint256 _tokenTax,
        uint256 _bnbTax
    ) external onlyOwner {
        // selectTaxToChange
        // 0: transferTaxes
        // 1: buyTaxes
        // 2: sellTaxes

        require(
            selectTaxToChange == 0 ||
            selectTaxToChange == 1 ||
            selectTaxToChange == 2,
            "Please specify selectTaxToChange: 0 for transferTaxes, 1 for buyTaxes or 2 for sellTaxes"
        );
        require(_rfi + _tokenTax + _bnbTax <= 20, "Taxes are limited to a maximum of 20%");

        if(selectTaxToChange == 0){
            transferTaxes.rfi = _rfi;
            transferTaxes.tokenTax = _tokenTax;
            transferTaxes.bnbTax = _bnbTax;
        } else if(selectTaxToChange == 1){
            buyTaxes.rfi = _rfi;
            buyTaxes.tokenTax = _tokenTax;
            buyTaxes.bnbTax = _bnbTax;
        } else if(selectTaxToChange == 2){
            sellTaxes.rfi = _rfi;
            sellTaxes.tokenTax = _tokenTax;
            sellTaxes.bnbTax = _bnbTax;
        } else{
            return;
        }

        emit FeesChanged(
            transferTaxes,
            buyTaxes,
            sellTaxes,
            howAreTheBnbsFromTaxesDistributed,
            howAreTheTokensFromTaxesDistributed
        );
    }

    function setBNBDistribution(uint256 newLiquidity, uint256 newMarketing, uint256 newTeam, uint256 newDev, uint256 newBounty, uint256 newStaking, uint256 newReserve) external onlyOwner {
        require(newLiquidity + newMarketing + newTeam + newDev + newBounty + newStaking + newReserve == 100, "The total distribution has to add up to 100%");
        
        howAreTheBnbsFromTaxesDistributed = bnbDistribution(newLiquidity, newMarketing, newTeam, newDev, newBounty, newStaking, newReserve);
        
        emit FeesChanged(
            transferTaxes,
            buyTaxes,
            sellTaxes,
            howAreTheBnbsFromTaxesDistributed,
            howAreTheTokensFromTaxesDistributed
        );
    }

    function setTokenDistribution(uint256 newBurn, uint256 newMarketing, uint256 newTeam, uint256 newDev, uint256 newBounty, uint256 newStaking, uint256 newReserve) external onlyOwner {
        require(newBurn + newMarketing + newTeam + newDev + newBounty + newStaking + newReserve == 100, "The total distribution has to add up to 100%");
        
        howAreTheTokensFromTaxesDistributed = tokenDistribution(newBurn, newMarketing, newTeam, newDev, newBounty, newStaking, newReserve);
        
        emit FeesChanged(
            transferTaxes,
            buyTaxes,
            sellTaxes,
            howAreTheBnbsFromTaxesDistributed,
            howAreTheTokensFromTaxesDistributed
        );
    }
    
    function updateTaxWallets(
        address newMarketingAddress, 
        address newBountyAddress, 
        address newStakingAddress, 
        address newTeamAddress,
        address newReserveAddress
        ) 
        external onlyOwner {
            marketingAddress = newMarketingAddress;
            bountyAddress = newBountyAddress;
            stakingAddress = newStakingAddress;
            teamAddress = newTeamAddress;
            reserveAddress = newReserveAddress;

            excludeFromEverything(marketingAddress);
            excludeFromEverything(bountyAddress);
            excludeFromEverything(teamAddress);
            excludeFromEverything(stakingAddress);
            excludeFromEverything(reserveAddress);
    }

    function setSwapSettings(bool set, uint256 minimumSwap, uint256 maximumSwap) external onlyOwner {
		swapEnabled = set;
        require(minimumSwap <= maximumSwap, "Duh?!");
        swapThreshold = minimumSwap * 10**_decimals;
        maxSwapAmount = maximumSwap * 10**_decimals;
    }

    function addPair(address newPair) external onlyOwner {
        pairs.push(newPair);
        excludeFromReward(newPair);
    }

    function removeLastPair() external onlyOwner {
        pairs.pop();
    }

    function openTrading() external onlyOwner {
        tradingEnabled = true;
        swapEnabled = true;
    }
 
////////////////////////////////////////////////////////////////////// Admin functions end

////////////////////////////////////////////////////////////////////// Include and exclude wallets from taxes and reflections
    function excludeFromReward(address account) public onlyOwner {
        if(_isExcluded[account]){
            return;
        }
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner {
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

    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function excludeFromEverything(address account) public onlyOwner {
        excludeFromFee(account);
        excludeFromReward(account);
    }
////////////////////////////////////////////////////////////////////// Include and exclude wallets from taxes and reflections end

////////////////////////////////////////////////////////////////////// Emergency functions 
    function rescueBNB() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
    
    function rescueAnyBEP20Tokens(address _tokenAddr) external onlyOwner {
        IERC20(_tokenAddr).transfer(owner(), IERC20(_tokenAddr).balanceOf(address(this)));
    }
////////////////////////////////////////////////////////////////////// Emergency functions end 
}