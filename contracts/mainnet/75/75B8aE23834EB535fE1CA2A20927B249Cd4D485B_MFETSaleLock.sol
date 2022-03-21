/**
 *Submitted for verification at BscScan.com on 2022-03-21
*/

// SPDX-License-Identifier: MIT

// MFET - Multi Functional Environmental Token
// We are Developing New Generation Projects and Funding These Projects with Green Blockchain.

// A Sustainable World
// MFET is an ecosystem that supports sustainable projects, provides mentoring to companies in carbon footprint studies,
// provides consultancy on environmental and climate studies, and makes decisions without being dependent on an authority
// with the community it has created, thanks to the blockchain.

// MFET - Stake Contract

// Mens et Manus
pragma solidity ^0.8.0;

interface IBEP20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
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
     * by making the `nonReentrant` function external, and make it call a
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

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

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

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

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

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

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

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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

library SafeBEP20 {
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeBEP20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            require(
                abi.decode(returndata, (bool)),
                "SafeBEP20: BEP20 operation did not succeed"
            );
        }
    }
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

contract MFETSaleLock is Context, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    //Lock needs
    struct Items {
        address tokenAddress;
        address withdrawalAddress;
        uint256 tokenAmount;
        uint256 unlockTime;
        bool withdrawn;
    }

    uint256 public lockId;
    uint256[] public allLockIds;
    uint256 public mfetMultiplayer = 10000;
    mapping(address => uint256) public totalLockedAmounts;

    mapping(address => uint256[]) public depositsByWithdrawalAddress;
    mapping(uint256 => Items) public lockedToken;
    mapping(address => mapping(address => uint256)) public walletTokenBalance;
    mapping(address => mapping(address => bool)) public specialAddress;
    mapping(address => bool) public tokenClaimStatusList;

    event LogWithdrawal(address SentToAddress, uint256 AmountTransferred);

    // Sale needs
    struct Pair {
        address token0;
        uint256 t0decimal;
        address token1;
        uint256 t1decimal;
        uint256 price;
        uint256 provision;
        address receiver;
        uint256 minCap;
        uint256 maxCap;
        uint256[] lockPercentList;
        uint256[] lockTimestampList;
        bool active;
    }

    mapping(address => bool) public tokenLockStatusList;
    mapping(address => Pair) public tokenPairList;

    // Get address special status
    function getAddressSpecialStatus(address _token, address _addr)
        external
        view
        returns (bool)
    {
        return (specialAddress[_token][_addr]);
    }

    // Set nasadoge to mfet multiplayer
    function setMfetMultiplayer(uint256 _multiplayer) external onlyOwner {
        mfetMultiplayer = _multiplayer;
    }

    // Add single address convert limit to list
    function addSingleAccountToSpecialList(address _token, address _addr)
        external
        onlyOwner
    {
        specialAddress[_token][_addr] = true;
    }

    // Remove single address special
    function removeSingleAccountFromSpecialList(address _token, address _addr)
        external
        onlyOwner
    {
        specialAddress[_token][_addr] = false;
    }

    // Set token claim status
    function setTokenClaimStatus(address _token, bool _status)
        external
        onlyOwner
    {
        tokenClaimStatusList[_token] = _status;
    }

    // Contract Lock status for token via crowedsale active or passive
    function setTokensLockStatus(address _token, bool _lockActive)
        external
        onlyOwner
    {
        tokenLockStatusList[_token] = _lockActive;
    }

    // Setting Pairs for sale and Lock
    function setTokenSalePair(
        address _token0,
        uint8 _token0decimal,
        address _token1,
        uint8 _token1decimal,
        uint256 _price,
        uint256 _provision,
        address _receiver,
        uint256[] memory _lockPercents,
        uint256[] memory _lockTimestamps
    ) external onlyOwner {
        uint256[] memory _lockPercentList = new uint256[](_lockPercents.length);
        uint256[] memory _lockTimestampList = new uint256[](
            _lockTimestamps.length
        );

        // Pair check
        require(tokenPairList[_token1].active == false, "Pair already defined");

        // Set LockPercentList for pair
        require(
            _lockPercents.length == _lockTimestamps.length,
            "MFET : percent list length check error"
        );
        uint256 totalPercent = 0;
        for (uint256 i = 0; i < _lockPercents.length; i++) {
            require(_lockPercents[i] > 0, "MFET : percentage can not be zero");
            totalPercent += _lockPercents[i];
        }
        require(
            totalPercent == 1000,
            "MFET : Total percentage must be equal 1000"
        );

        for (uint256 i = 0; i < _lockPercents.length; i++) {
            _lockPercentList[i] = _lockPercents[i];
        }

        // Set LockTimeStamp List for pair
        for (uint256 i = 0; i < _lockTimestamps.length; i++) {
            require(
                _lockTimestamps[i] > block.timestamp,
                "MFET : unlock timestamp should be higher than current time"
            );
        }

        for (uint256 i = 0; i < _lockTimestamps.length; i++) {
            _lockTimestampList[i] = _lockTimestamps[i];
        }

        tokenPairList[_token1].token0 = _token0;
        tokenPairList[_token1].t0decimal = _token0decimal;
        tokenPairList[_token1].token1 = _token1;
        tokenPairList[_token1].t1decimal = _token1decimal;
        tokenPairList[_token1].price = _price;
        tokenPairList[_token1].provision = _provision;
        tokenPairList[_token1].receiver = _receiver;
        tokenPairList[_token1].lockPercentList = _lockPercentList;
        tokenPairList[_token1].lockTimestampList = _lockTimestampList;
        tokenPairList[_token1].active = true;

        // Set default claim status to false
        tokenClaimStatusList[_token1] = false;

        // Set default lock status to true
        tokenLockStatusList[_token1] = true;
    }

    function deleteTokenPair(address _token) external onlyOwner {
        delete tokenPairList[_token];
    }

    function getTokenPairDetails(address _token)
        external
        view
        returns (Pair memory)
    {
        return _getTokenPair(_token);
    }

    function _getTokenPair(address _token) internal view returns (Pair memory) {
        return tokenPairList[_token];
    }

    // Get sale pair key
    function _getSalePairKey(Pair memory _pair)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_pair.token0, _pair.token1));
    }

    // Here Get Liquidity function for call inside
    function _getLiquidity(address _token) internal view returns (uint256) {
        return IBEP20(_token).balanceOf(address(this));
    }

    // Internal total locked token show
    function _calculateTotalTokenLocked(address _token)
        internal
        view
        returns (uint256)
    {
        return totalLockedAmounts[_token];
    }

    // Multiple lock internal function
    function _createMultipleLocks(
        address _tokenAddress,
        address _withdrawalAddress,
        uint256[] memory _amounts,
        uint256[] memory _unlockTimes
    ) internal returns (uint256 _id) {
        require(
            _amounts.length > 0,
            "MFET : amounts array length cannot be zero"
        );
        require(
            _amounts.length == _unlockTimes.length,
            "MFET : amounts array length and unlock timestamp array length must same"
        );

        uint256 i;
        for (i = 0; i < _amounts.length; i++) {
            require(_amounts[i] > 0, "MFET : amount cannot be zero");
            require(
                _unlockTimes[i] < 10000000000,
                "MFET : timestamp must be smaller then 10000000000"
            );

            //update balance in address
            walletTokenBalance[_tokenAddress][
                _withdrawalAddress
            ] = walletTokenBalance[_tokenAddress][_withdrawalAddress].add(
                _amounts[i]
            );

            totalLockedAmounts[_tokenAddress] = totalLockedAmounts[
                _tokenAddress
            ].add(_amounts[i]);

            _id = ++lockId;
            lockedToken[_id].tokenAddress = _tokenAddress;
            lockedToken[_id].withdrawalAddress = _withdrawalAddress;
            lockedToken[_id].tokenAmount = _amounts[i];
            lockedToken[_id].unlockTime = _unlockTimes[i];
            lockedToken[_id].withdrawn = false;

            allLockIds.push(_id);
            depositsByWithdrawalAddress[_withdrawalAddress].push(_id);
        }
    }

    // Calculate time for tokens
    function _calculateSendAmount(uint256 _amount, Pair memory _pair)
        internal
        pure
        returns (uint256, uint256[] memory)
    {
        require(
            _amount >= _pair.price,
            "MFET : given amount should be higher than unit price"
        );

        uint256[] memory lockAmounts = new uint256[](
            _pair.lockPercentList.length
        );

        uint256 dustAmount = _amount.mod(_pair.price); // Dust amount calculation0
        uint256 allowAmount = _amount.sub(dustAmount); // Accept amount for sell
        uint256 ratio = allowAmount.div(_pair.price); // Sell ratio
        uint256 allTransferSize = _pair.provision.mul(ratio); // Transfer before lock applied

        // Calculate tokens convert lockpercent
        for (uint256 i = 0; i < _pair.lockPercentList.length; i++) {
            uint256 lockPercent = _pair.lockPercentList[i];
            uint256 lockAmount = allTransferSize.div(1000).mul(lockPercent);
            lockAmounts[i] = lockAmount;
        }

        require(
            lockAmounts.length > 0,
            "MFET : lock amounts calculation failed"
        );

        return (allTransferSize, lockAmounts);
    }

    // Check for convert
    function _beforeConvert(uint256 _amount, Pair memory _pair)
        internal
        view
        returns (bool)
    {
        require(_pair.active == true, "MFET : pair is not active");
        require(
            _pair.receiver != address(0),
            "MFET : receiver is zero address"
        );
        require(
            _pair.token1 != address(0),
            "MFET : sale contract is not defined"
        );

        // Check signer allowance for sale
        uint256 signerAllowance = IBEP20(_pair.token0).allowance(
            _msgSender(),
            address(this)
        );

        require(
            signerAllowance >= _amount,
            "MFET : signer allowance required for pair.token0"
        );

        return true;
    }

    // Buy some tokens and lock them all
    function convert(uint256 _amount, address _token) external nonReentrant {
        Pair memory _pair = _getTokenPair(_token);
        require(
            _beforeConvert(_amount, _pair) == true,
            "MFET : convert is not allowed currently"
        );

        // Calculate allowed amount, transfer size & dust amount for refund
        (
            uint256 _allTransferSize,
            uint256[] memory _lockAmounts
        ) = _calculateSendAmount(_amount, _pair);

        // Send token0 to current contract
        IBEP20(_pair.token0).safeTransferFrom(
            _msgSender(),
            address(this),
            _amount
        );

        if (tokenLockStatusList[_pair.token1]) {
            // Create locks in contract for future
            uint256 lockSuccess = _createMultipleLocks(
                _pair.token1,
                _msgSender(),
                _lockAmounts,
                _pair.lockTimestampList
            );

            require(lockSuccess > 0, "MFET : lock call is failed");
        } else {
            // Send token1 to caller

            IBEP20(_pair.token1).safeTransfer(_msgSender(), _allTransferSize);
        }
    }

    // Add some token to contract for sale and lock
    function addLiquidity(uint256 _amount, address _token) external onlyOwner {
        uint256 allowance = IBEP20(_token).allowance(
            _msgSender(),
            address(this)
        );
        require(allowance >= _amount, "MFET : allowance is not enough");

        IBEP20(_token).safeTransferFrom(_msgSender(), address(this), _amount);
    }

    // Owner Calls Remove Liquidity from contract
    function removeLiquidity(
        address _to,
        uint256 _amount,
        address _token
    ) external onlyOwner {
        require(_to != address(0), "MFET : to address is zero address");
        require(
            _getLiquidity(_token) >= _amount,
            "MFET : insufficient liquidity"
        );

        require(
            _calculateTotalTokenLocked(_token) <=
                _getLiquidity(_token) - _amount,
            "MFET : there are locked tokens you can not remove locked tokens"
        );
        IBEP20(_token).safeTransfer(_to, _amount);
    }

    // Ready for withdraw tokens from contract
    function withdrawTokens(uint256 _id) external nonReentrant {
        require(
            !specialAddress[lockedToken[_id].tokenAddress][_msgSender()],
            "MFET: wallet error"
        );
        require(
            tokenClaimStatusList[lockedToken[_id].tokenAddress] == true,
            "MFET : token claim status is not ready"
        );
        require(
            _msgSender() == lockedToken[_id].withdrawalAddress,
            "MFET : this is not your token"
        );
        require(!lockedToken[_id].withdrawn, "MFET : amount already withdrawn");

        lockedToken[_id].withdrawn = true;

        // Update balance in address
        walletTokenBalance[lockedToken[_id].tokenAddress][
            _msgSender()
        ] = walletTokenBalance[lockedToken[_id].tokenAddress][_msgSender()].sub(
            lockedToken[_id].tokenAmount
        );

        // Amount remove from totalLockList
        totalLockedAmounts[lockedToken[_id].tokenAddress] = totalLockedAmounts[
            lockedToken[_id].tokenAddress
        ].sub(lockedToken[_id].tokenAmount);

        // Everything is ok now, transfer tokens to wallet address
        require(
            IBEP20(lockedToken[_id].tokenAddress).transfer(
                _msgSender(),
                (lockedToken[_id].tokenAmount * mfetMultiplayer) / 10000
            ),
            "MFET : error while transfer tokens"
        );

        emit LogWithdrawal(_msgSender(), lockedToken[_id].tokenAmount);
    }

    // Get total token balance in contract of given token address
    function getContractTotalTokenBalance(address _tokenAddress)
        external
        view
        returns (uint256)
    {
        return IBEP20(_tokenAddress).balanceOf(address(this));
    }

    // Get total token balance of wallets given token address
    function getTokenBalanceByAddress(
        address _tokenAddress,
        address _walletAddress
    ) external view returns (uint256) {
        return walletTokenBalance[_tokenAddress][_walletAddress];
    }

    // Get All Lock Ids
    function getAllLockIds() external view returns (uint256[] memory) {
        return allLockIds;
    }

    // Get Lock Details
    function getLockDetails(uint256 _id)
        external
        view
        returns (
            address _tokenAddress,
            address _withdrawalAddress,
            uint256 _tokenAmount,
            uint256 _unlockTime,
            bool _withdrawn
        )
    {
        return (
            lockedToken[_id].tokenAddress,
            lockedToken[_id].withdrawalAddress,
            lockedToken[_id].tokenAmount,
            lockedToken[_id].unlockTime,
            lockedToken[_id].withdrawn
        );
    }

    // Get Deposits By Withdrawal Address
    function getDepositsByWithdrawalAddress(address _withdrawalAddress)
        external
        view
        returns (uint256[] memory)
    {
        return depositsByWithdrawalAddress[_withdrawalAddress];
    }

    // Creating Multiple Locks for token in contract
    function createMultipleLocks(
        address _tokenAddress,
        address _withdrawalAddress,
        uint256[] memory _amounts,
        uint256[] memory _unlockTimes
    ) external nonReentrant returns (uint256 _id) {
        return
            _createMultipleLocks(
                _tokenAddress,
                _withdrawalAddress,
                _amounts,
                _unlockTimes
            );
    }
}
// Made with love.