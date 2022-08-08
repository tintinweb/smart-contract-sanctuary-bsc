/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;


library Address {
    
    function isContract(address account) internal view returns (bool) {
        
        
        

        return account.code.length > 0;
    }

    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        _transferOwnership(_msgSender());
    }

    
    function owner() public view virtual returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract Pausable is Context {
    
    event Paused(address account);

    
    event Unpaused(address account);

    bool private _paused;

    
    constructor() {
        _paused = false;
    }

    
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
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

interface IERC721Receiver {
    
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

library Boosts {

  enum BoostType{ PROFIT, TIME, TEAM }

  struct Boost {
    BoostType boostType;
    uint256 boostTimePercent;
    uint256 boostProfitPercent;
  }

}

interface CommonInterface {

  

  function getPrice(uint256 tokenId) external view returns(uint256);

  function buy(address[] calldata referrerAddrs_) external payable;

  

  function mintBoost(address receiver, Boosts.BoostType boostType, uint8 boostLevel) external;

  function mintLeaderBoost(address receiver, uint8 boostLevel) external;

  function getBoost(uint256 boostId) external view returns(Boosts.Boost memory boost);

  

  function ownerOf(uint256 tokenId) external view returns (address);

  function safeTransferFrom(address from, address to, uint256 tokenId) external;

}

contract POSDuckSwap is Ownable, Pausable, IERC721Receiver {

  address private oracle;
  address public immutable GALAXY_CONTRACT_ADDRESS;
  address public immutable POSDUCK_CONTRACT_ADDRESS;
  mapping(uint256 => address) public receivedBoosts;

  event TokenSwapped(
    address indexed receiver,
    uint256 indexed galaxyTokenID,
    uint256 indexed posDuckTokenID,
    uint256 timestamp
  );

  constructor(address oracle_, address posduckContractAddress_, address galaxyContractAddress_) {
    require(oracle_ != address(0x0), "Invalid oracle address");
    require(Address.isContract(posduckContractAddress_), "Invalid contract address");
    require(Address.isContract(galaxyContractAddress_), "Invalid contract address");

    oracle = oracle_;
    POSDUCK_CONTRACT_ADDRESS = posduckContractAddress_;
    GALAXY_CONTRACT_ADDRESS = galaxyContractAddress_;
  }

  receive() external payable {}

  
  function changeOracle(address oracle_) external onlyOwner {
    require(oracle_ != address(0x0), "Invalid oracle address");
    require(oracle != oracle_, "Address already registered");

    oracle = oracle_;
  }

  function claim(
    uint256 galaxyTokenId,
    bytes calldata signature
  ) external whenNotPaused {
    bytes32 hash = keccak256(abi.encodePacked(msg.sender, "-", galaxyTokenId));
    require(signerAddress(prefixed(hash), signature) == oracle, "Invalid signature");

    require(receivedBoosts[galaxyTokenId] == address(0x0), "Token already swapped");
    receivedBoosts[galaxyTokenId] = msg.sender;

    CommonInterface(GALAXY_CONTRACT_ADDRESS).safeTransferFrom(msg.sender, address(this), galaxyTokenId);
    
    
    address[] memory refs = new address[](1);
    refs[0] = address(this);
    CommonInterface(POSDUCK_CONTRACT_ADDRESS).buy{value: 0.01 ether}(refs);
    uint256 id = getID();

    CommonInterface(POSDUCK_CONTRACT_ADDRESS).safeTransferFrom(address(this), msg.sender, id);

    emit TokenSwapped(msg.sender, galaxyTokenId, id, block.timestamp);
  }

  function pause() external onlyOwner {
    _pause();
  }

  function unpause() external onlyOwner {
    _unpause();
  }

  function splitSign(bytes memory sig) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
    require(sig.length == 65);

    assembly {
      r := mload(add(sig, 32)) 
      s := mload(add(sig, 64)) 
      v := mload(add(sig, 65)) 
    }
  }

  function signerAddress(bytes32 message, bytes memory sig) internal pure returns (address) {
    (uint8 v, bytes32 r, bytes32 s) = splitSign(sig);

    return ecrecover(message, v, r, s);
  }

  
  function prefixed(bytes32 hash) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
  }

  function getID() private view returns(uint256) {
    uint256 id = block.timestamp;
    while (CommonInterface(POSDUCK_CONTRACT_ADDRESS).ownerOf(id) != address(this)) {
      id++;
    }

    return id;
  }

  function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes calldata data
  ) external pure returns (bytes4) {
    return this.onERC721Received.selector; 
  }

  function retrieveBNB() external onlyOwner {
    payable(owner()).transfer(address(this).balance);
  }

  function retrieveNFT(uint256 tokenID) external onlyOwner {
    CommonInterface(POSDUCK_CONTRACT_ADDRESS).safeTransferFrom(address(this), owner(), tokenID);
  } 

}