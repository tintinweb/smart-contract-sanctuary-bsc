/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

pragma solidity >=0.5.0 <0.7.0;
pragma experimental ABIEncoderV2;

contract ZXL {
  struct IDCard {
    uint256 number;
  }
  struct Man {
    IDCard card;
    string name;
    uint256 age;
  }
  struct InvariantTransactionData {
    address receivingChainTxManagerAddress;
    address user;//0x0fC64d3724D4282DAB2dd689f93C5A245C2C4A68
    // 0x92495600b72EF0e1fa22453b58938A9af49918aE
    address router;// 0x92495600b72EF0e1fa22453b58938A9af49918aE
    address initiator; // msg.sender of sending side
    address sendingAssetId;// 0xDDAfbb505ad214D7b80b1f830fcCc89B60fb7A83 usdc
    address receivingAssetId;
    address sendingChainFallback; // funds sent here on cancelb //0x0fC64d3724D4282DAB2dd689f93C5A245C2C4A68
    address receivingAddress;//0x0fC64d3724D4282DAB2dd689f93C5A245C2C4A68
    address callTo;
    uint256 sendingChainId;//56
    uint256 receivingChainId;//100
    bytes32 callDataHash; // hashed to prevent free option
    bytes32 transactionId;
  }
struct PrepareArgs {
    InvariantTransactionData invariantData;
    uint256 amount;//10**6
    uint256 expiry;//block.timestamp + 86400,最大为block.timestamp + 30 * 86400
    bytes encryptedCallData;
    bytes encodedBid;
    bytes bidSignature;
    bytes encodedMeta;
  }

  Man[] public persons;

  constructor() public {
    // IDCard memory card = IDCard({number: 15245});
    persons.push(Man({
      card: IDCard({number: 15245}), 
      name: "mame", 
      age: 11
      }));
    // persons.push(Man("mame1", 22));
  }

  // ["aa",1]
  function addMan(Man memory man) public {
    persons.push(man);
  }
  function addManPrepareArgs(PrepareArgs calldata args) public {
    // persons.push(man);
  }
  //  [["aa",1],["a2",2]]
  function addMen(Man[] memory men) public {
    for (uint256 i = 0; i < men.length; i++) {
      persons.push(men[i]);
    }
  }

  function getMen() public view returns (Man[] memory) {
    return persons;
  }
}