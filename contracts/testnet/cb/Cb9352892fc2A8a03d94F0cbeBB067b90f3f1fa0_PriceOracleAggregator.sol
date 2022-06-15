// SPDX-License-Identifier: MIT
pragma solidity ^0.7.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IPriceOracleAggregator.sol";
import "../interfaces/IOracle.sol";

////////////////////////////////////////////////////////////////////////////////////////////
/// @title PriceOracleAggregator
/// @notice aggregator of price oracle for assets
////////////////////////////////////////////////////////////////////////////////////////////

contract PriceOracleAggregator is IPriceOracleAggregator {
    /// STATE VARIABLES ////

    /// @dev admin allowed to update price oracle
    address public owner;

    /// @dev new owner
    address internal newOwner;

    /// @notice token to the oracle address
    mapping(IERC20 => IOracle) public assetToOracle;

    /// @notice stable to is stable status
    mapping(IERC20 => bool) public stableTokens;

    modifier onlyOwner() {
        require(msg.sender == owner, "ONLY_OWNER");
        _;
    }

    constructor(address _owner) {
        require(_owner != address(0), "INVALID_OWNER");
        owner = _owner;
    }

    /// @notice adds oracle for an asset e.g. ETH
    /// @param _asset the oracle for the asset
    /// @param _oracle the oracle address
    function setOracleForAsset(
        IERC20[] calldata _asset,
        IOracle[] calldata _oracle
    ) external override onlyOwner {
        require(_asset.length == _oracle.length, "INV");
        uint256 size = _asset.length;

        for (uint256 i = 0; i < size; i++) {
            IOracle oracle = _oracle[i];
            require(address(oracle) != address(0), "INVALID_ORACLE");
            assetToOracle[_asset[i]] = oracle;
            emit UpdateOracle(_asset[i], oracle);
        }
    }

    /// @notice remove oracle
    function removeOracleForAsset(IERC20 _asset) external onlyOwner {
        assetToOracle[_asset] = IOracle(address(0));
        emit UpdateOracle(_asset, IOracle(address(0)));
    }

    /// @notice addStable use to add stablecoin asset that should be hardcoded
    function addStable(IERC20[] calldata _tokens) public onlyOwner {
        uint256 size = _tokens.length;
        for (uint256 i = 0; i < size; i++) {
            stableTokens[_tokens[i]] = true;
            emit StableTokenAdded(_tokens[i], block.timestamp);
        }
    }

    /// @notice returns price of token in USD in 1e8 decimals
    /// @param _token token to fetch price
    function getPriceInUSD(IERC20 _token)
        public
        view
        override
        returns (uint256 price)
    {
        IOracle oracle = assetToOracle[_token];

        if (address(oracle) != address(0)) {
            price = uint256(assetToOracle[_token].latestAnswer());
        } else if (stableTokens[_token] == true) {
            price = 1e8;
        }

        require(price > 0, "INVALID_PRICE");
    }

    function getPriceInUSDMultiple(IERC20[] calldata _tokens)
        external
        view
        override
        returns (uint256[] memory prices)
    {
        uint256 size = _tokens.length;
        for (uint256 i = 0; i < size; i++) {
            prices[i] = getPriceInUSD(_tokens[i]);
        }
    }

    /// @notice accept transfer of control
    function acceptOwnership() external {
        require(msg.sender == newOwner, "invalid owner");

        // emit event before state change to do not trigger null address
        emit OwnershipAccepted(owner, newOwner, block.timestamp);

        owner = newOwner;
        newOwner = address(0);
    }

    /// @notice Transfer control from current owner address to another
    /// @param _newOwner The new team
    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "INVALID_NEW_OWNER");
        newOwner = _newOwner;
        emit TransferControl(_newOwner, block.timestamp);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.4;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IOracle.sol";

interface IPriceOracleAggregator {
    event UpdateOracle(IERC20 token, IOracle oracle);

    function getPriceInUSD(IERC20 _token) external view returns (uint256);

    function getPriceInUSDMultiple(IERC20[] calldata _tokens)
        external
        view
        returns (uint256[] memory);

    function setOracleForAsset(
        IERC20[] calldata _asset,
        IOracle[] calldata _oracle
    ) external;

    event OwnershipAccepted(
        address prevOwner,
        address newOwner,
        uint256 timestamp
    );
    event TransferControl(address _newTeam, uint256 timestamp);
    event StableTokenAdded(IERC20 _token, uint256 timestamp);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.4;

interface IOracle {
    /// @notice Price update event
    /// @param asset the asset
    /// @param newPrice price of the asset
    event PriceUpdated(address asset, uint256 newPrice);

    /// @dev returns latest answer
    function latestAnswer() external view returns (int256);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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