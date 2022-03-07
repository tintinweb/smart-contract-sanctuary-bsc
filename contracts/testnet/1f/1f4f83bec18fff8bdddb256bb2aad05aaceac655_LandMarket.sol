/**
 *Submitted for verification at BscScan.com on 2022-03-07
*/

// SPDX-License-Identifier: MIT

// File: @openzeppelin\contracts\utils\math\SafeMath.sol

// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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

// File: contracts\Market\MarketStore.sol


pragma solidity ^0.8.9;

contract MarketStore{
    uint public shopLandCount = 0;

    struct LandSale {
        uint landId;
        uint8 landType;
        address seller;
        uint price;
        uint timestamp;
        uint thawingTime;
    }

    // LandMarket
    mapping (uint => LandSale) LandSales;
}

// File: @openzeppelin\contracts\utils\introspection\IERC165.sol

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

// File: @openzeppelin\contracts\token\ERC721\IERC721.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

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

// File: contracts\interfaces\ILandCore.sol


pragma solidity ^0.8.9;
interface ILandCore is IERC721 {
    event NewLand(address indexed to, uint indexed landId, uint8 landType, uint landPrice, uint landNumber, uint _timeStamp);
    event setLTConfig(uint8 landType, uint256 landPrice, uint256 landTotalNumber, uint256 landNumber);
    event updateLTConfig(uint8 landType, uint256 landPrice, uint256 landTotalNumber, uint256 landNumber);
    
    function getDataAdmin() external view returns(address);
    function safeTransferByMainContract(address from, address to, uint256 tokenId) external;
    function getLandTokenIds() external view returns(uint[] memory);
}

// File: contracts\interfaces\ILandMarket.sol


pragma solidity ^0.8.9;

interface ILandMarket {
    event PutShopLand(uint indexed landId, uint8 landType, address indexed seller, uint price, uint _timeStamp);
    event GetOffShopLand(uint indexed landId, uint8 landType, address indexed seller, uint _timeStamp);
    event BuyShopLand(uint indexed landId, uint8 landType, address indexed buyer, address indexed seller, uint price, uint _timeStamp);
    function putShopLand(uint _landId, uint8 _landType, uint _sellPrice) external returns(uint);
    function getOffShopLand(uint _landId, uint8 _landType) external returns(uint);
    function getShopByLandId(uint _landId) external view returns(address, uint, uint, uint);
    function delLandSalesInfo(uint _landId) external;
    function addLandSalesInfo(uint _landId, uint8 _landType, address _seller, uint _sellPrice) external;
}

// File: contracts\Dependency\FyFarmDep.sol


pragma solidity ^0.8.9;

contract FyFarmDep{
    address public whitelistSetterAddress;
    address public fyTokenAddress;
    address public landCoreAddress;
    address public landMarketAddress;
    address[] private fyFarmDeps;

    uint public minPrice = 10 * (10 ** 9);
    address owner;

    event SetFarmDeps(address _op , address _delAddr);
    event DelFarmDeps(address _op , address _delAddr);
    
    constructor() {
        owner = msg.sender;
        whitelistSetterAddress = msg.sender;
    }

    modifier onlyWhitelistSetter() {
        require(msg.sender == whitelistSetterAddress || msg.sender == owner);
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function setWhitelistSetter(address _newSetter) external onlyOwner {
        whitelistSetterAddress = _newSetter;
    }

    function setFyToken(address _newAddress) external onlyWhitelistSetter {
        fyTokenAddress = _newAddress;
        fyFarmDeps.push(_newAddress);
    }

    function setLandCore(address _newAddress) external onlyWhitelistSetter {
        landCoreAddress = _newAddress;
        fyFarmDeps.push(_newAddress);
    }

    function setLandMarket(address _newAddress) external onlyWhitelistSetter {
        landMarketAddress = _newAddress;
        fyFarmDeps.push(_newAddress);
    }

    function setMinPrice(uint _value) external onlyWhitelistSetter{
        minPrice = _value;
    }

    function setFarmDeps(address _newAddress) external onlyOwner{
        fyFarmDeps.push(_newAddress);
        emit SetFarmDeps(msg.sender, _newAddress);
    }

    function delFarmDeps(address _address) external onlyOwner{
        for (uint i = 0; i < fyFarmDeps.length; i++){
            if (fyFarmDeps[i] == _address) {
                fyFarmDeps[i] = address(0);
            }
        }
        emit DelFarmDeps(msg.sender, _address);
    }

    function getFarmDeps() public view returns(address[] memory) {
        return fyFarmDeps;
    }
}

// File: contracts\Market\MarketService.sol


pragma solidity ^0.8.9;
abstract contract MarketService is MarketStore, ILandMarket{
    using SafeMath for uint256;

    uint public freezeTime = 30 minutes;
    uint public commissionRate = 500;
    FyFarmDep internal fyFarmDep;
    address internal owner;

    modifier onlyOwner() {
        require(msg.sender == owner,'sender is not matched');
        _;
    }

    modifier landOnlyOwnerOf(uint _landId) {
        ILandCore landCoreInter = ILandCore(fyFarmDep.landCoreAddress());
        require(msg.sender == landCoreInter.ownerOf(_landId),'The landowner is not you');
        _;
    }

    modifier unlockThawing(uint _landId){
        require( LandSales[_landId].thawingTime <= block.timestamp, "is freeze time");
        _;
    }

    modifier onlyLandMarketDep() {
        address[] memory deps = fyFarmDep.getFarmDeps();
        address depAddress;
        for (uint i = 0; i < deps.length;i++) {
            if (msg.sender == deps[i]) {
                depAddress = deps[i];
                break;
            }
        }
        require(msg.sender == depAddress, "is not landMarket dependency");
        _;
    }

    function delLandSalesInfo(uint _landId) external override onlyLandMarketDep{
        if (LandSales[_landId].landId != 0) {
            LandSale memory _ls = LandSales[_landId];
            delete LandSales[_landId];
            shopLandCount = shopLandCount.sub(1);
            emit GetOffShopLand(_landId, _ls.landType, _ls.seller, block.timestamp);
        }
    }

    function addLandSalesInfo(uint _landId, uint8 _landType, address _seller, uint _sellPrice) external override onlyLandMarketDep{
        if (LandSales[_landId].landId == 0) {
            LandSales[_landId] = LandSale(_landId, _landType, _seller, _sellPrice, block.timestamp, block.timestamp + freezeTime);
            shopLandCount = shopLandCount.add(1);
        }
    }

    function setFreezeTime(uint _freezeTime) external onlyOwner{
        freezeTime = _freezeTime;
    }

    function setCommissionRate(uint _commissionRate) external onlyOwner{
        commissionRate = _commissionRate;
    }
}

// File: @openzeppelin\contracts\token\ERC20\IERC20.sol

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

// File: contracts\interfaces\IFYToken.sol


pragma solidity ^0.8.9;
interface IFYToken is IERC20 {
    // function transferAccount(
    //     address from,
    //     address to,
    //     uint256 amount
    // ) external returns (bool);

    function transferAccountToAddress(address from, uint256 amount)
        external
        returns (bool);

    function transferToAddress(
        address from,
        uint256 amount,
        address to,
        uint256 commission
    ) external returns (bool);

    function getCapValue() external view returns (uint256);
}

// File: contracts\Market\LandMarket.sol


pragma solidity ^0.8.9;
contract LandMarket is MarketService{
    using SafeMath for uint256;
    constructor(address _fyFarmDep){
        fyFarmDep = FyFarmDep(_fyFarmDep);
        owner = msg.sender;
    }

    function putShopLand(uint _landId, uint8 _landType, uint _sellPrice) external override landOnlyOwnerOf(_landId) returns(uint){
        require(LandSales[_landId].landId == 0, "The land on the shop");
        IFYToken fyTokenInter = IFYToken(fyFarmDep.fyTokenAddress());
        require(_sellPrice >= fyFarmDep.minPrice() && _sellPrice < fyTokenInter.getCapValue(), 'Your price must > minPrice and < capValue');
        LandSales[_landId] = LandSale(_landId, _landType, msg.sender, _sellPrice, block.timestamp, block.timestamp + freezeTime);
        shopLandCount = shopLandCount.add(1);
        emit PutShopLand(_landId, _landType, msg.sender, _sellPrice, block.timestamp);
        return _landId;
    }

    function getOffShopLand(uint _landId, uint8 _landType) external override landOnlyOwnerOf(_landId) unlockThawing(_landId) returns(uint){
        require(LandSales[_landId].landId != 0, "The land is not on the shop");
        delete LandSales[_landId];
        shopLandCount = shopLandCount.sub(1);
        emit GetOffShopLand(_landId, _landType, msg.sender, block.timestamp);
        return _landId;
    }

    function buyShopLand(uint _landId, uint8 _landType) public {
        LandSale memory _landSale = LandSales[_landId];
        require(_landSale.landId != 0, "The land is not on the shop");
        require(_landSale.seller != address(0), "This land get off shop");
        require(msg.sender != _landSale.seller,'seller is yourself');
        IFYToken fyTokenInter = IFYToken(fyFarmDep.fyTokenAddress());
        uint commission = _landSale.price.mul(commissionRate).div(10000);
        fyTokenInter.transferToAddress(msg.sender, _landSale.price, _landSale.seller, commission);
        ILandCore landCoreInter = ILandCore(fyFarmDep.landCoreAddress());
        landCoreInter.safeTransferByMainContract(_landSale.seller, msg.sender, _landId);
        emit BuyShopLand(_landId, _landType, msg.sender, _landSale.seller, _landSale.price, block.timestamp);
    }

    function getShopLand() external view returns(LandSale[] memory) {
        ILandCore landCoreInter = ILandCore(fyFarmDep.landCoreAddress());
        uint[] memory _LandTokenIds = landCoreInter.getLandTokenIds();
        LandSale[] memory result = new LandSale[](shopLandCount);
        uint counter = 0;
        for (uint i = 0; i < _LandTokenIds.length; i++) {
            uint key = _LandTokenIds[i];
            if (LandSales[key].price != 0) {
                result[counter] = LandSales[key];
                counter++;
            }
        }
        return result;
    }

    function getShopByLandId(uint _landId) external view override returns(address, uint, uint, uint) {
        return (LandSales[_landId].seller, LandSales[_landId].price, LandSales[_landId].timestamp, LandSales[_landId].thawingTime);
    }
}