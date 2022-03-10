/**
 *Submitted for verification at BscScan.com on 2022-03-10
*/

pragma solidity ^0.6.0;
// SPDX-License-Identifier: MIT
/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}







/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        // Check if the computed hash (root) is equal to the provided root
        return computedHash == root;
    }
}
interface IMerkleDistributor {
    // Returns the address of the token distributed by this contract.
    function token() external view returns (address);
    // Returns the merkle root of the merkle tree containing account balances available to claim.
    function merkleRoot() external view returns (bytes32);
    // Returns true if the index has been marked claimed.
    function isClaimed(uint256 index) external view returns (bool);
    // Claim the given amount of the token to the given address. Reverts if the inputs are invalid.
    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external;

    // This event is triggered whenever a call to #claim succeeds.
    event Claimed(uint256 index, address account, uint256 amount);
}
contract ClaimContract {
    constructor(uint256 index, address account, uint256 amount, bytes32[] memory merkleProof) public {
        IMerkleDistributor(msg.sender).claim(index,address(this),amount,merkleProof);
    }
}

/**
generate-merkle-root
https://github.com/Uniswap/merkle-distributor

Precompute Contract Address
const util = require('ethereumjs-util');
const rlp = require('rlp');
function calcContractAddress() {
    let addr = '0x955dDCa79B56e8754878688c95b7D2C45ce237DB';
    let info = {};
    for (let i = 0; i < 10; i++) {
        let indexStr ="";
        if(i === 0){
            indexStr = "";
        }else{
            indexStr = web3.utils.numberToHex(i);
        }
        let re = util.bufferToHex(util.keccak256(rlp.encode([addr, indexStr])).slice(12));
        info[re] = i + 1;
    }
    console.log(JSON.stringify(info))
}

//TODO remix evm中计算地址从0开始， bsc是从1开始算，bsc从下面的第二个地址开始，第一个地址作废

{
    "0xbb67fea689d935412aa842848b5db7c9faf58472": 1, 
    "0x910b5aabef30c0902a1f43e79a85fa432fbaa2b0": 2, 
    "0x9e6c79d2886411e1bd661dded27c8546c683eb61": 3, 
    "0xd4a9a5a68fac32562da3b7687941a8092cfdd836": 4, 
    "0x10cabde9934024968a0c72f0e72c4652e64bab0d": 5, 
    "0xea7d7ec0889d17c70dc8445273ebb36d8e01eeee": 6, 
    "0x7006f33be57023635ccea89ceae62c2329b9b104": 7, 
    "0x809dd301f30d9cc60206a31cf5b0f2d7caaf34f5": 8, 
    "0xf8c893ba98d074cd94089776c681871c7f6947f1": 9, 
    "0x59cae0ee94ccef8590d67cb4c963c48bb6127d05": 10
}

{
    "merkleRoot": "0x4cbe4bdc82829744d6672ef054c0fc0a552fd679ca5becc27c04e0e176f27c56", 
    "tokenTotal": "0x37", 
    "claims": {
        "0x10CAbDe9934024968A0C72F0e72C4652e64BAb0d": {
            "index": 0, 
            "amount": "0x05", 
            "proof": [
                "0x1a4a32dae247e5fdb2ee512cd2608873b80f95 58bdf2241b03c21e005a5f4090", 
                "0xb84f76ca87f8230986adc983e6f894dcecfe1686794cc0294e617cd1b085d833", 
                "0x360a8d79de319f274f8636e0458e4ccf9c4e83284f5b4bafeade106b7a0f1733", 
                "0xd86c00d0832a33b4b371fd3d47ae4279617f2a60940e2b52bb9aaf30d72d5592"
            ]
        }, 
        "0x59CAe0eE94ccef8590d67cB4c963C48bB6127D05": {
            "index": 1, 
            "amount": "0x0a", 
            "proof": [
                "0x1bd21a2f711da7db377822b22209fe5b5ddf0e4ccdd7356320665a8bd1081fcd", 
                "0xb84f76ca87f8230986adc983e6f894dcecfe1686794cc0294e617cd1b085d833", 
                "0x360a8d79de3 19f274f8636e0458e4ccf9c4e83284f5b4bafeade106b7a0f1733", 
                "0xd86c00d0832a33b4b371fd3d47ae4279617f2a60940e2b52bb9aaf30d72d5592"
            ]
        }, 
        "0x7006F33be57023635CCea89ceaE62C2329B9b104": {
            "index": 2, 
            "amount": "0x07", 
            "proof": [
                "0x1c260425d264cda16cb203c754ff777ceb592aa5d8a4fef003beaed20e93c8f1", 
                "0x873d52f3f91ea49fd2c3c1c9449e7cbbb899d0d80dd5d43bb2c96b2b53550db9", 
                "0x360a8d79de319f274f8636e0458e4ccf9c4e83284f5b4bafeade106b7a0f1733", 
                "0xd86c00d0832a33b4b371fd3d47ae4279617f2a60940e2b52bb9aaf30d72d5592"
            ]
        }, 
        "0x809Dd301f30d9Cc60206A31cf5B0f2d7CAAf34f5": {
            "index": 3, 
            "amount": "0x08", 
            "proof": [
                "0xb297bfa0ebb87f5f5a2acf18f56f1e87f0871a25bcf0c91607ba1aa24ebe1f93", 
                "0x2c0748e4cd8ef14783f8e76345d50c30940d85d2ddbde791dc51c19dcdc739d2", 
                "0xd3ba2d8ad9944fcc8570fc2f8041365769357f755b5b535a3fb8563e10f0d219", 
                "0xd86c00d0832a33b4b371fd3d47ae4279617f2a60940e2b52bb9aaf30d72d5592"
            ]
        }, 
        "0x910B5AaBEF30C0902a1f43E79a85FA432fbaa2B0": {
            "index": 4, 
            "amount": "0x02", 
            "proof": [
                "0x5c12714b47d9 af8db58f91359322658cfb7f18f953d42f766bcc5684c96003a4", 
                "0xc88b52d2dc2f79f8520c458e4033d05d99bf48cf79a690f79022b1864e67a417", 
                "0xd3ba2d8ad9944fcc8570fc2f8041365769357f755b5b535a3fb8563e10f0d219", 
                "0xd86c00d0832a33b4b371fd3d47ae4279617f2a60940e2b52bb9aaf30d72d5592"
            ]
        }, 
        "0x9e6c79D2886411e1bd661ddeD27C8546C683eb61": {
            "index": 5, 
            "amount": "0x03", 
            "proof": [
                "0x8dec30ab5916228f0fc3487257cc4b1724905c4a06136fde9d78934ebcddee63", 
                "0x2c0748e4cd8ef14783f8e76345d50c30940d85d2ddbde791dc51c19dcdc739d2", 
                "0xd3ba2d8ad9944fcc8570fc2f8041365769357f755b5b535a3fb8563e10f0d219", 
                "0xd86c00d0832a33b4b371fd3d47ae4279617f2a60940e2b52bb9aaf30d72d5592"
            ]
        }, 
        "0xBB67fea689D935412aA842848b5db7C9FaF58472": {
            "index": 6, 
            "amount": "0x01", 
            "proof": [
                "0x1be7c34457ee0581865e00af4b24922959b9697b03da7987865568297965dec5", 
                "0x873d52f3f91ea49fd2c3c1c9449e7cbbb899d0d80dd5d43bb2c96b2b53550db9", 
                "0x360a8d79de319f274f8636e0458e4ccf9c4e83284f5b4bafeade106b7a0f1733", 
                "0xd86c00d0832a33b4b371fd3d47ae4279617f2a60940e2b52bb9aaf30d72d5592"
            ]
        }, 
        "0xD4a9a5a68fAC32562dA3B7687941A8092CFDD836": {
            "index": 7, 
            "amount": "0x04", 
            "proof": [
                "0xe5ff8c232e52071855006a45348c313692915b6ddf0ffdbbbb69900bf7cabf96", 
                "0x12249c0acfc3887ca28d4921979001012747cabff4e8b38bc2a87a077a03fc0b"
            ]
        }, 
        "0xF8c893ba98d074Cd94089776C681871c7F6947F1": {
            "index": 8, 
            "amount": "0x09", 
            "proof": [
                "0xe3eedef8321e18e839219dfe3d84f533004a7c23e4e0fb3cf4ee967166d4a49c", 
                "0x12249c0acfc3887ca28d4921979001012747cabff4e8b38bc2a87a077a03fc0b"
            ]
        }, 
        "0xeA7d7Ec0889D17C70dc8445273EBB36D8e01EEeE": {
            "index": 9, 
            "amount": "0x06", 
            "proof": [
                "0x73fed30713dcd946fc28bcc818acf1900c4de5dafcdff3e56e16b4db58e0257a", 
                "0xc88b52d2dc2f79f8520c458e4033d05d99bf48cf79a690f79022b1864e67a417", 
                "0xd3ba2d8ad9944fcc8570fc2f8041365769357f755b5b535a3fb8563e10f0d219", 
                "0xd86c00d0832a33b4b371fd3d47ae4279617f2a60940e2b52bb9aaf30d72d5592"
            ]
        }
    }
}

*/
contract UniMerkleDistributor is ERC20("abc", "ABC", 6) {

    constructor() public {
        _mint(address(this), 1100000000 * (10 ** uint256(decimals())));
    }
    
// This event is triggered whenever a call to #claim succeeds.
    event Claimed(uint256 index, address account, uint256 amount);
     address public   token;
    bytes32 public   merkleRoot;

    // This is a packed array of booleans.
    mapping(uint256 => uint256) private claimedBitMap;



    function setInfo(address token_, bytes32 merkleRoot_)public{
        token = token_;
        merkleRoot = merkleRoot_; 
    }

    function claimToken(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external   {
            new ClaimContract(index,account,amount,merkleProof);
    }

    function isClaimed(uint256 index) public view   returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function _setClaimed(uint256 index) private {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }

    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external   {
        require(!isClaimed(index), 'MerkleDistributor: Drop already claimed.');

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        require(MerkleProof.verify(merkleProof, merkleRoot, node), 'MerkleDistributor: Invalid proof.');

        // Mark it claimed and send the token.
        _setClaimed(index);
        require(IERC20(token).transfer(account, amount), 'MerkleDistributor: Transfer failed.');

        emit Claimed(index, account, amount);
    }
}