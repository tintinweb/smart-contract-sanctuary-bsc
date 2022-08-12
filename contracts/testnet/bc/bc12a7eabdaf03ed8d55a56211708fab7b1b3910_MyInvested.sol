/**
 *Submitted for verification at BscScan.com on 2022-08-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function burn(uint256 amount)external ;
    function burnFrom(address account, uint256 amount)external ;
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



contract MyInvested  {
    struct Item { // 结构体       
        address rec;  //项目收款地址
        uint256 usdt;
        uint256 insf;
        uint256 deadline;
    }


    struct User{ 
        uint256 usdt;
        uint256 insf;
        uint256 deadline;
    }

    using Strings for uint256;
    /*索引從1開始*/
    
    mapping(uint256=>Item) public ItemList;//投资项目列表  项目ID=>项目结构

    mapping(uint256=>mapping(address=>User)) public UserList; //投资的用户 项目ID=>(用户=>投资信息)  
   

       
    IERC20 public Token;

    address private server_address;
    address private my_address;
    //投资信息
    event Invested(address indexed from, uint256  _tid,uint256 _usdt,uint256 _insf);   
    constructor() {      
        Token = IERC20(0x190f04be2c974E3063c5158A4975EE0e00dd1594);       
        server_address = address(0xa9132Faf77102854bdAABC3a7B1472B52596382c);
        my_address = msg.sender;
    }
    
  
    function verify(bytes32 dataHash, bytes memory signature) private pure returns  (address){
        require(signature.length == 65,"signature length error");
        uint8 v; bytes32 r; bytes32 s;
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
        if(v==0 || v==1){
            v=v+27;
        }
        return ecrecover(dataHash,v,r,s);
    }

    function _verify(bytes32 dataHash, bytes memory signature, address account) private pure returns (bool) {
        return verify(dataHash,signature) == account;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }    
    
    function investe(uint256 _tid , uint256 _insf,uint256 _usdt, uint256 _user_count_insf,uint256 _user_count_usdt, uint256 _count_insf,uint256 _count_usdt,uint256 deadline ,bytes memory signature) public {
        require(block.timestamp < deadline,"Timeout");
        require(_insf>0,"Insf must be greater than the 0");
        
        if(msg.sender != my_address ){
            require(_verify(toEthSignedMessageHash(abi.encode(msg.sender,_tid,_insf,_usdt, _user_count_insf, _user_count_usdt, _count_insf,_count_usdt ,deadline)), signature,server_address),"Token:signature error");
        }        

        if(_count_usdt >0 ){
           require( ItemList[_tid].usdt + _usdt <= _count_usdt,"usdt investment is full" );
        }

        if(_count_insf >0 ){
           require( ItemList[_tid].insf + _insf <= _count_insf,"insf investment is full" );
        }
        
        if( _user_count_usdt >0 ){
            require( UserList[_tid][msg.sender].usdt + _usdt <= _user_count_usdt ,"your usdt investment is full" );
        }

        if( _user_count_insf >0 ){
            require(UserList[_tid][msg.sender].insf + _insf <= _user_count_insf ,"your usdt investment is full" );
        }

        address rec =  ItemList[_tid].rec;

        if(rec== address(0) && ItemList[_tid].deadline==0){
            rec = address(this);
        }
        if(rec == address(0)){
            Token.burnFrom(msg.sender, _insf );
        }else{
            Token.transferFrom(msg.sender, rec,_insf );
        }
        UserList[_tid][msg.sender].insf = UserList[_tid][msg.sender].insf + _insf;
        UserList[_tid][msg.sender].usdt = UserList[_tid][msg.sender].usdt + _usdt;
        ItemList[_tid].usdt =  ItemList[_tid].usdt + _usdt;
        ItemList[_tid].insf =  ItemList[_tid].insf + _insf;
        UserList[_tid][msg.sender].deadline = block.timestamp;
        emit Invested(msg.sender,_tid,_usdt,_insf);
    }

    function chang_token( address _token ) public{
        require(msg.sender==my_address);
        Token = IERC20(_token);
    }
    //修改地址
    function chang_address( address _my ) public{
        require(msg.sender==my_address);
        my_address=_my;
    }
    //簽名地址
    function chang_ser( address _ser ) public{
        require(msg.sender==my_address);
        server_address=_ser;
    }
    //修改项目收款地址
    function chang_rec( uint256 tid, address _rec ) public{
        require(msg.sender==my_address);
        ItemList[tid].rec = _rec;
        ItemList[tid].deadline = block.timestamp;
    }
    fallback() external payable {}
    receive() external payable {}
    function withdraw_erc(address _erc, address _receive, uint256 _amount ) public {
        require(msg.sender==my_address);
        if(_erc==address(0)){
            if(_amount == 0){
                _amount =  address(this).balance;
            }
            (bool os, ) = payable(_receive).call{value: _amount }("");
            //(bool os, ) = payable(owner()).call{value: address(this).balance}("");
            require(os);
        }else{
            IERC20 temp =  IERC20(_erc) ;
             if(_amount == 0){
                (_amount) =  temp.balanceOf(address(this));
            }
            //(uint256 ba )= temp.balanceOf(address(this));
            temp.transfer(_receive, _amount );
        }
    }
}