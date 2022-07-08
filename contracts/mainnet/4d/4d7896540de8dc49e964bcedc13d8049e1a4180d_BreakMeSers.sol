/**
 *Submitted for verification at BscScan.com on 2022-07-08
*/

/*

,,,,,,,,,,,,,,,,,,,,,,,,,,,,,(@@@@@@@@@@@@@@@@#.(@.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
,,,,,,,,,,,,,,,,,,,...,,, @@@@@@&%%&@@@&@&&&@&%@&@%/.(,.,,,,,,,,,,,,,,,,,,,,,,,,
,,,,.,,,,,,,,,,.....,(@@@@@@@@@@@&&&@@@@@@@@@@@@@%@/**,.,,,,,,,,,,,,,,,,,,,,,,,,
.,,,..,,..,.....,..#@@@@@@&&@@&&&@@@@@@@@@@@@%%@@@@&%@@@@@,,.,,,,,,,,,,,,,,,,,,,
.................&@@@@@&&&@@@%%@@@@@&@@@@@@@&&@@@%@@@@&@@@ .,,.,,,,,,,,,,,,,,,,,
................*&@@@@@@@@@@@%@@@@&&@@@@@@@@@@@@@@@@&&%%@@@@....,,,,.,,,,,,,,,,,
...............(@@@@&@@@@@@@@@@@@@@@@@@&@%@@@@@@@@@&%&%&@@@@ .........,,,,,,,,,,
..............,@@@@@@&&@#/(@@@%&@@@@&#(@##%%%&&@&@@%%@%&@@@@&...........,.,.,,,,
...............%@@@@@#///^^^^///,^(/*,@...,^^/((#%%%@&&@@@@@&,.............,..,.
...............&@@@@(///*,,,...........,.....,,^//###&@@@@@@@ ..................
..............,.%@@%////,**,,,..........,.....,,,,^^//&@@@@&/...................
................ &@%/***,,,,,,............,...,,,^^^/*%@@@@@....................
[email protected]#//**,,,,,......,,,,....,,,,,,,^^/(&@@@&,....................
.................#@(///*,,..,......,.........,,,*,^^//(&@@*%& ..................
.................,&#((///*,,,,,,,,,,*,,*,,,,,,,*,,^//((#@%/#( ..................
................. ###%##(%%&&%%%#(*,*,/#%%%%%#(/(/#(//(#@(#*,...................
..................(#(/%&%/%((/**,/,..,**,/^/^/*(%&#/^/(#%^//....................
...................%(****(///,,,^/,..,*,,.,,/***,*,,^/(##^/* ...................
................. .%#/*,,,,,,,,,/(*..,/*,,.....,.,,^^/##%^/  ...................
................... @(/**,,,,,,/(/,..,//*,...,..,,,^/(#%,.... .......... .......
......... ... .  .. ,#(/**,,.*(/**...,^^///,.,,,,*,^/##&  .        .. .  .......
........ ...... . .  @%#(^^^/^/&%///#&&(*,,,,,*****#&&*           .       .  . 
............   ....   @&(//*^^/*(%&##(/((/***,,****(#&&%.          .             
.. ..... . .      .    @%%/%###((/,,(,/(/((((/*(%(%%&@                       .  
............        . . @&(#(,^////#%((****,/((/(%&@&&.                      .  
.  ......... . . . . ,@@&@&&#//(/*(/(^^//*,**(##%@&%#.*@#..                     
.............   ..*@&&@&@**@@(////(%##(/^^/%#%@@@@%& ,,&&@@/  ..                
 . ...... . .,@&&&&&&&@&&#,.,@#(#(*.*#,^/(/#&&@%#(....,%&@&&&&@* .              
.....  ,#&&%%%%%%&&&&&&&&&.....&%###%##(#%%&###     ..&&&&&&&%%%%%%&*     .     
 (@&%%%%&%%%%%%%%%%%&&%%%%%... ....,,,,,&#&         .(%%&&%&&&%%%%%%%%%%&(. ..  
%%%%%%%%%%%%%%%%%%%%%%%%%%%,...        #@@&@@       .#%%%%%%%%%%%%#%%%%%%%%%%%&%
%%%%%%%%%#%%%%%%%%%&%%%%%#%* .        @@@&%@ .,    .%%%%%%%%%&%%%%%#%#%%%#%%%%%%
#%#%%%%%%%%%&%%%%%%%%%%%%%#%         ,,@@&&@   .   .#%%%%%#%%%%%%%%%##%%#####%%%
%%%%%%%%%%%%%%%@%##%%%%%%%%#*       *   @@@@       %#%%%%#%%#%%#%%####%#%####%##
%%%%%#%%%%%%%%%%%%%%%%%%%%%%%      .   &&@@@&    / %#%%%%%#%#%##%%%%%#%%##%#####
%%%%%#%#%%%%%%%%%%#%%%%%%%%##     .    @&&@@%@   ,%%#%%%%%%#%####%#%##%%%%%%###%
%%%%%%%%%%%%%%%%%%%#%%%%%%%##&   .    @@&&@@@&   /%#%%%#%%#%&###%#%%%%##%%%#%%#%

*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IBEP20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);
}

abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        if (_owner != msg.sender) return;
        _;
    }
}

interface IUniswapV2Pair {
    event Approval(address indexed owner,address indexed spender,uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from,address to,uint256 value) external returns (bool);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint256);
    function permit(address owner,address spender,uint256 value,uint256 deadline,uint8 v,bytes32 r,bytes32 s) external;
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender,uint256 amount0,uint256 amount1,address indexed to);
    event Swap(address indexed sender,uint256 amount0In,uint256 amount1In,uint256 amount0Out,uint256 amount1Out,address indexed to);
    event Sync(uint112 reserve0, uint112 reserve1);
    function MINIMUM_LIQUIDITY() external pure returns (uint256);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0,uint112 reserve1,uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint256);
    function price1CumulativeLast() external view returns (uint256);
    function kLast() external view returns (uint256);
    function mint(address to) external returns (uint256 liquidity);
    function burn(address to) external returns (uint256 amount0, uint256 amount1);
    function swap(uint256 amount0Out,uint256 amount1Out,address to,bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
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
    )
        external
        payable
        returns (
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

contract BreakMeSers is IBEP20, Ownable {
    string private _name = "BreakMeSers";
    string private _symbol = "BREAK";
    uint256 private _decimals = 18;
    uint256 private _totalSupply = 100_000_000 * 10**_decimals;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    address public bridge;

    bool private swapping;
    bool public hellUnleashed;

    address public constant VICTORY = 0xd5F6Dd430e0c34eA313b7540D6B9e8d71260154d;
    address payable public marketingWallet = payable(0x5BA3f8FBB64B872C983E5fB7C695Dde99e7527e6);
    address payable public teamWallet = payable(0x58037D51231F0F68ABDFE8E48B6D006a092B7487);
    address payable public croWallet = payable(0x10De05E5553C47223E24fAF8CCbF4706fF50725c);

    uint256 public maximusWallet = _totalSupply / 50;
    bool public maximusWalletEnabled;
    uint256 public swapTokensAtAmount = _totalSupply / 400;
    uint256 public buyMarketingFees = 2;
    uint256 public sellMarketingFees = 2;
    uint256 public buyLiquidityFee = 1;
    uint256 public sellLiquidityFee = 1;
    uint256 public buyTeamFee = 2;
    uint256 public sellTeamFee = 2;
    uint256 public buyCroFee = 1;
    uint256 public sellCroFee = 1;
    uint256 public buyVictoryFee = 1;
    uint256 public sellVictoryFee = 1;

    uint256 public totalBuyFees = buyMarketingFees + buyLiquidityFee + buyTeamFee + buyCroFee;
    uint256 public totalSellFees = sellMarketingFees + sellLiquidityFee + sellTeamFee + sellCroFee;

    uint256 private totalSellTaxCollected;
    uint256 private totalBuyTaxCollected;
    uint256 private liqTaxTokensTotal;

    bool public swapEnabled = true;
    bool public liquifyEnabled = true;

    mapping(address => bool) private _limitless;
    mapping(address => bool) public automatedMarketMakerPairs;
    mapping(address => bool) private _isVesting;
    mapping(address => uint256) private tokensVesting;
    mapping(address => uint256) private _holderLastTransferBlock;
    mapping(address => uint256) private _holderLastTransferTimestamp;

    uint256 private gasPriceLimit;
    uint256 public hellBlock;
    uint256 public hellTimeStamp;
    uint256 public coolDownTimer;
    uint256 private numberOfLimitedBlocks;
    uint256 private antiBotCoolDownTimer;
    uint256 private antiBotTimeStamp;
    uint256 private marketingGas = 34000;
    uint256 private teamGas = 34000;
    uint256 private croGas = 34000;
    uint256 private normalGwei;

    bool public coolDownActive = true;
    bool public antiBotLimitsInEffect;
    bool public StrengthAndHonor;

    modifier contractSelling() {
        swapping = true;
        _;
        swapping = false;
    }

    event EnableSwapAndLiquify(bool swap, bool liquify);
    event UpdateMarketingWallet(address wallet);
    event UpdateTeamWallet(address wallet);
    event UpdateCroWallet(address wallet);
    event UpdateBridge(address bridge);
    event HellUnleashed();
    event Airdrop(address holder, uint256 amount);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event TaxableTransfer(address indexed account, bool isTaxable);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    event SentDividends(uint256 opAmount, bool success);
    event UpdateFees(
        uint256 sellMarketingFees,
        uint256 buyMarketingFees,
        uint256 sellLiquidityFee,
        uint256 buyLiquidityFee,
        uint256 sellTeamFee,
        uint256 buyTeamFee,
        uint256 sellCroFee,
        uint256 buyCroFee,
        uint256 sellVictoryFee,
        uint256 buyVictoryFee
    );

    constructor(address _router, uint256 _normalGwei) {
        address router = _router;
        normalGwei = _normalGwei;

        uniswapV2Router = IUniswapV2Router02(router);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this),uniswapV2Router.WETH());
        _approve(address(this), address(uniswapV2Router), type(uint256).max);

        _setAutomatedMarketMakerPair(uniswapV2Pair, true);

        _limitless[address(this)] = true;
        _limitless[msg.sender] = true;
        _limitless[marketingWallet] = true;
        _limitless[teamWallet] = true;
        _limitless[croWallet] = true;

        _balances[owner()] = _totalSupply;
        emit Transfer(address(0), owner(), _totalSupply);
    }

    receive() external payable {}

    function name() public view override returns (string memory) {return _name;}
    function symbol() public view override returns (string memory) {return _symbol;}
    function decimals() public pure override returns (uint8) {return 18;}
    function totalSupply() public view override returns (uint256) {return _totalSupply;}
    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}
    function transfer(address recipient, uint256 amount) public override returns (bool) {_transfer(msg.sender, recipient, amount);return true;}
    function allowance(address owner, address spender) public view override returns (uint256) {return _allowances[owner][spender];}
    function approve(address spender, uint256 amount) public override returns (bool) {_approve(msg.sender, spender, amount);return true;}
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function _lowGasTransfer(address sender, address recipient, uint256 amount) internal {
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _limitless[account];
    }

    function _transfer(address from, address to, uint256 amount) internal {
        if (amount == 0) return;

        if (_limitless[from] || _limitless[to] || swapping) {
            _lowGasTransfer(from, to, amount);
            return;
        }

        if (antiBotLimitsInEffect && from == uniswapV2Pair) {
            if (block.timestamp > antiBotTimeStamp) antiBotLimitsInEffect = false;
            if (block.number <= hellBlock + numberOfLimitedBlocks) require(amount <= _totalSupply / 1000 * (block.number - hellBlock),"Max buy exceeded");
            if (block.timestamp < hellTimeStamp + 5 minutes) require(amount <= _totalSupply / 100, "Max buy exceeded");
            require(tx.gasprice <= gasPriceLimit, "Max gwei exceeded");
            if (_holderLastTransferBlock[tx.origin] == block.number) return;
            if (block.timestamp < _holderLastTransferTimestamp[tx.origin] + antiBotCoolDownTimer) return;
            _holderLastTransferBlock[tx.origin] = block.number;
            _holderLastTransferTimestamp[tx.origin] = block.timestamp;
        }

        if (!hellUnleashed) return;

        if (_isVesting[from]) {
            require(block.timestamp > hellTimeStamp + 1 days, "team can't sell on the first day");
            if (block.timestamp < hellTimeStamp + 11 days) {
                require(amount <= (tokensVesting[from] * (block.timestamp - hellTimeStamp - 1 days)) / 10 days,
                    "only 10% of vested tokens are unlocked every day"
                );
            }
        }

        amount = takeFee(from, to, amount);
        _lowGasTransfer(from, to, amount);
    }

    function takeFee(
        address from,
        address to,
        uint256 amount
    ) internal returns (uint256) {
        bool isSelling = automatedMarketMakerPairs[to];
        bool isBuying = automatedMarketMakerPairs[from];
        uint256 fee;
        uint256 victoryFee;

        if (isSelling) {
            if (StrengthAndHonor) victoryFee = sellVictoryFee;
            fee = sellMarketingFees + sellLiquidityFee + sellTeamFee + sellCroFee;

            if (coolDownActive) {
                require(block.timestamp >=_holderLastTransferTimestamp[tx.origin] + coolDownTimer,"cooldown period active");
                _holderLastTransferTimestamp[tx.origin] = block.timestamp;
            }

        } else if(isBuying && maximusWalletEnabled) require(balanceOf(to) + amount <= maximusWallet, "Exceeds maximum wallet token amount.");
        if(StrengthAndHonor) victoryFee = buyVictoryFee;
        fee = buyMarketingFees + buyLiquidityFee + buyTeamFee + buyCroFee;

        uint256 contractTokenBalance = balanceOf(address(this));

        if(contractTokenBalance >= swapTokensAtAmount && !automatedMarketMakerPairs[from]) {
                uint256 liqTaxFromBuys =  totalBuyFees == 0 ? 0 : ((contractTokenBalance * totalBuyTaxCollected) / contractTokenBalance) * (buyLiquidityFee / totalBuyFees);
                uint256 liqTaxFromSells = totalSellFees == 0 ? 0 :  ((contractTokenBalance * totalSellTaxCollected) / contractTokenBalance) * (sellLiquidityFee / totalSellFees);
                liqTaxTokensTotal += liqTaxFromSells + liqTaxFromBuys;

            if (swapEnabled) swapAndLiquify(contractTokenBalance);

            totalBuyTaxCollected = 0;
            totalSellTaxCollected = 0;
        }

        uint256 fees = amount * fee / 100;
        uint256 victorytokens = amount * victoryFee / 100;
        if (isSelling) totalSellTaxCollected += fees;
        if (!isSelling) totalBuyTaxCollected += fees;

        if (fees > 0) _lowGasTransfer(from, address(this), fees);
        if (victoryFee > 0) _lowGasTransfer(from, VICTORY, victorytokens);

        return amount - fees - victorytokens;
    }

    function swapAndLiquify(uint256 contractTokenBalance) internal contractSelling {
        if (liqTaxTokensTotal > 0 && liquifyEnabled) {
            contractTokenBalance -= (liqTaxTokensTotal / 2);
            uint256 tokensForLiquidity = liqTaxTokensTotal / 2;

            swapTokensForEth(contractTokenBalance);
            uint256 newBalance = address(this).balance;

            addLiquidity(tokensForLiquidity, newBalance);
            emit SwapAndLiquify(tokensForLiquidity,newBalance,tokensForLiquidity);
            liqTaxTokensTotal = 0;
        } else swapTokensForEth(contractTokenBalance - liqTaxTokensTotal);
        
        bool success = true;
        uint256 _completeFees = totalBuyFees + totalSellFees;
        
        if (_completeFees == 0){
            (success, ) = address(teamWallet).call{gas: teamGas, value: address(this).balance}("");
            return;
        }
        
        uint256 feePortions = address(this).balance / _completeFees;

        uint256 marketingPayout = (buyMarketingFees + sellMarketingFees) * feePortions;
        uint256 teamPayout = (buyTeamFee + sellTeamFee) * feePortions;
        uint256 croPayout = (buyCroFee + sellCroFee) * feePortions;

        if (marketingPayout > 0) (success, ) = address(marketingWallet).call{gas: marketingGas, value: marketingPayout}("");
        if (teamPayout > 0) (success, ) = address(teamWallet).call{gas: teamGas, value: teamPayout}("");
        if (croPayout > 0) (success, ) = address(croWallet).call{gas: croGas, value: croPayout}("");

        emit SentDividends(marketingPayout + teamPayout + croPayout, success);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), type(uint256).max);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(address(this),tokenAmount,0,0,owner(),block.timestamp);
    }

    function forceSwapAndSendDividends(uint256 tokens) public onlyOwner {
        tokens = tokens * (10**_decimals);
        uint256 totalAmount = _balances[address(this)];
        uint256 fromBuy = (tokens * totalBuyTaxCollected) / totalAmount;
        uint256 fromSell = (tokens * totalSellTaxCollected) / totalAmount;
        swapAndLiquify(tokens);
        totalBuyTaxCollected = totalBuyTaxCollected - fromBuy;
        totalSellTaxCollected = totalSellTaxCollected - fromSell;
    }

    function atMySignalUnleashHell(
        uint256 _gasLimit,
        uint256 limitedBlocks,
        uint256 minutesOfAntiBot
    ) external payable contractSelling onlyOwner {
        require(!hellUnleashed);
        antiBotTimeStamp = block.timestamp + minutesOfAntiBot * 1 minutes;
        numberOfLimitedBlocks = limitedBlocks;
        gasPriceLimit = _gasLimit;
        hellUnleashed = true;
        hellBlock = block.number;
        hellTimeStamp = block.timestamp;
        emit HellUnleashed();
    }

    function setMarketingWallet(address wallet) external onlyOwner {
        _limitless[wallet] = true;
        marketingWallet = payable(wallet);
        emit UpdateMarketingWallet(wallet);
    }

    function setTeamWallet(address wallet) external onlyOwner {
        _limitless[wallet] = true;
        teamWallet = payable(wallet);
        emit UpdateTeamWallet(wallet);
    }

    function setBridge(address _bridge) external onlyOwner {
        _limitless[_bridge] = true;
        bridge = _bridge;
        emit UpdateBridge(bridge);
    }

    function setCroWallet(address wallet) external onlyOwner {
        _limitless[wallet] = true;
        croWallet = payable(wallet);
        emit UpdateCroWallet(wallet);
    }

    function setLimitlessWallet(address account, bool really) public onlyOwner {
        _limitless[account] = really;
        emit ExcludeFromFees(account, really);
    }

    function setCoolDownActive(bool value) external onlyOwner {
        coolDownActive = value;
    }

    function setGasPriceLimit(uint256 valueInGwei) external onlyOwner {
        if (valueInGwei < normalGwei) return;
        gasPriceLimit = valueInGwei * 1 gwei;
    }

    function StrengthAndHonorMode(bool value) external onlyOwner {
        StrengthAndHonor = value;
    }

    function setCoolDownTimer(uint256 value) external onlyOwner {
        require(value <= 300, "cooldown timer cannot exceed 5 minutes");
        coolDownTimer = value;
    }

    function setMaximusWalletOnOff(bool value) external onlyOwner {
        maximusWalletEnabled = value;
    }

    function sweep() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function setSwapTriggerAmount(uint256 amount) public onlyOwner {
        swapTokensAtAmount = amount * (10**_decimals);
    }

    function enableSwapAndLiquify(bool swap, bool liquify) public onlyOwner {
        swapEnabled = swap;
        liquifyEnabled = liquify;
        emit EnableSwapAndLiquify(swap, liquify);
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) internal {
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function updateFees(
        uint256 marketingBuy,
        uint256 marketingSell,
        uint256 liquidityBuy,
        uint256 liquiditySell,
        uint256 teamBuy,
        uint256 teamSell,
        uint256 croBuy,
        uint256 croSell,
        uint256 victoryBuy,
        uint256 victorySell
    ) public onlyOwner {
        require(victoryBuy <= 3 && victorySell <= 3, "victory tax cannot exceed 3%");
        buyMarketingFees = marketingBuy;
        buyLiquidityFee = liquidityBuy;
        sellMarketingFees = marketingSell;
        sellLiquidityFee = liquiditySell;
        buyTeamFee = teamBuy;
        sellTeamFee = teamSell;
        buyCroFee = croBuy;
        sellCroFee = croSell;
        buyVictoryFee = victoryBuy;
        sellVictoryFee = victorySell;
        totalSellFees = sellMarketingFees + sellLiquidityFee + sellTeamFee + sellCroFee;
        totalBuyFees =buyMarketingFees + buyLiquidityFee + buyTeamFee + buyCroFee;
        require(totalSellFees <= 10 && totalBuyFees <= 10,"total fees cannot exceed 10%");

        emit UpdateFees(
            sellMarketingFees,
            buyMarketingFees,
            sellLiquidityFee,
            buyLiquidityFee,
            sellTeamFee,
            buyTeamFee,
            sellCroFee,
            buyCroFee,
            sellVictoryFee,
            buyVictoryFee
        );
    }

    function airdropToWalletsAndVest(address[] memory airdropWallets, uint256[] memory amount) external onlyOwner {
        require(airdropWallets.length == amount.length,"Arrays must be the same length");
        require(airdropWallets.length <= 200,"Wallets list length must be <= 200");
        for (uint256 i = 0; i < airdropWallets.length; i++) {
            address wallet = airdropWallets[i];
            uint256 airdropAmount = amount[i] * (10**_decimals);
            _lowGasTransfer(msg.sender, wallet, airdropAmount);
            tokensVesting[wallet] = balanceOf(wallet);
            _isVesting[wallet] = true;
        }
    }
}