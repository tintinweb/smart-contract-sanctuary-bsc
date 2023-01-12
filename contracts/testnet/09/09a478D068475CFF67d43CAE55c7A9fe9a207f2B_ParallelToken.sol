//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./ERC20.sol";
import "./Ownable.sol";
import "./Pausable.sol";

interface IUniswapV2Pair {
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

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Factory {
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

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

contract ParallelToken is ERC20, Ownable, Pausable {

    // CONFIG START

    uint256 private denominator = 100;

    uint256 private swapThreshold = 0.0000005 ether; // The contract will only swap to ETH, once the fee tokens reach the specified threshold

    uint256 private devTaxBuy;
    uint256 private marketingTaxBuy;
    uint256 private liquidityTaxBuy;
    uint256 private administrationTaxBuy;
    
    uint256 private devTaxSell;
    uint256 private marketingTaxSell;
    uint256 private liquidityTaxSell;
    uint256 private administrationTaxSell;
    
    address private devTaxWallet = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;//0xe006A3f07E361Db4c5fd09B0CBdcFe9b9Cb1AeC6;
    address private marketingTaxWallet = 0x26ec743E04F9441C8cde3fb7260aa0aF3515BbFf;
    address private administrationTaxWallet = 0xD5Bec8258A2634F25a37d0b52A8ec52640dFa169;
    address private liquidityTaxWallet = 0xC2bBE5bb705b947B93c58377f9e7C67Da43Da318;
    address private presaleLiquidityWallet = 0x51885Af62E7EEF82925Cb24b7D8d86Ed5b352c1f;

    address private uniSwapLiquidityAddress = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;//0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 private devTokens;
    uint256 private marketingTokens;
    uint256 private administrationTokens;
    uint256 private liquidityTokens;

    uint256 private lockEndsDate = 548 days; // Lock time is 1 year and a half.
    uint256 public lockDate;

    address private _presaleContractAddress;

    mapping (address => uint256) private _lockedBalances;

    mapping (address => bool) public contractsWhiteList;
    mapping (address => uint) public lastTXBlock;

    mapping (uint8 => address) public managers;
    mapping (bytes32 => bool) public executedTask;
    uint16 public taskIndex;

    mapping (address => bool) private excludeList;

    mapping (string => uint256) private buyTaxes;
    mapping (string => uint256) private sellTaxes;
    mapping (string => address) private taxWallets;
    
    bool public taxStatus = true;
    
    IUniswapV2Router02 private uniswapV2Router02;
    IUniswapV2Factory private uniswapV2Factory;
    IUniswapV2Pair private uniswapV2Pair;

    //CONFIG END

    modifier isManager() {
        require(managers[0] == msg.sender || managers[1] == msg.sender || managers[2] == msg.sender, "Not manager");
        _;
    }

    modifier isWhitelisted(address _beneficiary) {
        require(contractsWhiteList[_beneficiary]);
        _;
    }

    event Received(address, uint);

    constructor () payable ERC20("Parallel", "PRLL") {
        mint(msg.sender, 100000000000 * (10 ** uint256(decimals())));

        _transferOwnership(msg.sender);

        uniswapV2Router02 = IUniswapV2Router02(uniSwapLiquidityAddress);
        uniswapV2Factory = IUniswapV2Factory(uniswapV2Router02.factory());
        uniswapV2Pair = IUniswapV2Pair(uniswapV2Factory.createPair(address(this), uniswapV2Router02.WETH()));

        managers[0] = msg.sender;
        managers[1] = devTaxWallet;
        managers[2] = administrationTaxWallet;

        taxWallets["liquidity"] = liquidityTaxWallet;
        taxWallets["dev"] = devTaxWallet;
        taxWallets["marketing"] = marketingTaxWallet;
        taxWallets["administration"] = administrationTaxWallet;
        setBuyTax(1, 1, 1, 1, 1);
        setSellTax(1, 1, 1, 1, 1);
        setTaxWallets(taxWallets["dev"], taxWallets["marketing"], taxWallets["liquidity"], taxWallets["administration"]);

        exclude(msg.sender);
        exclude(address(this));

        lockDate = block.timestamp + lockEndsDate; // Date when BNBs will be unlocked for the owner
    }

    function mint(address _to, uint256 _amount) private onlyOwner {
        _mint(_to, _amount);
    }

    function burn(uint256 _value) public returns (address) {
        _burn(_msgSender(), _value);
        return _msgSender();
    }

    /**
     * @dev Calculates the tax, transfer it to the contract. If the user is selling, and the swap threshold is met, it executes the tax.
     */
    function handleTax(address from, address to, uint256 amount) private returns (uint256) {
        address[] memory sellPath = new address[](2);
        sellPath[0] = address(this);
        sellPath[1] = uniswapV2Router02.WETH();
        
        if(!isExcluded(from) && !isExcluded(to)) {
            uint256 tax;
            uint256 baseUnit = amount / denominator;
            if(from == address(uniswapV2Pair)) {
                tax += baseUnit * buyTaxes["marketing"];
                tax += baseUnit * buyTaxes["dev"];
                tax += baseUnit * buyTaxes["liquidity"];
                tax += baseUnit * buyTaxes["administration"];
                
                if(tax > 0) {
                    _transfer(from, address(this), tax);   
                }
                
                marketingTokens += baseUnit * buyTaxes["marketing"];
                devTokens += baseUnit * buyTaxes["dev"];
                liquidityTokens += baseUnit * buyTaxes["liquidity"];
                administrationTokens += baseUnit * buyTaxes["administration"];
            } else if(to == address(uniswapV2Pair)) {
                tax += baseUnit * sellTaxes["marketing"];
                tax += baseUnit * sellTaxes["dev"];
                tax += baseUnit * sellTaxes["liquidity"];
                tax += baseUnit * sellTaxes["administration"];
                
                if(tax > 0) {
                    _transfer(from, address(this), tax);   
                }
                
                marketingTokens += baseUnit * sellTaxes["marketing"];
                devTokens += baseUnit * sellTaxes["dev"];
                liquidityTokens += baseUnit * sellTaxes["liquidity"];
                administrationTokens += baseUnit * sellTaxes["administration"];
                
                uint256 taxSum = marketingTokens + devTokens + liquidityTokens + administrationTokens;
                
                if(taxSum == 0) return amount;
                
                uint256 ethValue = uniswapV2Router02.getAmountsOut(marketingTokens + devTokens + liquidityTokens + administrationTokens, sellPath)[1];
                
                if(ethValue >= swapThreshold) {
                    uint256 startBalance = address(this).balance;

                    uint256 toSell = marketingTokens + devTokens + liquidityTokens / 2 + administrationTokens;
                    
                    _approve(address(this), address(uniswapV2Router02), toSell);
            
                    uniswapV2Router02.swapExactTokensForETH(
                        toSell,
                        0,
                        sellPath,
                        address(this),
                        block.timestamp
                    );
                    
                    uint256 ethGained = address(this).balance - startBalance;
                    
                    uint256 liquidityToken = liquidityTokens / 2;
                    uint256 liquidityETH = (ethGained * ((liquidityTokens / 2 * 10**18) / taxSum)) / 10**18;
                    
                    uint256 marketingETH = (ethGained * ((marketingTokens * 10**18) / taxSum)) / 10**18;
                    uint256 devETH = (ethGained * ((devTokens * 10**18) / taxSum)) / 10**18;
                    uint256 administrationETH = (ethGained * ((administrationTokens * 10**18) / taxSum)) / 10**18;
                    
                    _approve(address(this), address(uniswapV2Router02), liquidityToken);
                    
                    (uint amountToken, ,) = uniswapV2Router02.addLiquidityETH{value: liquidityETH}(
                        address(this),
                        liquidityToken,
                        0,
                        0,
                        owner(),
                        block.timestamp
                    );
                    
                    uint256 remainingTokens = (marketingTokens + devTokens + liquidityTokens + administrationTokens) - (toSell + amountToken);
                    
                    if(remainingTokens > 0) {
                        _transfer(address(this), owner(), remainingTokens);
                    }
                    
                    (bool success,) = taxWallets["marketing"].call{value: marketingETH}("");
                    (bool success1,) = taxWallets["dev"].call{value: devETH}("");
                    (bool success2,) = taxWallets["administration"].call{value: administrationETH}("");
                    require(success && success1 && success2, "Transfer rejected");
                    
                    if(ethGained - (marketingETH + devETH + liquidityETH + administrationETH) > 0) {
                        uint _amt = ethGained - (marketingETH + devETH + liquidityETH + administrationETH);
                        (bool success3,) = taxWallets["marketing"].call{value: _amt}("");
                        require(success3, "Transfer rejected");
                    }
                    
                    marketingTokens = 0;
                    devTokens = 0;
                    liquidityTokens = 0;
                    administrationTokens = 0;
                }
                
            }
            
            amount -= tax;
        }
        
        return amount;
    }

    /**
     * @dev Triggers the tax handling functionality
     */
    function triggerTax() public onlyOwner {
        handleTax(address(0), address(uniswapV2Pair), 0);
    }

    /**
     * @dev Adds presale ICO funds to PancakeSwap liquidity
     */
    function addLiquidityToPS(uint256 amountToken) external payable onlyOwner {
        _approve(address(this), address(uniswapV2Router02), amountToken);
                    
        uniswapV2Router02.addLiquidityETH{value: msg.value}(
            address(this),
            amountToken,
            0,
            0,
            presaleLiquidityWallet,
            block.timestamp+10000
        );
        
    }

    function pause() public isManager {
        _pause();
    }

    function unpause() public isManager {
        _unpause();
    }

    function balance() public view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Unlocks initial liquidity withdraw
     */
    function releaseTokens(address _address) public {
        require(block.timestamp > lockDate, "Unlock date not reached yet");
        _lockedBalances[_address] = 0;
    }

    function setPresaleContractAddress() public override returns (address) { //TODO: onlyOwner
        require(_presaleContractAddress == address(0), "Address already initialized");
        _presaleContractAddress = msg.sender; //TODO: Cambiar esto
        return _presaleContractAddress;
    }

    function presaleContractAddress() public view returns (address) {
        return _presaleContractAddress;
    }

    function getLockedBalance(address _address) public view returns (uint256) {
        return _lockedBalances[_address];
    }

    function setLockedBalance(address _address, uint256 _lockedBalance) public override returns (bool) { //TODO: Corregir esto
        require(msg.sender == presaleContractAddress(), "You are not allowed to call this function");
        _lockedBalances[_address] = _lockedBalance;
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override whenNotPaused virtual {
        if(recipient == presaleLiquidityWallet && getLockedBalance(presaleLiquidityWallet) > 0){
            require(amount <= (balanceOf(presaleLiquidityWallet) - getLockedBalance(presaleLiquidityWallet)), "This recipient address is not allowed to do this transfer");
        }

        if(taxStatus) {
            amount = handleTax(sender, recipient, amount);
        }
        
        super._transfer(sender, recipient, amount);
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        _spendAllowance(from, _msgSender(), amount);
        _transfer(from, to, amount);
        return true;
    }

    receive() external payable {}

    /**
     * @dev Sets tax for buys.
     */
    function setBuyTax(uint256 owner, uint256 dev, uint256 marketing, uint256 liquidity, uint256 administration) public onlyOwner {
        buyTaxes["owner"] = owner;
        buyTaxes["dev"] = dev;
        buyTaxes["marketing"] = marketing;
        buyTaxes["liquidity"] = liquidity;
        buyTaxes["administration"] = administration;
    }
    
    /**
     * @dev Sets tax for sells.
     */
    function setSellTax(uint256 owner, uint256 dev, uint256 marketing, uint256 liquidity, uint256 administration) public onlyOwner {
        sellTaxes["owner"] = owner;
        sellTaxes["dev"] = dev;
        sellTaxes["marketing"] = marketing;
        sellTaxes["liquidity"] = liquidity;
        sellTaxes["administration"] = administration;
    }

    /**
     * @dev Sets wallets for taxes.
     */
    function setTaxWallets(address dev, address marketing, address liquidity, address administration) public onlyOwner {
        taxWallets["dev"] = dev;
        taxWallets["marketing"] = marketing;
        taxWallets["liquidity"] = liquidity;
        taxWallets["administration"] = administration;
    }
    
    /**
     * @dev Enables tax globally.
     */
    function enableTax() public onlyOwner {
        require(!taxStatus, "Tax is already enabled");
        taxStatus = true;
    }
    
    /**
     * @dev Disables tax globally.
     */
    function disableTax() public onlyOwner {
        require(taxStatus, "Tax is already disabled");
        taxStatus = false;
    }

    /**
     * @dev Excludes the specified account from tax.
     */
    function exclude(address account) public onlyOwner {
        require(!isExcluded(account), "Account is already excluded");
        excludeList[account] = true;
    }

    /**
     * @dev Re-enables tax on the specified account.
     */
    function removeExclude(address account) public onlyOwner {
        require(isExcluded(account), "Account is not excluded");
        excludeList[account] = false;
    }

    /**
     * @dev Returns true if the account is excluded, and false otherwise.
     */
    function isExcluded(address account) public view returns (bool) {
        return excludeList[account];
    }

    function changeManager(address _manager, uint8 _index) public isManager {
        require(_index >= 0 && _index <= 2, "Invalid index");
        managers[_index] = _manager;
    }
}