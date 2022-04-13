// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MintNFT.sol";
import "./interfaces/IApeRouter01.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NFTMarketplace {
    MintNFT private mintNft;
    IERC20 private ogtToken;
    IApeRouter01 private apeswapRouter;

    address constant APESWAP_ROUTER =
        0xcF0feBd3f17CEf5b47b0cD257aCf6025c5BFf3b7;
    address constant WBNB_ADDRESS = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    uint256 constant OGT_PRICE = 8 * 10**12;
    struct SaleNFT {
        uint256 id; //No. of nft added for sell
        uint256 tokenId;
        uint256 price;
        address payable sellerAddr;
        bool isSold;
    }

    SaleNFT[] public saleNFTItem;

    mapping(uint256 => bool) private activeNft;
    event BuyNFT(address indexed userAddr, uint256 tokenId, uint256 price);
    event SellNFT(
        uint256 id,
        uint256 tokenId,
        uint256 price,
        address indexed sellerAddress
    );
    event SellNFTForFloatPrice(
        uint256 id,
        uint256 tokenId,
        uint256 price,
        address indexed sellerAddress
    );

    constructor(MintNFT _nft, IERC20 _token) {
        mintNft = _nft;
        apeswapRouter = IApeRouter01(APESWAP_ROUTER);
        ogtToken = _token;
    }

    function buyNFTItem(uint256 _id) external payable {
        require(_id >= 0 && _id < saleNFTItem.length, "NFT Id not found"); //(10> = 11 reverted)
        require(!saleNFTItem[_id].isSold, "Already sold NFT");
        require(
            msg.sender != address(0) &&
                msg.sender != saleNFTItem[_id].sellerAddr,
            "Cannot buy to zero address"
        );
        require(msg.value >= saleNFTItem[_id].price, "Not enough funds");

        saleNFTItem[_id].isSold = true;
        address payable sellerAddress = saleNFTItem[_id].sellerAddr;
        sellerAddress.transfer(msg.value);

        uint256 tokenId = saleNFTItem[_id].tokenId;
        activeNft[tokenId] = false; //Set that token id as false

        emit BuyNFT(msg.sender, tokenId, saleNFTItem[_id].price);
    }

    function sellNFTItem(uint256 _tokenId, uint256 _price) external {
        require(!activeNft[_tokenId], "Already added for sell");

        uint256 nftId = saleNFTItem.length;
        saleNFTItem.push(
            SaleNFT({
                id: nftId,
                tokenId: _tokenId,
                price: _price,
                sellerAddr: payable(msg.sender),
                isSold: false
            })
        );
        activeNft[_tokenId] = true;
        emit SellNFT(nftId, _tokenId, _price, msg.sender);
    }

    function sellNFTItemForFloatPrice(
        uint256 _tokenId,
        uint256 _premiumValue,
        uint256 nftToSell
    ) external {
        require(!activeNft[_tokenId], "Already added for sell");
        uint256 floatPrice = floatingPrice(_premiumValue, nftToSell);

        uint256 nftId = saleNFTItem.length;
        saleNFTItem.push(
            SaleNFT({
                id: nftId,
                tokenId: _tokenId,
                price: floatPrice,
                sellerAddr: payable(msg.sender),
                isSold: false
            })
        );
        activeNft[_tokenId] = true;
        emit SellNFTForFloatPrice(nftId, _tokenId, floatPrice, msg.sender);
    }

    function floatingPrice(uint256 preminumValue, uint256 _nftToSell)
        internal
        view
        returns (uint256)
    {
        address[] memory path = new address[](2);

        path[0] = address(ogtToken); //OGT token address
        path[1] = WBNB_ADDRESS; //BNB address
        uint256 _amountIn = _nftToSell * OGT_PRICE;
        uint256 ethAmount = apeswapRouter.getAmountsOut(_amountIn, path)[1];

        uint256 preminum = (ethAmount * preminumValue) / 100;
        uint256 priceFloat = ethAmount + preminum;
        return priceFloat;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title A Mint NFT contract
contract MintNFT is Ownable {
    uint256 constant MAX_X = 50;
    uint256 constant MAX_Y = 50;
    uint256 constant MAX_Z = 50;

    uint256 public counter = 0; //tokenId

    // Mapping from token ID to owner
    mapping(uint256 => address) internal tokenOwner;

    // Mapping from owner to number of owned token
    mapping(address => uint256) internal ownedTokensCount;

    // Metadata of NFT
    mapping(uint256 => string) internal metaDataNFT;

    // Mapping from encodedTokenId to owner address
    mapping(uint256 => address) internal holderOf;

    event CreateNFT(
        address indexed user,
        uint256 nftId,
        string metaData,
        uint256 x,
        uint256 y,
        uint256 z,
        uint256 encodeTokenID
    );

    /**
     * @dev Only called by Owner else throw error
     * @param to address of user that will own the minted NFT
     * @param metaData string that contains metaData
     * @param x uint256 x coordinates
     * @param y uint256 y coordiantes
     * @param z uint256 z coordinates
     */
    function mint(
        address to,
        string calldata metaData,
        uint256[] calldata x,
        uint256[] calldata y,
        uint256[] calldata z
    ) external onlyOwner {
        require(to != address(0), "Mint to zero address");
        require(x.length > 0, "Give at least one coordinate");
        require(
            x.length == y.length &&
                x.length == z.length &&
                y.length == z.length,
            "The coordinates should have same length"
        );
        for (uint256 i = 0; i < x.length; i++) {
            uint256 encodedTokenId = _encodeTokenId(x[i], y[i], z[i]);
            require(
                !_exists(encodedTokenId),
                "The coordinate x,y,z already minted"
            );
            holderOf[encodedTokenId] = to;

            counter++;
            tokenOwner[counter] = to;
            ownedTokensCount[to] += 1;
            _updateMetaData(counter, metaData);
            emit CreateNFT(
                to,
                counter,
                metaData,
                x[i],
                y[i],
                z[i],
                encodedTokenId
            );
        }
    }

    /**
     * @param x uint256 x coordinates
     * @param y uint256 y coordiantes
     * @param z uint256 z coordinates
     * @return uint256 encoded Id of the x,y,z coordinates
     */
    function encodeTokenId(
        uint256 x,
        uint256 y,
        uint256 z
    ) external pure returns (uint256) {
        return _encodeTokenId(x, y, z);
    }

    /**
     * @param result uint256 result is the encoded id of x,y,z coordinates
     */
    function decodeTokenId(uint256 result)
        external
        pure
        returns (
            uint256 x,
            uint256 y,
            uint256 z
        )
    {
        return _decodeTokenId(result);
    }

    /**
     * @param x uint256 x coordinate
     * @param y uint256 y coordinate
     * @param z uint256 z coordinate
     * @return bool whether the token exists
     */
    function exists(
        uint256 x,
        uint256 y,
        uint256 z
    ) external view returns (bool) {
        uint256 _encodeId = _encodeTokenId(x, y, z);
        return (_exists(_encodeId));
    }

    function _encodeTokenId(
        uint256 x,
        uint256 y,
        uint256 z
    ) internal pure returns (uint256) {
        require(
            0 < x && x <= MAX_X && 0 < y && y <= MAX_Y && 0 < z && z <= MAX_Z,
            "(x,y,z) should be inside bounds"
        );
        uint256 a = 1;
        uint256 b = MAX_X + 1;
        uint256 c = (MAX_X + 1) * (MAX_Y + 1);
        uint256 d = 0;
        return a * x + b * y + c * z + d;
    }

    function _decodeTokenId(uint256 result)
        internal
        pure
        returns (
            uint256 x,
            uint256 y,
            uint256 z
        )
    {
        x = result % (MAX_X + 1);
        result /= (MAX_X + 1);
        y = result % (MAX_Y + 1);
        result /= (MAX_Y + 1);
        z = result;

        require(
            0 < x && x <= MAX_X && 0 < y && y <= MAX_Y && 0 < z && z <= MAX_Z,
            "(x,y,z) should be inside bounds"
        );
        return (x, y, z);
    }

    function _exists(uint256 _encodeId) internal view returns (bool) {
        return (holderOf[_encodeId] != address(0));
    }

    function _updateMetaData(uint256 _tokenId, string memory _metaData)
        internal
    {
        metaDataNFT[_tokenId] = _metaData;
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2;

interface IApeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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