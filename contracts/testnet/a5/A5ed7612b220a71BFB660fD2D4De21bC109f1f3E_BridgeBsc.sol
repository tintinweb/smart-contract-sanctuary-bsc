// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import './BridgeBase.sol';

contract BridgeBsc is BridgeBase {
  constructor(address token) BridgeBase(token) {}
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "./IERC20.sol";
import './IToken.sol';

contract BridgeBase {
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  address public DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;
  address private ZERO_ADDRESS = 0x0000000000000000000000000000000000000000;

  address private _owner;
  modifier onlyOwner() {
    require(_owner == msg.sender, "Ownable: caller is not the owner");
    _;
  }

  IToken public token;
  mapping(address => mapping(uint => bool)) public processedNonces;

  enum Step { Burn, Mint }
  event Transfer(
    address from,
    address to,
    uint amount,
    uint date,
    uint nonce,
    bytes signature,
    Step indexed step
  );

  constructor(address _token) {
    token = IToken(_token);
    _owner = msg.sender;
  }

  function owner() public view returns (address) {
    return _owner;
  }

  function transferOwner(address newOwner) external onlyOwner {
    require(newOwner != ZERO_ADDRESS, "Call renounceOwnership to transfer owner to the zero address.");
    require(newOwner != DEAD_ADDRESS, "Call renounceOwnership to transfer owner to the zero address.");
    _owner = newOwner;
    emit OwnershipTransferred(_owner, newOwner);
  }

  function burn(address to, uint amount, uint nonce, bytes calldata signature) external {
    require(processedNonces[msg.sender][nonce] == false, 'transfer already processed');
    processedNonces[msg.sender][nonce] = true;
    token.burn(msg.sender, amount);
    emit Transfer(
      msg.sender,
      to,
      amount,
      block.timestamp,
      nonce,
      signature,
      Step.Burn
    );
  }

  function mint(
    address from, 
    address to, 
    uint amount, 
    uint nonce,
    bytes calldata signature
  ) external {
    bytes32 message = prefixed(keccak256(abi.encodePacked(
      from, 
      to, 
      amount,
      nonce
    )));
    require(recoverSigner(message, signature) == from , 'wrong signature');
    require(processedNonces[from][nonce] == false, 'transfer already processed');
    processedNonces[from][nonce] = true;
    token.mint(to, amount);
    emit Transfer(
      from,
      to,
      amount,
      block.timestamp,
      nonce,
      signature,
      Step.Mint
    );
  }

  function prefixed(bytes32 hash) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(
      '\x19Ethereum Signed Message:\n32', 
      hash
    ));
  }

  function recoverSigner(bytes32 message, bytes memory sig)
    internal
    pure
    returns (address)
  {
    uint8 v;
    bytes32 r;
    bytes32 s;
  
    (v, r, s) = splitSignature(sig);
  
    return ecrecover(message, v, r, s);
  }

  function splitSignature(bytes memory sig)
    internal
    pure
    returns (uint8, bytes32, bytes32)
  {
    require(sig.length == 65);
  
    bytes32 r;
    bytes32 s;
    uint8 v;
  
    assembly {
        // first 32 bytes, after the length prefix
        r := mload(add(sig, 32))
        // second 32 bytes
        s := mload(add(sig, 64))
        // final byte (first byte of the next 32 bytes)
        v := byte(0, mload(add(sig, 96)))
    }
  
    return (v, r, s);
  }

  function linkBridgeToToken() external onlyOwner() {
    IToken(token).updateBridges(address(this), true);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface IToken {
  function mint(address to, uint256 amount) external;
  function burn(address owner, uint256 amount) external;
  function updateBridges(address bridgeAddress, bool newVal) external;
}