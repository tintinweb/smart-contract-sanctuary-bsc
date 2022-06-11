// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.0;

interface INToken {

    event Mint(address indexed from, uint256 value);
    event Burn(address indexed from, uint256 value);

    function mint(address user, uint256 amount) external;
    function burn(address user, uint256 amount) external;

    function scaledTotalSupply() external returns (uint256);
    function getUserBalance(address user) external returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

// import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/ISwap.sol";
import "./interfaces/IVault.sol";
import "./interfaces/IRegistry.sol";
import "./interfaces/INToken.sol";
import "./interfaces/IWBNB.sol";
import "./libraries/Errors.sol";
import "./NToken.sol";
import "./libraries/DataTypes.sol";

contract Vault is IVault {

    using SafeMath for uint256;
    // BUSD contract address on the testnet
    // address public constant BUSD = 0x8301F2213c0eeD49a7E28Ae4c3e91722919B8B47;
    // BUSD contract address on the mainnet

    uint256 public watermark; //Stores the max price of each nToken
    uint256 public lastFeeDate; //Stores fee taken last date

    /*

    Management fee: % diario (% anual/365)
      - Deposit & Withdraw:
        1) lastMgtFeeDate se inicializa con la Fecha de creación del Vault
        2) En cada operación se calcula el nº de días que ha pasado desde que se cobró por última vez el management fee.
        3) Se cobra nº de días desde la última, multiplicado por el fee diario.
        4) Se obtiene el dinero pre-Money (previo al deposit), y se aplica el %.
        5) Se cobra el % calculado minteando nuevos Share Tokens.


    Performance fee: % diario (% anual/365)
      - Deposit & Withdraw:
        1) lastPerFeeDate se inicializa con la Fecha de creación del Vault
        2) Se comprueba si el valor actual sel Share token es superior al valor del watermark. En tal caso se calcula el nº de días que ha pasado desde que se cobró por última vez el management fee.
        3) Se cobra nº de días desde la última, multiplicado por el fee diario.
        4) Se obtiene el dinero pre-Money (previo al deposit), y se aplica el %.
        5) Se cobra el % calculado minteando nuevos Share Tokens.


        UPDATE Performance

        de la diferencia de precio del share token entre los 2 momentos, sacas el performance real
Y dices, 20% de performance
entonces si el TVL en el momento 1, es de 5M y en el momento 2 es de 7M
porque si lo calculas sobre el TVL del momento 2 (7M) estarías teniendo en cuenta entradas/salidas de capital, que no deberían aplicar
Ejemplo: Si había 5M de TVL, con 1$/share (momento 1) y luego 7M de TVL, con 1,2$/share (momento 2)
el aumento de TVL, derivado únicamente del performance ha sido de 1M (20% de 5M)
y sobre ese millón de aumento, se aplicariía el performance fee


    */

    address public constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    uint256 public constant MAX_BPS  = 100000;
    uint256 public constant MIN_BPS  = 1000;


    // treasury account to save Platform Fee
    address private treasury;

    // vault's creator address
    address public creator;

    // vault name
    string public vaultName;
    uint256 public numInvestors;

    mapping(address => uint256) public balances;
    mapping(address => bool) public isInvestor;

    INToken internal nToken;
    ISwap internal navePortfolioSwap;
    IRegistry internal registry;

    DataTypes.TokenOut[] public tokenOuts;

    uint256 public entryFeeRate;
    uint256 public maintenanceFeeRate;
    uint256 public performanceFeeRate;

    modifier validAmount(uint256 amount) {
        require(amount > 0, Errors.VL_INVALID_AMOUNT);
        _;
    }

    modifier onlyTreasury {
        require(msg.sender == treasury, Errors.NOT_ADMIN);
        _;
    }

    modifier onlyCreator {
        require(msg.sender == creator, Errors.VL_NOT_CREATOR);
        _;
    }

    modifier onlyInvestor {
        require(
            isInvestor[msg.sender] || msg.sender == creator || msg.sender == treasury,
            Errors.VL_NOT_INVESTOR
        );
        _;
    }

    constructor(
        address _creator,
        address _treasury,
        DataTypes.VaultData memory _vaultData,
        uint256 _entryFeeRate,
        uint256 _maintenanceFeeRate,
        uint256 _performanceFeeRate,
        ISwap _navePortfolioSwap
    ) {
        creator = _creator;
        treasury = _treasury;

        vaultName = _vaultData.vaultName;

        entryFeeRate = _entryFeeRate;
        maintenanceFeeRate = (_maintenanceFeeRate * MIN_BPS)/365;
        performanceFeeRate = (_performanceFeeRate * MIN_BPS)/365;

        navePortfolioSwap = _navePortfolioSwap;
        registry = IRegistry(msg.sender);

        // Create LP Token(NToken) contract
        nToken = new NToken(
            IVault(address(this)),
            _vaultData.nTokenName,
            _vaultData.nTokenSymbol
        );

        // Store vault token distribution
        for (uint256 i = 0; i < _vaultData.tokenAddresses.length; i++) {
            tokenOuts.push(
                DataTypes.TokenOut(_vaultData.tokenAddresses[i], _vaultData.percents[i])
            );
        }

        emit Initialized(
            address(this),
            msg.sender,
            _vaultData.vaultName,
            _vaultData.nTokenName,
            _vaultData.nTokenSymbol,
            _vaultData.tokenAddresses,
            _vaultData.percents,
            _entryFeeRate,
            _maintenanceFeeRate,
            _performanceFeeRate
        );
    }

    function deposit() external override payable validAmount(msg.value) {
        uint256 entryFee = 0;
        // Check if this is the first deposit.
        if(balances[msg.sender] == 0) {
            addInvestor(msg.sender);
        }

        _takeFees();

        entryFee = takeEntryFee(msg.sender, msg.value);

        uint256 inputAmount = msg.value - entryFee;
        balances[msg.sender] += inputAmount;

        uint256 preTVLInBUSD = 0;
        for (uint256 i = 0; i < tokenOuts.length; i++) {
            // Calculate TVL(pre-money) before deposit.
            uint256 tokenAmount =
                IERC20(tokenOuts[i].tokenAddress).balanceOf(address(this));
            if (tokenAmount != 0) {
                preTVLInBUSD += ISwap(navePortfolioSwap).getAmountOutMin(
                    tokenOuts[i].tokenAddress,
                    BUSD,
                    tokenAmount
                );
            }
            // Distribute deposit amount(xBNB) into respective tokens.
            swapBNBForTokens(
                tokenOuts[i].tokenAddress,
                inputAmount * tokenOuts[i].percent / 100
            );
        }
        // calculate input amount in BUSD
        uint256 amountInBUSD = ISwap(navePortfolioSwap).getAmountOutMin(
            ISwap(navePortfolioSwap).wBNB(),
            BUSD,
            inputAmount
        );

        // Mint LP Tokens
        if (preTVLInBUSD == 0) {
            INToken(nToken).mint(msg.sender, amountInBUSD);
        } else {
            uint256 nTokenSupply = INToken(nToken).scaledTotalSupply();
            INToken(nToken).mint(
                msg.sender,
                amountInBUSD.mul(nTokenSupply).div(preTVLInBUSD)
            );
        }

        emit Deposit(address(this), creator, msg.sender, msg.value, amountInBUSD, entryFee);
    }

    /**
   * @dev Withdraws BNB from the vault, burning the equivalent nTokens `amount` owned
   * @param _amount The underlying amount to be withdrawn
   *   - Send the value type(uint256).max in order to withdraw the whole nToken balance
   **/

    function withdraw(uint256 _amount) external override onlyInvestor {
        if (_amount == type(uint256).max) {
            removeInvestor(msg.sender);
        }

        _takeFees();

        uint256 nTokenBalance = INToken(nToken).getUserBalance(msg.sender);
        require(_amount <= nTokenBalance, Errors.VL_NOT_ENOUGH_AMOUNT);

        for (uint256 i = 0; i < tokenOuts.length; i++) {
            uint256 tokenAmountToSwap = IERC20(tokenOuts[i].tokenAddress).balanceOf(address(this))
                .mul(_amount)
                .div(INToken(nToken).scaledTotalSupply());

            swapTokensForBNB(tokenOuts[i].tokenAddress, tokenAmountToSwap);
        }

        // burn LP Token
        INToken(nToken).burn(msg.sender, _amount);

        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, Errors.VL_WITHDRAW_FAILED);

        emit Withdraw(msg.sender, _amount);
    }

    function nTokenAddress() external view returns(address) {
        return address(nToken);
    }

    function setEntryFee(uint256 _newEntryFeeRate) public onlyCreator {
        entryFeeRate = _newEntryFeeRate;
    }

    function setTreasury(address _newTreasury) public onlyTreasury {
        require(_newTreasury != address(0), Errors.NOT_ZERO_ADDRESS);
        treasury = _newTreasury;
    }

    function addInvestor(address _newInvestor) internal {
        numInvestors++;
        isInvestor[_newInvestor] = true;
    }

    function removeInvestor(address _investor) internal {
        numInvestors--;
        delete isInvestor[_investor];
        delete balances[_investor];
    }
/*
    function takeFees(uint256 nTokenAmount)
        external
        validAmount(nTokenAmount)
        onlyTreasury
    {
        // mint the given number of LP Tokens to the vault creator
        INToken(nToken).mint(creator, nTokenAmount);

        // calculate nToken amount for platform fee
        uint256 nTokenSupply = INToken(nToken).scaledTotalSupply();
        uint256 creatorAmount = INToken(nToken).getUserBalance(creator);

        uint256 platformFee = (IRegistry(registry).platformFeeRate())
            .mul(nTokenSupply.sub(creatorAmount))
            .div(MAX_BPS);

        require(platformFee > 0, Errors.ZERO_PLATFORM_FEE);
        INToken(nToken).mint(treasury, platformFee);

        // withdraw nToken amount into treasury wallet as BNB
        for (uint256 i = 0; i < tokenOuts.length; i++) {
            uint256 tokenAmountToSwap = IERC20(tokenOuts[i].tokenAddress).balanceOf(address(this))
                .mul(platformFee)
                .div(nTokenSupply);

            swapTokensForBNB(tokenOuts[i].tokenAddress, tokenAmountToSwap);
        }

        (bool sent, ) = treasury.call{value: address(this).balance}("");
        require(sent, Errors.VL_WITHDRAW_FAILED);

        // burn LP Token
        INToken(nToken).burn(treasury, platformFee);

        emit TakeFee(treasury, address(this), creator, nTokenAmount, platformFee);
    }
    */


    function _takeFees()
        internal
    {
        uint256 _numDays = _numdays();
        uint256 _managementFee = maintenanceFeeRate * _numDays;
        uint256 _performanceFee = performanceFeeRate * _numDays;
        uint256 _creatorFee;

        uint256 _shareTokenPrice = ISwap(navePortfolioSwap).getShareTokenPrice(BUSD);

        // calculate nToken amount for platform fee
        uint256 nTokenSupply = INToken(nToken).scaledTotalSupply();
        uint256 creatorAmount = INToken(nToken).getUserBalance(creator);


        uint256 managementFee;
        uint256 performanceFee;
        //Take fees for Vault manager
        if (_managementFee > 0){
          managementFee = _managementFee
              .mul(_numDays)
              .mul(nTokenSupply)
              .div(MAX_BPS);
        }

        if (_performanceFee > 0 && _shareTokenPrice > watermark){
          performanceFee = _performanceFee
              .mul(_numDays)
              .mul(nTokenSupply)
              .div(MAX_BPS);
        }

        _creatorFee = managementFee.add(performanceFee);

        INToken(nToken).mint(creator, _creatorFee);

        //Take Platform Fee
        uint256 platformFee = (IRegistry(registry).platformFeeRate())
            .mul(_numDays)
            .mul(nTokenSupply.sub(creatorAmount))
            .div(MAX_BPS);

        require(platformFee > 0, Errors.ZERO_PLATFORM_FEE);
        INToken(nToken).mint(treasury, platformFee);

        // withdraw nToken amount into treasury wallet as BNB
        for (uint256 i = 0; i < tokenOuts.length; i++) {
            uint256 tokenAmountToSwap = IERC20(tokenOuts[i].tokenAddress).balanceOf(address(this))
                .mul(platformFee)
                .div(nTokenSupply);

            swapTokensForBNB(tokenOuts[i].tokenAddress, tokenAmountToSwap);
        }

        (bool sent, ) = treasury.call{value: address(this).balance}("");
        require(sent, Errors.VL_WITHDRAW_FAILED);

        // burn LP Token
        INToken(nToken).burn(treasury, platformFee);

        emit TakeFee(treasury, address(this), creator, _creatorFee, platformFee);
    }

    function editTokens(
        address[] calldata _tokenAddresses,
        uint256[] calldata _percents
    ) external onlyCreator {
        require(_tokenAddresses.length > 0, Errors.VL_INVALID_TOKENOUTS);
        require(_tokenAddresses.length < IRegistry(registry).maxNumTokens(), Errors.EXCEED_MAX_NUMBER);

        for (uint256 i = 0; i < tokenOuts.length; i++) {
            uint256 tokenAmountToSwap = IERC20(tokenOuts[i].tokenAddress).balanceOf(address(this));

            swapTokensForBNB(tokenOuts[i].tokenAddress, tokenAmountToSwap);
        }
        // initialize tokenOuts array
        delete tokenOuts;

        // set new token distribution
        for (uint256 i = 0; i < _tokenAddresses.length; i++) {
            tokenOuts.push(
                DataTypes.TokenOut(_tokenAddresses[i], _percents[i])
            );
            swapBNBForTokens(
                tokenOuts[i].tokenAddress,
                address(this).balance * tokenOuts[i].percent / 100
            );
        }

        emit EditTokens(address(this), creator, _tokenAddresses, _percents);
    }

    function swapBNBForTokens(
        address tokenOut,
        uint256 bnbAmountToSwap
    ) internal {
        if (tokenOut == ISwap(navePortfolioSwap).wBNB()) {
            IWBNB(ISwap(navePortfolioSwap).wBNB()).deposit{
                value: bnbAmountToSwap
            }();
        } else {
            ISwap(navePortfolioSwap).swapBNBForTokens{
                value: bnbAmountToSwap
            }(
                tokenOut,
                0,
                address(this)
            );
        }
    }

    function swapTokensForBNB(
        address tokenIn,
        uint256 amountToSwap
    ) internal {
        if (tokenIn == ISwap(navePortfolioSwap).wBNB()) {
            IWBNB(ISwap(navePortfolioSwap).wBNB()).withdraw(amountToSwap);
        } else {
            IERC20(tokenIn).approve(address(navePortfolioSwap), amountToSwap);
            ISwap(navePortfolioSwap).swapTokensForBNB(
                tokenIn,
                amountToSwap,
                0,
                address(this)
            );
        }
    }

    function swapTokensForBNBToReceiver(
        address receiver,
        address tokenIn,
        uint256 amountToSwap
    ) internal {
        if (tokenIn == ISwap(navePortfolioSwap).wBNB()) {
            IWBNB(ISwap(navePortfolioSwap).wBNB()).withdraw(amountToSwap);
        } else {
            IERC20(tokenIn).approve(address(navePortfolioSwap), amountToSwap);
            ISwap(navePortfolioSwap).swapTokensForBNB(
                tokenIn,
                amountToSwap,
                0,
                receiver
            );
        }
    }

    function takeEntryFee(
        address investor,
        uint256 depositAmount
    ) internal returns(uint256) {
        uint256 entryFee = 0;
        if (investor == creator) return 0;
        entryFee = depositAmount.mul(entryFeeRate).div(MAX_BPS);
        (bool sent, ) = creator.call{value: entryFee}("");
        require(sent, "Failed to send entry fee into the creator wallet");
        return entryFee;
    }


    function _numdays() internal view returns (uint256) {
            return (block.timestamp - lastFeeDate) / 60 / 60 / 24;
    }

    function getBalance(address _user) public override returns (uint256) {
        uint256 balance = INToken(nToken).getUserBalance(_user);
        return balance;
    }

    function getTotalSupply() public override returns (uint256) {
        uint256 totalSupply = INToken(nToken).scaledTotalSupply();
        return totalSupply;
    }

    function getTokenOuts() external view override returns (DataTypes.TokenOut[] memory){
        return tokenOuts;
    }

    receive() external payable {}

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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
    function allowance(address owner, address spender) external view returns (uint256);

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
// OpenZeppelin Contracts v4.4.0 (utils/math/SafeMath.sol)

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
library SafeMath {
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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.0;

interface ISwap {
    function wBNB() external pure returns(address);

    function swapBNBForTokens(
        address _tokenOut,
        uint256 _amountOutMin,
        address _to
    ) external payable;

    function swapTokensForBNB(
        address _tokenIn,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address _to
    ) external;

    function getAmountOutMin(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn
    )  external view returns (uint256);

    function swapTokensForTokens(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address _to
    ) external;

    function getTokenPrice(
        uint256 _amount,
        address _tokenIn,
        address _tokenOut
    ) external returns (uint256);

    function getShareTokenPrice(
        address _tokenOut
    ) external returns (uint256);

    function getVaultTVL(
        address _tokenOut
    ) external returns (uint256);

}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.0;

import "../libraries/DataTypes.sol";

interface IVault {
    event Initialized(
        address indexed vaultAddress,
        address indexed creator,
        string vaultName,
        string nTokenName,
        string nTokenSymbol,
        address[] tokenAddresses,
        uint256[] percents,
        uint256 entryFeeRate,
        uint256 maintenanceFeeRate,
        uint256 performanceFeeRate
    );

    event EditTokens(
        address indexed vaultAddress,
        address indexed creator,
        address[] newTokenAddresses,
        uint256[] newPercents
    );

    event TakeFee(
        address indexed treasury,
        address indexed vaultAddress,
        address indexed creator,
        uint256 creatorFee,
        uint256 platformFee
    );

    event Deposit(
        address indexed vaultAddress,
        address indexed creator,
        address indexed investor,
        uint256 amountInBNB,
        uint256 amountInBUSD,
        uint256 entryFee
    );

    event Withdraw(address indexed to, uint256 amount);

    function deposit() external payable;
    function withdraw(uint256 _amount) external;

    function getBalance(
        address _user
    ) external returns (uint256);

    function getTotalSupply(
    ) external returns (uint256);

    function getTokenOuts(
    ) external returns (DataTypes.TokenOut[] memory);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.0;

import "./ISwap.sol";
import "../libraries/DataTypes.sol";

interface IRegistry {
    function registerVault(
        DataTypes.VaultData calldata _vaultData,
        uint256 _entryFeeRate,
        uint256 _maintenanceFeeRate,
        uint256 _performanceFeeRate,
        ISwap _swap
    ) external;

    function isRegistered(
        string memory _vaultName
    ) external view returns(bool);

    function vaultAddress(
        string memory _vaultName
    ) external view returns(address);

    function vaultCreator(
        address _vault
    ) external view returns(address);

    function platformFeeRate() external view returns(uint256);

    function maxNumTokens() external view returns(uint256);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.0;

interface IWBNB {
    function deposit() external payable;

    function withdraw(uint wad) external;

    function totalSupply() external view returns(uint);

    function approve(address guy, uint wad) external returns(bool);

    function transfer(address dst, uint wad) external returns(bool);

    function balanceOf(address account) external view returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.0;

library Errors {
    string public constant VL_INVALID_AMOUNT = "1"; // Amount must be greater than 0
    string public constant VL_INVALID_TOKENOUTS = "2"; // Token to be distributed does not exist
    string public constant CT_CALLER_MUST_BE_VAULT = "3"; // The caller of this function must be a lending pool
    string public constant VL_NOT_CREATOR = "4"; // Not vault creator
    string public constant VL_NOT_INVESTOR = "5"; // Not vault investor
    string public constant VL_WITHDRAW_FAILED = "6"; // Failed to withdraw
    string public constant VL_NOT_ENOUGH_AMOUNT = "7"; // Not enough amount
    string public constant EXCEED_MAX_NUMBER = "8"; // Exceed max number of tokens
    string public constant VAULT_NAME_DUP = "9"; // Duplicated vault name
    string public constant TOKEN_NAME_DUP = "10"; // Duplicated token name      
    string public constant NOT_ADMIN = "11"; // Not admin
    string public constant ZERO_PLATFORM_FEE = "12"; // No investors, no platform fee
    string public constant NOT_ZERO_ADDRESS = "13"; // No zero address
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.0;

// import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/IVault.sol";
import "./interfaces/INToken.sol";
import "./libraries/Errors.sol";

contract NToken is ERC20, INToken {

    IVault internal vault;

    modifier onlyVault {
        require(msg.sender == address(vault), Errors.CT_CALLER_MUST_BE_VAULT);
        _;
    }

    constructor(
        IVault _vault,
        string memory _nTokenName,
        string memory _nTokenSymbol
    ) ERC20(_nTokenName, _nTokenSymbol) {
        vault = _vault;
    }

    function mint(
        address user,
        uint256 amount
    ) external override onlyVault {
        require(amount != 0, Errors.VL_INVALID_AMOUNT);
        _mint(user, amount);
        emit Mint(user, amount);
    }

    function burn(
        address user,
        uint256 amount
    ) external override onlyVault {
        require(amount != 0, Errors.VL_INVALID_AMOUNT);
        _burn(user, amount);
        emit Burn(user, amount);
    }

    function scaledTotalSupply() external view override returns (uint256) {
        return super.totalSupply();
    }

    function getUserBalance(address user) external view override returns (uint256) {
        return super.balanceOf(user);
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.0;

library DataTypes {
    struct VaultData {
        string vaultName;
        string nTokenName;
        string nTokenSymbol;
        address[] tokenAddresses;
        uint256[] percents;
    }

    struct TokenOut {
        address tokenAddress;
        uint256 percent;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

pragma solidity ^0.8.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IPancakeRouter02.sol";
import "./interfaces/ISwap.sol";
import "./interfaces/IVault.sol";
import "./libraries/DataTypes.sol";
//import "./Vault.sol";

contract Swap is ISwap {
    // contract address of PancakeRouter on testnet
    // address private constant PANCAKE_V2_ROUTER = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    // contract address of PancakeRouter on mainnet
    address private constant PANCAKE_V2_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    IVault internal vault;

    function wBNB() public pure override returns(address) {
        return IPancakeRouter02(PANCAKE_V2_ROUTER).WETH();
    }

    function swapBNBForTokens(
        address _tokenOut,
        uint256 _amountOutMin,
        address _to
    ) external override payable {
        address[] memory path = new address[](2);

        path[0] = wBNB();
        path[1] = _tokenOut;

        IPancakeRouter02(PANCAKE_V2_ROUTER).swapExactETHForTokens{value: msg.value}(
            _amountOutMin,
            path,
            _to,
            block.timestamp
        );
    }

    function swapTokensForBNB(
        address _tokenIn,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address _to
    ) external override {
        IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
        IERC20(_tokenIn).approve(PANCAKE_V2_ROUTER, _amountIn);

        address[] memory path = new address[](2);

        path[0] = _tokenIn;
        path[1] = wBNB();

        IPancakeRouter02(PANCAKE_V2_ROUTER).swapExactTokensForETH(
            _amountIn,
            _amountOutMin,
            path,
            _to,
            block.timestamp
        );
    }

    function swapTokensForTokens(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address _to
    ) external override {
        address WETH = wBNB();

        IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
        IERC20(_tokenIn).approve(PANCAKE_V2_ROUTER, _amountIn);

        address[] memory path;
        if (_tokenIn == WETH || _tokenOut == WETH) {
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        } else {
            path = new address[](3);
            path[0] = _tokenIn;
            path[1] = WETH;
            path[2] = _tokenOut;
        }

        IPancakeRouter02(PANCAKE_V2_ROUTER).swapExactTokensForTokens(
            _amountIn,
            _amountOutMin,
            path,
            _to,
            block.timestamp
        );
    }

    function getAmountOutMin(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn
    ) external view override returns (uint256) {
        address[] memory path;
        if (_tokenIn == wBNB() || _tokenOut == wBNB()) {
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        } else {
            path = new address[](3);
            path[0] = _tokenIn;
            path[1] = wBNB();
            path[2] = _tokenOut;
        }

        // same length as path
        uint256[] memory amountOutMins = IPancakeRouter02(PANCAKE_V2_ROUTER).getAmountsOut(
            _amountIn,
            path
        );

        return amountOutMins[path.length - 1];
    }


    function getTokenPrice(uint256 _amount, address _tokenIn, address _tokenOut) public view override returns(uint256) {
        address[] memory path = new address[](2);
        path[0] = _tokenIn;
        path[1] = _tokenOut;
        uint[] memory price = IPancakeRouter02(PANCAKE_V2_ROUTER).getAmountsOut(_amount, path);
        return price[0];
    }


    function getShareTokenPrice(address _tokenOut) external override returns(uint256) {
        DataTypes.TokenOut[] memory tokenOuts = IVault(msg.sender).getTokenOuts();
        uint256 numTokens = IVault(msg.sender).getTotalSupply();
        uint256 tvl;
        for (uint256 i=0; i < tokenOuts.length; i++){
            uint256 tvlAux = getTokenPrice(tokenOuts[i].percent, tokenOuts[i].tokenAddress, _tokenOut);
            tvl = tvl + tvlAux;
        }
        return tvl/numTokens;
    }


    function getVaultTVL(address _tokenOut) external override returns(uint256) {
        DataTypes.TokenOut[] memory tokenOuts = IVault(msg.sender).getTokenOuts();
        uint256 tvl;
        for (uint256 i=0; i < tokenOuts.length; i++){
            uint256 tvlAux = getTokenPrice(tokenOuts[i].percent, tokenOuts[i].tokenAddress, _tokenOut);
            tvl = tvl + tvlAux;
        }
        return tvl;
    }




}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.0;

interface IPancakeRouter02 {
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

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.0;

import "./interfaces/ISwap.sol";
import "./Vault.sol";
import "./libraries/DataTypes.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Registry {

    using SafeMath for uint256;
    // administrator of Registry contract
    address private admin;
    // total number of vaults
    uint256 public numVaults;

    uint256 public constant MIN_BPS  = 1000;
    uint256 public platformFeeRate = _yearToDayFee(5);//.mul(MIN_BPS).div(365);
    uint256 public maxNumTokens = 10;


    uint256 public maxEntryFee = 30;
    uint256 public maxMaintenanceFee = 30;
    uint256 public maxPerformanceFee = 50;



    mapping(bytes32 => address) private vaults;
    mapping(uint256 => address) public vaultList;
    mapping(bytes32 => address) private tokens;
    mapping(address => address) private vaultCreators;

    modifier onlyAdmin {
        require(msg.sender == admin, Errors.NOT_ADMIN);
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function registerVault(
        DataTypes.VaultData calldata _vaultData,
        uint256 _entryFeeRate,
        uint256 _maintenanceFeeRate,
        uint256 _performanceFeeRate,
        ISwap _swap
    ) external {
        bytes32 identifier = keccak256(abi.encodePacked(_vaultData.vaultName));
        // Check vault name existence
        require(vaults[identifier] == address(0), Errors.VAULT_NAME_DUP);
        require(tokens[identifier] == address(0), Errors.TOKEN_NAME_DUP);

        require(_vaultData.tokenAddresses.length > 0, Errors.VL_INVALID_TOKENOUTS);
        require(_vaultData.tokenAddresses.length <= maxNumTokens, Errors.EXCEED_MAX_NUMBER);

        Vault vault = new Vault(
            msg.sender,
            admin,
            _vaultData,
            _entryFeeRate,
            _maintenanceFeeRate,
            _performanceFeeRate,
            _swap
        );
        vaults[identifier] = address(vault);
        vaultCreators[address(vault)] = msg.sender;
        numVaults++;
        vaultList[numVaults] = address(vault);
    }

    function isRegistered(
        string memory _vaultName
    ) external view returns(bool) {
        bytes32 identifier = keccak256(
            abi.encodePacked(
                _vaultName
            )
        );

        if(vaults[identifier] == address(0)) return false;
        else return true;
    }

    function vaultAddress(
        string memory _vaultName
    ) external view returns(address) {
        bytes32 identifier = keccak256(
            abi.encodePacked(
                _vaultName
            )
        );
        return vaults[identifier];
    }

    function vaultCreator(
        address _vault
    ) external view returns(address) {
        return vaultCreators[_vault];
    }

    function setPlatformFeeRate(uint256 _newPlatformFeeRate) public {
        platformFeeRate = _yearToDayFee(_newPlatformFeeRate);//.mul(MIN_BPS).div(365);
    }

    function setMaxNumTokens(uint256 _newMaxNumTokens) public {
        maxNumTokens = _newMaxNumTokens;
    }

    //Fees
    function setMaxEntryFee(uint256 _newMaxEntryFee) public onlyAdmin {
        require(_newMaxEntryFee <= 30);
        maxEntryFee = _yearToDayFee(_newMaxEntryFee);//.mul(MIN_BPS).div(365);
    }

    function setMaxMaintenanceFee(uint256 _newMaxMaintenanceFee) public onlyAdmin {
        require(_newMaxMaintenanceFee <= 30);
        maxMaintenanceFee = _yearToDayFee(_newMaxMaintenanceFee);//.mul(MIN_BPS).div(365);
    }

    function setMaxPerformanceFee(uint256 _newMaxPerformanceFee) public onlyAdmin {
        require(_newMaxPerformanceFee <= 50);
        maxPerformanceFee = _yearToDayFee(_newMaxPerformanceFee);//.mul(MIN_BPS).div(365);
    }

    function _yearToDayFee(uint256 num) pure internal returns (uint256){
      return (num.mul(MIN_BPS).div(365));
    }
}