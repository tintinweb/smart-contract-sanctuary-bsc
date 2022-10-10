/**
 *Submitted for verification at BscScan.com on 2022-10-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

interface Weapons {
    //function weapons(uint) external view returns (Weapon memory);
    function weapons(uint256 ) external view returns(string memory class, string memory name, string memory scarcity, uint256 pic_id, uint256 level, uint256 attack, uint256 hp, uint256 battleCounts, uint256 exp);
    function weapon(uint) external view returns (uint256[3] memory);
    function battle(uint tokenId) external;
    struct Weapon {
        string class;   // 4D
        string name;    // name of event
        string scarcity;
        uint pic_id;    // cannot be zero!!!!
        uint level;     // 1,2,3..6
        uint attack;    // harm value
        uint hp;        // blood
        uint battleCounts;
        uint exp;
    }
}

contract PolyStaking is Ownable, IERC721Receiver {
    using SafeMath for uint256;
    
    struct StakingInfo {
        address staker;
        uint256 power;
        uint256 chain;
        bool claimed;
    }
    
    address public _erc20;
    address public _erc20_rewarder;
    address public _nft;
    
    uint256 public start_time;

    
    mapping(uint256 => mapping(uint256 => StakingInfo)) public stakes;              // round => tokenId => StakingInfo
    
    mapping(uint256 => mapping(uint256 => uint256[])) public chainStakes;           // A_or_B => round => tokenID[]
    mapping(uint256 => mapping(uint256 => uint256)) public chainStakesNumber;       // A_or_B => number[], one round one number, round as the index
    mapping(uint256 => mapping(uint256 => uint256)) public chainPowers;             // A_or_B => round => total power 
    
    mapping(address => uint256[]) public _stakersRounds;                            // address => all rounds
    mapping(address => mapping(uint256 => uint256[])) public _stakersRoundsNfts;    // address => all rounds => all nfts;
    
    uint256 constant public CHAIN_A = 0;
    uint256 constant public CHAIN_B = 1;
    
    mapping(uint256 => uint256) public levelPower;
    mapping(string => uint256) public classPower;
    mapping(uint256 => uint256) public toolsNumber;

    uint public hp_reduction_per_battle = 10;
    
    //event
    event Stake(address sender, uint256 round, uint256 tokenId, uint256 chain);
    event Claim(address sender, uint256 round, uint256 tokenId, uint256 earning);
    
    constructor(address geon_, address geon_rewarder_, address polyNft_, uint256 start_time_) { //1637020800 // 2021.11.16 0:0:0
        _erc20 = geon_;
        _erc20_rewarder = geon_rewarder_;
        _nft = polyNft_;
        start_time = start_time_;
        
        initLevelPower();
        initClassPower();
        initToolsNumber();
    }
    function initLevelPower() internal {
        levelPower[1] = 100;
        levelPower[2] = 150;
        levelPower[3] = 300;
        levelPower[4] = 800;
        levelPower[5] = 2000;
        levelPower[6] = 4000;
    }
    function setLevelPower(uint256 level, uint256 power) external onlyOwner() {
        levelPower[level] = power;
    }
    function initClassPower() internal {
        classPower["Destroyer"] = 100;
        classPower["Daemon"] = 150;
        classPower["Delusionist"] = 200;
        classPower["Dungeon"] = 400;
    }
    function setClassPower(string memory class, uint value) external onlyOwner() {
        classPower[class] = value;
    }
    function initToolsNumber() internal {
        toolsNumber[6	] = 3 ;
        toolsNumber[33	] = 9 ;
        toolsNumber[65	] = 12;
        toolsNumber[79	] = 6 ;
        toolsNumber[81	] = 9 ;
        toolsNumber[94	] = 9 ;
        toolsNumber[101	] = 12;
        toolsNumber[104	] = 10;
        toolsNumber[106	] = 9 ;
        toolsNumber[124	] = 7 ;
        toolsNumber[149	] = 8 ;
        toolsNumber[155	] = 9 ;
        toolsNumber[176	] = 4 ;
        toolsNumber[210	] = 5 ;
        toolsNumber[213	] = 8 ;
        toolsNumber[222	] = 6 ;
        toolsNumber[238	] = 5 ;
        toolsNumber[251	] = 8 ;
        toolsNumber[264	] = 10;
        toolsNumber[267	] = 6 ;
        toolsNumber[276	] = 9 ;
        toolsNumber[290	] = 12;
        toolsNumber[315	] = 7 ;
        toolsNumber[362	] = 4 ;
        toolsNumber[384	] = 9 ;
        toolsNumber[413	] = 5 ;
    }
    function setToolNumber(uint256 pic_id, uint256 num) external onlyOwner() {
        toolsNumber[pic_id] = num;
    }
    function setHpReduction(uint value) external onlyOwner() {
        hp_reduction_per_battle = value;
    }

    function _round(uint256 timeStamp) public view returns (uint256) {
        require(timeStamp >= start_time, "unstarted...");
 
        uint256 day = timeStamp.sub(start_time).div(1 days);
        uint256 secs = timeStamp.mod(1 days);
        uint256 r;
        if (secs < 3600*3) {
            r = 0;
        } else if (secs < 3600 * 10) {
            r = 1;
        } else if (secs < 3600 * 17) {
            r = 2;
        } else {
            r = 3;
        }
        
        r = day.mul(3).add(r);
        
        return r;
    }
    function _start(uint256 round) public view returns (uint256) {
        uint256 t;
        uint256 day = round / 3;
        
        if (round % 3 == 0) {
            t = start_time.add(day.mul(1 days)).add(3 hours);
        } else if (round % 3 == 1) {
            t = start_time.add(day.mul(1 days)).add(10 hours);
        } else {
            t = start_time.add(day.mul(1 days)).add(17 hours);
        }
        return t;
    }
    function _end(uint256 round) public view returns (uint256) {
        return _start(round).add(6 hours);
    }
    
    function _power(uint256 tokenId) public view returns (uint256) {
        uint pic_id;
        uint level;
        uint attack;
        uint hp;
        string memory class;

        (class, , , pic_id, level, attack, hp, , ) = Weapons(_nft).weapons(tokenId);

        uint256 p = 0;

        p = (toolsNumber[pic_id] *200)
          + (levelPower[level] * 4)
          + (attack)
          + (hp)
          + (classPower[class] * 2);
        
        return p;
    }
    
    function stake(uint256 tokenId, uint256 chainChoice) external {
        require(block.timestamp >= start_time, "unstarted now.");
        require(chainChoice == CHAIN_A || chainChoice == CHAIN_B, "chain param must be A or B.");

        // hp must be bigger than 10
        (, , , , , , uint hp, , ) = Weapons(_nft).weapons(tokenId);
        require(hp >= hp_reduction_per_battle, "hp not enough for battle.");
        
        uint round = _round(block.timestamp);
        address sender = _msgSender();
        
        // transfer nft 
        IERC721(_nft).safeTransferFrom(sender, address(this), tokenId);
        
        // record
        uint power = _power(tokenId);
        stakes[round][tokenId].staker = sender;
        stakes[round][tokenId].power = power;
        stakes[round][tokenId].chain = chainChoice;

        chainStakes[chainChoice][round].push(tokenId);
        chainStakesNumber[chainChoice][round] += 1;
        chainPowers[chainChoice][round] += power;
        
        // battle
        Weapons(_nft).battle(tokenId);
        
        emit Stake(sender, round, tokenId, chainChoice);
    }
    
    function _earning(uint256 round, uint256 tokenId) public view returns (uint256 reward) {
        if (stakes[round][tokenId].staker == address(0)) {
            return 0;
        }

        uint256 chainChoice = stakes[round][tokenId].chain;
        
        return stakes[round][tokenId].power.mul(chainStakesNumber[chainChoice][round]).mul(248).div(chainPowers[chainChoice][round]).mul(1 ether);
        
    }
    
    function claim(uint256 round, uint256 tokenId) external {
        require(_end(round) < block.timestamp, "not end now.");
        require(stakes[round][tokenId].staker == _msgSender(), "not the owner of the nft");
        require(stakes[round][tokenId].claimed == false, "have claimed before.");
        
        uint256 amount = _earning(round, tokenId);

        IERC721(_nft).safeTransferFrom(address(this), _msgSender(), tokenId);
        bool ok = IERC20(_erc20).transferFrom(_erc20_rewarder, _msgSender(), amount);
        require(ok, "transfer geon to staker failed when claim.");
        
        stakes[round][tokenId].claimed = true;
        
        emit Claim(_msgSender(), round, tokenId, amount);
    }
    
    /*
    struct UserStakes {
        uint256 round;
        uint256 tokenId;
    }
    
    function getUserStakes(address addr) external view returns (UserStakes[] memory) {
        uint256 totalNumber = 0;
        uint256 round;
        uint256 number;
        for (uint256 i = 0; i < _stakersRounds[addr].length; i++) {
            round = _stakersRounds[addr][i];
            number =  _stakersRoundsNfts[addr][round].length;
            totalNumber += number;
        }
        
        UserStakes[] memory ret = new UserStakes[](totalNumber);
        uint256 k;
        for (uint256 i = 0; i < _stakersRounds[addr].length; i++) {
            round = _stakersRounds[addr][i];
            for (uint256 j = 0; j < _stakersRoundsNfts[addr][round].length; j++) {
                UserStakes memory u = UserStakes (
                    round,
                    _stakersRoundsNfts[addr][round][j]
                );
                ret[k] = u;
                k++;
            }
        }
        
        return ret;
    }
    */
    
    function onERC721Received(address, address, uint256, bytes calldata) external override pure returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function onERC1155Received(address, address, uint256, uint256, bytes calldata) external pure returns(bytes4) {
        return this.onERC1155Received.selector;
    }
    
    function getERC721TokenBack(uint256 tokenId) external onlyOwner()  {
        if  (IERC721(_nft).ownerOf(tokenId) == address(this)) {
            IERC721(_nft).safeTransferFrom(address(this), _erc20_rewarder, tokenId);
        }
    }
}