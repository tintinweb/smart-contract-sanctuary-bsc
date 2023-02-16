/**
 *Submitted for verification at BscScan.com on 2023-02-16
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.9;

interface IBEP20 {

  function decimals() external view returns (uint8);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

contract Pausable is Context {
    
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () {
        _paused = false;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

library Address {
   
    function isContract(address account) internal view returns (bool) {
        
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
   
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            
            if (returndata.length > 0) {
                
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }

     function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

abstract contract SafeBep20 {
    using Address for address;

    function safeTransfer(IBEP20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IBEP20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
       

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { 
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract _socialCrypto_ is Ownable, SafeBep20, Pausable{

    address[4] public wallets;
    uint16[4] public walletShares = [770,210,10,10];
    IBEP20 public BUSD;
    address public signer;
    address public admin;

    mapping (bytes32 => bool) public hashVerify;

    event Withdraw(address indexed User, address indexed Admin, uint TokenAmount, uint blockTime);

    constructor(address[4] memory _wallets, address _BUSD, address _signer, address _admin) {
        wallets = _wallets;
        BUSD = IBEP20(_BUSD);
        signer = _signer;
        admin = _admin;
    }

    function pause() external onlyOwner{
        _pause();
    }

    function unPause() external onlyOwner{
        _unpause();
    }

    function withdraw(uint _amount, uint8 _V, bytes32 _R, bytes32 _S, uint256 _blockTime) external whenNotPaused {

        require(_blockTime >= block.timestamp,"Time Expired");
        bytes32 msgHash = toSigEthMsg(msg.sender, _amount, _blockTime);
        require(!hashVerify[msgHash],"signature already used");
        require(verifySignature(msgHash, _V,_R,_S) == signer,"invalid signature");
        hashVerify[msgHash] = true;

        safeTransferFrom(BUSD, admin, wallets[0], (_amount * walletShares[0] / 1000));
        safeTransferFrom(BUSD, admin, wallets[1], (_amount * walletShares[1] / 1000));
        safeTransferFrom(BUSD, admin, wallets[2], (_amount * walletShares[2] / 1000));
        safeTransferFrom(BUSD, admin, wallets[3], (_amount * walletShares[3] / 1000));

        emit Withdraw(_msgSender(), admin, _amount, block.timestamp);
    }

    function verifySignature(bytes32 _msgHash, uint8 v,bytes32 r, bytes32 s)public pure returns(address signerAdd){
        signerAdd = ecrecover(_msgHash, v, r, s);
    }
    
    function toSigEthMsg(address _user, uint256 _tokenAmount, uint256 _blockTime)internal view returns(bytes32){
        bytes32 hash = getHash(_user, _tokenAmount, _blockTime);
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function getHash(address _user, uint256 _tokenAmount, uint256 _blockTime)public view returns(bytes32){
        return keccak256(abi.encodePacked(abi.encodePacked(_user, _tokenAmount, _blockTime),address(this)));
    }

    function setSigner(address _signer) external onlyOwner {
        require(address(0x0) != _signer,"invalid signer address");
        signer = _signer;
    } 

    function setWallets(address[4] memory _wallets) external onlyOwner{
        wallets = _wallets;
    }
    
    function setWalletShares(uint16[4] memory _walletShares) external onlyOwner {
        require((_walletShares[0] + _walletShares[1] + _walletShares[2] + _walletShares[3]) == 1000,"invalid shares");

        walletShares = _walletShares;
    }

    function emergency(address _tokenAddress, address _to, uint256 _tokenAmount) external onlyOwner {
        if(_tokenAddress == address(0x0)){
            require(payable(_to).send(_tokenAmount),"transaction failed");
        } else {
            safeTransfer(IBEP20(_tokenAddress), _to, (_tokenAmount));
        }
    }

}