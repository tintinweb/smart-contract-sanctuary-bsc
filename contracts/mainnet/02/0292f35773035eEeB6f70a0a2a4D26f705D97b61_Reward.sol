pragma solidity ^0.8.6;

import './IERC20.sol';

contract Reward{
    address public admin;
    IERC20 public token;
    uint public totalReward;
    
    struct ProcessRewardAddress{
        string txId;
        address reciept;
        uint amount;
        bool status;
    }
    
    struct AccountReward{
        address reciept;
        uint totalReward;
    }
    
    mapping (string => ProcessRewardAddress) public processReward;
    mapping (address => AccountReward) public accountReward;
    
    constructor(address _admin, address _token){
        admin = _admin;
        token = IERC20(_token);
    }
    
    function claimReward(string memory txId,address _reciept,uint amount,
    bytes memory signature) public {
        
        bytes32 message = prefixed(keccak256(abi.encodePacked(txId,_reciept, amount)));
        require(recoverSigner(message, signature) == admin , 'wrong signature');
        require(processReward[txId].reciept == address(0), 'txId had already');
        setProcessReward(txId,_reciept,amount);
        totalReward += amount;
        accountReward[_reciept].totalReward +=amount;
        token.transfer(_reciept, amount);
    }
    
    function checkReward(string memory txId)public view returns(address, uint){
        return (processReward[txId].reciept,processReward[txId].amount);
    }
    
    function setProcessReward
(string memory txId,address _reciept,uint amount)internal{
        require(processReward[txId].reciept == address(0), 'txId had already');
        processReward[txId].reciept = _reciept;
        processReward[txId].amount = amount;
        processReward[txId].status = true;
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
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}