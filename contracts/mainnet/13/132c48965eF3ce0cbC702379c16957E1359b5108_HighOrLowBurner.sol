// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IAuthorizationUtilsV0.sol";
import "./ITemplateUtilsV0.sol";
import "./IWithdrawalUtilsV0.sol";

interface IAirnodeRrpV0 is
    IAuthorizationUtilsV0,
    ITemplateUtilsV0,
    IWithdrawalUtilsV0
{
    event SetSponsorshipStatus(
        address indexed sponsor,
        address indexed requester,
        bool sponsorshipStatus
    );

    event MadeTemplateRequest(
        address indexed airnode,
        bytes32 indexed requestId,
        uint256 requesterRequestCount,
        uint256 chainId,
        address requester,
        bytes32 templateId,
        address sponsor,
        address sponsorWallet,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes parameters
    );

    event MadeFullRequest(
        address indexed airnode,
        bytes32 indexed requestId,
        uint256 requesterRequestCount,
        uint256 chainId,
        address requester,
        bytes32 endpointId,
        address sponsor,
        address sponsorWallet,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes parameters
    );

    event FulfilledRequest(
        address indexed airnode,
        bytes32 indexed requestId,
        bytes data
    );

    event FailedRequest(
        address indexed airnode,
        bytes32 indexed requestId,
        string errorMessage
    );

    function setSponsorshipStatus(address requester, bool sponsorshipStatus)
        external;

    function makeTemplateRequest(
        bytes32 templateId,
        address sponsor,
        address sponsorWallet,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes calldata parameters
    ) external returns (bytes32 requestId);

    function makeFullRequest(
        address airnode,
        bytes32 endpointId,
        address sponsor,
        address sponsorWallet,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes calldata parameters
    ) external returns (bytes32 requestId);

    function fulfill(
        bytes32 requestId,
        address airnode,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes calldata data,
        bytes calldata signature
    ) external returns (bool callSuccess, bytes memory callData);

    function fail(
        bytes32 requestId,
        address airnode,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        string calldata errorMessage
    ) external;

    function sponsorToRequesterToSponsorshipStatus(
        address sponsor,
        address requester
    ) external view returns (bool sponsorshipStatus);

    function requesterToRequestCountPlusOne(address requester)
        external
        view
        returns (uint256 requestCountPlusOne);

    function requestIsAwaitingFulfillment(bytes32 requestId)
        external
        view
        returns (bool isAwaitingFulfillment);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAuthorizationUtilsV0 {
    function checkAuthorizationStatus(
        address[] calldata authorizers,
        address airnode,
        bytes32 requestId,
        bytes32 endpointId,
        address sponsor,
        address requester
    ) external view returns (bool status);

    function checkAuthorizationStatuses(
        address[] calldata authorizers,
        address airnode,
        bytes32[] calldata requestIds,
        bytes32[] calldata endpointIds,
        address[] calldata sponsors,
        address[] calldata requesters
    ) external view returns (bool[] memory statuses);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITemplateUtilsV0 {
    event CreatedTemplate(
        bytes32 indexed templateId,
        address airnode,
        bytes32 endpointId,
        bytes parameters
    );

    function createTemplate(
        address airnode,
        bytes32 endpointId,
        bytes calldata parameters
    ) external returns (bytes32 templateId);

    function getTemplates(bytes32[] calldata templateIds)
        external
        view
        returns (
            address[] memory airnodes,
            bytes32[] memory endpointIds,
            bytes[] memory parameters
        );

    function templates(bytes32 templateId)
        external
        view
        returns (
            address airnode,
            bytes32 endpointId,
            bytes memory parameters
        );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IWithdrawalUtilsV0 {
    event RequestedWithdrawal(
        address indexed airnode,
        address indexed sponsor,
        bytes32 indexed withdrawalRequestId,
        address sponsorWallet
    );

    event FulfilledWithdrawal(
        address indexed airnode,
        address indexed sponsor,
        bytes32 indexed withdrawalRequestId,
        address sponsorWallet,
        uint256 amount
    );

    function requestWithdrawal(address airnode, address sponsorWallet) external;

    function fulfillWithdrawal(
        bytes32 withdrawalRequestId,
        address airnode,
        address sponsor
    ) external payable;

    function sponsorToWithdrawalRequestCount(address sponsor)
        external
        view
        returns (uint256 withdrawalRequestCount);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IAirnodeRrpV0.sol";

/// @title The contract to be inherited to make Airnode RRP requests
contract RrpRequesterV0 {
    IAirnodeRrpV0 public immutable airnodeRrp;

    /// @dev Reverts if the caller is not the Airnode RRP contract.
    /// Use it as a modifier for fulfill and error callback methods, but also
    /// check `requestId`.
    modifier onlyAirnodeRrp() {
        require(msg.sender == address(airnodeRrp), "Caller not Airnode RRP");
        _;
    }

    /// @dev Airnode RRP address is set at deployment and is immutable.
    /// RrpRequester is made its own sponsor by default. RrpRequester can also
    /// be sponsored by others and use these sponsorships while making
    /// requests, i.e., using this default sponsorship is optional.
    /// @param _airnodeRrp Airnode RRP contract address
    constructor(address _airnodeRrp) {
        airnodeRrp = IAirnodeRrpV0(_airnodeRrp);
        IAirnodeRrpV0(_airnodeRrp).setSponsorshipStatus(address(this), true);
    }
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
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

pragma solidity >=0.6.2;

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

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

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

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@api3/airnode-protocol/contracts/rrp/requesters/RrpRequesterV0.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract HighOrLowBurner is Ownable, RrpRequesterV0 {
    enum Direction {
        Under,
        Over
    }

    struct Fees {
        uint16 treasury;
        uint16 burn;
        uint16 swap;
    }

    struct Token {
        bool isActive;
        Fees fee;
        address router;
        address[] path;
        uint256 minBet;
        uint256 maxBet;
        uint256 swapValue;
        uint256 currentBalance;
    }

    struct Game {
        Direction direction; //0-under, 1-over
        uint8 rolledNumber;
        uint32 timestamp;
        address betToken;
        address player;
        uint256 betAmount;
        uint256 wonAmount;
    }

    mapping(address => Token) public tokenInfo;
    mapping(address => mapping(uint256 => Game)) public games;
    mapping(uint256 => Game) public idToGame;
    mapping(address => uint256) public totalPlayed;
    mapping(bytes32 => uint256) internal requestToGame;

    uint8 public rollOver = 55;
    uint8 public rollUnder = 45;
    uint256 public gameId;

    address public treasury = 0x0Ba7D8d8A8B39c49215bc6EC45C8b0718593e466;
    address[] public activeTokens;

    /** BSC Mainnet */
    address public airnode = 0x9d3C147cA16DB954873A498e0af5852AB39139f2;
    address public rrpAddress = 0xa0AD79D995DdeeB18a14eAef56A549A04e3Aa1Bd;
    bytes32 public endpointIdUint256 = 0xfb6d017bb87991b7495f563db3c8cf59ff87b09781947bb1e417006ad7f55a78;
    address public sponsorWallet;

    event DicePlayed(
        uint256 indexed gameId,
        address indexed player,
        address indexed token,
        uint256 amount,
        Direction direction,
        uint256 timestamp
    );
    event GameResult(
        uint256 indexed gameId,
        address indexed player,
        Direction direction,
        uint256 result,
        uint256 amount
    );

    constructor() RrpRequesterV0(rrpAddress) {
        address _token = 0x02678125Fb30d0fE77fc9D10Ea531f8b4348c603; //LVM
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E; //PCS ROUTER

        address[] memory _path = new address[](2);
        _path[0] = _token;
        _path[1] = IUniswapV2Router02(_router).WETH();

        tokenInfo[_token] = Token({
            isActive: true,
            fee: Fees({ treasury: 90, burn: 300, swap: 10 }),
            router: _router,
            path: _path,
            minBet: 1000 * 10**9,
            maxBet: 20000 * 10 ** 9,
            swapValue: 50000 * 10 ** 9,
            currentBalance: 0
        });

        IERC20(_token).approve(_router, type(uint256).max);
        activeTokens.push(_token);
    }

    function setToken(
        address _token,
        bool _isActive,
        uint256 _swapValue,
        address _router,
        address[] memory _path,
        uint256 _minBet,
        uint256 _maxBet,
        Fees memory _fee
    ) external onlyOwner {
        Token storage tkn = tokenInfo[_token];

        if (_isActive) {
            if (!tkn.isActive) {
                IERC20(_token).approve(_router, type(uint256).max);
                activeTokens.push(_token);
            }
        } else {
            for (uint256 i = 0; i < activeTokens.length; i++) {
                if (activeTokens[i] == _token) {
                    activeTokens[i] = activeTokens[activeTokens.length - 1];
                    activeTokens.pop();
                }
            }
        }

        tkn.isActive = _isActive;
        tkn.swapValue = _swapValue;
        tkn.minBet = _minBet;
        tkn.maxBet = _maxBet;
        tkn.fee = _fee;
        tkn.router = _router;
        tkn.path = _path;
    }

    function setDiceInfo(uint8 _newOver, uint8 _newUnder) external onlyOwner {
        rollOver = _newOver;
        rollUnder = _newUnder;
    }

    function setSponsorWallet(address _newWallet) external onlyOwner {
        sponsorWallet = _newWallet;
    }

    function playDice(Direction _overOrUnder, address _token, uint256 _betAmount) external {
        Token memory tkn = tokenInfo[_token];
        Game storage game = idToGame[gameId];
        IERC20(_token).transferFrom(msg.sender, address(this), _betAmount);

        require(tkn.isActive, "Invalid playing token");
        require(_betAmount <= tkn.maxBet && _betAmount >= tkn.minBet, "Amount exceeds limit");
        require(
            IERC20(_token).balanceOf(address(this)) - tkn.currentBalance >= _betAmount * 2,
            "Not enough funds to payout win"
        );

        bytes32 requestId = airnodeRrp.makeFullRequest(
            airnode,
            endpointIdUint256,
            address(this),
            sponsorWallet,
            address(this),
            this.fulfillUint256.selector,
            ""
        );

        requestToGame[requestId] = gameId;

        game.player = msg.sender;
        game.betAmount = _betAmount;
        game.direction = _overOrUnder;
        game.betToken = _token;
        game.timestamp = uint32(block.timestamp);

        emit DicePlayed(gameId, msg.sender, _token, _betAmount, _overOrUnder, block.timestamp);

        gameId++;
    }

    function fulfillUint256(bytes32 requestId, bytes calldata data) external onlyAirnodeRrp {
        uint256 _gameId = requestToGame[requestId];
        Game storage game = idToGame[_gameId];
        Token storage tkn = tokenInfo[game.betToken];

        uint256 qrngUint256 = abi.decode(data, (uint256));
        uint256 randomNum = qrngUint256 % 101;
        game.rolledNumber = uint8(randomNum);
        games[game.player][totalPlayed[game.player]] = Game(
            game.direction,
            game.rolledNumber,
            game.timestamp,
            game.betToken,
            game.player,
            game.betAmount,
            game.wonAmount
        );
        totalPlayed[game.player]++;

        if (
            (game.direction == Direction.Under && randomNum <= rollUnder) ||
            (game.direction == Direction.Over && randomNum >= rollOver)
        ) {
            game.wonAmount = game.betAmount * 2;
            games[game.player][totalPlayed[game.player]].wonAmount = game.wonAmount;
            IERC20(game.betToken).transfer(game.player, game.wonAmount);
        } else {
            IERC20 token = IERC20(game.betToken);
            uint256 amount = game.betAmount;

            uint256 treasuryFee = (amount * tkn.fee.treasury) / 1000;
            uint256 burnFee = (amount * tkn.fee.burn) / 1000;
            uint256 swapFee = (amount * tkn.fee.swap) / 1000;

            token.transfer(treasury, treasuryFee);
            token.transfer(address(0xdead), burnFee);
            tkn.currentBalance += swapFee;

            if (tkn.currentBalance >= tkn.swapValue) {
                IUniswapV2Router02 router = IUniswapV2Router02(tkn.router);
                router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                    tkn.currentBalance,
                    0,
                    tkn.path,
                    treasury,
                    block.timestamp + 60
                );
                tkn.currentBalance = 0;
            }
        }

        emit GameResult(_gameId, game.player, game.direction, game.rolledNumber, game.wonAmount);
    }

    function rescueTokens(address _token, uint256 _amount) external onlyOwner {
        if (_token == address(0x0)) {
            payable(owner()).transfer(_amount);
            return;
        }
        IERC20 token = IERC20(_token);
        token.transfer(owner(), _amount);
    }

    function getActiveTokens() external view returns (address[] memory) {
        return activeTokens;
    }
}