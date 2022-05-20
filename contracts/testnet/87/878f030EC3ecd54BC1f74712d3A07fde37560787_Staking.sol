// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "PausableByOwner.sol";
import "IUniswapV2ERC20.sol";
import "IERC20.sol";

//TODO add a list of valid tokens

contract Staking is PausableByOwner {
    /**
     * @param totalStaked amount of NMXLP currently staked in the service
     */
    struct State {
        uint256 totalStaked;
    }

    /**
     * @param amount of NMXLP currently staked by the staker
     */
    struct Staker {
        mapping(address => uint256) staked_tokens;
        address[] list_token;
    }

    struct TokenBalance {
        address token;
        uint256 amount;
    }

    enum UPDATE_ACTION {
        STAKED,
        UNSTAKED
    }

    //TODO: INIT Pendiente de revisar

    //bytes32 public immutable DOMAIN_SEPARATOR;

    // string private constant CLAIM_TYPE =
    //     "Claim(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)";
    // bytes32 public constant CLAIM_TYPEHASH =
    //     keccak256(abi.encodePacked(CLAIM_TYPE));

    // string private constant UNSTAKE_TYPE =
    //     "Unstake(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)";
    // bytes32 public constant UNSTAKE_TYPEHASH =
    //     keccak256(abi.encodePacked(UNSTAKE_TYPE));
    // mapping(address => uint256) public nonces;
    //TODO: END Pendiente de revisar

    State public state; /// @dev internal service state
    // the value in the countToAddress mapping points to the key in the next mapping
    mapping(uint256 => address) private countToAddress;
    mapping(address => Staker) stakers; /// @dev mapping of staker's address to its state

    event Staked(address indexed owner, address indexed token, uint256 amount); /// @dev someone is staked NMXLP
    event Unstaked(
        address indexed from,
        address indexed to,
        uint256 amount,
        address indexed token
    ); /// @dev someone unstaked NMXLP

    constructor() {
        // uint256 chainId;
        // assembly {
        //     chainId := chainid()
        // }
        // DOMAIN_SEPARATOR = keccak256(
        //     abi.encode(
        //         keccak256(
        //             "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        //         ),
        //         keccak256(bytes("StakingService")),
        //         keccak256(bytes("1")),
        //         chainId,
        //         address(this)
        //     )
        // );
    }

    /**
     @dev function to stake permitted amount of LP tokens from uniswap contract
     @param amount of NMXLP to be staked in the service
     */
    function stake(uint256 amount, address token) external {
        _stakeFrom(_msgSender(), token, amount);
    }

    //TODO: Refactor to let user stake multiple tokens
    function stakeWithPermit(
        uint256 amount,
        address token,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        IUniswapV2ERC20(token).permit(
            _msgSender(),
            address(this),
            amount,
            deadline,
            v,
            r,
            s
        );
        _stakeFrom(_msgSender(), token, amount);
    }

    //TODO: Refactor to let user stake multiple tokens
    function stakeFrom(
        address owner,
        address token,
        uint256 amount
    ) external {
        _stakeFrom(owner, token, amount);
    }

    //TODO: Refactor to let user stake multiple tokens
    function _stakeFrom(
        address owner,
        address token,
        uint256 amount
    ) private whenNotPaused nonZeroAmount(amount) {
        bool transferred = IERC20(token).transferFrom(
            owner,
            address(this),
            uint256(amount)
        );
        require(
            transferred,
            "ShieldTowerStaking._stakeFrom: TOKEN_FAILED_TRANSFER"
        );

        updateTokenStaker(UPDATE_ACTION.STAKED, owner, token, amount);
    }

    /**
     @dev function to unstake LP tokens from the service and transfer to uniswap contract
     @param amount of NMXLP to be unstaked from the service
     */
    function unstake(uint256 amount, address token) external {
        _unstake(_msgSender(), _msgSender(), amount, token);
    }

    function unstakeTo(
        address to,
        uint256 amount,
        address token
    ) external {
        _unstake(_msgSender(), to, amount, token);
    }

    // function unstakeWithAuthorization(
    //     address owner,
    //     uint256 amount,
    //     uint256 signedAmount,
    //     uint256 deadline,
    //     uint8 v,
    //     bytes32 r,
    //     bytes32 s
    // ) external {
    //     require(amount <= signedAmount, "NmxStakingService: INVALID_AMOUNT");
    //     verifySignature(
    //         UNSTAKE_TYPEHASH,
    //         owner,
    //         _msgSender(),
    //         signedAmount,
    //         deadline,
    //         v,
    //         r,
    //         s
    //     );
    //     _unstake(owner, _msgSender(), amount);
    // }

    function _unstake(
        address from,
        address to,
        uint256 amount,
        address token
    ) private nonZeroAmount(amount) {
        require(
            amount <= getBalanceTokenAmountOf(_msgSender(), token),
            "ShieldTowerStaking._unstake: NOT_ENOUGH_STAKED"
        );
        require(
            getBalanceTokenAmountOf(_msgSender(), token) > 0,
            "ShieldTowerStaking._unstake: STAKED_BALANCE_ZERO"
        );
        //TODO un require para verificar que no puedes hacer unstake de un importe que no tienes
        updateTokenStaker(UPDATE_ACTION.UNSTAKED, from, token, amount);

        bool transferred = IERC20(token).transfer(to, amount);
        require(
            transferred,
            "ShieldTowerStaking._unstake: TOKEN_FAILED_TRANSFER"
        );
    }

    function updateTokenStaker(
        UPDATE_ACTION _status,
        address _staker_address,
        address _token_address,
        uint256 _amount
    ) private {
        Staker storage staker = stakers[_staker_address];

        if (_status == UPDATE_ACTION.STAKED) {
            //save in array
            bool force_save = true;

            for (uint256 i; i < staker.list_token.length; i++) {
                if (staker.list_token[i] == _token_address) {
                    force_save = false;
                    break;
                }
            }

            if (force_save) {
                staker.list_token.push(_token_address);
            }
            //save in mapping
            staker.staked_tokens[_token_address] += _amount;
            emit Staked(_staker_address, _token_address, _amount);
        } else {
            staker.staked_tokens[_token_address] -= _amount;

            //remove item from array/mapping if its 0
            if (staker.staked_tokens[_token_address] == 0) {
                delete staker.staked_tokens[_token_address];
                for (uint256 i; i < staker.list_token.length; i++) {
                    if (staker.list_token[i] == _token_address) {
                        delete staker.list_token[i];
                        break;
                    }
                }
            }

            emit Unstaked(
                _staker_address,
                _token_address,
                _amount,
                _token_address
            );
        }
    }

    //TODO: Pendiente de revisar
    // function verifySignature(
    //     bytes32 typehash,
    //     address owner,
    //     address spender,
    //     uint256 value,
    //     uint256 deadline,
    //     uint8 v,
    //     bytes32 r,
    //     bytes32 s
    // ) private {
    //     require(deadline >= block.timestamp, "NmxStakingService: EXPIRED");
    //     bytes32 digest = keccak256(
    //         abi.encodePacked(
    //             "\x19\x01",
    //             DOMAIN_SEPARATOR,
    //             keccak256(
    //                 abi.encode(
    //                     typehash,
    //                     owner,
    //                     spender,
    //                     value,
    //                     nonces[owner]++,
    //                     deadline
    //                 )
    //             )
    //         )
    //     );
    //     address recoveredAddress = ecrecover(digest, v, r, s);
    //     require(
    //         recoveredAddress != address(0) && recoveredAddress == owner,
    //         "NmxStakingService: INVALID_SIGNATURE"
    //     );
    // }

    function getBalanceTokenAmountOf(address _user, address _token)
        public
        view
        returns (uint256)
    {
        Staker storage staker = stakers[_user];
        return staker.staked_tokens[_token];
    }

    function getBalanceOf(address _user)
        public
        view
        returns (TokenBalance[] memory)
    {
        Staker storage staker = stakers[_user];
        TokenBalance[] memory user_tokens = new TokenBalance[](
            staker.list_token.length
        );

        for (uint256 i = 0; i < staker.list_token.length; i++) {
            TokenBalance memory token;
            token.token = staker.list_token[i];
            token.amount = staker.staked_tokens[staker.list_token[i]];
            user_tokens[i] = token;
        }

        return user_tokens;
    }

    // function totalStaked() external view returns (uint256) {
    //     return state.totalStaked;
    // }
    modifier nonZeroAmount(uint256 amount) {
        require(amount > 0, "ShieldTowerStaking: NOT ALLOW ZERO AMOUNT");
        _;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >0.8.0;

import "Ownable.sol";
import "Pausable.sol";

/**
 * @dev Contract module which is essentially like Pausable but only owner is allowed to change the state.
 */
abstract contract PausableByOwner is Pausable, Ownable {
    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function pause() external virtual onlyOwner {
        _pause();
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function unpause() external virtual onlyOwner {
        _unpause();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "Context.sol";

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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

pragma solidity >=0.5.0;

interface IUniswapV2ERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
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