/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


contract Betiract is Ownable{
    // Variables
   
    mapping(uint256 => _Match) private matches;
    uint256 private matchCount;
    uint256 private _feepercent;
    
    mapping(uint256 => bool) private notFirstTime;   

     mapping(uint256 => uint256) private winningside;       

    mapping(uint256 => mapping(address => bool)) private betPlaced;
    mapping(uint256 => mapping(uint => uint256)) private betamt;

    mapping(uint256 => mapping(uint256 => address[] )) private bets; 
    mapping(uint256 => mapping(address => uint256)) private betmadebyaddress; 
    
    // Events
    event BetMade(address user, uint256 matchid, uint256 teamid, uint256 amount,uint256 timestamp);
    event Received(address user, uint value);
     
     event Match(
        uint256 id,
        uint256 timestamp
    );
 

    // Structs
    struct _Bet {
        address user;
        uint256 matchid;
        uint256 teamid;
        uint256 amount;
        uint256 timestamp;
    }

     struct _Match {
        uint256 id;
        uint256 timestamp;
    }

    constructor ()  {
        _feepercent = 1;
    }


    receive() external payable{
        emit Received(msg.sender, msg.value);
        
    }

    function SetFeePercent(uint256 feepercent) external onlyOwner {
        _feepercent = feepercent;
    }

    function isOpen(uint256 _matchid) external view returns(bool) {
            return notFirstTime[_matchid];
    }


    function getFeePercent() external view returns(uint256) {
            return _feepercent;
    }


    function NoOfBetsPlaced(uint256 _matchid, uint256 _teamid) external view returns(uint256){
        return bets[_matchid][_teamid].length;
    }

      function PlaceBet(uint256 _matchid, uint256 _teamid, uint256 _amount, uint256 _matchtime) payable public {
        require(block.timestamp <= _matchtime, 'Error, Match has started');
        require(_matchid >= 0, 'Error,Negative Match id');
        require(!betPlaced[_matchid][msg.sender], 'Error, Bet already Placed');
        require(msg.value >= _amount,'Error,Wrong Value');
        
        if(!notFirstTime[_matchid]){
            matches[_matchid] = _Match(_matchid,block.timestamp);
            emit Match(_matchid, block.timestamp);
            notFirstTime[_matchid] = true;       }
        
        betamt[_matchid][_teamid] = betamt[_matchid][_teamid] + _amount;
        emit BetMade(msg.sender, _matchid, _teamid, _amount, block.timestamp);
        bets[_matchid][_teamid].push(msg.sender);
        betmadebyaddress[_matchid][msg.sender] = _amount;
        betPlaced[_matchid][msg.sender] = true;
    }

    function TotalAmtBettedTeamWise(uint256 _matchid, uint256 _teamid) public view returns (uint256){
        return betamt[_matchid][_teamid];
    }

    function AddressesBetted(uint256 _matchid, uint256 _teamid) external view returns (address[] memory){
        return bets[_matchid][_teamid];
    }

     function BetAmtbyAddress(uint256 _matchid, address addr) external view returns (uint256){
        return betmadebyaddress[_matchid][addr];
    }

    function WonSide(uint256 _matchid) external view returns (uint256){
        
        return winningside[_matchid];
    }

    function WonAmtByAddress(uint256 _matchid, address _address) external view returns (uint256){

        require(winningside[_matchid]!=0,'Error,Winner has not been announced');
        
        uint256 wonside = winningside[_matchid];
    
        uint256 totalbetamt = betamt[_matchid][1] + betamt[_matchid][2];
        uint256 poolamt = betamt[_matchid][wonside];
        
        uint256 _poolpercent = (betmadebyaddress[_matchid][_address]*100000000) / poolamt;
        return (_poolpercent * totalbetamt*(100 - _feepercent))/10000000000;


    }

    function WinnerDistribution(uint256 _matchid, uint256 _winningteamid) external onlyOwner  {
        uint256 totalbetamt = betamt[_matchid][1] + betamt[_matchid][2];
        uint256 poolamt = betamt[_matchid][_winningteamid];
        require(poolamt > 0 ,'Error, Pool Amount is 0');
        address[] memory users = bets[_matchid][_winningteamid];
        require(users.length > 0 ,'Error, No one made any bet');
        uint256[] memory _poolpercent = new uint256[](users.length) ;
        winningside[_matchid] = _winningteamid;


       for(uint256 i = 0; i < users.length;i++){
            _poolpercent[i] = (betmadebyaddress[_matchid][users[i]]*100000000) / poolamt;
       }
       
        for(uint256 i = 0; i < users.length; i++){
           payable(users[i]).transfer((_poolpercent[i]* totalbetamt*(100 - _feepercent))/10000000000);
        }

    }

    function MatchDrawn(uint256 _matchid) external onlyOwner{
        winningside[_matchid] = 3;
        uint256 poolamt1 = betamt[_matchid][1];
        uint256 poolamt2 = betamt[_matchid][2];
        require(poolamt1 > 0 || poolamt2>0,'Error, Pool Amount is 0');
        address[] memory users1 = bets[_matchid][1];
        address[] memory users2 = bets[_matchid][2];
        require(users1.length>0 || users2.length> 0 ,'Error, No one made any bet');
        uint256[] memory _poolpercent1 = new uint256[](users1.length) ;
        uint256[] memory _poolpercent2 = new uint256[](users2.length) ;


       for(uint256 i = 0; i < users1.length;i++){
            _poolpercent1[i] = (betmadebyaddress[_matchid][users1[i]]*100000000) / poolamt1;
       }

        for(uint256 i = 0; i < users2.length;i++){
            _poolpercent2[i] = (betmadebyaddress[_matchid][users2[i]]*100000000) / poolamt2;
       }
       
        for(uint256 i = 0; i < users1.length; i++){
           payable(users1[i]).transfer((_poolpercent1[i]* poolamt1 *(100 - _feepercent))/10000000000);
        }
        for(uint256 i = 0; i < users2.length; i++){
           payable(users2[i]).transfer((_poolpercent2[i]* poolamt2*(100 - _feepercent))/10000000000);
        }


    }

    function withdraw(address addr) public payable onlyOwner {
        payable(addr).transfer(address(this).balance);
    }
}