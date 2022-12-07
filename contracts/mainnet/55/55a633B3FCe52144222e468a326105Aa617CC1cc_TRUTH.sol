//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./Ownable.sol";
import "./IUniswapV2Router02.sol";

interface IFeeReceiver {
    function trigger() external;
}

interface ISwapper {
    function buy(address user) external payable;
    function sell(address user) external;
}

interface IPair {
    function sync() external;
}

/**
    Modular Upgradeable Token
    Token System Designed By DeFi Mark
 */
contract TRUTH is IERC20, Ownable {

    // total supply
    uint256 private _totalSupply = 11_200_000 * 10**18;

    // token data
    string private constant _name = 'Truth Seekers';
    string private constant _symbol = 'TRUTH';
    uint8  private constant _decimals = 18;

    // balances
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    // Swapper
    address public swapper;

    // Amount Burned
    uint256 public totalBurned;

    // Taxation on transfers
    uint256 public buyFee             = 0;
    uint256 public sellFee            = 1500;
    uint256 public transferFee        = 0;
    uint256 public constant TAX_DENOM = 10000;

    // permissions
    struct Permissions {
        bool isFeeExempt;
        bool isLiquidityPool;
        bool canSellBurn;
        bool isPauseExempt;
        bool isBlacklisted;
    }
    mapping ( address => Permissions ) public permissions;

    // Fee Recipients
    address public sellFeeRecipient;
    address public buyFeeRecipient;
    address public transferFeeRecipient;

    // Trigger Fee Recipients
    bool public triggerBuyRecipient = false;
    bool public triggerTransferRecipient = true;
    bool public triggerSellRecipient = false;

    // Ownership Functions
    bool public tradingPaused = true;

    // events
    event SetBuyFeeRecipient(address recipient);
    event SetSellFeeRecipient(address recipient);
    event SetTransferFeeRecipient(address recipient);
    event SetFeeExemption(address account, bool isFeeExempt);
    event SetCanSellBurn(address account, bool canSellBurn);
    event SetAutomatedMarketMaker(address account, bool isMarketMaker);
    event SetFees(uint256 buyFee, uint256 sellFee, uint256 transferFee);
    event SetSwapper(address newSwapper);
    event SetAutoTriggers(bool triggerBuy, bool triggerSell, bool triggerTransfer);

    constructor() {

        // exempt sender for tax-free initial distribution
        permissions[msg.sender].isFeeExempt = true;
        permissions[msg.sender].isPauseExempt = true;

        // initial supply allocation
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    /////////////////////////////////
    /////    ERC20 FUNCTIONS    /////
    /////////////////////////////////

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    
    function name() public pure override returns (string memory) {
        return _name;
    }

    function symbol() public pure override returns (string memory) {
        return _symbol;
    }

    function decimals() public pure override returns (uint8) {
        return _decimals;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /** Transfer Function */
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        if (msg.sender == recipient) {
            return _sell(amount, msg.sender);
        } else {
            return _transferFrom(msg.sender, recipient, amount);
        }
    }

    /** Transfer Function */
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        require(
            _allowances[sender][msg.sender] >= amount,
            'Insufficient Allowance'
        );
        _allowances[sender][msg.sender] -= amount;
        return _transferFrom(sender, recipient, amount);
    }


    /////////////////////////////////
    /////   PUBLIC FUNCTIONS    /////
    /////////////////////////////////

    function burn(uint256 amount) external returns (bool) {
        return _burn(msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) external returns (bool) {
        require(
            _allowances[account][msg.sender] >= amount,
            'Insufficient Allowance'
        );
        _allowances[account][msg.sender] -= amount;
        return _burn(account, amount);
    }

    function sell(uint256 amount) external returns (bool) {
        return _sell(amount, msg.sender);
    }

    function sellFor(uint256 amount, address recipient) external returns (bool) {
        return _sell(amount, recipient);
    }

    function buyFor(address account) external payable {
        ISwapper(swapper).buy{value: msg.value}(account);
    }

    receive() external payable {
        ISwapper(swapper).buy{value: address(this).balance}(msg.sender);
    }

    function sellBurn(
        uint256 amount,
        address to,
        address router,
        address receiveToken,
        uint256 excess
    ) external {
        require(
            permissions[msg.sender].canSellBurn == true,
            'Invalid Permissions'
        );
        require(
            to != address(0),
            'Invalid Params'
        );
        require(
            _balances[msg.sender] >= amount,
            'Insufficient Balance'
        );

        // Instantiate Router
        IUniswapV2Router02 _router = IUniswapV2Router02(router);

        if (amount > 0) {

            // allocate balance to address(this)
            _balances[msg.sender] -= amount;
            _balances[address(this)] += amount;
            emit Transfer(msg.sender, address(this), amount);

            // approve tokens for router
            _allowances[address(this)][router] = amount;

            // swap path
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = receiveToken;

            // sell tokens for underlying
            if (receiveToken == _router.WETH()) {
                _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                    amount,
                    0,
                    path,
                    to,
                    block.timestamp + 1000
                );
            } else {
                _router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    amount,
                    0,
                    path,
                    to,
                    block.timestamp + 1000
                );
            }

            // clear memory
            delete path;
        }

        // calculate amount to burn
        uint256 amountToBurn = amount + excess;

        // fetch pair address
        address pair = IUniswapV2Factory(_router.factory()).getPair(address(this), receiveToken);
        require(
            pair != address(0),
            'No Pair'
        );

        // ensure enough balance exists in the pair with at least 1 token extra
        require(
            _balances[pair] >= ( amountToBurn + 10**18 ),
            'Amount Exceeds Pair Balance Plus Min Reserve'
        );

        // burn tokens from the pair
        _burn(pair, amountToBurn);

        // sync the LP with the new values
        IPair(pair).sync();
    }

    /////////////////////////////////
    /////    OWNER FUNCTIONS    /////
    /////////////////////////////////

    function withdraw(address token) external onlyOwner {
        require(token != address(0), 'Zero Address');
        bool s = IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
        require(s, 'Failure On Token Withdraw');
    }

    function withdrawBNB() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }

    function setTransferFeeRecipient(address recipient) external onlyOwner {
        require(recipient != address(0), 'Zero Address');
        transferFeeRecipient = recipient;
        permissions[recipient].isFeeExempt = true;
        emit SetTransferFeeRecipient(recipient);
    }

    function setBuyFeeRecipient(address recipient) external onlyOwner {
        require(recipient != address(0), 'Zero Address');
        buyFeeRecipient = recipient;
        permissions[recipient].isFeeExempt = true;
        emit SetBuyFeeRecipient(recipient);
    }

    function setSellFeeRecipient(address recipient) external onlyOwner {
        require(recipient != address(0), 'Zero Address');
        sellFeeRecipient = recipient;
        permissions[recipient].isFeeExempt = true;
        emit SetSellFeeRecipient(recipient);
    }

    function registerAutomatedMarketMaker(address account) external onlyOwner {
        require(account != address(0), 'Zero Address');
        require(!permissions[account].isLiquidityPool, 'Already An AMM');
        permissions[account].isLiquidityPool = true;
        emit SetAutomatedMarketMaker(account, true);
    }

    function unRegisterAutomatedMarketMaker(address account) external onlyOwner {
        require(account != address(0), 'Zero Address');
        require(permissions[account].isLiquidityPool, 'Not An AMM');
        permissions[account].isLiquidityPool = false;
        emit SetAutomatedMarketMaker(account, false);
    }

    function setAutoTriggers(
        bool autoBuyTrigger,
        bool autoTransferTrigger,
        bool autoSellTrigger
    ) external onlyOwner {
        triggerBuyRecipient = autoBuyTrigger;
        triggerTransferRecipient = autoTransferTrigger;
        triggerSellRecipient = autoSellTrigger;
        emit SetAutoTriggers(autoBuyTrigger, autoSellTrigger, autoTransferTrigger);
    }

    function setFees(uint _buyFee, uint _sellFee, uint _transferFee) external onlyOwner {
        require(
            _buyFee <= 2500,
            'Buy Fee Too High'
        );
        require(
            _sellFee <= 2500,
            'Sell Fee Too High'
        );
        require(
            _transferFee <= 2500,
            'Transfer Fee Too High'
        );

        buyFee = _buyFee;
        sellFee = _sellFee;
        transferFee = _transferFee;

        emit SetFees(_buyFee, _sellFee, _transferFee);
    }

    function setFeeExempt(address account, bool isExempt) external onlyOwner {
        require(account != address(0), 'Zero Address');
        permissions[account].isFeeExempt = isExempt;
        emit SetFeeExemption(account, isExempt);
    }

    function setCanSellBurn(address account, bool canSellBurn) external onlyOwner {
        require(account != address(0), 'Zero Address');
        permissions[account].canSellBurn = canSellBurn;
        emit SetCanSellBurn(account, canSellBurn);
    }

    function pauseTrading() external onlyOwner {
        tradingPaused = true;
    }

    function resumeTrading() external onlyOwner {
        tradingPaused = false;
    }

    function setIsPausedExempt(address user, bool isPauseExempt) external onlyOwner {
        permissions[user].isPauseExempt = isPauseExempt;
    }

    function setIsBlacklisted(address user, bool isBlacklisted) external onlyOwner {
        permissions[user].isBlacklisted = isBlacklisted;
    }

    function setSwapper(address newSwapper) external onlyOwner {
        require(
            newSwapper != address(0),
            'Zero Address'
        );
        swapper = newSwapper;
        emit SetSwapper(newSwapper);
    }


    /////////////////////////////////
    /////     READ FUNCTIONS    /////
    /////////////////////////////////

    function getTax(address sender, address recipient, uint256 amount) public view returns (uint256, address, bool) {
        if ( permissions[sender].isFeeExempt || permissions[recipient].isFeeExempt ) {
            return (0, address(0), false);
        }
        return permissions[sender].isLiquidityPool ? 
               ((amount * buyFee) / TAX_DENOM, buyFeeRecipient, triggerBuyRecipient) : 
               permissions[recipient].isLiquidityPool ? 
               ((amount * sellFee) / TAX_DENOM, sellFeeRecipient, triggerSellRecipient) :
               ((amount * transferFee) / TAX_DENOM, transferFeeRecipient, triggerTransferRecipient);
    }


    //////////////////////////////////
    /////   INTERNAL FUNCTIONS   /////
    //////////////////////////////////

    /** Internal Transfer */
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(
            recipient != address(0),
            'Zero Recipient'
        );
        require(
            amount > 0,
            'Zero Amount'
        );
        require(
            amount <= _balances[sender],
            'Insufficient Balance'
        );
        require(
            permissions[sender].isBlacklisted == false,
            'Sender Blacklisted'
        );
        if (tradingPaused) {
            require(
                permissions[sender].isPauseExempt,
                'Not Pause Exempt'
            );
        }
        
        // decrement sender balance
        _balances[sender] -= amount;

        // fee for transaction
        (uint256 fee, address feeDestination, bool trigger) = getTax(sender, recipient, amount);

        // give amount to recipient less fee
        uint256 sendAmount = amount - fee;
        _balances[recipient] += sendAmount;
        emit Transfer(sender, recipient, sendAmount);

        // allocate fee if any
        if (fee > 0) {

            // if recipient field is valid
            bool isValidRecipient = feeDestination != address(0) && feeDestination != address(this);

            // allocate amount to recipient
            address feeRecipient = isValidRecipient ? feeDestination : address(this);
            _balances[feeRecipient] += fee;
            emit Transfer(sender, feeRecipient, fee);

            // if valid and trigger is enabled, trigger tokenomics mid transfer
            if (trigger && isValidRecipient) {
                IFeeReceiver(feeRecipient).trigger();
            }
        }

        return true;
    }

    function _burn(address account, uint256 amount) internal returns (bool) {
        require(
            account != address(0),
            'Zero Address'
        );
        require(
            amount > 0,
            'Zero Amount'
        );
        require(
            amount <= _balances[account],
            'Insufficient Balance'
        );
        
        // delete from balance and supply
        _balances[account] -= amount;
        _totalSupply -= amount;

        // increment total burned
        unchecked {
            totalBurned += amount;
        }

        // emit transfer
        emit Transfer(account, address(0), amount);
        return true;
    }

    function _sell(uint256 amount, address recipient) internal returns (bool) {
        require(
            amount > 0,
            'Zero Amount'
        );
        require(
            recipient != address(0) && recipient != address(this) && recipient != swapper,
            'Invalid Recipient'
        );
        require(
            amount <= _balances[msg.sender],
            'Insufficient Balance'
        );

        // re-allocate balances
        _balances[msg.sender] -= amount;
        _balances[swapper] += amount;
        emit Transfer(msg.sender, swapper, amount);

        // sell token for user
        ISwapper(swapper).sell(recipient);
        return true;
    }

}