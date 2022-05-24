// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./AccessControl.sol";
import "./Pausable.sol";

interface MEAWNFT {

    function safeMint(address to, uint256 tokenId, string memory uri,uint256 valueNft) external;
    function checkSeedRound() external view returns(uint256);

    function checkPrivate1Round() external view returns(uint256);

    function checkPrivate2Round() external view returns(uint256);
}

interface MCoinToken {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferforinvester(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract MEAWNFTpool is Pausable, AccessControl {

    address private tokenNftAddress;
    address private tokenAddress;
    uint256 private _balance;
    uint256 private valueNft;
    string private uri;

    //0x8d63ecbd7fba9139d012d6108907b3085e91762e5794ddcd59db7235a2a5482f
    bytes32 public constant PAUSER_ROLE = keccak256("NFT_PAUSER_ROLE");
    // //0x3a5b873628a2c49bf313473942acc8932f6f84c76b74bf3db0e4d8b51277a623
    // bytes32 public constant MINTER_ROLE = keccak256("NFT_MINTER_ROLE");
    // //0x959a28df138ba991cc7d4b673b7e36093c3d5c35636e4d0fd1f66890fe06edfc
    // bytes32 public constant SETURI_ROLE = keccak256("NFT_SETURI_ROLE");

    constructor() {
      tokenAddress = 0x9D7f74d0C41E726EC95884E0e97Fa6129e3b5E99;
      tokenNftAddress = 0x358AA13c52544ECCEF6B0ADD0f801012ADAD5eE3;
      _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
      _grantRole(PAUSER_ROLE, msg.sender);
    //   _grantRole(MINTER_ROLE, msg.sender);
    //   _grantRole(SETURI_ROLE, msg.sender);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function setTokenAddress(address tokenaddress) public onlyRole(DEFAULT_ADMIN_ROLE) {
        tokenAddress = tokenaddress;
    }

    //จ่ายเงินเพื่อรับ NFT
    function buyNft(uint256 tokenId,uint256 amount) public {
    // function buyNft(uint256 amount) public {
        require(msg.sender != address(0), "transfer from the zero address");
        require(amount != 0, "amount can't zero");
        

        if( MEAWNFT(tokenNftAddress).checkSeedRound() != 0 && MEAWNFT(tokenNftAddress).checkSeedRound() >= 50000 && amount == 3500 * 10**18 ){ //100000
           uri = "ipfs://QmTRoCqLu2fzRZVxgUMy8A5SHgnrR73duihRQeZoSRtZnC/SEED-50k.jpg";
           valueNft = 50000;
        } else if (  MEAWNFT(tokenNftAddress).checkSeedRound() != 0 && MEAWNFT(tokenNftAddress).checkSeedRound() >= 100000 && amount == 7000 * 10**18 ) {
           uri = "ipfs://QmTRoCqLu2fzRZVxgUMy8A5SHgnrR73duihRQeZoSRtZnC/SEED-100k.jpg";
           valueNft = 100000;
        } else if ( MEAWNFT(tokenNftAddress).checkSeedRound() == 0 && MEAWNFT(tokenNftAddress).checkPrivate1Round() >= 50000 && amount == 3500 * 10**18 ) {
            uri = "ipfs://QmTRoCqLu2fzRZVxgUMy8A5SHgnrR73duihRQeZoSRtZnC/PV1-50K.jpg";
            valueNft = 50000;
        } else if ( MEAWNFT(tokenNftAddress).checkSeedRound() == 0 && MEAWNFT(tokenNftAddress).checkPrivate1Round() >= 100000 && amount == 7000 * 10**18 ) {
            uri = "ipfs://QmTRoCqLu2fzRZVxgUMy8A5SHgnrR73duihRQeZoSRtZnC/PV1-100K.jpg";
            valueNft = 100000;
        } else if ( MEAWNFT(tokenNftAddress).checkSeedRound() == 0 && MEAWNFT(tokenNftAddress).checkPrivate1Round() == 0 && MEAWNFT(tokenNftAddress).checkPrivate2Round() >= 50000 && amount == 3500 * 10**18 ) {
            uri = "ipfs://QmTRoCqLu2fzRZVxgUMy8A5SHgnrR73duihRQeZoSRtZnC/PV2-100K.jpg";
            valueNft = 50000;
        } else if ( MEAWNFT(tokenNftAddress).checkSeedRound() == 0 && MEAWNFT(tokenNftAddress).checkPrivate1Round() == 0 && MEAWNFT(tokenNftAddress).checkPrivate2Round() >= 100000 && amount == 7000 * 10**18 ) {
            uri = "ipfs://QmTRoCqLu2fzRZVxgUMy8A5SHgnrR73duihRQeZoSRtZnC/PV2-100K.jpg";
            valueNft = 100000;
        } else {
            require(bytes(uri).length != 0, "Not condition");
        }
        require(bytes(uri).length != 0, "error out of NFT");
        require(valueNft != 0, "error out of NFT by valueNft");
        MCoinToken(tokenAddress).transferFrom(msg.sender,address(this), amount);
        _balance += amount;
        MEAWNFT(tokenNftAddress).safeMint(msg.sender, tokenId, uri, valueNft);
    }



//ถอน
    function withdrawbyadmin(address to ,uint256 amount) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(amount <= _balance,"Not Enough Balance");
        require(to != address(0), "transfer to the zero address");
        
        MCoinToken(tokenAddress).transfer(to,amount);
        _balance -= amount;
    }

    function checkbalance() public view returns(uint256 balance) {
        return _balance;
    }

}