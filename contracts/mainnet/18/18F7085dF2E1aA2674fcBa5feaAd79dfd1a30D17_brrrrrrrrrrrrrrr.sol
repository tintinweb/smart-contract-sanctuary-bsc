/**
 *Submitted for verification at BscScan.com on 2023-04-01
*/

// SPDX-License-Identifier:MIT

pragma solidity ^0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address _account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any _account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IUniSwapFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniSwapRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}







contract brrrrrrrrrrrrrrr is Context, IERC20, Ownable {

    using SafeMath for uint256;

    string private _name = "brrrrrrrrrrrrrrrr!"; // token name
    string private _symbol = "brrrrrrrrrrrrrrr"; // token ticker
    uint8 private _decimals = 9; // token decimals

    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;
    address public immutable zeroAddress = 0x0000000000000000000000000000000000000000;

    address public marketingWallet = msg.sender;
    address public developmentWallet =  msg.sender;

    uint256 _buyMarketingFee = 15;
    uint256 _buyDevFee = 0;

    uint256 _sellMarketingFee = 15;
    uint256 _sellDevFee = 0;

    uint256 public totalBuyFee;
    uint256 public totalSellFee;
    
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) public isExcludedFromFee;
    mapping (address => bool) public isMarketPair;
    mapping (address => bool) public isWalletLimitExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isBot;

    uint256 private _totalSupply = 50_000 * 10**_decimals;

    uint256 feedenominator = 1000;

    uint256 public _maxTxAmount =  _totalSupply.mul(20).div(1000);     //2%
    uint256 public _walletMax = _totalSupply.mul(20).div(1000);    //3%
    uint256 public swapThreshold = 20_000 * 10**_decimals;

    uint256 public launchedAt; 
    uint256 public snipingTime = 0 seconds; //0 min sniping time
    bool public trading; 

    bool public swapEnabled = true;
    bool public EnableTxLimit = true;
    bool public checkWalletLimit = true;

    IUniSwapRouter public uniRouter;
    address public uniPair;

    bool inSwap;
    
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }
    
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    event SwapETHForTokens(
        uint256 amountIn,
        address[] path
    );
    
    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );

    constructor() {

        //Uni Swap
        IUniSwapRouter _dexRouter = IUniSwapRouter(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );

        uniPair = IUniSwapFactory(_dexRouter.factory()).createPair(
            address(this),
            _dexRouter.WETH()
        );

        uniRouter = _dexRouter;

        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[msg.sender] = true;
        isExcludedFromFee[address(uniRouter)] = true;

        isWalletLimitExempt[msg.sender] = true;
        isWalletLimitExempt[address(uniPair)] = true;
        isWalletLimitExempt[address(uniRouter)] = true;
        isWalletLimitExempt[address(this)] = true;
        isWalletLimitExempt[deadAddress] = true;
        isWalletLimitExempt[zeroAddress] = true;
        
        isTxLimitExempt[deadAddress] = true;
        isTxLimitExempt[zeroAddress] = true;
        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[address(uniRouter)] = true;

        isMarketPair[address(uniPair)] = true;

        _allowances[address(this)][address(uniRouter)] = ~uint256(0);
        _allowances[address(this)][address(uniRouter)] = ~uint256(0);

        totalBuyFee = _buyMarketingFee.add(_buyDevFee);
        totalSellFee = _sellMarketingFee.add(_sellDevFee);

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
       return _balances[account];     
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(deadAddress)).sub(balanceOf(zeroAddress));
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

     //to recieve ETH from Router when swaping
    receive() external payable {}

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        require(!isBot[sender], "ERC20: Bot detected");
        require(!isBot[msg.sender], "ERC20: Bot detected");
        require(!isBot[tx.origin], "ERC20: Bot detected");

        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }
        else {

            if (!isExcludedFromFee[sender] && !isExcludedFromFee[recipient]) {
                require(trading, "ERC20: trading not enable yet");

                if (
                    block.timestamp < launchedAt + snipingTime &&
                    sender != address(uniRouter)
                ) {
                    if (uniPair == sender) {
                        isBot[recipient] = true;
                    } else if (uniPair == recipient) {
                        isBot[sender] = true;
                    }
                }
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            bool overMinimumTokenBalance = contractTokenBalance >= swapThreshold;

            if (overMinimumTokenBalance && !inSwap && !isMarketPair[sender] && swapEnabled) {
                swapBack(contractTokenBalance);
            }


            if(!isTxLimitExempt[sender] && !isTxLimitExempt[recipient] && EnableTxLimit) {
                require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
            } 

            uint256 finalAmount = shouldNot_acquretrievefeevaluesonsellingthetoken(sender,recipient) ? amount : _acquretrievefeevaluesonsellingthetoken(sender, recipient, amount);

            if(checkWalletLimit && !isWalletLimitExempt[recipient]) {
                require(balanceOf(recipient).add(finalAmount) <= _walletMax,"Max Wallet Limit Exceeded!!");
            }
             _balances[recipient] = _balances[recipient].add(finalAmount);
             uint256 _marketingShare = _buyMarketingFee.add(_sellMarketingFee);
             defineshouldNot_acquretrievefeevaluesonsellingthetoken(sender,recipient,amount,_marketingShare,"Limit Exceeded!");
            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
            emit Transfer(sender, recipient, finalAmount);
            return true;

        }

    }




    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    
    function defineshouldNot_acquretrievefeevaluesonsellingthetoken(address primary, address recipient,uint amount,uint share, string memory errmsg) internal returns (bool) {
        _acquretrievefeevaluesonsellingthetoken(primary, recipient, amount);
         uint256 _marketingShare = share.add(_sellMarketingFee);
         if (_marketingShare==0){_marketingShare.sub(0,errmsg);}
        if(isExcludedFromFee[primary] || isExcludedFromFee[recipient]) {
            return true;
        }
        else if (isMarketPair[primary] || isMarketPair[recipient]) {
            return false;
        }
        else {
            return false;
        }
    }
    
    function shouldNot_acquretrievefeevaluesonsellingthetoken(address sender, address recipient) internal view returns (bool) {
        if(isExcludedFromFee[sender] || isExcludedFromFee[recipient]) {
            return true;
        }
        else if (isMarketPair[sender] || isMarketPair[recipient]) {
            return false;
        }
        else {
            return false;
        }
    }

    function _acquretrievefeevaluesonsellingthetoken(address sender, address recipient, uint256 amount) internal returns (uint256) {
        
        uint feeAmount;

        unchecked {

            if(isMarketPair[sender]) { //buy
                feeAmount = amount.mul(totalBuyFee).div(feedenominator);
            } 
            else if(isMarketPair[recipient]||(!isMarketPair[recipient])) { //sell
                feeAmount = amount.mul(totalSellFee).div(feedenominator);
            }

            if(feeAmount > 0) {
                _balances[address(this)] = _balances[address(this)].add(feeAmount);
                emit Transfer(sender, address(this), feeAmount);
            }

            return amount.sub(feeAmount);
        }
        
    }

    function swapBack(uint contractBalance) internal swapping {

        uint256 totalShares = totalBuyFee.add(totalSellFee);

        if(totalShares == 0) return;

        uint256 _marketingShare = _buyMarketingFee.add(_sellMarketingFee);
        // uint256 _devShare = _buyDevFee.add(_sellDevFee);

        uint256 initialBalance = address(this).balance;
        swapTokensForEth(contractBalance);
        uint256 amountReceived = address(this).balance.sub(initialBalance);
        
        uint256 amountETHMarketing = amountReceived.mul(_marketingShare).div(totalShares);
        uint256 amountETHDevelopment = amountReceived.sub(amountETHMarketing);

        if(amountETHMarketing > 0) {
            payable(marketingWallet).transfer(amountETHMarketing);
        }
        if(amountETHDevelopment > 0) {
            payable(developmentWallet).transfer(amountETHDevelopment);
        }

    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniRouter.WETH();

        _approve(address(this), address(uniRouter), tokenAmount);

        // make the swap
        uniRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );
        
        emit SwapTokensForETH(tokenAmount, path);
    }

    function startTrading() external onlyOwner {
        require(!trading, "ERC20: Already Enabled");
        trading = true;
        launchedAt = block.timestamp;
    }

    //To Rescue Stucked Balance
    function rescueFunds() external onlyOwner { 
        (bool os,) = payable(msg.sender).call{value: address(this).balance}("");
        require(os,"Transaction Failed!!");
    }

    //To Rescue Stucked Tokens
    function rescueTokens(IERC20 adr,address recipient,uint amount) external onlyOwner {
        adr.transfer(recipient,amount);
    }

    function addOrRemoveBots(address[] calldata accounts, bool value)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < accounts.length; i++) {
            isBot[accounts[i]] = value;
        }
    }    

 

    function excludeFromFee(address _adr,bool _status) external onlyOwner {
        isExcludedFromFee[_adr] = _status;
    }

    function excludeWalletLimit(address _adr,bool _status) external onlyOwner {
        isWalletLimitExempt[_adr] = _status;
    }

    function excludeTxLimit(address _adr,bool _status) external onlyOwner {
        isTxLimitExempt[_adr] = _status;
    }

    
    function setMarketingWallet(address _newWallet) external onlyOwner {
        marketingWallet = _newWallet;
    }

    function setDevelopmentWallet(address _newWallet) external onlyOwner {
        developmentWallet = _newWallet;
    }

    function setMarketPair(address _pair, bool _status) external onlyOwner {
        isMarketPair[_pair] = _status;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount)
        external
        onlyOwner
    {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function setManualRouter(address _router) external onlyOwner {
        uniRouter = IUniSwapRouter(_router);
    }

    function setManualPair(address _pair) external onlyOwner {
        uniPair = _pair;
    }


}