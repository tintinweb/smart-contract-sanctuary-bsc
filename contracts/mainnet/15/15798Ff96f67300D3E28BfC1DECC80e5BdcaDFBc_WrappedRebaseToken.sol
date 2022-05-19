//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./IERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract WrappedRebaseToken is IERC20, Ownable {

    using SafeMath for uint256;

    // total supply
    uint256 private _totalSupply;

    // token data
    string private constant _name = "Wrapped-Aalto";
    string private constant _symbol = "wAalto";
    uint8  private constant _decimals = 18;

    // Token We Wrap Around
    IERC20 public constant Aalto = IERC20(0xcE18FbBAd490D4Ff9a9475235CFC519513Cfb19a);

    // For Redeem Rate
    uint256 private constant precision = 10**18;

    // balances
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    // Taxation on transfers
    uint256 public buyFee             = 1300;
    uint256 public sellFee            = 1700;
    uint256 public transferFee        = 1300;
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

    // events
    event SetBuyFeeRecipient(address recipient);
    event SetSellFeeRecipient(address recipient);
    event SetTransferFeeRecipient(address recipient);
    event SetFeeExemption(address account, bool isFeeExempt);
    event SetAutomatedMarketMaker(address account, bool isMarketMaker);
    event SetFees(uint256 buyFee, uint256 sellFee, uint256 transferFee);

    constructor() {
        emit Transfer(address(0), msg.sender, 0);
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
        return _transferFrom(msg.sender, recipient, amount);
    }

    /** Transfer Function */
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, 'Insufficient Allowance');
        return _transferFrom(sender, recipient, amount);
    }

    function burn(uint256 amount) external returns (bool) {
        return _burn(msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) external returns (bool) {
        _allowances[account][msg.sender] = _allowances[account][msg.sender].sub(amount, 'Insufficient Allowance');
        return _burn(account, amount);
    }
    
    /** Internal Transfer */
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(
            recipient != address(0),
            'Zero Recipient'
        );
        require(
            sender != address(0),
            'Zero Sender'
        );
        require(
            amount > 0,
            'Zero Amount'
        );
        require(
            amount <= balanceOf(sender),
            'Insufficient Balance'
        );
        
        // decrement sender balance
        _balances[sender] = _balances[sender].sub(amount, 'Balance Underflow');
        // fee for transaction
        (uint256 fee, address feeDestination) = getTax(sender, recipient, amount);

        // allocate fee
        if (fee > 0) {
            address feeRecipient = feeDestination == address(0) ? address(this) : feeDestination;
            _balances[feeRecipient] = _balances[feeRecipient].add(fee);
            emit Transfer(sender, feeRecipient, fee);
        }

        // give amount to recipient
        uint256 sendAmount = amount.sub(fee);
        _balances[recipient] = _balances[recipient].add(sendAmount);

        // emit transfer
        emit Transfer(sender, recipient, sendAmount);
        return true;
    }

    /**
        Wrap `amount` of Aalto into wAalto
     */
    function wrap(uint256 amount) external {
        require(
            amount > 0,
            'Zero Amount'
        );
        require(
            amount <= Aalto.balanceOf(msg.sender),
            'Amount Exceeds Senders Aalto Balance'
        );

        uint wAaltoToMint;
        if (_totalSupply == 0) {
            wAaltoToMint = amount;
        } else {
            wAaltoToMint = amount.mul(precision).div(getRedeemRate());
        }

        // Transfer In Aalto
        uint before = Aalto.balanceOf(address(this));
        bool s = Aalto.transferFrom(
            msg.sender,
            address(this),
            amount
        );
        uint received = Aalto.balanceOf(address(this)).sub(before);
        require(
            s &&
            received > 0 &&
            received <= amount,
            'Error TransferFrom'
        );

        // Mint wAalto To Sender
        _mint(msg.sender, wAaltoToMint);
    }

    /**
        Unwrap `amount` of wAalto into Aalto
     */
    function unwrap(uint256 amount) external {
        require(
            amount > 0,
            'Zero Amount'
        );
        require(
            amount <= balanceOf(msg.sender),
            'Amount Exceeds Balance'
        );
        
        // calculate Aalto to redeem for wAalto
        uint AaltoToSend = getUnwrappedQuantity(amount);

        // burn tokens from balance and supply
        _burn(msg.sender, amount);

        // release Aalto for caller
        require(
            Aalto.transfer(
                msg.sender,
                AaltoToSend
            ),
            'Error On Aalto Transfer'
        );
    }

    function withdraw(address token) external onlyOwner {
        require(token != address(0), 'Zero Address');
        require(token != address(Aalto), 'Cannot Withdraw Aalto');
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

    function getTax(address sender, address recipient, uint256 amount) public view returns (uint256, address) {
        if ( permissions[sender].isFeeExempt || permissions[recipient].isFeeExempt ) {
            return (0, address(0));
        }
        return permissions[sender].isLiquidityPool ? 
               (amount.mul(buyFee).div(TAX_DENOM), buyFeeRecipient) : 
               permissions[recipient].isLiquidityPool ? 
               (amount.mul(sellFee).div(TAX_DENOM), sellFeeRecipient) :
               (amount.mul(transferFee).div(TAX_DENOM), transferFeeRecipient);
    }

    function getRedeemRate() public view returns (uint256) {
        return Aalto.balanceOf(address(this)).mul(precision).div(_totalSupply);
    }

    /**
        For an `amount` of wAalto, Returns the amount of Aalto to receive when unwrapping
     */
    function getUnwrappedQuantity(uint256 amount) public view returns (uint256) {
        uint unwrapQTY = amount.mul(getRedeemRate()).div(precision);
        uint aaltoBalance = Aalto.balanceOf(address(this));
        return unwrapQTY < aaltoBalance ? unwrapQTY : aaltoBalance;
    }

    /**
        For an `amount` of Aalto, Returns the amount of wAalto to receive when wrapping
     */
    function getWrappedQuantity(uint256 amount) public view returns (uint256) {
        uint unwrapQTY = amount.mul(precision).div(getRedeemRate());
        uint aaltoBalance = Aalto.balanceOf(address(this));
        return unwrapQTY < aaltoBalance ? unwrapQTY : aaltoBalance;
    }

    /**
        Burns `amount` wAalto from `account`
     */
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
        _balances[account] = _balances[account].sub(amount, 'Balance Underflow');
        _totalSupply = _totalSupply.sub(amount, 'Supply Underflow');
        emit Transfer(account, address(0), amount);
        return true;
    }

    /**
        Mints `amount` of wAalto to `account`
     */
    function _mint(address account, uint256 amount) internal returns (bool) {
        require(
            account != address(0),
            'Zero Address'
        );
        require(
            amount > 0,
            'Zero Amount'
        );
        _balances[account] = _balances[account].add(amount);
        _totalSupply = _totalSupply.add(amount);
        emit Transfer(address(0), account, amount);
        return true;
    }

    receive() external payable {}
}