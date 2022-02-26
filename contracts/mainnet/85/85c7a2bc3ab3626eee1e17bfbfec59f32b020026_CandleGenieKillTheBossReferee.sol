/**
 *Submitted for verification at BscScan.com on 2022-02-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

/*

      ___           ___           ___           ___           ___       ___                    ___           ___           ___                       ___     
     /\  \         /\  \         /\__\         /\  \         /\__\     /\  \                  /\  \         /\  \         /\__\          ___        /\  \    
    /::\  \       /::\  \       /::|  |       /::\  \       /:/  /    /::\  \                /::\  \       /::\  \       /::|  |        /\  \      /::\  \   
   /:/\:\  \     /:/\:\  \     /:|:|  |      /:/\:\  \     /:/  /    /:/\:\  \              /:/\:\  \     /:/\:\  \     /:|:|  |        \:\  \    /:/\:\  \  
  /:/  \:\  \   /::\~\:\  \   /:/|:|  |__   /:/  \:\__\   /:/  /    /::\~\:\  \            /:/  \:\  \   /::\~\:\  \   /:/|:|  |__      /::\__\  /::\~\:\  \ 
 /:/__/ \:\__\ /:/\:\ \:\__\ /:/ |:| /\__\ /:/__/ \:|__| /:/__/    /:/\:\ \:\__\          /:/__/_\:\__\ /:/\:\ \:\__\ /:/ |:| /\__\  __/:/\/__/ /:/\:\ \:\__\
 \:\  \  \/__/ \/__\:\/:/  / \/__|:|/:/  / \:\  \ /:/  / \:\  \    \:\~\:\ \/__/          \:\  /\ \/__/ \:\~\:\ \/__/ \/__|:|/:/  / /\/:/  /    \:\~\:\ \/__/
  \:\  \            \::/  /      |:/:/  /   \:\  /:/  /   \:\  \    \:\ \:\__\             \:\ \:\__\    \:\ \:\__\       |:/:/  /  \::/__/      \:\ \:\__\  
   \:\  \           /:/  /       |::/  /     \:\/:/  /     \:\  \    \:\ \/__/              \:\/:/  /     \:\ \/__/       |::/  /    \:\__\       \:\ \/__/  
    \:\__\         /:/  /        /:/  /       \::/__/       \:\__\    \:\__\                 \::/  /       \:\__\         /:/  /      \/__/        \:\__\    
     \/__/         \/__/         \/__/         ~~            \/__/     \/__/                  \/__/         \/__/         \/__/                     \/__/  
     
  
                                                                CG KILL THE BOSS REFEREE 2.0
                                                                     
                                                                   https://candlegenie.io


*/


//CONTEXT
abstract contract Context 
{
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

//OWNABLE
abstract contract Ownable is Context 
{
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() { address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function OwnershipRenounce() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function OwnershipTransfer(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract CandleGenieKillTheBoss 
{
    enum Status {Idle, Punching , Impacted, Refunded}

    struct Punch 
    {
        address user;
        uint256 id;
        uint256 punchTimestamp;
        uint256 impactTimestamp;
        uint256 punchAmount;
        uint256 rewardAmount;
        bool paid;
        Status status;
    }

  	function Impact(uint256 id, uint256 amount) external virtual; 
    function getPunch(uint256 id) external virtual view returns (Punch memory);
}

abstract contract CandleGenieKillTheBossController 
{
    function Resolve(uint256 id) external virtual; 
}


contract CandleGenieKillTheBossReferee is Ownable
{

    CandleGenieKillTheBoss internal gameContract;
    CandleGenieKillTheBossController internal controllerContract;

    constructor(address _gameContractAddress) 
    {
        gameContract = CandleGenieKillTheBoss(_gameContractAddress);
    }

    modifier onlyControllerContract() 
    {
        require(msg.sender == address(controllerContract), "Only controller contract allowed");
        _;
    }

    modifier onlyGameContract() 
    {
        require(msg.sender == address(gameContract), "Only game contract allowed");
        _;
    }
    
    function SetControllerContract(address _controllerAddress) external onlyOwner 
    {
        controllerContract = CandleGenieKillTheBossController(_controllerAddress);
    }

    // -------------------------
    // START ----------------
    //--------------------------
    function Resolve(uint256 id, uint256 maxRewardMultiplier) external onlyGameContract
    {
        controllerContract.Resolve(id);
    }

    // -------------------------
    // FALLBACK ----------------
    //--------------------------
    function Impact(uint256 id, uint256 reward) external onlyControllerContract
    {
        gameContract.Impact(id, reward);
    }

}