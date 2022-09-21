/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "addition overflow");

        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "subtraction overflow");
    }


    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }


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


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }


    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }


    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


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


/// @title ERC-721 Non-Fungible Token Standard
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x80ac58cd.
interface IERC721 /* is ERC165 */ {
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


interface IAdminData {
    function checkAdmin(string memory _appId, address _sender) external view returns (bool);
}

interface IIntegrateToken {
    function mint(address account, uint256 amount) external;

    function burn(address account, uint256 amount) external;
}


interface IAwardData {

    struct AwardPool {
        IERC20 token;
        bool isETH;
        bool isNFT;
        IERC721 nft;
        uint256 awardCount;
        uint256[] nftIds;
    }


    function setAwardPools(string memory _appId, uint256 _id, AwardPool[] memory _pools, address _creator) external;

    function getAwardPools(uint256 _id) external view returns (AwardPool[] memory);

    function getPoolCreator(address _id) external view returns (address);

    function overPool(uint256 _id) external;

    function checkIsOver(uint256 _id) external view returns (bool);

    function checkIsExist(uint256 _id) external view returns (bool);

    function checkBelongApp(string memory _appId, uint256 _id) external view returns (bool);
}


contract Permission {
    address public owner;
    address payable public operator;
    mapping(string => address payable) appOperators;

    modifier onlyOwner(){
        require(msg.sender == owner, "Only Owner");
        _;
    }

    function transferOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

    function isOperator(string memory _appId) public view returns (bool){
        return (operator == msg.sender || address(appOperators[_appId]) == msg.sender);
    }

    function changeOperator(address payable _newOperator) public onlyOwner {
        operator = _newOperator;
    }

    function addAppOperator(string memory _appId, address payable _newOperator) public onlyOwner {
        appOperators[_appId] = _newOperator;
    }

    function delAppOperator(string memory _appId) public onlyOwner {
        appOperators[_appId] = payable(0);
    }
}


contract Award is Permission, IERC721Receiver {

    using SafeMath for uint256;

    IAdminData public adminData;
    IAwardData public awardData;
    IIntegrateToken public integrateToken;
    uint256 public integrateValue;
    IERC20[] public erc20List;
    IERC721[] public nftList;
    mapping(IERC20 => bool) public erc20Exist;
    mapping(IERC721 => bool) public nftExist;


    constructor(address payable _operator, IAdminData _adminData, IAwardData _awardData) {
        owner = msg.sender;
        operator = _operator;
        adminData = _adminData;
        awardData = _awardData;
    }


    function changeAdminData(IAdminData _newData) public onlyOwner {
        adminData = _newData;
    }

    function changeAwardData(IAwardData _newData) public onlyOwner {
        awardData = _newData;
    }

    function changeIntegrateToken(IIntegrateToken _newToken) public onlyOwner {
        integrateToken = _newToken;
    }

    function changeIntegrateValue(uint256 _newValue) public onlyOwner {
        integrateValue = _newValue;
    }

    function transferAsset(address payable _to) public onlyOwner {
        if (address(this).balance > 0) {
            _to.transfer(address(this).balance);
        }
        for (uint i = 0; i < erc20List.length; i++) {
            uint256 balance = erc20List[i].balanceOf(address(this));
            if (balance > 0) {
                erc20List[i].transfer(_to, balance);
            }
        }
    }


    function checkOver(uint256 _id) private view {
        require(!awardData.checkIsOver(_id), "Over");
    }


    modifier onlyAdmin(string memory _appId) {
        require(adminData.checkAdmin(_appId, msg.sender) || isOperator(_appId), "Only admin");
        _;
    }

    modifier onlyOperator(string memory _appId) {
        require(isOperator(_appId), "Only operator");
        _;
    }


    function _addErc20(IERC20 _token) internal {
        if (!erc20Exist[_token]) {
            erc20List.push(_token);
            erc20Exist[_token] = true;
        }
    }

    function _addNFT(IERC721 _nft) internal {
        if (!nftExist[_nft]) {
            nftList.push(_nft);
            nftExist[_nft] = true;
        }
    }


    function createAwardPools(string memory _appId, uint256 _id, IAwardData.AwardPool[] memory _pools, uint256 _preGas) public payable onlyAdmin(_appId) {
        require(!awardData.checkIsExist(_id), "Exist");
        uint256 ethCount = _preGas;
        for (uint i = 0; i < _pools.length; i++) {
            if (_pools[i].isNFT) {
                for (uint j = 0; j < _pools[i].nftIds.length; j++) {
                    _pools[i].nft.safeTransferFrom(msg.sender, address(this), _pools[i].nftIds[j]);
                }
                _addNFT(_pools[i].nft);
            } else {
                if (_pools[i].isETH) {
                    ethCount = ethCount.add(_pools[i].awardCount);
                } else {
                    _pools[i].token.transferFrom(msg.sender, address(this), _pools[i].awardCount);
                    _addErc20(_pools[i].token);
                }
            }
        }

        if (ethCount > _preGas) {
            require(msg.value >= ethCount, "Insufficient eth");
        }
        if (address(integrateToken) != address(0) && integrateValue > 0) {
            integrateToken.mint(msg.sender, integrateValue);
        }
        operator.transfer(_preGas);
        awardData.setAwardPools(_appId, _id, _pools, msg.sender);
    }


    function executeAward(string memory _appId, uint256 _id, address[][] memory _receivers, uint256[][] memory _amounts) public {
        require(isOperator(_appId), "Only operator");
        require(awardData.checkIsExist(_id), "Not exist");
        require(awardData.checkBelongApp(_appId, _id), "award not match app");
        checkOver(_id);
        IAwardData.AwardPool[] memory pools = awardData.getAwardPools(_id);
        require(pools.length == _receivers.length, "Receivers length not match pool length");
        for (uint i = 0; i < pools.length; i++) {
            if (pools[i].isNFT) {
                require(pools[i].nftIds.length >= _receivers[i].length, "Receivers length not match nft length");
                for (uint j = 0; j < _receivers[i].length; j++) {
                    pools[i].nft.safeTransferFrom(address(this), _receivers[i][j], pools[i].nftIds[j]);
                }
            } else {
                if (pools[i].isETH) {
                    for (uint j = 0; j < _receivers[i].length; j++) {
                        payable(_receivers[i][j]).transfer(_amounts[i][j]);
                    }
                } else {
                    for (uint j = 0; j < _receivers[i].length; j++) {
                        pools[i].token.transfer(_receivers[i][j], _amounts[i][j]);
                    }
                }
            }
        }
        awardData.overPool(_id);
    }

    function getAwardPools(uint256 _id) public view returns (IAwardData.AwardPool[] memory){
        return awardData.getAwardPools(_id);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}