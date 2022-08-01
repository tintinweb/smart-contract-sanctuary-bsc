/**
 *Submitted for verification at BscScan.com on 2022-08-01
*/

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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

// File: contracts/interfaces/IBEP20.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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
// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


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

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// File: contracts/interfaces/IFounderNFT.sol


pragma solidity ^0.8.7;


interface IFounderNFT {
    
    function mintFNFT(address to, string memory uri) external payable returns (uint8 tokenCounter);

    function tranferFNFT(address from, address to, uint8 id) external payable;

    function setTotalSupply(uint8 count) external;

    function setOperator(address operator) external;

    function tokenURI(uint256 tokenId) external view returns (string memory);

    function totalSupply() external view returns (uint8 totalSupply);
}
// File: contracts/FNFTFactory.sol


pragma solidity ^0.8.7;




contract FNFTFactory {
    using SafeMath for uint256;
    uint8 constant HUNDRED_PERCENTAGE = 100;

    address _admin;
    address _devWallet;
    IFounderNFT _founderNFT;
    IBEP20 _bonsai;
    uint8 _indexOfFNFT;
    uint256 _airdropDuration;
    uint256 _airdropInterval;
    uint8 _airdropPercentage;
    uint256 public _initialBNB;

    struct FounderInfo{
        address wallet;
        uint8 founderId;
        uint256 amountBNB;
        uint256 numberOfFNFT;
        uint256 buyTime;
        uint256 stakingPoint;
        uint256 unstakingPoint;
        uint256 stakingPeriod;
        bool isOnStaking;
    }

    mapping (address => bool) _isWhiteListed;
    mapping (address => FounderInfo) _founderInfo;
    mapping (uint8 => address) _founderAddress;

    event DepositBNB(address from, uint256 amount, uint256 numberOfFNFT);
    event MintFNFT(address to);
    event StakeFNFT(address from, address to, uint256 id);
    event UnstakeFNFT(address from, address to, uint256 id);
    event RedeemBNB(address from, address to, uint256 amount);
    event Airdrop(address from, address to, uint256 count);

    modifier onlyAdmin() {
        require(msg.sender == _admin, "FNFTFactory: Caller is not owner");
        _;
    }

    modifier isWhiteListed() {
        require(_isWhiteListed[msg.sender], "FNFTFactory: Caller is not whitelisted");
        _;
    }

    modifier isAirdropDiabled() {
        require(block.timestamp - _founderInfo[msg.sender].buyTime > _airdropDuration, "FNFTFactory: Caller is enabled to be airdropped");
        _;
    }

    constructor( address addrBonsai, address addrFNFT) {
        _admin = msg.sender;
        _bonsai = IBEP20(addrBonsai);
        _founderNFT = IFounderNFT(addrFNFT);
        _indexOfFNFT = 0;
        _airdropDuration = 365 days;
        _airdropInterval = 7 days;
        _airdropPercentage = 20;
        _initialBNB = 10 ether;
    }

    function setDevelopmentWallet(address addr) external onlyAdmin {
        _devWallet = addr;
    }

    function setWhitelist(address addr, bool flag) internal {
        _isWhiteListed[addr] = flag;
    }

    function setInitialBNB(uint256 amount) external onlyAdmin {
        _initialBNB = amount;
    }

    function setAirdropDuration(uint256 duration) external onlyAdmin {
        _airdropDuration = duration;
    }

    function setAirdropInterval(uint256 interval) external onlyAdmin {
        _airdropInterval = interval;
    }

    function setAirdropPercentage(uint8 percentage) external onlyAdmin {
        _airdropPercentage = percentage;
    }

    function depositBNB() external payable {
        require(msg.value >= _initialBNB, "FNFTFactory: BNB amount should be more than this.");

        setWhitelist(msg.sender, true);

        for (uint256 numberOfFNFT = 0; numberOfFNFT < msg.value / _initialBNB; numberOfFNFT++) {
            FounderInfo memory founderInfo = FounderInfo(msg.sender, _indexOfFNFT, msg.value, msg.value / _initialBNB, block.timestamp, block.timestamp, 0, 0, false);
            _founderInfo[msg.sender] = founderInfo;
            _founderAddress[_indexOfFNFT] = msg.sender;
            _indexOfFNFT++;
        }

        emit DepositBNB(msg.sender, msg.value, msg.value / _initialBNB);
    }

    function mintFNFT(string memory uri, address holderOfFNFT) external onlyAdmin {
        require(_indexOfFNFT <= _founderNFT.totalSupply(), "FNFTFactory: All of FNFTs are already sent to founders");
        
        // for (uint8 i = 0; i < _indexOfFNFT; i++) {
            _founderNFT.mintFNFT(holderOfFNFT, uri);            

            emit MintFNFT(holderOfFNFT);
        // }
    }

    function stakeFNFT() external isWhiteListed {
        require(!_founderInfo[msg.sender].isOnStaking, "FNFTFactory: This account has already staked the own FNFT");

        _founderNFT.tranferFNFT(msg.sender, address(this), _founderInfo[msg.sender].founderId);
        FounderInfo memory founderInfo = _founderInfo[msg.sender];

        founderInfo.stakingPoint = block.timestamp;
        founderInfo.isOnStaking = true;
        
        _founderInfo[msg.sender] = founderInfo;

        emit StakeFNFT(msg.sender, address(this), _founderInfo[msg.sender].founderId);
    }

    function unstakeFNFT() external isWhiteListed {
        require(_founderInfo[msg.sender].isOnStaking, "FNFTFactory: This account has already unstaked the own FNFT");

        _founderNFT.tranferFNFT(address(this), msg.sender, _founderInfo[msg.sender].founderId);
        _founderInfo[msg.sender].stakingPeriod = _founderInfo[msg.sender].stakingPeriod + block.timestamp - _founderInfo[msg.sender].stakingPoint;
        _founderInfo[msg.sender].unstakingPoint = block.timestamp;
        _founderInfo[msg.sender].isOnStaking = false;

        emit UnstakeFNFT(address(this), msg.sender,  _founderInfo[msg.sender].founderId);
    }

    function airdrop(address founder, uint256 amount) internal {
        uint256 amountExpected = amount;
        if (!_founderInfo[founder].isOnStaking) {
            amountExpected = 0;
        } else {
            // if (_founderInfo[msg.sender].stakingPeriod < _airdropInterval) {
            //     amountExpected = amountExpected.mul(_founderInfo[msg.sender].stakingPeriod).div(_airdropInterval);
            //     _founderInfo[msg.sender].stakingPeriod = 0;
            // } else {
            //     _founderInfo[msg.sender].stakingPeriod = _founderInfo[msg.sender].stakingPeriod - _airdropInterval;
            // }
            if (_airdropInterval != 0)
                amountExpected = amountExpected.mul(_founderInfo[msg.sender].stakingPeriod + block.timestamp - _founderInfo[msg.sender].stakingPoint).div(_airdropInterval);      
            _bonsai.transferFrom(_devWallet, founder, amountExpected);            
            _founderInfo[founder].stakingPoint = block.timestamp;
            _founderInfo[msg.sender].stakingPeriod = 0;
        }

        emit Airdrop(_devWallet, founder, amountExpected);

        // if (_founderInfo[founder].lastAirdropTime - _founderInfo[founder].buyTime > _airdropDuration)
        //     _founderInfo[founder].enabledAirdrop = false;
    }

    function airdrop2All() external onlyAdmin {
        uint256 amount = getAirdropAmountPerFounder();
        require(amount > 0, "FNFTFactory: Balance of Development Wallet is not enough to airdrop");
        for (uint8 i = 0; i < _indexOfFNFT; i++)
            airdrop(_founderAddress[i], amount);
    }

    function redeemBNB() external isWhiteListed isAirdropDiabled {
        require(!_founderInfo[msg.sender].isOnStaking, "FNFTFactory: This account has still staked the own FNFT");
        _founderNFT.tranferFNFT(msg.sender, address(this), _founderInfo[msg.sender].founderId);
        payable(msg.sender).transfer(_founderInfo[msg.sender].amountBNB);

        emit RedeemBNB(address(this), msg.sender, _founderInfo[msg.sender].amountBNB);
    }

    function getAirdropAmountPerFounder() public view returns (uint256) {
        require(_devWallet.balance > 0, "FNFTFactory: Balance of Development Wallet is not enough to pay gas fee");
        return (_bonsai.balanceOf(_devWallet)).mul(_airdropPercentage).div(HUNDRED_PERCENTAGE).div(_founderNFT.totalSupply());
    }

    function getFounderInfo(address founder) public view returns (FounderInfo memory) {
        return _founderInfo[founder];
    }

    receive() payable external { }

    fallback() payable external { }
}