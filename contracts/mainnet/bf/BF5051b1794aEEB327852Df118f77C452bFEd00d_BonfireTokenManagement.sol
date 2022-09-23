// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "../swap/IBonfireTokenManagement.sol";
import "../token/IMultichainTokenFactory.sol";

interface IBonfireProxyToken {
    function sourceToken() external returns (address);
}

contract BonfireTokenManagement is Ownable, IBonfireTokenManagement {
    address constant WBNB = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);

    address public override WETH;
    address[] public intermediateTokens;
    address public override tokenFactory;
    address public override defaultToken =
        address(0x5e90253fbae4Dab78aa351f4E6fed08A64AB5590); //Bonfire on BSC

    mapping(address => address) defaultProxy;
    mapping(address => uint256) public override maxTx;

    event ChangeIntermediateToken(
        address indexed intermediateToken,
        bool enabled
    );

    event DefaultTokenUpdate(address indexed token);

    event DefaultProxyUpdate(address sourceToken, address newProxy);

    event TokenFactoryUpdate(address factory);

    event MaxTxUpdate(address token, uint256 _maxTx);

    error BadAddress(uint256 location, address a);

    constructor(address admin) Ownable() {
        transferOwnership(admin);
        if (block.chainid == 56) {
            WETH = WBNB;
        }
    }

    function setMaxTx(address token, uint256 _maxTx) external onlyOwner {
        maxTx[token] = _maxTx;
        emit MaxTxUpdate(token, _maxTx);
    }

    function setDefaultToken(address token) external onlyOwner {
        defaultToken = token;
        emit DefaultTokenUpdate(token);
    }

    function finaliseWETH(address _weth) external onlyOwner {
        if (WETH != address(0)) {
            revert BadAddress(0, WETH);
        }
        WETH = _weth;
    }

    function setTokenFactory(address _tokenFactory) external onlyOwner {
        tokenFactory = _tokenFactory;
        emit TokenFactoryUpdate(tokenFactory);
    }

    function setDefaultProxy(address proxy) external onlyOwner {
        address sourceToken = IBonfireProxyToken(proxy).sourceToken();
        defaultProxy[sourceToken] = proxy;
        emit DefaultProxyUpdate(sourceToken, proxy);
    }

    function getAlternateProxy(address sourceToken)
        public
        virtual
        override
        returns (address)
    {
        return
            IMultichainTokenFactory(tokenFactory).getMultichainToken(
                owner(),
                sourceToken,
                IERC20(sourceToken).totalSupply(),
                block.chainid,
                string(
                    abi.encodePacked("bon", IERC20Metadata(sourceToken).name())
                ),
                string(
                    abi.encodePacked("b", IERC20Metadata(sourceToken).symbol())
                ),
                IERC20(sourceToken).totalSupply(),
                IERC20Metadata(sourceToken).decimals(),
                2
            );
    }

    function defaultProxyAddress(address sourceToken)
        external
        view
        returns (address)
    {
        if (defaultProxy[sourceToken] != address(0)) {
            return defaultProxy[sourceToken];
        } else {
            return
                IMultichainTokenFactory(tokenFactory).multichainTokenAddress(
                    owner(),
                    sourceToken,
                    IERC20(sourceToken).totalSupply(),
                    block.chainid,
                    string(
                        abi.encodePacked(
                            "bon",
                            IERC20Metadata(sourceToken).name()
                        )
                    ),
                    string(
                        abi.encodePacked(
                            "b",
                            IERC20Metadata(sourceToken).symbol()
                        )
                    ),
                    IERC20(sourceToken).totalSupply(),
                    IERC20Metadata(sourceToken).decimals(),
                    1
                );
        }
    }

    function getDefaultProxy(address sourceToken)
        public
        virtual
        override
        returns (address)
    {
        if (defaultProxy[sourceToken] == address(0)) {
            defaultProxy[sourceToken] = IMultichainTokenFactory(tokenFactory)
                .getMultichainToken(
                    owner(),
                    sourceToken,
                    IERC20(sourceToken).totalSupply(),
                    block.chainid,
                    string(
                        abi.encodePacked(
                            "bon",
                            IERC20Metadata(sourceToken).name()
                        )
                    ),
                    string(
                        abi.encodePacked(
                            "b",
                            IERC20Metadata(sourceToken).symbol()
                        )
                    ),
                    IERC20(sourceToken).totalSupply(),
                    IERC20Metadata(sourceToken).decimals(),
                    1
                );
        }
        return defaultProxy[sourceToken];
    }

    function intermediateTokenEnabled(address token)
        external
        view
        returns (bool)
    {
        for (uint256 i = 0; i < intermediateTokens.length; i++) {
            if (intermediateTokens[i] == token) {
                return true;
            }
        }
        return false;
    }

    function setIntermediateToken(address token, bool enabled)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < intermediateTokens.length; i++) {
            if (token == intermediateTokens[i]) {
                if (enabled) {
                    revert BadAddress(1, token); //token already present
                }
                intermediateTokens[i] = intermediateTokens[
                    intermediateTokens.length - 1
                ];
                intermediateTokens.pop();
                return;
            }
        }
        if (!enabled) {
            revert BadAddress(2, token); //token not present
        }
        intermediateTokens.push(token);
        emit ChangeIntermediateToken(token, enabled);
    }

    function getIntermediateTokens()
        external
        view
        override
        returns (address[] memory tokens)
    {
        return intermediateTokens;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

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

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface IBonfireTokenManagement {
    function WETH() external view returns (address);

    function tokenFactory() external view returns (address);

    function defaultToken() external view returns (address);

    function getIntermediateTokens() external view returns (address[] memory);

    function getAlternateProxy(address sourceToken) external returns (address);

    function getDefaultProxy(address sourceToken) external returns (address);

    function maxTx(address token) external view returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface IMultichainTokenFactory {
    event TokenCreation(
        address creator,
        address sourceToken,
        uint256 chainId,
        address targetToken
    );

    function multichainTokenAddress(
        address creator,
        address sourceToken,
        uint256 sourceTotalSupply,
        uint256 chainId,
        string memory name,
        string memory symbol,
        uint256 totalSupply,
        uint8 decimals,
        uint256 pepper
    ) external view returns (address multichainToken);

    function getMultichainToken(
        address creator,
        address sourceToken,
        uint256 sourceTotalSupply,
        uint256 chainId,
        string memory name,
        string memory symbol,
        uint256 totalSupply,
        uint8 decimals,
        uint256 pepper
    ) external returns (address multichainToken);
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