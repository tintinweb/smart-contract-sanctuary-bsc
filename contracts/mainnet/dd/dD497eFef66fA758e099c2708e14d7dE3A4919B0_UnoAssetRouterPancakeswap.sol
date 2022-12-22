// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {IUnoFarmPancakeswap as Farm} from './interfaces/IUnoFarmPancakeswap.sol'; 
import "../../interfaces/IUniswapV2Router.sol";
import '../../interfaces/IUnoFarmFactory.sol';
import '../../interfaces/IUnoAccessManager.sol'; 
import '../../interfaces/IUniswapV2Pair.sol';
import '../../interfaces/IWBNB.sol';
import '../../libs/SafeBEP20.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@pancakeswap/pancake-swap-lib/contracts/token/BEP20/IBEP20.sol';
import '@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';

contract UnoAssetRouterPancakeswap is Initializable, PausableUpgradeable, UUPSUpgradeable {
    using SafeBEP20 for IBEP20;

    /**
     * @dev Contract Variables:
     * farmFactory - The contract that deploys new Farms and links them to {lpPair}s.
     * accessManager - Role manager contract.
     */
    IUnoFarmFactory public farmFactory;
    IUnoAccessManager public accessManager;

    bytes32 private constant DISTRIBUTOR_ROLE = keccak256('DISTRIBUTOR_ROLE');
    bytes32 private constant PAUSER_ROLE = keccak256('PAUSER_ROLE');

    uint256 public fee;

    address public constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    IUniswapV2Router01 public constant PancakeswapRouter = IUniswapV2Router01(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address private constant OneInchRouter = 0x1111111254EEB25477B68fb85Ed929f73A960582;

    event Deposit(address indexed lpPool, address indexed sender, address indexed recipient, uint256 amount);
    event Withdraw(address indexed lpPool, address indexed sender, address indexed recipient, uint256 amount);
    event Distribute(address indexed lpPool, uint256 reward);
    
    event FeeChanged(uint256 previousFee, uint256 newFee);

    modifier onlyRole(bytes32 role){
        require(accessManager.hasRole(role, msg.sender), 'CALLER_NOT_AUTHORIZED');
        _;
    }

    // ============ Methods ============

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _accessManager, address _farmFactory) external initializer{
        require (_accessManager != address(0), 'BAD_ACCESS_MANAGER');
        require (_farmFactory != address(0), 'BAD_FARM_FACTORY');

        __Pausable_init();
        accessManager = IUnoAccessManager(_accessManager);
        farmFactory = IUnoFarmFactory(_farmFactory);
    }

    receive() external payable {
        require(msg.sender == WBNB || msg.sender == address(PancakeswapRouter), 'ONLY_ACCEPT_WBNB'); // only accept ETH via fallback from the WBNB or router contract
    }

    /**
     * @dev Deposits tokens in the given pool. Creates new Farm contract if there isn't one deployed for the {lpPair} and deposits tokens in it. Emits a {Deposit} event.
     * @param lpPair - Address of the pool to deposit tokens in.
     * @param amountA  - Token A amount to deposit.
     * @param amountB -  Token B amount to deposit.
     * @param amountAMin - Bounds the extent to which the B/A price can go up before the transaction reverts.
     * @param amountBMin - Bounds the extent to which the A/B price can go up before the transaction reverts.
     * @param recipient - Address which will receive the deposit.
     
     * @return sentA - Token A amount sent to the farm.
     * @return sentB - Token B amount sent to the farm.
     * @return liquidity - Total liquidity sent to the farm (in lpTokens).
     */
    function deposit(address lpPair, uint256 amountA, uint256 amountB, uint256 amountAMin, uint256 amountBMin, address recipient) external whenNotPaused returns(uint256 sentA, uint256 sentB, uint256 liquidity){
        require(amountA > 0 && amountB > 0, "NO_TOKENS_SENT");
        Farm farm = Farm(farmFactory.Farms(lpPair));
        if(farm == Farm(address(0))){
            farm = Farm(farmFactory.createFarm(lpPair));
        }

        address tokenA = farm.tokenA();
        address tokenB = farm.tokenB();
        IBEP20(tokenA).safeTransferFrom(msg.sender, address(this), amountA);
        IBEP20(tokenB).safeTransferFrom(msg.sender, address(this), amountB);

        (sentA, sentB, liquidity) = _addLiquidity(tokenA, tokenB, amountA, amountB, amountAMin, amountBMin, address(farm));
        farm.deposit(liquidity, recipient);

        emit Deposit(lpPair, msg.sender, recipient, liquidity); 
    }

    /**
     * @dev Autoconverts BNB into WBNB and deposits tokens in the given pool. Creates new Farm contract if there isn't one deployed for the {lpStakingPool} and deposits tokens in it. Emits a {Deposit} event.
     * @param lpPair - Address of the pool to deposit tokens in.
     * @param amountToken  - Token amount to deposit.
     * @param amountTokenMin - Bounds the extent to which the TOKEN/WBNB price can go up before the transaction reverts.
     * @param amountETHMin - Bounds the extent to which the WBNB/TOKEN price can go up before the transaction reverts.
     * @param recipient - Address which will receive the deposit.
     
     * @return sentToken - Token amount sent to the farm.
     * @return sentETH - WBNB amount sent to the farm.
     * @return liquidity - Total liquidity sent to the farm (in lpTokens).
     */
    function depositETH(address lpPair, uint256 amountToken, uint256 amountTokenMin, uint256 amountETHMin, address recipient) external payable whenNotPaused returns(uint256 sentToken, uint256 sentETH, uint256 liquidity){
        require(msg.value > 0, "NO_BNB_SENT");
        require(amountToken > 0, "NO_TOKEN_SENT");
        Farm farm = Farm(farmFactory.Farms(lpPair));
        if(farm == Farm(address(0))){
            farm = Farm(farmFactory.createFarm(lpPair));
        }

        address tokenA = farm.tokenA();
        address tokenB = farm.tokenB();
        if (tokenA == WBNB) {
            IBEP20(tokenB).safeTransferFrom(msg.sender, address(this), amountToken);
            (sentToken, sentETH, liquidity) = _addLiquidityETH(tokenB, amountToken, amountTokenMin, amountETHMin, address(farm));
        } else if (tokenB == WBNB) {
            IBEP20(tokenA).safeTransferFrom(msg.sender, address(this), amountToken);
            (sentToken, sentETH, liquidity) = _addLiquidityETH(tokenA, amountToken, amountTokenMin, amountETHMin, address(farm));
        } else {
            revert("NOT_WBNB_POOL");
        }
        farm.deposit(liquidity, recipient);

        emit Deposit(lpPair, msg.sender, recipient, liquidity);
    }

    /**
     * @dev Deposits single token in the given pool. Creates new Farm contract if there isn't one deployed for the {lpPair}, swaps {token} for pool tokens and deposits them. Emits a {Deposit} event.
     * @param lpPair - Address of the pool to deposit tokens in.
     * @param token  - Address of a token to enter the pool.
     * @param amount - Amount of token sent.
     * @param swapData - Parameter with which 1inch router is being called with.
     * @param amountAMin - Bounds the extent to which the B/A price can go up before the transaction reverts.
     * @param amountBMin - Bounds the extent to which the A/B price can go up before the transaction reverts.
     * @param recipient - Address which will receive the deposit.
     
     * @return sent - Total {token} amount sent to the farm. NOTE: Returns dust left from swap in {token}, but if A/B amounts are not correct also returns dust in pool's tokens.
     * @return liquidity - Total liquidity sent to the farm (in lpTokens).
     */
    function depositSingleAsset(address lpPair, address token, uint256 amount, bytes[2] calldata swapData, uint256 amountAMin, uint256 amountBMin, address recipient) external whenNotPaused returns(uint256 sent, uint256 liquidity){
        require(amount > 0, "NO_TOKEN_SENT");
        Farm farm = Farm(farmFactory.Farms(lpPair));
        if(farm == Farm(address(0))){
            farm = Farm(farmFactory.createFarm(lpPair));
        }

        IBEP20(token).safeTransferFrom(msg.sender, address(this), amount);
        IBEP20(token).approve(OneInchRouter, amount);

        sent = amount;
        uint256 amountA;
        uint256 amountB;
        address tokenA = farm.tokenA();
        address tokenB = farm.tokenB();

        if (tokenA != token) {
            (uint256 returnAmount, uint256 spentAmount) = _swap(swapData[0]);
            amount -= spentAmount;
            amountA = returnAmount;
        }
        if (tokenB != token) {
            (uint256 returnAmount, uint256 spentAmount) = _swap(swapData[1]);
            amount -= spentAmount;
            amountB = returnAmount;
        }

        if (tokenA == token) {
            amountA = amount;
        } else if (tokenB == token) {
            amountB = amount;
        } else if(amount > 0) {
            sent -= amount;
            IBEP20(token).safeTransfer(msg.sender, amount);
        }

        require(amountA > 0 && amountB > 0, "NO_TOKENS_SENT");
        (,,liquidity) = _addLiquidity(tokenA, tokenB, amountA, amountB, amountAMin, amountBMin, address(farm));
        farm.deposit(liquidity, recipient);
        
        emit Deposit(lpPair, msg.sender, recipient, liquidity);
    }
     
    /**
     * @dev Deposits single BNB in the given pool. Creates new Farm contract if there isn't one deployed for the {lpPair}, swaps BNB for pool tokens and deposits them. Emits a {Deposit} event.
     * @param lpPair - Address of the pool to deposit tokens in.
     * @param swapData - Parameter with which 1inch router is being called with.
     * @param amountAMin - Bounds the extent to which the B/A price can go up before the transaction reverts.
     * @param amountBMin - Bounds the extent to which the A/B price can go up before the transaction reverts.
     * @param recipient - Address which will receive the deposit.
     
     * @return sentETH - Total BNB amount sent to the farm. NOTE: Returns dust left from swap in BNB, but if A/B amount are not correct also returns dust in pool's tokens.
     * @return liquidity - Total liquidity sent to the farm (in lpTokens).
     */
    function depositSingleETH(address lpPair, bytes[2] calldata swapData, uint256 amountAMin, uint256 amountBMin, address recipient) external payable whenNotPaused returns(uint256 sentETH, uint256 liquidity){
        require(msg.value > 0, "NO_BNB_SENT");
        Farm farm = Farm(farmFactory.Farms(lpPair));
        if(farm == Farm(address(0))){
            farm = Farm(farmFactory.createFarm(lpPair));
        }

        uint256 amount = msg.value;
        IWBNB(WBNB).deposit{value: amount}();
        IBEP20(WBNB).approve(OneInchRouter, amount);

        sentETH = amount;
        uint256 amountA;
        uint256 amountB;
        address tokenA = farm.tokenA();
        address tokenB = farm.tokenB();

        if (tokenA != WBNB) {
            (uint256 returnAmount, uint256 spentAmount) = _swap(swapData[0]);
            amount -= spentAmount;
            amountA = returnAmount;
        }
        if (tokenB != WBNB) {
            (uint256 returnAmount, uint256 spentAmount) = _swap(swapData[1]);
            amount -= spentAmount;
            amountB = returnAmount;
        }

        if (tokenA == WBNB) {
            amountA = amount;
        } else if (tokenB == WBNB) {
            amountB = amount;
        } else if (amount > 0) {
            sentETH -= amount;
            IWBNB(WBNB).withdraw(amount);
            payable(msg.sender).transfer(amount);
        }

        require(amountA > 0 && amountB > 0, "NO_TOKENS_SENT");
        (,,liquidity) = _addLiquidity(tokenA, tokenB, amountA, amountB, amountAMin, amountBMin, address(farm));
        farm.deposit(liquidity, recipient);

        emit Deposit(lpPair, msg.sender, recipient, liquidity);
    }

    /**
     * @dev Deposits tokens in the given pool. Creates new Farm contract if there isn't one deployed for the {lpPair} and deposits tokens in it. Emits a {Deposit} event.
     * @param lpPair - Address of the pool to deposit tokens in.
     * @param amount - LP Token amount to deposit.
     * @param recipient - Address which will receive the deposit.
     */
    function depositLP(address lpPair, uint256 amount, address recipient) external whenNotPaused{
        require(amount > 0, "NO_TOKEN_SENT");
        Farm farm = Farm(farmFactory.Farms(lpPair));
        if(farm == Farm(address(0))){
            farm = Farm(farmFactory.createFarm(lpPair));
        }

        IBEP20(lpPair).safeTransferFrom(msg.sender, address(farm), amount);
        farm.deposit(amount, recipient);

        emit Deposit(lpPair, msg.sender, recipient, amount); 
    }

    /** 
     * @dev Withdraws tokens from the given pool. Emits a {Withdraw} event.
     * @param lpPair - LP pool to withdraw from.
     * @param amount - LP amount to withdraw. 
     * @param amountAMin - The minimum amount of tokenA that must be received for the transaction not to revert.
     * @param amountBMin - The minimum amount of tokenB that must be received for the transaction not to revert.
     * @param withdrawLP - True: Withdraw in LP tokens, False: Withdraw in normal tokens.
     * @param recipient - The address which will receive tokens.

     * @return amountA - Token A amount sent to the {recipient}, 0 if withdrawLP == false.
     * @return amountB - Token B amount sent to the {recipient}, 0 if withdrawLP == false.
     */ 
    function withdraw(address lpPair, uint256 amount, uint256 amountAMin, uint256 amountBMin, bool withdrawLP, address recipient) external returns(uint256 amountA, uint256 amountB){
        Farm farm = Farm(farmFactory.Farms(lpPair));
        require(farm != Farm(address(0)),'FARM_NOT_EXISTS');
        
        (amountA, amountB) = farm.withdraw(amount, amountAMin, amountBMin, withdrawLP, msg.sender, recipient);
        emit Withdraw(lpPair, msg.sender, recipient, amount);  
    }

    /** 
     * @dev Autoconverts WBNB into BNB and withdraws tokens from the pool. Emits a {Withdraw} event.
     * @param lpPair - LP pool to withdraw from.
     * @param amount - LP amount to withdraw. 
     * @param amountTokenMin - The minimum amount of token that must be received for the transaction not to revert.
     * @param amountETHMin - The minimum amount of BNB that must be received for the transaction not to revert.
     * @param recipient - The address which will receive tokens.

     * @return amountToken - Token amount sent to the {recipient}.
     * @return amountETH - BNB amount sent to the {recipient}.
     */ 
    function withdrawETH(address lpPair, uint256 amount, uint256 amountTokenMin, uint256 amountETHMin, address recipient) external returns(uint256 amountToken, uint256 amountETH){
        Farm farm = Farm(farmFactory.Farms(lpPair));
        require(farm != Farm(address(0)),'FARM_NOT_EXISTS');

        address tokenA = farm.tokenA();
        address tokenB = farm.tokenB();

        if (tokenA == WBNB) {
            (amountETH, amountToken) = farm.withdraw(amount, amountETHMin, amountTokenMin, false, msg.sender, address(this));
            IBEP20(tokenB).safeTransfer(recipient, amountToken);
        } else if (tokenB == WBNB) {
            (amountToken, amountETH) = farm.withdraw(amount, amountTokenMin, amountETHMin, false, msg.sender, address(this)); 
            IBEP20(tokenA).safeTransfer(recipient, amountToken);
        } else {
            revert("NOT_WBNB_POOL");
        }

        IWBNB(WBNB).withdraw(amountETH);
        payable(recipient).transfer(amountETH);
        emit Withdraw(lpPair, msg.sender, recipient, amount);
    }

    /**
     * @dev Distributes tokens between users.
     * @param lpPair - LP pool to distribute tokens in.
     * @param swapInfos - Arrays of structs with token arrays describing swap routes (rewardTokenToTokenA, rewardTokenToTokenB, rewarderTokenToTokenA, rewarderTokenToTokenB) and minimum amounts of output tokens that must be received for the transaction not to revert.
     * @param feeSwapInfo - Struct with token arrays describing swap route (rewardTokenToFeeToken, rewarderTokenToFeeToken) and minimum amounts of output tokens that must be received for the transaction not to revert.
     * @param feeTo - Address to collect fees to.
     *
     * Note: This function can only be called by the distributor.
     */ 
    function distribute(
        address lpPair,
        Farm.SwapInfo[2] calldata swapInfos,
        Farm.SwapInfo calldata feeSwapInfo,
        address feeTo
    ) external whenNotPaused onlyRole(DISTRIBUTOR_ROLE) {
        Farm farm = Farm(farmFactory.Farms(lpPair));
        require(farm != Farm(address(0)), 'FARM_NOT_EXISTS');

        uint256 reward = farm.distribute(swapInfos, feeSwapInfo, Farm.FeeInfo(feeTo, fee));
        emit Distribute(lpPair, reward);
    }

    /**
     * @dev Returns tokens staked by the {_address} for the given {lpPair}.
     * @param _address - The address to check stakes for.
     * @param lpPair - LP pool to check stakes in.

     * @return stakeLP - Total user stake(in LP tokens).
     * @return stakeA - Token A stake.
     * @return stakeB - Token B stake.
     */
    function userStake(address _address, address lpPair) external view returns (uint256 stakeLP, uint256 stakeA, uint256 stakeB) {
        Farm farm = Farm(farmFactory.Farms(lpPair));
        if (farm != Farm(address(0))) {
            stakeLP = farm.userBalance(_address);
            (stakeA, stakeB) = _getTokenStake(lpPair, stakeLP);
        }
    }

    /**
     * @dev Returns total amount locked in the pool. Doesn't take pending rewards into account.
     * @param lpPair - LP pool to check total deposits in.

     * @return totalDepositsLP - Total deposits (in LP tokens).
     * @return totalDepositsA - Token A deposits.
     * @return totalDepositsB - Token B deposits.
     */  
    function totalDeposits(address lpPair) external view returns (uint256 totalDepositsLP, uint256 totalDepositsA, uint256 totalDepositsB) {
        Farm farm = Farm(farmFactory.Farms(lpPair));
        if (farm != Farm(address(0))) {
            totalDepositsLP = farm.getTotalDeposits(); 
            (totalDepositsA, totalDepositsB) = _getTokenStake(lpPair, totalDepositsLP);
        }
    }

    /**
     * @dev Returns addresses of tokens in {lpPair}.
     * @param lpPair - LP pair to check tokens in.

     * @return tokens - Tokens addresses.
     */  
    function getTokens(address lpPair) external view returns(IBEP20[] memory tokens){
        tokens = new IBEP20[](2);
        tokens[0] = IBEP20(IUniswapV2Pair(lpPair).token0());
        tokens[1] = IBEP20(IUniswapV2Pair(lpPair).token1());
    }

    /**
     * @dev Deposits assets to router & refunds dust.
     */ 
    function _addLiquidity(
        address tokenA,
        address tokenB, 
        uint256 amountA, 
        uint256 amountB, 
        uint256 amountAMin, 
        uint256 amountBMin, 
        address farm
    ) internal returns(uint256 sentA, uint256 sentB, uint256 liquidity){
        IBEP20(tokenA).approve(address(PancakeswapRouter), amountA);
        IBEP20(tokenB).approve(address(PancakeswapRouter), amountB);

        (sentA, sentB, liquidity) = PancakeswapRouter.addLiquidity(tokenA, tokenB, amountA, amountB, amountAMin, amountBMin, farm, block.timestamp);
        // Refund dust
        IBEP20(tokenA).safeTransfer(msg.sender, amountA - sentA);
		IBEP20(tokenB).safeTransfer(msg.sender, amountB - sentB);
    }

    /**
     * @dev Deposits assets to router & refunds dust.
     */ 
    function _addLiquidityETH(
        address token,
        uint256 amount, 
        uint256 amountTokenMin, 
        uint256 amountETHMin, 
        address farm
    ) internal returns(uint256 sentToken, uint256 sentETH, uint256 liquidity){
        IBEP20(token).approve(address(PancakeswapRouter), amount);

        (sentToken, sentETH, liquidity) = PancakeswapRouter.addLiquidityETH{value: msg.value}(token, amount, amountTokenMin, amountETHMin, farm, block.timestamp);
        // Refund dust
        IBEP20(token).safeTransfer(msg.sender, amount - sentToken);
        payable(msg.sender).transfer(msg.value - sentETH);
    }

    /**
     * @dev Swaps assets using 1inch exchange.
     */  
    function _swap(bytes calldata swapData) internal returns(uint256 returnAmount, uint256 spentAmount){
        (bool success, bytes memory data) = OneInchRouter.call(swapData);
        require(success, "SWAP_NOT_SUCCESSFUL");
        (returnAmount, spentAmount) = abi.decode(data, (uint256, uint256));
    }

    /**
     * @dev Converts LP tokens to normal tokens, value(amountA) == value(amountB) == 0.5*amountLP
     * @param lpPair - LP pair for conversion.
     * @param amountLP - Amount of LP tokens to convert.

     * @return amountA - Token A amount.
     * @return amountB - Token B amount.
     */ 
    function _getTokenStake(address lpPair, uint256 amountLP) internal view returns (uint256 amountA, uint256 amountB) {
        uint256 totalSupply = IBEP20(lpPair).totalSupply();
        amountA = amountLP * IBEP20(IUniswapV2Pair(lpPair).token0()).balanceOf(lpPair) / totalSupply;
        amountB = amountLP * IBEP20(IUniswapV2Pair(lpPair).token1()).balanceOf(lpPair) / totalSupply;
    }

    /**
     * @dev Change fee amount.
     * @param _fee -New fee to collect from farms. [10^18 == 100%]
     *
     * Note: This function can only be called by ADMIN_ROLE.
     */ 
    function setFee(uint256 _fee) external onlyRole(accessManager.ADMIN_ROLE()){
        require (_fee <= 1 ether, "BAD_FEE");
        if(fee != _fee){
            emit FeeChanged(fee, _fee); 
            fee = _fee;
        }
    }
 
    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _authorizeUpgrade(address) internal override onlyRole(accessManager.ADMIN_ROLE()) {

    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import '@pancakeswap/pancake-swap-lib/contracts/token/BEP20/IBEP20.sol';
import '@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol';

/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeBEP20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            'SafeBEP20: decreased allowance below zero'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
interface IWBNB {
    function deposit() external payable;
    function withdraw(uint wad) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;
import "./IUnoAccessManager.sol"; 

interface IUnoFarmFactory {
    event FarmDeployed(address indexed farmAddress);
    
    function accessManager() external view returns (IUnoAccessManager);
    function assetRouter() external view returns (address);
    function farmBeacon() external view returns (address);
    function pools(uint256) external view returns (address);

    function Farms(address) external view returns (address);
    function createFarm(address pool) external returns (address);
    function poolLength() external view returns (uint256);
    function upgradeFarms(address newImplementation) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

interface IUnoAccessManager {
    event RoleGranted(bytes32 indexed role, address indexed account);
    event RoleRevoked(bytes32 indexed role, address indexed account);

    function hasRole(bytes32 role, address account) external view returns (bool);
    function ADMIN_ROLE() external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT 
pragma solidity 0.8.10;

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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface IUnoFarmPancakeswap {
    struct SwapInfo{
        address[] route;
        uint256 amountOutMin;
    }
    struct FeeInfo {
        address feeTo;
        uint256 fee;
    }

    function rewardToken() external view returns (address);
    function lpPair() external view returns (address);
    function tokenA() external view returns (address);
    function tokenB() external view returns (address);
    function pid() external view returns (uint256);
    function assetRouter() external view returns (address);

    function initialize( address _lpPair, address _assetRouter) external;

    function deposit(uint256 amount, address recipient) external;
    function withdraw(uint256 amount, uint256 amountAMin, uint256 amountBMin, bool withdrawLP, address origin, address recipient) external returns(uint256 amountA, uint256 amountB);

    function distribute(
        SwapInfo[2] calldata swapInfos,
        SwapInfo calldata feeSwapInfo,
        FeeInfo calldata feeInfo
    ) external returns(uint256 reward);

    function userBalance(address _address) external view returns (uint256);
    function getTotalDeposits() external view returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.4.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;

import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../ERC1967/ERC1967UpgradeUpgradeable.sol";
import "./Initializable.sol";

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate that the this implementation remains valid after an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeaconUpgradeable.sol";
import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/StorageSlotUpgradeable.sol";
import "../utils/Initializable.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822ProxiableUpgradeable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}