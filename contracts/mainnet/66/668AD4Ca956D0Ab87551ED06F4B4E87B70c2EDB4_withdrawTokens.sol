/**
 *Submitted for verification at BscScan.com on 2022-11-23
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.9;

interface IBEP20 {

  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
    
  constructor () { }

  function _msgSender() internal view returns (address) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode 
    return msg.data;
  }
}

contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor (){
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }
  
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract withdrawTokens is Ownable{

    address public wallet1;
    address public wallet2;
    address public admin;
    address public BUSD;
    address public signer;

    uint8 public wallet_1_fee = 10;   //10 = 1% fee
    uint8 public wallet_2_fee = 10;   //10 = 1% fee

    mapping (bytes32 => bool) public hashVerify;

    event Withdraw(address indexed User, uint TokenAmount, uint blockTime);

    constructor(address _wallet1, address _wallet2, address _admin, address _BUSD, address _signer) {
        wallet1 = _wallet1;
        wallet2 = _wallet2;
        admin = _admin;
        BUSD = _BUSD;
        signer = _signer;
    }

    function withdraw(address _to,uint _tokenAmount, uint _blockTime, uint8 v, bytes32 r, bytes32 s) external {

        require(_blockTime >= block.timestamp,"Time Expired");
        bytes32 msgHash = toSigEthMsg(msg.sender, _tokenAmount, _blockTime);
        require(!hashVerify[msgHash],"signature already used");
        require(verifySignature(msgHash, v,r,s) == signer,"invalid signature");
        hashVerify[msgHash] = true;
        
        IBEP20(BUSD).transferFrom(admin, wallet1, (_tokenAmount * wallet_1_fee / 1000));
        IBEP20(BUSD).transferFrom(admin, wallet2, (_tokenAmount * wallet_2_fee / 1000));
        _tokenAmount = _tokenAmount - (_tokenAmount * (wallet_1_fee + wallet_2_fee) / 1000);
        IBEP20(BUSD).transferFrom(admin, _to, _tokenAmount);

        emit Withdraw(_to, _tokenAmount, block.timestamp);
        
    }

    function verifySignature(bytes32 msgHash, uint8 v,bytes32 r, bytes32 s)public pure returns(address signerAdd){
        signerAdd = ecrecover(msgHash, v, r, s);
    }
    
    function toSigEthMsg(address user, uint256 _tokenAmount, uint256 _blockTime)internal view returns(bytes32){
        bytes32 hash = keccak256(abi.encodePacked(abi.encodePacked(user, _tokenAmount, _blockTime),address(this)));
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function getHash(address user, uint256 _tokenAmount, uint256 _blockTime)public view returns(bytes32){
        return keccak256(abi.encodePacked(abi.encodePacked(user, _tokenAmount, _blockTime),address(this)));
    }

    function setSigner(address _signer) external onlyOwner {
        require(address(0x0) != _signer,"invalid signer address");
        signer = _signer;
    } 

    function setFeePercentage(uint8 fee1, uint8 fee2) external onlyOwner {
        wallet_1_fee = fee1;
        wallet_2_fee = fee2;
    }

    function setAdmin(address _admin) external onlyOwner {
      require(address(0x0) != _admin,"invalid admin address");
      admin = _admin;
    }

    function setWallets(address _wallet1, address _wallet2) external onlyOwner {
      require(address(0x0) != _wallet1,"invalid wallet-1 address");
      require(address(0x0) != _wallet2,"invalid wallet-2 address");

      wallet1 = _wallet1;
      wallet2 = _wallet2;
    }

    function emergency(address _tokenAddress, address _to, uint256 _tokenAmount) external onlyOwner {
        if(_tokenAddress == address(0x0)){
            require(payable(_to).send(_tokenAmount),"transaction failed");
        } else {
            IBEP20(_tokenAddress).transfer(_to, _tokenAmount);
        }
    }

}