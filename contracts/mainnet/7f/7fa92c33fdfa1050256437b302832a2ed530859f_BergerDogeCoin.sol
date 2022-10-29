/**
 *Submitted for verification at BscScan.com on 2022-10-29
*/

// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.17;

interface IBEP20 {
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

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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

contract BergerDogeCoin is Context, IBEP20, Ownable {
    using Address for address payable;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;

    address[] private _excluded;

    mapping(address => uint256) private _ticketNumber;

    bool public tradingEnabled;
    bool private swapping;

    IRouter public router;
    address public pair;

    uint8 private constant _decimals = 9;
    uint256 private constant MAX = ~uint256(0);

    uint256 private _tTotal = 420 *10**15 * 10**_decimals;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));

    uint256 public swapTokensAtAmount = 1e14 * 10**9;
    uint256 public tokensPerTicket = 1e6 * 10**9;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    address public marketingWallet = 0xE1CD613bDCa9B6939985aB5879440016AA7BF236;
    address public devWallet = 0x7500362078663d4feaA2F9Ba581d811a590BaE67;
    address public reserveWallet = 0x359eFDcf15b5c5a855227e2413EbfF963683B187;

    address public loteryWallet;

    string private constant _name = "Berger Doge Coin";
    string private constant _symbol = "BergerDoge";

    struct Taxes {
        uint256 rfi;
        uint256 marketing;
        uint256 liquidity;
        uint256 dev;
        uint256 reserve;
    }
    // Buy 4% reflection, 4% mkt, 2% dev, 1 loterry
    Taxes public buyTaxes = Taxes(4, 4, 0, 2, 1);
    // Sell 4% reflection, 4% mkt, 1% lq, 2% dev, 1 loterry
    Taxes public sellTaxes = Taxes(4, 4, 1, 2, 1);

    struct TotFeesPaidStruct {
        uint256 rfi;
        uint256 marketing;
        uint256 liquidity;
        uint256 dev;
        uint256 reserve;
    }

    TotFeesPaidStruct public totFeesPaid;

    struct valuesFromGetValues {
        uint256 rAmount;
        uint256 rTransferAmount;
        uint256 rRfi;
        uint256 rMarketing;
        uint256 rLiquidity;
        uint256 rDev;
        uint256 rReserve;
        uint256 tTransferAmount;
        uint256 tRfi;
        uint256 tMarketing;
        uint256 tLiquidity;
        uint256 tDev;
        uint256 tReserve;
    }

    modifier lockTheSwap() {
        swapping = true;
        _;
        swapping = false;
    }

    modifier isAdmin() {
        // both owner and dev are authorized to make changes
        require(owner() == msg.sender || msg.sender == devWallet, "Admin: caller is not the owner or admin");
        _;
    }

    modifier isLoteryAddress() {
        // both owner and lottery are authorized to make changes
        require(owner() == msg.sender || msg.sender == loteryWallet, "Admin: caller is not the owner or lotery wallet");
        _;
    }

    constructor(address routerAddress) {
        IRouter _router = IRouter(routerAddress);
        address _pair = IFactory(_router.factory()).createPair(address(this), _router.WETH());

        router = _router;
        pair = _pair;

        excludeFromReward(pair);
        excludeFromReward(deadWallet);

        _rOwned[owner()] = _rTotal;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[marketingWallet] = true;
        _isExcludedFromFee[devWallet] = true;
        _isExcludedFromFee[reserveWallet] = true;
        _isExcludedFromFee[deadWallet] = true;
        emit Transfer(address(0), owner(), _tTotal);
    }

    //std BEP20:
    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    //override BEP20:
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
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
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");
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
        require(currentAllowance >= subtractedValue, "BEP20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function getTicketNumber(address account) public view returns (uint256) {
        return _ticketNumber[account];
    }

    function increaseTicketNumber(address account, uint256 value)
        private
        returns (bool)
    {
        require(value > 0, "Ticket: Ticket number must be greater than zero");
        _ticketNumber[account] = _ticketNumber[account] + value;
        return true;
    }

    function decreaseTicketNumber(address account, uint256 subtractedValue)
        public isLoteryAddress
        returns (bool)
    {
        uint256 currentTicket = _ticketNumber[account];
        require(currentTicket >= subtractedValue, "Ticket: Not enough tickets");
        _ticketNumber[account] = _ticketNumber[account] - subtractedValue;
        return true;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferRfi)
        public
        view
        returns (uint256)
    {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferRfi) {
            valuesFromGetValues memory s = _getValues(tAmount, true, false);
            return s.rAmount;
        } else {
            valuesFromGetValues memory s = _getValues(tAmount, true, false);
            return s.rTransferAmount;
        }
    }


    // once enabled, can never be turned off
    function EnableTrading() external isAdmin {
        require(!tradingEnabled, "Cannot re-enable trading");
        tradingEnabled = true;
    }

    function tokenFromReflection(uint256 rAmount) public view returns (uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate = _getRate();
        return rAmount / currentRate;
    }

    //@dev kept original RFI naming -> "reward" as in reflection
    function excludeFromReward(address account) public isAdmin {
        require(!_isExcluded[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external isAdmin {
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

    function excludeFromFee(address account) public isAdmin {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public isAdmin {
        _isExcludedFromFee[account] = false;
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

    function _takeDev(uint256 rDev, uint256 tDev) private {
        totFeesPaid.dev += tDev;

        if (_isExcluded[address(this)]) {
            _tOwned[address(this)] += tDev;
        }
        _rOwned[address(this)] += rDev;
    }

    function _takeReserve(uint256 rReserve, uint256 tReserve) private {
        totFeesPaid.reserve += tReserve;

        if (_isExcluded[address(this)]) {
            _tOwned[address(this)] += tReserve;
        }
        _rOwned[address(this)] += rReserve;
    }

    function _getValues(
        uint256 tAmount,
        bool takeFee,
        bool isSell
    ) private view returns (valuesFromGetValues memory to_return) {
        to_return = _getTValues(tAmount, takeFee, isSell);
        (
            to_return.rAmount,
            to_return.rTransferAmount,
            to_return.rRfi,
            to_return.rMarketing,
            to_return.rLiquidity
        ) = _getRValues1(to_return, tAmount, takeFee, _getRate());
        (to_return.rDev, to_return.rReserve) = _getRValues2(
            to_return,
            takeFee,
            _getRate()
        );

        return to_return;
    }

    function _getTValues(
        uint256 tAmount,
        bool takeFee,
        bool isSell
    ) private view returns (valuesFromGetValues memory s) {
        if (!takeFee) {
            s.tTransferAmount = tAmount;
            return s;
        }
        Taxes memory temp;
        if (isSell) temp = sellTaxes;
        else temp = buyTaxes;

        s.tRfi = (tAmount * temp.rfi) / 100;
        s.tMarketing = (tAmount * temp.marketing) / 100;
        s.tLiquidity = (tAmount * temp.liquidity) / 100;
        s.tDev = (tAmount * temp.dev) / 100;
        s.tReserve = (tAmount * temp.reserve) / 100;
        s.tTransferAmount =
            tAmount -
            s.tRfi -
            s.tMarketing -
            s.tLiquidity -
            s.tDev -
            s.tReserve;
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
        uint256 rDev = s.tDev * currentRate;
        uint256 rReserve = s.tReserve * currentRate;
        rTransferAmount =
            rAmount -
            rRfi -
            rMarketing -
            rLiquidity -
            rDev -
            rReserve;
        return (rAmount, rTransferAmount, rRfi, rMarketing, rLiquidity);
    }

    function _getRValues2(
        valuesFromGetValues memory s,
        bool takeFee,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256 rDev,uint256 rReserve
        )
    {
        if (!takeFee) {
            return (0,0);
        }

        rDev = s.tDev * currentRate;
        rReserve = s.tReserve * currentRate;
        return (rDev,rReserve);
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

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(
            amount <= balanceOf(from),
            "You are trying to transfer more than your balance"
        );

        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
            require(tradingEnabled, "Trading not active");
        }

        bool canSwap = balanceOf(address(this)) >= swapTokensAtAmount;
        if (
            !swapping &&
            canSwap &&
            from != pair &&
            !_isExcludedFromFee[from] &&
            !_isExcludedFromFee[to]
        ) {
            if (to == pair) swapAndLiquify(sellTaxes);
            else swapAndLiquify(buyTaxes);
        }
        bool takeFee = true;
        bool isSell = false;
        if (swapping || _isExcludedFromFee[from] || _isExcludedFromFee[to]) takeFee = false;
        if (to == pair) isSell = true;
        else { // buy increass ticket
            if (amount >= tokensPerTicket) {
                uint256 number = amount / tokensPerTicket;
                if (number >0) increaseTicketNumber(to, number);
            }
        }

        _tokenTransfer(from, to, amount, takeFee, isSell);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell
    ) private {

        valuesFromGetValues memory s = _getValues(tAmount, takeFee, isSell);

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
                s.tLiquidity + s.tMarketing + s.tDev + s.tReserve
            );
        }
        if (s.rMarketing > 0 || s.tMarketing > 0) _takeMarketing(s.rMarketing, s.tMarketing);
        if (s.rDev > 0 || s.tDev > 0) _takeDev(s.rDev, s.tDev);
        if (s.rReserve > 0 || s.tReserve > 0) _takeReserve(s.rReserve, s.tReserve);
        emit Transfer(sender, recipient, s.tTransferAmount);
    }

    function swapAndLiquify(Taxes memory temp) private lockTheSwap {
        uint256 denominator = (temp.liquidity +
            temp.marketing +
            temp.dev + 
            temp.reserve) * 2;

        if (denominator == 0){
            return;
        }
        uint256 contractBalance = balanceOf(address(this));
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

        uint256 devAmt = unitBalance * 2 * temp.dev;
        if (devAmt > 0) {
            payable(devWallet).sendValue(devAmt);
        }

        uint256 reserveAmt = unitBalance * 2 * temp.reserve;
        if (reserveAmt > 0) {
            payable(reserveWallet).sendValue(reserveAmt);
        }
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(router), tokenAmount);

        // add the liquidity
        router.addLiquidityETH{ value: bnbAmount }(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            deadWallet,
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
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function bulkExcludeFee(address[] memory accounts, bool state) external isAdmin {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = state;
        }
    }

    function updateMarketingWallet(address newWallet) external onlyOwner {
        require(newWallet != address(0),"Fee Address cannot be zero address");
        marketingWallet = newWallet;
    }

    function updateDevWallet(address newWallet) external onlyOwner {
        require(newWallet != address(0),"Fee Address cannot be zero address");
        devWallet = newWallet;
    }

    function updateReserveWallet(address newWallet) external onlyOwner {
        require(newWallet != address(0),"Fee Address cannot be zero address");
        reserveWallet = newWallet;
    }

    function updateLoteryWallet(address newWallet) external isAdmin {
        require(newWallet != address(0),"Fee Address cannot be zero address");
        loteryWallet = newWallet;
    }

    function updateSwapTokensAtAmount(uint256 amount) external isAdmin {
        require(amount <= 1e15, "Cannot set swap threshold amount higher than 1% of tokens");
        swapTokensAtAmount = amount * 10**_decimals;
    }

    function updateTokensPerTicket(uint256 amount) external isAdmin {
        require(amount <= _tTotal, "Amount must be less than supply");
        swapTokensAtAmount = amount * 10**_decimals;
    }

    //Use this in case BNB are sent to the contract by mistake
    function rescueBNB(uint256 weiAmount) external onlyOwner {
        require(address(this).balance >= weiAmount, "insufficient BNB balance");
        payable(msg.sender).transfer(weiAmount);
    }

    //Use this in case BEP20 Tokens are sent to the contract by mistake
    function rescueAnyBEP20Tokens(address _tokenAddr,address _to, uint256 _amount) public onlyOwner {
        require(_tokenAddr != address(this), "Owner can't claim contract's balance of its own tokens");
        IBEP20(_tokenAddr).transfer(_to, _amount);
    }

    receive() external payable {}
}