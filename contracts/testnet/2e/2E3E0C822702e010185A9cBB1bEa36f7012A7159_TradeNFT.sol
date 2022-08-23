// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor()  {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }


  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }


  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }


  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

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

contract TradeNFT is Ownable, IERC721Receiver{

    bool public emergent;   // 紧急情况
    uint256 constant MIN_PRICE = 1000;
    uint256 public free_numerator;   // 分子
    uint256 public free_denominator; // 分母

    address public immutable token = 0x56f48E52deDb49Ddf7D3C965deFc4922814313c1;

    bytes32 private  constant PARAM_TYPE_HASH = keccak256("Param(address _contract,uint256 tokenId,uint256 numerator,address owner)");
    bytes32 private  constant EIP712_DOMAIN_TYPE_HASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 private DOMAIN_SEPARATOR;


    mapping (address => mapping (uint256 => Item)) private staking;

    struct Item {
      address owner;          // NFT拥有者
      uint256 tokenId;        // Token ID
      bool listing;           // 是否上架
    }

    struct Param {
      address _contract;      // NFT合约地址
      uint256 tokenId;        // token id
      uint256 numerator;      // 价格
      address owner;          // 签名者
    }

    event Listing(address indexed _contract, address indexed owner, uint256 tokenId);
    event Delisting(address indexed _contract, address indexed owner, uint256 tokenId);
    event Stake(address indexed owner, address indexed _contract, uint256 tokenId);
    event Unstake(address indexed _contract, address indexed owner, uint256 tokenId);
    event EmergentUnstak(address indexed _contract, address indexed owner, uint256 tokenId);
    event TradeForETH(address indexed from, address indexed to, uint256 tokenId);
    event TradeForToken(address indexed from, address indexed to, uint256 tokenId);
    event WithdrawalETH(address indexed owner, uint256 amount);
    event WithdrawalToken(address indexed owner, uint256 amount);

    constructor(
      uint256 _free_numerator, 
      uint256 _free_denominator
      ) {
      DOMAIN_SEPARATOR = keccak256(abi.encode(
            EIP712_DOMAIN_TYPE_HASH,
            keccak256(bytes("Nuoibo NFT")),
            keccak256(bytes("1")),
            block.chainid,
            address(this)
        ));

        free_numerator = _free_numerator;
        free_denominator = _free_denominator;
    }

    /**
     * @dev  查询NFT是否上架
     * @param _contract 合约地址
     * @param _tokenId token id
     */
    function getTokenUp(address _contract, uint256 _tokenId) public view returns(bool) {
      return staking[_contract][_tokenId].listing;
    }


    /**
     * @dev  采用ETH交易
     * @param _contract 合约地址
     * @param _tokenId token id
     * @param signature 签名hash
     * @param _param 签名者和价格的结构体
     */
    function tradeForETH(
      address _contract, 
      uint256 _tokenId,
      bytes memory signature, 
      Param memory _param
      ) external payable{
      Item memory item = staking[_contract][_tokenId];
      require(item.owner != msg.sender, "Owner address can't buy");
      require(item.listing, "Already down");

      // 签名验证
      address sign = verifyToAddress(signature, _param);
      uint256 price = _param.numerator;
      require(sign == item.owner, "Invalid signature");
      require(price >= MIN_PRICE, "Price too low");
      require(msg.value >= price, "Insufficient funds");
    
      // 收取手续费并支付卖家代币
      payable(item.owner).transfer(msg.value - price * free_numerator / free_denominator);

      // 删除质押NFT数据
      delete staking[_contract][_tokenId];

      // 向买家转NFT
      IERC721(_contract).safeTransferFrom(address(this), msg.sender, _tokenId);

      // 退还剩余代币
      if (msg.value > price) {
        payable(msg.sender).transfer(msg.value - price);
      }

      emit TradeForETH(address(this), msg.sender, _tokenId);
    }


    /**
     * @dev  采用Token代币交易
     * @param _contract 合约地址
     * @param _tokenId token id
     * @param signature 签名hash
     * @param _param 签名者和价格的结构体
     */
    function tradeForToken(
      address _contract, 
      uint256 _tokenId,
      bytes memory signature, 
      Param memory _param
      ) external{
      Item memory item = staking[_contract][_tokenId];
      require(item.owner != msg.sender, "Owner address can't buy");
      require(item.listing, "Already delisted");

      // 签名验证
      address sign = verifyToAddress(signature, _param);
      uint256 price = _param.numerator;
      require(price >= MIN_PRICE, "Price too low");
      require(sign == item.owner, "Invalid signature");
      require(IERC20(token).allowance(msg.sender, address(this)) >= price, "Insufficient approve amount");
    
      // 收取手续费并支付卖家代币
      IERC20(token).transferFrom(msg.sender, address(this), price);
      IERC20(token).transferFrom(address(this), item.owner, price - price * free_numerator / free_denominator);

      // 删除质押NFT数据
      delete staking[_contract][_tokenId];
      
      // 向买家转NFT
      IERC721(_contract).safeTransferFrom(address(this), msg.sender, _tokenId);

      emit TradeForToken(address(this), msg.sender, _tokenId);
    }

    /**
     * @dev  token id 上架 
     * @param _contract 合约地址
     * @param _tokenId token id
     */
    function listing(
      address _contract, 
      uint256 _tokenId) external {
      Item storage item = staking[_contract][_tokenId];
      require(item.owner == msg.sender, "Permission denied");
      require(!item.listing, "Already listed");

      item.listing = true;
      
      emit Listing(_contract, msg.sender, _tokenId);
    }


    /**
     * @dev  token id 下架 
     * @param _contract 合约地址
     * @param _tokenId token id
     */
    function delisting(address _contract, uint256 _tokenId) external {
      Item storage item = staking[_contract][_tokenId];
      require(item.owner == msg.sender, "Permission denied");
      require(item.listing, "Already delisted");

      item.listing = false;

      emit Delisting(_contract, msg.sender, _tokenId);
    }

    /**
     * @dev 赎回 token id
     * @param _contract 合约地址
     * @param _tokenId token id
     */
    function unstake(address _contract, uint256 _tokenId) external {
      Item memory item = staking[_contract][_tokenId];
      require(item.owner != address(0), "Not exists");
      require(msg.sender == item.owner, "Permission denied");
      require(!item.listing, "Listing");
      
      delete staking[_contract][_tokenId];

      IERC721(_contract).safeTransferFrom(address(this), msg.sender, _tokenId);
      
      emit Unstake(_contract, msg.sender, _tokenId);
    }

    /**
     * @dev 质押 token id 并上架
     * @param _contract 合约地址
     * @param _tokenId token id
     */
    function stake(
      address _contract, 
      uint256 _tokenId) external {
      require(staking[_contract][_tokenId].owner == address(0), "Already exists");

      // transfer token
      IERC721(_contract).safeTransferFrom(msg.sender, address(this), _tokenId);

      staking[_contract][_tokenId] = Item(msg.sender, _tokenId, true);

      emit Stake(msg.sender, _contract, _tokenId);
    }

    /**
     * @dev  设置手续费
     * @param _free_numerator 手续费分子
     * @param _free_denominator 手续费分母
     */
    function setFree(uint256 _free_numerator, uint256 _free_denominator) external onlyOwner {
      free_numerator = _free_numerator;
      free_denominator = _free_denominator;
    }


    /**
     * @dev  设置紧急情况
     * @param _emergent 紧急情况
     */
    function setEmergent(bool _emergent) external onlyOwner {
      emergent = _emergent;
    }

    /**
     * @dev  提现ETH
     * @param to 提现目标地址
     */
    function withdrawalETH(address to) external onlyOwner {
      require(to != address(0), "To address is zero address");
      payable(to).transfer(address(this).balance);

      emit WithdrawalETH(msg.sender, address(this).balance);
    }

    /**
     * @dev  提现Token
     * @param to 提现目标地址
     */
    function withdrawalToken(address to) external onlyOwner {
      require(to != address(0), "To address is zero address");
      uint256 balance = IERC20(token).balanceOf(address(this));
      IERC20(token).transfer(to, balance);

      emit WithdrawalToken(msg.sender, balance);
    }

    /**
     * @dev  参数hash
     * @param _param 参数结构体
     */
    function hashParam(Param memory _param) private view returns (bytes32) {
        return keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            keccak256(abi.encode(
                    PARAM_TYPE_HASH,
                    _param._contract,
                    _param.tokenId,
                    _param.numerator,
                    _param.owner
                )))
        );
    }


    /**
     * @dev  验证链下签名链上验证
     * @param signature 签名
     * @param _param 参数结构体
     */
    function verifyToAddress(bytes memory signature, Param memory _param) private view returns (address) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return ecrecover(hashParam(_param), v, r, s);
        } else {
            return address(0);
        }
        
    }

    /**
     * @dev  紧急情况赎回NFT
     * @param _contract 合约地址
     * @param _tokenId token id
     */
    function emergentUnstak(address _contract, uint256 _tokenId) external {
      require(emergent, "No open emergent");

      Item memory item = staking[_contract][_tokenId];
      require(msg.sender == item.owner, "No promission");
      
      delete staking[_contract][_tokenId];

      IERC721(_contract).safeTransferFrom(address(this), msg.sender, _tokenId);
      emit EmergentUnstak(_contract, msg.sender, _tokenId);
    }

    receive() external payable {}

    function onERC721Received(
      address _operator, 
      address _from, 
      uint256 _tokenId, 
      bytes memory _data) public pure override returns(bytes4 value) {
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));

    }
}