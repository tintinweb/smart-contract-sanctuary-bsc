// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../interface/IIsland.sol";

contract IslandStake is OwnableUpgradeable {
    IERC20 public BLK;
    IBEP20 public islandToken;
    IERC721 public NFT;
    uint constant acc = 1e10;
    uint private seq;

    mapping(uint => bool) public banned;
    mapping(uint => LevelInfo) public levelData;
    uint[] public levelList;

    struct LevelInfo {
        uint max;
        uint earnRate;
        uint contributeRate;
    }

    struct IslandInfo {
        uint total;
        uint debt;
        uint lastTime;
        uint contribute;
        uint lastAssignTime;
    }

    struct UserIslandStakeInfo {
        uint total;
        uint locked;
    }

    struct StakeInfo {
        uint seq;
        uint stakeTime;
        uint stakeAmount;
        uint debt;
        uint claimTime;
        uint toClaim;
    }

    struct Contribute {
        address user;
        uint amount;
    }

    mapping(uint => IslandInfo) public islandInfo;
    mapping(address => mapping(uint => UserIslandStakeInfo)) public userInfo;
    mapping(address => uint[]) public userStakeList;
    mapping(address => mapping(uint => uint)) public stakeIndex;
    mapping(uint => Contribute[]) public contributor;
    mapping(address => mapping(uint => StakeInfo[])) userStake;

    event Stake(address indexed player, uint indexed islandID, uint indexed amount, uint seq);
    event UnStake(address indexed player, uint indexed islandID, uint indexed amount, uint seq);
    event Claim(address indexed player, uint indexed islandID,uint indexed amount,uint seq);

    function initialize() external initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();

        NFT = IERC721(0x1B2FdF787a053794435877bB316a43B6B9A8bc05);
        BLK = IERC20(0x1B442989C8AD504B75EBD0A41D688206A980F523);
        islandToken = IBEP20(0x66B204Ff355A0e863Efa2900560689882Af6E971);
        seq = 1;

        levelData[1] = LevelInfo({
            max:50000 ether,
            earnRate:0,
            contributeRate:0
        });
        levelList.push(1);

        levelData[2] = LevelInfo({
        max:70000 ether,
        earnRate:20,
        contributeRate:10
        });
        levelList.push(2);

        levelData[3] = LevelInfo({
        max:100000 ether,
        earnRate:30,
        contributeRate:15
        });
        levelList.push(3);

        levelData[4] = LevelInfo({
        max:200000 ether,
        earnRate:50,
        contributeRate:30
        });
        levelList.push(4);

        levelData[5] = LevelInfo({
        max:300000 ether,
        earnRate:120,
        contributeRate:70
        });
        levelList.push(5);

        levelData[6] = LevelInfo({
        max:10e7 ether,
        earnRate:150,
        contributeRate:120
        });
        levelList.push(6);
    }

    function updateLevelData(uint lv, uint amount, uint rate1, uint rate2) public onlyOwner {
        require(levelData[lv].max != 0, "wrong lv");
        levelData[lv] = LevelInfo({
            max: amount,
            earnRate: rate1,
            contributeRate: rate2
        });
    }

    function bandId(uint id) external onlyOwner{
        require(!banned[id],"banned id");
        banned[id] = true;
    }

    function checkRate(uint id) public view returns (uint, uint){
        uint amount = islandInfo[id].total;
        for (uint i = 0; i < levelList.length; i++) {
            LevelInfo memory lv = levelData[levelList[i]];
            if (amount <= lv.max) {
                return (lv.earnRate,lv.contributeRate);
            }
        }
        return (0,0);
    }

    function coutingDebt(uint id) public view returns (uint _debt){
        IslandInfo storage info = islandInfo[id];
        (uint rate,) = checkRate(id);
        _debt = info.total > 0 ? rate * (block.timestamp - info.lastTime) * acc / 365000 days + info.debt : 0;
    }

    function calculateReward(address addr, uint id, uint index) public view returns (uint){
        StakeInfo memory info = userStake[addr][id][index];
        return (info.stakeAmount * (coutingDebt(id) - info.debt)) / acc + info.toClaim;
    }

    function getEarningAndLocked(address addr, uint[] memory islandIds) public view returns(uint,uint){
        uint rew;
        uint locked;
        for(uint i = 0; i < islandIds.length; i ++){
            uint islandId = islandIds[i];
            for (uint j = 0; j < userStake[addr][islandId].length; j++) {
                rew += calculateReward(addr, islandId, j);
                locked += userInfo[msg.sender][islandId].locked;
            }
        }
        return (rew, locked);
    }

    function stake(uint id, uint amount) external{
        require(!banned[id], "banned id");
        IslandInfo storage landInfo = islandInfo[id];
        require(landInfo.total + amount <= 10e7 ether,"maximum");

        require(NFT.ownerOf(id) != address(0), 'wrong id');
        if (stakeIndex[msg.sender][id] == 0) {
            stakeIndex[msg.sender][id] = userStakeList[msg.sender].length;
            userStakeList[msg.sender].push(id);
            userInfo[msg.sender][id] = UserIslandStakeInfo({
                total:0,
                locked:0
            });
        }
        BLK.transferFrom(msg.sender, address(this), amount);

        uint debt = coutingDebt(id);
        userStake[msg.sender][id].push(StakeInfo({
            seq:seq,
            stakeTime:block.timestamp,
            stakeAmount:amount,
            debt:debt,
            claimTime:block.timestamp,
            toClaim: 0
        }));

        landInfo.total += amount;
        landInfo.debt = debt;
        landInfo.lastTime = block.timestamp;
        userInfo[msg.sender][id].total += amount;

        emit Stake(msg.sender, id, amount, seq);
        seq += 1;
    }

    function unStake(uint id, uint idx, uint amount) external {
        StakeInfo storage stakeInfo = userStake[msg.sender][id][idx];
        require(userStake[msg.sender][id].length > idx, "bad index");
        require(stakeInfo.stakeAmount >= amount, "out of value");

        if (block.timestamp - stakeInfo.stakeTime >= 14 days) {
            stakeInfo.toClaim = calculateReward(msg.sender, id, idx);
        }

        if (stakeInfo.stakeAmount > amount) {
            stakeInfo.stakeAmount -= amount;
        } else {
            if (idx + 1 < userStake[msg.sender][id].length){
                userStake[msg.sender][id][idx] = userStake[msg.sender][id][userStake[msg.sender][id].length - 1];
            }
            userStake[msg.sender][id].pop();
        }

        BLK.transfer(msg.sender, amount);

        uint debt = coutingDebt(id);
        IslandInfo storage landInfo = islandInfo[id];
        landInfo.total -= amount;
        landInfo.debt = debt;
        landInfo.lastTime = block.timestamp;

        userInfo[msg.sender][id].total -= amount;
        stakeInfo.debt = debt;

        emit UnStake(msg.sender, id, amount, stakeInfo.seq);
    }

    function singleClaim(uint islandId, uint index) external {
        require(userStake[msg.sender][islandId].length > index,"wrong index");
        claim(islandId, index, true);
    }

    function fastClaim(uint[] memory ids) external {
        for (uint i = 0; i < ids.length; i++) {
            uint islandId = ids[i];
            for (uint j = 0; j < userStake[msg.sender][islandId].length; j++){
                claim(islandId, j, false);
            }
        }
    }

    function claim(uint islandId, uint index, bool check) internal {
        StakeInfo storage info = userStake[msg.sender][islandId][index];

        if (check) {
            require(block.timestamp - info.claimTime >= 14 days, "time limit");
        }else if (block.timestamp - info.claimTime < 14 days) {
            return;
        }

        uint reward = calculateReward(msg.sender, islandId, index) ;
        uint amount = reward / 100 * 40;
        if (check) {
            require(amount >= 100 ether, "minimum");
        }else if (amount < 100 ether) {
            return;
        }

        uint locked = reward - amount;
        userInfo[msg.sender][islandId].locked += locked;

        (uint rate1,uint rate2) = checkRate(islandId);
        IslandInfo storage landInfo = islandInfo[islandId];

        uint tribute;
        if (rate1 > 0 ) {
            tribute = amount * rate2 / rate1 / 100 * 40;
            landInfo.contribute += tribute;
        }

        emit Claim(msg.sender, islandId, amount, info.seq);

        amount -= amount / 1000 * 45;
        if (NFT.ownerOf(islandId) == msg.sender) {
            islandToken.mint(msg.sender, amount + tribute);
        } else {
            islandToken.mint(msg.sender, amount);

            if (tribute > 0) {
                if (contributor[islandId].length > 0) {
                    for (uint i = 0; i < contributor[islandId].length; i++){
                        if (contributor[islandId][i].user == msg.sender) {
                            contributor[islandId][i].amount += tribute;
                            break;
                        }
                    }
                } else {
                    contributor[islandId].push(Contribute({
                    user: msg.sender,
                    amount: tribute
                    }));
                }
            }

        info.claimTime = block.timestamp;
        info.toClaim = 0;
    }
}

    function assign(uint id, uint selfPercent) external {
        require(NFT.ownerOf(id) == msg.sender, 'not owner');
        require(selfPercent <= 100, "percentage");
        IslandInfo storage landInfo = islandInfo[id];
        require(landInfo.contribute > 0 && (landInfo.lastAssignTime == 0 || block.timestamp - landInfo.lastAssignTime >= 30 days), "assign cond");

        uint ownerBonus;
        if (selfPercent == 100) {
            ownerBonus = landInfo.contribute;
        } else {
            uint assignBonus = landInfo.contribute / 100 * (100 - selfPercent);
            ownerBonus = landInfo.contribute - assignBonus;
            for (uint i = 0; i < contributor[id].length; i++) {
                islandToken.mint(contributor[id][i].user, contributor[id][i].amount / landInfo.contribute * assignBonus);
            }
        }

        islandToken.mint(msg.sender, ownerBonus);
        landInfo.lastAssignTime = block.timestamp;
        landInfo.contribute = 0;
        delete contributor[id];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
interface IBEP20 {
function decimals() external view returns (uint8);

function name() external view returns (string memory);

function symbol() external view returns (string memory);

function totalSupply() external view returns (uint);

function balanceOf(address account) external view returns (uint);

function transfer(address recipient, uint amount) external returns (bool);

function allowance(address owner, address spender) external view returns (uint);

function approve(address spender, uint amount) external returns (bool);

function transferFrom(address sender, address recipient, uint amount) external returns (bool);

function mint(address addr_, uint amount_) external;

event Transfer(address indexed from, address indexed to, uint value);
event Approval(address indexed owner, address indexed spender, uint value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
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
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}