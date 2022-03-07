pragma solidity ^0.7.0;
// SPDX-License-Identifier: SimPL-2.0
pragma experimental ABIEncoderV2;
import "./ERC721Ex.sol"; // done
import "./Member.sol";
import "./shop/VerifySignature.sol";
import "./utils/SafeMath.sol";

contract TheKingToken is Member {
    using SafeMath for uint256;
    uint32 public _buyNo;
    uint32 public _blockInterval;
    uint256 public _totalSupply;
    uint256 private _buyKingTokenAmount;
    uint256 private _buyQueenToken;

    uint256 public _buyContMax;
    IERC20 public _buyTokenAddress;
    address public verify;
    bool private _isOpen;
    event BuyKing(address, uint32, uint256 amounts, uint256); // 1
    event AddQueen(address, address, uint256); // 2

    event GetInviteToken(address add, uint256 amount, uint256); // 3

    event DelQueen(address, address, uint256); //4
    event DelUser(address, address, uint256); //5

    struct users {
        bool hasKing;
        bool hasQueen;
        bool isUse;
        uint32 buyNo;
        uint256 buyKingTime;
        uint256 buyKingBlock;
    }
    struct orderInfo {
        uint256 startBlock;
        uint256 colseBlock;
        address[] buyUserAddress;
        uint32 buyContNow;
    }
    mapping(uint32 => orderInfo) order;
    address[] buyUser;
    mapping(address => users) user;

    constructor(
        uint256 buyKingAmount,
        IERC20 buyToken,
        uint256 startTime,
        uint32 buyNo,
        uint256 buyCont,
        uint32 timeInterval,
        address _verify
    ) {
        _buyKingTokenAmount = buyKingAmount;
        _buyTokenAddress = buyToken;
        _buyNo = buyNo;
        _buyContMax = buyCont;
        _blockInterval = timeInterval;
        orderInfo storage _orderInfo = order[buyNo];

        _orderInfo.startBlock = startTime;
        verify = _verify;
    }

    function changeBuyToken(uint256 buyKingAmount, IERC20 buyToken)
        public
        CheckPermit("Config")
    {
        _buyKingTokenAmount = buyKingAmount;
        _buyTokenAddress = buyToken;
    }

    function changeGameOpen(bool isOpen) public CheckPermit("Config") {
        _isOpen = isOpen;
    }

    function getGameOpen() public view returns (bool) {
        return _isOpen;
    }

    function changeBlockInterval(uint32 timeInterval)
        public
        CheckPermit("Config")
    {
        _blockInterval = timeInterval;
    }

    function buyGoldKing() public {
        require(_isOpen, "Sale has not started");
        require(
            order[_buyNo].startBlock <= block.number,
            "Sale has not started"
        );
        require(
            order[_buyNo].buyContNow < _buyContMax,
            "This round of pre-sale has ended"
        );
        require(!user[address(msg.sender)].hasKing, "User already owns");
        require(!user[address(msg.sender)].hasQueen, "You are Queen");

        if (order[_buyNo].startBlock + _blockInterval >= block.number) {
            _buyTokenAddress.transferFrom(
                address(msg.sender),
                address(this),
                _buyKingTokenAmount
            );
            users storage _user = user[address(msg.sender)];
            _user.buyKingTime = block.timestamp;
            _user.buyKingBlock = block.number;
            _user.buyNo = _buyNo;
            _user.hasKing = true;
            _user.isUse = true;
            orderInfo storage _orderInfo = order[_buyNo];
            _orderInfo.buyContNow++;
            _orderInfo.buyUserAddress.push(address(msg.sender));

            buyUser.push(address(msg.sender));
            emit BuyKing(address(msg.sender), _buyNo, _buyKingTokenAmount, 1);
            if (_orderInfo.buyContNow == _buyContMax) {
                _buyNo++;
                _orderInfo.colseBlock = block.number;
                orderInfo storage _orderInfoNew = order[_buyNo];
                _orderInfoNew.startBlock =
                    order[_buyNo - 1].startBlock +
                    _blockInterval;
            }
        } else {
            orderInfo storage _orderInfo = order[_buyNo];
            uint32 intervalNo = uint32(
                (block.number - _orderInfo.startBlock + _blockInterval - 1) /
                    _blockInterval
            );
            _buyNo = intervalNo + _buyNo;

            orderInfo storage _orderInfoNew = order[_buyNo];

            _orderInfoNew.startBlock =
                _orderInfo.startBlock +
                (_blockInterval * (intervalNo - 1));
            buyGoldKing();
        }
    }

    function getAllToken(uint256 _surplusAmount) public CheckPermit("Admin") {
        uint256 amount = _buyTokenAddress.balanceOf(address(this));
        _buyTokenAddress.transfer(msg.sender,amount.sub(_surplusAmount));
    }

    function getUserInviteToken(bytes memory data) public {
        (address user, uint256 amount) = VerifySignature(verify).verifyWithdraw(
            data
        );
        require(msg.sender == user, "invalid user");
        IERC20(_buyTokenAddress).transfer(msg.sender, amount);
        emit GetInviteToken(msg.sender, amount, 3);
    }

    function addQueen(address[] memory queen) public CheckPermit("Config") {
        uint256 length = queen.length;
        for (uint256 i = 0; i != length; ++i) {
            if (!user[queen[i]].hasKing) {
                users storage _user = user[queen[i]];
                _user.hasQueen = true;
                _user.isUse = true;
                emit AddQueen(address(msg.sender), queen[i], 2);
            }
        }
    }

    function setStartTime(uint256 startTime) public CheckPermit("Config") {
        orderInfo storage _orderInfo = order[_buyNo];
        _orderInfo.startBlock = startTime;
    }

    function delQueen(address _addr) public CheckPermit("Config") {
        require(user[_addr].isUse, "User does not exist ");
        users storage _user = user[_addr];
        _user.hasQueen = false;
        emit AddQueen(address(msg.sender), _addr, 4);
    }

    function delUser(address _addr) public CheckPermit("Config") {
        require(user[_addr].isUse, "User does not exist ");
        users storage _user = user[_addr];
        _user.isUse = false;
        emit AddQueen(address(msg.sender), _addr, 5);
    }

    function checkUserKing(address _addr) public view returns (bool) {
        return user[_addr].hasKing;
    }

    function getPayTokenAmount() public view returns (uint256) {
        return _buyKingTokenAmount;
    }

    function checkUserQueen(address _addr) public view returns (bool) {
        return user[_addr].hasQueen;
    }

    function checkTime() public view returns (uint256) {
        return block.number;
    }

    function checkSellNo() public view returns (uint256) {
        return _buyNo;
    }

    function getMaxCont() public view returns (uint256) {
        return _buyContMax;
    }

    function getBlockInterval() public view returns (uint256) {
        return _blockInterval;
    }

    function getUser(address addr) public view returns (users memory) {
        return user[addr];
    }

    function getOrderInfo(uint32 orderNo)
        public
        view
        returns (orderInfo memory)
    {
        return order[orderNo];
    }

    function getChainID() external view returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }
}

pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

import "./interface/IERC20.sol"; // done
import "./utils/Address.sol"; // almost
import "./ERC721.sol"; // done
import "./interface/IERC721TokenReceiverEx.sol"; // about
import "./lib/Util.sol"; //about
import "./Member.sol";

abstract contract ERC721Ex is ERC721, Member {
    using Address for address;
     
    uint256 public constant NFT_SIGN_BIT = 1 << 255;
    
    // 总量0
    uint256 public totalSupply = 0;
    
    // uri前缀
    string public uriPrefix = "http://api.ufox.io/";
    
    // 铸造
    function _mint(address to, uint256 tokenId) internal {
        // 添加token到to               
        _mintOld(to, tokenId);
        // 总量加一
        ++totalSupply;
        
        // emit Transfer(address(0), to, tokenId);
    }

  
    
    // 燃烧
    function _burn(uint256 tokenId)  internal {
     
        // 移除                       
        // _removeTokenFrom(owner, tokenId);
        _burnOld(tokenId);
        
        // 如果这个token有单授权 移除授权
        if (_tokenApprovals[tokenId] != address(0)) {
            delete _tokenApprovals[tokenId];
        }
        
        // emit Transfer(owner, address(0), tokenId);
    }
    
    // 安全发送一批授权token
    function safeBatchTransferFrom(address from, address to,
        uint256[] memory tokenIds) external {
        
        // 转发出
        safeBatchTransferFrom(from, to, tokenIds, "");
    }
    
    // 安全发送一批token 带备注
    function safeBatchTransferFrom(address from, address to,
        uint256[] memory tokenIds, bytes memory data) public {
        
        // 转发出
        batchTransferFrom(from, to, tokenIds);
        
        //如果转到合约
        if (to.isContract()) {
            // 验证         
            require(IERC721TokenReceiverEx(to)
                .onERC721ExReceived(msg.sender, from, tokenIds, data)
                == Util.ERC721_RECEIVER_EX_RETURN,
                "onERC721ExReceived() return invalid");
        }
    }
    
    // 发送一批token
    function batchTransferFrom(address from, address to,
        uint256[] memory tokenIds) public {
        // 两方地址不空
        require(from != address(0), "from is zero address");
        require(to != address(0), "to is zero address");
        // tokens长度
        uint256 length = tokenIds.length;
        // 调用者地址
        address sender = msg.sender;
        // bool = 是否是调用自己的token 或者 是否调用授权所有地址
        bool approval = from == sender || _operatorApprovals[from][sender];
        // 遍历
        for (uint256 i = 0; i != length; ++i) {
            // 当前token
            uint256 tokenId = tokenIds[i];
			// token是否是自己的
            require(from == _owners[tokenId], "from must be owner");
            // 授权验证
            require(approval || sender == _tokenApprovals[tokenId],
                "sender must be owner or approvaled");
            // 如果当前token有被授权
            if (_tokenApprovals[tokenId] != address(0)) {
                // 移除授权
                delete _tokenApprovals[tokenId];
            }
            
            _burnOld(tokenId);
            _mintOld(to, tokenId);
            
            emit Transfer(from, to, tokenId);
        }
    }
    // 更换uri  要验证当前地址Config权限
    function setUriPrefix(string memory prefix)
        external CheckPermit("Config") {
        uriPrefix = prefix;
    }
}

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

contract VerifySignature {
    address private verifyingContract;
    bytes32 private DOMAIN_SEPARATOR;
    address private constant signer =
        0x251e2689a0e1b7Bf860131698d9a0dbb22a3c791;
    address private constant signerb =
        0x251e2689a0e1b7Bf860131698d9a0dbb22a3c791;
    bytes32 private constant salt =
        0x24671349f61b9f588e658201d3c954256b4c3fea0f1f42b3e0afd58a3daa9711;

    string private constant EIP712_DOMAIN =
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)";
    string private constant PERMIT_TYPE =
        "Permit(address user,uint256 packageId,uint256[] cardTypes,uint256[] raritys)";
    string private constant PERMIT_SYNTHESIS =
        "PermitSynthesis(address user,uint256[] cardIds,uint level,uint type)";

    string private constant PERMIT_CREAD_ORDER =
        "PermitCreadOrder(address user,uint256[] cardIds)";
    string private constant PERMIT_MINING_CARD =
        "PermitMiningCard(address user,uint256 cardId)";
    string private constant PERMIT_WITHDRAW_TYPE =
        "PermitWithdraw(address user,uint256 amount, uint256 deadLine)";

    string private constant PERMIT_WITHDRAW_MINE =
        "PermitWithdraw(uint256 amount, uint256 deadLine)";

    bytes32 private constant EIP712_DOMAIN_TYPEHASH =
        keccak256(abi.encodePacked(EIP712_DOMAIN));
    bytes32 private constant PERMIT_TYPEHASH =
        keccak256(abi.encodePacked(PERMIT_TYPE));

    bytes32 private constant PERMIT_SYNTHESISHASH =
        keccak256(abi.encodePacked(PERMIT_SYNTHESIS));

    bytes32 private constant PERMIT_ORDERHASH =
        keccak256(abi.encodePacked(PERMIT_CREAD_ORDER));

    bytes32 private constant PERMIT_MININGCARDHASH =
        keccak256(abi.encodePacked(PERMIT_MINING_CARD));

    bytes32 private constant PERMIT_WITHDRAW_TYPEHASH =
        keccak256(abi.encodePacked(PERMIT_WITHDRAW_TYPE));

    bytes32 private constant PERMIT_WITHDRAW_MINEHASH =
        keccak256(abi.encodePacked(PERMIT_WITHDRAW_MINE));

    mapping(uint256 => bool) public verifyRecord;
    mapping(bytes32 => bool) verifyRecordb;

    address public ab;
    address public ac;
    address public a;
    uint256 public b;
    uint256[] public c;
    uint256[] public d;
    bytes public f;

    constructor() {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        verifyingContract = address(this);
        // verifyingContract = 0x4c67Ac30D155C4042D3FCba861ebA3923Bd9578D;
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                keccak256("KKShop"),
                keccak256("1.0"),
                chainId,
                verifyingContract,
                salt
            )
        );
    }

    function verifyOpenPackage(
        address sender,
        uint256 packageId,
        bytes memory data
    ) external returns (uint256[] memory, uint256[] memory) {
        (
            address user,
            uint256 _packageId,
            uint256[] memory cardTypes,
            uint256[] memory raritys,
            bytes memory signature
        ) = abi.decode(data, (address, uint256, uint256[], uint256[], bytes));
        require(packageId == _packageId, "Invalid Request");
        require(user == sender, "Invalid User");
        require(!verifyRecord[packageId], "Invalid Data");
        // aa = user;
        // b = _packageId;
        // c = cardTypes;
        // d = raritys;
        // f = signature;
        uint8 v;
        bytes32 r;
        bytes32 s;
        (v, r, s) = splitSignature(signature);
        bytes32 signHash = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        PERMIT_TYPEHASH,
                        user,
                        packageId,
                        cardTypes,
                        raritys
                    )
                )
            )
        );
        // a = ecrecover(signHash, v, r, s);
        require(signer == ecrecover(signHash, v, r, s), "Invalid Request!");
        verifyRecord[packageId] = true;
        return (cardTypes, raritys);
    }

    function synthesisCards(address sender, bytes memory data)
        external
        returns (
            address users,
            uint256[] memory,
            uint256 levels,
            uint256 logeType
        )
    {
        (
            address user,
            uint256[] memory cardIds,
            uint256 level,
            uint256 types,
            bytes memory signature
        ) = abi.decode(data, (address, uint256[], uint256, uint256, bytes));
        bytes32 cardId32 = keccak256(
            abi.encode(user, cardIds, level, signature)
        );
        require(!verifyRecordb[cardId32], "Invalid Data");
        require(user == sender, "Invalid User");

        // aa = user;
        // b = _packageId;
        // c = cardTypes;
        // d = raritys;
        // f = signature;
        uint8 v;
        bytes32 r;
        bytes32 s;
        (v, r, s) = splitSignature(signature);
        bytes32 signHash = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        PERMIT_SYNTHESISHASH,
                        user,
                        cardIds,
                        level,
                        types
                    )
                )
            )
        );
        // a = ecrecover(signHash, v, r, s);
        require(signer == ecrecover(signHash, v, r, s), "Invalid Request!");
        verifyRecordb[cardId32] = true;
        return (user, cardIds, level, types);
    }

    function creatOrder(address sender, bytes memory data)
        external
        returns (address users, uint256[] memory)
    {
        (address user, uint256[] memory cardIds, bytes memory signature) = abi
            .decode(data, (address, uint256[], bytes));
        bytes32 cardId32 = keccak256(abi.encode(user, cardIds, signature));

        require(user == sender, "Invalid User");

        // aa = user;
        // b = _packageId;
        // c = cardTypes;
        // d = raritys;
        // f = signature;
        uint8 v;
        bytes32 r;
        bytes32 s;
        (v, r, s) = splitSignature(signature);
        bytes32 signHash = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_ORDERHASH, user, cardIds))
            )
        );
        // a = ecrecover(signHash, v, r, s);
        require(signer == ecrecover(signHash, v, r, s), "Invalid Request!");
        verifyRecordb[cardId32] = true;
        return (user, cardIds);
    }

    function miningCards(address sender, bytes memory data)
        external
        returns (address users, uint256)
    {
        (address user, uint256 cardId, bytes memory signature) = abi.decode(
            data,
            (address, uint256, bytes)
        );
        bytes32 cardId32 = keccak256(abi.encode(user, cardId, signature));
        require(!verifyRecordb[cardId32], "Invalid Data");
        require(user == sender, "Invalid User");

        // aa = user;
        // b = _packageId;
        // c = cardTypes;
        // d = raritys;
        // f = signature;
        uint8 v;
        bytes32 r;
        bytes32 s;
        (v, r, s) = splitSignature(signature);
        bytes32 signHash = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_MININGCARDHASH, user, cardId))
            )
        );
        // a = ecrecover(signHash, v, r, s);
        require(signer == ecrecover(signHash, v, r, s), "Invalid Request!");
        verifyRecordb[cardId32] = true;
        return (user, cardId);
    }

    function splitSignature(bytes memory sig)
        internal
        pure
        returns (
            uint8,
            bytes32,
            bytes32
        )
    {
        require(sig.length == 65, "Not Invalid Signature Data");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    function verifyWithdraw(bytes memory data)
        external
        returns (address, uint256)
    {
        (
            address user,
            uint256 amount,
            uint256 deadLine,
            bytes memory signature
        ) = abi.decode(data, (address, uint256, uint256, bytes));
        a = user;
        b = amount;
        // c = deadLine;
        // d = signature;
        require(block.timestamp <= deadLine, "Request Timeout");
        bytes32 requestId = keccak256(abi.encode(user, amount, deadLine));
        require(!verifyRecordb[requestId], "Invalid Data");
        uint8 v;
        bytes32 r;
        bytes32 s;
        (v, r, s) = splitSignature(signature);
        bytes32 signHash = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(PERMIT_WITHDRAW_TYPEHASH, user, amount, deadLine)
                )
            )
        );
        require(signerb == ecrecover(signHash, v, r, s), "Invalid Request!");
        verifyRecordb[requestId] = true;
        return (user, amount);
    }

    function verifyWithdrawMine(bytes memory data) external returns (uint256) {
        (uint256 amount, uint256 deadLine, bytes memory signature) = abi.decode(
            data,
            (uint256, uint256, bytes)
        );
        // ac = upOne;
        // ab = upTwo;
        // aa = down;
        require(block.timestamp <= deadLine, "Request Timeout");
        bytes32 requestId = keccak256(abi.encode(amount, deadLine));
        require(!verifyRecordb[requestId], "Invalid Data");
        uint8 v;
        bytes32 r;
        bytes32 s;
        (v, r, s) = splitSignature(signature);
        bytes32 signHash = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(PERMIT_WITHDRAW_MINEHASH, amount, deadLine)
                )
            )
        );
        require(signerb == ecrecover(signHash, v, r, s), "Invalid Request!");
        verifyRecordb[requestId] = true;
        return amount;
    }
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

pragma solidity ^0.7.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function decimals()  external view returns (uint256);
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
        assembly {
            size := extcodesize(account)
        }
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "./interface/IERC721.sol";
import "./interface/IERC721Receiver.sol";
import "./interface/IERC721Metadata.sol";
import "./ERC165.sol";

import "./utils/Address.sol";
import "./lib/Context.sol";
import "./lib/Strings.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string public _name;

    // Token symbol
    string public _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) public _owners;

    // Mapping owner address to token count
    mapping(address => uint256) public _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) public _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) public _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mintOld(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mintOld(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burnOld(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

import "./IERC721Receiver.sol";

interface IERC721TokenReceiverEx is IERC721Receiver {
    // bytes4(keccak256("onERC721ExReceived(address,address,uint256[],bytes)")) = 0x0f7b88e3
     
    function onERC721ExReceived(address operator, address from,
        uint256[] memory tokenIds, bytes memory data)
        external returns(bytes4);
}

pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

library Util {
    bytes4 internal constant ERC721_RECEIVER_RETURN = 0x150b7a02;  
    bytes4 internal constant ERC721_RECEIVER_EX_RETURN = 0x0f7b88e3;  
    
    uint256 public constant UDENO = 10 ** 18;  
    int256 public constant SDENO = 10 ** 18;  
    
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "./IERC165.sol";

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "./IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "./interface/IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

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