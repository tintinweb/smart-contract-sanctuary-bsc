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
import './Storage.sol';
import './Access.sol';
import './Events.sol';
import './UUPS.sol';

contract Prosper365Init is DataStorage, Access, Events, UUPS {

  constructor() {
    owner = msg.sender;
  
    Storage.getAddress(0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103).value = owner; //keccak-256 hash of "eip1967.proxy.admin" subtracted by 1

    reEntryStatus = ENTRY_ENABLED;
    contractStatus = false;
    remoteStatus = false;
  }

  function setSystemReceiver(address _addr) external contractMaintenance() isOwner(msg.sender) {
    systemReceiver = _addr;
  }

  function setExchangeHandler(address _addr) external contractMaintenance() isOwner(msg.sender) {
    exchangeHandler = _addr;
  }

  function setProsper365Handler(address _addr) external contractMaintenance() isOwner(msg.sender) {
    prosper365Contract = _addr;
  }

  function setRemoteHandler(address _addr) external contractMaintenance() isOwner(msg.sender) {
    remoteHandler = _addr;
  }

  function setExchangeRateTimeout(uint _secondsTimeout) external contractMaintenance() isOwner(msg.sender) {
    exchangeRateTimeout = _secondsTimeout;
  }

  function addPackage(uint _cost, uint _unpaidTier, uint _matchBonus, uint _matrix, uint _system) external contractMaintenance() isOwner(msg.sender) {
    require((packageCost[topPackage].cost < _cost), "E10");
    require((_matrix + _system + _unpaidTier + _matchBonus) == 100, "E24");

    topPackage++;

    packageCost[topPackage] = Package({cost: _cost, tierUnpaid: _unpaidTier, matchBonus: _matchBonus, matrix: _matrix, system: _system});    

    (bool success, ) = prosper365Contract.delegatecall(abi.encodeWithSignature("finalizeAddPackage()"));

    require(success, "E5");

    members[idToMember[1]].ownPackage[topPackage] = true;
  }

  function updatePackageCost(uint _package, uint _cost, uint _unpaidTier, uint _matchBonus, uint _matrix, uint _system) external contractMaintenance() isOwner(msg.sender) {
    require((_package > 0 && _package <= topPackage), "E11");
    require((_cost > 0), "E10");
    require((_matrix + _system + _unpaidTier + _matchBonus) != 100, "E33");

    if (_package > 1) {
      require((packageCost[(_package - 1)].cost < _cost), "E10");
    }

    if (_package < topPackage) {
      require((packageCost[(_package + 1)].cost > _cost), "E10");
    }

    packageCost[_package] = Package({cost: _cost, tierUnpaid: _unpaidTier, matchBonus: _matchBonus, matrix: _matrix, system: _system});
  }

  function init(address _addr) external contractMaintenance() isOwner(msg.sender) {
    require(lastId == 0, "E14");
    require(prosper365Contract != address(0x0), "E5");

    (bool success, ) = prosper365Contract.delegatecall(abi.encodeWithSignature("finalizeCreateAccount(address)", _addr));

    require(success == true, "E5");

    (success, ) = prosper365Contract.delegatecall(abi.encodeWithSignature("finalizeAddPackage()"));

    require(success, "E6");
    
    members[_addr].ownPackage[1] = true;
  }

  function preInit() external {
    require(topPackage == 0, "E14");

    owner = Storage.getAddress(0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103).value; //keccak-256 hash of "eip1967.proxy.admin" subtracted by 1
    
    require(owner == msg.sender, "E3");

    reEntryStatus = ENTRY_ENABLED; 
    contractStatus = false;
    remoteStatus = false;

    exchangeRateTimeout = 900;

    matrixRow[1] = Row({start: 1, end: 2, total: 2});
    matrixRow[2] = Row({start: 3, end: 6, total: 4});

    packageCost[1] = Package({cost: 5000, tierUnpaid: 5, matchBonus: 45, matrix: 45, system: 5});
    topPackage = 1;
  }
}