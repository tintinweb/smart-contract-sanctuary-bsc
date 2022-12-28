//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./Ownable.sol";

interface ISwapper {
    function buy(address recipient) external payable;
    function sell(address recipient) external;
}

interface IFeeReceiver {
    function trigger() external;
}

contract CryptoRealEstate is IERC20, Ownable {

    // total supply
    uint256 private _totalSupply = 100_000_000 * 10**18;

    // token data
    string private constant _name = "Crypto Real Estate";
    string private constant _symbol = "CRE";
    uint8  private constant _decimals = 18;

    // balances
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    // Taxation on transfers
    uint256 public buyFee             = 300;
    uint256 public sellFee            = 900;
    uint256 public transferFee        = 300;
    uint256 public constant TAX_DENOM = 10000;

    // permissions
    struct Permissions {
        bool isFeeExempt;
        bool isLiquidityPool;
    }
    mapping ( address => Permissions ) public permissions;

    // Fee Recipients
    address public sellFeeRecipient;
    address public buyFeeRecipient;
    address public transferFeeRecipient;

    // Swapper
    address public tokenSwapper;

    // Trigger Fee Recipients
    bool public triggerBuyRecipient = true;
    bool public triggerTransferRecipient = true;
    bool public triggerSellRecipient = false;

    // events
    event SetBuyFeeRecipient(address recipient);
    event SetSellFeeRecipient(address recipient);
    event SetTokenSwapper(address newSwapper);
    event SetTransferFeeRecipient(address recipient);
    event SetFeeExemption(address account, bool isFeeExempt);
    event SetAutomatedMarketMaker(address account, bool isMarketMaker);
    event SetFees(uint256 buyFee, uint256 sellFee, uint256 transferFee);
    event SetAutoTriggers(bool triggerBuy, bool triggerSell, bool triggerTransfer);

    constructor() {

        // exempt sender for tax-free initial distribution
        permissions[msg.sender].isFeeExempt = true;

        // initial supply allocation
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

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
        if (recipient == msg.sender) {
            return _sell(msg.sender, amount);
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
        _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        return _transferFrom(sender, recipient, amount);
    }

    function sell(uint256 amount) external returns (bool) {
        return _sell(msg.sender, amount);
    }

    function buy(address recipient) external payable {
        ISwapper(tokenSwapper).buy{value: msg.value}(recipient);
    }

    function burn(uint256 amount) external returns (bool) {
        return _burn(msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) external returns (bool) {
        require(
            _allowances[account][msg.sender] >= amount,
            'Insufficient Allowance'
        );
        _allowances[account][msg.sender] = _allowances[account][msg.sender] - amount;
        return _burn(account, amount);
    }
    
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
        
        // decrement sender balance
        _balances[sender] = _balances[sender] - amount;
        
        // fee for transaction
        (uint256 fee, address feeDestination, bool trigger) = getTax(sender, recipient, amount);

        // allocate fee
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

        // give amount to recipient
        uint256 sendAmount = amount - fee;
        _balances[recipient] = _balances[recipient] + sendAmount;

        // emit transfer
        emit Transfer(sender, recipient, sendAmount);
        return true;
    }

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

    function setTokenSwapper(address newSwapper) external onlyOwner {
        require(newSwapper != address(0), 'Zero Address');
        tokenSwapper = newSwapper;
        emit SetTokenSwapper(newSwapper);
    }

    function setFees(uint _buyFee, uint _sellFee, uint _transferFee) external onlyOwner {
        require(
            _buyFee <= 300,
            'Buy Fee Too High'
        );
        require(
            _sellFee <= 900,
            'Sell Fee Too High'
        );
        require(
            _transferFee <= 300,
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
            amount <= balanceOf(account),
            'Insufficient Balance'
        );
        _balances[account] = _balances[account] - amount;
        _totalSupply = _totalSupply - amount;
        emit Transfer(account, address(0), amount);
        return true;
    }

    function _sell(address recipient, uint256 amount) internal returns (bool) {
        require(
            amount > 0,
            'Zero Amount'
        );
        require(
            amount <= _balances[recipient],
            'Insufficient Balance'
        );

        // Allocate Balance To Swapper
        _balances[recipient] -= amount;
        _balances[tokenSwapper] += amount;
        emit Transfer(recipient, tokenSwapper, amount);

        // Sell From Swapper
        ISwapper(tokenSwapper).sell(recipient);
        return true;
    }

    receive() external payable {
        ISwapper(tokenSwapper).buy{value: msg.value}(msg.sender);
    }
}