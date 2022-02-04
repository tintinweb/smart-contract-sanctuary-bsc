// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Context.sol";
import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./ReentrancyGuard.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./IPancakeRouter02.sol";
import "./IPancakeFactory.sol";

contract Dyzcredit is
    Context,
    IERC20,
    IERC20Metadata,
    Ownable,
    ReentrancyGuard
{
    using SafeMath for uint256;

    //Incepted
    IPancakeRouter02 public pancakeswapRouter;
    address public pancakeswapPair;
    bool public buyBackEnabled = false;

    mapping(address => bool) isHolder;
    //Percentages
    uint256 buyBackWalletPercent;
    uint256 developersPercent;
    uint256 holdersPercent;
    //Config
    uint256 private buyBackPercent;
    bool buyBackWalletStatus;
    uint256 holdersCount;
    uint256 holdersLimit;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;
    // Addresses

    address payable private developersAddress;
    address payable private holdersAddress;

    event BuyBackEnabledUpdated(bool enabled);
    event SwapBNBForTokens(uint256 amountIn, address[] path);
    event SwapTokensForBNB(uint256 amountIn, address[] path);

    //Standard
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name = "DYZCREDIT";
    string private _symbol = "DYZCRED";
    bool enableTrading = false;
    address public immutable deadAddress =
        0x000000000000000000000000000000000000dEaD;
    uint256 private holdback = 30;

    constructor(
        address _pancakeswapRouterAddress,
        uint256 _holdersLimit,
        uint256 initialSupply
    ) {
        IPancakeRouter02 _pancakeswapRouter = IPancakeRouter02(
            _pancakeswapRouterAddress
        );
        pancakeswapPair = IPancakeFactory(_pancakeswapRouter.factory())
            .createPair(address(this), _pancakeswapRouter.WETH());

        pancakeswapRouter = _pancakeswapRouter;
        holdersLimit = _holdersLimit;
        _totalSupply = initialSupply;
        // uint256 _rTotal = initialSupply.mul(holdback).div(10**2);
        _mint(msg.sender, _totalSupply);
        // _mint(address(this), _rTotal);
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
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

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: transfer amount exceeds allowance"
            );
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        //Determine sell

        if (enableTrading == true && sender != pancakeswapPair) {
            uint256 contractTokenBalance = balanceOf(address(this));

            if (contractTokenBalance > 0) {
                swapTokens(contractTokenBalance);
            }

            uint256 balance = address(this).balance;

            if (buyBackEnabled == true) {
                if (balance > 0) buyBackTokens(balance);
            }
        }

        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            takeFee = false;
        }

        _checkHolder(recipient);
        _transferTokens(sender, recipient, amount, takeFee);
    }

    function _transferTokens(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (takeFee == true) {
            (uint256 taxAmount, uint256 tAmount) = _getTax(amount);
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] += tAmount;
            //Take Liquidity fee
            _balances[address(this)] += taxAmount;
            emit Transfer(sender, recipient, amount);
        } else {
            _balances[sender] = _balances[sender] - amount;
            _balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
        }
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
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
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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

    //Insipid

    function transferBNBtoAddress(address payable recipient, uint256 amount)
        private
    {
        recipient.transfer(amount);
    }

    function swapTokens(uint256 amount) private nonReentrant {
        uint256 initialBalance = address(this).balance;

        swapTokensForBNB(amount);
        uint256 transferredBalance = address(this).balance.sub(initialBalance);
        // uint256 total = transferredBalance

        if (transferredBalance > 0) {
            transferBNBtoAddress(
                developersAddress,
                transferredBalance.mul(developersPercent).div(10**2)
            );
            transferBNBtoAddress(
                holdersAddress,
                transferredBalance.mul(holdersPercent).div(10**2)
            );
        }
    }

    function buyBackTokens(uint256 amount) private nonReentrant {
        if (amount > 0) {
            swapBNBForTokens(amount);
        }
    }

    function swapTokensForBNB(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeswapRouter.WETH();

        _approve(address(this), address(pancakeswapRouter), tokenAmount);

        // make the swap
        pancakeswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );

        emit SwapTokensForBNB(tokenAmount, path);
    }

    function swapBNBForTokens(uint256 amount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = pancakeswapRouter.WETH();
        path[1] = address(this);

        // make the swap
        pancakeswapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(
            0, // accept any amount of Tokens
            path,
            deadAddress, // Burn address
            block.timestamp
        );

        emit SwapBNBForTokens(amount, path);
    }

    function _getTax(uint256 amount) private view returns (uint256, uint256) {
        uint256 taxAmount = amount.mul(buyBackPercent).div(10**2);
        return (taxAmount, amount.sub(taxAmount));
    }

    function _checkHolder(address user) private {
        if (isHolder[user] == false) {
            isHolder[user] = true;
            holdersCount += 1;
        }

        if (holdersCount == holdersLimit) {
            buyBackWalletStatus = true;
        }
    }

    function setAddresses(
        address payable _developersAddress,
        address payable _holdersAddress
    ) public onlyOwner {
        developersAddress = _developersAddress;
        holdersAddress = _holdersAddress;
    }

    function viewAddresses() public view onlyOwner returns (address, address) {
        return (developersAddress, holdersAddress);
    }

    function setAccountPercentages(
        uint256 _buyBackpercentage,
        uint256 _holdersPercentage,
        uint256 _developersPercent,
        uint256 _buyBackWalletPercent
    ) public onlyOwner {
        buyBackPercent = _buyBackpercentage;
        holdersPercent = _holdersPercentage;
        developersPercent = _developersPercent;
        buyBackWalletPercent = _buyBackWalletPercent;
    }

    function startrading() public onlyOwner {
        enableTrading = true;
    }

    function stoptrading() public onlyOwner {
        enableTrading = false;
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(pancakeswapRouter), tokenAmount);

        // add the liquidity
        pancakeswapRouter.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    function getPercentages()
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            buyBackPercent,
            holdersPercent,
            developersPercent,
            buyBackWalletPercent
        );
    }

    function numberOfHolder() public view returns (uint256) {
        return holdersCount;
    }

    function teamSwap(uint256 amount) public onlyOwner {
        swapTokens(amount);
    }

    receive() external payable {}
}