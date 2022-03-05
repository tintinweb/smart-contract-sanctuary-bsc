/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

// Cosmic Kiss Bridge
// https://cosmickiss.io/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract CosmicBridgeETH {

    uint256 public tax;
    address public relayer;
    address public operator;
    uint256 public minAmount;
    mapping(address => mapping(uint => bool)) public processedNonces;

    enum State { Deposit, Withdraw }
    
    event Transfer(
        address from,
        address to,
        uint256 amount,
        uint date,
        uint256 nonce,
        bytes signature,
        State indexed state
    );

    constructor(address _relayer,uint256 _tax,uint256 _minAmount) {
        minAmount = _minAmount;
        operator = msg.sender;
        tax = _tax;
        relayer = _relayer;
    }



function transferOperator(address newOperator) public returns(bool){
        require(msg.sender==operator,"only owner can call this function");
        operator = newOperator;        
        return true;
    }
    function updateRelayer(address newRelayer) public returns(bool) {
        require(msg.sender==operator,"only owner can call this function");
        relayer = newRelayer;        
        return true;
    }
    function updateTax(uint256 newTax) public returns(bool) {
        require(msg.sender==operator,"only owner can call this function");
        tax = newTax;
        return true;
    }

  function updateMinAmount(uint256 newMinAmount) public returns(bool) {
        require(msg.sender==operator,"only owner can call this function");
        minAmount = newMinAmount;
        return true;
    }
    
  function deposit(address to, uint amount, uint nonce, bytes calldata signature) external payable {
    require(msg.value>=minAmount,"insufficient amount");
    require(processedNonces[msg.sender][nonce] == false, 'transfer already processed');
    require(msg.value>=amount,"insufficient amount");
    processedNonces[msg.sender][nonce] = true;
        
    emit Transfer(
      msg.sender,
      to,
      amount,
      block.timestamp,
      nonce,
      signature,
      State.Deposit
    );
  }

  function processedNonceses(address[] memory addresses,uint256[] memory nonces) public view returns(bool[] memory){
    bool[] memory toReturn = new bool[](addresses.length);

    if(addresses.length==nonces.length){
      for(uint256 i=0;i<nonces.length;i++){
        toReturn[i]= processedNonces[addresses[i]][nonces[i]]; 
      }
    }
    return toReturn;    
  }


  function withdraw(
        address from, 
        address payable to, 
        uint256 amount, 
        uint nonce,
        bytes calldata signature,
        uint256 _gas
    ) external {
        require(msg.sender==relayer,"Only relayer can call this function");
        require((amount-tax-_gas)>0,"wrong amount");
        require(processedNonces[from][nonce] == false, 'transfer already processed');
        bytes32 message = prefixed(keccak256(abi.encodePacked(
            from, 
            to, 
            amount,
            nonce
        )));
        require(recoverSigner(message, signature) == from , 'wrong signature');
        require(address(this).balance>amount,"insufficient balance");
        processedNonces[from][nonce] = true;
        
        to.transfer(amount-tax-_gas);

        emit Transfer(
            from,
            to,
            amount,
            block.timestamp,
            nonce,
            signature,
            State.Withdraw
        );    
    }

    function addFunds() public payable {} 

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