/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

// SPDX-License-Identifier: Exchange
pragma solidity ^0.8.0;
interface GlodContract{
    function transfer(address sender,uint256 amount) external returns (bool);
    function transferFrom(address sender,address to,uint256 amount) external returns (bool);
    
}
interface NftContract{
    function totalSupply() external view  returns (uint256);
    function toTransfer(address from_,address to_,uint256 tokenId_) external returns (bool);
    function ownerOf(uint256 tokenid_) external view returns (address);
}
contract Exchange{
    address public _owner;
    modifier Owner {
        require(_owner == msg.sender);
        _;
    }
    uint256 public serviceCharge;
    address public chargingAddress;
    uint256 public orderId;
    mapping(uint256=>order) public orders; 
    struct order{
        address     account;
        address     nftContract;
        address     glodContract;
        uint256     price;
        uint256     tokenId;
        address     to;
        uint64      state;
    }
    event _addTheOrder(uint256 _orderId);
    event _cancellationOfOrder(uint256 _orderId); 
    event _buyOrder(uint256 _orderId);
    constructor(uint256 orderId_,uint256 serviceCharge_,address chargingAddress_)
        {
            require (serviceCharge_ > 0 && serviceCharge_ < 1000,"parameter error");
            orderId = orderId_;
            serviceCharge = serviceCharge_;
            chargingAddress = address(chargingAddress_);
            _owner = msg.sender;
        }
    function modifyingServiceCharges(uint256 serviceCharge_)
        public 
        Owner
        returns(bool)
        {
            require (serviceCharge_ > 0 && serviceCharge_ < 1000,"parameter error");
            serviceCharge = serviceCharge_;
            return true;
        }
    function modifyTheServer(address chargingAddress_)
        public
        Owner
        returns(bool)
        {
            chargingAddress = chargingAddress_;
            return true;
        }
    function toAddTheOrder(address nftContract_,address glodContract_,uint256 price_,uint256 tokenId_)
        public
        returns(bool)
        {
            orderId = orderId + 1;
            orders[orderId] = order(msg.sender,nftContract_,glodContract_,price_,tokenId_,address(0x00),1);
            _transferToken(nftContract_,msg.sender,address(this),tokenId_);
            emit _addTheOrder(orderId);
            return true;
        } 
    function theOrderDetailsImmutable(uint256 orderId_)
        view
        public
        returns(address account_,address gameContract_,address glodContract_,uint256 tokenId_,address to_,uint256 price_,uint256 state_)
        {
            return (orders[orderId_].account,
                    orders[orderId_].nftContract,
                    orders[orderId_].glodContract,
                    orders[orderId_].tokenId,
                    orders[orderId_].to,
                    orders[orderId_].price,
                    orders[orderId_].state
                    );
        } 
    function toCancel(uint256 orderId_)
        public
        returns(bool)
        {
            order storage myOrder= orders[orderId_];
            require (msg.sender == myOrder.account,"Do not have permission");
            require (myOrder.state == 1,"Abnormal order status");
            myOrder.state = 3;
            _transferToken(myOrder.nftContract,address(this),msg.sender,myOrder.tokenId);
            emit _cancellationOfOrder(orderId_);
            return true;
        }    
    function buyOrder(uint256 orderId_)
        public
        payable
        returns(bool)
        {
            order storage myOrder= orders[orderId_];
            require (myOrder.state == 1,"Abnormal order status");
            myOrder.state = 2;
            myOrder.to = msg.sender;
            GlodContract coinContract = GlodContract(myOrder.glodContract);  
            //这里需要判断是否收取手续费
            uint256 transactionServiceCharge = myOrder.price * serviceCharge / 1000; 
            uint256 transactionFee = myOrder.price - transactionServiceCharge;        
            coinContract.transferFrom(msg.sender,myOrder.account,transactionFee);
            coinContract.transferFrom(msg.sender,chargingAddress,transactionServiceCharge);
            _transferToken(myOrder.nftContract,address(this),msg.sender,myOrder.tokenId);
            emit _buyOrder(orderId_);
            return true;
        }    
    function _transferToken(address _contractAddress,address _from,address _to,uint256 _tokenid)
        internal 
        returns(bool) 
        {
            NftContract(_contractAddress).toTransfer(_from,_to,_tokenid);
            return true;
        }  
    function onERC1155Received(address,address,uint256,uint256,bytes calldata) external pure returns(bytes4){
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }
    
}