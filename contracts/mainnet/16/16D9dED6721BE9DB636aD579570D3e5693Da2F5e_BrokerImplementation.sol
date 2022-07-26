// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import '../utils/NameVersion.sol';
import '../token/IERC20.sol';
import '../token/IDToken.sol';
import '../pool/IPool.sol';
import '../library/SafeERC20.sol';
import './BrokerStorage.sol';
import './IClient.sol';

contract BrokerImplementation is BrokerStorage, NameVersion {

    event OpenBet(
        address indexed user,
        address indexed pool,
        address asset,
        uint256 amount,
        string symbolName,
        int256 tradeVolume,
        address client
    );

    event CloseBet(
        address indexed user,
        address indexed pool,
        address asset,
        uint256 amount,
        string symbolName,
        int256 tradeVolume,
        address client
    );

    using SafeERC20 for IERC20;

    address public immutable clientTemplate;

    address public immutable clientImplementation;

    constructor (
        address clientTemplate_,
        address clientImplementation_
    ) NameVersion('BrokerImplementation', '3.0.1')
    {
        clientTemplate = clientTemplate_;
        clientImplementation = clientImplementation_;
    }

    function openBet(
        address pool,
        address asset,
        uint256 amount,
        string memory symbolName,
        int256 tradeVolume,
        int256 priceLimit,
        IPool.OracleSignature[] memory oracleSignatures
    ) external payable {
        bytes32 symbolId = keccak256(abi.encodePacked(symbolName));
        Bet storage bet = bets[msg.sender][pool][symbolId];
        int256 volume = getVolume(msg.sender, pool, symbolId);
        require(volume == 0, 'BrokerImplementation.openBet: existed bet');

        bet.asset = asset;
        address client;
        if (bet.client == address(0)) {
            client = _clone(clientTemplate);
            bet.client = client;
        } else {
            client = bet.client;
        }

        if (asset == address(0)) {
            amount = msg.value;
            _transfer(address(0), client, amount);
        } else {
            IERC20(asset).safeTransferFrom(msg.sender, client, amount);
        }

        IClient(client).addMargin(pool, asset, amount, oracleSignatures);
        IClient(client).trade(pool, symbolName, tradeVolume, priceLimit, oracleSignatures);

        emit OpenBet(msg.sender, pool, asset, amount, symbolName, tradeVolume, client);
    }

    function closeBet(
        address pool,
        string memory symbolName,
        int256 priceLimit,
        IPool.OracleSignature[] memory oracleSignatures
    ) external {
        bytes32 symbolId = keccak256(abi.encodePacked(symbolName));
        Bet memory bet = bets[msg.sender][pool][symbolId];
        int256 volume = getVolume(msg.sender, pool, symbolId);
        require(volume != 0, 'BrokerImplementation.closeBet: no bet');

        IClient(bet.client).trade(pool, symbolName, -volume, priceLimit, oracleSignatures);
        IClient(bet.client).removeMargin(pool, bet.asset, type(uint256).max, oracleSignatures);

        uint256 balance = bet.asset == address(0) ? bet.client.balance : IERC20(bet.asset).balanceOf(bet.client);
        IClient(bet.client).transfer(bet.asset, msg.sender, balance);

        emit CloseBet(msg.sender, pool, bet.asset, balance, symbolName, -volume, bet.client);
    }

    function getBetVolumes(address account, address pool, string[] memory symbols) external view returns (int256[] memory) {
        int256[] memory volumes = new int256[](symbols.length);
        for (uint256 i = 0; i < symbols.length; i++) {
            volumes[i] = getVolume(account, pool, keccak256(abi.encodePacked(symbols[i])));
        }
        return volumes;
    }

    function getVolume(address account, address pool, bytes32 symbolId) public view returns (int256 volume) {
        Bet storage bet = bets[account][pool][symbolId];
        address client = bet.client;
        if (client != address(0)) {
            IDToken pToken = IDToken(IPoolComplement(pool).pToken());
            uint256 pTokenId = pToken.getTokenIdOf(client);
            if (pTokenId != 0) {
                address symbol = ISymbolManagerComplement(IPoolComplement(pool).symbolManager()).symbols(symbolId);
                if (symbol != address(0)) {
                    ISymbolComplement.Position memory p = ISymbolComplement(symbol).positions(pTokenId);
                    volume = p.volume;
                }
            }
        }
    }

    function getUserStatuses(address account, address pool, string[] memory symbols) external view returns (uint256[] memory) {
        uint256[] memory statuses = new uint256[](symbols.length);
        for (uint256 i = 0; i < symbols.length; i++) {
            statuses[i] = getUserStatus(account, pool, keccak256(abi.encodePacked(symbols[i])));
        }
        return statuses;
    }

    // Return value:
    // 1: User never entered bet, no client
    // 2: User is holding a betting volume
    // 3: User closed bet normally
    // 4: User is liquidated
    // 0: Wrong query, e.g. wrong symbolId etc.
    function getUserStatus(address account, address pool, bytes32 symbolId) public view returns (uint256 status) {
        Bet storage bet = bets[account][pool][symbolId];
        address client = bet.client;
        if (client == address(0)) {
            status = 1;
        } else {
            IDToken pToken = IDToken(IPoolComplement(pool).pToken());
            uint256 pTokenId = pToken.getTokenIdOf(client);
            if (pTokenId != 0) {
                address symbol = ISymbolManagerComplement(IPoolComplement(pool).symbolManager()).symbols(symbolId);
                if (symbol != address(0)) {
                    ISymbolComplement.Position memory p = ISymbolComplement(symbol).positions(pTokenId);
                    if (p.volume != 0) {
                        status = 2;
                    } else {
                        status = p.cumulativeFundingPerVolume != 0 ? 3 : 4;
                    }
                }
            }
        }
    }

    function claimRewardAsLpVenus(address pool, address[] memory clients) external _onlyAdmin_ {
        for (uint256 i = 0; i < clients.length; i++) {
            IClient(clients[i]).claimRewardAsLpVenus(pool);
        }
    }

    function claimRewardAsTraderVenus(address pool, address[] memory clients) external _onlyAdmin_ {
        for (uint256 i = 0; i < clients.length; i++) {
            IClient(clients[i]).claimRewardAsTraderVenus(pool);
        }
    }

    function claimRewardAsLpAave(address pool, address[] memory clients) external _onlyAdmin_ {
        for (uint256 i = 0; i < clients.length; i++) {
            IClient(clients[i]).claimRewardAsLpAave(pool);
        }
    }

    function claimRewardAsTraderAave(address pool, address[] memory clients) external _onlyAdmin_ {
        for (uint256 i = 0; i < clients.length; i++) {
            IClient(clients[i]).claimRewardAsTraderAave(pool);
        }
    }

    function transfer(address asset, address to, uint256 amount) external _onlyAdmin_ {
        _transfer(asset, to, amount);
    }

    function _clone(address source) internal returns (address target) {
        bytes20 sourceBytes = bytes20(source);
        assembly {
            let c := mload(0x40)
            mstore(c, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(c, 0x14), sourceBytes)
            mstore(add(c, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            target := create(0, c, 0x37)
        }
    }

    // amount in asset's own decimals
    function _transfer(address asset, address to, uint256 amount) internal {
        if (asset == address(0)) {
            (bool success, ) = payable(to).call{value: amount}('');
            require(success, 'BrokerImplementation.transfer: send ETH fail');
        } else {
            IERC20(asset).safeTransfer(to, amount);
        }
    }

}

interface IPoolComplement {
    function pToken() external view returns (address);
    function symbolManager() external view returns (address);
}

interface ISymbolManagerComplement {
    function symbols(bytes32 symbolId) external view returns (address);
}

interface ISymbolComplement {
    struct Position {
        int256 volume;
        int256 cost;
        int256 cumulativeFundingPerVolume;
    }
    function positions(uint256 pTokenId) external view returns (Position memory);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import './INameVersion.sol';

/**
 * @dev Convenience contract for name and version information
 */
abstract contract NameVersion is INameVersion {

    bytes32 public immutable nameId;
    bytes32 public immutable versionId;

    constructor (string memory name, string memory version) {
        nameId = keccak256(abi.encodePacked(name));
        versionId = keccak256(abi.encodePacked(version));
    }

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

interface IERC20 {

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    event Transfer(address indexed from, address indexed to, uint256 amount);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import './IERC721.sol';
import '../utils/INameVersion.sol';

interface IDToken is IERC721, INameVersion {

    function pool() external view returns (address);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function totalMinted() external view returns (uint256);

    function exists(address owner) external view returns (bool);

    function exists(uint256 tokenId) external view returns (bool);

    function getOwnerOf(uint256 tokenId) external view returns (address);

    function getTokenIdOf(address owner) external view returns (uint256);

    function mint(address owner) external returns (uint256);

    function burn(uint256 tokenId) external;

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import '../utils/INameVersion.sol';
import '../utils/IAdmin.sol';
import '../token/IDToken.sol';

interface IPool is INameVersion, IAdmin {

    function implementation() external view returns (address);

    function protocolFeeCollector() external view returns (address);

    function liquidity() external view returns (int256);

    function lpsPnl() external view returns (int256);

    function cumulativePnlPerLiquidity() external view returns (int256);

    function protocolFeeAccrued() external view returns (int256);

    function setImplementation(address newImplementation) external;

    function addMarket(address market) external;

    function approveSwapper(address underlying) external;

    function collectProtocolFee() external;

    function claimVenusLp(address account) external;

    function claimVenusTrader(address account) external;

    struct OracleSignature {
        bytes32 oracleSymbolId;
        uint256 timestamp;
        uint256 value;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function addLiquidity(address underlying, uint256 amount, OracleSignature[] memory oracleSignatures) external payable;

    function removeLiquidity(address underlying, uint256 amount, OracleSignature[] memory oracleSignatures) external;

    function addMargin(address underlying, uint256 amount, OracleSignature[] memory oracleSignatures) external payable;

    function removeMargin(address underlying, uint256 amount, OracleSignature[] memory oracleSignatures) external;

    function trade(string memory symbolName, int256 tradeVolume, int256 priceLimit, OracleSignature[] memory oracleSignatures) external;

    function liquidate(uint256 pTokenId, OracleSignature[] memory oracleSignatures) external;

    struct LpInfo {
        address vault;
        int256 amountB0;
        int256 liquidity;
        int256 cumulativePnlPerLiquidity;
    }

    function lpInfos(uint256) external view returns (LpInfo memory);

    function tokenB0() external view returns (address);

    function vTokenB0() external view returns (address);

    function minRatioB0() external view returns (int256);

    function lToken() external view returns (IDToken);

    function decimalsB0() external view returns (uint256);

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "../token/IERC20.sol";
import "./Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {

    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) - value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import '../utils/Admin.sol';

abstract contract BrokerStorage is Admin {

    address public implementation;

    struct Bet {
        address asset;
        address client;
        int256 volume;
    }

    // user => pool => symbolId => client address
    mapping (address => mapping (address => mapping (bytes32 => Bet))) public bets;

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import '../utils/INameVersion.sol';
import '../pool/IPool.sol';

interface IClient is INameVersion {

    function broker() external view returns (address);

    function addLiquidity(
        address pool,
        address asset,
        uint256 amount,
        IPool.OracleSignature[] memory oracleSignatures
    ) external payable;

    function removeLiquidity(
        address pool,
        address asset,
        uint256 amount,
        IPool.OracleSignature[] memory oracleSignatures
    ) external;

    function addMargin(
        address pool,
        address asset,
        uint256 amount,
        IPool.OracleSignature[] memory oracleSignatures
    ) external payable;

    function removeMargin(
        address pool,
        address asset,
        uint256 amount,
        IPool.OracleSignature[] memory oracleSignatures
    ) external;

    function trade(
        address pool,
        string memory symbolName,
        int256 tradeVolume,
        int256 priceLimit,
        IPool.OracleSignature[] memory oracleSignatures
    ) external;

    function transfer(address asset, address to, uint256 amount) external;

    function claimRewardAsLpVenus(address pool) external;

    function claimRewardAsTraderVenus(address pool) external;

    function claimRewardAsLpAave(address pool) external;

    function claimRewardAsTraderAave(address pool) external;

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

interface INameVersion {

    function nameId() external view returns (bytes32);

    function versionId() external view returns (bytes32);

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "./IERC165.sol";

interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed operator, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address);

    function getApproved(uint256 tokenId) external view returns (address);

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function approve(address operator, uint256 tokenId) external;

    function setApprovalForAll(address operator, bool approved) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

interface IAdmin {

    event NewAdmin(address indexed newAdmin);

    function admin() external view returns (address);

    function setAdmin(address newAdmin) external;

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

pragma solidity >=0.8.0 <0.9.0;

import './IAdmin.sol';

abstract contract Admin is IAdmin {

    address public admin;

    modifier _onlyAdmin_() {
        require(msg.sender == admin, 'Admin: only admin');
        _;
    }

    constructor () {
        admin = msg.sender;
        emit NewAdmin(admin);
    }

    function setAdmin(address newAdmin) external _onlyAdmin_ {
        admin = newAdmin;
        emit NewAdmin(newAdmin);
    }

}