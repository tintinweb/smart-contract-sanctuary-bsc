// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./interfaces/IBEP20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IUniswapV2Router.sol";
import "./Fetchers.sol";

contract SocialFlexInvestment is Fetchers, Ownable {
    constructor(address _flexvis) {
        flexvis = IBEP20(_flexvis);
    }

    /**
     * @notice Allows contract to initialize all addresses. 
     Only the contract deployer can invoke this function.
     * @param _treasury to store the insured amount and the unclaimed reward after 14 days
     * @param _flexvis addess of Flexvis token
     * @param _busd addess of BUSD
     * @param _wbnb addess of WBNB
     * @param _router address of pancakeswap router.
     */
    function initializeContract(
        address _treasury,
        address _flexvis,
        address _busd,
        address _wbnb,
        address _router
    ) external onlyOwner {
        TREASURY = _treasury;
        FLEXVIS = _flexvis;
        BUSD = _busd;
        WBNB = _wbnb;
        ROUTER = _router;
    }

    /**
     * @notice A function for users to create a regular investment. 
     The investment reward is greatly affected by Flexvis market price. The return is constant.
     * @param amount flexvis amount for creating an investment 
     * @param duration The number of days the investment will be locked up. The longer the day, the higher the reward 
     */
    function createInvestment(uint256 amount, uint256 duration)
        external
        nonReentrant
        returns (bytes16 investmentID)
    {
        if (isContract(msg.sender)) {
            revert ContractAddressRevoked();
        }

        if (amount < MIN_AMOUNT) {
            revert InsufficientInvestmentAmount();
        }

        if (!isValidDuration(duration)) {
            revert InvalidDuration();
        }

        if (flexvis.balanceOf(msg.sender) < amount) {
            revert InsufficientFlexvisBalance();
        }

        flexvis.transferFrom(msg.sender, address(this), amount);

        Investment memory newInvestment;
        newInvestment.investor = msg.sender;
        newInvestment.investedAmount = amount;
        newInvestment.startDay = block.timestamp;
        newInvestment.investingDays = duration;
        newInvestment.hasInsurance = false;
        newInvestment.isActive = true;

        investmentID = _generateInvestmentID(msg.sender);
        newInvestment.investmentID = investmentID;

        uint256 reward = getInvestmentReward(duration, amount);
        newInvestment.reward = reward;

        int256 index = checkIfIncluded(msg.sender, allInvestors);
        if (index < 0) {
            allInvestors.push(msg.sender);
        }

        allInvestment[msg.sender].push(newInvestment);
        investments[msg.sender][investmentID] = newInvestment;
        investmentCount[msg.sender] += 1;

        totalInvested += amount;
        totalRegularInvested += amount;

        emit InvestmentCreated(
            investmentID,
            msg.sender,
            newInvestment.investedAmount,
            newInvestment.startDay,
            newInvestment.investingDays,
            0,
            0
        );
    }

    /**
     * @notice A function for users to create an insured investment. 
     The investment reward is greatly affected by Flexvis market price. 
     Unlike the regular investment, the return will be higher if the price of Flexvis goes down.
     * @param amount flexvis amount for creating an investment 
     * @param duration The number of days the investment will be locked up. The longer the day, the higher the reward 
     * @param insuredAmount the amount required to create an insured investment.
     * @return investmentID a unique ID for an investment
     */

    function createInsuredInvestment(
        uint256 amount,
        uint256 duration,
        uint256 insuredAmount
    ) external nonReentrant returns (bytes16 investmentID) {
        if (isContract(msg.sender)) {
            revert ContractAddressRevoked();
        }

        if (insuredAmount < (10 * amount) / 100) {
            revert InsufficientInsuredAmount();
        }

        if (amount < MIN_AMOUNT) {
            revert InsufficientInvestmentAmount();
        }

        if (!isValidDurationForInsured(duration)) {
            revert InvalidDuration();
        }

        uint256 totalAmount = amount + insuredAmount;

        if (flexvis.balanceOf(msg.sender) < totalAmount) {
            revert InsufficientFlexvisBalance();
        }

        flexvis.transferFrom(msg.sender, address(this), totalAmount);

        flexvis.transfer(TREASURY, insuredAmount);

        Investment memory newInvestment;
        newInvestment.investor = msg.sender;
        newInvestment.investedAmount = amount;
        newInvestment.startDay = block.timestamp;
        newInvestment.investingDays = duration;
        newInvestment.hasInsurance = true;
        newInvestment.isActive = true;

        investmentID = _generateInvestmentID(msg.sender);
        newInvestment.investmentID = investmentID;

        uint256 rewardInFlexvis = getInvestmentReward(duration, amount);
        newInvestment.reward = rewardInFlexvis;
        newInvestment.stablePrincipal = flexvisToBusd(amount);
        newInvestment.stableReward = flexvisToBusd(rewardInFlexvis);

        int256 index = checkIfIncluded(msg.sender, allInvestors);
        if (index < 0) {
            allInvestors.push(msg.sender);
        }

        allInvestment[msg.sender].push(newInvestment);
        investments[msg.sender][investmentID] = newInvestment;
        investmentCount[msg.sender] += 1;

        totalInvested += amount;
        totalInsuredInvested += amount;

        emit InsuredInvestmentCreated(
            investmentID,
            msg.sender,
            newInvestment.investedAmount,
            newInvestment.startDay,
            newInvestment.investingDays,
            newInvestment.stablePrincipal,
            newInvestment.stableReward
        );
    }

    /**
     * @notice A function to end an investment. You will be penalized for ending an investment when it is not yet matured (i.e when the duration you specify has not elapsed) and when it is overmatured (i.e when the duration you specify + 14 days grace period, has elapsed)
     * @param investmentID the investment ID of the investment you want to end.
     * @return totalReturn the total return in flexvis that will be transferred to the user.
     */

    function endInvestment(bytes16 investmentID)
        external
        nonReentrant
        returns (uint256 totalReturn)
    {
        if (isContract(msg.sender)) {
            revert ContractAddressRevoked();
        }

        Investment memory investment = investments[msg.sender][investmentID];

        if (investment.investedAmount < MIN_AMOUNT) {
            revert NoInvestmentFound();
        }

        if (!investment.isActive) {
            revert InvestmentNotActive();
        }

        uint256 principal;
        uint256 reward;

        uint256 lastInvestmentDay = investment.startDay +
            investment.investingDays;


        if (investment.hasInsurance && block.timestamp >= lastInvestmentDay) {
            uint256 investedAmountInBusd = flexvisToBusd(
                investment.investedAmount
            );

            // checking if the invested amount in busd as at now is greater than 
            // or equal to the invested amount in busd at the time the investment was created.
            if (investedAmountInBusd >= investment.stablePrincipal) {
                principal = investment.investedAmount;
                reward = investment.reward;
            } else {
                IUniswapV2Router router = IUniswapV2Router(ROUTER);

                address[] memory path = new address[](3);

                path[0] = address(flexvis);
                path[1] = WBNB;
                path[2] = BUSD;

                principal = router.getAmountsIn(
                    investment.stablePrincipal,
                    path
                )[0];
                reward = router.getAmountsIn(investment.stableReward, path)[0];
            }
        } else {
            principal = investment.investedAmount;
            reward = investment.reward;
        }

        if (block.timestamp >= lastInvestmentDay) {
            if (block.timestamp > lastInvestmentDay + 14 days) {
                totalReturn = principal;

                flexvis.transfer(msg.sender, totalReturn);
                flexvis.transfer(TREASURY, reward);
            } else {
                totalReturn = principal + reward;

                flexvis.transfer(msg.sender, totalReturn);
            }
        } else {
            totalReturn = percentOf(50, principal) + percentOf(1, reward);
            flexvis.transfer(msg.sender, totalReturn);
            uint256 toBurn = percentOf(50, principal) + percentOf(99, reward);
            flexvis.burn(address(this), toBurn);
        }

        investments[msg.sender][investmentID].isActive = false;
        totalInvested -= investment.investedAmount;

        if (investment.hasInsurance) {
            totalInsuredInvested -= investment.investedAmount;
        } else {
            totalRegularInvested -= investment.investedAmount;
        }

        modifyInvestmentArray(msg.sender, investmentID);

        emit End(investmentID, msg.sender, totalReturn);
    }

    function modifyInvestmentArray(address _investor, bytes16 investmentID)
        internal
    {
        uint256 index = uint256(
            getInvestmentIndex(investmentID, allInvestment[_investor])
        );
        Investment memory currentInvestment = allInvestment[_investor][index];

        Investment memory newInvestment = Investment(
            currentInvestment.investor,
            currentInvestment.investmentID,
            currentInvestment.investedAmount,
            currentInvestment.startDay,
            currentInvestment.investingDays,
            currentInvestment.reward,
            currentInvestment.hasInsurance,
            currentInvestment.stablePrincipal,
            currentInvestment.stableReward,
            false
        );

        Investment[] storage allUserInvestments = allInvestment[_investor];
        allUserInvestments[index] = newInvestment;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IBEP20 {
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

    /**
     * @dev Burns the {amount} amount of tokens from account .
     */
    function burn(address account, uint256 amount) external returns(bool);


    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2;

interface IUniswapV2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
 
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

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Tradeable.sol";


abstract contract Fetchers is Tradeable {
     function hasInvestment(address _user) external view returns (bool) {
        return investmentCount[_user] > 0;
    }

    function getAllInvestments(address investor)
        external
        view
        returns (Investment[] memory)
    {
        return allInvestment[investor];
    }

    function getAllInvestors() external view returns(address[] memory){
        return allInvestors;
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Helper.sol";
import "./Conversion.sol";
import "./interfaces/IUniswapV2Router.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/IBEP20.sol";
import "./interfaces/IWBNB.sol";
import "./Events.sol";

abstract contract Tradeable is Conversion, ReentrancyGuard, Events {
    /**
     * @notice A function to buy Flexvis with BUSD
     * @param busdAmount busd amount for buying flexvis
     * @param path the route to take to convert busd to flexvis
     * @param deadline transaction will fail if it takes a very long time (longer the deadline) to execute
     * @param minPercentage to determine the min amount of Flexvis to receive to control the impact of price flunctuation.
     */
    function buyFlexvisWithBUSD(
        uint256 busdAmount,
        address[] memory path,
        uint256 deadline,
        uint16 minPercentage
    ) external nonReentrant {
        IBEP20 busd = IBEP20(BUSD);

        if (isContract(msg.sender)) {
            revert ContractAddressRevoked();
        }
     
        if (path[path.length -1] != FLEXVIS){
            revert InvalidPath();
        }

        IUniswapV2Router router = IUniswapV2Router(ROUTER);

        uint256[] memory amountsOut = router.getAmountsOut(busdAmount, path);

        uint256 amountOutMin = (amountsOut[amountsOut.length - 1] *
            minPercentage) / 10000;

        busd.transferFrom(msg.sender, address(this), busdAmount);

        busd.approve(address(router), busdAmount);

        uint256[] memory amounts = router.swapExactTokensForTokens(
            busdAmount,
            amountOutMin,
            path,
            msg.sender,
            deadline
        );

        emit Buy(msg.sender, busdAmount, amounts[amounts.length - 1]);
    }

    function buyFlexvisWithBNB(
        address[] memory path,
        uint256 deadline,
        uint16 minPercentage
    ) external payable nonReentrant {
        if (isContract(msg.sender)) {
            revert ContractAddressRevoked();
        }

        if (path[path.length -1] != FLEXVIS){
            revert InvalidPath();
        }

        IUniswapV2Router router = IUniswapV2Router(ROUTER);

        uint256[] memory amountsOut = router.getAmountsOut(msg.value, path);

        uint256 amountOutMin = (amountsOut[amountsOut.length - 1] *
            minPercentage) / 10000;

        uint256[] memory amounts = router.swapExactETHForTokens{
            value: msg.value
        }(amountOutMin, path, msg.sender, deadline);

        emit Buy(msg.sender, msg.value, amounts[amounts.length - 1]);
    }

    function sellFlexvisForToken(
        uint256 flexvisAmount,
        address[] memory path,
        uint256 deadline,
        uint16 minPercentage
    ) external nonReentrant {
        if (isContract(msg.sender)) {
            revert ContractAddressRevoked();
        }

         if (path[0] != FLEXVIS){
            revert InvalidPath();
        }

        IUniswapV2Router router = IUniswapV2Router(ROUTER);

        uint256[] memory amountsOut = router.getAmountsOut(flexvisAmount, path);

        uint256 amountOutMin = (amountsOut[amountsOut.length - 1] *
            minPercentage) / 10000;

        flexvis.transferFrom(msg.sender, address(this), flexvisAmount);

        flexvis.approve(address(router), flexvisAmount);

        if (path[path.length - 1] == WBNB) {
            uint256[] memory amounts = router.swapExactTokensForETH(
                flexvisAmount,
                amountOutMin,
                path,
                msg.sender,
                deadline
            );

            emit Sell(msg.sender, flexvisAmount, amounts[amounts.length - 1]);
        } else {
            uint256[] memory amounts = router.swapExactTokensForTokens(
                flexvisAmount,
                amountOutMin,
                path,
                msg.sender,
                deadline
            );

            emit Sell(msg.sender, flexvisAmount, amounts[amounts.length - 1]);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Declaration.sol";
import "./Events.sol";

abstract contract Helper is Declaration {
    function _toBytes16(uint256 x) internal pure returns (bytes16 b) {
        return bytes16(bytes32(x));
    }

    function generateID(
        address x,
        uint256 y,
        bytes1 z
    ) public pure returns (bytes16 b) {
        b = _toBytes16(uint256(keccak256(abi.encodePacked(x, y, z))));
    }

    function _generateInvestmentID(address _investor)
        internal
        view
        returns (bytes16 investmentID)
    {
        return generateID(_investor, investmentCount[_investor], 0x01);
    }

    function percentOf(uint256 percentage, uint256 amount)
        internal
        pure
        returns (uint256)
    {
        return (percentage * amount) / 100;
    }

    function getInvestmentIndex(
        bytes16 investmentID,
        Investment[] memory investments
    ) internal pure returns (int256) {
        for (uint256 i = 0; i < investments.length; i++) {
            Investment memory currentInvestment = investments[i];
            bytes16 currentInvestmentID = currentInvestment.investmentID;
            if (currentInvestmentID == investmentID) {
                return int256(i);
            }
        }
        return -1;
    }

    function checkIfIncluded(address investor, address[] memory allInvestors)
        internal
        pure
        returns (int256)
    {
        for (uint256 i = 0; i < allInvestors.length; i++) {
            address currentInvestor = allInvestors[i];
            if (currentInvestor == investor) {
                return int256(i);
            }
        }
        return -1;
    }

    function getInvestmentReward(
        uint256 _investingDays,
        uint256 _investedAmount
    ) internal pure returns (uint256 reward) {
        if (_investingDays == 7 days) {
            reward = 0;
        } else if (_investingDays == 30 days) {
            reward = (4 * _investedAmount) / 100;
        } else if (_investingDays == 180 days) {
            reward = (30 * _investedAmount) / 100;
        } else if (_investingDays == 365 days) {
            reward = (70 * _investedAmount) / 100;
        } else if (_investingDays == 1095 days) {
            reward = (200 * _investedAmount) / 100;
        } else if (_investingDays == 1825 days) {
            reward = (400 * _investedAmount) / 100;
        } else {
            reward = 0;
        }
    }

    function getInsuredInvestmentReward(
        uint256 _investingDays,
        uint256 _investedAmount
    ) internal pure returns (uint256 reward) {
        if (_investingDays == 365 days) {
            reward = (70 * _investedAmount) / 100;
        } else if (_investingDays == 1095 days) {
            reward = (200 * _investedAmount) / 100;
        } else if (_investingDays == 1825 days) {
            reward = (400 * _investedAmount) / 100;
        } else {
            reward = 0;
        }
    }

    function isValidDuration(uint256 _investingDays)
        internal
        pure
        returns (bool isValid)
    {
        if (
            _investingDays == 7 days ||
            _investingDays == 30 days ||
            _investingDays == 180 days ||
            _investingDays == 365 days ||
            _investingDays == 1095 days ||
            _investingDays == 1825 days
        ) {
            isValid = true;
        } else {
            isValid = false;
        }
    }
        function isValidDurationForInsured(uint256 _investingDays)
        internal
        pure
        returns (bool isValid)
    {
        if (
            _investingDays == 365 days ||
            _investingDays == 1095 days ||
            _investingDays == 1825 days
        ) {
            isValid = true;
        } else {
            isValid = false;
        }
    }

      function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Helper.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "./interfaces/IUniswapV2Router.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";


abstract contract Conversion is Helper {
    function bnbToBusd(uint256 bnbAmount) public view returns (uint256) {
        (uint112 wbnbReserve, uint112 busdReserve) = getReserves(WBNB, BUSD);
        uint256 busdEquivalent = (busdReserve * bnbAmount) /
            (wbnbReserve + bnbAmount);
        return busdEquivalent;
    }

    function flexvisToBusd(uint256 flexvisAmount)
        public
        view
        returns (uint256)
    {
        uint256 wbnbAmount = flexvisToBnb(flexvisAmount);

        uint256 busdEquivalent = bnbToBusd(wbnbAmount);

        return busdEquivalent;
    }

    function flexvisToBnb(uint256 flexvisAmount) public view returns (uint256) {
        (uint112 flexvisReserve, uint112 wbnbReserve) = getReserves(
            FLEXVIS,
            WBNB
        );
        uint256 wbnbEquivalent = (wbnbReserve * flexvisAmount) /
            (flexvisReserve + flexvisAmount);

        return wbnbEquivalent;
    }

    function getReserves(address tokenA, address tokenB)
        public
        view
        returns (uint112 reserveA, uint112 reserveB)
    {
        IUniswapV2Router router = IUniswapV2Router(ROUTER);
        IUniswapV2Factory factory = IUniswapV2Factory(router.factory());
        address pairAddress = factory.getPair(tokenA, tokenB);

        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        address token0 = pair.token0();
       
        (uint112 _reserve0, uint112 _reserve1, ) = pair.getReserves();
        (reserveA, reserveB) = token0 == tokenA
            ? (_reserve0, _reserve1)
            : (_reserve1, _reserve0);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
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

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

interface IWBNB {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);

    function deposit() external payable;

    function withdraw(uint256 wad) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


abstract contract Events{

    event InvestmentCreated(
        bytes16 indexed investmentID,
        address indexed investor,
        uint256 investedAmount,
        uint256 indexed startDay,
        uint256 investingDays,
        uint256 stablePrincipal,
        uint256 stableReward
    );

    event InsuredInvestmentCreated(
        bytes16 indexed investmentID,
        address indexed investor,
        uint256 investedAmount,
        uint256 indexed startDay,
        uint256 investingDays,
        uint256 stablePrincipal,
        uint256 stableReward
    );

    event End(
        bytes16 indexed investmentID,
        address indexed investor,
        uint256 totalReturn
    );

    event Sell(address to, uint256 amountIn, uint256 amountsOut);
    event Buy(address to, uint256 amountIn, uint256 amountsOut);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interfaces/IBEP20.sol";
import "./Errors.sol";

abstract contract Declaration is Errors {

     struct Investment {
        address investor;
        bytes16 investmentID;
        uint256 investedAmount;
        uint256 startDay;
        uint256 investingDays;
        uint256 reward;
        bool hasInsurance;
        uint256 stablePrincipal;
        uint256 stableReward;
        bool isActive;
    }

    address public TREASURY;
    address public ROUTER;
    address public FLEXVIS;
    address public BUSD;
    address public WBNB;

    IBEP20 public flexvis;

    mapping(address => uint256) public investmentCount; 
    mapping(address => mapping(bytes16 => Investment)) public investments; 
    mapping(address => Investment[]) public allInvestment;
    address[] public allInvestors;

    uint public MIN_AMOUNT = 10E18;

    uint public totalInvested;
    uint public totalInsuredInvested;
    uint public totalRegularInvested;

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

abstract contract Errors {
    error InvalidDuration();
    error InsufficientInvestmentAmount();
    error InsufficientFlexvisBalance();
    error InsufficientBusdBalance();
    error InsufficientInsuredAmount();
    error TransferFromFailed();
    error InvalidStartDate();
    error NoInvestmentFound();
    error InvestmentNotActive();
    error ContractAddressRevoked();
    error InvalidPath();
    error ValueCannotBeZero();
}

pragma solidity >=0.5.0;

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

pragma solidity >=0.5.0;

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