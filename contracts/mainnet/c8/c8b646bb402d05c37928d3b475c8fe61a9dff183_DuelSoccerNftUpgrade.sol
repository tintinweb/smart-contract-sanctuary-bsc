/**
 *Submitted for verification at BscScan.com on 2022-08-30
*/

// SPDX-License-Identifier: MIT
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
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

contract DuelSoccerNftUpgrade is Ownable {

    IERC20 public feeToken;
    IERC721 public nft;
    bool public initialised;
    uint256 public updatingStartTime;

    constructor(IERC721 _nft, IERC20 _feeToken) {
        nft = _nft;
        feeToken = _feeToken;  
    }

    struct Spec {
        uint256 Speed;
        uint256 JumpSpeed;
        uint256 Shot;
        uint256 Dribbling;
    }

    mapping(uint256 => Spec) public Specs;

    event Updated(uint256 tokenId, uint256 upgradeType);
    
    uint[] successRates = [100,100,90,80,60,50,40,30,20];
    uint[] feeRates = [5,5,5,5,5,10,20,30,100];
    
    
    function getSelectedSpecs(uint256[] calldata _targets) 
        public 
        view 
        returns (uint256[] memory _tSpecs) 
    {
        uint256[] memory _targetSpecs = new uint256[]((_targets.length*4));
        uint _t = 0;

        for (uint i = 0; i < _targets.length; i++) {
            Spec storage spec = Specs[_targets[i]];
            _targetSpecs[_t] = spec.Speed;_t++;
            _targetSpecs[_t] = spec.JumpSpeed;_t++;
            _targetSpecs[_t] = spec.Shot;_t++;
            _targetSpecs[_t] = spec.Dribbling;_t++;
            
        }
        return _targetSpecs;
    }

    function setFeeRates(uint[] memory _nv) public onlyOwner {
        require(_nv.length == 9 , "DuelNftSoccer: Wrong Value for FeeRates");
        feeRates = _nv;
    }

    function setSuccessRates(uint[] memory _nv) public onlyOwner {
        require(_nv.length == 9 , "DuelNftSoccer: Wrong Value for SuccessRates");
        successRates = _nv;
    }

    function startUpdating() public onlyOwner {
        require(!initialised, "DuelNftSoccer: Already started");
        updatingStartTime = block.timestamp;
        initialised = true;
    }

    function stopUpdating() public onlyOwner {
        require(initialised, "DuelNftSoccer: Already stopped");
        updatingStartTime = 0;
        initialised = false;
    }

    function getSuccessRate(uint256 _element)
        public
        view
        returns (uint256 value)
    {
        return successRates[_element];
    }

    function getFeeRate(uint256 _element)
        public
        view
        returns (uint256 value)
    {
        return feeRates[_element];
    }

    function getTokenSpeed(uint256 _tokenId)
        public
        view
        returns (uint256 Speed)
    {   
        return Specs[_tokenId].Speed;
    }

    function getTokenJumpSpeed(uint256 _tokenId)
        public
        view
        returns (uint256 JumpSpeed)
    {
        return Specs[_tokenId].JumpSpeed;
    }

    function getTokenShot(uint256 _tokenId)
        public
        view
        returns (uint256 Shot)
    {
        return Specs[_tokenId].Shot;
    }

    function getTokenDribbling(uint256 _tokenId)
        public
        view
        returns (uint256 Dribbling)
    {
        return Specs[_tokenId].Dribbling;
    }

    function setTokenSpecs(uint256 _tokenId, uint256 _speed, uint256 _jumpspeed, uint256 _shot, uint256 _dribbling)
        public onlyOwner
    {   
        require(_speed > 0 && _speed < 11 , "DuelNftSoccer: Wrong Value for Speed");
        require(_jumpspeed > 0 && _jumpspeed < 11 , "DuelNftSoccer: Wrong Value for Jumpspeed");
        require(_shot > 0 && _shot < 11 , "DuelNftSoccer: Wrong Value for Shot");
        require(_dribbling > 0 && _dribbling < 11 , "DuelNftSoccer: Wrong Value for Dribbling");
        require(initialised, "DuelNftSoccer: updating has not active yet");

        Spec storage spec = Specs[_tokenId];
        spec.Speed = _speed;
        spec.JumpSpeed = _jumpspeed;
        spec.Shot = _shot;
        spec.Dribbling = _dribbling;

    }
    
    function withdrawErc20(uint256 _amount) public onlyOwner() {
        feeToken.transfer(msg.sender, (_amount*10**18));
    }

    function upgrade(uint256 tokenId, uint256 upgradeType) public {
        _upgrade(msg.sender, tokenId, upgradeType);
    }

    function getFee(uint256 _i) internal {
        uint256 priceToPay = feeRates[(_i-1)]*10**18;
        feeToken.transferFrom(msg.sender,address(this),priceToPay);
    }

    function _upgrade(address _user, uint256 _tokenId, uint256 _upgradeType ) internal {

        require(initialised, "DuelNftSoccer: updating has been stopped");
        require(_upgradeType > 0 && _upgradeType < 5 , "DuelNftSoccer: Wrong Value for Upgrade Type");
        require(
            nft.ownerOf(_tokenId) == _user,
            "DuelNftSoccer: User must be the owner of the token"
        );

        Spec storage spec = Specs[_tokenId];
        uint _newspec;
        uint _rh = (uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % 100) % 100;

        if (_upgradeType == 1) {
            _newspec = spec.Speed > 0 ? spec.Speed : 1;
            require(_newspec < 11 , "DuelNftSoccer: Speed Property is Already in Max Level");
            getFee(_newspec);
            if (successRates[(_newspec-1)] == 100){
                spec.Speed = _newspec+1;
            }
            else {
                if ( _rh >= (100 - successRates[(_newspec-1)]) ) {
                    spec.Speed = _newspec+1;
                }
            }
        }
        else if (_upgradeType == 2) {
            _newspec = spec.JumpSpeed > 0 ? spec.JumpSpeed : 1;
            require(_newspec < 11 , "DuelNftSoccer: JumpSpeed Property is Already in Max Level");
            getFee(_newspec);
            if (successRates[(_newspec-1)] == 100){
                spec.JumpSpeed = _newspec+1;
            }
            else {
                if ( _rh >= (100 - successRates[(_newspec-1)]) ) {
                    spec.JumpSpeed = _newspec+1;
                }
            }
        }
        else if (_upgradeType == 3) {
            _newspec = spec.Shot > 0 ? spec.Shot : 1;
            require(_newspec < 11 , "DuelNftSoccer: Shot Property is Already in Max Level");
            getFee(_newspec);
            if (successRates[(_newspec-1)] == 100){
                spec.Shot = _newspec+1;
            }
            else {
                if ( _rh >= (100 - successRates[(_newspec-1)]) ) {
                    spec.Shot = _newspec+1;
                }
            }
        }
        else {
            _newspec = spec.Dribbling > 0 ? spec.Dribbling : 1;
            require(_newspec < 11 , "DuelNftSoccer: Dribbling Property is Already in Max Level");
            uint256 priceToPay = feeRates[(_newspec-1)]*10**18;
            feeToken.transferFrom(msg.sender,address(this),priceToPay);
            if (successRates[(_newspec-1)] == 100){
                spec.Dribbling = _newspec+1;
            }
            else {
                if ( _rh >= (100 - successRates[(_newspec-1)]) ) {
                    spec.Dribbling = _newspec+1;
                }
            }
        }

        emit Updated(_tokenId, _upgradeType);
    }
    
}