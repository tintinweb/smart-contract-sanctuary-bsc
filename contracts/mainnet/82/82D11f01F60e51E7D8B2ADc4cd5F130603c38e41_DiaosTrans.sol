/**
 *Submitted for verification at BscScan.com on 2022-08-15
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

contract DiaosTrans {


    address public owner; //创建合约owner地址
    uint256 public chainId;  //链id
    address public verifyingContract; //指定验证签名的合约地址，
    address public tokenAddress; //合约处理授权转账的token地址
    bool public authTransSwitch; //交易状态

    mapping (uint256 => bool) private orderids;



    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can call this");
        _;
    }

    // 修饰器为修饰判断某个address类型的值不为0地址
    modifier notAddress(address _useAdd){
        require(_useAdd != address(0), "address is error");
        _;
    }

    // 该event事件为合约收到转账时候触发
    event Received(address, uint);

    //授权转账event事件
    event AuthTrans(address indexed tokenAddress,address  from, address  to,uint256 indexed orderId, uint256 value);

    constructor(address _tokenAddress) payable{
        owner = msg.sender;
        chainId = block.chainid;
        verifyingContract = address(this);
        tokenAddress = _tokenAddress;
        authTransSwitch = true;
    }

    //当合约收到转账时候该方法会被调用，方法内实现了去触发Received event事件
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    //该方法定义了payable，代表后面可以通过该方法往合约里面转移BNB
    function pay() public payable{

    }

   

    //通过合约直接给_to地址转移所有的Bnb
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


    //检查合约账户剩余的可用Bnb数量
    function checkBalance() 
        public 
        view 
        returns (uint) {
        return address(this).balance;
    }





    //授权转账
    function authTrans(uint256 amount,uint256 orderId, uint256 deadline,bytes memory signMsg) public returns (bool){

        require(authTransSwitch,"suspended trading");

          require(signMsg.length > 0,"Signature information cannot be empty");
        //检查签名
        require(_checkTranSignMsg(msg.sender,amount,orderId,deadline,signMsg),"Incorrect signature information");

        //判断余额是否充足，不充足做相应的提示
        require(amount <= checkTokenBalance(),"The balance of the transfer address is insufficient, please contact the project party.");
        
        //转账处理
        IBEP20 _token = IBEP20(tokenAddress);
         require(_token.transfer(msg.sender,amount));
         orderids[orderId]=true;
         
         emit AuthTrans(tokenAddress,address(this),msg.sender,orderId,amount);
         return true;

    }

    //订单状态
    function orderStatus(uint256  orderId) public view returns(bool){
        require(keccak256(abi.encodePacked(orderId)) != keccak256(abi.encodePacked("")),"orderId cannot be empty");
        return orderids[orderId];

    }


    //回收token到owner地址
      function withdrawalToken()  public onlyOwner { 
         IBEP20 _token = IBEP20(tokenAddress);
        _token.transfer(owner, _token.balanceOf(address(this)));
    }

    //设置交易状态 true:开 false:暂停
     function setAuthTransSwitch(bool transStatus)  public onlyOwner { 
         authTransSwitch = transStatus;
    }

    //查看token 余额
      function checkTokenBalance() public view returns (uint) { 
      IBEP20 _token = IBEP20(tokenAddress);
        return _token.balanceOf(address(this));
    }


  // 销毁合约，合约被销毁后，合约中剩余的BNB将会被转移到合约铸造者地址中，且合约后面将不再可用
    function destroy() 
        public
        onlyOwner
         {
        selfdestruct(payable(msg.sender));

    }



    //检查转账签名 _toAddress:收款地址  amount:收款金额  orderId:转账订单id防止重复提交 deadline:过期时间  signMsg：签名信息
    function _checkTranSignMsg(address _toAddress, uint256 amount,uint256 orderId, uint256 deadline,bytes memory signMsg) internal view returns(bool) {
         
         require(deadline >= block.timestamp,"Signature information expired[deadline]");
         require(!orderids[orderId],"Duplicate transfer order ID[orderId]");
         


        //生成校验msg
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

        //根据签名获取r,s,v
        uint8 v;bytes32 r; bytes32 s;
        (v, r, s) = _splitSignature(signMsg);

        //校验签名
         address signer = ecrecover(hash, v, r, s);
        require( signer != address(0) && signer == owner,"invalid signature");
        return true;
     

    }


    //获取签名信息，获取v,r,s
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