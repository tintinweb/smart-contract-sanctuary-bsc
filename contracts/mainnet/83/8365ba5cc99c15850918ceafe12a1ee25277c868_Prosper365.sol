// SPDX-License-Identifier: BSD-3-Clause

/**
 *  
 *         ##### ##                                                                         
 *      ######  /###                                                                        
 *     /#   /  /  ###                                                                       
 *    /    /  /    ###                                                                      
 *        /  /      ##                                                                      
 *       ## ##      ## ###  /###     /###     /###      /###     /##  ###  /###             
 *       ## ##      ##  ###/ #### / / ###  / / #### /  / ###  / / ###  ###/ #### /          
 *     /### ##      /    ##   ###/ /   ###/ ##  ###/  /   ###/ /   ###  ##   ###/           
 *    / ### ##     /     ##       ##    ## ####      ##    ## ##    ### ##                  
 *       ## ######/      ##       ##    ##   ###     ##    ## ########  ##                  
 *       ## ######       ##       ##    ##     ###   ##    ## #######   ##                  
 *       ## ##           ##       ##    ##       ### ##    ## ##        ##                  
 *       ## ##           ##       ##    ##  /###  ## ##    ## ####    / ##            n n n 
 *       ## ##           ###       ######  / #### /  #######   ######/  ###           u u u 
 *  ##   ## ##            ###       ####      ###/   ######     #####    ###          m m m 
 * ###   #  /                                        ##                               b b b 
 *  ###    /                                         ##                               e e e 
 *   #####/                                          ##                               r r r 
 *     ###                                            ##                              3 6 5 
 * 
 * Prosper 365 is the very first 100% sponsor matching bonus smart contract ever created.
 * https://www.prosper365.io
 * It’s Time To Learn, Earn, and Prosper 365!
 */
 
pragma solidity 0.8.17;

import './DataStorage.sol';
import './Access.sol';
import './Events.sol';
import './UUPS.sol';

contract Prosper365 is DataStorage, Access, Events, UUPS {

  constructor() {
    owner = msg.sender;

    reEntryStatus = ENTRY_ENABLED;
    contractStatus = false;
    remoteStatus = false;
  }

  function locatePlacedUnder(address _addr, uint _package, uint _matrixNum, uint _timestamp) internal view returns (address, uint, uint, bool) {
    F1 storage position = members[_addr].x22Positions[_package];

    uint num = position.placedCount[_matrixNum];

    for (uint i=num;i > 0;i--) {
      F1Placement memory info = position.placedUnder[_matrixNum][i];

      if (info.timestamp <= _timestamp) {
        return (info.under, info.placementSide, info.timestamp, num != i);
      }
    }

    revert('E7');
  }

  function getCommission(uint _amount, uint _percentage) internal pure returns (uint) {
    return (_amount * _percentage) / 100;
  }

  function handlePayout(address _addr, address _sponsor, address _activeSponsor, uint _package, uint _matrixNum, uint _amount) internal {
    Payout[] memory payout = new Payout[](4);

    payout = locateTierPayout(_addr, _sponsor, _package, _amount, payout);
    payout = locateBonusMatchPayout(_addr, _sponsor, _activeSponsor, _package, _amount, payout);
    payout = locateMatrixPayout(_addr, _sponsor, _activeSponsor, _package, _matrixNum, _amount, payout);

    if (packageCost[_package].system > 0) {
      payout = reviewPayout(systemReceiver, getCommission(_amount, packageCost[_package].system), payout);
    }

    for (uint num=0;num < payout.length;num++) {
      if (payout[num].amount > 0) {
        (bool success, ) = payable(payout[num].receiver).call{ value: payout[num].amount, gas: 20000 }("");

        if (success == false) { //Failsafe to prevent malicious contracts from blocking
          (success, ) = payable(members[idToMember[1]].payoutTo).call{ value: payout[num].amount, gas: 20000 }("");
          require(success, "E12");
        }
      }
    }
  }

  function locateTierPayout(address _addr, address _directSponsor, uint _package, uint _amount, Payout[] memory _payout) internal returns (Payout[] memory) {
    uint amount = getCommission(_amount, packageCost[_package].tierUnpaid);
    
    _payout = reviewPayout(members[_directSponsor].payoutTo, amount, _payout);

    emit CommissionTierUnpaid(_directSponsor, _addr, _package, amount, orderId);
    
    return _payout;
  }

  function locateBonusMatchPayout(address _addr, address _directSponsor, address _activeSponsor, uint _package, uint _amount, Payout[] memory _payout) internal returns (Payout[] memory) {
    address receiver = _activeSponsor;

    if (members[_directSponsor].ownPackage[1] == true) {
      receiver = _directSponsor;
    }

    uint amount = getCommission(_amount, packageCost[_package].matchBonus);
    
    _payout = reviewPayout(members[receiver].payoutTo, amount, _payout);

    emit CommissionBonusMatch(receiver, _addr, _package, amount, orderId);
    
    return _payout;
  }

  function locateMatrixPayout(address _addr, address _directSponsor, address _activeSponsor, uint _package, uint _matrixNum, uint _amount, Payout[] memory _payout) internal returns (Payout[] memory) {
    address from = _addr;
    address receiver = _activeSponsor;    
    uint amount = getCommission(_amount, packageCost[_package].matrix);

    if (_directSponsor != _activeSponsor) {
      emit PassupMatrix(_directSponsor, _addr, _package, amount, orderId);
    }

    if (members[_addr].x22Positions[_package].position < 3) {      
      (receiver, , , ) = locatePlacedUnder(receiver, _package, _matrixNum, block.timestamp);      
    }

    if (members[receiver].x22Positions[_package].cycleInitiated == true) {
      while (members[receiver].x22Positions[_package].cycleInitiated == true) {
        from = receiver;

        members[receiver].x22Positions[_package].cycleInitiated = false;

        receiver = members[receiver].x22Positions[_package].sponsor;
      }

      if (members[from].x22Positions[_package].position < 3) {
        (receiver, , , ) = locatePlacedUnder(receiver, _package, members[receiver].x22Positions[_package].matrixNum, members[receiver].x22Positions[_package].timestamp);      
      }      
    }

    _payout = reviewPayout(members[receiver].payoutTo, amount, _payout);
 
    emit CommissionMatrix(receiver, from, _package, amount, orderId);

    return _payout;
  }

  function reviewPayout(address _addr, uint _amount, Payout[] memory _payout) internal pure returns (Payout[] memory) {

    for (uint i=0;i < _payout.length;i++) {
      if (_addr == _payout[i].receiver) {
        _payout[i].amount += _amount;
        break;
      } else if (_payout[i].amount == 0) {
        _payout[i] = Payout({receiver: _addr, amount: _amount});
        break;
      }
    }

    return _payout;
  }

  function createPosition(address _addr, address _sponsor, uint _package, bool _cycle) internal {
    (uint row, uint matrixNum, uint position, uint placementSide) = locatePosition(_sponsor, _package);
     
    address placedUnder = getPlacedUnder(_sponsor, _package, position);
    uint depth = members[placedUnder].x22Positions[_package].depth + 1;

    if (_cycle == false) {
      createPositionRecord(_addr, _sponsor, _package, position, depth, placementSide, matrixNum, placedUnder);
    } else {
      updatePositionRecord(_addr, _package, position, depth, placementSide, matrixNum, placedUnder, true);
    }

    updatePosition(_addr, _sponsor, _package, row, position, true);

    emit Placement(_addr, _sponsor, _package, matrixNum, position, placedUnder, _cycle, orderId);

    if (depth == 1) {
      return;
    }

    createPlacement(_addr, _sponsor, _package, depth, matrixNum);
  }

  function createPlacement(address _addr, address _sponsor, uint _package, uint _depth, uint _matrixNum) internal {
    uint num = 2;
    uint total = 3;
    uint row_depth = 2;
  
    uint[] memory sides = new uint[](6);
    address[] memory sponsors = new address[](6);

    if (_depth < 2) {
      num = _depth;
      total = _depth + 1;
      row_depth = _depth;
    }
      
    address account = _addr;
    uint timestamp = block.timestamp;
  
    for (;num > 0;num--) {
      (account, sides[num], timestamp, ) = locatePlacedUnder(account, _package, _matrixNum, timestamp);  

      require(sides[num] > 0, "E26");

      sponsors[num] = account;
    }
    
    uint position;

    for (num = 1;num < total;num++) {
      if (sponsors[num] == _sponsor) {
        row_depth--;
        continue;
      }

      position = sides[num];

      for (uint i = (num+1);i < total;i++) {
        position = (position * 2) + sides[i];
      }

      updatePosition(_addr, sponsors[num], _package, row_depth--, position, false);

      checkIfCycle(_addr, sponsors[num], _package);
    }

    checkIfCycle(_addr, _sponsor, _package);
  }

  function checkIfCycle(address _from, address _addr, uint _package) internal {
    F1 storage position = members[_addr].x22Positions[_package];

    if (position.rows[2] < matrixRow[2].total) {
      return;
    }

    cycleId++;

    emit Cycle(_addr, _from, _package, cycleId, orderId);

    if (_addr == idToMember[1]) {
      updatePositionRecord(_addr, _package, 0, 0, 0, (position.matrixNum + 1), _addr, false);
    } else {      
      address sponsor = members[_addr].sponsor;

      if (sponsor != position.sponsor && members[sponsor].ownPackage[_package] == true) {
        position.reEntryCheck++;
      
        if (position.reEntryCheck >= REENTRY_REQ) {
          position.sponsor = sponsor;
          position.reEntryCheck = 0;
          
          emit PlacementReEntry(sponsor, _addr, _package, orderId);
        }
      }

      createPosition(_addr, position.sponsor, _package, true);
    }
  }

 function getPlacedUnder(address _addr, uint _package, uint _position) internal view returns (address) {
    if (_position <= 2) {
      return _addr;
    }

    uint position = (_position <= 4)?1:2;

    return members[_addr].x22Positions[_package].x22Matrix[position];
  }
  
  function updatePosition(address _addr, address _sponsor, uint _package, uint _row, uint _position, bool updateLastPosition) internal {
    F1 storage position = members[_sponsor].x22Positions[_package];

    require(position.x22Matrix[_position] == address(0x0), "E28");

    position.rows[_row]++;
    position.x22Matrix[_position] = _addr;

    if (updateLastPosition == true) {
      position.lastPlacedPosition = _position;
    }
  }

  function locatePosition(address _addr, uint _package) internal view returns (uint, uint, uint, uint) {
    F1 storage matrix = members[_addr].x22Positions[_package];    

    uint row;
    uint total = 2;
    uint position;

    for (row = 1; row <= total; row++) {
      if (matrix.rows[row] >= matrixRow[row].total) {
        continue;
      }

      position = matrixRow[row].start;
      total = matrixRow[row].end;
      break;
    }

    if (matrix.lastPlacedPosition > position) {
      position = matrix.lastPlacedPosition + 1;
    }

    for(; position <= total; position++) {
        if (matrix.x22Matrix[position] != address(0x0)) {
          continue;
        }

        break;
      }

    require(position <= total, "E27");

    return(row, matrix.matrixNum, position, ((position % 2 == 0)?2:1));
  }

  function findActiveSponsor(address _addr, address _sponsor, uint _package, bool _emit) internal returns (address) {
    address sponsorAddress = _sponsor;

    while (true) {
      if (members[sponsorAddress].ownPackage[_package] == true) {
        return sponsorAddress;
      }

      if (_emit == true) {
        emit Passup(sponsorAddress, _addr, _package, orderId);
      }

      sponsorAddress = members[sponsorAddress].sponsor;
    }

    revert('E7');
  }

  function handlePackagePurchase(address _addr, uint _package, uint _amount, bool _handlePayout) internal {
    require((_package > 0 && _package <= topPackage), "E11");
    require(members[_addr].ownPackage[_package] != true, "E23");    

    if (_handlePayout == true) {
      require(confirmReceivedAmount(_amount, packageCost[_package].cost) == true, "E16");
    }
  
    orderId++;

    if (members[_addr].accountType == TYPE_AFFILIATE) {
      members[_addr].accountType = TYPE_MEMBER;

      emit AccountChange(_addr, TYPE_MEMBER, orderId);
    }

    handlePosition(_addr, members[_addr].sponsor, _package, _amount, _handlePayout);

    emit Upgrade(_addr, members[_addr].x22Positions[_package].sponsor, _package, members[_addr].accountType, orderId);
  }

  function purchasePackage(uint _package) external payable isMember(msg.sender) contractEnabled() blockReEntry() {
    handlePackagePurchase(msg.sender, _package, msg.value, true);
  }

  function purchaseBundle(uint[] calldata _packages) external payable isMember(msg.sender) contractEnabled() blockReEntry() {
    uint cost = 0;

    for (uint i=1;i < _packages.length;i++) {
      if (_packages[i] > 0) {
        cost += _packages[i];
      }
    }

    require(cost == msg.value, "E10");

    for (uint i=1;i < _packages.length;i++) {
      if (_packages[i] > 0) {
        handlePackagePurchase(msg.sender, i, _packages[i], true);
      }
    }
  }

  function preRegistration(address _addr, address _sponsor, uint _package, uint _type) internal contractEnabled() {
    require(confirmReceivedAmount(msg.value, packageCost[_package].cost) == true, "E16");

    lastId++;

    createAccount(lastId, _addr, _sponsor, _type, false);

    handlePosition(_addr, _sponsor, _package, msg.value, true);
  }

  function handlePosition(address _addr, address _sponsor, uint _package, uint _amount, bool _handlePayout) internal {
    address activeSponsor = findActiveSponsor(_addr, _sponsor, _package, true);
    
    members[_addr].ownPackage[_package] = true;

    createPosition(_addr, activeSponsor, _package, false);    

    if (_handlePayout == true) {        
      handlePayout(_addr, _sponsor, activeSponsor, _package, members[_addr].x22Positions[_package].matrixNum, _amount);
    }
  }

  function createPositionRecord(address _addr, address _sponsor, uint _package, uint _position, uint _depth, uint _placementSide, uint _matrixNum, address _placedUnder) internal {
    F1 storage position = members[_addr].x22Positions[_package];

    position.sponsor = _sponsor;
    position.position = _position;
    position.lastPlacedPosition = 0;
    position.cycleInitiated = false;
    position.matrixNum = _matrixNum;
    position.timestamp = block.timestamp;    
    position.depth = _depth;
    position.reEntryCheck = 0;
    position.placedCount[_matrixNum] = 1;
    position.placedUnder[_matrixNum][1] = F1Placement({timestamp: block.timestamp, under: _placedUnder, placementSide: _placementSide});
    position.rows = new uint[](6);
  }

  function updatePositionRecord(address _addr, uint _package, uint _position, uint _depth, uint _placementSide, uint _matrixNum, address _placedUnder, bool _cycle) internal {
    F1 storage position = members[_addr].x22Positions[_package];

    position.position = _position;
    position.lastPlacedPosition = 0;
    position.cycleInitiated = _cycle;    
    position.matrixNum = _matrixNum;
    position.timestamp = block.timestamp;
    position.depth = _depth;    
    position.placedCount[_matrixNum]++;
    position.placedUnder[_matrixNum][position.placedCount[_matrixNum]] = F1Placement({timestamp: block.timestamp, under: _placedUnder, placementSide: _placementSide});
    position.rows = new uint[](3);

    for (uint i=1;i < 7;i++) {
      delete position.x22Matrix[i];
    }
  }

  function confirmReceivedAmount(uint _amount, uint _cost) internal view returns (bool) {
    require((block.timestamp - exchangeRateTimeout) < exchangeRateUpdated, "E7");

    if (calculateCost(_amount, _cost, exchangeRate) == true) {
      return true;
    }

    return calculateCost(_amount, _cost, exchangeRatePrevious);
  }

  function calculateCost(uint _amount, uint _cost, uint _exchangeRate) internal pure returns (bool) {
    return _amount == ((_cost * _exchangeRate) / 100);
  }

  function createAccount(uint _memberId, address _addr, address _sponsor, uint _type, bool _initial) internal {
    require(members[_addr].id == 0, "E22");
    require(_initial == true || members[_sponsor].id > 0, "E21");

    orderId++;

    Account storage member = members[_addr];

    member.id = _memberId;
    member.sponsor = _sponsor;
    member.payoutTo = _addr;
    member.accountType = _type;

    idToMember[_memberId] = _addr;

    emit Registration(_addr, _memberId, _sponsor, _type, orderId);
  }

  function registration(address _sponsor) external payable blockReEntry() {
    preRegistration(msg.sender, _sponsor, 1, TYPE_MEMBER);
  }

  fallback() external payable blockReEntry() {
    preRegistration(msg.sender, bytesToAddress(msg.data), 1, TYPE_MEMBER);
  }

  receive() external payable blockReEntry() {
    preRegistration(msg.sender, idToMember[1], 1, TYPE_MEMBER);
  }

  function createAffiliate(address _sponsor) external contractEnabled() blockReEntry() {
    lastId++;

    createAccount(lastId, msg.sender, _sponsor, TYPE_AFFILIATE, false);
  }

  function setupAccount(address _addr, address _sponsor, uint _type) external payable isRemoteHandler(msg.sender) remoteEnabled() blockReEntry() {
    require(_type == TYPE_AFFILIATE || confirmReceivedAmount(msg.value, packageCost[1].cost) == true, "E16");
    require(_type == TYPE_MEMBER || _type == TYPE_AFFILIATE, "E15");

    lastId++;

    createAccount(lastId, _addr, _sponsor, _type, false);

    if (_type == TYPE_MEMBER) {      
      handlePosition(_addr, _sponsor, 1, msg.value, true);
    }
  }

  function setupUpgrade(address _addr, uint _package) external payable isRemoteHandler(msg.sender) isMember(_addr) remoteEnabled() blockReEntry() {
    handlePackagePurchase(_addr, _package, msg.value, true);
  }

  function compAccount(address _addr, address _sponsor) external isOwner(msg.sender) {    
    lastId++;

    createAccount(lastId, _addr, _sponsor, TYPE_MEMBER, false);
    handlePosition(_addr, _sponsor, 1, 0, false);    
  }

  function compPackage(address _addr, uint _package, uint _toPackage) external isOwner(msg.sender) isMember(_addr) {
    if (_package > 0) {
      handlePackagePurchase(_addr, _package, 0, false);
    } else if (_toPackage > 1) {
      for (uint num=2;num <= _toPackage;num++) {
        if (members[_addr].ownPackage[num] != true) {
          handlePackagePurchase(_addr, num, 0, false);
        }
      }
    }
  }

  function bytesToAddress(bytes memory _source) internal pure returns (address addr) {
    assembly {
      addr := mload(add(_source, 20))
    }
  }

  function changeContractStatus() external isOwner(msg.sender) {
    contractStatus = !contractStatus;
  }

  function changeRemoteStatus() external isOwner(msg.sender) {
    remoteStatus = !remoteStatus;
  }

  function setExchangeRate(uint rate) public isExchangeHandler(msg.sender) {
    exchangeRateUpdated = block.timestamp;
    exchangeRatePrevious = exchangeRate;
    exchangeRate = rate;
  }
  
  function finalizeAddPackage() external contractMaintenance() isOwner(msg.sender) {
    require(members[idToMember[1]].ownPackage[topPackage] == false, "E13");

    createPositionRecord(idToMember[1], idToMember[1], topPackage, 0, 0, 0, 1, idToMember[1]);
  }

  function finalizeCreateAccount(address _addr) external contractMaintenance() isOwner(msg.sender) {
    require(lastId == 0, "E14");

    lastId++;

    createAccount(lastId, _addr, _addr, TYPE_MEMBER, true); 
  }

  function getPackageCost(uint _package) public view returns (uint) {
    return (packageCost[_package].cost * exchangeRate) / 100;
  }

  function getBundleCost(uint _package) external view returns (uint, uint[] memory) {
    require((_package > 0 && _package <= topPackage), "E11");

    uint cost;
    uint total = 0;
    uint[] memory amount = new uint[](_package + 1);

    for (uint num = 1;num <= _package;num++) {
      if (members[msg.sender].ownPackage[num] != true) {
        cost = getPackageCost(num);

        total += cost;
        amount[num] = cost;
      }
    }

    return (total, amount);
  }

  function ownPackage(address _addr, uint _package) external view returns (bool) {
    return members[_addr].ownPackage[_package];
  }

  function ownPackages(address _addr) external view returns (bool[] memory) {
    bool[] memory own = new bool[](topPackage + 1);

    for (uint i=1;i < (topPackage + 1);i++) {
      own[i] = members[_addr].ownPackage[i];
    }
    
    return own;
  }

  function getContractStatus() external view returns (bool, bool) {
    return (contractStatus, remoteStatus);
  }

  function getExchangeRate() external view returns (uint, uint) {
    return (exchangeRate, exchangeRateUpdated);
  }

  function getSettings() external view returns (uint) {
    return topPackage;
  }

  function getSystemPositions() external view returns (uint, uint, uint) {  
    return (lastId, cycleId, orderId);
  }

  function getPackageInfo(uint _package) external view returns (Package memory) {
    return packageCost[_package];
  }

  function getIdToMember(uint _id) external view returns (address) {
    return idToMember[_id];
  }

  function getMember(address _addr) external view returns (uint, address, uint) {
    require(members[_addr].id > 0, "E20");
    
    return (members[_addr].id, members[_addr].sponsor, members[_addr].accountType);
  }

  function getMemberMatrix(address _addr, uint _package) external view returns (address, uint, uint, uint, uint, uint) {
    require(members[_addr].id > 0, "E20");

    F1 storage position = members[_addr].x22Positions[_package];

    return (position.sponsor, position.matrixNum, position.position, position.depth, position.lastPlacedPosition, position.lastCycleId);
  }
}