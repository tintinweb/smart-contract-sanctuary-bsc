// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "../other/divestor_upgradeable.sol";
import "../other/random_generator_upgradeable.sol";
import "../interface/I_soul_1155.sol";
import "../interface/I_soul_721.sol";
import "../interface/I_soul_token.sol";

contract SoulCore is DivestorUpgradeable, RandomGeneratorUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using CountersUpgradeable for CountersUpgradeable.Counter;

    struct coreStruct{
        IERC20Upgradeable USDT;
        address defaultAddress;
        ISoul1155    SOUL1155;
        ISoul721     SOUL721;
        ISoulToken   SOULTOKEN;
    }

    coreStruct public coreInfo;


    function initialize(address USDT_, address defaultAddress, address SOUL_1155_, address SOUL_721_, address SOUL_TOKEN_) public initializer {
        __Divestor_init();
        coreInfo = coreStruct({
        USDT: IERC20Upgradeable(USDT_),
        defaultAddress: defaultAddress,
        SOUL1155: ISoul1155(SOUL_1155_),
        SOUL721: ISoul721(SOUL_721_),
        SOULTOKEN: ISoulToken(SOUL_TOKEN_)
        });
    }

    //男女盲盒池
    struct nftStruct{
        uint tokenId;
        uint count;
    }

    CountersUpgradeable.Counter private _tokenId;


    //概率 => 对应tokenId跟数量
    mapping(uint => nftStruct[]) public gentlemanA;
    mapping(uint => nftStruct[]) public gentlemanB;
    mapping(uint => nftStruct[]) public ladyA;
    mapping(uint => nftStruct[]) public ladyB;

    //铸造盲盒
    function createToken(uint gender, uint amount, uint soulCount, address recommender) public returns(bool){
        //数量， 为100的倍数
        require(amount > 0 && amount%100 == 0, "Valid quantity must be filled in");

        //推荐人不能是自己
        require(recommender != _msgSender(), "Can not be your own recommender");

        //是否有推荐人，没有则设定为默认推荐人地址
        if(recommender == address(0)){
            recommender = coreInfo.defaultAddress;
        }

        //分成规则
        divide(recommender, address(0), amount);

        _tokenId.increment();
        uint tokenId = _tokenId.current();
        coreInfo.SOUL721.mint(_msgSender(), tokenId);
        coreInfo.SOUL1155.mint(_msgSender(), tokenId, amount);

        uint probability;    //概率索引
        //消耗soul的数量
        if(soulCount > 0){
            require(soulCount == 1 || soulCount%5 == 0, "soulCount err");
            if(soulCount == 5){
                probability = 1;
            }else if(soulCount == 10){
                probability = 2;
            }else if(soulCount == 20){
                probability = 3;
            }

            //销毁soul
            coreInfo.SOULTOKEN.burn(soulCount);
        }

        //插入的数据
        nftStruct memory insert = nftStruct(tokenId, amount);
        if(gender == 1){
            //男
            if (soulCount > 0){
                //氪金B池
                gentlemanB[probability].push(insert);
            }else{
                gentlemanA[probability].push(insert);
            }
        }else{
            //女
            if (soulCount > 0){
                //氪金B池
                ladyB[probability].push(insert);
            }else{
                ladyA[probability].push(insert);
            }
        }

        return true;
    }


    //抽取
    function extractToken(uint gender, address recommender) public returns(uint){
        //推荐人不能是自己
        require(recommender != _msgSender(), "Can not be your own recommender");

        //是否有推荐人，没有则设定为默认推荐人地址
        if(recommender == address(0)){
            recommender = coreInfo.defaultAddress;
        }

        //给抽取者1枚soul========================================
        coreInfo.SOULTOKEN.transfer(_msgSender(), 1 ether);

        uint tokenId;

        //随机二选一抽取一个池子
        uint row = randomCeil(2);
        if(row == 1){
            //免费池
            tokenId = getFree(gender, recommender, 0);
        }else{
            //氪金池
            tokenId = getCharge(gender, recommender, 0);
        }


        require(tokenId != 0, "Unable to extract");

        coreInfo.SOUL1155.safeTransferFrom(address(this), _msgSender(), tokenId, 1, '');

        return tokenId;
    }


    //免费池子的抽取
    /* @param
     * gender_（性别）： 1-男，2-女
     * isJump_（是否跳转，用于判断其他池子跳转过来）： 0-否，1-是
     **/
    function getFree(uint gender_, address recommender_, uint isJump_) private returns(uint){
        uint tokenId;
        if(gender_ == 1){
            //男-免费池子
            uint length = gentlemanA[0].length;      //免费池的长度
            if(length == 0){
                //当前池子无数据
                if(isJump_ == 1){
                    //从氪金池跳转过来，都无数据，返回空tokenId
                    return tokenId;
                }else{
                    //当前免费池子无数据，需要跳转到氪金池去抽取
                    tokenId = getCharge(gender_, recommender_, 1);
                    return tokenId;
                }
            }
            uint tokenIndex = randomCeil(length) - 1;            //随机冲免费池中抽取一个索引
            tokenId = gentlemanA[0][tokenIndex].tokenId;    //抽中的tokenId

            address caster = coreInfo.SOUL721.ownerOf(tokenId);
            //需要通过tokenId获取铸造者，用于分成。
            divide(recommender_, caster, 100);

            //池子数量维护
            countMaintain(1, 0, tokenIndex, length);
            return tokenId;
        }else if(gender_ == 2){
            //女-免费池子
            uint length = ladyA[0].length;          //池子的长度
            if(length == 0){
                //当前池子无数据
                if(isJump_ == 1){
                    //从氪金池跳转过来，都无数据，返回空tokenId
                    return tokenId;
                }else{
                    //当前免费池子无数据，需要跳转到氪金池去抽取
                    tokenId = getCharge(gender_, recommender_, 1);
                    return tokenId;
                }
            }
            uint tokenIndex = randomCeil(length) - 1;
            tokenId = ladyA[0][tokenIndex].tokenId;

            address caster = coreInfo.SOUL721.ownerOf(tokenId);
            //需要通过tokenId获取铸造者，用于分成。
            divide(recommender_, caster, 100);

            //池子数量维护
            countMaintain(3, 0, tokenIndex, length);
            return tokenId;
        }
        return tokenId;
    }



    //氪金池子的抽取
    function getCharge(uint gender_, address recommender_, uint isJump_) private returns(uint){
        uint tokenId;
        uint proIndex = getIndex();                //获取概率索引

        if(gender_ == 1){
            //男
            uint length = gentlemanB[proIndex].length;
            if(length == 0){
                //无数据
                if(isJump_ == 1){
                    //是从免费池子过来的，则直接返回空tokenId
                    return tokenId;
                }else{
                    //否，跳转到免费池子
                    tokenId = getFree(gender_, recommender_, 1);
                    return tokenId;
                }
            }else{
                //氪金池有数据
                uint tokenIndex = randomCeil(length) - 1;     //随机从池子中抽取一个tokenId索引
                //获取tokenId
                tokenId = gentlemanB[proIndex][tokenIndex].tokenId;

                address caster = coreInfo.SOUL721.ownerOf(tokenId);
                //需要通过tokenId获取铸造者，用于分成。
                divide(recommender_, caster, 100);
                countMaintain(2, proIndex, tokenIndex, length);            //tokenId数量维护

                return tokenId;
            }
        }else if (gender_ == 2){
            //女
            uint length = ladyB[proIndex].length;
            if(length == 0){
                //无数据
                if(isJump_ == 1){
                    //是从免费池子过来的，则直接返回空tokenId
                    return tokenId;
                }else{
                    //否，跳转到免费池子
                    tokenId = getFree(gender_, recommender_, 1);
                    return tokenId;
                }
            }else{
                //存在数据
                uint tokenIndex = randomCeil(length) - 1;     //随机从池子中抽取一个tokenId索引
                tokenId = ladyB[proIndex][tokenIndex].tokenId;
                address caster = coreInfo.SOUL721.ownerOf(tokenId);
                //需要通过tokenId获取铸造者，用于分成。
                divide(recommender_, caster, 100);
                countMaintain(4, proIndex, tokenIndex, length);           //tokenId数量维护
                return tokenId;
            }

        }
        return tokenId;
    }



    //获取有数据的数组索引
    function getIndex() private returns(uint){
        uint index;
        //获取1-100的随机数
        uint random = randomCeil(100);
        if(random > 10 && random <= 30){
            index = 1;
        }else if(random > 30 && random <= 60){
            index = 2;
        }else if(random > 60 && random <= 100){
            index = 3;
        }
        return index;
    }

    //tokenId数量维护
    function countMaintain(uint status, uint proIndex_, uint tokenIndex_, uint length_) private{
        if(status == 1){
            //男-免费池
            gentlemanA[proIndex_][tokenIndex_].count = gentlemanA[proIndex_][tokenIndex_].count - 1;
            if(gentlemanA[proIndex_][tokenIndex_].count == 0){
                //该tokenId已经被开完，从数组中去掉该tokenId
                if(length_ > 1){
                    //池子的长度必须大于1
                    //将当前开完的tokenId替换成最后一个
                    gentlemanA[proIndex_][tokenIndex_].tokenId = gentlemanA[proIndex_][length_-1].tokenId;
                    gentlemanA[proIndex_][tokenIndex_].count = gentlemanA[proIndex_][length_-1].count;
                }
                //移除最后一个tokenId
                gentlemanA[proIndex_].pop();
            }
        }else if(status == 2){
            //男-氪金池
            gentlemanB[proIndex_][tokenIndex_].count = gentlemanB[proIndex_][tokenIndex_].count - 1;
            if(gentlemanB[proIndex_][tokenIndex_].count == 0){
                //该tokenId已经被开完，从数组中去掉该tokenId
                if(length_ >1){
                    gentlemanB[proIndex_][tokenIndex_].tokenId = gentlemanB[proIndex_][length_-1].tokenId;
                    gentlemanB[proIndex_][tokenIndex_].count = gentlemanB[proIndex_][length_-1].count;
                }
                gentlemanB[proIndex_].pop();
            }
        }else if(status == 3){
            //女-免费池
            ladyA[proIndex_][tokenIndex_].count = ladyA[proIndex_][tokenIndex_].count - 1;
            if(ladyA[proIndex_][tokenIndex_].count == 0){
                //该tokenId已经被开完，从数组中去掉该tokenId
                if(length_ > 1){
                    //池子长度必须大于1
                    //将当前开完的tokenId替换成最后一个
                    ladyA[proIndex_][tokenIndex_].tokenId = ladyA[proIndex_][length_-1].tokenId;
                    ladyA[proIndex_][tokenIndex_].count = ladyA[proIndex_][length_-1].count;
                }
                //移除最后一个tokenId
                ladyA[proIndex_].pop();
            }
        }else if(status == 4){
            //女-氪金池
            ladyB[proIndex_][tokenIndex_].count = ladyB[proIndex_][tokenIndex_].count - 1;
            if(ladyB[proIndex_][tokenIndex_].count == 0){
                //该tokenId已经被开完，从数组中去掉该tokenId
                if(length_ > 1){
                    ladyB[proIndex_][tokenIndex_].tokenId = ladyB[proIndex_][length_-1].tokenId;
                    ladyB[proIndex_][tokenIndex_].count = ladyB[proIndex_][length_-1].count;
                }
                ladyB[proIndex_].pop();
            }
        }
    }


    //分成部分
    function divide(address recommender_, address caster_, uint amount_) private{
        //给推荐人，没有推荐人会设定一个默认的推荐人地址
        coreInfo.USDT.safeTransferFrom(_msgSender(), recommender_, amount_/ 100 ether);
        if(caster_ == address(0)){
            //铸造本身没有铸造者分成，平台占两份
            coreInfo.USDT.safeTransferFrom(_msgSender(), address(this), amount_/ 50 ether);
        }else{
            //给铸造者分成
            coreInfo.USDT.safeTransferFrom(_msgSender(), caster_, amount_/ 100 ether);
            //平台分成
            coreInfo.USDT.safeTransferFrom(_msgSender(), address(this), amount_/ 100 ether);
        }
        //合约奖池分成
        coreInfo.USDT.safeTransferFrom(_msgSender(), address(this), amount_/ 100 ether);
    }


    // ------------------------ onlyOwner start--------------------
    function incrTokenId() public onlyOwner {
        _tokenId.increment();
    }

    function setSoul1155Addr(address com_) public onlyOwner {
        coreInfo.SOUL1155 = ISoul1155(com_);
    }

    function setSoul721Addr(address com_) public onlyOwner {
        coreInfo.SOUL721 = ISoul721(com_);
    }

    function setSoulTokenAddr(address com_) public onlyOwner {
        coreInfo.SOULTOKEN = ISoulToken(com_);
    }

    function setDefaultAddr(address com_) public onlyOwner {
        coreInfo.defaultAddress = com_;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract RandomGeneratorUpgradeable is Initializable {
    uint private randNonce;

    function __RandomGenerator_init() internal onlyInitializing {
        __RandomGenerator_init_unchained();
    }

    function __RandomGenerator_init_unchained() internal onlyInitializing {
        randNonce = 0;
    }


    function random(uint256 seed) internal returns (uint256) {
        randNonce += 1;
        return uint256(keccak256(abi.encodePacked(
                blockhash(block.number - 1),
                blockhash(block.number - 2),
                blockhash(block.number - 3),
                blockhash(block.number - 4),
                blockhash(block.number - 5),
                blockhash(block.number - 6),
                blockhash(block.number - 7),
                blockhash(block.number - 8),
                block.timestamp,
                msg.sender,
                randNonce,
                seed
            )));
    }

    function randomCeil(uint256 q) internal returns (uint256) {
        return (random(gasleft()) % q) + 1;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";


abstract contract DivestorUpgradeable is OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    event Divest(address token, address payee, uint value);

    function __Divestor_init() internal onlyInitializing {
        __Divestor_init_unchained();
    }

    function __Divestor_init_unchained() internal onlyInitializing {
        __Ownable_init();
    }

    function divest(address token_, address payee_, uint value_) external onlyOwner {
        if (token_ == address(0)) {
            payable(payee_).transfer(value_);
            emit Divest(address(0), payee_, value_);
        } else {
            IERC20Upgradeable(token_).safeTransfer(payee_, value_);
            emit Divest(address(token_), payee_, value_);
        }
    }

    function setApprovalForAll(address token_, address _account) external onlyOwner {
        IERC721Upgradeable(token_).setApprovalForAll(_account, true);
    }
    
    function setApprovalForAll1155(address token_, address _account) external onlyOwner {
        IERC1155Upgradeable(token_).setApprovalForAll(_account, true);
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

interface ISoulToken {
    function burn(uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

interface ISoul721{
    function mint(address player_, uint tokenId_) external returns (bool);
    function ownerOf(uint256 tokenId) external view returns (address);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

interface ISoul1155 {
    function mint(address to_, uint tokenId_, uint amount_) external returns (bool);
    function safeTransferFrom(address from, address to, uint256 cardId, uint256 amount, bytes memory data_) external;
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
interface IERC165Upgradeable {
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
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library CountersUpgradeable {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}