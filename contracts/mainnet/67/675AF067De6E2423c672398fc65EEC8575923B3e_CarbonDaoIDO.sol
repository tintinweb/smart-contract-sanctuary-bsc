// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


import "./Ownable.sol";
import "./SafeMath.sol";
import "./Context.sol";
import "./IERC20.sol";

contract CarbonDaoIDO is Context,Ownable {
     using SafeMath for uint256;


     address public treasury;

     IERC20 public usdtToken;

     uint256 private totalFeeRate = 10000;
     uint256 private userFeeRate = 100;
     uint256 private merchantFeeRate = 200;

     struct CarbonProject{
          string  _project_name;
          address _temp_token_contract;
          address _receiving_address;//receiving usdt
          uint256 _total_token_amount;
          uint256 _token_balance;
          uint256 _usdt_balance;
          uint256 _token_price; //usdt
          bool _isOk;
     }

     mapping(address => CarbonProject) public projectMap;

     //20 add project
     event AddProjectEvent(uint256 indexed topc, string project_name_,address temp_token_contract_,address receiving_address_,uint256 total_token_amount_,uint256 token_price_);
     //21 user fee
     event TakeUserFeeEvent(uint256 indexed topc, address from, address to, uint256 feeAmount);
     //22 merchant fee
     event TakeMerchantFeeEvent(uint256 indexed topc, address from,address to,uint256 feeAmount);
     //23 order log
     event BuyOrderEvent(uint256 indexed topc,address from, address temp_token_contract, uint256 usdtAmount,uint256 tokenAmount,uint256 tokenPrice,uint256 feeAmount);

     function addProject(string memory project_name_,address temp_token_contract_,address receiving_address_,uint256 total_token_amount_,uint256 token_price_) public onlyOwner returns (bool){
          require(_msgSender() != address(0), "CarbonDao: transfer from the zero address");
          require(total_token_amount_>0,"CarbonDao: amount must be > 0");
          require(IERC20(temp_token_contract_).transferFrom(msg.sender, address(this), total_token_amount_), "CarbonDao:No approval or insufficient balance");

          CarbonProject memory projectObj = CarbonProject({
               _project_name: project_name_,
               _temp_token_contract: temp_token_contract_,
               _receiving_address: receiving_address_,
               _total_token_amount: total_token_amount_,
               _token_balance: 0,
               _usdt_balance: 0,
               _token_price: token_price_,
               _isOk: true
          });

          projectMap[temp_token_contract_] = projectObj;
          emit AddProjectEvent(20,project_name_,temp_token_contract_,receiving_address_,total_token_amount_,token_price_);
          return true;
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

     function changeProjectTokenPrice(address project_contract_, uint256 token_price_) onlyOwner public returns (bool){
          projectMap[project_contract_]._token_price = token_price_;
        return true;
     }
     
     function setTreasury(address treasury_) onlyOwner public returns (bool){
        treasury = treasury_;
        return true;
    }

     function buy(address temp_token_contract_,uint256 amount)public returns(bool){
          require(_msgSender() != address(0), "CarbonDao: transfer from the zero address");
          require(amount>0,"CarbonDao: amount must be > 0");
          require(projectMap[temp_token_contract_]._isOk,"CarbonDao: Not found this project.");
          require(usdtToken.transferFrom(msg.sender, address(this), amount), "CarbonDao:No approval or insufficient balance");

          CarbonProject memory pro = projectMap[temp_token_contract_];
          IERC20 tempToken = IERC20(pro._temp_token_contract);

          //1. take user fee
          uint256 userFeeAmount = amount.div(totalFeeRate).mul(userFeeRate);
          uint256 realBuyAmount = amount.sub(userFeeAmount);
          uint256 buyTokenAmount = realBuyAmount.mul(10**18).div(pro._token_price);
        
          require(tempToken.balanceOf(address(this))>= buyTokenAmount,"Insufficient balance of contract account");
            //Issue token
          tempToken.transfer(_msgSender(),buyTokenAmount);
          usdtToken.transfer(treasury,userFeeAmount);

          //2，take merchant fee
          uint256 merchantFeeAmount = realBuyAmount.div(totalFeeRate).mul(merchantFeeRate);
          usdtToken.transfer(treasury,merchantFeeAmount);

          //Issue usdt
          uint256 issueUsdtAmount = amount.sub(userFeeAmount).sub(merchantFeeAmount);
          usdtToken.transfer(pro._receiving_address,issueUsdtAmount);

          projectMap[temp_token_contract_]._token_balance = projectMap[temp_token_contract_]._total_token_amount.sub(buyTokenAmount);
          projectMap[temp_token_contract_]._usdt_balance = projectMap[temp_token_contract_]._usdt_balance.add(issueUsdtAmount);

          emit TakeUserFeeEvent(21, _msgSender(),treasury,userFeeAmount);
          emit TakeMerchantFeeEvent(22,pro._receiving_address,treasury,merchantFeeAmount);
          emit BuyOrderEvent(23,_msgSender(),pro._temp_token_contract,amount,buyTokenAmount,pro._token_price,userFeeAmount);
          return true;
     }

}