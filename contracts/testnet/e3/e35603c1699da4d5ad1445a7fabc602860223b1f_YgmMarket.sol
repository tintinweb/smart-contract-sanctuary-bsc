/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

// SPDX-License-Identifier: MIT



pragma solidity ^0.8.0;


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

interface IERC20 {

    function allowance(address owner, address spender) external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

}


interface IERC721 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    // event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    // /**
    //  * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
    //  */
    // event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    // /**
    //  * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
    //  */
    // event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    // function balanceOf(address owner) external view returns (uint256 balance);

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
    // function transferFrom(
    //     address from,
    //     address to,
    //     uint256 tokenId
    // ) external;

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
    // function approve(address to, uint256 tokenId) external;

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
    // function setApprovalForAll(address operator, bool _approved) external;

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
    // function isApprovedForAll(address owner, address operator) external view returns (bool);
}



contract YgmMarket is Ownable {

    using SafeMath for uint256;
    

    mapping(address => bool) public noSell;

    uint maxFee = 10000;
    uint defFee;
    address  platformAddress;
    mapping(address => uint)  platformFee;

    mapping(address => uint) public businessFee;
    mapping(address => address) public businessAddress;
    mapping(address => address) public payContract;


    mapping(address => mapping(uint => uint)) tokenAmount;

    mapping(address => mapping(uint => bool)) isLock;

    event BuildProject(address indexed _contract, address _payContract, uint _businessFee, address _businessAddress);
    event Shelves(address indexed seller, address indexed _contract, uint indexed tokenId, address _payContract, uint amount, uint timestamp);
    event Cancel(address indexed seller, address indexed _contract, uint indexed tokenId, address _payContract, uint amount, uint timestamp);
    event Buy(address indexed seller, address indexed buyer, address  _contract, uint indexed tokenId, address _payContract, uint amount, uint platformRate, uint businessRate, uint timestamp);


    constructor(address _address, uint _rate){
        setPlatformAddress(_address);
        setPlatformDefFee(_rate);
    }



    function getPlatformAddress() external view onlyOwner returns(address){
        return platformAddress;
    }


    function getPlatformFee(address _contract) public view  returns(uint){
        if(address(0) == _contract){
            return defFee;
        }else{
            return 0 == platformFee[_contract] ? defFee : platformFee[_contract];
        }
    }

    function getSellAmount(address _contract, uint _tokenId) external view returns(uint){
        return tokenAmount[_contract][_tokenId];
    }


    function _getFee(uint _amount, uint _platformRate, uint _businessRate) private view returns(uint){
        uint sumRate = _platformRate.add(_businessRate);
        return _amount.mul(sumRate).div(maxFee);
    }




    

    function buildProject(address _contract, address _payContract, uint _businessFee, address _businessAddress) external  _nft_owner(_contract) {
       
        payContract[_contract] = _payContract;
        
        uint feeTotal = _businessFee.add(maxFee);
        require(feeTotal < maxFee, 'Fee too large');
        businessFee[_contract] = _businessFee;

        if(address(0) == _businessAddress){
            address sender = _msgSender();
            businessAddress[_contract] = sender;
        }else{
            businessAddress[_contract] = _businessAddress;
        }

        emit BuildProject(_contract, _payContract, _businessFee, _businessAddress);

    }



    function shelves(address _contract, uint tokenId, uint amount) external {

        require(!noSell[_contract], 'The nft can not sell');
        
        require(0 == tokenAmount[_contract][tokenId], 'Nft is selling');
        
        address sender = _msgSender();
        IERC721 nft = IERC721(_contract);
        require(sender == IERC721(_contract).ownerOf(tokenId), 'Nft owner is not sender');

        require(address(this) == nft.getApproved(tokenId), 'Nft unapprove');

        tokenAmount[_contract][tokenId] = amount;

        emit Shelves(sender, _contract, tokenId, address(0) == payContract[_contract] ? address(0) : payContract[_contract], amount, block.timestamp);
    }



    function cancel(address _contract, uint tokenId) external {
        
        require(0 < tokenAmount[_contract][tokenId], 'Nft is canceled');
        
        address sender = _msgSender();

        IERC721 nft = IERC721(_contract);

        require(sender == nft.ownerOf(tokenId), 'Nft owner is not sender');

        uint sellAmount = tokenAmount[_contract][tokenId];
        tokenAmount[_contract][tokenId] = 0;

        emit Cancel(sender, _contract, tokenId, address(0) == payContract[_contract] ? address(0) : payContract[_contract], sellAmount, block.timestamp);
    }



    function buy(address _contract, uint tokenId) payable external locked(_contract, tokenId) {

        require(!noSell[_contract], 'The nft can not sell');

        uint sellAmount = tokenAmount[_contract][tokenId];
        require(0 < sellAmount, 'Nft already buyed');

        IERC721 nft = IERC721(_contract);
        address _nftOwner = nft.ownerOf(tokenId);
        address _sender = _msgSender();

        uint _platformRate = getPlatformFee(_contract);
        uint _businessRate = businessFee[_contract];
        uint fee = _getFee(sellAmount, _platformRate, _businessRate);
        
        address payType = payContract[_contract];
        if(address(0) == payType){
            require(msg.value == sellAmount, 'Pay amount invalid');
            payable(platformAddress).transfer(fee);
            payable(_nftOwner).transfer(sellAmount.sub(fee));
        }else{
            IERC20 erc = IERC20(payType);
            uint _allowance = erc.allowance(_sender, address(this));
            require(_allowance >= sellAmount, 'Insufficient number of authorizations');
            erc.transferFrom(_sender, platformAddress, fee);
            erc.transferFrom(_sender, _nftOwner, sellAmount.sub(fee));
        }

        nft.safeTransferFrom(_nftOwner, _sender, tokenId);
        tokenAmount[_contract][tokenId] = 0;
        
        emit Buy(_nftOwner, _sender, _contract, tokenId,  payType, sellAmount, _platformRate, _businessRate,  block.timestamp);
    }





    function swichSell(address _contract) external  onlyOwner {
        noSell[_contract] = !noSell[_contract];
    }


    function setPlatformDefFee(uint _amount) public onlyOwner {
        defFee = _amount;
    }

    function setPlatformAddress(address _address) public onlyOwner {
        platformAddress = _address;
    }

    function setPlatformFee(address _contract, uint _amount) external onlyOwner {
        platformFee[_contract] = _amount;
    }


    


    // check nft owner
    modifier _nft_owner(address _contract){
        address sender = _msgSender();

        address _owner = Ownable(_contract).owner();

        require(_owner == sender, 'Not owner');
        
        _;
    }


     modifier locked(address _contract, uint tokenId){
        require(!isLock[_contract][tokenId], 'Nft is buying');
        isLock[_contract][tokenId] = true;
        _;
        isLock[_contract][tokenId] = false;
    }

}