// SPDX-License-Identifier: MIT

pragma solidity >=0.8.7;

import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '../interfaces/IPancakeRouter.sol';
import '../interfaces/IPRC20.sol';
import '../interfaces/IVolt.sol';
import '../interfaces/IPotContract.sol';

// File: PotContract.sol

contract PowerBall is ReentrancyGuard {
    enum STATE {
        WAITING,
        STARTED,
        LIVE,
        CALCULATING_WINNER
    }

    struct Entry {
        address player;
        uint256 amount;
    }

    address public owner;
    address public admin;
    address public tokenAddress;
    uint8 public tokenDecimal;

    address internal constant wbnbAddr = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; // testnet: 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd, mainnet: 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
    address internal constant busdAddr = 0x4608Ea31fA832ce7DCF56d78b5434b49830E91B1; // testnet: 0x4608Ea31fA832ce7DCF56d78b5434b49830E91B1, mainnet: 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
    address internal constant pancakeRouterAddr = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1; // testnet: 0xD99D1c33F9fC3444f8101754aBC46c52416550D1, mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E
    IPancakeRouter02 public router;

    STATE public roundStatus;
    uint256 public entryIds;
    uint256 public roundIds;
    uint256 public roundDuration;
    uint256 public roundStartTime;
    uint256 public roundLiveTime;
    uint256 public minEntranceAmount;
    uint256 public currentEntryCount;
    Entry[] public currentEntries;

    uint256 public totalEntryAmount;
    uint256 public nonce;
    uint256 public calculateIndex;

    uint256 public marketingFee = 100;
    uint256 public burnFee = 75;
    uint256 public platformFee = 75;

    address public BNBPAddr = 0xcAf4f8C9f1e511B3FEb3226Dc3534E4c4b2f3D70; // mainnet: 0x4D9927a8Dc4432B93445dA94E4084D292438931F, testnet: 0xcAf4f8C9f1e511B3FEb3226Dc3534E4c4b2f3D70
    address public hotWalletAddr;
    address public potContractAddr;

    constructor(address _tokenAddress, address _potContractAddr) {
        owner = msg.sender;
        admin = msg.sender;
        tokenAddress = _tokenAddress;
        tokenDecimal = IVolt(tokenAddress).decimals();
        roundStatus = STATE.WAITING;
        roundDuration = 5; // 5 secs

        minEntranceAmount = 2 * 10 ** tokenDecimal; // 2 Volt

        router = IPancakeRouter02(pancakeRouterAddr);
        hotWalletAddr = 0xCf4560A9c128B844F139581A75218e757cc1bbb2;
        potContractAddr = _potContractAddr;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin || msg.sender == owner, '!admin');
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, '!owner');
        _;
    }

    modifier validBNBP() {
        require(BNBPAddr != address(0), '!BNBP Addr');
        _;
    }

    modifier excludeContract() {
        require(tx.origin == msg.sender, 'Contract');
        _;
    }

    event EnteredPot(uint256 indexed roundId, uint256 indexed entryId, address indexed player, uint256 amount);

    event CalculateWinner(uint256 indexed roundId, address indexed winner, uint256 reward);

    event TokenSwapFailedString(string tokenName, string reason);
    event TokenSwapFailedBytes(string tokenName, bytes reason);

    function changeOwner(address _owner) public onlyOwner {
        owner = _owner;
    }

    function changeAdmin(address _adminAddress) public onlyOwner {
        admin = _adminAddress;
    }

    function setBNBPAddress(address _address) public onlyAdmin {
        BNBPAddr = _address;
    }

    function enterPot(uint256 _amount) external excludeContract {
        unchecked {
            require(_amount >= minEntranceAmount, 'Min');
            require(roundLiveTime == 0 || block.timestamp <= roundLiveTime + roundDuration, 'ended');

            IVolt token = IVolt(tokenAddress);
            uint256 beforeBalance = token.balanceOf(address(this));
            token.transferFrom(msg.sender, address(this), _amount);
            uint256 rAmount = token.balanceOf(address(this)) - beforeBalance;

            uint256 count = currentEntryCount;
            if (currentEntries.length == count) {
                currentEntries.push();
            }

            Entry storage entry = currentEntries[count];
            entry.player = msg.sender;
            entry.amount = rAmount;
            ++currentEntryCount;
            ++entryIds;
            totalEntryAmount = totalEntryAmount + rAmount;

            if (
                currentEntryCount >= 2 && currentEntries[count - 1].player != msg.sender && roundStatus == STATE.STARTED
            ) {
                roundStatus = STATE.LIVE;
                roundLiveTime = block.timestamp;
            } else if (currentEntryCount == 1) {
                roundStatus = STATE.STARTED;
                roundStartTime = block.timestamp;
                ++roundIds;
            }

            emit EnteredPot(roundIds, entryIds, msg.sender, rAmount);
        }
    }

    function calculateWinner() public {
        bool isRoundEnded = roundStatus == STATE.LIVE && roundLiveTime + roundDuration < block.timestamp;
        require(isRoundEnded || roundStatus == STATE.CALCULATING_WINNER, 'Not ended');

        if (isRoundEnded) {
            nonce = fullFillRandomness() % totalEntryAmount;
            calculateIndex = 0;
        }
        address winner = determineWinner();
        if (winner != address(0)) {
            IVolt token = IVolt(tokenAddress);
            uint256 totalFeePercent = (marketingFee + burnFee + platformFee);
            uint256 totalFeeAmount = (totalEntryAmount * totalFeePercent) / 1000;
            uint256 reward = totalEntryAmount - totalFeeAmount;
            uint256 marketingAmount = (totalFeeAmount * marketingFee) / totalFeePercent;
            uint256 burnAmount = (totalFeeAmount * burnFee) / totalFeePercent;
            uint256 amount = totalFeeAmount - marketingAmount - burnAmount;

            token.transfer(winner, reward);
            token.transfer(token.marketingAddress(), marketingAmount);
            token.transfer(token.burningAddress(), burnAmount);
            emit CalculateWinner(roundIds, winner, reward);

            swapAccumulatedFees(amount);
            initializeRound();
        } else {
            roundStatus = STATE.CALCULATING_WINNER;
        }
    }

    /**   @dev Attempts to select a random winner
     */
    function determineWinner() internal returns (address winner) {
        uint256 start = calculateIndex;
        uint256 length = currentEntryCount;
        uint256 _nonce = nonce;
        for (uint256 index = 0; index < 3000 && (start + index) < length; index++) {
            uint256 amount = currentEntries[index].amount;
            if (_nonce <= amount) {
                //That means that the winner has been found here
                winner = currentEntries[index].player;
                return winner;
            }
            _nonce -= amount;
        }
        nonce = _nonce;
        calculateIndex = start + 3000;
        return address(0);
    }

    function initializeRound() internal {
        delete currentEntryCount;
        delete roundLiveTime;
        delete roundStartTime;
        delete totalEntryAmount;
        roundStatus = STATE.WAITING;
    }

    /**   @dev generates a random number
     */
    function fullFillRandomness() internal view returns (uint256) {
        return uint256(uint128(bytes16(keccak256(abi.encodePacked(block.difficulty, block.timestamp)))));
    }

    /**
     * @dev Swaps accumulated fees into BNB, or BUSD first, and then to BNBP
     */
    function swapAccumulatedFees(uint256 amount) internal validBNBP {
        address[] memory path = new address[](3);
        path[0] = tokenAddress;
        path[1] = router.WETH();
        path[2] = BNBPAddr;
        IVolt(tokenAddress).approve(address(router), amount);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amount, 0, path, address(this), block.timestamp);
        uint256 balance = IPRC20(BNBPAddr).balanceOf(address(this));
        IPRC20(BNBPAddr).approve(potContractAddr, balance);
        IPotLottery(potContractAddr).addAdminTokenValue(balance);
    }

    /**
     * @dev sets hot wallet address
     */
    function setHotWalletAddress(address addr) external onlyAdmin {
        hotWalletAddr = addr;
    }

    function setRoundDuration(uint256 value) external onlyAdmin {
        roundDuration = value;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IPRC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function decimals() external view returns (uint8);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

interface IPancakeRouter01 {
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

interface IPancakeRouter02 is IPancakeRouter01 {
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

/**
 *Submitted for verification at Etherscan.io on 2022-04-18
 */

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

// File: PotContract.sol

interface IPotLottery {
    struct Token {
        address tokenAddress;
        string tokenSymbol;
        uint256 tokenDecimal;
    }

    enum POT_STATE {
        PAUSED,
        WAITING,
        STARTED,
        LIVE,
        CALCULATING_WINNER
    }

    event EnteredPot(
        string tokenName,
        address indexed userAddress,
        uint256 indexed potRound,
        uint256 usdValue,
        uint256 amount,
        uint256 indexed enteryCount,
        bool hasEntryInCurrentPot
    );
    event CalculateWinner(
        address indexed winner,
        uint256 indexed potRound,
        uint256 potValue,
        uint256 amount,
        uint256 amountWon,
        uint256 participants
    );

    event PotStateChange(uint256 indexed potRound, POT_STATE indexed potState, uint256 indexed time);
    event TokenSwapFailed(string tokenName);

    function getRefund() external;

    function airdropPool() external view returns (uint256);

    function lotteryPool() external view returns (uint256);

    function burnPool() external view returns (uint256);

    function airdropInterval() external view returns (uint256);

    function burnInterval() external view returns (uint256);

    function lotteryInterval() external view returns (uint256);

    function fullFillRandomness() external view returns (uint256);

    function getBNBPrice() external view returns (uint256 price);

    function swapAccumulatedFees() external;

    function burnAccumulatedBNBP() external;

    function airdropAccumulatedBNBP() external returns (uint256);

    function addAdminTokenValue(uint256 value) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IVolt {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function decimals() external view returns (uint8);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function marketingAddress() external view returns (address);

    function burningAddress() external view returns (address);
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