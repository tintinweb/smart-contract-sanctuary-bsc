/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
      return interfaceId == type(IERC165).interfaceId;
    }
}
 library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
       if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool _approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}


interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

 interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}


interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}


interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function tokenByIndex(uint256 index) external view returns (uint256);
}
library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
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
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
 library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    function toString(uint256 value) internal pure returns (string memory) {
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

  contract ERC721A is
      Context,
      ERC165,
      IERC721,
      IERC721Metadata,
      IERC721Enumerable
      {
    using Address for address;
    using Strings for uint256;

    struct TokenOwnership {
      address addr;
      uint64 startTimestamp;
    }

    struct AddressData {
      uint128 balance;
      uint128 numberMinted;
    }

    uint256 private currentIndex = 1;

    uint256 internal immutable collectionSize;
    uint256 internal maxBatchSize = 50;

    string private _name;

    string private _symbol;


    mapping(uint256 => TokenOwnership) private _ownerships;

    mapping(address => AddressData) private _addressData;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;


    

    constructor(
      string memory name_,
      string memory symbol_,
      uint256 maxBatchSize_,
      uint256 collectionSize_
    ) {
      require(
        collectionSize_ > 0,
        "ERC721A: collection must have a nonzero supply"
      );
      require(maxBatchSize_ > 0, "ERC721A: max batch size must be nonzero");
      _name = name_;
      _symbol = symbol_;
      maxBatchSize = maxBatchSize_;
      collectionSize = collectionSize_;
    }

    function totalSupply() public view override returns (uint256) {
      return currentIndex -1;
    }

    function tokenByIndex(uint256 index) public view override returns (uint256) {
      require(index < totalSupply()+1, "ERC721A: global index out of bounds");
      return index;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index)
      public
      view
      override
      returns (uint256)
    {
      require(index < balanceOf(owner), "ERC721A: owner index out of bounds");
      uint256 numMintedSoFar = totalSupply()+1;
      uint256 tokenIdsIdx = 0;
      address currOwnershipAddr = address(0);
      for (uint256 i = 0; i <numMintedSoFar; i++) {
        TokenOwnership memory ownership = _ownerships[i];
        if (ownership.addr != address(0)) {
          currOwnershipAddr = ownership.addr;
        }
        if (currOwnershipAddr == owner) {
          if (tokenIdsIdx == index) {
            return i;
          }
          tokenIdsIdx++;
        }
      }
      revert("ERC721A: unable to get token of owner by index");
    }

    function supportsInterface(bytes4 interfaceId)
      public
      view
      virtual
      override(ERC165, IERC165)
      returns (bool)
    {
      return
        interfaceId == type(IERC721).interfaceId ||
        interfaceId == type(IERC721Metadata).interfaceId ||
        interfaceId == type(IERC721Enumerable).interfaceId ||
        super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view override returns (uint256) {
      require(owner != address(0), "ERC721A: balance query for the zero address");
      return uint256(_addressData[owner].balance);
    }

    function _numberMinted(address owner) internal view returns (uint256) {
      require(
        owner != address(0),
        "ERC721A: number minted query for the zero address"
      );
      return uint256(_addressData[owner].numberMinted);
    }

    function ownershipOf(uint256 tokenId)
      internal
      view
      returns (TokenOwnership memory)
    {
      require(_exists(tokenId), "ERC721A: owner query for nonexistent token");

      uint256 lowestTokenToCheck;
      if (tokenId >= maxBatchSize) {
        lowestTokenToCheck = tokenId - maxBatchSize + 1;
      }

      for (uint256 curr = tokenId; curr >= lowestTokenToCheck; curr--) {
        TokenOwnership memory ownership = _ownerships[curr];
        if (ownership.addr != address(0)) {
          return ownership;
        }
      }

      revert("ERC721A: unable to determine the owner of token");
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
      return ownershipOf(tokenId).addr;
    }

    function name() public view virtual override returns (string memory) {
      return _name;
    }

    function symbol() public view virtual override returns (string memory) {
      return _symbol;
    }

    function tokenURI(uint256 tokenId)
      public
      view
      virtual
      override
      returns (string memory)
    {
      require(
        _exists(tokenId),
        "ERC721Metadata: URI query for nonexistent token"
      );

      string memory baseURI = _baseURI();
      return
        bytes(baseURI).length > 0
          ? string(abi.encodePacked(baseURI, tokenId.toString()))
          : "";
    }

    function _baseURI() internal view virtual returns (string memory) {
      return "";
    }

    function approve(address to, uint256 tokenId) public override {
      address owner = ERC721A.ownerOf(tokenId);
      require(to != owner, "ERC721A: approval to current owner");

      require(
        _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
        "ERC721A: approve caller is not owner nor approved for all"
      );

      _approve(to, tokenId, owner);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {
      require(_exists(tokenId), "ERC721A: approved query for nonexistent token");

      return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public override {
      require(operator != _msgSender(), "ERC721A: approve to caller");

      _operatorApprovals[_msgSender()][operator] = approved;
      emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator)
      public
      view
      virtual
      override
      returns (bool)
    {
      return _operatorApprovals[owner][operator];
    }

    function transferFrom(
      address from,
      address to,
      uint256 tokenId
    ) public override {
      _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
      address from,
      address to,
      uint256 tokenId
    ) public override {
      safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
      address from,
      address to,
      uint256 tokenId,
      bytes memory _data
    ) public override {
      _transfer(from, to, tokenId);
      require(
        _checkOnERC721Received(from, to, tokenId, _data),
        "ERC721A: transfer to non ERC721Receiver implementer"
      );
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
      return tokenId < currentIndex;
    }


    function _safeMint(address to, uint256 quantity) internal {
      _safeMint(to, quantity, "");
    }

    function _safeMint(
      address to,
      uint256 quantity,
      bytes memory _data
    ) internal {
      uint256 startTokenId = currentIndex;
      require(to != address(0), "ERC721A: mint to the zero address");
      require(!_exists(startTokenId), "ERC721A: token already minted");
      require(quantity <= maxBatchSize, "ERC721A: quantity to mint too high");

      _beforeTokenTransfers(address(0), to, startTokenId, quantity);

      AddressData memory addressData = _addressData[to];
      _addressData[to] = AddressData(
        addressData.balance + uint128(quantity),
        addressData.numberMinted + uint128(quantity)
      );
      _ownerships[startTokenId] = TokenOwnership(to, uint64(block.timestamp));

      uint256 updatedIndex = startTokenId;

      for (uint256 i = 1; i <=quantity; i++) {
        emit Transfer(address(0), to, updatedIndex);
        require(
          _checkOnERC721Received(address(0), to, updatedIndex, _data),
          "ERC721A: transfer to non ERC721Receiver implementer"
        );
        
        updatedIndex++;
        
      }

      currentIndex = updatedIndex;
      _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    function _transfer(
      address from,
      address to,
      uint256 tokenId
    ) private {
      TokenOwnership memory prevOwnership = ownershipOf(tokenId);

      bool isApprovedOrOwner = (_msgSender() == prevOwnership.addr ||
        getApproved(tokenId) == _msgSender() ||
        isApprovedForAll(prevOwnership.addr, _msgSender()));

      require(
        isApprovedOrOwner,
        "ERC721A: transfer caller is not owner nor approved"
      );

      require(
        prevOwnership.addr == from,
        "ERC721A: transfer from incorrect owner"
      );
      require(to != address(0), "ERC721A: transfer to the zero address");
    
      


      _beforeTokenTransfers(from, to, tokenId, 1);

      _approve(address(0), tokenId, prevOwnership.addr);

      _addressData[from].balance -= 1;
      _addressData[to].balance += 1;
      _ownerships[tokenId] = TokenOwnership(to, uint64(block.timestamp));

      uint256 nextTokenId = tokenId + 1;
      if (_ownerships[nextTokenId].addr == address(0)) {
        if (_exists(nextTokenId)) {
          _ownerships[nextTokenId] = TokenOwnership(
            prevOwnership.addr,
            prevOwnership.startTimestamp
          );
        }
      }

      emit Transfer(from, to, tokenId);
      _afterTokenTransfers(from, to, tokenId, 1);
    }

    function _approve(
      address to,
      uint256 tokenId,
      address owner
    ) private {
      _tokenApprovals[tokenId] = to;
      emit Approval(owner, to, tokenId);
    }

    uint256 public nextOwnerToExplicitlySet = 0;

    function _setOwnersExplicit(uint256 quantity) internal {
      uint256 oldNextOwnerToSet = nextOwnerToExplicitlySet;
      require(quantity > 0, "quantity must be nonzero");
      uint256 endIndex = oldNextOwnerToSet + quantity - 1;
      if (endIndex > collectionSize - 1) {
        endIndex = collectionSize - 1;
      }
      require(_exists(endIndex), "not enough minted yet for this cleanup");
      for (uint256 i = oldNextOwnerToSet; i <= endIndex; i++) {
        if (_ownerships[i].addr == address(0)) {
          TokenOwnership memory ownership = ownershipOf(i);
          _ownerships[i] = TokenOwnership(
            ownership.addr,
            ownership.startTimestamp
          );
        }
      }
      nextOwnerToExplicitlySet = endIndex + 1;
    }

    function _checkOnERC721Received(
      address from,
      address to,
      uint256 tokenId,
      bytes memory _data
    ) private returns (bool) {
      if (to.isContract()) {
        try
          IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data)
        returns (bytes4 retval) {
          return retval == IERC721Receiver(to).onERC721Received.selector;
        } catch (bytes memory reason) {
          if (reason.length == 0) {
            revert("ERC721A: transfer to non ERC721Receiver implementer");
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

    function _beforeTokenTransfers(
      address from,
      address to,
      uint256 startTokenId,
      uint256 quantity
    ) internal virtual {}

    function _afterTokenTransfers(
      address from,
      address to,
      uint256 startTokenId,
      uint256 quantity
    ) internal virtual {}
  }
 abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

   
    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
interface IBEP20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function _approve(address owner, address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
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
abstract contract Pausable is Context {

    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
      _paused = true;
      emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
      _paused = false;
      emit Unpaused(_msgSender());
    }
}



  contract THEVIKINGS is ERC721A, Ownable, Pausable{

    using SafeMath for uint256;

    uint256 public constant MAX_SUPPLY = 5555;

    string public prefixURI = "Place here Ipfs link";


    mapping(address=>uint256) public userMintedNFT;
    // ---------------------------------------------
      using SafeMath for uint256;
    IBEP20 public ULE;
    IPancakeRouter01 public Router;
    IPancakePair public bnbbusdlp;
    address public WETH;


    uint256 public PoolBNBamount;
    uint256 public PoolPercentage = 50;
    uint256 public count;
    uint256 public SwapandLiquifyCount = 4;
    address public LpReceiver;
    address public MaticReceiver;
    uint256 HalfToken;
    uint256 ContractBalance;
    IBEP20 public Token;
  IBEP20 public BUSD;

    constructor(
      IBEP20 _ULETOken, IBEP20 _BUSD, IPancakeRouter01 _Router,address _LpReceiver_, address _MaticReceiver,
      IPancakePair _bnbtobusd) ERC721A("The Vikings", "TVK",10, 5555)
    {
       ULE = _ULETOken;
       Router = _Router;
       WETH = Router.WETH();
      BUSD =_BUSD;
       LpReceiver = _LpReceiver_;
       MaticReceiver = _MaticReceiver;
       bnbbusdlp = _bnbtobusd;
    }
   
    // 1st sale
    function Minting(uint256 _count, uint256 _ULEtokens) public whenNotPaused payable
    {
        // require(userMintedNFT[msg.sender] + _count <= 5,"USER_MAX_LIMIT_REACHED");
        _safeMint(msg.sender, _count);
        userMintedNFT[msg.sender] += _count;
        Swap(_ULEtokens);
    }
    function changeBatch(uint256 _maxBatchSize) public onlyOwner {
      maxBatchSize = _maxBatchSize;
    }

    // function to get tokenIds from sales
    function WalletOfOwner(address _owner) public view returns (uint256[] memory) {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
        tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }


    function setPrefixURI(string calldata _uri) external onlyOwner {
        prefixURI = _uri;
    }



    function _toString(uint256 value) internal pure returns (string memory ptr) {
        assembly {
            ptr := add(mload(0x40), 128)
            mstore(0x40, ptr)
            let end := ptr
            for { 
                let temp := value
                ptr := sub(ptr, 1)
                mstore8(ptr, add(48, mod(temp, 10)))
                temp := div(temp, 10)
            } temp { 
                temp := div(temp, 10)
            } {
                ptr := sub(ptr, 1)
                mstore8(ptr, add(48, mod(temp, 10)))
            }
            let length := sub(end, ptr)
            ptr := sub(ptr, 32)
            mstore(ptr, length)
        }
    }
//"ipfs://Qme4ZqvH48SRXbUME6rZqgqnyGqAqdS1kvVYqR1CFRkgdT/"
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        return string(abi.encodePacked(prefixURI,_toString(tokenId),".json"));
    }


     function Swap(uint256 _tokens)
    public 
    payable
    {
        require(ULE.transferFrom(_msgSender(),address(this),_tokens),"Approve Token First");
        require(msg.value > 0," Enter BNB Amount ");
        uint256 BNBamount = msg.value;
        PoolBNBamount += (BNBamount.mul(PoolPercentage)).div(100);

        bool pool;
        if(count == SwapandLiquifyCount)
        {
        uint256 half = PoolBNBamount/2;
        uint256[] memory returnValues = swapExactETHForToken(half,address(ULE));
        ULE.approve(address(Router), returnValues[1]);
        addLiquidity(returnValues[1],half);

        ///Transfer Half Token to other contract

        ContractBalance = ULE.balanceOf(address(this));
        HalfToken = ContractBalance.div(2);
        ULE.approve(address(Router), HalfToken);
        swapExactTokenForETH(HalfToken);
        pool = true;
        }
        count++;
        if(pool) {
            count = 0;
            PoolBNBamount = 0;
        }
    }

    function swapExactETHForToken(uint256 value, address token) public payable  returns (uint[] memory amounts )  
    {
        address[] memory path = new address[](2);
        path[0] = Router.WETH();
        path[1] = token;
        return Router.swapExactETHForTokens{value:value}(
        0, 
        path,
        address(this), 
        block.timestamp
        );
    }

    function addLiquidity(uint256 _amount,uint256 half) public payable
    {
        Router.addLiquidityETH{value:half}(
            address(ULE),
            _amount,
            0,
            0,
            LpReceiver,
            block.timestamp
        );
    }

    function swapExactTokenForETH(uint256 _tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(ULE);
        path[1] = Router.WETH();
        Router.swapExactTokensForETH(
            _tokenAmount,
            0,
            path,
            MaticReceiver,
            block.timestamp
        );
    }

  /////////////////////////////////////////////////////////////////////////////
  function BNBperBUSD() public view returns(uint256 )
    {
       (uint256 a,uint256 b,uint256 c) =  bnbbusdlp.getReserves();
       uint256 z = (b*1e18)/a;
       return z;
    }

    uint256 PRICE = 50 ether;
      function BUSDto_BNB() public view returns(uint256 )
    {
        return PRICE.mul(BNBperBUSD()).div(1 ether);
    }
////////////////////////////////////////////////////////////////////////////



    function pauseMint() public onlyOwner{
    _pause(); 
    } 

    function resumeMint() public onlyOwner{
    _unpause(); 
    } 

     function UpdateCondition(uint256 SwapandLiquifyCount_)
    public
    onlyOwner
    {SwapandLiquifyCount = SwapandLiquifyCount_;}
    
    function withdraw()
    public
    onlyOwner
    {payable(msg.sender).transfer(address(this).balance);}

    function withdrawToken(uint256 _amount)
    public
    onlyOwner
    {ULE.transfer(msg.sender, _amount);}

    receive() external payable {}

    
  }

  /*

  [
      "0x0A098Eda01Ce92ff4A4CCb7A4fFFb5A43EBC70DC",
      "0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c",
      "0x12E8613F1d980FD0543ECEBB2dab9533C589250F",
      "0x12E8613F1d980FD0543ECEBB2dab9533C589250F",
      "0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB",
      "0x583031D1113aD414F02576BD6afaBfb302140225",
      "0xdD870fA1b7C4700F2BD7f44238821C26f7392148",
      "0xAD4f1d02ad3e819AD86D3eD27dfd13F31A19a09a",
      "0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C",
      "0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C"
  ]

  */



// https://docs.google.com/document/d/1iZiYCBSuZfjnkOeh-UsEuZ6S9AmGBZvDiPAUMDCeJaM/edit