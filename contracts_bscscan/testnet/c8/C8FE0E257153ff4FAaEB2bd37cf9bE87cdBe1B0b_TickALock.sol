/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.3 <0.9.0;

/**
* _______ _____ _____ _  __             _      ____   _____ _  __
* |__   __|_   _/ ____| |/ /     /\     | |    / __ \ / ____| |/ /
*    | |    | || |    | ' /     /  \    | |   | |  | | |    | ' / 
*    | |    | || |    |  <     / /\ \   | |   | |  | | |    |  <  
*    | |   _| || |____| . \   / ____ \  | |___| |__| | |____| . \ 
*    |_|  |_____\_____|_|\_\ /_/    \_\ |______\____/ \_____|_|\_\
*
*    Website: https://tickalock.app    
*
*    The Question: https://question.tickalock.app/
*    Solve the question, win the prize.
*    
*    The Crossword: https://crossword.tickalock.app/
*    Play the weekly crossword!
*    
*    Socials
*    Telegram: https://t.me/tickalock
*    Twitter: https://twitter.com/mrtialo
*    Discord: https://discord.gg/wCMpBzBpfE
*/

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IPancakeERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
}

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = msg.sender;
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
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IPancakeRouter01 {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getamountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getamountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getamountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getamountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract TickALock is Ownable, IBEP20 {
    uint256 private constant _initialSupply = 24000000000 * 10**9;
    uint256 public constant _totalSupply = _initialSupply;
    //get 2% of the total supply
    uint256 public _totalSupply2 = _totalSupply * 200 / 10000;
    //get 24% of the total supply
    uint256 public _totalSupply24 = _totalSupply * 2400 / 10000;
    /* Trading */
    uint256 private _antiBotTimer;
    bool public _canTrade;
    /* SwapAndLiquify */
    bool private _isSwappingContractModifier;
    bool public swapAndLiquifyEnabled = true;
    uint256 public _numTokensSellToAddToLiquidity = 60000000 * 10**9;
    /* Sell Delay & Token Vesting (Locking) */
    uint256 private _maxSellDelay = 1 hours;
    uint256 public _sellDelay = 0;
    uint256 private _totalTokensHeld;
    /* Tracking Tokens for LP on Contract   */
    uint256 public _totalAllocatedLiquidityContract;
    /* Tracking Tokens for Marketing on Contract   */
    uint256 public _totalAllocatedMarketingContract;
    /* Tracking Tokens for Crossword Pot on Contract */
    uint256 public _totalAllocatedCrosswordPotContract;
    /* Burn Mechanism */
    uint256 public _tokensToBurn;
    /* LP tax represented as a percentage */
    uint256 private constant _maxTax = 1225; // 12.25% max percent for total tax - no honeypots here!
    uint256 public _liquidityTax = 1224; // 12.24% ie 100 * 1224 / 10000
    bool private _addingLiquidity;
    /* "Buyback" Burn Tax */
    uint256 public _maxBurnTax = 724;
    uint256 public _minBurnTax = 24;
    /* Marketing */
    address public _marketingWalletAddress = 0x9b53C12226e0B46Ac7e4f21De7bC0A5357EF822A;
    uint256 public _marketingTax = 200;
    /* Balance & Sell Limits */
    uint256 public _maxWalletSize = _initialSupply / 100; // 1 % of total supply
    uint256 public _maxSellSize = _initialSupply / 100;
    /* PancakeSwap */
    IPancakeRouter02 private _pancakeRouter;
    address public constant _pancakeRouterAddress = 0xCc7aDc94F3D80127849D2b41b6439b7CF1eB4Ae0;
    address public _pancakePairAddress;

    /* Multi-Sig Team Wallet */
    address public constant _devWallet = 0x82De1c2B2f6DD4aa6eACD3f170357aC4E982C2dd;
    address public constant _burnWallet = 0x000000000000000000000000000000000000dEaD;
    //create a property to track the current weeks  puzzle
    uint256 public _currentPuzzleWeek = 0;
    //create a property to track minimum guess holding fee
    uint256 public _minHoldingsForGuess = 1000 * 10**9;
    //create a property to track the minimum letter submission fee
    uint256 public _crosswordLetterCost = 1000 * 10**9;
    uint256 public _minGuessLength = 24;

    uint256 public _crosswordGuessesPerCoordinate = 3;

    bool public _crosswordEnabled = true;
    bool public _puzzleEnabled = true;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _automatedMarketMakers;
    mapping(address => Holder) private _holders;
    struct Holder {
        // Used for sell delay & token vesting (locking)
        uint256 nextSell;
        uint256 pancakeswapTotalPurchased;
        bool excludeFromFees;
    }
    event OwnerCreateLP(uint8 teamPercent, uint8 contractPercent);
    event OwnerChangeSellDelay(uint256 sellDelay);
    event OwnerUpdateAMM(address indexed AMMAdress, bool enabled);
    event OwnerUpdateMarketingWallet(address indexed marketingWalletAddress);
    event OwnerSwitchSwapAndLiquify(bool disabled);
    event OwnerChangeLPTaxes(uint256 liquidityTax);
    event OwnerChangeBurnTaxes(uint256 maxBurnTax, uint256 minBurnTax);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 amountToken,
        uint256 amountBNB
    );
    event GuessSubmitted(string guess);
    event LetterSubmitted(string letter);

    event GuessLengthChanged(uint256 minGuessLength);
    event MinHoldingsForGuessChanged(uint256 minHoldingsForGuess);
    event GuessCountChanged(uint256 guessCount);
    event CrosswordLetterCostChanged(uint256 crosswordLetterCost);

    event SetTokensToBurn(uint256 tokensToBurn);
    event TokensToLiquidateAdd(uint256 totalAllocatedLiquidityContract);
    event TokensAllocatedMarketingAdd(uint256 totalAllocatedMarketingContract);
    event TokensAllocatedCrosswordPotAdd(uint256 totalAllocatedCrosswordPotContract);
    event TokensToLiquidateSubtract(uint256 totalAllocatedLiquidityContract);
    event TokensAllocatedMarketingSubtract(uint256 totalAllocatedMarketingContract);
    event TokensAllocatedCrosswordPotSubtract(uint256 totalAllocatedCrosswordPotContract);
    
    event SetMaxWalletSize(uint256 maxWalletSize);

    event OwnerEnableCrossword(bool enable);
    event OwnerEnablePuzzle(bool enable);
    event OwnerSetGridLength(uint256 gridLength);
    modifier lockTheSwap() {
        _isSwappingContractModifier = true;
        _;
        _isSwappingContractModifier = false;
    }
    modifier onlyDev() {
        require(msg.sender == _devWallet);
        _;
    }

    constructor() {
        uint256 pancakeSupply = _initialSupply - _totalSupply24 - _totalSupply2;
        // Mint initial supply to contract
        _updateBalance(msg.sender, pancakeSupply);
        _updateBalance(address(this), _totalSupply24);
        _updateBalance(_devWallet, _totalSupply2);
        emit Transfer(address(0), address(msg.sender), pancakeSupply);
        emit Transfer(address(0), address(this), _totalSupply24);
        emit Transfer(address(0), _devWallet, _totalSupply2);
        // Init & approve PCSR
        _pancakeRouter = IPancakeRouter02(_pancakeRouterAddress);
        _pancakePairAddress = IPancakeFactory(_pancakeRouter.factory()).createPair(address(this), _pancakeRouter.WETH());
        _automatedMarketMakers[_pancakePairAddress] = true;
        
        // Exclude from fees
        _holders[msg.sender].excludeFromFees = true;
        _holders[address(this)].excludeFromFees = true;
        _holders[_devWallet].excludeFromFees = true;
    }

    function forceAddingLiquidityReset() external onlyDev {
        //if for some reason addingLiquidity were to get "stuck"
        _addingLiquidity = false;
    }

    function setNumTokensSellToAddToLiquidity(uint256 numTokens) external onlyDev {
        require(numTokens * 10**9 <= _totalSupply24, "numTokens must be less than or equal to _totalSupply24");
        _numTokensSellToAddToLiquidity = numTokens * 10**9;
    }

    function setMaxWalletSize(uint256 maxWalletSize) external onlyDev {
        //max wallet size must be greater than or equal to 1% of the total supply and no more than 3 % of the total supply
        require(maxWalletSize >= _initialSupply / 100, "maxWalletSize must be greater than or equal to 1% of the total supply");
        require(maxWalletSize <= _initialSupply / 100 * 3, "maxWalletSize must be less than or equal to 3% of the total supply");
        _maxWalletSize = maxWalletSize;
        emit SetMaxWalletSize(maxWalletSize);
    }

    ///////////////////////////////////////////
    // Transfer Functions
    ///////////////////////////////////////////
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(
            sender != address(0) && recipient != address(0),
            "Cannot be zero address."
        );
        bool isBuy = _automatedMarketMakers[sender];
        bool isSell = _automatedMarketMakers[recipient];
        bool isExcluded = _holders[sender].excludeFromFees ||
            _holders[recipient].excludeFromFees || _addingLiquidity;
        if (isExcluded) {
            _transferExcluded(sender, recipient, amount);
        } else {
            // Trading can only be enabled once
            require(_canTrade, "Trading isn't enabled.");
            //swap and liquify
            bool overMinTokenBalance = _totalAllocatedLiquidityContract >=
            _numTokensSellToAddToLiquidity;
            if (
                overMinTokenBalance &&
                !_isSwappingContractModifier &&
                msg.sender != _pancakePairAddress &&
                swapAndLiquifyEnabled
            ) {
                swapContractTokens();
            }

            if (isBuy) {
                _buyTokens(recipient, amount);
            }
            else if (isSell) { 
                _sellTokens(sender, amount);
            }
            else {
                // Dev Wallet cannot transfer tokens until lock has expired
                if (sender == _devWallet) {
                    require(block.timestamp >= _holders[_devWallet].nextSell);
                }
                require(_balances[recipient] + amount <= _maxWalletSize);
                _transferExcluded(sender, recipient, amount);
                // Recipient will incur sell delay to prevent pump & dump
                _holders[recipient].nextSell = block.timestamp + _sellDelay;
            }
        }
    }

    function _buyTokens(address recipient, uint256 amount) private {
        if (block.timestamp < _antiBotTimer) {
            totalAllocatedLiquidityContractAdd(amount);
            // 100 % of tokens sent to contract for LP
            _transferExcluded(_pancakePairAddress, address(this), amount);
        } else {
            // Balance + amount cannot exceed 1 % of circulating supply (_maxWalletSize)
            require(_balances[recipient] + amount <= _maxWalletSize, "Balance + amount cannot exceed 1 % of circulating supply.");
            // Amount of tokens to be sent to contract
            uint256 taxedTokensLP = 0;
            uint256 taxedTokensMarketing = 0;
            if (_liquidityTax > 0) {
                // Amount of tokens to be sent to contract
                taxedTokensLP = (amount * _liquidityTax) / 10000;
                totalAllocatedLiquidityContractAdd(taxedTokensLP);
            }
            if (_marketingTax > 0) {
                // Amount of tokens to be sent to contract
                taxedTokensMarketing = (amount * _marketingTax) / 10000;
                totalAllocatedMarketingContractAdd(taxedTokensMarketing);
            }
            _transferIncluded(
                _pancakePairAddress,
                recipient,
                amount,
                taxedTokensLP + taxedTokensMarketing
            );
            _totalTokensHeld += amount - taxedTokensLP - taxedTokensMarketing;
            // Reset sell delay
            _holders[recipient].nextSell = block.timestamp + _sellDelay;
            //Set pancake total purchased amount
            _holders[recipient].pancakeswapTotalPurchased = _holders[recipient].pancakeswapTotalPurchased + amount - taxedTokensLP - taxedTokensMarketing;
        }
    }

    function _sellTokens(address sender, uint256 amount) private {
        // Cannot sell before nextSell
        require(block.timestamp >= _holders[sender].nextSell, "Sell delay not over.");
        require(amount <= _maxSellSize && amount <= _balances[sender], "Amount is too large.");
        // Amount of tokens to be sent to contract
        uint256 taxedTokensBurn = 0;
        uint256 burnTax = calculateBurnTax(sender);
        uint256 taxedTokensMarketing = 0;
        if (burnTax > 0) {
            // Amount of tokens to be sent to contract
            taxedTokensBurn = (amount * burnTax) / 10000;
            _tokensToBurn += taxedTokensBurn;
        }
        if (_marketingTax > 0) {
            // Amount of tokens to be sent to contract
            taxedTokensMarketing = (amount * _marketingTax) / 10000;
            totalAllocatedMarketingContractAdd(taxedTokensMarketing);
        }
        _transferIncluded(sender, _pancakePairAddress, amount, taxedTokensBurn + taxedTokensMarketing);
        _totalTokensHeld -= amount - taxedTokensBurn - taxedTokensMarketing;
        // Reset sell delay
        _holders[sender].nextSell = block.timestamp + _sellDelay;
    }

    //Burn tax is calculated as a percentage of the senders tokens
    function calculateBurnTax(address sender) public view returns (uint256) {
        uint256 burnTax = 0;
        //get senders balance
        uint256 senderBalance = _balances[sender];
        //max burn tax defaults to %7.24
        uint256 maxBurnTax = _maxBurnTax;
        //min burn tax defaults to %0.24
        uint256 minBurnTax = _minBurnTax;
        uint256 percentageOfHoldings = (senderBalance * 10000) / _totalSupply;
        //given that the percentageOfHoldings can only ever be max 1% of the circulating supply, make this a percentage where the max is 100%
        uint256 relativePercentageValue = percentageOfHoldings * 100;
        //given the range of min minBurnTax and max maxBurnTax, find the relative percentage of the percentage of holdings.  This is the burn tax.
        burnTax = ((maxBurnTax - minBurnTax) * relativePercentageValue) / 10000 + minBurnTax;

        return burnTax;
    }

    function setMarketingTax(uint256 marketingTax) public onlyOwner {
        require(_marketingTax <= 400, "Marketing tax must be between 0 and 400");
        _marketingTax = marketingTax;
    }

    function _transferIncluded(
        address sender,
        address recipient,
        uint256 amount,
        uint256 taxedTokens
    ) private {
        uint256 newAmount = amount - taxedTokens;
        _updateBalance(sender, _balances[sender] - amount);
        // Taxed tokens are sent to contract
        _updateBalance(address(this), _balances[address(this)] + taxedTokens);
        emit Transfer(sender, address(this), taxedTokens);
        _updateBalance(recipient, _balances[recipient] + newAmount);
        emit Transfer(sender, recipient, newAmount);
    }

    function _transferExcluded(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        _updateBalance(sender, _balances[sender] - amount);
        _updateBalance(recipient, _balances[recipient] + amount);
        emit Transfer(sender, recipient, amount);
    }

    function _updateBalance(address account, uint256 newBalance) private {
        _balances[account] = newBalance;
    }

    ///////////////////////////////////////////
    // Liquidity Functions
    ///////////////////////////////////////////
    function _contractSwapAndLiquify() public onlyDev {
        bool overMinTokenBalance = _totalAllocatedLiquidityContract >=
            _numTokensSellToAddToLiquidity;
        require(
            overMinTokenBalance &&
            !_isSwappingContractModifier &&
            msg.sender != _pancakePairAddress &&
            swapAndLiquifyEnabled, "Must be over min token balance, not inSwappingContract and swapAndLiquifyEnabled."
        );
        swapContractTokens();
    }

    function swapContractTokens() private lockTheSwap {
        uint256 prizeTokens = getPrizeTokens();
        uint256 remainingBalance = _balances[address(this)] - prizeTokens - _tokensToBurn - _totalAllocatedMarketingContract - _totalAllocatedCrosswordPotContract;
        require(
            _totalAllocatedLiquidityContract >= remainingBalance,
            "totalAllocatedLiquidityContract must be greater than or equal to the remainder of the contract balance and tokens to burn"
        );

        uint256 tokensForLP = remainingBalance;
        uint256 tokensForMarketing = _totalAllocatedMarketingContract;

        (uint256 tokensLiquidity, uint256 BNBLiquidity) = swapAndLiquify(tokensForLP, tokensForMarketing); 
   
        // remove allocated tokens from tally
        totalAllocatedLiquidityContractSubtract(_totalAllocatedLiquidityContract);
        totalAllocatedMarketingContractSubtract(_totalAllocatedMarketingContract);
        emit SwapAndLiquify(tokensLiquidity, BNBLiquidity);
    }
    
    function getPrizeTokens() public view returns (uint256) {
        return _balances[address(this)] - _totalAllocatedLiquidityContract - _tokensToBurn - _totalAllocatedMarketingContract - _totalAllocatedCrosswordPotContract;
    }

    function swapAndLiquify(uint256 tokensForLP, uint256 tokensForMarketing) private returns (uint256, uint256) {
        if(tokensForMarketing > 0) {
            //swap tokens for Marketing to BNB and send to marketing wallet
            // swap the tokens for BNB
            _swapTokensForBNB(tokensForMarketing, _marketingWalletAddress);
        }
        // capture the contract's current BNB balance.
        // this is so that we can capture exactly the amount of BNB that the
        // swap creates, and not make the liquidity event include any BNB that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // split the tokensForLP into halves
        uint256 half = tokensForLP / 2;
        uint256 otherHalf = tokensForLP - half;
        
        // swap tokens for BNB
        _swapTokensForBNB(half, address(this));

        // how much BNB did we just swap into?
        uint256 newBalance = address(this).balance - initialBalance;

        // add liquidity to pancakeswap
        _addLiquidity(otherHalf, newBalance);
        return (half, newBalance);
    }

    function _addLiquidity(uint256 amountTokens, uint256 amountBNB) private {
        _approve(address(this), address(_pancakeRouter), amountTokens);

        _addingLiquidity = true;
        _pancakeRouter.addLiquidityETH{value: amountBNB}(
            address(this), 
            amountTokens, 
            0, 
            0, 
            _burnWallet, 
            block.timestamp
        );
        _addingLiquidity = false;
    }

    function _swapTokensForBNB(uint256 amount, address to) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        //WBNB
        path[1] = address(_pancakeRouter.WETH());
        
        _approve(address(this), address(_pancakeRouter), amount);
        
        _pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            // Receiver address
            to,
            block.timestamp
        );
    }

    function getPancakeRouter() public view returns (address) {
        return address(_pancakeRouter);
    }

    function getThisAddress() public view returns (address) {
        return address(this);
    }

    //reduce LP tax
    function reduceLPTax() private {
        if (_liquidityTax >= 24) {
            _liquidityTax = _liquidityTax - 24;
        }
    }

    ///////////////////////////////////////////
    // Owner Public Functions
    ///////////////////////////////////////////
    function ownerChangeLPTaxes(uint256 liquidityTax) public onlyOwner {
        require((liquidityTax) <= _maxTax);
        _liquidityTax = liquidityTax;
        emit OwnerChangeLPTaxes(_liquidityTax);
    }

    function ownerChangeBurnTaxes(uint256 maxBurnTax,  uint256 minBurnTax) public onlyOwner {
        require((maxBurnTax) <= _maxTax);
        require((minBurnTax) <= _maxTax);
        require(maxBurnTax > minBurnTax, "maxBurnTax must be greater than minBurnTax");
        _maxBurnTax = maxBurnTax;
        _minBurnTax = minBurnTax;
        emit OwnerChangeBurnTaxes(_maxBurnTax, _minBurnTax);
    }

    function enableTrading() public onlyOwner {
        // This function can only be called once
        require(!_canTrade);
        _canTrade = true; // true
        // Team tokens are vested (locked) for 60 days
        _holders[_devWallet].nextSell = block.timestamp + 60 days;
        // All buys in the next 5 minutes are burned and added to LP
        _antiBotTimer = block.timestamp + 5 minutes;
    }

    // 0 disables sellDelay.  sellDelay is in seconds
    function changeSellDelay(uint256 sellDelay) public onlyOwner {
        // Cannot exceed 1 hour.
        require(sellDelay <= _maxSellDelay);
        _sellDelay = sellDelay;
        emit OwnerChangeSellDelay(sellDelay);
    }

    function switchSwapAndLiquify() public onlyOwner {
        swapAndLiquifyEnabled = !swapAndLiquifyEnabled;
        emit OwnerSwitchSwapAndLiquify(swapAndLiquifyEnabled);
    }

    // Disable anti-snipe manually, if needed
    function disableAntiSnipe() public onlyOwner {
        _antiBotTimer = 0;
    }

    //update _marketingWalletAddress
    function updateMarketingWallet(address marketingWalletAddress) public onlyOwner {
        _marketingWalletAddress = marketingWalletAddress;
        emit OwnerUpdateMarketingWallet(marketingWalletAddress);
    }

    ///////////////////////////////////////////
    // BEP-2O Functions
    ///////////////////////////////////////////
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

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        uint256 allowance_ = _allowances[sender][msg.sender];
        _transfer(sender, recipient, amount);
        require(allowance_ >= amount, "BEP20: insufficient allowance");
        _approve(sender, msg.sender, allowance_ - amount);
        return true;
    }

    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    receive() external payable {
        require(
            msg.sender == _pancakeRouterAddress ||
                msg.sender == owner() ||
                msg.sender == _devWallet
        );
    }

    function allTaxes() external view returns (uint256 liquidityTax) {
        liquidityTax = _liquidityTax;
    }

    function antiBotTimeLeft() external view returns (uint256) {
        return
            _antiBotTimer > block.timestamp
                ? _antiBotTimer - block.timestamp
                : 0;
    }

    function nextSellOf(address account) external view returns (uint256) {
        return
            _holders[account].nextSell > block.timestamp
                ? _holders[account].nextSell - block.timestamp
                : 0;
    }

    function totalTokensHeld() external view returns (uint256) {
        return _totalTokensHeld;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function balanceOf(address account)
        external
        view
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function name() external pure override returns (string memory) {
        return "Tick a Lock - TN 03";
    }

    function symbol() external pure override returns (string memory) {
        return "TIALO_TN03";
    }

    //totalSupply() pure function returns _initialSupply
    function totalSupply() external pure override returns (uint256) {
        return _initialSupply;
    }

    function decimals() external pure override returns (uint8) {
        return 9;
    }

    function getOwner() external view override returns (address) {
        return owner();
    }

    //Puzzle Functions
    struct Guess {
        address guesser;
        string guess;
        uint256 timestamp;
        bool hasBeenSubmitted;
    }

    struct PuzzleWeek {
        uint256 puzzleId;
        string solution;
        address walletThatSolved; //defaults to burnAddress if puzzle not solved
        bool puzzleSolved;
    }

    struct LetterGuessed {
        address guesser;
        string letter;
        uint256 timestamp;
        bool isLetterGuessed;
    }

    struct Coordinate {
        uint256 x;
        uint256 y;
    }

    //create a list of PuzzleGuesses tied to the current puzzleWeek and the wallet address
    //week - address - int - Guess count
    mapping(uint256 => mapping(address => uint256)) public _addressGuessCount;
    //week - string (guess hash) - Guess
    mapping(uint256 => mapping(bytes32 => Guess)) public _puzzleGuesses;
    //week - address - guesses
    mapping(uint256 => mapping(address => string[])) public _puzzleGuessesForAddress;
    //Store a full array of puzzleGuesses for each puzzleWeek
    mapping(uint256 => Guess[]) public _puzzleWeekFullGuessList;
    //Store a counter for each weeks total guesses
    mapping(uint256 => uint256) public _puzzleWeekGuessCount;
    //create a list of PuzzleWeeks
    mapping(uint256 => PuzzleWeek) public _puzzleWeek;
    uint256 public _guessCount = 3;

    //CROSSWORD
    //create an array of all letters of the alphabet
    string[] public _alphabet = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"];
    
    //function to return a deterministic hash given an x and y coordinate
    function getDeterministicCoordinateHash(uint256 x, uint256 y) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(x, y));
    } 
    mapping(uint256 => mapping(bytes32 => Coordinate)) public coordinatesForWeek;
    //week - coordinate hash - letter
    mapping(uint256 => mapping(bytes32 => mapping(string => LetterGuessed))) public crossWordLetterGuesses;
    //week - coordinate hash - address
    mapping(uint256 => mapping(bytes32 => mapping(address => uint256))) public guessCountOfCoordinate; 

    function setGuessCount(uint256 guessCount) external onlyDev {
        _guessCount = guessCount;
        emit GuessCountChanged(_guessCount);
    }

    function setCoordinatesForWeek(uint256 week, Coordinate[] memory coordinates) external onlyDev {
        for (uint256 i = 0; i < coordinates.length; i++) {
            coordinatesForWeek[week][getDeterministicCoordinateHash(coordinates[i].x, coordinates[i].y)] = coordinates[i];
        }
    }

    function setCrosswordLetterCost(uint256 cost) external onlyDev {
        _crosswordLetterCost = cost * 10**9;
        emit CrosswordLetterCostChanged(_crosswordLetterCost);
    }

    function enableCrossWord(bool enable) external onlyDev {
        _crosswordEnabled = enable;
        emit OwnerEnableCrossword(enable);
    }

    function setCrosswordGuessesPerCoordinate(uint256 guesses) external onlyDev {
        _crosswordGuessesPerCoordinate = guesses;
    }

    function enablePuzzle(bool enable) external onlyDev {
        _puzzleEnabled = enable;
        emit OwnerEnablePuzzle(enable);
    }

    function submitCrosswordLetter(uint256 xCoordinate, uint256 yCoordinate, string memory letter) external {
        require(_crosswordEnabled, "Crossword is not enabled");
        //Must have enough to pay the cost of the letter
        require(_balances[msg.sender] >= _crosswordLetterCost, "You do not have enough to pay the cost of the letter.");
        _transferExcluded(msg.sender, address(this), _crosswordLetterCost);
        //50% goes to crossword-pot
        totalAllocatedCrosswordPotContractAdd(_crosswordLetterCost / 2);
        //25% goes to the marketing wallet
        totalAllocatedMarketingContractAdd(_crosswordLetterCost / 4);
        //25% goes to the LP
        totalAllocatedLiquidityContractAdd(_crosswordLetterCost / 4);
        //cast letter to lowercase
        string memory lowercaseLetter = _toLower(letter);
        //bool if letter is in the alphabet
        bool isInAlphabet = false;
        //iterate through letters and see if lowercaseLetter is in the array
        for(uint256 i = 0; i < _alphabet.length; i++) {
            if(compareStrings(lowercaseLetter, _alphabet[i])) {
                isInAlphabet = true;
            }
        }
        require(
            isInAlphabet,
            "Letter does not exist in the alphabet"
        );
        bool isInCoordinates = false;
        bytes32 deterministicCoordinateHash = getDeterministicCoordinateHash(xCoordinate, yCoordinate);
        //see if mapping exists
        if(coordinatesForWeek[_currentPuzzleWeek][deterministicCoordinateHash].x != 0 && coordinatesForWeek[_currentPuzzleWeek][deterministicCoordinateHash].y != 0) {
            isInCoordinates = true;
        }
        require(
            isInCoordinates,
            "Coordinates are not part of the current weeks crossword"
        );
        //see if letter has already been submitted
        bool isLetterAlreadySubmitted = false;
        if(crossWordLetterGuesses[_currentPuzzleWeek][deterministicCoordinateHash][lowercaseLetter].isLetterGuessed) {
            isLetterAlreadySubmitted = true;
        }
        require(guessCountOfCoordinate[_currentPuzzleWeek][deterministicCoordinateHash][msg.sender] < _crosswordGuessesPerCoordinate, "You have exceeded your guesses for this coordinate.");
        require(
            !isLetterAlreadySubmitted,
            "Letter has already been submitted"
        );
        //set the letter
        crossWordLetterGuesses[_currentPuzzleWeek][deterministicCoordinateHash][lowercaseLetter] = LetterGuessed(
            msg.sender,
            lowercaseLetter,
            block.timestamp,
            true
        );
        //increase guess count for sender on this coordinate
        guessCountOfCoordinate[_currentPuzzleWeek][deterministicCoordinateHash][msg.sender]++;
        emit LetterSubmitted(lowercaseLetter);
    }

    function compareStrings(string memory a, string memory b) private pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function _toLower(string memory str) internal pure returns (string memory) {
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);
        for (uint i = 0; i < bStr.length; i++) {
            // Uppercase character...
            if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
                // So we add 32 to make it lowercase
                bLower[i] = bytes1(uint8(bStr[i]) + 32);
            } else {
                bLower[i] = bStr[i];
            }
        }
        return string(bLower);
    }
    

    function setMinHoldingsForGuess(uint256 minHoldingsForGuess) external onlyDev {
        _minHoldingsForGuess = minHoldingsForGuess * 10**9;
        emit MinHoldingsForGuessChanged(_minHoldingsForGuess);
    }

    function setMinGuessLength(uint256 minGuessLength) external onlyDev {
        _minGuessLength = minGuessLength;
        emit GuessLengthChanged(_minGuessLength);
    }

    function submitGuess(string memory _guess) external {
        require(_puzzleEnabled, "Puzzle is not enabled");
        //require msg sender to have enough tokens to submit a guess from their current balance and those tokens purchased through pancakeswap
        require(_balances[msg.sender] >= _minHoldingsForGuess && _holders[msg.sender].pancakeswapTotalPurchased >= _minHoldingsForGuess, "You must hold and have purchased the minimum amount of tokens.");
        //if the wallet has submitted three guesses for the current puzzleWeek, guesses cannot be submitted
        require(
            _addressGuessCount[_currentPuzzleWeek][msg.sender] < _guessCount,
            "Guesses for the current puzzle week cannot be submitted after three have been submitted for the current puzzle week."
        );
        //guess can only be up to 60 characters
        require(
            bytes(_guess).length <= _minGuessLength,
            "Guess cannot exceeds character length _minGuessLength."
        );
        //convert _guess to lowercase letters
        string memory lowercaseGuess = _toLower(_guess);
        bytes32 guessHash = getHashOfGuess(lowercaseGuess);
        require(!_puzzleGuesses[_currentPuzzleWeek][guessHash].hasBeenSubmitted, "Guess has already been submitted");

        Guess memory guess = Guess({
                guesser: msg.sender,
                guess: _guess,
                timestamp: block.timestamp,
                hasBeenSubmitted: true
            });

        _puzzleGuesses[_currentPuzzleWeek][guessHash] = guess;
        _puzzleWeekFullGuessList[_currentPuzzleWeek].push(guess);
        _puzzleGuessesForAddress[_currentPuzzleWeek][msg.sender].push(_guess);
        //increate _guessCount for sender by 1
        _addressGuessCount[_currentPuzzleWeek][msg.sender]++;
        //increate _puzzleWeekGuessCount by 1
        _puzzleWeekGuessCount[_currentPuzzleWeek]++;
        emit GuessSubmitted(_guess);
    }

    function getHashOfGuess(string memory guess) public pure returns (bytes32) {
        return keccak256(abi.encodePacked((guess)));
    }

    function setPuzzleWeek() private {
        //increment the current puzzleWeek by 1
        _currentPuzzleWeek = _currentPuzzleWeek + 1;
    }

    //set puzzle solved, should be burn address if the puzzle was not solved, also set solved for crossword
    function setPuzzleSolved(
        bool isSolved,
        bool isSolvedCrossword,
        string memory answer,
        address[] memory crossWordWinningWallets,
        address addressThatSolved
    ) external onlyDev {
        //0.24% of the prizeTokens are sent to the winner
        uint256 prizeTokens = getPrizeTokens();
        uint256 prizeAllotment = _totalSupply24 / 48; //48 weeks of prizes
        uint256 crossWordBonusPrizeTokens = 0;
        require(
            prizeTokens >= prizeAllotment,
            "Not enough tokens to distribute prize."
        );
        address _addressThatSolved = addressThatSolved;
        if(isSolvedCrossword) {
            reduceLPTax();
        }
        if (isSolved) {
            reduceLPTax();
            _addressThatSolved = addressThatSolved;
        } else {
            _addressThatSolved = _burnWallet;
        }
        //if the crossword was solved, split prizeAllotment in half
        if(isSolvedCrossword) {
            uint256 halfOfPrizeAllotment = prizeAllotment / 2;
            //prizeAllotment gets split in half
            prizeAllotment = prizeAllotment - halfOfPrizeAllotment;
            crossWordBonusPrizeTokens = halfOfPrizeAllotment;
            //divide the crossWordBonusPrizeTokens among crossWordWinningWallets
            uint256 crossWordBonusPrizeAllotment = (crossWordBonusPrizeTokens + _totalAllocatedCrosswordPotContract) / crossWordWinningWallets.length;
            for(uint256 i = 0; i < crossWordWinningWallets.length; i++) {
                _transferExcluded(address(this), crossWordWinningWallets[i], crossWordBonusPrizeAllotment);
            }
            totalAllocatedCrosswordPotContractSubtract(crossWordBonusPrizeAllotment * crossWordWinningWallets.length);
        }
        //send prize tokens to the wallet that solved the puzzle
        _transferExcluded(address(this), _addressThatSolved, prizeAllotment);

        //burn the contracts alloted burn tokens
        if(_tokensToBurn > 0) {
            burnTokenContractTokens();
        }
        //create a PuzzleWeek object and assign it to the current puzzleWeek
        PuzzleWeek memory puzzleWeek = PuzzleWeek({
            puzzleId: _currentPuzzleWeek,
            solution: answer,
            walletThatSolved: _addressThatSolved,
            puzzleSolved: isSolved
        });
        _puzzleWeek[_currentPuzzleWeek] = puzzleWeek;

        //increment the current puzzle week
        setPuzzleWeek();
    }

    function burnTokenContractTokens() private {
        //burn the tokens that were allocated to the contract
        _transferExcluded(
            address(this),
            _burnWallet,
            _tokensToBurn
        );
        _tokensToBurn = 0;
    }

    function totalAllocatedCrosswordPotContractAdd(uint256 amount) private {
        _totalAllocatedCrosswordPotContract = _totalAllocatedCrosswordPotContract + amount;
        emit TokensAllocatedCrosswordPotAdd(amount);
    }

    function totalAllocatedCrosswordPotContractSubtract(uint256 amount) private {
        require(_totalAllocatedCrosswordPotContract >= amount, "Not enough tokens to subtract from total allocated crossword pot contract.");
        _totalAllocatedCrosswordPotContract = _totalAllocatedCrosswordPotContract - amount;
        emit TokensAllocatedCrosswordPotSubtract(amount);
    }

    function totalAllocatedMarketingContractAdd(uint256 amount) private {
        _totalAllocatedMarketingContract = _totalAllocatedMarketingContract + amount;
        emit TokensAllocatedMarketingAdd(amount);
    }

    function totalAllocatedMarketingContractSubtract(uint256 amount) private {
        require(_totalAllocatedMarketingContract >= amount, "Not enough tokens to subtract from total allocated marketing contract.");
        _totalAllocatedMarketingContract = _totalAllocatedMarketingContract - amount;
        emit TokensAllocatedMarketingSubtract(amount);
    }

    function totalAllocatedLiquidityContractAdd(uint256 amount) private {
        _totalAllocatedLiquidityContract = _totalAllocatedLiquidityContract + amount;
        emit TokensToLiquidateAdd(amount);
    }

    function totalAllocatedLiquidityContractSubtract(uint256 amount) private {
        require(_totalAllocatedLiquidityContract >= amount, "Not enough tokens to subtract from total allocated liquidity contract.");
        _totalAllocatedLiquidityContract = _totalAllocatedLiquidityContract - amount;
        emit TokensToLiquidateSubtract(amount);
    }
}