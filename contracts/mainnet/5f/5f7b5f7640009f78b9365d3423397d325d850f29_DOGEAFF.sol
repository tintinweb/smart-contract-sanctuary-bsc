/**
 *Submitted for verification at BscScan.com on 2023-02-05
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

contract DOGEAFF is Context, IBEP20, Ownable {
    using Address for address payable;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;

    struct RefererList {
        uint256 tokenEarned;
        address[] listRef;
    }

    mapping(address => address) public _refererOf;
    mapping(address => RefererList) public _refererList;
    mapping(address => uint256) public _tokenEarnFromRef;

    mapping(address => uint256) private _ticketNumber;

    address[] private _excluded;

    bool public tradingEnabled;
    bool private swapping;
    bool private lottering;

    IRouter public router;
    address public pair;

    uint8 private constant _decimals = 9;
    uint256 private constant MAX = ~uint256(0);

    uint256 private _tTotal = 100 *10**15 * 10**_decimals;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));

    uint256 public swapTokensAtAmount = 1e14 * 10**9;
    uint256 public tokensPerTicket = 1e6 * 10**9;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    address public marketingWallet = 0x3fBb61699038C4b136EcaC6D56575637f9ED1fb3;
    address public lotteryWallet = 0x7706CA6Af3FD2E6C524819b8585b3B27cD74d36D;
    address public reserveWallet = 0xEeD8d8a433F7734292f4e97042d93Ee00aA440ab;
    address public affiliateSM;
    address public lotterySM;

    string private constant _name = "Doge Affiliate";
    string private constant _symbol = "DOGAFF";

    struct Taxes {
        uint256 rfi;
        uint256 marketing;
        uint256 lottery;
        uint256 ref;
        uint256 reserve;
    }

    //2% reflection, 3% mkt, 1% lottery, 4% referer, 0% reverse  (10% tax if you sign via refer link https://dapp.dogeaffiliate.io)                                
    Taxes public taxesWithReferer = Taxes(2, 3, 1, 4, 0);
    //2% reflection, 3% mkt, 1% lottery, 0% referer, 6% reverse  (10% tax if you not sign via refer link  https://dapp.dogeaffiliate.io)
    Taxes public taxesWithoutReferer = Taxes(2, 3, 1, 0, 6); 

    struct TotFeesPaidStruct {
        uint256 rfi;
        uint256 marketing;
        uint256 lottery;
        uint256 ref;
        uint256 reserve;
    }

    TotFeesPaidStruct public totFeesPaid;

    struct valuesFromGetValues {
        uint256 rAmount;
        uint256 rTransferAmount;
        uint256 rRfi;
        uint256 rMarketing;
        uint256 rLottery;
        uint256 rRef;
        uint256 rReserve;
        uint256 tTransferAmount;
        uint256 tRfi;
        uint256 tMarketing;
        uint256 tLottery;
        uint256 tRef;
        uint256 tReserve;
    }

    modifier lockTheSwap() {
        swapping = true;
        _;
        swapping = false;
    }

    modifier isAdmin() {
        // both owner and mkt are authorized to make changes
        require(owner() == msg.sender || msg.sender == marketingWallet, "Admin: caller is not the owner or admin");
        _;
    }

    modifier isAffiliateSM() {
        // both owner and affiliate are authorized to make changes
        require(owner() == msg.sender || msg.sender == marketingWallet || msg.sender == affiliateSM, "Caller is not the admin or lottery contract");
        _;
    }

    modifier isLottery() {
        // both owner and lottery are authorized to make changes
        require(owner() == msg.sender || msg.sender == marketingWallet || msg.sender == lotterySM, "Caller is not the admin or affiliate contract");
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

    // when lottery open, start count increase tickets
    function setStateLottery(bool state) external isAdmin {
        lottering = state;
    }

    function tokenFromReflection(uint256 rAmount) public view returns (uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate = _getRate();
        return rAmount / currentRate;
    }

    function getTicketNumber(address account) public view returns (uint256) {
        return _ticketNumber[account];
    }

    function increaseTicketNumberBuyPCS(address account, uint256 value) private
    {
        require(value > 0, "Ticket: Ticket number must be greater than zero");
        _ticketNumber[account] = _ticketNumber[account] + value;
    }

    function increaseTicketNumber(address account, uint256 value) public isLottery
    {
        require(value > 0, "Ticket: Ticket number must be greater than zero");
        _ticketNumber[account] = _ticketNumber[account] + value;
    }

    function decreaseTicketNumber(address account, uint256 subtractedValue)
        public isLottery
    {
        uint256 currentTicket = _ticketNumber[account];
        require(currentTicket >= subtractedValue, "Ticket: Not enough tickets");
        _ticketNumber[account] = _ticketNumber[account] - subtractedValue;
    }

    function updateTokensPerTicket(uint256 amount) external isAdmin {
        require(amount <= 1e15, "Amount must be less than 1% supply");
        tokensPerTicket = amount * 10**_decimals;
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

    function _takeLottery(uint256 rLottery, uint256 tLottery) private {
        totFeesPaid.lottery += tLottery;

        if (_isExcluded[address(this)]) {
            _tOwned[address(this)] += tLottery;
        }
        _rOwned[address(this)] += rLottery;
    }

    function _takeMarketing(uint256 rMarketing, uint256 tMarketing) private {
        totFeesPaid.marketing += tMarketing;

        if (_isExcluded[address(this)]) {
            _tOwned[address(this)] += tMarketing;
        }
        _rOwned[address(this)] += rMarketing;
    }

    function _takeRef(address sender, address recipient, uint256 rRef, uint256 tRef) private {
        totFeesPaid.ref += tRef;
        if (_isExcluded[address(this)]) {
            _tOwned[address(this)] += tRef;
        }
        if (recipient == pair) {  // sell
            _rOwned[_refererOf[sender]] += rRef;
            _refererList[_refererOf[sender]].tokenEarned += tRef;
            emit Transfer(
                sender,
                _refererOf[sender],
                tRef
            );
        } 
        if (sender == pair) {  // buy
            _rOwned[sender] = _rOwned[sender] - rRef;
            _rOwned[_refererOf[recipient]] += rRef;
            _refererList[_refererOf[recipient]].tokenEarned += tRef;
            emit Transfer(
                sender,
                _refererOf[recipient],
                tRef
            );
        }    
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
        bool shareReferer
    ) private view returns (valuesFromGetValues memory to_return) {
        to_return = _getTValues(tAmount, takeFee, shareReferer);
        (
            to_return.rAmount,
            to_return.rTransferAmount,
            to_return.rRfi,
            to_return.rMarketing,
            to_return.rLottery
        ) = _getRValues1(to_return, tAmount, takeFee, _getRate());
        (to_return.rRef, to_return.rReserve) = _getRValues2(
            to_return,
            takeFee,
            _getRate()
        );

        return to_return;
    }

    function _getTValues(
        uint256 tAmount,
        bool takeFee,
        bool shareReferer
    ) private view returns (valuesFromGetValues memory s) {
        if (!takeFee) {
            s.tTransferAmount = tAmount;
            return s;
        }
        Taxes memory temp;
        if (shareReferer) temp = taxesWithReferer;
        else temp = taxesWithoutReferer;

        s.tRfi = (tAmount * temp.rfi) / 100;
        s.tMarketing = (tAmount * temp.marketing) / 100;
        s.tLottery = (tAmount * temp.lottery) / 100;
        s.tRef = (tAmount * temp.ref) / 100;
        s.tReserve = (tAmount * temp.reserve) / 100;
        s.tTransferAmount =
            tAmount -
            s.tRfi -
            s.tMarketing -
            s.tLottery -
            s.tRef -
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
            uint256 rLottery
        )
    {
        rAmount = tAmount * currentRate;

        if (!takeFee) {
            return (rAmount, rAmount, 0, 0, 0);
        }

        rRfi = s.tRfi * currentRate;
        rMarketing = s.tMarketing * currentRate;
        rLottery = s.tLottery * currentRate;
        uint256 rRef = s.tRef * currentRate;
        uint256 rReserve = s.tReserve * currentRate;
        rTransferAmount =
            rAmount -
            rRfi -
            rMarketing -
            rLottery -
            rRef -
            rReserve;
        return (rAmount, rTransferAmount, rRfi, rMarketing, rLottery);
    }

    function _getRValues2(
        valuesFromGetValues memory s,
        bool takeFee,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256 rRef,uint256 rReserve
        )
    {
        if (!takeFee) {
            return (0,0);
        }

        rRef = s.tRef * currentRate;
        rReserve = s.tReserve * currentRate;
        return (rRef,rReserve);
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
            swapAndLiquify();
        }
        bool takeFee = true;
        bool shareReferer = false;
        if (swapping || _isExcludedFromFee[from] || _isExcludedFromFee[to]) takeFee = false;
        if (to != pair && from != pair) takeFee = false; // normal transfer
        if ((_refererOf[to] != address(0) && from == pair) || ((_refererOf[from] != address(0) && to == pair))) shareReferer = true;
        if (from == pair && lottering) { //buy inc ticket lottery
            if (amount >= tokensPerTicket) {
                uint256 number = amount / tokensPerTicket;
                if (number >0) increaseTicketNumberBuyPCS(to, number);
            }
        }
        _tokenTransfer(from, to, amount, takeFee, shareReferer);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool shareReferer
    ) private {

        valuesFromGetValues memory s = _getValues(tAmount, takeFee, shareReferer);
        
        if (_isExcluded[sender]) {
            //from excluded
            _tOwned[sender] = _tOwned[sender] - tAmount;
        }
        if (_isExcluded[recipient]) {
            //to excluded
            _tOwned[recipient] = _tOwned[recipient] + s.tTransferAmount;
        }

        // rAmout rTranferAmout 
        _rOwned[sender] = _rOwned[sender] - s.rAmount;
        _rOwned[recipient] = _rOwned[recipient] + s.rTransferAmount;

        if (s.rRfi > 0 || s.tRfi > 0) _reflectRfi(s.rRfi, s.tRfi);
        if (s.rLottery > 0 || s.tLottery > 0) {
            _takeLottery(s.rLottery, s.tLottery);
            emit Transfer(
                sender,
                address(this),
                s.tLottery + s.tMarketing + s.tReserve
            );
        }
        if (s.rMarketing > 0 || s.tMarketing > 0) _takeMarketing(s.rMarketing, s.tMarketing);
        if (s.rRef > 0 || s.tRef > 0) { 
            _takeRef(sender, recipient, s.rRef, s.tRef);         
        }
        if (s.rReserve > 0 || s.tReserve > 0) _takeReserve(s.rReserve, s.tReserve);
        emit Transfer(sender, recipient, s.tTransferAmount);
    }

    function swapAndLiquify() private lockTheSwap {
        uint256 denominator = (totFeesPaid.lottery +
            totFeesPaid.marketing +
            totFeesPaid.reserve);

        if (denominator == 0){
            return;
        }
        uint256 contractBalance = balanceOf(address(this));

        swapTokensForBNB(contractBalance);

        uint256 unitBalance = address(this).balance;

        uint256 marketingAmt = unitBalance * totFeesPaid.marketing / denominator;
        if (marketingAmt > 0) {
            payable(marketingWallet).sendValue(marketingAmt);
        }

        uint256 lotteryAmt = unitBalance * totFeesPaid.lottery / denominator;
        if (lotteryAmt > 0) {
            payable(lotteryWallet).sendValue(lotteryAmt);
        }

        uint256 reserveAmt = unitBalance * totFeesPaid.reserve / denominator;
        if (reserveAmt > 0) {
            payable(reserveWallet).sendValue(reserveAmt);
        }
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

    function setRefererWallet(address register, address referer) external isAffiliateSM {
        require(referer != address(0),"Referer Address cannot be zero address");
        require(register != address(0),"register Address cannot be zero address");
        require(register != referer,"Referer Address cannot be yourself");
        require(_refererOf[register] == address(0),"Referer address only can set 1 time");
        
        _refererOf[register] = referer;
        _refererList[referer].listRef.push(register);
    }

    function updateLoterySM(address newWallet) external isAdmin {
        require(newWallet != address(0),"Fee Address cannot be zero address");
        lotterySM = newWallet;
    }

    function updateAffiliateSM(address newWallet) external isAdmin {
        require(newWallet != address(0),"Fee Address cannot be zero address");
        affiliateSM = newWallet;
    }

    function updateMarketingWallet(address newWallet) external onlyOwner {
        require(newWallet != address(0),"Fee Address cannot be zero address");
        marketingWallet = newWallet;
    }

    function updateReserveWallet(address newWallet) external onlyOwner {
        require(newWallet != address(0),"Fee Address cannot be zero address");
        reserveWallet = newWallet;
    }

    function updateLotteryWallet(address newWallet) external onlyOwner {
        require(newWallet != address(0),"Fee Address cannot be zero address");
        lotteryWallet = newWallet;
    }

    function updateSwapTokensAtAmount(uint256 amount) external isAdmin {
        require(amount <= 1e15, "Cannot set swap threshold amount higher than 1% of tokens");
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