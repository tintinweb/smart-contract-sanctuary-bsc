// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


import "./Ownable.sol";
import "./SafeMath.sol";
import "./Context.sol";
import "./IERC20.sol";
import "./strings.sol";

contract CarbonDaoMarket is Context,Ownable {
     using SafeMath for uint256;
     using strings for *;

     address public treasury;

     IERC20 public usdtToken;
     uint256 public orderIndex = 1;

     uint256 private totalFeeRate = 10000;
     uint256 private userFeeRate = 100;
     uint256 private merchantFeeRate = 100;

     struct PendingOrder{
          string _order_id;
          uint256 _order_time;
          uint256 _total_token_amount;
          uint256 _order_price;
          uint256 _order_token_balance;
          uint256 _order_usdt_balance;

          address _token_contract;
          address _receiving_usdt_address;

          bool _isOk;
     }

     mapping(string => PendingOrder) public pendingOrderMap;

     //10 pending order
     event PendingOrderEvent(uint256 indexed topc, string order_id_, uint256 order_time_,uint256 total_token_amount_,uint256 order_price_,address token_contract_,address receiving_usdt_address_);

     //11 user fee
     event TakeUserFeeEvent(uint256 indexed topc,string  order_id_, address from, address to, uint256 feeAmount);

     //12 merchant fee
     event TakeMerchantFeeEvent(uint256 indexed topc,string  order_id_, address from,address to,uint256 feeAmount);

     //13 order log
     event BuyOrderEvent(uint256 indexed topc,string  order_id_, address user, address temp_token_contract, uint256 usdtAmount,uint256 tokenAmount,uint256 tokenPrice,uint256 feeAmount);
     
     //14 revoke pending order
     event RevokePendingOrderEvent(uint256 indexed topc,string  order_id_);

     function pendingOrder(uint256 total_token_amount_,uint256 order_price_,address token_contract_) public returns(string memory){
          require(msg.sender != address(0), "CarbonDao: transfer from the zero address");
          require(total_token_amount_>0,"CarbonDao: amount must be > 0");
          require(IERC20(token_contract_).transferFrom(msg.sender, address(this), total_token_amount_), "CarbonDao:No approval or insufficient balance");
          
          string memory orderId = genOrderId();
          uint256 orderTime = block.timestamp;
          PendingOrder memory order = PendingOrder({
               _order_id: orderId,
               _order_time: orderTime,
               _total_token_amount: total_token_amount_,
               _order_price: order_price_,
               _order_token_balance: total_token_amount_,
               _order_usdt_balance: 0,
               _token_contract: token_contract_,
               _receiving_usdt_address: msg.sender,
               _isOk: true
          });

          pendingOrderMap[orderId] = order;
          orderIndex = orderIndex+1;

          emit PendingOrderEvent(10,orderId,orderTime,total_token_amount_,order_price_,token_contract_,msg.sender);
          return orderId;
     }

     function setUsdtToken(IERC20 usdtToken_) onlyOwner public returns (bool){
        usdtToken = usdtToken_;
        return true;
    }

     function setMerchantFeeRate(uint256 merchant_fee_rate_) onlyOwner public returns (bool){
          merchantFeeRate = merchant_fee_rate_;
        return true;
    }

    function setUserFeeRate(uint256 user_fee_rate_) onlyOwner public returns (bool){
          userFeeRate = user_fee_rate_;
        return true;
    }

     function revokePendingOrder(string memory order_id_)public returns (bool){
          require(pendingOrderMap[order_id_]._isOk,"CarbonDao: Not found this project.");
          PendingOrder memory order = pendingOrderMap[order_id_];
          require(order._receiving_usdt_address==msg.sender,"CarbonDao: No permission");

          if(order._order_token_balance>0){
               IERC20(order._token_contract).transfer(order._receiving_usdt_address,order._order_token_balance);
          }

          pendingOrderMap[order_id_]._isOk = false;
          emit RevokePendingOrderEvent(14,order_id_);
          return true;
     }
     
     function setTreasury(address treasury_) onlyOwner public returns (bool){
        treasury = treasury_;
        return true;
    }

     function buy(string memory pending_order_id_,uint256 buy_token_amount_)public returns(bool){
          require(msg.sender != address(0), "CarbonDao: transfer from the zero address");
          require(buy_token_amount_>0,"CarbonDao: amount must be > 0");
          require(pendingOrderMap[pending_order_id_]._isOk,"CarbonDao: Not found this project.");

          // require(usdtToken.transferFrom(msg.sender, address(this), amount), "CarbonDao:No approval or insufficient balance");
          PendingOrder memory pendingOrder = pendingOrderMap[pending_order_id_];
          IERC20 tempToken = IERC20(pendingOrder._token_contract);
          require(tempToken.balanceOf(address(this))>buy_token_amount_,"CarbonDao: contract temp token balance must be > buy token amount.");
          require(pendingOrder._order_token_balance>buy_token_amount_,"CarbonDao: order token balance must be > buy token amount.");

          //1,take usdt
          uint256 buyUsdtAmount = buy_token_amount_.mul(pendingOrder._order_price).div(10**18);
          uint256 feeUsdtAmount = buy_token_amount_.mul(userFeeRate).div(totalFeeRate).mul(pendingOrder._order_price).div(10**18);
          require(usdtToken.transferFrom(msg.sender, address(this), buyUsdtAmount.add(feeUsdtAmount)), "CarbonDao:No approval or insufficient balance");
          usdtToken.transfer(treasury,feeUsdtAmount);
          
          //2. take user fee
          uint256 merchantFeeAmount = buyUsdtAmount.div(totalFeeRate).mul(merchantFeeRate);
          usdtToken.transfer(treasury,merchantFeeAmount);
          usdtToken.transfer(pendingOrder._receiving_usdt_address,buyUsdtAmount.sub(merchantFeeAmount));
          
          //Issue token
          tempToken.transfer(_msgSender(),buy_token_amount_);
        
          pendingOrderMap[pending_order_id_]._order_token_balance = pendingOrderMap[pending_order_id_]._order_token_balance.sub(buy_token_amount_);
          pendingOrderMap[pending_order_id_]._order_usdt_balance = pendingOrderMap[pending_order_id_]._order_usdt_balance.add(buyUsdtAmount);

          emit TakeUserFeeEvent(11,pending_order_id_,_msgSender(),treasury,feeUsdtAmount);
          emit TakeMerchantFeeEvent(12,pending_order_id_,pendingOrder._receiving_usdt_address,treasury,merchantFeeAmount);
          emit BuyOrderEvent(13,pending_order_id_,_msgSender(),pendingOrder._token_contract,buyUsdtAmount.add(feeUsdtAmount),buy_token_amount_,pendingOrder._order_price,feeUsdtAmount);
          return true;
     }

     function genOrderId() internal returns(string memory) {
          string memory indexStr = orderIndex.toString();
          string memory orderId = block.timestamp.toString().toSlice().concat(indexStr.toSlice());
          return orderId;
     }

}