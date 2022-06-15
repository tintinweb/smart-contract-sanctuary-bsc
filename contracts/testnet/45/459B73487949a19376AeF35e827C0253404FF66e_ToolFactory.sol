/**
 *Submitted for verification at BscScan.com on 2022-06-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-10
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "e5");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "e6");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "e7");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "e8");
        uint256 c = a / b;
        return c;
    }
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
        require(owner() == _msgSender(), "k002");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "k003");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "k004");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}




contract ToolFactory is ReentrancyGuard, Ownable {
    
    using SafeMath for uint256;

    mapping (uint256=>address) public addressPledge;

    mapping (address=>uint256[]) public addressPledgeList;

    mapping (address=>uint256) public addressPledgeNum;

    uint256 public totalPledge;

    IERC721 public _nftToken;

    constructor() Ownable() {
        
    }

    function pledgeNFT(uint256 _tokenId) public returns (bool){
        _nftToken.transferFrom(msg.sender,address(this),_tokenId);
        addressPledge[_tokenId]=msg.sender;
        addressPledgeList[msg.sender].push(_tokenId);
        addressPledgeNum[msg.sender]++;
        totalPledge++;
        return true;
    }


    function withdrawPledge(uint256 _tokenId,address _to) public returns (bool){
        require(addressPledge[_tokenId]==msg.sender,"Not pledged");
        _nftToken.transferFrom(address(this),_to,_tokenId);
        addressPledge[_tokenId]=address(0);
        addressPledgeNum[msg.sender]--;
        totalPledge--;
        return true;
    }

    function getAddressTokenIds(address _address) public view returns(uint256[] memory){
        uint256[] memory list=addressPledgeList[_address];
        uint256[] memory result = new uint256[](addressPledgeNum[msg.sender]);
        uint256 resultIndex=0;
        for(uint i=0;i<list.length;i++){
              if(addressPledge[list[i]]==msg.sender){
                  result[resultIndex]=list[i];
                  resultIndex++;
              }
        }
        return result;
    }


    function setNftToken(IERC721 _token) public onlyOwner returns (bool){
        _nftToken=_token;
        return true;
    }
  
    function claimTokens(address _token, uint256 _amount) public onlyOwner returns (bool){
        if (_token == address(0) && address(this).balance > 0) {
            payable(msg.sender).transfer(address(this).balance); 
            return true;
        } else if (_token != address(0) && IERC20(_token).balanceOf(address(this)) > 0) {
            IERC20(_token).transfer(msg.sender, _amount);
            return true;
        } else {
            return false;
        }
    }
    receive() payable external {}
}