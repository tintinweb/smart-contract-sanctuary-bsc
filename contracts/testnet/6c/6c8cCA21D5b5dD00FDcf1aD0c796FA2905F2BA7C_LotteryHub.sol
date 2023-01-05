// SPDX-License-Identifier: GPL-3.0
// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// File: teste.sol




      pragma solidity ^0.8.0;


      contract LotteryHub is ReentrancyGuard {

      address public HubOwner;
      uint256 public CreatedLotterys;
      uint256 public CostPerLottery;
      address public FeesAddress;
      address public Operator;
      
      struct LotteryStruct {
      uint256 LotteryId;
      address Owner;
      uint8 Fees;
      uint256 CostPerTicket;
      address [] Tickets;
      uint256 Duration;
      uint256 MaxTickets;
      uint256 MaxTicketsPerAddress;
      bool isActive;
      bool started;
      address winner;
      }
      
      mapping(uint256 => LotteryStruct) public lotteryStructs;
      mapping(address => uint256) public winnings; // maps the winners to there winnings
      mapping(address => uint256) public LotteryCreatorFees; // maps the lottery creators to fees commision
      mapping(address => uint256) public HubOwnerFees; // maps the lottery creators to fees commision

            constructor(address _HubOwner,address _Operator) {
            HubOwner = _HubOwner;
            CreatedLotterys = 0;
            CostPerLottery = 0.05 ether;
            FeesAddress = _HubOwner;
            Operator = _Operator;
            }

            event LotteryWinners(
            uint256 lotteryNumb,
            address Winner,
            uint256 amountWon
            );

            modifier isOwner() {
            require((msg.sender == HubOwner),"Caller dont't have permissions");
            _;
      }

            modifier isOperator() {
            require((msg.sender == Operator || msg.sender == HubOwner),"Caller dont't have permissions");
            _;
      }

      function newLottery(uint8 _Fees, uint256 _CostPerTicket, uint256 _Duration, uint256 _MaxTickets, uint256 _MaxTicketsPerAddress) public payable returns(uint256 index) {
      
      require(msg.value >= CostPerLottery, "Insufficient fee");
      HubOwnerFees[FeesAddress] += CostPerLottery;

      uint256 lotteryNumb = CreatedLotterys++;
      address [] memory ticketsArray;
      lotteryStructs[lotteryNumb].LotteryId = lotteryNumb;
      lotteryStructs[lotteryNumb].Owner   = msg.sender;
      lotteryStructs[lotteryNumb].Fees   = _Fees;
      lotteryStructs[lotteryNumb].CostPerTicket = _CostPerTicket;
      lotteryStructs[lotteryNumb].Tickets = ticketsArray;
      lotteryStructs[lotteryNumb].Duration = _Duration;
      lotteryStructs[lotteryNumb].MaxTickets = _MaxTickets;
      lotteryStructs[lotteryNumb].MaxTicketsPerAddress = _MaxTicketsPerAddress;
      lotteryStructs[lotteryNumb].isActive = true;
      lotteryStructs[lotteryNumb].started = false;

      return lotteryStructs[lotteryNumb].LotteryId;
      }

      function getAllLottery() public view returns (LotteryStruct[] memory) {

            LotteryStruct[] memory items = new LotteryStruct[](CreatedLotterys);

            for(uint i = 0; i < CreatedLotterys; i++) {
                  LotteryStruct storage currentLottery = lotteryStructs[i];
                  items[i] = currentLottery;
            }

            return items;
      }

      function getAllLotteryFromAddress(address _LotteryOwnerAddress) public view returns (LotteryStruct[] memory) {

            LotteryStruct[] memory items = new LotteryStruct[](CreatedLotterys);

            for(uint i = 0; i < CreatedLotterys; i++) {
                  uint lotteryID = i;
                  if (lotteryStructs[lotteryID].Owner == _LotteryOwnerAddress){
                  LotteryStruct storage currentLottery = lotteryStructs[lotteryID];
                  items[lotteryID] = currentLottery;
                  }
                  lotteryID += 1;
            }

            return items;
      }
      function getLotteryById(uint256 _LotteryKey) public view returns (LotteryStruct memory) {
            return lotteryStructs[_LotteryKey];
      }
      
      function GetLotteryTickets(uint256 _LotteryKey) public view returns (address[] memory) {
            return lotteryStructs[_LotteryKey].Tickets;
      }

      function BuyTickets(uint256 _LotteryKey) public payable nonReentrant{
            require(lotteryStructs[_LotteryKey].isActive, "This lottery is not active");
            require(lotteryStructs[_LotteryKey].MaxTickets > lotteryStructs[_LotteryKey].Tickets.length, "This lottery has reached the maximum number of tickets");
            require(lotteryStructs[_LotteryKey].CostPerTicket <= msg.value, "Insufficient payment");
            if(lotteryStructs[_LotteryKey].started == true){
                  require(lotteryStructs[_LotteryKey].Duration < block.timestamp, "This lottery already ended!");
            }
            uint256 hasAlreadyBought = 0;
            for (uint i = 0; i < lotteryStructs[_LotteryKey].Tickets.length; i++) {
            if (lotteryStructs[_LotteryKey].Tickets[i] == msg.sender) {
                  hasAlreadyBought ++;
            }
            }

            require(hasAlreadyBought < lotteryStructs[_LotteryKey].MaxTicketsPerAddress, "You bought the maximum number of tickets per address");
            lotteryStructs[_LotteryKey].Tickets.push(msg.sender);
            StartLotteryDuration(_LotteryKey);
            
      }

      function StartLotteryDuration(uint256 _LotteryKey) public {
            if(lotteryStructs[_LotteryKey].started == false){
            for (uint i = 0; i < lotteryStructs[_LotteryKey].Tickets.length; i++) {
                        if (lotteryStructs[_LotteryKey].Tickets[0] != lotteryStructs[_LotteryKey].Tickets[i]) {
                              lotteryStructs[_LotteryKey].started = true;
                              lotteryStructs[_LotteryKey].Duration = block.timestamp + lotteryStructs[_LotteryKey].Duration;
                        }
                  }
            }

      }
      
      function DrawWinnerTicket(uint256 _LotteryKey) public isOperator() nonReentrant{
            require(lotteryStructs[_LotteryKey].Tickets.length > 0, "No tickets were purchased");
            require(lotteryStructs[_LotteryKey].Tickets.length > 1, "Not enough players to make a draw");

            bytes32 blockHash = blockhash(block.number - lotteryStructs[_LotteryKey].Tickets.length);
            uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, blockHash)));
            uint256 winningTicket = randomNumber % lotteryStructs[_LotteryKey].Tickets.length;
            address winner = lotteryStructs[_LotteryKey].Tickets[winningTicket];

            uint256 numTickets = lotteryStructs[_LotteryKey].Tickets.length;
            uint256 ticketCost = lotteryStructs[_LotteryKey].CostPerTicket;
            uint256 totalAmount = numTickets * ticketCost;

            LotteryCreatorFees[lotteryStructs[_LotteryKey].Owner] += (totalAmount * lotteryStructs[_LotteryKey].Fees / 100);
            winnings[winner] += (totalAmount - LotteryCreatorFees[lotteryStructs[_LotteryKey].Owner]);

            lotteryStructs[_LotteryKey].isActive=false;
            lotteryStructs[_LotteryKey].winner = winner;
            emit LotteryWinners(_LotteryKey, winner, totalAmount);
            
      }

      function RemainingTickets(uint256 _LotteryKey) public view returns (uint256) {
            return lotteryStructs[_LotteryKey].MaxTickets - lotteryStructs[_LotteryKey].Tickets.length;
      }
      

      function getWinnings() public nonReentrant {
            require((winnings[msg.sender] + LotteryCreatorFees[msg.sender]) > 0, "You don't have any winnings!");
            address payable toSend = payable(msg.sender);

            toSend.transfer(winnings[msg.sender]+LotteryCreatorFees[msg.sender]);
            winnings[msg.sender] = 0;
            LotteryCreatorFees[msg.sender] = 0;
      }

      function setCostPerLottery(uint256 _CostPerLottery) public isOwner {
            CostPerLottery = _CostPerLottery;
      }
      
      function setFeesAddress(address _FeesAddress) public isOwner {
            FeesAddress = _FeesAddress;
      }

      function setHubOwner(address _HubOwner) public isOwner {
            HubOwner = _HubOwner;
      }

      function setOperator(address _Operator) public isOwner {
            Operator = _Operator;
      }

      function getHubOwnerComissions() public isOwner nonReentrant{
            require(HubOwnerFees[HubOwner] > 0, "You don't have any comission amount");
            address payable toSend = payable(HubOwner);
            
            toSend.transfer(HubOwnerFees[HubOwner]);
            HubOwnerFees[HubOwner] = 0;
      }


      function getAddressBalance(address _address) public view returns (uint256) {
            return LotteryCreatorFees[_address] + winnings[_address];
      
      }
}