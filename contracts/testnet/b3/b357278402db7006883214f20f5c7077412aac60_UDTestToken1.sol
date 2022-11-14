// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./SafeMath.sol";

import "./DexRouter.sol";
import "./ABDKMathQuad.sol";

contract UDTestToken1 is IERC20 {
    using SafeMath for uint256;

    // Pancakeswap 0x10ED43C718714eb63d5aA57B78B54704E256024E (testnet: 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3)
    //address private constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    // WBNB 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c (testnet: 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd)
    //address private constant BNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    // Pancakeswap 0x10ED43C718714eb63d5aA57B78B54704E256024E (testnet: 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3)
    address private constant ROUTER = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    // BUSD 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56 (testnet: 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7)
    address private constant BUSD = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;

    uint256 public Tax = 100;
    uint256 public TRANSACTION_LIMIT = 100000000000000000000;
    uint256 public Cycle = 0;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    mapping(address => bool) private excludedFromTax;
    mapping(address => bool) private lpPairs;
    address private _owner;

    DexRouter router;

    uint256 public target_buy;
    uint256 public target_sell;
    uint256 public _delta;
    uint256 public _deltafactor;
    uint256 public delta_buy;
    uint256 public delta_sell;
    uint256 public Rate;
    uint256 public BUSDEarned;
    uint256 public RateMod;
    bool public can_buy;
    bool public can_sell;
    bool public canClaim;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor(uint256 _supply) {
        _name = "UD Test BUSD1";
        _symbol = "UDTBUSD1";
        _supply = 1000000000;

        _transferOwnership(msg.sender);

        _totalSupply += _supply.mul((10**decimals()));
        _balances[_owner] += _supply.mul((10**decimals()));

        excludedFromTax[_owner] = true;
        excludedFromTax[ROUTER] = true;
        excludedFromTax[address(this)] = true;

        router = DexRouter(ROUTER);
        _approve(address(this), ROUTER, totalSupply());

        target_buy = 0;
        target_sell = 0;
        _delta = 0;
        _deltafactor = 1;
        can_buy = false;
        can_sell = false;
        canClaim = false;
    }

    modifier onlyOwner() {
        require(
            _owner == msg.sender || msg.sender == address(this),
            "Ownable: caller is not the owner"
        );
        _;
    }

    function manageTrading(uint256 _type, bool _status) external onlyOwner {
        if (_type == 0) {
            can_buy = _status;
        } else {
            can_sell = _status;
        }
    }

    function setTax(uint256 tax) public onlyOwner {
        require(tax >= 0, "Tax must be zero or greater");
        require(tax <= 10, "Tax must be 10 or less");
        Tax = tax;
    }

    function setDelta(uint256 delta) public onlyOwner {
        require(delta >= 1, "Step size must be whole number greater than zero");
        _delta = delta;
        delta_buy = delta;
        delta_sell = delta_buy * 2;
        //With a deltafactor of 1: delta of 1 = 100%, 2 = 50%, 4 = 25%, 5 = 20%, 10 = 10%, 20 = 5%, 100 = 1%, 1000 = 0.1%, and so on
    }

    function setDeltaFactor(uint256 deltafactor) public onlyOwner {
        require(deltafactor >= 1, "Step size must be whole number greater than zero");
        _deltafactor = deltafactor;
    }

    function setTargets() public onlyOwner {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = BUSD;
        uint256 price = router.getAmountsOut(1000000000000000000, path)[1];
        target_buy = price.add(price.div(delta_buy).mul(_deltafactor));
        target_sell = price;
    }

    function setLPPair(address _pair) external onlyOwner {
        lpPairs[_pair] = true;
    }

    function resetTransactionLimit(uint256 TransactionLimit) external onlyOwner {
        TransactionLimit = 100000000000000000000;
        TRANSACTION_LIMIT = TransactionLimit;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 z
    ) public pure returns (uint256) {
        return
            ABDKMathQuad.toUInt(
                ABDKMathQuad.div(
                    ABDKMathQuad.mul(
                        ABDKMathQuad.fromUInt(x),
                        ABDKMathQuad.fromUInt(y)
                    ),
                    ABDKMathQuad.fromUInt(z)
                )
            );
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function allowance(address the_owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[the_owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _approve(
        address the_owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(
            the_owner != address(0),
            "ERC20: approve from the zero address"
        );
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[the_owner][spender] = amount;
        emit Approval(the_owner, spender, amount);
    }

    function ManAdjustTarget_buy() external onlyOwner {
        target_buy = target_buy.add(target_sell.div(delta_buy).mul(_deltafactor));
    }

    function setTarget_buy(uint256 Target_Buy) external onlyOwner {
        target_buy = Target_Buy;
    }

    function ManAdjustTarget_sell() external onlyOwner {
        target_sell = target_sell.add(target_buy.div(delta_sell).mul(_deltafactor));
    }

    function setTarget_sell(uint256 Target_Sell) external onlyOwner {
        target_sell = Target_Sell;
    }

    function adjustTarget_buy() private {
        target_buy = target_buy.add(target_sell.div(delta_buy).mul(_deltafactor));
    }

    function adjustTarget_sell() private {
        target_sell = target_sell.add(target_buy.div(delta_sell).mul(_deltafactor));
    }

    function adjustCycle() private {
        Cycle = Cycle + 1;
    }

    function setCycle(uint256 cycle) external {
        Cycle = cycle;
    }

    function processTransfers(
        address _sender,
        address _recipient,
        uint256 _amount
    ) private {
        if (
            excludedFromTax[msg.sender] ||
            excludedFromTax[_sender] ||
            (!lpPairs[_recipient] && !lpPairs[_sender])
        ) {
            _transfer(_sender, _recipient, _amount);
        } else {
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = BUSD;
            uint256 tokenPrice = router.getAmountsOut(1 * 10**18, path)[1];

            if (tokenPrice > target_buy && can_buy) {
                can_buy = false;
                can_sell = true;
                adjustTarget_buy();
            } else if (tokenPrice < target_sell && can_sell) {
                can_sell = false;
                can_buy = true;
                adjustTarget_sell();
                TRANSACTION_LIMIT = TRANSACTION_LIMIT + 25000000000000000000;
                adjustCycle();
            }

            uint256 investment = (tokenPrice * _amount).div(10**18);
            require(investment <= TRANSACTION_LIMIT);

            // Check Sell
            if (lpPairs[_recipient]) {
                require(can_sell, "cannot sell");
            }
            // Check Buy
            else if (lpPairs[_sender]) {
                require(can_buy, "cannot buy");
            }

            uint256 taxFee = mulDiv(_amount, Tax, 100);
            _transfer(_sender, _recipient, _amount.sub(taxFee));
            _transfer(_sender, address(this), taxFee);
        }
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function accumulateFees() external onlyOwner {
        uint256 tokenBalance = balanceOf(address(this));
        swapTokens(tokenBalance, _owner);
        }

    function transfer(address _recipient, uint256 _amount)
        public
        override
        returns (bool)
    {
        processTransfers(msg.sender, _recipient, _amount);
        return true;
    }

    function transferFrom(
        address the_owner,
        address _recipient,
        uint256 _amount
    ) public override returns (bool) {
        processTransfers(the_owner, _recipient, _amount);

        uint256 currentAllowance = allowance(the_owner, msg.sender);
        require(
            currentAllowance >= _amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(the_owner, msg.sender, currentAllowance.sub(_amount));
        }

        return true;
    }

    function swapTokens(uint256 _amount, address _to) private {
        require(_amount > 0, "amount less than 0");
        require(_to != address(0), "address equal to 0");

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = BUSD;
        uint256 amountWethMin = router.getAmountsOut(_amount, path)[1];

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _amount,
            amountWethMin,
            path,
            _to,
            block.timestamp
        );
    }

    function excludeFromFee(address _user, bool _exclude) external onlyOwner {
        require(_user != address(0));
        excludedFromTax[_user] = _exclude;
    }

    function setRate(uint256 rate) external onlyOwner {
        Rate = rate;
    }

    function setRateMod(uint256 rateMod) external onlyOwner{
        RateMod = rateMod;
    }

    function setBUSDBalance(uint256) private {
        BUSDEarned = (balanceOf(msg.sender) * Rate) / RateMod;
        //Set Rate = whole # by moving decimal to right. Set RateMod = 1 with same # of zeroes as decimal places moved
        //Ex: Token value $0.01234, rate = 1234, RateMod = 100000
    }

    function ApproveDeposit(address spender, uint256) public virtual returns (bool) {
        _approve(msg.sender, spender, balanceOf(msg.sender));
        return true;
    }

    function depositUD() private {
        transferFrom(msg.sender, _owner, balanceOf(msg.sender));
    }

    function claimBUSD() private {
        setBUSDBalance(BUSDEarned);
        address recipient = msg.sender;
        payable(recipient).transfer(BUSDEarned);
    }

    function setClaim(bool _bool) external onlyOwner {
        canClaim = _bool;
    }

    function claimPayout() public{
        require (canClaim = true);
        ApproveDeposit(msg.sender, balanceOf(msg.sender));
        depositUD();
        claimBUSD();
    }

}