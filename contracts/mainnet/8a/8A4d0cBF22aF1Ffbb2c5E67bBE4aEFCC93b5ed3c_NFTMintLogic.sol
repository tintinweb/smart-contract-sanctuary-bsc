/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

interface IERC20 {
    function totalSupply() external view returns(uint256);

    function balanceOf(address account) external view returns(uint256);

    function transfer(address recipient, uint256 amount)
    external
    returns(bool);

    function allowance(address owner, address spender)
    external
    view
    returns(uint256);

    function approve(address spender, uint256 amount) external returns(bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns(bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    function burnFrom(address user, uint256 amount) external;
}

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);
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
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
	
	function mint(address value, uint256 mintAmount) external;
    function totalSupply() external view returns (uint256);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract NFTMintLogic is Ownable {

	address public nftBase = 0xb42AEDdE71787C4269fEC06e53Ebc62Ea9149733;
    address public whitelistTicket = 0x2231e659BF1D4d81a334cCf770e45e48A39d39AF;
    uint256 public cap = 510;
	uint256 public nftPrice = 0.3 ether;
    uint256 public whitelistPrice = 0.3 ether;
    uint256 public reserved = 15;
    uint256 public reservedMinted = 0;
    uint256 public pauseGate = 0;
    uint256 public whitelistPauseGate = 0;
    uint256 public transactionLimit = 20;

    uint256 private counter = 1;



    function buyNFT(uint256 _mintAmount) public payable {

	IERC721 ab = IERC721(nftBase);
    require(ab.totalSupply() + _mintAmount <= cap);
    require(pauseGate == 1);
    require(_mintAmount > 0);
    require(msg.value >= nftPrice * _mintAmount);
    require(_mintAmount <= transactionLimit);
    ab.mint(msg.sender, _mintAmount);
  }

  function adminMint(address account, uint256 amount) external onlyOwner {
	IERC721 ab = IERC721(nftBase);
    require(ab.totalSupply() + amount <= cap);
    require(reservedMinted + amount <= reserved);
    require(amount <= transactionLimit);
	ab.mint(account,amount);
    reservedMinted = reservedMinted + amount;
  }
    function setPauseGate(uint256 pause) external onlyOwner {
        pauseGate = pause;
    }

    function setWhitelistPauseGate(uint256 pause) external onlyOwner {
        whitelistPauseGate = pause;
    }

   function whiteListMint(uint256 amount) external payable {
    IERC721 ab = IERC721(nftBase);
    IERC20 wt = IERC20(whitelistTicket);
    require(whitelistPauseGate == 1);
    require(amount <= 20);
    require(ab.totalSupply() + amount <= cap);
    require(msg.value >= nftPrice * amount);
    require(amount <= transactionLimit);
    wt.burnFrom(msg.sender,amount * 1e18);
    ab.mint(msg.sender,amount);
  }
	function setNFTContract(address nftContract) external onlyOwner {
	nftBase = nftContract;
  }
	function setPrice(uint256 price) external onlyOwner {
	nftPrice = price;
  }
    function setWlPrice(uint256 price) external onlyOwner {
    whitelistPrice = price;
  }
    function setWlTokenAddr(address wltoken) external onlyOwner {
    whitelistTicket = wltoken;
  }
    function setCap(uint256 newCap) external onlyOwner {
    cap = newCap;
  }
    function setReserved(uint256 newValue) external onlyOwner {
    reserved = newValue;
  }
    function withdrawFTM(uint256 amount) onlyOwner public {
    payable(owner()).transfer(amount);
  }
}