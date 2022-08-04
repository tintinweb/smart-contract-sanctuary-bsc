/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

// SPDX-License-Identifier: MIT
// File: NFT/IPancakeRouter01.sol


pragma solidity >=0.6.2;

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// File: NFT/IPancakeRouter02.sol


pragma solidity >=0.6.2;


interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// File: NFT/ERC1155Interface.sol


pragma solidity 0.8.7;

interface ERC1155Interface {
    function creators(uint256) external pure returns (address);

    function balanceOf(address account, uint256 id) external view returns (uint256);
    function exists(uint256 _id) external view returns (bool);
    function create(address _initialOwner, uint256 _id, uint256 _initialSupply, string memory _uri, bytes memory _data) external returns (uint256);
    function setCreator(address _to, uint256[] memory _ids) external;
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;
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

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;



/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}

// File: @openzeppelin/contracts/utils/Counters.sol


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
library Counters {
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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: NFT/HodlFactory.sol



pragma solidity 0.8.7;







contract HodlFactory is Ownable,ERC1155Receiver {
    using Counters for Counters.Counter;

    struct SaleInfo {
        uint256 tokenId;
        string tokenHash;
        uint256 createdTime;
        address creator;
        address currentOwner;
        uint256 salePrice;
    }

    struct RoyaltyInfo {
        uint256 totalPercent;
        uint256 rewardPercent;
        uint256 liquidityPercent;
        uint256 teamPercent;
        uint256 marketingPercent;
        uint256 tradingPercent;
    }

    struct RoyaltyAddressInfo {
        address payable marketingAddress;
        address payable teamAddress;
    }

    struct NFTCardInfo {
        string symbol;
        string imgUri;
        uint256 priceUSDT;
        uint256 nftROI;
        uint256 nftTOKEN;
        uint256 supply;
        uint256 soldCount;
        bool state;
    }

    struct NFTRewardCardInfo {
        uint256 createdTime;
        uint256 claimedTime;
    }

    struct NFTInfos {
        string[] symbols;
        uint256[] tokenIDs;
        uint256[] tokenPrices;
        string[] uris;
        uint256[] createdTime;
        bool[] canStable;
        uint256[] nftUSDT;
        uint256[] nftHODL;
    }
    
    bool _status;
    bool _pauseService;

    uint256 _maxTokenId;
    address mkNFTaddress;
    ERC1155Interface mkNFT;
    
    RoyaltyInfo public royaltyInfo;
    RoyaltyAddressInfo public addressInfo;
    IPancakeRouter02 public _pancakeRouter;
    
    IERC20 private _usdtToken;
    IERC20 private _hodlToken;
    uint256 constant ONE_DAY_TIME                               = 86400;
    uint256 MINT_START_TIME                                     = ~uint256(0);
    
    NFTCardInfo[] _allCardInfos;
    SaleInfo[] _allSaleInfo;
    mapping(uint256 => uint256) public _allTokenIDToIndex;
    mapping(uint256 => NFTRewardCardInfo) public _NFTRewardCardInfos;
    mapping(address => uint256[]) public _nftIDsOfUser;

    mapping(uint256 => uint) public _getCIDFromID;
    mapping(uint256 => string) public _uriFromId;

    modifier onlyNFTSeller(uint256 _tokenID) {
        uint256 _tokenIndex = _allTokenIDToIndex[_tokenID];
        require(_allSaleInfo[_tokenIndex].currentOwner == msg.sender || owner() == msg.sender, "No NFT seller");
        _;
    }

    modifier onlyNFTOwner(uint256 _tokenID) {
        require(mkNFT.balanceOf(msg.sender, _tokenID) > 0, "No NFT owner");
        _;
    }

    modifier nonReentrant() {
        require(_status != true, "ReentrancyGuard: reentrant call");
        _status = true;
        _;
        _status = false;
    }

    constructor(address _nftAddress, address _hodl) {
        mkNFTaddress = _nftAddress;
        mkNFT = ERC1155Interface(_nftAddress);
        _usdtToken = IERC20(0x55d398326f99059fF775485246999027B3197955);
        _pancakeRouter = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _hodlToken = IERC20(_hodl);

        _status = false;
        _pauseService = false;
        _maxTokenId = 0;

        royaltyInfo.totalPercent = 1000;
        royaltyInfo.rewardPercent = 700;
        royaltyInfo.liquidityPercent = 200;
        royaltyInfo.teamPercent = 50;
        addressInfo.teamAddress = payable(0x935C0b053a120Ed058004984c59705a3F2b3Fa0c);
        royaltyInfo.marketingPercent = 50;
        addressInfo.marketingAddress = payable(0x3E5B36d93e8b0CEAdF33BFD4394a0D7d5576811C);
        royaltyInfo.tradingPercent = 50;
    }

    function _createOrMint(
        address nftAddress,
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes memory _data
    ) internal {
        ERC1155Interface tradable = ERC1155Interface(nftAddress);

        require(!tradable.exists(_id), "Already exist id");
        tradable.create(_to, _id, _amount, "", _data);

        uint256[] memory ids = new uint256[](1);
        ids[0] = _id;
        tradable.setCreator(_to, ids);
    }

    function setNFTCardInfo (uint _id, string memory _symbol, string memory _uri, uint256 _usdt, uint256 _roi, uint256 _token, uint256 _sup) external onlyOwner {
        require(_allCardInfos.length > _id, "Not Exsiting Info");
        _allCardInfos[_id].symbol = _symbol;
        _allCardInfos[_id].imgUri = _uri;
        _allCardInfos[_id].priceUSDT = _usdt;
        _allCardInfos[_id].nftROI = _roi;
        _allCardInfos[_id].nftTOKEN = _token;
        _allCardInfos[_id].supply = _sup;

        emit SetNFTCardInfo (msg.sender, _id, _uri, _usdt, _sup);
    }

    function addNFTCardInfo (string memory _symbol, string memory _uri, uint256 _usdt, uint256 _roi, uint256 _token, uint256 _sup) external onlyOwner {
        _allCardInfos.push (NFTCardInfo({symbol: _symbol, imgUri: _uri, priceUSDT: _usdt, nftROI: _roi, nftTOKEN: _token, supply: _sup, soldCount: 0, state: false}));

        emit AddNFTCardInfo (msg.sender, _symbol, _uri, _usdt, _roi, _sup);
    }

    function setCardState (uint _id, bool _state) external onlyOwner {
        require(_allCardInfos.length > _id, "Not Exsiting Info");
        _allCardInfos[_id].state = _state;

        emit SetCardState (_id, _state);
    }

    function getNFTCardInfos () external view returns (NFTCardInfo[] memory) {
        return _allCardInfos;
    }

    function mintSingleNFT (uint _cid) internal {
        _createOrMint(mkNFTaddress, msg.sender, _maxTokenId, 1, "");
        _getCIDFromID[_maxTokenId] = _cid;
        _setTokenUri(_maxTokenId, _allCardInfos[_cid].imgUri);
        _NFTRewardCardInfos[_maxTokenId] = NFTRewardCardInfo({ createdTime: block.timestamp, claimedTime: block.timestamp});
        _nftIDsOfUser[msg.sender].push(_maxTokenId);
        _maxTokenId++;
    }

    function mintNFTs (uint _id, uint256 _count) external {
        require(_pauseService == false, "Service is stopped.");
        require(_allCardInfos.length > _id, "No Exsiting Info");
        require(MINT_START_TIME < block.timestamp, "No Mint Time");
        require(_allCardInfos[_id].soldCount + _count < _allCardInfos[_id].supply, "No NFT for Mint");

        uint256 mintUSDT = _allCardInfos[_id].priceUSDT;
        if (MINT_START_TIME + 60 * 60 * 24 * 2 > block.timestamp) {
            mintUSDT = mintUSDT * 950 / 1000;           // 95%
        }
        else if (MINT_START_TIME + 60 * 60 * 24 * 4 > block.timestamp) {
            mintUSDT = mintUSDT * 975 / 1000;           // 97.5%
        }
        uint256 swapAmount = mintUSDT * royaltyInfo.liquidityPercent / royaltyInfo.totalPercent;
        require(_usdtToken.balanceOf(msg.sender) >= mintUSDT, "No enough USDT amounts");
        _usdtToken.transferFrom (msg.sender, address(this), mintUSDT * (royaltyInfo.rewardPercent + royaltyInfo.liquidityPercent) / royaltyInfo.totalPercent);
        _usdtToken.transferFrom (msg.sender, addressInfo.teamAddress, mintUSDT * royaltyInfo.teamPercent / royaltyInfo.totalPercent);
        _usdtToken.transferFrom (msg.sender, addressInfo.marketingAddress, mintUSDT * royaltyInfo.marketingPercent / royaltyInfo.totalPercent);

        swapAndLiquidy(swapAmount);

        for (uint256 i = 0; i < _count; i ++) {
            mintSingleNFT(_id);
            emit MintSingleNFT (msg.sender, _id, _maxTokenId - 1);
        }

        _allCardInfos[_id].soldCount += _count;

        emit MintNFTs(msg.sender, _id, _count);
    }

    function swapUSDTtoHODL(uint256 _usdt) private {
        address[] memory path = new address[](2);
        path[0] = address(_usdtToken);
        path[1] = address(_hodlToken);

        _usdtToken.approve(address(_pancakeRouter), _usdt);
        _pancakeRouter.swapExactTokensForTokens(
            _usdt,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    
    function swapAndLiquidy(uint256 _usdt) private {
        uint256 half = _usdt / 2;
        uint256 otherHalf = _usdt - half;
        uint256 initialBalance = _hodlToken.balanceOf(address(this));

        swapUSDTtoHODL(half);

        uint256 newBalance = _hodlToken.balanceOf(address(this)) - initialBalance;

        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquidy(half, newBalance, otherHalf);
    }

    function addLiquidity(uint256 usdtAmount, uint256 tokenAmount) private {
        // approve token transfer to cover all possible scenarios
        _usdtToken.approve(address(_pancakeRouter), usdtAmount);
        _hodlToken.approve(address(_pancakeRouter), tokenAmount);

        // add the liquidity
        _pancakeRouter.addLiquidity(
            address(_usdtToken),
            address(_hodlToken),
            usdtAmount,
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    function canReceiveStable(uint256 _nftID) view private returns(bool) {
        uint256 nftCreatedTime = _NFTRewardCardInfos[_nftID].createdTime;
        uint256 nftROI = _allCardInfos[_getCIDFromID[_nftID]].nftROI;

        uint256 wholeReturnDays = 10000 / nftROI;
        if (block.timestamp - nftCreatedTime <= ONE_DAY_TIME * wholeReturnDays) {
            return true;
        }
        else {
            return false;
        }
    }

    function getRewardInfoByNFT(uint256 _nftID) view private returns(uint256, uint256){
        uint256 nftCreatedTime = _NFTRewardCardInfos[_nftID].createdTime;
        uint256 nftClaimedTime = _NFTRewardCardInfos[_nftID].claimedTime;
        uint256 nftPrice = _allCardInfos[_getCIDFromID[_nftID]].priceUSDT;
        uint256 nftROI = _allCardInfos[_getCIDFromID[_nftID]].nftROI;
        uint256 nftTOKEN = _allCardInfos[_getCIDFromID[_nftID]].nftROI;

        if (mkNFT.balanceOf(msg.sender, _nftID) <= 0) return (0, 0);

        uint256 rewardCoinAmount = 0;
        uint256 rewardTokenAmount = 0;
        uint256 wholeReturnDays = 10000 / nftROI;
        if (block.timestamp - nftCreatedTime <= ONE_DAY_TIME * wholeReturnDays) {
            rewardCoinAmount += (block.timestamp - nftClaimedTime) * nftPrice * nftROI / 10000 / ONE_DAY_TIME;
        }
        else if (block.timestamp - nftCreatedTime <= ONE_DAY_TIME * 365 * 2) {
            if (nftCreatedTime + ONE_DAY_TIME * wholeReturnDays >= nftClaimedTime) {
                rewardCoinAmount += (nftCreatedTime + ONE_DAY_TIME * wholeReturnDays - nftClaimedTime) * nftPrice * nftROI / 10000 / ONE_DAY_TIME;
            }

            rewardTokenAmount = (block.timestamp - nftCreatedTime - ONE_DAY_TIME * wholeReturnDays) * nftTOKEN / ONE_DAY_TIME;
        }

        return (rewardCoinAmount, rewardTokenAmount);
    }

    function claimByNFT(uint256 _tokenID) external onlyNFTOwner(_tokenID) {
        require(_pauseService == false, "Service is stopped.");
        require(_maxTokenId > _tokenID, "Not existing NFT token");

        // add rewards and initialize timestamp for all enabled nodes
        (uint256 nftCoinReward, uint256 nftTokenReward) = getRewardInfoByNFT(_tokenID);
        _NFTRewardCardInfos[_tokenID].claimedTime = block.timestamp;
        
        // send usdt rewards of nodeId to msg.sender
        require(nftCoinReward > 0 || nftTokenReward > 0, "There is no rewards.");
        require(_usdtToken.balanceOf(address(this)) > nftCoinReward, "no enough balance on usdt");
        require(_hodlToken.balanceOf(address(this)) > nftTokenReward, "no enough balance on hodl");

        if (nftCoinReward > 0) {
            _usdtToken.transfer(msg.sender, nftCoinReward * (royaltyInfo.totalPercent - royaltyInfo.tradingPercent) / royaltyInfo.totalPercent);
            _usdtToken.transfer(addressInfo.teamAddress, nftCoinReward * royaltyInfo.tradingPercent / royaltyInfo.totalPercent);
        }
        if (nftTokenReward > 0) {
            _hodlToken.transfer(msg.sender, nftTokenReward * (royaltyInfo.totalPercent - royaltyInfo.tradingPercent) / royaltyInfo.totalPercent);
            _hodlToken.transfer(addressInfo.teamAddress, nftTokenReward * royaltyInfo.tradingPercent / royaltyInfo.totalPercent);
        }
        
        emit ClaimByNFT(msg.sender, _tokenID, nftCoinReward * royaltyInfo.tradingPercent / royaltyInfo.totalPercent, nftTokenReward * royaltyInfo.tradingPercent / royaltyInfo.totalPercent);
    }

    function claimAll() external {
        require(_pauseService == false, "Service is stopped.");
        uint256 nftCount = _nftIDsOfUser[msg.sender].length;
                
        uint256 usdts = 0;
        uint256 hodls = 0;
        for(uint i=0; i<nftCount; i++) {
            (uint256 usdt, uint256 hodl) = getRewardInfoByNFT(_nftIDsOfUser[msg.sender][i]);
            usdts += usdt;
            hodls += hodl;
            
            _NFTRewardCardInfos[_nftIDsOfUser[msg.sender][i]].claimedTime = block.timestamp;
        }

        // send usdt rewards to msg.sender
        require(usdts > 0 || hodls > 0, "There is no rewards.");
        require(_usdtToken.balanceOf(address(this)) > usdts, "no enough usdt balance on reward pool");
        require(_hodlToken.balanceOf(address(this)) > hodls, "no enough hodl balance on reward pool");
        
        if (usdts > 0) {
            _usdtToken.transfer(msg.sender, usdts * (royaltyInfo.totalPercent - royaltyInfo.tradingPercent) / royaltyInfo.totalPercent);
            _usdtToken.transfer(addressInfo.teamAddress, usdts * royaltyInfo.tradingPercent / royaltyInfo.totalPercent);
        }
        if (hodls > 0) {
            _hodlToken.transfer(msg.sender, hodls * (royaltyInfo.totalPercent - royaltyInfo.tradingPercent) / royaltyInfo.totalPercent);
            _hodlToken.transfer(addressInfo.teamAddress, hodls * royaltyInfo.tradingPercent / royaltyInfo.totalPercent);
        }

        emit ClaimAllNFT(msg.sender, usdts * royaltyInfo.tradingPercent / royaltyInfo.totalPercent, hodls * royaltyInfo.tradingPercent / royaltyInfo.totalPercent);
    }

    function getAllNFTInfos () view external returns (NFTInfos memory){
        uint256[] memory nftIDs = _nftIDsOfUser[msg.sender];
        NFTInfos memory rwInfo;
        rwInfo.symbols = new string[](nftIDs.length);
        rwInfo.tokenIDs = new uint256[](nftIDs.length);
        rwInfo.tokenPrices = new uint256[](nftIDs.length);
        rwInfo.uris = new string[](nftIDs.length);
        rwInfo.createdTime = new uint256[](nftIDs.length);
        rwInfo.canStable = new bool[](nftIDs.length);
        rwInfo.nftUSDT = new uint256[](nftIDs.length);
        rwInfo.nftHODL = new uint256[](nftIDs.length);

        uint256 rwIndex = 0;
        for(uint i=0; i<nftIDs.length; i++) {
            uint256 nftID = _nftIDsOfUser[msg.sender][i];
            if (mkNFT.balanceOf(msg.sender, nftID) <= 0) continue;

            rwInfo.symbols[rwIndex] = _allCardInfos[_getCIDFromID[nftID]].symbol;
            rwInfo.tokenIDs[rwIndex] = nftID;
            rwInfo.tokenPrices[rwIndex] = _allCardInfos[_getCIDFromID[nftID]].priceUSDT;
            rwInfo.uris[rwIndex] = _uriFromId[nftID];
            rwInfo.createdTime[rwIndex] = _NFTRewardCardInfos[nftID].createdTime;
            (rwInfo.nftUSDT[rwIndex], rwInfo.nftHODL[rwIndex]) = getRewardInfoByNFT(nftID);
            rwInfo.canStable[rwIndex] = canReceiveStable(nftID);

            rwIndex ++;
        }

        return rwInfo;
    }

    function createSaleReal(uint256 _tokenID, uint _price) external onlyNFTOwner(_tokenID) {
        require(_pauseService == false, "Service is stopped.");
        require(_maxTokenId > _tokenID, "No Existing Item ID");
        require(_price > 0, "Price is zero");

        mkNFT.safeTransferFrom(msg.sender, address(this), _tokenID, 1, "");

        _allTokenIDToIndex[_tokenID] = _allSaleInfo.length;
        _allSaleInfo.push (SaleInfo(_tokenID, _uriFromId[_tokenID], _NFTRewardCardInfos[_tokenID].createdTime, mkNFT.creators(_tokenID), msg.sender, _price));

        emit CreateSaleReal(msg.sender, _tokenID, _price);
    }

    function closeSale(uint256 _tokenID) external onlyNFTSeller(_tokenID) nonReentrant {
        require(_pauseService == false, "Service is stopped.");
        require(_maxTokenId > _tokenID, "No Existing Item ID");

        uint256 _tokenIndex = _allTokenIDToIndex[_tokenID];
        mkNFT.safeTransferFrom(address(this), _allSaleInfo[_tokenIndex].currentOwner, _tokenID, 1, "");
        emit CloseSale(_allSaleInfo[_tokenIndex].currentOwner, _uriFromId[_tokenID], _tokenID);

        destroySale (_tokenID);
    }

    function destroySale(uint256 _tokenID) internal {
        uint256 _tokenIndex = _allTokenIDToIndex[_tokenID];
        uint256 _tokenLastIndex = _allSaleInfo.length - 1;
        uint256 _lastTokenID = _allSaleInfo[_tokenLastIndex].tokenId;

        _allTokenIDToIndex[_lastTokenID] = _tokenIndex;
        _allTokenIDToIndex[_tokenID] = 0;
        _allSaleInfo[_tokenIndex] = _allSaleInfo[_tokenLastIndex];
        _allSaleInfo.pop();
    }

    function buyNow(uint256 _tokenID) payable external nonReentrant{
        require(_pauseService == false, "Service is stopped.");
        RoyaltyInfo memory royaltys;

        uint256 _tokenIndex = _allTokenIDToIndex[_tokenID];
        customizedTransfer(payable(_allSaleInfo[_tokenIndex].currentOwner), _allSaleInfo[_tokenIndex].salePrice);
        mkNFT.safeTransferFrom(address(this), msg.sender, _tokenID, 1, "");

        emit BuyNow(msg.sender, _allSaleInfo[_tokenIndex].currentOwner, _allSaleInfo[_tokenIndex].salePrice, _allSaleInfo[_tokenIndex].tokenHash, _tokenID, royaltys);

        destroySale(_tokenID);
        bool isExist = false;
        for (uint256 i = 0; i < _nftIDsOfUser[msg.sender].length; i ++) {
            if (_nftIDsOfUser[msg.sender][i] == _tokenID) { isExist = true; break; }
        }
        if (!isExist) _nftIDsOfUser[msg.sender].push(_tokenID);
    }

    function getAllSaleInfos() public view returns (SaleInfo[] memory) {
        return _allSaleInfo;
    }

    function getSaleInfo(uint256 _tokenID) public view returns (SaleInfo memory) {
        require(_maxTokenId > _tokenID, "No Existing Item ID");

        uint256 _tokenIndex = _allTokenIDToIndex[_tokenID];
        return _allSaleInfo[_tokenIndex];
    }

    function getMintStartTime() public view returns (uint256) {
        return MINT_START_TIME;
    }

    function setMintStartTime(uint256 _time) external {
        MINT_START_TIME = _time;

        emit SetMintStartTime (_time);
    }

    function customizedTransfer(address payable _to, uint256 _amount) internal {
        require(_to != address(0), "Invalid address...");
        if(_amount > 0) {
            _usdtToken.transferFrom(msg.sender, _to, _amount);
        }
    }

    function customizedTransferToken(address _addr, uint256 _amount) external onlyOwner {
        uint256 balance = IERC20(_addr).balanceOf(address(this));
        if (balance >= _amount) {
            IERC20(_addr).transfer(msg.sender, _amount);
        }
    }

    function _setTokenUri(uint256 _tokenId, string memory _uri) internal {
        _uriFromId[_tokenId] = _uri;
        emit SetTokenUri(_tokenId, _uri);
    }

    function changePrice(uint256 _tokenID, uint256 newPrice) external onlyNFTSeller(_tokenID){
        uint256 _tokenIndex = _allTokenIDToIndex[_tokenID];
        uint256 oldPrice = _allSaleInfo[_tokenIndex].salePrice;
        _allSaleInfo[_tokenIndex].salePrice = newPrice;
        emit ChangePrice(msg.sender, _uriFromId[_tokenID], oldPrice, newPrice);
    }

    function getNFTAddress() external view returns(address nftAddress) {
        return mkNFTaddress;
    }

    function setNFTAddress(address nftAddress) external onlyOwner {
        mkNFTaddress = nftAddress;
        mkNFT = ERC1155Interface(nftAddress);
        emit SetNFTAddress(msg.sender, nftAddress);
    }

    function getMaxTokenId() external view returns(uint256) {
        return _maxTokenId;
    }

    function setMaxTokenId(uint256 maxTokenId) external onlyOwner {
        _maxTokenId = maxTokenId;
        emit SetMaxTokenId(msg.sender, maxTokenId);
    }

    function setRoyalty(uint256 _ra, uint256 _ta, uint256 _tp, uint256 _tda) external onlyOwner {
        royaltyInfo.rewardPercent = _ra;
        royaltyInfo.liquidityPercent = _ta;
        royaltyInfo.teamPercent = _tp;
        royaltyInfo.tradingPercent = _tda;

        emit SetRoyalty (msg.sender, royaltyInfo);
    }

    function getBalanceOf(address user, uint256 _tokenID, address nftAddress) external view returns(uint256) {
        ERC1155Interface nft;
        if(nftAddress == address(0)) {
            nft = ERC1155Interface(mkNFTaddress);
        } else {
            nft = ERC1155Interface(nftAddress);
        }
        return nft.balanceOf(user, _tokenID);
    }

    receive() payable external {}

    fallback() payable external {}
    
    function onERC1155Received(address, address, uint256, uint256, bytes memory) public override pure virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) public override virtual returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    event CreateSaleReal(address seller, uint256 tokenID, uint price);
    event CloseSale(address seller, string tokenHash, uint256 tokenId);
    event BuyNow(address buyer, address seller, uint256 price, string tokenHash, uint256 tokenId, RoyaltyInfo royaltyInfo);
    event SetMintingFee(address sender, address creator, uint256 amount);
    event SetRoyalty(address sender, RoyaltyInfo info);
    event TransferNFTOwner(address sender, address to);
    event ChangePrice(address sender,string tokenHash, uint256 oldPrice, uint256 newPrice);
    event TransferNFT(address sender, address receiver, string tokenHash, uint256 tokenId);
    event BurnNFT(address sender, string tokenHash, uint256 tokenId);
    event SetNFTAddress(address sender, address nftAddress);
    event SetTokenUri(uint256 tokenId, string uri);
    event SetMaxTokenId(address sender, uint256 maxTokenId);
    event SetNFTCardInfo(address sender, uint infoID, string uri, uint256 usdt, uint256 sup);
    event SetCardState(uint infoID, bool state);
    event MintSingleNFT(address buyer, uint infoID, uint256 itemID);
    event MintNFTs(address buyer, uint infoID, uint256 count);
    event ClaimByNFT(address addr, uint256 nftId, uint256 usdt, uint256 hodl);
    event ClaimAllNFT(address addr, uint256 usdts, uint256 hodls);
    event AddNFTCardInfo (address addr, string symbol, string uri, uint256 usdt, uint256 roi, uint256 sup);
    event InsertWhitelist(address addr, uint256 newInsertedCount);
    event SetWhitelist(address addr, bool flag);
    event CustomizedTransferToken(address owner, uint256 usdt, uint256 token);
    event SwapAndLiquidy(uint256 half, uint256 hodl, uint256 otherhalf);
    event SetMintStartTime(uint256 time);
}