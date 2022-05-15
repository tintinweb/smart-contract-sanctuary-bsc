/**
 *Submitted for verification at BscScan.com on 2022-05-15
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.10;

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

/**
 * @dev These functions deal with verification of Merkle Trees proofs.
 *
 * The proofs can be generated using the JavaScript library
 * https://github.com/miguelmota/merkletreejs[merkletreejs].
 * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.
 *
 * See `test/utils/cryptography/MerkleProof.test.js` for some examples.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merklee tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf)
        internal
        pure
        returns (bytes32)
    {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = keccak256(
                    abi.encodePacked(computedHash, proofElement)
                );
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = keccak256(
                    abi.encodePacked(proofElement, computedHash)
                );
            }
        }
        return computedHash;
    }
}

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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

library LibBet {
    enum MatchResult {
        HOME,
        AWAY,
        DRAW
    }

    struct TokenAsset {
        address addr;
        uint256 amount;
    }

    struct Bet {
        address bettor;
        uint256 matchId;
        MatchResult betOn;
        TokenAsset asset;
        uint256 salt;
    }

    bytes32 constant TOKEN_ASSET_TYPE_TYPEHASH =
        keccak256("TokenAsset(address addr,uint256 amount)");
    bytes32 constant BET_TYPE_TYPEHASH =
        keccak256(
            "Bet(address bettor,uint256 matchId,uint8 betOn,TokenAsset asset,uint256 salt)TokenAsset(address addr,uint256 amount)"
        );

    function hash(TokenAsset memory tokenAsset)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked(
                    TOKEN_ASSET_TYPE_TYPEHASH,
                    tokenAsset.addr,
                    tokenAsset.amount
                )
            );
    }

    function hash(Bet memory bet) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    BET_TYPE_TYPEHASH,
                    bet.bettor,
                    bet.matchId,
                    bet.betOn,
                    hash(bet.asset),
                    bet.salt
                )
            );
    }
}

contract EuphoriaBetting is Ownable {
    enum PaymentType {
        BALANCE,
        WALLET,
        WALLET_BALANCE
    }

    struct Odds {
        uint256 home;
        uint256 away;
    }
    struct Match {
        uint256 id;
        Odds odds;
        uint256 startTimestamp;
    }
    struct Reward {
        address bettor;
        LibBet.TokenAsset[] tokens;
    }

    bytes32 public merkleRoot;
    mapping(uint256 => Match) public matches;
    mapping(address => mapping(address => uint256)) public balances;
    mapping(bytes32 => bool) public bets;

    mapping(address => uint256) public commissionBalance;

    event Bet(LibBet.Bet bet, uint256 odds);
    event MatchAddition(Match[] matches);
    event MatchRemoval(uint256[] matches);
    event MatchCancel(uint256[] matches);

    event MatchFinished(uint256 matchId, LibBet.MatchResult result);
    event RewardsDistributed(Reward[] rewards);
    event MerkleRootUpdated(bytes32 merkleRoot);
    event CommissionBalanceUpdatedBy(LibBet.TokenAsset[] commissions);

    event Withdrawal(address bettor, address token, uint256 amount);

    function makeBet(LibBet.Bet memory bet, PaymentType paymentType) external {
        require(
            matches[bet.matchId].startTimestamp > block.timestamp,
            "Match is not available for betting"
        );
        require(bet.bettor == msg.sender, "Bettor must be message sender");

        bytes32 betHash = hashBet(bet);
        require(!bets[betHash], "Bet has already been made");

        require(
            bet.asset.amount >= 1000,
            "Bet amount must be equal or greater than 1000"
        );
        require(
            bet.betOn != LibBet.MatchResult.DRAW,
            "Bettor can't bet on a DRAW"
        );

        uint256 bettorBalance = balances[msg.sender][bet.asset.addr];

        if (paymentType == PaymentType.BALANCE) {
            require(
                bettorBalance >= bet.asset.amount,
                "Not enough funds in balance"
            );
            balances[msg.sender][bet.asset.addr] -= bet.asset.amount;
        } else if (paymentType == PaymentType.WALLET) {
            IERC20 bettorToken = IERC20(bet.asset.addr);
            require(
                bettorToken.allowance(msg.sender, address(this)) >=
                    bet.asset.amount - bettorBalance,
                "Insufficient allowance"
            );
            bettorToken.transferFrom(
                msg.sender,
                address(this),
                bet.asset.amount
            );
        } else if (paymentType == PaymentType.WALLET_BALANCE) {
            if (bettorBalance < bet.asset.amount) {
                IERC20 bettorToken = IERC20(bet.asset.addr);
                require(
                    bettorToken.allowance(msg.sender, address(this)) >=
                        bet.asset.amount - bettorBalance,
                    "Insufficient allowance"
                );

                bettorToken.transferFrom(
                    msg.sender,
                    address(this),
                    bet.asset.amount - bettorBalance
                );
                balances[msg.sender][bet.asset.addr] = 0;
            } else {
                balances[msg.sender][bet.asset.addr] -= bet.asset.amount;
            }
        }

        uint256 odds;
        if (bet.betOn == LibBet.MatchResult.HOME) {
            odds = matches[bet.matchId].odds.home;
        } else {
            odds = matches[bet.matchId].odds.away;
        }

        bets[betHash] = true;

        emit Bet(bet, odds);
    }

    function finishMatch(
        uint256 matchId,
        LibBet.MatchResult result,
        bytes32 newMerkleRoot,
        Reward[] memory rewards,
        LibBet.TokenAsset[] memory commissions
    ) external onlyOwner {
        require(
            matches[matchId].startTimestamp <= block.timestamp,
            "Match is not started"
        );
        setMerkleRoot(newMerkleRoot);
        distributeRewards(rewards);
        updateCommissionBalance(commissions);

        emit MatchFinished(matchId, result);
    }

    function addMatches(Match[] memory _matches) external onlyOwner {
        for (uint256 i; i < _matches.length; i++) {
            matches[_matches[i].id] = _matches[i];
        }

        emit MatchAddition(_matches);
    }

    function cancelMatches(uint256[] memory match_ids, Reward[] memory rewards)
        external
        onlyOwner
    {
        require(match_ids.length > 0, "Length of matches must not be zero");
        for (uint256 i; i < match_ids.length; i++) {
            matches[match_ids[i]].startTimestamp = block.timestamp;
        }

        if (rewards.length > 0) {
            distributeRewards(rewards);
        }

        emit MatchCancel(match_ids);
    }

    function addFunds(LibBet.TokenAsset memory asset) external {
        IERC20 token = IERC20(asset.addr);
        require(
            token.allowance(msg.sender, address(this)) >= asset.amount,
            "Insufficient allowance"
        );

        token.transferFrom(msg.sender, address(this), asset.amount);
        balances[msg.sender][asset.addr] += asset.amount;
    }

    function withdraw(address token, uint256 amount) external {
        require(
            balances[msg.sender][token] >= amount,
            "Insufficient token amount"
        );

        IERC20(token).transfer(msg.sender, amount);
        balances[msg.sender][token] -= amount;

        emit Withdrawal(msg.sender, token, amount);
    }

    function verifyMerkleRoot(bytes32[] memory proof, bytes32 leaf)
        external
        view
        returns (bool)
    {
        return MerkleProof.verify(proof, merkleRoot, leaf);
    }

    function hashBet(LibBet.Bet memory bet) public pure returns (bytes32) {
        return LibBet.hash(bet);
    }

    function distributeRewards(Reward[] memory rewards) internal {
        require(rewards.length > 0, "Rewards must not be empty");
        for (uint256 i; i < rewards.length; i++) {
            processReward(rewards[i]);
        }

        emit RewardsDistributed(rewards);
    }

    function processReward(Reward memory reward) internal {
        for (uint256 i; i < reward.tokens.length; i++) {
            LibBet.TokenAsset memory token = reward.tokens[i];
            balances[reward.bettor][token.addr] += token.amount;
        }
    }

    function updateCommissionBalance(LibBet.TokenAsset[] memory commissions)
        internal
    {
        for (uint256 i; i < commissions.length; i++) {
            commissionBalance[commissions[i].addr] += commissions[i].amount;
        }
    }

    function setMerkleRoot(bytes32 newMerkleRoot) internal {
        require(
            newMerkleRoot != merkleRoot,
            "New merkleRoot must not be the same as the old one"
        );
        merkleRoot = newMerkleRoot;

        emit MerkleRootUpdated(merkleRoot);
    }
}