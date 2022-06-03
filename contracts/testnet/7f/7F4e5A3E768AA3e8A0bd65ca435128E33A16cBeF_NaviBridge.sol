/**
 *Submitted for verification at BscScan.com on 2022-06-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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

// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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

interface IBridgedData {
    function bridgedData() external view returns (bytes memory);

    function resetBridgeReciever() external;

    function receiveBridgedData(bytes memory data) external;
}

interface IBridged {
    /*
     * @note amount is in wad with 18 deciamls
     */
    function bridgeMint(address account, uint256 amount) external;

    function bridgeBurn(address account, uint256 amount) external;
}

interface INaviOracle {
    function isBridged(uint32 id) external view returns (bool);

    function hasBridgedData(uint32 id) external view returns (bool);

    function isnToken(uint32 id) external view returns (bool);

    function hasPriceFeed(uint32 id) external view returns (bool);

    function tokenAddress(uint32 id) external view returns (address);

    function daoAddress(uint32 id) external view returns (address);

    function price(uint32 id) external view returns (uint256);

    function tokenExtra(uint32 id) external view returns (string memory);

    function maxId() external view returns (uint32);

    function idByTokenAddress(address token) external view returns (uint32);
}

interface InTokenForEther {
    function compensateFee(
        address from,
        address to,
        uint256 amount
    ) external;
}

/// math.sol -- mixin for inline numerical wizardry

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/**
 * @title Fixed point WAD\RAY math contract
 * @notice Implements the fixed point arithmetic operations for WAD numbers (18 decimals) and RAY (27 decimals)
 * @dev Wad functions have a [w] prefix: wmul, wdiv. Ray functions have a [r] prefix: rmul, rdiv, rpow.
 * @author https://github.com/dapphub/ds-math
 **/

contract DSMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        return x <= y ? x : y;
    }

    function max(uint256 x, uint256 y) internal pure returns (uint256 z) {
        return x >= y ? x : y;
    }

    function imin(int256 x, int256 y) internal pure returns (int256 z) {
        return x <= y ? x : y;
    }

    function imax(int256 x, int256 y) internal pure returns (int256 z) {
        return x >= y ? x : y;
    }

    uint256 constant WAD = 10**18;
    uint256 constant RAY = 10**27;

    //rounds to zero if x*y < WAD / 2
    function wmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }

    //rounds to zero if x*y < WAD / 2
    function rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }

    //rounds to zero if x*y < WAD / 2
    function wdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, WAD), y / 2) / y;
    }

    //rounds to zero if x*y < RAY / 2
    function rdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint256 x, uint256 n) internal pure returns (uint256 z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

//MAYBE TODO transferOutBySigWithBlockhash

/**
 * @title Cross-chain bridge for token and data transfers.
 * @notice Implements a transaction storage mechanism for forming blocks with token and data transfers
 * and a mechanism for voting on previous block hash
 * @dev Bridged tokens and data can be discovered in NaviOracle contract. Block is fixed to 10 minutes using
 * block.timestamp's. Blocks of incoming transfers are formed offchain from deterministic algorithm
 * using onchain outgoing transfers. Incoming transfers are stored in merkle trees. Root of the tree is
 * called the hash of of the block. This hash is voted on.
 **/
contract NaviBridge is Ownable, ReentrancyGuard, DSMath {
    struct Transaction {
        address recipient;
        uint32 token;
        uint256 amount;
        uint256 chainIdTo;
        bytes32 lastBlockHash;
        uint256 feeTo;
    }

    //Current block data
    uint32 private currentBlock; //height
    uint256 private timestampStart;
    mapping(address => Transaction) private txs; //transactions
    address[] private addresses; //transactions key array
    mapping(bytes32 => uint256) private staked; //last block hash votes
    bytes32[] private hashes; // votes key array
    bytes[] private blockData; // other data collected on-chain

    //Past block data
    mapping(uint32 => Transaction[]) private pastBlock;
    mapping(uint32 => bytes32) private blockHashes; //confirmed block hashes
    mapping(uint32 => uint256) private blockTimestamps;
    mapping(uint32 => bytes) private pastBlockData;

    //Global state
    mapping(address => uint32) private nonces; // to exclude transaction signature reuse
    mapping(address => mapping(uint256 => uint32)) blockNumbers; //exclude transferIn reuse
    INaviOracle public immutable oracle; //used for last block hash voting
    uint8 private minConfirmations; //numer of next blocks needed for a block to become confirmed
    uint16 private maxBlockLength; //max number of transactions included in a block
    uint8 private naviStakeMultiplier; //NaviDAO tokens has bigger stake in voting for correct hash
    InTokenForEther private feeCompensator; //nToken used to compensate tx fees

    //Users authorizes strategy contract to act on their behalf
    mapping(address => mapping(address => bool)) private strategyAllowances;
    address[] private allStrategies; // for introspection

    event TransferOut(
        address signatory,
        uint32 token,
        uint256 amount,
        uint256 chainIdTo,
        bytes32 lastBlockHash,
        uint256 feeTo
    );
    event NewBlock(uint32 height, uint256 timestamp);
    event DataRecieved(uint32 height);
    event TransferIn(
        uint32 token,
        uint256 amount,
        uint256 chainIdFrom,
        uint256 feeTo,
        address recepient,
        uint32 blockNumber
    );
    event NewStrategyRegistered(address strategy);
    event StrategyRemoved(address strategy);
    event StrategyAuthorizationChanged(
        address strategy,
        address signatory,
        bool authorize
    );

    constructor(
        address _oracle,
        uint8 _minConfirmations,
        uint16 _maxBlockLength
    ) Ownable() {
        oracle = INaviOracle(_oracle);
        minConfirmations = _minConfirmations;
        currentBlock = 0;
        timestampStart = (block.timestamp / 600) * 600;
        maxBlockLength = _maxBlockLength;
        naviStakeMultiplier = 10;
        calculateNewBlockData(INaviOracle(_oracle)); //During deployment, first block does not have correct data!
        // maybe: form data at the end of a block?
    }

    // Strategy is registerd by contract owner and authorized by user
    function isAuthorized(address strategy, address signatory)
        public
        view
        returns (bool)
    {
        return
            strategyAllowances[address(0)][strategy] &&
            strategyAllowances[signatory][strategy];
    }

    function getStrategy(uint32 index) external view returns (address) {
        return allStrategies[index];
    }

    function getAllStrategiesLength() external view returns (uint256) {
        return allStrategies.length;
    }

    function registerStrategy(address strategy) external onlyOwner {
        allStrategies.push(strategy);
        strategyAllowances[address(0)][strategy] = true;
        emit NewStrategyRegistered(strategy);
    }

    function removeStrategy(uint32 index) external onlyOwner {
        address strategy = allStrategies[index];
        delete strategyAllowances[address(0)][strategy];
        delete allStrategies[index];
        emit StrategyRemoved(strategy);
    }

    function authorizeStrategy(address strategy, bool authorize) external {
        strategyAllowances[msg.sender][strategy] = authorize;
        emit StrategyAuthorizationChanged(strategy, msg.sender, authorize);
    }

    struct AuthorizeStrategyBySigParams {
        address strategy;
        bool authorize;
        uint256 fee;
        uint32 nonce;
        uint256 expiry;
        bytes32 schema;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function authorizeStrategyBySig(bytes calldata paramData) external {
        AuthorizeStrategyBySigParams memory vars = abi.decode(
            paramData,
            (AuthorizeStrategyBySigParams)
        );
        require(
            block.timestamp <= vars.expiry,
            "Navi::authorizeStrategyBySig: Signature expired"
        );
        bytes32 data = keccak256(
            abi.encodePacked(
                vars.strategy,
                vars.authorize,
                vars.fee,
                address(this),
                vars.nonce,
                vars.expiry
            )
        );
        data = keccak256(abi.encodePacked(vars.schema, data));
        address signatory = ecrecover(data, vars.v, vars.r, vars.s);
        require(
            signatory != address(0),
            "Navi::authorizeStrategyBySig: Invalid signature"
        );
        require(
            vars.nonce > nonces[signatory],
            "Navi::authorizeStrategyBySig: Invalid nonce"
        );

        nonces[signatory] = vars.nonce;
        strategyAllowances[signatory][vars.strategy] = vars.authorize;
        emit StrategyAuthorizationChanged(
            vars.strategy,
            signatory,
            vars.authorize
        );
        if (vars.fee > 0)
            feeCompensator.compensateFee(signatory, msg.sender, vars.fee);
    }

    function getFeeCompensator() external view returns (InTokenForEther) {
        return feeCompensator;
    }

    function setFeeCompensator(address compensator) external onlyOwner {
        feeCompensator = InTokenForEther(compensator);
    }

    function getCurrentHeight() external view returns (uint32) {
        return currentBlock;
    }

    function getTimestampStart() external view returns (uint256) {
        return timestampStart;
    }

    //NaviDAO token advantage factor when voting for a block hash
    function getNaviStakeMultiplier() external view returns (uint8) {
        return naviStakeMultiplier;
    }

    function setNaviStakeMultiplier(uint8 value) external onlyOwner {
        naviStakeMultiplier = value;
    }

    //Numer of 10-minute blocks needed for a transaction to become confirmed and withdrawable
    function setMinConfirmations(uint8 _minConfirmations) external onlyOwner {
        require(
            _minConfirmations >= 2,
            "Navi::setMinConfirmations: minConfirmations must be 2 or more"
        );
        require(
            _minConfirmations < 30,
            "Navi::setMinConfirmations: minConfirmations must be less than 30"
        );
        minConfirmations = _minConfirmations;
    }

    function getMinConfirmations() external view returns (uint8) {
        return minConfirmations;
    }

    //Max number of transactions included in a 10-minute block
    function setMaxBlockLength(uint16 _maxBlockLength) external onlyOwner {
        require(
            _maxBlockLength >= 10,
            "Navi::setMinConfirmations: maxBlockLength must be 10 or more"
        );
        maxBlockLength = _maxBlockLength;
    }

    function getMaxBlockLength() external view returns (uint16) {
        return maxBlockLength;
    }

    function getBlockData() external view returns (bytes memory) {
        return abi.encode(blockData);
    }

    function getLastBlock() external view returns (bytes memory ret) {
        if (currentBlock == 0) return ret;
        return abi.encode(pastBlock[currentBlock - 1]);
    }

    function getPastBlock(uint32 index) external view returns (bytes memory) {
        return abi.encode(pastBlock[index]);
    }

    /*function getBlockDataLength() external view returns (uint256) {
        return blockData.length;
    }

    function getLastBlockLength() external view returns (uint256) {
        return lastBlock.length;
    }*/

    function getBlockHash(uint32 blockNum) external view returns (bytes32) {
        return blockHashes[blockNum];
    }

    function getBlockTimestamp(uint32 index) external view returns (uint256) {
        return blockTimestamps[index];
    }

    // get transactions from timestamp start to timestamp end for chainId
    function getTransactions(
        uint256 start,
        uint256 end,
        uint256 chainId
    ) external view returns (Transaction[] memory out) {
        if (currentBlock == 0) return out;
        uint256 length = getTransactionsLength(start, end, chainId);
        out = new Transaction[](length);
        uint256 k = 0;
        uint32 i = currentBlock - 1;
        for (; i >= 0; i--) {
            if (blockTimestamps[i] < start) break;
            if (blockTimestamps[i] < end)
                for (uint32 j = 0; j < pastBlock[i].length; j++)
                    if (pastBlock[i][j].chainIdTo == chainId)
                        out[k++] = pastBlock[i][j];
        }
    }

    function getTransactionsLength(
        uint256 start,
        uint256 end,
        uint256 chainId
    ) public view returns (uint256 ret) {
        if (currentBlock == 0) return ret;
        uint32 i = currentBlock - 1;
        for (; i >= 0; i--) {
            if (blockTimestamps[i] < start) break;
            if (blockTimestamps[i] < end)
                for (uint32 j = 0; j < pastBlock[i].length; j++)
                    if (pastBlock[i][j].chainIdTo == chainId) ret++;
        }
    }

    //get blockData as certain timestamp
    function getPastBlockData(uint256 time)
        external
        view
        returns (bytes memory ret)
    {
        if (currentBlock == 0) return ret;
        uint32 i = currentBlock - 1;
        for (; blockTimestamps[i] + 600 >= time; i--) {}
        return pastBlockData[i];
    }

    function getNounce(address addr) external view returns (uint32) {
        return nonces[addr];
    }

    function getInNounce(address addr, uint256 chainIdFrom)
        external
        view
        returns (uint32)
    {
        return blockNumbers[addr][chainIdFrom];
    }

    function getDataForTransfer()
        external
        view
        returns (
            uint32 height,
            uint256 current,
            uint256 last,
            uint256 beforeLast,
            bytes32 beforeLastHash
        )
    {
        height = currentBlock;
        current = timestampStart;
        if (currentBlock > 0) last = blockTimestamps[currentBlock - 1];
        if (currentBlock > 1) {
            beforeLast = blockTimestamps[currentBlock - 2];
            beforeLastHash = blockHashes[currentBlock - 2];
        }
    }

    function getTransaction(address addr)
        external
        view
        returns (Transaction memory)
    {
        return txs[addr];
    }

    struct TransferOutBySigParams {
        uint32 token;
        uint256 amount;
        uint256 chainIdTo;
        uint256 feeTo;
        uint256 feeFrom;
        uint32 height;
        bytes32 lastBlockHash;
        uint32 nonce;
        uint256 expiry;
        bytes32 schema;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function transferOutBySig(bytes calldata params) external nonReentrant {
        TransferOutBySigParams memory vars = abi.decode(
            params,
            (TransferOutBySigParams)
        );
        require(
            vars.height == currentBlock,
            "Navi::transferOutBySig: Wrong height"
        );
        require(
            oracle.isBridged(vars.token),
            "Navi::transferOutBySig: This token is not bridged"
        );
        require(
            block.timestamp <= vars.expiry,
            "Navi::transferOutBySig: Signature expired"
        );
        bytes32 data = keccak256(
            abi.encodePacked(
                vars.token,
                vars.amount,
                vars.chainIdTo,
                getChainId(),
                vars.feeTo,
                vars.feeFrom,
                address(this),
                vars.nonce,
                vars.expiry
            )
        );
        data = keccak256(abi.encodePacked(vars.schema, data));
        address signatory = ecrecover(data, vars.v, vars.r, vars.s);
        require(
            signatory != address(0),
            "Navi::transferOutBySig: Invalid signature"
        );
        require(
            vars.nonce > nonces[signatory],
            "Navi::transferOutBySig: Invalid nonce"
        );

        nonces[signatory] = vars.nonce;
        _transferOut(
            signatory,
            vars.token,
            vars.amount,
            vars.chainIdTo,
            vars.lastBlockHash,
            vars.feeTo
        );
        if (vars.feeFrom > 0)
            feeCompensator.compensateFee(signatory, msg.sender, vars.feeFrom);
    }

    function transferOut(
        uint32 token,
        uint256 amount,
        uint256 chainIdTo,
        uint32 height,
        bytes32 lastBlockHash
    ) external nonReentrant {
        require(height == currentBlock, "Navi::transferOut: Wrong height");
        require(
            oracle.isBridged(token),
            "Navi::transferOut: This token is not bridged"
        );
        _transferOut(msg.sender, token, amount, chainIdTo, lastBlockHash, 0);
    }

    //Note strategy must check currentBlock to vote for good lastBlockHash
    function transferOutByStrategy(
        address signatory,
        uint32 token,
        uint256 amount,
        uint256 chainIdTo,
        bytes32 lastBlockHash,
        uint256 feeTo
    ) external nonReentrant {
        require(
            isAuthorized(msg.sender, signatory),
            "Navi::transferOutByStrategy: You are not a registered strategy"
        );
        require(
            oracle.isBridged(token),
            "Navi::transferOut: This token is not bridged"
        );
        _transferOut(signatory, token, amount, chainIdTo, lastBlockHash, feeTo);
    }

    function _transferOut(
        address signatory,
        uint32 token,
        uint256 amount,
        uint256 chainIdTo,
        bytes32 lastBlockHash,
        uint256 feeTo
    ) internal {
        //MAYBE TODO make more safe block boundary
        require(amount > 0, "Navi::_transferOut: Amount must be > 0");
        if (block.timestamp - timestampStart > 600) _finalizeBlock();
        // this order matters, because here might be new block
        require(
            txs[signatory].amount == 0,
            "Navi::_transferOut: Only one transaction is allowed per address per block"
        );

        if (addresses.length < maxBlockLength) addresses.push(signatory);
        else {
            //block is full, let's try to replace some cheap tx with this one
            require(
                oracle.hasPriceFeed(token),
                "Navi::_transferOut: block is full, unable to determine transfered token price"
            );
            uint256 transferValue = wmul(oracle.price(token), amount);
            require(
                transferValue > 0,
                "Navi::_transferOut: block is full, unable to determine transfer value"
            );
            for (uint16 i = 0; i < addresses.length; i++) {
                uint32 oldToken = txs[addresses[i]].token;
                uint256 oldAmoout = txs[addresses[i]].amount;
                uint256 oldTransferValue = wmul(
                    oracle.price(oldToken),
                    oldAmoout
                );
                if (
                    !oracle.hasPriceFeed(oldToken) ||
                    transferValue > oldTransferValue
                ) {
                    //undo tx[addr[i]] repaying oldToken and replace addr[i] with signatory
                    if (oldToken == 1) oldTransferValue *= naviStakeMultiplier;
                    staked[txs[addresses[i]].lastBlockHash] -= transferValue;
                    if (txs[addresses[i]].chainIdTo != getChainId())
                        IBridged(oracle.tokenAddress(oldToken)).bridgeMint(
                            addresses[i],
                            oldAmoout
                        );
                    delete txs[addresses[i]];
                    addresses[i] = signatory;
                    transferValue = 0;
                    break;
                }
            }
            require(
                transferValue == 0,
                "Navi::_transferOut: block is full, transfer value too low"
            );
        }
        txs[signatory] = Transaction(
            signatory,
            token,
            amount,
            chainIdTo,
            lastBlockHash,
            feeTo
        );
        if (oracle.hasPriceFeed(token)) {
            uint256 transferValue = wmul(oracle.price(token), amount);
            if (token == 1) transferValue *= naviStakeMultiplier;
            if (staked[lastBlockHash] == 0) hashes.push(lastBlockHash);
            staked[lastBlockHash] += transferValue;
        }
        if (chainIdTo != getChainId())
            IBridged(oracle.tokenAddress(token)).bridgeBurn(signatory, amount);
        emit TransferOut(
            signatory,
            token,
            amount,
            chainIdTo,
            lastBlockHash,
            feeTo
        );
    }

    function getLastBlockWinningHash() external view returns (bytes32) {
        bytes32 winner = "";
        uint256 winnerStaked = 0;
        for (uint16 i = 0; i < hashes.length; i++) {
            if (staked[hashes[i]] >= winnerStaked) {
                winner = hashes[i];
                winnerStaked = staked[winner];
            }
        }
        return winner;
    }

    function _finalizeBlock() internal {
        // determine winning hash of the previous block (hash with most value stacked)
        bytes32 winner = "";
        uint256 winnerStaked = 0;
        for (uint16 i = 0; i < hashes.length; i++) {
            if (staked[hashes[i]] >= winnerStaked) {
                winner = hashes[i];
                winnerStaked = staked[winner];
            }
            delete staked[hashes[i]];
        }
        hashes = new bytes32[](0);
        //pastBlock[currentBlock] = new Transaction[](0);
        Transaction[] storage lastBlock = pastBlock[currentBlock];
        // we penalize people, who voted for wrong block by reverting their transactions
        for (uint16 i = 0; i < addresses.length; i++) {
            Transaction storage t = txs[addresses[i]];
            if (t.lastBlockHash != winner)
                //undo transaction t
                IBridged(oracle.tokenAddress(t.token)).bridgeMint(
                    addresses[i],
                    t.amount
                );
            else lastBlock.push(t);
            delete txs[addresses[i]];
        }
        if (currentBlock > 1000) {
            delete pastBlock[currentBlock - 1000];
            delete pastBlockData[currentBlock - 1000];
        }
        blockTimestamps[currentBlock] = timestampStart;
        pastBlockData[currentBlock] = abi.encode(blockData);
        addresses = new address[](0);

        // if people voted for zero hash, that means 2 previous blocks will be reverted
        // that is done to prevent late voting attack (see docs)
        if (currentBlock > 0) {
            blockHashes[currentBlock - 1] = winner;
            if (winner == bytes32(0) && currentBlock > 1)
                blockHashes[currentBlock - 2] = winner;
        }
        // it would be good idea to somehow revert those zero block transactions automatically
        // for now it can only be done by including reverts as transferIn transactions
        currentBlock++;
        timestampStart = (block.timestamp / 600) * 600;

        calculateNewBlockData(oracle);
        emit NewBlock(currentBlock, timestampStart);
    }

    function calculateNewBlockData(INaviOracle o) internal {
        blockData = new bytes[](0);
        uint32 length = o.maxId();
        if (length == 0) return;
        for (uint32 i = 1; i <= length; i++) {
            if (o.hasBridgedData(i)) {
                blockData.push(IBridgedData(o.tokenAddress(i)).bridgedData());
            }
            if (o.daoAddress(i) != address(0)) {
                blockData.push(IBridgedData(o.daoAddress(i)).bridgedData());
            }
        }
    }

    // this function can be called by the recepient, by a strategy or a fee collecting robot on behalf of recepient
    function transferIn(
        uint32 token,
        uint256 amount,
        uint256 chainIdFrom,
        uint256 feeTo,
        address recepient,
        uint32 blockNumber,
        uint16 merklePath,
        uint32[16] calldata merkleProof,
        bytes calldata data
    ) external nonReentrant {
        require(
            currentBlock - blockNumber > minConfirmations,
            "Navi::transferIn: Not enough block confirmations for this transaction"
        );
        //nonce = blockNumber + 1, because blockNumber can be 0, if it is blockNumber>nonces[...] will always fail
        require(
            blockNumber + 1 > blockNumbers[recepient][chainIdFrom],
            "Navi::transferIn: Invalid nonce, transaction reuse"
        );
        require(oracle.isBridged(token), "Navi::transferIn: Invalid token");
        bytes32 dataHash = keccak256(
            abi.encodePacked(
                token,
                amount,
                getChainId(),
                chainIdFrom,
                feeTo,
                recepient,
                blockNumber,
                address(this),
                data
            )
        );
        for (uint8 i = 0; i < 16; i++) {
            if ((merklePath & 1) == 0)
                dataHash = keccak256(
                    abi.encodePacked(dataHash, merkleProof[i])
                );
            else
                dataHash = keccak256(
                    abi.encodePacked(merkleProof[i], dataHash)
                );
            merklePath = merklePath >> 1;
        }
        require(
            blockHashes[blockNumber] == dataHash,
            "Navi::transferIn: Merkle proof check failed"
        );
        blockNumbers[recepient][chainIdFrom] = blockNumber + 1;
        //Be aware that first transaction can be omitted when transferIn never claimed
        if (merklePath == 0 && data.length > 0) {
            uint32 length = oracle.maxId();
            //reset receiver states
            for (uint32 j = 1; j <= length; j++) {
                if (oracle.hasBridgedData(j))
                    IBridgedData(oracle.tokenAddress(j)).resetBridgeReciever();

                if (oracle.daoAddress(j) != address(0))
                    IBridgedData(oracle.daoAddress(j)).resetBridgeReciever();
            }
            //unpack each chain data
            bytes[] memory chainsData = abi.decode(data, (bytes[]));
            for (uint8 i = 0; i < chainsData.length; i++) {
                bytes[] memory chainData = abi.decode(chainsData[i], (bytes[]));
                //chainData array structure is similar to current block's blockData
                uint32 k = 0;
                for (uint32 j = 1; j <= length; j++) {
                    if (oracle.hasBridgedData(j))
                        IBridgedData(oracle.tokenAddress(j)).receiveBridgedData(
                            chainData[k++]
                        );
                    if (k > chainData.length) break;
                    if (oracle.daoAddress(j) != address(0))
                        IBridgedData(oracle.daoAddress(j)).receiveBridgedData(
                            chainData[k++]
                        );
                    if (k > chainData.length) break;
                }
            }
            emit DataRecieved(blockNumber);
        }
        IBridged(oracle.tokenAddress(token)).bridgeMint(recepient, amount);
        if (feeTo > 0)
            feeCompensator.compensateFee(recepient, msg.sender, feeTo);
        emit TransferIn(
            token,
            amount,
            chainIdFrom,
            feeTo,
            recepient,
            blockNumber
        );
    }

    function getChainId() internal view returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }
}