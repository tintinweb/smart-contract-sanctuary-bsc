/**
 *Submitted for verification at BscScan.com on 2022-07-30
*/

pragma solidity ^0.8.0;
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract Owner {
    address private _owner;
    address private _pendingOwner;

    event NewOwner(address indexed owner);
    event NewPendingOwner(address indexed pendingOwner);

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "caller is not the owner");
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    function setPendingOwner(address account) external onlyOwner {
        require(account != address(0), "zero address");
        _pendingOwner = account;
        emit NewPendingOwner(_pendingOwner);
    }

    function becomeOwner() external {
        require(msg.sender == _pendingOwner, "not pending owner");
        _owner = _pendingOwner;
        _pendingOwner = address(0);
        emit NewOwner(_owner);
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IComLand721 {
    function minerEnable(address miner_, bool enable) external;
    function mintTYPE1(address recipient_) external payable returns (uint256);
    function mintTYPE2(address recipient_) external payable returns (uint256);
    function mintTYPE3(address recipient_) external payable returns (uint256);
    function mintTYPE4(address recipient_) external payable returns (uint256);
    function mintTYPE5(address recipient_) external payable returns (uint256);
}

contract NFTHelper  is Owner {

    using SafeMath for uint256;

    enum NFTType{COMLANDN,COMLANDR,COMLANDSR,COMLANDSSR,COMLANDSSSR}
    IComLand721 public nftAddress;
    IERC20 public token;
    address public tokenRecipientAddress;

    uint256 public price1=100000000000000000;
    uint256 public price2=200000000000000000;
    uint256 public price3=300000000000000000;
    uint256 public price4=400000000000000000;
    uint256 public price5=500000000000000000;


    constructor(address _nftAddress,address _token) {
       nftAddress=IComLand721(_nftAddress); 
       token=IERC20(_token);
       tokenRecipientAddress=msg.sender;
    }


    function buyNFT1(address _recipient,uint256 _nftAmount) external returns(uint256[] memory) {
        require(_nftAmount<=50,"exceeded limit");
         token.transferFrom(msg.sender, tokenRecipientAddress, price1.mul(_nftAmount));
          uint256[] memory nftIds = new uint256[](_nftAmount); 
         for(uint256 i=0;i<_nftAmount;i++) {
             uint256 id=nftAddress.mintTYPE1(_recipient);
             nftIds[i]=id;
         }
         return nftIds;
    }

    
    function buyNFT2(address _recipient,uint256 _nftAmount) external returns(uint256[] memory) {
        require(_nftAmount<=50,"exceeded limit");
         token.transferFrom(msg.sender, tokenRecipientAddress, price2.mul(_nftAmount));
          uint256[] memory nftIds = new uint256[](_nftAmount); 
         for(uint256 i=0;i<_nftAmount;i++) {
             uint256 id=nftAddress.mintTYPE2(_recipient);
             nftIds[i]=id;
         }
         return nftIds;
    }

    
    function buyNFT3(address _recipient,uint256 _nftAmount) external returns(uint256[] memory) {
        require(_nftAmount<=50,"exceeded limit");
         token.transferFrom(msg.sender, tokenRecipientAddress, price3.mul(_nftAmount));
          uint256[] memory nftIds = new uint256[](_nftAmount); 
         for(uint256 i=0;i<_nftAmount;i++) {
             uint256 id=nftAddress.mintTYPE3(_recipient);
             nftIds[i]=id;
         }
         return nftIds;
    }

    
    function buyNFT4(address _recipient,uint256 _nftAmount) external returns(uint256[] memory) {
        require(_nftAmount<=50,"exceeded limit");
         token.transferFrom(msg.sender, tokenRecipientAddress, price4.mul(_nftAmount));
          uint256[] memory nftIds = new uint256[](_nftAmount); 
         for(uint256 i=0;i<_nftAmount;i++) {
             uint256 id=nftAddress.mintTYPE4(_recipient);
             nftIds[i]=id;
         }
         return nftIds;
    }

    
    function buyNFT5(address _recipient,uint256 _nftAmount) external returns(uint256[] memory) {
        require(_nftAmount<=50,"exceeded limit");
         token.transferFrom(msg.sender, tokenRecipientAddress, price5.mul(_nftAmount));
          uint256[] memory nftIds = new uint256[](_nftAmount); 
         for(uint256 i=0;i<_nftAmount;i++) {
             uint256 id=nftAddress.mintTYPE5(_recipient);
             nftIds[i]=id;
         }
         return nftIds;
    }

    function setprice(uint256 _price,NFTType _type) external onlyOwner {
        if(_type == NFTType.COMLANDN) {
            price1 = _price;
        }else if(_type == NFTType.COMLANDR) {
            price2 = _price;
        }else if(_type == NFTType.COMLANDSR) {
            price3 = _price;
        }else if(_type == NFTType.COMLANDSSR) {
            price4 = _price;
        }else if(_type == NFTType.COMLANDSSSR) {
            price5 = _price;
        }
    }

    function rescueToken(
        address _token,
        address _recipient,
        uint256 _amount
    ) public onlyOwner {
        IERC20(_token).transfer(_recipient, _amount);
    }

    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sendStatus,)=_owner.call{value:amount}("");
        require(sendStatus,"Failed send");
    }
}