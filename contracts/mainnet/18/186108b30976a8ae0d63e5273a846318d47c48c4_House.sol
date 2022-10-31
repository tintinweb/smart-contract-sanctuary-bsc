/**
 *Submitted for verification at BscScan.com on 2022-10-31
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    mapping(address => bool) public addressAdmin;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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

    function addAdmin(address _address) external onlyOwner {
        addressAdmin[_address] = true;
    }

    modifier admin() {
        require(addressAdmin[msg.sender] == true, "You are not an admin");
        _;
    }

    function removeAdmin(address _address) external onlyOwner {
        addressAdmin[_address] = false;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(
            owner() == _msgSender() || addressAdmin[msg.sender] == true,
            "Ownable: caller do not has auth"
        );
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
        }
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

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

interface IDicewar {
    function balanceOfToken(address _userAddr) external returns (uint256);

    function burn(address _userAddr, uint256 amount) external;

    function mint(address to, uint256 amount) external;
}

interface IDiceWarNft {
    function upgradeMint(address _addr, uint8 level) external;

    function burn(
        address _userAddr,
        uint8 tokenId,
        uint256 amount
    ) external;

    function balanceOfNft(address account, uint256 id)
        external
        returns (uint256);

    function getLvList(uint8 tokenId)
        external
        returns (address[] memory _addresses);

    function nftStakingRewards(address userAddr) external returns (uint256);

    function claimAll(address userAddr) external returns (bool);

    function unstakeAllToken(address userAddr) external returns (bool);
}

contract House is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    bool public houseLive = true;
    uint256 public lockedInBets;
    uint256 public lockedInRewards;
    uint256 public projectRewards;
    uint256 public jackpot;
    uint256 public nftHoldersRewardsToDistribute;
    uint256 public balanceMaxProfitRatio = 1;
    uint256 public lv1Weight = 10;
    uint256 public lv2Weight = 20;
    uint256 public lv3Weight = 40;
    uint256 public lv4Weight = 80;
    uint256 public houseEdgeBP = 400;
    uint256 public userSum = 0;
    uint256 public lev1Token = 1000000000000000000000;
    uint256 public lev2Token = 10000000000000000000000;
    uint256 public lev3Token = 100000000000000000000000;
    uint256 public nftHoldersRewardsBP = 200;
    uint256 public projectRewardsBP = 80;
    uint256 public jackpotBP = 20;
    uint256 public refBP = 80;
    uint256 public allBetAmount;
    IDiceWarNft dicewarNft;
    IDicewar dicewar;
    address public diceWarAddress;
    address public DiceWarNFTAddress;

    mapping(address => uint256) public playerBalance;

    // Events
    event Donation(address indexed player, uint256 amount);
    event HousePlaceBet(address player, uint256 amount);
    event BalanceClaimed(address indexed player, uint256 amount);
    event RefRewardsClaimed(address indexed player, uint256 amount);
    event RewardsDistributed(uint256 nPlayers, uint256 amount);
    event upgradeNftE(address userAddress, uint8 levelBefore);

    fallback() external payable {
        emit Donation(msg.sender, msg.value);
    }

    receive() external payable {
        emit Donation(msg.sender, msg.value);
    }

    modifier isHouseLive() {
        require(houseLive == true, "House not live");
        _;
    }

    // Getter
    function balance() public view returns (uint256) {
        return address(this).balance;
    }

    function dicewarBalance() public view returns (uint256) {
        return IERC20(diceWarAddress).balanceOf(address(this));
    }

    // Setter
    /**
     *Update upgrade's token amount
     */
    function addLockedInRewards(uint256 _amount) external onlyOwner {
        lockedInRewards += _amount;
    }

    function addProjectRewards(uint256 _amount) external onlyOwner {
        projectRewards += _amount;
    }

    function addJackPot(uint256 _amount) external onlyOwner {
        jackpot += _amount;
    }

    function addNftHoldersRewardsToDistribute(uint256 _amount)
        external
        onlyOwner
    {
        nftHoldersRewardsToDistribute += _amount;
    }

    function updateUpgradeToken(uint256[] memory _data) external onlyOwner {
        lev1Token = _data[0];
        lev2Token = _data[1];
        lev3Token = _data[2];
    }

    function initializeWeight(
        uint256 _lv1Weight,
        uint256 _lv2Weight,
        uint256 _lv3Weight,
        uint256 _lv4Weight
    ) external onlyOwner {
        lv1Weight = _lv1Weight;
        lv2Weight = _lv2Weight;
        lv3Weight = _lv3Weight;
        lv4Weight = _lv4Weight;
    }

    function initializeDiceWar(address _address) external onlyOwner {
        dicewar = IDicewar(_address);
        diceWarAddress = _address;
    }

    function initializeDiceWarNft(address _address) external onlyOwner {
        dicewarNft = IDiceWarNft(_address);
        DiceWarNFTAddress = _address;
    }

    function toggleHouseLive() external onlyOwner {
        houseLive = !houseLive;
    }

    function setBalanceMaxProfitRatio(uint256 _balanceMaxProfitRatio)
        external
        onlyOwner
    {
        balanceMaxProfitRatio = _balanceMaxProfitRatio;
    }

    function setHouseEdgeBP(uint256 _houseEdgeBP) external onlyOwner {
        require(houseLive == false, "Bets in pending");
        houseEdgeBP = _houseEdgeBP;
    }

    function getHouseEdgeBP() external view returns (uint256) {
        return houseEdgeBP;
    }

    function setNftHoldersRewardsBP(uint256 _nftHoldersRewardsBP)
        external
        onlyOwner
    {
        nftHoldersRewardsBP = _nftHoldersRewardsBP;
    }

    function setprojectRewardsBP(uint256 _projectRewardsBP) external onlyOwner {
        projectRewardsBP = _projectRewardsBP;
    }

    function setjackpotBP(uint256 _jackpotBP) external onlyOwner {
        jackpotBP = _jackpotBP;
    }

    function setrefBP(uint256 _refBP) external onlyOwner {
        refBP = _refBP;
    }

    // Converters
    function amountToWinnableAmount(
        uint256 _amount,
        uint256 rollUnder,
        uint256 MODULO
    ) public view returns (uint256) {
        require(
            0 < rollUnder && rollUnder <= MODULO,
            "Win probability out of range"
        );
        uint256 bettableAmount = this.amountToBettableAmountConverter(_amount);
        return (bettableAmount * MODULO) / rollUnder;
    }

    function amountToBettableAmountConverter(uint256 amount)
        public
        view
        returns (uint256)
    {
        return (amount * 10000) / (houseEdgeBP + 10000);
    }

    function amountToNftHoldersRewardsConverter(uint256 _amount)
        internal
        view
        returns (uint256)
    {
        return (_amount * nftHoldersRewardsBP) / houseEdgeBP;
    }

    function amountToProjectRewardsConverter(uint256 _amount)
        internal
        view
        returns (uint256)
    {
        return (_amount * projectRewardsBP) / houseEdgeBP;
    }

    function amountToJackPotConverter(uint256 _amount)
        internal
        view
        returns (uint256)
    {
        return (_amount * jackpotBP) / houseEdgeBP;
    }

    function amountToRefConverter(uint256 _amount)
        internal
        view
        returns (uint256)
    {
        return (_amount * refBP) / houseEdgeBP;
    }

    // Methods

    // Game methods
    function balanceAvailableForBet() public view returns (uint256) {
        return balance() - lockedInBets - lockedInRewards;
    }

    function maxProfit() public view returns (uint256) {
        return balanceAvailableForBet() / balanceMaxProfitRatio;
    }

    function placeBet(
        address player,
        uint256 amount,
        uint256 rollUnder,
        uint256 MODULO,
        address refAddr
    ) external payable isHouseLive admin nonReentrant {
        if (this.isNew(player)) {
            register(player, refAddr);
        }
        uint256 bettableAmount = amountToBettableAmountConverter(amount);
        uint256 profitAmount = amount - bettableAmount;
        uint256[] memory amountArray = new uint256[](6);
        amountArray[0] = amountToNftHoldersRewardsConverter(profitAmount);
        amountArray[1] = amountToProjectRewardsConverter(profitAmount);
        amountArray[2] = amountToJackPotConverter(profitAmount);
        amountArray[3] = amountToWinnableAmount(amount, rollUnder, MODULO);
        amountArray[4] = amountToRefConverter(profitAmount);
        require(amountArray[3] <= maxProfit(), "MaxProfit violation");
        uint256 dicewarRewards = bettableAmount;
        require(
            dicewarRewards <= dicewarBalance(),
            "Not enough dicewar tokens"
        );
        allBetAmount += bettableAmount;
        lockedInBets += amountArray[3];
        nftHoldersRewardsToDistribute += amountArray[0];
        lockedInRewards += amountArray[0] + amountArray[1] + amountArray[2];
        projectRewards += amountArray[1];
        jackpot += amountArray[2];
        IERC20(diceWarAddress).safeTransfer(player, dicewarRewards);
        if (user[player].refAddr != address(0)) {
            user[user[player].refAddr].refProfit += amountArray[4];
            user[user[player].refAddr].totallRefProfit += amountArray[4];
        } else {
            projectRewards += amountArray[4];
        }
        user[player].dicewarToken += dicewarRewards;
        user[player].betAmountSum += bettableAmount;
        user[player].betCounter += 1;
        emit HousePlaceBet(player, amount);
    }

    function settleBet(
        address player,
        uint256 winnableAmount,
        bool win
    ) external isHouseLive admin nonReentrant {
        lockedInBets -= winnableAmount;
        if (win == true) {
            payable(player).transfer(winnableAmount);
        }
    }

    function payPlayer(address player, uint256 amount)
        external
        isHouseLive
        admin
        nonReentrant
    {
        require(amount <= maxProfit(), "MaxProfit violation");
        payable(player).transfer(amount);
    }

    function senddicewarTokens(address player, uint256 amount)
        external
        isHouseLive
        admin
        nonReentrant
    {
        require(amount <= dicewarBalance(), "Not enough dicewar tokens");
        IERC20(diceWarAddress).safeTransfer(player, amount);
    }

    function refundBet(
        address player,
        uint256 amount,
        uint256 winnableAmount
    ) external isHouseLive admin nonReentrant {
        lockedInBets -= winnableAmount;
        payable(player).transfer(amount);
    }

    function claimBalance(address player) external isHouseLive nonReentrant {
        require(player == msg.sender, "Can only withdraw your own NFT rewards");
        uint256 gBalance = playerBalance[player];
        require(gBalance > 0, "No funds to claim");
        payable(player).transfer(gBalance);
        playerBalance[player] = 0;
        lockedInRewards -= gBalance;
        emit BalanceClaimed(player, gBalance);
    }

    function claimRefRewards(address player) external isHouseLive nonReentrant {
        require(
            player == msg.sender,
            "Can only withdraw your own referral rewards"
        );
        uint256 gBalance = user[player].refProfit;
        require(gBalance > 0, "No funds to claim");
        payable(player).transfer(gBalance);
        user[player].refProfit = 0;
        emit RefRewardsClaimed(player, gBalance);
    }

    function claimProjectRewards() external isHouseLive nonReentrant onlyOwner {
        require(projectRewards > 0, "No funds to claim");
        payable(msg.sender).transfer(projectRewards);
        lockedInRewards -= projectRewards;
        projectRewards = 0;
        emit BalanceClaimed(msg.sender, projectRewards);
    }

    function claimJackPot() external isHouseLive nonReentrant onlyOwner {
        require(jackpot > 0, "No funds to claim");
        payable(msg.sender).transfer(jackpot);
        lockedInRewards -= jackpot;
        jackpot = 0;
        emit BalanceClaimed(msg.sender, jackpot);
    }

    function distributeNftHoldersRewards() external onlyOwner {
        require(nftHoldersRewardsToDistribute > 0, "No rewards to distribute");
        address[] memory lv1Addr = dicewarNft.getLvList(1);
        address[] memory lv2Addr = dicewarNft.getLvList(2);
        address[] memory lv3Addr = dicewarNft.getLvList(3);
        address[] memory lv4Addr = dicewarNft.getLvList(4);
        uint256 sumAddr = lv1Addr.length +
            lv2Addr.length +
            lv3Addr.length +
            lv4Addr.length;
        uint256 sumWeight = lv1Weight *
            lv1Addr.length +
            lv2Weight *
            lv2Addr.length +
            lv3Weight *
            lv3Addr.length +
            lv4Weight *
            lv4Addr.length;
        uint256 sigLv1Reward = (nftHoldersRewardsToDistribute * lv1Weight) /
            sumWeight;
        uint256 sigLv2Reward = (nftHoldersRewardsToDistribute * lv2Weight) /
            sumWeight;
        uint256 sigLv3Reward = (nftHoldersRewardsToDistribute * lv3Weight) /
            sumWeight;
        uint256 sigLv4Reward = (nftHoldersRewardsToDistribute * lv4Weight) /
            sumWeight;
        for (uint256 i = 0; i < lv1Addr.length; i++) {
            if (lv1Addr[i] != address(0)) {
                playerBalance[lv1Addr[i]] += sigLv1Reward;
            }
        }
        for (uint256 i = 0; i < lv2Addr.length; i++) {
            if (lv1Addr[i] != address(0)) {
                playerBalance[lv2Addr[i]] += sigLv2Reward;
            }
        }
        for (uint256 i = 0; i < lv3Addr.length; i++) {
            if (lv1Addr[i] != address(0)) {
                playerBalance[lv3Addr[i]] += sigLv3Reward;
            }
        }
        for (uint256 i = 0; i < lv4Addr.length; i++) {
            if (lv1Addr[i] != address(0)) {
                playerBalance[lv4Addr[i]] += sigLv4Reward;
            }
        }
        lockedInRewards -= nftHoldersRewardsToDistribute;
        emit RewardsDistributed(sumAddr, nftHoldersRewardsToDistribute);
        nftHoldersRewardsToDistribute = 0;
    }

    function withdrawFunds(address payable beneficiary, uint256 withdrawAmount)
        external
        onlyOwner
    {
        require(withdrawAmount <= this.balance(), "Withdrawal exceeds limit");
        beneficiary.transfer(withdrawAmount);
    }

    function withdrawdicewarFunds(address beneficiary, uint256 withdrawAmount)
        external
        onlyOwner
    {
        require(
            withdrawAmount <= dicewarBalance(),
            "dicewar token withdrawal exceeds limit"
        );
        IERC20(diceWarAddress).safeTransfer(beneficiary, withdrawAmount);
    }

    function withdrawCustomTokenFunds(
        address beneficiary,
        uint256 withdrawAmount,
        address token
    ) external onlyOwner {
        require(
            withdrawAmount <= IERC20(token).balanceOf(address(this)),
            "Withdrawal exceeds limit"
        );
        IERC20(token).safeTransfer(beneficiary, withdrawAmount);
    }

    /**
     *Upgrade user's NFT
     */
    function upgradeNft(uint8 level) external nonReentrant {
        require(
            level == 1 || level == 2 || level == 3,
            "Can not upgrade this level"
        );
        require(
            dicewarNft.balanceOfNft(msg.sender, level) >= 1,
            "You do not have NFT to upgrade"
        );
        if (level == 1) {
            require(dicewar.balanceOfToken(msg.sender) >= lev1Token);
            dicewar.burn(msg.sender, lev1Token);
        }
        if (level == 2) {
            require(dicewar.balanceOfToken(msg.sender) >= lev2Token);
            dicewar.burn(msg.sender, lev2Token);
        }
        if (level == 3) {
            require(dicewar.balanceOfToken(msg.sender) >= lev3Token);
            dicewar.burn(msg.sender, lev3Token);
        }
        dicewarNft.burn(msg.sender, level, 1);
        dicewarNft.upgradeMint(msg.sender, level);
        emit upgradeNftE(msg.sender, level);
    }

    struct userDetail {
        uint256 id;
        address addr;
        address refAddr;
        uint256 refProfit;
        uint256 dicewarToken;
        uint256 betAmountSum;
        uint256 betCounter;
        uint256 totallRefProfit;
    }
    mapping(address => userDetail) public user;
    event UserRegister(address addr, address refAddr, uint256 userId);

    function isNew(address _addr) external view returns (bool) {
        if (user[_addr].id == 0 || user[_addr].refAddr == address(0)) {
            return true;
        } else {
            return false;
        }
    }

    function register(address _addr, address _refAddr) internal returns (bool) {
        require(
            user[_addr].id == 0 || user[_addr].refAddr == address(0),
            "You have registered before"
        );
        _refAddr = _addr == _refAddr ? address(0) : _refAddr;
        if (user[_addr].id == 0) {
            user[_addr] = userDetail(
                userSum + 1,
                _addr,
                _refAddr,
                0,
                0,
                0,
                0,
                0
            );
            userSum++;
            emit UserRegister(_addr, _refAddr, userSum + 1);
        } else {
            user[msg.sender].refAddr = _refAddr;
        }
        return true;
    }

    function updateRef(address _refAddr) external nonReentrant returns (bool) {
        require(user[msg.sender].id != 0, "You need registered first");
        require(
            user[msg.sender].refAddr == address(0),
            "Refferal Address can not be updated if exist"
        );
        user[msg.sender].refAddr = _refAddr;
        return true;
    }

    event stakingRewardsClaim(address userAddress, uint256 amount);

    function claimNftStakingRewards() public nonReentrant returns (bool) {
        uint256 rewardAmount = dicewarNft.nftStakingRewards(msg.sender);
        require(rewardAmount > 0, "No amount can be claimed");
        require(
            dicewarNft.unstakeAllToken(msg.sender),
            "unstake all token error"
        );
        require(dicewarNft.claimAll(msg.sender), "claim all token error");
        IERC20(diceWarAddress).safeTransfer(msg.sender, rewardAmount);
        emit stakingRewardsClaim(msg.sender, rewardAmount);
        return true;
    }

    function batchTransferDwt(address[] memory _address, uint256 _amount)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < _address.length; i++) {
            dicewar.mint(_address[i], _amount);
        }
    }
}