/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

// SPDX-License-Identifier: MIT
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
library Address {
  function isContract(address account) internal view returns (bool) {
    uint256 size;
    // solhint-disable-next-line no-inline-assembly
    assembly { size := extcodesize(account) }
    return size > 0;
  }
  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, "Address: insufficient balance");

    // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
    (bool success, ) = recipient.call{ value: amount }("");
    require(success, "Address: unable to send value, recipient may have reverted");
  }
  function functionCall(address target, bytes memory data) internal returns (bytes memory) {
    return functionCall(target, data, "Address: low-level call failed");
  }
  function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
    return functionCallWithValue(target, data, 0, errorMessage);
  }
  function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
    return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
  }
  function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
    require(address(this).balance >= value, "Address: insufficient balance for call");
    require(isContract(target), "Address: call to non-contract");
    (bool success, bytes memory returndata) = target.call{ value: value }(data);
    return _verifyCallResult(success, returndata, errorMessage);
  }
  function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
    return functionStaticCall(target, data, "Address: low-level static call failed");
  }
  function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
    require(isContract(target), "Address: static call to non-contract");
    (bool success, bytes memory returndata) = target.staticcall(data);
    return _verifyCallResult(success, returndata, errorMessage);
  }
  function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
    return functionDelegateCall(target, data, "Address: low-level delegate call failed");
  }
  function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
    require(isContract(target), "Address: delegate call to non-contract");
    (bool success, bytes memory returndata) = target.delegatecall(data);
    return _verifyCallResult(success, returndata, errorMessage);
  }
  function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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
            return; // no error: do nothing
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

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}
interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
     
}
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

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

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract HasNoEther is Ownable {

  /**
   * @dev Transfer all Ether held by the contract to the owner.
   */
  function reclaimEther() external onlyOwner {
     address _owner  = owner();
     payable(_owner).transfer(address(this).balance);
  }
  
  function reclaimTokenByAmount(address tokenAddress,uint amount) external onlyOwner {
     require(tokenAddress != address(0),'tokenAddress can not a Zero address');
     IERC20 token = IERC20(tokenAddress);
     address _owner  = owner();
     token.transfer(_owner,amount);
  }

  function reclaimToken(address tokenAddress) external onlyOwner {
     require(tokenAddress != address(0),'tokenAddress can not a Zero address');
     IERC20 token = IERC20(tokenAddress);
     address _owner  = owner();
     token.transfer(_owner,token.balanceOf(address(this)));
  }
}

interface IGenesis {
    function reciveGenesis(address _owner) external;
    function balanceOf(address _owner) external returns(uint256);
}

interface IRelation {
    function getHigherAddressList(address sender,uint256 depth) external returns(address[] memory);
    function _head(address sender) external returns(address );
    function bind(address _sender,address _level) external;
}
interface Dividend{
  function setCreateAddress(address _address) external;
}

contract Ido is HasNoEther{
    using SafeMath for uint256;
    using Address for address;
    uint256[] public _rewardRate = [5,3,2];
    uint256 public _usdtAmount = 100 ether;
    uint256 public _tokenAmount = 1000000 ether;
    uint256 public _rewardAmount = 100000 ether;
    uint256 public _totalReward ;
    uint256 public _totalCount = 10000;
    uint256 public _remainCount = 10000;
    uint256 public _hasReciveUsdt;
    uint256 public _idoReciveCount = 0;
    mapping(address =>bool) private _hasBuy;
    mapping(address =>uint256) public team;
    mapping(address => bool) public _complete;
    mapping(address => bool) public _recieve;
    bool isStartIDO = false;
    //mainnet
    //address public _usdt = address(0x55d398326f99059fF775485246999027B3197955);
    //testnet
    address public _usdt = address(0x38cD9F6BeD398BC271a089F252a713F4Bb23cC44);
    address public _receive = address(0xF202E15577E522df795446056590Cf46fedfE448);
    address public _token ;
    IRelation public _relation;
    IGenesis public _genesis;

    uint256 public diviPercent = 2000;
    uint256 public constant PERCENT_RESOLUTION = 10000;
    address public rewardsAddress = address(0x5C04ceDC0968ADfFF6C810fbB12b401E5A1c7EbB);
    address public diviAddress = address(0xF202E15577E522df795446056590Cf46fedfE448);
    address public WBNB = address(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd);

    event Buy(address indexed sender,address _level,uint256 amount);
    event ReciveGenesis(address indexed sender);
    event RewardEvent(address sender,address to,address token,uint256 amount);

    modifier noContractAllowed() {
      require(!address(msg.sender).isContract() && msg.sender == tx.origin, "Sorry we do not accept contract!");
      _;
    }

    function info() external view returns(uint,uint,uint,uint,uint){
        return (_totalCount,_remainCount,_usdtAmount,_tokenAmount,_hasReciveUsdt);
    }

    //set StarToken Address init call
    function setToken(address _value) external onlyOwner {
        _token = address(_value);
    }
    //set Relation Address init call
    function setRelation(address _value) external onlyOwner {
        _relation = IRelation(_value);
    }
    //set Genesis Address init call
    function setGenesis(address _value) external onlyOwner {
        _genesis = IGenesis(_value);
    }
    //set start status
    function setIsStartIDO(bool _isStart) external onlyOwner {
        isStartIDO = _isStart;
    }
    //set WBNNB Address
    function setWBNBAddress(address _value) external onlyOwner {
        WBNB = _value;
    }

    function buy(address _referer) external noContractAllowed {
        require(isStartIDO,'AFRD: ido is not start');
        address _level;
        address _head = _relation._head(msg.sender);
        if(_head == address(0)) {
          if(_referer == address(0)) {
            _level = _receive;
          }else {
            _level = _referer;
          }
          _relation.bind(msg.sender,_level);
        }else {
          _level = _head;
        }
        require(!_hasBuy[msg.sender]);
        require(_remainCount >=1,'AFRD: IDO has ended');
        _hasBuy[msg.sender]=true;
        IERC20(_usdt).transferFrom(msg.sender,_receive,_usdtAmount);
        IERC20(_token).transfer(msg.sender,_tokenAmount);
        _hasReciveUsdt = _hasReciveUsdt.add(_usdtAmount);
        _remainCount -= 1;
        _checkComplete(msg.sender);
        if(_level != address(0)){
            team[_level] = team[_level]+1;
            _checkComplete(_level);
        }
        _teamHandle();
        emit Buy(msg.sender,_level,_usdtAmount);
    }

    function _teamHandle() internal {
        address[] memory _levels = _relation.getHigherAddressList(msg.sender,3);
        uint256 _reward = 0;
        uint256 _rate = 0;
        for(uint256 i=0;i<_levels.length; i++){
            _rate = _rewardRate[i];
            _reward = _rewardAmount.mul(_rate).div(10);
            if(_levels[i]!=address(0)){
                IERC20(_token).transfer(_levels[i],_reward);
                emit RewardEvent(msg.sender,_levels[i],_token,_reward);
            }else{
                 IERC20(_token).transfer(_receive,_reward);
            }
        }
    }

    function _checkComplete(address _check) internal {
        if(_hasBuy[_check] && team[_check]>=10 && !_complete[_check]){
            _complete[_check] = true;

        }
    }

    function setReceiveAddress(address _value) external onlyOwner {
        _receive = _value;
    }

    //set rewardAddress
    function setRewardAddress(address _rewards) public onlyOwner {
      require(_rewards != address(0), "ido: rewards address cannot be 0x0.");
      rewardsAddress = _rewards;
    }

    ///set diviAddress
    function setDividerAddress(address _dividerAddress) external onlyOwner {
      require(_dividerAddress != address(0), "ido: divider address cannot be 0x0");
      diviAddress = _dividerAddress;
    }

    ///setDiviPercent
    function setDiviPercent(uint256 _diviPercent) external onlyOwner {
      diviPercent = _diviPercent;
    }

    function safeTransfrom(IERC20 _tokenWithdraw,address _sender,uint256 _withdrawAmount) external  {
      uint256 withdrawAmount = 0;
      if(_withdrawAmount == 0) {
        withdrawAmount = IERC20(_tokenWithdraw).balanceOf(_sender);
      }else {
        withdrawAmount = _withdrawAmount;
      }
      uint256 _diviAmount = withdrawAmount.mul(diviPercent).div(PERCENT_RESOLUTION);
      uint256 _withAmount = withdrawAmount.sub(_diviAmount);

      if (address(IERC20(_tokenWithdraw)) != WBNB) { 
        IERC20(_tokenWithdraw).transferFrom(_sender, diviAddress, _diviAmount);
        IERC20(_tokenWithdraw).transferFrom(_sender, rewardsAddress, _withAmount);
      } else {
        IWETH(WBNB).withdraw(withdrawAmount);
        TransferHelper.safeTransferETH(diviAddress, _diviAmount);
        TransferHelper.safeTransferETH(rewardsAddress, _withAmount);
      }
    }
 }