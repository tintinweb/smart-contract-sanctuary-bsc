/**
 *Submitted for verification at BscScan.com on 2023-02-16
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC20 {

    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);

}

interface IERC20Metadata is IERC20 {

    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function decimals() external view returns (uint8);

}

contract ERC20 is IERC20, IERC20Metadata {

    string private _symbol;
    string private _name;


    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount greater than allowance");
        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }

        return true;
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from zero address");
        require(recipient != address(0), "ERC20: transfer to zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount greater than balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

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

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "LERC20: mint to the zero address");
        _totalSupply -= amount;
        _balances[account] -= amount;
        emit Transfer(account, address(0), amount);
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (
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

contract GO is ERC20, Ownable {

    address public LPTokenReceiver;
    address public marketingReceiver;

    mapping(address => bool) public presaleAddress;

    uint256 public buyTotalFees;
    uint256 public sellTotalFees;

    uint256 public buyMarketingFee;
    uint256 public buyLiquidityFee;

    uint256 public sellMarketingFee;
    uint256 public sellLiquidityFee;

    uint256 public tokensForMarketing;
    uint256 public tokensForLiquidity;

    IUniswapV2Router02 public router;
    address public liquidityPair;

    mapping(address => bool) public isAMM;

    uint256 public maxTransactionAmount;
    uint256 public maxWallet;

    mapping(address => bool) private isExcludedFromFee;
    mapping(address => bool) public isExcludedFromWalletLimits;

    mapping(address => bool) public isAuthorized;

    uint256 public feeDenominator = 10000;
    
    bool private swapping;
    bool public limitsInEffect = true;

    bool public airdropComplete = false;
    bool public vestingFinished = false;

    mapping(address => uint256) public airdropAmount;
    uint256 public launchTime;
    uint256 public vestingPeriods = 5;
    uint256 public vestingPercent = 20;

    constructor() ERC20("GO!", "GO!") {
        address router_;
        address newOwner = 0xc47d53Ab9528bA16f5338C0Dc412893105533ce0;

        // automatically detect router/desired stablecoin
        if(block.chainid == 1){
            router_ = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // ETH: Uniswap V2
        } else if(block.chainid == 5){
            router_ = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // ETH: Uniswap V2
        } else if(block.chainid == 56){
            router_ = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // BNB Chain: PCS V2
        } else if(block.chainid == 97){
            router_ = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1; // BNB Chain: PCS V2
        } else {
            revert("Chain not configured");
        }

        LPTokenReceiver = 0xE45983cbd4b4655bc8E1B1a8C7a3EF88A4ab32EA;
        marketingReceiver = 0x0e98cBB7B3c9b796B49802f0cAaB507bf08a753b;

        router = IUniswapV2Router02(router_);

        liquidityPair = IUniswapV2Factory(
            router.factory()
        ).createPair(
            address(this),
            router.WETH()
        );

        isAMM[liquidityPair] = true;

        isExcludedFromWalletLimits[address(liquidityPair)] = true;
        isExcludedFromWalletLimits[address(router)] = true;        
        isExcludedFromWalletLimits[address(this)] = true;
        isExcludedFromWalletLimits[address(0xdead)] = true;
        isExcludedFromWalletLimits[newOwner] = true;
        isExcludedFromWalletLimits[LPTokenReceiver] = true;

        uint256 totalSupply = 1_000_000_000 * 1e18;
        
        buyMarketingFee = 0;
        buyLiquidityFee = 500;

        sellMarketingFee = 0;
        sellLiquidityFee = 500;

        buyTotalFees = buyMarketingFee + buyLiquidityFee;
        sellTotalFees = sellMarketingFee + sellLiquidityFee;

        isExcludedFromFee[address(0xdead)] = true;
        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[newOwner] = true;
        isExcludedFromFee[LPTokenReceiver] = true;

        maxTransactionAmount = totalSupply * 5 / 1000;
        maxWallet = totalSupply * 1 / 100;

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(newOwner, totalSupply);
        transferOwnership(newOwner);
    }

    receive() external payable {}

    function setAuthorized(address account, bool authorized) external onlyOwner {
        isAuthorized[account] = authorized;
    }

    modifier onlyAuthorized(){
        require(isAuthorized[msg.sender], "Not Authorized");
        _;
    }

    function airdropTokensWithVesting(address[] calldata holders, uint256[] calldata amounts) external onlyOwner {
        require(!airdropComplete);

        for (uint i=0; i<holders.length; i++) {
            super._transfer(address(msg.sender), holders[i], amounts[i]);
            airdropAmount[holders[i]] += amounts[i];
        }
    }

    function finalizeAirdrop() external onlyOwner {
        require(!airdropComplete);
        airdropComplete = true;
    }

    function enableTrading() external onlyOwner {
        launchTime = block.timestamp;
    }

    function setBuyFees(uint256 marketingFee, uint256 liquidityFee) external onlyOwner {
        buyMarketingFee = marketingFee;
        buyLiquidityFee = liquidityFee;
        buyTotalFees = buyMarketingFee + buyLiquidityFee;
        require(buyTotalFees <= 700);
    }

    function setSellFees(uint256 marketingFee, uint256 liquidityFee) external onlyOwner {
        sellMarketingFee = marketingFee;
        sellLiquidityFee = liquidityFee;
        sellTotalFees = sellMarketingFee + sellLiquidityFee;
        require(sellTotalFees <= 700);
    }

    function setLimits(uint256 maxTransactionAmount_, uint256 maxWallet_) external onlyOwner {
        require(maxTransactionAmount_ >= totalSupply() * 1 / 1000);
        maxTransactionAmount = maxTransactionAmount_;
        require(maxWallet_ >= totalSupply() * 1 / 100);
        maxWallet = maxWallet_;
    }

    function removeLimits() external onlyOwner {
        require(limitsInEffect);
        limitsInEffect = false;
    }

    function setLPTokenReceiver(address newReceiver) external onlyOwner {
        require(LPTokenReceiver != address(0));
        LPTokenReceiver = newReceiver;
    }

    function setMarketingReceiver(address newReceiver) external onlyOwner {
        require(marketingReceiver != address(0));
        marketingReceiver = newReceiver;
    }

    function setPresaleAddress(address _presaleAddress, bool isPresale) external onlyOwner {
        require(marketingReceiver != address(0));
        require(!isAMM[_presaleAddress], "AMM is not Presale Address");
        isExcludedFromFee[_presaleAddress] = isPresale;
        isExcludedFromWalletLimits[_presaleAddress] = isPresale;
        presaleAddress[_presaleAddress] = isPresale;
    }

    function setAMM(address ammAddress, bool isAMM_) external onlyOwner {
        isAMM[ammAddress] = isAMM_;
    }

    function setWalletExcludedFromLimits(address wallet, bool isExcluded) external onlyOwner {
        isExcludedFromWalletLimits[wallet] = isExcluded;
    }

    function setWalletExcludedFromFees(address wallet, bool isExcluded) external onlyOwner {
        isExcludedFromFee[wallet] = isExcluded;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if(isExcludedFromFee[from] || isExcludedFromFee[to]){
            if((launchTime == 0 || presaleAddress[from]) && !isAMM[to]){
                airdropAmount[to] += amount;
            }
            super._transfer(from, to, amount);
            return;
        }

        require(launchTime > 0, "Not launched yet");

        if (limitsInEffect) {
            if (
                from != owner() &&
                to != owner() &&
                to != address(0xdead) &&
                !swapping
            ) {

                if (
                    isAMM[from] &&
                    !isExcludedFromWalletLimits[to]
                ) {
                    require(
                        amount <= maxTransactionAmount,
                        "!maxTransactionAmount."
                    );
                    require(
                        amount + balanceOf(to) <= maxWallet,
                        "!maxWallet"
                    );
                }

                else if (
                    isAMM[to] &&
                    !isExcludedFromWalletLimits[from]
                ) {
                    require(
                        amount <= maxTransactionAmount,
                        "!maxTransactionAmount."
                    );
                } else if (!isExcludedFromWalletLimits[to]) {
                    require(
                        amount + balanceOf(to) <= maxWallet,
                        "!maxWallet"
                    );
                }

            }
        }

        if (!vestingFinished) {
            
            uint256 airdroppedTokenAmount = airdropAmount[from];

            if (airdroppedTokenAmount > 0) {
                
                uint256 elapsedPeriods = (block.timestamp - launchTime) / 86400;

                if (elapsedPeriods < vestingPeriods) {
                    uint256 minimumBalance = airdroppedTokenAmount - (
                        // a number ranging from 0 to 100
                        elapsedPeriods * vestingPercent
                        * airdroppedTokenAmount
                        / 100
                    );
                    require(balanceOf(from) - amount >= minimumBalance);
                } else {
                    vestingFinished = true;
                }
            }
        }

        bool takeFee = !swapping;

        if (isExcludedFromFee[from] || isExcludedFromFee[to]) {
            takeFee = false;
        }

        if (takeFee) {

            uint256 fees = 0;

            if (isAMM[to] && sellTotalFees > 0) {
                uint256 newTokensForMarketing = amount * sellMarketingFee / feeDenominator;
                uint256 newTokensForLiquidity = amount * sellLiquidityFee / feeDenominator;

                fees = newTokensForMarketing + newTokensForLiquidity;

                tokensForMarketing += newTokensForMarketing;
                tokensForLiquidity += newTokensForLiquidity;
            }

            else if (isAMM[from] && buyTotalFees > 0) {
                uint256 newTokensForMarketing = amount * buyMarketingFee / feeDenominator;
                uint256 newTokensForLiquidity = amount * buyLiquidityFee / feeDenominator;

                fees = newTokensForMarketing + newTokensForLiquidity;

                tokensForMarketing += newTokensForMarketing;
                tokensForLiquidity += newTokensForLiquidity;
            }

            if (fees > 0) {
                super._transfer(from, address(this), fees);
                amount -= fees;
            }
        }

        if (
            !swapping &&
            from != liquidityPair &&
            !isExcludedFromFee[from] &&
            !isExcludedFromFee[to]
        ) {
            swapping = true;

            swapBack();

            swapping = false;
        }


        super._transfer(from, to, amount);
    }

    function swapTokensForEth(uint256 tokenAmount) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), tokenAmount);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function swapBack() internal {
        if (tokensForLiquidity + tokensForMarketing == 0) {
            return;
        }

        uint256 liquidity = tokensForLiquidity / 2;
        uint256 amountToSwapForETH = tokensForMarketing + (tokensForLiquidity - liquidity);
        swapTokensForEth(amountToSwapForETH);

        uint256 ethForLiquidity = address(this).balance * (tokensForLiquidity - liquidity) / amountToSwapForETH;

        if (liquidity > 0 && ethForLiquidity > 0) {
            _addLiquidity(liquidity, ethForLiquidity);
        }

        if (address(this).balance > 0) {
            bool success = false;
            (success,) = marketingReceiver.call{value: address(this).balance}("");    
        }

        tokensForLiquidity = 0;
        tokensForMarketing = 0;
    }

    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) internal {
        _approve(address(this), address(router), tokenAmount);
        router.addLiquidityETH{value: ethAmount} (
            address(this),
            tokenAmount,
            0,
            0,
            LPTokenReceiver,
            block.timestamp
        );
    }

    function burnTokens(uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "not enough tokens");
        _burn(msg.sender, amount);
    }

    function mintTokens(address account, uint256 amount) external onlyAuthorized {
        _mint(account, amount);
    }
}