/**
 *Submitted for verification at BscScan.com on 2022-06-02
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

interface IPlanet {
    function recivePlanet(address _owner) external;
}

contract Ido is HasNoEther{
    using SafeMath for uint256;
    address public _zero = address(0x0000000000000000000000000000000000000000);

    bool public _start;
    uint256 public _startTime;
    uint256 public _time = 18 days;
    uint256 public _usdtAmount = 100 ether;
    uint256 public _starAmount = 100000 ether;
    uint256 public _totalAmount = 2000000000 ether;
    uint256 public _remainAmount = 2000000000 ether;
    uint256 public _hasReciveUsdt;
    mapping(address =>bool) public hasGive;
    mapping(address =>uint256) public team;
    mapping(address =>uint256) public recivePlanetChance;
    mapping(address =>uint256) public hasGiveChance;
    mapping(address =>uint256) public buyStarChance;
    mapping(address =>uint256) public hasBuyCount;
    mapping(address =>uint256) public waitReciveToken;
    mapping(uint256 =>bool) public hasUsed;
    address public _star;
    address public _key = 0x3300dbDC13b7A80B242DAaaD3a89268F506b5adE;
    //mainnet
    //address public _usdt = address(0x55d398326f99059fF775485246999027B3197955);
    //testnet
    address public _usdt = address(0xAf73CB491c7040c0C31C4FCe6Fd8C6e33D482B62);
    IPlanet public _planet;

    event Buy(address indexed sender,address _level,uint256 amount);
    event ReciveToken(address indexed sender,uint256 amount);
    event RecivePlanet(address indexed sender,uint256 indexed id,uint count);
    //start IDO
    function start() external onlyOwner{
        _start = true;
        _startTime = block.timestamp;
    }

    // set EndTime
    function setTime(uint256 _days) external onlyOwner{
        _time = _days;
    }

    //set StarToken Address
    function setStar(address _value) external onlyOwner {
        _star = address(_value);
    }

    function addTeam(uint count) external{
        team[msg.sender] = count;
    }

    //set PlanetNFT Address
    function setPlanet(address _value) external onlyOwner {
        _planet = IPlanet(_value);
    }

    function getWeight() public view returns(uint) {
        return buyStarChance[msg.sender].add(1).sub(hasBuyCount[msg.sender]);
    }

    function getLevelWeight(address _level) internal view returns(uint) {
        return buyStarChance[_level].add(1).sub(hasBuyCount[_level]);
    }

    function canReciveToken() public view returns(bool _state){
        return block.timestamp >= _startTime.add(_time);
    }

    function recivePlanet () external {
        require(recivePlanetChance[msg.sender]>0,'Star: Insufficient quantity available');
        uint256 _chance = recivePlanetChance[msg.sender];
        for(uint i=0;i<_chance;i++){
            recivePlanetChance[msg.sender]=_chance.sub(1);
            _planet.recivePlanet(msg.sender);
        }
    }

    function recivePlanetWithSign (uint256 id,uint256 count,bytes memory sign) external {
        require(!hasUsed[id],'Star:Has been used');
        hasUsed[id] = true;
        bytes32 message = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(id,count,msg.sender)));
        require(ECDSA.recover(message, sign) == _key,'Star: sign error');
        for(uint i=0;i<count;i++){
            _planet.recivePlanet(msg.sender);
        }
        emit RecivePlanet(msg.sender,id,count);
    }

    function reciveToken() external {
        require(canReciveToken(),'Star: IDO is in progress');
        require(waitReciveToken[msg.sender]>0,'Insufficient quantity available');
        IERC20(_star).transfer(msg.sender,waitReciveToken[msg.sender]);
        emit ReciveToken(msg.sender,waitReciveToken[msg.sender]);
    }

    function buy(uint256 weight,address _level) external {
        require(msg.sender!=_level,'Star: level can not yourself');
        require(_start,'Star: IDO is not start');
        require(block.timestamp<_startTime.add(_time),'Star: IDO is ended');
        uint256 userWeight = getWeight();
        require(userWeight>=weight,'Star: can not buy anymore');
        hasBuyCount[msg.sender]=hasBuyCount[msg.sender].add(1);
        uint256 amount = _usdtAmount.mul(weight);
        uint starAmount = _starAmount.mul(weight);
        IERC20(_usdt).transferFrom(msg.sender,address(this),amount);
        _hasReciveUsdt = _hasReciveUsdt.add(amount);
        _remainAmount = _remainAmount.sub(starAmount);
        waitReciveToken[msg.sender] = waitReciveToken[msg.sender].add(starAmount);
        if(team[msg.sender]>=10 && !hasGive[msg.sender]){
            _givePlanetChance(msg.sender);
        }
        if(_level != _zero){
            team[_level] = team[_level]+1;
            if(hasBuyCount[_level]>0 &&team[_level]>=10 && !hasGive[_level]){
                _givePlanetChance(_level);
            }   
        }
        emit Buy(msg.sender,_level,amount);
    }

    function _givePlanetChance(address _value) internal {
        uint256 levelWeight = getLevelWeight(_value);
        buyStarChance[_value] = levelWeight.add(2);
        recivePlanetChance[_value] = 1;
        hasGive[_value] = true;
    }
 }