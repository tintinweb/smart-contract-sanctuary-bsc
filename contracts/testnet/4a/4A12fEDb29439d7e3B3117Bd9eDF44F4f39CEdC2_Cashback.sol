// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./FlexibleStaking.sol";

interface IPancakeRouter {
    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

contract Cashback is Ownable {
    IERC20 public fitToken;
    IPancakeRouter public pancakeRouter;
    FlexibleStaking public flexibleStaking;
    address public backend;

    // Pancake swap addresses
    address public routerAddress;
    address public tokenForSwap;
    address public WBNB;

    mapping(address => uint256) public nonce;

    modifier onlyBackend() {
        require(msg.sender == backend);
        _;
    }

    constructor(
        IERC20 _fitToken,
        address _backend
    ) {
        fitToken = _fitToken;
        backend = _backend;
    }

    receive() external payable {}

    function setFlexibleStaking(address _flexibleStaking) external onlyBackend {
        flexibleStaking = FlexibleStaking(_flexibleStaking);
        fitToken.approve(_flexibleStaking, 2**256 - 1);
    }

    function changeBackend(address _newBackend) external onlyBackend {
        backend = _newBackend;
    }

    function setRouter(address _newRouter) external onlyBackend {
        routerAddress = _newRouter;
        pancakeRouter = IPancakeRouter(_newRouter);
    }

    function setPair(address _tokenForSwap, address _WBNB)
        external
        onlyBackend
    {
        tokenForSwap = _tokenForSwap;
        WBNB = _WBNB;
        IERC20(_tokenForSwap).approve(routerAddress, 2**256 - 1);
    }

    function stake(uint256 _amount, bytes calldata _sig) external {
        require(
            cashbackPool() >= _amount,
            "Not enough tokens in cashback pool"
        );
        require(verify(_amount, _sig), "Wrong signature");
        nonce[msg.sender]++;
        flexibleStaking.stakeFromCashback(msg.sender, _amount);
    }

    function withdraw(uint256 _amount, bytes calldata _sig) external {
        require(
            cashbackPool() >= _amount,
            "Not enough tokens in cashback pool"
        );
        require(verify(_amount, _sig), "Wrong signature");
        nonce[msg.sender]++;
        fitToken.transfer(msg.sender, _amount);
    }

    function stakeWithBNB(
        uint256 _tokenAmount,
        address _stakeholder,
        uint256 _bnbAmount
    ) external onlyBackend {
        uint256 supposedTokenSwapped = tokenAmountForBNB(_bnbAmount);
        require(
            _tokenAmount > supposedTokenSwapped,
            "Not enough tokens for swapping to BNB"
        );
        require(
            cashbackPool() >= _tokenAmount - supposedTokenSwapped,
            "Not enough tokens in cashback pool"
        );
        uint256 tokenSwapped = swapTokensForBNB(_bnbAmount, _tokenAmount);
        payable(backend).transfer(_bnbAmount / 3);
        payable(_stakeholder).transfer((_bnbAmount * 2) / 3);
        flexibleStaking.stakeFromCashback(
            _stakeholder,
            _tokenAmount - tokenSwapped
        );
    }

    function withdrawWithBNB(
        uint256 _tokenAmount,
        address _user,
        uint256 _bnbAmount
    ) external onlyBackend {
        uint256 supposedTokenSwapped = tokenAmountForBNB(_bnbAmount);
        require(
            _tokenAmount > supposedTokenSwapped,
            "Not enough tokens for swapping to BNB"
        );
        require(
            cashbackPool() >= _tokenAmount - supposedTokenSwapped,
            "Not enough tokens in cashback pool"
        );
        uint256 tokenSwapped = swapTokensForBNB(_bnbAmount, _tokenAmount);
        payable(backend).transfer(_bnbAmount / 3);
        payable(_user).transfer((_bnbAmount * 2) / 3);
        fitToken.transfer(_user, _tokenAmount - tokenSwapped);
    }

    function tokenAmountForBNB(uint256 _bnbAmount)
        public
        view
        returns (uint256)
    {
        address[] memory pair = new address[](2);
        pair[0] = tokenForSwap;
        pair[1] = WBNB;
        return pancakeRouter.getAmountsIn(_bnbAmount, pair)[0];
    }

    function cashbackPool() public view returns (uint256) {
        return fitToken.balanceOf(address(this));
    }

    function swapTokensForBNB(uint256 _bnbAmount, uint256 _maxTokensToSpend)
        internal
        returns (uint256)
    {
        address[] memory pair = new address[](2);
        pair[0] = tokenForSwap;
        pair[1] = WBNB;
        return
            pancakeRouter.swapTokensForExactETH(
                _bnbAmount,
                _maxTokensToSpend,
                pair,
                address(this),
                block.timestamp + 2 minutes
            )[0];
    }

    function verify(uint256 _amount, bytes memory _sig)
        internal
        view
        returns (bool)
    {
        bytes32 hashedMessage = ethMessageHash(
            msg.sender,
            nonce[msg.sender],
            _amount
        );
        return recover(hashedMessage, _sig) == backend;
    }

    /**
     * @dev Recover signer address from a message by using their signature
     * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
     * @param sig bytes signature, the signature is generated using web3.eth.sign()
     */
    function recover(bytes32 hash, bytes memory sig)
        internal
        pure
        returns (address)
    {
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Check the signature length
        if (sig.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            // solium-disable-next-line arg-overflow
            return ecrecover(hash, v, r, s);
        }
    }

    /**
     * @dev prefix a bytes32 value with "\x19Ethereum Signed Message:" and hash the result
     */
    function ethMessageHash(
        address _user,
        uint256 _nonce,
        uint256 _amount
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    keccak256(abi.encodePacked(_user, _nonce, _amount))
                )
            );
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FlexibleStaking is Ownable {
    IERC20 public fitToken;
    address public cashbackAddr;

    uint256 public rewardPool;
    // About 1000 tokens per day
    uint256 public rewardRate = 11574074074074074;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    uint256 public totalValueLocked;
    mapping(address => uint256) balances;

    event Staked(address indexed staker, address indexed payer, uint256 indexed amount);
    event Unstaked(address indexed staker, uint256 indexed amount);
    event Rewarded(address indexed staker, uint256 indexed reward);

    modifier onlyCashback() {
        require(msg.sender == cashbackAddr);
        _;
    }

    modifier updateReward(address _account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;

        uint256 reward = earned(_account);
        rewards[_account] = reward;
        userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        _;
    }

    constructor(address _fitToken, address _cashbackAddr) {
        fitToken = IERC20(_fitToken);
        cashbackAddr = _cashbackAddr;
    }

    function increaseRewardPool(uint256 _amount) external onlyOwner {
        fitToken.transferFrom(msg.sender, address(this), _amount);
        rewardPool += _amount;
    }

    function changeRewardRate(uint256 _amount) external onlyOwner {
        rewardRate = _amount;
    }

    function stake(uint256 _amount) external {
        _stake(msg.sender, _amount, msg.sender);
    }

    function stakeFromCashback(address _user, uint256 _amount)
        external
        onlyCashback
    {
        _stake(_user, _amount, msg.sender);
    }

    function getReward() external updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        require(reward > 0, "Reward should be more than 0");
        require(
            rewardPool >= rewards[msg.sender],
            "Reward pool is less than your reward"
        );
        rewards[msg.sender] = 0;
        rewardPool -= reward;
        fitToken.transfer(msg.sender, reward);
        emit Rewarded(msg.sender, reward);
    }

    function withdraw() external updateReward(msg.sender) {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "Amount should be more than 0");
        require(
            totalValueLocked >= amount,
            "Total supply is less than amount to withdraw"
        );
        totalValueLocked -= amount;
        balances[msg.sender] = 0;
        fitToken.transfer(msg.sender, amount);
        emit Unstaked(msg.sender, amount);
    }

    function userStake(address _account) external view returns (uint256) {
        return balances[_account];
    }

    function getAPYStaked() public view returns (uint256) {
        return (rewardRate * 60 * 60 * 24 * 365 * 100) / totalValueLocked;
    }

    function getAPYNotStaked(uint256 _stakeAmount)
        public
        view
        returns (uint256)
    {
        return
            (rewardRate * 60 * 60 * 24 * 365 * 100) /
            (totalValueLocked + _stakeAmount);
    }

    function earnedAlready(address _account) external view returns (uint256) {
        uint256 _rewardPerTokenStored = rewardPerToken();
        uint256 _lastUpdateTime = block.timestamp;
        uint256 _rewardPerToken;
        if (totalValueLocked == 0) {
            _rewardPerToken = rewardPerTokenStored;
        } else {
            _rewardPerToken =
                _rewardPerTokenStored +
                (((block.timestamp - _lastUpdateTime) * rewardRate * 1e32) /
                    totalValueLocked);
        }
        uint256 reward = ((balances[_account] *
            (_rewardPerToken - userRewardPerTokenPaid[_account])) / 1e32) +
            rewards[_account];
        return reward;
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalValueLocked == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored +
            (((block.timestamp - lastUpdateTime) * rewardRate * 1e32) /
                totalValueLocked);
    }

    function _stake(
        address _staker,
        uint256 _amount,
        address _payer
    ) internal updateReward(_staker) {
        require(_amount > 0, "Amount should be more than 0");
        totalValueLocked += _amount;
        balances[_staker] += _amount;
        fitToken.transferFrom(_payer, address(this), _amount);
        emit Staked(_staker, _payer, _amount);
    }

    function earned(address _account) internal view returns (uint256) {
        return
            ((balances[_account] *
                (rewardPerToken() - userRewardPerTokenPaid[_account])) / 1e32) +
            rewards[_account];
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