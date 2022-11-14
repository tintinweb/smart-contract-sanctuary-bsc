/**
 *Submitted for verification at BscScan.com on 2022-11-13
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.14;

library Address
{
    function isContract(address account) internal view returns (bool)
    {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly
        {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }
}

interface IERC20
{
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapV2Factory
{
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint256) external view returns (address pair);
    function allPairsLength() external view returns (uint256);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair
{
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Swap(address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out,address indexed to);
    event Sync(uint112 reserve0, uint112 reserve1);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function MINIMUM_LIQUIDITY() external pure returns (uint256);
    function nonces(address owner) external view returns (uint256);
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint256);
    function price1CumulativeLast() external view returns (uint256);
    function kLast() external view returns (uint256);
    function burn(address to) external returns (uint256 amount0, uint256 amount1);
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
}

interface IUniswapV2Router01
{
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(address tokenA, address tokenB, uint256 amountADesired, uint256 amountBDesired, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);
    function addLiquidityETH(address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
    function removeLiquidity(address tokenA, address tokenB, uint256 liquidity, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline) external returns (uint256 amountA, uint256 amountB);
    function removeLiquidityETH(address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external returns (uint256 amountToken, uint256 amountETH);
    function removeLiquidityWithPermit(address tokenA, address tokenB, uint256 liquidity, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint256 amountA, uint256 amountB);
    function removeLiquidityETHWithPermit(address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint256 amountToken, uint256 amountETH);
    function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);
    function swapTokensForExactTokens(uint256 amountOut, uint256 amountInMax, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);
    function swapExactETHForTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external payable returns (uint256[] memory amounts);
    function swapTokensForExactETH(uint256 amountOut, uint256 amountInMax, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);
    function swapExactTokensForETH(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);
    function swapETHForExactTokens(uint256 amountOut, address[] calldata path, address to, uint256 deadline) external payable returns (uint256[] memory amounts);
    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB);
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountOut);
    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountIn);
    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01
{
    function removeLiquidityETHSupportingFeeOnTransferTokens(address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external returns (uint256 amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint256 amountETH);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;
}

abstract contract Context
{
    function _msgSender() internal view virtual returns (address payable)
    {
        return payable(msg.sender);
    }
}

contract Ownable is Context
{
    address private _owner;
    address private _newOwner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor()
    {
        address msgSender = _msgSender();
        _owner = msgSender;
        _newOwner = address(0);
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address)
    {
        return _owner;
    }

    function isOwner(address who) public view returns (bool)
    {
        return _owner == who;
    }

    modifier onlyOwner()
    {
        require(isOwner(_msgSender()), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) external virtual onlyOwner
    {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        require(newOwner != _owner, "Ownable: new owner is already the owner");
        _newOwner = newOwner;
    }

    function acceptOwnership() external
    {
        require(_msgSender() == _newOwner, "Ownable: can't assign to the current owner");
        emit OwnershipTransferred(_owner, _newOwner);
        _owner = _newOwner;
        _newOwner = address(0);
    }

    function getTime() public view returns (uint256)
    {
        return block.timestamp;
    }
}

// VSL Token Contract Use - Setup Order:
//  1) Create Contract
//  2) Set wallet for BNB out (Marketing/Dev)
//  3) Set wallet for Tokens out (Staking Contract)
//  4) Set the Router/Pair Up (changeRouterVersion)
//  5) Distribute Private Sale Tokens to the Air-Drop Contract
//  6) Distribute Presale and Liquidity Tokens to VSale Contract
//  7) Turn on buy/sell flag - After Presale Finalization and Liquidity, etc.
contract VSLToken is Ownable, IERC20
{
    using Address for address;

    string private constant _name = "Vetter Skylabs Token";
    string private constant _symbol = "VSL";
    uint8  private constant _decimals = 9;

    uint256 private constant _totalTokens = 25 * 10**9 * 10**_decimals;     // 25 Billion Tokens

    mapping(address => uint256) private _tokensOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    IUniswapV2Router02 private uniswapV2Router;         // The current router address
    address private uniswapV2Pair;                      // The current pair address
    mapping(address => bool) private _isExchangeAddress;// Simple check for an exchange address
    uint256 private exchangeCount = 0;                  // Number of exchanges in the list
    mapping (uint256 => address) private exchanges;     // Keep the exchange list
    mapping (address => uint256) private exchangeToId;  // Keep the exchange list

    bool private _buysellEnabled = false;               // Used to allow transfers and staking prior to buy/sell being enabled

    bool private _taxesEnabled = true;                  // Allows a quick way to turn taxes off on the token

    uint256 private _marketingBuyTax = 0;               // (stored at 10x so 5% is 50)
    uint256 private _marketingSellTax = 80;             // (stored at 10x so 5% is 50)
    uint256 private constant _marketTaxCap = 100;       // 10% max

    uint256 private _liquidityBuyTax = 0;               // (stored at 10x so 1% is 10)
    uint256 private _halfLiquidityBuyTax = 0;           // (stored at 10x so 0.5% is 5) - kept for math efficiency later (calc once)
    uint256 private _liquiditySellTax = 20;             // (stored at 10x so 1% is 10)
    uint256 private _halfLiquiditySellTax = 10;         // (stored at 10x so 0.5% is 5)
    uint256 private constant _liquidityCap = 20;        // 2% max

    uint256 private _royaltyBuyTax = 150;               // (stored at 10x so 10% is 100)
    uint256 private _royaltySellTax = 50;               // (stored at 10x so 10% is 100)
    uint256 private constant _royaltyCap = 150;         // 15% max

    mapping(address => bool) private _isExcludedFromFee;// Tax Free wallets and contracts

    address payable private externalAddress;            // External Address (to send the BNB to when auto selling)
    address private stakingContract;                    // Royalty Taxes Go Here for Distribution

    mapping(address => bool) private _allowedContract;  // Simple boolean check for allowed or not
    uint256 private allowedCount;                       // In case it takes more than one contract from the DAO to perform the functions
    mapping(uint256 => address) private _allowedByID;   // Used to allow the DAO to control the contract later

    // Use this to prevent those not on the list from accessing controlled functions on the token contract
    modifier onlyAllowedContract()
    {
        require(isOwner(_msgSender()) || _allowedContract[_msgSender()], "caller is not an allowed contract or the owner");
        _;
    }

    constructor()
    {
        // Create the tokens...
        _tokensOwned[address(this)] = _totalTokens;
        _isExcludedFromFee[address(this)] = true;
        emit Transfer(address(0), address(this), _totalTokens);

        // Distribute the tokens...
        _tokensOwned[owner()] = _totalTokens;
        _tokensOwned[address(this)] = 0;
        _isExcludedFromFee[owner()] = true;
        emit Transfer(address(this), owner(), _totalTokens);

        // Initial Setup Defaults...change after launched
        externalAddress = payable(owner());
        stakingContract = owner();
    }

    // To receive ETH from uniswapV2Router when swapping
    receive() external payable {}

    // Standard function: maximum token ever generated
    function totalSupply() external pure override returns (uint256)
    {
        return _totalTokens;
    }

    // Standard function: how many tokens a wallet or contract holds
    function balanceOf(address account) external view override returns (uint256)
    {
        return _tokensOwned[account];
    }

    // Standard function: move tokens from the caller to another wallet
    function transfer(address recipient, uint256 amount) external override returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    // Standard function: see how many tokens someone is able to move on another's behalf
    function allowance(address owner, address spender) public view override returns (uint256)
    {
        return _allowances[owner][spender];
    }

    // Standard function: allow another to transfer or spend the caller's tokens
    function approve(address spender, uint256 amount) external override returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    // Standard function: used by a contract like swap to move tokens on another's behalf if approved to do so
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool)
    {
        require(amount <= _allowances[sender][_msgSender()], "ERC20: transfer amount exceeds allowance");
        // Perform the transfer
        _transfer(sender, recipient, amount);
        // Reduce the amount they can later transfer
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    // Standard function: name of the token
    function name() external pure returns (string memory)
    {
        return _name;
    }

    // Standard function: symbol of the token
    function symbol() external pure returns (string memory)
    {
        return _symbol;
    }

    // Standard function: digits after the decimal for the token
    function decimals() external pure returns (uint8)
    {
        return _decimals;
    }

    // Standard function: add to an allowance amount
    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool)
    {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    // Standard function: subtract from an allowance amount
    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool)
    {
        require(subtractedValue <= _allowances[_msgSender()][spender], "ERC20: transfer amount exceeds allowance");
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }

    // Add tokens and BNB to the liquidity contract using the router function
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private
    {
        // Approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // Add the liquidity...Slippage is unavoidable
        uniswapV2Router.addLiquidityETH{value: ethAmount}(address(this),tokenAmount,0,0,address(this),getTime());
    }

    // Standard function: internal function to handle the approve/allowance code
    function _approve(address owner, address spender, uint256 amount) private
    {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    // Convert tokens to BNB using the router's function
    // Just converts the tokens held by the contract itself to BNB...
    function swapTokensForBNB(uint256 tokenAmount) private returns (bool status)
    {
        // Generate the uniswap pair path of token -> WETH
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        if(allowance(address(this), address(uniswapV2Router)) < tokenAmount)
        {
          _approve(address(this), address(uniswapV2Router), ~uint256(0));
        }

        // Make the swap
        // Param 2 = Accept any amount of ETH
        try uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), getTime())
        {
          return true;
        }
        catch
        {
          return false;
        }
    }

    // Internal processing of the token transfer - emits one or more Transfer events as needed
    // Handles any buy or sell tax as needed
    // Initially will fail until the ability to buy and sell is enabled (after people have time to stake) [_buysellEnabled]
    function _transfer(address from, address to, uint256 amount) private
    {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount != 0, "Transfer amount must be greater than zero");
        require(amount <= _tokensOwned[from], "Transfer amount would exceed balance");

        // Remove the selected amount from the balance of the from address
        _tokensOwned[from] = _tokensOwned[from] - amount;

        // Keep track to know how many are left after taxes to go to the to address
        uint256 remaining = amount;

        // Selling to a listed exchange...may have a SELL Tax if enabled...
        uint256 tax; uint256 mtax; uint256 hltax; uint256 rtax; uint256 initialBalance; uint256 newBalance;
        if(_isExchangeAddress[to])
        {
            require(_buysellEnabled, "Unable to Sell Tokens at this time");

            // If taxes are not on right now (or tax free wallet)...ignore this section and just perform the transfer...
            if(_taxesEnabled && !_isExcludedFromFee[from])
            {
                // Compute all taxes...
                mtax = (remaining * _marketingSellTax) / 1000;          // Marketing/DEV
                hltax = (remaining * _halfLiquiditySellTax) / 1000;     // 1/2 Liquidity
                rtax = (remaining * _royaltySellTax) / 1000;            // Royalty Tax
                tax = mtax + hltax + hltax + rtax;                      // Total includes both halves of liquidity
                if(tax != 0)
                {
                    // Removed from seller
                    remaining -= tax;

                    // Send the royalty tax to the staking contract
                    _tokensOwned[stakingContract] += rtax;
                    emit Transfer(from, stakingContract, rtax);

                    // Send the rest to this contract to sell and create liquidity
                    tax -= rtax;
                    _tokensOwned[address(this)] += tax;
                    emit Transfer(from, address(this), tax);

                    // Check the BNB level before the mini-sell
                    initialBalance = address(this).balance;

                    // Sell the marketing and 1/2 the liquidity tokens
                    if((mtax + hltax != 0) && swapTokensForBNB(mtax + hltax))
                    {
                        // Check the new balance of the BNB on the contract
                        newBalance = address(this).balance - initialBalance;
                        if (newBalance != 0)
                        {
                            // Add the other 1/2 liquidity to the contract
                            addLiquidity(hltax, newBalance); // This returns any unused BNB for the next step automatically
                            // See how much BNB is left (this is the marketing/DEV BNB amount)
                            newBalance = address(this).balance - initialBalance;
                            // Send the amount to the market/dev wallet
                            if (newBalance != 0) externalAddress.transfer(newBalance);
                        }
                    }
                }
            }
        }

        // Buying from a listed exchange...may have a BUY Tax if enabled...
        if(_isExchangeAddress[from])
        {
            require(_buysellEnabled, "Unable to Buy Tokens at this time");

            // If taxes are not on right now (or tax free wallet)...ignore this section and just perform the transfer...
            if(_taxesEnabled && !_isExcludedFromFee[to])
            {
                // Compute all taxes...
                mtax = (remaining * _marketingBuyTax) / 1000;           // Marketing/DEV
                hltax = (remaining * _halfLiquidityBuyTax) / 1000;      // 1/2 Liquidity
                rtax = (remaining * _royaltyBuyTax) / 1000;             // Royalty Tax
                tax = mtax + hltax + hltax + rtax;                      // Total includes both halves of liquidity
                if(tax != 0)
                {
                    // Removed from buyer
                    remaining -= tax;

                    // Send the royalty tax to the staking contract
                    _tokensOwned[stakingContract] += rtax;
                    emit Transfer(from, stakingContract, rtax);

                    // Send the rest to this contract to sell and create liquidity
                    tax -= rtax;
                    _tokensOwned[address(this)] += tax;
                    emit Transfer(from, address(this), tax);

                    // Check the BNB level before the mini-sell
                    initialBalance = address(this).balance;

                    // Sell the marketing and 1/2 the liquidity tokens
                    if((mtax + hltax != 0)&& swapTokensForBNB(mtax + hltax))
                    {
                        // Check the new balance of the BNB on the contract
                        newBalance = address(this).balance - initialBalance;
                        if (newBalance != 0)
                        {
                            // Add the other 1/2 liquidity to the contract
                            addLiquidity(hltax, newBalance);
                            // See how much BNB is left (this is the marketing BNB amount)
                            newBalance = address(this).balance - initialBalance;
                            // Send the amount to the market/dev wallet
                            if (newBalance != 0) externalAddress.transfer(newBalance);
                        }
                    }
                }
            }
        }

        // Give tokens to the new owner...
        _tokensOwned[to] += remaining;
        emit Transfer(from, to, remaining);
    }

    event TaxesEnabled();
    event TaxesDisabled();

    // Turns the taxes on or off, but must be allowed to call this function
    function toggleTaxes(bool _enabled) external onlyAllowedContract
    {
        _taxesEnabled = _enabled;
        if(_enabled) emit TaxesEnabled();
        else emit TaxesDisabled();
    }

    event BuySellEnabled();

    // Turns the ability to buy on permanently (can never stop it after it is enabled), but must be allowed to call this function
    function buysellEnabled() external onlyAllowedContract
    {
        _buysellEnabled = true;
        emit BuySellEnabled();
    }

    event BuyTaxesChanged(uint256 marketing, uint256 liquidity, uint256 royalty);
    event SellTaxesChanged(uint256 marketing, uint256 liquidity, uint256 royalty);

    // Ability to set the taxes (within predetermined limits), but must be allowed to call this function
    function setAllTaxes(uint256 marketingBuy, uint256 marketingSell, uint256 liquidityBuy, uint256 liquiditySell, uint256 royaltyBuy, uint256 royaltySell) external onlyAllowedContract
    {
        require(marketingBuy <= _marketTaxCap && marketingSell <= _marketTaxCap, "Marketing Tax Exceeds Cap");
        require(liquidityBuy <= _liquidityCap && liquiditySell <= _liquidityCap, "Liquidity Tax Exceeds Cap");
        require(royaltyBuy <= _royaltyCap && royaltySell <= _royaltyCap, "Royalty Tax Exceeds Cap");

        _marketingBuyTax = marketingBuy;
        _marketingSellTax = marketingSell;

        _liquidityBuyTax = liquidityBuy;
        _halfLiquidityBuyTax = _liquidityBuyTax / 2;

        _liquiditySellTax = liquiditySell;
        _halfLiquiditySellTax = _liquiditySellTax / 2;

        _royaltyBuyTax = royaltyBuy;
        _royaltySellTax = royaltySell;

        emit BuyTaxesChanged(_marketingBuyTax, _liquidityBuyTax, _royaltyBuyTax);
        emit SellTaxesChanged(_marketingSellTax, _liquiditySellTax, _royaltySellTax);
    }

    // Getter for the total buy tax (must divide to get actual rate)
    function getTotalBuyTax() external view returns (uint256)
    {
        return(_marketingBuyTax + _liquidityBuyTax + _royaltyBuyTax);
    }

    // Getter for the total sell tax (must divide to get actual rate)
    function getTotalSellTax() external view returns (uint256)
    {
        return(_marketingSellTax + _liquiditySellTax + _royaltySellTax);
    }

    // Getter for the router to determine a current rate on the liquidity contract
    function getSellBnBAmount(uint256 tokenAmount) external view returns (uint256 tokenOut, uint256 bnbOut)
    {
        address[] memory path = new address[](2);

        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uint256[] memory amounts = uniswapV2Router.getAmountsOut(tokenAmount, path);

        tokenOut = amounts[0];
        bnbOut = amounts[1];
    }

    // Getter for the router to determine a current rate on the liquidity contract
    function getBuyBnBAmount(uint256 tokenAmount) external view returns (uint256 bnbIn, uint256 tokenIn)
    {
        address[] memory path = new address[](2);

        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

        uint256[] memory amounts = uniswapV2Router.getAmountsOut(tokenAmount, path);

        bnbIn = amounts[0];
        tokenIn = amounts[1];
    }

    // Getter to see the active pair address for the active router
    function getCurrentPairAddress() external view returns (address)
    {
        return uniswapV2Pair;
    }

    // Setter to set up the active pair address for the active router
    // Used when Pancake Swap is upgraded to a new version for example
    // Examples:
    //  (0x10ED43C718714eb63d5aA57B78B54704E256024E); // BSC Mainnet Pancake Swap
    //  (0xD99D1c33F9fC3444f8101754aBC46c52416550D1); // BSC Testnet Pancake Swap
    //  (0xBBe737384C2A26B15E23a181BDfBd9Ec49E00248); // Pink Swap Test Router
    //  (0x319EF69a98c8E8aAB36Aea561Daba0Bf3D0fa3ac); // Pink Swap Main Router
    //  (0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // Testnet Pancake Swap (https://pancake.kiemtienonline360.com/)
    // Another testnet Pancake Swap clone (https://pcs.nhancv.com/#/swap)
    event RouterVersionChanged(address _router, address _pair);
    function changeRouterVersion(address _router) external onlyAllowedContract returns (address _pair)
    {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_router);

        _pair = IUniswapV2Factory(_uniswapV2Router.factory()).getPair(address(this), _uniswapV2Router.WETH());
        if (_pair == address(0))
        {
            // Pair doesn't exist
            _pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        }

        // Set the router/pair of the contract variables
        uniswapV2Pair = _pair;
        _isExcludedFromFee[uniswapV2Pair] = true;
        emit RouterVersionChanged(_router, _pair);

        // Keep the exchange in the list
        _isExchangeAddress[uniswapV2Pair] = true;
        exchangeCount++;
        exchanges[exchangeCount] = uniswapV2Pair;
        exchangeToId[uniswapV2Pair] = exchangeCount;

        // Also set router to tax free...
        uniswapV2Router = _uniswapV2Router;
        _isExcludedFromFee[address(uniswapV2Router)] = true;
    }

    // Getter to see the ID in the list of the exchange in question
    function getExchangeID(address _exchange) view public onlyAllowedContract returns(uint256 _exchangeID)
    {
        _exchangeID = exchangeToId[_exchange];
    }

    // Getter to see the address of the exchange in the list
    function getExchangeAddress(uint256 _exchangeID) view external onlyAllowedContract returns(address which)
    {
        which = exchanges[_exchangeID];
    }

    // Getter for the size of list of the exchanges
    function getExchangeCount() view external onlyAllowedContract returns(uint256 count)
    {
        count = exchangeCount;
    }

    // Getter for the entire list of the exchanges
    function getAllExchanges() view external onlyAllowedContract returns (address [] memory)
    {
        address[] memory exchangeList = new address[](exchangeCount);
        uint256 elem = 0;
        for(uint256 i = 1; i <= exchangeCount; i++)
        {
            exchangeList[elem] = exchanges[i];
            elem++;
        }
        return exchangeList;
    }

    // Getter to quickly check on whether an address is an exchange address
    function isExchangeAddress(address _address) view external onlyAllowedContract returns (bool)
    {
        return _isExchangeAddress[_address];
    }

    // Setter to add an address to the exchange address list (normally happens with changeRouterVersion, but this can turn them off)
    event ExchangeAddressAdded(address _address, bool _enabled);
    function setupExchangeAddress(address _address, bool _allowOrNot) external onlyAllowedContract
    {
        _isExchangeAddress[_address] = _allowOrNot;
        emit ExchangeAddressAdded(_address, _allowOrNot);

        // If we are adding one...
        if(_allowOrNot)
        {
            // See if we already know about it...
            if(getExchangeID(_address) < 1)
            {
                exchangeCount++;
                exchanges[exchangeCount] = _address;
                exchangeToId[_address] = exchangeCount;
            }
        }
    }

    // Getter to quickly check on whether an address is tax free
    function isExcludedFromFee(address account) external view returns (bool)
    {
        return _isExcludedFromFee[account];
    }

    // Setter to make an address tax free
    event FeeExclusionChange(address _address, bool _enabled);
    function excludeFromFee(address account) external onlyAllowedContract
    {
        _isExcludedFromFee[account] = true;
        emit FeeExclusionChange(account, true);
    }

    // Setter to make an address have to pay taxes again
    function includeInFee(address account) external onlyAllowedContract
    {
        _isExcludedFromFee[account] = false;
        emit FeeExclusionChange(account, false);
    }

    // Setter to add an allowed contract into the list (for a DAO to later control the token)
    event AllowedContractChange(address _contractAddress, bool _enabled);
    function setupAllowedContract(address _contractAddress, bool _allowOrNot) external onlyOwner
    {
        _allowedContract[_contractAddress] = _allowOrNot;

        // Only add the address in if it is new...
        for(uint256 i = 1; i <= allowedCount; i++)
        {
            if(_allowedByID[i] == _contractAddress)
            {
                emit AllowedContractChange(_contractAddress, _allowOrNot);
                return;
            }
        }

        // Would have exited by now if it was used in the past...
        allowedCount++;
        _allowedByID[allowedCount] = _contractAddress;
        emit AllowedContractChange(_contractAddress, true);
    }

    // Getter to quickly check whether an address is in the list or not (not whether it has control)
    function IsAddressInList(address which) view external returns(bool)
    {
        for(uint256 i = 1; i <= allowedCount; i++)
        {
            if(_allowedByID[i] == which) return true;
        }
        return false;
    }

    struct Allowed
    {
        address account;
        bool stillAllowed;
    }

    // Getter to get all addresses that can perform special functions on the token
    function getAllAllowedAddresses() view external onlyAllowedContract returns (Allowed [] memory)
    {
        Allowed[] memory entries = new Allowed[](allowedCount);
        uint256 elem = 0;
        for(uint256 i = 1; i <= allowedCount; i++)
        {
            entries[elem].account = _allowedByID[i];
            entries[elem].stillAllowed = _allowedContract[entries[elem].account];
            elem++;
        }
        return entries;
    }

    // Getter to quickly check whether an address can perform special functions on the token or not
    function isAllowedContract(address _contractAddress) view external onlyAllowedContract returns (bool _allowOrNot)
    {
        return _allowedContract[_contractAddress];
    }

    // Setter to control the address of the staking contract so it has tokens to distribute
    event StakingContractChanged(address _contractAddress);
    function setStakingContract(address _contractAddress) external onlyAllowedContract
    {
        stakingContract = _contractAddress;
        emit StakingContractChanged(_contractAddress);
    }

    // Getter to determine the address of the staking contract that receives tokens to distribute
    function getStakingContract() external view onlyAllowedContract returns(address _contractAddress)
    {
        _contractAddress = stakingContract;
    }

    // Setter to control the address of the marketing/DEV wallet that receives the BNB taxes received
    event ExternalAddressChanged(address _externalAddress);
    function setExternalAddress(address payable _externalAddress) external onlyAllowedContract
    {
        externalAddress = _externalAddress;
        emit ExternalAddressChanged(_externalAddress);
    }

    // Getter to see the address of the marketing/DEV wallet that receives the BNB taxes received
    function getExternalAddress() external view onlyAllowedContract returns(address payable _externalAddress)
    {
        _externalAddress = externalAddress;
    }

    // SECTION: Token and BNB Transfers...

    // Used to get random tokens sent to this address out to a wallet...
    function TransferForeignTokens(address _token, address _to) external onlyAllowedContract returns (bool _sent)
    {
        // See what is available...
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));

        // Perform the send...
        if(_contractBalance != 0) _sent = IERC20(_token).transfer(_to, _contractBalance);
        else _sent = false;
    }

    // Used to get an amount of random tokens sent to this address out to a wallet...
    function TransferForeignAmount(address _token, address _to, uint256 _maxAmount) external onlyAllowedContract returns (bool _sent)
    {
        // See what we have available...
        uint256 amount = IERC20(_token).balanceOf(address(this));

        // Cap it at the max requested...
        if(amount > _maxAmount) amount = _maxAmount;

        // Perform the send...
        if(amount != 0) _sent = IERC20(_token).transfer(_to, amount);
        else _sent = false;
    }

    // Used to get BNB from the contract...
    function TransferBNBToAddress(address payable recipient, uint256 amount) external onlyAllowedContract
    {
        if(address(this).balance < amount) revert("Balance Low");
        if(amount != 0) recipient.transfer(amount);
    }

    // Used to get BNB from the contract...
    function TransferAllBNBToAddress(address payable recipient) external onlyAllowedContract
    {
        uint256 amount = address(this).balance;
        if(amount != 0) recipient.transfer(amount);
    }
}