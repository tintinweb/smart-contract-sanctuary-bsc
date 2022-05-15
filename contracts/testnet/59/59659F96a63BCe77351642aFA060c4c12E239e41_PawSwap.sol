/**
 *Submitted for verification at BscScan.com on 2022-05-15
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.1;

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

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
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
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
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

contract PawSwap is Ownable, ReentrancyGuard {
    // IERC20 private token;
    // ITaxStructure private taxStructure;

    struct TaxStruct {
        IERC20 token;
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

    // struct Taxes {
    //     uint256 tax1;
    //     uint256 tax2;
    //     uint256 tax3;
    //     uint256 tax4;
    //     uint256 tokenTax;
    //     uint256 burnTax;
    //     uint256 liquidityTax;
    //     uint256 customTax;
    //     uint256 lpTokenHolder;
    // }

    // Taxes private _taxes = Taxes(0, 0, 0, 0, 0, 0, 0, 0);

    mapping(address => address) public tokenTaxContracts;
    mapping(address => bool) public dexExcludedFromTreasury;

    PawSwapFactory public pawSwapFactory;

    bool public killSwitchEngaged = false;

    address public pawSwapRouter = 0xb89B3d833A77c78b58157d6f0c6Bc993E60c265A;
    // sets treasury fee to 0.03%
    uint256 public treasuryFee = 3;

    event Buy(
        address buyer,
        uint256 ethSpent,
        uint256 tokensReceived,
        uint256 customTaxAmount,
        address indexed customTaxAddress,
        uint256 extraTax1Amount
    );

    event Sell(
        address seller,
        uint256 tokensSold,
        uint256 ethReceived,
        uint256 customTaxAmount,
        address indexed customTaxAddress,
        uint256 extraTax1Amount
    );

    constructor () {
        PawSwapFactory _factory = PawSwapFactory(
            0x0a839fcfDc58cDEF0362CA9614fdB3724126c4dA
            // _factoryAddr
        );
        pawSwapFactory = _factory;
        dexExcludedFromTreasury[pawSwapRouter];
    }

    function processPreSwapBuyTaxes (
        uint256 ethAmount,
        address customTaxAddress,
        TaxStruct memory taxStructure,
        ITaxStructure taxStructureContract
    ) private returns (uint256, uint256) {
        uint256 ethToSwap = ethAmount;
        uint256 liquidityEth = 0;

        if (!dexExcludedFromTreasury[taxStructure.router]) {
            // take a treasury fee if we are not using the pawswap dex
            uint256 treasuryEth = ethAmount * treasuryFee / 10**4; // always 4
            (bool sent, ) = pawSwapFactory.feeTo().call{value: treasuryEth}("");
            require(sent, "Failed to send eth to treasury");
            // payable(pawSwapFactory.feeTo()).transfer(treasuryEth);
            ethToSwap -= treasuryEth;
        }

        if (taxStructure.liquidityTax != 0) {
            // hold onto some eth to pair with tokens for liquidity
            liquidityEth = ethAmount * (taxStructure.liquidityTax / 2) / 10**(taxStructure.feeDecimal + 2);
            ethToSwap -= liquidityEth;
        }

        if (taxStructure.tax1 != 0) {
            // send eth percentage to the tax1 wallet
            uint256 tax1Eth = ethAmount * taxStructure.tax1 / 10**(taxStructure.feeDecimal + 2);
            // payable(taxStructureContract.tax1Wallet()).transfer(tax1Eth);
            (bool sent, ) = taxStructureContract.tax1Wallet().call{value: tax1Eth}("");
            require(sent, "Failed to send eth to tax1 wallet");
            ethToSwap -= tax1Eth;
        }

        if (taxStructure.tax2 != 0) {
            // send eth percentage to the tax2 wallet
            uint256 tax2Eth = ethAmount * taxStructure.tax2 / 10**(taxStructure.feeDecimal + 2);
            // payable(taxStructureContract.tax2Wallet()).transfer(tax2Eth);
            (bool sent, ) = taxStructureContract.tax2Wallet().call{value: tax2Eth}("");
            require(sent, "Failed to send eth to tax2 wallet");
            ethToSwap -= tax2Eth;
        }

        if (taxStructure.tax3 != 0) {
            // send eth percentage to the tax3 wallet
            uint256 tax3Eth = ethAmount * taxStructure.tax3 / 10**(taxStructure.feeDecimal + 2);
            // payable(taxStructureContract.tax3Wallet()).transfer(tax3Eth);
            (bool sent, ) = taxStructureContract.tax3Wallet().call{value: tax3Eth}("");
            require(sent, "Failed to send eth to tax3 wallet");
            ethToSwap -= tax3Eth;
        }

        if (taxStructure.tax4 != 0) {
            // send eth percentage to the tax4 wallet
            uint256 tax4Eth = ethAmount * taxStructure.tax4 / 10**(taxStructure.feeDecimal + 2);
            // payable(taxStructureContract.tax4Wallet()).transfer(tax4Eth);
            (bool sent, ) = taxStructureContract.tax4Wallet().call{value: tax4Eth}("");
            require(sent, "Failed to send eth to tax4 wallet");
            ethToSwap -= tax4Eth;
        }

        if (taxStructure.customTax != 0) {
            // send to the custom tax address
            uint256 customTaxEth = ethAmount * taxStructure.customTax / 10**(taxStructure.feeDecimal + 2);
            // payable(customTaxAddress).transfer(customTaxEth);
            (bool sent, ) = customTaxAddress.call{value: customTaxEth}("");
            require(sent, "Failed to send eth to custom tax wallet");
            ethToSwap -= customTaxEth;
        }

        return (ethToSwap, liquidityEth);
    }

    function processPostSwapBuyTaxes(
      IERC20 token,
      uint256 tokensFromSwap,
      uint256 liquidityEth,
      TaxStruct memory taxStruct,
      ITaxStructure taxStructureContract
    ) private returns (uint256) {
        uint256 purchasedTokens = tokensFromSwap;

        if (taxStruct.liquidityTax != 0) {
            // add to the LP
            uint256 liquidityTokens = tokensFromSwap * (taxStruct.liquidityTax / 2) / 10**(taxStruct.feeDecimal + 2);
            addLiquidity(liquidityTokens, liquidityEth, taxStruct.lpTokenHolder, token, taxStruct.router);
            purchasedTokens -= liquidityTokens;
        }

        // burn fee is taken in pawth
        if (taxStruct.burnTax != 0) {
            // send to the pawth burn addr
            uint256 burnTokens = tokensFromSwap * taxStruct.burnTax / 10**(taxStruct.feeDecimal + 2);
            token.transfer(taxStructureContract.burnAddress(), burnTokens);
            purchasedTokens -= burnTokens;
        }

        // staking fee is taken in token
        if (taxStruct.tokenTax != 0) {
            // send to the token tax wallet
            uint256 taxTokens = tokensFromSwap * taxStruct.tokenTax / 10**(taxStruct.feeDecimal + 2);
            token.transfer(taxStructureContract.tokenTaxWallet(), taxTokens);
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
    ) external payable nonReentrant {
        require(killSwitchEngaged == false, "Killswitch is engaged");
        require(tokenTaxContracts[tokenAddress] != address(0), "Token not listed");
        
        ITaxStructure _taxStructureContract = ITaxStructure(tokenTaxContracts[tokenAddress]);

        TaxStruct memory _taxStruct = TaxStruct(
            IERC20(tokenAddress),
            _taxStructureContract.tax1BuyAmount(_msgSender()) + extraTax1Amount,
            _taxStructureContract.tax2BuyAmount(_msgSender()),
            _taxStructureContract.tax3BuyAmount(_msgSender()),
            _taxStructureContract.tax4BuyAmount(_msgSender()),
            _taxStructureContract.tokenTaxBuyAmount(_msgSender()),
            _taxStructureContract.burnTaxBuyAmount(_msgSender()),
            _taxStructureContract.liquidityTaxBuyAmount(_msgSender()),
            customTaxAmount,
            _taxStructureContract.feeDecimal(),
            _taxStructureContract.routerAddress(),
            _taxStructureContract.lpTokenHolder()
        );

        (uint256 ethToSwap, uint256 liquidityEth) = processPreSwapBuyTaxes(
          msg.value,
          customTaxAddress,
          _taxStruct,
          _taxStructureContract
        );

        uint256 tokensFromSwap = swapEthForTokens(
          ethToSwap, 
          minTokensToReceive, // this wont get used if IsExactIn is true
          _taxStruct.token, 
          _taxStruct.router, 
          isExactIn
        );

        uint256 purchasedTokens = processPostSwapBuyTaxes(
          _taxStruct.token,
          tokensFromSwap,
          liquidityEth,
          _taxStruct,
          _taxStructureContract
        );

        // require that we met the minimum set by the user
        require (purchasedTokens >= minTokensToReceive);
        // send the tokens to the buyer
        _taxStruct.token.transfer(_msgSender(), purchasedTokens);

        emit Buy(
            _msgSender(),
            msg.value, 
            purchasedTokens,
            customTaxAmount,
            customTaxAddress,
            extraTax1Amount
        );
    }

    function processPreSwapSellTaxes(
        uint256 tokensToSwap,
        TaxStruct memory taxStruct,
        ITaxStructure taxStructureContract
    ) private returns (uint256, uint256) {
        uint256 liquidityTokens;

        if (taxStruct.liquidityTax != 0) {
            // hold onto some tokens to pair with eth for liquidity
            liquidityTokens = tokensToSwap * (taxStruct.liquidityTax / 2) / 10**(taxStruct.feeDecimal + 2);
            tokensToSwap -= liquidityTokens;
        }
    
        // burn fee is taken in pawth
        if (taxStruct.burnTax != 0) {
            // send to the pawth burn addr
            uint256 burnTokens = tokensToSwap * taxStruct.burnTax / 10**(taxStruct.feeDecimal + 2);
            taxStruct.token.transfer(taxStructureContract.burnAddress(), burnTokens);
            tokensToSwap -= burnTokens;
        }

        // staking fee is taken in tokens
        if (taxStruct.tokenTax != 0) {
            // send to the token tax wallet
            uint256 taxTokens = tokensToSwap * taxStruct.tokenTax / 10**(taxStruct.feeDecimal + 2);
            taxStruct.token.transfer(taxStructureContract.tokenTaxWallet(), taxTokens);
            tokensToSwap -= taxTokens;
        }

        return (tokensToSwap, liquidityTokens);
    }

    function processPostSwapSellTaxes(
      uint256 ethFromSwap,
      uint256 liquidityTokens,
      TaxStruct memory taxStruct,
      ITaxStructure taxStructureContract
    ) private returns (uint256) {
        uint256 ethToTransfer = ethFromSwap;

        if (taxStruct.tax1 != 0) {
            // send eth percentage to the tax1 wallet
            uint256 tax1Eth = ethFromSwap * taxStruct.tax1 / 10**(taxStruct.feeDecimal + 2);
            (bool sent, ) = taxStructureContract.tax1Wallet().call{value: tax1Eth}("");
            require(sent, "Failed to send eth to tax1 wallet");
            ethToTransfer -= tax1Eth;
        }

        if (taxStruct.tax2 != 0) {
            // send eth percentage to the tax2 wallet
            uint256 tax2Eth = ethFromSwap * taxStruct.tax2 / 10**(taxStruct.feeDecimal + 2);
            // payable(taxStructureContract.tax2Wallet()).transfer(tax2Eth);
            (bool sent, ) = taxStructureContract.tax2Wallet().call{value: tax2Eth}("");
            require(sent, "Failed to send eth to tax2 wallet");
            ethToTransfer -= tax2Eth;
        }

        if (taxStruct.tax3 != 0) {
            // send eth percentage to the tax3 wallet
            uint256 tax3Eth = ethFromSwap * taxStruct.tax3 / 10**(taxStruct.feeDecimal + 2);
            // payable(taxStructureContract.tax3Wallet()).transfer(tax3Eth);
            (bool sent, ) = taxStructureContract.tax3Wallet().call{value: tax3Eth}("");
            require(sent, "Failed to send eth to tax3 wallet");
            ethToTransfer -= tax3Eth;
        }
    
        if (taxStruct.tax4 != 0) {
            // send eth percentage to the tax4 wallet
            uint256 tax4Eth = ethFromSwap * taxStruct.tax4 / 10**(taxStruct.feeDecimal + 2);
            // payable(taxStructureContract.tax4Wallet()).transfer(tax4Eth);
            (bool sent, ) = taxStructureContract.tax4Wallet().call{value: tax4Eth}("");
            require(sent, "Failed to send eth to tax4 wallet");
            ethToTransfer -= tax4Eth;
        }

        if (!dexExcludedFromTreasury[taxStruct.router]) {
            // take a treasury fee if we are not using the pawswap dex
            uint256 treasuryEth = ethFromSwap * treasuryFee / 10**4; // always 4
            // payable(pawSwapFactory.feeTo()).transfer(treasuryEth);
            (bool sent, ) = pawSwapFactory.feeTo().call{value: treasuryEth}("");
            require(sent, "Failed to send eth to treasury");
            ethToTransfer -= treasuryEth;
        }

        if (taxStruct.liquidityTax != 0) {
            // add to the LP
            uint256 liquidityEth = ethFromSwap * (taxStruct.liquidityTax / 2) / 10**(taxStruct.feeDecimal + 2);
            addLiquidity(liquidityTokens, liquidityEth, taxStruct.lpTokenHolder, taxStruct.token, taxStruct.router);
            ethToTransfer -= liquidityEth;
        }

        return ethToTransfer;
    }

    function sellOnPawSwap (
        address tokenAddress,
        uint256 tokensSold, 
        uint customTaxAmount, 
        address customTaxAddress, 
        uint extraTax1Amount, 
        uint minEthToReceive,
        bool isExactIn
    ) external {
        require(killSwitchEngaged == false, "Killswitch is engaged");
        require(tokenTaxContracts[tokenAddress] != address(0), "Token not listed");

        ITaxStructure _taxStructureContract = ITaxStructure(tokenTaxContracts[tokenAddress]);

        TaxStruct memory _taxStruct = TaxStruct(
            IERC20(tokenAddress),
            _taxStructureContract.tax1SellAmount(_msgSender()) + extraTax1Amount,
            _taxStructureContract.tax2SellAmount(_msgSender()),
            _taxStructureContract.tax3SellAmount(_msgSender()),
            _taxStructureContract.tax4SellAmount(_msgSender()),
            _taxStructureContract.tokenTaxSellAmount(_msgSender()),
            _taxStructureContract.burnTaxSellAmount(_msgSender()),
            _taxStructureContract.liquidityTaxSellAmount(_msgSender()),
            customTaxAmount,
            _taxStructureContract.feeDecimal(),
            _taxStructureContract.routerAddress(),
            _taxStructureContract.lpTokenHolder()
        );

        _taxStruct.token.transferFrom(_msgSender(), address(this), tokensSold);
        (uint256 tokensToSwap, uint256 liquidityTokens) = processPreSwapSellTaxes(
          tokensSold,
          _taxStruct,
          _taxStructureContract
        );

        uint256 ethFromSwap = swapTokensForEth(
          tokensToSwap, 
          minEthToReceive,
          _taxStruct,
          isExactIn
        );

        uint256 ethToTransfer = processPostSwapSellTaxes(
          ethFromSwap, 
          liquidityTokens, 
          _taxStruct,
          _taxStructureContract
        );

        // require that we met the minimum set by the user
        // require(ethToTransfer >= minEthToReceive, "Insufficient ETH out");
        // send the eth to seller
        sendEthToUser(ethToTransfer);

        emit Sell(
            _msgSender(),
            tokensToSwap, 
            ethToTransfer,
            customTaxAmount,
            customTaxAddress,
            extraTax1Amount
        );
    }

    function sendEthToUser (uint256 amount) private {
        (bool sent, ) = _msgSender().call{value: amount}("");
        require(sent, "Failed to send eth to user");
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount, address lpTokenHolder, IERC20 token, address routerAddress) private {
        IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(routerAddress);
        token.approve(address(uniswapV2Router), tokenAmount);

        uint256 initialEthBalance = address(this).balance;
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(token),
            tokenAmount,
            0,
            0,
            lpTokenHolder,
            block.timestamp
        );
        if (address(this).balance > initialEthBalance) {
          uint256 dustEth = address(this).balance - initialEthBalance;
          // send any excess eth from liquidity adding to the user
          if (dustEth > 0) {
              (bool sent,) = _msgSender().call{ value: dustEth }("");
              require(sent, "Failed to send excess eth to user");
          }
        }
    }

    function swapEthForTokens(
      uint256 ethToSwap,
      uint256 minAmountOut,
      IERC20 token, 
      address routerAddress,
      bool isExactIn
    ) private returns (uint256) {
        IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(routerAddress);
        address [] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(token);

        uint256 initialTokenBalance = token.balanceOf(address(this));

        if (isExactIn) {
          // if user specified amount of eth to spend, get as many tokens as possible
          uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: ethToSwap}(
              0,
              path,
              address(this),
              block.timestamp
          );
        } else {
          // if user specified amount of tokens to receive, get exactly that
          // there may be some dust eth left over
          uint256 initialEthBalance = address(this).balance;
          uniswapV2Router.swapETHForExactTokens{value: ethToSwap}(
              minAmountOut,
              path,
              address(this),
              block.timestamp
          );
          if (address(this).balance > initialEthBalance) {
            uint256 dustEth = address(this).balance - initialEthBalance;
            // send any excess eth from swap to the buyer
            if (dustEth > 0) {
                (bool sent,) = _msgSender().call{ value: dustEth }("");
                require(sent, "Failed to send excess eth to user");
            }
          }
        }

        return token.balanceOf(address(this)) - initialTokenBalance;
    }

    function swapTokensForEth(
      uint256 tokenAmount,
      uint256 minEthToReceive,
      TaxStruct memory taxStruct,
      bool isExactIn
    ) private returns (uint256) {
        IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(taxStruct.router);
        address [] memory path = new address[](2);
        path[0] = address(taxStruct.token);
        path[1] = uniswapV2Router.WETH();
        
        taxStruct.token.approve(address(uniswapV2Router), tokenAmount);

        uint256 initialEthBalance = address(this).balance;
        if (isExactIn) {
          uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
          );
        } else {                        
          // do something for not exact in
          uniswapV2Router.swapTokensForExactETH(
            minEthToReceive,
            tokenAmount,
            path,
            address(this),
            block.timestamp
          );
        }

        return address(this).balance - initialEthBalance;
    }

    function getSellAmountIn (
        address seller,
        address tokenAddress,
        uint customTaxAmount,
        uint extraTax1Amount,
        uint minEthToReceive
    ) external view returns (uint256) {
        require(tokenTaxContracts[tokenAddress] != address(0), "Token not listed");
        ITaxStructure _taxStructureContract = ITaxStructure(tokenTaxContracts[tokenAddress]);

        TaxStruct memory _taxStruct = TaxStruct(
            IERC20(tokenAddress),
            _taxStructureContract.tax1SellAmount(seller) + extraTax1Amount,
            _taxStructureContract.tax2SellAmount(seller),
            _taxStructureContract.tax3SellAmount(seller),
            _taxStructureContract.tax4SellAmount(seller),
            _taxStructureContract.tokenTaxSellAmount(seller),
            _taxStructureContract.burnTaxSellAmount(seller),
            _taxStructureContract.liquidityTaxSellAmount(seller),
            customTaxAmount,
            _taxStructureContract.feeDecimal(),
            _taxStructureContract.routerAddress(),
            _taxStructureContract.lpTokenHolder()
        );

        uint256 ethPercentageTaxedPostSwap = 
            _taxStruct.liquidityTax / 2 + _taxStruct.tax1 + _taxStruct.tax2 +
            _taxStruct.tax3 + _taxStruct.tax4 + customTaxAmount;

        uint256 ethAmountTaxedPostSwap = minEthToReceive * ethPercentageTaxedPostSwap / 10**(_taxStruct.feeDecimal + 2);
        
        if (!dexExcludedFromTreasury[_taxStruct.router]) {
            ethAmountTaxedPostSwap -= minEthToReceive * treasuryFee / 10**4;
        }

        uint256 tokensToSwapForMinEth = getTokensToSwapForMinEth(minEthToReceive + ethAmountTaxedPostSwap, _taxStruct);

        uint256 tokenPercentageTaxedPreSwap = _taxStruct.liquidityTax / 2 + _taxStruct.burnTax + _taxStruct.tokenTax;
        uint256 tokenAmountTaxedPreSwap = tokensToSwapForMinEth * tokenPercentageTaxedPreSwap / 10**(_taxStruct.feeDecimal + 2);

        return tokensToSwapForMinEth + tokenAmountTaxedPreSwap;
    }

    function getBuyAmountIn (
        address buyer,
        address tokenAddress,
        uint customTaxAmount,
        uint extraTax1Amount,
        uint minTokensToReceive
    ) external view returns (uint256) {
        require(tokenTaxContracts[tokenAddress] != address(0), "Token not listed");
        ITaxStructure _taxStructureContract = ITaxStructure(tokenTaxContracts[tokenAddress]);

        TaxStruct memory _taxStruct = TaxStruct(
            IERC20(tokenAddress),
            _taxStructureContract.tax1BuyAmount(buyer) + extraTax1Amount,
            _taxStructureContract.tax2BuyAmount(buyer),
            _taxStructureContract.tax3BuyAmount(buyer),
            _taxStructureContract.tax4BuyAmount(buyer),
            _taxStructureContract.tokenTaxBuyAmount(buyer),
            _taxStructureContract.burnTaxBuyAmount(buyer),
            _taxStructureContract.liquidityTaxBuyAmount(buyer),
            customTaxAmount,
            _taxStructureContract.feeDecimal(),
            _taxStructureContract.routerAddress(),
            _taxStructureContract.lpTokenHolder()
        );

        uint256 tokenPercentageTaxedPostSwap = _taxStruct.liquidityTax / 2 + _taxStruct.burnTax + _taxStruct.tokenTax;
        uint256 tokenAmountTaxedPostSwap = minTokensToReceive * tokenPercentageTaxedPostSwap / 10**(_taxStruct.feeDecimal + 2);

        uint256 ethToSwapForMinTokens = getEthToSwapForMinTokens(minTokensToReceive + tokenAmountTaxedPostSwap, _taxStruct);
        
        uint256 ethPercentageTaxedPreSwap = 
            _taxStruct.liquidityTax / 2 + _taxStruct.tax1 + _taxStruct.tax2 +
            _taxStruct.tax3 + _taxStruct.tax4 + customTaxAmount;

        uint256 ethAmountTaxedPreSwap = ethToSwapForMinTokens * ethPercentageTaxedPreSwap / 10**(_taxStruct.feeDecimal + 2);

        if (!dexExcludedFromTreasury[_taxStruct.router]) {
            ethAmountTaxedPreSwap += ethToSwapForMinTokens * treasuryFee / 10**4;
        }

        return ethToSwapForMinTokens + ethAmountTaxedPreSwap;
    }

    function getEthToSwapForMinTokens (uint256 minTokensToReceive, TaxStruct memory taxStruct) private view returns (uint256) {
        IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(taxStruct.router);
        address WETH = uniswapV2Router.WETH();
        // sort token and weth
        (address token0, address token1) = address(taxStruct.token) < WETH 
            ? (address(taxStruct.token), WETH)
            : (WETH, address(taxStruct.token));
        // get the pair and the reserves
        IUniswapV2Factory uniswapV2Factory = IUniswapV2Factory(uniswapV2Router.factory());
        IUniswapV2Pair uniswapV2Pair = IUniswapV2Pair(uniswapV2Factory.getPair(token0, token1));
        (uint112 reserve0, uint112 reserve1, ) = uniswapV2Pair.getReserves();
        return uniswapV2Router.getAmountIn(
            minTokensToReceive, // amount tokens out
            token0 == address(taxStruct.token) ? reserve1 : reserve0, // eth reserve in
            token0 == address(taxStruct.token) ? reserve0 : reserve1 // token reserve out
        );
    }

    function getTokensToSwapForMinEth (uint256 minEthToReceive, TaxStruct memory taxStruct) private view returns (uint256) {
        IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(taxStruct.router);
        address WETH = uniswapV2Router.WETH();
        // sort token and weth
        (address token0, address token1) = address(taxStruct.token) < WETH 
            ? (address(taxStruct.token), WETH)
            : (WETH, address(taxStruct.token));
        // get the pair and the reserves
        IUniswapV2Factory uniswapV2Factory = IUniswapV2Factory(uniswapV2Router.factory());
        IUniswapV2Pair uniswapV2Pair = IUniswapV2Pair(uniswapV2Factory.getPair(token0, token1));
        (uint112 reserve0, uint112 reserve1, ) = uniswapV2Pair.getReserves();
        return uniswapV2Router.getAmountIn(
            minEthToReceive, // amount eth out
            token0 == address(taxStruct.token) ? reserve0 : reserve1, // token reserve in
            token0 == address(taxStruct.token) ? reserve1 : reserve0 // eth reserve out
        );
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