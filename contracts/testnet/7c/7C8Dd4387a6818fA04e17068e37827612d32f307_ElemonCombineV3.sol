// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "./interfaces/IERC20.sol";
import "./interfaces/IERC721.sol";
import "./interfaces/IElemonNFT.sol";
import "./utils/ReentrancyGuard.sol";
import "./utils/Runnable.sol";

contract ElemonCombineV3 is
    ReentrancyGuard,
    Runnable
{
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    uint256 public _combinePrice;

    address public _recipientTokenAddress;
    IElemonNFT public _elemonNFT;
    IERC20 public _paymentToken;

    constructor(
        address paymentTokenAddress,
        address recipientTokenAddress,
        address elemonNFTAddress
    ){
        _paymentToken = IERC20(paymentTokenAddress);
        _recipientTokenAddress = recipientTokenAddress;
        _elemonNFT = IElemonNFT(elemonNFTAddress);

        _combinePrice = 10000000000000000000;
    }

    function combine(uint256 tokenId1, uint256 tokenId2, uint256 option) external nonReentrant whenRunning {
         require(
            _recipientTokenAddress != address(0),
            "Recepient address is not setted"
        );
        require(tokenId1 > 0, "TokenId1 is invalid");
        require(tokenId2 > 0, "tokenId2 is invalid");
        require(option <= 2, "Invalid option");

        require(_paymentToken.transferFrom(_msgSender(), _recipientTokenAddress, _combinePrice), "Can not transfer payment token");

        //Get user NFTs
        _elemonNFT.safeTransferFrom(_msgSender(), BURN_ADDRESS, tokenId1);
        _elemonNFT.safeTransferFrom(_msgSender(), BURN_ADDRESS, tokenId2);
        uint256 newTokenId = _elemonNFT.mint(_msgSender());

        emit Combined(_msgSender(), tokenId1, tokenId2, newTokenId, option, block.timestamp);
    }

    function setCombinePrice(uint256 value) public onlyOwner {
        _combinePrice = value;
    }

    function setPaymentToken(address paymentTokenAddress) external onlyOwner {
        _paymentToken = IERC20(paymentTokenAddress);
    }

    function setRecepientTokenAddress(address recipientTokenAddress)
        external
        onlyOwner
    {
        _recipientTokenAddress = recipientTokenAddress;
    }

    function setElemonNFT(address newAddress) external onlyOwner {
        _elemonNFT = IElemonNFT(newAddress);
    }

    function batchWithdrawNft(uint256[] memory tokenIds, address recipient) external onlyOwner{
        require(recipient != address(0), "recipient is zero address");
        require(tokenIds.length > 0, "tokenIds is empty");
        for (uint256 index = 0; index < tokenIds.length; index++) {
            _elemonNFT.safeTransferFrom(address(this), recipient, tokenIds[index]);
        }
    }

    function withdrawToken(
        address tokenAddress,
        address recepient,
        uint256 value
    ) public onlyOwner {
        IERC20(tokenAddress).transfer(recepient, value);
    }

    event Combined(address account, uint256 tokenId1, uint256 tokenId2, uint256 newTokenId, uint256 option, uint256 time);
}

//SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "./Ownable.sol";

contract Runnable is Ownable{
    modifier whenRunning{
        require(_isRunning, "Paused");
        _;
    }
    
    modifier whenNotRunning{
        require(!_isRunning, "Running");
        _;
    }
    
    bool public _isRunning;
    
    constructor(){
        _isRunning = true;
    }
    
    function toggleRunning() public onlyOwner{
        _isRunning = !_isRunning;
    }
}

//SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

abstract contract ReentrancyGuard {
    uint256 public constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 internal _status;

    constructor() {
         _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

//SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import './Context.sol';

contract Ownable is Context {
  address public _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor () {
     _owner = _msgSender();
     emit OwnershipTransferred(address(0), _msgSender());
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

//SPDX-License-Identifier: MIT

pragma solidity 0.8.9;


contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor () { }

  function _msgSender() internal view returns (address payable) {
    return payable(msg.sender);
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
  
  function _now() internal view returns (uint256) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return block.timestamp;
  }
}

//SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface IElemonNFT{
    function mint(address to) external returns(uint256);
    function setContractOwner(address newOwner) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address);
}

//SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "./IERC165.sol";

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    
    function isExisted(uint256 tokenId) external view returns(bool);
}

//SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

//SPDX-License-Identifier: MIT

pragma solidity 0.8.9;
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}