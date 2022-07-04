//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./IERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

interface ILP {
    function sync() external;
}

contract TestKingToken is IERC20, Ownable {
    using SafeMath for uint256;

    // total supply
    uint256 private _totalSupply;

    // token data
    string private constant _name = "NewKingToken4";
    string private constant _symbol = "NKT34";
    uint8  private constant _decimals = 18;
    uint256 public constant MAX_TOTAL_SUPPLY = 1 * 1**_decimals;
    address private constant _BackingBusd = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;

    // balances
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    // Taxation on transfers
    uint256 public buyFee             = 200;
    uint256 public sellFee            = 200;
    uint256 public transferFee        = 100;
    uint256 public constant TAX_DENOM = 10000;

    // permissions
    struct Permissions {
        bool isFeeExempt;
        bool isLiquidityPool;
    }
    mapping ( address => Permissions ) public permissions;

    // LP syncing stuff
    address public lp;
    ILP public lpContract;

    // events
    event SetFeeExemption(address account, bool isFeeExempt);
    event SetAutomatedMarketMaker(address account, bool isMarketMaker);
    event SetFees(uint256 buyFee, uint256 sellFee, uint256 transferFee);

    constructor() {

        // set initial starting supply
        _totalSupply = 10 * 10**_decimals;

        // exempt sender for tax-free initial distribution
        permissions[
            msg.sender
        ].isFeeExempt = true;

        // initial supply allocation
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    
    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
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

    function burn(uint256 amount) external onlyOwner returns (bool) {
        return _burn(msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) external returns (bool) {
        _allowances[account][msg.sender] = _allowances[account][msg.sender].sub(amount, 'Insufficient Allowance');
        return _burn(account, amount);
    }

    function mint(address account, uint amount) external onlyOwner returns (bool) {
        return _mint(account, amount);
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
            amount <= balanceOf(sender),
            'Insufficient Balance'
        );
        
        // decrement sender balance
        _balances[sender] = _balances[sender].sub(amount, 'Balance Underflow');
        // fee for transaction
        uint256 fee = getTax(sender, recipient, amount);
        
        if(permissions[sender].isLiquidityPool == true) {
            _mintBuy(sender, recipient, fee, amount);
        }
        if( permissions[recipient].isLiquidityPool == true ) {
            _burnSell(sender, recipient, fee, amount);
        }
        else {
            uint256 sendAmount = amount.sub(fee);
            _balances[recipient] = _balances[recipient].add(sendAmount);

            // emit transfer
            emit Transfer(sender, recipient, sendAmount);
        }

        if (fee > 0) {
            // burn tokens
            _burn(sender, fee);     
        }

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
            _buyFee <= 1000,
            'Buy Fee Too High'
        );
        require(
            _sellFee <= 1000,
            'Sell Fee Too High'
        );
        require(
            _transferFee <= 1000,
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

    function getTax(address sender, address recipient, uint256 amount) public view returns (uint256) {
        if ( permissions[sender].isFeeExempt || permissions[recipient].isFeeExempt ) {
            return (0);
        }
        return permissions[sender].isLiquidityPool ? 
               (amount.mul(buyFee).div(TAX_DENOM)) : 
               permissions[recipient].isLiquidityPool ? 
               (amount.mul(sellFee).div(TAX_DENOM)) :
               (amount.mul(transferFee).div(TAX_DENOM));
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
        _balances[account] = _balances[account].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
        return true;
    }

    function _mint(address account, uint256 amount) internal returns (bool) {
        require(
            account != address(0),
            'Zero Address'
        );
        require(
            amount > 0,
            'Zero Amount'
        );
        require(
            _totalSupply.add(amount) <= MAX_TOTAL_SUPPLY,
            'Exceeds MAX Total Supply'
        );
        _balances[account] = _balances[account].add(amount);
        _totalSupply = _totalSupply.add(amount);
        emit Transfer(address(0), account, amount);
        return true;
    }

    // mint buying function
    function _mintBuy(address sender, address recipient, uint256 fee, uint256 amount) internal returns (bool) {
        require(
            _totalSupply.add(amount.mul(2)) <= MAX_TOTAL_SUPPLY,
            'Exceeds MAX Total Supply'
        );
        uint256 oldBalance = IERC20(_BackingBusd).balanceOf(sender);
        lp = sender;
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        uint256 backingValue = IERC20(_BackingBusd).balanceOf(sender).sub(oldBalance).mul(2);
        fee = backingValue.mul(buyFee).div(TAX_DENOM);
        backingValue = backingValue.sub(fee);
        _mint(sender, backingValue);
        lpContract.sync();
        backingValue = backingValue.div(2).sub(amount);
        _balances[sender] = _balances[sender].sub(backingValue);
        _balances[recipient] = _balances[recipient].add(backingValue);
        emit Transfer(sender, recipient, backingValue);
        return true;
    }

    // burn selling function
    function _burnSell(address sender, address recipient, uint256 fee, uint256 amount) internal returns (bool) {
        // uint256 oldBalance = IERC20(_BackingBusd).balanceOf(recipient);
        lp = recipient;
        _burn(recipient, amount);
        lpContract.sync();
        amount = amount.sub(fee);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        _burn(recipient, amount);
        lpContract.sync();

        return true;
    }

    receive() external payable {}
}