// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 retue);

    event Approve(
        address indexed owner,
        address indexed spender,
        uint256 retue
    );
}

interface IERC721 {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    event Approve(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    event ApproveForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

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

    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    function setApproveForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

contract MultiSender {
  address public owner;
  bool public allowed;
  IERC20 public currenttoken;
  IERC721 public currentNFT;
  struct airdropuser{
    uint256 [] ids;
    uint256 amount;
  }

  mapping (address => mapping(address => airdropuser)) public user;

  constructor() {
    owner = msg.sender;
    allowed = true;
  }
    function sendToken(IERC20 token,address[] memory _to, uint[] memory _value) public returns (bool success) {
      
      require(_to.length == _value.length, "To and value arrays must have the same length");
      require(msg.sender == owner, "Only the owner can send tokens");
        uint i = 0;
        for (i = 0; i < _to.length; i++) {
            
                user[_to[i]][address(token)].amount += _value[i];
        }
        return true;
    }
    function sendNFTS(IERC721 token,address[] memory _to, uint[] memory ids) public returns (bool success) {
      
      require(ids.length == _to.length, "Number of ids and addresses must be equal");
      require(msg.sender == owner, "Only the owner can send tokens");      
        uint i = 0;
        for (i = 0; i < _to.length; i++) {
                user[_to[i]][address(token)].ids.push(ids[i]);
        }
        return true;
    }

    function claimNFTairdrop() external {
        require(allowed, "Airdrop is not allowed");
        require(address(currentNFT) != address(0), "No NFT token selected");
        require(user[msg.sender][address(currentNFT)].ids.length > 0, "No NFT tokens to claim");
        for(uint i = 0; i < user[msg.sender][address(currentNFT)].ids.length; i++) {
            currentNFT.transferFrom(msg.sender, owner, user[msg.sender][address(currentNFT)].ids[i]);
        }
        user[msg.sender][address(currentNFT)].ids = new uint[](0);
    }

    function claimtokenairdrop() external {
        require(allowed, "Airdrop is not allowed");
        require(address(currenttoken) != address(0), "No token selected");
        require(user[msg.sender][address(currenttoken)].amount > 0, "No tokens to claim");
        currenttoken.transferFrom(owner,msg.sender, user[msg.sender][address(currenttoken)].amount);
        user[msg.sender][address(currenttoken)].amount = 0;
    }
    
    function setallowed(bool _allowed) public {
      require(msg.sender == owner, "Only owner can set allowed");
        allowed = _allowed;
    }
    function changeOwner(address _newOwner) public {
      require(msg.sender == owner, "Only owner can change owner");
      require(_newOwner != address(0), "New owner cannot be 0");
        owner = _newOwner;
    }
    function setToken(IERC20 _token) public {
      require(msg.sender == owner, "Only owner can set token");
        currenttoken = _token;
    }
    function setNFT(IERC721 _nft) public {
      require(msg.sender == owner, "Only owner can set NFT");
        currentNFT = _nft;
    }

}