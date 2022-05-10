/**
 *Submitted for verification at BscScan.com on 2022-05-10
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
interface ITaxStructure {
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
    // IERC20 private token;
    // ITaxStructure private taxStructure;

    struct TaxStruct {
        uint256 tax1;
        uint256 tax2;
        uint256 tax3;
        uint256 tax4;
        uint256 tokenTax;
        uint256 burnTax;
        uint256 liquidityTax;
        uint256 customTax;
        uint256 feeDecimal;
        address router;
        address lpTokenHolder;
    }

    // Taxes private _taxes = Taxes(0, 0, 0, 0, 0, 0, 0, 0, 0);

    mapping(address => address) public tokenTaxContracts;
    mapping(address => bool) public dexExcludedFromTreasury;

    IUniswapV2Router02 public uniswapV2Router;

    PawSwapFactory public pawSwapFactory;

    bool public killSwitchEngaged = false;

    address public pawthAddress = 0x5aBD80b8108f90c8525a183547D6ecc004112C22;
    address public pawSwapRouter = 0xc2a8dD01aabB1e21bF2535Ca1C222ffC916e6609;
    // sets treasury fee to 0.03%
    uint256 public treasuryFee = 3;

    event Buy(
        address buyer,
        uint256 ethSpent,
        uint256 tokensReceived
    );

    event BuyDono(
        address buyer,
        uint256 customTaxAmount,
        address indexed customTaxAddress
    );

    event Sell(
        address seller,
        uint256 tokensSold,
        uint256 ethReceived
    );

    event SellDono(
        address seller,
        uint256 customTaxAmount,
        address indexed customTaxAddress
    );

    constructor (address _pawth, address _factoryAddr, address _routerAddr) {
        pawthAddress = _pawth;

        PawSwapFactory _factory = PawSwapFactory(
            _factoryAddr
        );
        pawSwapFactory = _factory;

        dexExcludedFromTreasury[_routerAddr];
    }

    function getEthToSwapAndSendTaxes(
        uint256 ethAmount,
        address customTaxAddress,
        TaxStruct memory taxStruct, 
        ITaxStructure taxStuctureContract
    ) private returns (uint256, uint256) {
        uint256 ethToSwap = ethAmount;
        uint256 liquidityEth;

        if (!dexExcludedFromTreasury[taxStruct.router]) {
            // take a treasury fee if we are not using the pawswap dex
            uint256 treasuryEth = ethAmount * treasuryFee / 10**4; // always 4
            (bool sent,) = pawSwapFactory.feeTo().call{ value: treasuryEth }("");
            require(sent, "Failed to send eth to treasury");
            ethToSwap -= treasuryEth;
        }

        if (taxStruct.liquidityTax != 0) {
            // hold onto some eth to pair with tokens for liquidity
            liquidityEth = ethAmount * (taxStruct.liquidityTax / 2) / 10**(taxStruct.feeDecimal + 2);
            ethToSwap -= liquidityEth;
        }

        if (taxStruct.tax1 != 0) {
            // send eth percentage to the tax1 wallet
            uint256 tax1Eth = ethAmount * taxStruct.tax1 / 10**(taxStruct.feeDecimal + 2);
            (bool sent,) = taxStuctureContract.tax1Wallet().call{ value: tax1Eth }("");
            require(sent, "Failed to send eth to tax 1 wallet");
            ethToSwap -= tax1Eth;
        }

        if (taxStruct.tax2 != 0) {
            // send eth percentage to the tax2 wallet
            uint256 tax2Eth = ethAmount * taxStruct.tax2 / 10**(taxStruct.feeDecimal + 2);
            (bool sent,) = taxStuctureContract.tax2Wallet().call{ value: tax2Eth }("");
            require(sent, "Failed to send eth to tax 2 wallet");
            ethToSwap -= tax2Eth;
        }

        if (taxStruct.tax3 != 0) {
            // send eth percentage to the tax3 wallet
            uint256 tax3Eth = ethAmount * taxStruct.tax3 / 10**(taxStruct.feeDecimal + 2);
            (bool sent,) = taxStuctureContract.tax3Wallet().call{ value: tax3Eth }("");
            require(sent, "Failed to send eth to tax 3 wallet");
            ethToSwap -= tax3Eth;
        }

        if (taxStruct.tax4 != 0) {
            // send eth percentage to the tax4 wallet
            uint256 tax4Eth = ethAmount * taxStruct.tax4 / 10**(taxStruct.feeDecimal + 2);
            (bool sent,) = taxStuctureContract.tax4Wallet().call{ value: tax4Eth }("");
            require(sent, "Failed to send eth to tax 4 wallet");
            ethToSwap -= tax4Eth;
        }

        if (taxStruct.customTax != 0) {
            // send to the custom tax address
            uint256 customTaxEth = ethAmount * taxStruct.customTax / 10**(taxStruct.feeDecimal + 2);
            (bool sent,) = customTaxAddress.call{ value: customTaxEth }("");
            require(sent, "Failed to send eth to custom tax wallet");
            emit BuyDono(
                _msgSender(),
                customTaxEth,
                customTaxAddress
            );
            ethToSwap -= customTaxEth;
        }
        return (ethToSwap, liquidityEth);
    }

    function getPurchasedTokensAndSendTaxes(
        IERC20 token, 
        uint256 tokensFromSwap, 
        uint256 liquidityEth, 
        TaxStruct memory taxStruct, 
        ITaxStructure taxStructure
    ) private returns (uint256) {
        uint256 purchasedTokens;

        if (taxStruct.liquidityTax != 0) {
            // add to the LP
            uint256 liquidityTokens = tokensFromSwap * (taxStruct.liquidityTax / 2) / 10**(taxStruct.feeDecimal + 2);
            addLiquidity(token, liquidityTokens, liquidityEth, taxStruct);
            purchasedTokens -= liquidityTokens;
        }

        // burn fee is taken in pawth
        if (taxStruct.burnTax != 0) {
            // send to the pawth burn addr
            uint256 burnTokens = tokensFromSwap * taxStruct.burnTax / 10**(taxStruct.feeDecimal + 2);
            token.transfer(taxStructure.burnAddress(), burnTokens);
            purchasedTokens -= burnTokens;
        }

        // staking fee is taken in token
        if (taxStruct.tokenTax != 0) {
            // send to the token tax wallet
            uint256 taxTokens = tokensFromSwap * taxStruct.tokenTax / 10**(taxStruct.feeDecimal + 2);
            token.transfer(taxStructure.tokenTaxWallet(), taxTokens);
            purchasedTokens -= taxTokens;
        }
        return purchasedTokens;
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

        IERC20 token = IERC20(tokenAddress);
        ITaxStructure taxStructure = ITaxStructure(tokenTaxContracts[tokenAddress]);

        TaxStruct memory _taxStruct = TaxStruct(
            taxStructure.tax1BuyAmount(_msgSender()) + extraTax1Amount,
            taxStructure.tax2BuyAmount(_msgSender()),
            taxStructure.tax3BuyAmount(_msgSender()),
            taxStructure.tax4BuyAmount(_msgSender()),
            taxStructure.tokenTaxBuyAmount(_msgSender()),
            taxStructure.burnTaxBuyAmount(_msgSender()),
            taxStructure.liquidityTaxBuyAmount(_msgSender()),
            customTaxAmount,
            taxStructure.feeDecimal(),
            taxStructure.routerAddress(),
            taxStructure.lpTokenHolder()
        );

        (uint256 ethToSwap, uint256 liquidityEth) = getEthToSwapAndSendTaxes(msg.value, customTaxAddress, _taxStruct, taxStructure);
    
        (uint256 dustEth, uint256 tokensFromSwap) = swapEthForTokens(
            ethToSwap, 
            minTokensToReceive,
            token, 
            isExactIn,
            _taxStruct
        );

        uint256 purchasedTokens = getPurchasedTokensAndSendTaxes(token, tokensFromSwap, liquidityEth, _taxStruct, taxStructure);

        // require that we met the minimum set by the user
        require (purchasedTokens >= minTokensToReceive, "Minimum amount of tokens not received");
        // send the tokens to the buyer
        token.transfer(_msgSender(), purchasedTokens);
        // send any excess eth from swap to the buyer
        if (dustEth > 0) {
            (bool sent,) = _msgSender().call{ value: dustEth }("");
            require(sent, "Failed to send excess eth to user");
        }

        emit Buy(
            _msgSender(),
            msg.value, 
            purchasedTokens
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
        IERC20 token = IERC20(tokenAddress);
        ITaxStructure taxStructure = ITaxStructure(tokenTaxContracts[tokenAddress]);

        token.transferFrom(_msgSender(), address(this), tokensToSwap);

        TaxStruct memory _taxStruct = TaxStruct(
            taxStructure.tax1SellAmount(_msgSender()) + extraTax1Amount,
            taxStructure.tax2SellAmount(_msgSender()),
            taxStructure.tax3SellAmount(_msgSender()),
            taxStructure.tax4SellAmount(_msgSender()),
            taxStructure.tokenTaxSellAmount(_msgSender()),
            taxStructure.burnTaxSellAmount(_msgSender()),
            taxStructure.liquidityTaxSellAmount(_msgSender()),
            customTaxAmount,
            taxStructure.feeDecimal(),
            taxStructure.routerAddress(),
            taxStructure.lpTokenHolder()
        );

        uint256 liquidityTokens;

        if (_taxStruct.liquidityTax != 0) {
            // hold onto half of liquidity token tax amount to pair with eth for liquidity
            liquidityTokens = tokensToSwap * (_taxStruct.liquidityTax / 2) / 10**(_taxStruct.feeDecimal + 2);
            tokensToSwap -= liquidityTokens;
        }
    
        // burn fee is taken in pawth
        if (_taxStruct.burnTax != 0) {
            // send to the pawth burn addr
            uint256 burnTokens = tokensToSwap * _taxStruct.burnTax / 10**(_taxStruct.feeDecimal + 2);
            token.transfer(taxStructure.burnAddress(), burnTokens);
            tokensToSwap -= burnTokens;
        }

        // staking fee is taken in tokens
        if (_taxStruct.tokenTax != 0) {
            // send to the token tax wallet
            uint256 taxTokens = tokensToSwap * _taxStruct.tokenTax / 10**(_taxStruct.feeDecimal + 2);
            token.transfer(taxStructure.tokenTaxWallet(), taxTokens);
            tokensToSwap -= taxTokens;
        }

        uint256 newEthBalance = swapTokensForEth(
            token,
            tokensToSwap, 
            tokenAddress,
            minEthToReceive,
            isExactIn,
            _taxStruct
        );
        
        uint256 ethToTransfer = newEthBalance;

        if (_taxStruct.tax1 != 0) {
            // send eth percentage to the tax1 wallet
            uint256 tax1Eth = newEthBalance * _taxStruct.tax1 / 10**(_taxStruct.feeDecimal + 2);
            (bool sent,) = taxStructure.tax1Wallet().call{ value: tax1Eth }("");
            require(sent, "Failed to send eth to tax 1 wallet");
            ethToTransfer -= tax1Eth;
        }

        if (_taxStruct.tax2 != 0) {
            // send eth percentage to the tax2 wallet
            uint256 tax2Eth = newEthBalance * _taxStruct.tax2 / 10**(_taxStruct.feeDecimal + 2);
            (bool sent,) = taxStructure.tax2Wallet().call{ value: tax2Eth }("");
            require(sent, "Failed to send eth to tax 2 wallet");
            ethToTransfer -= tax2Eth;
        }

        if (_taxStruct.tax3 != 0) {
            // send eth percentage to the tax3 wallet
            uint256 tax3Eth = newEthBalance * _taxStruct.tax3 / 10**(_taxStruct.feeDecimal + 2);
            (bool sent,) = taxStructure.tax3Wallet().call{ value: tax3Eth }("");
            require(sent, "Failed to send eth to tax 3 wallet");
            ethToTransfer -= tax3Eth;
        }
    
        if (_taxStruct.tax4 != 0) {
            // send eth percentage to the tax4 wallet
            uint256 tax4Eth = newEthBalance * _taxStruct.tax4 / 10**(_taxStruct.feeDecimal + 2);
            (bool sent,) = taxStructure.tax4Wallet().call{ value: tax4Eth }("");
            require(sent, "Failed to send eth to tax 4 wallet");
            ethToTransfer -= tax4Eth;
        }

        if (_taxStruct.customTax != 0) {
            // send to the custom tax address
            uint256 customTaxEth = newEthBalance * _taxStruct.customTax / 10**(_taxStruct.feeDecimal + 2);
            (bool sent,) = customTaxAddress.call{ value: customTaxEth }("");
            require(sent, "Failed to send eth to custom tax wallet");
            emit SellDono(
                _msgSender(),
                customTaxEth,
                customTaxAddress
            );
            ethToTransfer -= customTaxEth;
        }

        if (!dexExcludedFromTreasury[_taxStruct.router]) {
            // take a treasury fee if we are not using the pawswap dex
            uint256 treasuryEth = newEthBalance * treasuryFee / 10**4; // always 4
            (bool sent,) = pawSwapFactory.feeTo().call{ value: treasuryEth }("");
            require(sent, "Failed to send eth to treasury");
            ethToTransfer -= treasuryEth;
        }

        if (_taxStruct.liquidityTax != 0) {
            // add to the LP
            uint256 liquidityEth = newEthBalance * (_taxStruct.liquidityTax / 2) / 10**(_taxStruct.feeDecimal + 2);
            addLiquidity(token, liquidityTokens, liquidityEth, _taxStruct);
            ethToTransfer -= liquidityEth;
        }

        // require that we met the minimum set by the user
        require(ethToTransfer >= minEthToReceive, "Minimum amount of eth not received");
        // send the eth to seller
        (bool ethSent,) = _msgSender().call{ value: ethToTransfer }("");
        require(ethSent, "Failed to send eth to user");

        emit Sell(
            _msgSender(),
            tokensToSwap, 
            ethToTransfer
        );
    }

    function addTokenTax (uint256 amount, TaxStruct memory taxStruct) private pure returns (uint256) {
        uint256 amountPlusTax = amount;
        if (taxStruct.liquidityTax != 0) {
            amountPlusTax += amount * (taxStruct.liquidityTax / 2) / 10**(taxStruct.feeDecimal + 2);
        }
        if (taxStruct.burnTax != 0) {
            amountPlusTax += amount * taxStruct.burnTax / 10**(taxStruct.feeDecimal + 2);
        }
        if (taxStruct.tokenTax != 0) {
            amountPlusTax += amount * taxStruct.tokenTax / 10**(taxStruct.feeDecimal + 2);
        }
        return amountPlusTax;
    }

    function addEthTax (uint256 amount, TaxStruct memory taxStruct) private pure returns (uint256) {
        uint256 amountPlusTax = amount;
        if (taxStruct.tax1 != 0) {
            amountPlusTax += amount * taxStruct.tax1 / 10**(taxStruct.feeDecimal + 2);
        }
        if (taxStruct.tax2 != 0) {
            amountPlusTax += amount * taxStruct.tax2 / 10**(taxStruct.feeDecimal + 2);
        }
        if (taxStruct.tax3 != 0) {
            amountPlusTax += amount * taxStruct.tax3 / 10**(taxStruct.feeDecimal + 2);
        }
        if (taxStruct.tax4 != 0) {
            amountPlusTax += amount * taxStruct.tax4 / 10**(taxStruct.feeDecimal + 2);
        }
        if (taxStruct.liquidityTax != 0) {
            amountPlusTax += amount * (taxStruct.liquidityTax / 2) / 10**(taxStruct.feeDecimal + 2);
        }
        return amountPlusTax;
    }
    
    function setRouter (address routerAddress) private {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(routerAddress);
        uniswapV2Router = _uniswapV2Router;
    }

    function addLiquidity(IERC20 token, uint256 tokenAmount, uint256 ethAmount, TaxStruct memory taxStruct) private {
        token.approve(taxStruct.router, tokenAmount);

        IUniswapV2Router02(taxStruct.router).addLiquidityETH{value: ethAmount}(
            address(token),
            tokenAmount,
            0,
            0,
            taxStruct.lpTokenHolder,
            block.timestamp
        );
    }

    function swapEthForTokens(uint256 ethToSwap, uint256 minTokensToReceive, IERC20 token, bool isExactIn, TaxStruct memory taxStruct) private returns (uint256, uint256) {
        address [] memory path = new address[](2);
        path[0] = IUniswapV2Router02(taxStruct.router).WETH();
        path[1] = address(token);

        uint256 initialTokenBalance = token.balanceOf(address(this));

        if (isExactIn) {
            IUniswapV2Router02(taxStruct.router).swapExactETHForTokensSupportingFeeOnTransferTokens{value: ethToSwap}(
                0,
                path,
                address(this),
                block.timestamp
            );
            return (token.balanceOf(address(this)) - initialTokenBalance, 0);
        } else {
            uint256 initialEthBalance = address(this).balance;
            IUniswapV2Router02(taxStruct.router).swapETHForExactTokens{value: ethToSwap}(
                addTokenTax(minTokensToReceive, taxStruct),
                path,
                address(this),
                block.timestamp
            );
            return (
                token.balanceOf(address(this)) - initialTokenBalance,
                address(this).balance - initialEthBalance
            );
        }
    }

    function swapTokensForEth(IERC20 token, uint256 tokenAmount, address tokenAddress, uint256 minEthToReceive, bool isExactIn, TaxStruct memory taxStruct) private returns (uint256) {
        address [] memory path = new address[](2);
        path[0] = tokenAddress;
        path[1] = IUniswapV2Router02(taxStruct.router).WETH();
        
        token.approve(taxStruct.router, tokenAmount);

        uint256 initialEthBalance = address(this).balance;

        if (isExactIn) {
            IUniswapV2Router02(taxStruct.router).swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            );
        } else {
            IUniswapV2Router02(taxStruct.router).swapTokensForExactETH(
                addEthTax(minEthToReceive, taxStruct),
                tokenAmount,
                path,
                address(this),
                block.timestamp
            );
        }
        
        return address(this).balance - initialEthBalance;
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
        (bool sent,) = _msgSender().call{ value: _amount }("");
        require(sent, "Failed to withdraw eth");
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