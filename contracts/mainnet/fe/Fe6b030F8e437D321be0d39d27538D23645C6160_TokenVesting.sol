/**
 *Submitted for verification at BscScan.com on 2022-04-26
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
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

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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

// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

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

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

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

pragma solidity ^0.8.0;

library Math {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

pragma solidity ^0.8.0;

library SafeMath {
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

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

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

pragma solidity ^0.8.4;

contract TokenVesting is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event deposited(address from, uint256 amount);
    event payed(address to, uint256 amount);

    struct vestingCard {
        uint256 id;
        uint256 totalAmount;
        uint256 payed;
        uint256 totalAmountFirst;
        bool changed;
    }

    mapping(address => mapping(uint256 => vestingCard)) private idToVestingCard;
    mapping(address => uint256) userVestingCardAmount;
    mapping(uint256 => address) idToAddress;

    uint256 private counter;

    mapping(uint256 => uint256) private currentTime;
    mapping(uint256 => uint256) private startTime;

    mapping(uint256 => uint256) private unlockedPart;
    uint256 private tokenProportion;
    bool private stVest = false;

    IERC20 private immutable _token;
    IERC20 private immutable _rewardToken;

    constructor(
        address token_,
        address rewardToken_,
        uint256 proportion_
    ) {
        require(token_ != address(0x0) && rewardToken_ != address(0x0));
        _token = IERC20(token_);
        _rewardToken = IERC20(rewardToken_);
        setProportion(proportion_);
    }

    modifier vestingStarted(uint256 userId) {
        require(startTime[userId] > 0, "Vesting not started yet");
        _;
    }

    modifier vestingNotStarted(uint256 userId) {
        require(startTime[userId] == 0, "Vesting started already");
        _;
    }

    function maxStartVesting() internal view returns (uint256) {
        uint256 max = 0;
        for (uint256 i = 1; i <= counter; i++) {
            if (startTime[i] > max) {
                max = startTime[i];
            }
        }
        return max;
    }

    modifier unlockedPartUpgrade(uint256 userCard) {
        if (getCurrentTime() > currentTime[userCard]) {
            uint256 full = (getCurrentTime() - currentTime[userCard]) /
                30 days;
            currentTime[userCard] += full * 30 days; //!!!
            for (uint256 i = 0; i < full; i++) {
                if (unlockedPart[userCard] != 100) {
                    unlockedPart[userCard] += 15;
                } else {
                    startTime[userCard] = 0; // !!!!!!!!!!!!!!!!!!!!!!!!!!!
                }
            }
        }
        _;
    }

    function startVesting() external onlyOwner {
        for (uint256 i = 1; i <= counter; i++) {
            startTime[i] = getCurrentTime();
            currentTime[i] = startTime[i];
        }
        stVest = true;
    }

    function isUserExists(address key) public view returns (bool) {
        if (getUserCardAmount(key) > 0) {
            return true;
        } else {
            return false;
        }
    }

    function sumReserved() public view returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i <= counter; i++) {
            if (
                (idToVestingCard[idToAddress[i]][i].totalAmount !=
                    idToVestingCard[idToAddress[i]][i].totalAmountFirst) &&
                (idToVestingCard[idToAddress[i]][i].changed == true)
            ) {
                sum += idToVestingCard[idToAddress[i]][i].totalAmountFirst;
                sum -= idToVestingCard[idToAddress[i]][i].payed;
            } else {
                sum += idToVestingCard[idToAddress[i]][i].totalAmount;
                sum -= idToVestingCard[idToAddress[i]][i].payed;
            }
        }
        return sum;
    }

    function getBalance() external view returns (uint256) {
        return (_rewardToken.balanceOf(address(this)));
    }

    function deposit(uint256 amount)
        external
        vestingNotStarted(userVestingCardAmount[msg.sender])
    {
        require((amount * tokenProportion) / 10**10 > 0);
        require(
            _rewardToken.balanceOf(address(this)) >=
                ((sumReserved() + amount * tokenProportion) / 10**10)
        );
        require(amount >= 10**10 / tokenProportion);
        _token.transferFrom(msg.sender, address(this), amount);

        if (isUserExists(msg.sender)) {
            uint256 percent = ((amount * tokenProportion) / 100) * 10;

            idToVestingCard[msg.sender][userVestingCardAmount[msg.sender]]
                .payed += percent;

            _rewardToken.approve(msg.sender, percent / 10**10);
            _rewardToken.transfer(msg.sender, percent / (10**10));
            emit payed(msg.sender, percent / (10**10));

            if (
                (idToVestingCard[msg.sender][userVestingCardAmount[msg.sender]]
                    .totalAmount !=
                    idToVestingCard[msg.sender][
                        userVestingCardAmount[msg.sender]
                    ].totalAmountFirst) &&
                (idToVestingCard[msg.sender][userVestingCardAmount[msg.sender]]
                    .changed == true)
            ) {
                idToVestingCard[msg.sender][userVestingCardAmount[msg.sender]]
                    .totalAmountFirst += amount * tokenProportion; // меняет значение ферст и из-за этого меняется все
            } else {
                idToVestingCard[msg.sender][userVestingCardAmount[msg.sender]]
                    .totalAmount += amount * tokenProportion;
            }
        } else {
            counter++;
            userVestingCardAmount[msg.sender] = counter;

            idToVestingCard[msg.sender][
                userVestingCardAmount[msg.sender]
            ] = vestingCard(
                userVestingCardAmount[msg.sender],
                amount * tokenProportion,
                0,
                amount * tokenProportion,
                false
            );
            idToAddress[counter] = msg.sender;
            startTime[counter] = 0;

            firstPercent(msg.sender, userVestingCardAmount[msg.sender]);
        }

        emit deposited(msg.sender, amount);
    }

    function firstPercent(address user, uint256 cardId) internal {
        uint256 amount = (idToVestingCard[user][cardId].totalAmount / 100) * 10;
        uint256 value = amount - idToVestingCard[user][cardId].payed;
        idToVestingCard[msg.sender][cardId].payed += value;
        unlockedPart[cardId] += 10;
        _rewardToken.approve(msg.sender, amount / 10**10);
        _rewardToken.transfer(msg.sender, amount / (10**10));
        emit payed(msg.sender, amount / (10**10));
    }

    function release(uint256 cardId)
        external
        vestingStarted(cardId)
        unlockedPartUpgrade(cardId)
    {
        require(
            cardId <= getUserCardAmount(msg.sender),
            "This id does not exist!"
        );
        require(userVestingCardAmount[msg.sender] == cardId);

        uint256 amount = calculateReward(msg.sender, cardId);
        idToVestingCard[msg.sender][cardId].payed += amount;
        _rewardToken.transfer(msg.sender, amount / (10**10));
        emit payed(msg.sender, amount / (10**10));
    }

    function calculateReward(address user, uint256 cardId)
        internal
        view
        returns (uint256)
    {
        uint256 amount;
        if (
            (idToVestingCard[user][cardId].totalAmount !=
                idToVestingCard[user][cardId].totalAmountFirst) &&
            (idToVestingCard[user][cardId].changed == true)
        ) {
            amount =
                (idToVestingCard[user][cardId].totalAmountFirst / 100) *
                unlockedPart[cardId];
        } else {
            amount =
                (idToVestingCard[user][cardId].totalAmount / 100) *
                unlockedPart[cardId];
        }

        uint256 value = amount - idToVestingCard[user][cardId].payed;

        return value;
    }

    function checkReward(address user, uint256 cardId)
        public
        view
        returns (uint256)
    {
        uint256 perc = alreadyUnlocked();
        uint256 amount;
        if (
            (idToVestingCard[user][cardId].totalAmount !=
                idToVestingCard[user][cardId].totalAmountFirst) &&
            (idToVestingCard[user][cardId].changed == true)
        ) {
            amount =
                (idToVestingCard[user][cardId].totalAmountFirst / 100) *
                perc;
        } else {
            amount = (idToVestingCard[user][cardId].totalAmount / 100) * perc;
        }

        if (unlockedPart[cardId] == 100) {
            if (amount == idToVestingCard[user][cardId].payed) {
                return 0;
            } else {
                return (amount - ((amount * 10) / 100)) / 10**10;
            }
        } else {
            return (amount - idToVestingCard[user][cardId].payed) / 10**10;
        }
    }

    function withdrawMainToken(address to, uint256 amount) external onlyOwner {
        require(
            _token.balanceOf(address(this)) >= amount,
            "Not enough tokens on balance"
        );
        _token.transfer(to, amount);
    }

    function withdrawRewardToken(address to, uint256 amount)
        external
        onlyOwner
    {
        require(
            _rewardToken.balanceOf(address(this)) >= amount,
            "Not enough tokens on balance"
        );
        _rewardToken.transfer(to, amount);
    }

    function setProportion(uint256 proportion_) public onlyOwner {
        if (tokenProportion > 0) {
            for (uint256 i = 0; i <= counter; i++) {
                idToVestingCard[idToAddress[i]][i].totalAmount =
                    (idToVestingCard[idToAddress[i]][i].totalAmount /
                        tokenProportion) *
                    proportion_;
                idToVestingCard[idToAddress[i]][i].changed = true;
            }
        }

        tokenProportion = proportion_;
    }

    function getToken() external view returns (address) {
        return address(_token);
    }

    function getRewardToken() external view returns (address) {
        return address(_rewardToken);
    }

    function getInformation(address user, uint256 cardId)
        external
        view
        returns (uint256, uint256)
    {
        if (
            (idToVestingCard[user][cardId].totalAmountFirst !=
                idToVestingCard[user][cardId].totalAmount) &&
            (idToVestingCard[user][cardId].changed == true)
        ) {
            return (
                idToVestingCard[user][cardId].totalAmountFirst / 10**10,
                (idToVestingCard[user][cardId].totalAmountFirst -
                    idToVestingCard[user][cardId].payed) / 10**10
            );
        } else {
            return (
                idToVestingCard[user][cardId].totalAmount / 10**10,
                (idToVestingCard[user][cardId].totalAmount -
                    idToVestingCard[user][cardId].payed) / 10**10
            );
        }
    }

    function getUserCardAmount(address user) public view returns (uint256) {
        return userVestingCardAmount[user];
    }

    function getTotalCards() external view returns (uint256) {
        return counter;
    }

    function getStartTime() public view returns (uint256) {
        return maxStartVesting();
    }

    function alreadyUnlocked() public view returns (uint256) {
        if (stVest == false) {
            return 10;
        } else {
            uint256 full = (getCurrentTime() - maxStartVesting()) / 3 minutes;
            uint256 unlocked = 0;
            if (full >= 6) {
                unlocked = 6 * 15;
            } else {
                unlocked = full * 15;
            }
            return 10 + unlocked;
        }
    }

    function getTokenProportion() external view returns (uint256) {
        return tokenProportion;
    }

    function getCurrentTime() internal view returns (uint256) {
        return block.timestamp;
    }

    receive() external payable {}

    fallback() external payable {}
}