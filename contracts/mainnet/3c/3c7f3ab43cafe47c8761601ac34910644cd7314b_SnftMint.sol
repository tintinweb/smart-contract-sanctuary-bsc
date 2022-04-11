/**
 *Submitted for verification at BscScan.com on 2022-04-11
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC721 {
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
}

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface IERC721Enumerable is IERC721Metadata {
    function totalSupply() external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function tokenByIndex(uint256 index) external view returns (uint256);
}

interface SNFT is IERC721Enumerable {
    function mint(address to) external;
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract SnftMint is Context {
    uint256 public lplimit;
    uint256 public nftlimit;
    uint256 public coincost;

    address public coinlp;
    address public nftaddr;
    address public coinaddr;
    address public coindead;
    mapping(address => bool) public roles;

    constructor() {
        nftlimit = 500;
        coincost = 5 * 10 ** 18;
        lplimit = 10000000000000;
        roles[_msgSender()] = true;
        nftaddr = 0xeCCFb9296092a2DcedF85A98617A4Fdf75404071;
        coinaddr = 0xb3d728c6D10c1324ef4C3D3DE11c6B465d5C33D6;
        coindead = 0x000000000000000000000000000000000000dEaD;
        coinlp = 0x1858486b6bdB8f41E0281b2064B0BE963f655273;
    }

    function getInfo() public view returns(uint256[8] memory) {
        uint256[8] memory aaa = [
            nftlimit, coincost, lplimit,
            IERC20(coinaddr).balanceOf(_msgSender()),
            IERC20(coinaddr).allowance(_msgSender(), address(this)),
            IERC20(coinlp).balanceOf(_msgSender()),
            SNFT(nftaddr).balanceOf(_msgSender()),
            SNFT(nftaddr).totalSupply()];
        return aaa;
    }

    function doMint() public {
        SNFT snft = SNFT(nftaddr);
        require(snft.totalSupply() <= nftlimit);
        require(IERC20(coinlp).balanceOf(_msgSender()) >= lplimit);
        IERC20(coinaddr).transferFrom(_msgSender(), coindead, coincost);
        snft.mint(_msgSender());
    }

    function doMints(uint256 num) public {
        for (uint256 i=0; i<num; i++) {
            doMint();
        }
    }

    function setNum(uint256 _lmt, uint256 _cost, uint256 _lp) public {
        require(roles[_msgSender()], "SN: must have role");
        nftlimit = _lmt;
        coincost = _cost;
        lplimit = _lp;
    }

    function setAddr(address nft, address coin, address lp) public {
        require(roles[_msgSender()], "SN: must have role");
        nftaddr = nft;
        coinaddr = coin;
        coinlp = lp;
    }

    function setNftaddr(address val) public {
        require(roles[_msgSender()], "SN: must have role");
        nftaddr = val;
    }

    function setRole(address addr, bool val) public {
        require(roles[_msgSender()], "SN: must have role");
        roles[addr] = val;
    }

	function returnIn(address con, address addr, uint256 val) public {
        require(roles[_msgSender()] && addr != address(0) && val > 0);
        if (con == address(0)) {payable(addr).transfer(val);} 
        else {IERC20(con).transfer(addr, val);}
	}

}