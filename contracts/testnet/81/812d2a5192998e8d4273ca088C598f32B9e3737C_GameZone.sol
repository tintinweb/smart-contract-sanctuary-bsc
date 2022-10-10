/**
 *Submitted for verification at BscScan.com on 2022-10-10
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.17;

library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return;
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;

            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;

            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address, RecoverError) {
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }

        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target,bytes memory data,string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target,bytes memory data,uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target,bytes memory data,uint256 value,string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target,bytes memory data,string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target,bytes memory data,string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success,bytes memory returndata,string memory errorMessage) private pure returns (bytes memory) {
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

library SafeBEP20 {
    using Address for address;

    function safeTransfer(IBEP20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IBEP20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "safeBEP20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "safeBEP20: BEP operation did not succeed");
        }
    }
}

interface IBEP20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view returns (address) {
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
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function _checkOwner() internal view {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract Pausable is Context {
    event Paused(address indexed account);
    event Unpaused(address indexed account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    modifier whenPaused() {
        _requirePaused();
        _;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    function _requireNotPaused() internal view {
        require(!paused(), "Pausable: paused");
    }

    function _requirePaused() internal view {
        require(paused(), "Pausable: not paused");
    }

    function _pause() internal whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

abstract contract ReentrancyGuard {
    uint8 private constant _NOT_ENTERED = 1;
    uint8 private constant _ENTERED = 2;
    uint8 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract GameZone is Ownable,Pausable,ReentrancyGuard{
    using SafeBEP20 for IBEP20;
    using Address for address payable;
    using ECDSA for bytes32;

    address public signer;
    IBEP20 public token;

    struct Sig {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    mapping(bytes32 => bool) private _signStatus;

    event CoinDeposit(address indexed _account, uint indexed amount, uint indexed time);
    event TokenDeposit(address indexed _account, uint indexed amount, uint indexed time);
    event CoinWithdraw(address indexed _account, uint indexed amount, uint indexed time);
    event TokenWithdraw(address indexed _account, uint indexed amount, uint indexed time);
    event CoinEmergencyWithdraw(address indexed account, uint256 indexed amount, uint indexed time);
    event TokenEmergencyWithdraw(address indexed account, uint256 indexed amount, uint indexed time);
    event Fallback(address indexed account, uint256 indexed amount, uint indexed time);

    constructor(address _Token,address _signerAddress){
        token = IBEP20(_Token);
        signer = _signerAddress; 
    }

    receive() external payable {
        emit Fallback(_msgSender(), msg.value, block.timestamp);
    }
    
    function pause() external onlyOwner{
        _pause();
    }

    function unpause() external onlyOwner{
        _unpause();
    }

    function setSigner(address newSigner) external onlyOwner{
        require(newSigner != address(0), "signerUpdate : Invalid newSigner");
        signer = newSigner;
    }

    function setToken(address _token) external onlyOwner {
        require(_token != address(0), "Invalid address");
        token = IBEP20(_token);
    }

    function deposit(uint8 _flag, uint256 _amount) external payable whenNotPaused {
        require(_flag == 1 || _flag == 2 ,"Incorrect flag");

        if (_flag == 1) {
            require(msg.value > 0 && _amount == 0,"Incorrect Amount");
            emit CoinDeposit(_msgSender(), msg.value, block.timestamp);
        } else {
            require(_amount > 0 && msg.value == 0,"Incorrect Amount");
            IBEP20(token).safeTransferFrom(_msgSender(), address(this), _amount);
            emit TokenDeposit(_msgSender(), _amount, block.timestamp);
        }
    }

    function withdraw(address _user, uint256 _amount ,uint256 _expiry, uint8 _flag, Sig memory sig) external nonReentrant whenNotPaused {
        require(block.timestamp < _expiry, "Time Invalid");
        require(_user != address(0), "Invalid user Address");
        require(_flag == 1 || _flag == 2 , "Incorrect flag");
        require(_amount > 0, "Invalid amount");
        require(signer == verifySignature(_user, _amount , _expiry, _flag, sig), "Invalid Signer");

        if(_flag == 1){
            require(_amount <= bnbBalance(), "Insufficient BNB");
            payable(_user).sendValue(_amount);
            emit CoinWithdraw(_user, _amount, block.timestamp);
        }

        else{
           require(_amount <= tokenBalance(),"Insufficient Tokens");
           IBEP20(token).safeTransfer(_user,_amount);
           emit TokenWithdraw(_user, _amount, block.timestamp);
        }
    }

    function emergencyWithdraw(address _user, uint8 _flag, uint _amount) external onlyOwner {
        require(_user != address(0), "emergencyWithdraw : Invalid to address");
        require(_amount > 0, "Invalid amount");
        require(_flag == 1 || _flag == 2, "Incorrect flag");
        
        if (_flag == 1) {
            require(_amount <= bnbBalance(), "Insufficient BNB");
            payable(_user).sendValue(_amount);
            emit CoinEmergencyWithdraw(_user, _amount, block.timestamp);
        } else {
           require(_amount <= tokenBalance(),"Insufficient Tokens");
           IBEP20(token).safeTransfer(_user,_amount);
            emit TokenEmergencyWithdraw(_user, _amount, block.timestamp);
        }
    }

    function prepareHash(address _user, uint _amount, uint _expiry, uint8 _flag) public view returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                _user,
                _amount,
                _expiry,
                _flag,
                address(this)
            )
        );
    }

    function bnbBalance() public view returns(uint256){
       return address(this).balance;    
    }

    function tokenBalance() public view returns(uint256){
        return IBEP20(token).balanceOf(address(this));
    }

    function verifySignature(address _user, uint256 _amount , uint256 _expiry, uint8 _flag, Sig memory sig) private  returns (address signatureAddress){
        bytes32 hash = prepareHash(_user, _amount, _expiry, _flag);
        bytes32 messageHash = hash.toEthSignedMessageHash();
        require(!_signStatus[messageHash], "Invalid Signature");
        _signStatus[messageHash] = true;
        signatureAddress = messageHash.recover(sig.v, sig.r, sig.s);
    }
}