/**
 *Submitted for verification at BscScan.com on 2022-05-09
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.13;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

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

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

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
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapTokensForExactETH(
        uint amountOut, 
        uint amountInMax, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapETHForExactTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/**
 * @dev Interface of the pawswap factory contract.
 */
interface PawSwapFactory {
    function feeTo() external view returns (address);
}

/**
 * @dev Interface of the tax structure contract.
 */
interface TaxStructure {
    function routerAddress() external view returns (address);

    // these taxes will be taken as eth
    function tax1Name() external view returns (string memory);
    function tax1Wallet() external view returns (address);
    function tax1BuyAmount(address) external view returns (uint256);
    function tax1SellAmount(address) external view returns (uint256);
    
    function tax2Name() external view returns (string memory);
    function tax2Wallet() external view returns (address);
    function tax2BuyAmount(address) external view returns (uint256);
    function tax2SellAmount(address) external view returns (uint256);
    
    function tax3Name() external view returns (string memory);
    function tax3Wallet() external view returns (address);
    function tax3BuyAmount(address) external view returns (uint256);
    function tax3SellAmount(address) external view returns (uint256);

    function tax4Name() external view returns (string memory);
    function tax4Wallet() external view returns (address);
    function tax4BuyAmount(address) external view returns (uint256);
    function tax4SellAmount(address) external view returns (uint256);

    // this tax will be taken as tokens
    function tokenTaxName() external view returns (string memory);
    function tokenTaxWallet() external view returns (address);
    function tokenTaxBuyAmount(address) external view returns (uint256);
    function tokenTaxSellAmount(address) external view returns (uint256);

    // this tax will send tokens to burn address
    function burnTaxBuyAmount(address) external view returns (uint256);
    function burnTaxSellAmount(address) external view returns (uint256);
    function burnAddress() external view returns (address);

    // this tax will be sent to the LP
    function liquidityTaxBuyAmount(address) external view returns (uint256);
    function liquidityTaxSellAmount(address) external view returns (uint256);
    function lpTokenHolder() external view returns (address);

    // this custom tax will send ETH to a dynamic address
    function customTaxName() external view returns (string memory);

    function feeDecimal() external view returns (uint256);
}

interface OwnableContract {
    function owner() external view returns (address);
}

contract PawSwap is Ownable {
    IERC20 private token;
    TaxStructure private taxStructure;

    struct Taxes {
        uint256 tax1;
        uint256 tax2;
        uint256 tax3;
        uint256 tax4;
        uint256 tokenTax;
        uint256 burnTax;
        uint256 liquidityTax;
        uint256 customTax;
        uint256 feeDecimal;
    }

    Taxes private _taxes = Taxes(0, 0, 0, 0, 0, 0, 0, 0, 0);

    mapping(address => address) public tokenTaxContracts;
    mapping(address => bool) public dexExcludedFromTreasury;

    IUniswapV2Router02 public uniswapV2Router;

    PawSwapFactory public pawSwapFactory;

    bool public killSwitchEngaged = false;

    address public pawthAddress = 0xB556f41Aaa3F3d8BA33388c4aFCe62C0847eb58a;
    address public pawSwapRouter = 0xC3eF83A0C40c3f809876a3B19560e9523122A04C;
    // sets treasury fee to 0.03%
    uint256 public treasuryFee = 3;

    event Buy(
        address buyer,
        uint256 ethSpent,
        uint256 tokensReceived,
        uint256 customTaxAmount,
        address customTaxAddress,
        uint256 extraTax1Amount
    );

    event Sell(
        address seller,
        uint256 tokensSold,
        uint256 ethReceived,
        uint256 customTaxAmount,
        address customTaxAddress,
        uint256 extraTax1Amount
    );

    constructor (address _pawth, address _factoryAddr, address _routerAddr) {
        pawthAddress = _pawth;

        PawSwapFactory _factory = PawSwapFactory(
            //0xC30081B278e65721E06e43beC37C5e8B60Fd7DE6
            _factoryAddr
        );
        pawSwapFactory = _factory;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            // 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 // testnet
            _routerAddr
        );
        uniswapV2Router = _uniswapV2Router;
    }

    function buyOnPawSwap (
        address tokenAddress,
        uint customTaxAmount, 
        address customTaxAddress, 
        uint extraTax1Amount, 
        uint256 minTokensToReceive,
        bool isExactIn
    ) external payable {
        require(killSwitchEngaged == false, "Killswitch is engaged");
        require(tokenTaxContracts[tokenAddress] != address(0), "Token not listed");
        uint256 ethToSwap = msg.value;
        
        token = IERC20(tokenAddress);
        taxStructure = TaxStructure(tokenTaxContracts[tokenAddress]);

        if (address(uniswapV2Router) != taxStructure.routerAddress()) {
            setRouter(taxStructure.routerAddress());
        }

        _taxes = Taxes(
            taxStructure.tax1BuyAmount(_msgSender()) + extraTax1Amount,
            taxStructure.tax2BuyAmount(_msgSender()),
            taxStructure.tax3BuyAmount(_msgSender()),
            taxStructure.tax4BuyAmount(_msgSender()),
            taxStructure.tokenTaxBuyAmount(_msgSender()),
            taxStructure.burnTaxBuyAmount(_msgSender()),
            taxStructure.liquidityTaxBuyAmount(_msgSender()),
            customTaxAmount,
            taxStructure.feeDecimal()
        );

        uint256 liquidityEth;

        if (taxStructure.routerAddress() != pawSwapRouter) {
            // take a treasury fee if we are not using the pawswap dex
            uint256 treasuryEth = msg.value * treasuryFee / 10**4; // always 4
            (bool sent,) = pawSwapFactory.feeTo().call{ value: treasuryEth }("");
            require(sent, "Failed to send eth to treasury");
            ethToSwap -= treasuryEth;
        }

        if (_taxes.liquidityTax != 0) {
            // hold onto some eth to pair with tokens for liquidity
            liquidityEth = msg.value * _taxes.liquidityTax / 10**(_taxes.feeDecimal + 2);
            ethToSwap -= liquidityEth;
        }

        if (_taxes.tax1 != 0) {
            // send eth percentage to the tax1 wallet
            uint256 tax1Eth = msg.value * _taxes.tax1 / 10**(_taxes.feeDecimal + 2);
            (bool sent,) = taxStructure.tax1Wallet().call{ value: tax1Eth }("");
            require(sent, "Failed to send eth to tax 1 wallet");
            ethToSwap -= tax1Eth;
        }

        if (_taxes.tax2 != 0) {
            // send eth percentage to the tax2 wallet
            uint256 tax2Eth = msg.value * _taxes.tax2 / 10**(_taxes.feeDecimal + 2);
            (bool sent,) = taxStructure.tax2Wallet().call{ value: tax2Eth }("");
            require(sent, "Failed to send eth to tax 2 wallet");
            ethToSwap -= tax2Eth;
        }

        if (_taxes.tax3 != 0) {
            // send eth percentage to the tax3 wallet
            uint256 tax3Eth = msg.value * _taxes.tax3 / 10**(_taxes.feeDecimal + 2);
            (bool sent,) = taxStructure.tax3Wallet().call{ value: tax3Eth }("");
            require(sent, "Failed to send eth to tax 3 wallet");
            ethToSwap -= tax3Eth;
        }

        if (_taxes.tax4 != 0) {
            // send eth percentage to the tax4 wallet
            uint256 tax4Eth = msg.value * _taxes.tax4 / 10**(_taxes.feeDecimal + 2);
            (bool sent,) = taxStructure.tax4Wallet().call{ value: tax4Eth }("");
            require(sent, "Failed to send eth to tax 4 wallet");
            ethToSwap -= tax4Eth;
        }

        if (_taxes.customTax != 0) {
            // send to the custom tax address
            uint256 customTaxEth = msg.value * _taxes.customTax / 10**(_taxes.feeDecimal + 2);
            (bool sent,) = customTaxAddress.call{ value: customTaxEth }("");
            require(sent, "Failed to send eth to custom tax wallet");
            ethToSwap -= customTaxEth;
        }

        uint256 initialTokenBalance = token.balanceOf(address(this));

        swapEthForTokens(
            ethToSwap, 
            minTokensToReceive,
            tokenAddress, 
            isExactIn
        );

        uint256 newTokenBalance = token.balanceOf(address(this)) - initialTokenBalance;
        uint256 purchasedTokens = newTokenBalance;

        if (_taxes.liquidityTax != 0) {
            // add to the LP
            uint256 liquidityTokens = newTokenBalance * _taxes.liquidityTax / 10**(_taxes.feeDecimal + 2);
            addLiquidity(liquidityTokens, liquidityEth, tokenAddress);
            purchasedTokens -= liquidityTokens;
        }

        // burn fee is taken in pawth
        if (_taxes.burnTax != 0) {
            // send to the pawth burn addr
            uint256 burnTokens = newTokenBalance * _taxes.burnTax / 10**(_taxes.feeDecimal + 2);
            token.transfer(taxStructure.burnAddress(), burnTokens);
            purchasedTokens -= burnTokens;
        }

        // staking fee is taken in token
        if (_taxes.tokenTax != 0) {
            // send to the token tax wallet
            uint256 taxTokens = newTokenBalance * _taxes.tokenTax / 10**(_taxes.feeDecimal + 2);
            token.transfer(taxStructure.tokenTaxWallet(), taxTokens);
            purchasedTokens -= taxTokens;
        }

        // require that we met the minimum set by the user
        require (purchasedTokens >= minTokensToReceive, "Minimum amount of tokens not received");
        // send the tokens to the buyer
        token.transfer(_msgSender(), purchasedTokens);

        emit Buy(
            _msgSender(),
            msg.value, 
            purchasedTokens,
            customTaxAmount,
            customTaxAddress,
            extraTax1Amount
        );
    }

    function sellOnPawSwap (
        address tokenAddress,
        uint256 tokensToSwap, 
        uint customTaxAmount, 
        address customTaxAddress, 
        uint extraTax1Amount, 
        uint minEthToReceive,
        bool isExactIn
    ) external {
        require(killSwitchEngaged == false, "Killswitch is engaged");
        require(tokenTaxContracts[tokenAddress] != address(0), "Token not listed");
        token = IERC20(tokenAddress);
        taxStructure = TaxStructure(tokenTaxContracts[tokenAddress]);
        if (address(uniswapV2Router) != taxStructure.routerAddress()) {
            setRouter(taxStructure.routerAddress());
        }
        token.transferFrom(_msgSender(), address(this), tokensToSwap);

        _taxes = Taxes(
            taxStructure.tax1SellAmount(_msgSender()) + extraTax1Amount,
            taxStructure.tax2SellAmount(_msgSender()),
            taxStructure.tax3SellAmount(_msgSender()),
            taxStructure.tax4SellAmount(_msgSender()),
            taxStructure.tokenTaxSellAmount(_msgSender()),
            taxStructure.burnTaxSellAmount(_msgSender()),
            taxStructure.liquidityTaxSellAmount(_msgSender()),
            customTaxAmount,
            taxStructure.feeDecimal()
        );

        uint256 liquidityTokens;

        if (_taxes.liquidityTax != 0) {
            // hold onto half of liquidity token tax amount to pair with eth for liquidity
            liquidityTokens = tokensToSwap * (_taxes.liquidityTax / 2) / 10**(_taxes.feeDecimal + 2);
            tokensToSwap -= liquidityTokens;
        }
    
        // burn fee is taken in pawth
        if (_taxes.burnTax != 0) {
            // send to the pawth burn addr
            uint256 burnTokens = tokensToSwap * _taxes.burnTax / 10**(_taxes.feeDecimal + 2);
            token.transfer(taxStructure.burnAddress(), burnTokens);
            tokensToSwap -= burnTokens;
        }

        // staking fee is taken in tokens
        if (_taxes.tokenTax != 0) {
            // send to the token tax wallet
            uint256 taxTokens = tokensToSwap * _taxes.tokenTax / 10**(_taxes.feeDecimal + 2);
            token.transfer(taxStructure.tokenTaxWallet(), taxTokens);
            tokensToSwap -= taxTokens;
        }

        uint256 initialEthBalance = address(this).balance;

        swapTokensForEth(
            tokensToSwap, 
            tokenAddress,
            minEthToReceive,
            isExactIn
        );

        uint256 newEthBalance = address(this).balance - initialEthBalance;
        uint256 ethToTransfer = newEthBalance;

        if (_taxes.tax1 != 0) {
            // send eth percentage to the tax1 wallet
            uint256 tax1Eth = newEthBalance * _taxes.tax1 / 10**(_taxes.feeDecimal + 2);
            (bool sent,) = taxStructure.tax1Wallet().call{ value: tax1Eth }("");
            require(sent, "Failed to send eth to tax 1 wallet");
            ethToTransfer -= tax1Eth;
        }

        if (_taxes.tax2 != 0) {
            // send eth percentage to the tax2 wallet
            uint256 tax2Eth = newEthBalance * _taxes.tax2 / 10**(_taxes.feeDecimal + 2);
            (bool sent,) = taxStructure.tax2Wallet().call{ value: tax2Eth }("");
            require(sent, "Failed to send eth to tax 2 wallet");
            ethToTransfer -= tax2Eth;
        }

        if (_taxes.tax3 != 0) {
            // send eth percentage to the tax3 wallet
            uint256 tax3Eth = newEthBalance * _taxes.tax3 / 10**(_taxes.feeDecimal + 2);
            (bool sent,) = taxStructure.tax3Wallet().call{ value: tax3Eth }("");
            require(sent, "Failed to send eth to tax 3 wallet");
            ethToTransfer -= tax3Eth;
        }
    
        if (_taxes.tax4 != 0) {
            // send eth percentage to the tax4 wallet
            uint256 tax4Eth = newEthBalance * _taxes.tax4 / 10**(_taxes.feeDecimal + 2);
            (bool sent,) = taxStructure.tax4Wallet().call{ value: tax4Eth }("");
            require(sent, "Failed to send eth to tax 4 wallet");
            ethToTransfer -= tax4Eth;
        }

        if (taxStructure.routerAddress() != pawSwapRouter) {
            // take a treasury fee if we are not using the pawswap dex
            uint256 treasuryEth = newEthBalance * treasuryFee / 10**4; // always 4
            (bool sent,) = pawSwapFactory.feeTo().call{ value: treasuryEth }("");
            require(sent, "Failed to send eth to treasury");
            ethToTransfer -= treasuryEth;
        }

        if (_taxes.liquidityTax != 0) {
            // add to the LP
            uint256 liquidityEth = newEthBalance * (_taxes.liquidityTax / 2) / 10**(_taxes.feeDecimal + 2);
            addLiquidity(liquidityTokens, liquidityEth, tokenAddress);
            ethToTransfer -= liquidityEth;
        }

        // require that we met the minimum set by the user
        require(ethToTransfer >= minEthToReceive, "Minimum amount of eth not received");
        // send the eth to seller
        payable(_msgSender()).transfer(ethToTransfer);

        emit Sell(
            _msgSender(),
            tokensToSwap, 
            ethToTransfer,
            customTaxAmount,
            customTaxAddress,
            extraTax1Amount
        );
    }

    function addTokenTax (uint256 amount) private view returns (uint256) {
        if (_taxes.liquidityTax != 0) {
            amount += amount * (_taxes.liquidityTax / 2) / 10**(_taxes.feeDecimal + 2);
        }
        if (_taxes.burnTax != 0) {
            amount += amount * _taxes.burnTax / 10**(_taxes.feeDecimal + 2);
        }
        if (_taxes.tokenTax != 0) {
            amount += amount * _taxes.tokenTax / 10**(_taxes.feeDecimal + 2);
        }
        return amount;
    }

    function addEthTax (uint256 amount) private view returns (uint256) {
        if (_taxes.tax1 != 0) {
            amount += amount * _taxes.tax1 / 10**(_taxes.feeDecimal + 2);
        }
        if (_taxes.tax2 != 0) {
            amount += amount * _taxes.tax2 / 10**(_taxes.feeDecimal + 2);
        }
        if (_taxes.tax3 != 0) {
            amount += amount * _taxes.tax3 / 10**(_taxes.feeDecimal + 2);
        }
        if (_taxes.tax4 != 0) {
            amount += amount * _taxes.tax4 / 10**(_taxes.feeDecimal + 2);
        }
        if (_taxes.liquidityTax != 0) {
            amount += amount * (_taxes.liquidityTax / 2) / 10**(_taxes.feeDecimal + 2);
        }
        return amount;
    }
    
    function setRouter (address routerAddress) private {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(routerAddress);
        uniswapV2Router = _uniswapV2Router;
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount, address tokenAddress) private {
        token.approve(address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            tokenAddress,
            tokenAmount,
            0,
            0,
            taxStructure.lpTokenHolder(),
            block.timestamp
        );
    }

    function swapEthForTokens(uint256 ethToSwap, uint256 minTokensToReceive, address tokenAddress, bool isExactIn) private {
        address [] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = tokenAddress;

        if (isExactIn) {
            uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: ethToSwap}(
                0,
                path,
                address(this),
                block.timestamp
            );
        } else {
            uniswapV2Router.swapETHForExactTokens{value: ethToSwap}(
                addTokenTax(minTokensToReceive),
                path,
                address(this),
                block.timestamp
            );
        }
    }

    function swapTokensForEth(uint256 tokenAmount, address tokenAddress, uint256 minEthToReceive, bool isExactIn) private {
        address [] memory path = new address[](2);
        path[0] = tokenAddress;
        path[1] = uniswapV2Router.WETH();
        
        token.approve(address(uniswapV2Router), tokenAmount);

        if (isExactIn) {
            uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            );
        } else {
            uniswapV2Router.swapTokensForExactETH(
                addEthTax(minEthToReceive),
                tokenAmount,
                path,
                address(this),
                block.timestamp
            );
        }
    }

    function setTokenTaxContract (address _tokenAddress, address _taxStructureContractAddress) external {
        require (tokenTaxContracts[_tokenAddress] != _taxStructureContractAddress, "Structure already set to this address");
        bool callerIsPawSwapOwner = this.owner() == _msgSender();
        bool callerIsTokenOwner = OwnableContract(_tokenAddress).owner() == _msgSender();
        require (callerIsPawSwapOwner || callerIsTokenOwner, "Permission denied");
        tokenTaxContracts[_tokenAddress] = _taxStructureContractAddress;
    }
    
    function setPawSwapFactory (address _address) external onlyOwner {
        PawSwapFactory _factory = PawSwapFactory(_address);
        pawSwapFactory = _factory;
    }

    function setPawSwapRouter (address _address) external onlyOwner {
        require (pawSwapRouter != _address, "Router already set to this address");
        pawSwapRouter = _address;
    }

    function setTreasuryFee (uint256 _fee) external onlyOwner {
        require (treasuryFee != _fee, "Fee already set to this value");
        require (_fee <= 300, "Fee cannot exceed 3%");
        treasuryFee = _fee;
    }

    function toggleDexExcludedFromTreasuryFee (address _dex, bool _excluded) external onlyOwner {
        dexExcludedFromTreasury[_dex] = _excluded;
    }

    function setPawthereum (address _pawth) external onlyOwner {
        pawthAddress = _pawth;
    }

    function withdrawEthToOwner (uint256 _amount) external onlyOwner {
        payable(_msgSender()).transfer(_amount);
    }

    function withdrawTokenToOwner(address tokenAddress, uint256 amount) external onlyOwner {
        uint256 balance = IERC20(tokenAddress).balanceOf(address(this));
        require(balance >= amount, "Insufficient token balance");

        IERC20(tokenAddress).transfer(_msgSender(), amount);
    }

    function toggleKillSwitch(bool _enabled) external onlyOwner {
        killSwitchEngaged = _enabled;
    }

    receive() external payable {}
}