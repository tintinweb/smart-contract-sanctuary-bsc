// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IApeRouter01.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./interfaces/IOneForge.sol";

contract NFTMarketplace {
    IERC721 private mintNft;
    IERC20 private ogtToken;
    IApeRouter01 private apeswapRouter;
    IOneForge private oneForge;

    address constant APESWAP_ROUTER =
        // 0xC0788A3aD43d79aa53B09c2EaCc313A787d1d607; //Polygon Mainnet
        0xcF0feBd3f17CEf5b47b0cD257aCf6025c5BFf3b7; //BSC Mainnet
    // 0x3380aE82e39E42Ca34EbEd69aF67fAa0683Bb5c1 //For testnet
    address constant WBNB_ADDRESS = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; //(Mainnet) //0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd(BSC testnet) //0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;(Polygon)
    uint256 constant OGT_PRICE = 8 * 10**12;
    uint256 counter = 1;
    struct SaleNFT {
        uint256 id; //No. of nft added for sell
        uint256 tokenId;
        uint256 price;
        address sellerAddr;
        bool isSold;
    }

    mapping(uint256 => SaleNFT) public saleNFTItem;
    mapping(uint256 => address) public ownerOfLinkedListId;

    event BuyNFT(
        address indexed userAddr,
        address indexed sellerAddr,
        uint256 indexed tokenId,
        uint256 price
    );
    event SellNFT(
        uint256 id,
        uint256 indexed tokenId,
        uint256 price,
        address indexed sellerAddress
    );
    event SellNFTForFloatPrice(
        uint256 id,
        uint256 indexed tokenId,
        uint256 price,
        address indexed sellerAddress
    );
    event RemoveNFT(uint256 indexed tokenId);

    event ChangeFloatPrice(uint256 tokenId, uint256 id, uint256 changedPrice);

    constructor(
        IERC721 _nft,
        IERC20 _token,
        IOneForge _forge
    ) {
        mintNft = _nft;
        apeswapRouter = IApeRouter01(APESWAP_ROUTER);
        ogtToken = _token;
        oneForge = _forge;
    }

    function buyNFTItem(uint256 _id) external payable {
        SaleNFT storage saleNft = saleNFTItem[_id];

        require(!saleNft.isSold, "Already sold NFT");
        require(
            msg.sender != address(0) && msg.sender != saleNft.sellerAddr,
            "Cannot buy to zero address and Seller cannot buy"
        );
        require(msg.value >= saleNft.price, "Not enough funds");

        saleNft.isSold = true;
        address payable sellerAddress = payable(saleNft.sellerAddr);

        uint256 tokenId = saleNft.tokenId;

        emit BuyNFT(msg.sender, saleNft.sellerAddr, tokenId, saleNft.price);
        (bool isSendToAccount, ) = payable(sellerAddress).call{
            value: msg.value
        }("");
        require(isSendToAccount, "OGT marketplace: send service fee failed");
        mintNft.safeTransferFrom(sellerAddress, msg.sender, tokenId);
    }

    function removeNFTFromSell(uint256 counterId, uint256 _tokenID) external {
        SaleNFT memory saleNft = saleNFTItem[counterId];
        require(_tokenID == saleNft.tokenId, "Not same tokenID");
        require(
            msg.sender == saleNft.sellerAddr,
            "Only seller can remove nft from sell"
        );

        emit RemoveNFT(_tokenID);
    }

    function sellNFTItem(uint256 _tokenId, uint256 _price) external {
        require(msg.sender == mintNft.ownerOf(_tokenId), "Not called by owner");
        require(mintNft.balanceOf(msg.sender) > 0, "Insufficients NFT");

        SaleNFT storage saleNft = saleNFTItem[counter];

        saleNft.id = counter;
        saleNft.tokenId = _tokenId;
        saleNft.price = _price;
        saleNft.sellerAddr = msg.sender;
        saleNft.isSold = false;

        emit SellNFT(counter, _tokenId, _price, msg.sender);
        counter++;
    }

    function sellMergeNFT(uint256 linkedListId, uint256 nftPrice) external {
        uint256 linkListSize = oneForge.sizeOfList(linkedListId);
        require(linkListSize > 0, "Not contain any data");

        SaleNFT storage saleNft = saleNFTItem[counter];

        saleNft.id = counter;
        saleNft.tokenId = linkedListId;
        saleNft.price = nftPrice;
        saleNft.sellerAddr = msg.sender;
        saleNft.isSold = false;

        ownerOfLinkedListId[linkedListId] = msg.sender;

        emit SellNFT(counter, linkedListId, nftPrice, msg.sender);
        counter++;
    }

    function sellNFTItemForFloatPrice(
        uint256 _tokenId,
        uint256 _premiumValue,
        uint256 nftToSell
    ) external {
        require(
            _premiumValue >= 1000 && _premiumValue <= 10000,
            "Premimum value must be in between 1000 to 10000"
        );
        require(msg.sender == mintNft.ownerOf(_tokenId), "Not called by owner");

        SaleNFT storage saleNFT = saleNFTItem[counter];

        uint256 floatPrice = floatingPrice(_premiumValue, nftToSell);

        saleNFT.tokenId = _tokenId;
        saleNFT.price = floatPrice;
        saleNFT.sellerAddr = msg.sender;
        saleNFT.isSold = false;

        emit SellNFTForFloatPrice(counter, _tokenId, floatPrice, msg.sender);
    }

    function changeFloatPrice(
        uint256 premiumNo,
        uint256 _tokenId,
        uint256 _id,
        uint256 numberOfNft
    ) external returns (uint256) {
        require(
            premiumNo >= 1000 && premiumNo <= 10000,
            "Premimum value must be in between 1000 to 10000"
        );
        require(
            msg.sender == saleNFTItem[_id].sellerAddr,
            "Only seller allow to change price"
        );
        require(_tokenId == saleNFTItem[_id].tokenId, "Not valid tokenId");
        uint256 _price = floatingPrice(premiumNo, numberOfNft);
        saleNFTItem[_id].price = _price;

        emit ChangeFloatPrice(_tokenId, _id, _price);
        return _price;
    }

    function floatingPrice(uint256 premiumValue, uint256 _nftToSell)
        internal
        view
        returns (uint256)
    {
        address[] memory path = new address[](2);

        path[0] = address(ogtToken); //OGT token address
        path[1] = WBNB_ADDRESS; //BNB address
        uint256 _amountIn = _nftToSell * OGT_PRICE;
        uint256 ethAmount = apeswapRouter.getAmountsOut(_amountIn, path)[1];

        uint256 preminum = (ethAmount * premiumValue) / 10000;
        uint256 priceFloat = ethAmount + preminum;
        return priceFloat;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

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
pragma solidity ^0.8.0;

interface IOneForge {
    function merge(uint256[] memory tokenId) external;

    function mergeWithExistingId(uint256 linkedListID, uint256[] memory tokenID)
        external;

    function mergedNFT(uint256 linkedListID1, uint256 linkedListID2) external;

    function sizeOfList(uint256 _id) external view returns (uint256);
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