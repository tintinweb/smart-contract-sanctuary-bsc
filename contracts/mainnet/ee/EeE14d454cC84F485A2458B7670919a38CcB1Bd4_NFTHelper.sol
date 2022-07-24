/**
 *Submitted for verification at BscScan.com on 2022-07-24
*/

pragma solidity ^0.8.0;


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
}

contract NFTHelper  is Owner {


    IComLand721 public nftAddress;
    IERC20 public token;

    constructor(address _nftAddress,address _token) {
       nftAddress=IComLand721(_nftAddress); 
       token=IERC20(_token);
    }


    function buyNFT(address _recipient,uint256 _amount,uint256 _nftAmount) external returns(uint256[] memory) {
         token.transferFrom(msg.sender, address(this), _amount);
          uint256[] memory nftIds = new uint256[](_nftAmount); 
         for(uint256 i=0;i<_nftAmount;i++) {
             uint256 id=nftAddress.mintTYPE1(_recipient);
             nftIds[i]=id;
         }
         return nftIds;
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