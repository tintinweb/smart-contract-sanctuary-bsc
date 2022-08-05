/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IUniswapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniSwapRouter {
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract TradeProtection is IERC20, Ownable {

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint256 private _totalSupply;
    uint256 public constant MaxTotalAmount = 3000_0000 * 10**18;

    address private tpcPair;
    address public marketAddr;
    address public luckyBonusAddr;
    address public wethAddr;
    address public immutable blackHoleAddr = address(0xdead);

    bool inSwapToBNB;
    bool public feeOn;
    bool public tradeSwitch;
    uint256 public tradingTime;

    uint256 public luckyUserBuyAmount = 0.2 ether;
    uint256 public marketAmountToShare = 126 * 10 ** 18;
    uint256 private marketTPCAmount ;

    uint8[3] public feeSetting = [4, 4, 4];

    mapping (address => bool) private controller;
    mapping (address => bool) private _isExcludedFee;

    IUniSwapRouter uniswapRouter;

    modifier onlyController () {
        require(controller[_msgSender()] , "TPC: only by controller.");
        _;
    }

    modifier lockTheSwap {
        inSwapToBNB = true;
        _;
        inSwapToBNB = false;
    }

    constructor() {

        _name = "TradeProtection";
        _symbol = "TPC";

        controller[_msgSender()] = true;

        _isExcludedFee[_msgSender()] = true;
        _isExcludedFee[address(this)] = true;

        luckyBonusAddr = msg.sender;
        marketAddr = address(0x790c6c4d902Ffc3190BFb0cf89141b2D22f03275);

        uniswapRouter = IUniSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        wethAddr = uniswapRouter.WETH();
        tpcPair = IUniswapFactory(uniswapRouter.factory()).createPair(address(this), wethAddr);
        //
        _mint(msg.sender , MaxTotalAmount);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function getPairAddr() external view returns(address){
        return tpcPair;
    }

    function setController(address addr_,bool switch_) external onlyController {
        controller[addr_] = switch_;
    }

    function setFee(uint8 buyFee_, uint8 sellFee_, uint8 transferFee_) external onlyController {
        require(buyFee_ + sellFee_ + transferFee_ <= 100, "Invalid fee");
        feeSetting[0] = buyFee_;
        feeSetting[1] = sellFee_;
        feeSetting[2] = transferFee_;
    }

    function getFee() external view returns(uint8[3] memory feeArray) {
        feeArray = feeSetting;
    }

    function setLuckyUserBuyAmount(uint amount_) public onlyController {
        luckyUserBuyAmount = amount_;
    }

    function setMarketAmountToShare(uint amount_) public onlyController {
        marketAmountToShare = amount_;
    }

    function setMarketAddr(address marketAddr_) external onlyController {
        marketAddr = marketAddr_;
    }

    function setTradeSwitch(bool switch_) external onlyController {
        tradeSwitch = switch_;
        // set trading beging time
        if (switch_ && tradingTime == 0) {
            tradingTime = block.timestamp;
        }
    }

    function excludeFeeBatch(address[] calldata accounts, bool _switch) public onlyController {

        for(uint256 i = 0; i < accounts.length; i ++) {
            _isExcludedFee[accounts[i]] = _switch;
        }
    }

    function setFeeOn(bool feeOn_) external onlyController {
        feeOn = feeOn_;
    }

    function getMarketTPCAmount() external view onlyController returns (uint) {
        return marketTPCAmount;
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
    unchecked {
        _approve(owner, spender, currentAllowance - subtractedValue);
    }
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(from != to, "ERC20: from = to");

        // _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");

    unchecked {
        _balances[from] = fromBalance - amount;
    }

        require(tradeSwitch || _isExcludedFee[from] || _isExcludedFee[to], "Trade is not open.");

        address pair = tpcPair;

        if (marketTPCAmount >= marketAmountToShare && balanceOf(address(this)) >= marketAmountToShare) swapAndShareToMarket();

        if(feeOn && !(_isExcludedFee[from] || _isExcludedFee[to])){
            // judge is start trading
            uint8[3] memory feeRate = feeSetting;
            if (tradingTime + 6 hours > block.timestamp) {
                feeRate = [5, 12, 0];
            }
            uint256 fee;
            bool isTrade = true;
            //  buy in or remove liquidity
            if(from == pair){
                //  buy in fee
                fee = amount * feeRate[0] / 100;
                // is not share to market
                if (!inSwapToBNB) {
                    // path
                    address[] memory path = new address[](2);
                    path[0] = wethAddr;
                    path[1] = address(this);
                    //
                    uint256[] memory amounts = uniswapRouter.getAmountsIn(amount, path);
                    if (amounts[0] > luckyUserBuyAmount) {
                        luckyBonusAddr = to;
                    }
                }
            }else if(to == pair){
                fee = amount * feeRate[1] / 100;
            }else {
                isTrade = false;
                fee = amount * feeRate[2] / 100;
            }

            if (fee > 0 && !inSwapToBNB) {
                amount -= fee;
                handleTakeFee(isTrade ? pair : from, fee);
            }
        }

        _balances[to] += amount;
        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function handleTakeFee(address from_, uint256 fee_) private {
        uint luckyShare;
        uint marketShare;
        uint blackHoleShare;
        // 10% destory ，25% lucky，65% market
        if (tradingTime + 6 hours > block.timestamp) {
            luckyShare =  fee_ * 25 / 100;
            blackHoleShare = fee_ * 10 / 100;
            marketShare = fee_ - luckyShare + blackHoleShare;
        } else {
            luckyShare = fee_ * 3 / 10 ;
            blackHoleShare = luckyShare;
            marketShare = (fee_ - luckyShare * 2);
        }

        _balances[blackHoleAddr] += luckyShare;
        _balances[luckyBonusAddr] += luckyShare;
        _balances[address(this)] += marketShare;
        // increase market TPC Amount
        marketTPCAmount += marketShare;

        emit Transfer(from_, blackHoleAddr, luckyShare);
        emit Transfer(from_, luckyBonusAddr, luckyShare);
        emit Transfer(from_, address(this), marketShare);

    }

    function swapAndShareToMarket() private lockTheSwap {
        // path
        address[] memory path = new address[](2);
        //
        path[0] = address(this);
        path[1] = wethAddr;
        // approve
        _approve(address(this), address(uniswapRouter), marketTPCAmount);
        // swap
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            marketTPCAmount,
            0,
            path,
            marketAddr,
            block.timestamp + 20 minutes
        );
        marketTPCAmount = 0;
    }

    function _mint(address account, uint256 amount) private {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) private {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
    unchecked {
        _balances[account] = accountBalance - amount;
    }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
        unchecked {
            _approve(owner, spender, currentAllowance - amount);
        }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {}


    function moveToken(address token, uint256 amount) public onlyController {
        require(IERC20(token).transfer(msg.sender, amount));
    }

    // Withdraw ETH that gets stuck in contract by accident
    function withdrawEther(uint256 amount) external onlyController {
        require(amount < address(this).balance, "Insufficient balance");
        payable(msg.sender).transfer(amount);
    }

}