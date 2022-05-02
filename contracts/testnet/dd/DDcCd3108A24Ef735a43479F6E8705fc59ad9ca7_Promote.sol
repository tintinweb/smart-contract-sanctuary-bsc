// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "../Utils/IERC20.sol";
import "../Utils/IERC721.sol";
import "../Utils/SafeMath.sol";
import "../Utils/SafeERC20.sol";
import "../Manager/Member.sol";



interface INFT{
    function transferFrom(address _from,address _to,uint256 _tokenId)external;
    function approve(address _approved,uint256 _tokenId) external;
    function safeTransferFrom(address _from,address _to,uint256 _tokenId) external;
    function viewTokenID() view external returns(uint256);
    function setTokenTypeAttributes(uint256 _tokenId,uint8 _typeAttributes,uint256 _tvalue) external;
    function transferList(address _to,uint256[] calldata _tokenIdList) external;
    function ownerOf(uint256 _tokenID) external returns (address _owner);
    function starAttributes(uint256 _tokenID) external view returns(address,string memory,uint256,uint256,uint256,bool,uint256);
}

contract LimitTimeAuction is Member {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;


    mapping(uint256 => AuctionOrder) private makerOrders;
    uint256 public  txFees = 200;
    IERC20 public usdt;
    IERC20 public mp;


    event CreateOrder(address indexed creater, uint256 tokenid,uint256 start, uint256 end, uint256 acutionAmount, uint8 payment);
    event HighestBidIncreased(address bidder, uint amount, uint256 tokenid, uint8 payment);
    event AuctionEnded(address winner, uint amount, uint8 payment, uint256 tokenid);
    event ChangeTxFee(uint256 txFees,uint256 newTxFee);
    event ChangeStampFee(uint256 txFees,uint256 newStampFee);
    event CancelAuction(uint256 tokenid,address maker,uint256 timestamp);
    event NewFee(uint8 payment, uint256 payAmount);
  


    struct AuctionOrder {
        address     maker;         //发起者
        address     highestBidder;        //最高拍卖者地址
    
        uint256     nftid;
        uint256     auctionAmount;       //拍卖价格
        uint256     startTime;       //拍卖开始时间
        uint256     endTime;
        bool        isBid;       //是否拍卖出去
        uint8       payment;
    }



    constructor(IERC20 _usdt, IERC20 _mp)
         {
            usdt = _usdt;
            mp = _mp;
    }

    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function createAuction(uint256 tokenid, uint256 acutionPrice,uint256 auctionStartTime, uint256 auctionEndTime,uint8 payment) external {    //创建订单
        require(makerOrders[tokenid].maker == address(0), "Exists Auction!");
        require(
            block.timestamp < auctionEndTime ,
            "Auction end!"
        );
        (,,,,,bool isOffical,) = INFT(manager.members("nft")).starAttributes(tokenid);
        if(isOffical == true) {
            require(payment == 2, "offical NFT can only support MP token");
        }
        IERC721(manager.members("nft")).transferFrom(msg.sender, address(this), tokenid);   //调用者转入自身token到本合约
        makerOrders[tokenid].maker = msg.sender;
        makerOrders[tokenid].highestBidder = address(0);
        
        makerOrders[tokenid].nftid = tokenid;
        makerOrders[tokenid].auctionAmount = acutionPrice;
        makerOrders[tokenid].startTime = auctionStartTime;
        makerOrders[tokenid].endTime = auctionEndTime;
        makerOrders[tokenid].isBid = false;
        makerOrders[tokenid].payment = payment;
        emit CreateOrder(msg.sender, tokenid, auctionStartTime, auctionEndTime, acutionPrice, payment);
    }



    function bid(uint256 tokenid, uint256 acutionAmount) public payable {
        require(msg.sender == tx.origin,"Only EOA!");
        require(
            block.timestamp >= makerOrders[tokenid].startTime ,
            "Auction not start."
        );
        require(
            block.timestamp <= makerOrders[tokenid].endTime ,
            "Auction already ended."
        );

        // 如果出价不够高，返还你的钱
        require(
            acutionAmount > makerOrders[tokenid].auctionAmount,
            "There already is a higher bid."
        );
        require(!isContract(msg.sender), "Address: call to non-contract");

        uint8 payment = makerOrders[tokenid].payment;
        if (payment == 0) {
            require(msg.value == acutionAmount);
            if (makerOrders[tokenid].highestBidder != address(0)) {
          
                payable(makerOrders[tokenid].highestBidder).transfer(makerOrders[tokenid].auctionAmount);
             }
        } else {
            IERC20 token;
            if (payment == 1) {
                token = usdt;
            }
            if (payment == 2) {
                token = mp;
            } 
            IERC20(token).transferFrom(msg.sender, address(this), acutionAmount);
            if (makerOrders[tokenid].highestBidder != address(0)) {
                IERC20(token).transfer(makerOrders[tokenid].highestBidder, makerOrders[tokenid].auctionAmount);
            }
        }
        makerOrders[tokenid].highestBidder = msg.sender;
        makerOrders[tokenid].auctionAmount = acutionAmount;
        makerOrders[tokenid].isBid = true;
        emit HighestBidIncreased(msg.sender, acutionAmount, tokenid, payment);
    }


    function cancelAuction(uint256 tokenid) public {     
        // require(block.timestamp > makerOrders[tokenid].startTime ,"Auction not start.");
        require(block.timestamp < makerOrders[tokenid].endTime, "Auction has ended.");
        require(msg.sender ==  makerOrders[tokenid].maker, "Only maker.");
        uint8 payment = makerOrders[tokenid].payment;
        if(makerOrders[tokenid].isBid){            //if someone bid
            if (payment == 0) {
                
                if (makerOrders[tokenid].highestBidder != address(0)) {
            
                    payable(makerOrders[tokenid].highestBidder).transfer(makerOrders[tokenid].auctionAmount);
                }
            } else {
                IERC20 token;
                if (payment == 1) {
                    token = usdt;
                }
                if (payment == 2) {
                    token = mp;
                } 
                
                if (makerOrders[tokenid].highestBidder != address(0)) {
                    IERC20(token).transfer(makerOrders[tokenid].highestBidder, makerOrders[tokenid].auctionAmount);
                }
            }
        }
        IERC721(manager.members("nft")).transferFrom(address(this),makerOrders[tokenid].maker,tokenid);
        emit CancelAuction(tokenid,msg.sender,block.timestamp);
        delete makerOrders[tokenid];
    }

    function getAuctionOrder(uint256 tokenid) external view returns(AuctionOrder memory) {
        return makerOrders[tokenid];
    }

    /// 结束拍卖
    function auctionEnd(uint256 tokenid) public payable {
        require(msg.sender == tx.origin,"Only EOA!");
        require(block.timestamp >= makerOrders[tokenid].endTime, "Auction not yet ended.");
        uint8 payment = makerOrders[tokenid].payment;
        if(makerOrders[tokenid].isBid){
            IERC721(manager.members("nft")).transferFrom(address(this),makerOrders[tokenid].highestBidder,tokenid);

            (address origin,,,,uint256 stampFees,,uint256 nftCreateTime) = INFT(manager.members("nft")).starAttributes(tokenid);
            
              //收取手续费
            uint256 fee = getTxFee(nftCreateTime);
            uint256 tradeFee = makerOrders[tokenid].auctionAmount.mul(fee.sub(stampFees)).div(1000);   // 扣掉版稅，剩下當作手續費

            uint256 stampFee = makerOrders[tokenid].auctionAmount.mul(stampFees).div(1000);
            uint256 sendAmount = makerOrders[tokenid].auctionAmount.sub(tradeFee).sub(stampFee);
            
            if (payment == 0) {
            
                payable(manager.members("funder")).transfer(tradeFee);
                payable(origin).transfer(stampFee);
                payable(makerOrders[tokenid].maker).transfer(sendAmount);
                emit NewFee(payment, tradeFee);
            } else {
                IERC20 token;
                if (payment == 1) {
                    token = usdt;
                }
                if (payment == 2) {
                    token = mp;
                } 
                IERC20(token).transfer(manager.members("funder"), tradeFee);
                IERC20(token).transfer(origin, stampFee);
                IERC20(token).transfer(makerOrders[tokenid].maker,sendAmount);
                
                emit NewFee(payment, tradeFee);
            }
        }
        else{       //流拍
            IERC721(manager.members("nft")).transferFrom(address(this),makerOrders[tokenid].maker,tokenid);
        }
        emit AuctionEnded(makerOrders[tokenid].highestBidder,makerOrders[tokenid].auctionAmount, payment, tokenid);        
        delete makerOrders[tokenid];
    }

    function setTxFee(uint256 newTxFee) public {
        require(msg.sender == manager.members("owner"));
        require(newTxFee <= 200, "tx Fee to high!");    // max 20%
        emit ChangeTxFee(txFees,newTxFee);
        txFees = newTxFee;
       
    }


    function getTxFee(uint256 createTime) public view returns(uint256 fee) {
        // 初始手續費20%，以后每15天递减2.5%共遞減6次直至5%後固定，其中2% 作為版权费給 mint holder，其餘项目方。 
        uint256 round =  (block.timestamp.sub(createTime)).div(15 minutes);

        // 最低5%
        if(round >= 6){
            return 50;
        }

        fee = txFees.sub(round.mul(25));
    }



}

pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    function name() external view returns(string memory);
    function symbol() external view returns(string memory);
    function decimals() external view returns(uint8);
    function totalSupply() external view returns(uint256);
    function balanceOf(address owner) external view returns(uint256);
    function allowance(address owner, address spender) external view returns(uint256);
    
    function approve(address spender, uint256 value) external returns(bool);
    function transfer(address to, uint256 value) external returns(bool);
    function transferFrom(address from, address to, uint256 value) external returns(bool);

    function burn(uint256 amount) external;
    function mintFrom(address to, uint256 amount) external;
}

pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

/// @title ERC-721 Non-Fungible Token Standard
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x80ac58cd.
interface IERC721 /* is ERC165 */ {
    /// @dev This emits when ownership of any NFT changes by any mechanism.
    ///  This event emits when NFTs are created (`from` == 0) and destroyed
    ///  (`to` == 0). Exception: during contract creation, any number of NFTs
    ///  may be created and assigned without emitting Transfer. At the time of
    ///  any transfer, the approved address for that NFT (if any) is reset to none.
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    /// @dev This emits when the approved address for an NFT is changed or
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    /// @dev This emits when an operator is enabled or disabled for an owner.
    ///  The operator can manage all NFTs of the owner.
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// @param _owner An address for whom to query the balance
    /// @return The number of NFTs owned by `_owner`, possibly zero
    function balanceOf(address _owner) external view returns(uint256);

    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT
    function ownerOf(uint256 _tokenId) external view returns(address);

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) external payable;

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to "".
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Change or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _approved, uint256 _tokenId) external payable;

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) external;

    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT.
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId) external view returns(address);

    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) external view returns(bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

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
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "./IERC20.sol";
import "./Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

import "./ContractOwner.sol";
import "./Manager.sol";

abstract contract Member is ContractOwner {
    modifier CheckPermit(string memory permit) {
        require(manager.userPermits(msg.sender, permit),
            "no permit");
        _;
    }
    
    Manager public manager;
    
    function setManager(address addr) external ContractOwnerOnly {
        manager = Manager(addr);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.3._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.3._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

pragma solidity ^0.7.0;
// SPDX-License-Identifier: SimPL-2.0

abstract contract ContractOwner {
    address public contractOwner = msg.sender;
    
    modifier ContractOwnerOnly {
        require(msg.sender == contractOwner, "contract owner only");
        _;
    }
}

pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

import "./ContractOwner.sol";

contract Manager is ContractOwner {
    mapping(string => address) public members;
    
    mapping(address => mapping(string => bool)) public userPermits;
    
    function setMember(string memory name, address member)
        external ContractOwnerOnly {
        
        members[name] = member;
    }
    
    function setUserPermit(address user, string memory permit,
        bool enable) external ContractOwnerOnly {
        
        userPermits[user][permit] = enable;
    }
    
    function getTimestamp() external view returns(uint256) {
        return block.timestamp;
    }
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "../Manager/Member.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
interface ITokenStake {
    function update(uint256 amount) external;
}

contract TokenV2 is ERC20, Ownable, Member {
    string private _name = "MP TOKEN";
    string private _symbol = "MP";

    constructor (
        uint256 _totalSupply
    ) ERC20(_name, _symbol) {
        _mint(msg.sender, _totalSupply);
    }
    
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../../utils/Context.sol";
import "./IERC20.sol";
import "../../math/SafeMath.sol";

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

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

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
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
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
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
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
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
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
     * Requirements:
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
     * Requirements:
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
    function _setupDecimals(uint8 decimals_) internal virtual {
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
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";

interface INFT{
    struct CardAttributesStruct {
      uint256 grade;
    }
    function transferFrom(address _from,address _to,uint256 _tokenId)external;
    function approve(address _approved,uint256 _tokenId) external;
    function safeTransferFrom(address _from,address _to,uint256 _tokenId) external;
    function viewTokenID() view external returns(uint256);
    function setTokenTypeAttributes(uint256 _tokenId,uint8 _typeAttributes,uint256 _tvalue) external;
    function transferList(address _to,uint256[] calldata _tokenIdList) external;
    function ownerOf(uint256 _tokenID) external returns (address _owner);
    function starAttributes(uint256 _tokenID) external view returns(address,string memory,uint256,uint256,uint256,bool,uint256);
    function safeBatchTransferFrom(address from, address to,uint256[] memory tokenIds) external; 
    function burn(uint256 Id) external;
    function changePower(uint256 tokenId,uint256 power)external returns(bool);
    function switchMint(address to, uint256 grade) external returns(uint256);
    function cardAttributes(uint256 _tokenID) external returns(CardAttributesStruct memory);
}

contract UpdateCardSwitch is Ownable {
    INFT public nftv1;
    INFT public nftv2;
    uint256 public endTime;

    event Switch(address to, uint256 nftv1id, uint256 nftv2id);

    constructor (INFT _nftv1, INFT _nftv2) {
        require(_nftv1 != _nftv2, "duplicate address error");
        nftv1 = _nftv1;
        nftv2 = _nftv2;
    }

    function setEndTime(uint256 _endTime) external onlyOwner {
        endTime = _endTime;
    }
  
    function nftSwitch(uint256 nftv1Id) external {
        require(block.timestamp < endTime, "time`s up");
        require(nftv1.ownerOf(nftv1Id) == msg.sender, "it is not your nft");
        INFT.CardAttributesStruct memory nftAttr = nftv1.cardAttributes(nftv1Id);
        INFT(nftv1).burn(nftv1Id);
        uint256 nftv2Id = INFT(nftv2).switchMint(msg.sender, nftAttr.grade);
        emit Switch(msg.sender, nftv1Id, nftv2Id);
    }

    function batchnftSwitch(uint256[] memory nftv1Ids) external {
        require(block.timestamp < endTime, "time`s up");
        require(nftv1Ids.length <= 20, "batch limit");

        for (uint256 i = 0; i != nftv1Ids.length; ++i) {
            if (nftv1.ownerOf(nftv1Ids[i]) != msg.sender) {
                continue;
            }
            
            INFT.CardAttributesStruct memory nftAttr = nftv1.cardAttributes(nftv1Ids[i]);
            INFT(nftv1).burn(nftv1Ids[i]);
            uint256 nftv2Id = INFT(nftv2).switchMint(msg.sender, nftAttr.grade);
            emit Switch(msg.sender, nftv1Ids[i], nftv2Id);
        }
    }
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "../Utils/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MPSwitch is Ownable {
    IERC20 public mpv1;
    IERC20 public mpv2;
    uint256 public endTime;

    event Switch(address to, uint256 amount);
    event SwitchBurn(uint256 amount);
    event SwitchTransfer(address to, uint256 amount);

    constructor (IERC20 _mpv1, IERC20 _mpv2) {
        require(_mpv1 != _mpv2, "duplicate address error");
        mpv1 = _mpv1;
        mpv2 = _mpv2;
    }

    function setEndTime(uint256 _endTime) external onlyOwner {
        endTime = _endTime;
    }

    function transfer(address to, uint256 amount) external onlyOwner {
        require(amount > 0, "MPv1 balances zero");
        require(mpv1.balanceOf(address(this)) >= amount, "MPv1 balances not enough");
        mpv1.transfer(to, amount);
        emit SwitchTransfer(to, amount);
    }
  
    function tokenSwitch() external {
        require(block.timestamp < endTime, "time`s up");
        uint256 amount = mpv1.balanceOf(msg.sender);
        require(amount > 0, "MPv1 balances not enough");
        require(mpv2.balanceOf(address(this)) >= amount, "MPv2 out of balances");
        mpv1.transferFrom(msg.sender, address(this), amount);
        mpv2.transfer(msg.sender, amount);
        emit Switch(msg.sender, amount);
    }
}

pragma solidity ^0.7.0;

import "../Utils/IERC20.sol";
import "../Utils/SafeERC20.sol";
import "../Utils/SafeMath.sol";


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @title TokenVesting
 * @dev A token holder contract that can release its token balance gradually like a
 * typical vesting scheme, with a cliff and vesting period. Optionally revocable by the
 * owner.
 */
contract TokenVesting is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  event Released(uint256 amount);
  event Revoked();

  // beneficiary of tokens after they are released
  address public beneficiary;

  uint256 public cliff;
  uint256 public start;
  uint256 public duration;
  uint256 public blockReleasePer; 
  
  IERC20 public token;

  bool public revocable;

  mapping (address => uint256) public released;
  mapping (address => bool) public revoked;

  /**
   * @dev Creates a vesting contract that vests its balance of any ERC20 token to the
   * _beneficiary, gradually in a linear fashion until _start + _duration. By then all
   * of the balance will have vested.
   * ex: 鎖定 2 分鐘(chiff = 120) 後，線性解鎖 5 分鐘(duration = 300)，解鎖區間時間，每分鐘(_block_release_per = 60)解鎖 (20%)
   * @param _token 鎖定的合約
   * @param _beneficiary address of the beneficiary to whom vested tokens are transferred
   * @param _cliff duration in seconds of the cliff in which tokens will begin to vest
   * @param _duration duration in seconds of the period in which the tokens will vest
   * @param _revocable whether the vesting is revocable or not
   * @param _block_release_per 沒次釋放區段時間，
   */
  constructor(
    IERC20 _token,
    address _beneficiary,
    uint256 _start,
    uint256 _cliff,
    uint256 _duration,
    uint256 _block_release_per,
    bool _revocable
  )
    public
  {
    require(_beneficiary != address(0));
    require(_cliff <= _duration);

    token = _token;
    beneficiary = _beneficiary;
    revocable = _revocable;
    duration = _duration;
    cliff = _start.add(_cliff);
    start = _start;
    blockReleasePer = _block_release_per;
  }

  /**
   * @notice Transfers vested tokens to beneficiary.
   */
  function release() public {
    uint256 unreleased = releasableAmount();

    require(unreleased > 0, "no unreleased");

    released[address(token)] = released[address(token)].add(unreleased);

    token.safeTransfer(beneficiary, unreleased);

    Released(unreleased);
  }

  /**
   * @notice Allows the owner to revoke the vesting. Tokens already vested
   * remain in the contract, the rest are returned to the owner.
   */
  function revoke() public onlyOwner {
    require(revocable);
    require(!revoked[address(token)]);

    uint256 balance = token.balanceOf(address(this));

    uint256 unreleased = releasableAmount();
    uint256 refund = balance.sub(unreleased);

    revoked[address(token)] = true;

    token.safeTransfer(Ownable.owner(), refund);

    Revoked();
  }

  function withdraw() public onlyOwner {
    uint256 balance = token.balanceOf(address(this));
    token.safeTransfer(Ownable.owner(), balance);
  }

  /**
   * @dev Calculates the amount that has already vested but hasn't been released yet.
   */
  function releasableAmount() public view returns (uint256) {
    if (vestedAmount() < released[address(token)]) {
      return 0;
    }
    return vestedAmount().sub(released[address(token)]);
  }

  /**
   * @dev Calculates the amount that has already vested.
   */
  function vestedAmount() public view returns (uint256) {
    uint256 currentBalance = token.balanceOf(address(this));
    // 合約餘額不足
    if (currentBalance == 0) {
      return 0;
    }

    uint256 totalBalance = currentBalance.add(released[address(token)]);
    if (block.timestamp < cliff) {
      return 0;
    } else if (block.timestamp >= start.add(duration) || revoked[address(token)]) {
      return totalBalance;
    } else {
      // ex: 鎖定 2 分鐘(chiff = 120) 後，線性解鎖 5 分鐘(duration = 300)，解鎖區間時間，每分鐘(_block_release_per = 60)解鎖 (20%)
      // 先算出每區段釋出幾 % 獎勵
      uint256 percentage = (duration).div(blockReleasePer);
      // 算出先在時間已經是第幾個區段
      uint256 numBlock = (block.timestamp.sub(cliff)).div(blockReleasePer).add(1);

      return totalBalance.mul(numBlock).div(percentage);
    }
  }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
import "../Manager/Member.sol";
import "../Utils/IERC20.sol";
import "../Utils/SafeMath.sol";

contract TokenStake is Member {
    
    using SafeMath for uint256;
    uint256 public totalDepositedAmount;
    uint256 public totalRewards;
    uint256 public totalStakers;
    
    bool public pauseStake = false;
    bool public pauseWithdraw = false;
    bool public pauseGetReward = false;

    uint256 public timeLock = 15 minutes;
    
    IERC20 mp;
    IERC20 stakeToken;

    struct PoolInfo {
        uint256 daliyDividends;
        uint256 rewardedAmount;
        uint256 totalDeposited;
        uint256 accSushiPerShare;   //從古至今，每質押1Mp，已派發獎勵的Mp(* 1e12)
    }

    struct UserInfo {
        uint256 depositedToken;
        uint256 rewardDebt;     // 負債值
        uint256 pendingReward;
        uint256 receivedReward;
        uint256 pendingWithdraw;
    }
    
    PoolInfo public poolInfo;
    mapping(address => UserInfo) public userInfo;
    mapping(address => uint256) public lockRequest;

    event WithdrawRequest(address _user);
    event Withdraw(address _user, uint256 _amount);
    event GetReward(address _user, uint256 _amount);
    event Deposit(address _user, uint256 _amount);
    event UpdatePool(uint256 amount);
    event Recycle(uint256 _p);
    event RecoverTokens(address token, uint256 amount, address to);
    
    modifier validSender{
        require(msg.sender == manager.members("mpToken") || msg.sender == address(manager.members("nftMasterChef")) || msg.sender == manager.members("nft") || msg.sender == manager.members("updatecard"));
        _;
    }
    
    constructor(IERC20 _mp, IERC20 _stakeToken) {
        mp = _mp;
        stakeToken = _stakeToken;
    }
    

    function getDaliyTotalDeposited() public view returns(uint256) {
        return poolInfo.totalDeposited;
    }

    function claimReward(address _user) internal {
        uint256 reward = settleRewards(_user);
        userInfo[_user].pendingReward = userInfo[_user].pendingReward.add(reward);
    }
    
    function update(uint256 amount) external validSender {
        totalRewards = totalRewards.add(amount);
        // 當沒人質押，獎池金額回流至項目方
        if(poolInfo.totalDeposited == 0){
            IERC20(mp).transfer(address(manager.members("funder")), amount);
            emit Recycle(amount);
        }else{
            poolInfo.daliyDividends = poolInfo.daliyDividends.add(amount);

            // 計算從古至今，每質押1Mp，已派發獎勵的Mp(* 1e12)
            poolInfo.accSushiPerShare = poolInfo.accSushiPerShare.add(amount.mul(1e12).div(poolInfo.totalDeposited));
            emit UpdatePool(amount);
        }
    }
    
    function deposit(uint256 amount) public {
        require(lockRequest[msg.sender] == 0, "is in pending");
        require(amount > 0, "zero amount");
        require(pauseStake == false, "function is suspended");
        IERC20(stakeToken).transferFrom(msg.sender, address(this), amount);
        claimReward(msg.sender);
        if(userInfo[msg.sender].depositedToken == 0) {
            totalStakers++;
        }
        userInfo[msg.sender].depositedToken = userInfo[msg.sender].depositedToken.add(amount);
        totalDepositedAmount = totalDepositedAmount.add(amount);
        poolInfo.totalDeposited = poolInfo.totalDeposited.add(amount);
        
        if(poolInfo.accSushiPerShare > 0){
            userInfo[msg.sender].rewardDebt = userInfo[msg.sender].depositedToken.mul(poolInfo.accSushiPerShare).div(1e12);
        }
        emit Deposit(msg.sender, amount);
    }

    function getReward() public {
        require(pauseGetReward == false, "function is suspended");
        uint256 reward = settleRewards(msg.sender);
        uint256 payReward = reward.add(userInfo[msg.sender].pendingReward);
        userInfo[msg.sender].receivedReward = userInfo[msg.sender].receivedReward.add(payReward);
        userInfo[msg.sender].pendingReward = 0;
        IERC20(mp).transfer(msg.sender, payReward);
        emit GetReward(msg.sender, reward);
    }

    function timeLockChange(uint256 _period) external {
        require(manager.members("owner") != address(0), "member owner empty");
        require(msg.sender == manager.members("owner"), "onlyOwner");
        timeLock = _period;
    }
    
    function tokenChange(IERC20 _mp, IERC20 _stakeToken) external {
        require(manager.members("owner") != address(0), "member owner empty");
        require(msg.sender == manager.members("owner"), "onlyOwner");
        mp = _mp;
        stakeToken = _stakeToken;
    }
    
    function withdraw() public {
        require(lockRequest[msg.sender] !=0 && block.timestamp >= lockRequest[msg.sender].add(timeLock), "locked");
        require(pauseWithdraw == false, "function is suspended");
        uint256 pendingWithdraw = userInfo[msg.sender].pendingWithdraw;
        uint256 fee = pendingWithdraw.mul(2).div(100);
        IERC20(stakeToken).transfer(msg.sender, pendingWithdraw.sub(fee));
        IERC20(stakeToken).transfer(address(manager.members("OfficalAddress")), fee);
        
        lockRequest[msg.sender] = 0;
        totalDepositedAmount = totalDepositedAmount.sub(pendingWithdraw);
        userInfo[msg.sender].pendingWithdraw = 0;
        emit Withdraw(msg.sender, pendingWithdraw);
    }

    function withdrawRequest() public {
        require(lockRequest[msg.sender] == 0, "is in pending");
        getReward();

        uint256 userDeposited = userInfo[msg.sender].depositedToken;
        poolInfo.totalDeposited = poolInfo.totalDeposited.sub(userDeposited);
        userInfo[msg.sender].depositedToken = 0;
        userInfo[msg.sender].pendingWithdraw = userDeposited;
        totalStakers--;
        lockRequest[msg.sender] = block.timestamp;
        emit WithdrawRequest(msg.sender);
        if(timeLock == 0){
            withdraw();
        }
    }
    
    function pendingRewards(address _user) public view returns (uint256 reward){
        if(userInfo[_user].depositedToken == 0){
            return 0;
        }

        // 從開始到現在都沒獎勵
        if(poolInfo.accSushiPerShare == 0){
            return 0;
        }

        reward = userInfo[_user].depositedToken.mul(poolInfo.accSushiPerShare).div(1e12).sub(userInfo[_user].rewardDebt);
        reward = reward.add(userInfo[_user].pendingReward);
    }

    function settleRewards(address _user) internal returns (uint256 reward){
        if(userInfo[_user].depositedToken == 0){
            return 0;
        }
        
        // 從開始到現在都沒獎勵
        if(poolInfo.accSushiPerShare == 0){
            return 0;
        }

        reward = userInfo[_user].depositedToken.mul(poolInfo.accSushiPerShare).div(1e12).sub(userInfo[_user].rewardDebt);
        poolInfo.rewardedAmount=poolInfo.rewardedAmount.add(reward);
        userInfo[_user].rewardDebt = userInfo[_user].depositedToken.mul(poolInfo.accSushiPerShare).div(1e12);
    }
    
    function setPauseStake(bool _pause) external {
        require(manager.members("owner") != address(0), "member owner empty");
        require(msg.sender == manager.members("owner"), "only owner");
        pauseStake = _pause;
    }

    function setPauseWithdraw(bool _pause) external {
        require(manager.members("owner") != address(0), "member owner empty");
        require(msg.sender == manager.members("owner"), "only owner");
        pauseWithdraw = _pause;
    }

    function setPauseGetReward(bool _pause) external {
        require(manager.members("owner") != address(0), "member owner empty");
        require(msg.sender == manager.members("owner"), "only owner");
        pauseGetReward = _pause;
    }

    function setPauseAll(bool _pause) external {
        require(manager.members("owner") != address(0), "member owner empty");
        require(msg.sender == manager.members("owner"), "only owner");
        pauseStake = _pause;
        pauseWithdraw = _pause;
        pauseGetReward = _pause;
    }

    function recoverTokens(address token, uint256 amount, address to) external {
        require(manager.members("owner") != address(0), "member owner empty");
        require(msg.sender == manager.members("owner"), "only owner");
        require(IERC20(token).balanceOf(address(this)) >= amount, "balance not enough");
        IERC20(token).transfer(to, amount);
        emit RecoverTokens(token, amount, to);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
import "../Manager/Member.sol";
import "../Utils/IERC20.sol";
import "../Utils/SafeMath.sol";
import "../Utils/IUniswapV2Pair.sol";
import "../Utils/IPreacher.sol";

interface IMasterChef {
    struct _UserInfo {
        uint256 receivedReward;
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 pendingReward;
        uint256[]  _nftBalances;
        uint256 lvMore1Count;   // 擁有level > 1的nft數量
    }
    function getUser(address _user) external view returns(_UserInfo memory);
    function claimReward(uint256 _pid, address _user) external;
    function updateRewardDebt(address _user) external;
}

contract Promote is Member {
    
    using SafeMath for uint256;
    uint256 public totalDepositedAmount;
    uint256 public round;
    uint256 public totalRewards;

    uint256 public timeLock = 15 minutes;

    IERC20 public usdt;
    IERC20 public mp;
    IUniswapV2Pair public pair;

    struct DaliyInfo {
        uint256 daliyDividends;
        uint256 rewardedAmount;
        // 各等級三代加總權重
        uint256[4] totalDown3GenWeight;
        // 各等級，有效用戶數
        uint256[] perNodeNum;
    }

    struct UserInfo {
        // 上線八代
        address[8] upline8Gen;
        // 以8代内的權重加總(包含自己)
        uint256 down8GenWeight;
        // 以3代内的權重加總(包含自己)
        uint256 down3GenWeight;
        //  6 代内有效地址數
        uint256 numDown6Gen;

        // 已提領獎勵
        uint256 receivedReward;

        bool isValid;
        uint8 level;
        // md 值(一代)
        uint256 numSS;
        // md 值(三代)
        uint256 numGS;
        uint256 weight;
        uint256 depositAsUsdt;
        uint256 depositedMP;
        uint256 lastRewardRound;
        uint256 pendingReward;
        // 用戶上線
        address f;
        // 下線群組
        address[] ss;
    }

    struct User3GenWeight {
        // 1、2、3代的權重加總(不含加成)
        uint256 gen3Weight;
        uint256 gen2Weight;
        uint256 gen1Weight;
        // 1、2、3代代加成百分比(6 = 6%)
        uint256 gen3Bonus;
        uint256 gen2Bonus;
        uint256 gen1Bonus;
    }
        

    struct pendingDeposit{
        uint256 pendingMP;
        uint256 pendingAsUsdt;
    }

    mapping(address=>pendingDeposit) public userPending;
    
    mapping(uint256 => DaliyInfo) public daliyInfo;
    mapping(address => UserInfo) public userInfo;
    mapping(address => User3GenWeight) public user3GenWeight;
    uint256 public total3GenBonusWeight;    // 全網（包含無效user權重）
    uint256 public invalid3GenBonusWeight;    // 無效user的權重加總
    mapping(address => bool) public isGamer;
    mapping(uint256 => uint256) public roundTime;
    mapping(address => uint256) public lockRequest;
    
    // MD 值（直推）
    uint256[] internal numThresholdSS = [6,8,12,15];
    // MD 值（三代內）
    uint256[] internal numThresholdGS = [3,6,12,18];
    // 質押 MP 等級
    uint256[] internal amountThreshould = [1000*1e18, 2000*1e18, 3000*1e18, 4000*1e18];
    // 獎勵係數
    uint256[] internal rewardPrecent = [40, 30, 20, 10];

    event LevelChange(address _user, uint8 beforeLv, uint8 curLv);
    event NewRound(uint256 _round);
    event NewJoin(address _user, address _f);
    event WithdrawRequest(address _user);
    event Withdraw(address _user, uint256 _amount);
    event GetReward(address _user, uint256 _amount);
    event Deposit(address _user, uint256 _amount);
    event UpdatePool(uint256 amount);
    event Recycle(uint256 amount);
    event RecoverTokens(address token, uint256 amount, address to);

    modifier onlyPool{
        require(msg.sender == address(manager.members("nftMasterChef")), "err1"); // this function can only called by pool address!
        _;
    }
    
    modifier validSender{
        require(msg.sender == address(manager.members("updatecard")) || msg.sender == manager.members("nft"));
        _;
    }
    
    constructor(IERC20 _mp, IERC20 _usdt, IUniswapV2Pair _pair, address genesis) {
        mp = _mp;
        usdt = _usdt;
        pair = _pair;
        isGamer[genesis] = true;
        
        uint8 i = 0;
        while( i < 4) {
            daliyInfo[0].perNodeNum.push(0);
            i++;
        }
    }

    function getSS(address _user) public view returns (address[] memory) {
        return userInfo[_user].ss;
    }
    
    
    function getDaily(uint256 _round)  public view returns(DaliyInfo memory) {
        return daliyInfo[_round];
    }
    function getDaliyPerNode(uint256 _round) public view returns(uint256[] memory) {
        return daliyInfo[_round].perNodeNum;
    }
    function getUser3GenWeight(address _user) public view returns(User3GenWeight memory) {
        return user3GenWeight[_user];
    }

    function bind(address downline, address binding) external {
        address _downline = msg.sender;
        if (msg.sender == manager.members("owner")){
            _downline = downline;
        } else {
            // 只有在 user bind 時檢查
            require(msg.sender != binding, "err6"); // can not bindself
        }
        UserInfo storage user = userInfo[_downline];
        require((isGamer[binding] == true) && (isGamer[_downline] == false), "err4"); // origin & upline must in game!
        
        user.f = binding;
        isGamer[_downline] = true;

        // 第一代
        address upline = binding;
        // 存1~8代上線
        for(uint8 i=0; i < 8; i++) {
            user.upline8Gen[i] = upline;
            // 取下一代
            upline = userInfo[upline].f;
            if (upline == address(0)) {
                break;
            }
        }

        // 更新下線群組
        userInfo[user.f].ss.push(_downline);
        emit NewJoin(_downline, user.f);
    }

    // NFT 解質押後會呼叫
    function redem(address sender, uint256, uint256 amount) external onlyPool {
        UserInfo storage user = userInfo[sender];
        require(isGamer[sender] == true, "err2"); // origin must in game!
        address f = user.f;
        address ff = userInfo[f].f;
        address fff = userInfo[ff].f;
        
        if(!userInfo[sender].isValid){
            // 個人權重
            invalid3GenBonusWeight =  invalid3GenBonusWeight.sub(amount);
        }
        user.weight -= amount;
        IMasterChef(manager.members("nftMasterChef")).updateRewardDebt(sender);

        bool changeToInvalid = false;
        if(user.isValid && user.weight == 0) {
            userDown(sender);

            if(f != address(0)) {
                evoDown(f,1);
            }
            if(ff != address(0)) {
                evoDown(ff,2);
            }
            if(fff != address(0)) {
                evoDown(fff,3);
            }
            changeToInvalid = true;
        }else{
            IMasterChef._UserInfo memory masterUserInfo = IMasterChef(manager.members("nftMasterChef")).getUser(sender);
            if(masterUserInfo.lvMore1Count == 0){
                // 檢查權重加成
                updateUserBouns(sender);
                // 檢查升等
                uint8 level1 = userInfo[sender].level;
                uint8 level2 = updateLevel(sender);
                if (level1 != level2) {
                    levelChange(sender, level1, level2);
                    emit LevelChange(sender, level1, level2);
                }
            }
        }
        // 更新權重
        // 自己
        claimReward(sender);
        user.down8GenWeight = user.down8GenWeight.sub(amount);
        user.down3GenWeight = user.down3GenWeight.sub(amount);
        
        bool isPreacher = IPreacher(manager.members("PreacherAddress")).checkIsPreacher(sender);
        if(isPreacher){
            bool isAdd = false;
            IPreacher(manager.members("PreacherAddress")).updateWeight(sender, amount, isAdd);
        }

        // 紀錄total3GenBonusWeight的更新值
        uint256 _total3GenBonusWeight;
        uint256 _invalid3GenBonusWeight;
        // 自己
        _total3GenBonusWeight = _total3GenBonusWeight.add(amount);

        uint256[4] memory subTotalUpdateWeight;
        if(user.level > 0){
            subTotalUpdateWeight[user.level-1] = subTotalUpdateWeight[user.level-1].add(amount);
        }
        uint256 tmpAmount = amount;
        for(uint8 i=0; i < 8; i++) {
            address _user = user.upline8Gen[i];
            if(_user == address(0)){
                break;
            }
            // 更新上線6代的有效人數
            if (changeToInvalid) {
                if (i < 6) {
                    userInfo[_user].numDown6Gen = userInfo[_user].numDown6Gen.sub(1);
                    // 檢查是否為佈道者
                    IPreacher(manager.members("PreacherAddress")).upgradePreacher(_user);
                }
            }
            
            // 更新上線8代的權重加總
            userInfo[_user].down8GenWeight = userInfo[_user].down8GenWeight.sub(tmpAmount);
            bool _isPreacher = IPreacher(manager.members("PreacherAddress")).checkIsPreacher(_user);
            if(_isPreacher){
                bool isAdd = false;
                IPreacher(manager.members("PreacherAddress")).updateWeight(_user, tmpAmount, isAdd);
            }

            // 更新上線3代權重加總
            if(i < 3){
                claimReward(_user);

                userInfo[_user].down3GenWeight = userInfo[_user].down3GenWeight.sub(tmpAmount);

                uint256 _level = userInfo[_user].level;
                if(_level > 0){
                    subTotalUpdateWeight[_level-1] = subTotalUpdateWeight[_level-1].add(tmpAmount);
                }
                IMasterChef(manager.members("nftMasterChef")).claimReward(0, _user);
                // 用於「masterChef算力額外加成」
                if(i == 0){
                    user3GenWeight[_user].gen1Weight = user3GenWeight[_user].gen1Weight.sub(tmpAmount);
                    // 更新全網總權重
                    uint256 _bounsWeight = tmpAmount.mul(user3GenWeight[_user].gen1Bonus).div(100);
                    _total3GenBonusWeight = _total3GenBonusWeight.add(_bounsWeight);

                    if(!userInfo[_user].isValid){
                        _invalid3GenBonusWeight =  _invalid3GenBonusWeight.add(_bounsWeight);
                    }
                }

                if(i == 1){
                    user3GenWeight[_user].gen2Weight = user3GenWeight[_user].gen2Weight.sub(tmpAmount);
                    // 更新全網總權重
                    uint256 _bounsWeight = tmpAmount.mul(user3GenWeight[_user].gen2Bonus).div(100);
                    _total3GenBonusWeight = _total3GenBonusWeight.add(_bounsWeight);

                    if(!userInfo[_user].isValid){
                        _invalid3GenBonusWeight =  _invalid3GenBonusWeight.add(_bounsWeight);
                    }
                }

                if(i == 2){
                    user3GenWeight[_user].gen3Weight = user3GenWeight[_user].gen3Weight.sub(tmpAmount);
                    // 更新全網總權重
                    uint256 _bounsWeight = tmpAmount.mul(user3GenWeight[_user].gen3Bonus).div(100);
                    _total3GenBonusWeight = _total3GenBonusWeight.add(_bounsWeight);

                    if(!userInfo[_user].isValid){
                        _invalid3GenBonusWeight =  _invalid3GenBonusWeight.add(_bounsWeight);
                    }
                }
                IMasterChef(manager.members("nftMasterChef")).updateRewardDebt(_user);
            }
        }

        // 更新個等級權重
        for(uint8 i=0 ;i<4 ;i++){
            daliyInfo[round].totalDown3GenWeight[i] = daliyInfo[round].totalDown3GenWeight[i].sub(subTotalUpdateWeight[i]) ;
        }

        // 更新全網三代bouns權重
        total3GenBonusWeight = total3GenBonusWeight.sub(_total3GenBonusWeight);
        invalid3GenBonusWeight = invalid3GenBonusWeight.sub(_invalid3GenBonusWeight);
    }

    

    function userDown(address sender) internal {
        uint8 level1 = userInfo[sender].level;
        if (userInfo[sender].level > 0) {
            levelChange(sender, level1, 0);
            emit LevelChange(sender, level1, 0);
        }

        if(userInfo[sender].isValid == true){
            updateInvalid3GenBonusWeight(sender, false);
        }
        userInfo[sender].isValid = false;
    }

    // 代數gen 1~3
    function evoDown(address _user, uint8 gen) internal {
        uint8 level = userInfo[_user].level;

        // 更新 MD 值
        if(gen == 1){
            // 直推
            userInfo[_user].numSS--;
            
            // 更新權重加成
            if(userInfo[_user].numSS >= 0 && userInfo[_user].numSS < 3){
                updateUserBouns(_user);
            }
        }
        userInfo[_user].numGS--;
        
        // 如果上線因此降级了，更新用户等级以及全網數據
        if ( level > 0 && (userInfo[_user].numSS < numThresholdSS[level - 1] || userInfo[_user].numGS < numThresholdGS[level - 1])) {
            levelChange(_user, level, level - 1);
            emit LevelChange(_user, level, level - 1);
        }
    }
    
    // NFT 質押後會呼叫
    function newDeposit(address sender,uint256, uint256 amount) external onlyPool {
        require(isGamer[sender] == true, "err2"); // origin must in game!
        UserInfo storage user = userInfo[sender];

        address f = user.f;
        address ff = userInfo[f].f;
        address fff = userInfo[ff].f;

        claimReward(sender);
        if(!userInfo[sender].isValid){
            // 個人權重
            invalid3GenBonusWeight =  invalid3GenBonusWeight.add(amount);
        }
        user.weight += amount;

        bool changeToValid = false;
        // 質押後，該用戶變為有效用戶
        if(!user.isValid && user.weight > 0) {
            userUp(sender);
            evo(f,1);
            if (ff != address(0)) {
                evo(ff, 2);
            }
            if (fff != address(0)) {
                evo(fff, 3);
            }
            changeToValid = true;
        }else{
            IMasterChef._UserInfo memory masterUserInfo = IMasterChef(manager.members("nftMasterChef")).getUser(sender);
            if(masterUserInfo.lvMore1Count > 0){
                // 檢查權重加成
                updateUserBouns(sender);
                // 檢查升等
                uint8 level1 = userInfo[sender].level;
                uint8 level2 = updateLevel(sender);
                if (level1 != level2) {
                    levelChange(sender, level1, level2);
                    emit LevelChange(sender, level1, level2);
                }
            }
        }  

        // 更新權重
        // 自己
        userInfo[sender].down8GenWeight = userInfo[sender].down8GenWeight.add(amount);
        userInfo[sender].down3GenWeight = userInfo[sender].down3GenWeight.add(amount);

        bool isPreacher = IPreacher(manager.members("PreacherAddress")).checkIsPreacher(sender);
        if(isPreacher){
            bool isAdd = true;
            IPreacher(manager.members("PreacherAddress")).updateWeight(sender, amount, isAdd);
        }

        // 紀錄total3GenBonusWeight的更新值
        uint256 _total3GenBonusWeight;
        uint256 _invalid3GenBonusWeight;
        // 自己
        _total3GenBonusWeight = _total3GenBonusWeight.add(amount);

        uint256[4] memory addTotalUpdateWeight;
        uint256 userLevel = userInfo[sender].level;
        if(userLevel > 0){
            addTotalUpdateWeight[userLevel-1] = addTotalUpdateWeight[userLevel-1].add(amount);
        }
        uint256 tmpAmount = amount;
        for(uint8 i=0; i < 8; i++) {
            address _user =user.upline8Gen[i];
            if(_user == address(0)){
                break;
            }
            // 更新上線6代的有效人數
            if (changeToValid) {
                if (i < 6) {
                    userInfo[_user].numDown6Gen = userInfo[_user].numDown6Gen.add(1);
                    // 檢查是否為佈道者
                    IPreacher(manager.members("PreacherAddress")).upgradePreacher(_user);
                }
            }
            
            // 更新上線8代的權重加總
            userInfo[_user].down8GenWeight = userInfo[_user].down8GenWeight.add(tmpAmount);
            bool _isPreacher = IPreacher(manager.members("PreacherAddress")).checkIsPreacher(_user);
            if(_isPreacher){
                bool isAdd = true;
                IPreacher(manager.members("PreacherAddress")).updateWeight(_user, tmpAmount, isAdd);
            }

            // 更新上線3代權重加總
            if(i < 3){
                claimReward(_user);
                userInfo[_user].down3GenWeight = userInfo[_user].down3GenWeight.add(tmpAmount);

                uint256 _level = userInfo[_user].level;
                if(_level > 0){
                    addTotalUpdateWeight[_level-1] = addTotalUpdateWeight[_level-1].add(tmpAmount);
                }

                 IMasterChef(manager.members("nftMasterChef")).claimReward(0, _user);
                // 用於「masterChef算力額外加成」
                if(i == 0){
                    user3GenWeight[_user].gen1Weight = user3GenWeight[_user].gen1Weight.add(tmpAmount);
                   
                    // 更新全網總權重
                    uint256 _bounsWeight = tmpAmount.mul(user3GenWeight[_user].gen1Bonus).div(100);
                    _total3GenBonusWeight = _total3GenBonusWeight.add(_bounsWeight);

                    if(!userInfo[_user].isValid){
                        _invalid3GenBonusWeight =  _invalid3GenBonusWeight.add(_bounsWeight);
                    }
                }

                if(i == 1){
                    user3GenWeight[_user].gen2Weight = user3GenWeight[_user].gen2Weight.add(tmpAmount);
                    // 更新全網總權重
                    uint256 _bounsWeight = tmpAmount.mul(user3GenWeight[_user].gen2Bonus).div(100);
                    _total3GenBonusWeight = _total3GenBonusWeight.add(_bounsWeight);

                    if(!userInfo[_user].isValid){
                        _invalid3GenBonusWeight =  _invalid3GenBonusWeight.add(_bounsWeight);
                    }
                }

                if(i == 2){
                    user3GenWeight[_user].gen3Weight = user3GenWeight[_user].gen3Weight.add(tmpAmount);
                    // 更新全網總權重
                    uint256 _bounsWeight = tmpAmount.mul(user3GenWeight[_user].gen3Bonus).div(100);
                    _total3GenBonusWeight = _total3GenBonusWeight.add(_bounsWeight);

                    if(!userInfo[_user].isValid){
                        _invalid3GenBonusWeight =  _invalid3GenBonusWeight.add(_bounsWeight);
                    }
                }
                 IMasterChef(manager.members("nftMasterChef")).updateRewardDebt(_user);
            }
        }
        
        // 更新個等級權重
        for(uint8 i=0 ;i<4 ;i++){
            daliyInfo[round].totalDown3GenWeight[i] = daliyInfo[round].totalDown3GenWeight[i].add(addTotalUpdateWeight[i]);
        }

        // 更新全網三代bouns權重
        total3GenBonusWeight = total3GenBonusWeight.add(_total3GenBonusWeight);
        invalid3GenBonusWeight = invalid3GenBonusWeight.add(_invalid3GenBonusWeight);
    }

    function userUp(address sender) internal {
        uint8 level1 = userInfo[sender].level;
        uint8 level2 = updateLevel(sender);
        if (userInfo[sender].isValid == false && level2 > 0) {
            levelChange(sender, level1, level2);
            emit LevelChange(sender, level1, level2);

        }
        
        if(userInfo[sender].isValid == false){
            updateInvalid3GenBonusWeight(sender, true);
        }
        userInfo[sender].isValid = true;
    }

    // 更上線信息（如果提升了等级将沉淀奖励）
    function evo(address _user, uint8 gen) internal {
        uint8 level = userInfo[_user].level;

        // 更新 MD 值
        if(gen == 1){
            // 直推
            userInfo[_user].numSS++;

            // 更新權重加成
            if(userInfo[_user].numSS >= 0 && userInfo[_user].numSS <= 3){
                updateUserBouns(_user);
            }
        }
        userInfo[_user].numGS++;

        // 如果上線因此升级了，更新用户等级以及全網數據
        if ( 
            userInfo[_user].isValid &&
            level <= 3 && 
            userInfo[_user].numSS >= numThresholdSS[level] && 
            userInfo[_user].numGS >= numThresholdGS[level] && 
            userInfo[_user].depositAsUsdt >= amountThreshould[level]) {
                levelChange(_user, level, level+1);
                emit LevelChange(_user, level, level+1);
        }
    }

    function claimReward(address _user) internal {
        userInfo[_user].pendingReward = userInfo[_user].pendingReward.add(settleRewards(_user));
        userInfo[_user].lastRewardRound = round;
    }
    
    function update(uint256 amount) external validSender {
        if(block.timestamp >= roundTime[round] + 10 minutes) {
            round++;
            roundTime[round] = block.timestamp;
            if (round > 0) {
                daliyInfo[round] = daliyInfo[round -1];
                daliyInfo[round].totalDown3GenWeight = daliyInfo[round -1].totalDown3GenWeight;
                daliyInfo[round].perNodeNum = daliyInfo[round -1].perNodeNum;
            }
            // daliyInfo[round].round = round;
            daliyInfo[round].daliyDividends = 0;
            daliyInfo[round].rewardedAmount = 0;
            if(round > 16) {
                uint256 _p = daliyInfo[round - 16].daliyDividends.sub(daliyInfo[round - 16].rewardedAmount);
                if(_p > 0){
                    IERC20(mp).transfer(address(manager.members("funder")), _p);
                    emit Recycle(_p);    // 回收
                }
            }
            emit NewRound(round);
        }
        daliyInfo[round].daliyDividends = daliyInfo[round].daliyDividends.add(amount);
        totalRewards = totalRewards.add(amount);
        emit UpdatePool(amount);
    }

    function getUser(address _user) external view returns (UserInfo memory) {
        return userInfo[_user];
    }

    function getNowDaily() external view returns (DaliyInfo memory) {
        return daliyInfo[round];
    }
    
    function deposit(uint256 amount) external {
        require(lockRequest[msg.sender] == 0, "err7"); // In withdraw
        require(amount > 0);
        require(isGamer[msg.sender] == true);
        
        uint256 usd_balance;
        uint256 mp_balance;
        if (pair.token0() == address(usdt)) {
          (usd_balance, mp_balance , ) = pair.getReserves();   
        }  
        else{
          (mp_balance, usd_balance , ) = pair.getReserves();           
        }
    
        IERC20(mp).transferFrom(msg.sender, address(this), amount);
        userInfo[msg.sender].depositedMP = userInfo[msg.sender].depositedMP.add(amount);
        userInfo[msg.sender].depositAsUsdt = userInfo[msg.sender].depositAsUsdt.add(amount.mul(usd_balance.mul(1e18).div(mp_balance)).div(1e18));
        uint8 old = userInfo[msg.sender].level;
        uint8 newlevel = updateLevel(msg.sender);
        if (old != newlevel && userInfo[msg.sender].isValid) {
            levelChange(msg.sender, old, newlevel);
            emit LevelChange(msg.sender, old, newlevel);
        }
        totalDepositedAmount = totalDepositedAmount.add(amount);
        emit Deposit(msg.sender, amount);
    }

    function updateLevel(address user) internal view returns (uint8){
        // 質押 MP 的等級
        uint8 level1;
        // MD 值（直推）
        uint8 level2;
        // MD 值（兩代）
        uint8 level3;
        IMasterChef._UserInfo memory masterUserInfo = IMasterChef(manager.members("nftMasterChef")).getUser(user);
        if(masterUserInfo.lvMore1Count == 0){
            return 0;
        }
        
        uint256 amount = userInfo[user].depositAsUsdt;
         for(uint8 i = 4; i > 0;i--) {
            level1 = level1==0 && amount >= amountThreshould[i - 1]? i : level1;
            level2 = level2==0 && userInfo[user].numSS >= numThresholdSS[i-1] ? i : level2;
            level3 = level3==0 && userInfo[user].numGS >= numThresholdGS[i-1] ? i : level3;
         }

        uint8 mdLevel = level2 < level3 ? level2:level3;
        return level1 < mdLevel ? level1:mdLevel;
    }
    
    function getReward() public {
        uint256 reward = settleRewards(msg.sender);
        uint256 payReward = reward.add(userInfo[msg.sender].pendingReward);
        IERC20(mp).transfer(msg.sender, payReward);
        userInfo[msg.sender].receivedReward = userInfo[msg.sender].receivedReward.add(payReward);
        userInfo[msg.sender].pendingReward = 0;
        userInfo[msg.sender].lastRewardRound = round;
        emit GetReward(msg.sender, reward);
    }
    
    function withdraw() external {
        require(lockRequest[msg.sender] !=0 && block.timestamp >= lockRequest[msg.sender].add(timeLock), "err8"); // locked
        IERC20(mp).transfer(msg.sender, userPending[msg.sender].pendingMP);
        lockRequest[msg.sender] = 0;
        totalDepositedAmount = totalDepositedAmount.sub(userPending[msg.sender].pendingMP);
        delete userPending[msg.sender];
        emit Withdraw(msg.sender, userPending[msg.sender].pendingMP);
    }

    function withdrawRequest() external {
        require(lockRequest[msg.sender] == 0, "err5"); // is in pending
        getReward();
        userPending[msg.sender].pendingMP = userInfo[msg.sender].depositedMP;
        userPending[msg.sender].pendingAsUsdt = userInfo[msg.sender].depositAsUsdt;
        userInfo[msg.sender].depositedMP = 0;
        userInfo[msg.sender].depositAsUsdt = 0;
        lockRequest[msg.sender] = block.timestamp;


        levelChange(msg.sender, userInfo[msg.sender].level, 0);
        emit LevelChange(msg.sender, userInfo[msg.sender].level, 0);
        emit WithdrawRequest(msg.sender);
    }
    
    function pendingRewards(address _user) external view returns (uint256 reward){
        if (userInfo[_user].level == 0) {
            return 0;
        }
        // uint256 num = userInfo[_user].numSS;
        uint8 level = userInfo[_user].level;
        uint8 i = round.sub(userInfo[_user].lastRewardRound) >= 15 ? 15: uint8(round.sub(userInfo[_user].lastRewardRound));
        for(i; i >0; i--) {
            if(daliyInfo[round-i].daliyDividends == 0 || userInfo[_user].down3GenWeight == 0 || daliyInfo[round-i].totalDown3GenWeight[level-1] == 0){
                continue;
            }
            // (daliyDividends * level 加成百分比) * (用戶3代算力 / 當前等級3代全網總算力) = 元域池 * 全網站比
            reward = reward.add(daliyInfo[round-i].daliyDividends.mul(rewardPrecent[userInfo[_user].level-1]).div(100).mul(userInfo[_user].down3GenWeight).div(daliyInfo[round-i].totalDown3GenWeight[level-1]));
        }
        reward = reward.add(userInfo[_user].pendingReward);
    }

    function settleRewards(address _user) internal returns (uint256 reward){
        if (userInfo[_user].level == 0) {
            return 0;
        }
        uint8 level = userInfo[_user].level;
        uint8 i = round.sub(userInfo[_user].lastRewardRound) >= 15 ? 15: uint8(round.sub(userInfo[_user].lastRewardRound));
        uint256 roundReward;
        for(i; i >0; i--) {
            if(daliyInfo[round-i].daliyDividends == 0 || userInfo[_user].down3GenWeight == 0 || daliyInfo[round-i].totalDown3GenWeight[level-1] == 0){
                continue;
            }
            // (daliyDividends * level 加成百分比) * (用戶3代算力 / 當前等級3代全網總算力) = 元域池 * 全網站比
            roundReward = daliyInfo[round-i].daliyDividends.mul(rewardPrecent[userInfo[_user].level-1]).div(100).mul(userInfo[_user].down3GenWeight).div(daliyInfo[round-i].totalDown3GenWeight[level-1]);
            reward = reward.add(roundReward);
            daliyInfo[round-i].rewardedAmount+=roundReward;
        }
    }

    // 更新user bouns加成權重%
    function updateUserBouns(address _user) public {
        IMasterChef(manager.members("nftMasterChef")).claimReward(0, _user);
        IMasterChef._UserInfo memory masterUserInfo = IMasterChef(manager.members("nftMasterChef")).getUser(_user);

         User3GenWeight storage user3Gen = user3GenWeight[_user];

        uint256[3] memory _oldGenBonusArray = [user3Gen.gen1Bonus, user3Gen.gen2Bonus,user3Gen.gen3Bonus];
        user3Gen.gen1Bonus = 0;
        user3Gen.gen2Bonus = 0;
        user3Gen.gen3Bonus = 0;
        // 質押 Uncommon罕見级NFT(以上) > 0  
        if(masterUserInfo.lvMore1Count > 0){
            // 直推1个有效地址获得1代 30%算力奖励
            if(userInfo[_user].numSS >= 3) {
                user3Gen.gen1Bonus = 30;
                user3Gen.gen2Bonus = 20;
                user3Gen.gen3Bonus = 10;
            }else if(userInfo[_user].numSS == 2) {
                user3Gen.gen1Bonus = 30;
                user3Gen.gen2Bonus = 20;
            }else if(userInfo[_user].numSS == 1) {
                user3Gen.gen1Bonus = 30;
            }
        }

        uint256[3] memory _newGenBonusArray = [user3Gen.gen1Bonus, user3Gen.gen2Bonus,user3Gen.gen3Bonus];
        uint256[3] memory _newGenWeightArray = [user3Gen.gen1Weight, user3Gen.gen2Weight,user3Gen.gen3Weight];

        uint256 _total3GenBonusWeight = total3GenBonusWeight;
        uint256 _invalid3GenBonusWeight = invalid3GenBonusWeight;
        // 更新全網權重
        for( uint8 i = 0; i < 3; i++) {
            if(_newGenBonusArray[i] != _oldGenBonusArray[i]) {
                uint256 _oldBounsWeight = _newGenWeightArray[i].mul(_oldGenBonusArray[i]).div(100);
                uint256 _newBounsWeight = _newGenWeightArray[i].mul(_newGenBonusArray[i]).div(100);
                _total3GenBonusWeight = _total3GenBonusWeight.sub(_oldBounsWeight).add(_newBounsWeight); 
                if(!userInfo[_user].isValid){
                    _invalid3GenBonusWeight = _invalid3GenBonusWeight.sub(_oldBounsWeight).add(_newBounsWeight);
                }
            }
        }
        total3GenBonusWeight = _total3GenBonusWeight;
        invalid3GenBonusWeight = _invalid3GenBonusWeight;
        IMasterChef(manager.members("nftMasterChef")).updateRewardDebt(_user);
    }

    // 有效身份變動時需更新
    function updateInvalid3GenBonusWeight(address _user, bool isValid) internal {
        // isValid是新狀態
        // sender已經領獎(該func只有sender使用)
        // IMasterChef(manager.members("nftMasterChef")).claimReward(0, _user);

        User3GenWeight memory _user3Gen = user3GenWeight[_user];
        UserInfo memory _userInfo = userInfo[_user];
        uint256 userTotalWeight;
        userTotalWeight = userTotalWeight.add(_user3Gen.gen3Weight.mul(_user3Gen.gen3Bonus).div(100));
        userTotalWeight = userTotalWeight.add(_user3Gen.gen2Weight.mul(_user3Gen.gen2Bonus).div(100));
        userTotalWeight = userTotalWeight.add(_user3Gen.gen1Weight.mul(_user3Gen.gen1Bonus).div(100));
        userTotalWeight = userTotalWeight.add(_userInfo.weight);

        if(isValid){
            // 變有效用戶
            invalid3GenBonusWeight = invalid3GenBonusWeight.sub(userTotalWeight);
        }else{
            // 變無效用戶
            invalid3GenBonusWeight = invalid3GenBonusWeight.add(userTotalWeight);
        }
    }
    function levelChange(address _user , uint8 oldLevel, uint8 newLevel)internal{
        // 領獎
        claimReward(_user);

        // 進行升級
        if (oldLevel > 0) {
            daliyInfo[round].perNodeNum[oldLevel - 1]--;
        }
        if (newLevel > 0) {
            daliyInfo[round].perNodeNum[newLevel - 1]++;
        }
        userInfo[_user].level = newLevel;

        // after new level

        // 檢查佈道者身份
        IPreacher(manager.members("PreacherAddress")).upgradePreacher(_user);

        // 當有人升級，更新該等級全網權重
        uint256 _down3GenWeight = userInfo[_user].down3GenWeight;
        if(oldLevel > 0){
            daliyInfo[round].totalDown3GenWeight[oldLevel-1] = daliyInfo[round].totalDown3GenWeight[oldLevel-1].sub(_down3GenWeight);
        }
        if(newLevel > 0){
            daliyInfo[round].totalDown3GenWeight[newLevel-1] = daliyInfo[round].totalDown3GenWeight[newLevel-1].add(_down3GenWeight);
        }
    }

    function recoverTokens(address token, uint256 amount, address to) external {
        require(msg.sender == manager.members("owner"), "owner");
        require(IERC20(token).balanceOf(address(this)) >= amount, "balance");
        IERC20(token).transfer(to, amount);
        emit RecoverTokens(token, amount, to);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

interface IUniswapV2Pair {
    function balanceOf(address owner) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

interface IPreacher {
    function update(uint256 amount) external;
    function updateWeight(address _user, uint256 amount, bool isAdd) external;
    function upgradePreacher(address _user) external;
    function checkIsPreacher(address _user) external view returns (bool);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
import "../Manager/Member.sol";
import "../Utils/IERC20.sol";
import "../Utils/SafeMath.sol";

interface IPromote{
    struct _UserInfo {
        // 上線八代
        address[8] upline8Gen;
        // 以8代内的權重加總(包含自己)
        uint256 down8GenWeight;
        // 以3代内的權重加總(包含自己)
        uint256 down3GenWeight;
        //  6 代内有效地址數
        uint256 numDown6Gen;

        // 已提領獎勵
        uint256 receivedReward;

        bool isValid;
        uint8 level;
        // md 值(一代)
        uint256 numSS;
        // md 值(三代)
        uint256 numGS;
        uint256 weight;
        uint256 depositAsUsdt;
        uint256 depositedMP;
        uint256 lastRewardRound;
        uint256 pendingReward;
        // 用戶上線
        address f;
        // 下線群組
        address[] ss;
    }

    function update(uint256 amount) external;
    function getUser(address _user) external view returns (_UserInfo memory);
}

contract Preacher is Member {
    
    using SafeMath for uint256;
    uint256 public round;
    uint256 public totalRewards;
    uint256 public totalV4Rewards;
    uint256 public constant preacherCondition = 15;   // 須達到150人
    
    bool public pauseGetReward = false;
    
    IERC20 rewardToken;

    struct DaliyInfo {
        uint256 poolAmount;
        uint256 rewardedAmount;
        uint256 totalWeight;
        // 佈道者/v4  人數
        uint256 userCount;
    }

    struct UserInfo {
        uint256 weight;
        uint256 lastRewardRound;
        uint256 pendingReward;
        uint256 pendingWithdraw;
        uint256 receivedReward;
    }

    mapping(uint256 => DaliyInfo) public daliyInfo; // 佈道者池
    mapping(uint256 => DaliyInfo) public daliyV4Info; // 海盜大將池
    mapping(address => UserInfo) public userInfo;
    mapping(address => bool) public isPreacher;
    mapping(address => bool) public isV4Preacher;
    mapping(uint256 => uint256) public roundTime;
    mapping(address => uint256) public lockRequest;
    
    event NewRound(uint256 _round);
    event GetReward(address _user, uint256 _amount);
    event UpdateWeight(address _user, uint256 _amount, bool isAdd);
    event UpdatePool(uint256 amount);
    event UpdateV4Pool(uint256 amount);
    event ChangePreacherLevel(address _user, uint8 level);
    event ChangePreacherV4Level(address _user, uint8 level);
    event Recycle(uint256 amount);    // 回收
    event RecoverTokens(address token, uint256 amount, address to);
    
    modifier validSender{
        require(msg.sender == address(manager.members("PromoteAddress")) || msg.sender == manager.members("nft") || msg.sender == manager.members("updatecard"));
        _;
    }
    
    constructor(IERC20 _rewardToken) {
        rewardToken = _rewardToken;
    }
    
    function getDaliyTotalDeposited(uint256 _round) public view returns(uint256) {
        return daliyInfo[_round].totalWeight;
    }

    function claimReward(address _user) internal {
        uint256 reward = settleRewards(_user);
        userInfo[_user].pendingReward = userInfo[_user].pendingReward.add(reward);
        userInfo[_user].lastRewardRound = round;
    }
    
    // 匯入獎勵池
    function update(uint256 amount) external validSender {
        checkToNextRound();
        
        daliyInfo[round].poolAmount = daliyInfo[round].poolAmount.add(amount);
        totalRewards = totalRewards.add(amount);

        emit UpdatePool(amount);
    }

    function updateV4(uint256 amount) external validSender {
        checkToNextRound();

        daliyV4Info[round].poolAmount = daliyV4Info[round].poolAmount.add(amount);
        totalV4Rewards = totalV4Rewards.add(amount);

        emit UpdateV4Pool(amount);
    }
    
    // 更新佈道者權重
    function updateWeight(address _user, uint256 amount, bool isAdd) external validSender {
        require(amount > 0);
        claimReward(_user);
        if(isPreacher[_user]){
            if(isAdd) {
                userInfo[_user].weight = userInfo[_user].weight.add(amount);
                daliyInfo[round].totalWeight = daliyInfo[round].totalWeight.add(amount);

                // 海盜大將
                if(isV4Preacher[_user]){
                    daliyV4Info[round].totalWeight = daliyV4Info[round].totalWeight.add(amount);
                }
            }else{
                userInfo[_user].weight = userInfo[_user].weight.sub(amount);
                daliyInfo[round].totalWeight = daliyInfo[round].totalWeight.sub(amount);

                // 海盜大將
                if(isV4Preacher[_user]){
                    daliyV4Info[round].totalWeight = daliyV4Info[round].totalWeight.sub(amount);
                }
            }
            
            emit UpdateWeight(_user, amount, isAdd);    
        }
    }

    function getReward() public {
        require(pauseGetReward == false, "function is suspended");
        uint256 reward = settleRewards(msg.sender);
        uint256 payReward = reward.add(userInfo[msg.sender].pendingReward);
        IERC20(rewardToken).transfer(msg.sender, payReward);
        userInfo[msg.sender].receivedReward = userInfo[msg.sender].receivedReward.add(payReward);
        userInfo[msg.sender].pendingReward = 0;
        userInfo[msg.sender].lastRewardRound = round;
        emit GetReward(msg.sender, reward);
    }
    
    function pendingRewards(address _user) public view returns (uint256 reward){
        if (!isPreacher[_user] || userInfo[_user].weight == 0) {
            return userInfo[_user].pendingReward;
        }

        uint8 i = round.sub(userInfo[_user].lastRewardRound) >= 15 ? 15: uint8(round.sub(userInfo[_user].lastRewardRound));
        for(i; i >0; i--) {
            if(daliyInfo[round-i].poolAmount != 0 && daliyInfo[round-i].totalWeight != 0){
                reward = reward.add(daliyInfo[round-i].poolAmount.mul(userInfo[_user].weight).div(daliyInfo[round-i].totalWeight));
            }
            if(isV4Preacher[_user]) {
                if(daliyV4Info[round-i].poolAmount != 0 && daliyV4Info[round-i].totalWeight != 0){
                    reward = reward.add(daliyV4Info[round-i].poolAmount.mul(userInfo[_user].weight).div(daliyV4Info[round-i].totalWeight));
                }
            }
        }
        reward = reward.add(userInfo[_user].pendingReward);
    }

    function settleRewards(address _user) internal returns (uint256 reward){
        if (!isPreacher[_user] || userInfo[_user].weight == 0) {
            return 0;
        }
        uint8 i = round.sub(userInfo[_user].lastRewardRound) >= 15 ? 15: uint8(round.sub(userInfo[_user].lastRewardRound));

        for(i; i >0; i--) {
            uint256 roundReward;
            uint256 roundV4Reward;
            if(daliyInfo[round-i].poolAmount != 0 && daliyInfo[round-i].totalWeight != 0){
                 // (poolAmount * 用戶權重 / 當時全網總權重)
                roundReward = daliyInfo[round-i].poolAmount.mul(userInfo[_user].weight).div(daliyInfo[round-i].totalWeight);
                reward = reward.add(roundReward);
                
                daliyInfo[round-i].rewardedAmount= daliyInfo[round-i].rewardedAmount.add(roundReward);
            }
           
            if(isV4Preacher[_user]) {
                if(daliyV4Info[round-i].poolAmount != 0 && daliyV4Info[round-i].totalWeight != 0){
                    roundV4Reward = daliyV4Info[round-i].poolAmount.mul(userInfo[_user].weight).div(daliyV4Info[round-i].totalWeight);
                    reward = reward.add(roundV4Reward);

                    daliyV4Info[round-i].rewardedAmount= daliyV4Info[round-i].rewardedAmount.add(roundV4Reward);
                }
            }
            
        }
    }

    function checkToNextRound() internal {
        if(block.timestamp >= roundTime[round] + 10 minutes) {
            round++;
            roundTime[round] = block.timestamp;

            // 佈道者初始化
            daliyInfo[round].poolAmount = 0;
            daliyInfo[round].rewardedAmount = 0;
            daliyInfo[round].totalWeight = daliyInfo[round-1].totalWeight;
            daliyInfo[round].userCount = daliyInfo[round-1].userCount;

            if(round > 16) {
                uint256 _p = daliyInfo[round - 16].poolAmount.sub(daliyInfo[round - 16].rewardedAmount);
                if(_p > 0){
                    IERC20(rewardToken).transfer(address(manager.members("funder")), _p);
                    emit Recycle(_p);    // 回收
                }
            }

            // 海盜大將初始化
            daliyV4Info[round].poolAmount = 0;
            daliyV4Info[round].rewardedAmount = 0;
            daliyV4Info[round].totalWeight = daliyV4Info[round-1].totalWeight;
            daliyV4Info[round].userCount = daliyV4Info[round-1].userCount;

            if(round > 16) {
                uint256 _p = daliyV4Info[round - 16].poolAmount.sub(daliyV4Info[round - 16].rewardedAmount);
                if(_p > 0){
                    IERC20(rewardToken).transfer(address(manager.members("funder")), _p);
                    emit Recycle(_p);    // 回收
                }
            }

            emit NewRound(round);
        }
    }

    function upgradePreacher(address _user) external {
        IPromote._UserInfo memory promoteUserInfo = IPromote(manager.members("PromoteAddress")).getUser(_user);
        uint256 userWeight = userInfo[_user].weight;
        // 檢查傳教士等級升降
        checkPreacherLevel(_user, promoteUserInfo);
        // 檢查傳教士海盜大將升降
        checkPreacherV4Level(_user, promoteUserInfo, userWeight);
        
    }
    
    function checkIsPreacher(address _user) external view returns (bool) {
       return isPreacher[_user];
    }
    
    function checkPreacherLevel(address _user, IPromote._UserInfo memory promoteUserInfo) internal validSender {
        // 檢查是否為傳教士
        if(isPreacher[_user]){
            // 檢查降級條件
            if(promoteUserInfo.level < 2 || promoteUserInfo.numDown6Gen < preacherCondition){
                claimReward(_user);
                delete isPreacher[_user];
                // 移除權重
                daliyInfo[round].totalWeight = daliyInfo[round].totalWeight.sub(userInfo[_user].weight);
                userInfo[_user].weight = 0;
                daliyInfo[round].userCount--;

                emit ChangePreacherLevel(_user,0);
            }
        }else{
            // 檢查升級條件
            if(promoteUserInfo.level >= 2 && promoteUserInfo.numDown6Gen >= preacherCondition){
                claimReward(_user);
                isPreacher[_user] = true;
                // 加入權重
                userInfo[_user].weight = promoteUserInfo.down8GenWeight;
                daliyInfo[round].totalWeight = daliyInfo[round].totalWeight.add(userInfo[_user].weight);
                daliyInfo[round].userCount++;

                emit ChangePreacherLevel(_user,1);
            }
        }
    }
    
    function checkPreacherV4Level(address _user, IPromote._UserInfo memory promoteUserInfo, uint256 oldWeight) internal {
        // 檢查是否為傳教士海盜大將
        if(isV4Preacher[_user]){
            // 檢查降級條件
            if(!isPreacher[_user] || promoteUserInfo.level != 4){
                claimReward(_user);
                delete isV4Preacher[_user];
                // 移除權重
                // 拿舊的權重
                daliyV4Info[round].totalWeight = daliyV4Info[round].totalWeight.sub(oldWeight);
                daliyV4Info[round].userCount--;

                emit ChangePreacherV4Level(_user,0);
            }
        }else{
            // 檢查升級條件
            if(isPreacher[_user] && promoteUserInfo.level == 4){
                claimReward(_user);
                isV4Preacher[_user] = true;
                // 加入權重(拿最新的權重)
                daliyV4Info[round].totalWeight = daliyV4Info[round].totalWeight.add(userInfo[_user].weight);
                daliyV4Info[round].userCount++;

                emit ChangePreacherV4Level(_user,1);
            }
        }
    }
    
    function setPauseGetReward(bool _pause) external {
        require(manager.members("owner") != address(0), "member owner empty");
        require(msg.sender == manager.members("owner"), "only owner");
        pauseGetReward = _pause;
    }

    function setPauseAll(bool _pause) external {
        require(manager.members("owner") != address(0), "member owner empty");
        require(msg.sender == manager.members("owner"), "only owner");
        pauseGetReward = _pause;
    }

    function recoverTokens(address token, uint256 amount, address to) external {
        require(manager.members("owner") != address(0), "member owner empty");
        require(msg.sender == manager.members("owner"), "only owner");
        require(IERC20(token).balanceOf(address(this)) >= amount, "balance not enough");
        IERC20(token).transfer(to, amount);
        emit RecoverTokens(token, amount, to);
    }

    function tokenChange(IERC20 _rewardToken) external {
        require(manager.members("owner") != address(0), "member owner empty");
        require(msg.sender == manager.members("owner"), "onlyOwner");
        rewardToken = _rewardToken;
    }
}

pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

// SPDX-License-Identifier: SimPL-2.0


import "../Utils/IERC20.sol";
import "../Utils/IERC721.sol";
import "../Utils/SafeMath.sol";
import "../Utils/SafeERC20.sol";
import "../Manager/Member.sol";


interface INFT{
    struct starAttributesStruct{
      address origin;   //发布者
      string  IphsHash;//hash
      uint256 power;//nft等级
      uint256 price;   //价格
      uint256 stampFee;  //版税
      bool offical;
      uint256 createTime;  //鑄造時間
    }
    function transferFrom(address _from,address _to,uint256 _tokenId)external;
    function approve(address _approved,uint256 _tokenId) external;
    function safeTransferFrom(address _from,address _to,uint256 _tokenId) external;
    function viewTokenID() view external returns(uint256);
    function setTokenTypeAttributes(uint256 _tokenId,uint8 _typeAttributes,uint256 _tvalue) external;
    function transferList(address _to,uint256[] calldata _tokenIdList) external;
    function ownerOf(uint256 _tokenID) external returns (address _owner);
    function getStarAttributes(uint256 _tokenID) external view returns(starAttributesStruct memory nftAttr);
}


contract NFTExchange is Member{
    
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    event CreateOrder(address indexed maker, uint256 indexed tokenid, bool canExchange, uint256 payAmount, uint8 payment);
    event TradeOrder(uint256 indexed tokenid, address maker, address taker, bytes32 orderid, uint256 payAmount, uint8 payment);
    event NewFee(uint8 payment, uint256 payAmount);
    event CancelOrder(uint256 indexed tokenid);
    event ChangeTxFee(uint256 txFees,uint256 newTxFee);
    event CancelBid(uint256 indexed tokenid, uint256 amount, address user);
       


    // event TradeOrder(uint256 tokenid,address maker,address sender,uint256 orderid,uint256 payamount,uint8 payment);
    // event CreateAuctionOrder(address indexed creater, uint256 tokenid, uint256 acutionAmount);
    event HighestBidIncreased(address bidder, uint amount, uint256 tokenid, uint8 payment);
    event AuctionEnded(address winner, uint amount, uint256 tokenId, uint8 payment);


    // struct AuctionOrder {
    //     address     maker;         //发起者
    //     uint256     nftid;
    //     uint256     auctionAmount;       //拍卖价格
    //     // bool        isBid;       //是否拍卖出去
    //     bool       payment;
       
    // }

    struct ExchangeOrder {
        address     maker;
        address     taker;
        uint256     nftid;
        uint256     payAmount;
        uint256     createTime;
        uint256     tradeTime;
        uint8       payment;
        bool        canExchange;
    }

    struct TakerOrder {
        address     taker;         //发起者
        uint256     auctionAmount;       //拍卖价格
    }


    // mapping(uint256 => AuctionOrder) private auctionOrders;
    mapping(uint256 => mapping(address=>TakerOrder)) public takerOrders;
    mapping(uint256 => address[]) public auctionOrdersArray;

    mapping(uint256 => ExchangeOrder) public makerOrders;
    mapping(bytes32 => ExchangeOrder) public tradeOrders;
    uint256 public  txFees = 200;

    IERC20 public usdt;
    IERC20 public mp;

    constructor(IERC20 _usdt, IERC20 _mp)
         {
            usdt = _usdt;
            mp = _mp;
    }

    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
    
    function createOrder(uint256 tokenid, uint256 tradePrice,uint8 payment, bool canExchange) external {    //创建订单
        require(makerOrders[tokenid].maker == address(0), "Exists Order!");
        if(canExchange == false) {
            require(tradePrice == 2**256 - 1);
        }
        INFT.starAttributesStruct memory nftAttr = INFT(manager.members("nft")).getStarAttributes(tokenid);
        if(nftAttr.offical == true) {
            require(payment == 2, "offical NFT can only support MP token");
        }
        IERC721(manager.members("nft")).transferFrom(msg.sender, address(this), tokenid);   //调用者转入自身token到本合约
        makerOrders[tokenid].maker = msg.sender;
        makerOrders[tokenid].nftid = tokenid;
        makerOrders[tokenid].payAmount = tradePrice;
        makerOrders[tokenid].payment = payment;
        makerOrders[tokenid].createTime = block.timestamp;
        makerOrders[tokenid].canExchange = canExchange;
        emit CreateOrder(msg.sender, tokenid, canExchange, tradePrice,payment);
    }


    function changePrice(uint256 tokenid, uint256 newPrice) public returns(bool){
        require(block.timestamp > makerOrders[tokenid].createTime,"Time wrong!");
        require(makerOrders[tokenid].maker == msg.sender, "Only Order Creater!");
        require(makerOrders[tokenid].canExchange == true);
        makerOrders[tokenid].payAmount = newPrice;
        makerOrders[tokenid].createTime = block.timestamp;
        return true;
    }

    
    function takeOrder(uint256 tokenid) external payable {
        require(!isContract(msg.sender), "Address: call to non-contract");
        require(msg.sender == tx.origin,"Only EOA!");
        ExchangeOrder memory order = makerOrders[tokenid];
        require(order.maker != address(0), "Not Exists Order!");
        require(makerOrders[tokenid].canExchange == true);
        uint256 payAmount = order.payAmount;

        INFT.starAttributesStruct memory nftAttr = INFT(manager.members("nft")).getStarAttributes(tokenid);

        //收取手续费
        uint256 tradeFee;
        uint256 stampFee;
        uint256 sendAmount;
        {
            uint256 fee = getTxFee(nftAttr.createTime);
            tradeFee = payAmount.mul(fee.sub(nftAttr.stampFee)).div(1000);   // 扣掉版稅，剩下當作手續費
            stampFee = payAmount.mul(nftAttr.stampFee).div(1000);   //收取版税
            sendAmount = payAmount.sub(tradeFee).sub(stampFee);
        }
       
        uint8 payment  = order.payment;
        if (payment == 0) {
            require(msg.value == payAmount);

            // 退還其他拍賣出價
            bidBackBnb(tokenid);
            
            payable(manager.members("funder")).transfer(tradeFee);
            payable(nftAttr.origin).transfer(stampFee);
            payable(order.maker).transfer(sendAmount);
            emit NewFee(payment, tradeFee);
        } else {
            IERC20 token;
            if (payment == 1) {
                token = usdt;
            }
            if (payment == 2) {
                token = mp;
            }

            // 退還其他拍賣出價
            bidBackToken(tokenid, token);

            IERC20(token).safeTransferFrom(msg.sender, manager.members("funder"), tradeFee);
            IERC20(token).safeTransferFrom(msg.sender, nftAttr.origin, stampFee);
            IERC20(token).safeTransferFrom(msg.sender, order.maker, sendAmount);

            emit NewFee(payment, tradeFee);
        }
        IERC721(manager.members("nft")).transferFrom(address(this), msg.sender, tokenid);  //将nft发送给购买者
        
        order.taker = msg.sender;
        order.tradeTime = block.timestamp;
        bytes32 orderid = keccak256(abi.encode(
            tokenid,
            order.maker,
            order.taker,
            block.number
        ));
        
        delete makerOrders[tokenid];
        tradeOrders[orderid] = order;             //增加订单购买信息
        emit TradeOrder(tokenid, order.maker, msg.sender, orderid, payAmount, payment);
    }
    
    function cancelOrder(uint256 tokenid) external {         //取消订单
        ExchangeOrder memory order = makerOrders[tokenid];
        require(order.maker == msg.sender, "invalid card");
        IERC721(manager.members("nft")).transferFrom(address(this),msg.sender, tokenid);
        uint8 payment = makerOrders[tokenid].payment;
        if(auctionOrdersArray[tokenid].length >0){
            if (payment == 0) {
                for(uint256 i=0;i<auctionOrdersArray[tokenid].length;i++){           //退還其他拍賣出價
                    address bidder = auctionOrdersArray[tokenid][i];
                    uint256 backAmount = takerOrders[tokenid][bidder].auctionAmount;
                    payable(bidder).transfer(backAmount);
                    delete takerOrders[tokenid][bidder];
                    emit CancelBid(tokenid, backAmount, bidder);
                }
                delete auctionOrdersArray[tokenid];    
            } else {
                IERC20 token;
                if (payment == 1) {
                    token = usdt;
                }
                if (payment == 2) {
                    token = mp;
                }
                for(uint256 i=0;i<auctionOrdersArray[tokenid].length;i++){           //退還其他拍賣出價
                    address bidder = auctionOrdersArray[tokenid][i];
                    uint256 backAmount = takerOrders[tokenid][bidder].auctionAmount;
                    IERC20(token).transfer(bidder, backAmount);
                    delete takerOrders[tokenid][bidder];
                    emit CancelBid(tokenid, backAmount, bidder);
                }
                delete auctionOrdersArray[tokenid];   
            }
        }
        delete makerOrders[tokenid];
        emit CancelOrder(tokenid);
    }
    
    function getMakerOrder(uint256 tokenid) external view returns(ExchangeOrder memory) {
        return makerOrders[tokenid];
    }
    
    function getTradeOrder(bytes32 tokenid) external view returns(ExchangeOrder memory) {
        return tradeOrders[tokenid];
    }

    function setTxFee(uint256 newTxFee) public {
        require(msg.sender == manager.members("owner"));
        require(newTxFee <= 200, "tx Fee to high!");    // max 20%
        emit ChangeTxFee(txFees,newTxFee);
        txFees = newTxFee;
       
    }

    function getTxFee(uint256 createTime) public view returns(uint256 fee) {
        // 初始手續費20%，以后每15天递减2.5%共遞減6次直至5%後固定，其中2% 作為版权费給 mint holder，其餘项目方。 
         uint256 round =  (block.timestamp.sub(createTime)).div(15 minutes);
        
        // 最低5%
        if(round >= 6){
            return 50;
        }

        fee = txFees.sub(round.mul(25));
    }

    function bid(uint256 tokenid, uint256 acutionAmount) public  payable{
        require(!isContract(msg.sender), "Address: call to non-contract");
        require(msg.sender == tx.origin,"Only EOA!");
        address user = msg.sender;
        uint8 payment = makerOrders[tokenid].payment;
        uint256 oldAuctionAmount = takerOrders[tokenid][user].auctionAmount;
        // require(
        //     acutionAmount < makerOrders[tokenid].payAmount,
        //     "You can take order instead of bidding"
        // );
        // require(takerOrders[tokenid][user].taker == address(0), "You have bided!");
        if(!(takerOrders[tokenid][user].taker == address(0))){                  //Rebid
            
            if (payment == 0) {
                
                payable(user).transfer(oldAuctionAmount);
            } else {
                IERC20 token;
                if (payment == 1) {
                    token = usdt;
                }
                if (payment == 2) {
                    token = mp;
                } 
                IERC20(token).transfer(user,oldAuctionAmount);
            }
        }
        
        if (payment == 0) {
            require(msg.value == acutionAmount);
            // address(this).transfer(acutionAmount);
        } else {
            IERC20 token;
            if (payment == 1) {
                token = usdt;
            }
            if (payment == 2) {
                token = mp;
            } 
            IERC20(token).transferFrom(msg.sender, address(this), acutionAmount);
        }
        takerOrders[tokenid][user].taker = user;
        takerOrders[tokenid][user].auctionAmount = acutionAmount;
   
        // auctionOrders[tokenid].isBid = true;
        if(oldAuctionAmount == 0){           //Only first bid
            auctionOrdersArray[tokenid].push(user);
        } 
        emit HighestBidIncreased(msg.sender, acutionAmount, tokenid, payment);
    }


    // function reBid(uint256 tokenid, uint256 newAcutionAmount) public payable returns(bool){
    //     cancelBid(tokenid);
    //     bid(tokenid,newAcutionAmount);
    //     emit ReBid(tokenid,newAcutionAmount);
    //     return true;
    // }



    function cancelBid(uint256 tokenid) public payable{
        address payable user = msg.sender;
   
        require(takerOrders[tokenid][user].taker == user, "No permission");
        require(auctionOrdersArray[tokenid].length >0, "end!");
        // IERC20 token = makerOrders[tokenid].payment? usdt:mp;
        uint8 payment = makerOrders[tokenid].payment;
        if (payment == 0) {
            user.transfer(takerOrders[tokenid][user].auctionAmount);
        } else {
            IERC20 token;
            if (payment == 1) {
                token = usdt;
            }
            if (payment == 2) {
                token = mp;
            }
            IERC20(token).transfer(user, takerOrders[tokenid][user].auctionAmount);
        }
        delete takerOrders[tokenid][user];
        uint256 index = 0;
        uint256 indexLast = auctionOrdersArray[tokenid].length - 1; 
        for(uint256 i=0;i<auctionOrdersArray[tokenid].length;i++){
                if(auctionOrdersArray[tokenid][i] == user){
                    index = i;
                    break;
                }
        }
        address lastuser = auctionOrdersArray[tokenid][indexLast];
        auctionOrdersArray[tokenid][index] = lastuser;
        auctionOrdersArray[tokenid].pop();

    }

    /// 结束拍卖
    function auctionEnd(uint256 tokenid,address taker) public payable{

        require(msg.sender == makerOrders[tokenid].maker, "No permission to end");
        require(msg.sender == tx.origin,"Only EOA!");
        uint8 payment = makerOrders[tokenid].payment;
        if(auctionOrdersArray[tokenid].length >0){
            emit AuctionEnded(taker,takerOrders[tokenid][taker].auctionAmount, tokenid, payment);
            IERC721(manager.members("nft")).transferFrom(address(this),taker,tokenid);

            INFT.starAttributesStruct memory nftAttr = INFT(manager.members("nft")).getStarAttributes(tokenid);


            //收取手续费
            uint256 fee = getTxFee(nftAttr.createTime);
            uint256 tradeFee = takerOrders[tokenid][taker].auctionAmount.mul(fee.sub(nftAttr.stampFee)).div(1000);   // 扣掉版稅，剩下當作手續費
            
            uint256 stampFee = takerOrders[tokenid][taker].auctionAmount.mul(nftAttr.stampFee).div(1000);
            uint256 sendAmount = takerOrders[tokenid][taker].auctionAmount.sub(tradeFee).sub(stampFee);
            
            if (payment == 0) {
                payable(manager.members("funder")).transfer(tradeFee);
                payable(nftAttr.origin).transfer(stampFee);
                payable(makerOrders[tokenid].maker).transfer(sendAmount);

                emit NewFee(payment, tradeFee);

                for(uint256 i=0;i<auctionOrdersArray[tokenid].length;i++){           //退還其他拍賣出價
                    
                    if(auctionOrdersArray[tokenid][i] == taker){
                        delete takerOrders[tokenid][auctionOrdersArray[tokenid][i]];
                        continue;                                              //结束此次循环到下次循环
                    }
                    else{
                        address otherTaker = auctionOrdersArray[tokenid][i];
                        uint256 backAmount = takerOrders[tokenid][otherTaker].auctionAmount;
                        payable(otherTaker).transfer(backAmount);
                        delete takerOrders[tokenid][otherTaker];
                    }
                    
                }
            } else {
                IERC20 token;
                if (payment == 1) {
                    token = usdt;
                }
                if (payment == 2) {
                    token = mp;
                }
                IERC20(token).transfer(manager.members("funder"), tradeFee);
                IERC20(token).transfer(nftAttr.origin, stampFee);
                IERC20(token).transfer(makerOrders[tokenid].maker,sendAmount);

                emit NewFee(payment, tradeFee);

                for(uint256 i=0;i<auctionOrdersArray[tokenid].length;i++){           //退還其他拍賣出價
                    
                    if(auctionOrdersArray[tokenid][i] == taker){
                        delete takerOrders[tokenid][auctionOrdersArray[tokenid][i]];
                        continue;                                              //结束此次循环到下次循环
                    } else{
                        address otherTaker = auctionOrdersArray[tokenid][i];
                        uint256 backAmount = takerOrders[tokenid][otherTaker].auctionAmount;
                        IERC20(token).transfer(otherTaker, backAmount);
                        delete takerOrders[tokenid][otherTaker];
                    }
                    
                }
            }
            
        }
        else{       //流拍
            IERC721(manager.members("nft")).transferFrom(address(this),makerOrders[tokenid].maker,tokenid);
        }
        delete makerOrders[tokenid];
        delete auctionOrdersArray[tokenid];
    }




    // function getTakerOrder(uint256 tokenid) public view returns(TakerOrder[] memory) {
    //     TakerOrder[] memory takerorders;
    //     for(uint256 i=0;i<auctionOrdersArray[tokenid].length;i++){
    //             address taker = auctionOrdersArray[tokenid][i];
    //             TakerOrder memory order = takerOrders[tokenid][taker];
    //             takerorders[i] = order;

    //     }
    //     return takerorders;
    // }
    function bidBackBnb(uint256 tokenid) internal {
       for(uint256 i=0;i<auctionOrdersArray[tokenid].length;i++){           //退還其他拍賣出價
            address bidder = auctionOrdersArray[tokenid][i];
            uint256 backAmount = takerOrders[tokenid][bidder].auctionAmount;
            payable(bidder).transfer(backAmount);
            delete takerOrders[tokenid][bidder];
            emit CancelBid(tokenid, backAmount, bidder);
        }
        delete auctionOrdersArray[tokenid];
    }

    function bidBackToken(uint256 tokenid, IERC20 token) internal {
       for(uint256 i=0;i<auctionOrdersArray[tokenid].length;i++){           //退還其他拍賣出價
            address bidder = auctionOrdersArray[tokenid][i];
            uint256 backAmount = takerOrders[tokenid][bidder].auctionAmount;
            IERC20(token).transfer(bidder, backAmount);
            delete takerOrders[tokenid][bidder];
            emit CancelBid(tokenid, backAmount, bidder);
        }
        delete auctionOrdersArray[tokenid];
    }

    receive() external payable{}
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
import "../Manager/Member.sol";
import "../Utils/IERC20.sol";
import "../Utils/SafeMath.sol";
import "../Utils/SafeERC20.sol";

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Pair {
    function balanceOf(address owner) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}


interface INFT{
    function transferFrom(address _from,address _to,uint256 _tokenId)external;
    function approve(address _approved,uint256 _tokenId) external;
    function safeTransferFrom(address _from,address _to,uint256 _tokenId) external;
    function viewTokenID() view external returns(uint256);
    function setTokenTypeAttributes(uint256 _tokenId,uint8 _typeAttributes,uint256 _tvalue) external;
    function transferList(address _to,uint256[] calldata _tokenIdList) external;
    function ownerOf(uint256 _tokenID) external returns (address _owner);
    function starAttributes(uint256 _tokenID) external view returns(address,string memory,uint256,uint256,uint256,bool,uint256);
    function batchTransferFrom(address from, address to,uint256[] calldata tokenIds) external; 
    function burn(uint256 Id) external;
    function changePower(uint256 tokenId,uint256 power)external returns(bool);
}

interface IPromote{
    struct _UserInfo {// 上線八代
        address[8] upline8Gen;
        // 以8代内的權重加總(包含自己)
        uint256 down8GenWeight;
        // 以3代内的權重加總(包含自己)
        uint256 down3GenWeight;
        //  6 代内有效地址數
        uint256 numDown6Gen;

        // 已提領獎勵
        uint256 receivedReward;

        bool isValid;
        uint8 level;
        // md 值(一代)
        uint256 numSS;
        // md 值(三代)
        uint256 numGS;
        uint256 weight;
        uint256 depositAsUsdt;
        uint256 depositedMP;
        uint256 lastRewardRound;
        uint256 pendingReward;
        // 用戶上線
        address f;
        // 下線群組
        address[] ss;
    }

    struct User3GenWeight {
        // 1、2、3代的權重加總(不含加成)
        uint256 gen3Weight;
        uint256 gen2Weight;
        uint256 gen1Weight;
        // 1、2、3代代加成百分比(6 = 6%)
        uint256 gen3Bonus;
        uint256 gen2Bonus;
        uint256 gen1Bonus;
    }
    // 全網3代加成總權重
    function total3GenBonusWeight() external view returns (uint256);
    function invalid3GenBonusWeight() external view returns (uint256);
    function getUser3GenWeight(address _user) external view returns (User3GenWeight memory);
    function update(uint256 amount) external;
    function getUser(address _user) external view returns (_UserInfo calldata);
    function newDeposit(address sender, uint256 weight, uint256 amount) external;
    function redem(address sender, uint256 weight, uint256 amount) external;
    function updateUserBouns(address _user) external;
}

interface ITokenStake{
    function update(uint256 amount) external;
}

contract NFT_MasterChef is Ownable, Member {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 receivedReward;
        uint256 rewardDebt; 
        uint256 pendingReward;
        uint256[]  _nftBalances;
        uint256 lvMore1Count;   // 擁有level > 1的nft數量
    }

    struct PoolInfo {
        address lpToken;           
        uint256 allocPoint;       
        uint256 lastRewardBlock;  
        uint256 accSushiPerShare; 
        uint256 totalStakingNFTAmount;
    }


    IERC20 public mp;
    IPromote internal promote;

    uint256 public bonusEndBlock;
    uint256 public sushiPerBlock;
    uint256 public sushiPerBlockOrigin;

    PoolInfo[] public poolInfo;
    uint256[] public nftweight = [100,210,440,920,2000,4200];
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;
    uint256 public fifteenDays = 15 minutes;
    
    bool public pauseStake = false;
    bool public pauseWithdraw = false;
    bool public pauseGetReward = false;
    
    address public usdt;
    IUniswapV2Pair public pair;

    
    //mapping(address => uint256[]) public _nftBalances;
    mapping(address => mapping(uint256 => bool)) public isInStating;
    mapping(uint256 => uint256) public lockedTime;
    uint256 maxWithAmount = 10;

    uint256 public lastCutBlock;
    uint256 constant public CUT_PERIOD = 20 * 24 * 3600;
    
    uint256 public level;
    uint256 public constant MAX_REWARD_WEIGHT = 5000000;  // 50w
    

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event DepositNFT(address indexed user, uint256 indexed pid, uint256 _tokenID);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event WithdrawNFT(address indexed user, uint256 indexed pid, uint256 _tokenID);
    event ChangeFee(uint256 indexed origunfee, uint256 newfee);
    event UpdatePool(uint256 indexed pid, uint256 timestamp);
    event OriginPerShareChanged(uint256 _before, uint256 _current);
    event PerShareChanged(uint256 _before, uint256 _current);
    event RecoverTokens(address token, uint256 amount, address to);

    constructor(
        IERC20 _mp,
        address _usdt,
        IPromote _promote, 
	    IUniswapV2Pair _pair,
        uint256 _sushiPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock
        
    ) {
        mp = _mp;
        usdt = _usdt;
        promote = _promote;
	    pair = _pair;
        sushiPerBlockOrigin = _sushiPerBlock;
        bonusEndBlock = _bonusEndBlock;
        startBlock = _startBlock;
        lastCutBlock = _startBlock;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }
    
    function getUser(address _user) external view returns(UserInfo memory) {
        uint256 _pid = 0;
        return userInfo[_pid][_user];
    }

    function getBalances(uint256 _pid, address _user) external view returns (uint256[] memory) {
        return userInfo[_pid][_user]._nftBalances;
    }
    
    function balanceOfNFT(uint256 _pid,address account) public view returns(uint256){
        return userInfo[_pid][account]._nftBalances.length;
    }
    function balanceOfByIdex(uint256 _pid,address account,uint256 index) public view returns(uint256){
        return userInfo[_pid][account]._nftBalances[index];
    }

    function add(uint256 _allocPoint, address _lpToken, bool _withUpdate) public onlyOwner {
        require(address(_lpToken) != address(0),'address invalid');
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accSushiPerShare: 0,
            totalStakingNFTAmount:0
        }));
    }

    function timeLockChange(uint256 _period) public {
        require(msg.sender == manager.members("owner"), "onlyOwner");
        fifteenDays = _period;
    }

    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        if (_to <= bonusEndBlock) {
            return _to.sub(_from);
        } else if (_from >= bonusEndBlock) {
            return _to.sub(_from);
        } else {
            return bonusEndBlock.sub(_from).add(
                _to.sub(bonusEndBlock)
            );
        }
    }

    // View function to see pending SUSHIs on frontend.
    function pendingSushi(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accSushiPerShare = pool.accSushiPerShare;
        uint256 lpSupply = IPromote(promote).total3GenBonusWeight().sub(IPromote(promote).invalid3GenBonusWeight());
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 sushiReward = multiplier.mul(sushiPerBlock).mul(pool.allocPoint).div(totalAllocPoint);

            // 产出总量的95%加权给NFT质押池，3%分配给添加LP質押池，2%分配给MP靜態池
            uint256 toLpAmount = sushiReward.mul(3).div(100);
            uint256 toMpAmount = sushiReward.mul(2).div(100);
            uint256 rewardAmount = sushiReward.sub(toLpAmount).sub(toMpAmount);

            accSushiPerShare = accSushiPerShare.add(rewardAmount.mul(1e12).div(lpSupply));
        }

        uint256 userTotalWeight = getUserTotalWeight(_user);
        uint256 _pendding;
        if(userTotalWeight > 0){
            _pendding = userTotalWeight.mul(accSushiPerShare).div(1e12).sub(user.rewardDebt);
        }

        return user.pendingReward.add(_pendding);
    }

    // Update reward vairables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number < pool.lastRewardBlock) {
            return;
        }

        uint256 lpSupply = IPromote(promote).total3GenBonusWeight().sub(IPromote(promote).invalid3GenBonusWeight());
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        // 每達到 1,728,000 個區塊高度（大約需要 60 天），ERA 的產出數量將減少 5%。
        if(block.number >= lastCutBlock.add(CUT_PERIOD)){
            lastCutBlock = block.number;
            sushiPerBlockOrigin = sushiPerBlockOrigin.mul(95).div(100);
        }

        if(level != 0){
            uint256 newSushiPerBlock;
            if(lpSupply<MAX_REWARD_WEIGHT){
                // 未滿產按照比例
                newSushiPerBlock = sushiPerBlockOrigin.mul(level).mul(lpSupply).div(MAX_REWARD_WEIGHT);
            }else{
                // 滿產
                newSushiPerBlock = sushiPerBlockOrigin;
            }
            emit PerShareChanged(sushiPerBlock, newSushiPerBlock);
            sushiPerBlock = newSushiPerBlock;
        }

        // level只會有 0 or 1
        uint256 level2 = lpSupply >= 6000 ? 1: 0;

        // 等級改變
        if(level2 != level) {
            level = level2;
            uint256 newSushiPerBlock;
            if(level == 0) {
               newSushiPerBlock = 0;
            }else{
                if(lpSupply < MAX_REWARD_WEIGHT){
                    // 未滿產按照比例
                    newSushiPerBlock = sushiPerBlockOrigin.mul(level).mul(lpSupply).div(MAX_REWARD_WEIGHT);
                }else{
                    // 滿產
                    newSushiPerBlock = sushiPerBlockOrigin;
                }
            }
            emit PerShareChanged(sushiPerBlock, newSushiPerBlock);
            sushiPerBlock = newSushiPerBlock;
        }

        if (level == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        //與上次生產mp的相差塊數
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        if (multiplier == 0) {
            return;
        }
        // 這段時間的總派發Mp * 1 / 1
        uint256 sushiReward = multiplier.mul(sushiPerBlock).mul(pool.allocPoint).div(totalAllocPoint);

        // 产出总量的95%加权给NFT质押池，3%分配给添加LP質押池，2%分配给MP靜態池
        uint256 toLpAmount = sushiReward.mul(3).div(100);
        uint256 toMpAmount = sushiReward.mul(2).div(100);
        uint256 rewardAmount = sushiReward.sub(toLpAmount).sub(toMpAmount);
        
        IERC20(mp).transfer(address(manager.members("LPAddress")),toLpAmount);  
        ITokenStake(manager.members("LPAddress")).update(toLpAmount);
        IERC20(mp).transfer(address(manager.members("MPAddress")),toMpAmount);
        ITokenStake(manager.members("MPAddress")).update(toMpAmount);

        pool.accSushiPerShare = pool.accSushiPerShare.add(rewardAmount.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
        emit UpdatePool(_pid, block.timestamp);
    }
    function deposit(uint256 _pid, uint256[] memory tokenIDList) public{
        require(pauseStake == false, "function is suspended");
        require(tokenIDList.length > 0, "Cannot stake 0");
        updatePool(_pid);
        claimReward(_pid, msg.sender);
        uint256 _amount = _stake(_pid,tokenIDList);
        deposit_In(_pid,_amount);
        updatePool(_pid);

        // 算個人負債
        uint256 userTotalWeight = getUserTotalWeight(msg.sender);
        if(userTotalWeight > 0){
            userInfo[_pid][msg.sender].rewardDebt = userTotalWeight.mul(poolInfo[_pid].accSushiPerShare).div(1e12);
        }
    }
    // 更新user在IPromote的權重
    function deposit_In(uint256 _pid, uint256 _amount) internal {
        IPromote(promote).newDeposit(msg.sender,0, _amount);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function claimReward(uint256 _pid, address _user) public {
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];

        uint256 userTotalWeight = getUserTotalWeight(_user);
        if (userTotalWeight > 0) {
           
            uint256 pending = userTotalWeight.mul(pool.accSushiPerShare).div(1e12).sub(user.rewardDebt);
            if(pending>0){
                user.pendingReward = user.pendingReward.add(pending);
            }
            user.rewardDebt = userTotalWeight.mul(pool.accSushiPerShare).div(1e12);
        } 
    }

    function updateRewardDebt(address _user) external {
        require(msg.sender == address(promote), "promoteOwner");
        // 算個人負債
        uint256 userTotalWeight = getUserTotalWeight(_user);
        if(userTotalWeight > 0){
            userInfo[0][_user].rewardDebt = userTotalWeight.mul(poolInfo[0].accSushiPerShare).div(1e12);
        }
    }

    function _stake(uint256 _pid,uint256[] memory amount) internal returns(uint256 totalAmount){
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 len = amount.length;
        uint256 tokenID;
        require(len <= maxWithAmount,"can not big then maxWithAmount");
        for(uint256 i=0;i<len;i++){
            tokenID = amount[i];
            require(!isInStating[msg.sender][tokenID],"already exit");
            require(INFT(pool.lpToken).ownerOf(tokenID) == msg.sender,"not ownerOf");
            lockedTime[tokenID] = block.timestamp;
            (,,uint256 Grade,,,,) = INFT(pool.lpToken).starAttributes(tokenID);
            require(Grade != 0, "Only offical nft can be stake");

            // 計數lv>1的nft數量
            if(Grade > 1){
                user.lvMore1Count++;
                if(user.lvMore1Count == 1){
                    IPromote(promote).updateUserBouns(msg.sender);
                }
            }

            totalAmount = totalAmount.add(nftweight[Grade - 1]);
            
            isInStating[msg.sender][tokenID] = true;
            user._nftBalances.push(tokenID);
            emit DepositNFT(msg.sender,_pid,tokenID);
        }

        pool.totalStakingNFTAmount = pool.totalStakingNFTAmount.add(len);           //更新总抵押nft数量
        INFT(pool.lpToken).batchTransferFrom(msg.sender,address(this),amount);
    }

    function withdraw(uint256 _pid,uint256 tokenid) public{
        require(pauseWithdraw == false, "function is suspended");
        require(isInStating[msg.sender][tokenid] == true,"not ownerOf");
        updatePool(_pid);
        claimReward(_pid, msg.sender);
        uint256 amount = withdrawNFT(_pid,tokenid);
        withdraw_in(_pid,amount);
        updatePool(_pid);
        
        // 算個人負債
        uint256 userTotalWeight = getUserTotalWeight(msg.sender);
        if(userTotalWeight > 0){
            userInfo[_pid][msg.sender].rewardDebt = userTotalWeight.mul(poolInfo[_pid].accSushiPerShare).div(1e12);
        }
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw_in(uint256 _pid, uint256 _amount) internal {
        IPromote(promote).redem(msg.sender , 0, _amount);
        emit Withdraw(msg.sender, _pid, _amount);
    }
    
    function getReward(uint256 _pid) public payable{
        require(pauseGetReward == false, "function is suspended");
        updatePool(_pid);
        claimReward(_pid, msg.sender);
        UserInfo storage user = userInfo[_pid][msg.sender];
        if(user.pendingReward>0){
            safeSushiTransfer(msg.sender, user.pendingReward);
            user.receivedReward = user.receivedReward.add(user.pendingReward);
            user.pendingReward = 0; 
        }
    }

    function withdrawNFT(uint256 _pid,uint256 tokenID) internal returns(uint256 totalAmount){
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 len = user._nftBalances.length;
        
        if(len == 0){
            return 0;
        }
        uint256 index = 0;
        uint256 indexLast = len.sub(1);
        uint256 TiD = 0;
        for(uint256 i = 0;i < len; i++){
            TiD = user._nftBalances[i];
            if(TiD == tokenID){
                index = i;
                break;
            } 
        }
        uint256 lastTokenId = user._nftBalances[indexLast];
        user._nftBalances[index] = lastTokenId;
        user._nftBalances.pop();
        require(block.timestamp.sub(lockedTime[tokenID]) >= fifteenDays,"NO Enough Time to lock");  
        (,,uint256 Grade,,,,)= INFT(pool.lpToken).starAttributes(tokenID); 

        // 計數lv>1的nft數量
        if(Grade > 1){
            user.lvMore1Count--;
        }

        // 取消算力額外加成
        if(user.lvMore1Count == 0) {
            IPromote(promote).updateUserBouns(msg.sender);
        }
        
        totalAmount = nftweight[Grade - 1];
        isInStating[msg.sender][tokenID] = false;
        delete lockedTime[tokenID];
        pool.totalStakingNFTAmount = pool.totalStakingNFTAmount.sub(1);
        emit WithdrawNFT(msg.sender,_pid,tokenID);
        INFT(pool.lpToken).transferFrom(address(this),msg.sender,tokenID);
    }

    function safeSushiTransfer(address _to, uint256 _amount) internal {
        uint256 sushiBal = mp.balanceOf(address(this));
        if (_amount > sushiBal) {
            mp.transfer(_to, sushiBal);
        } else {
            mp.transfer(_to, _amount);
        }
    }

    function getPrice() public view returns(uint256){
        uint256 usd_balance;
        uint256 rea_balance;
        if (pair.token0() == address(usdt)) {
          (usd_balance, rea_balance , ) = pair.getReserves();   
        }  
        else{
          (rea_balance, usd_balance , ) = pair.getReserves();           
        }
        uint256 token_price = usd_balance.mul(1e18).div(rea_balance);
        return token_price;
    }

    function getUserTotalWeight(address _user) public view returns(uint256 userTotalWeight){
        IPromote._UserInfo memory _userInfo = IPromote(promote).getUser(_user);
        if(!_userInfo.isValid){
            return 0;
        }

        IPromote.User3GenWeight memory _user3Gen = IPromote(promote).getUser3GenWeight(_user);

        if(_user3Gen.gen3Weight > 0){
            userTotalWeight = userTotalWeight.add(_user3Gen.gen3Weight.mul(_user3Gen.gen3Bonus).div(100));
        }

        if(_user3Gen.gen2Weight > 0){
            userTotalWeight = userTotalWeight.add(_user3Gen.gen2Weight.mul(_user3Gen.gen2Bonus).div(100));
        }

        if(_user3Gen.gen1Weight > 0){
            userTotalWeight = userTotalWeight.add(_user3Gen.gen1Weight.mul(_user3Gen.gen1Bonus).div(100));
        }
        userTotalWeight = userTotalWeight.add(_userInfo.weight);
        return userTotalWeight;
    }

    function setPauseStake(bool _pause) external {
        require(manager.members("owner") != address(0), "member owner empty");
        require(msg.sender == manager.members("owner"), "only owner");
        pauseStake = _pause;
    }

    function setPauseWithdraw(bool _pause) external {
        require(manager.members("owner") != address(0), "member owner empty");
        require(msg.sender == manager.members("owner"), "only owner");
        pauseWithdraw = _pause;
    }

    function setPauseGetReward(bool _pause) external {
        require(manager.members("owner") != address(0), "member owner empty");
        require(msg.sender == manager.members("owner"), "only owner");
        pauseGetReward = _pause;
    }

    function setPauseAll(bool _pause) external {
        require(manager.members("owner") != address(0), "member owner empty");
        require(msg.sender == manager.members("owner"), "only owner");
        pauseStake = _pause;
        pauseWithdraw = _pause;
        pauseGetReward = _pause;
    }

    function recoverTokens(address token, uint256 amount, address to) external {
        require(manager.members("owner") != address(0), "member owner empty");
        require(msg.sender == manager.members("owner"), "only owner");
        require(IERC20(token).balanceOf(address(this)) >= amount, "balance not enough");
        IERC20(token).transfer(to, amount);
        emit RecoverTokens(token, amount, to);
    }
    function changeConstructor(
        IERC20 _mp,
        address _usdt,
        IPromote _promote, 
	    IUniswapV2Pair _pair,
        uint256 _sushiPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock
    ) external { 
        require(manager.members("owner") != address(0), "member owner empty");
        require(msg.sender == manager.members("owner"), "only owner");
        mp = _mp;
        usdt = _usdt;
        promote = _promote;
	    pair = _pair;
        sushiPerBlockOrigin = _sushiPerBlock;
        bonusEndBlock = _bonusEndBlock;
        startBlock = _startBlock;
        lastCutBlock = _startBlock;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
import "../Utils/ERC721.sol";
import "../Utils/IERC20.sol";
import "../Utils/SafeMath.sol";
import "../Utils/String.sol";
import "../Utils/Util.sol";
import "../Utils/SafeERC20.sol";
import "../Manager/Member.sol";
interface INFT{
    function transferFrom(address _from,address _to,uint256 _tokenId)external;
    function approve(address _approved,uint256 _tokenId) external;
    function safeTransferFrom(address _from,address _to,uint256 _tokenId) external;
    function viewTokenID() view external returns(uint256);
    function setTokenTypeAttributes(uint256 _tokenId,uint8 _typeAttributes,uint256 _tvalue) external;
    function transferList(address _to,uint256[] calldata _tokenIdList) external;
    function ownerOf(uint256 _tokenID) external returns (address _owner);
    function starAttributes(uint256 _tokenID) external view returns(address,string memory,uint256,uint256,uint256,bool,uint256);
    function safeBatchTransferFrom(address from, address to,uint256[] memory tokenIds) external; 
    function burn(uint256 Id) external;
    function changePower(uint256 tokenId,uint256 power)external returns(bool);
}

interface IPromote{
    function update(uint256 amount) external;
}

interface ISuperPirate{
    function update(uint256 amount) external;
    function updateV4(uint256 amount) external; 
}

interface ITokenStake{
    function update(uint256 amount) external;
}

interface IUniswapV2Pair {
    function balanceOf(address owner) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}

contract MPUpdateCardV2 is ERC721,Member {
    using String for string;
	using SafeERC20 for IERC20;
	using SafeMath for uint256;

    modifier validSender{
        require(msg.sender == manager.members("owner"));
        _;
    }
 
    uint256 public card_Id = 0;
    INFT nft;
    IERC20 public usdt;
    IERC20 public mp;
    IUniswapV2Pair public pair;
    uint256[] public cardPowerPrice = [315,630,1260,2520,5040];
    uint8 public maxGrade = 4;
    bool public isInitailized;

    mapping(uint256 => CardAttributesStruct) public cardAttributes;
    mapping(uint256 => mapping(uint256 => CardUpdateRecord)) public updateRecord;


    event Mintcard(address indexed owner,uint256 grade, uint256 id, uint256 amount);
    event Update(address indexed user,uint256 nftId,uint256 grade,uint256 time); 

    struct CardAttributesStruct{

      uint256 grade;  //等级
    }


    struct CardUpdateRecord{
        address user;
        uint256 timeStamp;
    }

    
    constructor(INFT _nft,IERC20 _usdt, IERC20 _mp, IUniswapV2Pair _pair)
        ERC721("MetaPirate Upgrade Card", "MetaPirate Upgrade Card") {
            nft = _nft;
            usdt = _usdt;
            mp = _mp;
            pair = _pair;
    }

    function transfer(address to,uint256 tokenId) external payable returns(bool) {               //updateCard转账
        _transferFrom(msg.sender, to, tokenId);
        return true;
    }

    function batchMint(address[] memory addr, uint256[] memory lv) external {
        require(addr.length == lv.length);
        require(!isInitailized, "initailized");
        for (uint256 i = 0; i < addr.length; i++) {
            require(addr[i] != address(0));
            require(lv[i] > 1 && lv[i] <= maxGrade);
            _mint(addr[i], card_Id);
            cardAttributes[card_Id].grade = lv[i];
            card_Id++;
        }
        isInitailized = true;
    }

    function mintCard(uint256 grade) public {
            require(grade >= 2 && grade <= maxGrade,"Wrong grade!");
            address user = msg.sender;
            uint256 mp_price = getPrice();
            uint256 needPay = cardPowerPrice[grade-2].mul(1e36).div(mp_price);

            // check user balance
            uint256 amount = IERC20(mp).balanceOf(address(user));
            require(amount >= needPay, "blanace not enough");

            IERC20(mp).transferFrom(user,address(this),needPay);
            distribute(needPay);

            card_Id++;
            cardAttributes[card_Id].grade = grade;
            _mint(user, card_Id);
            emit Mintcard(user,grade,card_Id, needPay);
    }

    function updateNFT(uint256 nftId,uint256 cardId) public{
        require(nftId <= 77700, "Only offical NFT can update!");
        require(nft.ownerOf(nftId) == msg.sender,"It's not your nft");
        (,,uint256 nftGrade,,,,) = nft.starAttributes(nftId);
        uint256 grade = cardAttributes[cardId].grade;
        require(nftGrade + 1 == grade,"Grade Mismatch");
        require(tokenOwners[cardId] == msg.sender, "It's not your cardnft");
        burn(cardId);
        delete cardAttributes[cardId];
        bool res = nft.changePower(nftId, grade);
        updateRecord[nftId][grade].user = msg.sender;
        updateRecord[nftId][grade].timeStamp = block.timestamp;
        require(res == true, "update fail");
        emit Update(msg.sender,nftId, grade,block.timestamp);
    }
    
    
    function burn(uint256 Id) public {
        address owner = tokenOwners[Id];
        require(msg.sender == owner
            || msg.sender == tokenApprovals[Id]
            || approvalForAlls[owner][msg.sender],
            "msg.sender must be owner or approved");
        
        _burn(Id);
    }



    function distribute(uint256 needpay) internal{
        uint256 totalPay = 0;
        // 70% 销毁、6% 超級海盗将领池、2% LP質押池、1% MP質押池(MP靜態池)、20% 海盜將領池(MP動態池)、1% 海盜大將池。
        uint256 SuperPirateAmount = needpay.mul(6).div(105); // 6/105 超級海盗将领池
        totalPay = totalPay.add(SuperPirateAmount);

        uint256 SuperPirateV4Amount = needpay.mul(1).div(105); // 1/105 海盜大將池
        totalPay = totalPay.add(SuperPirateV4Amount);
        
        
        uint256 LPAmount = needpay.mul(2).div(105); // 2/105 LP質押池
        totalPay = totalPay.add(LPAmount);

        uint256 MPAmount = needpay.mul(1).div(105); // 1/105 MP質押池
        totalPay = totalPay.add(MPAmount);

        uint256 PromoteAmount = needpay.mul(20).div(105);   // 20/105 海盜將領池(MP動態池)
        totalPay = totalPay.add(PromoteAmount);

        uint256 OfficalAmount = needpay.mul(5).div(105);    // 5/105
        totalPay = totalPay.add(OfficalAmount);

        uint256 burnAmount = needpay.sub(totalPay);

        IERC20(mp).transfer(address(manager.members("OfficalAddress")),OfficalAmount);  
        IERC20(mp).transfer(address(manager.members("PromoteAddress")),PromoteAmount);  
        IPromote(manager.members("PromoteAddress")).update(PromoteAmount);

        IERC20(mp).transfer(address(manager.members("PreacherAddress")),SuperPirateAmount.add(SuperPirateV4Amount)); //   6/105 超級海盗将领池 + 1/105 海盜大將池
        ISuperPirate(manager.members("PreacherAddress")).update(SuperPirateAmount); 
        ISuperPirate(manager.members("PreacherAddress")).updateV4(SuperPirateV4Amount);

        IERC20(mp).transfer(address(manager.members("LPAddress")),LPAmount);  
        ITokenStake(manager.members("LPAddress")).update(LPAmount);

        IERC20(mp).transfer(address(manager.members("MPAddress")),MPAmount);  
        ITokenStake(manager.members("MPAddress")).update(MPAmount);

        IERC20(mp).burn(burnAmount);      
    }

    
    function tokenURI(uint256 NftId) external view override returns(string memory) {
        bytes memory bs = abi.encodePacked(NftId);
        return uriPrefix.concat("nft/").concat(Util.base64Encode(bs));
    }
    
    function setUriPrefix(string memory prefix)  
        external  {
        require(msg.sender == manager.members("owner"));
        uriPrefix = prefix;
    }


    function getPrice() public view returns(uint256){
        uint256 usd_balance;
        uint256 mp_balance;
        if (pair.token0() == address(usdt)) {
          (usd_balance, mp_balance , ) = pair.getReserves();   
        }  
        else{
          (mp_balance, usd_balance , ) = pair.getReserves();           
        }
        uint256 token_price = usd_balance.mul(1e18).div(mp_balance);
        return token_price;
    }

    function setMaxGrade(uint8 grade) public validSender {
        require(grade == 4 || grade == 6, "invalid grade");
        maxGrade = grade;
    }

    function switchMint(address to, uint256 grade) external returns(uint256) {
        require(manager.members("UpdateCardSwitch") == msg.sender, "member UpdateCardSwitch forbidden");

        card_Id++;
        cardAttributes[card_Id].grade = grade;
        _mint(to, card_Id);

        uint256 mp_price = getPrice();
        uint256 needPay = cardPowerPrice[grade-2].mul(1e36).div(mp_price);
        emit Mintcard(to, grade, card_Id, needPay);
        
        return card_Id;
    }
}

pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

import "./IERC165.sol";
import "./IERC721.sol";
import "./IERC721Metadata.sol";
import "./IERC721TokenReceiver.sol";
import "./IERC721TokenReceiverEx.sol";

import "./Address.sol";
import "./Util.sol";

abstract contract ERC721 is IERC165, IERC721, IERC721Metadata {
    using Address for address;
    

    bytes4 private constant INTERFACE_ID_ERC165 = 0x01ffc9a7;
    
    bytes4 private constant INTERFACE_ID_ERC721 = 0x80ac58cd;
    
    bytes4 private constant INTERFACE_ID_ERC721Metadata = 0x5b5e139f;
    
    string public override name;
    string public override symbol;
    uint256 public totalSupply = 0;
    string public uriPrefix = "https://ipfs.io/ipfs/";
    
    
    mapping(address => uint256[]) internal ownerTokens;         //玩家拥有代币数组
    mapping(uint256 => uint256) internal tokenIndexs;            //玩家拥有nft代币数组中的index
    mapping(uint256 => address) internal tokenOwners;         //根据tokenId查询玩家地址
    
    mapping(uint256 => address) internal tokenApprovals;        //代币授权
    mapping(address => mapping(address => bool)) internal approvalForAlls;       //owner对其他地址的授权
    
    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }
    
    function balanceOf(address owner) external view override returns(uint256) {
        require(owner != address(0), "owner is zero address");
        return ownerTokens[owner].length;
    }
    
    // [startIndex, endIndex)
    function tokensOf(address owner, uint256 startIndex, uint256 endIndex)
        external view returns(uint256[] memory) {
        
        require(owner != address(0), "owner is zero address");
        
        uint256[] storage tokens = ownerTokens[owner];
        if (endIndex == 0) {
            return tokens;
        }
        
        require(startIndex < endIndex, "invalid index");
        
        uint256[] memory result = new uint256[](endIndex - startIndex);
        for (uint256 i = startIndex; i != endIndex; ++i) {
            result[i] = tokens[i];
        }
        
        return result;
    }
    
    function ownerOf(uint256 tokenId)
        external view override returns(address) {
        
        address owner = tokenOwners[tokenId];
        require(owner != address(0), "nobody own the token");
        return owner;
    }
    
    function safeTransferFrom(address from, address to, uint256 tokenId)
            external payable override {
        
        safeTransferFrom(from, to, tokenId, "");
    }
    
    function safeTransferFrom(address from, address to, uint256 tokenId,
        bytes memory data) public payable override {                     //合约转账
        
        _transferFrom(from, to, tokenId);
        
        if (to.isContract()) {
            require(IERC721TokenReceiver(to)
                .onERC721Received(msg.sender, from, tokenId, data)
                == Util.ERC721_RECEIVER_RETURN,
                "onERC721Received() return invalid");
        }
    }
    
    function transferFrom(address from, address to, uint256 tokenId)
        external payable override {               //普通代理转账
        
        _transferFrom(from, to, tokenId);
    }
    
    function _transferFrom(address from, address to, uint256 tokenId)
        internal {
        
        require(from != address(0), "from is zero address");
        require(to != address(0), "to is zero address");
        
        require(from == tokenOwners[tokenId], "from must be owner");
        
        require(msg.sender == from
            || msg.sender == tokenApprovals[tokenId]
            || approvalForAlls[from][msg.sender],
            "sender must be owner or approvaled");
        
        if (tokenApprovals[tokenId] != address(0)) {
            delete tokenApprovals[tokenId];
        }
        
        _removeTokenFrom(from, tokenId);
        _addTokenTo(to, tokenId);
        
        emit Transfer(from, to, tokenId);
    }
    
    // ensure everything is ok before call it
    function _removeTokenFrom(address from, uint256 tokenId) internal {
        uint256 index = tokenIndexs[tokenId];  //0
        
        uint256[] storage tokens = ownerTokens[from];    
        uint256 indexLast = tokens.length - 1;   
        
        // save gas
        // if (index != indexLast) {
            uint256 tokenIdLast = tokens[indexLast];   //1
            tokens[index] = tokenIdLast;                 
            tokenIndexs[tokenIdLast] = index;   //tokenIndexs[1]=0
        // }
        
        tokens.pop();   //删除owner拥有nft代币数组
        
        // delete tokenIndexs[tokenId]; // save gas
        delete tokenOwners[tokenId];         //删除映射表中owner的nft记录
    }
    
    // ensure everything is ok before call it
    function _addTokenTo(address to, uint256 tokenId) internal {
        uint256[] storage tokens = ownerTokens[to];
        tokenIndexs[tokenId] = tokens.length;
        tokens.push(tokenId);
        
        tokenOwners[tokenId] = to;
    }
    
    function approve(address to, uint256 tokenId)
        external payable override {
        
        address owner = tokenOwners[tokenId];
        
        require(msg.sender == owner
            || approvalForAlls[owner][msg.sender],
            "sender must be owner or approved for all"
        );
        
        tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }
    
    function setApprovalForAll(address to, bool approved) external override {
        approvalForAlls[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }
    
    function getApproved(uint256 tokenId)
        external view override returns(address) {
        
        require(tokenOwners[tokenId] != address(0),
            "nobody own then token");
        
        return tokenApprovals[tokenId];
    }
    
    function isApprovedForAll(address owner, address operator)
        external view override returns(bool) {
        
        return approvalForAlls[owner][operator];
    }
    
    function supportsInterface(bytes4 interfaceID)
        external pure override returns(bool) {
        
        return interfaceID == INTERFACE_ID_ERC165
            || interfaceID == INTERFACE_ID_ERC721
            || interfaceID == INTERFACE_ID_ERC721Metadata;
    }

    // function _mint(address to, uint256 tokenId, string memory tokenURI) internal {
    function _mint(address to, uint256 tokenId) internal {
        _addTokenTo(to, tokenId);
        // _setTokenURI(to, tokenURI);
        ++totalSupply;
        
        emit Transfer(address(0), to, tokenId);
    }
    
    function _burn(uint256 tokenId) internal {
        address owner = tokenOwners[tokenId];
        _removeTokenFrom(owner, tokenId);
        
        if (tokenApprovals[tokenId] != address(0)) {
            delete tokenApprovals[tokenId];
        }
        
        emit Transfer(owner, address(0), tokenId);
    }
    
    function safeBatchTransferFrom(address from, address to,
        uint256[] memory tokenIds) external {                   //批量转账
        
        safeBatchTransferFrom(from, to, tokenIds, "");
    }
    
    function safeBatchTransferFrom(address from, address to,
        uint256[] memory tokenIds, bytes memory data) public {
        
        batchTransferFrom(from, to, tokenIds);
        
        if (to.isContract()) {
            require(IERC721TokenReceiverEx(to)
                .onERC721ExReceived(msg.sender, from, tokenIds, data)
                == Util.ERC721_RECEIVER_EX_RETURN,
                "onERC721ExReceived() return invalid");
        }
    }
    
    function batchTransferFrom(address from, address to,
        uint256[] memory tokenIds) public {
        
        require(from != address(0), "from is zero address");
        require(to != address(0), "to is zero address");
        
        uint256 length = tokenIds.length;
        address sender = msg.sender;
        
        bool approval = from == sender || approvalForAlls[from][sender];
        
        for (uint256 i = 0; i != length; ++i) {
            uint256 tokenId = tokenIds[i];
			
            require(from == tokenOwners[tokenId], "from must be owner");
            require(approval || sender == tokenApprovals[tokenId],
                "sender must be owner or approvaled");
            
            if (tokenApprovals[tokenId] != address(0)) {
                delete tokenApprovals[tokenId];
            }
            
            _removeTokenFrom(from, tokenId);
            _addTokenTo(to, tokenId);
            
            emit Transfer(from, to, tokenId);
        }
    }
    
    

    
}

pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

library String {
    function equals(string memory a, string memory b)
        internal pure returns(bool) {
        
        bytes memory ba = bytes(a);
        bytes memory bb = bytes(b);
        
        uint256 la = ba.length;
        uint256 lb = bb.length;
        
        for (uint256 i = 0; i != la && i != lb; ++i) {
            if (ba[i] != bb[i]) {
                return false;
            }
        }
        
        return la == lb;
    }
    
    function concat(string memory a, string memory b)
        internal pure returns(string memory) {
            
        bytes memory ba = bytes(a);
        bytes memory bb = bytes(b);
        bytes memory bc = new bytes(ba.length + bb.length);
        
        uint256 bal = ba.length;
        uint256 bbl = bb.length;
        uint256 k = 0;
        
        for (uint256 i = 0; i != bal; ++i) {
            bc[k++] = ba[i];
        }
        for (uint256 i = 0; i != bbl; ++i) {
            bc[k++] = bb[i];
        }
        
        return string(bc);
    }
}

pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

library Util {
    bytes4 internal constant ERC721_RECEIVER_RETURN = 0x150b7a02;
    bytes4 internal constant ERC721_RECEIVER_EX_RETURN = 0x0f7b88e3;
    
    uint256 public constant UDENO = 10 ** 10;
    int256 public constant SDENO = 10 ** 10;
    
    uint256 public constant RARITY_WHITE = 0;
    uint256 public constant RARITY_GREEN = 1;
    uint256 public constant RARITY_BLUE = 2;
    uint256 public constant RARITY_PURPLE = 3;
    uint256 public constant RARITY_ORANGE = 4;
    uint256 public constant RARITY_GOLD = 5;
    
    bytes public constant BASE64_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";
    
    function randomUint(bytes memory seed, uint256 min, uint256 max)
        internal pure returns(uint256) {
        
        if (min >= max) {
            return min;
        }
        
        uint256 number = uint256(keccak256(seed));
        return number % (max - min + 1) + min;
    }
    
    function randomInt(bytes memory seed, int256 min, int256 max)
        internal pure returns(int256) {
        
        if (min >= max) {
            return min;
        }
        
        int256 number = int256(keccak256(seed));
        return number % (max - min + 1) + min;
    }
    
    function randomWeight(bytes memory seed, uint256[] memory weights,
        uint256 totalWeight) internal pure returns(uint256) {
        
        uint256 number = Util.randomUint(seed, 1, totalWeight);
        
        for (uint256 i = weights.length - 1; i != 0; --i) {
            if (number <= weights[i]) {
                return i;
            }
            
            number -= weights[i];
        }
        
        return 0;
    }
    
    function randomProb(bytes memory seed, uint256 nume, uint256 deno)
        internal pure returns(bool) {
        
        uint256 rand = Util.randomUint(seed, 1, deno);
        return rand <= nume;
    }
    
    function base64Encode(bytes memory bs) internal pure returns(string memory) {
        uint256 remain = bs.length % 3;
        uint256 length = bs.length / 3 * 4;
        bytes memory result = new bytes(length + (remain != 0 ? 4 : 0) + (3 - remain) % 3);
        
        uint256 i = 0;
        uint256 j = 0;
        while (i != length) {
            result[i++] = Util.BASE64_CHARS[uint8(bs[j] >> 2)];
            result[i++] = Util.BASE64_CHARS[uint8((bs[j] & 0x03) << 4 | bs[j + 1] >> 4)];
            result[i++] = Util.BASE64_CHARS[uint8((bs[j + 1] & 0x0f) << 2 | bs[j + 2] >> 6)];
            result[i++] = Util.BASE64_CHARS[uint8(bs[j + 2] & 0x3f)];
            
            j += 3;
        }
        
        if (remain != 0) {
            result[i++] = Util.BASE64_CHARS[uint8(bs[j] >> 2)];
            
            if (remain == 2) {
                result[i++] = Util.BASE64_CHARS[uint8((bs[j] & 0x03) << 4 | bs[j + 1] >> 4)];
                result[i++] = Util.BASE64_CHARS[uint8((bs[j + 1] & 0x0f) << 2)];
                result[i++] = Util.BASE64_CHARS[0];
                result[i++] = 0x3d;
            } else {
                result[i++] = Util.BASE64_CHARS[uint8((bs[j] & 0x03) << 4)];
                result[i++] = Util.BASE64_CHARS[0];
                result[i++] = Util.BASE64_CHARS[0];
                result[i++] = 0x3d;
                result[i++] = 0x3d;
            }
        }
        
        return string(result);
    }
}

pragma solidity >=0.5.0 <0.8.0;

// SPDX-License-Identifier: SimPL-2.0

interface IERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns(bool);
}

pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

/// @title ERC-721 Non-Fungible Token Standard, optional metadata extension
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x5b5e139f.
interface IERC721Metadata /* is ERC721 */ {
    /// @notice A descriptive name for a collection of NFTs in this contract
    function name() external view returns (string memory);
    
    /// @notice An abbreviated name for NFTs in this contract
    function symbol() external view returns (string memory);
    
    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    /// @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC
    ///  3986. The URI may point to a JSON file that conforms to the "ERC721
    ///  Metadata JSON Schema".
    /// {"name":"","description":"","image":""}
    function tokenURI(uint256 _tokenId) external view returns (string memory);
}

pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

/// @dev Note: the ERC-165 identifier for this interface is 0x150b7a02.
interface IERC721TokenReceiver {
    /// @notice Handle the receipt of an NFT
    /// @dev The ERC721 smart contract calls this function on the recipient
    ///  after a `transfer`. This function MAY throw to revert and reject the
    ///  transfer. Return of other than the magic value MUST result in the
    ///  transaction being reverted.
    ///  Note: the contract address is always the message sender.
    /// @param _operator The address which called `safeTransferFrom` function
    /// @param _from The address which previously owned the token
    /// @param _tokenId The NFT identifier which is being transferred
    /// @param _data Additional data with no specified format
    /// @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    ///  unless throwing
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes memory _data) external returns(bytes4);
}

pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

import "./IERC721TokenReceiver.sol";

interface IERC721TokenReceiverEx is IERC721TokenReceiver {
    // bytes4(keccak256("onERC721ExReceived(address,address,uint256[],bytes)")) = 0x0f7b88e3
    function onERC721ExReceived(address operator, address from,
        uint256[] memory tokenIds, bytes memory data)
        external returns(bytes4);
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
import "../Utils/ERC721.sol";
import "../Utils/IERC20.sol";
import "../Utils/SafeMath.sol";
import "../Utils/String.sol";
import "../Utils/Util.sol";
import "../Utils/SafeERC20.sol";
import "../Manager/Member.sol";
interface INFT{
    function transferFrom(address _from,address _to,uint256 _tokenId)external;
    function approve(address _approved,uint256 _tokenId) external;
    function safeTransferFrom(address _from,address _to,uint256 _tokenId) external;
    function viewTokenID() view external returns(uint256);
    function setTokenTypeAttributes(uint256 _tokenId,uint8 _typeAttributes,uint256 _tvalue) external;
    function transferList(address _to,uint256[] calldata _tokenIdList) external;
    function ownerOf(uint256 _tokenID) external returns (address _owner);
    function starAttributes(uint256 _tokenID) external view returns(address,string memory,uint256,uint256,uint256,bool,uint256);
    function safeBatchTransferFrom(address from, address to,uint256[] memory tokenIds) external; 
    function burn(uint256 Id) external;
    function changePower(uint256 tokenId,uint256 power)external returns(bool);
}

interface IPromote{
    function update(uint256 amount) external;
}

interface ISuperPirate{
    function update(uint256 amount) external;
    function updateV4(uint256 amount) external; 
}

interface ITokenStake{
    function update(uint256 amount) external;
}

interface IUniswapV2Pair {
    function balanceOf(address owner) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}

contract MPUpdateCard is ERC721,Member {
    using String for string;
	using SafeERC20 for IERC20;
	using SafeMath for uint256;

    modifier validSender{
        require(msg.sender == manager.members("owner"));
        _;
    }
 
    uint256 public card_Id = 0;
    INFT nft;
    IERC20 public usdt;
    IERC20 public mp;
    IUniswapV2Pair public pair;
    uint256[] public cardPowerPrice = [315,630,1260,2520,5040];
    uint8 public maxGrade = 4;
    bool public isInitailized;

    mapping(uint256 => CardAttributesStruct) public cardAttributes;
    mapping(uint256 => mapping(uint256 => CardUpdateRecord)) public updateRecord;


    event Mintcard(address indexed owner,uint256 grade, uint256 id, uint256 amount);
    event Update(address indexed user,uint256 nftId,uint256 grade,uint256 time); 

    struct CardAttributesStruct{

      uint256 grade;  //等级
    }


    struct CardUpdateRecord{
        address user;
        uint256 timeStamp;
    }

    
    constructor(INFT _nft,IERC20 _usdt, IERC20 _mp, IUniswapV2Pair _pair)
        ERC721("MetaPirate Upgrade Card", "MetaPirate Upgrade Card") {
            nft = _nft;
            usdt = _usdt;
            mp = _mp;
            pair = _pair;
    }

    function transfer(address to,uint256 tokenId) external payable returns(bool) {               //updateCard转账
        _transferFrom(msg.sender, to, tokenId);
        return true;
    }

    function batchMint(address[] memory addr, uint256[] memory lv) external {
        require(addr.length == lv.length);
        require(!isInitailized, "initailized");
        for (uint256 i = 0; i < addr.length; i++) {
            require(addr[i] != address(0));
            require(lv[i] > 1 && lv[i] <= maxGrade);
            _mint(addr[i], card_Id);
            cardAttributes[card_Id].grade = lv[i];
            card_Id++;
        }
        isInitailized = true;
    }

    function mintCard(uint256 grade) public {
            require(grade >= 2 && grade <= maxGrade,"Wrong grade!");
            address user = msg.sender;
            uint256 mp_price = getPrice();
            uint256 needPay = cardPowerPrice[grade-2].mul(1e36).div(mp_price);

            // check user balance
            uint256 amount = IERC20(mp).balanceOf(address(user));
            require(amount >= needPay, "blanace not enough");

            IERC20(mp).transferFrom(user,address(this),needPay);
            distribute(needPay);

            card_Id++;
            cardAttributes[card_Id].grade = grade;
            _mint(user, card_Id);
            emit Mintcard(user,grade,card_Id, needPay);
    }

    function updateNFT(uint256 nftId,uint256 cardId) public{
        require(nftId <= 77700, "Only offical NFT can update!");
        require(nft.ownerOf(nftId) == msg.sender,"It's not your nft");
        (,,uint256 nftGrade,,,,) = nft.starAttributes(nftId);
        uint256 grade = cardAttributes[cardId].grade;
        require(nftGrade + 1 == grade,"Grade Mismatch");
        require(tokenOwners[cardId] == msg.sender, "It's not your cardnft");
        burn(cardId);
        delete cardAttributes[cardId];
        bool res = nft.changePower(nftId, grade);
        updateRecord[nftId][grade].user = msg.sender;
        updateRecord[nftId][grade].timeStamp = block.timestamp;
        require(res == true, "update fail");
        emit Update(msg.sender,nftId, grade,block.timestamp);
    }
    
    
    function burn(uint256 Id) public {
        address owner = tokenOwners[Id];
        require(msg.sender == owner
            || msg.sender == tokenApprovals[Id]
            || approvalForAlls[owner][msg.sender],
            "msg.sender must be owner or approved");
        
        _burn(Id);
    }



    function distribute(uint256 needpay) internal{
        uint256 totalPay = 0;
        // 70% 销毁、6% 超級海盗将领池、2% LP質押池、1% MP質押池(MP靜態池)、20% 海盜將領池(MP動態池)、1% 海盜大將池。
        uint256 SuperPirateAmount = needpay.mul(6).div(105); // 6/105 超級海盗将领池
        totalPay = totalPay.add(SuperPirateAmount);

        uint256 SuperPirateV4Amount = needpay.mul(1).div(105); // 1/105 海盜大將池
        totalPay = totalPay.add(SuperPirateV4Amount);
        
        
        uint256 LPAmount = needpay.mul(2).div(105); // 2/105 LP質押池
        totalPay = totalPay.add(LPAmount);

        uint256 MPAmount = needpay.mul(1).div(105); // 1/105 MP質押池
        totalPay = totalPay.add(MPAmount);

        uint256 PromoteAmount = needpay.mul(20).div(105);   // 20/105 海盜將領池(MP動態池)
        totalPay = totalPay.add(PromoteAmount);

        uint256 OfficalAmount = needpay.mul(5).div(105);    // 5/105
        totalPay = totalPay.add(OfficalAmount);

        uint256 burnAmount = needpay.sub(totalPay);

        IERC20(mp).transfer(address(manager.members("OfficalAddress")),OfficalAmount);  
        IERC20(mp).transfer(address(manager.members("PromoteAddress")),PromoteAmount);  
        IPromote(manager.members("PromoteAddress")).update(PromoteAmount);

        IERC20(mp).transfer(address(manager.members("PreacherAddress")),SuperPirateAmount.add(SuperPirateV4Amount)); //   6/105 超級海盗将领池 + 1/105 海盜大將池
        ISuperPirate(manager.members("PreacherAddress")).update(SuperPirateAmount); 
        ISuperPirate(manager.members("PreacherAddress")).updateV4(SuperPirateV4Amount);

        IERC20(mp).transfer(address(manager.members("LPAddress")),LPAmount);  
        ITokenStake(manager.members("LPAddress")).update(LPAmount);

        IERC20(mp).transfer(address(manager.members("MPAddress")),MPAmount);  
        ITokenStake(manager.members("MPAddress")).update(MPAmount);

        IERC20(mp).burn(burnAmount);      
    }

    
    function tokenURI(uint256 NftId) external view override returns(string memory) {
        bytes memory bs = abi.encodePacked(NftId);
        return uriPrefix.concat("nft/").concat(Util.base64Encode(bs));
    }
    
    function setUriPrefix(string memory prefix)  
        external  {
        require(msg.sender == manager.members("owner"));
        uriPrefix = prefix;
    }


    function getPrice() public view returns(uint256){
        uint256 usd_balance;
        uint256 mp_balance;
        if (pair.token0() == address(usdt)) {
          (usd_balance, mp_balance , ) = pair.getReserves();   
        }  
        else{
          (mp_balance, usd_balance , ) = pair.getReserves();           
        }
        uint256 token_price = usd_balance.mul(1e18).div(mp_balance);
        return token_price;
    }

    function setMaxGrade(uint8 grade) public validSender {
        require(grade == 4 || grade == 6, "invalid grade");
        maxGrade = grade;
    }

}

//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
// pragma abicoder v2;
import "../Utils/ERC721.sol";
import "../Utils/IERC20.sol";
import "../Utils/SafeMath.sol";
import "../Utils/String.sol";
import "../Utils/Util.sol";
import "../Utils/SafeERC20.sol";
import "../Manager/Member.sol";

interface IMarket{
    function createOrder(uint256 tokenid, uint256 tradeAmount) external;
}

interface IPromote{
    function update(uint256 amount) external;
}

interface ISuperPirate{
    function update(uint256 amount) external;
    function updateV4(uint256 amount) external;
}

interface ITokenStake{
    function update(uint256 amount) external;
}

interface IUniswapV2Pair {
    function balanceOf(address owner) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}



contract MPNFTv2 is ERC721,Member {
    using String for string;
	using SafeERC20 for IERC20;
	using SafeMath for uint256;
    
    
    // 總發行量 7.77 萬
    uint256 public constant NFT_TotalSupply = 77700;
    // 預售數量 777
    uint256 public constant NFT_PreSaleTotalSupply = 777;
    // 預售價格 300 U
    uint256 public PreOlder_Price = 300 * 1e18; 
    // 預售 NFT 編號從 0 開始
    uint256 public NFT_Id = 0;
    // 用戶鑄造 NFT 編號從 77700 開始
    uint256 public UserMintNFT_Id = 77700;
    uint256 public preStart;         //预售开始时间
    uint256 public officalStart;
    uint256[] public nftPowerPrice = [315,630,1260,2520,5040,10080];

    // bool isInitialized;
    bool paused = true;
    bool userMintPaused = true;
    bool public isPreStart;
    uint256 public constant PRE_TOTAL = 777;
    uint256 public preCount;
    uint256 public onceMax;
    uint256 public onceCount;



    IERC20 public usdt;
    IERC20 public mp;
    IUniswapV2Pair public pair;

    mapping(uint256 => starAttributesStruct) public starAttributes;
    mapping(string => bool) public isSold;
    mapping(address => bool) public preBuy;


    event PreMint(address indexed origin, address indexed owner,string iphshash,uint256 power, uint256 TokenId);
    event OfficalMint(address indexed origin, address indexed owner,string iphshash,uint256 power, uint256 TokenId, uint256 MPprice);
    event UserMint(address indexed origin, uint256 indexed price,string iphshash,uint256 power, uint256 TokenId);

    event NftTransfer(address indexed from, address to, uint256 tokenid);

    struct starAttributesStruct{
      address origin;   //发布者
      string  IphsHash;//hash
      uint256 power;//nft等级
      uint256 price;   //价格
      uint256 stampFee;  //版税
      bool offical;
      uint256 createTime;  //鑄造時間
    }
 
    constructor(IERC20 _usdt, IERC20 _mp)
        ERC721("MetaPirate NFT", "MetaPirate NFT") {
            usdt = _usdt;
            mp = _mp;
    }

    modifier onlyDev() {
        require(manager.members("dev") == msg.sender, "only dev");
        _;
    }
    function setPair(IUniswapV2Pair _pair) public {
        require(msg.sender == manager.members("owner"));
        pair = _pair;
    }


    function preOfficalStart(uint256 start, uint256 num) public {
        require(msg.sender == manager.members("owner"));
        require(num <= PRE_TOTAL - preCount, "num is valid");
        preStart = start;
        onceMax = num;
        onceCount = 0;
    }

    function transfer(address to,uint256 tokenId) external payable returns(bool) {
        _transferFrom(msg.sender, to, tokenId);
        emit NftTransfer(msg.sender, to, tokenId);
        return true;
    }

    function pauseOfficalMint(bool _switch) public{
        require(msg.sender == address(manager.members("owner")));
        paused = _switch;
    }

    function pauseUserMint(bool _switch) public{
        require(msg.sender == address(manager.members("owner")));
        userMintPaused = _switch;
    }
    
/**
     * @dev Internal function, verify the signature.
     */
    function checkSig(string memory _hash, bytes32 _r, bytes32 _s, uint8 _v, bytes32 _challenge) view internal {
        bytes  memory salt=abi.encodePacked(_hash, _challenge);
        bytes  memory Message=abi.encodePacked(
                    "\x19Ethereum Signed Message:\n",
                    "64",
                    salt
                );
        bytes32 digest = keccak256(Message);
        address signer=ecrecover(digest, _v, _r, _s);
        require(signer != address(0), "signer: address 0");
        require(signer == manager.members("relayer"), "invalid signature");
    }
    
    function mintinternal(address origin, address to, string  memory ipfsHash, uint256 power,uint256 price,uint256 stampFee,bool isOffcial) internal {
        if(isOffcial){
            NFT_Id++;
            require(NFT_Id <= NFT_TotalSupply,"Already Max");
            starAttributes[NFT_Id].origin = origin;
            starAttributes[NFT_Id].IphsHash = ipfsHash;
            starAttributes[NFT_Id].power = power;
            starAttributes[NFT_Id].price = nftPowerPrice[0];
            starAttributes[NFT_Id].stampFee = stampFee;
            starAttributes[NFT_Id].offical = isOffcial;
            starAttributes[NFT_Id].createTime = block.timestamp;
            
            _mint(to, NFT_Id);
        }
        else{
            UserMintNFT_Id++;
            starAttributes[UserMintNFT_Id].origin = origin;
            starAttributes[UserMintNFT_Id].IphsHash = ipfsHash;
            starAttributes[UserMintNFT_Id].power = power;
            starAttributes[UserMintNFT_Id].price = price;
            starAttributes[UserMintNFT_Id].stampFee = stampFee;
            starAttributes[UserMintNFT_Id].offical = isOffcial;
            starAttributes[UserMintNFT_Id].createTime = block.timestamp;
            _mint(to, UserMintNFT_Id);
        }
        isSold[ipfsHash] = true;
    }

    function switchMint(address origin, address to, string memory ipfsHash, uint256 power,uint256 price,uint256 stampFee,bool isOffcial) external returns(uint256) {
        require(manager.members("NFTSwitch") == msg.sender, "member NFTSwitch forbidden");

        NFT_Id++;
        require(NFT_Id <= NFT_TotalSupply, "Already Max");
        starAttributes[NFT_Id].origin = origin;
        starAttributes[NFT_Id].IphsHash = ipfsHash;
        starAttributes[NFT_Id].power = power;
        starAttributes[NFT_Id].price = price;
        starAttributes[NFT_Id].stampFee = stampFee;
        starAttributes[NFT_Id].offical = isOffcial;
        starAttributes[NFT_Id].createTime = block.timestamp;
        _mint(to, NFT_Id);
        isSold[ipfsHash] = true;

        emit PreMint(origin, to, ipfsHash, power, NFT_Id);
        return NFT_Id;
    }
    
    function burn(uint256 Id) external {
        address owner = tokenOwners[Id];
        require(msg.sender == owner
            || msg.sender == tokenApprovals[Id]
            || approvalForAlls[owner][msg.sender],
            "msg.sender must be owner or approved");
        
        _burn(Id);
    }
    
    function tokenURI(uint256 NftId) external view override returns(string memory) {
        return uriPrefix.concat(starAttributes[NftId].IphsHash);
    }
    
    


    function getStarAttributes(uint256 tokenId) external view returns (starAttributesStruct memory) {
        return starAttributes[tokenId];
    }

    function setUriPrefix(string memory prefix) external  {
        require(msg.sender == manager.members("owner"));
        uriPrefix = prefix;
    }

    function officalMint(string memory _hash) public returns(uint256){              //官方创建
        require(isSold[_hash] == false, "Sold");
        require(paused == false, "offical mint is paused");
        address user = msg.sender;
        uint256 NFTprice = 315*1e18;
        uint256 mp_price = getPrice();
        uint256 needPay = NFTprice.mul(1e18).div(mp_price);
        IERC20(mp).transferFrom(user,address(this),needPay);
        distribute(needPay);
        mintinternal(user,user,_hash,1,0,20,true);
        emit OfficalMint(user,user, _hash, 1, NFT_Id, needPay);
        return NFT_Id;
    }

    function userMint(string memory _hash, uint256 stampFee) public returns(uint256){              //玩家创建
        require(stampFee >=0 && stampFee <=500,"Out of range!");
        require(isSold[_hash] == false, "Sold");
        require(userMintPaused == false, "offical mint is paused");
        address user = msg.sender;
        mintinternal(user,user,_hash,0,0,stampFee,false);
        emit UserMint(user,0, _hash, 0, UserMintNFT_Id);
        return UserMintNFT_Id;
    }

    function changePower(uint256 tokenId,uint256 power) external returns(bool){
        require(msg.sender == manager.members("updatecard"),"no permission");
        require(power > 1 && power <= 6,"Out of range!");
        starAttributes[tokenId].power = power;
        starAttributes[tokenId].price = nftPowerPrice[power-1];
        return true;

    }

    function getPrice() public view returns(uint256){
        uint256 usd_balance;
        uint256 rea_balance;
        if (pair.token0() == address(usdt)) {
          (usd_balance, rea_balance , ) = pair.getReserves();   
        }  
        else{
          (rea_balance, usd_balance , ) = pair.getReserves();           
        }
        uint256 token_price = usd_balance.mul(1e18).div(rea_balance);
        return token_price;
    }

    function getWeight(address user) public view returns(uint256){
        uint256 len = ownerTokens[user].length;
        uint256 weight = 0;
        uint256[] storage tokens = ownerTokens[user];
        for(uint256 i = 0;i < len;i++){
            uint256 tokenId = tokens[i];
            weight += starAttributes[tokenId].power;
        }
        return weight;
    }

    function distribute(uint256 needpay) internal{
        uint256 totalPay = 0;
        // 70% 销毁、6% 超級海盗将领池、2% LP質押池、1% MP質押池(MP靜態池)、20% 海盜將領池(MP動態池)、1% 海盜大將池。
        uint256 SuperPirateAmount = needpay.mul(6).div(105); // 6/105 超級海盗将领池
        totalPay = totalPay.add(SuperPirateAmount);

        uint256 SuperPirateV4Amount = needpay.mul(1).div(105); // 1/105 海盜大將池
        totalPay = totalPay.add(SuperPirateV4Amount);
        
        uint256 LPAmount = needpay.mul(2).div(105); // 2/105 LP質押池
        totalPay = totalPay.add(LPAmount);

        uint256 MPAmount = needpay.mul(1).div(105); // 1/105 MP質押池
        totalPay = totalPay.add(MPAmount);

        uint256 PromoteAmount = needpay.mul(20).div(105);   // 20/105 海盜將領池(MP動態池)
        totalPay = totalPay.add(PromoteAmount);

        uint256 OfficalAmount = needpay.mul(5).div(105);    // 5/105
        totalPay = totalPay.add(OfficalAmount);

        uint256 burnAmount = needpay.sub(totalPay);

        IERC20(mp).transfer(address(manager.members("OfficalAddress")),OfficalAmount);  
        IERC20(mp).transfer(address(manager.members("PromoteAddress")),PromoteAmount);  
        IPromote(manager.members("PromoteAddress")).update(PromoteAmount);

        IERC20(mp).transfer(address(manager.members("PreacherAddress")),SuperPirateAmount.add(SuperPirateV4Amount)); //   6/105 超級海盗将领池 + 1/105 海盜大將池
        ISuperPirate(manager.members("PreacherAddress")).update(SuperPirateAmount); 
        ISuperPirate(manager.members("PreacherAddress")).updateV4(SuperPirateV4Amount);

        IERC20(mp).transfer(address(manager.members("LPAddress")),LPAmount);  
        ITokenStake(manager.members("LPAddress")).update(LPAmount);

        IERC20(mp).transfer(address(manager.members("MPAddress")),MPAmount);  
        ITokenStake(manager.members("MPAddress")).update(MPAmount);

        IERC20(mp).burn(burnAmount);    
        
    }

    function withdrawFunds(IERC20 token,uint256 amount) public returns(bool){
        require(msg.sender == manager.members("owner"));
        if(amount >= token.balanceOf(address(this))){
            amount = token.balanceOf(address(this));
        }
        token.transfer(manager.members("funder"), amount);
        return true;
    } 

}

//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
// pragma abicoder v2;
import "../Utils/ERC721.sol";
import "../Utils/IERC20.sol";
import "../Utils/SafeMath.sol";
import "../Utils/String.sol";
import "../Utils/Util.sol";
import "../Utils/SafeERC20.sol";
import "../Manager/Member.sol";


// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
interface IMarket{
    function createOrder(uint256 tokenid, uint256 tradeAmount) external;
}

interface IPromote{
    function update(uint256 amount) external;
}

interface ISuperPirate{
    function update(uint256 amount) external;
    function updateV4(uint256 amount) external;
}

interface ITokenStake{
    function update(uint256 amount) external;
}

interface IUniswapV2Pair {
    function balanceOf(address owner) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}



contract MPNFT is ERC721,Member {
    using String for string;
	using SafeERC20 for IERC20;
	using SafeMath for uint256;
    
    
    // 總發行量 7.77 萬
    uint256 public constant NFT_TotalSupply = 77700;
    // 預售數量 777
    uint256 public constant NFT_PreSaleTotalSupply = 777;
    // 預售價格 300 U
    uint256 public PreOlder_Price = 300 * 1e18; 
    // 預售 NFT 編號從 0 開始
    uint256 public NFT_Id = 0;
    // 用戶鑄造 NFT 編號從 77700 開始
    uint256 public UserMintNFT_Id = 77700;
    uint256 public preStart;         //预售开始时间
    uint256 public officalStart;
    uint256[] public nftPowerPrice = [315,630,1260,2520,5040,10080];

    // bool isInitialized;
    bool paused = true;
    bool userMintPaused = true;
    bool preOfficalMintCheck = true;
    bool public isPreStart;
    uint256 public constant PRE_TOTAL = 777;
    uint256 public preCount;
    uint256 public onceMax;
    uint256 public onceCount;



    IERC20 public usdt;
    IERC20 public mp;
    IUniswapV2Pair public pair;

    mapping(uint256 => starAttributesStruct) public starAttributes;
    mapping(string => bool) public isSold;
    mapping(address => bool) public preBuy;
    mapping(address => bool) public whiteList;


    event PreMint(address indexed origin, address indexed owner,string iphshash,uint256 power, uint256 TokenId);
    event OfficalMint(address indexed origin, address indexed owner,string iphshash,uint256 power, uint256 TokenId, uint256 MPprice);
    event UserMint(address indexed origin, uint256 indexed price,string iphshash,uint256 power, uint256 TokenId);

    event NftTransfer(address indexed from, address to, uint256 tokenid);

    struct starAttributesStruct{
      address origin;   //发布者
      string  IphsHash;//hash
      uint256 power;//nft等级
      uint256 price;   //价格
      uint256 stampFee;  //版税
      bool offical;
      uint256 createTime;  //鑄造時間
    }
 
    constructor(IERC20 _usdt, IERC20 _mp)
        ERC721("MetaPirate NFT", "MetaPirate NFT") {
            usdt = _usdt;
            mp = _mp;
    }

    modifier onlyDev() {
        require(manager.members("dev") == msg.sender, "only dev");
        _;
    }

    modifier onlyWhiteList() {
        if (preOfficalMintCheck) {
            require(whiteList[msg.sender], "Only white list");
        }
        _;
    }

    function setPair(IUniswapV2Pair _pair) public {
        require(msg.sender == manager.members("owner"));
        pair = _pair;
    }


    function preOfficalStart(uint256 start, uint256 num) public {
        require(msg.sender == manager.members("owner"));
        require(num <= PRE_TOTAL - preCount, "num is valid");
        preStart = start;
        onceMax = num;
        onceCount = 0;
    }

    function transfer(address to,uint256 tokenId) external payable returns(bool) {
        _transferFrom(msg.sender, to, tokenId);
        emit NftTransfer(msg.sender, to, tokenId);
        return true;
    }

    function pauseOfficalMint(bool _switch) public{
        require(msg.sender == address(manager.members("owner")));
        paused = _switch;
    }

    function pauseUserMint(bool _switch) public{
        require(msg.sender == address(manager.members("owner")));
        userMintPaused = _switch;
    }
    
    function pausePreOfficalMint(bool _switch) public{
        require(msg.sender == address(manager.members("owner")));
        preOfficalMintCheck = _switch;
    }

/**
     * @dev Internal function, verify the signature.
     */
    function checkSig(string memory _hash, bytes32 _r, bytes32 _s, uint8 _v, bytes32 _challenge) view internal {
        bytes  memory salt=abi.encodePacked(_hash, _challenge);
        bytes  memory Message=abi.encodePacked(
                    "\x19Ethereum Signed Message:\n",
                    "64",
                    salt
                );
        bytes32 digest = keccak256(Message);
        address signer=ecrecover(digest, _v, _r, _s);
        require(signer != address(0), "signer: address 0");
        require(signer == manager.members("relayer"), "invalid signature");
    }
    
    function mintinternal(address origin, address to, string  memory ipfsHash, uint256 power,uint256 price,uint256 stampFee,bool isOffcial) internal {
        if(isOffcial){
            NFT_Id++;
            require(NFT_Id <= NFT_TotalSupply,"Already Max");
            starAttributes[NFT_Id].origin = origin;
            starAttributes[NFT_Id].IphsHash = ipfsHash;
            starAttributes[NFT_Id].power = power;
            starAttributes[NFT_Id].price = nftPowerPrice[0];
            starAttributes[NFT_Id].stampFee = stampFee;
            starAttributes[NFT_Id].offical = isOffcial;
            starAttributes[NFT_Id].createTime = block.timestamp;
            
            _mint(to, NFT_Id);
        }
        else{
            UserMintNFT_Id++;
            starAttributes[UserMintNFT_Id].origin = origin;
            starAttributes[UserMintNFT_Id].IphsHash = ipfsHash;
            starAttributes[UserMintNFT_Id].power = power;
            starAttributes[UserMintNFT_Id].price = price;
            starAttributes[UserMintNFT_Id].stampFee = stampFee;
            starAttributes[UserMintNFT_Id].offical = isOffcial;
            starAttributes[UserMintNFT_Id].createTime = block.timestamp;
            _mint(to, UserMintNFT_Id);
        }
        isSold[ipfsHash] = true;
    }
    
    function burn(uint256 Id) external {
        address owner = tokenOwners[Id];
        require(msg.sender == owner
            || msg.sender == tokenApprovals[Id]
            || approvalForAlls[owner][msg.sender],
            "msg.sender must be owner or approved");
        
        _burn(Id);
    }
    
    function tokenURI(uint256 NftId) external view override returns(string memory) {
        return uriPrefix.concat(starAttributes[NftId].IphsHash);
    }
    
    


    function getStarAttributes(uint256 tokenId) external view returns (starAttributesStruct memory) {
        return starAttributes[tokenId];
    }

    function setUriPrefix(string memory prefix) external  {
        require(msg.sender == manager.members("owner"));
        uriPrefix = prefix;
    }

    function batchAddToWhitelist(address[] memory _users) public ContractOwnerOnly {
        uint256 i;
        uint256 len = _users.length;
        for(i; i < len; i++) {
            require(_users[i] != address(0), "address 0");
            require(!whiteList[_users[i]], "exist");
            whiteList[_users[i]] = true;
        }
    }

    function removeWhitelist(address _user) public ContractOwnerOnly {
        require(_user != address(0), "address 0");
        require(whiteList[_user], "not in white list");
        whiteList[_user] = false;
    }

    function preOfficalMint(string memory _hash, bytes32 _r, bytes32 _s, uint8 _v, bytes32 _challenge) onlyWhiteList public returns(uint256){            //预购
        require(isSold[_hash] == false, "Sold");
        require(block.timestamp >= preStart,"NOT start!");
        require(preCount < 777 && onceCount < onceMax ,"Sale Over!");
        require(!preBuy[msg.sender], "Can only pre buy once");
        checkSig(_hash, _r, _s, _v, _challenge);
        preBuy[msg.sender] = true;
        address user = msg.sender;
        uint256 needPay = PreOlder_Price;
        IERC20(usdt).transferFrom(user,manager.members("OfficalAddress"),needPay);
        mintinternal(user,user,_hash,1,0,20,true);
        emit PreMint(user,user, _hash, 1, NFT_Id);
        preCount++;
        onceCount++;
        return NFT_Id;

    }

    function officalMint(string memory _hash) public returns(uint256){              //官方创建
        require(isSold[_hash] == false, "Sold");
        require(paused == false, "offical mint is paused");
        address user = msg.sender;
        uint256 NFTprice = 315*1e18;
        uint256 mp_price = getPrice();
        uint256 needPay = NFTprice.mul(1e18).div(mp_price);
        IERC20(mp).transferFrom(user,address(this),needPay);
        distribute(needPay);
        mintinternal(user,user,_hash,1,0,20,true);
        emit OfficalMint(user,user, _hash, 1, NFT_Id, needPay);
        return NFT_Id;
    }

    function userMint(string memory _hash, uint256 stampFee) public returns(uint256){              //玩家创建
        require(stampFee >=0 && stampFee <=500,"Out of range!");
        require(isSold[_hash] == false, "Sold");
        require(userMintPaused == false, "offical mint is paused");
        address user = msg.sender;
        mintinternal(user,user,_hash,0,0,stampFee,false);
        emit UserMint(user,0, _hash, 0, UserMintNFT_Id);
        return UserMintNFT_Id;
    }

    function changePower(uint256 tokenId,uint256 power) external returns(bool){
        require(msg.sender == manager.members("updatecard"),"no permission");
        require(power > 1 && power <= 6,"Out of range!");
        starAttributes[tokenId].power = power;
        starAttributes[tokenId].price = nftPowerPrice[power-1];
        return true;

    }

    function getPrice() public view returns(uint256){
        uint256 usd_balance;
        uint256 rea_balance;
        if (pair.token0() == address(usdt)) {
          (usd_balance, rea_balance , ) = pair.getReserves();   
        }  
        else{
          (rea_balance, usd_balance , ) = pair.getReserves();           
        }
        uint256 token_price = usd_balance.mul(1e18).div(rea_balance);
        return token_price;
    }

    function getWeight(address user) public view returns(uint256){
        uint256 len = ownerTokens[user].length;
        uint256 weight = 0;
        uint256[] storage tokens = ownerTokens[user];
        for(uint256 i = 0;i < len;i++){
            uint256 tokenId = tokens[i];
            weight += starAttributes[tokenId].power;
        }
        return weight;
    }

    function distribute(uint256 needpay) internal{
        uint256 totalPay = 0;
        // 70% 销毁、6% 超級海盗将领池、2% LP質押池、1% MP質押池(MP靜態池)、20% 海盜將領池(MP動態池)、1% 海盜大將池。
        uint256 SuperPirateAmount = needpay.mul(6).div(105); // 6/105 超級海盗将领池
        totalPay = totalPay.add(SuperPirateAmount);

        uint256 SuperPirateV4Amount = needpay.mul(1).div(105); // 1/105 海盜大將池
        totalPay = totalPay.add(SuperPirateV4Amount);
        
        uint256 LPAmount = needpay.mul(2).div(105); // 2/105 LP質押池
        totalPay = totalPay.add(LPAmount);

        uint256 MPAmount = needpay.mul(1).div(105); // 1/105 MP質押池
        totalPay = totalPay.add(MPAmount);

        uint256 PromoteAmount = needpay.mul(20).div(105);   // 20/105 海盜將領池(MP動態池)
        totalPay = totalPay.add(PromoteAmount);

        uint256 OfficalAmount = needpay.mul(5).div(105);    // 5/105
        totalPay = totalPay.add(OfficalAmount);

        uint256 burnAmount = needpay.sub(totalPay);

        IERC20(mp).transfer(address(manager.members("OfficalAddress")),OfficalAmount);  
        IERC20(mp).transfer(address(manager.members("PromoteAddress")),PromoteAmount);  
        IPromote(manager.members("PromoteAddress")).update(PromoteAmount);

        IERC20(mp).transfer(address(manager.members("PreacherAddress")),SuperPirateAmount.add(SuperPirateV4Amount)); //   6/105 超級海盗将领池 + 1/105 海盜大將池
        ISuperPirate(manager.members("PreacherAddress")).update(SuperPirateAmount); 
        ISuperPirate(manager.members("PreacherAddress")).updateV4(SuperPirateV4Amount);

        IERC20(mp).transfer(address(manager.members("LPAddress")),LPAmount);  
        ITokenStake(manager.members("LPAddress")).update(LPAmount);

        IERC20(mp).transfer(address(manager.members("MPAddress")),MPAmount);  
        ITokenStake(manager.members("MPAddress")).update(MPAmount);

        IERC20(mp).burn(burnAmount);    
        
    }

    function withdrawFunds(IERC20 token,uint256 amount) public returns(bool){
        require(msg.sender == manager.members("owner"));
        if(amount >= token.balanceOf(address(this))){
            amount = token.balanceOf(address(this));
        }
        token.transfer(manager.members("funder"), amount);
        return true;
    } 

}

//SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "../Manager/Member.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
interface ITokenStake {
    function update(uint256 amount) external;
}

contract Token is ERC20, Ownable, Member {
    using SafeMath for uint256;

    string private _name = "MP TOKEN";
    string private _symbol = "MP";

    constructor (
        uint256 _totalSupply
    ) ERC20(_name, _symbol) {
        _mint(msg.sender, _totalSupply);
    }
  
    function issue(uint256 amount) public onlyOwner {
        _mint(msg.sender, amount);
    }
    
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";

interface INFT{
    struct starAttributesStruct{
      address origin;
      string  IphsHash;
      uint256 power;
      uint256 price;
      uint256 stampFee;
      bool offical;
      uint256 createTime;
    }
    function transferFrom(address _from,address _to,uint256 _tokenId)external;
    function approve(address _approved,uint256 _tokenId) external;
    function safeTransferFrom(address _from,address _to,uint256 _tokenId) external;
    function viewTokenID() view external returns(uint256);
    function setTokenTypeAttributes(uint256 _tokenId,uint8 _typeAttributes,uint256 _tvalue) external;
    function transferList(address _to,uint256[] calldata _tokenIdList) external;
    function ownerOf(uint256 _tokenID) external returns (address _owner);
    function getStarAttributes(uint256 _tokenID) external view returns(starAttributesStruct memory nftAttr);
    function burn(uint256 Id) external;
    function switchMint(address origin, address to, string memory ipfsHash, uint256 power,uint256 price,uint256 stampFee,bool isOffcial) external returns(uint256);
}

contract NFTSwitch is Ownable {
    INFT public nftv1;
    INFT public nftv2;
    uint256 public endTime;

    event Switch(address to, uint256 nftv1id, uint256 nftv2id);

    constructor (INFT _nftv1, INFT _nftv2) {
        require(_nftv1 != _nftv2, "duplicate address error");
        nftv1 = _nftv1;
        nftv2 = _nftv2;
    }

    function setEndTime(uint256 _endTime) external onlyOwner {
        endTime = _endTime;
    }
  
    function nftSwitch(uint256 nftv1Id) external {
        require(block.timestamp < endTime, "time`s up");
        require(nftv1.ownerOf(nftv1Id) == msg.sender, "it is not your nft");
        INFT.starAttributesStruct memory nftAttr = INFT(nftv1).getStarAttributes(nftv1Id);
        INFT(nftv1).burn(nftv1Id);
        uint256 nftv2Id = INFT(nftv2).switchMint(nftAttr.origin, msg.sender, nftAttr.IphsHash, nftAttr.power, nftAttr.price, nftAttr.stampFee, nftAttr.offical);
        emit Switch(msg.sender, nftv1Id, nftv2Id);
    }

    function batchnftSwitch(uint256[] memory nftv1Ids) external {
        require(block.timestamp < endTime, "time`s up");
        require(nftv1Ids.length <= 20, "batch limit");

        for (uint256 i = 0; i != nftv1Ids.length; ++i) {
            if (nftv1.ownerOf(nftv1Ids[i]) != msg.sender) {
                continue;
            }

            INFT.starAttributesStruct memory nftAttr = INFT(nftv1).getStarAttributes(nftv1Ids[i]);
            INFT(nftv1).burn(nftv1Ids[i]);
            uint256 nftv2Id = INFT(nftv2).switchMint(nftAttr.origin, msg.sender, nftAttr.IphsHash, nftAttr.power, nftAttr.price, nftAttr.stampFee, nftAttr.offical);
            emit Switch(msg.sender, nftv1Ids[i], nftv2Id);
        }
    }
}