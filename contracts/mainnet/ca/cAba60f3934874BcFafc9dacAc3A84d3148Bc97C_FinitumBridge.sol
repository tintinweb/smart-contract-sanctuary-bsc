//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ISwapRouter {
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] memory path)
        external
        view
        returns (uint[] memory amounts);
}

contract FinitumBridge {
    address public admin;
    uint256 public bnbBal;
    uint256 public txFee;
    mapping (address => bool) public supportedTokens;
    mapping (address => uint256) public minAdaForTokens;
    mapping (string => address) public contractAddresses;
    mapping (string => bool) public fulfilledBridgeInTxs;

    event TransferReceived(address _from, uint _amount);
    event BridgeOutRequestReceived(address _from, string _to, IERC20 _token, uint _amount, bool _withAda);
    event BridgeInRequestFulfilled(string _from, address _to, IERC20 _token, uint _amount, string _sourceTxHash);
    event ReservesTransferred(address _by, address _to, string _assetType, uint _amount);
    event AdminChanged(address _prevAdmin, address _newAdmin);
    event ContractAddressUpdated(string _contractName, address _prevContract, address _newContract);
    event SupportedTokensUpdated(address _tokenAddress, bool _supported, uint256 _minAda);
    
    constructor(address _swapRouter, address _adaAddress, address _wbnbAddress) {
        admin = msg.sender;
        contractAddresses["swapRouter"] = _swapRouter;
        contractAddresses["ada"] = _adaAddress;
        contractAddresses["wbnb"] = _wbnbAddress;
        txFee = 3000000000000000; // initial txFee setting
    }

    modifier adminOnly {
        require(msg.sender == admin, "Unauthorized");
        _;
    }

    receive() payable external {
        bnbBal += msg.value;
        emit TransferReceived(msg.sender, msg.value);
    }
    
    function moveCoinReserves(uint amount, address payable to) public adminOnly {
        uint256 _bnbBal = address(this).balance;
        require(amount <= _bnbBal, "Insufficient bal");
        bnbBal = _bnbBal - amount;
        to.transfer(amount);
        emit ReservesTransferred(msg.sender, to, 'bnb', amount);
    }

    function moveAllReserves(IERC20[] calldata tokens, address payable to) public adminOnly {
        uint256 _bnbBal = address(this).balance;
        if (_bnbBal > 0){
            bnbBal -= _bnbBal;
            to.transfer(_bnbBal);
        }
        for (uint i = 0; i < tokens.length; i++) {
            uint256 erc20balance = tokens[i].balanceOf(address(this));
            if (erc20balance > 0){
                tokens[i].transfer(to, erc20balance);
            }            
        }
        emit ReservesTransferred(msg.sender, to, 'all', _bnbBal);
    }
    
    function transferERC20(IERC20 token, address to, uint256 amount) public adminOnly {
        uint256 erc20balance = token.balanceOf(address(this));
        require(amount <= erc20balance, "ERC20: Insufficient bal");
        token.transfer(to, amount);
        emit ReservesTransferred(msg.sender, to, 'erc20', amount);
    }

    function transferERC721(IERC721 token, address to, uint256 tokenId) public adminOnly {
        address tokenIdOwner = token.ownerOf(tokenId);
        require(tokenIdOwner == address(this), "ERC721: tokenId not owned.");
        token.transferFrom(address(this), to, tokenId);
        emit ReservesTransferred(msg.sender, to, 'erc721', tokenId);
    }

    function changeAdmin(address newAdmin) public adminOnly {
        require(newAdmin != address(0), "New admin cannot be the zero address");
        admin = newAdmin;
        emit AdminChanged(msg.sender, newAdmin);
    }

    function getContract(string memory name) public view returns(address) {
        return contractAddresses[name];
    }

    function updateContractAddress(string memory contractName, address newContract) public adminOnly {
        address oldContract = contractAddresses[contractName];
        contractAddresses[contractName] = newContract;
        emit ContractAddressUpdated(contractName, oldContract, newContract);
    }

    function updateSupportedTokens(address contractAddress, bool support, uint256 minAda) public adminOnly {
        supportedTokens[contractAddress] = support;
        minAdaForTokens[contractAddress] = minAda;
        emit SupportedTokensUpdated(contractAddress, support, minAda);
    }

    function updateTxFee(uint256 _txFee) public adminOnly {
        txFee = _txFee;
    }

    function checkSupportedTokens(address contractAddress) public view returns (address _contractAddress, bool _support, uint256 _minAda) {
        if (supportedTokens[contractAddress]) {
            return (contractAddress, true, minAdaForTokens[contractAddress]);
        } else {
            return (contractAddress, false, 0);
        }
    }

    function getReqdBnbForToken(address contractAddress, uint256 amount) public view returns (uint256[] memory amountsIn) {
        address[] memory path = new address[](2);
        path[0] = contractAddresses["wbnb"];
        path[1] = contractAddress;
        amountsIn = ISwapRouter(contractAddresses["swapRouter"]).getAmountsIn(amount, path);
        return amountsIn;
    }

    function sendToCardanoChain(IERC20 token, uint256 amount, string memory cardanoAddress) public payable {
        require(amount <= token.allowance(msg.sender, address(this)), "Insufficient approved amount.");
        require(supportedTokens[address(token)], "Bridge: unsupported token.");
        payable(admin).transfer(msg.value);
        token.transferFrom(msg.sender, address(this), amount);
        emit BridgeOutRequestReceived(msg.sender, cardanoAddress, token, amount, false);
    }

    function sendToCardanoChainWithAda(IERC20 token, uint256 amount, string memory cardanoAddress) public payable {
        require(amount <= token.allowance(msg.sender, address(this)), "Insufficient approved amount.");
        require(supportedTokens[address(token)], "Bridge: unsupported token.");
        address[] memory path = new address[](2);
        path[0] = contractAddresses["wbnb"];
        path[1] = contractAddresses["ada"];
        uint256[] memory amountsIn = ISwapRouter(contractAddresses["swapRouter"]).getAmountsIn(minAdaForTokens[address(token)], path);
        uint256 fee = msg.value - amountsIn[0];
        require((amountsIn[0] + txFee) <= (msg.value), "Insuffient BNB to cover txFee & minAda on Cardano.");
        // acquire ADA to cover the minAda needed on Cardano chain
        _getAda(amountsIn[0], minAdaForTokens[address(token)], path);

        token.transferFrom(msg.sender, address(this), amount);
        payable(admin).transfer(fee);
        emit BridgeOutRequestReceived(msg.sender, cardanoAddress, token, amount, true);
    }

    function _getAda(uint256 bnbAmount, uint256 adaAmount, address[] memory path) private {
        ISwapRouter(contractAddresses["swapRouter"]).swapETHForExactTokens{value: bnbAmount}(adaAmount, path, address(this), block.timestamp);
    }

    function sendFromCardanoChain(IERC20 token, string memory from, address to, uint256 amount, string memory sourceTxHash) public adminOnly {
        uint256 erc20balance = token.balanceOf(address(this));
        require(amount <= erc20balance, "Insufficient reserve");
        require(!fulfilledBridgeInTxs[sourceTxHash], "Request already fulfilled");
        fulfilledBridgeInTxs[sourceTxHash] = true;
        token.transfer(to, amount);
        emit BridgeInRequestFulfilled(from, to, token, amount, sourceTxHash);
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