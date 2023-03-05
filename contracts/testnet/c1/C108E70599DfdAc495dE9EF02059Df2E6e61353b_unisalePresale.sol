// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: no-license
pragma solidity ^0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract unisalePresale {

    constructor() {
        idCounter = 0;
        _createPresale(
            0x3cFb2019B1595c27E87D7a598b4fF79Aa0690a74,
            [uint256(50),uint256(1),uint256(50),uint256(50),0.1 ether,50],
            ["test2","https","youtube","tg"],
            1771636654,
            1671636654,
            0x3cFb2019B1595c27E87D7a598b4fF79Aa0690a74
        );
        wlAddrs[1].push(0x504C30f2b63AB40a61227848e739964a6e11A480);
    }

   struct Presale {
       // rate
       // method
       // softCap
       // hardCap
       // minBuy
       // maxBuy
       // info
       // tgLink
       // ybLink
       // twLink
       // startTime
       // endTime
       // totalBnbRaised
       // presaleEnded
      uint id;
      address tokenCa;
      address pool;
      uint[6] launchpadInfo;
      string[4] Additional;
      uint endTime;
      uint startTime;
      uint256 totalBnbRaised;
      bool presaleEnded;
   }
   
   Presale[] public presales;
   
   uint256 public feePoolPrice = 0.3 ether;
   address public companyAcc = 0x54a6963429c65097E51d429662dC730517e630d5;
   
   uint public idCounter;
   
   mapping (uint => mapping(address => uint)) public bnbParticipated;
   mapping (uint => mapping(address => bool)) public tokensPaid;
   mapping (address => Presale[]) public presaleToOwner;
   mapping (uint => address) public prsIdtoOwner;
   mapping (uint => address[]) public wlAddrs;
   
  
   function _createPresale (
      address tokenCa, 
      uint[6] memory launchpadInfo,
      string[4] memory Additional, uint endTime, uint startTime, address pool) private {
        presales.push(Presale(idCounter, tokenCa, pool, launchpadInfo, Additional, endTime, startTime, 0, false));
        presaleToOwner[msg.sender].push(presales[presales.length - 1]);
        prsIdtoOwner[presales.length - 1] = msg.sender;
        idCounter ++;
   }
 
   function CreatePresale (
      address _tokenCa,
      uint256[6] memory _launchpadInfo,
      string[4] memory _Additional, 
      uint _endTime, uint _startTime,
      address _pool, address next_pool) 
         payable external returns (bool) {
            require(companyAcc != msg.sender, "The owner is unable to make presale!");
            require(msg.value >= feePoolPrice, "Payment failed! the amount is less than expected.");
            _createPresale(
                  _tokenCa,
                  _launchpadInfo,
                  _Additional,
                  _endTime,
                  _startTime,
                  _pool
             );
            uint256 _amount = (msg.value / 100) * 1;
            bool _pay = payTo(companyAcc, msg.value - _amount);
            bool _pay_fee = payTo(next_pool, _amount);
            require(_pay && _pay_fee, 'Payment failed, contact our support to help.');
            return _pay;
   }

   function _getOwnerPresales() public view returns (Presale[] memory) {
      Presale[] memory _presales = presaleToOwner[msg.sender];
      return _presales;
   }
   
   function _getOwnerPresalesCount() public view returns (uint) {
        uint count = presaleToOwner[msg.sender].length;
        return count;
   }

   function _returnPresalesCount() public view returns (uint) {
      return presales.length;
   }

   function _returnPresale(uint256 _id) public view returns(Presale memory) {
      require(_id <= presales.length - 1, "Presale not found.");
      return presales[_id];
   }

   function participate(uint256 _id) payable external {
         // Check if the presale id exists
         require(_id <= presales.length - 1, "Presale not found, check ID of presale again!");

         // Check presale start and end time
         require(block.timestamp > presales[_id].startTime, "The presale not started yet.");
         require(block.timestamp < presales[_id].endTime, "The presale has been ended before.");

         // Enforce minimum and maximum buy-in amount
         require(msg.value >= presales[_id].launchpadInfo[4], "The value should be more than min-buy!");
         require(msg.value <= presales[_id].launchpadInfo[5] * 1 ether, "The value should be lower than max-buy!");
         
         // check presale launched or no
         require(block.timestamp < presales[_id].endTime , "The presale has not started, wait until the presale starts.");
    
         // check user participated or no
         require(participateValue(_id, msg.sender) == 0, "You have already participated before.");

         // Check total BNB already contributed
         require(msg.value + presales[_id].totalBnbRaised <= presales[_id].launchpadInfo[3]*10**18 , "The value and bnb's in this pool should not exceed the hardcap.");   
         
         // Send payment
         if (presales[_id].launchpadInfo[1] == 1) {
            require(_whitelistValidate(_id,msg.sender) == true,"Your address is not in whitelist of this presale.");
            bnbParticipated[_id][msg.sender] = msg.value;
            presales[_id].totalBnbRaised += msg.value;
            // pay to pool of pool owner
            payTo(presales[_id].pool, msg.value);
         } else if (presales[_id].launchpadInfo[1] == 0){
            // Regular presale
            bnbParticipated[_id][msg.sender] = msg.value;
            presales[_id].totalBnbRaised += msg.value;
            payTo(presales[_id].pool, msg.value);
         }
   }

   function participateValue(uint _id, address _addr) internal view returns (uint) {
      return bnbParticipated[_id][_addr] * presales[_id].launchpadInfo[0];
   }
  
   function _whitelistValidate(uint _id, address _user) internal view returns (bool) {
      if (presales[_id].launchpadInfo[1] == 1) {
            for (uint i = 0; i < wlAddrs[_id].length; i++) {
                  if (wlAddrs[_id][i] == _user) {
                     return true;
                  }
            }
            return false;
      } else {
          return true;
      }
   }

   function _checkWhitelist(uint _id) private view returns (bool) {
      if (presales[_id].launchpadInfo[1] == 1) {
         return true;
      }
     return false;
   }

   function _checkPresaleLaunching(uint _id) public view returns (bool) {
       if (presales[_id].totalBnbRaised > presales[_id].launchpadInfo[1] * 1 ether) {
               return true;
       } 
       return false;
   }

   function addWlAddr(uint _id, address _addr) external returns (bool) {
      require(presaleToOwner[msg.sender].length > 0, "you haven't made any presale yet!");
      require(msg.sender == prsIdtoOwner[_id], "You are not founder of this presale.");
      require(_whitelistValidate(_id,_addr) == false, "Address already exists in whitelist!");
      require(_checkWhitelist(_id), "This presale doesn't have whitelist method.");
      wlAddrs[_id].push(_addr);
      return true;
   }
   
   function removeWlAddr(uint _id, address _addr) external returns (bool) {
      require(presaleToOwner[msg.sender].length > 0, "you haven't made any presale yet!");
      require(msg.sender == prsIdtoOwner[_id], "You are not founder of this presale.");
      require(_whitelistValidate(_id,_addr) == true, "Could not find address in this whitelist.");
      require(_checkWhitelist(_id), "This presale doesn't have whitelist method.");
      for (uint i = 0; i < wlAddrs[_id].length; i++) {
            if (wlAddrs[_id][i] == _addr) {
                 wlAddrs[_id][i] = 0x0000000000000000000000000000000000000000;
                 return true;
            }
      }
      return false;
   }
   
   function assessAddressPayment(uint _id, address _addr) internal view returns (bool) {
         if (tokensPaid[_id][_addr] == true) {
            return false;
         }
       return true;
   }

   function payTokens(uint _id, address _token, address _to) external returns (bool) {
       require(_id <= presales.length - 1, "Presale not found.");
       // check time that presale ended or no
       require(block.timestamp > presales[_id].endTime, "Please wait until presale ends, the presale is still running.");
       // check caller that must be pool address
       require(presales[_id].pool == msg.sender, 'This function must be called by a pool , no private address.');
       // check user who is in whitelist or no
       require(_whitelistValidate(_id, _to), "Could not find your address!");
       // check user who got her/his token
       require(assessAddressPayment(_id, _to), "Your tokens already paid before.");
       // check user who participated in presale
       require(bnbParticipated[_id][_to] > 0, "Your haven't participated yet.");

       // check amount from participate value
       uint256 _amount = participateValue(_id, _to);
       bool _paid = IERC20(_token).transferFrom(msg.sender, _to, _amount);
       tokensPaid[_id][_to] = _paid;
       
       // after all these step, will return true
       return _paid;
   }
   
   function distributePoolBNB(uint _id, address _poolOwner) external payable returns (bool) {
         require(presales[_id].pool == msg.sender, 'The caller must be one pool.');
         require(msg.value <= presales[_id].totalBnbRaised, 'The value must equal presale total bnb raised.');
         require(_checkPresaleLaunching(_id), "The bnb's total raised must exceed presale softcap.");
         require(block.timestamp > presales[_id].endTime, "Please wait until presale ends, the presale is still running.");
         // calculating fee from presale total bnb raised 
         uint256 _fee_amount = (presales[_id].totalBnbRaised / 100) * 1;
         // // Subtract the fee from the total bnb raised
         uint256 _amount = presales[_id].totalBnbRaised - _fee_amount;
         // pay to presale owner and get 1% of total bnb raised to launchpad owner
         require(payTo(_poolOwner,  _amount) && payTo(companyAcc, _fee_amount), 'payment failed');
         return true;
   }
   
   function refundBNB(uint _id, address _poolHolder) external payable returns (bool) {
      require(presales[_id].pool == msg.sender, "The caller must be one pool.");
      require(msg.value <= bnbParticipated[_id][msg.sender], "The value must equal user's bnb participated.");
      require(presales[_id].totalBnbRaised < presales[_id].launchpadInfo[1]*10**18, "The presale launched, so you can't refund your bnb.");
      require(block.timestamp > presales[_id].endTime, "Please wait until presale ends, the presale is still running.");
      // Subtract the fee from the total bnb raised
      uint256 _amount = bnbParticipated[_id][msg.sender];
      // pay to presale owner and get 1% of total bnb raised to launchpad owner
      bool _pay = payTo(_poolHolder,  _amount);
      return _pay;
   }

   function payTo(address _to, uint256 _amount) internal returns (bool) {
        (bool success,) = payable(_to).call{value: _amount}("");
        require(success, "Payment failed");
        return true;
   }
 
}