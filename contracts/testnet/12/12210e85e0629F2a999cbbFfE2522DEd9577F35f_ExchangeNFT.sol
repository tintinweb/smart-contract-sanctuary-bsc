// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./utils/Member.sol";
import "./utils/SafeMath.sol";

interface NFTContract {
    function getCardInfo(uint256 tokenId)
        external
        view
        returns (uint256, uint256);
}

contract ExchangeNFT is Member, IERC721Receiver {
    mapping(address => bool) isMyNft;
    mapping(uint256 => bool) isCardGrade; //可交易的卡牌等级
    NFTContract nftAddress;
    using SafeMath for uint256;
    struct OrderInfo {
        bytes32 orderId;
        uint256 tokenId;
        uint256 price;
        address payToken;
        address nftToken;
        address marker;
        address takeMan;
        uint256 finishTime;
        bool isUse;
    }

    event CreateOrder(
        bytes32 orderId,
        address createMan,
        address payToken,
        address nftToken,
        uint256 price,
        uint256 tokenId
    );

    event TakeOrder(
        bytes32 orderId,
        uint256 tokenId,
        uint256 price,
        address payToken,
        address nftToken,
        address marker,
        address takeMan,
        uint256 finishTime
    );
    event Cancel(bytes32 orderId);

    mapping(bytes32 => OrderInfo) order;
    OrderInfo[] public nowOrder;
    OrderInfo[] public takeOrderList;
    uint256 takeFee;
    address feeMan;

    constructor(address _address) {
        isCardGrade[5] = true;
        isCardGrade[6] = true;
        nftAddress = NFTContract(_address);
    }

    function checkCardGrade(uint tokenId)public view returns(bool){

        (uint cardGrade,) = nftAddress.getCardInfo(tokenId);

        return isCardGrade[cardGrade];
    }

    function createOrder(
        uint256 tokenId,
        uint256 price,
        address payToken,
        address nftAddr
    ) public {
        require(isMyNft[nftAddr], "NFT Address Error");
        require(checkCardGrade(tokenId),"Card grade error");
        IERC721(nftAddr).transferFrom(msg.sender, address(this), tokenId);
        bytes32 orderid = keccak256(
            abi.encode(tokenId, msg.sender, block.number)
        );

        order[orderid] = OrderInfo(
            orderid,
            tokenId,
            price,
            payToken,
            nftAddr,
            msg.sender,
            address(0),
            0,
            true
        );
        nowOrder.push(order[orderid]);
        emit CreateOrder(
            orderid,
            msg.sender,
            payToken,
            nftAddr,
            price,
            tokenId
        );
    }

    function takeOrder(bytes32 orderId) public payable {
        OrderInfo storage _takeOrder = order[orderId];
        require(_takeOrder.isUse, "Oder erroe");
        uint256 feeAmount = _takeOrder.price.mul(takeFee).div(1000);
        if (_takeOrder.payToken == address(0)) {
            require(msg.value >= _takeOrder.price);
            payable(feeMan).transfer(feeAmount);
            payable(_takeOrder.marker).transfer(
                _takeOrder.price.sub(feeAmount)
            );
        } else {
            IERC20(_takeOrder.payToken).transfer(feeMan, feeAmount);
            IERC20(_takeOrder.payToken).transfer(
                _takeOrder.marker,
                _takeOrder.price.sub(feeAmount)
            );
        }
        _takeOrder.finishTime = block.timestamp;
        _takeOrder.takeMan = msg.sender;
        _takeOrder.isUse = false;
        IERC721(_takeOrder.nftToken).transferFrom(
            address(this),
            msg.sender,
            _takeOrder.tokenId
        );
        takeOrderList.push(_takeOrder);
        delete order[orderId];
        uint256 index = getOrderIndex(orderId);
        if (index != 0) {
            delete nowOrder[index - 1];
        }
        emit TakeOrder(
            orderId,
            _takeOrder.tokenId,
            _takeOrder.price,
            _takeOrder.payToken,
            _takeOrder.nftToken,
            _takeOrder.marker,
            msg.sender,
            block.timestamp
        );
    }

    function getOrderIndex(bytes32 orderId) private view returns (uint256) {
        uint256 index = 0;
        for (uint256 i = 0; i != nowOrder.length; ++i) {
            if (orderId == nowOrder[i].orderId) {
                index = i + 1;
                break;
            }
        }
        return index;
    }

    function cancelOrder(bytes32 orderId) public {
        require(msg.sender == order[orderId].marker, "It is not you order");
        require(order[orderId].takeMan == address(0), "Order has takeMan ");
        require(order[orderId].finishTime == 0, "Order has finishTime ");
        address owner = IERC721(order[orderId].nftToken).ownerOf(
            order[orderId].tokenId
        );
        require(owner == address(this), "NFT token error");
        uint256 tokenId = order[orderId].tokenId;
        address nfdAddr = order[orderId].nftToken;
        delete order[orderId];
        uint256 index = getOrderIndex(orderId);
        if (index != 0) {
            delete nowOrder[index - 1];
        }
        IERC721(nfdAddr).transferFrom(address(this), msg.sender, tokenId);
        emit Cancel(orderId);
    }

    function setNftAddress(address addr, bool status)
        public
        CheckPermit("Config")
    {
        isMyNft[addr] = status;
    }

    function setNftGrade(uint256 _grade, bool _isUser)
        public
        CheckPermit("Config")
    {
        isCardGrade[_grade] = _isUser;
    }

    function setFee(uint256 _fee, address _feeMan)
        public
        CheckPermit("Config")
    {
        takeFee = _fee;
        feeMan = _feeMan;
    }

    function getAllTakeOeder() public view returns (OrderInfo[] memory) {
        return takeOrderList;
    }

    function getAllNowOeder() public view returns (OrderInfo[] memory) {
        return nowOrder;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) public override returns (bytes4) {
        return this.onERC721Received.selector;
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

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
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

pragma solidity ^0.8.0;

// SPDX-License-Identifier: SimPL-2.0

import "./Manager.sol"; // done

// 抽象生成合约
abstract contract Member {
    // 修饰 检查当前用户string行为的许可
    modifier CheckPermit(string memory permit) {
        require(manager.userPermits(msg.sender, permit),
            "no permit");
        _;
    }

     modifier ContractOwnerOnly {
        // 只有合约拥有者可以调用
        require(msg.sender == admin, "contract owner only");
        _;
    }

    // 生成manager(经理)
    Manager public manager;

    address public  admin;

    address public newAdmin;

    constructor(){
      admin = msg.sender;
    }

    
    // 迁移
    function setManager(address addr) external ContractOwnerOnly {
        manager = Manager(addr);
    }

     function setNewAdmin (address _newAdmin) external ContractOwnerOnly {
        require(admin == msg.sender,"you are not admin");
        newAdmin = _newAdmin;
    }
    
    function getNewAdmin () public {
        require(newAdmin == msg.sender,"you are not newAdmin");
        admin = msg.sender;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
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

pragma solidity ^0.8.0;

// SPDX-License-Identifier: SimPL-2.0

import "./ContractOwner.sol"; // done

// 全局导入拥有权限
contract Manager is ContractOwner {

    // 映射members(成员)
    mapping(string => address) public members;

    // 映射userPermits(用户许可)  地址 => string => bool
    mapping(address => mapping(string => bool)) public userPermits;
    
    // 修改|添加|删除 member(成员)
    function setMember(string memory name, address member)
        external ContractOwnerOnly {
        
        members[name] = member;
    }
    
    // 修改|添加|删除 userPermit(用户许可) 
    function setUserPermit(address user, string memory permit,
        bool enable) external ContractOwnerOnly {
        
        userPermits[user][permit] = enable;
    }
    
    // 获得当前时间戳
    function getTimestamp() external view returns(uint256) {
        return block.timestamp;
    }
}

pragma solidity ^0.8.0;

// SPDX-License-Identifier: SimPL-2.0

abstract contract ContractOwner {
    //　合约拥有者
    address public contractOwner = msg.sender; 
    
    modifier ContractOwnerOnly {
        // 只有合约拥有者可以调用
        require(msg.sender == contractOwner, "contract owner only");
        _;
    }
}