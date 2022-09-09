/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

pragma solidity 0.5.8;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
 
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }
 
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
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

interface ERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function lpUserListIndex() external returns (uint256);
    function lpUserList(uint256 index) external returns (address);
}

interface IERC721 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function totalSupply() external view returns (uint256);
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

contract Ownable {
  address public owner;
  address public controler;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  modifier onlyControler() {
    require(msg.sender == controler);
    _;
  }
  
  modifier onlySelf() {
    require(address(msg.sender) == address(tx.origin));
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract Minning is Ownable {
    using SafeMath for uint256;

    address CSTokenAddress = 0x779B0e440c087377212dB4B5c7Cc32A5243bcdAa;
    address ZCTokenAddress = 0x5F7e3BE080D3d0d6e3027BbC5f1Ed9C2dfd0759e;
    address NFTAddress = 0xE35710Df3D6390076Ca423FAc45B6f2A86F095cE;

    address CSTokenPairAddress = 0x647ec4CCB86655242CBEf2F09E71F1A6F8Ea4b67;
    address ZCTokenPairAddress = 0x8c8172A7472873A8F527C40dbEF1B53AEb6fc891;

    address public blackholeAccount = 0x0000000000000000000000000000000000000001;//黑洞地址

    ERC20 CSToken;
    ERC20 ZCToken;
    IERC721 NFT;

    ERC20 CSTokenPair;
    ERC20 ZCTokenPair;

    constructor(
      
    ) public {
        controler = msg.sender;

        CSToken = ERC20(CSTokenAddress);
        ZCToken = ERC20(ZCTokenAddress);
        NFT = IERC721(NFTAddress);
        CSTokenPair = ERC20(CSTokenPairAddress);
        ZCTokenPair = ERC20(ZCTokenPairAddress);
    }

    function receive_cs_usdt() public {
        ZCToken.transfer(msg.sender,mine_cs_usdt[msg.sender]);
        mine_cs_usdt[msg.sender] = 0;
    }

    function receive_cs_zc() public {
        ZCToken.transfer(msg.sender,mine_cs_zc[msg.sender]);
        mine_cs_zc[msg.sender] = 0;
    }
    
    function receive_nft() public {
        ZCToken.transfer(msg.sender,mine_nft[msg.sender]);
        mine_nft[msg.sender] = 0;
    }

    function getMineNum_cs_usdt() public view returns(uint256) {
        return mine_cs_usdt[msg.sender];
    }

    function getMineNum_cs_zc() public view returns(uint256) {
        return mine_cs_zc[msg.sender];
    }

    function getMineNum_nft() public view returns(uint256) {
        return mine_nft[msg.sender];
    }

    mapping (address => uint256) public mine_cs_usdt;
    mapping (address => uint256) public mine_cs_zc;
    mapping (address => uint256) public mine_nft;

    uint256 cs_usdt_perDay = 200000000000000000000;
    uint256 cs_zc_perDay = 266666666666666700000;
    uint256 nft_perDay = 173333333333333300000;

    uint256 allLp;
    uint256 lpUserListIndex;
    uint256 mine;

    function calCS() public onlyControler {
        allLp = CSTokenPair.totalSupply();
        lpUserListIndex = CSToken.lpUserListIndex();

        for(uint256 i=0;i<lpUserListIndex;i++){
            mine = cs_usdt_perDay.mul(CSTokenPair.balanceOf(CSToken.lpUserList(i))).div(allLp);
            mine_cs_usdt[CSToken.lpUserList(i)] = mine_cs_usdt[CSToken.lpUserList(i)].add(mine);
        }
    }

    function calZC() public onlyControler {
        allLp = ZCTokenPair.totalSupply();
        lpUserListIndex = ZCToken.lpUserListIndex();

        for(uint256 i=0;i<lpUserListIndex;i++){
            mine = cs_zc_perDay.mul(ZCTokenPair.balanceOf(ZCToken.lpUserList(i))).div(allLp);
            mine_cs_zc[ZCToken.lpUserList(i)] = mine_cs_zc[ZCToken.lpUserList(i)].add(mine);
        }
    }

    function calNFT() public onlyControler {
        allLp = NFT.totalSupply();
        mine = nft_perDay.div(allLp);
        for(uint256 i=1;i<allLp+1;i++){
            mine_nft[NFT.ownerOf(i)] = mine_nft[NFT.ownerOf(i)].add(mine);
        }
    }

    function updateAddress(address _CSTokenAddress,address _ZCTokenAddress,address _NFTAddress,address _CSTokenPairAddress,address _ZCTokenPairAddress) public onlyControler {
        CSTokenAddress = _CSTokenAddress;
        ZCTokenAddress = _ZCTokenAddress;
        NFTAddress = _NFTAddress;
        CSTokenPairAddress = _CSTokenPairAddress;
        ZCTokenPairAddress = _ZCTokenPairAddress;

        CSToken = ERC20(CSTokenAddress);
        ZCToken = ERC20(ZCTokenAddress);
        NFT = IERC721(NFTAddress);
        CSTokenPair = ERC20(CSTokenPairAddress);
        ZCTokenPair = ERC20(ZCTokenPairAddress);
    }

    function updatePerDay(uint256 _cs_usdt_perDay,uint256 _cs_zc_perDay,uint256 _nft_perDay) public onlyControler {
        cs_usdt_perDay = _cs_usdt_perDay;
        cs_zc_perDay = _cs_zc_perDay;
        nft_perDay = _nft_perDay;
    }

    //-------------------------------------------------
    function changeControler(address _controler) public onlyOwner onlySelf{
        controler = _controler;
    }
}