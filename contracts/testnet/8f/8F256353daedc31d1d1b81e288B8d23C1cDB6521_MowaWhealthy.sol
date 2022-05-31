// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0 <0.8.0;
pragma abicoder v2;

import "../Library/Context.sol";
import "../Library/Ownable.sol";
import "../Library/SafeMath.sol";
import "../Library/IERC721.sol";
import "../Library/IERC20.sol";
import "../Library/Address.sol";
import "../Library/ReentrancyGuard.sol";
import "./MowaCore.sol";

contract MowaWhealthy is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address;

    event CreateWhealthy(uint256 indexed tokenId, uint256 roomId, address user);
    event JoinWhealthy(uint256 indexed tokenId, uint256 roomId, address user);
    event CancelWhealthy(uint256 indexed tokenId, uint256 roomId, address user);
    event Surrender(uint256 indexed tokenId, uint256 roomId, address user);
    event ClaimWhealthy(uint256 indexed tokenId, uint256 roomId, address user);

    uint256 public roomId;

    struct Whealthy {
        uint256 tokenId;
        uint256 _roomId;
        address roomMaster;
        address roomUser;
        uint256 price;
        uint256 priceCal;
        uint256 typePrice;
        bool    winner;
        bool    reconcile;
        bool    finish;
        uint256 timeCreate;
    }

    // account => room
    mapping(address => Whealthy) public whealthy;
    mapping(address => bool) public blackList;
    mapping(uint256 => bool) public TokenIdblackList;

    IERC20 public mowaToken;
    address public mowaNFTV1;
    address public mowaNFTV2;
    MowaCore public mowaNFTCoreV1;
    MowaCore public mowaNFTCoreV2;

    uint256 public feeWhealthyMOWA = 90;
    uint256 public feeWhealthyOrther = 100;
    uint256 public feeMOWA = 10;
    address payable public feeWallet = 0xBee47A5e41DC9c98467d816076d75FB9A3a4eba3;
    address public addressBurn = 0x309d4172B8A0B3883263EC9622651d88aA1B0972;
    uint256 constant public PERCENTS_DIVIDER = 1000;
    // IERC20 public USDT = 0x55d398326f99059fF775485246999027B3197955;
    IERC20 public USDT = IERC20(0x337610d27c682E347C9cD60BD4b3b107C9d34dDd);

    // address private botChange = 0xCAF84d187C3DD9d8ee91aFef9C9af5194dd3916e;
    address private botChangeWinner = 0x8b9588F69e04D69655e0d866cD701844177360A7;
    address private supervisor = 0x171a1639Aa7fe24b406c098C8d91198D625791e9;
    address private admin = 0x36b5628e587C257B64c41c63c9f0b67c0D27cad4;
    bool isActive = true;

    constructor(
        IERC20 _mowaToken,
        MowaCore _mowaNFTCoreV1,
        address _mowaNFTV1,
        MowaCore _mowaNFTCoreV2,
        address _mowaNFTV2
    )  {
        mowaToken = _mowaToken;
        mowaNFTCoreV1 = MowaCore(_mowaNFTCoreV1);
        mowaNFTCoreV2 = MowaCore(_mowaNFTCoreV2);
        mowaNFTV1 = _mowaNFTV1;
        mowaNFTV2 = _mowaNFTV2;
    }

    receive() external payable{}

    function changeMowaToken(address _mowa) public onlyOwner {
        mowaToken = IERC20(_mowa);
    }

    modifier onlySupervisor() {
        require(isActive == true, "ask admin for approval");
        require(_msgSender() == supervisor, "require safe supervisor Address.");
        _;
    }

    modifier onlyAdmin(){
        require(_msgSender() == admin, "require safe Admin Address.");
        _;
    }

    modifier onlyBot(){
        require(_msgSender() == botChangeWinner, "require safe Bot Address.");
        _;
    }

    function changeSupervisor(address _supervisor) public onlyOwner {
        supervisor = _supervisor;
    }

    function changeAdmin(address _admin) public onlyOwner {
        admin = _admin;
    }

    function setBotChangeWinner(address _botChangeWinner) public onlyOwner {
        botChangeWinner = _botChangeWinner;
    }

    function changIsActive(bool active) public onlyAdmin {
        isActive = active;
    }

    function setFeeWalletMOWA(uint256 _feeWhealthyMOWA) onlySupervisor public {
        feeWhealthyMOWA = _feeWhealthyMOWA;
    }

    function setFeeWalletOrther(uint256 _feeWhealthyOrther) onlySupervisor public {
        feeWhealthyOrther = _feeWhealthyOrther;
    }

    function setAddressBurn(address _addressBurn) public onlyOwner {
        addressBurn = _addressBurn;
    }

    function setBlackList(address[] memory _user, bool _block) onlyOwner public {
        for (uint256 index; index < _user.length; index++) {
            blackList[_user[index]] = _block;
        }
    }

    function setTokenIdblackList(uint256[] memory _tokenId, bool _block) onlyOwner public {
        for (uint256 index; index < _tokenId.length; index++) {
            TokenIdblackList[_tokenId[index]] = _block;
        }
    }

    function onERC721Received(address, address, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }

    /**
      * @dev Withdraw bnb from this contract (Callable by owner only)
      */
    function SwapExactToken(
        address coinAddress,
        uint256 value,
        address payable to
    ) public onlyOwner {
        if (coinAddress == address(0)) {
            return to.transfer(value);
        }
        IERC20(coinAddress).transfer(to, value);
    }

    function createWhealthy(uint256 tokenId, uint256 price, uint256 typePrice) public payable nonReentrant {
        require(tokenId > 0 && price > 0 && typePrice > 0, "Invalid data");
        require(blackList[_msgSender()] == false, "owner in black list");
        require(TokenIdblackList[tokenId] == false, "TokenId in black list");

        require(whealthy[_msgSender()]._roomId == 0, "Users only join 1 room only");
        proccessWhealthy(tokenId, price, typePrice);
        whealthy[_msgSender()].roomMaster = _msgSender();
        roomId += 1;
        whealthy[_msgSender()]._roomId = roomId;
        emit CreateWhealthy(tokenId, roomId, _msgSender());
    }

    function joinWhealthy(uint256 tokenId, address roomMaster) public payable nonReentrant {
        require(tokenId > 0, "NFT required for betting");
        require(roomMaster != address(0), "The roomMaster wallet cannot address 0");
        require(whealthy[roomMaster].tokenId > 0, "room owner doesn't exist");
        whealthy[_msgSender()].roomMaster = roomMaster;
        whealthy[roomMaster].roomUser = _msgSender();
        whealthy[_msgSender()]._roomId = whealthy[roomMaster]._roomId;
        proccessWhealthy(tokenId, whealthy[roomMaster].price, whealthy[roomMaster].typePrice);
        emit JoinWhealthy(tokenId, whealthy[roomMaster]._roomId, _msgSender());
    }

    function proccessWhealthy(uint256 tokenId, uint256 price, uint256 typePrice) internal {
        uint256 level = mowaNFTCoreV2.getNFT(tokenId).level;
        if (level == 0) {
            require(IERC721(mowaNFTV1).ownerOf(tokenId) == _msgSender(), "not owner");
            IERC721(mowaNFTV1).transferFrom(_msgSender(), addressBurn, tokenId);
            mowaNFTCoreV2.safeMintNFT(address(this), tokenId);
            Mowa memory mowa = Mowa(
                tokenId,
                mowaNFTCoreV1.getNFT(tokenId).level,
                mowaNFTCoreV1.getNFT(tokenId).skill,
                mowaNFTCoreV1.getNFT(tokenId).star,
                mowaNFTCoreV1.getNFT(tokenId).character,
                mowaNFTCoreV1.getNFT(tokenId).class,
                block.timestamp
            );
            mowaNFTCoreV2.setNFTFactory(mowa, tokenId);
        } else {
            require(IERC721(mowaNFTV2).ownerOf(tokenId) == _msgSender(), "not owner");
            IERC721(mowaNFTV2).transferFrom(_msgSender(), address(this), tokenId);
        }
        uint256 _priceCal = price;

        if(typePrice == 1){
            uint256 mowaBalance = mowaToken.balanceOf(_msgSender());
            require(mowaBalance >= price, "Insufficient MOWA funds in the account");

            bool tranfer = mowaToken.transferFrom(_msgSender(), address(this), price);
            require(tranfer == true, "Transfer MOWA failed");

            // 1% fee contract MOWA
            _priceCal = price - price.mul(feeMOWA).div(PERCENTS_DIVIDER);

        } else if(typePrice == 2){
            require(msg.value >= price, "The price BNB to send is not correct");
            payable(address(this)).transfer(msg.value);
        } else {
            uint256 UsdtBalance = USDT.balanceOf(_msgSender());
            require(UsdtBalance >= price, "Insufficient USDT funds in the account");
            USDT.transferFrom(_msgSender(), address(this), price);
        }
        whealthy[_msgSender()].tokenId = tokenId;
        whealthy[_msgSender()].typePrice = typePrice;
        whealthy[_msgSender()].price = price;
        whealthy[_msgSender()].priceCal = _priceCal;
        whealthy[_msgSender()].timeCreate = block.timestamp;
    }

    function cancelWhealthy() public {
        require(whealthy[_msgSender()].finish == false, "The game is over please claim NFT");
        require(whealthy[_msgSender()].roomMaster == _msgSender(), "you are not the owner of the room");
        require(whealthy[_msgSender()].roomUser == address(0), "There are bets, can't cancel");
        require(whealthy[_msgSender()].tokenId > 0, "you don't bet");
        require(blackList[_msgSender()] == false, "owner in black list");

        IERC721(mowaNFTV2).transferFrom(address(this), _msgSender(), whealthy[_msgSender()].tokenId);

        uint256 price = whealthy[_msgSender()].priceCal;
        uint typePrice = whealthy[_msgSender()].typePrice;
        if(typePrice == 1){
            uint256 mowaBalance = mowaToken.balanceOf(address(this));
            require(mowaBalance >= price, "not enough MOWA to refund");
            bool tranfer = mowaToken.transfer(_msgSender(), price);
            require(tranfer == true, "Transfer MOWA failed");
        } else if(typePrice == 2){
            require(address(this).balance >= price, "not enough BNB to refund");
            payable(_msgSender()).transfer(price);
        } else {
            uint256 UsdtBalance = USDT.balanceOf(_msgSender());
            require(UsdtBalance >= price, "not enough USDT to refund");
            USDT.transfer(_msgSender(), price);
        }

        emit CancelWhealthy(whealthy[_msgSender()].tokenId, whealthy[_msgSender()]._roomId, _msgSender());
        delete whealthy[_msgSender()];
    }

    function surrender() public{
        require(whealthy[_msgSender()].finish == false, "The game is over please claim NFT");
        require(blackList[_msgSender()] == false, "owner in black list");
        require(whealthy[_msgSender()].tokenId > 0, "you don't bet");
        address userWin;

        if(whealthy[_msgSender()].roomMaster == _msgSender()){
            userWin = whealthy[_msgSender()].roomUser;
        } else{
            userWin = whealthy[_msgSender()].roomMaster;
        }
        whealthy[userWin].winner = true;
        whealthy[userWin].finish = true;
        IERC721(mowaNFTV2).transferFrom(address(this), _msgSender(), whealthy[_msgSender()].tokenId);
        emit Surrender(whealthy[_msgSender()].tokenId, whealthy[_msgSender()]._roomId, _msgSender());
        delete whealthy[_msgSender()];
    }

    function claimWhealthy() public payable nonReentrant {
        require(whealthy[_msgSender()].finish == true, "the game is not over yet");
        require(whealthy[_msgSender()].tokenId > 0, "you haven't bet yet");
        require(blackList[_msgSender()] == false, "owner in black list");

        uint256 price = 0;
        if(whealthy[_msgSender()].winner == true){
            price = whealthy[_msgSender()].priceCal.mul(2);
        } else if(whealthy[_msgSender()].reconcile == true){
            price = whealthy[_msgSender()].priceCal;
        }

        if(price > 0){
            uint256 typePrice = whealthy[_msgSender()].typePrice;
            uint256 amountUserReceive;
            uint256 amountFeeReceive;
            if(typePrice == 1){
                uint256 mowaBalance = mowaToken.balanceOf(address(this));
                require(mowaBalance >= price, "not enough MOWA to refund");
                if(feeWhealthyMOWA > 0){
                    amountFeeReceive = price.mul(feeWhealthyMOWA).div(PERCENTS_DIVIDER);
                    amountUserReceive = price - amountFeeReceive;
                    mowaToken.transfer(feeWallet, amountFeeReceive);
                } else {
                    amountUserReceive = price;
                }
                mowaToken.transfer(_msgSender(), amountUserReceive);
            } else if(typePrice == 2){
                require(address(this).balance >= price, "not enough BNB to refund");
                if(feeWhealthyOrther > 0){
                    amountFeeReceive = price.mul(feeWhealthyOrther).div(PERCENTS_DIVIDER);
                    amountUserReceive = price - amountFeeReceive;
                    payable(feeWallet).transfer(amountFeeReceive);
                } else {
                    amountUserReceive = price;
                }
                payable(_msgSender()).transfer(amountUserReceive);
            } else {
                uint256 UsdtBalance = USDT.balanceOf(address(this));
                require(UsdtBalance >= price, "not enough USDT to refund");

                if(feeWhealthyOrther > 0){
                    amountFeeReceive = price.mul(feeWhealthyOrther).div(PERCENTS_DIVIDER);
                    amountUserReceive = price - amountFeeReceive;
                    payable(feeWallet).transfer(price);
                    USDT.transfer(feeWallet, amountFeeReceive);
                } else {
                    amountUserReceive = price;
                }
                USDT.transfer(_msgSender(), amountUserReceive);
            }
        }

        IERC721(mowaNFTV2).transferFrom(address(this), _msgSender(), whealthy[_msgSender()].tokenId);
        emit ClaimWhealthy(whealthy[_msgSender()].tokenId, whealthy[_msgSender()]._roomId, _msgSender());
        delete whealthy[_msgSender()];
    }

    function changeWinner(address user) public onlyBot nonReentrant {
        require(whealthy[user].winner == false, "User has set win");
        if(whealthy[user].roomMaster == user){
            whealthy[whealthy[user].roomUser].finish = true;
        } else{
            whealthy[whealthy[user].roomMaster].finish = true;
        }
        whealthy[user].winner = true;
        whealthy[user].finish = true;
    }

    function changeReconcile(address user1, address user2) public onlyBot nonReentrant {
        require(whealthy[user1].reconcile == false && whealthy[user2].reconcile == false, "User has set reconcile");
        whealthy[user1].reconcile = true;
        whealthy[user2].reconcile = true;
        whealthy[user1].finish = true;
        whealthy[user2].finish = true;
    }

    function getWhealthy(address user) public view returns (Whealthy memory) {
        return Whealthy({
            tokenId : whealthy[user].tokenId,
            _roomId : whealthy[user]._roomId,
            roomMaster : whealthy[user].roomMaster,
            roomUser : whealthy[user].roomUser,
            price : whealthy[user].price,
            priceCal : whealthy[user].priceCal,
            typePrice : whealthy[user].typePrice,
            winner : whealthy[user].winner,
            reconcile : whealthy[user].reconcile,
            finish : whealthy[user].finish,
            timeCreate : whealthy[user].timeCreate
        });
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.7.6;
pragma abicoder v2;

struct Mowa {
    uint256 tokenId;
    uint256 level;
    uint256 skill;
    uint256 star;
    uint256 character;
    uint256 class;
    uint256 bornTime;
}

interface MowaCore {
    function changeLevel(
        uint256 _tokenId,
        uint256 _level
    ) external;

    function changeClass(
        uint256 _tokenId,
        uint256 _class
    ) external;

    function changeSkill(
        uint256 _tokenId,
        uint256 _skill
    ) external;

    function changeCharacter(
        uint256 _tokenId,
        uint256 _character
    ) external;

    function changeStar(
        uint256 _tokenId,
        uint256 _star
    ) external;

    function getNFT(uint256 _tokenId) external view returns (Mowa memory);
    function setNFTFactory(Mowa memory _mowa, uint256 _tokenId) external;
    function safeMintNFT(address _addr, uint256 tokenId) external;
    function getAllNFT(uint256 _fromTokenId, uint256 _toTokenId) external view returns (Mowa[] memory);
    function getNextNFTId() external view returns (uint256);
    function safeBurnNFT(uint256 tokenId) external;
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "./Context.sol";
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
    constructor () {
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
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

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
    function transferFrom(address from, address to, uint256 tokenId) external;

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
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
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