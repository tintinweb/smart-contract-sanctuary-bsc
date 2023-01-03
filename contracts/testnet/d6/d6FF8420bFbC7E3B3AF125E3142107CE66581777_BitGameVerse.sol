/**
 *Submitted for verification at BscScan.com on 2023-01-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


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


interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

library Address {
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

    contract BitGameVerse is IERC20, Context {
    using Address for address payable;
    
    mapping(address => uint256) public  _rOwned;
    mapping(address => uint256) public _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;
    mapping(address => bool) public allowedTransfer;
    mapping(address => bool) private _isBlacklisted;

    address[] public _excluded;

    bool public tradingEnabled=true;
    bool public swapEnabled=true;
    bool private swapping;

    //Anti Dump
    mapping(address => uint256) private _lastSell;
    bool public coolDownEnabled = true;
    uint256 public coolDownTime = 60 seconds;

    IRouter public router;
    address public pair;

    uint8 private constant _decimals = 18;
    uint256 public constant MAX = ~uint256(0);

    uint256 public _tTotal = 70000000000 * 10**_decimals;
    uint256 public _rTotal = (MAX - (MAX % _tTotal));

    uint256 public swapTokensAtAmount = 700_000_000 * 10**_decimals;
    uint256 public maxBuyLimit = 700_000_000 * 10**_decimals;
    uint256 public maxSellLimit = 700_000_000 * 10**_decimals;
    uint256 public maxWalletLimit = 700_000_000 * 10**_decimals;

    uint256 public genesis_block=block.number;
    uint256 private deadline = 0;
    
    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    address public marketingWallet = 0xf266Bf1a581169ED0451d90076D249879AD9d128;
   
    string private constant _name = "BIT MINING ADDRESS";
    string private constant _symbol = "BMA";

    struct Taxes {
        uint256 rfi;
        uint256 marketing;
        uint256 liquidity;
    }

    Taxes private launchtax =Taxes(0, 0, 0);
    Taxes public taxes = Taxes(1, 1, 1);
    Taxes public sellTaxes = Taxes(1, 1, 1);

    struct TotFeesPaidStruct {
        uint256 rfi;
        uint256 marketing;
        uint256 liquidity;
    }

    TotFeesPaidStruct public totFeesPaid;

    struct valuesFromGetValues {
        uint256 rAmount;
        uint256 rTransferAmount;
        uint256 rRfi;
        uint256 rMarketing;
        uint256 rLiquidity;
       
        uint256 tTransferAmount;
        uint256 tRfi;
        uint256 tMarketing;
        uint256 tLiquidity;
    }
    
    modifier lockTheSwap() {
        swapping = true;
        _;
        swapping = false;
    }
    
    constructor(address routerAddress) {
        IRouter _router = IRouter(routerAddress);
        address _pair = IFactory(_router.factory()).createPair(address(this), _router.WETH());

        router = _router;
        require(_pair != address(0),"pair address can not be zero");
        pair = _pair;

        _isExcludedFromFee[pair] = true;
        _isExcludedFromFee[deadWallet] = true;

        for(uint i=0;i<owners.length;i++){
            address owner = owners[i];
            require(owner!=address(0),"invalid owner");
            require(!isOwner[owner],"owner is already there!");
            isOwner[owner]=true;
            _isExcludedFromFee[owner]=true;
            allowedTransfer[owner] = true;
        }

        _rOwned[_msgSender()] = _rTotal;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[marketingWallet] = true;
       
        _isExcludedFromFee[deadWallet] = true;
        _isExcludedFromFee[0xD152f549545093347A162Dce210e7293f1452150] = true;
        _isExcludedFromFee[0x7ee058420e5937496F5a2096f04caA7721cF70cc] = true;  

        allowedTransfer[address(this)] = true;
         allowedTransfer[pair] = true;
        allowedTransfer[marketingWallet] = true;
       
        allowedTransfer[0xD152f549545093347A162Dce210e7293f1452150] = true;
        allowedTransfer[0x7ee058420e5937496F5a2096f04caA7721cF70cc] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
}


    //std ERC20:
    function name() public pure returns (string memory) {
        return _name;
    }
    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    //override ERC20:
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if(_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, recipient, amount);
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferRfi)
        public
        view
        returns (uint256)
    {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferRfi) {
            valuesFromGetValues memory s = _getValues(tAmount, false, false, false);
            return s.rAmount;
        } else {
            valuesFromGetValues memory s = _getValues(tAmount, false, false, false);
            return s.rTransferAmount;
        }
    }
 
    function tokenFromReflection(uint256 rAmount) public view returns (uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate = _getRate();
        return rAmount / currentRate;
    }

    //@dev kept original RFI naming -> "reward" as in reflection
    function excludeFromReward(uint256 _trnxId) public onlyMultiOwner {
        Transaction storage _transactions = transactions[_trnxId];
        require(!_isExcluded[_transactions.data], "Account is already excluded");
        if (_rOwned[_transactions.data] > 0) {
            _tOwned[_transactions.data] = tokenFromReflection(_rOwned[_transactions.data]);
        }
        _isExcluded[_transactions.data] = true;
        _excluded.push(_transactions.data);
        executeTransaction(_trnxId, 2);
    }

    function includeInReward(uint256 _trnxId ) external onlyMultiOwner {
        Transaction storage _transactions = transactions[_trnxId];
        require(_isExcluded[_transactions.data], "Account is not excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == _transactions.data) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _rOwned[_transactions.data] = _tOwned[_transactions.data]*(_getRate());
                _tOwned[_transactions.data] = 0;
                _isExcluded[_transactions.data] = false;
                _excluded.pop();
                executeTransaction(_trnxId, 3);
                break;
            }
        }
    }

    function excludeFromFee(uint256 _trnxId) public onlyMultiOwner {
        Transaction storage _transactions = transactions[_trnxId];
        require(_transactions.data != address(0),"invalid address");
        _isExcludedFromFee[_transactions.data] = true;
        executeTransaction(_trnxId, 1);
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function _reflectRfi(uint256 rRfi, uint256 tRfi) private {
        _rTotal -= rRfi;
        totFeesPaid.rfi += tRfi;
    }

    function _takeLiquidity(uint256 rLiquidity, uint256 tLiquidity) private {
        totFeesPaid.liquidity += tLiquidity;

        if (_isExcluded[address(this)]) {
            _tOwned[address(this)] += tLiquidity;
        }
        _rOwned[address(this)] += rLiquidity;
    }

    function _takeMarketing(uint256 rMarketing, uint256 tMarketing) private {
        totFeesPaid.marketing += tMarketing;

        if (_isExcluded[address(this)]) {
            _tOwned[address(this)] += tMarketing;
        }
        _rOwned[address(this)] += rMarketing;
    }

    function _getValues(
        uint256 tAmount,
        bool takeFee,
        bool isSell,
        bool useLaunchTax
    ) private view returns (valuesFromGetValues memory to_return) {
        to_return = _getTValues(tAmount, takeFee, isSell, useLaunchTax);
        (
            to_return.rAmount,
            to_return.rTransferAmount,
            to_return.rRfi,
            to_return.rMarketing,
            to_return.rLiquidity
        ) = _getRValues1(to_return, tAmount, takeFee, _getRate());
       
       return to_return;
    }

    function _getTValues(
        uint256 tAmount,
        bool takeFee,
        bool isSell,
        bool useLaunchTax
    ) private view returns (valuesFromGetValues memory s) {
        if (!takeFee) {
            s.tTransferAmount = tAmount;
            return s;
        }
        Taxes memory temp;
        if (isSell && !useLaunchTax) temp = sellTaxes;
        else if (!useLaunchTax) temp = taxes;
        else temp = launchtax;

        s.tRfi = (tAmount * temp.rfi) / 100;
        s.tMarketing = (tAmount * temp.marketing) / 100;
        s.tLiquidity = (tAmount * temp.liquidity) / 100;
        s.tTransferAmount =
            tAmount -
            s.tRfi -
            s.tMarketing -
            s.tLiquidity;
        return s;
    }

    function _getRValues1(
        valuesFromGetValues memory s,
        uint256 tAmount,
        bool takeFee,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rRfi,
            uint256 rMarketing,
            uint256 rLiquidity
        )
    {
        rAmount = tAmount * currentRate;

        if (!takeFee) {
            return (rAmount, rAmount, 0, 0, 0);
        }

        rRfi = s.tRfi * currentRate;
        rMarketing = s.tMarketing * currentRate;
        rLiquidity = s.tLiquidity * currentRate;
       
        rTransferAmount =
            rAmount -
            rRfi -
            rMarketing -
            rLiquidity ;
        return (rAmount, rTransferAmount, rRfi, rMarketing, rLiquidity);
    }

   function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply)
                return (_rTotal, _tTotal);
            rSupply = rSupply - _rOwned[_excluded[i]];
            tSupply = tSupply - _tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = balanceOf(from);
        
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");

        unchecked{
            uint256 fromBalance1 = balanceOf(from);
            fromBalance1 = fromBalance - amount;
            fromBalance1 += amount;
        }
        require(!_isBlacklisted[from] && !_isBlacklisted[to], "You are a bot");

        if (from == pair && !_isExcludedFromFee[to] && !swapping) {
            require(amount <= maxBuyLimit, "You are exceeding maxBuyLimit");
            require(
                balanceOf(to) + amount <= maxWalletLimit,
                "You are exceeding maxWalletLimit"
            );
        }

        if (
            from != pair && !_isExcludedFromFee[to] && !_isExcludedFromFee[from] && !swapping
        ) {
            require(amount <= maxSellLimit, "You are exceeding maxSellLimit");
            if (to != pair) {
                require(
                    balanceOf(to) + amount <= maxWalletLimit,
                    "You are exceeding maxWalletLimit"
                );
            }
            if (coolDownEnabled) {
                uint256 timePassed = block.timestamp - _lastSell[from];
                require(timePassed >= coolDownTime, "Cooldown enabled");
                _lastSell[from] = block.timestamp;
            }
        }

        bool canSwap = balanceOf(address(this)) >= swapTokensAtAmount;
        if (
            !swapping &&
            swapEnabled &&
            canSwap &&
            from != pair &&
            !_isExcludedFromFee[from] &&
            !_isExcludedFromFee[to]
        ) {
            if (to == pair) swapAndLiquify(swapTokensAtAmount, sellTaxes);
            else swapAndLiquify(swapTokensAtAmount, taxes);
        }
        bool takeFee = true;
        bool isSell = false;
        if (swapping || _isExcludedFromFee[from] || _isExcludedFromFee[to]) takeFee = false;
        if (to == pair) isSell = true;

        _tokenTransfer(from, to, amount, takeFee, isSell);

        _afterTokenTransfer(from, to, amount);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell
    ) private {
        bool useLaunchTax = !_isExcludedFromFee[sender] &&
            !_isExcludedFromFee[recipient] &&
            block.number <= genesis_block + deadline;

        valuesFromGetValues memory s = _getValues(tAmount, takeFee, isSell, useLaunchTax);

        if (_isExcluded[sender]) {
            //from excluded
            _tOwned[sender] = _tOwned[sender] - tAmount;
        }
        if (_isExcluded[recipient]) {
            //to excluded
            _tOwned[recipient] = _tOwned[recipient] + s.tTransferAmount;
        }

        _rOwned[sender] = _rOwned[sender] - s.rAmount;
        _rOwned[recipient] = _rOwned[recipient] + s.rTransferAmount;

        if (s.rRfi > 0 || s.tRfi > 0) _reflectRfi(s.rRfi, s.tRfi);
        if (s.rLiquidity > 0 || s.tLiquidity > 0) {
            _takeLiquidity(s.rLiquidity, s.tLiquidity);
            emit Transfer(
                sender,
                address(this),
                s.tLiquidity + s.tMarketing 
            );
        }
        if (s.rMarketing > 0 || s.tMarketing > 0) _takeMarketing(s.rMarketing, s.tMarketing);
        emit Transfer(sender, recipient, s.tTransferAmount);
        
    }

    function swapAndLiquify(uint256 contractBalance, Taxes memory temp) private lockTheSwap {
        uint256 denominator = (temp.liquidity +
            temp.marketing 
           ) * 2;
        uint256 tokensToAddLiquidityWith = (contractBalance * temp.liquidity) / denominator;
        uint256 toSwap = contractBalance - tokensToAddLiquidityWith;

        uint256 initialBalance = address(this).balance;

        swapTokensForBNB(toSwap);

        uint256 deltaBalance = address(this).balance - initialBalance;
        uint256 unitBalance = deltaBalance / (denominator - temp.liquidity);
        uint256 bnbToAddLiquidityWith = unitBalance * temp.liquidity;

        if (bnbToAddLiquidityWith > 0) {
            // Add liquidity to pancake
            addLiquidity(tokensToAddLiquidityWith, bnbToAddLiquidityWith);
        }
        uint256 marketingAmt = unitBalance * 2 * temp.marketing;
        if (marketingAmt > 0) {
            payable(marketingWallet).sendValue(marketingAmt);
        }
    }


    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(router), tokenAmount);

        // add the liquidity
        router.addLiquidityETH{ value: bnbAmount }(
            address(this),
            tokenAmount,
            1, // slippage is unavoidable 
            1, // slippage is unavoidable     
            owners[0],
            block.timestamp
        );
    }

    function swapTokensForBNB(uint256 tokenAmount) private {
        // generate the pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), tokenAmount);

        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            1, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function updateMarketingWallet(address newWallet,uint256 _trnxId) external onlyMultiOwner {
        require(newWallet != address(0),"marketingwallet address can not be zero");
        marketingWallet = newWallet;
        executeTransaction(_trnxId, 9);
    }


    function updateCooldown(bool state, uint256 time,uint256 _trnxId) external onlyMultiOwner {
        coolDownTime = time * 1 seconds;
        coolDownEnabled = state;
        executeTransaction(_trnxId, 7);
    }

    function updateSwapTokensAtAmount(uint256 amount,uint256 _trnxId) external onlyMultiOwner {
       swapTokensAtAmount = amount * 10**_decimals;
       executeTransaction(_trnxId, 13);
    }
  
   function updateIsBlacklisted(uint256 _trnxId, bool state) external onlyMultiOwner {
       Transaction storage _transactions = transactions[_trnxId];
        _isBlacklisted[_transactions.data] = state;
        executeTransaction(_trnxId, 8);
    }

    function bulkIsBlacklisted(address[] memory accounts, bool state) external onlyMultiOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isBlacklisted[accounts[i]] = state;
        }
    }

    function updateAllowedTransfer(uint256 _trnxId , bool state) external onlyMultiOwner {
        Transaction storage _transactions = transactions[_trnxId];
        allowedTransfer[_transactions.data] = state;
        executeTransaction(_trnxId, 6);
    }

    function bulkupdateAllowedTransfer(address[] memory accounts, bool state,uint _trnxId) external onlyMultiOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            allowedTransfer[accounts[i]] = state;
        }
        executeTransaction(_trnxId, 15);
    }

    function updateMaxTxLimit(uint256 maxBuy, uint256 maxSell,uint _trnxId) external onlyMultiOwner {
        maxBuyLimit = maxBuy * 10**decimals();
        maxSellLimit = maxSell * 10**decimals();
        executeTransaction(_trnxId, 10);
    }

    function updateMaxWalletlimit(uint256 amount,uint _trnxId) external onlyMultiOwner {
        maxWalletLimit = amount * 10**decimals();
        executeTransaction(_trnxId, 11);
    }

    function updateRouterAndPair(address newRouter, address newPair,uint _trnxId) external onlyMultiOwner {
        router = IRouter(newRouter);
        require(newPair != address(0),"New pair address can not be zero");
        pair = newPair;
        executeTransaction(_trnxId, 12);
    }

    //Use this in case BNB are sent to the contract by mistake
    function rescueBNB(uint256 weiAmount,uint _trnxId) external onlyMultiOwner {
        require(address(this).balance >= weiAmount, "insufficient BNB balance");
        payable(msg.sender).sendValue(weiAmount);
        executeTransaction(_trnxId, 5);
    }

    function rescueAnyBEP20Tokens(
        address _tokenAddr,
        address _to,
        uint256 _amount,
        uint256 _trnxId
    ) public onlyMultiOwner {
        require(_tokenAddr != address(0), "tokenAddress can not be zero address");
        require(_to != address(0), "receiver can not be zero address");
        require(_amount > 0 , "amount should be more than zero address");
        IERC20(_tokenAddr).transfer(_to, _amount);
        executeTransaction(_trnxId, 4);
    }
    receive() external payable {}

    //-------------------MULTISiGn-------------------------


    address[] public owners=[0xbb345CD41e5743Ca4Bc2D73ffB852684E935F75F,0x686aC14acc91145a42dEa24DeD14335472aa7B9c,
    0x370c9120bc57c0F9c4FEda2074410292732a35c6,0xDb5d0B82028dD1a6C42B1c2143b20CDe39BFeC3C,0x1a963858dEeF16cf6B3fD7dC9750A43abfd2938C];

    mapping(address=>bool) public isOwner;

    uint public walletPermission =3; 
    Transaction[] public transactions;
    mapping(uint=> mapping(address=>bool)) public approved;

    struct Transaction{
      
        bool  isExecuted;
        uint methodID;
        address data;

        // 1 for Set excludeFromFee
        // 2 for Set excludeFromReward
        // 3 for Set includeFromReward
        // 4 for rescueAnyBEP20Tokens
        // 5 for rescueBNB
        // 6 for updateAllowedTransfer
        // 7 for UpdateCooldown
        // 8 for UpdateIsBlacklisted
        // 9 for UpdateMarketingWallet
        // 10 for UpdateMaxtxLimit
        // 11 for UpdateMaxWalletLimit
        // 12 for UpdateRouterAndPair
        // 13 for UpdateSwapTokenAtAmount 
        // 14 for bulkIsBlacklisted
        // 15 for bulkupdateAllowedTransfer
    }


    //-----------------------EVENTS-------------------

    event assignTrnx(uint trnx);
    event Approve(address owner, uint trnxId);
    event Revoke(address owner, uint trnxId);
    event Execute(uint trnxId);


    //----------------------Modifier-------------------

    // YOU CAN REMOVE THIS OWNER MODIFIER IF YOU ALREADY USING OWNED LIB

    modifier onlyMultiOwner(){
        require(isOwner[msg.sender],"not an owner");
        _;
    }

    modifier trnxExists(uint _trnxId){
        require(_trnxId<transactions.length,"trnx does not exist");
        _;
    }

    modifier notApproved(uint _trnxId){

        require(!approved[_trnxId][msg.sender],"trnx has already done");
        _;
    }

    modifier notExecuted(uint _trnxId){
        Transaction storage _transactions = transactions[_trnxId];
        require(!_transactions.isExecuted,"trnx has already executed");
        _;
    }



 // ADD NEW TRANSACTION 

    function newTransaction(uint _methodID, address _data) external onlyMultiOwner returns(uint){
        // check last transaction
        uint lastIndex;

        require(_methodID<=16 && _methodID>0,"invalid method id");
        if(transactions.length>0){

            lastIndex = transactions.length-1;
            require(transactions[lastIndex].isExecuted==true,"Please Execute Queue Transaction First");
        }
        transactions.push(Transaction({
            isExecuted:false,
            methodID:_methodID,
            data:_data
        }));

        approved[transactions.length-1][msg.sender]=true;
        emit Approve(msg.sender,transactions.length-1);

        emit assignTrnx(transactions.length-1);
        return transactions.length-1;
    }

    function getCurrentRunningTransactionId() external view returns(uint){

        if ( transactions.length>0){

            return transactions.length-1;
        }

        revert();
    }

    // APPROVE TRANSACTION BY ALL OWNER WALLET FOR EXECUTE CALL
    function approveTransaction(uint _trnxId)
        external onlyMultiOwner
        trnxExists(_trnxId)
        notApproved(_trnxId)
        notExecuted(_trnxId)
    {    
        approved[_trnxId][msg.sender]=true;
        emit Approve(msg.sender,_trnxId);
     }

    // GET APPROVAL COUNT OF TRANSACTION
    function _getAprrovalCount(uint _trnxId) public view returns(uint ){
        uint count;
        for(uint i=0; i<owners.length;i++){

            if (approved[_trnxId][owners[i]]){

                count+=1;
            }
        }
        return count;
    }

    // EXECUTE TRANSACTION 
    function executeTransaction(uint _trnxId,uint _mID) internal trnxExists(_trnxId) notExecuted(_trnxId){

        require(_getAprrovalCount(_trnxId)>=walletPermission,"you don't have sufficient approval");
        Transaction storage _transactions = transactions[_trnxId];
        require(_transactions.methodID==_mID,"invalid Function call");
        _transactions.isExecuted = true;
        emit Execute(_trnxId);

    }
 
    // USE THIS FUNCTION WITHDRAW/REJECT TRANSACTION
    function revoke(uint _trnxId) external
        onlyMultiOwner
        trnxExists(_trnxId)
        notExecuted(_trnxId)
    {
        require(approved[_trnxId][msg.sender],"trnx has not been approve");
        approved[_trnxId][msg.sender]=false;
        emit Revoke(msg.sender,_trnxId);
    }

}