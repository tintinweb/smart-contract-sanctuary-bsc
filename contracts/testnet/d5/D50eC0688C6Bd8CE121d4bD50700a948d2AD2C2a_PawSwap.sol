/**
 *Submitted for verification at BscScan.com on 2022-04-06
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-21
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.12;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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
    using SafeMath for uint256;

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
    }

    Taxes private _taxes = Taxes(0, 0, 0, 0, 0, 0, 0, 0);

    mapping(address => address) public tokenTaxContracts;
    mapping(address => bool) public dexExcludedFromTreasury;
    mapping(address => bool) public dexExcludedFromPawthHop;

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

    constructor (address _pawth, address _factoryAddr, address _routerAddr) public {
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
        uint256 minTokensToReceive
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
            taxStructure.tax1BuyAmount(_msgSender()).add(extraTax1Amount),
            taxStructure.tax2BuyAmount(_msgSender()),
            taxStructure.tax3BuyAmount(_msgSender()),
            taxStructure.tax4BuyAmount(_msgSender()),
            taxStructure.tokenTaxBuyAmount(_msgSender()),
            taxStructure.burnTaxBuyAmount(_msgSender()),
            taxStructure.liquidityTaxBuyAmount(_msgSender()),
            customTaxAmount
        );

        uint256 feeDecimal = taxStructure.feeDecimal();
        uint256 liquidityEth;

        if (taxStructure.routerAddress() != pawSwapRouter) {
            // take a treasury fee if we are not using the pawswap dex
            uint256 treasuryEth = msg.value.mul(treasuryFee).div(10**4); // always 4
            payable(pawSwapFactory.feeTo()).transfer(treasuryEth);
            ethToSwap = ethToSwap.sub(treasuryEth);
        }

        if (_taxes.liquidityTax != 0) {
            // hold onto some eth to pair with tokens for liquidity
            liquidityEth = msg.value.mul(_taxes.liquidityTax).div(10**(feeDecimal + 2));
            ethToSwap = ethToSwap.sub(liquidityEth);
        }

        if (_taxes.tax1 != 0) {
            // send eth percentage to the tax1 wallet
            uint256 tax1Eth = msg.value.mul(_taxes.tax1).div(10**(feeDecimal + 2));
            payable(taxStructure.tax1Wallet()).transfer(tax1Eth);
            ethToSwap = ethToSwap.sub(tax1Eth);
        }

        if (_taxes.tax2 != 0) {
            // send eth percentage to the tax2 wallet
            uint256 tax2Eth = msg.value.mul(_taxes.tax2).div(10**(feeDecimal + 2));
            payable(taxStructure.tax2Wallet()).transfer(tax2Eth);
            ethToSwap = ethToSwap.sub(tax2Eth);
        }

        if (_taxes.tax3 != 0) {
            // send eth percentage to the tax3 wallet
            uint256 tax3Eth = msg.value.mul(_taxes.tax3).div(10**(feeDecimal + 2));
            payable(taxStructure.tax3Wallet()).transfer(tax3Eth);
            ethToSwap = ethToSwap.sub(tax3Eth);
        }

        if (_taxes.tax4 != 0) {
            // send eth percentage to the tax4 wallet
            uint256 tax4Eth = msg.value.mul(_taxes.tax4).div(10**(feeDecimal + 2));
            payable(taxStructure.tax4Wallet()).transfer(tax4Eth);
            ethToSwap = ethToSwap.sub(tax4Eth);
        }

        if (_taxes.customTax != 0) {
            // send to the custom tax address
            uint256 customTaxEth = msg.value.mul(_taxes.customTax).div(10**(feeDecimal + 2));
            payable(customTaxAddress).transfer(customTaxEth);
            ethToSwap = ethToSwap.sub(customTaxEth);
        }

        uint256 initialTokenBalance = token.balanceOf(address(this));

        swapEthForTokens(ethToSwap, tokenAddress);

        uint256 newTokenBalance = token.balanceOf(address(this)).sub(initialTokenBalance);
        uint256 purchasedTokens = newTokenBalance;

        if (_taxes.liquidityTax != 0) {
            // add to the LP
            uint256 liquidityTokens = newTokenBalance.mul(_taxes.liquidityTax).div(10**(feeDecimal + 2));
            addLiquidity(liquidityTokens, liquidityEth, taxStructure.lpTokenHolder(), tokenAddress);
            purchasedTokens = purchasedTokens.sub(liquidityTokens);
        }

        // burn fee is taken in pawth
        if (_taxes.burnTax != 0) {
            // send to the pawth burn addr
            uint256 burnTokens = newTokenBalance.mul(_taxes.burnTax).div(10**(feeDecimal + 2));
            token.transfer(taxStructure.burnAddress(), burnTokens);
            purchasedTokens = purchasedTokens.sub(burnTokens);
        }

        // staking fee is taken in token
        if (_taxes.tokenTax != 0) {
            // send to the token tax wallet
            uint256 taxTokens = newTokenBalance.mul(_taxes.tokenTax).div(10**(feeDecimal + 2));
            token.transfer(taxStructure.tokenTaxWallet(), taxTokens);
            purchasedTokens = purchasedTokens.sub(taxTokens);
        }

        // require that we met the minimum set by the user
        require (purchasedTokens >= minTokensToReceive);
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
        uint minEthToReceive
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
            taxStructure.tax1SellAmount(_msgSender()).add(extraTax1Amount),
            taxStructure.tax2SellAmount(_msgSender()),
            taxStructure.tax3SellAmount(_msgSender()),
            taxStructure.tax4SellAmount(_msgSender()),
            taxStructure.tokenTaxSellAmount(_msgSender()),
            taxStructure.burnTaxSellAmount(_msgSender()),
            taxStructure.liquidityTaxSellAmount(_msgSender()),
            customTaxAmount
        );

        uint256 feeDecimal = taxStructure.feeDecimal();
        uint256 liquidityTokens;

        if (_taxes.liquidityTax != 0) {
            // hold onto some tokens to pair with eth for liquidity
            liquidityTokens = tokensToSwap.mul(_taxes.liquidityTax).div(10**(feeDecimal + 2));
            tokensToSwap = tokensToSwap.sub(liquidityTokens);
        }
    
        // burn fee is taken in pawth
        if (_taxes.burnTax != 0) {
            // send to the pawth burn addr
            uint256 burnTokens = tokensToSwap.mul(_taxes.burnTax).div(10**(feeDecimal + 2));
            token.transfer(taxStructure.burnAddress(), burnTokens);
            tokensToSwap = tokensToSwap.sub(burnTokens);
        }

        // staking fee is taken in tokens
        if (_taxes.tokenTax != 0) {
            // send to the token tax wallet
            uint256 taxTokens = tokensToSwap.mul(_taxes.tokenTax).div(10**(feeDecimal + 2));
            token.transfer(taxStructure.tokenTaxWallet(), taxTokens);
            tokensToSwap = tokensToSwap.sub(taxTokens);
        }

        uint256 initialEthBalance = address(this).balance;

        swapTokensForEth(tokensToSwap, tokenAddress);

        uint256 newEthBalance = address(this).balance.sub(initialEthBalance);
        uint256 ethToTransfer = newEthBalance;

        if (_taxes.tax1 != 0) {
            // send eth percentage to the tax1 wallet
            uint256 tax1Eth = newEthBalance.mul(_taxes.tax1).div(10**(feeDecimal + 2));
            payable(taxStructure.tax1Wallet()).transfer(tax1Eth);
            ethToTransfer = ethToTransfer.sub(tax1Eth);
        }

        if (_taxes.tax2 != 0) {
            // send eth percentage to the tax2 wallet
            uint256 tax2Eth = newEthBalance.mul(_taxes.tax2).div(10**(feeDecimal + 2));
            payable(taxStructure.tax2Wallet()).transfer(tax2Eth);
            ethToTransfer = ethToTransfer.sub(tax2Eth);
        }

        if (_taxes.tax3 != 0) {
            // send eth percentage to the tax3 wallet
            uint256 tax3Eth = newEthBalance.mul(_taxes.tax3).div(10**(feeDecimal + 2));
            payable(taxStructure.tax3Wallet()).transfer(tax3Eth);
            ethToTransfer = ethToTransfer.sub(tax3Eth);
        }
    
        if (_taxes.tax4 != 0) {
            // send eth percentage to the tax4 wallet
            uint256 tax4Eth = newEthBalance.mul(_taxes.tax4).div(10**(feeDecimal + 2));
            payable(taxStructure.tax4Wallet()).transfer(tax4Eth);
            ethToTransfer = ethToTransfer.sub(tax4Eth);
        }

        if (taxStructure.routerAddress() != pawSwapRouter) {
            // take a treasury fee if we are not using the pawswap dex
            uint256 treasuryEth = newEthBalance.mul(treasuryFee).div(10**4); // always 4
            payable(pawSwapFactory.feeTo()).transfer(treasuryEth);
            ethToTransfer = ethToTransfer.sub(treasuryEth);
        }

        if (_taxes.liquidityTax != 0) {
            // add to the LP
            uint256 liquidityEth = newEthBalance.mul(_taxes.liquidityTax).div(10**(feeDecimal + 2));
            addLiquidity(liquidityTokens, liquidityEth, taxStructure.lpTokenHolder(), tokenAddress);
            ethToTransfer = ethToTransfer.sub(liquidityEth);
        }

        // require that we met the minimum set by the user
        require(ethToTransfer >= minEthToReceive);
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
    
    function setRouter (address routerAddress) private {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(routerAddress);
        uniswapV2Router = _uniswapV2Router;
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount, address lpTokenHolder, address tokenAddress) private {
        token.approve(address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            tokenAddress,
            tokenAmount,
            0,
            0,
            lpTokenHolder,
            block.timestamp
        );
    }

    function swapEthForTokens(uint256 ethToSwap, address tokenAddress) private {
        // make an extra hop through pawthereum if trading something other than pawth
        // unless the dex that is being used is excluded from doing so
        address [] memory path;
        if (
            !dexExcludedFromPawthHop[address(uniswapV2Router)] &&
            tokenAddress != pawthAddress
        ) {
            path = new address[](4);
            path[0] = uniswapV2Router.WETH();
            path[1] = pawthAddress;
            path[2] = uniswapV2Router.WETH();
            path[3] = tokenAddress;
        } else {
            path = new address[](2);
            path[0] = uniswapV2Router.WETH();
            path[1] = tokenAddress;
        }

        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: ethToSwap}(
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function swapTokensForEth(uint256 tokenAmount, address tokenAddress) private {
        // make an extra hop through pawthereum if trading something other than pawth
        // unless the dex that is being used is excluded from doing so
        address [] memory path;
        if (
            !dexExcludedFromPawthHop[address(uniswapV2Router)] &&
            tokenAddress != pawthAddress
        ) {
            path = new address[](4);
            path[0] = tokenAddress;
            path[1] = uniswapV2Router.WETH();
            path[2] = pawthAddress;
            path[3] = uniswapV2Router.WETH();
        } else {
            path = new address[](2);
            path[0] = tokenAddress;
            path[1] = uniswapV2Router.WETH();
        }
        token.approve(address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
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

    function toggleDexExcludedFromPawthHop (address _dex, bool _excluded) external onlyOwner {
        dexExcludedFromPawthHop[_dex] = _excluded;
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