pragma solidity ^0.8.0;

import "./StyleCreate.sol";

import "../lib/Manager.sol";

contract StyleCreateFactory is Manager {

    event StyleCreated(address indexed admin, address indexed styleItem);

    constructor(address _dao) Manager(_dao) {

    }

    /**
     * @dev admin 款式合约的owner.
     * @dev dexAddress 中心化交易地址
     * @dev royaltyRate  版税手续费
     */
    function createStyle(address payable dexAddress, uint96 royaltyRate) external onlyDAO returns (address) {
        bytes32 salt = keccak256(abi.encodePacked(dao, block.timestamp));
        string memory url = "https://nft-admin.mgface.com/nft/system/storage/download/{id}.json";
        //create2
        StyleCreate styleItem = new StyleCreate{salt : salt}(url, dexAddress, royaltyRate);
        styleItem.transferOwnership(dao);
        address result = address(styleItem);
        emit StyleCreated(dao, result);
        return result;
    }
}

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155Supply} from  "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import {Ownable} from  "@openzeppelin/contracts/access/Ownable.sol";
import "../lib/ERC2981.sol";
import "../MgNftDex.sol";

contract StyleCreate is Ownable, ERC1155Supply, ERC2981 {

    uint256 public tokenSupply;
    uint256 public maxIndex = 1;
    mapping(address => bool) public whiteList;
    uint96 public royaltyRate;
    //订单号-nftId对应的价格
    mapping(uint256 => mapping(uint256 => uint256)) private nftIdPrice;
    MgNftDex private immutable mgNftDex;
    address  public  immutable dexAddress;

    event updatePrice(uint256 indexed saleOrderId, uint256 indexed nftId, uint256 price);

    // url = "https://nft-admin.mgface.com/nft/system/storage/download/{id}.json"
    // 部署时候设置参数
    constructor(string memory uri_, address payable _dexAddress, uint96 _royaltyRate) ERC1155(uri_) {
        whiteList[msg.sender] = true;
        royaltyRate = _royaltyRate;
        mgNftDex = MgNftDex(_dexAddress);
        dexAddress = _dexAddress;
    }

    function _feeDenominator() internal view override returns (uint96){
        return uint96(mgNftDex.feeDenominator());
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, ERC2981) returns (bool){
        return interfaceId == type(IERC2981).interfaceId || interfaceId == type(IERC165).interfaceId;
    }


    //设置订单价格
    function setNftIdPrice(uint256 saleOrderId, uint256 nftId, uint256 price) public {
        require(price > 0, "nftId price must be greater than 0");

        require(balanceOf(msg.sender, nftId) > 0 && price > 0, "nftId number must be greater than 0");

        nftIdPrice[saleOrderId][nftId] = price;

        emit updatePrice(saleOrderId, nftId, price);
    }

    //查询maker-nftId价格
    function getSaleOrderIdPrice(uint256 saleOrderId, uint256 nftId) external view returns (uint256) {
        return nftIdPrice[saleOrderId][nftId];
    }

    function addWhiteList(address account) public onlyOwner {
        whiteList[account] = true;
    }


    function mintWithWiteList(address to) public returns (uint256){
        require(whiteList[msg.sender], "Not in white");
        _mint(to, maxIndex, 1, "");
        maxIndex = maxIndex + 1;
        tokenSupply = tokenSupply + 1;
        return maxIndex - 1;
    }

    function mintBatchWithNumber(uint256 idsNumber, uint256 amount) public onlyOwner {
        require(amount > 0, "amount must more than zero");
        uint256[] memory ids = new uint256[](idsNumber);
        uint256[] memory amounts = new uint256[](idsNumber);
        uint256 addSupply;
        for (uint256 i = tokenSupply; i < (tokenSupply + idsNumber); i++) {
            ids[i - tokenSupply] = i;
            amounts[i - tokenSupply] = amount;
            if (!exists(i)) {
                ++addSupply;
            }
        }
        tokenSupply = tokenSupply + addSupply;
        maxIndex = maxIndex + idsNumber;
        _mintBatch(msg.sender, ids, amounts, "");
    }

    function transferWithNumber(uint256 start, uint256 idsNumber, uint256 amount, address to) public {
        uint256[] memory ids = new uint256[](idsNumber);
        uint256[] memory amounts = new uint256[](idsNumber);
        for (uint256 i = start; i < (idsNumber + start); i++) {
            ids[i - start] = i;
            amounts[i - start] = amount;
        }
        safeBatchTransferFrom(msg.sender, to, ids, amounts, "");
    }


    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
    public
    onlyOwner
    {
        uint256 addSupply;
        for (uint256 i = 0; i < ids.length; ++i) {
            if (!exists(ids[i])) {
                ++addSupply;
                _setTokenRoyalty(ids[i], mgNftDex.feeRecipient(), royaltyRate);
            }
        }
        tokenSupply = tokenSupply + addSupply;
        _mintBatch(to, ids, amounts, data);
        maxIndex = maxIndex + ids.length;
    }

    function getTokenSupply() public view returns (uint256) {
        return tokenSupply;
    }

    function brun(
        address account,
        uint256 id,
        uint256 value) public {

        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        _burn(account, id, value);
        if (totalSupply(id) == 0) {
            --tokenSupply;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Strings.sol";
import "../interfaces/DEXEventsAndErrors.sol";
import "../interfaces/IManager.sol";

contract Manager is IManager, DEXEventsAndErrors {

    address public dao;

    mapping(address => bool) public operators;

    mapping(address => bool) public platformDex;

    mapping(address => bool) public platformNft;

    mapping(address => bool) public allowedNft;

    constructor(address _dao)  {
        dao = _dao;
        operators[_dao] = true;
    }

    modifier onlyDAO() {
        require(msg.sender == dao, "NotDao Address");
        _;
    }

    modifier onlyOperator() {
        require(operators[msg.sender], "NotOperator");
        _;
    }

    /**
    *(success,) = address(test).call{value: 2 ether}("");
    * 纯转账，例如对每个空empty calldata的调用
    */
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    /**
    *  (success,) = address(test).call{value: 1}(abi.encodeWithSignature("nonExistingFunction()"));
    * 除了纯转账外，所有的调用都会调用这个函数．
    * (因为除了 receive 函数外，没有其他的函数).
    * 任何对合约非空calldata 调用会执行回退函数(即使是调用函数附加以太).
    */
    fallback() external payable {
        emit Received(msg.sender, msg.value);
    }


    function withdrawAll(address payable _to) public onlyDAO {
        _to.transfer(address(this).balance);
    }

    function setDao(address _dao, bool _isOperator) external onlyDAO {
        require(dao != _dao, "dao Address is same");

        delete operators[dao];

        dao = _dao;

        operators[_dao] = _isOperator;

        emit SetDao(_dao, _isOperator);
    }

    function setOperators(address[] memory _addrs, bool _flag) external onlyDAO {
        for (uint256 i = 0; i < _addrs.length; i++) {
            operators[_addrs[i]] = _flag;
            emit SetOperators(_addrs[i], _flag);
        }
    }

    //设置所属平台的DAO合约地址
    function setPlatformDex(address _addr, bool _flag) external onlyOperator {
        platformDex[_addr] = _flag;
        emit SetPlatformDex(_addr, _flag);
    }
    //设置所属平台的NFT合约地址
    function setPlatformNft(address _addr, bool _flag) external onlyOperator {
        platformNft[_addr] = _flag;
        allowedNft[_addr] = _flag;
    }

    function setNftAllowed(address _addr, bool _flag) external onlyOperator {
        allowedNft[_addr] = _flag;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./lib/OrderValidator.sol";
import "./lib/TransferHelper.sol";
import "./interfaces/IConduit.sol";
import {DEXConfig, EIP712} from "./lib/DEXConfig.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./lib/OrderHelper.sol";

contract MgNftDex is DEXConfig, OrderHelper, ReentrancyGuard, OrderValidator, TransferHelper {

    //订单可购买的数量
    mapping(uint256 => uint256) public purchasedNumber;

    constructor(address _daoAddr, address feeRecipientAddr, string memory _name, string memory _version, uint256 _chainId) DEXConfig(
        _daoAddr, feeRecipientAddr, _name, _version, _chainId)  {
    }


    /**
    * @dev 批量购买，用在购物车上面
    */
    function batchFulfillFixedPriceOrder(TakerInfo[] calldata takerInfos, FixedPriceOrder[] calldata _makerOrders, bytes[] calldata _makerSig)
    external
    payable
    nonReentrant {
        for (uint i = 0; i < takerInfos.length; i++) {
            fulfillFixedPriceOrder(takerInfos[i], _makerOrders[i], _makerSig[i]);
        }
    }

    /**
     * 单笔交易
     * @dev 买方信息
     * @dev 卖家订单信息
     * @dev 限制只有DAO地址才能调用该合约，其他地址都不能调用匹配订单
     */
    function fulfillFixedPriceOrder(TakerInfo calldata takerInfo, FixedPriceOrder calldata _makerOrder, bytes calldata _makerSig)
    public
    payable
    nonReentrant
    {
        //买方地址
        address _taker = msg.sender;
        //卖方地址
        address _maker = _makerOrder.maker;
        //购买的订单号
        uint256 saleOrderId = takerInfo.saleOrderId;

        require(saleOrderId == _makerOrder.saleOrderId, "saleOrderId isn't matched");
        //购买的NFT数量
        uint256 buyNftNumber = takerInfo.buyNftNumber;

        //购买NFT数量不能超过订单NFT数量
        require(buyNftNumber > 0 && purchasedNumber[saleOrderId] + buyNftNumber <= _makerOrder.assets.nftAmount, "Exceed_Nft_Number");

        //查询最终使用价格
        uint256 usePrice = getUsePrice(saleOrderId, _makerOrder.assets.nft, _makerOrder.assets.nftId, _makerOrder.assets.firstPrice);

        //得出订单ft数量
        uint256 _ftAmount = buyNftNumber * usePrice;

        //校验支付费用
        validatorFee(saleOrderId, takerInfo.tokenAmount, _makerOrder.assets.ft, _ftAmount, _makerOrder.royaltyRate);

        //判断是否有限价单或者指定的价格单交易
        (bool flag,uint256 amount) = speicalSale(saleOrderId, buyNftNumber, _taker, usePrice);
        if (flag) {
            _ftAmount = amount;
        }


        //验证订单正确性，参数为订单信息和签名信息，订单信息从中心化数据查询，签名信息从前端将订单信息打包签名
        (bytes memory assetsBytes, bytes32 orderHash, bytes memory orderBytes) = validateOrder(
            _makerOrder,
            _makerSig,
            _taker
        );

        // transfer nft  转移支付nft :第二参数是from，第三参数是to
        transferNFT(_makerOrder, _maker, _taker, buyNftNumber, _ftAmount);

        // transfer token  转移支付代币
        //:第二参数是to地址，第三参数是from地址，买家给卖家转账
        transferFT(
            _makerOrder,
            _taker,
            _maker,
            _ftAmount
        );

        //可购买的数据
        purchasedNumber[saleOrderId] += buyNftNumber;

        // emit log， 监控日志事件的十六进制数据通过abi.decode方法解析出来
        emit FixedPriceOrderMatched(_maker, _taker, saleOrderId, buyNftNumber, orderHash, orderBytes, assetsBytes);
    }


    //校验支付的费用
    function validatorFee(uint256 saleOrderId, uint256 tokenAmount, address ft, uint256 _ftAmount, uint256 _royaltyRate) private view {
        //平台币支付
        bool condition1 = tokenAmount == 0 && ft == address(0);
        //token代币支付
        bool condition2 = tokenAmount > 0 && ft != address(0);

        require(condition1 || condition2, "pay method is error");

        //说明是平台币支付
        if (condition1) {
            //校验用户支付费用>=平台税+版税+商品价格
            caculateMustValue(saleOrderId, _ftAmount, _royaltyRate, msg.value);
        }
        //说明是用的token代币支付
        if (condition2) {
            //校验用户支付费用>=平台税+版税+商品价格
            caculateMustValue(saleOrderId, _ftAmount, _royaltyRate, tokenAmount);
        }
    }

    //计算合格的数据
    function caculateMustValue(uint256 saleOrderId, uint256 _ftAmount, uint256 _royaltyRate, uint256 value) private view {
        //_ftAmount要包含版税+平台费用在里面的
        uint256 royaltyAmount = (_ftAmount * _royaltyRate) / feeDenominator;

        uint256 platformAmount = (_ftAmount * _feeRate()) / feeDenominator;

        uint256 payAmount = _ftAmount + royaltyAmount + platformAmount;

        require(value >= payAmount, string.concat("saleOrderId:", Strings.toString(saleOrderId), ",Require Value:", Strings.toString(payAmount)));
    }

    /**
     * @dev 取消订单
     */
    function cancelOrder(FixedPriceOrder[] calldata _orders) external {
        address maker = msg.sender;
        for (uint256 i = 0; i < _orders.length; i++) {
            FixedPriceOrder calldata order = _orders[i];
            // Verify order base infomation
            require(maker == order.maker, "cancelOrder-MakerNotMatch");

            (, , bytes32 orderHash,) = deriveOrder(order);

            require(!ordersStatus[orderHash].cancelled, "cancelOrder-OrderIsCancelled");

            ordersStatus[orderHash].cancelled = true;

            emit OrderCancelled(maker, order.saleOrderId, orderHash);
        }
    }


    function isPlatformNft(address _nft) internal view override returns (bool) {
        return platformNft[_nft];
    }

    function _feeDenominator() internal view override returns (uint256) {
        return feeDenominator;
    }

    function _feeRate() internal view override returns (uint256) {
        return feeRate;
    }

    function _feeRecipient() internal view override returns (address) {
        return feeRecipient;
    }

    function hashOrder(bytes memory _orderBytes) internal view override returns (bytes32) {
        return EIP712._hashTypedDataV4(keccak256(_orderBytes));
    }

    /**
     * @dev  recover public address
     */
    function recover(bytes32 _hash, bytes calldata _signature)
    internal
    pure
    override
    returns (address)
    {
        return ECDSA.recover(_hash, _signature);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/common/ERC2981.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "../interfaces/DEXEventsAndErrors.sol";

/**
 * @dev Implementation of the NFT Royalty Standard, a standardized way to retrieve royalty payment information.
 *
 * Royalty information can be specified globally for all token ids via {_setDefaultRoyalty}, and/or individually for
 * specific token ids via {_setTokenRoyalty}. The latter takes precedence over the first.
 *
 * Royalty is specified as a fraction of sale price. {_feeDenominator} is overridable but defaults to 10000, meaning the
 * fee is specified in basis points by default.
 *
 * IMPORTANT: ERC-2981 only specifies a way to signal royalty information and does not enforce its payment. See
 * https://eips.ethereum.org/EIPS/eip-2981#optional-royalty-payments[Rationale] in the EIP. Marketplaces are expected to
 * voluntarily pay royalties together with sales, but note that this standard is not yet widely supported.
 *
 * _Available since v4.5._
 */
abstract contract ERC2981 is IERC2981,ERC165 {
    struct RoyaltyInfo {
        address receiver;
        uint96 royaltyFraction;
    }

    RoyaltyInfo private _defaultRoyaltyInfo;
    mapping(uint256 => RoyaltyInfo) private _tokenRoyaltyInfo;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc IERC2981
     */
    function royaltyInfo(uint256 nftId, uint256 _salePrice) public view virtual override returns (address, uint256) {
        RoyaltyInfo memory royalty = _tokenRoyaltyInfo[nftId];

        if (royalty.receiver == address(0)) {
            royalty = _defaultRoyaltyInfo;
        }

        uint256 royaltyAmount = (_salePrice * royalty.royaltyFraction) / _feeDenominator();

        return (royalty.receiver, royaltyAmount);
    }

    /**
     * @dev The denominator with which to interpret the fee set in {_setTokenRoyalty} and {_setDefaultRoyalty} as a
     * fraction of the sale price. Defaults to 10000 so fees are expressed in basis points, but may be customized by an
     * override.
     */
    function _feeDenominator() internal view virtual returns (uint96);

    /**
     * @dev Sets the royalty information that all ids in this contract will default to.
     *
     * Requirements:
     *
     * - `receiver` cannot be the zero address.
     * - `feeNumerator` cannot be greater than the fee denominator.
     */
    function _setDefaultRoyalty(address receiver, uint96 feeNumerator) internal virtual {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: invalid receiver");
        _defaultRoyaltyInfo = RoyaltyInfo(receiver, feeNumerator);
    }

    /**
     * @dev Removes default royalty information.
     */
    function _deleteDefaultRoyalty() internal virtual {
        delete _defaultRoyaltyInfo;
    }

    /**
     * @dev Sets the royalty information for a specific token id, overriding the global default.
     *
     * Requirements:
     *
     * - `receiver` cannot be the zero address.
     * - `feeNumerator` cannot be greater than the fee denominator.
     */
    function _setTokenRoyalty(
        uint256 nftId,
        address receiver,
        uint96 feeNumerator
    ) internal virtual {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: Invalid parameters");

        _tokenRoyaltyInfo[nftId] = RoyaltyInfo(receiver, feeNumerator);
    }

    /**
     * @dev Resets royalty information for the token id back to the global default.
     */
    function _resetTokenRoyalty(uint256 nftId) internal virtual {
        delete _tokenRoyaltyInfo[nftId];
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.0;

import "./IERC1155.sol";
import "./IERC1155Receiver.sol";
import "./extensions/IERC1155MetadataURI.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    constructor(string memory uri_) {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: address zero is not a valid owner");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `from`
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `ids` and `amounts` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    /**
     * @dev Hook that is called after any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC1155/extensions/ERC1155Supply.sol)

pragma solidity ^0.8.0;

import "../ERC1155.sol";

/**
 * @dev Extension of ERC1155 that adds tracking of total supply per id.
 *
 * Useful for scenarios where Fungible and Non-fungible tokens have to be
 * clearly identified. Note: While a totalSupply of 1 might mean the
 * corresponding is an NFT, there is no guarantees that no other token with the
 * same id are not going to be minted.
 */
abstract contract ERC1155Supply is ERC1155 {
    mapping(uint256 => uint256) private _totalSupply;

    /**
     * @dev Total amount of tokens in with a given id.
     */
    function totalSupply(uint256 id) public view virtual returns (uint256) {
        return _totalSupply[id];
    }

    /**
     * @dev Indicates whether any token exist with a given id, or not.
     */
    function exists(uint256 id) public view virtual returns (bool) {
        return ERC1155Supply.totalSupply(id) > 0;
    }

    /**
     * @dev See {ERC1155-_beforeTokenTransfer}.
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        if (from == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                _totalSupply[ids[i]] += amounts[i];
            }
        }

        if (to == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                uint256 id = ids[i];
                uint256 amount = amounts[i];
                uint256 supply = _totalSupply[id];
                require(supply >= amount, "ERC1155: burn amount exceeds totalSupply");
                unchecked {
                    _totalSupply[id] = supply - amount;
                }
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./OrderDeriver.sol";
import "./NonceManager.sol";

abstract contract OrderValidator is NonceManager, OrderDeriver {
    mapping(bytes32 => OrderStatus) public ordersStatus;

    /**
     * @dev verify order info
     */
    function validateOrder(
        FixedPriceOrder calldata _makerOrder,
        bytes calldata _makerSig,
        address _taker
    )
    internal
    view
    returns (
        bytes memory assetsBytes,
        bytes32 orderHash,
        bytes memory orderBytes
    )
    {
        (, assetsBytes, orderHash, orderBytes) = deriveOrder(_makerOrder);

        // 恢复签名地址，判断是否是买方签名
        address maker = recover(orderHash, _makerSig);

        require (maker == _makerOrder.maker,"signMatchError");

        // 验证订单是否已经取消
        require (!ordersStatus[orderHash].cancelled,"OrderIsCancelled");


        // 如果taker为""的话,说明没有指定购买人
        require ((_makerOrder.taker == address(0)) || (_makerOrder.taker != address(0) && _makerOrder.taker == _taker),"SpecialTakerNotMatch");

        // 校验订单开启时间
        require (_makerOrder.startAt <= block.timestamp,"OrderNotReady");

        // 校验订单过期时间
        require (_makerOrder.expireAt >= block.timestamp,"OrderIsExpired");

        //卖家不能购买自己的订单
        require (maker != _taker,"TakerEqualsMaker");

    }

    function recover(bytes32 _hash, bytes calldata _signature)
    internal
    pure
    virtual
    returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../interfaces/IConduit.sol";

import "../interfaces/ILazyMint.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "@openzeppelin/contracts/interfaces/IERC2981.sol";

import "./DEXConstantsAndStructs.sol";

//  erc20   =》 erc 721
//  erc20   =》 erc 1155
//  eth     =》 erc 721
//  eth     =》 erc  1155

//  erc721  =》 erc 20
//  erc1155 =》 erc 20
abstract contract TransferHelper is DEXConstantsAndStructs {

    /**
     * @dev transfer nft
     */
    function transferNFT(
        FixedPriceOrder calldata _order,
        address _nftOwner,
        address _nftRecipient,
        uint256 nftAmount,
        uint256 ftAmount
    ) internal {
        // erc1155 transfer
        if (_order.assets.nftAmount > 0) {
            transferERC1155(
                _order.assets.nft,
                _nftOwner,
                _nftRecipient,
                _order.assets.nftId,
                nftAmount,
                _order.royaltyRecipient,
                ftAmount,
                _order.royaltyRate
            );

            return;
        }
        // erc721 transfer
        transferERC721(
            _order.assets.nft,
            _nftOwner,
            _nftRecipient,
            _order.assets.nftId,
            _order.royaltyRecipient,
            ftAmount,
            _order.royaltyRate
        );
    }

    /**
     * @dev erc721 transfer
     */
    function transferERC721(
        address _nftContract,
        address _nftOwner,
        address _nftRecipient,
        uint256 _nftId,
        address _royaltyRecipient,
        uint256 _ftAmount,
        uint256 _royaltyRate
    ) internal {
        try IERC721(_nftContract).supportsInterface(type(IERC165).interfaceId) returns (
            bool isERC165
        ) {
            if (
                isERC165 &&
                isPlatformNft(_nftContract) &&
                IERC165(_nftContract).supportsInterface(type(ILazyMint).interfaceId) &&
                !ILazyMint(_nftContract).exists(_nftId)
            ) {
                ILazyMint(_nftContract).lazyMint(
                    _nftRecipient,
                    _nftId,
                    _royaltyRecipient,
                    _royaltyRate
                );
                return;
            }

            if (isERC165 && IERC165(_nftContract).supportsInterface(type(IERC2981).interfaceId)) {
                checkRoyaltyInfo(
                    IERC2981(_nftContract),
                    _ftAmount,
                    _nftId,
                    _royaltyRecipient,
                    _royaltyRate
                );
            }
        } catch {}

        _transferFrom(_nftContract, _nftOwner, _nftRecipient, _nftId);
    }

    /**
     * @dev erc1155 transfer
     */
    function transferERC1155(
        address _nftContract,
        address _nftOwner,
        address _nftRecipient,
        uint256 _nftId,
        uint256 _nftAmount,
        address _royaltyRecipient,
        uint256 _ftAmount,
        uint256 _royaltyRate
    ) internal {
        try IERC1155(_nftContract).supportsInterface(type(IERC165).interfaceId) returns (
            bool isERC165
        ) {
            if (isERC165 && IERC165(_nftContract).supportsInterface(type(IERC2981).interfaceId)) {
                checkRoyaltyInfo(
                    IERC2981(_nftContract),
                    _ftAmount,
                    _nftId,
                    _royaltyRecipient,
                    _royaltyRate
                );
            }
        } catch {}

        _safeTransferFromERC1155(_nftContract, _nftOwner, _nftRecipient, _nftId, _nftAmount);
    }

    /**
     * @dev verify info
     */
    function checkRoyaltyInfo(
        IERC2981 _nftContract,
        uint256 _ftAmount,
        uint256 _nftId,
        address _royaltyRecipient,
        uint256 _royaltyRate
    ) internal view {
        //版税金额=总金额*P(符号P为手续费比例,P=版税分子/基础分母)
        uint256 royaltyAmount = (_ftAmount * _royaltyRate) / _feeDenominator();

        (address royaltyRecipientIERC2981, uint256 royaltyAmountIERC2981) = _nftContract
        .royaltyInfo(_nftId, _ftAmount);

        if (royaltyAmountIERC2981 != 0 || royaltyRecipientIERC2981 != address(0)) {
            require(_royaltyRecipient == royaltyRecipientIERC2981 && royaltyAmount >= royaltyAmountIERC2981, "OrderRoyaltyNotMatchIERC2981");
        }
    }

    /**
     * @dev transfer token
     */
    function transferFT(
        FixedPriceOrder calldata _makerOrder,
        address _ftOwner,
        address _ftRecipient,
        uint256 _ftAmount
    ) internal {
        uint256 feeDenominator = _feeDenominator();
        address feeRecipient = _feeRecipient();
        uint256 _royaltyRate = _makerOrder.royaltyRate;
        address _royaltyRecipient = _makerOrder.royaltyRecipient;

        //_ftAmount要包含版税+平台费用在里面的
        uint256 royaltyAmount = (_ftAmount * _royaltyRate) / feeDenominator;

        uint256 platformAmount = (_ftAmount * _feeRate()) / feeDenominator;

        uint256 payAmount = _ftAmount + royaltyAmount + platformAmount;

        uint256 msgVal = msg.value;
        address _ftContract = _makerOrder.assets.ft;
        //假如是token代币
        if (_ftContract != address(0)) {
            require(msgVal > 0, "token coin-ExtraMsgValue");
            //转账版税
            _transferFrom(_ftContract, _ftOwner, _royaltyRecipient, royaltyAmount);
            //平台抽成
            _transferFrom(_ftContract, _ftOwner, feeRecipient, platformAmount);
            //转给卖家
            _transferFrom(_ftContract, _ftOwner, _ftRecipient, payAmount);
            return;
        }
        //假如是平台代币
        require(msgVal >= payAmount, "origin coin-NotEnoughMsgValue");

        if (msgVal > payAmount) {
            sendValue(payable(msg.sender), msgVal - payAmount);
        }
        //转账版税
        sendValue(payable(_royaltyRecipient), royaltyAmount);
        //平台抽成
        sendValue(payable(feeRecipient), platformAmount);
        //转给卖家
        sendValue(payable(_ftRecipient), _ftAmount);
    }

    // 授权转移
    function _transferFrom(
        address _tokenContract,
        address _tokenOwner,
        address _tokenRecipient,
        uint256 _tokenIdOrAmount
    ) internal {
        bytes memory callData = abi.encodeWithSignature(
            "transferFrom(address,address,uint256)", //function transferFrom(address from, address to, uint256 amount) external returns (bool)
            _tokenOwner,
            _tokenRecipient,
            _tokenIdOrAmount
        );

        (bool result,) = address(_tokenContract).call(callData);
        require(result, "_transferFrom Error");
    }

    // 授权转移
    function _safeTransferFromERC1155(
        address _tokenContract,
        address _tokenOwner,
        address _tokenRecipient,
        uint256 _tokenId,
        uint256 _tokenAmount
    ) internal {
        bytes memory callData = abi.encodeWithSignature(
        //safeTransferFrom(address from,address to,uint256 id,uint256 amount,bytes memory data)
            "safeTransferFrom(address,address,uint256,uint256,bytes)",
            _tokenOwner,
            _tokenRecipient,
            _tokenId,
            _tokenAmount,
            ""
        );
        //address(nameReg).call.gas(1000000).value(1 ether)(abi.encodeWithSignature("register(string)", "MyName"));
        (bool result,) = address(_tokenContract).call(callData);
        require(result, "_safeTransferFrom Error");
    }

    /**
     * @dev send eth
     */
    function sendValue(address payable _recipient, uint256 _amount) internal {
        require(address(this).balance >= _amount, "InsufficientBalance");
        (bool success,) = _recipient.call{value : _amount}("");
        require(success, "UnableSendValue");
    }


    function isPlatformNft(address _nft) internal view virtual returns (bool);

    function _feeRate() internal view virtual returns (uint256);

    function _feeRecipient() internal view virtual returns (address);

    function _feeDenominator() internal view virtual returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IConduit {

    function call(address target, bytes memory data)
        external
        payable
        returns (bool status, bytes memory ret);

    function assertCall(address target, bytes memory data)
        external
        payable
        returns (bool status, bytes memory ret);

    function transferOwnership(address newOwner) external ;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {EIP712} from "./EIP712.sol";


import "../interfaces/DEXEventsAndErrors.sol";
import "./Manager.sol";


contract DEXConfig is EIP712, DEXEventsAndErrors, Manager {

    //平台手续费分子
    uint256 public feeRate;
    //手续费分母
    uint256 public feeDenominator;
    //手续费接收地址
    address public feeRecipient;

    constructor(address _daoAddr, address _feeRecipient, string memory _name, string memory _version, uint256 _chainId)
    EIP712(_name, _version, _chainId)
    Manager(_daoAddr) {
        feeRecipient = _feeRecipient;
        feeDenominator = 100_000_000;
        feeRate = 2_000_000;
        //平台默认手续费分子
        //实际平台手续费为=feeRate/feeDenominator=0.02
    }

    //设置费用接受者地址
    function setFeeRecipient(address _feeRecipient) external onlyDAO {
        require(_feeRecipient != address(0), "ZeroAddress");

        feeRecipient = _feeRecipient;
    }

    //设置平台手续费分子
    function setFeeRate(uint256 _feeRate) external onlyDAO {
        require(_feeRate <= feeDenominator, "TooHighFeeRate");
        feeRate = _feeRate;
    }

    //设置分母
    function setFeeDenominator(uint256 _feeDenominator) external onlyDAO {
        require(_feeDenominator <= feeDenominator, "TooHighDenominator");
        feeDenominator = _feeDenominator;
    }
    //设置分子分母
    function setAllFee(uint256 _feeRate, uint256 _feeDenominator) external onlyDAO {
        feeRate = _feeRate;
        feeDenominator = _feeDenominator;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./DEXConstantsAndStructs.sol";

interface FakeStyleCreate {
    function getSaleOrderIdPrice(uint256 saleOrderId, uint256 nftId) external view returns (uint256);
}

//订单帮助合约，主要用来处理限价单和线下磋商
contract OrderHelper is DEXConstantsAndStructs {
    //maker给指定的地址设置限定价格
    mapping(uint256 => mapping(address => LimitPrice)) private _allowedPayment;

    //查询使用价格
    function getUsePrice(uint256 saleOrderId, address nft, uint256 nftId, uint256 firstPrice) internal view returns (uint256) {
        //查询设置价格
        uint256 queryPrice = FakeStyleCreate(nft).getSaleOrderIdPrice(saleOrderId, nftId);

        uint256 usePrice = 0;

        //如果查询价格为0，那么使用初始化订单的价格
        if (queryPrice == 0) {
            usePrice = firstPrice;
        }

        //价格必须大于0
        require(usePrice > 0, "price must gt 0");

        return usePrice;
    }

    //maker指定某些地址可以按照限价单的单价(approvalPrice)购买指定的数量(approvalNumber)
    function setPaymentsAllowed(address[] calldata _payments, LimitPrice[] calldata _limitPrices)
    external
    {
        address maker = msg.sender;
        for (uint256 i = 0; i < _payments.length; i++) {
            LimitPrice memory limitPrice = _limitPrices[i];
            address _maker = limitPrice.maker;
            require(maker == _maker, "maker address isn't matched");
            uint256 saleOrderId = limitPrice.saleOrderId;
            address taker = limitPrice.taker;
            _allowedPayment[saleOrderId][taker] = limitPrice;
        }
    }
    //maker取消某些地址授权购买
    function cancelPaymentsAllowed(address[] calldata _payments, LimitPrice[] calldata _limitPrices)
    external
    {
        address maker = msg.sender;
        for (uint256 i = 0; i < _payments.length; i++) {
            LimitPrice memory limitPrice = _limitPrices[i];
            address _maker = limitPrice.maker;
            require(maker == _maker, "maker address isn't matched");
            uint256 saleOrderId = limitPrice.saleOrderId;
            address taker = limitPrice.taker;
            delete _allowedPayment[saleOrderId][taker];
        }
    }

    //控制购买数据
    function speicalSale(uint256 saleOrderId, uint256 buyNftNumber, address taker, uint currentPrice) internal returns (bool, uint256){
        uint256 _ftAmount = 0;
        //查询是否是限价单或者指定的价格售卖
        LimitPrice memory limitPrice = queryCanPayment(saleOrderId, taker);
        if (limitPrice.approvalNumber == 0) {
            return (false, 0);
        }
        if (buyNftNumber > limitPrice.approvalNumber) {
            uint256 approvalAmount = limitPrice.approvalNumber * limitPrice.approvalPrice;
            uint256 overNumber = buyNftNumber - limitPrice.approvalNumber;
            uint256 overAmount = overNumber * currentPrice;
            _ftAmount = approvalAmount + overAmount;
            //清空购买数据
            delete _allowedPayment[saleOrderId][taker];
        } else {
            uint256 approvalAmount = limitPrice.approvalNumber * limitPrice.approvalPrice;
            _ftAmount = approvalAmount;
            _allowedPayment[saleOrderId][taker].approvalNumber -= buyNftNumber;
        }
        return (true, _ftAmount);
    }

    function queryCanPayment(uint256 saleOrderId, address taker) public view returns (LimitPrice memory) {
        return _allowedPayment[saleOrderId][taker];
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.3) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./DEXConstantsAndStructs.sol";


abstract contract OrderDeriver is DEXConstantsAndStructs {

    // 订单信息处理，打包资产信息（结构体）为十六进制数据
    function hashAssets(Assets calldata assets) internal pure returns (bytes32, bytes memory) {
        bytes memory assetsBytes = abi.encode(
            AssetsStructHash,
            assets.nft,
            assets.nftId,
            assets.nftAmount,
            assets.ft,
            assets.firstPrice,
            assets.firstFtAmount
        );
        bytes32 hash = keccak256(assetsBytes);
        return (hash, assetsBytes);
    }

    // https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct
    function eip712Encode(FixedPriceOrder calldata _order, bytes32 _assetsHash)
    internal
    pure
    returns (bytes memory orderBytes)
    {
        orderBytes = abi.encode(
            OrderStructHash,
            _order.maker,
            _order.taker,
            _order.royaltyRecipient,
            _order.royaltyRate,
            _order.startAt,
            _order.expireAt,
            _order.saleOrderId,
            _assetsHash
        );
    }

    function deriveOrder(FixedPriceOrder calldata _order)
    internal
    view
    returns (
        bytes32 assetsHash,
        bytes memory assetsBytes,
        bytes32 orderHash,
        bytes memory orderBytes
    )
    {
        (assetsHash, assetsBytes) = hashAssets(_order.assets);

        orderBytes = eip712Encode(_order, assetsHash);

        orderHash = hashOrder(orderBytes);
    }

    function hashOrder(bytes memory orderBytes) internal view virtual returns (bytes32);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


contract NonceManager {
    // Only orders signed using an offerer's current nonce are fulfillable.
    mapping(address => uint256) private nonce_;

    function _increaseNonce(address _address) internal returns (uint256 newNonce) {
        // Skip overflow check as counter cannot be incremented that far.
        unchecked {
            newNonce = ++nonce_[_address];
        }
    }

    function _nonce(address _address) internal view returns (uint256 currentNonce) {
        currentNonce = nonce_[_address];
    }

    function nonce(address _address) external view virtual returns (uint256 currentNonce) {
        currentNonce = _nonce(_address);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../interfaces/DEXEventsAndErrors.sol";

abstract contract DEXConstantsAndStructs is DEXEventsAndErrors {
    bytes32 public constant OrderStructHash =
    keccak256(
        "FixedPriceOrder(address maker,address taker,address royaltyRecipient,uint256 royaltyRate,uint64 startAt,uint64 expireAt,uint256 saleOrderId,Assets assets)Assets(address nft,uint256 nftId,uint256 nftAmount,address ft,uint256 firstPrice,uint256 firstFtAmount)"
    );

    bytes32 public constant AssetsStructHash =
    keccak256(
        "Assets(address nft,uint256 nftId,uint256 nftAmount,address ft,uint256 firstPrice,uint256 firstFtAmount)"
    );

    // 订单状态
    struct OrderStatus {
        bool matched;   // 是否已经匹配
        bool cancelled; // 是否取消
    }

    // 订单信息
    struct FixedPriceOrder {
        // 卖方地址
        address maker;
        // 买方地址
        address taker;
        // 版税者地址
        address royaltyRecipient;
        // 版税手续费
        uint256 royaltyRate;
        // 开始时间
        uint64 startAt;
        // 订单过期时间
        uint64 expireAt;
        //订单号
        uint256 saleOrderId;
        // 资产信息
        Assets assets;
    }

    //资产数据
    struct Assets {
        // nft合约地址
        address nft;
        // nft token id
        uint256 nftId;
        // 0 is ERC721, gt 0 is ERC1155
        uint256 nftAmount;
        // 代币地址 address(0)=0x000000000000000000000000000000000 0地址硬编码代表eth原生币
        address ft;
        //初始化单价
        uint256 firstPrice;
        //初始化ftAmount
        uint256 firstFtAmount;
    }

    //taker的信息
    struct TakerInfo {
        //订单号
        uint256 saleOrderId;
        //购买数量
        uint256 buyNftNumber;
        //token代币总量,如果为0，那么识别为平台代币支付
        uint256 tokenAmount;

    }

    //限价单
    struct LimitPrice {
        //卖方地址
        address maker;
        //买方地址
        address taker;
        //订单号
        uint256 saleOrderId;
        //批准的个数
        uint256 approvalNumber;
        //批准的价格
        uint256 approvalPrice;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
 * @title DEXEventsAndErrors
 * @notice DEXEventsAndErrors contains all events and errors.
 */
interface DEXEventsAndErrors {
    event OrderCancelled(address indexed maker,uint256 indexed saleOrderId, bytes32 orderHash);

    event AllOrdersCancelled(address indexed offerer, uint256 increasedNonce);

    event FixedPriceOrderMatched(
        address indexed maker,
        address indexed taker,
        uint256 indexed saleOrderId,
        uint256 buyNftNumber,
        bytes32 orderHash,
        bytes orderBytes,
        bytes assetsBytes
    );

    event SetDao(address _dao, bool _isOperator);

    event UpdateConduitController(address _conduitController);

    event SetOperators(address _address, bool _flag);

    event SetPlatformDex(address _address, bool _flag);

    event Received(address indexed sender, uint value);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface ILazyMint is IERC165 {
    function exists(uint256 tokenId) external view returns (bool);

    function lazyMint(
        address to,
        uint256 tokenId,
        address royaltyRecipient,
        uint256 royaltyRate
    ) external;

    function setRoyaltyInfo(
        uint256 tokenId,
        address receiver,
        uint256 royaltyRate
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (interfaces/IERC2981.sol)

pragma solidity ^0.8.0;

import "../utils/introspection/IERC165.sol";

/**
 * @dev Interface for the NFT Royalty Standard.
 *
 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
 * support for royalty payments across all NFT marketplaces and ecosystem participants.
 *
 * _Available since v4.5._
 */
interface IERC2981 is IERC165 {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
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
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 *
 * @custom:storage-size 52
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    string private _NAME;
    string private _VERSION;
    uint256 private _CHAINID;
    bytes32 private _HASHED_NAME;
    bytes32 private _HASHED_VERSION;
    bytes32 private constant _TYPE_HASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
    constructor(string memory _name, string memory _version,uint256 _chainId) {
        _NAME = _name;
        _VERSION = _version;
        _CHAINID = _chainId;
        _HASHED_NAME = keccak256(bytes(_name));
        _HASHED_VERSION = keccak256(bytes(_version));
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        return _buildDomainSeparator(_TYPE_HASH, _EIP712NameHash(), _EIP712VersionHash(),chainId());
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash,
        uint256 chainId
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, chainId, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    /**
     * @dev The hash of the name parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712NameHash() internal view virtual returns (bytes32) {
        return _HASHED_NAME;
    }

    /**
     * @dev The hash of the version parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712VersionHash() internal view virtual returns (bytes32) {
        return _HASHED_VERSION;
    }

    function version() public view virtual returns (string memory) {
        return _VERSION;
    }

    function name() public view virtual returns (string memory) {
        return _NAME;
    }

    function chainId() public view virtual returns (uint256) {
        return _CHAINID;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IManager {

    function operators(address addr) external view returns (bool);

    function dao() external view returns (address);

    function platformDex(address addr) external view returns (bool);

    function platformNft(address addr) external view returns (bool);

    function allowedNft(address addr) external view returns (bool);

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
                /// @solidity memory-safe-assembly
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/IERC1155MetadataURI.sol)

pragma solidity ^0.8.0;

import "../IERC1155.sol";

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}