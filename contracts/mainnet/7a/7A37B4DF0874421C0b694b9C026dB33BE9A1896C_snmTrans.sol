/**
 *Submitted for verification at BscScan.com on 2022-10-06
*/

// SPDX-License-Identifier: MIT;
pragma solidity ^0.8;

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

contract snmTrans {


    address public owner; //
    uint256 public chainId;  //
    address public verifyingContract; //
    address public tokenAddress; //
    bool public authTransSwitch; //

    mapping (uint256 => bool) private orderids;



    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can call this");
        _;
    }

  
    modifier notAddress(address _useAdd){
        require(_useAdd != address(0), "address is error");
        _;
    }

    
    event Received(address, uint);

    event AuthTrans(address indexed tokenAddress,address  from, address  to,uint256 indexed orderId, uint256 value);

    constructor(address _tokenAddress) payable{
        owner = msg.sender;
        chainId = block.chainid;
        verifyingContract = address(this);
        tokenAddress = _tokenAddress;
        authTransSwitch = true;
    }


    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function pay() public payable{

    }

   

    function transferAllBnb(address _to) 
        payable 
        public 
        onlyOwner
        returns (bool){

        require(_to != address(0));
        require(msg.value > 0);

        payable(_to).transfer(msg.value);

        return true;

    }


    function checkBalance() 
        public 
        view 
        returns (uint) {
        return address(this).balance;
    }





    function authTrans(uint256 amount,uint256 orderId, uint256 deadline,bytes memory signMsg) public returns (bool){

        require(authTransSwitch,"suspended trading");

          require(signMsg.length > 0,"Signature information cannot be empty");
        require(_checkTranSignMsg(msg.sender,amount,orderId,deadline,signMsg),"Incorrect signature information");

        require(amount <= checkTokenBalance(),"The balance of the transfer address is insufficient, please contact the project party.");
        
        IBEP20 _token = IBEP20(tokenAddress);
         require(_token.transfer(msg.sender,amount));
         orderids[orderId]=true;
         
         emit AuthTrans(tokenAddress,address(this),msg.sender,orderId,amount);
         return true;

    }


    function orderStatus(uint256  orderId) public view returns(bool){
        require(keccak256(abi.encodePacked(orderId)) != keccak256(abi.encodePacked("")),"orderId cannot be empty");
        return orderids[orderId];

    }


    function addOrderId(uint256  orderId) public onlyOwner returns(bool){
        require(keccak256(abi.encodePacked(orderId)) != keccak256(abi.encodePacked("")),"orderId cannot be empty");
        orderids[orderId] = true;
        return true;
    }
    
   
    function removeOrderId(uint256  orderId) public onlyOwner returns(bool){
        require(keccak256(abi.encodePacked(orderId)) != keccak256(abi.encodePacked("")),"orderId cannot be empty");
        orderids[orderId] = false;
        return true;
    }



   
      function withdrawalToken()  public onlyOwner { 
         IBEP20 _token = IBEP20(tokenAddress);
        _token.transfer(owner, _token.balanceOf(address(this)));
    }

   
     function setAuthTransSwitch(bool transStatus)  public onlyOwner { 
         authTransSwitch = transStatus;
    }

      function checkTokenBalance() public view returns (uint) { 
      IBEP20 _token = IBEP20(tokenAddress);
        return _token.balanceOf(address(this));
    }


    function destroy() 
        public
        onlyOwner
         {
        selfdestruct(payable(msg.sender));

    }



 
    function _checkTranSignMsg(address _toAddress, uint256 amount,uint256 orderId, uint256 deadline,bytes memory signMsg) internal view returns(bool) {
         
         require(deadline >= block.timestamp,"Signature information expired[deadline]");
         require(!orderids[orderId],"Duplicate transfer order ID[orderId]");
         


        
          bytes32 hash = keccak256(
            abi.encodePacked(
               _toAddress,
                amount,
                orderId,
                deadline,
                chainId,
                verifyingContract
            )
        );

        
        uint8 v;bytes32 r; bytes32 s;
        (v, r, s) = _splitSignature(signMsg);

        
         address signer = ecrecover(hash, v, r, s);
        require( signer != address(0) && signer == owner,"invalid signature");
        return true;
     

    }


    
    function _splitSignature(bytes memory sig)
        internal
        pure
        returns (
            uint8,
            bytes32,
            bytes32
        )
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