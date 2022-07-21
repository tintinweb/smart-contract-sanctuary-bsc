/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

// File: contracts/IController.sol


pragma solidity ^0.8.3;

abstract contract IController{
   function canJoin(address account) external view virtual returns(bool);
   function useReferral(string memory _code) external virtual;
   function wasUsed(string memory _code) public view virtual returns (bool result);
   function renewCode() external virtual;
   function getRemaining(address account) public view virtual returns (uint256 result);
}

// File: contracts/IReferral.sol


pragma solidity ^0.8.3;

abstract contract IReferral{

   struct Code{
      address owner;
      address user;
   }

   function canJoin(address account) external view virtual returns(bool);
   function useReferral(address account,string memory _code) external virtual;
   function wasUsed(address account,string memory _code) public view virtual returns (bool result);
}

// File: contracts/IActivation.sol


pragma solidity ^0.8.3;

abstract contract IActivation{

   struct Code{
      address owner;
      address user;
      uint256 lifespan;
   }

   function canJoin(address account) external view virtual returns(bool);
   function useReferral(address account,string memory _code) external virtual;
   function wasUsed(address account,string memory _code) public view virtual returns (bool result);
   function renewCode(address account) external virtual;
   function getRemaining(address account) public view virtual returns (uint256 result);
}

// File: contracts/ReferralController.sol


// solhint-disable not-rely-on-time
pragma solidity ^0.8.3;




contract ReferralController is IController {

    IReferral public referral;
    IActivation public activation;

    constructor(address _referral,address _activation){
        referral = IReferral(_referral);
        activation = IActivation(_activation);
    }

    function canJoin(address account) external override view returns(bool result){
        result = false;
        if(referral.canJoin(account) || activation.canJoin(account))
        {
                result = true;
        }
    }

    function useReferral(string memory _code) external override{
        if(referral.wasUsed(msg.sender,_code))
        {
            activation.useReferral(msg.sender,_code);
        }else{
            referral.useReferral(msg.sender,_code);
        }
    }

    function wasUsed(string memory _code) public override view returns (bool result) {
        result = true;
        if(!referral.wasUsed(msg.sender,_code) || !activation.wasUsed(msg.sender,_code))
        {
            result = false;
        }

        return result;
    }

    function renewCode() external override {
        activation.renewCode(msg.sender);
    }

    function getRemaining(address account) public view override returns (uint256 result) {
        result = activation.getRemaining(account);
    }

    
}